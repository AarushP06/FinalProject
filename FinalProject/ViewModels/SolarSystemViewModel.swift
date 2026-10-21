//
//  SolarSystemViewModel.swift
//  FinalProject
//

import Foundation
import SwiftData
import Observation

/// One labelled value shown on a planet's detail screen.
struct PlanetStat: Identifiable {
    let title: String
    let value: String
    var id: String { title }
}

/// One planet measurement divided by the same measurement for Earth.
struct PlanetComparisonRow: Identifiable {
    let title: String
    let ratio: Double
    var id: String { title }
}

/// Logic for the Solar System tab: the Pluto toggle, favorites, and formatted stats.
@Observable
final class SolarSystemViewModel {
    var includePluto = true

    private let earthGravity = 9.8

    func visibleBodies(from bodies: [CelestialBody]) -> [CelestialBody] {
        includePluto ? bodies : bodies.filter { !$0.isDwarfPlanet }
    }

    func toggleFavorite(_ body: CelestialBody, context: ModelContext) {
        body.isFavorite.toggle()
        try? context.save()
    }

    /// The insight cards shown under the 3D planet.
    func stats(for body: CelestialBody) -> [PlanetStat] {
        [
            PlanetStat(title: "Gravity", value: "\(format(body.gravity)) m/s²"),
            PlanetStat(title: "vs Earth", value: "\(format(body.gravity / earthGravity, digits: 2))× gravity"),
            PlanetStat(title: "Avg. temperature", value: "\(format(body.meanTemperatureC)) °C"),
            PlanetStat(title: "Known moons", value: "\(body.moonCount)"),
            PlanetStat(title: "Length of day", value: dayLengthText(body.dayLengthHours)),
            PlanetStat(title: "Length of year", value: yearLengthText(body.yearLengthDays)),
            PlanetStat(title: "Distance from Sun", value: "\(format(body.distanceAU, digits: 2)) AU"),
            PlanetStat(title: "Radius", value: "\(format(body.radiusKm, digits: 0)) km")
        ]
    }

    /// Ratios use the seeded Earth record, so Earth always appears as 1×.
    func comparisonRows(for body: CelestialBody, comparedTo earth: CelestialBody) -> [PlanetComparisonRow] {
        [
            PlanetComparisonRow(title: "Gravity", ratio: body.gravity / earth.gravity),
            PlanetComparisonRow(title: "Radius", ratio: body.radiusKm / earth.radiusKm),
            PlanetComparisonRow(title: "Length of day", ratio: body.dayLengthHours / earth.dayLengthHours)
        ]
    }

    // MARK: - Formatting helpers

    private func format(_ value: Double, digits: Int = 1) -> String {
        value.formatted(.number.precision(.fractionLength(0...digits)))
    }

    private func dayLengthText(_ hours: Double) -> String {
        hours > 48 ? "\(format(hours / 24)) Earth days" : "\(format(hours)) hours"
    }

    private func yearLengthText(_ days: Double) -> String {
        days > 730 ? "\(format(days / 365.25)) Earth years" : "\(format(days, digits: 0)) days"
    }
}
