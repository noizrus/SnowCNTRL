import ActivityKit
import SwiftUI
import WidgetKit

/// Lock Screen banner + Dynamic Island presentation for an active parking
/// ban, started by `LiveActivityManager` in the main app. Purely a view over
/// `SnowBanActivityAttributes` — no logic of its own beyond formatting.
struct SnowBanLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SnowBanActivityAttributes.self) { context in
            LiveActivityLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "snowflake")
                        .foregroundStyle(WidgetText.color(for: context.state.stateRawValue))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(WidgetText.status(stateRawValue: context.state.stateRawValue, language: context.attributes.languageRawValue))
                        .font(.caption)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.cityName)
                        .font(.headline)
                }
            } compactLeading: {
                Image(systemName: "snowflake")
            } compactTrailing: {
                Circle()
                    .fill(WidgetText.color(for: context.state.stateRawValue))
                    .frame(width: 12, height: 12)
            } minimal: {
                Image(systemName: "snowflake")
            }
        }
    }
}

private struct LiveActivityLockScreenView: View {
    let context: ActivityViewContext<SnowBanActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "snowflake")
                .font(.title2)
                .foregroundStyle(WidgetText.color(for: context.state.stateRawValue))
            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.cityName)
                    .font(.headline)
                Text(WidgetText.status(stateRawValue: context.state.stateRawValue, language: context.attributes.languageRawValue))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .activityBackgroundTint(Color.black.opacity(0.75))
        .activitySystemActionForegroundColor(.white)
    }
}
