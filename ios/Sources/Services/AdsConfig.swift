import Foundation

/// Google's public test identifiers — they always serve a visible test ad,
/// with no AdMob account needed. Replace both with your real AdMob app id
/// and banner ad unit id before submitting to the App Store; using test ids
/// in a production build violates AdMob policy.
enum AdsConfig {
    static let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    /// Also set as GADApplicationIdentifier in project.yml — keep both in sync.
    static let appID = "ca-app-pub-3940256099942544~1458002511"
}
