import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var premiumManager: PremiumManager
    @AppStorage("snowcntrl.dailyReminder") private var dailyReminderEnabled = false
    @AppStorage(CityStatusService.simulateBanKey) private var isSimulatingBan = false
    @AppStorage(AlertRingDuration.storageKey) private var alertRingDurationSeconds = AlertRingDuration.default.rawValue
    @State private var isShowingCityHelp = false
    @State private var isShowingWeather = false
    let selectedCity: City?
    @ObservedObject var citySelection: CitySelectionViewModel
    @Binding var selectedTab: MainTab

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        DefaultCityPickerView(viewModel: citySelection)
                    } label: {
                        HStack {
                            Label(localizer.s(.settingsDefaultCity), systemImage: "star.fill")
                            Spacer()
                            Text(citySelection.favoriteCity?.name ?? localizer.s(.settingsDefaultCityNone))
                                .foregroundStyle(.secondary)
                        }
                    }
                } footer: {
                    Text(localizer.s(.settingsDefaultCityHint))
                }

                Section(localizer.s(.settingsLanguage)) {
                    Picker(localizer.s(.settingsLanguage), selection: $localizer.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.nativeName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(localizer.s(.settingsAppearance)) {
                    Picker(localizer.s(.settingsAppearance), selection: $themeManager.appearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.label(language: localizer.language)).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(localizer.s(.settingsTheme)) {
                    ThemeGridPicker(selection: $themeManager.selectedTheme)
                        .padding(.vertical, 4)
                }

                Section {
                    Toggle(localizer.s(.settingsNotificationsToggle), isOn: $dailyReminderEnabled)
                        .onChange(of: dailyReminderEnabled) { enabled in
                            handleReminderToggle(enabled)
                        }
                    Text(localizer.s(.settingsNotificationsSubtitle))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(localizer.s(.settingsAlertDuration)) {
                    Picker(localizer.s(.settingsAlertDuration), selection: $alertRingDurationSeconds) {
                        ForEach(AlertRingDuration.allCases) { duration in
                            Text("\(duration.rawValue) s").tag(duration.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(localizer.s(.settingsAlertDurationHint))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    if premiumManager.isPremium {
                        Label(localizer.s(.settingsPremiumActive), systemImage: "checkmark.seal.fill")
                            .foregroundStyle(themeManager.palette.primaryText)
                    } else {
                        HStack {
                            Text(localizer.s(.settingsPremiumComingSoonTitle))
                            Spacer()
                            Text(localizer.s(.settingsPremiumComingSoonSubtitle))
                                .foregroundStyle(.secondary)
                        }
                    }
                    #if DEBUG
                    Toggle(localizer.s(.settingsPremiumDebugToggle), isOn: $premiumManager.isPremium)
                    #endif
                }

                #if DEBUG
                Section {
                    Toggle(localizer.s(.settingsSimulateBan), isOn: $isSimulatingBan)
                        .onChange(of: isSimulatingBan) { _ in
                            Task { await BackgroundRefreshManager.checkNow(language: localizer.language) }
                        }
                    Text(localizer.s(.settingsSimulateBanHint))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                #endif

                Section(localizer.s(.settingsAboutHeader)) {
                    Text(localizer.s(.settingsAboutBody))
                        .font(.footnote)
                    Text(localizer.s(.settingsContactPrefix) + SupportConfig.contactEmail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    NavigationLink(localizer.s(.settingsPrivacyPolicy)) {
                        LegalDocumentView(
                            title: localizer.s(.settingsPrivacyPolicy),
                            body_: LegalTexts.privacyPolicy(language: localizer.language, contactEmail: SupportConfig.contactEmail)
                        )
                    }
                    NavigationLink(localizer.s(.settingsTermsOfUse)) {
                        LegalDocumentView(
                            title: localizer.s(.settingsTermsOfUse),
                            body_: LegalTexts.termsOfUse(language: localizer.language, contactEmail: SupportConfig.contactEmail)
                        )
                    }
                }

                Section {
                    Text(localizer.s(.settingsVersionPrefix) + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(localizer.s(.settingsTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SnowCntrlBrandmark()
                }
            }
            .themedNavigationBar(themeManager.palette)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                MainBottomBar(
                    selectedTab: $selectedTab,
                    onShowTowedHelp: { isShowingCityHelp = true },
                    onShowWeather: { isShowingWeather = true }
                )
            }
            // Pushed (not sheeted) so the bottom bar stays visible
            // underneath, same reasoning as Dashboard's own "Aide".
            .navigationDestination(isPresented: $isShowingCityHelp) {
                if let selectedCity {
                    CityHelpView(city: selectedCity)
                }
            }
            .navigationDestination(isPresented: $isShowingWeather) {
                if let selectedCity {
                    WeatherForecastView(city: selectedCity)
                }
            }
        }
        .tint(themeManager.palette.primaryText)
    }

    private func handleReminderToggle(_ enabled: Bool) {
        guard enabled else {
            NotificationScheduler.cancelDailyReminder()
            return
        }
        Task {
            let granted = await NotificationScheduler.requestAuthorizationIfNeeded()
            guard granted, let city = selectedCity else {
                dailyReminderEnabled = false
                return
            }
            NotificationScheduler.scheduleDailyReminder(cityName: city.name, language: localizer.language)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(selectedCity: CitiesData.all.first { $0.id == "montreal" }, citySelection: CitySelectionViewModel(), selectedTab: .constant(.settings))
            .environmentObject(Localizer())
            .environmentObject(ThemeManager())
            .environmentObject(PremiumManager())
    }
}
