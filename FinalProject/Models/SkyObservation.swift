//
//  SkyObservation.swift
//  FinalProject
//

import Foundation
import SwiftData

/// A stargazing log entry the user creates.
/// Can be linked to a planet, a saved event, both, or neither.
@Model
final class SkyObservation {
    var title: String
    var date: Date
    var notes: String
    var rating: Int                 // 1–5
    var latitude: Double?           // filled in later (Prompt 8)
    var longitude: Double?
    @Attribute(.externalStorage) var photoData: Data?

    var celestialBody: CelestialBody?
    var event: SavedEvent?

    init(title: String,
         date: Date = .now,
         notes: String = "",
         rating: Int = 3,
         celestialBody: CelestialBody? = nil,
         event: SavedEvent? = nil) {
        self.title = title
        self.date = date
        self.notes = notes
        self.rating = rating
        self.celestialBody = celestialBody
        self.event = event
    }
}
