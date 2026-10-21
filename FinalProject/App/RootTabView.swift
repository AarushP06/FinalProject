//
//  RootTabView.swift
//  FinalProject
//

import SwiftUI
import SwiftData

/// The three main areas of the app.
struct RootTabView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView {
            EventsView()
                .tabItem { Label("Events", systemImage: "sparkles") }

            SolarSystemView()
                .tabItem { Label("Solar System", systemImage: "globe.americas") }

            MySkyView()
                .tabItem { Label("My Sky", systemImage: "star.circle") }
        }
        // Fill SwiftData with the planets the first time the app runs.
        .task {
            SeedService.seedPlanetsIfNeeded(context: context)
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [CelestialBody.self, SavedEvent.self, SkyObservation.self], inMemory: true)
}
