import Foundation
import UserNotifications

enum TireSeason: String {
    case winter, summer

    var titleKey: LocKey {
        switch self {
        case .winter: return .tireReminderWinterTitle
        case .summer: return .tireReminderSummerTitle
        }
    }

    var bodyKey: LocKey {
        switch self {
        case .winter: return .tireReminderWinterBody
        case .summer: return .tireReminderSummerBody
        }
    }
}

/// Recommends switching tires a little ahead of the seasonal rush, based on
/// the same 14-day forecast already fetched for the weather tab — not a
/// fixed calendar date (a legal deadline like Quebec's Dec 1–Mar 15 is a
/// minimum, not a temperature) and not reactive to the first snowfall like
/// most drivers, which is exactly the crowd this gets ahead of.
enum TireChangeAdvisor {
    static let categoryIdentifier = "snowcntrl.tire-reminder"
    static let dismissActionIdentifier = "snowcntrl.tire.dismiss"
    static let stopAskingActionIdentifier = "snowcntrl.tire.stopAsking"
    static let enabledKey = "snowcntrl.tireReminderEnabled"

    /// Winter tires are recommended once nights are reliably below freezing
    /// — not the 7°C rule of thumb, which fires weeks before it's actually
    /// needed and reads as "do this right now" instead of "here's what's
    /// coming". Summer tires still use the 7°C rule since there's no
    /// urgency/safety case for catching that one early.
    private static let freezeThresholdC = 0.0
    private static let summerThresholdC = 7.0
    /// Requires the trend to hold for several consecutive days, not one
    /// cold/warm blip, before recommending a swap.
    private static let sustainDays = 3

    static func registerCategory(language: AppLanguage) {
        let dismiss = UNNotificationAction(
            identifier: dismissActionIdentifier,
            title: Strings.text(for: .tireReminderDismiss, language: language),
            options: []
        )
        let stopAsking = UNNotificationAction(
            identifier: stopAskingActionIdentifier,
            title: Strings.text(for: .tireReminderStopAsking, language: language),
            options: [.destructive]
        )
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [dismiss, stopAsking],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().getNotificationCategories { existing in
            UNUserNotificationCenter.current().setNotificationCategories(existing.union([category]))
        }
    }

    private static let lastCheckedDateKey = "snowcntrl.tireReminder.lastCheckedDate"

    /// Called alongside the existing ban check (app launch/foreground and
    /// best-effort background refresh), but only actually fetches weather
    /// and evaluates the trend once per calendar day — no need for more,
    /// since this is a once-a-year notification at most per season.
    ///
    /// Scans the whole available forecast (up to 14 days) for the first
    /// sustained cold or warm spell, instead of only checking whether it's
    /// already happening in the next few days — that's what turns this
    /// into an early heads-up ("in 9 days it'll be below freezing") rather
    /// than a same-day "go change your tires now".
    static func checkAndNotify(city: City, language: AppLanguage) async {
        guard UserDefaults.standard.bool(forKey: enabledKey) else { return }
        guard shouldCheckToday() else { return }
        guard let forecast = await WeatherService.forecast(for: city), forecast.count >= sustainDays else { return }
        markCheckedToday()

        if let daysUntil = daysUntilSustained(forecast, where: { $0.lowC < freezeThresholdC }) {
            notifyIfDue(season: .winter, daysUntil: daysUntil, cityName: city.name, language: language)
        } else if let daysUntil = daysUntilSustained(forecast, where: { $0.highC > summerThresholdC }) {
            notifyIfDue(season: .summer, daysUntil: daysUntil, cityName: city.name, language: language)
        }
    }

    /// First index (days from today) where `condition` holds for
    /// `sustainDays` in a row, or `nil` if no such run exists in `forecast`.
    private static func daysUntilSustained(_ forecast: [DailyForecast], where condition: (DailyForecast) -> Bool) -> Int? {
        guard forecast.count >= sustainDays else { return nil }
        for start in 0...(forecast.count - sustainDays) {
            if forecast[start..<(start + sustainDays)].allSatisfy(condition) {
                return start
            }
        }
        return nil
    }

    /// The action button on the notification itself — silences just this
    /// one season (winter or summer) going forward, not the other.
    static func stopAsking(season: TireSeason) {
        UserDefaults.standard.set(true, forKey: optOutKey(season))
    }

    /// Turning the Settings toggle back on after having turned it off is
    /// the "undo" for a "Ne plus demander" tapped by mistake.
    static func resetOptOuts() {
        UserDefaults.standard.removeObject(forKey: optOutKey(.winter))
        UserDefaults.standard.removeObject(forKey: optOutKey(.summer))
    }

    private static func notifyIfDue(season: TireSeason, daysUntil: Int, cityName: String, language: AppLanguage) {
        guard !isOptedOut(season) else { return }
        let year = Calendar.current.component(.year, from: Date())
        guard lastNotifiedYear(season) != year else { return }
        setLastNotifiedYear(season, year: year)

        let body = Strings.text(for: season.bodyKey, language: language)
            .replacingOccurrences(of: "%DAYS%", with: String(daysUntil))
            .replacingOccurrences(of: "%CITY%", with: cityName)

        let content = UNMutableNotificationContent()
        content.title = Strings.text(for: season.titleKey, language: language)
        content.body = body
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        content.userInfo = ["tireSeason": season.rawValue]

        let request = UNNotificationRequest(
            identifier: "snowcntrl.tire.\(season.rawValue).\(year)",
            content: content,
            trigger: nil // fires right away — this check already runs at most once a day
        )
        UNUserNotificationCenter.current().add(request)
    }

    private static func isOptedOut(_ season: TireSeason) -> Bool {
        UserDefaults.standard.bool(forKey: optOutKey(season))
    }

    private static func lastNotifiedYear(_ season: TireSeason) -> Int? {
        let value = UserDefaults.standard.integer(forKey: lastNotifiedKey(season))
        return value == 0 ? nil : value
    }

    private static func setLastNotifiedYear(_ season: TireSeason, year: Int) {
        UserDefaults.standard.set(year, forKey: lastNotifiedKey(season))
    }

    private static func optOutKey(_ season: TireSeason) -> String { "snowcntrl.tireReminder.optOut.\(season.rawValue)" }
    private static func lastNotifiedKey(_ season: TireSeason) -> String { "snowcntrl.tireReminder.lastYear.\(season.rawValue)" }

    private static func shouldCheckToday() -> Bool {
        guard let last = UserDefaults.standard.object(forKey: lastCheckedDateKey) as? Date else { return true }
        return !Calendar.current.isDateInToday(last)
    }

    private static func markCheckedToday() {
        UserDefaults.standard.set(Date(), forKey: lastCheckedDateKey)
    }
}
