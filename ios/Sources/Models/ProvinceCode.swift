import Foundation

enum ProvinceCode: String, CaseIterable, Codable, Hashable {
    case qc, on, bc, ab, mb, sk, nb, ns, nl, pe, yt, nt, nu

    func displayName(for language: AppLanguage) -> String {
        switch (self, language) {
        case (.qc, .french): return "Québec"
        case (.qc, .english): return "Quebec"
        case (.qc, .spanish): return "Quebec"
        case (.on, .french): return "Ontario"
        case (.on, _): return "Ontario"
        case (.bc, .french): return "Colombie-Britannique"
        case (.bc, .english): return "British Columbia"
        case (.bc, .spanish): return "Columbia Británica"
        case (.ab, _): return "Alberta"
        case (.mb, _): return "Manitoba"
        case (.sk, _): return "Saskatchewan"
        case (.nb, .french): return "Nouveau-Brunswick"
        case (.nb, .english): return "New Brunswick"
        case (.nb, .spanish): return "Nuevo Brunswick"
        case (.ns, .french): return "Nouvelle-Écosse"
        case (.ns, .english): return "Nova Scotia"
        case (.ns, .spanish): return "Nueva Escocia"
        case (.nl, .french): return "Terre-Neuve-et-Labrador"
        case (.nl, .english): return "Newfoundland and Labrador"
        case (.nl, .spanish): return "Terranova y Labrador"
        case (.pe, .french): return "Île-du-Prince-Édouard"
        case (.pe, .english): return "Prince Edward Island"
        case (.pe, .spanish): return "Isla del Príncipe Eduardo"
        case (.yt, _): return "Yukon"
        case (.nt, .french): return "Territoires du Nord-Ouest"
        case (.nt, .english): return "Northwest Territories"
        case (.nt, .spanish): return "Territorios del Noroeste"
        case (.nu, _): return "Nunavut"
        }
    }
}
