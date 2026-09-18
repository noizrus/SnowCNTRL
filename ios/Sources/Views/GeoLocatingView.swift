import SwiftUI
import CoreLocation

/// Shown right after onboarding: tries to auto-pick the user's city from
/// GPS instead of making them search for it. A manual fallback is always
/// visible immediately — permission can be denied, location can fail, or
/// the user might just not want to wait.
struct GeoLocatingView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var locationManager = LocationManager()
    var onResolved: (City) -> Void
    var onManualFallback: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
            Text(localizer.s(.onboardingLocating))
                .font(.headline)

            Button(localizer.s(.onboardingLocationFallback), action: onManualFallback)
                .font(.subheadline)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .tint(themeManager.palette.primary)
        .onAppear { locationManager.requestLocation() }
        .onReceive(locationManager.$lastLocation) { coordinate in
            guard let coordinate, let city = CityResolver.nearestCity(to: coordinate) else { return }
            onResolved(city)
        }
    }
}

struct GeoLocatingView_Previews: PreviewProvider {
    static var previews: some View {
        GeoLocatingView(onResolved: { _ in }, onManualFallback: {})
            .environmentObject(Localizer())
            .environmentObject(ThemeManager())
    }
}
