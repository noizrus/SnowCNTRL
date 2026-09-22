import Foundation

/// "My car was towed" help per city: the official page to locate a towed
/// vehicle and the phone numbers to call. Only numbers and links confirmed
/// on the cities' own sites are listed; other cities fall back to their
/// official website (`City.sourceURL`) and generic advice.
enum CityHelp {
    enum ContactKind {
        case towingInfo
        case cityServices
        case policeNonEmergency

        var labelKey: LocKey {
            switch self {
            case .towingInfo: return .helpTowingLine
            case .cityServices: return .helpCityServices
            case .policeNonEmergency: return .helpPoliceNonEmergency
            }
        }
    }

    struct Contact: Identifiable {
        let kind: ContactKind
        let number: String

        var id: String { number }

        /// `tel:` link with digits only, so it dials from the app.
        var dialURL: URL? {
            URL(string: "tel:" + number.filter(\.isNumber))
        }
    }

    struct Entry {
        let towedVehicleURL: URL?
        let contacts: [Contact]
    }

    static func entry(for city: City) -> Entry? {
        table[city.id]
    }

    private static func url(_ string: String) -> URL? { URL(string: string) }

    private static let halifax = Entry(
        towedVehicleURL: url("https://www.halifax.ca/transportation/parking/towing"),
        contacts: [
            Contact(kind: .cityServices, number: "311"),
            Contact(kind: .policeNonEmergency, number: "902-490-5020"),
        ]
    )

    private static let table: [String: Entry] = [
        "montreal": Entry(
            towedVehicleURL: url("https://montreal.ca/demarches/retrouver-un-vehicule-remorque"),
            contacts: [
                Contact(kind: .towingInfo, number: "514 868-3737"),
                Contact(kind: .cityServices, number: "311"),
            ]
        ),
        "quebec-city": Entry(
            towedVehicleURL: url("https://www.ville.quebec.qc.ca/citoyens/mobilite/stationnement/info-remorquage.aspx"),
            contacts: [
                Contact(kind: .towingInfo, number: "418 641-6666"),
                Contact(kind: .cityServices, number: "311"),
            ]
        ),
        "laval": Entry(
            towedVehicleURL: url("https://www.laval.ca/en/roadworks-mobility/parking/towing-and-vehicle-seizure/"),
            contacts: [Contact(kind: .cityServices, number: "311")]
        ),
        "longueuil": Entry(
            towedVehicleURL: url("https://longueuil.quebec/fr/localisation-des-remorquages-hivernaux"),
            contacts: [Contact(kind: .cityServices, number: "311")]
        ),
        "trois-rivieres": Entry(
            towedVehicleURL: url("https://www.v3r.net/stationnementdenuit"),
            contacts: [Contact(kind: .policeNonEmergency, number: "819 691-2929")]
        ),
        "toronto": Entry(
            towedVehicleURL: url("https://www.tps.ca/services/towing/"),
            contacts: [
                Contact(kind: .policeNonEmergency, number: "416-808-2222"),
                Contact(kind: .cityServices, number: "311"),
            ]
        ),
        "ottawa": Entry(
            towedVehicleURL: url("https://ottawa.ca/en/parking-roads-and-travel/parking/winter-parking/winter-weather-parking-bans"),
            contacts: [Contact(kind: .cityServices, number: "311")]
        ),
        "halifax": halifax,
        "dartmouth": halifax,
        "calgary": Entry(
            towedVehicleURL: url("https://www.calgary.ca/roads/conditions/snow-route-parking-bans.html"),
            contacts: [Contact(kind: .cityServices, number: "311")]
        ),
        "edmonton": Entry(
            towedVehicleURL: url("https://www.edmonton.ca/city_government/bylaws/parking-enforcement-services"),
            contacts: [Contact(kind: .cityServices, number: "311")]
        ),
        "winnipeg": Entry(
            towedVehicleURL: url("https://legacy.winnipeg.ca/publicworks/snow/winter-parking-bans.stm"),
            contacts: [Contact(kind: .cityServices, number: "311")]
        ),
    ]
}
