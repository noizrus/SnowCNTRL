import SwiftUI

/// Branded splash shown for ~1s on cold start: the app logo pulsing in a
/// neon glow of the theme color, plus the wordmark. Shown as an overlay by
/// `RootView` before the real content appears. A loading bar makes clear
/// something is happening on a slow first launch (fresh install: location
/// permission prompt, GPS fix, first network fetch) rather than looking
/// stuck on the logo.
struct LaunchSplashView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizer: Localizer
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 22) {
                AppLogoImage(size: 132)
                    .neonGlow(themeManager.palette.primary, radius: isPulsing ? 16 : 7)
                    .scaleEffect(isPulsing ? 1.04 : 0.96)

                Text(localizer.language.appName)
                    .font(.system(.title2, design: .rounded).weight(.heavy))
                    .tracking(2)
                    .foregroundStyle(themeManager.palette.accentText)
                    .neonGlow(themeManager.palette.accent, radius: isPulsing ? 8 : 4)

                ProgressView()
                    .progressViewStyle(.linear)
                    .tint(themeManager.palette.primary)
                    .frame(maxWidth: 160)
                    .padding(.top, 4)
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
