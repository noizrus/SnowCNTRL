import Foundation
import MapKit

protocol SnowSegmentProviding {
    func fetchSegments(near region: MKCoordinateRegion) async -> [StreetSegment]
}

/// No live per-street geometry for any city yet — every city except
/// Montreal returns nothing, and the map simply shows no glow lines
/// rather than fabricating a status.
struct GenericSnowSegmentProvider: SnowSegmentProviding {
    func fetchSegments(near region: MKCoordinateRegion) async -> [StreetSegment] {
        []
    }
}

/// Real network plumbing is not wired yet — same blocker as
/// MontrealOpenDataProvider (donnees.montreal.ca unreachable while writing
/// this, resource id unconfirmed). Until then this returns illustrative
/// sample streets around the requested region so the neon rendering
/// pipeline is genuinely visible and testable end to end.
///
/// To go from demo to real: fetch the street-segment geometry + status
/// for `region` from Montreal's open data (the "Déneigement des rues en
/// arrondissements" resource), map its status field to `SnowClearingStatus`,
/// and replace the `demoSegments(near:)` call below with that real data.
struct MontrealSnowSegmentProvider: SnowSegmentProviding {
    func fetchSegments(near region: MKCoordinateRegion) async -> [StreetSegment] {
        demoSegments(near: region.center)
    }

    private func demoSegments(near center: CLLocationCoordinate2D) -> [StreetSegment] {
        let statuses = SnowClearingStatus.allCases
        var segments: [StreetSegment] = []

        // A small grid of illustrative streets around the center point —
        // NOT real Montreal geometry, just enough to demo the glow lines.
        for row in -2...2 {
            let latOffset = Double(row) * 0.0018
            let centerline = [
                CLLocationCoordinate2D(latitude: center.latitude + latOffset, longitude: center.longitude - 0.01),
                CLLocationCoordinate2D(latitude: center.latitude + latOffset, longitude: center.longitude + 0.01),
            ]
            let leftStatus = statuses[abs(row) % statuses.count]
            let rightStatus = statuses[(abs(row) + 2) % statuses.count]
            segments += StreetSegmentBuilder.bothSides(
                centerline: centerline,
                idPrefix: "demo-h-\(row)",
                leftStatus: leftStatus,
                rightStatus: rightStatus
            )
        }

        for col in -2...2 {
            let lonOffset = Double(col) * 0.0022
            let centerline = [
                CLLocationCoordinate2D(latitude: center.latitude - 0.006, longitude: center.longitude + lonOffset),
                CLLocationCoordinate2D(latitude: center.latitude + 0.006, longitude: center.longitude + lonOffset),
            ]
            let leftStatus = statuses[(abs(col) + 1) % statuses.count]
            let rightStatus = statuses[(abs(col) + 4) % statuses.count]
            segments += StreetSegmentBuilder.bothSides(
                centerline: centerline,
                idPrefix: "demo-v-\(col)",
                leftStatus: leftStatus,
                rightStatus: rightStatus
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

    func fetchSegments(for city: City, near region: MKCoordinateRegion) async -> [StreetSegment] {
        guard let id = city.liveProviderID, let provider = providers[id] else {
            return await generic.fetchSegments(near: region)
        }
        return await provider.fetchSegments(near: region)
    }
}
