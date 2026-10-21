//
//  SolarSystemView.swift
//  FinalProject
//

import SwiftUI
import SwiftData

/// Tab 2: the planets (and Pluto, if you want it) as a grid of cards.
struct SolarSystemView: View {
    @Query(sort: \CelestialBody.order) private var bodies: [CelestialBody]
    @State private var viewModel = SolarSystemViewModel()

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Include Pluto", isOn: $viewModel.includePluto.animation())
                    if !viewModel.includePluto {
                        Text("Pluto was reclassified as a dwarf planet in 2006.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.visibleBodies(from: bodies)) { planet in
                        NavigationLink(value: planet) {
                            PlanetCard(planet: planet)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Solar System")
            .navigationDestination(for: CelestialBody.self) { planet in
                PlanetDetailView(planet: planet)
            }
        }
    }
}

/// Card for one planet in the grid.
struct PlanetCard: View {
    let planet: CelestialBody

    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(Color(hex: planet.colorHex).gradient)
                .frame(width: 80, height: 80)
                .shadow(radius: 6)

            Text(planet.name)
                .font(.headline)

            Text(planet.isDwarfPlanet ? "Dwarf planet" : "Planet \(planet.order)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .topTrailing) {
            if planet.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .padding(8)
            }
        }
    }
}

#Preview {
    SolarSystemView()
        .modelContainer(for: [CelestialBody.self, SavedEvent.self, SkyObservation.self], inMemory: true)
}
