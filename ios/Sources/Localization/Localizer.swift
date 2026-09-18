import Foundation
import Combine

/// Injected as an environment object; every view reads strings through it
/// so the whole UI reacts instantly when the user changes language.
final class Localizer: ObservableObject {
    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey) }
    }

    private static let storageKey = "snowcntrl.language"

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let saved = AppLanguage(rawValue: raw) {
            language = saved
        } else {
            language = AppLanguage.detectDefault()
        }
    }

    func s(_ key: LocKey) -> String {
        Strings.text(for: key, language: language)
    }

    func provinceName(_ province: ProvinceCode) -> String {
        province.displayName(for: language)
    }
}
