import Foundation
import MapKit

/// One block of one real street (between two intersections), as a
/// centerline. Both curbs are derived from it at draw time, so the glow
/// lines hug each side of the road the map actually draws at every zoom.
struct StreetBlock: Identifiable {
    let id: String
    let wayID: Int
    let centerline: [CLLocationCoordinate2D]
    let mapPoints: [MKMapPoint]
    let streetName: String?
    /// Approximate distance from the centerline to the curb (parked cars).
    let curbOffsetMeters: Double
    let bounds: MKMapRect

    init(id: String, wayID: Int, centerline: [CLLocationCoordinate2D], streetName: String?, curbOffsetMeters: Double) {
        self.id = id
        self.wayID = wayID
        self.centerline = centerline
        self.streetName = streetName
        self.curbOffsetMeters = curbOffsetMeters
        let points = centerline.map { MKMapPoint($0) }
        mapPoints = points
        let xs = points.map(\.x)
        let ys = points.map(\.y)
        let minX = xs.min() ?? 0
        let minY = ys.min() ?? 0
        bounds = MKMapRect(x: minX, y: minY, width: (xs.max() ?? 0) - minX, height: (ys.max() ?? 0) - minY)
    }

    func sides(status: SnowClearingStatus) -> [StreetSegment] {
        [
            StreetSegment(block: self, sideSign: 1, status: status),
            StreetSegment(block: self, sideSign: -1, status: status),
        ]
    }

    struct Projection {
        let point: MKMapPoint
        let distanceMeters: Double
        /// > 0 when the projected point lies on the left of the drawing
        /// direction (same convention as `StreetSegment.sideSign`).
        let cross: Double
        let leftNormal: (x: Double, y: Double)
    }

    func projection(of point: MKMapPoint) -> Projection? {
        var best: Projection?
        for i in 0..<(mapPoints.count - 1) {
            let a = mapPoints[i]
            let b = mapPoints[i + 1]
            let dx = b.x - a.x
            let dy = b.y - a.y
            let lengthSquared = dx * dx + dy * dy
            guard lengthSquared > 0 else { continue }
            let t = max(0, min(1, ((point.x - a.x) * dx + (point.y - a.y) * dy) / lengthSquared))
            let projected = MKMapPoint(x: a.x + t * dx, y: a.y + t * dy)
            let distance = point.distance(to: projected)
            if best == nil || distance < best!.distanceMeters {
                let length = lengthSquared.squareRoot()
                best = Projection(
                    point: projected,
                    distanceMeters: distance,
                    cross: dx * (point.y - a.y) - dy * (point.x - a.x),
                    leftNormal: (-dy / length, dx / length)
                )
            }
        }
        return best
    }
}

enum StreetCompassSide {
    case north, south, east, west

    func label(language: AppLanguage) -> String {
        switch (self, language) {
        case (.north, .french): return "côté nord"
        case (.south, .french): return "côté sud"
        case (.east, .french): return "côté est"
        case (.west, .french): return "côté ouest"
        case (.north, .english): return "north side"
        case (.south, .english): return "south side"
        case (.east, .english): return "east side"
        case (.west, .english): return "west side"
        case (.north, .spanish): return "lado norte"
        case (.south, .spanish): return "lado sur"
        case (.east, .spanish): return "lado este"
        case (.west, .spanish): return "lado oeste"
        }
    }
}

/// One side (one curb) of one street block — what Info-Neige lets you pick.
struct StreetSegment: Identifiable {
    let block: StreetBlock
    /// +1 = left of the block's drawing direction, -1 = right.
    let sideSign: Double
    var status: SnowClearingStatus

    var id: String { "\(block.id)-\(sideSign > 0 ? "L" : "R")" }

    var compassSide: StreetCompassSide {
        guard let first = block.mapPoints.first, let last = block.mapPoints.last else { return .north }
        // Left normal of the overall direction, flipped for the right side.
        // Map points grow eastward (x) and southward (y).
        let nx = -(last.y - first.y) * sideSign
        let ny = (last.x - first.x) * sideSign
        if abs(nx) > abs(ny) {
            return nx > 0 ? .east : .west
        }
        return ny > 0 ? .south : .north
    }

    /// Where a car parked on this side sits, next to `projection` on the
    /// centerline.
    func curbPoint(from projection: StreetBlock.Projection) -> CLLocationCoordinate2D {
        let metersPerMapPoint = MKMetersPerMapPointAtLatitude(projection.point.coordinate.latitude)
        let offset = block.curbOffsetMeters / metersPerMapPoint * sideSign
        return MKMapPoint(
            x: projection.point.x + projection.leftNormal.x * offset,
            y: projection.point.y + projection.leftNormal.y * offset
        ).coordinate
    }
}

struct StreetSideMatch {
    let segment: StreetSegment
    let distanceMeters: Double
    let curbPoint: CLLocationCoordinate2D
}

extension Array where Element == StreetSegment {
    /// The street side closest to `coordinate` — nearest block centerline,
    /// then whichever curb of that block the coordinate falls on.
    func nearestSide(to coordinate: CLLocationCoordinate2D, within maxMeters: Double) -> StreetSideMatch? {
        let point = MKMapPoint(coordinate)
        let margin = maxMeters / MKMetersPerMapPointAtLatitude(coordinate.latitude)
        var best: StreetSideMatch?
        for segment in self {
            guard segment.block.bounds.insetBy(dx: -margin, dy: -margin).contains(point),
                  let projection = segment.block.projection(of: point),
                  projection.distanceMeters <= maxMeters,
                  (projection.cross >= 0 ? 1.0 : -1.0) == segment.sideSign
            else { continue }
            if best == nil || projection.distanceMeters < best!.distanceMeters {
                best = StreetSideMatch(
                    segment: segment,
                    distanceMeters: projection.distanceMeters,
                    curbPoint: segment.curbPoint(from: projection)
                )
            }
        }
        return best
    }
}
