import SwiftUI

/// Matches Info-Neige MTL's own legend so users already familiar with it
/// aren't confused by different colors — rendered here in brighter,
/// glow-friendly variants of the same hues.
enum SnowClearingStatus: String, Codable, CaseIterable {
    case noParkingActive
    case planned
    case inProgress
    case snowCovered
    case cleared
    case awaitingInfo

    /// Base neon color used for the glow line on the map.
    var neonColor: Color {
        switch self {
        case .noParkingActive: return Color(red: 1.00, green: 0.16, blue: 0.24)
        case .planned: return Color(red: 1.00, green: 0.58, blue: 0.05)
        case .inProgress: return Color(red: 0.78, green: 0.22, blue: 1.00)
        case .snowCovered: return Color(red: 0.20, green: 0.55, blue: 1.00)
        case .cleared: return Color(red: 0.20, green: 1.00, blue: 0.45)
        case .awaitingInfo: return Color(red: 0.62, green: 0.65, blue: 0.70)
        }
    }

    func label(language: AppLanguage) -> String {
        switch (self, language) {
        case (.noParkingActive, .french): return "Interdiction active"
        case (.noParkingActive, .english): return "Ban active"
        case (.noParkingActive, .spanish): return "Prohibición activa"
        case (.planned, .french): return "Planifié"
        case (.planned, .english): return "Planned"
        case (.planned, .spanish): return "Planificado"
        case (.inProgress, .french): return "Chargement en cours"
        case (.inProgress, .english): return "Loading in progress"
        case (.inProgress, .spanish): return "Carga en curso"
        case (.snowCovered, .french): return "Enneigée"
        case (.snowCovered, .english): return "Snow-covered"
        case (.snowCovered, .spanish): return "Cubierta de nieve"
        case (.cleared, .french): return "Déneigée"
        case (.cleared, .english): return "Cleared"
        case (.cleared, .spanish): return "Despejada"
        case (.awaitingInfo, .french): return "En attente d'info"
        case (.awaitingInfo, .english): return "Awaiting info"
        case (.awaitingInfo, .spanish): return "Esperando información"
        }
    }
}
