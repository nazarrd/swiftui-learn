//
//  BrowseView.swift
//  LearnSwift
//
//  Created by Nazar on 16/08/23.
//

import SwiftUI
import AVKit

struct VideoData: Decodable, Identifiable {
    let id: String
    let path: String
    let createdAt: TimeInterval
    var isPlaying: Bool?
}

struct BrowseView: View {
    @State private var videoData: [VideoData] = []
    @State private var isLoading = false
    @State private var currentPage = 0
    @State private var token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.QXVYWHhyaWN0N1dJcHREZ3Bxd3NNZz09.Hgvi2Tcl49nwiFL2YDzW0G0KfrpGAqd2u0ijWZmsuzY"
    @State private var isPickerPresented = false
    @State private var selectedVideo: URL? = nil
    
    var body: some View {
        ZStack {
            VerticalPager(pageCount: videoData.count, currentIndex: $currentPage) {
                ForEach(Array(videoData.enumerated()), id: \.element.id) { index, video in
                    VideoView(videoPath: video.path, isPlaying: Binding(
                        get: { videoData[index].isPlaying ?? false },
                        set: { newValue in
                            videoData[index].isPlaying = newValue
                        }
                    ))
                    .id(video.id)
                }
            }
            
            if isLoading {
                ProgressView().scaleEffect(2)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        isPickerPresented = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                            .padding([.bottom, .trailing], 10.0)
                    }
                    .sheet(isPresented: $isPickerPresented, onDismiss: {
                        if let selectedVideo = selectedVideo {
                            let url = URL(string: "http://localhost:8080/v1/video")!
                            
                            var request = URLRequest(url: url)
                            request.httpMethod = "POST"
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            request.setValue(token, forHTTPHeaderField: "Authorization")
                            
                            let parameters: [String: Any] = [
                                "format": selectedVideo.pathExtension,
                                "video": convertVideoToBase64(from: selectedVideo)!
                            ]
                            
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                                request.httpBody = jsonData
                                
                                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                                    if let data = data {
                                        if let responseString = String(data: data, encoding: .utf8) {
                                            print("Response: \(responseString)")
                                            loadVideoData()
                                        }
                                    }
                                    if let error = error {
                                        print("Error: \(error)")
                                    }
                                }
                                
                                task.resume()
                            } catch {
                                print("Error creating JSON data: \(error)")
                            }
                        }
                    }) {
                        ImagePickerView(sourceType: .photoLibrary, mediaType: .movie) { video in
                            selectedVideo = video
                        }
                    }
                    .padding()
                }
            }
        }
//        .background(Color.black)
        .ignoresSafeArea(.container, edges: .vertical)
        .onAppear {
            loadVideoData()
        }
        .onChange(of: currentPage) { newValue in
            // Pause other videos when changing the page
            videoData.indices.forEach { index in
                if index != newValue {
                    videoData[index].isPlaying = false
                } else {
                    videoData[index].isPlaying = true
                }
            }
        }
//        .navigationBarBackButtonHidden(true)
    }
    
    func convertVideoToBase64(from fileURL: URL) -> String? {
        do {
            let videoData = try Data(contentsOf: fileURL)
            let base64String = videoData.base64EncodedString()
            return base64String
        } catch {
            print("Error converting video to base64: \(error)")
            return nil
        }
    }
    
    func loadVideoData() {
        guard let url = URL(string: "http://localhost:8080/v1/video") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                // Print the response body as a string
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let videoDataArray = responseJSON?["data"] as? [[String: Any]] {
                        let videoArray = try JSONDecoder().decode([VideoData].self, from: JSONSerialization.data(withJSONObject: videoDataArray))

                        DispatchQueue.main.async {
                            self.videoData = videoArray.enumerated().map { index, video in
                                var mutableVideo = video
                                mutableVideo.isPlaying = index == 0 // Set to true for the first video, false for the rest
                                return mutableVideo
                            }
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
            isLoading = false
        }.resume()
    }
}

struct VideoView: View {
    let videoPath: String
    @State private var player = AVPlayer()
    @Binding var isPlaying: Bool
    
    var body: some View {
        GeometryReader { geometry in
            PlayerWrapper(player: player, isPlaying: $isPlaying, onTap: {
                isPlaying.toggle()
            })
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: videoPath)!))
                player.play()
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                    player.seek(to: .zero)
                    player.play()
                }
            }
            .onDisappear {
                player.pause()
            }
        }
    }
}

struct PlayerWrapper: UIViewRepresentable {
    let player: AVPlayer
    @Binding var isPlaying: Bool
    var onTap: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let playerView = PlayerView(player: player)
        context.coordinator.playerView = playerView // Pass the PlayerView reference to the coordinator
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        playerView.addGestureRecognizer(tapGesture)
        return playerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the playback state and play/pause the player accordingly
        if isPlaying {
            player.play()
            context.coordinator.playerView?.hidePlayButton()
        } else {
            player.pause()
            context.coordinator.playerView?.showPlayButton()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: PlayerWrapper
        weak var playerView: PlayerView? // Store a weak reference to the PlayerView
        
        init(_ parent: PlayerWrapper) {
            self.parent = parent
        }
        
        @objc func handleTap() {
            parent.onTap()
        }
    }
}

class PlayerView: UIView {
    private var playerLayer: AVPlayerLayer?
    private var playButtonImageView: UIImageView?
    
    init(player: AVPlayer) {
        super.init(frame: .zero)
        playerLayer = AVPlayerLayer(player: player)
        if let playerLayer = playerLayer {
            layer.addSublayer(playerLayer)
        }
        
        playButtonImageView = UIImageView(image: UIImage(systemName: "play.circle.fill"))
        if let playButtonImageView = playButtonImageView {
            addSubview(playButtonImageView)
            playButtonImageView.contentMode = .scaleAspectFit
            playButtonImageView.tintColor = .white
            playButtonImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                playButtonImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                playButtonImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                playButtonImageView.widthAnchor.constraint(equalToConstant: 50),
                playButtonImageView.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    func showPlayButton() {
        playButtonImageView?.isHidden = false
    }
    
    func hidePlayButton() {
        playButtonImageView?.isHidden = true
    }
}

struct VerticalPager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let content: Content
    
    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }
    
    @GestureState private var translation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            LazyVStack(spacing: 0) {
                self.content.frame(width: geometry.size.width, height: UIScreen.main.bounds.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primary.opacity(0.000000001))
            .offset(y: -CGFloat(self.currentIndex) * UIScreen.main.bounds.height)
            .offset(y: self.translation)
            .animation(.interactiveSpring(response: 0.3), value: currentIndex)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture(minimumDistance: 1).updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let offset = -Int(value.translation.height)
                    if abs(offset) > 20 {
                        let newIndex = currentIndex + min(max(offset, -1), 1)
                        if newIndex >= 0 && newIndex < pageCount {
                            self.currentIndex = newIndex
                        }
                    }
                }
            )
        }
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var mediaType: MediaType
    var completionHandler: (URL) -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = [mediaType.rawValue]
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let mediaURL = info[.mediaURL] as? URL {
                parent.completionHandler(mediaURL)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    enum MediaType: String {
        case image = "public.image"
        case movie = "public.movie"
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
    }
}
