import Foundation
import Combine

/// Ad-free status. There's no in-app purchase yet (StoreKit comes later),
/// so the only way to turn it on today is the developer toggle in Settings,
/// which exists in Debug builds only — App Store builds start non-premium.
@MainActor
final class PremiumManager: ObservableObject {
    @Published var isPremium: Bool {
        didSet { UserDefaults.standard.set(isPremium, forKey: Self.storageKey) }
    }

    private static let storageKey = "snowcntrl.premium"

    init() {
        if UserDefaults.standard.object(forKey: Self.storageKey) != nil {
            isPremium = UserDefaults.standard.bool(forKey: Self.storageKey)
        } else {
            #if DEBUG
            isPremium = true
            #else
            isPremium = false
            #endif
        }
    }
}
