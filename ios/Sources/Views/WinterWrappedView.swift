import SwiftUI

/// A shareable end-of-winter recap — Spotify-Wrapped style — built entirely
/// from the on-device stats already tracked (`StatsStore`), no backend.
/// Reachable any time from Settings, not just at season's end, since a
/// mid-winter user might want to check in on their own tally too.
struct WinterWrappedView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject private var stats = StatsStore.shared
    let cityName: String?
    @State private var renderedImage: Image?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                card
                    .padding(.top, 12)

                if let renderedImage {
                    ShareLink(
                        item: renderedImage,
                        preview: SharePreview(localizer.s(.wrappedShareTitle), image: renderedImage)
                    ) {
                        Label(localizer.s(.wrappedShareButton), systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(ThemedFillButtonStyle(palette: themeManager.palette))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .navigationTitle(localizer.s(.wrappedTitle))
        .navigationBarTitleDisplayMode(.inline)
        .themedNavigationBar(themeManager.palette)
        .tint(themeManager.palette.primaryText)
        .task { renderCardImage() }
    }

    private var card: some View {
        WinterWrappedCard(
            cityName: cityName,
            avoidedBansCount: stats.avoidedBansCount,
            estimatedSavingsCAD: stats.estimatedSavingsCAD,
            firstUseDate: stats.firstUseDate,
            language: localizer.language,
            palette: themeManager.palette
        )
    }

    /// Rendered once for sharing — a live SwiftUI view can't be attached to
    /// a `ShareLink` directly, so this turns it into an image the same way
    /// it's drawn on screen.
    @MainActor
    private func renderCardImage() {
        let renderer = ImageRenderer(content: card.frame(width: 340))
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            renderedImage = Image(uiImage: uiImage)
        }
    }
}

/// The visual card itself, kept separate from the screen so the exact same
/// pixels shown on screen are what gets rendered into the shared image.
private struct WinterWrappedCard: View {
    let cityName: String?
    let avoidedBansCount: Int
    let estimatedSavingsCAD: Int
    let firstUseDate: Date
    let language: AppLanguage
    let palette: ThemePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                AppLogoImage(size: 28)
                Text(language.appName)
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                    .tracking(0.6)
                Spacer()
            }
            .foregroundStyle(palette.onAccent)

            Text(Strings.text(for: .wrappedHeadline, language: language).replacingOccurrences(of: "%CITY%", with: cityName ?? ""))
                .font(.title2.weight(.bold))
                .foregroundStyle(palette.onAccent)
                .fixedSize(horizontal: false, vertical: true)

            statRow(
                icon: "bell.badge.fill",
                value: "\(avoidedBansCount)",
                label: Strings.text(for: .wrappedAvoidedBans, language: language)
            )
            statRow(
                icon: "dollarsign.circle.fill",
                value: "~\(estimatedSavingsCAD) $",
                label: Strings.text(for: .wrappedSavings, language: language)
            )
            statRow(
                icon: "calendar",
                value: memberSinceText,
                label: Strings.text(for: .wrappedMemberSince, language: language)
            )

            Text(Strings.text(for: .wrappedFooterNote, language: language))
                .font(.caption2)
                .foregroundStyle(palette.onAccent.opacity(0.7))
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [palette.accent, palette.primary.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: palette.primary.opacity(0.4), radius: 20, y: 10)
    }

    private func statRow(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(palette.onAccent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.title3.weight(.bold).monospacedDigit())
                Text(label)
                    .font(.caption)
                    .opacity(0.85)
            }
            .foregroundStyle(palette.onAccent)
            Spacer(minLength: 0)
        }
    }

    private var memberSinceText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.rawValue)
        formatter.setLocalizedDateFormatFromTemplate("MMMyyyy")
        return formatter.string(from: firstUseDate).capitalized
    }
}

struct WinterWrappedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WinterWrappedView(cityName: "Montréal")
        }
        .environmentObject(Localizer())
        .environmentObject(ThemeManager())
    }
}
