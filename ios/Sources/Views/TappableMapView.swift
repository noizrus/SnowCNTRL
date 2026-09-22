import SwiftUI
import MapKit

/// A real MKMapView (SwiftUI's `Map` only gained tap-to-coordinate in
/// iOS 17). Draws each street side as a neon line along its curb (see
/// GlowPolylineRenderer) on a muted base map so the lines stand out.
struct TappableMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var pinCoordinate: CLLocationCoordinate2D?
    var accentColor: UIColor
    var segments: [StreetSegment] = []
    /// Saved spots, shown as car markers with their label as callout.
    var readOnlyPins: [SavedAddress] = []
    var isInteractive: Bool = true
    /// Street sides drawn highlighted (selected or saved).
    var highlightedSegmentIDs: Set<String> = []
    var onTap: ((CLLocationCoordinate2D) -> Void)? = nil
    var onSelectPin: ((UUID) -> Void)? = nil

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: [.publicTransport, .parking])
        mapView.setRegion(region, animated: false)
        mapView.isScrollEnabled = isInteractive
        mapView.isZoomEnabled = isInteractive
        mapView.isRotateEnabled = isInteractive
        mapView.isPitchEnabled = false

        if isInteractive {
            let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
            mapView.addGestureRecognizer(tap)
        }
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self

        if !coordinator.isDraggingOrAnimating, !region.isApproximatelyEqual(to: mapView.region) {
            mapView.setRegion(region, animated: true)
        }

        updateAnnotations(on: mapView, coordinator: coordinator)
        updateOverlays(on: mapView, coordinator: coordinator)
    }

    /// Only touches annotations when they actually changed — re-adding them
    /// on every update made the car markers re-animate while panning.
    private func updateAnnotations(on mapView: MKMapView, coordinator: Coordinator) {
        var hasher = Hasher()
        hasher.combine(pinCoordinate?.latitude)
        hasher.combine(pinCoordinate?.longitude)
        for pin in readOnlyPins {
            hasher.combine(pin.id)
            hasher.combine(pin.latitude)
            hasher.combine(pin.longitude)
            hasher.combine(pin.label)
        }
        let signature = hasher.finalize()
        guard signature != coordinator.annotationSignature else { return }
        coordinator.annotationSignature = signature

        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        if let coordinate = pinCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
        for address in readOnlyPins {
            let annotation = SavedSpotAnnotation()
            annotation.coordinate = address.coordinate
            annotation.title = address.label
            annotation.addressID = address.id
            mapView.addAnnotation(annotation)
        }
    }

    private func updateOverlays(on mapView: MKMapView, coordinator: Coordinator) {
        var hasher = Hasher()
        for segment in segments {
            hasher.combine(segment.id)
            hasher.combine(segment.status)
        }
        for id in highlightedSegmentIDs.sorted() {
            hasher.combine(id)
        }
        let signature = hasher.finalize()
        guard signature != coordinator.overlaySignature else { return }
        coordinator.overlaySignature = signature

        struct GroupKey: Hashable {
            let status: SnowClearingStatus
            let isSelected: Bool
        }
        var groups: [GroupKey: [MKPolyline]] = [:]
        for segment in segments {
            let line = SideLine(coordinates: segment.block.centerline, count: segment.block.centerline.count)
            line.sideSign = segment.sideSign
            line.curbOffsetMeters = segment.block.curbOffsetMeters
            let key = GroupKey(status: segment.status, isSelected: highlightedSegmentIDs.contains(segment.id))
            groups[key, default: []].append(line)
        }

        mapView.removeOverlays(mapView.overlays)
        // Selected groups last so they draw on top.
        for (key, lines) in groups.sorted(by: { !$0.key.isSelected && $1.key.isSelected }) {
            let overlay = GlowMultiPolyline(lines)
            overlay.status = key.status
            overlay.isSelected = key.isSelected
            mapView.addOverlay(overlay)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private final class SavedSpotAnnotation: MKPointAnnotation {
        var addressID: UUID?
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TappableMapView
        var isDraggingOrAnimating = false
        var annotationSignature: Int?
        var overlaySignature: Int?

        init(_ parent: TappableMapView) {
            self.parent = parent
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: mapView)
            // A tap on a marker selects it (didSelect below) — it must not
            // also place a new alert underneath.
            var hit = mapView.hitTest(point, with: nil)
            while let view = hit, view !== mapView {
                if view is MKAnnotationView { return }
                hit = view.superview
            }
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            parent.onTap?(coordinate)
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let spot = view.annotation as? SavedSpotAnnotation, let id = spot.addressID {
                parent.onSelectPin?(id)
            }
            // Deselect right away so the same marker can be tapped again.
            if let annotation = view.annotation {
                mapView.deselectAnnotation(annotation, animated: false)
            }
        }

        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            isDraggingOrAnimating = true
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            isDraggingOrAnimating = false
            // setRegion in updateUIView can call this synchronously; writing
            // the binding right away would publish during a view update.
            let newRegion = mapView.region
            let binding = parent.$region
            DispatchQueue.main.async {
                binding.wrappedValue = newRegion
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            let identifier = "snowcntrl.car"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.annotation = annotation
            view.markerTintColor = parent.accentColor
            view.glyphTintColor = UIColor(ThemePalette.contrastingText(on: Color(uiColor: parent.accentColor)))
            // Saved alert = car parked there; pending one = "+" (not added yet).
            view.glyphImage = UIImage(systemName: annotation is SavedSpotAnnotation ? "car.fill" : "plus")
            view.animatesWhenAdded = true
            view.canShowCallout = false
            view.displayPriority = .required
            return view
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is GlowMultiPolyline {
                return GlowPolylineRenderer(overlay: overlay)
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

private extension MKCoordinateRegion {
    func isApproximatelyEqual(to other: MKCoordinateRegion) -> Bool {
        abs(center.latitude - other.center.latitude) < 0.00001
            && abs(center.longitude - other.center.longitude) < 0.00001
            && abs(span.latitudeDelta - other.span.latitudeDelta) <= span.latitudeDelta * 0.02
            && abs(span.longitudeDelta - other.span.longitudeDelta) <= span.longitudeDelta * 0.02
    }
}
