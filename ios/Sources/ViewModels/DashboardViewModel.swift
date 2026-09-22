import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var result: CityStatusResult?

    private let service: CityStatusService

    init(service: CityStatusService = .shared) {
        self.service = service
    }

    func load(city: City, language: AppLanguage) async {
        isLoading = true
        let fetched = await service.fetchStatus(for: city)
        result = fetched
        StatusCache.save(cityID: city.id, cityName: city.name, state: fetched.state)
        LiveActivityManager.sync(cityName: city.name, languageRawValue: language.rawValue, state: fetched.state, updatedAt: Date())
        isLoading = false
    }
}
