import MapKit
import UIKit

/// A polyline overlay carrying its own status/color, so the shared
/// renderer below can draw each segment in the right color without a
/// separate MKOverlayRenderer subclass per color.
final class GlowPolyline: MKPolyline {
    var status: SnowClearingStatus = .awaitingInfo
}

/// Draws a "neon" line: a wide, soft, low-alpha halo underneath a thin,
/// bright core stroke. Plain MKPolylineRenderer only draws one flat
/// stroke, so this subclasses MKOverlayRenderer directly and builds the
/// path by hand.
final class GlowPolylineRenderer: MKOverlayRenderer {
    private var glowPolyline: GlowPolyline? { overlay as? GlowPolyline }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let polyline = glowPolyline, polyline.pointCount > 1 else { return }

        let path = CGMutablePath()
        let points = polyline.points()
        let first = point(for: points[0])
        path.move(to: first)
        for i in 1..<polyline.pointCount {
            path.addLine(to: point(for: points[i]))
        }

        let color = UIColor(polyline.status.neonColor)
        let baseLineWidth: CGFloat = 3.5 / zoomScale

        context.saveGState()
        context.addPath(path)
        context.setLineJoin(.round)
        context.setLineCap(.round)

        // Halo: wide, soft, translucent.
        context.setStrokeColor(color.withAlphaComponent(0.35).cgColor)
        context.setLineWidth(baseLineWidth * 5)
        context.setShadow(offset: .zero, blur: baseLineWidth * 4, color: color.withAlphaComponent(0.9).cgColor)
        context.strokePath()

        // Core: thin and near-white-hot for the neon look.
        context.addPath(path)
        context.setShadow(offset: .zero, blur: 0, color: nil)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(baseLineWidth)
        context.strokePath()

        context.restoreGState()
    }
}
