import SwiftUI

struct ThemePalette {
    let name: String
    let primary: Color
    let accent: Color
}

extension ProvinceCode {
    /// Approximate colors inspired by each province/territory's flag —
    /// decorative branding, not an official reproduction.
    var flagPalette: ThemePalette {
        switch self {
        case .qc: return ThemePalette(name: "Québec", primary: Color(red: 0.02, green: 0.25, blue: 0.65), accent: .white)
        case .on: return ThemePalette(name: "Ontario", primary: Color(red: 0.78, green: 0.06, blue: 0.18), accent: Color(red: 0.90, green: 0.75, blue: 0.30))
        case .bc: return ThemePalette(name: "Colombie-Britannique", primary: Color(red: 0.0, green: 0.20, blue: 0.40), accent: Color(red: 0.95, green: 0.70, blue: 0.15))
        case .ab: return ThemePalette(name: "Alberta", primary: Color(red: 0.0, green: 0.13, blue: 0.36), accent: Color(red: 0.80, green: 0.15, blue: 0.15))
        case .mb: return ThemePalette(name: "Manitoba", primary: Color(red: 0.70, green: 0.08, blue: 0.13), accent: Color(red: 0.15, green: 0.45, blue: 0.25))
        case .sk: return ThemePalette(name: "Saskatchewan", primary: Color(red: 0.02, green: 0.42, blue: 0.22), accent: Color(red: 1.0, green: 0.84, blue: 0.0))
        case .nb: return ThemePalette(name: "Nouveau-Brunswick", primary: Color(red: 0.95, green: 0.78, blue: 0.16), accent: Color(red: 0.0, green: 0.20, blue: 0.45))
        case .ns: return ThemePalette(name: "Nouvelle-Écosse", primary: Color(red: 0.0, green: 0.18, blue: 0.42), accent: Color(red: 0.80, green: 0.15, blue: 0.15))
        case .nl: return ThemePalette(name: "Terre-Neuve-et-Labrador", primary: Color(red: 0.0, green: 0.24, blue: 0.52), accent: Color(red: 0.95, green: 0.70, blue: 0.15))
        case .pe: return ThemePalette(name: "Île-du-Prince-Édouard", primary: Color(red: 0.75, green: 0.10, blue: 0.15), accent: Color(red: 0.15, green: 0.45, blue: 0.25))
        case .yt: return ThemePalette(name: "Yukon", primary: Color(red: 0.02, green: 0.30, blue: 0.55), accent: Color(red: 0.15, green: 0.45, blue: 0.25))
        case .nt: return ThemePalette(name: "Territoires du Nord-Ouest", primary: Color(red: 0.02, green: 0.30, blue: 0.55), accent: Color(red: 0.95, green: 0.70, blue: 0.15))
        case .nu: return ThemePalette(name: "Nunavut", primary: Color(red: 0.02, green: 0.30, blue: 0.55), accent: Color(red: 0.95, green: 0.70, blue: 0.15))
        }
    }
}

enum AppTheme: String, Codable, CaseIterable, Identifiable, Hashable {
    case automatic
    case christmas
    case halloween

    var id: String { rawValue }

    func label(language: AppLanguage) -> String {
        switch (self, language) {
        case (.automatic, .french): return "Automatique (ma province)"
        case (.automatic, .english): return "Automatic (my province)"
        case (.automatic, .spanish): return "Automático (mi provincia)"
        case (.christmas, .french): return "Noël"
        case (.christmas, .english): return "Christmas"
        case (.christmas, .spanish): return "Navidad"
        case (.halloween, .french): return "Halloween"
        case (.halloween, .english): return "Halloween"
        case (.halloween, .spanish): return "Halloween"
        }
    }

    var seasonalPalette: ThemePalette? {
        switch self {
        case .automatic: return nil
        case .christmas: return ThemePalette(name: "Noël", primary: Color(red: 0.75, green: 0.05, blue: 0.12), accent: Color(red: 0.10, green: 0.45, blue: 0.20))
        case .halloween: return ThemePalette(name: "Halloween", primary: Color(red: 0.95, green: 0.45, blue: 0.0), accent: Color(red: 0.35, green: 0.05, blue: 0.55))
        }
    }
}
