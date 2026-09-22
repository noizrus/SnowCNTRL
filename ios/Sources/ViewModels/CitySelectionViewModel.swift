import Foundation
import Combine
import CoreLocation

final class CitySelectionViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var selectedCity: City? {
        didSet {
            UserDefaults.standard.set(selectedCity?.id, forKey: Self.storageKey)
        }
    }
    /// The city the app opens on at launch (set with the star in the city
    /// list or in Settings). Without one, the app reopens the last city.
    @Published private(set) var favoriteCityID: String? {
        didSet {
            UserDefaults.standard.set(favoriteCityID, forKey: Self.favoriteKey)
        }
    }

    private static let storageKey = "snowcntrl.selectedCityID"
    private static let favoriteKey = "snowcntrl.favoriteCityID"
    private let allCities = CitiesData.all

    init() {
        favoriteCityID = UserDefaults.standard.string(forKey: Self.favoriteKey)
        let startID = favoriteCityID ?? UserDefaults.standard.string(forKey: Self.storageKey)
        if let startID {
            selectedCity = allCities.first { $0.id == startID }
        }
    }

    var favoriteCity: City? {
        allCities.first { $0.id == favoriteCityID }
    }

    /// Cities matching the search, nearest to `location` first.
    func cities(sortedFrom location: CLLocationCoordinate2D?) -> [City] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        let matching: [City]
        if trimmed.isEmpty {
            matching = allCities
        } else {
            let needle = trimmed.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            matching = allCities.filter {
                $0.name.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(needle)
            }
        }
        return CityResolver.sortedByDistance(matching, from: location)
    }

    func select(_ city: City) {
        selectedCity = city
    }

    func clearSelection() {
        selectedCity = nil
    }

    func setFavorite(_ city: City?) {
        favoriteCityID = city?.id
    }

    func toggleFavorite(_ city: City) {
        favoriteCityID = favoriteCityID == city.id ? nil : city.id
    }
}
