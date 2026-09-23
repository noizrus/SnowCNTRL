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

    private var statusColor: Color { WidgetText.color(for: entry.stateRawValue) }
    private var statusText: String {
        WidgetText.status(stateRawValue: entry.stateRawValue, language: entry.languageRawValue, isOffSeason: entry.isOffSeason)
    }
    /// The alert's street when there is one, the city otherwise.
    private var placeText: String? { entry.alertLabel ?? entry.cityName }

    var body: some View {
        switch family {
        case .accessoryRectangular:
            rectangularView.widgetBackground(.clear)
        case .accessoryInline:
            Label(statusText, systemImage: "snowflake").widgetBackground(.clear)
        default:
            circularView.widgetBackground(.clear)
        }
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

private extension View {
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
        .description("Statut du déneigement de ta rue, en un coup d'œil sur l'écran verrouillé.")
        // Lock screen only — no .systemSmall/.systemMedium, so it can't be
        // added to the Home Screen.
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
