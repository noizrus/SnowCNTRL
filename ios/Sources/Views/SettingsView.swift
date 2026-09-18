import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var localizer: Localizer
    @AppStorage("snowcntrl.dailyReminder") private var dailyReminderEnabled = false
    let selectedCity: City?

    var body: some View {
        NavigationStack {
            Form {
                Section(localizer.s(.settingsLanguage)) {
                    Picker(localizer.s(.settingsLanguage), selection: $localizer.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.nativeName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
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

                Section {
                    HStack {
                        Text(localizer.s(.settingsPremiumComingSoonTitle))
                        Spacer()
                        Text(localizer.s(.settingsPremiumComingSoonSubtitle))
                            .foregroundStyle(.secondary)
                    }
                }
                .disabled(true)

                Section(localizer.s(.settingsAboutHeader)) {
                    Text(localizer.s(.settingsAboutBody))
                        .font(.footnote)
                    Text(localizer.s(.settingsContactPrefix) + SupportConfig.contactEmail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Text(localizer.s(.settingsVersionPrefix) + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(localizer.s(.settingsTitle))
        }
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
