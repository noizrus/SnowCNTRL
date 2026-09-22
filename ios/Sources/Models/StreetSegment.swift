import Foundation
import MapKit

/// One side of one block of street, ready to draw — coordinates already
/// offset a few meters from the true centerline so both sides of the
/// street render as two distinct glowing lines instead of one line down
/// the middle.
struct StreetSegment: Identifiable {
    let id: String
    let coordinates: [CLLocationCoordinate2D]
    let status: SnowClearingStatus

    var polyline: MKPolyline {
        var coords = coordinates
        return MKPolyline(coordinates: &coords, count: coords.count)
    }

    var midpoint: CLLocationCoordinate2D {
        coordinates[coordinates.count / 2]
    }

    /// Shortest distance (meters) from `coordinate` to this segment's line
    /// — used to let a tap near a street side "snap" to that whole side,
    /// matching how Info-Neige lets you pick a side of the street rather
    /// than an arbitrary point.
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        guard coordinates.count >= 2 else {
            guard let first = coordinates.first else { return .greatestFiniteMagnitude }
            return CLLocation(latitude: first.latitude, longitude: first.longitude)
                .distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        let tapPoint = MKMapPoint(coordinate)
        var minDistance = Double.greatestFiniteMagnitude
        for i in 0..<(coordinates.count - 1) {
            let a = MKMapPoint(coordinates[i])
            let b = MKMapPoint(coordinates[i + 1])
            minDistance = min(minDistance, tapPoint.distanceToSegment(from: a, to: b))
        }
        return minDistance
    }
}

private extension MKMapPoint {
    func distanceToSegment(from a: MKMapPoint, to b: MKMapPoint) -> Double {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let lengthSquared = dx * dx + dy * dy
        guard lengthSquared > 0 else {
            return self.distance(to: a)
        }
        var t = ((x - a.x) * dx + (y - a.y) * dy) / lengthSquared
        t = max(0, min(1, t))
        let projected = MKMapPoint(x: a.x + t * dx, y: a.y + t * dy)
        return self.distance(to: projected)
    }
}

enum StreetSegmentBuilder {
    /// Splits a street centerline into two parallel segments (one per side),
    /// offset by `offsetMeters` in opposite perpendicular directions.
    /// This is a flat-Euclidean approximation using MapKit's projected
    /// map points — accurate enough at street scale, not meant for long
    /// or sharply curved centerlines.
    static func bothSides(
        centerline: [CLLocationCoordinate2D],
        idPrefix: String,
        leftStatus: SnowClearingStatus,
        rightStatus: SnowClearingStatus,
        offsetMeters: Double = 4
    ) -> [StreetSegment] {
        guard centerline.count >= 2 else { return [] }

        let points = centerline.map { MKMapPoint($0) }
        var leftPoints: [MKMapPoint] = []
        var rightPoints: [MKMapPoint] = []

        for i in points.indices {
            let prev = points[max(0, i - 1)]
            let next = points[min(points.count - 1, i + 1)]
            let dx = next.x - prev.x
            let dy = next.y - prev.y
            let length = (dx * dx + dy * dy).squareRoot()
            guard length > 0 else {
                leftPoints.append(points[i])
                rightPoints.append(points[i])
                continue
            }
            let metersPerMapPoint = MKMetersPerMapPointAtLatitude(centerline[i].latitude)
            let offsetInMapPoints = offsetMeters / metersPerMapPoint
            let normalX = -dy / length * offsetInMapPoints
            let normalY = dx / length * offsetInMapPoints

            leftPoints.append(MKMapPoint(x: points[i].x + normalX, y: points[i].y + normalY))
            rightPoints.append(MKMapPoint(x: points[i].x - normalX, y: points[i].y - normalY))
        }

        let leftSegment = StreetSegment(
            id: "\(idPrefix)-left",
            coordinates: leftPoints.map { $0.coordinate },
            status: leftStatus
        )
        let rightSegment = StreetSegment(
            id: "\(idPrefix)-right",
            coordinates: rightPoints.map { $0.coordinate },
            status: rightStatus
        )
        return [leftSegment, rightSegment]
    }
}
