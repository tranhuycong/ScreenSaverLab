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

  func showFullscreenVideo(videoURL: URL) {
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

    player?.volume = 0.0
    player?.play()

    window?.contentView = playerView
    window?.makeKeyAndOrderFront(nil)

    // Fade in
    NSAnimationContext.runAnimationGroup(
      { context in
        context.duration = 1.0
        window?.animator().alphaValue = 1.0
      }, completionHandler: nil)
  }

  @objc func closeFullscreen() {
    NSAnimationContext.runAnimationGroup(
      { context in
        context.duration = 1.0
        window?.animator().alphaValue = 0.0
      },
      completionHandler: { [weak self] in
        self?.player?.pause()
        self?.playerLooper?.disableLooping()
        self?.playerLooper = nil
        self?.player = nil
        self?.window?.close()
        self?.window = nil
      })
  }
}
