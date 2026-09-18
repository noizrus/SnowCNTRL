import SwiftUI

struct RootView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var onboarding = OnboardingViewModel()
    @StateObject private var citySelection = CitySelectionViewModel()
    @State private var skippedGeolocation = false

    var body: some View {
        Group {
            if !onboarding.hasAccepted {
                OnboardingView { onboarding.accept() }
            } else if let city = citySelection.selectedCity {
                TabView {
                    DashboardView(city: city) {
                        citySelection.clearSelection()
                        skippedGeolocation = false
                    }
                    .tabItem { Label(localizer.s(.tabDashboard), systemImage: "snowflake") }

                    SettingsView(selectedCity: city)
                        .tabItem { Label(localizer.s(.tabSettings), systemImage: "gearshape") }
                }
            } else if !skippedGeolocation {
                GeoLocatingView(
                    onResolved: { citySelection.select($0) },
                    onManualFallback: { skippedGeolocation = true }
                )
            } else {
                CitySelectionView(viewModel: citySelection) { _ in }
            }
        }
        .tint(themeManager.palette.primary)
    }
}
