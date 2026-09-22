import Foundation
import MapKit

extension ParkingBanState {
    /// Mapping from the city-wide ban state to the Info-Neige legend, used
    /// while no city feed gives a status per street side.
    var asSnowClearingStatus: SnowClearingStatus {
        switch self {
        case .activeBanNow: return .noParkingActive
        case .noActiveBan: return .cleared
        case .unknownNoData: return .awaitingInfo
        }
    }
}

enum StreetSegmentsResult {
    case zoomedOutTooFar
    case segments([StreetSegment])
}

@MainActor
final class SnowSegmentService {
    static let shared = SnowSegmentService()

    /// Both curbs of every real street block in `region`. Each side takes
    /// `overallStatus` for now: a per-side feed (Montréal's Planif-Neige,
    /// keyed by street side) would replace it here once wired in.
    func segments(for city: City, in region: MKCoordinateRegion, overallStatus: SnowClearingStatus) async -> StreetSegmentsResult {
        guard city.tier != .notApplicable else { return .segments([]) }
        guard let blocks = await OSMStreetGeometryService.shared.blocks(in: region) else {
            return .zoomedOutTooFar
        }
        return .segments(blocks.flatMap { $0.sides(status: overallStatus) })
    }
}
