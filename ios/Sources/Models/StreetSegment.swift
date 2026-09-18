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
