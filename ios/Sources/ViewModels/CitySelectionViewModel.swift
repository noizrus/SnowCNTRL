import Foundation
import Combine

final class CitySelectionViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var selectedCity: City? {
        didSet {
            UserDefaults.standard.set(selectedCity?.id, forKey: Self.storageKey)
        }
    }

    private static let storageKey = "snowcntrl.selectedCityID"
    private let allCities = CitiesData.all.sorted { $0.name < $1.name }

    init() {
        if let id = UserDefaults.standard.string(forKey: Self.storageKey) {
            selectedCity = allCities.first { $0.id == id }
        }
    }

    var filteredCities: [City] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return allCities }
        let needle = searchText.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        return allCities.filter {
            $0.name.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(needle)
        }
    }

    func select(_ city: City) {
        selectedCity = city
    }

    func clearSelection() {
        selectedCity = nil
    }
}
