# SnowCNTRL — app iOS (MVP)

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
  être obtenue (même blocage `donnees.montreal.ca`) — `MontrealSnowSegmentProvider`
  affiche donc des rues d'exemple générées autour du point choisi, pas de vraies
  données. Toutes les autres villes n'affichent aucune ligne (pas de donnée du tout).
  Voir les commentaires dans `Sources/Services/SnowSegmentProviding.swift` pour brancher
  les vraies données une fois le `resource_id` obtenu.
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
8. **Lignes de rue = données d'exemple, pas réelles** (voir plus haut) — c'est la limite
   la plus visible actuellement : le rendu néon fonctionne, mais ce n'est pas encore un
   vrai statut de déneigement rue par rue tant que le `resource_id` de Montréal n'est
   pas branché.
9. Les couleurs de thème par province sont une interprétation approximative des
   drapeaux, pas une reproduction officielle — à ajuster si certaines ne plaisent pas.
