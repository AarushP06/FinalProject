//
//  AstronomyEventsService.swift
//  FinalProject
//

import Foundation

/// Fetches eclipses calculated for the observer's location by AstronomyAPI.
struct AstronomyEventsService {
    private let endpoint = URL(string: "https://api.astronomyapi.com/api/v2/bodies/events/")!

    func fetchEclipses(at coordinates: ObservationCoordinates,
                      locationName: String) async throws -> [SkyEvent] {
        let credentials = try await Task.detached(priority: .utility) {
            try Self.readCredentials()
        }.value

        let sun = try await fetch(body: "sun", coordinates: coordinates,
                                  locationName: locationName, credentials: credentials)
        let moon = try await fetch(body: "moon", coordinates: coordinates,
                                   locationName: locationName, credentials: credentials)
        return (sun + moon).sorted { $0.date < $1.date }
    }

    private func fetch(body: String,
                       coordinates: ObservationCoordinates,
                       locationName: String,
                       credentials: String) async throws -> [SkyEvent] {
        var components = URLComponents(url: endpoint.appendingPathComponent(body),
                                       resolvingAgainstBaseURL: false)!
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let today = Date()
        let end = Calendar.current.date(byAdding: .day, value: 365, to: today) ?? today
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinates.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinates.longitude)),
            URLQueryItem(name: "elevation", value: "0"),
            URLQueryItem(name: "from_date", value: formatter.string(from: today)),
            URLQueryItem(name: "to_date", value: formatter.string(from: end)),
            URLQueryItem(name: "time", value: "09:00:00"),
            URLQueryItem(name: "output", value: "rows")
        ]
        guard let url = components.url else { throw AstronomyEventsError.badResponse }
        var request = URLRequest(url: url)
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 20

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AstronomyEventsError.networkUnavailable
        }
        guard let http = response as? HTTPURLResponse else {
            throw AstronomyEventsError.badResponse
        }
        if http.statusCode == 401 || http.statusCode == 403 {
            throw AstronomyEventsError.invalidCredentials
        }
        guard (200..<300).contains(http.statusCode),
              let payload = try? JSONDecoder().decode(AstronomyEventsResponse.self, from: data) else {
            throw AstronomyEventsError.badResponse
        }
        return payload.data.rows.flatMap(\.events).compactMap {
            Self.skyEvent(from: $0, locationName: locationName)
        }
    }

    private static func skyEvent(from event: AstronomyEventsResponse.Event,
                                 locationName: String) -> SkyEvent? {
        let kind: SkyEvent.Kind
        if event.type.hasSuffix("solar_eclipse") {
            kind = .solarEclipse
        } else if event.type.hasSuffix("lunar_eclipse") {
            kind = .lunarEclipse
        } else {
            return nil
        }
        guard event.eventHighlights.isAboveHorizon,
              let dateString = event.eventHighlights.peak?.date else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date: Date?
        if let precise = formatter.date(from: dateString) {
            date = precise
        } else {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: dateString)
        }
        guard let date else { return nil }
        let name = event.type.replacingOccurrences(of: "_", with: " ").capitalized
        let day = DateFormatter()
        day.calendar = Calendar(identifier: .gregorian)
        day.locale = Locale(identifier: "en_US_POSIX")
        day.dateFormat = "yyyy-MM-dd"
        return SkyEvent(id: "astronomyapi-\(event.type)-\(day.string(from: date))",
                        title: name,
                        kind: kind,
                        date: date,
                        visibility: "AstronomyAPI predicts this eclipse above the horizon for \(locationName). Weather may affect viewing.",
                        summary: "AstronomyAPI calculates this eclipse for the selected location. Check local viewing details before making plans.",
                        source: .astronomyAPI)
    }

    private static func readCredentials() throws -> String {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let secrets = try? PropertyListDecoder().decode([String: String].self, from: data),
              let id = secrets["ASTRONOMY_API_APP_ID"]?.trimmingCharacters(in: .whitespacesAndNewlines),
              let secret = secrets["ASTRONOMY_API_APP_SECRET"]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !id.isEmpty, !secret.isEmpty else {
            throw AstronomyEventsError.missingCredentials
        }
        return Data("\(id):\(secret)".utf8).base64EncodedString()
    }
}

private struct AstronomyEventsResponse: Decodable {
    let data: ResultData

    struct ResultData: Decodable {
        let rows: [Row]
    }

    struct Row: Decodable {
        let events: [Event]
    }

    struct Event: Decodable {
        let type: String
        let eventHighlights: Highlights
    }

    struct Highlights: Decodable {
        let penumbralStart: Point?
        let partialStart: Point?
        let fullStart: Point?
        let peak: Point?
        let fullEnd: Point?
        let partialEnd: Point?
        let penumbralEnd: Point?

        var isAboveHorizon: Bool {
            [penumbralStart, partialStart, fullStart, peak, fullEnd, partialEnd, penumbralEnd]
                .contains { ($0?.altitude ?? -.infinity) > 0 }
        }
    }

    struct Point: Decodable {
        let date: String
        let altitude: Double?
    }
}

enum AstronomyEventsError: LocalizedError {
    case missingCredentials
    case invalidCredentials
    case networkUnavailable
    case badResponse

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Add AstronomyAPI ID and Secret to Secrets.plist to refresh eclipses."
        case .invalidCredentials:
            return "AstronomyAPI rejected the ID or Secret. Bundled events are still shown."
        case .networkUnavailable:
            return "Couldn't reach AstronomyAPI. Bundled events are still shown."
        case .badResponse:
            return "Couldn't load eclipses. Bundled events are still shown."
        }
    }
}
