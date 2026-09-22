import SwiftUI

/// Matches Info-Neige MTL's own 7-color legend exactly (same statuses, same
/// order) so users already familiar with it aren't confused — rendered here
/// in brighter, glow-friendly variants of the same hues.
enum SnowClearingStatus: String, Codable, CaseIterable {
    case snowCovered
    case planned
    case noParkingActive
    case inProgress
    case awaitingConfirmation
    case cleared
    case noOperation

    /// Base neon color used for the glow line on the map.
    var neonColor: Color {
        switch self {
        case .snowCovered: return Color(red: 0.20, green: 0.55, blue: 1.00)
        case .planned: return Color(red: 1.00, green: 0.58, blue: 0.05)
        case .noParkingActive: return Color(red: 1.00, green: 0.16, blue: 0.24)
        case .inProgress: return Color(red: 0.78, green: 0.22, blue: 1.00)
        case .awaitingConfirmation: return Color(red: 0.70, green: 1.00, blue: 0.55)
        case .cleared: return Color(red: 0.10, green: 0.95, blue: 0.35)
        case .noOperation: return Color(red: 0.62, green: 0.65, blue: 0.70)
        }
    }

    func label(language: AppLanguage) -> String {
        switch (self, language) {
        case (.snowCovered, .french): return "Enneigée"
        case (.snowCovered, .english): return "Snow-covered"
        case (.snowCovered, .spanish): return "Cubierta de nieve"
        case (.planned, .french): return "Planifié"
        case (.planned, .english): return "Planned"
        case (.planned, .spanish): return "Planificado"
        case (.noParkingActive, .french): return "Stationnement interdit"
        case (.noParkingActive, .english): return "No parking"
        case (.noParkingActive, .spanish): return "Prohibido estacionar"
        case (.inProgress, .french): return "En cours"
        case (.inProgress, .english): return "In progress"
        case (.inProgress, .spanish): return "En curso"
        case (.awaitingConfirmation, .french): return "En attente de confirmation"
        case (.awaitingConfirmation, .english): return "Awaiting confirmation"
        case (.awaitingConfirmation, .spanish): return "En espera de confirmación"
        case (.cleared, .french): return "Déneigée"
        case (.cleared, .english): return "Cleared"
        case (.cleared, .spanish): return "Despejada"
        case (.noOperation, .french): return "Aucune opération en cours"
        case (.noOperation, .english): return "No operation right now"
        case (.noOperation, .spanish): return "Sin operación en curso"
        }
    }
}
