import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleMorningReminder(hour: Int = 8) {
        center.removePendingNotificationRequests(withIdentifiers: ["morning"])
        guard hour > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to walk!"
        content.body = "Your mascot is waiting. Start your daily steps!"
        content.sound = .default

        var date = DateComponents()
        date.hour = hour
        date.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

        let req = UNNotificationRequest(identifier: "morning", content: content, trigger: trigger)
        center.add(req)
    }

    func scheduleInactivityAlert(minutes: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["inactivity"])
        guard minutes > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Don't stop now!"
        content.body = "You haven't moved in a while. A short walk helps!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(minutes * 60), repeats: false)

        let req = UNNotificationRequest(identifier: "inactivity", content: content, trigger: trigger)
        center.add(req)
    }

    func sendGoalReached(steps: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Goal reached!"
        content.body = "You hit \(steps) steps today. Amazing!"
        content.sound = .default

        let req = UNNotificationRequest(identifier: "goal-\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        center.add(req)
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    func refresh(enabled: Bool, inactivityMinutes: Int) {
        if enabled {
            scheduleMorningReminder()
            scheduleInactivityAlert(minutes: inactivityMinutes)
        } else {
            cancelAll()
        }
    }
}
