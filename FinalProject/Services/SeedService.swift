//
//  SeedService.swift
//  FinalProject
//

import Foundation
import SwiftData

/// Puts the planets from Data/planets.json into SwiftData the first time the app runs.
enum SeedService {
    static func seedPlanetsIfNeeded(context: ModelContext) {
        let existingCount = (try? context.fetchCount(FetchDescriptor<CelestialBody>())) ?? 0
        guard existingCount == 0 else { return }

        do {
            let seeds = try LocalDataService.load([PlanetSeed].self, from: "planets")
            for seed in seeds {
                let body = CelestialBody(name: seed.name,
                                         order: seed.order,
                                         isDwarfPlanet: seed.isDwarfPlanet,
                                         radiusKm: seed.radiusKm,
                                         gravity: seed.gravity,
                                         meanTemperatureC: seed.meanTemperatureC,
                                         moonCount: seed.moonCount,
                                         dayLengthHours: seed.dayLengthHours,
                                         yearLengthDays: seed.yearLengthDays,
                                         distanceAU: seed.distanceAU,
                                         colorHex: seed.colorHex,
                                         textureName: seed.textureName,
                                         summary: seed.summary)
                context.insert(body)
            }
            try context.save()
        } catch {
            print("Seeding planets failed: \(error.localizedDescription)")
        }
    }
}
