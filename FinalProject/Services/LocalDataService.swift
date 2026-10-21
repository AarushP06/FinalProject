//
//  LocalDataService.swift
//  FinalProject
//

import Foundation

/// Loads JSON files bundled with the app (Data/planets.json, Data/sky_events.json).
enum LocalDataService {
    static func load<T: Decodable>(_ type: T.Type,
                                   from fileName: String,
                                   decoder: JSONDecoder = .bundledData) throws -> T {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw DataError.fileNotFound(fileName)
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }
}

enum DataError: LocalizedError {
    case fileNotFound(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "Couldn't find \(name).json in the app bundle."
        }
    }
}

extension JSONDecoder {
    /// Reads dates written as "yyyy-MM-dd" in the user's own time zone,
    /// so an eclipse on Feb 6 shows as Feb 6 and not Feb 5.
    static var bundledData: JSONDecoder {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
}
