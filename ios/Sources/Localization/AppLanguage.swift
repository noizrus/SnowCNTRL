import Foundation

enum AppLanguage: String, Codable, CaseIterable, Identifiable, Hashable {
    case french = "fr"
    case english = "en"
    case spanish = "es"

    var id: String { rawValue }

    var nativeName: String {
        switch self {
        case .french: return "Français"
        case .english: return "English"
        case .spanish: return "Español"
        }
    }

    /// The app's own wordmark translates too — "NEIGE CNTRL" in French,
    /// "SNOW CNTRL" otherwise. Shown in the brandmark and the launch splash.
    var appName: String {
        self == .french ? "NEIGE CNTRL" : "SNOW CNTRL"
    }

    static func detectDefault() -> AppLanguage {
        let preferred = Locale.preferredLanguages.first ?? "en"
        if preferred.hasPrefix("fr") { return .french }
        if preferred.hasPrefix("es") { return .spanish }
        return .english
    }
}
