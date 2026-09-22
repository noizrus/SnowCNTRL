import MapKit
import UIKit

/// A block centerline plus which curb to draw. The renderer shifts it
/// sideways at draw time, so it lands on the edge of the road as MapKit
/// draws it at the current zoom.
final class SideLine: MKPolyline {
    var sideSign: Double = 1
    var curbOffsetMeters: Double = 4.5
}

/// All side lines sharing one status (and selection state) — one overlay
/// per group instead of thousands keeps panning smooth.
final class GlowMultiPolyline: MKMultiPolyline {
    var status: SnowClearingStatus = .noOperation
    var isSelected = false
}

/// Neon look: soft translucent halo + bright thin core, plus a white
/// outline for selected sides.
final class GlowPolylineRenderer: MKOverlayRenderer {
    /// Screen-point bounds for the curb offset: never so close that both
    /// sides merge, never so far that they leave the drawn road.
    private static let minOffsetPoints = 2.5
    private static let maxOffsetPoints = 16.0

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let group = overlay as? GlowMultiPolyline else { return }

        let scale = Double(zoomScale)
        let coreWidth = (group.isSelected ? 4.5 : 2.6) / scale
        let margin = (Self.maxOffsetPoints + 12) / scale
        let visible = mapRect.insetBy(dx: -margin, dy: -margin)

        let path = CGMutablePath()
        for case let line as SideLine in group.polylines {
            guard line.pointCount > 1, line.boundingMapRect.intersects(visible) else { continue }
            let metersPerMapPoint = MKMetersPerMapPointAtLatitude(line.coordinate.latitude)
            let offset = min(
                max(line.curbOffsetMeters / metersPerMapPoint, Self.minOffsetPoints / scale),
                Self.maxOffsetPoints / scale
            ) * line.sideSign
            appendOffsetPath(of: line, offset: offset, to: path)
        }
        guard !path.isEmpty else { return }

        let color = UIColor(group.status.neonColor)
        // Shadow blur is in device pixels regardless of the context's
        // transform, hence contentScaleFactor rather than zoomScale.
        let blur = (group.isSelected ? 9 : 6) * contentScaleFactor

        context.saveGState()
        context.setLineJoin(.round)
        context.setLineCap(.round)

        context.addPath(path)
        context.setStrokeColor(color.withAlphaComponent(group.isSelected ? 0.5 : 0.3).cgColor)
        context.setLineWidth(coreWidth * 2.8)
        context.setShadow(offset: .zero, blur: blur, color: color.withAlphaComponent(0.9).cgColor)
        context.strokePath()
        context.setShadow(offset: .zero, blur: 0, color: nil)

        if group.isSelected {
            context.addPath(path)
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(coreWidth * 1.8)
            context.strokePath()
        }

        context.addPath(path)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(coreWidth)
        context.strokePath()

        context.restoreGState()
    }

    private func appendOffsetPath(of line: SideLine, offset: Double, to path: CGMutablePath) {
        let points = line.points()
        let count = line.pointCount
        for i in 0..<count {
            let previous = points[max(0, i - 1)]
            let next = points[min(count - 1, i + 1)]
            let dx = next.x - previous.x
            let dy = next.y - previous.y
            let length = (dx * dx + dy * dy).squareRoot()
            let normalX = length > 0 ? -dy / length : 0
            let normalY = length > 0 ? dx / length : 0
            let shifted = point(for: MKMapPoint(x: points[i].x + normalX * offset, y: points[i].y + normalY * offset))
            if i == 0 {
                path.move(to: shifted)
            } else {
                path.addLine(to: shifted)
            }
        }
    }
}
