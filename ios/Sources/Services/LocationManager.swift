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

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
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
