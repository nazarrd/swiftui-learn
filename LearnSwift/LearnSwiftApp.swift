//
//  LearnSwiftApp.swift
//  LearnSwift
//
//  Created by Nazar on 10/08/23.
//

import SwiftUI

@main
struct LearnSwiftApp: App {
    var body: some Scene {
        WindowGroup {
            IntroView()
        }
    }
}

struct IntroView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("POC SwiftUI")
                    .font(.title)
                    .fontWeight(.bold)
                NavigationLink("Tiktok Scroll", destination: BrowseView())
                    .padding(.vertical, 8.0)
                NavigationLink("Share Screenshot", destination: ScreenShotView())
                    .padding(.vertical, 8.0)
            }
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
