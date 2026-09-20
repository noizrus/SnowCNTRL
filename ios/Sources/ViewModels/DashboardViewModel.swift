import Foundation
import Combine
import WidgetKit

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
        WidgetSharedStatus.save(
            cityName: city.name,
            stateRawValue: StatusCache.rawValue(for: fetched.state),
            languageRawValue: language.rawValue
        )
        WidgetCenter.shared.reloadAllTimelines()
        LiveActivityManager.sync(cityName: city.name, languageRawValue: language.rawValue, state: fetched.state, updatedAt: Date())
        isLoading = false
    }
}
