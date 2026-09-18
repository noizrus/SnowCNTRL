import Foundation

/// Full-length legal text. Kept separate from `Strings.swift` (short UI
/// copy) since these are long, versioned documents.
///
/// IMPORTANT: this is a solid starting draft, not a substitute for review by
/// a lawyer familiar with Quebec/Canadian privacy law (Law 25) before
/// shipping to the App Store.
enum LegalTexts {
    static func privacyPolicy(language: AppLanguage, contactEmail: String) -> String {
        switch language {
        case .french:
            return """
            Dernière mise à jour : 2026.

            SnowCNTRL est développée par un développeur indépendant. Cette politique explique \
            quelles informations l'application utilise et pourquoi.

            **Ce que l'app stocke sur ton appareil (jamais envoyé à un serveur)**
            - Ta ville et ta langue choisies.
            - L'adresse ou le repère que tu places sur la carte pour suivre ta rue, ainsi que \
            l'état de l'interrupteur d'alerte.
            - Tes préférences de notifications.

            Ces données restent uniquement sur ton téléphone (dans les préférences locales de \
            l'app). Il n'y a pas de compte utilisateur et pas de base de données centrale à ce \
            jour.

            **Localisation**
            Si tu utilises le bouton "utiliser ma position" sur la carte, l'app demande l'accès \
            à ta position au moment de l'utilisation seulement, pour centrer la carte. Cette \
            position n'est ni conservée après la fermeture de l'app, ni transmise ailleurs qu'à \
            Apple/MapKit pour afficher la carte.

            **Publicité**
            L'app affiche des publicités via Google AdMob dans sa version gratuite. AdMob peut \
            utiliser un identifiant publicitaire pour proposer des publicités pertinentes ; tu \
            peux limiter ce suivi dans les réglages de ton appareil (Réglages > Confidentialité \
            et sécurité > Publicité, ou via l'invite de suivi au premier lancement). Consulte la \
            politique de confidentialité de Google pour plus de détails sur leurs pratiques.

            **Données provenant de sources ouvertes**
            Pour certaines villes, l'app interroge les portails de données ouvertes municipaux \
            (ex. Ville de Montréal) afin d'afficher un statut. Aucune donnée personnelle n'est \
            envoyée dans ces requêtes.

            **Enfants**
            L'app ne s'adresse pas spécifiquement aux enfants et ne collecte pas sciemment de \
            renseignements les concernant.

            **Modifications**
            Cette politique peut être mise à jour ; la date ci-dessus reflète la dernière \
            révision.

            **Contact**
            Des questions sur tes données ? Écris à \(contactEmail).
            """
        case .english:
            return """
            Last updated: 2026.

            SnowCNTRL is built by an independent developer. This policy explains what \
            information the app uses and why.

            **What the app stores on your device (never sent to a server)**
            - Your chosen city and language.
            - The address or pin you place on the map to track your street, and the state of \
            its alert toggle.
            - Your notification preferences.

            This data stays on your phone only (in the app's local preferences). There is no \
            user account and no central database at this time.

            **Location**
            If you use the "use my location" button on the map, the app requests access to your \
            location only while in use, to center the map. That location is neither kept after \
            the app closes nor sent anywhere besides Apple/MapKit to render the map.

            **Advertising**
            The app shows ads via Google AdMob in its free version. AdMob may use an advertising \
            identifier to show relevant ads; you can limit this tracking in your device settings \
            (Settings > Privacy & Security > Advertising, or via the tracking prompt on first \
            launch). See Google's own privacy policy for details on their practices.

            **Open-data sources**
            For some cities, the app queries municipal open-data portals (e.g. City of Montreal) \
            to display a status. No personal data is sent in these requests.

            **Children**
            The app is not specifically directed at children and does not knowingly collect \
            information about them.

            **Changes**
            This policy may be updated; the date above reflects the latest revision.

            **Contact**
            Questions about your data? Email \(contactEmail).
            """
        case .spanish:
            return """
            Última actualización: 2026.

            SnowCNTRL está desarrollada por un desarrollador independiente. Esta política \
            explica qué información utiliza la aplicación y por qué.

            **Lo que la app guarda en tu dispositivo (nunca enviado a un servidor)**
            - Tu ciudad e idioma elegidos.
            - La dirección o el marcador que colocas en el mapa para seguir tu calle, y el \
            estado de su interruptor de alerta.
            - Tus preferencias de notificaciones.

            Estos datos permanecen únicamente en tu teléfono (en las preferencias locales de la \
            app). No existe cuenta de usuario ni base de datos central por el momento.

            **Ubicación**
            Si usas el botón "usar mi ubicación" en el mapa, la app solicita acceso a tu \
            ubicación solo durante el uso, para centrar el mapa. Esa ubicación no se conserva \
            después de cerrar la app ni se envía a ningún otro lugar salvo a Apple/MapKit para \
            mostrar el mapa.

            **Publicidad**
            La app muestra anuncios mediante Google AdMob en su versión gratuita. AdMob puede \
            usar un identificador publicitario para mostrar anuncios relevantes; puedes limitar \
            este seguimiento en los ajustes de tu dispositivo (Ajustes > Privacidad y seguridad > \
            Publicidad, o mediante el aviso de seguimiento en el primer inicio). Consulta la \
            política de privacidad de Google para más detalles.

            **Datos de fuentes abiertas**
            Para algunas ciudades, la app consulta los portales de datos abiertos municipales \
            (ej. Ciudad de Montreal) para mostrar un estado. No se envían datos personales en \
            estas solicitudes.

            **Menores**
            La app no está dirigida específicamente a menores y no recopila conscientemente \
            información sobre ellos.

            **Cambios**
            Esta política puede actualizarse; la fecha anterior refleja la última revisión.

            **Contacto**
            ¿Preguntas sobre tus datos? Escribe a \(contactEmail).
            """
        }
    }

    static func termsOfUse(language: AppLanguage, contactEmail: String) -> String {
        switch language {
        case .french:
            return """
            Dernière mise à jour : 2026.

            En utilisant SnowCNTRL, tu acceptes les conditions suivantes.

            **Nature du service**
            SnowCNTRL fournit des alertes indicatives sur les interdictions de stationnement \
            liées au déneigement. La fiabilité de ces alertes varie selon la ville — voir le \
            niveau de couverture affiché pour chaque ville dans l'app.

            **Ce n'est pas une garantie**
            Cette application ne remplace pas la vérification de la signalisation officielle sur \
            place. SnowCNTRL ne peut être tenue responsable des contraventions, remorquages ou \
            autres conséquences liées à une information erronée, absente ou périmée, quelle \
            qu'en soit la cause (donnée municipale incorrecte, retard de notification, bogue, \
            etc.).

            **Développeur indépendant**
            L'app est développée par un développeur indépendant, sans équipe de support dédiée. \
            Les délais de correction de bogues ou de mise à jour des données peuvent être plus \
            longs qu'avec une grande entreprise.

            **Fonctionnalités payantes**
            Une version sans publicité pourra être proposée pour un prix annuel affiché dans \
            l'app au moment de son lancement. Les achats sont gérés par Apple selon ses propres \
            conditions.

            **Modifications du service**
            Les fonctionnalités, la couverture des villes et ces conditions peuvent changer avec \
            le temps.

            **Droit applicable**
            Ces conditions sont régies par les lois de la province de Québec et les lois du \
            Canada applicables, sans donner effet aux principes de conflits de lois.

            **Contact**
            Questions ou plaintes : \(contactEmail).
            """
        case .english:
            return """
            Last updated: 2026.

            By using SnowCNTRL, you agree to the following terms.

            **Nature of the service**
            SnowCNTRL provides informational alerts about snow-clearing parking bans. The \
            reliability of these alerts varies by city — see the coverage level shown for each \
            city in the app.

            **Not a guarantee**
            This app does not replace checking official signage on site. SnowCNTRL cannot be \
            held responsible for tickets, towing, or other consequences linked to incorrect, \
            missing, or outdated information, regardless of cause (incorrect municipal data, \
            delayed notification, a bug, etc.).

            **Independent developer**
            The app is built by an independent developer, without a dedicated support team. \
            Bug fixes and data updates may take longer than with a large company.

            **Paid features**
            An ad-free version may be offered for an annual price shown in the app at launch. \
            Purchases are handled by Apple under its own terms.

            **Changes to the service**
            Features, city coverage, and these terms may change over time.

            **Governing law**
            These terms are governed by the laws of the province of Quebec and applicable \
            Canadian law, without giving effect to conflict-of-law principles.

            **Contact**
            Questions or complaints: \(contactEmail).
            """
        case .spanish:
            return """
            Última actualización: 2026.

            Al usar SnowCNTRL, aceptas los siguientes términos.

            **Naturaleza del servicio**
            SnowCNTRL ofrece alertas informativas sobre prohibiciones de estacionamiento por \
            remoción de nieve. La fiabilidad de estas alertas varía según la ciudad — consulta \
            el nivel de cobertura mostrado para cada ciudad en la app.

            **No es una garantía**
            Esta app no reemplaza la verificación de la señalización oficial en el lugar. \
            SnowCNTRL no puede ser responsable de multas, remolques u otras consecuencias \
            derivadas de información incorrecta, ausente o desactualizada, sea cual sea la causa \
            (datos municipales incorrectos, notificación retrasada, un error, etc.).

            **Desarrollador independiente**
            La app está desarrollada por un desarrollador independiente, sin un equipo de \
            soporte dedicado. Las correcciones de errores y actualizaciones de datos pueden \
            tardar más que con una gran empresa.

            **Funciones de pago**
            Se podrá ofrecer una versión sin anuncios por un precio anual mostrado en la app en \
            su lanzamiento. Las compras son gestionadas por Apple bajo sus propios términos.

            **Cambios en el servicio**
            Las funciones, la cobertura de ciudades y estos términos pueden cambiar con el \
            tiempo.

            **Ley aplicable**
            Estos términos se rigen por las leyes de la provincia de Quebec y las leyes \
            canadienses aplicables, sin dar efecto a los principios de conflicto de leyes.

            **Contacto**
            Preguntas o quejas: \(contactEmail).
            """
        }
    }
}
