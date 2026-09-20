import Foundation

/// Hand-curated, plain-language summaries of how each city's snow-clearing
/// parking ban typically works — a layer above the raw tier disclaimer,
/// for cities well-documented enough to explain simply. These are general
/// descriptions of the published system, not a live feed: always cross-check
/// current signage and the city's own source link.
enum CityRules {
    private static let table: [String: [AppLanguage: String]] = [
        "montreal": [
            .french: "Deux systèmes se superposent à Montréal : les panneaux « interdiction de stationner » temporaires (activés secteur par secteur pendant une opération de déneigement, avec remorquage possible) et le stationnement alterné hiver sur certaines rues résidentielles. Vérifie toujours le panneau devant ta voiture, pas seulement l'app.",
            .english: "Two systems overlap in Montreal: temporary \"no parking\" signs (turned on sector by sector during a snow-clearing operation, with towing possible) and alternating winter parking on some residential streets. Always check the sign in front of your car, not just this app.",
            .spanish: "En Montreal se superponen dos sistemas: las señales temporales de \"prohibido estacionar\" (activadas sector por sector durante una operación de remoción de nieve, con posible remolque) y el estacionamiento alterno de invierno en algunas calles residenciales. Verifica siempre la señal frente a tu auto, no solo esta app.",
        ],
        "quebec-city": [
            .french: "Québec active l'interdiction de stationner par zones lors des opérations de déneigement, annoncée à l'avance sur le site de la Ville. Certains secteurs ont aussi un stationnement de nuit interdit en hiver. Consulte le site officiel avant de te garer pour la nuit.",
            .english: "Quebec City activates parking bans by zone during snow-clearing operations, announced in advance on the City's site. Some sectors also have an overnight winter parking ban. Check the official site before parking for the night.",
            .spanish: "Quebec activa prohibiciones de estacionamiento por zona durante las operaciones de remoción de nieve, anunciadas con antelación en el sitio de la ciudad. Algunos sectores también tienen prohibición nocturna en invierno. Consulta el sitio oficial antes de estacionar por la noche.",
        ],
        "laval": [
            .french: "Laval interdit le stationnement de nuit (généralement 23h à 7h) durant l'hiver sur les rues concernées, en plus des interdictions ponctuelles lors des opérations de déneigement. Les règles précises varient par secteur.",
            .english: "Laval bans overnight parking (generally 11pm to 7am) during winter on affected streets, in addition to temporary bans during snow-clearing operations. Exact rules vary by sector.",
            .spanish: "Laval prohíbe el estacionamiento nocturno (generalmente de 23h a 7h) durante el invierno en las calles afectadas, además de las prohibiciones temporales durante las operaciones de remoción de nieve. Las reglas exactas varían por sector.",
        ],
        "longueuil": [
            .french: "Longueuil applique une interdiction de stationnement de nuit l'hiver sur plusieurs rues, avec des interdictions supplémentaires activées lors des opérations de déneigement. Vérifie la signalisation locale.",
            .english: "Longueuil applies an overnight winter parking ban on several streets, with additional bans activated during snow-clearing operations. Check local signage.",
            .spanish: "Longueuil aplica una prohibición nocturna de estacionamiento en invierno en varias calles, con prohibiciones adicionales activadas durante las operaciones de remoción de nieve. Verifica la señalización local.",
        ],
        "gatineau": [
            .french: "Gatineau interdit le stationnement de nuit l'hiver sur certaines rues et active des interdictions temporaires par secteur pendant le déneigement. Les avis sont publiés sur le site de la Ville.",
            .english: "Gatineau bans overnight winter parking on some streets and activates temporary bans by sector during snow-clearing. Notices are posted on the City's site.",
            .spanish: "Gatineau prohíbe el estacionamiento nocturno en invierno en algunas calles y activa prohibiciones temporales por sector durante la remoción de nieve. Los avisos se publican en el sitio de la ciudad.",
        ],
        "toronto": [
            .french: "Toronto interdit le stationnement de nuit (1h à 6h) du 1er décembre au 1er avril sur la plupart des rues, sauf indication contraire. Une interdiction renforcée peut s'ajouter lors d'une tempête majeure (« Major Snowstorm »).",
            .english: "Toronto bans overnight parking (1am–6am) from December 1 to April 1 on most streets unless signs say otherwise. A stricter ban can be added during a declared Major Snowstorm.",
            .spanish: "Toronto prohíbe el estacionamiento nocturno (1h–6h) del 1 de diciembre al 1 de abril en la mayoría de las calles, salvo indicación contraria. Se puede añadir una prohibición más estricta durante una tormenta de nieve importante declarada.",
        ],
        "ottawa": [
            .french: "Ottawa interdit le stationnement de nuit (1h à 7h) du 1er novembre au 1er avril sur les rues signalées, qu'il neige ou non. Certaines rues ont aussi une interdiction ponctuelle liée au déneigement.",
            .english: "Ottawa bans overnight parking (1am–7am) from November 1 to April 1 on signed streets, whether or not it's snowing. Some streets also have a temporary snow-clearing ban.",
            .spanish: "Ottawa prohíbe el estacionamiento nocturno (1h–7h) del 1 de noviembre al 1 de abril en las calles señalizadas, nieve o no. Algunas calles también tienen una prohibición temporal por remoción de nieve.",
        ],
        "calgary": [
            .french: "Calgary désigne des « Snow Routes » prioritaires où le stationnement est interdit après une chute de neige importante, jusqu'au déneigement complet. Les rues résidentielles suivent des règles locales affichées.",
            .english: "Calgary designates priority \"Snow Routes\" where parking is banned after a significant snowfall until fully cleared. Residential streets follow locally posted rules.",
            .spanish: "Calgary designa \"Snow Routes\" prioritarias donde el estacionamiento se prohíbe tras una nevada importante hasta que se complete la limpieza. Las calles residenciales siguen reglas locales señalizadas.",
        ],
        "edmonton": [
            .french: "Edmonton active un « Snow Route Parking Ban » sur les routes prioritaires après une tempête, généralement pour 24 à 48h. Suis les avis officiels, la durée varie selon la tempête.",
            .english: "Edmonton activates a \"Snow Route Parking Ban\" on priority routes after a storm, usually for 24–48 hours. Follow official notices — duration varies by storm.",
            .spanish: "Edmonton activa una \"Snow Route Parking Ban\" en las rutas prioritarias después de una tormenta, generalmente por 24 a 48 horas. Sigue los avisos oficiales — la duración varía según la tormenta.",
        ],
        "winnipeg": [
            .french: "Winnipeg impose une interdiction de stationnement de nuit l'hiver sur les rues signalées, plus des « Alternate Side Parking » et des interdictions ponctuelles sur les routes de déneigement prioritaires.",
            .english: "Winnipeg imposes an overnight winter parking ban on signed streets, plus alternate-side parking and temporary bans on priority snow routes.",
            .spanish: "Winnipeg impone una prohibición nocturna de estacionamiento en invierno en las calles señalizadas, además de estacionamiento en lados alternos y prohibiciones temporales en rutas prioritarias de remoción de nieve.",
        ],
        "halifax": [
            .french: "Halifax peut déclarer une interdiction de stationnement sur rue à l'échelle de la municipalité pendant une tempête, généralement annoncée quelques heures à l'avance par la Ville et les médias locaux.",
            .english: "Halifax can declare a municipality-wide on-street parking ban during a storm, usually announced a few hours ahead by the City and local media.",
            .spanish: "Halifax puede declarar una prohibición de estacionamiento en la calle a nivel municipal durante una tormenta, generalmente anunciada con algunas horas de antelación por la ciudad y los medios locales.",
        ],
        "dartmouth": [
            .french: "Dartmouth suit la même règle que Halifax (municipalité régionale d'Halifax) : une interdiction de stationnement sur rue peut être déclarée pour toute la région pendant une tempête.",
            .english: "Dartmouth follows the same rule as Halifax (Halifax Regional Municipality): an on-street parking ban can be declared region-wide during a storm.",
            .spanish: "Dartmouth sigue la misma regla que Halifax (municipalidad regional de Halifax): se puede declarar una prohibición de estacionamiento en la calle para toda la región durante una tormenta.",
        ],
        "sherbrooke": [
            .french: "Sherbrooke active des interdictions de stationnement par secteur lors des opérations de déneigement, en plus d'un stationnement de nuit réglementé l'hiver sur certaines rues.",
            .english: "Sherbrooke activates parking bans by sector during snow-clearing operations, in addition to regulated overnight winter parking on some streets.",
            .spanish: "Sherbrooke activa prohibiciones de estacionamiento por sector durante las operaciones de remoción de nieve, además de un estacionamiento nocturno regulado en invierno en algunas calles.",
        ],
    ]

    static func summary(for cityID: String, language: AppLanguage) -> String? {
        table[cityID]?[language] ?? table[cityID]?[.english]
    }
}
