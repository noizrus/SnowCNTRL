import SwiftUI

struct RootView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var onboarding = OnboardingViewModel()
    @StateObject private var citySelection = CitySelectionViewModel()
    @State private var skippedGeolocation = false
    @State private var showSplash = true

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

    /// The flag theme follows the city actually shown, so there's no
    /// separate province setting to keep in sync.
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
                TabView {
                    DashboardView(city: city) {
                        citySelection.clearSelection()
                        // Straight to the manual list: the user tapped
                        // "change city" on purpose, so re-running geolocation
                        // here would just re-resolve to the same city.
                        skippedGeolocation = true
                    }
                    .tabItem { Label(localizer.s(.tabDashboard), systemImage: "snowflake") }

                    SettingsView(selectedCity: city, citySelection: citySelection)
                        .tabItem { Label(localizer.s(.tabSettings), systemImage: "gearshape") }
                }
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
}
