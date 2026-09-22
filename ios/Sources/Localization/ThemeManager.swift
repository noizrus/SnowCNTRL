import Foundation
import Combine
import SwiftUI
import UIKit

@MainActor
final class ThemeManager: ObservableObject {
    @Published var selectedTheme: AppTheme {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: Self.themeKey) }
    }
    /// Follows the current city (see RootView) — drives the "Automatique"
    /// flag theme.
    @Published var province: ProvinceCode? {
        didSet { UserDefaults.standard.set(province?.rawValue, forKey: Self.provinceKey) }
    }
    @Published var appearance: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: Self.appearanceKey)
            applyAppearance()
        }
    }

    private static let themeKey = "snowcntrl.theme"
    private static let provinceKey = "snowcntrl.province"
    private static let appearanceKey = "snowcntrl.appearance"

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.themeKey), let theme = AppTheme(rawValue: raw) {
            selectedTheme = theme
        } else {
            selectedTheme = .automatic
        }
        if let raw = UserDefaults.standard.string(forKey: Self.provinceKey), let code = ProvinceCode(rawValue: raw) {
            province = code
        } else {
            province = nil
        }
        if let raw = UserDefaults.standard.string(forKey: Self.appearanceKey), let mode = AppearanceMode(rawValue: raw) {
            appearance = mode
        } else {
            appearance = .system
        }
    }

    var palette: ThemePalette {
        if let curated = selectedTheme.curatedPalette {
            return curated
        }
        return province?.flagPalette ?? ThemePalette(
            name: "SnowCNTRL",
            primary: Color(red: 0.85, green: 0.34, blue: 0.12),
            accent: Color(red: 0.85, green: 0.34, blue: 0.12)
        )
    }

    /// Applied on the windows themselves (not just SwiftUI's
    /// preferredColorScheme) so sheets and the MapKit map switch too.
    func applyAppearance() {
        for scene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            for window in scene.windows {
                window.overrideUserInterfaceStyle = appearance.interfaceStyle
            }
        }
    }
}
