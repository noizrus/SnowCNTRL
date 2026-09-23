import XCTest
import SwiftUI
import MapKit
import AVFoundation
import UserNotifications
@testable import SnowCNTRL

final class LocalizationTests: XCTestCase {
    func testEveryTextExistsInFrenchEnglishAndSpanish() {
        for key in LocKey.allCases {
            for language in AppLanguage.allCases {
                let text = Strings.translation(for: key, language: language)
                XCTAssertNotNil(text, "\(key) is missing in \(language)")
                XCTAssertFalse(text?.isEmpty ?? true, "\(key) is empty in \(language)")
            }
        }
    }

    func testAppNameIsNeigeCntrlInFrenchOnly() {
        XCTAssertEqual(AppLanguage.french.appName, "NEIGE CNTRL")
        XCTAssertEqual(AppLanguage.english.appName, "SNOW CNTRL")
        XCTAssertEqual(AppLanguage.spanish.appName, "SNOW CNTRL")
    }
}

final class AlertPolicyTests: XCTestCase {
    func testFreeVersionAllowsOneAlert() {
        XCTAssertFalse(AlertPolicy.isAtLimit(alertCount: 0, isPremium: false))
        XCTAssertTrue(AlertPolicy.isAtLimit(alertCount: 1, isPremium: false))
    }

    func testPremiumHasNoLimit() {
        XCTAssertFalse(AlertPolicy.isAtLimit(alertCount: 1, isPremium: true))
        XCTAssertFalse(AlertPolicy.isAtLimit(alertCount: 50, isPremium: true))
    }
}

final class CityStatusTests: XCTestCase {
    private var savedSimulationFlag: Any?

    override func setUp() {
        super.setUp()
        // Tests run inside the app: don't let the debug simulation switch
        // (Settings) leak into them.
        savedSimulationFlag = UserDefaults.standard.object(forKey: CityStatusService.simulateBanKey)
        UserDefaults.standard.removeObject(forKey: CityStatusService.simulateBanKey)
    }

    override func tearDown() {
        UserDefaults.standard.set(savedSimulationFlag, forKey: CityStatusService.simulateBanKey)
        super.tearDown()
    }

    private func date(month: Int, day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: month, day: day, hour: 12))!
    }

    private var montreal: City {
        CitiesData.all.first { $0.id == "montreal" }!
    }

    func testSeptemberIsOffSeasonInTheProvinces() {
        XCTAssertTrue(CityStatusService.isOffSeason(for: .qc, on: date(month: 9, day: 22)))
        XCTAssertFalse(CityStatusService.isOffSeason(for: .qc, on: date(month: 12, day: 15)))
        XCTAssertFalse(CityStatusService.isOffSeason(for: .qc, on: date(month: 11, day: 20)))
    }

    func testTerritoriesHaveAShorterOffSeason() {
        XCTAssertFalse(CityStatusService.isOffSeason(for: .nu, on: date(month: 9, day: 22)))
        XCTAssertTrue(CityStatusService.isOffSeason(for: .nu, on: date(month: 7, day: 15)))
    }

    func testOffSeasonReportsNoBanWithoutNetwork() async {
        let result = await CityStatusService.shared.fetchStatus(for: montreal, now: date(month: 9, day: 22))
        XCTAssertEqual(result.state, .noActiveBan)
        XCTAssertTrue(result.isOffSeason)
    }

    func testOffSeasonStreetsAreGreen() {
        XCTAssertEqual(ParkingBanState.noActiveBan.asSnowClearingStatus, .cleared)
        XCTAssertEqual(ParkingBanState.activeBanNow.asSnowClearingStatus, .noParkingActive)
    }

    #if DEBUG
    func testSimulationForcesAnActiveBan() async {
        UserDefaults.standard.set(true, forKey: CityStatusService.simulateBanKey)
        let result = await CityStatusService.shared.fetchStatus(for: montreal, now: date(month: 9, day: 22))
        XCTAssertEqual(result.state, .activeBanNow)
    }
    #endif
}

final class StreetSideTests: XCTestCase {
    /// A 780 m west→east block along latitude 45.5.
    private let block = StreetBlock(
        id: "test-block",
        wayID: 1,
        centerline: [
            CLLocationCoordinate2D(latitude: 45.5, longitude: -73.60),
            CLLocationCoordinate2D(latitude: 45.5, longitude: -73.59),
        ],
        streetName: "Rue Test",
        curbOffsetMeters: 4.5
    )

    private var segments: [StreetSegment] { block.sides(status: .cleared) }

    func testEachBlockHasTwoSidesFacingOppositeWays() {
        let compasses = Set(segments.map(\.compassSide))
        XCTAssertEqual(segments.count, 2)
        XCTAssertEqual(compasses, [.north, .south])
    }

    func testTapNorthOfTheStreetSelectsTheNorthSide() throws {
        let tap = CLLocationCoordinate2D(latitude: 45.50005, longitude: -73.595)
        let match = try XCTUnwrap(segments.nearestSide(to: tap, within: 25))
        XCTAssertEqual(match.segment.compassSide, .north)
        XCTAssertGreaterThan(match.curbPoint.latitude, 45.5, "the car must sit on the north curb")
    }

    func testTapSouthOfTheStreetSelectsTheSouthSide() throws {
        let tap = CLLocationCoordinate2D(latitude: 45.49995, longitude: -73.595)
        let match = try XCTUnwrap(segments.nearestSide(to: tap, within: 25))
        XCTAssertEqual(match.segment.compassSide, .south)
        XCTAssertLessThan(match.curbPoint.latitude, 45.5)
    }

    func testCurbPointIsAtTheCurbOffset() throws {
        let tap = CLLocationCoordinate2D(latitude: 45.50005, longitude: -73.595)
        let match = try XCTUnwrap(segments.nearestSide(to: tap, within: 25))
        let onCenterline = CLLocation(latitude: 45.5, longitude: match.curbPoint.longitude)
        let curb = CLLocation(latitude: match.curbPoint.latitude, longitude: match.curbPoint.longitude)
        XCTAssertEqual(curb.distance(from: onCenterline), 4.5, accuracy: 0.5)
    }

    func testTapFarFromAnyStreetSelectsNothing() {
        let tap = CLLocationCoordinate2D(latitude: 45.51, longitude: -73.595)
        XCTAssertNil(segments.nearestSide(to: tap, within: 25))
    }
}

final class OverpassParsingTests: XCTestCase {
    /// Two residential streets crossing at node 2.
    private let fixture = """
    {"elements": [
      {"type": "way", "id": 10, "tags": {"highway": "residential", "name": "Rue Test"},
       "nodes": [1, 2, 3],
       "geometry": [{"lat": 45.5, "lon": -73.600}, {"lat": 45.5, "lon": -73.599}, {"lat": 45.5, "lon": -73.598}]},
      {"type": "way", "id": 20, "tags": {"highway": "secondary", "name": "Avenue Test"},
       "nodes": [4, 2, 5],
       "geometry": [{"lat": 45.4993, "lon": -73.599}, {"lat": 45.5, "lon": -73.599}, {"lat": 45.5007, "lon": -73.599}]}
    ]}
    """.data(using: .utf8)!

    func testStreetsAreSplitIntoBlocksAtIntersections() throws {
        let blocks = try XCTUnwrap(OverpassClient.parseBlocks(from: fixture))
        XCTAssertEqual(blocks.count, 4)
        XCTAssertEqual(blocks.filter { $0.wayID == 10 }.count, 2)
        XCTAssertEqual(blocks.filter { $0.wayID == 20 }.count, 2)
    }

    func testBlocksKeepNameAndCurbOffsetByStreetType() throws {
        let blocks = try XCTUnwrap(OverpassClient.parseBlocks(from: fixture))
        let residential = try XCTUnwrap(blocks.first { $0.wayID == 10 })
        let secondary = try XCTUnwrap(blocks.first { $0.wayID == 20 })
        XCTAssertEqual(residential.streetName, "Rue Test")
        XCTAssertEqual(residential.curbOffsetMeters, 4.5)
        XCTAssertGreaterThan(secondary.curbOffsetMeters, residential.curbOffsetMeters)
    }

    func testInvalidResponseIsRejected() {
        XCTAssertNil(OverpassClient.parseBlocks(from: Data("not json".utf8)))
    }
}

final class AlertNotificationTests: XCTestCase {
    private let alert = SavedAddress(
        label: "6702 Rue Saint-Denis, Montréal — côté est",
        coordinate: CLLocationCoordinate2D(latitude: 45.53, longitude: -73.60),
        cityID: "montreal"
    )

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: AlertRingDuration.storageKey)
        super.tearDown()
    }

    func testRingDurationDefaultsToTenSeconds() {
        UserDefaults.standard.removeObject(forKey: AlertRingDuration.storageKey)
        XCTAssertEqual(AlertRingDuration.current, .medium)
        XCTAssertEqual(AlertRingDuration.current.rawValue, 10)
    }

    func testChangingTheSettingChangesTheSoundFile() {
        UserDefaults.standard.set(AlertRingDuration.extended.rawValue, forKey: AlertRingDuration.storageKey)
        XCTAssertEqual(AlertNotifier.soundName.rawValue, "snowplow-20s.wav")
        UserDefaults.standard.set(AlertRingDuration.short.rawValue, forKey: AlertRingDuration.storageKey)
        XCTAssertEqual(AlertNotifier.soundName.rawValue, "snowplow-5s.wav")
    }

    func testBanAlertRingsWithTheSnowTruckSoundThroughFocus() {
        UserDefaults.standard.removeObject(forKey: AlertRingDuration.storageKey)
        let content = AlertNotifier.makeContent(for: alert, language: .french, isTest: false)
        XCTAssertNotNil(content.sound)
        XCTAssertEqual(AlertNotifier.soundName.rawValue, "snowplow-10s.wav")
        XCTAssertEqual(content.interruptionLevel, .timeSensitive, "must get through Do Not Disturb / Focus")
        XCTAssertEqual(content.categoryIdentifier, AlertNotifier.categoryIdentifier)
        XCTAssertTrue(content.body.contains(alert.label))
        XCTAssertEqual(content.userInfo["addressID"] as? String, alert.id.uuidString)
    }

    func testTestAlertUsesTheAppNameAndSameSound() {
        let content = AlertNotifier.makeContent(for: alert, language: .french, isTest: true)
        XCTAssertTrue(content.title.contains("NEIGE CNTRL"))
        XCTAssertNotNil(content.sound)
        XCTAssertEqual(content.interruptionLevel, .timeSensitive)
    }

    func testAlertRepeatsUntilAcknowledged() {
        XCTAssertLessThanOrEqual(AlertNotifier.firstRingDelay, 1, "first ring is immediate")
        XCTAssertGreaterThan(AlertNotifier.reminderInterval, 60, "must clear iOS's minimum repeat interval to actually recur")
        // First ring + recurring reminder + reserved snooze slot, all distinct.
        XCTAssertEqual(Set(AlertNotifier.requestIDs(for: alert.id)).count, 3)
    }

    func testEveryRingDurationHasABundledPlayableSoundOfTheRightLength() throws {
        for duration in AlertRingDuration.allCases {
            let name = duration.soundFileName
            let url = try XCTUnwrap(
                Bundle.main.url(forResource: (name as NSString).deletingPathExtension, withExtension: "wav"),
                "\(name) missing from the app bundle"
            )
            let file = try AVAudioFile(forReading: url)
            let seconds = Double(file.length) / file.processingFormat.sampleRate
            XCTAssertEqual(seconds, Double(duration.rawValue), accuracy: 0.2, name)
            XCTAssertLessThan(seconds, 30, "iOS ignores notification sounds of 30 s or more")
        }
    }
}

final class CityChoiceTests: XCTestCase {
    private let keys = ["snowcntrl.favoriteCityID", "snowcntrl.selectedCityID"]
    private var saved: [String: Any] = [:]

    override func setUp() {
        super.setUp()
        // Runs inside the app: keep the user's real choices intact.
        for key in keys {
            saved[key] = UserDefaults.standard.object(forKey: key)
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    override func tearDown() {
        for key in keys {
            UserDefaults.standard.set(saved[key], forKey: key)
        }
        super.tearDown()
    }

    func testCitiesAreSortedFromNearestToFarthest() {
        let montrealDowntown = CLLocationCoordinate2D(latitude: 45.5019, longitude: -73.5674)
        let sorted = CityResolver.sortedByDistance(CitiesData.all, from: montrealDowntown)
        XCTAssertEqual(sorted.first?.id, "montreal")
        let distances = sorted.map { CityResolver.distance(from: montrealDowntown, to: $0) }
        XCTAssertEqual(distances, distances.sorted())
    }

    func testWithoutPositionCitiesAreAlphabetical() {
        let names = CityResolver.sortedByDistance(CitiesData.all, from: nil).map(\.name)
        XCTAssertEqual(names, names.sorted { $0.localizedCompare($1) == .orderedAscending })
    }

    func testAppOpensOnTheDefaultCityRatherThanTheLastOne() {
        UserDefaults.standard.set("toronto", forKey: "snowcntrl.selectedCityID")
        UserDefaults.standard.set("quebec-city", forKey: "snowcntrl.favoriteCityID")
        XCTAssertEqual(CitySelectionViewModel().selectedCity?.id, "quebec-city")
    }

    func testWithoutDefaultCityTheLastCityReopens() {
        UserDefaults.standard.set("toronto", forKey: "snowcntrl.selectedCityID")
        XCTAssertEqual(CitySelectionViewModel().selectedCity?.id, "toronto")
    }

    func testStarTogglesTheDefaultCity() {
        let model = CitySelectionViewModel()
        let ottawa = CitiesData.all.first { $0.id == "ottawa" }!
        model.toggleFavorite(ottawa)
        XCTAssertEqual(model.favoriteCity?.id, "ottawa")
        model.toggleFavorite(ottawa)
        XCTAssertNil(model.favoriteCity)
    }
}

final class CityHelpTests: XCTestCase {
    func testEveryHelpEntryPointsToAKnownCityWithValidLinks() throws {
        let ids = ["montreal", "quebec-city", "laval", "longueuil", "trois-rivieres", "toronto", "ottawa", "halifax", "dartmouth", "calgary", "edmonton", "winnipeg"]
        for id in ids {
            let city = try XCTUnwrap(CitiesData.all.first { $0.id == id }, "\(id) not in CitiesData")
            let entry = try XCTUnwrap(CityHelp.entry(for: city), "\(id) has no help entry")
            XCTAssertEqual(entry.towedVehicleURL?.scheme, "https", id)
            XCTAssertFalse(entry.contacts.isEmpty, id)
            for contact in entry.contacts {
                let dial = try XCTUnwrap(contact.dialURL, "\(id) \(contact.number)")
                XCTAssertEqual(dial.scheme, "tel")
                XCTAssertTrue(dial.absoluteString.dropFirst(4).allSatisfy(\.isNumber), "\(dial)")
            }
        }
    }

    func testMontrealTowingLineDialsCorrectly() throws {
        let montreal = try XCTUnwrap(CitiesData.all.first { $0.id == "montreal" })
        let towing = try XCTUnwrap(CityHelp.entry(for: montreal)?.contacts.first { $0.kind == .towingInfo })
        XCTAssertEqual(towing.dialURL?.absoluteString, "tel:5148683737")
    }
}

final class WidgetDataTests: XCTestCase {
    func testWidgetEntryRoundTripsWithAlertAndOffSeason() throws {
        let entry = WidgetSharedStatus(
            cityName: "Montreal",
            stateRawValue: "noActiveBan",
            languageRawValue: "fr",
            updatedAt: Date(timeIntervalSinceReferenceDate: 0),
            alertLabel: "Rue Saint-Denis — côté est",
            isOffSeason: true,
            accentRGB: [0.1, 0.2, 0.3]
        )
        let decoded = try JSONDecoder().decode(WidgetSharedStatus.self, from: JSONEncoder().encode(entry))
        XCTAssertEqual(decoded.alertLabel, "Rue Saint-Denis — côté est")
        XCTAssertEqual(decoded.isOffSeason, true)
        XCTAssertEqual(decoded.accentRGB, [0.1, 0.2, 0.3])
    }

    func testEntrySavedByAnOlderBuildStillDecodes() throws {
        let legacy = Data("""
        {"cityName": "Montreal", "stateRawValue": "unknownNoData", "languageRawValue": "en", "updatedAt": 0}
        """.utf8)
        let decoded = try JSONDecoder().decode(WidgetSharedStatus.self, from: legacy)
        XCTAssertEqual(decoded.cityName, "Montreal")
        XCTAssertNil(decoded.alertLabel)
        XCTAssertNil(decoded.isOffSeason)
    }
}

final class ThemeContrastTests: XCTestCase {
    private func luminance(_ color: UIColor) -> CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        func linear(_ v: CGFloat) -> CGFloat {
            let v = min(max(v, 0), 1)
            return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
    }

    private func contrast(_ a: UIColor, _ b: UIColor) -> CGFloat {
        let la = luminance(a), lb = luminance(b)
        return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
    }

    func testTextOnThemeFillsPicksReadableColor() {
        let quebecBlue = ProvinceCode.qc.flagPalette.primary
        XCTAssertEqual(ThemePalette.contrastingText(on: quebecBlue), .white)
        XCTAssertEqual(ThemePalette.contrastingText(on: Color(red: 1, green: 0.84, blue: 0)), .black)
        XCTAssertEqual(ThemePalette.contrastingText(on: .white), .black)
    }

    func testEveryThemeColorIsReadableInDayAndNightMode() {
        let palettes = AppTheme.allCases.compactMap(\.curatedPalette) + ProvinceCode.allCases.map(\.flagPalette)
        let day = UITraitCollection(userInterfaceStyle: .light)
        let night = UITraitCollection(userInterfaceStyle: .dark)
        for palette in palettes {
            for color in [palette.primary, palette.accent] {
                let dynamic = ThemePalette.readableUIColor(color)
                XCTAssertGreaterThanOrEqual(contrast(dynamic.resolvedColor(with: day), .white), 4.4, "\(palette.name) unreadable in day mode")
                XCTAssertGreaterThanOrEqual(contrast(dynamic.resolvedColor(with: night), UIColor(white: 0.11, alpha: 1)), 4.4, "\(palette.name) unreadable in night mode")
            }
        }
    }
}
