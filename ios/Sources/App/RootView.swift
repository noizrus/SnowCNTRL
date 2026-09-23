import SwiftUI

struct RootView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var onboarding = OnboardingViewModel()
    @StateObject private var citySelection = CitySelectionViewModel()
    @State private var skippedGeolocation = false
    @State private var showSplash = true
    @State private var selectedTab: MainTab = .dashboard
    @State private var isShowingTowedHelp = false

    var body: some View {
        ZStack {
            content

            if showSplash {
                LaunchSplashView()
                    .transition(.opacity)
            }
        }
        .tint(themeManager.palette.primaryText)
        .onAppear {
            themeManager.applyAppearance()
            syncProvince(with: citySelection.selectedCity)
        }
        .onChange(of: citySelection.selectedCity) { city in
            syncProvince(with: city)
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_100_000_000)
            withAnimation(.easeOut(duration: 0.4)) {
                showSplash = false
            }
        }
    }

    /// Theme no longer follows the province — the app always defaults to
    /// its own brand colors. This only keeps `themeManager.province` in
    /// step with the city actually shown, for the province chip preview
    /// used during onboarding.
    private func syncProvince(with city: City?) {
        guard let city, themeManager.province != city.province else { return }
        themeManager.province = city.province
    }

    @ViewBuilder
    private var content: some View {
        Group {
            if !onboarding.hasAccepted {
                OnboardingView { onboarding.accept() }
            } else if let city = citySelection.selectedCity {
                mainTabs(for: city)
            } else if !skippedGeolocation {
                GeoLocatingView(
                    onResolved: { citySelection.select($0) },
                    onManualFallback: { skippedGeolocation = true }
                )
            } else {
                CitySelectionView(viewModel: citySelection)
            }
        }
    }

    /// Dashboard and Settings behind a custom bottom bar (not the system
    /// tab bar — its icons can't glow neon), plus the towed-car help sheet
    /// the bar's third button opens from anywhere. `TabView` (rather than a
    /// plain switch on `selectedTab`) keeps both screens alive across tab
    /// switches, so Dashboard doesn't lose its map position and loaded
    /// streets every time Settings is opened.
    private func mainTabs(for city: City) -> some View {
        TabView(selection: $selectedTab) {
            DashboardView(city: city) {
                citySelection.clearSelection()
                // Straight to the manual list: the user tapped
                // "change city" on purpose, so re-running geolocation
                // here would just re-resolve to the same city.
                skippedGeolocation = true
            }
            .tag(MainTab.dashboard)
            .toolbar(.hidden, for: .tabBar)

            SettingsView(selectedCity: city, citySelection: citySelection)
                .tag(MainTab.settings)
                .toolbar(.hidden, for: .tabBar)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MainBottomBar(selectedTab: $selectedTab) {
                isShowingTowedHelp = true
            }
        }
        .sheet(isPresented: $isShowingTowedHelp) {
            CityHelpView(city: city)
        }
    }
}
