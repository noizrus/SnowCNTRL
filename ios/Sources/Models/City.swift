import Foundation
import CoreLocation

struct City: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let province: ProvinceCode
    let tier: DataTier
    let sourceURLString: String?
    /// Identifier used by CityStatusService to pick a live data provider (e.g. "montreal").
    /// nil means no live integration exists yet for this city.
    let liveProviderID: String?
    /// Approximate downtown coordinate — used only to center the map when the
    /// user starts pinning their street; not precise enough for anything else.
    let latitude: Double
    let longitude: Double

    var sourceURL: URL? {
        sourceURLString.flatMap(URL.init(string:))
    }

    var approximateCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(
        id: String,
        name: String,
        province: ProvinceCode,
        tier: DataTier,
        latitude: Double,
        longitude: Double,
        sourceURLString: String? = nil,
        liveProviderID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.province = province
        self.tier = tier
        self.sourceURLString = sourceURLString
        self.liveProviderID = liveProviderID
        self.latitude = latitude
        self.longitude = longitude
    }
}
