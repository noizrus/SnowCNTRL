import Foundation

/// Tracks the app's own local, on-device record of "the alert worked" —
/// every time the user taps "J'ai déplacé ma voiture" on an active-ban
/// notification, that's one clearly avoided fine. No backend: this is a
/// personal counter, not a claim of exact savings, which is why the amount
/// shown is always labeled as an estimate.
final class StatsStore: ObservableObject {
    static let shared = StatsStore()

    /// A typical snow-clearing parking ticket in Quebec/Canada — used only
    /// to turn the count into a relatable number, never presented as an
    /// exact or city-specific figure.
    static let estimatedFineCAD: Int = 100

    @Published private(set) var avoidedBansCount: Int
    /// Hour-of-day (0–23) for each acknowledged ban, most recent last —
    /// capped so this stays a rolling recent average, not a lifetime one
    /// that would barely move after the first winter.
    @Published private(set) var acknowledgedHours: [Int]
    @Published private(set) var firstUseDate: Date

    private static let countKey = "snowcntrl.stats.avoidedBansCount"
    private static let hoursKey = "snowcntrl.stats.acknowledgedHours"
    private static let firstUseKey = "snowcntrl.stats.firstUseDate"
    private static let maxTrackedHours = 20

    init() {
        avoidedBansCount = UserDefaults.standard.integer(forKey: Self.countKey)
        acknowledgedHours = UserDefaults.standard.array(forKey: Self.hoursKey) as? [Int] ?? []
        if let stored = UserDefaults.standard.object(forKey: Self.firstUseKey) as? Date {
            firstUseDate = stored
        } else {
            firstUseDate = Date()
            UserDefaults.standard.set(firstUseDate, forKey: Self.firstUseKey)
        }
    }

    var estimatedSavingsCAD: Int {
        avoidedBansCount * Self.estimatedFineCAD
    }

    /// The hour most reminders should target, once there's enough history
    /// to trust it — otherwise callers fall back to a fixed default.
    var typicalAcknowledgedHour: Int? {
        guard acknowledgedHours.count >= 3 else { return nil }
        return Int((Double(acknowledgedHours.reduce(0, +)) / Double(acknowledgedHours.count)).rounded())
    }

    func recordAvoidedBan(at date: Date = Date()) {
        avoidedBansCount += 1
        UserDefaults.standard.set(avoidedBansCount, forKey: Self.countKey)

        var hours = acknowledgedHours
        hours.append(Calendar.current.component(.hour, from: date))
        if hours.count > Self.maxTrackedHours { hours.removeFirst(hours.count - Self.maxTrackedHours) }
        acknowledgedHours = hours
        UserDefaults.standard.set(hours, forKey: Self.hoursKey)
    }
}
