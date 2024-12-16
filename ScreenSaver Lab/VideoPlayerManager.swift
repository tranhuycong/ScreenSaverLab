//
//  VideoController.swift
//  ScreenSaver Lab
//
//  Created by Tran Cong on 9/12/24.
//

import AVKit
import Cocoa

class VideoPlayerManager {
  static let shared = VideoPlayerManager()

  private var window: NSWindow?
  private var player: AVPlayer?
  private var playerLooper: AVPlayerLooper?

  private init() {}

  func showFullscreenVideo(video: String) {
    // Get video URL from video string
    guard let videoURL = Bundle.main.url(forResource: video, withExtension: "mp4") else {
      print("Video file not found!")
      return
    }
    // Create a fullscreen window
    let screenFrame = NSScreen.main?.frame ?? .zero
    window = NSWindow(
      contentRect: screenFrame,
      styleMask: [.borderless],
      backing: .buffered,
      defer: false)
    window?.level = .screenSaver
    window?.isOpaque = true
    window?.backgroundColor = .black
    window?.alphaValue = 0.0

    // Setup player and looper
    let playerItem = AVPlayerItem(url: videoURL)
    player = AVQueuePlayer()
    playerLooper = AVPlayerLooper(player: player as! AVQueuePlayer, templateItem: playerItem)

    // Configure player view
    let playerView = AVPlayerView(frame: screenFrame)
    playerView.player = player
    playerView.showsFullScreenToggleButton = false
    playerView.controlsStyle = .none
    // Set video gravity to fill
    playerView.videoGravity = .resizeAspectFill

    player?.volume = 0.0
    player?.play()

    window?.contentView = playerView
    window?.isReleasedWhenClosed = false
    window?.makeKeyAndOrderFront(nil)

    // Fade in
    NSAnimationContext.runAnimationGroup(
      { context in
        context.duration = 1.0
        window?.animator().alphaValue = 1.0
      }, completionHandler: nil)
  }

  func closeFullscreen() {
    guard window != nil else { return }

    NSAnimationContext.runAnimationGroup(
      { context in
        context.duration = 1.0
        window?.animator().alphaValue = 0.0
      },
      completionHandler: { [weak self] in
        guard let self = self else { return }

        // Stop playback first
        self.player?.pause()
        self.playerLooper?.disableLooping()

        // Clean up player resources
        self.playerLooper = nil
        self.player = nil

        // Finally close and clean up window
        self.window?.delegate = nil
        self.window?.close()
        self.window = nil
      })
  }
}
