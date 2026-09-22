import Foundation
import MapKit
import Combine

@MainActor
final class AddressMapViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var region: MKCoordinateRegion
    @Published var pinCoordinate: CLLocationCoordinate2D?
    @Published private(set) var pinLabel: String?
    @Published private(set) var isBusy = false
    @Published var errorMessage: String?
    @Published var alertsEnabled: Bool
    /// The street side the user tapped near, if any — when set, the pin
    /// represents "this whole side of this street" (Info-Neige style)
    /// rather than an arbitrary dropped point.
    @Published private(set) var selectedSegment: StreetSegment?

    private let existingID: UUID?
    private let snapDistanceMeters: Double = 25

    init(fallbackCoordinate: CLLocationCoordinate2D, existing: SavedAddress? = nil) {
        let center = existing?.coordinate ?? fallbackCoordinate
        region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: existing == nil ? 0.05 : 0.01,
                longitudeDelta: existing == nil ? 0.05 : 0.01
            )
        )
        pinCoordinate = existing?.coordinate
        pinLabel = existing?.label
        existingID = existing?.id
        alertsEnabled = existing?.alertsEnabled ?? true
    }

    func search() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isBusy = true
        errorMessage = nil
        do {
            let found = try await AddressGeocoder.search(searchText)
            pinCoordinate = found.coordinate
            pinLabel = found.label
            region = MKCoordinateRegion(
                center: found.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isBusy = false
    }

    func dropPin(at coordinate: CLLocationCoordinate2D) async {
        selectedSegment = nil
        pinCoordinate = coordinate
        pinLabel = nil
        isBusy = true
        pinLabel = await AddressGeocoder.reverseGeocode(coordinate)
        isBusy = false
    }

    /// Tries to snap the tap to the nearest street side within
    /// `snapDistanceMeters`; falls back to a plain dropped pin when no
    /// segment is close enough (or none exist for this city yet).
    func handleTap(at coordinate: CLLocationCoordinate2D, segments: [StreetSegment]) async {
        let nearest = segments
            .map { ($0, $0.distance(to: coordinate)) }
            .min { $0.1 < $1.1 }

        guard let (segment, distance) = nearest, distance <= snapDistanceMeters else {
            await dropPin(at: coordinate)
            return
        }

        selectedSegment = segment
        pinCoordinate = segment.midpoint
        pinLabel = nil
        isBusy = true
        pinLabel = await AddressGeocoder.reverseGeocode(segment.midpoint)
        isBusy = false
    }

    func makeAddress(cityID: String) -> SavedAddress? {
        guard let coordinate = pinCoordinate, let label = pinLabel else { return nil }
        return SavedAddress(
            id: existingID ?? UUID(),
            label: label,
            coordinate: coordinate,
            cityID: cityID,
            alertsEnabled: alertsEnabled
        )
    }
}
