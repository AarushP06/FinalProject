//
//  StatCard.swift
//  FinalProject
//

import SwiftUI

/// Small reusable card: a caption and a value.
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StatCard(title: "Gravity", value: "9.8 m/s²")
        .padding()
}
