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

    func load(city: City) async {
        isLoading = true
        result = await service.fetchStatus(for: city)
        isLoading = false
    }
}
