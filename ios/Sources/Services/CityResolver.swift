import Foundation
import CoreLocation

enum CityResolver {
    /// Nearest known city to a coordinate, used to auto-select a city from
    /// GPS instead of making the user pick one. Straight-line distance is
    /// plenty accurate for this — the city list is sparse compared to the
    /// scale of Canada.
    static func nearestCity(to coordinate: CLLocationCoordinate2D, in cities: [City] = CitiesData.all) -> City? {
        let target = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return cities.min { a, b in
            let da = CLLocation(latitude: a.latitude, longitude: a.longitude).distance(from: target)
            let db = CLLocation(latitude: b.latitude, longitude: b.longitude).distance(from: target)
            return da < db
        }
    }
}
