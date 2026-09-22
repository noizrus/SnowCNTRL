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
/// this, resource id unconfirmed). Until then this draws an illustrative
/// grid of streets around the requested region, both sides colored with
/// the SAME `overallStatus` the dashboard already shows — not a fabricated
/// per-street value, since we have no real per-street data to justify one.
///
/// To go from demo to real: fetch the street-segment geometry + status
/// for `region` from Montreal's open data (the "Déneigement des rues en
/// arrondissements" resource), map its status field to `SnowClearingStatus`,
/// and replace the `demoSegments(near:overallStatus:)` call below with that
/// real per-segment data.
struct MontrealSnowSegmentProvider: SnowSegmentProviding {
    func fetchSegments(near region: MKCoordinateRegion, overallStatus: SnowClearingStatus) async -> [StreetSegment] {
        demoSegments(near: region.center, status: overallStatus)
    }

    private func demoSegments(near center: CLLocationCoordinate2D, status: SnowClearingStatus) -> [StreetSegment] {
        var segments: [StreetSegment] = []

        // A small grid of illustrative streets around the center point —
        // NOT real Montreal geometry, just enough to demo the glow lines.
        for row in -2...2 {
            let latOffset = Double(row) * 0.0018
            let centerline = [
                CLLocationCoordinate2D(latitude: center.latitude + latOffset, longitude: center.longitude - 0.01),
                CLLocationCoordinate2D(latitude: center.latitude + latOffset, longitude: center.longitude + 0.01),
            ]
            segments += StreetSegmentBuilder.bothSides(
                centerline: centerline,
                idPrefix: "demo-h-\(row)",
                leftStatus: status,
                rightStatus: status
            )
        }

        for col in -2...2 {
            let lonOffset = Double(col) * 0.0022
            let centerline = [
                CLLocationCoordinate2D(latitude: center.latitude - 0.006, longitude: center.longitude + lonOffset),
                CLLocationCoordinate2D(latitude: center.latitude + 0.006, longitude: center.longitude + lonOffset),
            ]
            segments += StreetSegmentBuilder.bothSides(
                centerline: centerline,
                idPrefix: "demo-v-\(col)",
                leftStatus: status,
                rightStatus: status
            )
        }

        return segments
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
