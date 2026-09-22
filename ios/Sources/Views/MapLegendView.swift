import SwiftUI

/// Card behind the "i" map button: Info-Neige color legend plus the way in
/// to the plain-language explanation of the city's rules.
struct MapLegendView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    var onShowCityRules: () -> Void

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
            Button(action: onShowCityRules) {
                Label(localizer.s(.cityRulesButton), systemImage: "questionmark.circle")
                    .font(.caption.weight(.semibold))
            }
            .buttonStyle(ThemedFillButtonStyle(palette: themeManager.palette, cornerRadius: 10))
            .padding(.top, 2)
        }
        .padding(12)
        .frame(width: 240, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

/// Round floating button used over the map (locate me, legend…): solid
/// theme color so it stands out on any map, in day or night mode; the
/// accent color marks it as toggled on.
struct MapControlButton: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let systemImage: String
    var isActive = false
    let accessibilityText: String
    let action: () -> Void

    var body: some View {
        let palette = themeManager.palette
        let fill = isActive ? palette.accent : palette.primary
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(isActive ? palette.onAccent : palette.onPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(fill))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.35), lineWidth: 1))
                .shadow(color: fill.opacity(0.55), radius: 8)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
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
