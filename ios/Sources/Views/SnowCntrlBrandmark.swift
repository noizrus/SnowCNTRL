import SwiftUI

/// The permanent wordmark shown top-left across the main screens — "SNOW
/// CNTRL", or "NEIGE CNTRL" when the app's language is French — glowing in
/// the current theme's accent color.
struct SnowCntrlBrandmark: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizer: Localizer

    var body: some View {
        Text(localizer.language.appName)
            .font(.system(.caption2, design: .rounded).weight(.heavy))
            .tracking(0.6)
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(themeManager.palette.accent)
            .neonGlow(themeManager.palette.accent, radius: 3)
    }
}

struct SnowCntrlBrandmark_Previews: PreviewProvider {
    static var previews: some View {
        SnowCntrlBrandmark()
            .padding()
            .background(Color.black)
            .environmentObject(ThemeManager())
            .environmentObject(Localizer())
    }
}
