import Foundation

/// One hour within a `DailyForecast` — what "degré de tempête" is judged
/// from, since a day's total snowfall says nothing about whether it falls
/// all at 3pm or spread evenly overnight.
struct HourlyForecast: Identifiable {
    let id = UUID()
    let hour: Int
    let temperatureC: Double
    let weatherCode: Int
    let snowfallCm: Double
    let precipitationProbability: Int?

    /// Coarse 0–3 scale used to color/size the hour's intensity mark —
    /// snowfall is what matters for a ban tracker, not just "is it snowing".
    var stormIntensity: StormIntensity {
        switch snowfallCm {
        case ..<0.1: return .none
        case ..<0.5: return .light
        case ..<2: return .moderate
        default: return .heavy
        }
    }
}

enum StormIntensity: Int, CaseIterable {
    case none, light, moderate, heavy
}

/// One day of the forecast — Celsius and centimeters, as used everywhere
/// else in the app (this is a Canadian snow app, not one that needs to
/// support imperial units).
struct DailyForecast: Identifiable {
    let id = UUID()
    let date: Date
    let weatherCode: Int
    let highC: Double
    let lowC: Double
    let snowfallCm: Double
    let precipitationProbability: Int?
    let hourly: [HourlyForecast]
}

/// Free, keyless 14-day forecast from Open-Meteo — no API key or paid
/// entitlement to register (unlike WeatherKit), which matters here since
/// this app already ran into real friction getting App Groups registered
/// with the developer account; one more capability to configure isn't
/// worth it for a secondary feature. `snowfall_sum` is the whole reason to
/// pick this API over a plainer one: knowing more snow is coming is
/// directly useful next to a snow-clearing ban tracker. Also pulls hourly
/// snowfall so tapping into a day can show when during it the snow falls.
enum WeatherService {
    private static let endpoint = "https://api.open-meteo.com/v1/forecast"
    /// Open-Meteo's free tier allows up to 16; 14 is plenty for planning
    /// around upcoming bans without cluttering the list.
    private static let forecastDays = 14

    private struct Response: Decodable {
        struct Daily: Decodable {
            let time: [String]
            let weathercode: [Int]
            let temperature_2m_max: [Double]
            let temperature_2m_min: [Double]
            let snowfall_sum: [Double]
            let precipitation_probability_max: [Int]?
        }
        struct Hourly: Decodable {
            let time: [String]
            let temperature_2m: [Double]
            let weathercode: [Int]
            let snowfall: [Double]
            let precipitation_probability: [Int]?
        }
        let daily: Daily
        let hourly: Hourly?
    }

    static func forecast(for city: City) async -> [DailyForecast]? {
        var components = URLComponents(string: endpoint)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(city.latitude)),
            URLQueryItem(name: "longitude", value: String(city.longitude)),
            URLQueryItem(name: "daily", value: "weathercode,temperature_2m_max,temperature_2m_min,snowfall_sum,precipitation_probability_max"),
            URLQueryItem(name: "hourly", value: "temperature_2m,weathercode,snowfall,precipitation_probability"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: String(forecastDays)),
        ]
        guard let url = components.url else { return nil }

        guard let (data, response) = try? await URLSession.shared.data(from: url),
              (response as? HTTPURLResponse)?.statusCode == 200,
              let decoded = try? JSONDecoder().decode(Response.self, from: data)
        else { return nil }

        return parse(decoded.daily, hourly: decoded.hourly)
    }

    private static func parse(_ daily: Response.Daily, hourly: Response.Hourly?) -> [DailyForecast]? {
        let count = daily.time.count
        guard daily.weathercode.count == count,
              daily.temperature_2m_max.count == count,
              daily.temperature_2m_min.count == count,
              daily.snowfall_sum.count == count
        else { return nil }

        let hourlyByDay = parseHourly(hourly)

        return (0..<count).compactMap { i in
            // Built from the calendar's own timezone (the device's), not
            // parsed as UTC midnight — a fixed offset there can land on the
            // wrong side of midnight once compared against
            // `Calendar.current`, shifting "today" and every weekday label
            // by a day for anyone not in a UTC-adjacent timezone.
            let dayKey = daily.time[i]
            let parts = dayKey.split(separator: "-").compactMap { Int($0) }
            guard parts.count == 3,
                  let date = Calendar.current.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
            else { return nil }
            return DailyForecast(
                date: date,
                weatherCode: daily.weathercode[i],
                highC: daily.temperature_2m_max[i],
                lowC: daily.temperature_2m_min[i],
                snowfallCm: daily.snowfall_sum[i],
                precipitationProbability: daily.precipitation_probability_max?[safe: i],
                hourly: hourlyByDay[dayKey] ?? []
            )
        }
    }

    /// Groups the flat hourly arrays by calendar day ("2026-01-15"), which
    /// is exactly the prefix of Open-Meteo's `"2026-01-15T14:00"` hourly
    /// timestamps when `timezone=auto` is used — so no separate timezone
    /// math is needed to match hours back up to their day.
    private static func parseHourly(_ hourly: Response.Hourly?) -> [String: [HourlyForecast]] {
        guard let hourly else { return [:] }
        let count = hourly.time.count
        guard hourly.weathercode.count == count,
              hourly.temperature_2m.count == count,
              hourly.snowfall.count == count
        else { return [:] }

        var byDay: [String: [HourlyForecast]] = [:]
        for i in 0..<count {
            let parts = hourly.time[i].split(separator: "T")
            guard parts.count == 2,
                  let hour = Int(parts[1].prefix(2))
            else { continue }
            let forecast = HourlyForecast(
                hour: hour,
                temperatureC: hourly.temperature_2m[i],
                weatherCode: hourly.weathercode[i],
                snowfallCm: hourly.snowfall[i],
                precipitationProbability: hourly.precipitation_probability?[safe: i]
            )
            byDay[String(parts[0]), default: []].append(forecast)
        }
        return byDay
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

/// WMO weather codes (used by Open-Meteo) → SF Symbol + short description.
enum WeatherCode {
    static func symbolName(for code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill"
        case 1, 2: return "cloud.sun.fill"
        case 3: return "cloud.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55, 56, 57: return "cloud.drizzle.fill"
        case 61, 63, 65, 66, 67: return "cloud.rain.fill"
        case 71, 73, 75, 77, 85, 86: return "cloud.snow.fill"
        case 80, 81, 82: return "cloud.heavyrain.fill"
        case 95, 96, 99: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }

    static func label(for code: Int, language: AppLanguage) -> String {
        switch (code, language) {
        case (0, .french): return "Ciel dégagé"
        case (0, .english): return "Clear sky"
        case (0, .spanish): return "Cielo despejado"
        case (1, .french), (2, .french): return "Partiellement nuageux"
        case (1, .english), (2, .english): return "Partly cloudy"
        case (1, .spanish), (2, .spanish): return "Parcialmente nublado"
        case (3, .french): return "Couvert"
        case (3, .english): return "Overcast"
        case (3, .spanish): return "Nublado"
        case (45, .french), (48, .french): return "Brouillard"
        case (45, .english), (48, .english): return "Fog"
        case (45, .spanish), (48, .spanish): return "Niebla"
        case (51, .french), (53, .french), (55, .french), (56, .french), (57, .french): return "Bruine"
        case (51, .english), (53, .english), (55, .english), (56, .english), (57, .english): return "Drizzle"
        case (51, .spanish), (53, .spanish), (55, .spanish), (56, .spanish), (57, .spanish): return "Llovizna"
        case (61, .french), (63, .french), (65, .french), (66, .french), (67, .french), (80, .french), (81, .french), (82, .french):
            return "Pluie"
        case (61, .english), (63, .english), (65, .english), (66, .english), (67, .english), (80, .english), (81, .english), (82, .english):
            return "Rain"
        case (61, .spanish), (63, .spanish), (65, .spanish), (66, .spanish), (67, .spanish), (80, .spanish), (81, .spanish), (82, .spanish):
            return "Lluvia"
        case (71, .french), (73, .french), (75, .french), (77, .french), (85, .french), (86, .french): return "Neige"
        case (71, .english), (73, .english), (75, .english), (77, .english), (85, .english), (86, .english): return "Snow"
        case (71, .spanish), (73, .spanish), (75, .spanish), (77, .spanish), (85, .spanish), (86, .spanish): return "Nieve"
        case (95, .french), (96, .french), (99, .french): return "Orage"
        case (95, .english), (96, .english), (99, .english): return "Thunderstorm"
        case (95, .spanish), (96, .spanish), (99, .spanish): return "Tormenta"
        default:
            switch language {
            case .french: return "Nuageux"
            case .english: return "Cloudy"
            case .spanish: return "Nublado"
            }
        }
    }
}
