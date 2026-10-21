//
//  PlanetComparisonChart.swift
//  FinalProject
//

import SwiftUI
import Charts

/// Three compact Earth-relative bar comparisons, each with its own scale.
struct PlanetComparisonChart: View {
    let planetName: String
    let rows: [PlanetComparisonRow]

    private var selectedLabel: String {
        planetName == "Earth" ? "Earth (selected)" : planetName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Compared with Earth")
                .font(.headline)

            ForEach(rows) { row in
                VStack(alignment: .leading, spacing: 6) {
                    Text(row.title)
                        .font(.subheadline.weight(.semibold))

                    Chart {
                        BarMark(x: .value("Earth ratio", 1.0),
                                y: .value("Planet", "Earth"))
                            .foregroundStyle(.secondary)
                            .annotation(position: .trailing) { Text("1×") }

                        BarMark(x: .value("Planet ratio", row.ratio),
                                y: .value("Planet", selectedLabel))
                            .foregroundStyle(.tint)
                            .annotation(position: .trailing) {
                                Text(row.ratio.formatted(.number.precision(.fractionLength(0...2))) + "×")
                            }
                    }
                    .chartXScale(domain: 0...max(1, row.ratio) * 1.3)
                    .chartXAxis(.hidden)
                    .frame(height: 74)
                }
            }
        }
    }
}
