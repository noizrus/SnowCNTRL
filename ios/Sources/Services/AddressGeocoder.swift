import Foundation
import CoreLocation

enum AddressGeocoder {
    /// Turns a coordinate into a readable street label, e.g.
    /// "6702 Rue Saint-Denis, Montréal".
    static func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async -> String {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let fallback = String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude)
        guard let placemark = try? await geocoder.reverseGeocodeLocation(location).first else {
            return fallback
        }
        return label(for: placemark, fallback: fallback)
    }

    /// Label for an alert placed on a street side: the address plus which
    /// side, e.g. "6702 Rue Saint-Denis, Montréal — côté est".
    static func alertLabel(for match: StreetSideMatch, language: AppLanguage) async -> String {
        let address = await reverseGeocode(match.curbPoint)
        let side = match.segment.compassSide.label(language: language)
        // Near corners reverse geocoding can name the cross street; the
        // OSM name of the tapped block is the one the user meant.
        if let streetName = match.segment.block.streetName,
           !address.localizedCaseInsensitiveContains(streetName) {
            return "\(streetName) — \(side)"
        }
        return "\(address) — \(side)"
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
