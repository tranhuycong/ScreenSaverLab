//
//  SettingsView.swift
//  ScreenSaver Lab
//
//  Created by Tran Cong on 13/12/24.
//
import SwiftUI

struct SettingsView: View {
  @EnvironmentObject private var appDelegate: AppDelegate

  @StateObject private var settings = AppSettings.shared

  var body: some View {
    Form {
      Section(header: Text("Screen Saver Settings").font(.title).padding()) {
        Toggle("Enable Screen Saver", isOn: $settings.isScreenSaverEnabled)

        if settings.isScreenSaverEnabled {
          HStack {
            Text("Start when inactive after (minutes):")
            Slider(
              value: $settings.inactiveTimeout,
              in: 1...60,
              step: 1
            )
            .onChange(of: settings.inactiveTimeout) { _ in
              appDelegate.checkIdleAndShowVideo()
            }
            Text("\(Int(settings.inactiveTimeout))")
          }
        }
      }
    }
    .padding()
  }
}
