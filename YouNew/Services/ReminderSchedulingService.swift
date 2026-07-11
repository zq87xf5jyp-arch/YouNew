import Foundation
import UserNotifications

protocol ReminderScheduling {
    func scheduleLocalNotification(for reminder: ReminderItem) async -> Bool
    func cancelLocalNotification(for reminder: ReminderItem) async
}

struct ReminderSchedulingService: ReminderScheduling {
    func scheduleLocalNotification(for reminder: ReminderItem) async -> Bool {
        guard let reminderDate = reminder.date else { return false }

        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else { return false }

            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.detail
            content.sound = .default

            let triggerDate = Self.notificationDate(for: reminderDate)
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: triggerDate
            )
            let request = UNNotificationRequest(
                identifier: Self.notificationIdentifier(for: reminder),
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            )

            try await center.add(request)
            return true
        } catch {
            return false
        }
    }

    func cancelLocalNotification(for reminder: ReminderItem) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [Self.notificationIdentifier(for: reminder)]
        )
    }

    private static func notificationDate(for dueDate: Date) -> Date {
        let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: dueDate) ?? dueDate
        let earliestAllowedDate = Date().addingTimeInterval(60)
        return max(oneDayBefore, earliestAllowedDate)
    }

    private static func notificationIdentifier(for reminder: ReminderItem) -> String {
        "younew.reminder.\(reminder.id.uuidString)"
    }
}
