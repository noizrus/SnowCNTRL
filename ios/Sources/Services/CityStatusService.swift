import Foundation

/// Picks the right provider per city and degrades gracefully: any provider
/// failure (missing config, network error, bad payload) falls back to the
/// generic tier-based placeholder rather than surfacing a crash or a
/// confusing error state to the user.
final class CityStatusService {
    static let shared = CityStatusService()

    private let generic = GenericTierProvider()
    private let providers: [String: CityStatusProviding]

    init(providers: [String: CityStatusProviding] = ["montreal": MontrealOpenDataProvider()]) {
        self.providers = providers
    }

    /// Debug-only switch (Settings, Xcode builds) that makes every city report
    /// an active ban, to test the red streets and the alert end to end.
    static let simulateBanKey = "snowcntrl.debug.simulateBan"

    func fetchStatus(for city: City, now: Date = Date()) async -> CityStatusResult {
        #if DEBUG
        if city.tier != .notApplicable, UserDefaults.standard.bool(forKey: Self.simulateBanKey) {
            return CityStatusResult(state: .activeBanNow, asOf: now, detail: nil)
        }
        #endif
        if city.tier != .notApplicable, Self.isOffSeason(for: city.province, on: now) {
            return CityStatusResult(state: .noActiveBan, asOf: now, detail: nil, isOffSeason: true)
        }
        if let id = city.liveProviderID, let provider = providers[id] {
            if let result = try? await provider.fetchStatus(for: city) {
                return result
            }
        }
        return (try? await generic.fetchStatus(for: city))
            ?? CityStatusResult(state: .unknownNoData, asOf: nil, detail: nil)
    }

    /// Conservative snow-free window: May–September in the provinces,
    /// June–August in the territories, where snow can come earlier and
    /// stay later.
    static func isOffSeason(for province: ProvinceCode, on date: Date) -> Bool {
        let month = Calendar.current.component(.month, from: date)
        switch province {
        case .yt, .nt, .nu:
            return (6...8).contains(month)
        default:
            return (5...9).contains(month)
        }
    }
}
