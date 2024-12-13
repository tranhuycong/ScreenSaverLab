//
//  HomeView.swift
//  ScreenSaver Lab
//
//  Created by Tran Cong on 13/12/24.
//
import SwiftUI

struct HomeView: View {
  @StateObject private var settings = AppSettings.shared

  var body: some View {
    VStack {
      Text("Active Screen Saver")
        .font(.largeTitle)
      if settings.isScreenSaverEnabled {
        Text(
          "Screen saver will start after \(Int(settings.inactiveTimeout)) minutes when inactive."
        )
        .foregroundColor(.secondary)
      }
    }
  }
}
