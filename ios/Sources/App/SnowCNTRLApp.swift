import SwiftUI
import GoogleMobileAds
import UserNotifications

@main
struct SnowCNTRLApp: App {
    @StateObject private var localizer = Localizer()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var premiumManager = PremiumManager()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        BackgroundRefreshManager.register()
        // Must be set before launch finishes to receive notification actions.
        UNUserNotificationCenter.current().delegate = NotificationCoordinator.shared
        AlertNotifier.registerCategories(language: Localizer().language)
        TireChangeAdvisor.registerCategory(language: Localizer().language)
        CarConnectionMonitor.shared.startMonitoring()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(localizer)
                .environmentObject(themeManager)
                .environmentObject(premiumManager)
                .task {
                    await BackgroundRefreshManager.checkNow(language: localizer.language)
                }
                .onChange(of: localizer.language) { language in
                    AlertNotifier.registerCategories(language: language)
                    TireChangeAdvisor.registerCategory(language: language)
                }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                Task { await BackgroundRefreshManager.checkNow(language: localizer.language) }
            case .background:
                BackgroundRefreshManager.scheduleNext()
            default:
                break
            }
        }
    }
}
