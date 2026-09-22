import Foundation
import BackgroundTasks

/// Checks every saved address that has alerts enabled and lives in a city
/// with a live data integration (currently: Montreal only — see
/// MontrealOpenDataProvider). If a ban is active, fires a local notification.
///
/// iOS controls exactly when a BGAppRefreshTask actually runs — it is
/// opportunistic (network + battery permitting), never instant and never
/// guaranteed on a fixed schedule. That's normal background wake, not a
/// bug: for anything time-critical, the app's own foreground check
/// (`checkNow`, called on launch/foreground) is what fires reliably.
///
/// Testing in the simulator: Xcode's Debug menu → "Simulate Background App
/// Refresh" triggers this immediately instead of waiting on the real OS
/// scheduler.
enum BackgroundRefreshManager {
    static let taskIdentifier = "com.snowcntrl.app.refresh"

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            handle(task: task as! BGAppRefreshTask)
        }
    }

    static func scheduleNext() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // no earlier than 1h from now
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handle(task: BGAppRefreshTask) {
        scheduleNext() // keep the chain going regardless of this run's outcome

        let workItem = Task {
            await checkNow(language: Localizer().language)
            task.setTaskCompleted(success: true)
        }
        task.expirationHandler = { workItem.cancel() }
    }

    /// Also called on app launch/foreground so the alert isn't only
    /// best-effort background timing.
    static func checkNow(language: AppLanguage) async {
        let citiesByID = Dictionary(uniqueKeysWithValues: CitiesData.all.map { ($0.id, $0) })
        var stateByCity: [String: ParkingBanState] = [:]

        for address in AddressStore.shared.addresses where address.alertsEnabled {
            guard let city = citiesByID[address.cityID] else { continue }

            let state: ParkingBanState
            if let cached = stateByCity[city.id] {
                state = cached
            } else {
                state = await CityStatusService.shared.fetchStatus(for: city).state
                stateByCity[city.id] = state
            }

            switch state {
            case .activeBanNow:
                AlertNotifier.handleBanActive(for: address, language: language)
            case .noActiveBan:
                AlertNotifier.handleBanCleared(for: address.id)
            case .unknownNoData:
                // A failed check must not cancel reminders for a real ban.
                break
            }
        }
    }
}
