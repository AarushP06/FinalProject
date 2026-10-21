//
//  CalendarService.swift
//  FinalProject
//

import EventKit
import Foundation

/// The values needed to create an all-day calendar event.
struct CalendarEventDetails: Sendable {
    let title: String
    let date: Date
    let notes: String
    let visibility: String
}

/// Adds saved sky events using calendar write-only permission.
enum CalendarService {
    static func addEvent(_ details: CalendarEventDetails) async throws {
        try await Task.detached(priority: .userInitiated) {
            let store = EKEventStore()
            guard try await store.requestWriteOnlyAccessToEvents() else {
                throw CalendarError.permissionDenied
            }
            guard let calendar = store.defaultCalendarForNewEvents else {
                throw CalendarError.noCalendar
            }

            let start = Calendar.current.startOfDay(for: details.date)
            guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else {
                throw CalendarError.invalidDate
            }

            let event = EKEvent(eventStore: store)
            event.title = details.title
            event.startDate = start
            event.endDate = end
            event.isAllDay = true
            event.calendar = calendar
            event.notes = ([details.visibility, details.notes]
                .filter { !$0.isEmpty }).joined(separator: "\n\n")
            try store.save(event, span: .thisEvent)
        }.value
    }
}

enum CalendarError: LocalizedError {
    case permissionDenied
    case noCalendar
    case invalidDate

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Calendar access is off. Allow calendar access in Settings to add this event."
        case .noCalendar:
            return "No calendar is available for new events on this device."
        case .invalidDate:
            return "This event's date couldn't be added to Calendar."
        }
    }
}
