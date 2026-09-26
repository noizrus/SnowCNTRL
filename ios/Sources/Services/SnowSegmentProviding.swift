import Foundation
import MapKit

extension ParkingBanState {
    /// Mapping from the city-wide ban state to the Info-Neige legend, used
    /// while no city feed gives a status per street side.
    var asSnowClearingStatus: SnowClearingStatus {
        switch self {
        case .activeBanNow: return .noParkingActive
        case .noActiveBan: return .cleared
        case .unknownNoData: return .noOperation
        }
    }
}

@MainActor
final class SnowSegmentService {
    static let shared = SnowSegmentService()

    /// Both curbs of every real street block in `region`. Each side takes
    /// `overallStatus` for now: a per-side feed (Montréal's Planif-Neige,
    /// keyed by street side) would replace it here once wired in. Shown at
    /// every zoom level — no substitute indicator when zoomed out, just the
    /// same colored lines, however many of them fit in view.
    func segments(for city: City, in region: MKCoordinateRegion, overallStatus: SnowClearingStatus) async -> [StreetSegment] {
        guard city.tier != .notApplicable else { return [] }
        let blocks = await OSMStreetGeometryService.shared.blocks(in: region)
        return blocks.flatMap { $0.sides(status: overallStatus) }
    }
}
