import WidgetKit

struct SnowStatusEntry: TimelineEntry {
    let date: Date
    let cityName: String?
    let stateRawValue: String?
    let languageRawValue: String
    let updatedAt: Date?
}

/// Reads whatever the main app last wrote to the shared App Group container
/// — the widget process itself never calls a network provider, since it has
/// no UI to show a loading/error state and no guarantee it runs often enough
/// to be worth it. Freshness comes from the main app refreshing on launch,
/// on foreground, and via its existing `BGAppRefreshTask`.
struct SnowCNTRLWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SnowStatusEntry {
        SnowStatusEntry(date: Date(), cityName: "Montreal", stateRawValue: "noActiveBan", languageRawValue: "en", updatedAt: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SnowStatusEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SnowStatusEntry>) -> Void) {
        let entry = currentEntry()
        let nextUpdate = Date().addingTimeInterval(30 * 60)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func currentEntry() -> SnowStatusEntry {
        guard let shared = WidgetSharedStatus.load() else {
            return SnowStatusEntry(date: Date(), cityName: nil, stateRawValue: nil, languageRawValue: "en", updatedAt: nil)
        }
        return SnowStatusEntry(
            date: Date(),
            cityName: shared.cityName,
            stateRawValue: shared.stateRawValue,
            languageRawValue: shared.languageRawValue,
            updatedAt: shared.updatedAt
        )
    }
}
