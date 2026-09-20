import Foundation
import ActivityKit

/// Starts, updates, and ends the Lock Screen / Dynamic Island Live Activity
/// that mirrors the dashboard's status pill. Purely reactive to whatever the
/// dashboard already fetched — this never polls or fetches on its own, so a
/// failure here (permission denied, activity limit reached) can never affect
/// the rest of the app.
enum LiveActivityManager {
    static func sync(cityName: String, languageRawValue: String, state: ParkingBanState, updatedAt: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let contentState = SnowBanActivityAttributes.ContentState(
            stateRawValue: StatusCache.rawValue(for: state),
            updatedAt: updatedAt
        )

        if let existing = Activity<SnowBanActivityAttributes>.activities.first {
            Task {
                await existing.update(using: contentState)
                if state != .activeBanNow {
                    await existing.end(using: contentState, dismissalPolicy: .after(Date().addingTimeInterval(600)))
                }
            }
            return
        }

        guard state == .activeBanNow else { return }

        let attributes = SnowBanActivityAttributes(cityName: cityName, languageRawValue: languageRawValue)
        do {
            _ = try Activity.request(attributes: attributes, contentState: contentState, pushType: nil)
        } catch {
            // Best-effort UI polish only — see doc comment above.
        }
    }
}
