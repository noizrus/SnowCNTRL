import SwiftUI

struct RootView: View {
    @EnvironmentObject private var localizer: Localizer
    @StateObject private var onboarding = OnboardingViewModel()
    @StateObject private var citySelection = CitySelectionViewModel()

    var body: some View {
        if !onboarding.hasAccepted {
            OnboardingView { onboarding.accept() }
        } else if let city = citySelection.selectedCity {
            TabView {
                DashboardView(city: city) {
                    citySelection.clearSelection()
                }
                .tabItem { Label(localizer.s(.tabDashboard), systemImage: "snowflake") }

                SettingsView(selectedCity: city)
                    .tabItem { Label(localizer.s(.tabSettings), systemImage: "gearshape") }
            }
        } else {
            CitySelectionView(viewModel: citySelection) { _ in }
        }
    }
}
