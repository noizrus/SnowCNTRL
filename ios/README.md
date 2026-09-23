# SnowCNTRL — app iOS (MVP)

## Correction barre du haut trop large + logo encore agrandi (dernière itération)

- **Barre du haut anormalement haute dans Réglages** (et, moins visible, Onboarding
  et Sélection de ville) : ces trois écrans n'avaient pas
  `.navigationBarTitleDisplayMode(.inline)`, donc la barre retombait en mode
  « grand titre » — un bloc navy bien plus haut que prévu, réservé pour un titre
  qu'on ne voit jamais puisqu'il est remplacé par le bandeau logo, avec le contenu
  qui démarre juste en dessous sans marge (« collé »). Ajouté aux trois — la barre
  revient à la hauteur compacte standard, comme le Tableau de bord et les autres
  écrans qui l'avaient déjà.
- **Logo encore agrandi** (`SnowCntrlBrandmark`, `DashboardView`) : 32/34 → 40 pt
  partout, en gardant le mode `.inline` — la barre s'ajuste à son contenu sans
  revenir au bug du dessus.

## Barres du haut et du bas bleu marine, logo agrandi, thèmes qui changent tout (dernière itération)

- **Barre du haut bleu marine** (`ThemedNavigationBar.swift`, `themedNavigationBar(_:)`) :
  la barre de navigation de chaque écran (Onboarding, Réglages, Sélection de ville,
  Tableau de bord, Mes alertes, Aide, Comment ça marche ici, textes légaux) est
  maintenant peinte dans la couleur d'accent du thème actif — marine par défaut,
  comme le fond du logo — au lieu de la barre système transparente. La
  Géolocalisation n'a pas de vraie barre de navigation (pas de retour, pas
  d'empilement) : une barre marine du même style est simulée en haut de l'écran.
- **Barre du bas assortie** (`MainBottomBar.swift`) : même couleur d'accent que la
  barre du haut, pour que les deux se répondent visuellement.
- **Logo agrandi** dans le bandeau (`SnowCntrlBrandmark`, 24 → 32 pt) et dans le
  titre du Tableau de bord (30 → 34 pt).
- **Les thèmes changent vraiment tout maintenant** : comme la barre du haut, la
  barre du bas et le bandeau utilisent tous la couleur d'accent/primaire du thème
  actif (`ThemePalette.onAccent` pour le texte/les icônes, contraste calculé
  automatiquement en noir ou blanc selon la couleur), choisir un autre thème dans
  Réglages recolore désormais ces deux barres, pas seulement les boutons de la
  carte et la pastille de statut.

## Nouveau logo, thème par défaut, barre du bas néon (dernière itération)

- **Nouveau logo** (fond marine `#082340`, voiture/déneigeuse orange `#fb6600`,
  flocons blancs, feuille d'érable sur la lame) : remplace l'icône et le logo
  interne partout (`Assets.xcassets/AppIcon.appiconset` des deux cibles,
  `AppLogo.imageset` de l'app et du widget). Image déjà carrée et plate, pas de
  découpe de cadre nécessaire cette fois.
- **Thème par défaut = couleurs du logo, plus lié à la province** :
  `ThemePalette.brandDefault` (orange `#fb6600` / marine `#082340`, extraits du
  logo) remplace l'ancien orange générique. Le thème « Automatique » retourne
  maintenant toujours ce thème (`ThemeManager.palette`), au lieu de suivre la
  province choisie/géolocalisée. La province reste suivie (`syncProvince` dans
  `RootView`) uniquement pour l'aperçu des villes par province à l'onboarding —
  elle ne pilote plus aucune couleur de l'app.
- **Logo affiché en permanence, centré en haut, sur tous les écrans** :
  Onboarding, Réglages, Sélection de ville, Géolocalisation, Tableau de bord et
  **Mes alertes** ont tous le bandeau `SnowCntrlBrandmark` en position centrale
  (`.principal`) — avant, certains l'avaient en haut à gauche ou pas du tout.
- **Suppression facile dans Mes alertes** (`AlertsListView`) : chaque alerte a
  maintenant un bouton corbeille visible directement sur la ligne (en plus du
  glisser-pour-retirer existant), pour ne plus dépendre d'un geste caché.
- **Barre du bas personnalisée, néon** (`MainBottomBar.swift`) : remplace la
  barre d'onglets système (ses icônes ne peuvent pas briller). Alertes,
  Réglages et un nouveau bouton **Aide** (voiture remorquée, `car.fill`) —
  celui du milieu, toujours accessible peu importe la ville affichée. Les
  icônes s'allument en néon dans la couleur du thème (glow permanent sur
  Aide, glow à l'activation sur Alertes/Réglages). `RootView` garde les deux
  écrans vivants dans un `TabView` cachée (`.toolbar(.hidden, for: .tabBar)`)
  pour ne pas perdre la position de la carte en changeant d'onglet, et pose la
  barre custom en `.safeAreaInset` par-dessus.

## Voiture remorquée, ville par défaut, villes par distance (dernière itération)

- **« Voiture remorquée ? »** (`CityHelpView`, données dans `Data/CityHelp.swift`) :
  accessible depuis le panneau du bas et la carte « i ». Pour la ville affichée : bouton
  vers la page officielle pour retrouver son véhicule, numéros à appeler (touche = appel),
  911 pour les urgences seulement, et le rappel que les voitures sont souvent juste
  déplacées dans une rue voisine. Numéros et liens vérifiés sur les sites officiels pour
  Montréal (Info-remorquage 514 868-3737, 311), Québec (418 641-6666, 311), Laval,
  Longueuil, Trois-Rivières (police 819 691-2929), Toronto (police 416-808-2222, 311),
  Ottawa, Halifax/Dartmouth (police 902-490-5020, 311), Calgary, Edmonton, Winnipeg.
  Les autres villes renvoient vers leur site officiel, sans numéro inventé.
- **Ville par défaut** : l'étoile dans la liste des villes, ou Réglages › Ville par
  défaut. L'app s'ouvre directement dessus ; sans ville par défaut, elle rouvre la
  dernière ville consultée.
- **Liste des villes triée par distance** (`CityListView`) : la ville par défaut en haut,
  puis de la plus proche à la plus loin avec la distance affichée (ordre alphabétique
  tant que la position n'est pas connue).

## Logo permanent, widget refait, boussole (dernière itération)

- **Logo de l'app** (`Assets.xcassets/AppLogo.imageset`, découpé de l'icône sans le cadre
  métallique) : affiché en permanence en haut de la carte (logo + NEIGE CNTRL + ville),
  dans le bandeau des autres écrans (`SnowCntrlBrandmark`) et sur l'écran de chargement.
- **Widget refait** : fond sombre néon avec la couleur du thème, logo, statut dans les
  mêmes couleurs que la carte, « Hors saison », rue de ta première alerte, heure de mise
  à jour (moyen). Corrigé : double marge sur iOS 17+ qui tronquait le texte, galerie de
  widgets vide sans données, widget jamais mis à jour quand on ajoute/retire une alerte
  ou change de thème (`WidgetBridge`, republié dès que l'un d'eux change).
- **App Groups déclarés comme capacité** dans `project.yml` (`SystemCapabilities`) pour
  que la signature automatique enregistre vraiment `group.com.snowcntrl.app` — sans ce
  groupe, le widget ne reçoit aucune donnée (erreur `CFPrefsPlistSource` dans la console).
- **Boussole toujours visible** sous la colonne de boutons de la carte (celle du système
  n'apparaissait qu'une fois la carte tournée, et cachée sous la barre du haut).

## Panneau réduit par défaut, logo, durée de sonnerie (dernière itération)

- **Panneau du bas réduit par défaut** : seule la pastille de statut (ex. « Hors
  saison ») est visible à l'ouverture. La toucher (ou le chevron, ou glisser)
  déplie le reste — un petit chevron dans la pastille indique que c'est tapable.
  S'ouvre aussi automatiquement dès qu'on ajoute ou sélectionne une alerte.
- **Logo NEIGE CNTRL / SNOW CNTRL** : affiché en haut, centré au-dessus du nom de
  la ville (remplace le simple titre de navigation). Le bouton favoris ayant pris
  le coin supérieur gauche, le centre — libéré par des boutons devenus des icônes
  seules — avait la place pour ça sans se faire tronquer.
- **Durée de la sonnerie configurable** (`AlertRingDuration` + Réglages) : 5, 10
  (par défaut), 15 ou 20 secondes. Comme iOS joue un son de notification jusqu'au
  bout sans API pour l'interrompre, chaque durée a son propre fichier
  (`Resources/snowplow-5s.wav` … `snowplow-20s.wav`), généré à partir du vrai
  enregistrement fourni par l'utilisateur (tronqué avec fondu pour les durées
  courtes, bouclé avec fondu enchaîné pour les plus longues).

## Alignement sur Info-Neige : couleurs et favoris

D'après des captures de l'app Info-Neige envoyées par l'utilisateur :

- **Légende à 7 couleurs, identique à Info-Neige** (`SnowClearingStatus.swift`, en
  version néon) : Enneigée (bleu), Planifié (orange), Stationnement interdit (rouge),
  En cours (mauve), **En attente de confirmation (vert pâle — nouveau)**, Déneigée
  (vert vif), Aucune opération en cours (gris). L'ancien statut unique « en attente
  d'info » (gris) est renommé `noOperation` ; `awaitingConfirmation` (vert pâle) est
  nouveau et suit exactement la légende d'Info-Neige, distincte du vert de « Déneigée ».
- **Mes alertes en haut à gauche** (`AlertsListView.swift`), comme la liste de favoris
  d'Info-Neige : bouton avec un point si des alertes existent, ouvre la liste complète
  (glisser pour retirer, toucher pour centrer la carte et rouvrir la fiche). Sur cet
  écran, ce bouton remplace le bandeau « NEIGE CNTRL »/« SNOW CNTRL » (qui reste affiché
  sur les autres écrans : onboarding, réglages, sélection de ville, géolocalisation) —
  Info-Neige n'a pas de logo dans sa barre du haut, seulement sa liste de favoris.
- Pas encore repris d'Info-Neige : barre de recherche d'adresse et bouton bascule
  stationnements gratuits/payants — à ajouter si tu les veux.

## Alertes par témoin + son de déneigeuse

- **Toucher une rue = placer une alerte** : sur la carte principale, toucher un côté de
  rue affiche un témoin « + » le long du trottoir et une carte « Ajouter une alerte
  ici ? ». Une fois ajoutée, l'alerte est un témoin voiture ; le toucher ouvre sa fiche
  (Tester le son / Retirer). Les alertes se retirent aussi d'un ✕ dans la liste.
- **Gratuit : 1 alerte, Premium : illimité** (`AlertPolicy`). En gratuit, placer une
  nouvelle alerte propose de remplacer l'ancienne.
- **Sonnerie** (`Services/AlertNotifier.swift`) : son de déneigeuse (`Resources/snowplow.wav`,
  12 s, synthétisé : moteur de camion qui passe, klaxon d'avertissement, bips de recul,
  lame qui racle), niveau **Time Sensitive** pour passer à travers le mode Ne pas
  déranger / Concentration (entitlement dans `project.yml`), répété à 0, 10 et 20 min
  jusqu'à « J'ai déplacé ma voiture » (bouton dans la notification), avec
  « Rappelle-moi dans 10 min ». Limite : l'interrupteur sonnerie/silencieux de l'iPhone
  coupe quand même le son — seul l'entitlement Apple « Critical Alerts » (sur demande,
  accordé au cas par cas) le contourne.
- **Simulation** (builds Xcode seulement) : Réglages → « Simuler une opération de
  déneigement » : toutes les rues passent au rouge et chaque alerte sonne tout de
  suite, comme lors d'une vraie opération. « Tester le son » sur une alerte fait sonner
  la vraie notification 5 s plus tard (le temps de verrouiller le téléphone).
- **Ce qu'il manque pour de vraies alertes en production** : une vraie donnée de statut
  (le `resource_id` de Montréal est toujours à brancher) et un petit serveur qui
  surveille cette donnée et envoie des notifications push — iOS ne réveille une app en
  arrière-plan que quand il le décide, ce qui ne suffit pas pour une alerte fiable à
  l'heure près (c'est aussi comme ça que fonctionne Info-Neige).
- **Interface** : colonne de boutons alignée en haut à droite (changer de ville, ma
  position, jour/nuit, « i »). Le « i » ouvre la légende et « Comment ça marche ici ».
  « Où stationner ? » retiré. Texte d'avertissement sous le statut rendu lisible.
- **Tests** (`ios/Tests`, cible `SnowCNTRLTests`) : traductions FR/EN/ES complètes,
  limite gratuit/premium, hors saison, simulation, choix du côté de rue et position
  de la voiture, découpage des rues OpenStreetMap, contenu des notifications (son,
  Time Sensitive, répétitions), présence et durée du son, contraste des couleurs de
  tous les thèmes en jour et en nuit. À lancer dans Xcode avec **⌘U** (sur l'iPhone
  branché).

## Couleurs lisibles, jour/nuit, premium

- **Boutons aux couleurs du thème, toujours lisibles** : `ThemePalette` distingue
  maintenant la couleur brute du thème (remplissages, halos), une variante lisible
  sur fond jour/nuit (`primaryText`/`accentText`, ajustée automatiquement jusqu'à un
  contraste 4.5:1) et la couleur du contenu posé dessus (`onPrimary`, noir ou blanc
  selon le contraste). Les boutons principaux et ceux de la carte sont pleins, dans la
  couleur du thème (`ThemedFillButtonStyle`, `MapControlButton`).
- **Mode jour / nuit** : Réglages → Auto / Jour / Nuit, plus un bouton soleil/lune sur
  la carte. Appliqué aux fenêtres elles-mêmes, donc la carte et les feuilles suivent.
- **Province retirée des Réglages** : elle suit automatiquement la ville affichée
  (géolocalisée ou choisie) et ne sert qu'au thème « Automatique ».
- **Boutons des Réglages** : la grille des thèmes déclenchait tous ses boutons d'un
  coup (bug SwiftUI des boutons multiples dans une ligne de formulaire) — corrigé.
- **Premium** : `PremiumManager` retire la pub quand il est actif. Pas encore d'achat
  intégré (StoreKit) : dans les builds lancés depuis Xcode, un interrupteur « Mode
  premium (test développeur) » existe dans Réglages et il est activé par défaut. Il
  n'existe pas dans les builds App Store.

## Vraies rues + ergonomie

- **Les lignes suivent les vrais trottoirs** : la géométrie des rues vient maintenant
  d'OpenStreetMap (API Overpass, sans clé), chargée **sur le téléphone** par tuiles
  selon la zone visible (`Services/OSMStreetGeometryService.swift`). Chaque rue est
  découpée **îlot par îlot** aux intersections (comme Info-Neige), et chaque côté est
  dessiné le long de sa bordure : le décalage est calculé à l'affichage en points
  écran (`GlowPolylineRenderer`), donc les deux lignes restent sur les bords de la
  route dessinée à tous les niveaux de zoom. Au-delà d'un certain dézoom, un message
  invite à zoomer (trop dense et trop lourd à charger).
- **Couleur des lignes** : pour l'instant, chaque côté prend le statut général de la
  ville (aucun flux officiel par côté de rue n'est branché — c'est le point d'entrée
  pour Planif-Neige, voir `SnowSegmentService`). La légende le dit explicitement.
- **Hors saison** : de mai à septembre (juin à août dans les territoires), aucune
  ville ne fait d'opération de déneigement — le statut affiche « Hors saison » et
  toutes les rues sont vertes (`CityStatusService.isOffSeason`).
- **Choisir son côté de rue** : dans « Choisir ma rue », on zoome puis on touche le
  côté où l'on se gare ; la voiture est placée le long de ce trottoir et le libellé
  indique le côté (« Rue Saint-Denis — côté est »). Les côtés enregistrés sont
  surlignés en blanc sur la carte principale.
- **Panneau abaissable** : poignée, chevron ou glissement vers le bas pour réduire le
  panneau au seul statut (et à la pub), vers le haut pour le rouvrir.
- **Ergonomie de la carte** : bouton « ma position », bouton légende des couleurs,
  points d'intérêt réduits (transports, stationnements) pour une carte plus lisible,
  marqueurs voiture qui ne se réaniment plus à chaque déplacement.
- **Favoris** : toucher un favori centre la carte dessus ; appui long → Modifier,
  J'ai vérifié, Supprimer. Les doublons déjà enregistrés sont nettoyés au lancement.
- **À faire avant un lancement à grande échelle** : les serveurs Overpass publics sont
  limités ; pointer `OverpassClient.endpoints` vers une instance auto-hébergée ou un
  fournisseur payant.

## Corrections suite au premier vrai test sur iPhone

Premier retour visuel après un build réussi sur iPhone 13 :

- **Bandeau "SNOW CNTRL" moche/tronqué** : la police était trop grande pour l'espace
  du bandeau de navigation, partagé avec le titre de ville + le bouton "Changer de
  ville" — d'où le "SN…" tronqué qui, avec le glow empilé dessus, ressemblait à une
  bulle. Corrigé : police plus compacte (`SnowCntrlBrandmark.swift`) + le bouton
  "Changer de ville" est maintenant une simple icône (`mappin.and.ellipse`) au lieu
  d'un texte, ce qui libère la place.
- **Lignes de rue "qui n'ont aucun sens"** : d'abord corrigé pour utiliser une seule
  couleur cohérente au lieu d'un arc-en-ciel arbitraire — mais le vrai problème était
  plus profond : cette grille de rues était **entièrement fabriquée** (un quadrillage
  généré autour de l'adresse), sans aucun rapport avec les vraies rues de Montréal. Une
  fois la couleur uniformisée, le décalage avec la vraie carte devenait encore plus
  visible/confus. `MontrealSnowSegmentProvider` ne génère donc plus cette grille du
  tout — elle retourne une liste vide, comme les 113 autres villes, en attendant la
  vraie géométrie (voir le TODO dans `Services/SnowSegmentProviding.swift`). Mieux vaut
  une carte sans lignes qu'une carte avec de fausses lignes qui donnent l'impression
  d'être des vraies rues.
- **Favoris en double / pas d'espace dédié** : `DashboardView.saveAddress` retire
  maintenant tout doublon (même libellé, même ville) avant d'enregistrer. Les adresses
  enregistrées s'affichent sur la carte avec une icône de **voiture** (`car.fill`) au
  lieu du repère générique — c'est l'endroit où tu es garé, pas juste un point.
- **Sélection au point plutôt qu'au côté de rue complet** : `AddressMapView` "aimante"
  un tap près d'une ligne de rue (< 25 m) et sélectionne **tout ce côté** (contour
  blanc), comme sur Info-Neige, au lieu de placer un point à l'endroit exact du doigt.
  Le code est prêt et attend simplement qu'il y ait des lignes de rue à aimanter —
  puisque `MontrealSnowSegmentProvider` ne fabrique plus de fausse grille (voir juste
  au-dessus), ça retombe partout sur le pin classique pour l'instant. Ça s'activera
  automatiquement dès que la vraie géométrie sera branchée.
- **Bannière pub mal cadrée** : elle prenait toute la largeur du panneau alors que le
  format `GADAdSizeBanner` est fixe (320×50) — corrigé en la centrant avec une largeur
  explicite au lieu de l'étirer.
- **Écran de chargement avec logo** : `LaunchSplashView.swift`, affiché ~1s au
  lancement (flocon + "SNOW CNTRL" qui pulsent dans le thème actif), avant le vrai
  contenu — géré dans `RootView.swift`.

## Générer et ouvrir le projet

Sur un Mac avec Xcode installé :

```bash
brew install xcodegen
cd ios
xcodegen generate
open SnowCNTRL.xcodeproj
```

Xcode va résoudre la dépendance Swift Package (Google Mobile Ads SDK) au premier
build — ça peut prendre une minute.

### Nouveau : cible Widget — signature à refaire pour DEUX cibles

Ce projet a maintenant deux cibles : `SnowCNTRL` (l'app) et
`SnowCNTRLWidgetExtension` (le widget écran d'accueil/verrouillage). Après un
`xcodegen generate`, Xcode va probablement demander une équipe de signature
pour **les deux** (comme pour l'app seule avant) :

1. Sélectionne le projet `SnowCNTRL` dans le navigateur > onglet **Signing &
   Capabilities**.
2. Fais-le pour **chaque cible** dans le sélecteur en haut (`SnowCNTRL` puis
   `SnowCNTRLWidgetExtension`) : coche "Automatically manage signing" et
   choisis ton équipe (Cyril Bondiguet).
3. Les deux cibles ont maintenant la capacité **App Groups**
   (`group.com.snowcntrl.app`) pour partager le dernier statut connu entre
   l'app et le widget. Si Xcode affiche une erreur du genre "no App Groups
   found", clique sur le bouton pour qu'Xcode crée/enregistre le groupe
   automatiquement avec ton compte développeur (nécessite d'être connecté à
   ton Apple ID dans Xcode > Settings > Accounts).

## Ce qui est fonctionnel dès maintenant

- Onboarding avec choix de langue (FR/EN/ES) et acceptation des disclaimers.
- Sélection parmi les 114 villes déjà cartographiées, avec badge de niveau de donnée.
- Tableau de bord : statut (actif / inactif / inconnu selon le niveau), disclaimer
  contextuel, lien vers la source officielle si disponible.
- Rappel quotidien local (notification), sans backend.
- Bannière publicitaire AdMob fonctionnelle avec les **identifiants de test publics
  de Google** — une vraie pub de test s'affiche dès le premier lancement.
- Réglages : langue, rappel, à propos / contact, ligne "version sans pub" désactivée
  (prévue plus tard, cohérent avec le plan freemium d'abord).
- **Carte colorée pour choisir sa rue** : dans le tableau de bord, "Choisir ma rue sur
  la carte" ouvre une vraie carte (MapKit) — cherche une adresse, dépose/déplace un
  repère en tapant sur la carte, ou utilise ta position actuelle. L'adresse choisie
  est sauvegardée (localement, sans compte) avec un interrupteur d'alerte.
- **Notification "déneigement programmé"** : pour une adresse dans une ville à donnée
  live (Montréal pour l'instant), l'app vérifie le statut au lancement/premier plan
  et via une tâche d'arrière-plan (`BGAppRefreshTask`), et envoie une notification si
  une interdiction est active. Pour les autres villes, l'alerte retombe sur le rappel
  quotidien générique (puisqu'il n'y a pas de donnée en temps réel à vérifier).
- **Géolocalisation au premier lancement** : après l'onboarding, l'app essaie de
  détecter automatiquement la ville la plus proche par GPS plutôt que de forcer une
  recherche manuelle (`GeoLocatingView`). Un bouton "Choisir ma ville manuellement"
  reste toujours visible en cas de refus de permission ou d'échec.
- **Lignes de rue lumineuses (style Info-Neige)** : sur la carte, chaque côté de rue
  peut s'afficher en ligne néon colorée selon le statut — rouge (interdiction active),
  orange (planifié), mauve (chargement en cours), bleu (enneigée), vert (déneigée),
  gris (en attente), les mêmes codes que Info-Neige MTL. Rendu via un
  `MKOverlayRenderer` maison (`GlowPolylineRenderer`) avec halo flou + trait vif.
  **Important** : comme pour le statut général, aucune géométrie de rue réelle n'a pu
  être obtenue (même blocage `donnees.montreal.ca`). Une première version affichait une
  grille de rues d'exemple générée autour du point choisi, mais elle ne correspondait
  pas aux vraies rues sur la carte (repéré lors du premier test sur iPhone) — donc
  `MontrealSnowSegmentProvider` n'affiche plus rien pour l'instant, comme les 113
  autres villes, plutôt que des lignes trompeuses. Voir les commentaires dans
  `Sources/Services/SnowSegmentProviding.swift` pour brancher les vraies données une
  fois le `resource_id` obtenu.
- **Carte "mutedStandard"** : style de carte désaturé (au lieu du standard MapKit) pour
  que les lignes néon ressortent davantage — pas de service de tuiles personnalisé
  (Mapbox, etc.), donc aucun coût ni clé API supplémentaire pour l'instant.
- **Thèmes de couleurs** : un thème par province/territoire inspiré de son drapeau
  (appliqué automatiquement selon la province choisie), plus deux thèmes saisonniers
  (Noël, Halloween) sélectionnables dans Réglages. Les couleurs de niveau de donnée
  (vert/jaune/rouge) restent séparées du thème décoratif — jamais changées par le thème,
  pour ne pas brouiller leur sens.
- **Réglages étendus** : langue, province (grille colorée par drapeau) et thème sont
  modifiables à tout moment dans l'onglet Réglages, pas seulement à l'onboarding.
- **10 thèmes néon + brandmark permanent** : `ThemeGridPicker` propose ~10 thèmes
  (automatique par province, thèmes néon curatés, Noël, Halloween). "SNOW CNTRL" est
  affiché en permanence (avec glow) sur les écrans principaux via `SnowCntrlBrandmark`.
- **Stationnements de secours à proximité** : bouton "Où stationner ?" dans le tableau
  de bord, ouvre `NearbyParkingView` qui interroge Apple Maps (`MKLocalSearch`, aucune
  clé API) autour de l'adresse choisie et propose d'ouvrir l'itinéraire dans Plans.
  Fonctionne dans les 114 villes puisqu'il ne dépend d'aucune donnée municipale.
- **"Comment ça marche ici"** : résumé en langage simple du système de ban de
  stationnement (`Sources/Data/CityRules.swift`), curaté à la main pour une douzaine de
  grandes villes (Montréal, Québec, Toronto, Ottawa, Calgary, Edmonton, Winnipeg,
  Halifax, etc.). Pour les autres villes, un message indique qu'aucun résumé n'existe
  encore et renvoie vers la source officielle.
- **Marqueur personnel "J'ai vérifié"** : un bouton à côté de chaque adresse permet de
  noter (localement, sur l'appareil uniquement — pas de compte ni de partage) qu'on a
  vérifié la signalisation sur place ; l'icône devient verte pendant 3h. Ce n'est PAS
  du crowdsourcing entre utilisateurs (il n'y a pas de backend pour ça) — juste un
  rappel personnel.
- **Raccourci Siri** ("Hey Siri, check SnowCNTRL status" / "Vérifie le statut avec
  SnowCNTRL…") : `Sources/App/SiriIntents.swift` déclare un `AppIntent` qui relit le
  statut de la première adresse enregistrée sans ouvrir l'app, et met en cache le
  dernier résultat (`StatusCache`) pour répondre même hors-ligne juste après un lancement
  précédent. Aucune cible Xcode supplémentaire requise (App Intents iOS 16+ vit dans la
  cible principale).
- **Widget écran d'accueil + écran verrouillé** (`ios/Widget/`) : nouvelle cible
  `SnowCNTRLWidgetExtension` (WidgetKit). Affiche la ville, un point coloré et le statut
  en petit (accueil, `.systemSmall`/`.systemMedium`) ou en icône/texte (verrouillage,
  `.accessoryCircular`/`.accessoryRectangular`/`.accessoryInline`). Les données passent
  par un App Group (`group.com.snowcntrl.app`, voir `Sources/Shared/WidgetSharedStatus.swift`)
  écrit par `DashboardViewModel` et `SiriIntents` à chaque vérification de statut — le
  widget ne fait lui-même aucun appel réseau, il relit juste la dernière valeur connue et
  se rafraîchit via `WidgetCenter.reloadAllTimelines()`.
- **Live Activity / Dynamic Island** (`Sources/Services/LiveActivityManager.swift` +
  `Widget/Sources/SnowBanLiveActivityWidget.swift`) : quand une interdiction devient
  active pour la ville affichée, une Live Activity démarre automatiquement (bannière
  écran verrouillé + Dynamic Island sur iPhone 14 Pro et plus récents) et se termine
  d'elle-même quand le statut redevient inactif/inconnu. Cible iOS 16.1+ (relèvement du
  `deploymentTarget` depuis 16.0, requis par ActivityKit) — vit dans la même cible
  `SnowCNTRLWidgetExtension` que le widget, aucune cible supplémentaire nécessaire.
  `NSSupportsLiveActivities: true` est déjà dans `project.yml`.

### Tester la vérification en arrière-plan

iOS décide seul du moment réel d'exécution d'un `BGAppRefreshTask` (jamais instantané,
jamais garanti à heure fixe) — c'est normal, pas un bug. Pour forcer un test dans le
simulateur : lance l'app, mets-la en arrière-plan, puis dans Xcode :
`Debug > Simulate Background App Refresh`.

## Ce qui reste à faire avant une sortie réelle

1. **Remplacer les identifiants AdMob de test** par les tiens (`Sources/Services/AdsConfig.swift`
   + `GADApplicationIdentifier` dans `project.yml`) — sinon Apple/Google refusent la
   soumission en production.
2. **Compléter l'intégration Montréal** (`Sources/Services/MontrealOpenDataProvider.swift`) :
   le `resourceID` est un espace réservé. Le domaine `donnees.montreal.ca` était bloqué
   depuis l'environnement où ce code a été écrit — impossible de confirmer l'identifiant
   exact de la ressource ni le nom des colonnes. Étapes pour finir :
   - ouvrir https://donnees.montreal.ca/dataset/deneigement
   - repérer la ressource "Déneigement des rues en arrondissements"
   - copier son `resource_id` et l'utiliser dans le fichier
   - adapter `parseState(records:)` selon les vrais champs retournés.
3. **Toutes les autres villes n'ont aucune vraie donnée live** — elles affichent le
   disclaimer de niveau (voir le Cahier des charges et la carte des données déjà
   publiés) plutôt qu'un vrai statut. C'est voulu pour cette étape, pas un bug.
4. **Pas de paiement / StoreKit** — cohérent avec la décision de lancer freemium
   d'abord. `SettingsView` a déjà la ligne "version sans pub" prête à activer.
5. **Pas de compilation vérifiée** : ce code a été écrit sans accès à Xcode/au
   simulateur iOS. Attends-toi à devoir corriger quelques erreurs de compilation
   mineures (typos, signatures d'API) au premier build.
6. Politique de confidentialité et conditions d'utilisation réelles (des textes de
   base existent déjà dans `Sources/Localization/Strings.swift`, à faire réviser par
   un vrai texte légal avant publication). L'icône est en place (`Sources/Assets.xcassets/AppIcon.appiconset`)
   mais dérivée d'un aperçu maquette (fond métallique + reflet) plutôt que d'un
   artwork carré plat — à refaire proprement avant la mise en boutique.
7. `NSLocationWhenInUseUsageDescription` est déjà dans `project.yml` (nécessaire pour
   le bouton "utiliser ma position" sur la carte et la géolocalisation au lancement)
   — relis le texte avant publication.
8. **Aucune ligne de rue affichée nulle part pour l'instant** (voir plus haut) — c'est
   la limite la plus visible actuellement : le rendu néon (`GlowPolylineRenderer`)
   fonctionne et est prêt, mais `MontrealSnowSegmentProvider` ne génère plus de fausse
   grille (elle ne correspondait pas aux vraies rues) et retourne une liste vide tant
   que le `resource_id` de Montréal n'est pas branché à de la vraie géométrie.
9. Les couleurs de thème par province sont une interprétation approximative des
   drapeaux, pas une reproduction officielle — à ajuster si certaines ne plaisent pas.
10. **Prochaine grosse étape : Widget (écran d'accueil/verrouillage), Apple Watch et
    CarPlay.** Contrairement aux fonctionnalités ci-dessus, ces trois-là nécessitent
    chacune une **nouvelle cible Xcode** avec sa propre signature (+ App Group pour
    partager les données avec l'app principale), donc plus de risque de casser le
    build existant. Elles seront ajoutées une par une, en commençant par le widget.
    La Live Activity / Dynamic Island partagera probablement la cible du widget.
11. **Pas d'alerte "X minutes avant" une interdiction** : volontairement absent. Une
    vraie alerte "avant" (comme Info-Neige) suppose une donnée d'horaire *prévu*, pas
    seulement un statut actuel — aucune ville couverte ici ne publie ça de façon fiable
    pour l'instant. Mieux vaut ne pas fabriquer une fausse promesse de délai.
