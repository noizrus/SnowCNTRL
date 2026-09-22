import Foundation
import CoreLocation

/// An alert marker: a spot on a street side (the curb where the car is
/// parked) that rings the phone when snow clearing reaches it.
struct SavedAddress: Identifiable, Codable, Hashable {
    let id: UUID
    var label: String
    var latitude: Double
    var longitude: Double
    var cityID: String
    var alertsEnabled: Bool

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(
        id: UUID = UUID(),
        label: String,
        coordinate: CLLocationCoordinate2D,
        cityID: String,
        alertsEnabled: Bool = true
    ) {
        self.id = id
        self.label = label
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.cityID = cityID
        self.alertsEnabled = alertsEnabled
    }
}
