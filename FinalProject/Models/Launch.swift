//
//  Launch.swift
//  FinalProject
//

import Foundation

/// Fields used from Launch Library 2's upcoming launches response.
struct Launch: Codable, Identifiable {
    let id: String
    let name: String
    let net: Date
    let status: LaunchStatus
    let launchServiceProvider: LaunchProvider?
    let image: LaunchImage?

    var imageURL: URL? { image?.thumbnailUrl ?? image?.imageUrl }
}

struct LaunchStatus: Codable {
    let name: String
}

struct LaunchProvider: Codable {
    let name: String
}

struct LaunchImage: Codable {
    let imageUrl: URL?
    let thumbnailUrl: URL?
}

struct LaunchResponse: Decodable {
    let results: [Launch]
}
