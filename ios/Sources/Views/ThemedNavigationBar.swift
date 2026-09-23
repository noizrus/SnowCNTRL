import SwiftUI

extension View {
    /// Paints the navigation bar in the current theme's accent color (navy
    /// by default, matching the logo's background) instead of the plain
    /// system bar, and tells the system which way to draw its own chrome
    /// (default title text, back button) so it stays legible against it.
    /// Every main screen's top bar uses this, so picking a different theme
    /// recolors it too instead of leaving it stuck on one color.
    func themedNavigationBar(_ palette: ThemePalette) -> some View {
        self
            .toolbarBackground(palette.accent, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(
                ThemePalette.contrastingText(on: palette.accent) == .white ? .dark : .light,
                for: .navigationBar
            )
    }
}
