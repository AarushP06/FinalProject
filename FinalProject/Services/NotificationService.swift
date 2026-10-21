//
//  NotificationService.swift
//  FinalProject
//

import Foundation
import UserNotifications

/// Local reminders for saved events.
enum NotificationService {
    static func requestPermission() async throws -> Bool {
        try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])
    }

    static func scheduleReminder(for event: SavedEvent) async throws {
        let calendar = Calendar.current
        guard let dayBefore = calendar.date(byAdding: .day, value: -1, to: event.date),
              let reminderDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: dayBefore),
              reminderDate > .now else {
            throw NotificationError.reminderTimePassed
        }
        guard try await requestPermission() else {
            throw NotificationError.permissionDenied
        }

        let content = UNMutableNotificationContent()
        content.title = "Sky event tomorrow"
        content.body = "\(event.title) is tomorrow."
        content.sound = .default

        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: event.eventID, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }

    static func cancelReminder(for event: SavedEvent) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [event.eventID])
    }
}

enum NotificationError: LocalizedError {
    case permissionDenied
    case reminderTimePassed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Notifications are off. The event was saved without a reminder."
        case .reminderTimePassed:
            return "The 9 a.m. reminder time has already passed. The event was saved without a reminder."
        }
    }
}
