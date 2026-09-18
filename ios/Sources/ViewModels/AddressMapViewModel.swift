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

    private let existingID: UUID?
    private let existingAlertsEnabled: Bool

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
        existingAlertsEnabled = existing?.alertsEnabled ?? true
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
        pinCoordinate = coordinate
        pinLabel = nil
        isBusy = true
        pinLabel = await AddressGeocoder.reverseGeocode(coordinate)
        isBusy = false
    }

    func makeAddress(cityID: String) -> SavedAddress? {
        guard let coordinate = pinCoordinate, let label = pinLabel else { return nil }
        return SavedAddress(
            id: existingID ?? UUID(),
            label: label,
            coordinate: coordinate,
            cityID: cityID,
            alertsEnabled: existingAlertsEnabled
        )
    }
}
