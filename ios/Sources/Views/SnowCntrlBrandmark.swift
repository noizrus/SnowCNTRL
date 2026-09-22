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
/// "NEIGE CNTRL" (French) or "SNOW CNTRL", glowing in the theme's accent.
struct SnowCntrlBrandmark: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizer: Localizer

    var body: some View {
        HStack(spacing: 6) {
            AppLogoImage(size: 24)
            Text(localizer.language.appName)
                .font(.system(.caption2, design: .rounded).weight(.heavy))
                .tracking(0.6)
                .lineLimit(1)
                .fixedSize()
                .foregroundStyle(themeManager.palette.accentText)
                .neonGlow(themeManager.palette.accent, radius: 3)
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
