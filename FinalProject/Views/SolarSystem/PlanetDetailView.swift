//
//  PlanetDetailView.swift
//  FinalProject
//

import SwiftUI
import SwiftData

/// A zoomable 3D planet plus insight cards and the user's observations of it.
struct PlanetDetailView: View {
    let planet: CelestialBody

    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<CelestialBody> { $0.name == "Earth" }) private var earthBodies: [CelestialBody]
    @State private var viewModel = SolarSystemViewModel()
    @State private var showingObservationForm = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PlanetSceneView(planetName: planet.name,
                                colorHex: planet.colorHex,
                                textureName: planet.textureName)
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Drag to rotate · pinch to zoom")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)

                Text(planet.summary)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.stats(for: planet)) { stat in
                        StatCard(title: stat.title, value: stat.value)
                    }
                }

                if let earth = earthBodies.first {
                    PlanetComparisonChart(
                        planetName: planet.name,
                        rows: viewModel.comparisonRows(for: planet, comparedTo: earth)
                    )
                } else {
                    Text("Earth comparison unavailable")
                        .foregroundStyle(.secondary)
                }

                Button {
                    showingObservationForm = true
                } label: {
                    Label("Log an observation", systemImage: "binoculars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if !planet.observations.isEmpty {
                    Text("Your observations")
                        .font(.headline)
                    ForEach(planet.observations.sorted { $0.date > $1.date }) { observation in
                        ObservationRow(observation: observation)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(planet.name)
        .toolbar {
            Button {
                viewModel.toggleFavorite(planet, context: context)
            } label: {
                Image(systemName: planet.isFavorite ? "star.fill" : "star")
            }
        }
        .sheet(isPresented: $showingObservationForm) {
            ObservationFormView(prefilledBody: planet)
        }
    }
}
