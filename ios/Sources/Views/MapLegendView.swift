import SwiftUI

/// Info-Neige color legend, shown over the map on demand.
struct MapLegendView: View {
    @EnvironmentObject private var localizer: Localizer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localizer.s(.legendTitle))
                .font(.caption.weight(.bold))
            ForEach(SnowClearingStatus.allCases, id: \.self) { status in
                HStack(spacing: 8) {
                    Capsule()
                        .fill(status.neonColor)
                        .frame(width: 22, height: 4)
                        .shadow(color: status.neonColor, radius: 3)
                    Text(status.label(language: localizer.language))
                        .font(.caption)
                }
            }
            Text(localizer.s(.legendCityWideNote))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(width: 230, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

/// Round floating button used over the map (locate me, legend…).
struct MapControlButton: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let systemImage: String
    var isActive = false
    let accessibilityText: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(isActive ? Color.black : themeManager.palette.primary)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(isActive ? AnyShapeStyle(themeManager.palette.primary) : AnyShapeStyle(.ultraThinMaterial))
                )
                .overlay(Circle().strokeBorder(themeManager.palette.primary.opacity(0.45), lineWidth: 1))
                .shadow(color: themeManager.palette.primary.opacity(0.35), radius: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityText)
    }
}

/// Small floating capsule message over the map.
struct MapHintCapsule: View {
    let text: String
    var showsProgress = false

    var body: some View {
        HStack(spacing: 6) {
            if showsProgress {
                ProgressView().controlSize(.small)
            }
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
    }
}
