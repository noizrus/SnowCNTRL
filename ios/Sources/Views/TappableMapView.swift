import SwiftUI
import MapKit

/// A real MKMapView (not the SwiftUI-16 `Map` view) so tapping the map to
/// drop a pin works reliably at the iOS 16 deployment target — SwiftUI's own
/// tap-to-coordinate API only arrived in iOS 17. Also draws neon glow lines
/// for street segments (see GlowPolylineRenderer) and uses the muted map
/// style so those glow lines stand out against a calmer base map.
struct TappableMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var pinCoordinate: CLLocationCoordinate2D?
    var accentColor: UIColor
    var segments: [StreetSegment] = []
    /// Extra, non-draggable pins shown alongside `pinCoordinate` — used to
    /// show every saved address for a city on one map (with a callout
    /// title) instead of just the one being edited.
    var readOnlyPins: [SavedAddress] = []
    var isInteractive: Bool = true
    var onTap: ((CLLocationCoordinate2D) -> Void)? = nil

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard
        mapView.setRegion(region, animated: false)
        mapView.isScrollEnabled = isInteractive
        mapView.isZoomEnabled = isInteractive
        mapView.isRotateEnabled = isInteractive
        mapView.isPitchEnabled = isInteractive

        if isInteractive {
            let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
            mapView.addGestureRecognizer(tap)
        }
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if !context.coordinator.isDraggingOrAnimating {
            mapView.setRegion(region, animated: true)
        }

        mapView.removeAnnotations(mapView.annotations)
        if let coordinate = pinCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
        for address in readOnlyPins {
            let annotation = ReadOnlyPinAnnotation()
            annotation.coordinate = address.coordinate
            annotation.title = address.label
            mapView.addAnnotation(annotation)
        }

        if context.coordinator.renderedSegmentIDs != segments.map(\.id) {
            mapView.removeOverlays(mapView.overlays)
            for segment in segments {
                let line = GlowPolyline(coordinates: segment.coordinates, count: segment.coordinates.count)
                line.status = segment.status
                mapView.addOverlay(line)
            }
            context.coordinator.renderedSegmentIDs = segments.map(\.id)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private final class ReadOnlyPinAnnotation: MKPointAnnotation {}

    final class Coordinator: NSObject, MKMapViewDelegate {
        private let parent: TappableMapView
        var isDraggingOrAnimating = false
        var renderedSegmentIDs: [String] = []

        init(_ parent: TappableMapView) {
            self.parent = parent
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            parent.onTap?(coordinate)
        }

        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            isDraggingOrAnimating = true
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            isDraggingOrAnimating = false
            // setRegion(_:animated:) in updateUIView can invoke this
            // delegate callback synchronously, so writing straight into the
            // SwiftUI binding here triggers "Publishing changes from within
            // view updates". Deferring one runloop tick avoids that.
            let newRegion = mapView.region
            DispatchQueue.main.async { [parent] in
                parent.region = newRegion
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            let identifier = "snowcntrl.pin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.annotation = annotation
            view.markerTintColor = parent.accentColor
            view.glyphImage = UIImage(systemName: "snowflake")
            view.animatesWhenAdded = true
            view.canShowCallout = annotation is ReadOnlyPinAnnotation
            return view
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let glow = overlay as? GlowPolyline {
                return GlowPolylineRenderer(overlay: glow)
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
