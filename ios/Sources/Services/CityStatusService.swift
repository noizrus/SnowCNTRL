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

    func fetchStatus(for city: City) async -> CityStatusResult {
        if let id = city.liveProviderID, let provider = providers[id] {
            if let result = try? await provider.fetchStatus(for: city) {
                return result
            }
        }
        return (try? await generic.fetchStatus(for: city))
            ?? CityStatusResult(state: .unknownNoData, asOf: nil, detail: nil)
    }
}
