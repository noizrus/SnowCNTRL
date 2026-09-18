import SwiftUI
import MapKit

/// "Choisis ta rue" — search an address, drop/drag a pin, or use the
/// current location, then save it as the street to watch for this city.
struct AddressMapView: View {
    @EnvironmentObject private var localizer: Localizer
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel: AddressMapViewModel
    @Environment(\.dismiss) private var dismiss

    let city: City
    var onSave: (SavedAddress) -> Void

    init(city: City, existing: SavedAddress? = nil, onSave: @escaping (SavedAddress) -> Void) {
        self.city = city
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: AddressMapViewModel(
            fallbackCoordinate: city.approximateCoordinate,
            existing: existing
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar

                ZStack(alignment: .bottomTrailing) {
                    TappableMapView(
                        region: $viewModel.region,
                        pinCoordinate: $viewModel.pinCoordinate,
                        accentColor: UIColor(city.tier.color)
                    ) { coordinate in
                        Task { await viewModel.dropPin(at: coordinate) }
                    }

                    Button {
                        locationManager.requestLocation()
                    } label: {
                        Image(systemName: "location.fill")
                            .padding(10)
                            .background(.thinMaterial, in: Circle())
                    }
                    .padding()
                }

                pinSummary
            }
            .navigationTitle(city.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("✕") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(localizer.s(.mapSaveButton)) {
                        if let address = viewModel.makeAddress(cityID: city.id) {
                            onSave(address)
                            dismiss()
                        }
                    }
                    .disabled(viewModel.pinCoordinate == nil || viewModel.pinLabelIsMissing)
                }
            }
            .onChange(of: locationManager.lastLocation) { coordinate in
                guard let coordinate else { return }
                viewModel.region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                Task { await viewModel.dropPin(at: coordinate) }
            }
        }
    }

    private var searchPlaceholder: String {
        localizer.s(.citySelectionSearchPlaceholder)
    }

    private var searchBar: some View {
        HStack {
            TextField(searchPlaceholder, text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
                .onSubmit { Task { await viewModel.search() } }
            Button {
                Task { await viewModel.search() }
            } label: {
                Image(systemName: "magnifyingglass")
            }
        }
        .padding()
    }

    @ViewBuilder
    private var pinSummary: some View {
        if viewModel.isBusy {
            ProgressView().padding()
        } else if let label = viewModel.pinLabel {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(city.tier.color)
                Text(label)
                    .font(.subheadline.weight(.medium))
                Spacer()
            }
            .padding()
        } else if let error = viewModel.errorMessage {
            Text(error)
                .font(.footnote)
                .foregroundStyle(.red)
                .padding()
        }
    }
}

private extension AddressMapViewModel {
    var pinLabelIsMissing: Bool { pinLabel == nil }
}

struct AddressMapView_Previews: PreviewProvider {
    static var previews: some View {
        AddressMapView(city: CitiesData.all.first { $0.id == "montreal" }!, onSave: { _ in })
            .environmentObject(Localizer())
    }
}
