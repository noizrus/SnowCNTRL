import Foundation

enum LocKey: Hashable, CaseIterable {
    case onboardingWelcomeTitle
    case onboardingIndependentDevNotice
    case onboardingLegalDisclaimer
    case onboardingAcceptButton
    case languagePickerTitle

    case citySelectionTitle
    case citySelectionSearchPlaceholder
    case citySelectionEmptyState
    case citySelectionChangeButton
    case settingsPrivacyPolicy
    case settingsTermsOfUse
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
    case tabHelp
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

    case cityRulesButton
    case cityRulesTitle
    case cityRulesFooter
    case cityRulesUnavailable

    case siriActiveBan
    case siriNoActiveBan
    case siriUnknown
    case siriNoAddressSaved

    case dashboardStatusOffSeason
    case legendTitle
    case legendCityWideNote
    case mapLoadingStreets
    case mapLocateMe
    case panelToggle
    case settingsAppearance
    case mapToggleDayNight
    case settingsPremiumActive
    case settingsPremiumDebugToggle

    case infoButton
    case alertAddTitle
    case alertAddButton
    case alertReplaceButton
    case alertFreeLimit
    case alertCancel
    case alertRemove
    case alertTest
    case alertTestScheduled
    case alertsEmptyHint
    case alertsListHint
    case alertCardDescription
    case alertNotificationsDenied
    case notifBanTitle
    case notifBanBody
    case notifTestTitle
    case notifTestBody
    case notifActionMoved
    case notifActionSnooze
    case settingsSimulateBan
    case settingsSimulateBanHint
    case alertsListTitle
    case settingsAlertDuration
    case settingsAlertDurationHint

    case cityListFavorite
    case cityListNearest
    case cityListAll
    case cityListSetFavorite
    case settingsDefaultCity
    case settingsDefaultCityNone
    case settingsDefaultCityHint
    case helpTitle
    case helpMovedNearbyTip
    case helpFindMyCar
    case helpCityWebsite
    case helpContactsTitle
    case helpTowingLine
    case helpCityServices
    case helpPoliceNonEmergency
    case helpEmergency
    case helpNoVerifiedNumber
    case helpReportSignageIssue
    case helpSourceNote

    case tabWeather
    case weatherTitle
    case weatherLoading
    case weatherError
    case weatherSnowThisWeek
    case weatherSnowAmount
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
            .french: "NEIGE CNTRL est développée par un développeur indépendant — pas une grande entreprise avec une équipe de support. Je fais de mon mieux pour que les alertes soient exactes et à jour, mais la fiabilité varie selon la ville. Il peut arriver qu'une alerte soit en retard, incomplète ou qu'un bug survienne.\n\nUn problème ? Écris-moi à %EMAIL% — je lis tous les messages personnellement.",
            .english: "SnowCNTRL is built by an independent developer — not a large company with a support team. I do my best to keep alerts accurate and up to date, but reliability varies by city. An alert may sometimes be late, incomplete, or a bug may occur.\n\nRan into a problem? Email me at %EMAIL% — I read every message personally.",
            .spanish: "SnowCNTRL está desarrollada por un desarrollador independiente, no por una gran empresa con equipo de soporte. Hago lo posible para que las alertas sean precisas y estén actualizadas, pero la fiabilidad varía según la ciudad. Puede ocurrir que una alerta llegue tarde, esté incompleta o que haya un error.\n\n¿Algún problema? Escríbeme a %EMAIL% — leo todos los mensajes personalmente.",
        ],
        .onboardingLegalDisclaimer: [
            .french: "Cette application fournit des alertes à titre indicatif seulement et ne remplace pas la vérification de la signalisation officielle. NEIGE CNTRL ne peut être tenue responsable des contraventions, remorquages ou autres conséquences liées à une information erronée, absente ou périmée.",
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
        .tabHelp: [
            .french: "Aide",
            .english: "Help",
            .spanish: "Ayuda",
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
            .french: "NEIGE CNTRL est développée par un développeur indépendant. Merci de ta patience si une ville n'est pas encore bien couverte.",
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
            .french: "Ouvre NEIGE CNTRL et choisis une adresse pour activer cette commande.",
            .english: "Open SnowCNTRL and pick an address to enable this shortcut.",
            .spanish: "Abre SnowCNTRL y elige una dirección para activar este acceso directo.",
        ],
        .dashboardStatusOffSeason: [
            .french: "Hors saison — aucune opération de déneigement",
            .english: "Off season — no snow clearing operations",
            .spanish: "Fuera de temporada — sin operaciones de remoción de nieve",
        ],
        .legendTitle: [
            .french: "Légende",
            .english: "Legend",
            .spanish: "Leyenda",
        ],
        .legendCityWideNote: [
            .french: "Pour l'instant, chaque rue affiche le statut général de la ville — le détail côté par côté viendra avec les données officielles.",
            .english: "For now every street shows the city-wide status — side-by-side detail will come with official data.",
            .spanish: "Por ahora cada calle muestra el estado general de la ciudad — el detalle por lado llegará con los datos oficiales.",
        ],
        .mapLoadingStreets: [
            .french: "Chargement des rues…",
            .english: "Loading streets…",
            .spanish: "Cargando calles…",
        ],
        .mapLocateMe: [
            .french: "Ma position",
            .english: "My location",
            .spanish: "Mi ubicación",
        ],
        .panelToggle: [
            .french: "Afficher ou réduire le panneau",
            .english: "Show or collapse the panel",
            .spanish: "Mostrar u ocultar el panel",
        ],
        .settingsAppearance: [
            .french: "Mode jour / nuit",
            .english: "Day / night mode",
            .spanish: "Modo día / noche",
        ],
        .mapToggleDayNight: [
            .french: "Basculer jour / nuit",
            .english: "Switch day / night",
            .spanish: "Cambiar día / noche",
        ],
        .settingsPremiumActive: [
            .french: "Premium actif — sans publicité",
            .english: "Premium active — no ads",
            .spanish: "Premium activo — sin anuncios",
        ],
        .settingsPremiumDebugToggle: [
            .french: "Mode premium (test développeur)",
            .english: "Premium mode (developer test)",
            .spanish: "Modo premium (prueba de desarrollador)",
        ],
        .infoButton: [
            .french: "Informations et légende",
            .english: "Information and legend",
            .spanish: "Información y leyenda",
        ],
        .alertAddTitle: [
            .french: "Ajouter une alerte ici ?",
            .english: "Add an alert here?",
            .spanish: "¿Añadir una alerta aquí?",
        ],
        .alertAddButton: [
            .french: "Ajouter l'alerte",
            .english: "Add alert",
            .spanish: "Añadir alerta",
        ],
        .alertReplaceButton: [
            .french: "Remplacer mon alerte",
            .english: "Replace my alert",
            .spanish: "Reemplazar mi alerta",
        ],
        .alertFreeLimit: [
            .french: "Version gratuite : une alerte à la fois — celle-ci remplacera la précédente. Premium : alertes illimitées.",
            .english: "Free version: one alert at a time — this one will replace the previous one. Premium: unlimited alerts.",
            .spanish: "Versión gratuita: una alerta a la vez — esta reemplazará a la anterior. Premium: alertas ilimitadas.",
        ],
        .alertCancel: [
            .french: "Annuler",
            .english: "Cancel",
            .spanish: "Cancelar",
        ],
        .alertRemove: [
            .french: "Retirer",
            .english: "Remove",
            .spanish: "Quitar",
        ],
        .alertTest: [
            .french: "Tester le son",
            .english: "Test the sound",
            .spanish: "Probar el sonido",
        ],
        .alertTestScheduled: [
            .french: "Verrouille ton téléphone : l'alerte sonne dans 5 secondes.",
            .english: "Lock your phone: the alert rings in 5 seconds.",
            .spanish: "Bloquea tu teléfono: la alerta suena en 5 segundos.",
        ],
        .alertsEmptyHint: [
            .french: "Touche une rue sur la carte pour placer une alerte du côté où tu es garé.",
            .english: "Tap a street on the map to place an alert on the side where you're parked.",
            .spanish: "Toca una calle en el mapa para poner una alerta del lado donde estacionaste.",
        ],
        .alertsListHint: [
            .french: "Touche une alerte pour l'ouvrir · ✕ pour la retirer · touche une rue pour en ajouter",
            .english: "Tap an alert to open it · ✕ to remove it · tap a street to add one",
            .spanish: "Toca una alerta para abrirla · ✕ para quitarla · toca una calle para añadir",
        ],
        .alertCardDescription: [
            .french: "Ton téléphone sonnera (son de déneigeuse) dès qu'une opération de déneigement touche cette rue — même en mode Ne pas déranger.",
            .english: "Your phone will ring (snow truck sound) as soon as snow clearing reaches this street — even in Do Not Disturb.",
            .spanish: "Tu teléfono sonará (sonido de quitanieves) en cuanto la remoción de nieve llegue a esta calle — incluso en No molestar.",
        ],
        .alertNotificationsDenied: [
            .french: "Les notifications sont désactivées : active-les dans Réglages iOS › NEIGE CNTRL pour que l'alerte sonne.",
            .english: "Notifications are off: turn them on in iOS Settings › SNOW CNTRL so the alert can ring.",
            .spanish: "Las notificaciones están desactivadas: actívalas en Ajustes de iOS › SNOW CNTRL para que la alerta suene.",
        ],
        .notifBanTitle: [
            .french: "Déneigement : déplace ta voiture",
            .english: "Snow clearing: move your car",
            .spanish: "Remoción de nieve: mueve tu auto",
        ],
        .notifBanBody: [
            .french: "Interdiction de stationner en vigueur — %LABEL%. Le remorquage peut commencer.",
            .english: "Parking ban in effect — %LABEL%. Towing may begin.",
            .spanish: "Prohibición de estacionar vigente — %LABEL%. Puede comenzar el remolque.",
        ],
        .notifTestTitle: [
            .french: "Test d'alerte %APP%",
            .english: "%APP% alert test",
            .spanish: "Prueba de alerta %APP%",
        ],
        .notifTestBody: [
            .french: "Voici le son qui retentira lors d'une opération de déneigement — %LABEL%.",
            .english: "This is the sound you'll hear during a snow clearing operation — %LABEL%.",
            .spanish: "Este es el sonido que oirás durante una operación de remoción de nieve — %LABEL%.",
        ],
        .notifActionMoved: [
            .french: "J'ai déplacé ma voiture",
            .english: "I moved my car",
            .spanish: "Moví mi auto",
        ],
        .notifActionSnooze: [
            .french: "Rappelle-moi dans 10 min",
            .english: "Remind me in 10 min",
            .spanish: "Recuérdamelo en 10 min",
        ],
        .settingsSimulateBan: [
            .french: "Simuler une opération de déneigement (test)",
            .english: "Simulate a snow clearing operation (test)",
            .spanish: "Simular una operación de remoción de nieve (prueba)",
        ],
        .settingsSimulateBanHint: [
            .french: "Toutes les rues passent au rouge et tes alertes sonnent, comme lors d'une vraie opération.",
            .english: "Every street turns red and your alerts ring, like during a real operation.",
            .spanish: "Todas las calles se ponen en rojo y tus alertas suenan, como en una operación real.",
        ],
        .alertsListTitle: [
            .french: "Mes alertes",
            .english: "My alerts",
            .spanish: "Mis alertas",
        ],
        .settingsAlertDuration: [
            .french: "Durée de la sonnerie",
            .english: "Ring duration",
            .spanish: "Duración del timbre",
        ],
        .settingsAlertDurationHint: [
            .french: "Combien de temps le son du déneigement sonne quand une alerte se déclenche.",
            .english: "How long the snow-clearing sound rings when an alert fires.",
            .spanish: "Cuánto tiempo suena el sonido de remoción de nieve cuando se activa una alerta.",
        ],
        .cityListFavorite: [
            .french: "Ville par défaut",
            .english: "Default city",
            .spanish: "Ciudad predeterminada",
        ],
        .cityListNearest: [
            .french: "Les plus proches de toi",
            .english: "Nearest to you",
            .spanish: "Las más cercanas a ti",
        ],
        .cityListAll: [
            .french: "Toutes les villes",
            .english: "All cities",
            .spanish: "Todas las ciudades",
        ],
        .cityListSetFavorite: [
            .french: "Définir comme ville par défaut",
            .english: "Set as default city",
            .spanish: "Definir como ciudad predeterminada",
        ],
        .settingsDefaultCity: [
            .french: "Ville par défaut",
            .english: "Default city",
            .spanish: "Ciudad predeterminada",
        ],
        .settingsDefaultCityNone: [
            .french: "Aucune",
            .english: "None",
            .spanish: "Ninguna",
        ],
        .settingsDefaultCityHint: [
            .french: "L'app s'ouvre directement sur cette ville. Sans ville par défaut, elle rouvre la dernière ville consultée. Tu peux aussi toucher l'étoile dans la liste des villes.",
            .english: "The app opens straight on this city. Without a default city, it reopens the last city viewed. You can also tap the star in the city list.",
            .spanish: "La app se abre directamente en esta ciudad. Sin ciudad predeterminada, reabre la última ciudad consultada. También puedes tocar la estrella en la lista de ciudades.",
        ],
        .helpTitle: [
            .french: "Voiture remorquée ?",
            .english: "Car towed?",
            .spanish: "¿Auto remolcado?",
        ],
        .helpMovedNearbyTip: [
            .french: "Pendant le déneigement, les voitures sont souvent simplement déplacées dans une rue voisine : regarde d'abord autour, puis utilise le service de ta ville.",
            .english: "During snow clearing, cars are often just moved to a nearby street: look around first, then use your city's service.",
            .spanish: "Durante la remoción de nieve, los autos a menudo solo se mueven a una calle cercana: mira primero alrededor y luego usa el servicio de tu ciudad.",
        ],
        .helpFindMyCar: [
            .french: "Retrouver mon véhicule",
            .english: "Find my car",
            .spanish: "Encontrar mi vehículo",
        ],
        .helpCityWebsite: [
            .french: "Site officiel de la ville",
            .english: "City's official website",
            .spanish: "Sitio oficial de la ciudad",
        ],
        .helpContactsTitle: [
            .french: "Numéros utiles",
            .english: "Useful numbers",
            .spanish: "Números útiles",
        ],
        .helpTowingLine: [
            .french: "Info-remorquage",
            .english: "Towing info line",
            .spanish: "Información de remolque",
        ],
        .helpCityServices: [
            .french: "Services municipaux",
            .english: "City services",
            .spanish: "Servicios municipales",
        ],
        .helpPoliceNonEmergency: [
            .french: "Police (non urgent)",
            .english: "Police (non-emergency)",
            .spanish: "Policía (no urgente)",
        ],
        .helpEmergency: [
            .french: "Urgence seulement",
            .english: "Emergencies only",
            .spanish: "Solo emergencias",
        ],
        .helpNoVerifiedNumber: [
            .french: "Pas encore de numéro vérifié pour cette ville : contacte ta municipalité ou la police locale (ligne non urgente).",
            .english: "No verified number yet for this city: contact your municipality or the local police (non-emergency line).",
            .spanish: "Aún no hay un número verificado para esta ciudad: contacta a tu municipio o a la policía local (línea no urgente).",
        ],
        .helpReportSignageIssue: [
            .french: "Signaler un problème de signalisation à la ville",
            .english: "Report a signage issue to the city",
            .spanish: "Reportar un problema de señalización a la ciudad",
        ],
        .helpSourceNote: [
            .french: "Liens et numéros tirés des sites officiels des villes. En cas de doute, vérifie auprès de ta ville.",
            .english: "Links and numbers come from the cities' official websites. When in doubt, check with your city.",
            .spanish: "Los enlaces y números provienen de los sitios oficiales de las ciudades. En caso de duda, consulta con tu ciudad.",
        ],
        .tabWeather: [
            .french: "Météo",
            .english: "Weather",
            .spanish: "Clima",
        ],
        .weatherTitle: [
            .french: "Prévisions 7 jours",
            .english: "7-day forecast",
            .spanish: "Pronóstico a 7 días",
        ],
        .weatherLoading: [
            .french: "Chargement de la météo…",
            .english: "Loading weather…",
            .spanish: "Cargando el clima…",
        ],
        .weatherError: [
            .french: "Impossible de charger la météo pour l'instant.",
            .english: "Couldn't load the weather right now.",
            .spanish: "No se pudo cargar el clima por ahora.",
        ],
        .weatherSnowThisWeek: [
            .french: "Neige prévue cette semaine",
            .english: "Snow expected this week",
            .spanish: "Nieve prevista esta semana",
        ],
        .weatherSnowAmount: [
            .french: "%CM% cm",
            .english: "%CM% cm",
            .spanish: "%CM% cm",
        ],
    ]

    static func text(for key: LocKey, language: AppLanguage) -> String {
        translation(for: key, language: language) ?? translation(for: key, language: .english) ?? ""
    }

    /// The exact entry, without the English fallback.
    static func translation(for key: LocKey, language: AppLanguage) -> String? {
        table[key]?[language]
    }
}
