import SwiftUI
import GoogleMobileAds

@main
struct SnowCNTRLApp: App {
    @StateObject private var localizer = Localizer()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        BackgroundRefreshManager.register()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(localizer)
                .task {
                    await BackgroundRefreshManager.checkNow(language: localizer.language)
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                BackgroundRefreshManager.scheduleNext()
            }
        }
    }
}
