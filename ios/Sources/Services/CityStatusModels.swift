import Foundation

enum ParkingBanState: Equatable {
    case activeBanNow
    case noActiveBan
    case unknownNoData
}

struct CityStatusResult {
    let state: ParkingBanState
    let asOf: Date?
    let detail: String?
    /// Outside snow season no city runs clearing operations, so there is
    /// no ban to report regardless of data availability.
    var isOffSeason = false
}

enum CityStatusError: Error {
    case notConfigured
    case network(Error)
    case badResponse
}

protocol CityStatusProviding {
    func fetchStatus(for city: City) async throws -> CityStatusResult
}
