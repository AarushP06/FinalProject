//
//  ObservationPhotoThumbnail.swift
//  FinalProject
//

import SwiftUI

/// A compact preview of a photo stored with an observation.
struct ObservationPhotoThumbnail: View {
    let data: Data
    let size: CGFloat

    var body: some View {
        Group {
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityLabel("Observation photo")
    }
}
