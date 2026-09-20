import Foundation

enum LocKey: Hashable {
    case onboardingWelcomeTitle
    case onboardingIndependentDevNotice
    case onboardingLegalDisclaimer
    case onboardingAcceptButton
    case languagePickerTitle

    case citySelectionTitle
    case citySelectionSearchPlaceholder
    case citySelectionEmptyState
    case citySelectionChangeButton
    case myStreetAlertsCaption
    case myStreetPickPrompt
    case myStreetAddAnother
    case mapSaveButton
    case settingsPrivacyPolicy
    case settingsTermsOfUse
    case provincePickerTitle
    case onboardingProvincePrompt
    case settingsTheme
    case onboardingLocating
    case onboardingLocationFallback
    case onboardingProvinceRequired
    case onboardingCitiesPreviewTitle

    case dashboardRefreshButton
    case dashboardLoading
    case dashboardStatusActive
    case dashboardStatusInactive
    case dashboardStatusUnknown
    case dashboardLastUpdatedPrefix
    case dashboardLearnMore

    case tierLabel1
    case tierLabel2
    case tierLabel3
    case tierLabelNA
    case tierLabelUnverified
    case disclaimerTier1
    case disclaimerTier2
    case disclaimerTier3
    case disclaimerTierNA

    case tabDashboard
    case tabSettings

    case settingsTitle
    case settingsLanguage
    case settingsNotificationsToggle
    case settingsNotificationsSubtitle
    case settingsAboutHeader
    case settingsAboutBody
    case settingsContactPrefix
    case settingsPremiumComingSoonTitle
    case settingsPremiumComingSoonSubtitle
    case settingsVersionPrefix

    case nearbyParkingButton
    case nearbyParkingTitle
    case nearbyParkingSubtitle
    case nearbyParkingEmpty
    case nearbyParkingSearching
    case nearbyParkingOpenInMaps
    case nearbyParkingDistanceMeters
    case nearbyParkingDistanceKm

    case cityRulesButton
    case cityRulesTitle
    case cityRulesFooter
    case cityRulesUnavailable

    case verifiedButton
    case verifiedRecently

    case siriActiveBan
    case siriNoActiveBan
    case siriUnknown
    case siriNoAddressSaved
}

enum Strings {
    /// %CITY% and %EMAIL% are replaced by the caller where applicable.
    private static let table: [LocKey: [AppLanguage: String]] = [
        .onboardingWelcomeTitle: [
            .french: "Bienvenue",
            .english: "Welcome",
            .spanish: "Bienvenido",
        ],
        .onboardingIndependentDevNotice: [
            .french: "SnowCNTRL est développée par un développeur indépendant — pas une grande entreprise avec une équipe de support. Je fais de mon mieux pour que les alertes soient exactes et à jour, mais la fiabilité varie selon la ville. Il peut arriver qu'une alerte soit en retard, incomplète ou qu'un bug survienne.\n\nUn problème ? Écris-moi à %EMAIL% — je lis tous les messages personnellement.",
            .english: "SnowCNTRL is built by an independent developer — not a large company with a support team. I do my best to keep alerts accurate and up to date, but reliability varies by city. An alert may sometimes be late, incomplete, or a bug may occur.\n\nRan into a problem? Email me at %EMAIL% — I read every message personally.",
            .spanish: "SnowCNTRL está desarrollada por un desarrollador independiente, no por una gran empresa con equipo de soporte. Hago lo posible para que las alertas sean precisas y estén actualizadas, pero la fiabilidad varía según la ciudad. Puede ocurrir que una alerta llegue tarde, esté incompleta o que haya un error.\n\n¿Algún problema? Escríbeme a %EMAIL% — leo todos los mensajes personalmente.",
        ],
        .onboardingLegalDisclaimer: [
            .french: "Cette application fournit des alertes à titre indicatif seulement et ne remplace pas la vérification de la signalisation officielle. SnowCNTRL ne peut être tenue responsable des contraventions, remorquages ou autres conséquences liées à une information erronée, absente ou périmée.",
            .english: "This app provides alerts for informational purposes only and does not replace checking official signage. SnowCNTRL cannot be held responsible for tickets, towing, or other consequences linked to incorrect, missing, or outdated information.",
            .spanish: "Esta aplicación ofrece alertas únicamente a título informativo y no reemplaza la verificación de la señalización oficial. SnowCNTRL no puede ser responsable de multas, remolques u otras consecuencias derivadas de información errónea, ausente o desactualizada.",
        ],
        .onboardingAcceptButton: [
            .french: "J'ai lu et j'accepte",
            .english: "I have read and I accept",
            .spanish: "He leído y acepto",
        ],
        .languagePickerTitle: [
            .french: "Langue",
            .english: "Language",
            .spanish: "Idioma",
        ],
        .citySelectionTitle: [
            .french: "Choisir une ville",
            .english: "Choose a city",
            .spanish: "Elegir una ciudad",
        ],
        .citySelectionSearchPlaceholder: [
            .french: "Chercher une ville",
            .english: "Search a city",
            .spanish: "Buscar una ciudad",
        ],
        .citySelectionEmptyState: [
            .french: "Aucune ville ne correspond à ta recherche.",
            .english: "No city matches your search.",
            .spanish: "Ninguna ciudad coincide con tu búsqueda.",
        ],
        .citySelectionChangeButton: [
            .french: "Changer de ville",
            .english: "Change city",
            .spanish: "Cambiar de ciudad",
        ],
        .myStreetAlertsCaption: [
            .french: "Alertes activées",
            .english: "Alerts enabled",
            .spanish: "Alertas activadas",
        ],
        .myStreetPickPrompt: [
            .french: "Choisir ma rue sur la carte",
            .english: "Pick my street on the map",
            .spanish: "Elegir mi calle en el mapa",
        ],
        .myStreetAddAnother: [
            .french: "Ajouter une autre adresse",
            .english: "Add another address",
            .spanish: "Añadir otra dirección",
        ],
        .mapSaveButton: [
            .french: "Enregistrer",
            .english: "Save",
            .spanish: "Guardar",
        ],
        .settingsPrivacyPolicy: [
            .french: "Politique de confidentialité",
            .english: "Privacy Policy",
            .spanish: "Política de privacidad",
        ],
        .settingsTermsOfUse: [
            .french: "Conditions d'utilisation",
            .english: "Terms of Use",
            .spanish: "Términos de uso",
        ],
        .provincePickerTitle: [
            .french: "Province",
            .english: "Province",
            .spanish: "Provincia",
        ],
        .onboardingProvincePrompt: [
            .french: "Ta province",
            .english: "Your province",
            .spanish: "Tu provincia",
        ],
        .settingsTheme: [
            .french: "Thème",
            .english: "Theme",
            .spanish: "Tema",
        ],
        .onboardingLocating: [
            .french: "Localisation en cours…",
            .english: "Locating…",
            .spanish: "Localizando…",
        ],
        .onboardingLocationFallback: [
            .french: "Choisir ma ville manuellement",
            .english: "Pick my city manually",
            .spanish: "Elegir mi ciudad manualmente",
        ],
        .onboardingProvinceRequired: [
            .french: "Choisis ta province ci-dessus pour continuer",
            .english: "Pick your province above to continue",
            .spanish: "Elige tu provincia arriba para continuar",
        ],
        .onboardingCitiesPreviewTitle: [
            .french: "Villes disponibles, des plus fiables aux moins fiables",
            .english: "Available cities, from most to least reliable",
            .spanish: "Ciudades disponibles, de más a menos confiables",
        ],
        .dashboardRefreshButton: [
            .french: "Actualiser",
            .english: "Refresh",
            .spanish: "Actualizar",
        ],
        .dashboardLoading: [
            .french: "Vérification du statut…",
            .english: "Checking status…",
            .spanish: "Comprobando el estado…",
        ],
        .dashboardStatusActive: [
            .french: "Interdiction de stationner active",
            .english: "Parking ban currently active",
            .spanish: "Prohibición de estacionar activa",
        ],
        .dashboardStatusInactive: [
            .french: "Aucune interdiction en ce moment",
            .english: "No ban in effect right now",
            .spanish: "Sin prohibición en este momento",
        ],
        .dashboardStatusUnknown: [
            .french: "Statut inconnu — donnée non disponible",
            .english: "Status unknown — data unavailable",
            .spanish: "Estado desconocido — datos no disponibles",
        ],
        .dashboardLastUpdatedPrefix: [
            .french: "Mis à jour : ",
            .english: "Updated: ",
            .spanish: "Actualizado: ",
        ],
        .dashboardLearnMore: [
            .french: "Voir la source officielle",
            .english: "View official source",
            .spanish: "Ver la fuente oficial",
        ],
        .tierLabel1: [
            .french: "Donnée officielle en temps réel",
            .english: "Live official data",
            .spanish: "Datos oficiales en tiempo real",
        ],
        .tierLabel2: [
            .french: "Donnée municipale générale",
            .english: "General municipal data",
            .spanish: "Datos municipales generales",
        ],
        .tierLabel3: [
            .french: "Aucune donnée officielle",
            .english: "No official data",
            .spanish: "Sin datos oficiales",
        ],
        .tierLabelNA: [
            .french: "Pas de système de ban ici",
            .english: "No ban system here",
            .spanish: "Sin sistema de prohibición aquí",
        ],
        .tierLabelUnverified: [
            .french: "Couverture non vérifiée",
            .english: "Unverified coverage",
            .spanish: "Cobertura no verificada",
        ],
        .disclaimerTier1: [
            .french: "Basé sur les données ouvertes de %CITY%. Vérifiez toujours la signalisation sur place avant de stationner.",
            .english: "Based on %CITY%'s open data. Always check the signage on site before parking.",
            .spanish: "Basado en los datos abiertos de %CITY%. Verifica siempre la señalización en el lugar antes de estacionar.",
        ],
        .disclaimerTier2: [
            .french: "%CITY% ne publie pas de donnée en temps réel spécifique aux interdictions de stationnement. Vérifiez la signalisation sur place — l'exactitude à 100% n'est pas garantie.",
            .english: "%CITY% does not publish real-time data specific to parking bans. Check the signage on site — 100% accuracy is not guaranteed.",
            .spanish: "%CITY% no publica datos en tiempo real específicos sobre prohibiciones de estacionamiento. Verifica la señalización en el lugar — no se garantiza una exactitud del 100%.",
        ],
        .disclaimerTier3: [
            .french: "Aucune donnée officielle n'existe pour %CITY%. Ne vous fiez pas uniquement à cette app pour éviter une contravention — vérifiez toujours les panneaux ou le site de la ville.",
            .english: "No official data exists for %CITY%. Do not rely on this app alone to avoid a ticket — always check the signs or the city's website.",
            .spanish: "No existen datos oficiales para %CITY%. No confíes únicamente en esta app para evitar una multa — verifica siempre los letreros o el sitio web de la ciudad.",
        ],
        .disclaimerTierNA: [
            .french: "Aucune interdiction de stationnement liée au déneigement n'est en vigueur à %CITY%.",
            .english: "No snow-clearing parking ban is in effect in %CITY%.",
            .spanish: "No hay ninguna prohibición de estacionamiento por remoción de nieve vigente en %CITY%.",
        ],
        .tabDashboard: [
            .french: "Alertes",
            .english: "Alerts",
            .spanish: "Alertas",
        ],
        .tabSettings: [
            .french: "Réglages",
            .english: "Settings",
            .spanish: "Ajustes",
        ],
        .settingsTitle: [
            .french: "Réglages",
            .english: "Settings",
            .spanish: "Ajustes",
        ],
        .settingsLanguage: [
            .french: "Langue",
            .english: "Language",
            .spanish: "Idioma",
        ],
        .settingsNotificationsToggle: [
            .french: "Rappel quotidien",
            .english: "Daily reminder",
            .spanish: "Recordatorio diario",
        ],
        .settingsNotificationsSubtitle: [
            .french: "Reçois une notification pour vérifier le statut de ta ville.",
            .english: "Get a notification to check your city's status.",
            .spanish: "Recibe una notificación para verificar el estado de tu ciudad.",
        ],
        .settingsAboutHeader: [
            .french: "À propos",
            .english: "About",
            .spanish: "Acerca de",
        ],
        .settingsAboutBody: [
            .french: "SnowCNTRL est développée par un développeur indépendant. Merci de ta patience si une ville n'est pas encore bien couverte.",
            .english: "SnowCNTRL is built by an independent developer. Thanks for your patience if a city isn't fully covered yet.",
            .spanish: "SnowCNTRL está desarrollada por un desarrollador independiente. Gracias por tu paciencia si una ciudad aún no está bien cubierta.",
        ],
        .settingsContactPrefix: [
            .french: "Contact : ",
            .english: "Contact: ",
            .spanish: "Contacto: ",
        ],
        .settingsPremiumComingSoonTitle: [
            .french: "Version sans pub",
            .english: "Ad-free version",
            .spanish: "Versión sin anuncios",
        ],
        .settingsPremiumComingSoonSubtitle: [
            .french: "Bientôt disponible — 3,99 $ / an.",
            .english: "Coming soon — $3.99 / year.",
            .spanish: "Próximamente — 3,99 $ / año.",
        ],
        .settingsVersionPrefix: [
            .french: "Version ",
            .english: "Version ",
            .spanish: "Versión ",
        ],
        .nearbyParkingButton: [
            .french: "Où stationner ?",
            .english: "Where to park?",
            .spanish: "¿Dónde estacionar?",
        ],
        .nearbyParkingTitle: [
            .french: "Stationnements à proximité",
            .english: "Nearby parking",
            .spanish: "Estacionamientos cercanos",
        ],
        .nearbyParkingSubtitle: [
            .french: "Trouvé via Apple Plans — vérifie toujours les panneaux sur place avant de te garer.",
            .english: "Found via Apple Maps — always check the signage on site before parking.",
            .spanish: "Encontrado mediante Apple Maps — verifica siempre la señalización en el lugar antes de estacionar.",
        ],
        .nearbyParkingEmpty: [
            .french: "Aucun stationnement trouvé à proximité.",
            .english: "No parking found nearby.",
            .spanish: "No se encontró estacionamiento cercano.",
        ],
        .nearbyParkingSearching: [
            .french: "Recherche en cours…",
            .english: "Searching…",
            .spanish: "Buscando…",
        ],
        .nearbyParkingOpenInMaps: [
            .french: "Ouvrir dans Plans",
            .english: "Open in Maps",
            .spanish: "Abrir en Maps",
        ],
        .nearbyParkingDistanceMeters: [
            .french: "%d m",
            .english: "%d m",
            .spanish: "%d m",
        ],
        .nearbyParkingDistanceKm: [
            .french: "%.1f km",
            .english: "%.1f km",
            .spanish: "%.1f km",
        ],
        .cityRulesButton: [
            .french: "Comment ça marche ici",
            .english: "How it works here",
            .spanish: "Cómo funciona aquí",
        ],
        .cityRulesTitle: [
            .french: "Comment ça marche",
            .english: "How it works",
            .spanish: "Cómo funciona",
        ],
        .cityRulesFooter: [
            .french: "Résumé simplifié, à titre indicatif. Les règles peuvent changer — vérifie toujours la signalisation et la source officielle.",
            .english: "Simplified summary, for guidance only. Rules can change — always check the signage and the official source.",
            .spanish: "Resumen simplificado, solo a título informativo. Las reglas pueden cambiar — verifica siempre la señalización y la fuente oficial.",
        ],
        .cityRulesUnavailable: [
            .french: "Pas encore de résumé simplifié pour cette ville. Consulte la source officielle ci-dessous.",
            .english: "No simplified summary yet for this city. Check the official source below.",
            .spanish: "Aún no hay un resumen simplificado para esta ciudad. Consulta la fuente oficial abajo.",
        ],
        .verifiedButton: [
            .french: "J'ai vérifié sur place",
            .english: "I checked on site",
            .spanish: "Verifiqué en el lugar",
        ],
        .verifiedRecently: [
            .french: "Vérifié par toi",
            .english: "Checked by you",
            .spanish: "Verificado por ti",
        ],
        .siriActiveBan: [
            .french: "Interdiction de stationner active à %CITY%.",
            .english: "Parking ban currently active in %CITY%.",
            .spanish: "Prohibición de estacionar activa en %CITY%.",
        ],
        .siriNoActiveBan: [
            .french: "Aucune interdiction de stationner à %CITY% en ce moment.",
            .english: "No parking ban in %CITY% right now.",
            .spanish: "Sin prohibición de estacionar en %CITY% en este momento.",
        ],
        .siriUnknown: [
            .french: "Statut inconnu pour %CITY% — aucune donnée officielle disponible.",
            .english: "Status unknown for %CITY% — no official data available.",
            .spanish: "Estado desconocido para %CITY% — no hay datos oficiales disponibles.",
        ],
        .siriNoAddressSaved: [
            .french: "Ouvre SnowCNTRL et choisis une adresse pour activer cette commande.",
            .english: "Open SnowCNTRL and pick an address to enable this shortcut.",
            .spanish: "Abre SnowCNTRL y elige una dirección para activar este acceso directo.",
        ],
    ]

    static func text(for key: LocKey, language: AppLanguage) -> String {
        table[key]?[language] ?? table[key]?[.english] ?? ""
    }
}
