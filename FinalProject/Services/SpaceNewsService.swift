//
//  SpaceNewsService.swift
//  FinalProject
//

import Foundation

/// Fetches space news from the Spaceflight News API.
/// Free, no API key. Docs: https://api.spaceflightnewsapi.net/v4/docs/
struct SpaceNewsService {
    private let baseURL = URL(string: "https://api.spaceflightnewsapi.net/v4/articles/")!

    func fetchLatest(limit: Int = 20, search: String? = nil) async throws -> [NewsArticle] {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw ServiceError.invalidURL
        }
        var queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        if let search, !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        components.queryItems = queryItems

        guard let url = components.url else { throw ServiceError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw ServiceError.badResponse
        }
        return try Self.decoder.decode(NewsResponse.self, from: data).results
    }

    /// snake_case keys and ISO 8601 dates (with or without fractional seconds).
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let text = try container.decode(String.self)

            let withFraction = ISO8601DateFormatter()
            withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = withFraction.date(from: text) { return date }

            let plain = ISO8601DateFormatter()
            plain.formatOptions = [.withInternetDateTime]
            if let date = plain.date(from: text) { return date }

            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Unrecognized date: \(text)")
        }
        return decoder
    }()
}

enum ServiceError: LocalizedError {
    case invalidURL
    case badResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:  return "The request URL was invalid."
        case .badResponse: return "The server returned an error. Try again in a moment."
        }
    }
}
