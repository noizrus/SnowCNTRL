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
}

enum CityStatusError: Error {
    case notConfigured
    case network(Error)
    case badResponse
}

protocol CityStatusProviding {
    func fetchStatus(for city: City) async throws -> CityStatusResult
}
