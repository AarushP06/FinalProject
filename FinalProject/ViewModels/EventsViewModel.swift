//
//  EventsViewModel.swift
//  FinalProject
//

import Foundation
import Observation

/// Loads the bundled sky events and handles filtering for the Events tab.
@Observable
final class EventsViewModel {
    var events: [SkyEvent] = []
    var selectedKind: SkyEvent.Kind? = nil      // nil = show all types
    var errorMessage: String?

    /// Events from today onward, filtered by type, soonest first.
    var upcomingEvents: [SkyEvent] {
        events
            .filter { $0.daysUntil >= 0 }
            .filter { selectedKind == nil || $0.kind == selectedKind }
            .sorted { $0.date < $1.date }
    }

    /// The next event coming up, for a highlight card.
    var nextEvent: SkyEvent? {
        upcomingEvents.first
    }

    func loadEvents() {
        guard events.isEmpty else { return }
        do {
            events = try LocalDataService.load([SkyEvent].self, from: "sky_events")
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
