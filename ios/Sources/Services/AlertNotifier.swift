import Foundation
import UserNotifications

/// How long the snow-truck sound rings for, in seconds — a pre-rendered
/// file exists for each option (`snowplow-<n>s.wav`) since iOS plays a
/// notification sound to completion and gives no API to cut it short.
enum AlertRingDuration: Int, CaseIterable, Identifiable {
    case short = 5
    case medium = 10
    case long = 15
    case extended = 20

    static let storageKey = "snowcntrl.alertRingDurationSeconds"
    static let `default`: AlertRingDuration = .medium

    var id: Int { rawValue }
    var soundFileName: String { "snowplow-\(rawValue)s.wav" }

    static var current: AlertRingDuration {
        let stored = UserDefaults.standard.integer(forKey: storageKey)
        return AlertRingDuration(rawValue: stored) ?? .default
    }
}

/// Rings the phone for an alert marker when snow clearing reaches its
/// street: snow-truck sound, Time Sensitive so it gets through Focus / Do
/// Not Disturb (moon mode), and repeated until "I moved my car".
///
/// Note: the ring/silent switch still mutes sounds — only Apple's Critical
/// Alerts entitlement (granted case by case by Apple) overrides it.
enum AlertNotifier {
    static let categoryIdentifier = "snowcntrl.ban-alert"
    static let movedActionIdentifier = "snowcntrl.moved"
    static let snoozeActionIdentifier = "snowcntrl.snooze"
    static var soundName: UNNotificationSoundName {
        UNNotificationSoundName(AlertRingDuration.current.soundFileName)
    }
    /// Rings right away, then keeps ringing every `reminderInterval` for as
    /// long as the ban stays active and nobody's said "J'ai déplacé ma
    /// voiture" — forgetting for an hour is the exact failure mode this
    /// alert exists for, so it shouldn't give up after two tries.
    static let firstRingDelay: TimeInterval = 1
    static let reminderInterval: TimeInterval = 15 * 60
    static let snoozeDelay: TimeInterval = 10 * 60
    static let testDelay: TimeInterval = 5
    private static let alertedKey = "snowcntrl.alertedAddressIDs"
    private static let firstRingIndex = 0
    private static let reminderIndex = 1
    private static let snoozeIndex = 99

    static func registerCategories(language: AppLanguage) {
        let moved = UNNotificationAction(
            identifier: movedActionIdentifier,
            title: Strings.text(for: .notifActionMoved, language: language),
            options: []
        )
        let snooze = UNNotificationAction(
            identifier: snoozeActionIdentifier,
            title: Strings.text(for: .notifActionSnooze, language: language),
            options: []
        )
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [moved, snooze], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    static func makeContent(for address: SavedAddress, language: AppLanguage, isTest: Bool) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = Strings.text(for: isTest ? .notifTestTitle : .notifBanTitle, language: language)
            .replacingOccurrences(of: "%APP%", with: language.appName)
        content.body = Strings.text(for: isTest ? .notifTestBody : .notifBanBody, language: language)
            .replacingOccurrences(of: "%LABEL%", with: address.label)
        content.sound = UNNotificationSound(named: soundName)
        content.categoryIdentifier = categoryIdentifier
        content.interruptionLevel = .timeSensitive
        content.relevanceScore = 1
        content.threadIdentifier = address.id.uuidString
        content.userInfo = ["addressID": address.id.uuidString]
        return content
    }

    /// A status check found a ban on this alert's street. Rings once per ban
    /// (with its reminders), not again at every later check.
    static func handleBanActive(for address: SavedAddress, language: AppLanguage) {
        var alerted = alertedIDs
        guard !alerted.contains(address.id.uuidString) else { return }
        alerted.insert(address.id.uuidString)
        alertedIDs = alerted

        let content = makeContent(for: address, language: language, isTest: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(
            identifier: requestID(address.id, firstRingIndex),
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: firstRingDelay, repeats: false)
        ))
        // A single recurring request instead of a fixed list of one-shots:
        // keeps firing every `reminderInterval` indefinitely, not just for
        // two more tries, until `acknowledge`/`handleBanCleared` cancels it.
        UNUserNotificationCenter.current().add(UNNotificationRequest(
            identifier: requestID(address.id, reminderIndex),
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: reminderInterval, repeats: true)
        ))
    }

    /// The ban is over (or the alert was removed): stop ringing and allow a
    /// future ban to ring again.
    static func handleBanCleared(for addressID: UUID) {
        var alerted = alertedIDs
        alerted.remove(addressID.uuidString)
        alertedIDs = alerted
        cancelPending(for: addressID)
    }

    /// "J'ai déplacé ma voiture": stop the reminders for this ban.
    static func acknowledge(addressID: UUID) {
        cancelPending(for: addressID)
    }

    static func snooze(addressID: UUID, content: UNNotificationContent) {
        cancelPending(for: addressID)
        let request = UNNotificationRequest(
            identifier: requestID(addressID, snoozeIndex),
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: snoozeDelay, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    /// Lets the user hear the real alert: fires in a few seconds, so there's
    /// time to lock the phone.
    static func sendTest(for address: SavedAddress, language: AppLanguage) {
        let request = UNNotificationRequest(
            identifier: "snowcntrl.test.\(address.id.uuidString)",
            content: makeContent(for: address, language: language, isTest: true),
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: testDelay, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    static func requestIDs(for addressID: UUID) -> [String] {
        [requestID(addressID, firstRingIndex), requestID(addressID, reminderIndex), requestID(addressID, snoozeIndex)]
    }

    private static func cancelPending(for addressID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: requestIDs(for: addressID))
    }

    private static func requestID(_ addressID: UUID, _ index: Int) -> String {
        "snowcntrl.ban.\(addressID.uuidString).\(index)"
    }

    private static var alertedIDs: Set<String> {
        get { Set(UserDefaults.standard.stringArray(forKey: alertedKey) ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: alertedKey) }
    }
}

/// Shows alerts even while the app is open and handles the notification
/// buttons ("J'ai déplacé ma voiture", "Rappelle-moi").
final class NotificationCoordinator: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationCoordinator()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer { completionHandler() }
        let content = response.notification.request.content

        if let rawSeason = content.userInfo["tireSeason"] as? String, let season = TireSeason(rawValue: rawSeason) {
            if response.actionIdentifier == TireChangeAdvisor.stopAskingActionIdentifier {
                TireChangeAdvisor.stopAsking(season: season)
            }
            return
        }

        guard let raw = content.userInfo["addressID"] as? String, let addressID = UUID(uuidString: raw) else { return }
        switch response.actionIdentifier {
        case AlertNotifier.movedActionIdentifier:
            AlertNotifier.acknowledge(addressID: addressID)
        case AlertNotifier.snoozeActionIdentifier:
            AlertNotifier.snooze(addressID: addressID, content: content)
        default:
            break
        }
    }
}
