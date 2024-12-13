import AVFoundation
import AppKit
//
//  HomeView.swift
//  ScreenSaver Lab
//
//  Created by Tran Cong on 13/12/24.
//
import SwiftUI

struct HomeView: View {
  @EnvironmentObject private var appDelegate: AppDelegate

  @StateObject private var settings = AppSettings.shared

  private let columns = [
    GridItem(.adaptive(minimum: 160), spacing: 16)
  ]

  var body: some View {
    VStack(spacing: 20) {
      Text("Active Screen Saver")
        .font(.largeTitle)

      if settings.isScreenSaverEnabled {
        Text(
          "Screen saver will start after \(Int(settings.inactiveTimeout)) minutes when inactive."
        )
        .foregroundColor(.secondary)
      }

      ScrollView {
        LazyVGrid(columns: columns, spacing: 16) {
          ForEach(settings.getAvailableVideos(), id: \.self) { video in
            VideoThumbnailView(videoName: video, isSelected: video == settings.selectedVideo)
              .frame(height: 120)
              .onTapGesture {
                appDelegate.showFullscreenVideo(video: video)
              }
          }
        }
        .padding()
      }
    }
    .padding()
  }
}

struct VideoThumbnailView: View {
  let videoName: String
  let isSelected: Bool
  @StateObject private var settings = AppSettings.shared

  var body: some View {
    VStack(spacing: 8) {
      ZStack {
        if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
          VideoThumbnailGenerator(url: url)
            .aspectRatio(contentMode: .fill)
        }

        VStack {
          Text("Preview")
            .foregroundColor(.white)
            .padding(8)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
        }
      }

      // Add radio button
      Image(systemName: isSelected ? "circle.fill" : "circle")
        .foregroundColor(isSelected ? .blue : .gray)
        .onTapGesture {
          settings.selectedVideo = videoName
        }
    }.cornerRadius(8)
  }
}

struct VideoThumbnailGenerator: View {
  let url: URL

  var body: some View {
    if let thumbnail = generateThumbnail(from: url) {
      Image(nsImage: thumbnail)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .cornerRadius(8)
    } else {
      Color.black
        .cornerRadius(8)
    }
  }

  func generateThumbnail(from videoURL: URL, at time: TimeInterval = 0) -> NSImage? {
    let asset = AVAsset(url: videoURL)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true

    // Convert time to CMTime
    let cmTime = CMTime(seconds: time, preferredTimescale: 60)

    do {
      let thumbnailCGImage = try imageGenerator.copyCGImage(at: cmTime, actualTime: nil)
      let thumbnailSize = NSSize(width: thumbnailCGImage.width, height: thumbnailCGImage.height)
      return NSImage(cgImage: thumbnailCGImage, size: thumbnailSize)
    } catch {
      print("Error generating thumbnail: \(error.localizedDescription)")
      return nil
    }
  }
}
