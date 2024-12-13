//
//  AppSettings.swift
//  ScreenSaver Lab
//
//  Created by Tran Cong on 13/12/24.
//
import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @AppStorage("inactiveTimeout") var inactiveTimeout: Double = 5.0 // Default 5 minutes
    @AppStorage("isScreenSaverEnabled") var isScreenSaverEnabled: Bool = true
    
    private init() {} // Singleton
}
