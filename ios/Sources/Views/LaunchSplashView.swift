import SwiftUI

/// Branded splash shown for ~3s on cold start (matching `RootView`'s splash
/// timer): the app logo pulsing in a neon glow of the theme color, the
/// wordmark, and a bar that fills over that same ~3s so it reads as an
/// actual loading step rather than a decorative pause — useful on a slow
/// first launch (fresh install: location permission prompt, GPS fix, first
/// network fetch). Shown as an overlay by `RootView` before the real
/// content appears.
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

                LoadingBar(color: themeManager.palette.primary, duration: RootView.splashDuration)
                    .frame(width: 160, height: 4)
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

/// Fills left to right once over `duration` — a `ProgressView` in `.linear`
/// style has no indeterminate mode on iOS (unlike the default spinner), it
/// just sits static, so this is drawn by hand instead.
private struct LoadingBar: View {
    let color: Color
    let duration: Double
    @State private var progress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(color.opacity(0.2))
                Capsule()
                    .fill(color)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .clipShape(Capsule())
        .onAppear {
            withAnimation(.linear(duration: duration)) {
                progress = 1
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
