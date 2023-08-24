//
//  PlaceListView.swift
//  LearnSwift
//
//  Created by Nazar on 23/08/23.
//

import SwiftUI

struct UserData {
    let name: String
    let photo: String
}

struct PlaceData : Identifiable {
    let id = UUID()
    let name: String
    let photo: String
    let rating: Double
}

struct PlacelistData {
    let title: String
    let subtitle: String
    let userdata: UserData
    let images: [PlaceData]
    let places: Int
    let likes: Int
    let shares: Int
}

struct PlaceListView: View {
    @Binding var isImagePopupVisible: Bool
    var data: PlacelistData
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isImagePopupVisible = false
                }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(data.title)
                    .font(.system(size: 16).weight(.semibold))
                    .foregroundColor(Color(hex: 0x1E1E1E))
                Text(data.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x1F2D3E))
                
                HStack {
                    AsyncImage(url: URL(string: data.userdata.photo))
                        .frame(maxWidth: 16, maxHeight: 16)
                        .scaledToFill()
                        .clipShape(Circle())
                    Text(data.userdata.name)
                        .font(.system(size: 12).weight(.medium))
                        .foregroundColor(Color(hex: 0x828A94))
                }
                .padding(.bottom, 8.0)
                
                ForEach(data.images) { place in
                    ZStack(alignment: .bottomLeading) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity, minHeight: 74, maxHeight: 74)
                            .background(
                                AsyncImage(url: URL(string: place.photo)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    case .failure:
                                        Color.red
                                    @unknown default:
                                        Color.gray
                                    }
                                }
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: 0x828A94), lineWidth: 0.09)
                            )
                        
                        HStack(alignment: .bottom, spacing: 0) {
                            Text(place.name)
                                .font(.system(size: 12).weight(.bold))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "star.fill")
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 11, height: 11)
                                .padding([.bottom, .trailing], 2.0)
                            Text(String(format: "%.1f", place.rating))
                                .font(.system(size: 11).weight(.bold))
                                .tracking(0.42)
                                .foregroundColor(.white)
                        }
                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0, blue: 0).opacity(0), .black]), startPoint: .top, endPoint: .bottom)
                        )
                        .padding(.top, 12)
                        .cornerRadius(12)
                        .padding(.top, -12)
                    }
                    .padding(.bottom, 8.0)
                }

                
                HStack(spacing: 0) {
                    ForEach([
                        ("house", String(format: "%d places", data.places)),
                        ("hand.thumbsup", String(format: "%d likes", data.likes)),
                        ("square.and.arrow.up", String(format: "%d shares", data.shares))
                    ], id: \.0) { item in
                        HStack(spacing: 4) {
                            if(item.0 == "hand.thumbsup") { Spacer() }
                            Image(systemName: item.0)
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 16, height: 16)
                                .padding(.trailing, 3.0)
                            Text(item.1)
                                .font(.system(size: 12).weight(.medium))
                                .foregroundColor(Color(hex: 0x1E1E1E))
                            if(item.0 == "hand.thumbsup") { Spacer() }
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 16, maxHeight: 16)
                .padding(.horizontal)
                
                HStack {
                    Spacer()
                    Text("Powered by:")
                        .font(.system(size: 8).weight(.bold))
                        .foregroundColor(Color(hex: 0xACACAC))
                    Image("cashbac")
                        .resizable()
                        .frame(width: 124, height: 22)
                    Spacer()
                }
                .padding(8)
            }
            .padding(16)
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .background(Color.white)
            .cornerRadius(12)
            .shadow( radius: 8, y: 2 )
        }
    }
}

struct PlaceListView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceListView(
            isImagePopupVisible: .constant(false),
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
    }
}
