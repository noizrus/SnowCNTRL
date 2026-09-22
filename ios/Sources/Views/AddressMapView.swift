import SwiftUI
import MapKit
import Combine

/// "Choisis ta rue" — search an address or use your location, then tap the
/// side of the street where you park; the car is placed along that curb.
struct AddressMapView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel: AddressMapViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var segments: [StreetSegment] = []
    @State private var cityStatus: SnowClearingStatus?
    @State private var isZoomedOutTooFar = false

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

    private struct StreetRequest: Equatable {
        let latitude: Int
        let longitude: Int
        let zoom: Int
        let status: SnowClearingStatus?
    }

    private var streetRequest: StreetRequest {
        StreetRequest(
            latitude: Int((viewModel.region.center.latitude / 0.0015).rounded()),
            longitude: Int((viewModel.region.center.longitude / 0.0015).rounded()),
            zoom: Int((log2(viewModel.region.span.latitudeDelta) * 2).rounded()),
            status: cityStatus
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar

                ZStack(alignment: .top) {
                    TappableMapView(
                        region: $viewModel.region,
                        pinCoordinate: $viewModel.pinCoordinate,
                        accentColor: UIColor(themeManager.palette.primary),
                        segments: segments,
                        highlightedSegmentIDs: Set([viewModel.selectedSegment?.id].compactMap { $0 }),
                        onTap: { coordinate in
                            Task {
                                await viewModel.handleTap(at: coordinate, segments: segments, language: localizer.language)
                            }
                        }
                    )

                    HStack(alignment: .top) {
                        MapHintCapsule(text: localizer.s(isZoomedOutTooFar ? LocKey.mapZoomInHint : LocKey.addressMapTapHint))
                        Spacer()
                        MapControlButton(systemImage: "location.fill", accessibilityText: localizer.s(.mapLocateMe)) {
                            locationManager.requestLocation()
                        }
                    }
                    .padding(12)
                }

                pinSummary
            }
            .navigationTitle(city.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
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
            .onReceive(locationManager.$lastLocation) { coordinate in
                guard let coordinate else { return }
                viewModel.region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
                )
            }
            .task {
                cityStatus = await CityStatusService.shared.fetchStatus(for: city).state.asSnowClearingStatus
            }
            .task(id: streetRequest) {
                guard let cityStatus else { return }
                try? await Task.sleep(nanoseconds: 300_000_000)
                guard !Task.isCancelled else { return }
                let result = await SnowSegmentService.shared.segments(for: city, in: viewModel.region, overallStatus: cityStatus)
                switch result {
                case .zoomedOutTooFar:
                    isZoomedOutTooFar = true
                    segments = []
                case .segments(let loaded):
                    isZoomedOutTooFar = false
                    segments = loaded
                }
            }
        }
        .tint(themeManager.palette.primaryText)
    }

    private var searchBar: some View {
        HStack {
            TextField(localizer.s(.citySelectionSearchPlaceholder), text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
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
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "car.fill")
                        .foregroundStyle(themeManager.palette.primaryText)
                    Text(label)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Toggle(localizer.s(.myStreetAlertsCaption), isOn: $viewModel.alertsEnabled)
                        .labelsHidden()
                }
                if viewModel.selectedSegment != nil {
                    Text(localizer.s(.addressMapSideSelected))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
            .environmentObject(ThemeManager())
    }
}
