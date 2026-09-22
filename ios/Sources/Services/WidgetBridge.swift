import SwiftUI
import UIKit
import WidgetKit

/// Pushes what the widget shows — status, first alert's street, theme color —
/// into the shared App Group and asks WidgetKit to redraw right away.
enum WidgetBridge {
    /// `accent` is nil from contexts without a theme (Siri): the previously
    /// published theme color is kept.
    static func publish(city: City, result: CityStatusResult, language: AppLanguage, accent: Color?) {
        let alert = AddressStore.shared.addresses.first { $0.cityID == city.id }
        WidgetSharedStatus.save(WidgetSharedStatus(
            cityName: city.name,
            stateRawValue: StatusCache.rawValue(for: result.state),
            languageRawValue: language.rawValue,
            updatedAt: Date(),
            alertLabel: alert?.label,
            isOffSeason: result.isOffSeason,
            accentRGB: accent.map { rgb($0) } ?? WidgetSharedStatus.load()?.accentRGB
        ))
        WidgetCenter.shared.reloadAllTimelines()
    }

    private static func rgb(_ color: Color) -> [Double] {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        return [r, g, b].map { Double(min(max($0, 0), 1)) }
    }
}
