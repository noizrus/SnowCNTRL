import SwiftUI

/// The two main screens plus the always-available towed-car shortcut sit
/// behind this bar's buttons.
enum MainTab: Hashable {
    case dashboard
    case settings
}

/// Custom bottom bar standing in for the system tab bar: a plain
/// `.tabItem` icon can't carry a shadow, and the app's whole look leans on
/// neon glow (map buttons, status pill, theme picker), so the bar that's
/// visible on every screen should glow too. Sits as a `.safeAreaInset` so
/// both tabs' own content lays out above it exactly like it did above the
/// system tab bar. Same accent-colored background as the top navigation
/// bar (`themedNavigationBar`), so switching themes recolors both bars
/// together.
struct MainBottomBar: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var selectedTab: MainTab
    var onShowTowedHelp: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            tabButton(tab: .dashboard, systemImage: "snowflake", title: localizer.s(.tabDashboard))
            helpButton
            tabButton(tab: .settings, systemImage: "gearshape.fill", title: localizer.s(.tabSettings))
        }
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(barBackground)
    }

    private var barBackground: some View {
        Rectangle()
            .fill(themeManager.palette.accent)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(themeManager.palette.onAccent.opacity(0.15))
                    .frame(height: 0.5)
            }
            .ignoresSafeArea(edges: .bottom)
    }

    private func tabButton(tab: MainTab, systemImage: String, title: String) -> some View {
        let isSelected = selectedTab == tab
        let onAccent = themeManager.palette.onAccent
        return Button {
            selectedTab = tab
        } label: {
            barItem(
                systemImage: systemImage,
                title: title,
                color: isSelected ? onAccent : onAccent.opacity(0.5),
                glowRadius: isSelected ? 10 : 0,
                showsSelectionPill: isSelected
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    /// Always glowing, not just when active — it opens a sheet rather than
    /// selecting a tab, so there's no "selected" state to dim it against.
    /// No selection pill either, for the same reason: it never means "you
    /// are here" the way Alertes/Réglages do, so it must never look like it
    /// does.
    private var helpButton: some View {
        Button(action: onShowTowedHelp) {
            barItem(
                systemImage: "car.fill",
                title: localizer.s(.tabHelp),
                color: themeManager.palette.onAccent,
                glowRadius: 6,
                showsSelectionPill: false
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    /// The pill background is what actually answers "where am I" — relying
    /// on brightness/glow alone wasn't enough to tell the active tab apart
    /// from Aide, which glows all the time.
    private func barItem(systemImage: String, title: String, color: Color, glowRadius: CGFloat, showsSelectionPill: Bool) -> some View {
        VStack(spacing: 2) {
            Image(systemName: systemImage)
                .font(.system(size: 21, weight: .semibold))
            Text(title)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(color)
        .neonGlow(themeManager.palette.primary, radius: glowRadius)
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background {
            if showsSelectionPill {
                Capsule().fill(themeManager.palette.primary.opacity(0.22))
            }
        }
    }
}

struct MainBottomBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            MainBottomBar(selectedTab: .constant(.dashboard), onShowTowedHelp: {})
        }
        .background(Color.black)
        .environmentObject(Localizer())
        .environmentObject(ThemeManager())
    }
}
