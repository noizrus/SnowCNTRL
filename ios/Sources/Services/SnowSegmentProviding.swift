import Foundation
import MapKit

protocol SnowSegmentProviding {
    /// `overallStatus` is what the dashboard already knows about the city
    /// (from `CityStatusService`) — providers without real per-street
    /// geometry use it so every segment they draw agrees with the status
    /// pill instead of showing an arbitrary, meaningless color per street.
    func fetchSegments(near region: MKCoordinateRegion, overallStatus: SnowClearingStatus) async -> [StreetSegment]
}

extension ParkingBanState {
    /// Best-effort mapping from the coarse city-wide ban state to the
    /// Info-Neige-style per-street legend, used wherever we only know the
    /// overall status and not real per-street data.
    var asSnowClearingStatus: SnowClearingStatus {
        switch self {
        case .activeBanNow: return .noParkingActive
        case .noActiveBan: return .cleared
        case .unknownNoData: return .awaitingInfo
        }
    }
}

/// No live per-street geometry for any city yet — every city except
/// Montreal returns nothing, and the map simply shows no glow lines
/// rather than fabricating a status.
struct GenericSnowSegmentProvider: SnowSegmentProviding {
    func fetchSegments(near region: MKCoordinateRegion, overallStatus: SnowClearingStatus) async -> [StreetSegment] {
        []
    }
}

/// Real network plumbing is not wired yet — same blocker as
/// MontrealOpenDataProvider (donnees.montreal.ca unreachable while writing
/// this, resource id unconfirmed). This used to draw a fabricated grid of
/// streets to demo the glow rendering, but that grid has no relationship
/// to Montreal's real street layout — it visibly doesn't line up with the
/// base map's actual roads, which is actively misleading rather than
/// illustrative. Returns nothing until real geometry is wired in, same as
/// every other city.
///
/// To go from empty to real: fetch the street-segment geometry + status
/// for `region` from Montreal's open data (the "Déneigement des rues en
/// arrondissements" resource), map its status field to `SnowClearingStatus`,
/// and build segments with `StreetSegmentBuilder.bothSides(centerline:...)`
/// from that real per-segment data.
struct MontrealSnowSegmentProvider: SnowSegmentProviding {
    func fetchSegments(near region: MKCoordinateRegion, overallStatus: SnowClearingStatus) async -> [StreetSegment] {
        []
    }
}

final class SnowSegmentService {
    static let shared = SnowSegmentService()

    private let generic = GenericSnowSegmentProvider()
    private let providers: [String: SnowSegmentProviding]

    init(providers: [String: SnowSegmentProviding] = ["montreal": MontrealSnowSegmentProvider()]) {
        self.providers = providers
    }

    func fetchSegments(for city: City, near region: MKCoordinateRegion, overallStatus: SnowClearingStatus) async -> [StreetSegment] {
        guard let id = city.liveProviderID, let provider = providers[id] else {
            return await generic.fetchSegments(near: region, overallStatus: overallStatus)
        }
        return await provider.fetchSegments(near: region, overallStatus: overallStatus)
    }
}
