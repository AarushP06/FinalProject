//
//  NotificationService.swift
//  FinalProject
//

import Foundation
import UserNotifications

/// Local reminders for saved events.
/// TODO (Prompt 6): implement permission + scheduling + cancelling.
enum NotificationService {
    static func requestPermission() async -> Bool {
        // TODO: ask UNUserNotificationCenter for .alert, .sound, .badge
        return false
    }

    static func scheduleReminder(for event: SavedEvent) async {
        // TODO: schedule a notification the day before event.date (e.g. 9 a.m.),
        // using event.eventID as the identifier.
    }

    static func cancelReminder(for event: SavedEvent) {
        // TODO: remove the pending notification with event.eventID
    }
}
