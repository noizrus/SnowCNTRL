import Foundation

/// Small UserDefaults cache of the last fetched status, so a Siri Shortcut
/// invoked while the app is backgrounded can report something the moment it
/// wakes the app process, instead of a blank screen.
enum StatusCache {
    private static let key = "snowcntrl.lastStatus"

    struct Entry: Codable {
        let cityID: String
        let cityName: String
        let stateRawValue: String
        let updatedAt: Date
    }

    static func rawValue(for state: ParkingBanState) -> String {
        switch state {
        case .activeBanNow: return "activeBanNow"
        case .noActiveBan: return "noActiveBan"
        case .unknownNoData: return "unknownNoData"
        }
    }

    static func save(cityID: String, cityName: String, state: ParkingBanState) {
        let entry = Entry(cityID: cityID, cityName: cityName, stateRawValue: rawValue(for: state), updatedAt: Date())
        guard let data = try? JSONEncoder().encode(entry) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func load() -> Entry? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Entry.self, from: data)
    }
}
