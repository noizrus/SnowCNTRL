import AppIntents
import Foundation
import WidgetKit

/// "Hey Siri, check SnowCNTRL status" — reports the parking ban status for
/// the first saved address without requiring the app to be opened. Uses the
/// same providers as the dashboard, so it's exactly as accurate (and exactly
/// as limited to well-covered cities) as the app itself.
struct CheckSnowStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Parking Ban Status"
    static var description = IntentDescription("Checks the latest snow-clearing parking ban status for your saved address.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let language = Self.currentLanguage()

        guard
            let address = AddressStore.shared.addresses.first,
            let city = CitiesData.all.first(where: { $0.id == address.cityID })
        else {
            return .result(dialog: IntentDialog(stringLiteral: Strings.text(for: .siriNoAddressSaved, language: language)))
        }

        let result = await CityStatusService.shared.fetchStatus(for: city)
        StatusCache.save(cityID: city.id, cityName: city.name, state: result.state)
        WidgetSharedStatus.save(
            cityName: city.name,
            stateRawValue: StatusCache.rawValue(for: result.state),
            languageRawValue: language.rawValue
        )
        WidgetCenter.shared.reloadAllTimelines()

        let key: LocKey
        switch result.state {
        case .activeBanNow: key = .siriActiveBan
        case .noActiveBan: key = .siriNoActiveBan
        case .unknownNoData: key = .siriUnknown
        }
        let message = Strings.text(for: key, language: language).replacingOccurrences(of: "%CITY%", with: city.name)
        return .result(dialog: IntentDialog(stringLiteral: message))
    }

    private static func currentLanguage() -> AppLanguage {
        if let raw = UserDefaults.standard.string(forKey: "snowcntrl.language"), let lang = AppLanguage(rawValue: raw) {
            return lang
        }
        return AppLanguage.detectDefault()
    }
}

struct SnowCntrlShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckSnowStatusIntent(),
            phrases: [
                "Check \(.applicationName) status",
                "Ask \(.applicationName) if there's a parking ban",
                "Vérifie le statut avec \(.applicationName)",
                "Y a-t-il une interdiction de stationner avec \(.applicationName)",
            ],
            shortTitle: "Check status",
            systemImageName: "snowflake"
        )
    }
}
