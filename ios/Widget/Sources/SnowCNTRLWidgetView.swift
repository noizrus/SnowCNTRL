import SwiftUI
import WidgetKit

/// Self-contained FR/EN/ES text for the widget — deliberately not sharing
/// `Strings.swift`/`LocKey` from the main app target, since that file lives
/// outside `Sources/Shared` and pulling it in would drag the rest of the
/// app's localization surface into the extension for three short strings.
enum WidgetText {
    static func status(stateRawValue: String?, language: String) -> String {
        switch (stateRawValue, language) {
        case ("activeBanNow", "fr"): return "Interdiction active"
        case ("activeBanNow", "es"): return "Prohibición activa"
        case ("activeBanNow", _): return "Ban active now"
        case ("noActiveBan", "fr"): return "Aucune interdiction"
        case ("noActiveBan", "es"): return "Sin prohibición"
        case ("noActiveBan", _): return "No ban right now"
        case ("unknownNoData", "fr"): return "Statut inconnu"
        case ("unknownNoData", "es"): return "Estado desconocido"
        case ("unknownNoData", _): return "Status unknown"
        default:
            switch language {
            case "fr": return "Ouvre l'app pour configurer"
            case "es": return "Abre la app para configurar"
            default: return "Open the app to set up"
            }
        }
    }

    static func color(for stateRawValue: String?) -> Color {
        switch stateRawValue {
        case "activeBanNow": return .red
        case "noActiveBan": return .green
        default: return .gray
        }
    }
}

struct SnowCNTRLWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: SnowCNTRLWidgetProvider.Entry

    private var statusColor: Color { WidgetText.color(for: entry.stateRawValue) }
    private var statusText: String { WidgetText.status(stateRawValue: entry.stateRawValue, language: entry.languageRawValue) }
    private var cityText: String { entry.cityName ?? "SnowCNTRL" }

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                circularView
            case .accessoryRectangular:
                rectangularView
            case .accessoryInline:
                Text("\(cityText) — \(statusText)")
            default:
                homeScreenView
            }
        }
        .widgetBackground(family: family)
    }

    private var circularView: some View {
        ZStack {
            Circle().strokeBorder(statusColor, lineWidth: 3)
            Image(systemName: "snowflake")
                .font(.title3)
        }
        .widgetAccentable()
    }

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(cityText).font(.headline).lineLimit(1)
            Text(statusText).font(.caption).lineLimit(2)
        }
    }

    private var homeScreenView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SNOW CNTRL")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            HStack(spacing: 6) {
                Circle().fill(statusColor).frame(width: 10, height: 10)
                Text(cityText).font(.headline).lineLimit(1)
            }
            Text(statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
    }
}

private extension View {
    /// iOS 17 requires an explicit `containerBackground` or the widget logs
    /// a runtime warning; on iOS 16 (our deployment target) no equivalent
    /// call exists or is needed, so this is a no-op there.
    @ViewBuilder
    func widgetBackground(family: WidgetFamily) -> some View {
        if #available(iOS 17.0, *) {
            switch family {
            case .accessoryCircular, .accessoryRectangular, .accessoryInline:
                containerBackground(.clear, for: .widget)
            default:
                containerBackground(for: .widget) { Color(.systemBackground) }
            }
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
        .configurationDisplayName("SnowCNTRL")
        .description("Statut de stationnement pour ton adresse enregistrée.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
