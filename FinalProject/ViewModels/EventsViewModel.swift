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

/// Loads bundled events and can refresh local eclipses from AstronomyAPI.
@MainActor
@Observable
final class EventsViewModel {
    var events: [SkyEvent] = []
    var selectedKind: SkyEvent.Kind? = nil      // nil = show all types
    var searchText = ""
    var errorMessage: String?
    var statusMessage: String?
    var isRefreshing = false

    @ObservationIgnored private let astronomyService = AstronomyEventsService()
    @ObservationIgnored private let locationService = LocationService()
    @ObservationIgnored private var bundledEvents: [SkyEvent] = []

    /// Reference location when a simulator cannot provide a location fix.
    private static let montreal = ObservationCoordinates(latitude: 45.5019, longitude: -73.5674)

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

    var apiEclipses: [SkyEvent] {
        upcomingEvents.filter { $0.source == .astronomyAPI }
    }

    var otherUpcomingEvents: [SkyEvent] {
        upcomingEvents.filter { $0.source != .astronomyAPI }
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
            bundledEvents = try LocalDataService.load([SkyEvent].self, from: "sky_events")
            events = bundledEvents
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Checks local eclipses, using Montréal as a labelled simulator fallback.
    func refreshEclipses() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        errorMessage = nil
        statusMessage = nil
        defer { isRefreshing = false }

        do {
            let coordinates: ObservationCoordinates
            let place: String
            do {
                coordinates = try await locationService.currentCoordinates()
                place = "your location"
            } catch {
                coordinates = Self.montreal
                place = "Montréal (device location unavailable)"
            }
            let eclipses = try await astronomyService.fetchEclipses(at: coordinates,
                                                                     locationName: place)
            if eclipses.isEmpty {
                events = bundledEvents
            } else {
                events = bundledEvents.filter { $0.kind != .solarEclipse && $0.kind != .lunarEclipse } + eclipses
                selectedKind = nil
                searchText = ""
            }
            statusMessage = eclipses.isEmpty
                ? "No eclipse above the horizon for \(place) in the next year. Showing bundled worldwide events."
                : "\(eclipses.count) AstronomyAPI eclipse\(eclipses.count == 1 ? "" : "s") for \(place). API results replace bundled eclipses; meteor showers use bundled dates."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
