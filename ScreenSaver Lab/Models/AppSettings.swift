//
//  AppSettings.swift
//  ScreenSaver Lab
//
//  Created by Tran Cong on 13/12/24.
//
import SwiftUI

class AppSettings: ObservableObject {
	static let shared = AppSettings()

	@AppStorage("inactiveTimeout") var inactiveTimeout: Double = 5.0  // Default 5 minutes
	@AppStorage("isScreenSaverEnabled") var isScreenSaverEnabled: Bool = true
	@AppStorage("selectedVideo") var selectedVideo: String = "christmas1"  // Store selected video name

	// Get available videos from assets
	func getAvailableVideos() -> [String] {
		guard let assetPath = Bundle.main.resourcePath else { return [] }

		do {
			let items = try FileManager.default.contentsOfDirectory(atPath: assetPath)
			return items.filter { $0.hasSuffix(".mp4") }
				.map { $0.replacingOccurrences(of: ".mp4", with: "") }
		} catch {
			print("Error reading directory: \(error)")
			return []
		}
	}

	// Get URL for selected video
	func getSelectedVideoURL() -> URL? {
		return Bundle.main.url(forResource: selectedVideo, withExtension: "mp4")
	}

	private init() {}  // Singleton
}
