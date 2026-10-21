//
//  LaunchService.swift
//  FinalProject
//

import Foundation

struct LaunchLoadResult {
    let launches: [Launch]
    let warning: String?
}

/// Fetches launches and keeps one hour of results in the app's Caches directory.
actor LaunchService {
    private let endpoint = URL(string: "https://ll.thespacedevs.com/2.3.0/launches/upcoming/?limit=20&ordering=net")!
    private let cacheLifetime: TimeInterval = 60 * 60

    func upcomingLaunches() async throws -> LaunchLoadResult {
        let cached = loadCache()
        if let cached, (0..<cacheLifetime).contains(Date().timeIntervalSince(cached.fetchedAt)) {
            return LaunchLoadResult(launches: cached.launches, warning: nil)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: endpoint)
            guard let http = response as? HTTPURLResponse else {
                throw LaunchServiceError.invalidResponse
            }
            guard (200..<300).contains(http.statusCode) else {
                throw LaunchServiceError.httpStatus(http.statusCode)
            }

            let launches = try Self.apiDecoder.decode(LaunchResponse.self, from: data).results
            let newCache = LaunchCache(fetchedAt: .now, launches: launches)
            do {
                try saveCache(newCache)
                return LaunchLoadResult(launches: launches, warning: nil)
            } catch {
                return LaunchLoadResult(launches: launches,
                                        warning: "Launches loaded, but the offline cache could not be saved.")
            }
        } catch {
            if let cached {
                return LaunchLoadResult(launches: cached.launches,
                                        warning: "Could not refresh launches. Showing saved results.")
            }
            throw error
        }
    }

    private func loadCache() -> LaunchCache? {
        guard let url = cacheURL(),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(LaunchCache.self, from: data)
    }

    private func saveCache(_ cache: LaunchCache) throws {
        guard let url = cacheURL() else { throw LaunchServiceError.cacheUnavailable }
        let data = try JSONEncoder().encode(cache)
        try data.write(to: url, options: .atomic)
    }

    private func cacheURL() -> URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("launches-v2.3.0.json")
    }

    private static let apiDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let text = try decoder.singleValueContainer().decode(String.self)
            let withFraction = ISO8601DateFormatter()
            withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = withFraction.date(from: text) { return date }
            let plain = ISO8601DateFormatter()
            if let date = plain.date(from: text) { return date }
            throw DecodingError.dataCorruptedError(in: try decoder.singleValueContainer(),
                                                   debugDescription: "Invalid launch date: \(text)")
        }
        return decoder
    }()
}

private struct LaunchCache: Codable {
    let fetchedAt: Date
    let launches: [Launch]
}

enum LaunchServiceError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case cacheUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "The launch service returned an invalid response."
        case .httpStatus(429): return "Launch data is rate limited. Try again later."
        case .httpStatus(let code): return "The launch service returned HTTP \(code)."
        case .cacheUnavailable: return "The launch cache is unavailable."
        }
    }
}
