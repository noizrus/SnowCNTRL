import SwiftUI
import MapKit

/// Map-first dashboard in the spirit of Info-Neige: tap a street side to
/// drop an alert marker there; each marker rings the phone when snow
/// clearing reaches its street.
struct DashboardView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(CityStatusService.simulateBanKey) private var isSimulatingBan = false
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var addressStore = AddressStore.shared
    @State private var segments: [StreetSegment] = []
    @State private var region: MKCoordinateRegion
    @State private var hasCenteredOnAddresses = false
    @State private var isShowingCityRules = false
    @State private var isShowingCityHelp = false
    @State private var isPanelCollapsed = true
    @State private var isShowingInfo = false
    @State private var isLoadingStreets = false
    @State private var isLocating = false
    @State private var pendingAlert: PendingAlert?
    @State private var selectedAlertID: UUID?
    @State private var notificationsDenied = false
    @State private var toast: String?
    @State private var isShowingAlertsList = false
    @State private var isShowingCityPicker = false
    @State private var isShowingWeather = false
    @Binding var selectedTab: MainTab
    @ObservedObject var citySelection: CitySelectionViewModel
    let city: City

    /// A marker placed by tapping the map but not added yet.
    private struct PendingAlert {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let segmentID: String?
        var label: String?
    }

    init(city: City, selectedTab: Binding<MainTab>, citySelection: CitySelectionViewModel) {
        self.city = city
        self._selectedTab = selectedTab
        self.citySelection = citySelection
        _region = State(initialValue: MKCoordinateRegion(
            center: city.approximateCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    private var myAddresses: [SavedAddress] {
        addressStore.addresses.filter { $0.cityID == city.id }
    }

    private var selectedAlert: SavedAddress? {
        myAddresses.first { $0.id == selectedAlertID }
    }

    private var isAtAlertLimit: Bool {
        AlertPolicy.isAtLimit(alertCount: addressStore.addresses.count, isPremium: premiumManager.isPremium)
    }

    /// Street sides with an alert (and the one being added), drawn highlighted.
    private var highlightedSideIDs: Set<String> {
        var ids = Set(myAddresses.compactMap { segments.nearestSide(to: $0.coordinate, within: 15)?.segment.id })
        if let pendingID = pendingAlert?.segmentID {
            ids.insert(pendingID)
        }
        return ids
    }

    /// Everything the home/lock screen widget displays; it's republished
    /// whenever any of it changes.
    private struct WidgetSignature: Equatable {
        let state: ParkingBanState?
        let isOffSeason: Bool?
        let alertLabel: String?
        let theme: AppTheme
        let province: ProvinceCode?
        let language: AppLanguage
    }

    private var widgetSignature: WidgetSignature {
        WidgetSignature(
            state: viewModel.result?.state,
            isOffSeason: viewModel.result?.isOffSeason,
            alertLabel: myAddresses.first?.label,
            theme: themeManager.selectedTheme,
            province: themeManager.province,
            language: localizer.language
        )
    }

    /// Fixed patch size loaded around each point of interest below —
    /// independent of the map's current zoom, so panning or zooming the
    /// visible map never changes how much street data gets fetched.
    private static let streetLoadSpanDegrees: CLLocationDegrees = 0.02

    /// Real street geometry is mainly needed around two kinds of place:
    /// where the driver is right now, and where they've parked (their
    /// saved alerts). Loading the whole visible map area used to mean the
    /// query (and the number of lines to draw) grew with how far out you'd
    /// zoomed, which got slow; a few small fixed radiuses here stay fast at
    /// any zoom level. Falls back to the city center so a first-time user
    /// with no saved address and no location yet still sees something to
    /// tap.
    private var pointsOfInterest: [CLLocationCoordinate2D] {
        var points = myAddresses.map(\.coordinate)
        if let location = locationManager.lastLocation {
            points.append(location)
        }
        // Zoomed in close enough that the visible area is already about the
        // size of one loaded patch: also load wherever that is, so browsing
        // to an unfamiliar spot still shows its lines once zoomed in enough
        // to actually place an alert there — just not while zoomed out
        // wide, which is what made the whole-viewport version slow.
        if region.span.latitudeDelta <= Self.streetLoadSpanDegrees {
            points.append(region.center)
        }
        if points.isEmpty {
            points.append(city.approximateCoordinate)
        }
        return points
    }

    private struct StreetRequest: Equatable {
        struct Point: Equatable {
            let latitude: Int
            let longitude: Int
        }
        let points: [Point]
        let state: ParkingBanState?
    }

    private var streetRequest: StreetRequest {
        StreetRequest(
            points: pointsOfInterest.map {
                StreetRequest.Point(
                    latitude: Int(($0.latitude / 0.0015).rounded()),
                    longitude: Int(($0.longitude / 0.0015).rounded())
                )
            },
            state: viewModel.result?.state
        )
    }

    var body: some View {
        // Kept as separate statements (not one long chained expression) —
        // otherwise the type-checker times out on this many stacked
        // modifiers ("unable to type-check in reasonable time").
        content
            .task(id: isSimulatingBan) {
                await viewModel.load(city: city, language: localizer.language)
            }
            .task(id: widgetSignature) {
                await publishToWidget()
            }
            .task(id: myAddresses.map(\.id)) {
                centerOnAddressesIfNeeded()
            }
            .task(id: streetRequest) {
                await loadSegmentsDebounced()
            }
            .onReceive(locationManager.$lastLocation) { coordinate in
                handleLocationUpdate(coordinate)
            }
            .sheet(isPresented: $isShowingCityRules) {
                CityRulesView(city: city)
            }
            .sheet(isPresented: $isShowingAlertsList) {
                alertsListSheet
            }
            .tint(themeManager.palette.primaryText)
    }

    private var content: some View {
        // Split from mapStackWithChrome (not one long chain) — this file
        // already hit the type-checker timeout once from an oversized
        // modifier chain; keep each one short as more get added.
        NavigationStack {
            mapStackWithChrome
                // Pushed into this same stack (not a sheet) so "Changer de
                // ville" gets a normal back button and keeps the bottom bar
                // visible underneath instead of covering it.
                .navigationDestination(isPresented: $isShowingCityPicker) {
                    CityListScreen(viewModel: citySelection) { newCity in
                        citySelection.select(newCity)
                        isShowingCityPicker = false
                    }
                }
                // Same reasoning as "Changer de ville" above: pushed, not
                // sheeted, so the bottom bar stays visible when "Aide" is
                // opened (from the bar itself, the panel button, or the map
                // legend — all three share this state).
                .navigationDestination(isPresented: $isShowingCityHelp) {
                    CityHelpView(city: city)
                }
                .navigationDestination(isPresented: $isShowingWeather) {
                    WeatherForecastView(city: city)
                }
        }
    }

    private var mapStackWithChrome: some View {
        mapStack
            .navigationTitle(city.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .themedNavigationBar(themeManager.palette)
            // Declared on this screen's own NavigationStack, not on the
            // TabView wrapping it — a `.safeAreaInset` added further up the
            // tree wasn't reliably reaching the draggable panel inside
            // here, which the collapsed panel (just the status pill) then
            // rendered partly behind the bottom bar.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                MainBottomBar(
                    selectedTab: $selectedTab,
                    onShowTowedHelp: { isShowingCityHelp = true },
                    onShowWeather: { isShowingWeather = true }
                )
            }
    }

    /// 8 pt top padding + four 44 pt buttons + three 10 pt gaps + 12 pt
    /// spacing = 226. Written as a single literal, not the arithmetic
    /// expression it comes from — mixing `+` and `*` across several
    /// integer literals made the type-checker time out (too many numeric
    /// operator overloads to resolve in one constraint system, a known
    /// Swift pitfall with SwiftUI/MapKit imported).
    private var compassTopInset: CGFloat { 226 }

    private var mapStack: some View {
        ZStack(alignment: .bottom) {
            TappableMapView(
                region: $region,
                pinCoordinate: .constant(pendingAlert?.coordinate),
                accentColor: UIColor(themeManager.palette.primary),
                segments: segments,
                readOnlyPins: myAddresses,
                highlightedSegmentIDs: highlightedSideIDs,
                onTap: handleMapTap,
                onSelectPin: selectAlert,
                compassTopInset: compassTopInset
            )
            .ignoresSafeArea(edges: .top)

            mapOverlay

            bottomPanel
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // Leading/trailing are icon-only now, so there's room for the
        // wordmark above the city name instead of squeezing it into a corner.
        ToolbarItem(placement: .principal) {
            titleToolbarContent
        }
        // Info-Neige puts its favorites list top-left — same spot, same
        // idea: every alert in one place.
        ToolbarItem(placement: .navigationBarLeading) {
            alertsListToolbarButton
        }
    }

    private var titleToolbarContent: some View {
        HStack(spacing: 8) {
            AppLogoImage(size: 40)
            VStack(alignment: .leading, spacing: 0) {
                Text(localizer.language.appName)
                    .font(.system(.caption2, design: .rounded).weight(.heavy))
                    .tracking(0.6)
                    .foregroundStyle(themeManager.palette.onAccent)
                Text(city.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(themeManager.palette.onAccent)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var alertsListToolbarButton: some View {
        Button {
            isShowingAlertsList = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "list.bullet")
                    .foregroundStyle(themeManager.palette.onAccent)
                if !myAddresses.isEmpty {
                    Circle()
                        .fill(themeManager.palette.primary)
                        .frame(width: 8, height: 8)
                        .offset(x: 6, y: -4)
                }
            }
        }
        .accessibilityLabel(localizer.s(.alertsListTitle))
    }

    private var alertsListSheet: some View {
        AlertsListView(
            alerts: myAddresses,
            currentStatus: (viewModel.result?.state ?? .unknownNoData).asSnowClearingStatus,
            onSelect: { alert in
                focus(on: alert)
                selectAlert(alert.id)
            },
            onRemove: removeAlert
        )
    }

    private func publishToWidget() async {
        guard let result = viewModel.result else { return }
        WidgetBridge.publish(city: city, result: result, language: localizer.language, accent: themeManager.palette.primary)
    }

    private func centerOnAddressesIfNeeded() {
        if !hasCenteredOnAddresses, !myAddresses.isEmpty {
            region = fittingRegion(for: myAddresses)
            hasCenteredOnAddresses = true
        }
    }

    private func loadSegmentsDebounced() async {
        // Debounce: panning changes the request continuously.
        try? await Task.sleep(nanoseconds: 300_000_000)
        guard !Task.isCancelled else { return }
        await loadSegments()
    }

    private func handleLocationUpdate(_ coordinate: CLLocationCoordinate2D?) {
        guard isLocating, let coordinate else { return }
        isLocating = false
        region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    }

    // MARK: - Map overlay

    private var mapOverlay: some View {
        VStack {
            mapOverlayTopRow
                .padding(.horizontal, 16)
                .padding(.top, 8)
            Spacer()
        }
    }

    private var mapOverlayTopRow: some View {
        HStack(alignment: .top) {
            mapHints
            Spacer(minLength: 8)
            mapControlsColumn
        }
    }

    @ViewBuilder
    private var mapHints: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let toast {
                MapHintCapsule(text: toast)
                    .transition(.opacity)
            }
            if isLoadingStreets {
                MapHintCapsule(text: localizer.s(.mapLoadingStreets), showsProgress: true)
            }
        }
    }

    private var mapControlsColumn: some View {
        VStack(alignment: .trailing, spacing: 10) {
            MapControlButton(systemImage: "mappin.and.ellipse", accessibilityText: localizer.s(.citySelectionChangeButton)) {
                isShowingCityPicker = true
            }
            MapControlButton(systemImage: "location.fill", accessibilityText: localizer.s(.mapLocateMe)) {
                isLocating = true
                locationManager.requestLocation()
            }
            MapControlButton(
                systemImage: colorScheme == .dark ? "sun.max.fill" : "moon.stars.fill",
                accessibilityText: localizer.s(.mapToggleDayNight)
            ) {
                themeManager.appearance = colorScheme == .dark ? .light : .dark
            }
            MapControlButton(systemImage: "info", isActive: isShowingInfo, accessibilityText: localizer.s(.infoButton)) {
                withAnimation(.easeInOut(duration: 0.2)) { isShowingInfo.toggle() }
            }
            if isShowingInfo {
                mapLegendPopover
            }
        }
    }

    private var mapLegendPopover: some View {
        MapLegendView(
            onShowCityRules: {
                isShowingInfo = false
                isShowingCityRules = true
            },
            onShowCityHelp: {
                isShowingInfo = false
                isShowingCityHelp = true
            }
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)))
    }

    // MARK: - Alerts

    private func handleMapTap(_ coordinate: CLLocationCoordinate2D) {
        selectedAlertID = nil

        // Roughly a finger's width on screen at the current zoom.
        let threshold = max(25, region.span.latitudeDelta * 111_000 * 0.04)
        if let match = segments.nearestSide(to: coordinate, within: threshold) {
            let pending = PendingAlert(coordinate: match.curbPoint, segmentID: match.segment.id)
            present(pending)
            Task {
                let label = await AddressGeocoder.alertLabel(for: match, language: localizer.language)
                if pendingAlert?.id == pending.id { pendingAlert?.label = label }
            }
        } else if segments.isEmpty {
            // No street geometry here: fall back to the exact tapped point.
            let pending = PendingAlert(coordinate: coordinate, segmentID: nil)
            present(pending)
            Task {
                let label = await AddressGeocoder.reverseGeocode(coordinate)
                if pendingAlert?.id == pending.id { pendingAlert?.label = label }
            }
        } else {
            // Tapped between streets: just dismiss any pending marker.
            withAnimation { pendingAlert = nil }
        }
    }

    private func present(_ pending: PendingAlert) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            pendingAlert = pending
            isPanelCollapsed = false
        }
    }

    private func confirmPendingAlert() {
        guard let pending = pendingAlert, let label = pending.label else { return }
        if isAtAlertLimit {
            // Free version: the new alert replaces the existing one.
            for existing in addressStore.addresses {
                removeAlert(existing)
            }
        }
        let alert = SavedAddress(label: label, coordinate: pending.coordinate, cityID: city.id)
        addressStore.upsert(alert)
        withAnimation {
            pendingAlert = nil
            selectedAlertID = alert.id
        }
        Task {
            notificationsDenied = !(await NotificationScheduler.requestAuthorizationIfNeeded())
            await BackgroundRefreshManager.checkNow(language: localizer.language)
        }
    }

    private func selectAlert(_ id: UUID) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            pendingAlert = nil
            selectedAlertID = id
            isPanelCollapsed = false
        }
    }

    private func removeAlert(_ address: SavedAddress) {
        AlertNotifier.handleBanCleared(for: address.id)
        withAnimation {
            addressStore.remove(address)
            if selectedAlertID == address.id { selectedAlertID = nil }
        }
    }

    private func testAlert(_ address: SavedAddress) {
        Task {
            let granted = await NotificationScheduler.requestAuthorizationIfNeeded()
            notificationsDenied = !granted
            guard granted else { return }
            AlertNotifier.sendTest(for: address, language: localizer.language)
            showToast(localizer.s(.alertTestScheduled))
        }
    }

    private func focus(on address: SavedAddress) {
        region = MKCoordinateRegion(center: address.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
    }

    private func showToast(_ text: String) {
        withAnimation { toast = text }
        Task {
            try? await Task.sleep(nanoseconds: 3_500_000_000)
            if toast == text {
                withAnimation { toast = nil }
            }
        }
    }

    // MARK: - Data

    private func loadSegments() async {
        let overallStatus = (viewModel.result?.state ?? .unknownNoData).asSnowClearingStatus
        isLoadingStreets = true
        var merged: [String: StreetSegment] = [:]
        for point in pointsOfInterest {
            let pointRegion = MKCoordinateRegion(
                center: point,
                span: MKCoordinateSpan(latitudeDelta: Self.streetLoadSpanDegrees, longitudeDelta: Self.streetLoadSpanDegrees)
            )
            let loaded = await SnowSegmentService.shared.segments(for: city, in: pointRegion, overallStatus: overallStatus)
            for segment in loaded { merged[segment.id] = segment }
        }
        isLoadingStreets = false
        segments = Array(merged.values)
    }

    private func fittingRegion(for addresses: [SavedAddress]) -> MKCoordinateRegion {
        let lats = addresses.map(\.latitude)
        let lons = addresses.map(\.longitude)
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
        bottomPanelContent
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(panelBackground)
            .shadow(color: .black.opacity(0.35), radius: 16, y: 6)
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
            .gesture(panelDragGesture)
    }

    private var bottomPanelContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            panelHandle
            panelHeaderRow
            if !isPanelCollapsed {
                panelExpandedContent
            }
            if !premiumManager.isPremium {
                adRow
            }
        }
    }

    private var panelHandle: some View {
        Capsule()
            .fill(Color.secondary.opacity(0.5))
            .frame(width: 38, height: 5)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { togglePanel() }
    }

    private var panelHeaderRow: some View {
        HStack(spacing: 10) {
            statusPill
                .contentShape(Rectangle())
                .onTapGesture { togglePanel() }
            Spacer(minLength: 0)
            roundIconButton(systemImage: "arrow.clockwise", accessibilityText: localizer.s(.dashboardRefreshButton)) {
                Task { await viewModel.load(city: city, language: localizer.language) }
            }
            roundIconButton(systemImage: isPanelCollapsed ? "chevron.up" : "chevron.down", accessibilityText: localizer.s(.panelToggle)) {
                togglePanel()
            }
        }
    }

    @ViewBuilder
    private var panelExpandedContent: some View {
        TierDisclaimerBanner(tier: city.tier, cityName: city.name)

        if let pending = pendingAlert {
            pendingAlertCard(pending)
        } else if let alert = selectedAlert {
            alertCard(alert)
        } else {
            alertsList
        }

        Button {
            isShowingCityHelp = true
        } label: {
            Label(localizer.s(.helpTitle), systemImage: "car.fill")
        }
        .buttonStyle(NeutralButtonStyle())
    }

    private var adRow: some View {
        HStack {
            Spacer(minLength: 0)
            AdBannerView()
                .frame(width: 320, height: 50)
            Spacer(minLength: 0)
        }
    }

    private var panelBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(themeManager.palette.primary.opacity(0.25), lineWidth: 1)
            )
    }

    private var panelDragGesture: some Gesture {
        DragGesture(minimumDistance: 15)
            .onEnded { value in
                if value.translation.height > 40, !isPanelCollapsed {
                    togglePanel()
                } else if value.translation.height < -40, isPanelCollapsed {
                    togglePanel()
                }
            }
    }

    private func togglePanel() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            isPanelCollapsed.toggle()
        }
    }

    private func roundIconButton(systemImage: String, accessibilityText: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(themeManager.palette.primaryText)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color(.tertiarySystemBackground)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityText)
    }

    private func pendingAlertCard(_ pending: PendingAlert) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(localizer.s(.alertAddTitle), systemImage: "bell.badge.fill")
                .font(.headline)
                .foregroundStyle(themeManager.palette.primaryText)
            if let label = pending.label {
                Text(label)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ProgressView().controlSize(.small)
            }
            if isAtAlertLimit {
                Text(localizer.s(.alertFreeLimit))
                    .font(.caption)
                    .foregroundStyle(Color.primary.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 8) {
                Button(localizer.s(.alertCancel)) {
                    withAnimation { pendingAlert = nil }
                }
                .buttonStyle(NeutralButtonStyle())

                Button(action: confirmPendingAlert) {
                    Label(localizer.s(isAtAlertLimit ? LocKey.alertReplaceButton : LocKey.alertAddButton), systemImage: "bell.fill")
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .buttonStyle(ThemedFillButtonStyle(palette: themeManager.palette))
                .disabled(pending.label == nil)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemBackground).opacity(0.85)))
    }

    private func alertCard(_ alert: SavedAddress) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "car.fill")
                    .foregroundStyle(themeManager.palette.primaryText)
                Text(alert.label)
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                Button {
                    withAnimation { selectedAlertID = nil }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            Text(localizer.s(.alertCardDescription))
                .font(.caption)
                .foregroundStyle(Color.primary.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
            if notificationsDenied {
                Text(localizer.s(.alertNotificationsDenied))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 8) {
                Button {
                    removeAlert(alert)
                } label: {
                    Label(localizer.s(.alertRemove), systemImage: "trash")
                }
                .buttonStyle(NeutralButtonStyle(isDestructive: true))

                Button {
                    testAlert(alert)
                } label: {
                    Label(localizer.s(.alertTest), systemImage: "speaker.wave.3.fill")
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .buttonStyle(ThemedFillButtonStyle(palette: themeManager.palette))
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemBackground).opacity(0.85)))
    }

    @ViewBuilder
    private var alertsList: some View {
        if myAddresses.isEmpty {
            Label(localizer.s(.alertsEmptyHint), systemImage: "hand.tap.fill")
                .font(.subheadline)
                .foregroundStyle(Color.primary.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(myAddresses) { alert in
                            alertChip(alert)
                        }
                    }
                    .padding(.vertical, 2)
                }
                Text(localizer.s(.alertsListHint))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func alertChip(_ alert: SavedAddress) -> some View {
        HStack(spacing: 6) {
            Button {
                focus(on: alert)
                selectAlert(alert.id)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundStyle(themeManager.palette.primaryText)
                    Text(alert.label)
                        .font(.caption.weight(.medium))
                        .lineLimit(1)
                }
            }
            .buttonStyle(.plain)

            Button {
                removeAlert(alert)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(localizer.s(.alertRemove))
        }
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color(.tertiarySystemBackground)))
        .overlay(Capsule().strokeBorder(themeManager.palette.primary.opacity(0.35), lineWidth: 1))
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
                    return ("questionmark.circle.fill", localizer.s(.dashboardStatusUnknown), SnowClearingStatus.noOperation.neonColor)
                }
            }()
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(text)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Image(systemName: isPanelCollapsed ? "chevron.down" : "chevron.up")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(color.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(color.opacity(0.16)))
            .overlay(Capsule().strokeBorder(color.opacity(0.5), lineWidth: 1))
            .shadow(color: color.opacity(0.35), radius: 6)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let montreal = CitiesData.all.first { $0.id == "montreal" }!
        DashboardView(city: montreal, selectedTab: .constant(.dashboard), citySelection: CitySelectionViewModel())
            .environmentObject(Localizer())
            .environmentObject(ThemeManager())
            .environmentObject(PremiumManager())
    }
}
