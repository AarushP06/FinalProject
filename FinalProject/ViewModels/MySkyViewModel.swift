//
//  MySkyViewModel.swift
//  FinalProject
//

import Foundation
import SwiftData
import Observation
import PhotosUI
import SwiftUI
import UIKit

/// All create / update / delete logic for saved events and observations.
/// Views call these methods instead of touching the ModelContext directly.
@MainActor
@Observable
final class MySkyViewModel {
    var errorMessage: String?
    var notificationMessage: String?
    var calendarMessage: String?
    var calendarAdded = false
    var photoMessage: String?
    var locationMessage: String?

    @ObservationIgnored private let locationService = LocationService()

    // MARK: - Saved events

    func saveEvent(_ event: SkyEvent, notes: String, reminderEnabled: Bool, context: ModelContext) async {
        notificationMessage = nil
        let saved = SavedEvent(eventID: event.id,
                               title: event.title,
                               kind: event.kind.rawValue,
                               date: event.date,
                               visibility: event.visibility,
                               notes: notes,
                               reminderEnabled: false)
        context.insert(saved)
        guard persist(context) else {
            context.delete(saved)
            return
        }
        if reminderEnabled {
            await enableReminder(for: saved, context: context)
        }
    }

    func updateSavedEvent(_ saved: SavedEvent, notes: String, reminderEnabled: Bool, context: ModelContext) async {
        notificationMessage = nil
        saved.notes = notes
        saved.reminderEnabled = false
        guard persist(context) else { return }
        NotificationService.cancelReminder(for: saved)
        if reminderEnabled {
            await enableReminder(for: saved, context: context)
        }
    }

    func deleteSavedEvent(_ saved: SavedEvent, context: ModelContext) {
        NotificationService.cancelReminder(for: saved)
        context.delete(saved)
        persist(context)
    }

    func addToCalendar(_ saved: SavedEvent, notes: String) async {
        let details = CalendarEventDetails(title: saved.title,
                                           date: saved.date,
                                           notes: notes,
                                           visibility: saved.visibility)
        do {
            try await CalendarService.addEvent(details)
            calendarAdded = true
            calendarMessage = "Added as an all-day event."
        } catch {
            calendarAdded = false
            calendarMessage = error.localizedDescription
        }
    }

    // MARK: - Observations

    func loadObservationPhoto(_ item: PhotosPickerItem) async -> Data? {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  UIImage(data: data) != nil else {
                photoMessage = "Couldn't load that photo. Choose another image."
                return nil
            }
            photoMessage = nil
            return data
        } catch {
            photoMessage = "Couldn't load the photo: \(error.localizedDescription)"
            return nil
        }
    }

    func currentObservationCoordinates() async -> ObservationCoordinates? {
        do {
            let coordinates = try await locationService.currentCoordinates()
            locationMessage = nil
            return coordinates
        } catch {
            locationMessage = error.localizedDescription
            return nil
        }
    }

    /// Creates a new observation, or updates `existing` if one is passed in.
    func saveObservation(existing: SkyObservation?,
                         title: String,
                         date: Date,
                         notes: String,
                         rating: Int,
                         latitude: Double?,
                         longitude: Double?,
                         photoData: Data?,
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
            existing.latitude = latitude
            existing.longitude = longitude
            existing.photoData = photoData
            existing.celestialBody = celestialBody
            existing.event = event
        } else {
            let observation = SkyObservation(title: trimmedTitle,
                                          date: date,
                                          notes: notes,
                                          rating: rating,
                                          celestialBody: celestialBody,
                                          event: event)
            observation.latitude = latitude
            observation.longitude = longitude
            observation.photoData = photoData
            context.insert(observation)
        }
        persist(context)
    }

    func deleteObservation(_ observation: SkyObservation, context: ModelContext) {
        context.delete(observation)
        persist(context)
    }

    // MARK: - Helpers

    private func enableReminder(for saved: SavedEvent, context: ModelContext) async {
        do {
            try await NotificationService.scheduleReminder(for: saved)
            saved.reminderEnabled = true
            if !persist(context) {
                NotificationService.cancelReminder(for: saved)
                saved.reminderEnabled = false
            }
        } catch {
            notificationMessage = error.localizedDescription
        }
    }

    @discardableResult
    private func persist(_ context: ModelContext) -> Bool {
        do {
            try context.save()
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Couldn't save: \(error.localizedDescription)"
            return false
        }
    }
}
