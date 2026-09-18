import Foundation
import CoreLocation

enum AddressGeocoder {
    /// Turns a typed address/street into a coordinate + a clean display label.
    static func search(_ query: String) async throws -> (coordinate: CLLocationCoordinate2D, label: String) {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(query)
        guard let first = placemarks.first, let location = first.location else {
            throw CityStatusError.badResponse
        }
        return (location.coordinate, label(for: first, fallback: query))
    }

    /// Turns a dropped pin (or the user's current location) into a readable
    /// street label, e.g. "Rue Sainte-Catherine, Montréal".
    static func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async -> String {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        guard let placemark = try? await geocoder.reverseGeocodeLocation(location).first else {
            return String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude)
        }
        return label(for: placemark, fallback: String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude))
    }

    private static func label(for placemark: CLPlacemark, fallback: String) -> String {
        let street = [placemark.subThoroughfare, placemark.thoroughfare]
            .compactMap { $0 }
            .joined(separator: " ")
        let city = placemark.locality
        switch (street.isEmpty, city) {
        case (false, let city?): return "\(street), \(city)"
        case (false, nil): return street
        case (true, let city?): return city
        default: return fallback
        }
    }
}
