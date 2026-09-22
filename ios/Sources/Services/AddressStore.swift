import Foundation
import Combine

/// Local-only persistence (UserDefaults + JSON) — no backend yet, but enough
/// to genuinely save and reload the user's pinned street(s) across launches.
final class AddressStore: ObservableObject {
    static let shared = AddressStore()

    @Published private(set) var addresses: [SavedAddress] {
        didSet { persist() }
    }

    private static let storageKey = "snowcntrl.savedAddresses"

    init() {
        if
            let data = UserDefaults.standard.data(forKey: Self.storageKey),
            let decoded = try? JSONDecoder().decode([SavedAddress].self, from: data)
        {
            // Drops duplicates saved before saving deduplicated them.
            var seen = Set<String>()
            addresses = decoded.filter { seen.insert("\($0.cityID)|\($0.label)").inserted }
        } else {
            addresses = []
        }
    }

    /// Adds a new address, or replaces the existing one with the same id
    /// (used when editing a previously saved pin).
    func upsert(_ address: SavedAddress) {
        if let index = addresses.firstIndex(where: { $0.id == address.id }) {
            addresses[index] = address
        } else {
            addresses.append(address)
        }
    }

    func remove(_ address: SavedAddress) {
        addresses.removeAll { $0.id == address.id }
    }

    func setAlertsEnabled(_ enabled: Bool, for address: SavedAddress) {
        guard let index = addresses.firstIndex(where: { $0.id == address.id }) else { return }
        addresses[index].alertsEnabled = enabled
    }

    func markVerified(_ address: SavedAddress) {
        guard let index = addresses.firstIndex(where: { $0.id == address.id }) else { return }
        addresses[index].lastVerifiedAt = Date()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(addresses) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
