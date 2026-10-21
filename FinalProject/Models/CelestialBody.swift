//
//  CelestialBody.swift
//  FinalProject
//

import Foundation
import SwiftData

/// A planet or dwarf planet, seeded from Data/planets.json on first launch.
/// Relationship: one CelestialBody has many Observations.
@Model
final class CelestialBody {
    @Attribute(.unique) var name: String
    var order: Int                  // position from the Sun
    var isDwarfPlanet: Bool
    var radiusKm: Double
    var gravity: Double             // m/s²
    var meanTemperatureC: Double
    var moonCount: Int
    var dayLengthHours: Double
    var yearLengthDays: Double
    var distanceAU: Double          // average distance from the Sun
    var colorHex: String            // used for the card and the 3D sphere
    var summary: String
    var isFavorite: Bool = false

    @Relationship(deleteRule: .nullify, inverse: \SkyObservation.celestialBody)
    var observations: [SkyObservation] = []

    init(name: String,
         order: Int,
         isDwarfPlanet: Bool,
         radiusKm: Double,
         gravity: Double,
         meanTemperatureC: Double,
         moonCount: Int,
         dayLengthHours: Double,
         yearLengthDays: Double,
         distanceAU: Double,
         colorHex: String,
         summary: String) {
        self.name = name
        self.order = order
        self.isDwarfPlanet = isDwarfPlanet
        self.radiusKm = radiusKm
        self.gravity = gravity
        self.meanTemperatureC = meanTemperatureC
        self.moonCount = moonCount
        self.dayLengthHours = dayLengthHours
        self.yearLengthDays = yearLengthDays
        self.distanceAU = distanceAU
        self.colorHex = colorHex
        self.summary = summary
    }
}

/// Shape of each entry in Data/planets.json (not persisted directly).
struct PlanetSeed: Decodable {
    let name: String
    let order: Int
    let isDwarfPlanet: Bool
    let radiusKm: Double
    let gravity: Double
    let meanTemperatureC: Double
    let moonCount: Int
    let dayLengthHours: Double
    let yearLengthDays: Double
    let distanceAU: Double
    let colorHex: String
    let summary: String
}
