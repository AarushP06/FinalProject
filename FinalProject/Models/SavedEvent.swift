//
//  SavedEvent.swift
//  FinalProject
//

import Foundation
import SwiftData

/// A sky event the user saved to "My Sky", with their own notes and reminder setting.
/// Relationship: one SavedEvent has many Observations (deleted with it).
@Model
final class SavedEvent {
    var eventID: String             // matches SkyEvent.id from the bundled JSON
    var title: String
    var kind: String                // SkyEvent.Kind raw value
    var date: Date
    var visibility: String
    var notes: String
    var reminderEnabled: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \SkyObservation.event)
    var observations: [SkyObservation] = []

    init(eventID: String,
         title: String,
         kind: String,
         date: Date,
         visibility: String,
         notes: String = "",
         reminderEnabled: Bool = true) {
        self.eventID = eventID
        self.title = title
        self.kind = kind
        self.date = date
        self.visibility = visibility
        self.notes = notes
        self.reminderEnabled = reminderEnabled
        self.createdAt = .now
    }

    /// Icon for the event type, falling back to a generic one.
    var systemImage: String {
        SkyEvent.Kind(rawValue: kind)?.systemImage ?? "sparkles"
    }
}
