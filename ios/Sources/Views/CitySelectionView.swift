import SwiftUI

/// The city list's title, brandmark and themed nav bar — shared by the
/// mandatory first-launch picker (`CitySelectionView` below, its own
/// `NavigationStack`) and Dashboard's "Changer de ville", which pushes
/// this straight into its own stack instead of presenting a sheet, so it
/// gets a normal back button and keeps the bottom bar visible underneath
/// instead of covering it the way a sheet would.
struct CityListScreen: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: CitySelectionViewModel
    var onPick: (City) -> Void

    var body: some View {
        CityListView(viewModel: viewModel, onPick: onPick)
            .navigationTitle(localizer.s(.citySelectionTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SnowCntrlBrandmark()
                }
            }
            .themedNavigationBar(themeManager.palette)
    }
}

struct CitySelectionView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: CitySelectionViewModel

    var body: some View {
        NavigationStack {
            CityListScreen(viewModel: viewModel) { city in
                viewModel.select(city)
            }
        }
        .tint(themeManager.palette.primaryText)
    }
}

/// Settings › default city: same list, a tap makes the city the one the
/// app opens on.
struct DefaultCityPickerView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: CitySelectionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        CityListView(viewModel: viewModel, checkedCityID: viewModel.favoriteCityID) { city in
            viewModel.setFavorite(city)
            dismiss()
        }
        .navigationTitle(localizer.s(.settingsDefaultCity))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.favoriteCityID != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizer.s(.settingsDefaultCityNone)) {
                        viewModel.setFavorite(nil)
                        dismiss()
                    }
                    .tint(themeManager.palette.onAccent)
                }
            }
        }
        .themedNavigationBar(themeManager.palette)
    }
}

struct CitySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CitySelectionView(viewModel: CitySelectionViewModel())
            .environmentObject(Localizer())
            .environmentObject(ThemeManager())
    }
}
