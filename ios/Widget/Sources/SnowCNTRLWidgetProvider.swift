import WidgetKit

struct SnowStatusEntry: TimelineEntry {
    let date: Date
    let cityName: String?
    let stateRawValue: String?
    let languageRawValue: String
    let updatedAt: Date?
    let alertLabel: String?
    let isOffSeason: Bool
    let accentRGB: [Double]?

    static func placeholder(language: String = "fr") -> SnowStatusEntry {
        SnowStatusEntry(
            date: Date(),
            cityName: "Montréal",
            stateRawValue: "noActiveBan",
            languageRawValue: language,
            updatedAt: Date(),
            alertLabel: "Rue Saint-Denis — côté est",
            isOffSeason: true,
            accentRGB: nil
        )
    }
}

/// Reads whatever the main app last published to the shared App Group —
/// the widget never calls a network provider itself (no UI for loading or
/// errors, no guarantee it runs often). Freshness comes from the app
/// republishing on launch, on foreground and via its background refresh.
struct SnowCNTRLWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SnowStatusEntry {
        .placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (SnowStatusEntry) -> Void) {
        // The widget gallery shows the snapshot: use real data when there
        // is some, a representative sample otherwise.
        completion(currentEntry() ?? .placeholder())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SnowStatusEntry>) -> Void) {
        let entry = currentEntry() ?? SnowStatusEntry(
            date: Date(),
            cityName: nil,
            stateRawValue: nil,
            languageRawValue: Locale.preferredLanguages.first.map { String($0.prefix(2)) } ?? "en",
            updatedAt: nil,
            alertLabel: nil,
            isOffSeason: false,
            accentRGB: nil
        )
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(30 * 60))))
    }

    private func currentEntry() -> SnowStatusEntry? {
        guard let shared = WidgetSharedStatus.load() else { return nil }
        return SnowStatusEntry(
            date: Date(),
            cityName: shared.cityName,
            stateRawValue: shared.stateRawValue,
            languageRawValue: shared.languageRawValue,
            updatedAt: shared.updatedAt,
            alertLabel: shared.alertLabel,
            isOffSeason: shared.isOffSeason ?? false,
            accentRGB: shared.accentRGB
        )
    }
}
