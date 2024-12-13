//
//  AboutView.swift
//  ScreenSaver Lab
//
//  Created by Tran Cong on 13/12/24.
//
import SwiftUI

struct AboutView: View {
  var body: some View {
    VStack {
      Text("About")
        .font(.largeTitle)
      Text("ScreenSaver Lab")
        .font(.title)
      if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        Text("Version \(version)")
      }
      Text("Created by Cong Tran")
    }
  }
}
