import Foundation
import CoreLocation

enum CityResolver {
    /// Straight-line distance in meters — plenty accurate at the scale of
    /// Canada's sparse city list.
    static func distance(from coordinate: CLLocationCoordinate2D, to city: City) -> CLLocationDistance {
        CLLocation(latitude: city.latitude, longitude: city.longitude)
            .distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }

    /// Nearest known city to a coordinate, used to auto-select a city from
    /// GPS instead of making the user pick one.
    static func nearestCity(to coordinate: CLLocationCoordinate2D, in cities: [City] = CitiesData.all) -> City? {
        cities.min { distance(from: coordinate, to: $0) < distance(from: coordinate, to: $1) }
    }

    /// Nearest first; alphabetical when the position is unknown.
    static func sortedByDistance(_ cities: [City], from coordinate: CLLocationCoordinate2D?) -> [City] {
        guard let coordinate else {
            return cities.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        }
        return cities
            .map { ($0, distance(from: coordinate, to: $0)) }
            .sorted { $0.1 < $1.1 }
            .map(\.0)
    }
}
