import Foundation
import AVFoundation
import CoreLocation

/// Suggests creating an alert right where the car was just parked, the
/// moment its Bluetooth/CarPlay audio disconnects — manually finding and
/// tapping the right curb is the app's biggest remaining friction, and no
/// official city app does this at all.
///
/// Foreground-biased by nature: iOS only delivers audio route change
/// notifications to a running process, so this reliably catches parking
/// that happens while the app is open or freshly backgrounded — not
/// necessarily hours later with the app fully suspended, since iOS gives
/// no public API to wake an arbitrary app on a classic-Bluetooth (not BLE)
/// disconnect. Partial coverage is still a net win over always typing the
/// street in by hand.
final class CarConnectionMonitor: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = CarConnectionMonitor()
    static let enabledKey = "snowcntrl.parkingDetectionEnabled"

    private static let pendingCoordinateKey = "snowcntrl.pendingParkingLatLon"
    private static let pendingDateKey = "snowcntrl.pendingParkingDate"
    /// Older than this, the suggestion is almost certainly stale — the
    /// user has moved on and it would just be confusing to resurface it.
    private static let suggestionValidityWindow: TimeInterval = 30 * 60

    private let locationManager = CLLocationManager()
    private var isObserving = false

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestAuthorizationIfNeeded() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func startMonitoring() {
        guard UserDefaults.standard.bool(forKey: Self.enabledKey), !isObserving else { return }
        isObserving = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    func stopMonitoring() {
        guard isObserving else { return }
        isObserving = false
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard UserDefaults.standard.bool(forKey: Self.enabledKey), let info = notification.userInfo,
              let rawReason = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              rawReason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue,
              let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
        else { return }

        let carLikePorts: Set<AVAudioSession.Port> = [.bluetoothA2DP, .bluetoothHFP, .bluetoothLE, .carAudio]
        guard previousRoute.outputs.contains(where: { carLikePorts.contains($0.portType) }) else { return }

        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        UserDefaults.standard.set([coordinate.latitude, coordinate.longitude], forKey: Self.pendingCoordinateKey)
        UserDefaults.standard.set(Date(), forKey: Self.pendingDateKey)
        NotificationScheduler.notifyParkingDetected()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silent — adding the alert by hand is always still available.
    }

    /// A parking spot detected recently enough to still be worth
    /// suggesting, and not yet acted on.
    var pendingCoordinate: CLLocationCoordinate2D? {
        guard
            let date = UserDefaults.standard.object(forKey: Self.pendingDateKey) as? Date,
            Date().timeIntervalSince(date) <= Self.suggestionValidityWindow,
            let parts = UserDefaults.standard.array(forKey: Self.pendingCoordinateKey) as? [Double],
            parts.count == 2
        else { return nil }
        return CLLocationCoordinate2D(latitude: parts[0], longitude: parts[1])
    }

    /// Called once the dashboard has offered the suggestion, so it doesn't
    /// keep reappearing on every subsequent launch.
    func consumePendingCoordinate() {
        UserDefaults.standard.removeObject(forKey: Self.pendingCoordinateKey)
        UserDefaults.standard.removeObject(forKey: Self.pendingDateKey)
    }
}
