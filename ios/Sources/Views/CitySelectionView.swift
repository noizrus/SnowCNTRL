import SwiftUI

struct CitySelectionView: View {
    @EnvironmentObject private var localizer: Localizer
    @ObservedObject var viewModel: CitySelectionViewModel
    var onSelect: (City) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.filteredCities.isEmpty {
                    ContentUnavailableFallback(text: localizer.s(.citySelectionEmptyState))
                } else {
                    List(viewModel.filteredCities) { city in
                        Button {
                            viewModel.select(city)
                            onSelect(city)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(city.name)
                                        .foregroundStyle(.primary)
                                    Text(localizer.provinceName(city.province))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                TierBadge(tier: city.tier)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: localizer.s(.citySelectionSearchPlaceholder))
            .navigationTitle(localizer.s(.citySelectionTitle))
        }
    }
}

/// `ContentUnavailableView` needs iOS 17; this keeps the app buildable
/// against the iOS 16 deployment target set in project.yml.
private struct ContentUnavailableFallback: View {
    let text: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(text)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
