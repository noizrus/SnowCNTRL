import Foundation
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var hasAccepted: Bool {
        didSet { UserDefaults.standard.set(hasAccepted, forKey: Self.storageKey) }
    }

    private static let storageKey = "snowcntrl.onboarding.accepted"

    init() {
        hasAccepted = UserDefaults.standard.bool(forKey: Self.storageKey)
    }

    func accept() {
        hasAccepted = true
    }
}
