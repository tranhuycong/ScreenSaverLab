//
//  ScreenSaver_LabApp.swift
//  ScreenSaver Lab
//
//  Created by Tran Cong on 9/12/24.
//

import AVKit
import AppKit
import FirebaseAnalytics
import FirebaseCore
import Foundation
import IOKit.ps
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
	var statusItem: NSStatusItem?
	private var eventMonitor: Any?
	private var isScreensaverActive = false
	private var autoHideTimer: Timer?
	private var idleTimer: Timer?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Add firebase configuration
		FirebaseApp.configure()
		// Enable analytics data collection explicitly if needed
		Analytics.setAnalyticsCollectionEnabled(true)

		// Create a menu bar icon
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
		if let button = statusItem?.button {
			button.image = NSImage(
				systemSymbolName: "photo.tv", accessibilityDescription: "Play Video")
			button.action = #selector(menuBarIconClicked)
			checkIdleAndShowVideo()
		}
	}

	@objc func menuBarIconClicked() {
		showFullscreenVideo(video: AppSettings.shared.selectedVideo)
	}

	deinit {
		NotificationCenter.default.removeObserver(
			self, name: Notification.Name("StartScreenSaverNotification"), object: nil)
	}

	func startEventMonitoring() {
		var lastEventTime = Date()

		// Global monitor for events outside your app
		eventMonitor = NSEvent.addGlobalMonitorForEvents(
			matching: [.keyDown, .mouseMoved, .leftMouseDown, .rightMouseDown, .otherMouseDown],
			handler: { [weak self] event in
				let now = Date()
				if now.timeIntervalSince(lastEventTime) > 1 {
					lastEventTime = now
					self?.handleUserActivity()
				}
			})

		// Local monitor for events inside your app
		NSEvent.addLocalMonitorForEvents(
			matching: [.keyDown, .mouseMoved, .leftMouseDown, .rightMouseDown, .otherMouseDown]
		) { [weak self] event in
			let now = Date()
			if now.timeIntervalSince(lastEventTime) > 1 {
				lastEventTime = now
				self?.handleUserActivity()
			}
			return event
		}
	}

	func handleUserActivity() {
		if isScreensaverActive {
			hideFullscreenVideo()
		}
	}

	func applicationWillTerminate(_ notification: Notification) {
		// Clean up monitoring when app terminates
		cleanUpMonitoring()
	}

	func cleanUpMonitoring() {
		if let monitor = eventMonitor {
			NSEvent.removeMonitor(monitor)
			print("Input monitoring stopped.")
		}
	}

	@objc func showFullscreenVideo(video: String) {
		// Show the fullscreen video
		VideoPlayerManager.shared.showFullscreenVideo(video: video)

		isScreensaverActive = true
		startEventMonitoring()

		autoHideFullscreenVideoTimer()
	}

	func autoHideFullscreenVideoTimer() {
		// Call hideFullscreenVideo before display sleep
		let displaySleepTime = getDisplaySleepTime()
		autoHideTimer = Timer.scheduledTimer(
			withTimeInterval: TimeInterval(displaySleepTime - 15), repeats: false
		) {
			[weak self] _ in
			if self?.isScreensaverActive == true {
				print("Hide video before display sleep")

				self?.hideFullscreenVideo()
			}
		}
	}

	func hideFullscreenVideo() {
		VideoPlayerManager.shared.closeFullscreen()
		isScreensaverActive = false
		cleanUpMonitoring()

		// Invalidate the auto-hide timer
		autoHideTimer?.invalidate()
		autoHideTimer = nil

		// Restart idle monitoring
		checkIdleAndShowVideo()
	}

	func getIdleTime() -> TimeInterval {
		var iterator = io_iterator_t()
		var idleTime: TimeInterval = 0

		if IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOHIDSystem"), &iterator)
			== KERN_SUCCESS
		{
			let entry = IOIteratorNext(iterator)
			if entry != 0 {
				var dict: Unmanaged<CFMutableDictionary>?
				if IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0) == KERN_SUCCESS {
					if let properties = dict?.takeUnretainedValue() as? [String: Any] {
						if let idle = properties[kIOHIDIdleTimeKey as String] as? Int64 {
							idleTime = Double(idle) / 1_000_000_000  // Convert nanoseconds to seconds
						}
					}
				}
				IOObjectRelease(entry)
			}
			IOObjectRelease(iterator)
		}
		return idleTime
	}

	func getDisplaySleepTime() -> Int {
		let pipe = Pipe()
		let process = Process()
		process.launchPath = "/usr/bin/pmset"
		process.arguments = ["-g"]
		process.standardOutput = pipe

		try? process.run()
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		if let output = String(data: data, encoding: .utf8) {
			let lines = output.components(separatedBy: "\n")
			for line in lines {
				if line.contains("displaysleep") {
					if let time = line.components(separatedBy: " ")
						.compactMap({ Int($0) })
						.first
					{
						return time * 60  // Convert minutes to seconds
					}
				}
			}
		}
		return 1200  // Default 20 minutes
	}

	func checkIdleAndShowVideo() {
		if idleTimer != nil {
			idleTimer?.invalidate()
			idleTimer = nil
		}
		idleTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] timer in
			guard let self = self else { return }
			let idle = self.getIdleTime()
			print("Idle time show: \(idle)")

			if idle >= AppSettings.shared.inactiveTimeout * 60 {
				timer.invalidate()
				DispatchQueue.main.async {
					self.showFullscreenVideo(video: AppSettings.shared.selectedVideo)
				}
			}
		}
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		// Keep app running in background
		// Hide the Dock icon
		NSApp.setActivationPolicy(.accessory)
		return false
	}

}

@main
struct ScreenSaver_LabApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
