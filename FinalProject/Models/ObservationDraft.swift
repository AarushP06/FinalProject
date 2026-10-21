//
//  ObservationDraft.swift
//  FinalProject
//

import Foundation

/// A Quick log suggestion that the user reviews before saving.
struct ObservationDraft {
    let title: String
    let date: Date
    let planetName: String?
    let rating: Int
    let notes: String
}
