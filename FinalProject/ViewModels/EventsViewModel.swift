//
//  EventsViewModel.swift
//  FinalProject
//

import Foundation
import Observation

/// Time remaining until the start of an event's listed date.
struct EventCountdown {
    let days: Int
    let hours: Int
    let minutes: Int
    let hasArrived: Bool
}

/// Loads the bundled sky events and handles filtering for the Events tab.
@Observable
final class EventsViewModel {
    var events: [SkyEvent] = []
    var selectedKind: SkyEvent.Kind? = nil      // nil = show all types
    var searchText = ""
    var errorMessage: String?

    /// Events from today onward, filtered by type and title, soonest first.
    var upcomingEvents: [SkyEvent] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return events
            .filter { $0.daysUntil >= 0 }
            .filter { selectedKind == nil || $0.kind == selectedKind }
            .filter { query.isEmpty || $0.title.localizedStandardContains(query) }
            .sorted { $0.date < $1.date }
    }

    /// The next event coming up, for a highlight card.
    var nextEvent: SkyEvent? {
        upcomingEvents.first
    }

    static func countdown(for event: SkyEvent, at now: Date) -> EventCountdown {
        let remainingMinutes = max(0, Int(ceil(event.date.timeIntervalSince(now) / 60)))
        return EventCountdown(days: remainingMinutes / 1_440,
                              hours: (remainingMinutes % 1_440) / 60,
                              minutes: remainingMinutes % 60,
                              hasArrived: now >= event.date)
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
