import AppIntents

/// "Dis Siri, est-ce qu'il y a une interdiction de stationner ?" — checks
/// the app's default/last-used city without opening the app, reusing the
/// exact same status source as the dashboard.
struct CheckBanStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Check parking ban status"
    static var description = IntentDescription("Checks whether a snow-clearing parking ban is active right now.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let language = Localizer().language
        guard let city = CitySelectionViewModel.currentCity else {
            return .result(dialog: IntentDialog(stringLiteral: Strings.text(for: .siriNoCity, language: language)))
        }

        let result = await CityStatusService.shared.fetchStatus(for: city)
        let statusText: String
        switch result.state {
        case .activeBanNow:
            statusText = Strings.text(for: .dashboardStatusActive, language: language)
        case .noActiveBan where result.isOffSeason:
            statusText = Strings.text(for: .dashboardStatusOffSeason, language: language)
        case .noActiveBan:
            statusText = Strings.text(for: .dashboardStatusInactive, language: language)
        case .unknownNoData:
            statusText = Strings.text(for: .dashboardStatusUnknown, language: language)
        }
        return .result(dialog: IntentDialog(stringLiteral: "\(city.name) : \(statusText)"))
    }
}

struct SnowCNTRLShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckBanStatusIntent(),
            phrases: [
                "Est-ce qu'il y a une interdiction de stationner dans \(.applicationName)",
                "Vérifie le stationnement avec \(.applicationName)",
                "Check the parking ban status in \(.applicationName)",
                "Is there a parking ban in \(.applicationName)",
            ],
            shortTitle: "Statut de stationnement",
            systemImageName: "car.fill"
        )
    }
}
