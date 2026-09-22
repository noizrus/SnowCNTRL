import MapKit
import UIKit

/// A polyline overlay carrying its own status/color, so the shared
/// renderer below can draw each segment in the right color without a
/// separate MKOverlayRenderer subclass per color.
final class GlowPolyline: MKPolyline {
    var status: SnowClearingStatus = .awaitingInfo
    /// True for the street side the user has picked (Info-Neige style),
    /// drawn with an extra white outline so it reads as "selected" at a
    /// glance against the rest of the grid.
    var isSelected: Bool = false
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
        let isSelected = polyline.isSelected
        let baseLineWidth: CGFloat = (isSelected ? 5.5 : 3.5) / zoomScale

        context.saveGState()
        context.addPath(path)
        context.setLineJoin(.round)
        context.setLineCap(.round)

        // Halo: wide, soft, translucent — brighter and wider when selected.
        context.setStrokeColor(color.withAlphaComponent(isSelected ? 0.55 : 0.35).cgColor)
        context.setLineWidth(baseLineWidth * (isSelected ? 6 : 5))
        context.setShadow(offset: .zero, blur: baseLineWidth * 4, color: color.withAlphaComponent(0.9).cgColor)
        context.strokePath()

        if isSelected {
            // A thin white outline so the selected side is unmistakable
            // even against a same-colored neighboring line.
            context.addPath(path)
            context.setShadow(offset: .zero, blur: 0, color: nil)
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(baseLineWidth * 1.6)
            context.strokePath()
        }

        // Core: thin and near-white-hot for the neon look.
        context.addPath(path)
        context.setShadow(offset: .zero, blur: 0, color: nil)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(baseLineWidth)
        context.strokePath()

        context.restoreGState()
    }
}
