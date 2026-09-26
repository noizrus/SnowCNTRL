import SwiftUI

/// 14-day forecast for the city currently shown — useful next to a
/// snow-clearing ban tracker precisely because it says whether more snow
/// (and therefore another ban) is coming. Tapping a day pushes an hourly
/// breakdown (`DayForecastDetailView`). Always pushed into the presenting
/// screen's own `NavigationStack` (see `CityHelpView`), so the bottom bar
/// stays visible underneath.
struct WeatherForecastView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    let city: City
    @State private var forecast: [DailyForecast]?
    @State private var loadFailed = false

    private var totalSnowCm: Double {
        (forecast ?? []).reduce(0) { $0 + $1.snowfallCm }
    }

    private var maxDailySnowCm: Double {
        (forecast ?? []).map(\.snowfallCm).max() ?? 0
    }

    var body: some View {
        Group {
            if let forecast {
                List {
                    if totalSnowCm >= 0.1 {
                        Section {
                            HStack {
                                Image(systemName: "snowflake")
                                    .foregroundStyle(themeManager.palette.primary)
                                Text(localizer.s(.weatherSnowThisWeek))
                                Spacer()
                                Text(snowAmountText(totalSnowCm))
                                    .font(.headline.monospacedDigit())
                                    .foregroundStyle(themeManager.palette.primaryText)
                            }
                        }
                    }
                    Section {
                        ForEach(forecast) { day in
                            NavigationLink {
                                DayForecastDetailView(day: day, cityName: city.name)
                            } label: {
                                dayRow(day)
                            }
                        }
                    } footer: {
                        Text(localizer.s(.weatherHourlyHint))
                    }
                }
            } else if loadFailed {
                errorView
            } else {
                loadingView
            }
        }
        .navigationTitle(localizer.s(.weatherTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(localizer.s(.weatherTitle))
                        .font(.headline)
                        .foregroundStyle(themeManager.palette.onAccent)
                    Text(city.name)
                        .font(.caption)
                        .foregroundStyle(themeManager.palette.onAccent.opacity(0.75))
                }
            }
        }
        .themedNavigationBar(themeManager.palette)
        .tint(themeManager.palette.primaryText)
        .task {
            guard forecast == nil else { return }
            if let result = await WeatherService.forecast(for: city) {
                forecast = result
            } else {
                loadFailed = true
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(localizer.s(.weatherLoading))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorView: some View {
        VStack(spacing: 8) {
            Image(systemName: "cloud.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(localizer.s(.weatherError))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func dayRow(_ day: DailyForecast) -> some View {
        HStack(spacing: 12) {
            Image(systemName: WeatherCode.symbolName(for: day.weatherCode))
                .font(.title2)
                .foregroundStyle(iconColor(for: day.weatherCode))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(weekdayText(day.date))
                    .font(.subheadline.weight(.semibold))
                Text(WeatherCode.label(for: day.weatherCode, language: localizer.language))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                if day.snowfallCm >= 0.1 {
                    snowIntensityBar(cm: day.snowfallCm)
                }
            }
            Spacer(minLength: 8)
            if day.snowfallCm >= 0.1 {
                Label(String(format: "%.1f cm", day.snowfallCm), systemImage: "snowflake")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(themeManager.palette.primaryText)
                    .lineLimit(1)
            }
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(day.highC.rounded()))°")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                Text("\(Int(day.lowC.rounded()))°")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 32, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }

    /// Snow amount relative to the biggest day in the whole forecast, so the
    /// list reads at a glance like a mini bar chart of "which days matter".
    private func snowIntensityBar(cm: Double) -> some View {
        GeometryReader { geo in
            let fraction = maxDailySnowCm > 0 ? min(1, cm / maxDailySnowCm) : 0
            Capsule()
                .fill(themeManager.palette.primary.opacity(0.18))
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(themeManager.palette.primary)
                        .frame(width: geo.size.width * fraction)
                }
        }
        .frame(height: 4)
        .frame(maxWidth: 90)
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
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        return formatter.string(from: date).capitalized
    }

    private func snowAmountText(_ cm: Double) -> String {
        localizer.s(.weatherSnowAmount).replacingOccurrences(of: "%CM%", with: String(format: "%.1f", cm))
    }
}

struct WeatherForecastView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeatherForecastView(city: CitiesData.all.first { $0.id == "montreal" }!)
        }
        .environmentObject(Localizer())
        .environmentObject(ThemeManager())
    }
}
