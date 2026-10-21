//
//  FinalProjectApp.swift
//  FinalProject
//
//  Aarush Patel - 2330241
//  420-N52-LA Mobile Application Development 2: iOS - Final Project
//

import SwiftUI
import SwiftData

@main
struct FinalProjectApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        // One SwiftData container for all persistent models.
        .modelContainer(for: [CelestialBody.self, SavedEvent.self, SkyObservation.self])
    }
}
