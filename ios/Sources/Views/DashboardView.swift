import SwiftUI
import MapKit

/// Map-first dashboard in the spirit of Info-Neige: the street map fills
/// the screen, a collapsible panel carries status and saved spots.
struct DashboardView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var addressStore = AddressStore.shared
    @State private var isAddingAddress = false
    @State private var addressBeingEdited: SavedAddress?
    @State private var segments: [StreetSegment] = []
    @State private var region: MKCoordinateRegion
    @State private var hasCenteredOnAddresses = false
    @State private var isShowingNearbyParking = false
    @State private var isShowingCityRules = false
    @State private var isPanelCollapsed = false
    @State private var isShowingLegend = false
    @State private var isZoomedOutTooFar = false
    @State private var isLoadingStreets = false
    @State private var isLocating = false
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

    /// The street side each saved spot sits on, drawn highlighted.
    private var savedSideIDs: Set<String> {
        Set(myAddresses.compactMap { segments.nearestSide(to: $0.coordinate, within: 15)?.segment.id })
    }

    private struct StreetRequest: Equatable {
        let latitude: Int
        let longitude: Int
        let zoom: Int
        let state: ParkingBanState?
    }

    private var streetRequest: StreetRequest {
        StreetRequest(
            latitude: Int((region.center.latitude / 0.0015).rounded()),
            longitude: Int((region.center.longitude / 0.0015).rounded()),
            zoom: Int((log2(region.span.latitudeDelta) * 2).rounded()),
            state: viewModel.result?.state
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                TappableMapView(
                    region: $region,
                    pinCoordinate: .constant(nil),
                    accentColor: UIColor(themeManager.palette.primary),
                    segments: segments,
                    readOnlyPins: myAddresses,
                    highlightedSegmentIDs: savedSideIDs
                )
                .ignoresSafeArea(edges: .top)

                mapOverlay

                bottomPanel
            }
            .navigationTitle(city.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    SnowCntrlBrandmark()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onChangeCity) {
                        Image(systemName: "mappin.and.ellipse")
                    }
                    .accessibilityLabel(localizer.s(.citySelectionChangeButton))
                }
            }
            .task { await viewModel.load(city: city, language: localizer.language) }
            .task(id: myAddresses.map(\.id)) {
                if !hasCenteredOnAddresses, !myAddresses.isEmpty {
                    region = fittingRegion(for: myAddresses)
                    hasCenteredOnAddresses = true
                }
            }
            .task(id: streetRequest) {
                // Debounce: panning changes the request continuously.
                try? await Task.sleep(nanoseconds: 300_000_000)
                guard !Task.isCancelled else { return }
                await loadSegments()
            }
            .onReceive(locationManager.$lastLocation) { coordinate in
                guard isLocating, let coordinate else { return }
                isLocating = false
                region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006))
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

    // MARK: - Map overlay

    private var mapOverlay: some View {
        VStack {
            HStack(alignment: .top) {
                if isZoomedOutTooFar {
                    MapHintCapsule(text: localizer.s(.mapZoomInHint))
                } else if isLoadingStreets {
                    MapHintCapsule(text: localizer.s(.mapLoadingStreets), showsProgress: true)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 10) {
                    MapControlButton(systemImage: "location.fill", accessibilityText: localizer.s(.mapLocateMe)) {
                        isLocating = true
                        locationManager.requestLocation()
                    }
                    MapControlButton(
                        systemImage: "paintpalette.fill",
                        isActive: isShowingLegend,
                        accessibilityText: localizer.s(.mapLegendButton)
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) { isShowingLegend.toggle() }
                    }
                    if isShowingLegend {
                        MapLegendView()
                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            Spacer()
        }
    }

    // MARK: - Actions

    private func isRecentlyVerified(_ address: SavedAddress) -> Bool {
        guard let verifiedAt = address.lastVerifiedAt else { return false }
        return Date().timeIntervalSince(verifiedAt) < 3 * 3600
    }

    private func saveAddress(_ saved: SavedAddress) {
        // Guards against two chips for the same spot.
        for duplicate in myAddresses where duplicate.id != saved.id && duplicate.label == saved.label {
            addressStore.remove(duplicate)
        }
        addressStore.upsert(saved)
        hasCenteredOnAddresses = false
        if saved.alertsEnabled, city.liveProviderID == nil {
            NotificationScheduler.scheduleDailyReminder(cityName: city.name, language: localizer.language)
        }
    }

    private func focus(on address: SavedAddress) {
        withAnimation {
            region = MKCoordinateRegion(center: address.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
        }
    }

    private func loadSegments() async {
        let overallStatus = (viewModel.result?.state ?? .unknownNoData).asSnowClearingStatus
        isLoadingStreets = true
        let result = await SnowSegmentService.shared.segments(for: city, in: region, overallStatus: overallStatus)
        isLoadingStreets = false
        switch result {
        case .zoomedOutTooFar:
            isZoomedOutTooFar = true
            segments = []
        case .segments(let loaded):
            isZoomedOutTooFar = false
            segments = loaded
        }
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
        // Close enough that street lines load right away.
        let span = MKCoordinateSpan(
            latitudeDelta: min(max((lats.max()! - lats.min()!) * 1.6, 0.006), 0.05),
            longitudeDelta: min(max((lons.max()! - lons.min()!) * 1.6, 0.006), 0.05)
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    // MARK: - Bottom panel

    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Capsule()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 38, height: 5)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { togglePanel() }

            HStack(spacing: 10) {
                statusPill
                Spacer(minLength: 0)
                Button {
                    Task { await viewModel.load(city: city, language: localizer.language) }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.body.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color(.tertiarySystemBackground)))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(localizer.s(.dashboardRefreshButton))

                Button(action: togglePanel) {
                    Image(systemName: isPanelCollapsed ? "chevron.up" : "chevron.down")
                        .font(.body.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color(.tertiarySystemBackground)))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(localizer.s(.panelToggle))
            }

            if !isPanelCollapsed {
                TierDisclaimerBanner(tier: city.tier, cityName: city.name)

                HStack(spacing: 8) {
                    actionButton(title: localizer.s(.nearbyParkingButton), systemImage: "parkingsign.circle.fill") {
                        isShowingNearbyParking = true
                    }
                    actionButton(title: localizer.s(.cityRulesButton), systemImage: "info.circle.fill") {
                        isShowingCityRules = true
                    }
                }

                addressChips
            }

            HStack {
                Spacer(minLength: 0)
                AdBannerView()
                    .frame(width: 320, height: 50)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(themeManager.palette.primary.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 16, y: 6)
        .padding(.horizontal, 10)
        .padding(.bottom, 6)
        .gesture(
            DragGesture(minimumDistance: 15)
                .onEnded { value in
                    if value.translation.height > 40, !isPanelCollapsed {
                        togglePanel()
                    } else if value.translation.height < -40, isPanelCollapsed {
                        togglePanel()
                    }
                }
        )
    }

    private func togglePanel() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            isPanelCollapsed.toggle()
        }
    }

    private func actionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(themeManager.palette.accent.opacity(0.18))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(themeManager.palette.accent.opacity(0.45), lineWidth: 1)
                )
                .foregroundStyle(themeManager.palette.accent)
        }
        .buttonStyle(.plain)
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
                    return ("exclamationmark.triangle.fill", localizer.s(.dashboardStatusActive), SnowClearingStatus.noParkingActive.neonColor)
                case .noActiveBan where result.isOffSeason:
                    return ("sun.max.fill", localizer.s(.dashboardStatusOffSeason), SnowClearingStatus.cleared.neonColor)
                case .noActiveBan:
                    return ("checkmark.circle.fill", localizer.s(.dashboardStatusInactive), SnowClearingStatus.cleared.neonColor)
                case .unknownNoData:
                    return ("questionmark.circle.fill", localizer.s(.dashboardStatusUnknown), SnowClearingStatus.awaitingInfo.neonColor)
                }
            }()
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(text)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(color.opacity(0.16)))
            .overlay(Capsule().strokeBorder(color.opacity(0.5), lineWidth: 1))
            .shadow(color: color.opacity(0.35), radius: 6)
        }
    }

    private var addressChips: some View {
        VStack(alignment: .leading, spacing: 6) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(myAddresses) { address in
                        addressChip(address)
                    }

                    Button {
                        isAddingAddress = true
                    } label: {
                        Label(
                            myAddresses.isEmpty ? localizer.s(.myStreetPickPrompt) : localizer.s(.myStreetAddAnother),
                            systemImage: "plus"
                        )
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(themeManager.palette.primary))
                        .foregroundStyle(Color.black)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 2)
            }

            if !myAddresses.isEmpty {
                Text(localizer.s(.addressChipsHint))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func addressChip(_ address: SavedAddress) -> some View {
        Button {
            focus(on: address)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "car.fill")
                    .font(.caption)
                    .foregroundStyle(themeManager.palette.primary)
                Text(address.label)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
                if !address.alertsEnabled {
                    Image(systemName: "bell.slash")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if isRecentlyVerified(address) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundStyle(SnowClearingStatus.cleared.neonColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color(.tertiarySystemBackground)))
            .overlay(Capsule().strokeBorder(themeManager.palette.primary.opacity(0.35), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                addressBeingEdited = address
            } label: {
                Label(localizer.s(.addressEdit), systemImage: "pencil")
            }
            Button {
                addressStore.markVerified(address)
            } label: {
                Label(localizer.s(.verifiedButton), systemImage: "checkmark.seal")
            }
            Button(role: .destructive) {
                addressStore.remove(address)
            } label: {
                Label(localizer.s(.addressDelete), systemImage: "trash")
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let montreal = CitiesData.all.first { $0.id == "montreal" }!
        DashboardView(city: montreal, onChangeCity: {})
            .environmentObject(Localizer())
            .environmentObject(ThemeManager())
    }
}
