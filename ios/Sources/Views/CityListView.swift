import SwiftUI
import CoreLocation

/// City list shared by "change city" and Settings › default city: the
/// favorite city pinned on top, then every city from nearest to farthest
/// (alphabetical until the position is known), each with its distance and a
/// star to make it the city the app opens on.
struct CityListView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: CitySelectionViewModel
    @StateObject private var locationManager = LocationManager()
    /// Shows a checkmark on this city (the default-city picker).
    var checkedCityID: String? = nil
    var onPick: (City) -> Void

    var body: some View {
        let cities = viewModel.cities(sortedFrom: locationManager.lastLocation)
        Group {
            if cities.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(localizer.s(.citySelectionEmptyState))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if let favorite = viewModel.favoriteCity, viewModel.searchText.isEmpty {
                        Section(localizer.s(.cityListFavorite)) {
                            row(for: favorite)
                        }
                    }
                    Section(locationManager.lastLocation == nil ? localizer.s(.cityListAll) : localizer.s(.cityListNearest)) {
                        ForEach(cities) { city in
                            row(for: city)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: localizer.s(.citySelectionSearchPlaceholder))
        .onAppear { locationManager.requestLocation() }
    }

    private func row(for city: City) -> some View {
        let isFavorite = viewModel.favoriteCityID == city.id
        return HStack(spacing: 12) {
            // Both buttons are borderless so each one gets its own taps
            // inside the List row.
            Button {
                onPick(city)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(city.name)
                            .foregroundStyle(.primary)
                        HStack(spacing: 6) {
                            Text(localizer.provinceName(city.province))
                            if let distance = distanceText(to: city) {
                                Text("· \(distance)")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if checkedCityID == city.id {
                        Image(systemName: "checkmark")
                            .foregroundStyle(themeManager.palette.primaryText)
                    } else {
                        TierBadge(tier: city.tier)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)

            Button {
                viewModel.toggleFavorite(city)
            } label: {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundStyle(isFavorite ? Color.yellow : Color.secondary)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(localizer.s(.cityListSetFavorite))
        }
    }

    private func distanceText(to city: City) -> String? {
        guard let location = locationManager.lastLocation else { return nil }
        let meters = CityResolver.distance(from: location, to: city)
        if meters < 10_000 {
            return String(format: "%.1f km", meters / 1000)
        }
        return "\(Int((meters / 1000).rounded())) km"
    }
}
