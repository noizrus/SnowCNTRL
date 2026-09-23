import SwiftUI

/// The app's logo (moose / snowflake / maple leaf) as a small rounded badge.
struct AppLogoImage: View {
    var size: CGFloat = 26

    var body: some View {
        Image("AppLogo")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 1.5, y: 0.5)
            .accessibilityHidden(true)
    }
}

/// The permanent brand shown at the top of every main screen: the logo plus
/// "NEIGE CNTRL" (French) or "SNOW CNTRL", glowing in the theme's primary
/// color. Always sits on the navigation bar's own accent-colored background
/// (see `themedNavigationBar`), so its text uses `onAccent` — the color
/// that contrasts with that exact background — rather than a variant tuned
/// for the plain system background.
struct SnowCntrlBrandmark: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizer: Localizer

    var body: some View {
        HStack(spacing: 8) {
            AppLogoImage(size: 40)
            Text(localizer.language.appName)
                .font(.system(.caption2, design: .rounded).weight(.heavy))
                .tracking(0.6)
                .lineLimit(1)
                .fixedSize()
                .foregroundStyle(themeManager.palette.onAccent)
                .neonGlow(themeManager.palette.primary, radius: 3)
        }
        .accessibilityElement(children: .combine)
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
