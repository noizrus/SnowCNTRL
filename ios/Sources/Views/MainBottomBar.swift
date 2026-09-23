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
/// system tab bar.
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
            .fill(.bar)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 0.5)
            }
            .ignoresSafeArea(edges: .bottom)
    }

    private func tabButton(tab: MainTab, systemImage: String, title: String) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            selectedTab = tab
        } label: {
            barItem(
                systemImage: systemImage,
                title: title,
                color: isSelected ? themeManager.palette.primary : .secondary,
                glowRadius: isSelected ? 6 : 0
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    /// Always glowing, not just when active — it opens a sheet rather than
    /// selecting a tab, so there's no "selected" state to dim it against.
    private var helpButton: some View {
        Button(action: onShowTowedHelp) {
            barItem(
                systemImage: "car.fill",
                title: localizer.s(.tabHelp),
                color: themeManager.palette.primary,
                glowRadius: 6
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func barItem(systemImage: String, title: String, color: Color, glowRadius: CGFloat) -> some View {
        VStack(spacing: 2) {
            Image(systemName: systemImage)
                .font(.system(size: 21, weight: .semibold))
            Text(title)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(color)
        .neonGlow(color, radius: glowRadius)
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
