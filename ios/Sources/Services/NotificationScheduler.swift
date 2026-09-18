import Foundation
import UserNotifications

/// Local-only notifications (no backend/APNs yet): a daily reminder to open
/// the app and check the current city's status.
enum NotificationScheduler {
    private static let identifier = "snowcntrl.daily-reminder"

    static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        default:
            return false
        }
    }

    static func scheduleDailyReminder(cityName: String, language: AppLanguage) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = cityName
        content.body = Strings.text(for: .dashboardLoading, language: language)
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 18
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Fired as soon as a live-data check finds an active ban for a saved
    /// address — this is the "déneigement programmé" alert, as opposed to
    /// the generic daily reminder above.
    static func notifyBanActive(addressLabel: String, language: AppLanguage) {
        let content = UNMutableNotificationContent()
        content.title = addressLabel
        content.body = Strings.text(for: .dashboardStatusActive, language: language)
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "snowcntrl.ban-active.\(addressLabel.hashValue)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
}
