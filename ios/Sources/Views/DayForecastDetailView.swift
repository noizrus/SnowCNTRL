import SwiftUI

/// Hour-by-hour breakdown of one day from `WeatherForecastView` — a day's
/// total snowfall says nothing about whether it falls all at once during
/// rush hour or lightly overnight, which matters for deciding when to move
/// a car. Pushed (not sheeted), consistent with the rest of the app.
struct DayForecastDetailView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    let day: DailyForecast
    let cityName: String

    private var hours: [HourlyForecast] {
        day.hourly.sorted { $0.hour < $1.hour }
    }

    private var hasSnow: Bool {
        hours.contains { $0.snowfallCm >= 0.1 }
    }

    var body: some View {
        Group {
            if hours.isEmpty {
                emptyView
            } else {
                List {
                    Section {
                        header
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                    if !hasSnow {
                        Section {
                            Text(localizer.s(.weatherHourlyNoSnow))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section(localizer.s(.weatherHourlyTitle)) {
                        ForEach(hours) { hour in
                            hourRow(hour)
                        }
                    }
                }
            }
        }
        .navigationTitle(weekdayText(day.date))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(weekdayText(day.date))
                        .font(.headline)
                        .foregroundStyle(themeManager.palette.onAccent)
                    Text(cityName)
                        .font(.caption)
                        .foregroundStyle(themeManager.palette.onAccent.opacity(0.75))
                }
            }
        }
        .themedNavigationBar(themeManager.palette)
        .tint(themeManager.palette.primaryText)
    }

    private var header: some View {
        HStack(spacing: 16) {
            Image(systemName: WeatherCode.symbolName(for: day.weatherCode))
                .font(.system(size: 40))
                .foregroundStyle(iconColor(for: day.weatherCode))
            VStack(alignment: .leading, spacing: 2) {
                Text(WeatherCode.label(for: day.weatherCode, language: localizer.language))
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 6) {
                    Text("\(Int(day.highC.rounded()))°")
                        .font(.title3.weight(.semibold).monospacedDigit())
                    Text("\(Int(day.lowC.rounded()))°")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                if day.snowfallCm >= 0.1 {
                    Label(String(format: "%.1f cm", day.snowfallCm), systemImage: "snowflake")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(themeManager.palette.primaryText)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.badge.questionmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(localizer.s(.weatherError))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func hourRow(_ hour: HourlyForecast) -> some View {
        HStack(spacing: 12) {
            Text(hourText(hour.hour))
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .frame(width: 48, alignment: .leading)

            Image(systemName: WeatherCode.symbolName(for: hour.weatherCode))
                .font(.body)
                .foregroundStyle(iconColor(for: hour.weatherCode))
                .frame(width: 24)

            intensityBar(hour.stormIntensity)

            Spacer(minLength: 8)

            if hour.snowfallCm >= 0.1 {
                Text(String(format: "%.1f cm", hour.snowfallCm))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(themeManager.palette.primaryText)
                    .frame(minWidth: 42, alignment: .trailing)
            }

            Text("\(Int(hour.temperatureC.rounded()))°")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(minWidth: 32, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }

    /// The "degré de tempête" indicator — a short colored bar whose length
    /// and color both scale with how heavy the snow is that hour, so a
    /// glance down the list shows exactly which hours matter.
    private func intensityBar(_ intensity: StormIntensity) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<StormIntensity.heavy.rawValue + 1, id: \.self) { step in
                Capsule()
                    .fill(step <= intensity.rawValue ? intensityColor(intensity) : themeManager.palette.primary.opacity(0.12))
                    .frame(width: 5, height: 14)
            }
        }
    }

    private func intensityColor(_ intensity: StormIntensity) -> Color {
        switch intensity {
        case .none: return themeManager.palette.primary.opacity(0.12)
        case .light: return themeManager.palette.primary.opacity(0.45)
        case .moderate: return themeManager.palette.primary.opacity(0.75)
        case .heavy: return themeManager.palette.primary
        }
    }

    private func iconColor(for code: Int) -> Color {
        switch code {
        case 71, 73, 75, 77, 85, 86: return themeManager.palette.primary
        case 61, 63, 65, 66, 67, 80, 81, 82: return .blue
        case 95, 96, 99: return .purple
        case 0: return .yellow
        default: return .secondary
        }
    }

    private func hourText(_ hour: Int) -> String {
        String(format: "%02d h", hour)
    }

    private func weekdayText(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            switch localizer.language {
            case .french: return "Aujourd'hui"
            case .english: return "Today"
            case .spanish: return "Hoy"
            }
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: localizer.language.rawValue)
        formatter.setLocalizedDateFormatFromTemplate("EEEE d MMMM")
        return formatter.string(from: date).capitalized
    }
}

struct DayForecastDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DayForecastDetailView(
                day: DailyForecast(
                    date: Date(),
                    weatherCode: 71,
                    highC: -2,
                    lowC: -9,
                    snowfallCm: 6.4,
                    precipitationProbability: 80,
                    hourly: (0..<24).map {
                        HourlyForecast(
                            hour: $0,
                            temperatureC: Double.random(in: -10...(-2)),
                            weatherCode: 71,
                            snowfallCm: [6, 7, 8, 14, 15, 16, 17].contains($0) ? Double.random(in: 0.3...2.5) : 0,
                            precipitationProbability: 70
                        )
                    }
                ),
                cityName: "Montréal"
            )
        }
        .environmentObject(Localizer())
        .environmentObject(ThemeManager())
    }
}
