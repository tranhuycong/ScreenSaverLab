//
//  ContentView.swift
//  ScreenSaver Lab
//
//  Created by Tran Cong on 9/12/24.
//

import SwiftUI

struct ContentView: View {
  @State private var selectedItem: String? = nil

  var body: some View {
    NavigationSplitView {
      // Sidebar
      List(selection: $selectedItem) {
        Section("Menu") {
          NavigationLink("Home", value: "home")
          NavigationLink("Settings", value: "settings")
          NavigationLink("About", value: "about")
        }
      }
      .navigationTitle("Sidebar")
    } detail: {
      switch selectedItem {
      case "home":
        HomeView()
      case "settings":
        SettingsView()
      case "about":
        AboutView()
      default:
        HomeView()
      }
    }
  }
}

#Preview {
  ContentView()
}
