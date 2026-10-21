//
//  SolarSystemService.swift
//  FinalProject
//

import Foundation

/// Values supplied by Solar System OpenData for a planet.
struct SolarSystemBodyData: Decodable {
    let moons: [Moon]?
    let mass: Mass?
    let density: Double?

    private enum CodingKeys: String, CodingKey {
        case moons, mass, density
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // A null moons value means zero; an absent field means an incomplete response.
        guard container.contains(.moons) else {
            throw DecodingError.keyNotFound(
                CodingKeys.moons,
                .init(codingPath: container.codingPath, debugDescription: "Missing moons field")
            )
        }
        moons = try container.decodeIfPresent([Moon].self, forKey: .moons)
        mass = try container.decodeIfPresent(Mass.self, forKey: .mass)
        density = try container.decodeIfPresent(Double.self, forKey: .density)
    }

    struct Moon: Decodable {
        let moon: String
    }

    struct Mass: Decodable {
        let massValue: Double
        let massExponent: Int
    }

    var moonCount: Int { moons?.count ?? 0 }
    var massKg: Double? {
        guard let mass else { return nil }
        return mass.massValue * pow(10, Double(mass.massExponent))
    }
}

/// Fetches one body's current data using the key bundled in Secrets.plist.
struct SolarSystemService {
    func fetchBody(id: String) async throws -> SolarSystemBodyData {
        let key = try await Task.detached(priority: .utility) {
            try Self.readAPIKey()
        }.value

        let url = URL(string: "https://api.le-systeme-solaire.net/rest/bodies/")!
            .appendingPathComponent(id.lowercased())
        var request = URLRequest(url: url)
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw SolarSystemError.networkUnavailable
        }

        guard let response = response as? HTTPURLResponse else {
            throw SolarSystemError.badResponse
        }
        if response.statusCode == 401 || response.statusCode == 403 {
            throw SolarSystemError.invalidKey
        }
        guard (200..<300).contains(response.statusCode) else {
            throw SolarSystemError.badResponse
        }
        guard let body = try? JSONDecoder().decode(SolarSystemBodyData.self, from: data) else {
            throw SolarSystemError.badResponse
        }
        return body
    }

    private static func readAPIKey() throws -> String {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let secrets = try? PropertyListDecoder().decode([String: String].self, from: data),
              let key = secrets["SOLAR_SYSTEM_API_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !key.isEmpty else {
            throw SolarSystemError.missingKey
        }
        return key
    }
}

enum SolarSystemError: LocalizedError {
    case missingKey
    case invalidKey
    case networkUnavailable
    case badResponse

    var errorDescription: String? {
        switch self {
        case .missingKey:
            return "Add SOLAR_SYSTEM_API_KEY to Secrets.plist to refresh."
        case .invalidKey:
            return "The API key was rejected. Current values are still shown."
        case .networkUnavailable:
            return "Couldn't reach the API. Current values are still shown."
        case .badResponse:
            return "Couldn't load planet data. Current values are still shown."
        }
    }
}
