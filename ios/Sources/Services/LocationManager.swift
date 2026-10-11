import Foundation
import CoreLocation
import Combine

/// Thin wrapper so the map can offer a "use my location" button. Optional —
/// the user can always search or drop a pin manually without granting access.
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var lastLocation: CLLocationCoordinate2D?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    /// Ticks (via a fresh UUID, not the error itself) whenever a one-shot
    /// `requestLocation()` fails — `didFailWithError` only fires once per
    /// request, so this is the one chance to tell the caller "give up
    /// waiting" instead of leaving it hung on a location that's never coming.
    @Published private(set) var lastFailure: UUID?

    private let manager = CLLocationManager()
    /// Whether the last request before an auth prompt was for continuous
    /// tracking (vs. a one-shot fix) — so once permission actually comes
    /// back, the right kind of request resumes instead of always falling
    /// back to a single fix.
    private var wantsContinuousUpdates = false

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        // Road-speed movement, not pedestrian jitter: filters GPS noise
        // appropriately and avoids redundant updates every couple of meters.
        manager.activityType = .automotiveNavigation
        manager.distanceFilter = 15
    }

    func requestLocation() {
        wantsContinuousUpdates = false
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    /// Keeps `lastLocation` updated as the car moves, instead of the single
    /// fix `requestLocation()` gives — what a "follow me while driving" map
    /// mode needs.
    func startUpdatingLocation() {
        wantsContinuousUpdates = true
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    func stopUpdatingLocation() {
        wantsContinuousUpdates = false
        manager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else { return }
        if wantsContinuousUpdates {
            manager.startUpdatingLocation()
        } else {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastFailure = UUID()
    }
}
