import SwiftUI

struct CitySelectionView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @ObservedObject var viewModel: CitySelectionViewModel

    var body: some View {
        NavigationStack {
            CityListView(viewModel: viewModel) { city in
                viewModel.select(city)
            }
            .navigationTitle(localizer.s(.citySelectionTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SnowCntrlBrandmark()
                }
            }
            .themedNavigationBar(themeManager.palette)
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
