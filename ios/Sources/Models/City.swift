import Foundation

struct City: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let province: ProvinceCode
    let tier: DataTier
    let sourceURLString: String?
    /// Identifier used by CityStatusService to pick a live data provider (e.g. "montreal").
    /// nil means no live integration exists yet for this city.
    let liveProviderID: String?

    var sourceURL: URL? {
        sourceURLString.flatMap(URL.init(string:))
    }

    init(
        id: String,
        name: String,
        province: ProvinceCode,
        tier: DataTier,
        sourceURLString: String? = nil,
        liveProviderID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.province = province
        self.tier = tier
        self.sourceURLString = sourceURLString
        self.liveProviderID = liveProviderID
    }
}
