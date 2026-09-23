import SwiftUI
import WidgetKit

/// Self-contained FR/EN/ES text and colors for the widget — the app's
/// `Strings.swift` and `SnowClearingStatus` live in the main target only.
/// Colors mirror `SnowClearingStatus.neonColor` so widget and map agree.
enum WidgetText {
    static func status(stateRawValue: String?, language: String, isOffSeason: Bool = false) -> String {
        switch (stateRawValue, language) {
        case ("activeBanNow", "fr"): return "Stationnement interdit"
        case ("activeBanNow", "es"): return "Prohibido estacionar"
        case ("activeBanNow", _): return "No parking"
        case ("noActiveBan", "fr") where isOffSeason: return "Hors saison"
        case ("noActiveBan", "es") where isOffSeason: return "Fuera de temporada"
        case ("noActiveBan", _) where isOffSeason: return "Off season"
        case ("noActiveBan", "fr"): return "Aucune interdiction"
        case ("noActiveBan", "es"): return "Sin prohibición"
        case ("noActiveBan", _): return "No ban right now"
        case ("unknownNoData", "fr"): return "Statut inconnu"
        case ("unknownNoData", "es"): return "Estado desconocido"
        case ("unknownNoData", _): return "Status unknown"
        default: return openAppHint(language: language)
        }
    }

    static func openAppHint(language: String) -> String {
        switch language {
        case "fr": return "Ouvre l'app et touche ta rue"
        case "es": return "Abre la app y toca tu calle"
        default: return "Open the app and tap your street"
        }
    }

    static func updated(language: String) -> String {
        switch language {
        case "fr": return "Mis à jour"
        case "es": return "Actualizado"
        default: return "Updated"
        }
    }

    static func color(for stateRawValue: String?) -> Color {
        switch stateRawValue {
        case "activeBanNow": return Color(red: 1.00, green: 0.16, blue: 0.24)
        case "noActiveBan": return Color(red: 0.10, green: 0.95, blue: 0.35)
        default: return Color(red: 0.62, green: 0.65, blue: 0.70)
        }
    }

    /// Mirrors `AppLanguage.appName` in the main app target.
    static func appName(language: String) -> String {
        language == "fr" ? "NEIGE CNTRL" : "SNOW CNTRL"
    }
}

struct SnowCNTRLWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: SnowCNTRLWidgetProvider.Entry

    private var hasData: Bool { entry.stateRawValue != nil }
    private var statusColor: Color { WidgetText.color(for: entry.stateRawValue) }
    private var statusText: String {
        WidgetText.status(stateRawValue: entry.stateRawValue, language: entry.languageRawValue, isOffSeason: entry.isOffSeason)
    }
    /// The alert's street when there is one, the city otherwise.
    private var placeText: String? { entry.alertLabel ?? entry.cityName }
    private var accent: Color {
        guard let rgb = entry.accentRGB, rgb.count == 3 else { return Color(red: 0.984, green: 0.400, blue: 0.0) }
        return Color(red: rgb[0], green: rgb[1], blue: rgb[2])
    }

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView.widgetBackground(.clear)
        case .accessoryRectangular:
            rectangularView.widgetBackground(.clear)
        case .accessoryInline:
            Label(statusText, systemImage: "snowflake").widgetBackground(.clear)
        case .systemMedium:
            mediumView.homeScreenStyle(accent: accent, glow: statusColor)
        default:
            smallView.homeScreenStyle(accent: accent, glow: statusColor)
        }
    }

    // MARK: Home screen

    private var brandRow: some View {
        HStack(spacing: 6) {
            WidgetLogo(size: 22)
            Text(WidgetText.appName(language: entry.languageRawValue))
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.5)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var statusRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 9, height: 9)
                .shadow(color: statusColor, radius: 4)
            Text(statusText)
                .font(.system(size: hasData ? 15 : 13, weight: .bold, design: .rounded))
                .foregroundStyle(hasData ? statusColor : .white)
                .shadow(color: hasData ? statusColor.opacity(0.6) : .clear, radius: 4)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            brandRow
            Spacer(minLength: 0)
            statusRow
            if let placeText {
                Text(placeText)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var mediumView: some View {
        HStack(spacing: 14) {
            WidgetLogo(size: 64)
            VStack(alignment: .leading, spacing: 6) {
                Text(WidgetText.appName(language: entry.languageRawValue))
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .tracking(0.6)
                    .foregroundStyle(.white)
                statusRow
                if let placeText {
                    Text(placeText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(2)
                }
                if let updatedAt = entry.updatedAt {
                    (Text(WidgetText.updated(language: entry.languageRawValue) + " ") + Text(updatedAt, style: .time))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: Lock screen

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            Circle().strokeBorder(statusColor, lineWidth: 3)
            Image(systemName: "snowflake")
                .font(.title3.weight(.semibold))
        }
        .widgetAccentable()
    }

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 1) {
            Label(WidgetText.appName(language: entry.languageRawValue), systemImage: "snowflake")
                .font(.caption2.weight(.heavy))
                .widgetAccentable()
            Text(statusText)
                .font(.headline)
                .lineLimit(1)
            if let placeText {
                Text(placeText)
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The app logo, kept in full color even in iOS 18's tinted home screen.
private struct WidgetLogo: View {
    let size: CGFloat

    var body: some View {
        logoImage
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }

    @ViewBuilder
    private var logoImage: some View {
        if #available(iOS 18.0, *) {
            Image("AppLogo")
                .resizable()
                .widgetAccentedRenderingMode(.fullColor)
                .scaledToFit()
        } else {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
        }
    }
}

private extension View {
    /// Home screen look: always dark, a glow of the theme color and of the
    /// status color in the corners, white text.
    @ViewBuilder
    func homeScreenStyle(accent: Color, glow: Color) -> some View {
        let background = ZStack {
            Color(red: 0.05, green: 0.06, blue: 0.09)
            RadialGradient(colors: [accent.opacity(0.45), .clear], center: .topTrailing, startRadius: 0, endRadius: 170)
            RadialGradient(colors: [glow.opacity(0.28), .clear], center: .bottomLeading, startRadius: 0, endRadius: 150)
        }
        if #available(iOS 17.0, *) {
            // iOS 17+ adds the standard content margins itself.
            self
                .environment(\.colorScheme, .dark)
                .containerBackground(for: .widget) { background }
        } else {
            self
                .environment(\.colorScheme, .dark)
                .padding()
                .background(background)
        }
    }

    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(color, for: .widget)
        } else {
            self
        }
    }
}

struct SnowCNTRLWidget: Widget {
    let kind = "SnowCNTRLWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SnowCNTRLWidgetProvider()) { entry in
            SnowCNTRLWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NEIGE CNTRL")
        .description("Statut du déneigement de ta rue, en un coup d'œil.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
