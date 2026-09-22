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

    func testBanAlertRingsWithTheSnowTruckSoundThroughFocus() {
        let content = AlertNotifier.makeContent(for: alert, language: .french, isTest: false)
        XCTAssertNotNil(content.sound)
        XCTAssertEqual(AlertNotifier.soundName.rawValue, "snowplow.wav")
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
        XCTAssertEqual(AlertNotifier.repeatOffsets.count, 3)
        XCTAssertLessThanOrEqual(AlertNotifier.repeatOffsets[0], 1, "first ring is immediate")
        XCTAssertEqual(Set(AlertNotifier.requestIDs(for: alert.id)).count, AlertNotifier.repeatOffsets.count + 1)
    }

    func testSnowTruckSoundIsBundledAndPlayableAsANotification() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "snowplow", withExtension: "wav"), "snowplow.wav missing from the app bundle")
        let file = try AVAudioFile(forReading: url)
        let seconds = Double(file.length) / file.processingFormat.sampleRate
        XCTAssertGreaterThan(seconds, 5)
        XCTAssertLessThan(seconds, 30, "iOS ignores notification sounds of 30 s or more")
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
