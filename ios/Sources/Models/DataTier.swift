import SwiftUI

enum DataTier: String, Codable, CaseIterable, Hashable {
    case liveApi        // Niveau 1 - dataset/API dédié
    case openPortal     // Niveau 2 - portail open data général
    case noOpenData     // Niveau 3 - ban confirmé, aucune donnée ouverte
    case notApplicable  // Climat ne justifie pas le système
    case unverified     // Petite municipalité, non vérifiée individuellement

    var sortOrder: Int {
        switch self {
        case .liveApi: return 0
        case .openPortal: return 1
        case .noOpenData: return 2
        case .notApplicable: return 3
        case .unverified: return 4
        }
    }

    var color: Color {
        switch self {
        case .liveApi: return Color(red: 0.06, green: 0.48, blue: 0.32)
        case .openPortal: return Color(red: 0.58, green: 0.38, blue: 0.04)
        case .noOpenData: return Color(red: 0.69, green: 0.20, blue: 0.18)
        case .notApplicable: return Color(red: 0.18, green: 0.37, blue: 0.56)
        case .unverified: return Color(red: 0.35, green: 0.39, blue: 0.47)
        }
    }

    func label(for language: AppLanguage) -> String {
        Strings.text(for: labelKey, language: language)
    }

    func disclaimer(cityName: String, language: AppLanguage) -> String {
        let template = Strings.text(for: disclaimerKey, language: language)
        return template.replacingOccurrences(of: "%CITY%", with: cityName)
    }

    private var labelKey: LocKey {
        switch self {
        case .liveApi: return .tierLabel1
        case .openPortal: return .tierLabel2
        case .noOpenData: return .tierLabel3
        case .notApplicable: return .tierLabelNA
        case .unverified: return .tierLabelUnverified
        }
    }

    private var disclaimerKey: LocKey {
        switch self {
        case .liveApi: return .disclaimerTier1
        case .openPortal: return .disclaimerTier2
        case .noOpenData: return .disclaimerTier3
        case .notApplicable: return .disclaimerTierNA
        case .unverified: return .disclaimerTier3
        }
    }
}
