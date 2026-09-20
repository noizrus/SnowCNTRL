import Foundation
import Combine
import SwiftUI

final class ThemeManager: ObservableObject {
    @Published var selectedTheme: AppTheme {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: Self.themeKey) }
    }
    @Published var province: ProvinceCode? {
        didSet { UserDefaults.standard.set(province?.rawValue, forKey: Self.provinceKey) }
    }

    private static let themeKey = "snowcntrl.theme"
    private static let provinceKey = "snowcntrl.province"

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
}
