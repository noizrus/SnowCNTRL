import Foundation

/// What the main app hands to the widget extension through the shared App
/// Group container. Deliberately tiny and dependency-free (no MapKit/UIKit)
/// so it compiles unchanged in both targets. New fields are optional so an
/// entry saved by an older build still decodes.
public struct WidgetSharedStatus: Codable {
    public static let appGroupID = "group.com.snowcntrl.app"
    private static let key = "snowcntrl.widget.status"

    public let cityName: String
    /// Raw value of `ParkingBanState` ("activeBanNow" / "noActiveBan" / "unknownNoData").
    public let stateRawValue: String
    public let languageRawValue: String
    public let updatedAt: Date
    /// Label of the first alert in this city, if any.
    public let alertLabel: String?
    public let isOffSeason: Bool?
    /// Theme primary color as sRGB components (0...1).
    public let accentRGB: [Double]?

    public init(
        cityName: String,
        stateRawValue: String,
        languageRawValue: String,
        updatedAt: Date,
        alertLabel: String? = nil,
        isOffSeason: Bool? = nil,
        accentRGB: [Double]? = nil
    ) {
        self.cityName = cityName
        self.stateRawValue = stateRawValue
        self.languageRawValue = languageRawValue
        self.updatedAt = updatedAt
        self.alertLabel = alertLabel
        self.isOffSeason = isOffSeason
        self.accentRGB = accentRGB
    }

    public static func save(_ entry: WidgetSharedStatus) {
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
