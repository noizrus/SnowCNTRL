import Foundation
import MapKit

struct NearbyParkingLot: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let distanceMeters: Double
    let mapItem: MKMapItem
}

/// Answers "OK there's a ban — where do I put my car?" using Apple Maps'
/// own points of interest, so it works everywhere without needing
/// municipal data (unlike the ban status itself, which most cities don't
/// publish at all).
enum NearbyParkingFinder {
    static func search(near coordinate: CLLocationCoordinate2D, radiusMeters: CLLocationDistance = 1500) async -> [NearbyParkingLot] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "parking"
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radiusMeters * 2,
            longitudinalMeters: radiusMeters * 2
        )
        if #available(iOS 13.0, *) {
            request.resultTypes = .pointOfInterest
        }

        guard let response = try? await MKLocalSearch(request: request).start() else { return [] }

        let origin = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let lots = response.mapItems.compactMap { item -> NearbyParkingLot? in
            guard let name = item.name else { return nil }
            let itemLocation = CLLocation(
                latitude: item.placemark.coordinate.latitude,
                longitude: item.placemark.coordinate.longitude
            )
            return NearbyParkingLot(
                name: name,
                coordinate: item.placemark.coordinate,
                distanceMeters: itemLocation.distance(from: origin),
                mapItem: item
            )
        }
        .sorted { $0.distanceMeters < $1.distanceMeters }

        return Array(lots.prefix(8))
    }
}
