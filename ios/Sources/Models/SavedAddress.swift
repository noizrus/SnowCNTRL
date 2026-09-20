import Foundation
import CoreLocation

struct SavedAddress: Identifiable, Codable, Hashable {
    let id: UUID
    var label: String
    var latitude: Double
    var longitude: Double
    var cityID: String
    var alertsEnabled: Bool
    /// Personal, device-local "I checked on site" marker — there is no
    /// backend to share this with other users, so it only ever reflects
    /// what this one person confirmed on this one phone.
    var lastVerifiedAt: Date?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(
        id: UUID = UUID(),
        label: String,
        coordinate: CLLocationCoordinate2D,
        cityID: String,
        alertsEnabled: Bool = true,
        lastVerifiedAt: Date? = nil
    ) {
        self.id = id
        self.label = label
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.cityID = cityID
        self.alertsEnabled = alertsEnabled
        self.lastVerifiedAt = lastVerifiedAt
    }
}
