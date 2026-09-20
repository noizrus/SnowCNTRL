import Foundation
import ActivityKit

/// Shared between the main app (which starts/updates/ends the activity) and
/// the widget extension (which renders it on the Lock Screen / Dynamic
/// Island). Kept in `Sources/Shared` so both targets compile the exact same
/// type instead of two structurally-identical ones that could drift apart.
struct SnowBanActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var stateRawValue: String
        var updatedAt: Date
    }

    var cityName: String
    var languageRawValue: String
}
