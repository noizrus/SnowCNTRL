import SwiftUI
import MapKit

/// Map-first dashboard: the colored street map is the main event, not a
/// small preview buried under a stack of cards — matching how Info-Neige
/// MTL / Info-Stationnement present themselves.
struct DashboardView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = DashboardViewModel()
    @ObservedObject private var addressStore = AddressStore.shared
    @State private var isAddingAddress = false
    @State private var addressBeingEdited: SavedAddress?
    @State private var segments: [StreetSegment] = []
    @State private var region: MKCoordinateRegion
    @State private var hasCenteredOnAddresses = false
    @State private var isShowingNearbyParking = false
    @State private var isShowingCityRules = false
    let city: City
    var onChangeCity: () -> Void

    init(city: City, onChangeCity: @escaping () -> Void) {
        self.city = city
        self.onChangeCity = onChangeCity
        _region = State(initialValue: MKCoordinateRegion(
            center: city.approximateCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    private var myAddresses: [SavedAddress] {
        addressStore.addresses.filter { $0.cityID == city.id }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                TappableMapView(
                    region: $region,
                    pinCoordinate: .constant(nil),
                    accentColor: UIColor(city.tier.color),
                    segments: segments,
                    readOnlyPins: myAddresses
                )
                .ignoresSafeArea(edges: .top)

                bottomPanel
            }
            .navigationTitle(city.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    SnowCntrlBrandmark()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizer.s(.citySelectionChangeButton), action: onChangeCity)
                }
            }
            .task { await viewModel.load(city: city, language: localizer.language) }
            .task(id: myAddresses.map(\.id)) {
                await loadSegments()
                if !hasCenteredOnAddresses, !myAddresses.isEmpty {
                    region = fittingRegion(for: myAddresses)
                    hasCenteredOnAddresses = true
                }
            }
            .sheet(isPresented: $isAddingAddress) {
                AddressMapView(city: city, existing: nil, onSave: saveAddress)
            }
            .sheet(item: $addressBeingEdited) { address in
                AddressMapView(city: city, existing: address, onSave: saveAddress)
            }
            .sheet(isPresented: $isShowingNearbyParking) {
                NearbyParkingView(coordinate: myAddresses.first?.coordinate ?? region.center)
            }
            .sheet(isPresented: $isShowingCityRules) {
                CityRulesView(city: city)
            }
        }
        .tint(themeManager.palette.primary)
    }

    private func isRecentlyVerified(_ address: SavedAddress) -> Bool {
        guard let verifiedAt = address.lastVerifiedAt else { return false }
        return Date().timeIntervalSince(verifiedAt) < 3 * 3600
    }

    private func saveAddress(_ saved: SavedAddress) {
        addressStore.upsert(saved)
        hasCenteredOnAddresses = false
        if saved.alertsEnabled, city.liveProviderID == nil {
            NotificationScheduler.scheduleDailyReminder(cityName: city.name, language: localizer.language)
        }
    }

    private func loadSegments() async {
        guard let first = myAddresses.first else {
            segments = []
            return
        }
        let segmentRegion = MKCoordinateRegion(
            center: first.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        segments = await SnowSegmentService.shared.fetchSegments(for: city, near: segmentRegion)
    }

    private func fittingRegion(for addresses: [SavedAddress]) -> MKCoordinateRegion {
        let coordinates = addresses.map(\.coordinate)
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(center: city.approximateCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lons.min()! + lons.max()!) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((lats.max()! - lats.min()!) * 1.6, 0.01),
            longitudeDelta: max((lons.max()! - lons.min()!) * 1.6, 0.01)
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                statusPill
                Spacer()
                Button {
                    Task { await viewModel.load(city: city, language: localizer.language) }
                } label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title2)
                }
            }

            TierDisclaimerBanner(tier: city.tier, cityName: city.name)

            HStack(spacing: 8) {
                Button {
                    isShowingNearbyParking = true
                } label: {
                    Label(localizer.s(.nearbyParkingButton), systemImage: "parkingsign.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(themeManager.palette.accent)

                Button {
                    isShowingCityRules = true
                } label: {
                    Label(localizer.s(.cityRulesButton), systemImage: "info.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(themeManager.palette.accent)
            }

            addressChips

            AdBannerView()
                .frame(height: 50)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private var statusPill: some View {
        if viewModel.isLoading {
            HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text(localizer.s(.dashboardLoading)).font(.subheadline)
            }
        } else if let result = viewModel.result {
            let (icon, text, color): (String, String, Color) = {
                switch result.state {
                case .activeBanNow:
                    return ("exclamationmark.triangle.fill", localizer.s(.dashboardStatusActive), .red)
                case .noActiveBan:
                    return ("checkmark.circle.fill", localizer.s(.dashboardStatusInactive), .green)
                case .unknownNoData:
                    return ("questionmark.circle.fill", localizer.s(.dashboardStatusUnknown), .secondary)
                }
            }()
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(color)
                Text(text).font(.subheadline.weight(.semibold))
            }
        }
    }

    private var addressChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(myAddresses) { address in
                    HStack(spacing: 6) {
                        Button {
                            addressBeingEdited = address
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: address.alertsEnabled ? "bell.fill" : "bell.slash")
                                    .font(.caption)
                                Text(address.label)
                                    .font(.caption.weight(.medium))
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)

                        Button {
                            addressStore.markVerified(address)
                        } label: {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(isRecentlyVerified(address) ? .green : .secondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(localizer.s(.verifiedButton))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
                }

                Button {
                    isAddingAddress = true
                } label: {
                    Label(
                        myAddresses.isEmpty ? localizer.s(.myStreetPickPrompt) : localizer.s(.myStreetAddAnother),
                        systemImage: "plus"
                    )
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let montreal = CitiesData.all.first { $0.id == "montreal" }!
        let regina = CitiesData.all.first { $0.id == "regina" }!

        Group {
            DashboardView(city: montreal, onChangeCity: {})
                .environmentObject(Localizer())
                .environmentObject(ThemeManager())
                .previewDisplayName("Montréal — Niveau 1")

            DashboardView(city: regina, onChangeCity: {})
                .environmentObject(Localizer())
                .environmentObject(ThemeManager())
                .previewDisplayName("Regina — Niveau 3")
        }
    }
}
