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

struct PlacelistData {
    let title: String
    let subtitle: String
    let userdata: UserData
    let images: [String]
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
                
                ForEach(data.images, id: \.self) { url in
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
                        .background(
                            AsyncImage(url: URL(string: url))
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: 0x828A94), lineWidth: 0.09)
                        )
                        .padding(.bottom, 8.0)
                }
                
                HStack(spacing: 20) {
                    ForEach([
                        ("house", String(format: "%d places", data.places)),
                        ("hand.thumbsup", String(format: "%d likes", data.likes)),
                        ("square.and.arrow.up", String(format: "%d shares", data.shares))
                    ], id: \.0) { item in
                        HStack(spacing: 4) {
                            Image(systemName: item.0)
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 16, height: 16)
                                .padding(.trailing, 3.0)
                            Text(item.1)
                                .font(.system(size: 12).weight(.medium))
                                .foregroundColor(Color(hex: 0x1E1E1E))
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
