import Foundation

/// Real network integration against Montreal's public CKAN open-data portal
/// (donnees.montreal.ca), using the standard CKAN `datastore_search` action —
/// no API key needed for public resources.
///
/// IMPORTANT: `resourceID` below is a placeholder. donnees.montreal.ca was not
/// reachable from the sandbox this was written in, so the exact resource id
/// for the live snow-removal-sector dataset (and the exact column names it
/// returns) could not be confirmed. To finish this integration:
///   1. Open https://donnees.montreal.ca/dataset/deneigement
///   2. Open the "Déneigement des rues en arrondissements" resource
///   3. Copy its resource id from the resource's own page (or the "API" tab)
///      and paste it below.
///   4. Inspect one real response and adjust `parseState(records:)` to match
///      the actual field names (this file currently only checks whether any
///      records come back, as a safe placeholder).
/// Until step 3 is done, this provider throws `.notConfigured` and
/// `CityStatusService` falls back to the generic tier-based placeholder, so
/// the app never crashes or shows garbage data.
struct MontrealOpenDataProvider: CityStatusProviding {
    private let resourceID = "REPLACE_WITH_REAL_RESOURCE_ID"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchStatus(for city: City) async throws -> CityStatusResult {
        guard resourceID != "REPLACE_WITH_REAL_RESOURCE_ID" else {
            throw CityStatusError.notConfigured
        }

        var components = URLComponents(string: "https://donnees.montreal.ca/api/3/action/datastore_search")!
        components.queryItems = [
            URLQueryItem(name: "resource_id", value: resourceID),
            URLQueryItem(name: "limit", value: "50"),
        ]
        guard let url = components.url else { throw CityStatusError.badResponse }

        let data: Data
        do {
            let (responseData, _) = try await session.data(from: url)
            data = responseData
        } catch {
            throw CityStatusError.network(error)
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            json["success"] as? Bool == true,
            let result = json["result"] as? [String: Any],
            let records = result["records"] as? [[String: Any]]
        else {
            throw CityStatusError.badResponse
        }

        return CityStatusResult(
            state: parseState(records: records),
            asOf: Date(),
            detail: nil
        )
    }

    /// Placeholder logic: treat any returned record as "a ban is active
    /// somewhere in the dataset right now". Replace with real field
    /// filtering (e.g. a status/date column) once the schema is confirmed.
    private func parseState(records: [[String: Any]]) -> ParkingBanState {
        records.isEmpty ? .noActiveBan : .activeBanNow
    }
}
