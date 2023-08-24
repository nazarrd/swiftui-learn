//
//  ScreenShotView.swift
//  LearnSwift
//
//  Created by Nazar on 22/08/23.
//

import SwiftUI
import UIKit

struct ScreenShotView: View {
    @State private var isImagePopupVisible = false
    
    var body: some View {
        ZStack(alignment: .center) {
            RemoteImage(url: "https://picsum.photos/512")
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width)
            
            if !isImagePopupVisible {
                VStack {
                    Spacer()
                    Button("Share Screen") { isImagePopupVisible = true }
                        .padding(.bottom, 30.0)
                }
            }
            
            if isImagePopupVisible {
                PlaceListView(
                    isImagePopupVisible: $isImagePopupVisible,
                    data: PlacelistData(
                        title: "Bakmi Jakarta Pusat",
                        subtitle: "Kumpulan bakmi terenak di Jakarta Pusat",
                        userdata: UserData(
                            name: "Hasan Silalahi",
                            photo: "https://picsum.photos/16"
                        ),
                        images: [
                            PlaceData(
                                name: "Bakmi Roxy Cikini",
                                photo: "https://picsum.photos/296/72",
                                rating: 5.0
                            ),
                            PlaceData(
                                name: "Bakmi TipTop Pasar Senen",
                                photo: "https://picsum.photos/296/72",
                                rating: 4.5
                            ),
                            PlaceData(
                                name: "Bakmi Luwes St. Sudirman",
                                photo: "https://picsum.photos/296/72",
                                rating: 5.0
                            ),
                            PlaceData(
                                name: "Bakmi Roxy Sabang",
                                photo: "https://picsum.photos/296/72",
                                rating: 4.8
                            ),
                            PlaceData(
                                name: "Bakmi BBT",
                                photo: "https://picsum.photos/296/72",
                                rating: 4.0
                            )
                        ],
                        places: 5,
                        likes: 123,
                        shares: 88
                    )
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        takeScreenshot()
                    }
                }
//                ImagePopupView(
//                    image: screenshotImage,
//                    isImagePopupVisible: $isImagePopupVisible
//                )
            }
        }
        .navigationBarBackButtonHidden(isImagePopupVisible)
        .ignoresSafeArea(.container, edges: .vertical)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
            takeScreenshot()
        }
    }
}

struct RemoteImage: View {
    var url: String
    
    @State private var image: UIImage? = nil
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .onAppear(perform: loadImage)
        } else {
            ProgressView().scaleEffect(2)
                .onAppear(perform: loadImage)
        }
    }
    
    private func loadImage() {
        guard let imageURL = URL(string: url) else {
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, _, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async { self.image = uiImage }
            }
        }.resume()
    }
}

struct ImagePopupView: View {
    var image: UIImage?
    @Binding var isImagePopupVisible: Bool
    var width = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isImagePopupVisible = false
                }
            
            VStack {
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width * 0.8, height: width * 0.8)
                    .padding([.top, .leading, .trailing])
                
                Button(action: {
                    isImagePopupVisible = false
                    share(items: [image as Any])
                }) {
                    Text("Share This Screenshot")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: width * 0.5, maxHeight: 10)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom)
                .padding(.top, 8.0)
            }
            .background(Color.white)
            .cornerRadius(10)
            .padding()
        }
    }
}

extension UIApplication {
    var keyWindowInConnectedScenes: UIWindow? {
        let windowScenes: [UIWindowScene] = connectedScenes.compactMap({ $0 as? UIWindowScene })
        let windows: [UIWindow] = windowScenes.flatMap({ $0.windows })
        return windows.first(where: { $0.isKeyWindow })
    }
}

func takeScreenshot() {
    var screenshotImage: UIImage?
    guard let window = UIApplication.shared.keyWindowInConnectedScenes else { return }
    
    UIGraphicsBeginImageContextWithOptions(window.frame.size, false, UIScreen.main.scale)
    window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
    screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    share(items: [screenshotImage as Any])
}

@discardableResult
func share( items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil ) -> Bool {
    guard let source = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController else { return false }
    
    let activityViewController = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil
    )
    activityViewController.excludedActivityTypes = excludedActivityTypes
    source.present(activityViewController, animated: true)
    
    return true
}

struct ScreenShotView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenShotView()
    }
}
