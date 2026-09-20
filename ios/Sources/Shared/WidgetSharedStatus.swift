import Foundation

/// Bridges the last known status from the main app to the widget extension
/// via the shared App Group container. Deliberately tiny and dependency-free
/// (no MapKit/UIKit) so it can compile unchanged in both targets.
public struct WidgetSharedStatus: Codable {
    public static let appGroupID = "group.com.snowcntrl.app"
    private static let key = "snowcntrl.widget.status"

    public let cityName: String
    /// Raw value of `ParkingBanState` ("activeBanNow" / "noActiveBan" / "unknownNoData").
    public let stateRawValue: String
    public let languageRawValue: String
    public let updatedAt: Date

    public init(cityName: String, stateRawValue: String, languageRawValue: String, updatedAt: Date) {
        self.cityName = cityName
        self.stateRawValue = stateRawValue
        self.languageRawValue = languageRawValue
        self.updatedAt = updatedAt
    }

    public static func save(cityName: String, stateRawValue: String, languageRawValue: String) {
        let entry = WidgetSharedStatus(
            cityName: cityName,
            stateRawValue: stateRawValue,
            languageRawValue: languageRawValue,
            updatedAt: Date()
        )
        guard
            let defaults = UserDefaults(suiteName: appGroupID),
            let data = try? JSONEncoder().encode(entry)
        else { return }
        defaults.set(data, forKey: key)
    }

    public static func load() -> WidgetSharedStatus? {
        guard
            let defaults = UserDefaults(suiteName: appGroupID),
            let data = defaults.data(forKey: key)
        else { return nil }
        return try? JSONDecoder().decode(WidgetSharedStatus.self, from: data)
    }
}
