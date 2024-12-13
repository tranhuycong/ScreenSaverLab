//
//  ContentView.swift
//  ScreenSaver Lab
//
//  Created by Tran Cong on 9/12/24.
//

import SwiftUI

struct ContentView: View {

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
      Button("Active") {
        guard let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
          print("Video file not found!")
          return
        }

        // Show the fullscreen video
        VideoPlayerManager.shared.showFullscreenVideo(videoURL: videoURL)

      }
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
