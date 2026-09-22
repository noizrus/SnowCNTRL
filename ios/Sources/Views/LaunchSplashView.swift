import SwiftUI

/// Branded splash shown for ~1s on cold start. There's no static launch
/// image asset to keep in sync with the theme system, so this is a real
/// SwiftUI screen (pulsing neon snowflake + wordmark) shown as an overlay
/// by `RootView` before the real content appears.
struct LaunchSplashView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizer: Localizer
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 18) {
                Image(systemName: "snowflake")
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(themeManager.palette.primaryText)
                    .neonGlow(themeManager.palette.primary, radius: isPulsing ? 14 : 6)
                    .scaleEffect(isPulsing ? 1.08 : 0.92)

                Text(localizer.language.appName)
                    .font(.system(.title2, design: .rounded).weight(.heavy))
                    .tracking(2)
                    .foregroundStyle(themeManager.palette.accentText)
                    .neonGlow(themeManager.palette.accent, radius: isPulsing ? 8 : 4)
            }
        }
        // Always on black, so theme colors resolve to their night variants.
        .environment(\.colorScheme, .dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

struct LaunchSplashView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchSplashView()
            .environmentObject(ThemeManager())
            .environmentObject(Localizer())
    }
}
