import SwiftUI
import GoogleMobileAds

@main
struct SnowCNTRLApp: App {
    @StateObject private var localizer = Localizer()

    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(localizer)
        }
    }
}
