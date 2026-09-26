import Foundation

/// A same-day-tomorrow estimate of how likely a snow-clearing ban is,
/// straight from the forecasted snowfall — before any city announces
/// anything. This is a plain heuristic on public weather data, not a model
/// trained on each city's actual ban history (no city publishes that), so
/// it's shown to the user as an estimate, never as a confirmed prediction.
enum SnowRiskEstimator {
    /// 5–95, never the extremes — even a big storm can result in no ban in
    /// a city that plows without banning parking, and a light dusting can
    /// still trigger one in a city with a low threshold.
    static func riskPercent(for tomorrow: DailyForecast) -> Int {
        switch tomorrow.snowfallCm {
        case ..<0.1: return 5
        case ..<1: return 25
        case ..<3: return 50
        case ..<6: return 70
        case ..<12: return 85
        default: return 95
        }
    }
}
