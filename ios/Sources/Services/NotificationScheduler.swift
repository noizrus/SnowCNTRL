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

    private static let defaultHour = 18

    /// `preferredHour` — the hour the user actually tends to act, learned
    /// from `StatsStore.typicalAcknowledgedHour` — moves the reminder to an
    /// hour ahead of that instead of the fixed default, once there's enough
    /// history to trust it. Falls back to the default otherwise.
    static func scheduleDailyReminder(cityName: String, language: AppLanguage, preferredHour: Int? = nil) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = cityName
        content.body = Strings.text(for: .dashboardLoading, language: language)
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = preferredHour.map { max(0, $0 - 1) } ?? defaultHour
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    private static let parkingDetectedIdentifier = "snowcntrl.parking-detected"

    /// Fired by `CarConnectionMonitor` right after a car-audio disconnect —
    /// opening the app from here is what actually surfaces the "add an
    /// alert here?" suggestion, since notifications can't show custom UI.
    static func notifyParkingDetected() {
        let language = Localizer().language
        let content = UNMutableNotificationContent()
        content.title = Strings.text(for: .parkingDetectedTitle, language: language)
        content.body = Strings.text(for: .parkingDetectedBody, language: language)
        content.sound = .default
        let request = UNNotificationRequest(identifier: parkingDetectedIdentifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
