//
//  SkyEvent.swift
//  FinalProject
//

import Foundation

/// An upcoming astronomical event loaded from Data/sky_events.json.
/// Not stored in SwiftData; the user saves a copy as a SavedEvent.
struct SkyEvent: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let kind: Kind
    let date: Date
    let visibility: String
    let summary: String

    enum Kind: String, Codable, CaseIterable, Identifiable {
        case solarEclipse
        case lunarEclipse
        case meteorShower
        case planetary

        var id: String { rawValue }

        var label: String {
            switch self {
            case .solarEclipse: return "Solar eclipse"
            case .lunarEclipse: return "Lunar eclipse"
            case .meteorShower: return "Meteor shower"
            case .planetary:    return "Planetary event"
            }
        }

        var systemImage: String {
            switch self {
            case .solarEclipse: return "sun.max.circle"
            case .lunarEclipse: return "moon.circle"
            case .meteorShower: return "sparkles"
            case .planetary:    return "moon.stars"
            }
        }
    }
}

extension SkyEvent {
    /// Whole days from today until the event (negative if it has passed).
    var daysUntil: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    var daysUntilText: String {
        switch daysUntil {
        case ..<0: return "Passed"
        case 0:    return "Today"
        case 1:    return "Tomorrow"
        default:   return "In \(daysUntil) days"
        }
    }
}
