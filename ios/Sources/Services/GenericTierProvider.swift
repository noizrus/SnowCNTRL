import Foundation

/// Used for every city that has no live data integration yet (the vast
/// majority — see the tier map). It never claims a ban state it can't back
/// up: the UI is expected to lean on the tier disclaimer, not on `detail`.
struct GenericTierProvider: CityStatusProviding {
    func fetchStatus(for city: City) async throws -> CityStatusResult {
        CityStatusResult(state: .unknownNoData, asOf: nil, detail: nil)
    }
}
