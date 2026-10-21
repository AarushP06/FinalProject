//
//  MySkyViewModel.swift
//  FinalProject
//

import Foundation
import SwiftData
import Observation

/// All create / update / delete logic for saved events and observations.
/// Views call these methods instead of touching the ModelContext directly.
@Observable
final class MySkyViewModel {
    var errorMessage: String?

    // MARK: - Saved events

    func saveEvent(_ event: SkyEvent, notes: String, reminderEnabled: Bool, context: ModelContext) {
        let saved = SavedEvent(eventID: event.id,
                               title: event.title,
                               kind: event.kind.rawValue,
                               date: event.date,
                               visibility: event.visibility,
                               notes: notes,
                               reminderEnabled: reminderEnabled)
        context.insert(saved)
        persist(context)
        // TODO (Prompt 6): if reminderEnabled, schedule a reminder with NotificationService.
    }

    func updateSavedEvent(_ saved: SavedEvent, notes: String, reminderEnabled: Bool, context: ModelContext) {
        saved.notes = notes
        saved.reminderEnabled = reminderEnabled
        persist(context)
        // TODO (Prompt 6): reschedule or cancel the reminder.
    }

    func deleteSavedEvent(_ saved: SavedEvent, context: ModelContext) {
        // TODO (Prompt 6): cancel the reminder first.
        context.delete(saved)
        persist(context)
    }

    // MARK: - Observations

    /// Creates a new observation, or updates `existing` if one is passed in.
    func saveObservation(existing: SkyObservation?,
                         title: String,
                         date: Date,
                         notes: String,
                         rating: Int,
                         celestialBody: CelestialBody?,
                         event: SavedEvent?,
                         context: ModelContext) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Give the observation a title."
            return
        }

        if let existing {
            existing.title = trimmedTitle
            existing.date = date
            existing.notes = notes
            existing.rating = rating
            existing.celestialBody = celestialBody
            existing.event = event
        } else {
            let observation = SkyObservation(title: trimmedTitle,
                                          date: date,
                                          notes: notes,
                                          rating: rating,
                                          celestialBody: celestialBody,
                                          event: event)
            context.insert(observation)
        }
        persist(context)
    }

    func deleteObservation(_ observation: SkyObservation, context: ModelContext) {
        context.delete(observation)
        persist(context)
    }

    // MARK: - Helpers

    private func persist(_ context: ModelContext) {
        do {
            try context.save()
            errorMessage = nil
        } catch {
            errorMessage = "Couldn't save: \(error.localizedDescription)"
        }
    }
}
