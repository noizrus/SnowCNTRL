import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    var onFinished: () -> Void

    private var provinceBinding: Binding<ProvinceCode?> {
        Binding(get: { themeManager.province }, set: { themeManager.province = $0 })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Picker(localizer.s(.languagePickerTitle), selection: $localizer.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.nativeName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(localizer.s(.onboardingWelcomeTitle))
                        .font(.largeTitle.bold())

                    Text(localizer.s(.onboardingProvincePrompt))
                        .font(.headline)
                    ProvinceGridPicker(selection: provinceBinding)

                    if let province = themeManager.province {
                        provinceCitiesPreview(for: province)
                    }

                    Text(
                        localizer.s(.onboardingIndependentDevNotice)
                            .replacingOccurrences(of: "%EMAIL%", with: SupportConfig.contactEmail)
                    )
                    .font(.body)

                    Divider()

                    Text(localizer.s(.onboardingLegalDisclaimer))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 6) {
                    if themeManager.province == nil {
                        Text(localizer.s(.onboardingProvinceRequired))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Button {
                        onFinished()
                    } label: {
                        Text(localizer.s(.onboardingAcceptButton))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(themeManager.province == nil)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .tint(themeManager.palette.primary)
    }

    /// Shown right after picking a province: which of its cities have
    /// reliable live data versus none at all, so expectations are set
    /// before the user ever picks an address.
    private func provinceCitiesPreview(for province: ProvinceCode) -> some View {
        let cities = CitiesData.all
            .filter { $0.province == province }
            .sorted { $0.tier.sortOrder < $1.tier.sortOrder || ($0.tier.sortOrder == $1.tier.sortOrder && $0.name < $1.name) }

        return VStack(alignment: .leading, spacing: 8) {
            Text(localizer.s(.onboardingCitiesPreviewTitle))
                .font(.subheadline.weight(.semibold))

            VStack(spacing: 0) {
                ForEach(cities) { city in
                    HStack {
                        Text(city.name)
                            .font(.subheadline)
                        Spacer()
                        TierBadge(tier: city.tier)
                    }
                    .padding(.vertical, 6)
                    if city.id != cities.last?.id {
                        Divider()
                    }
                }
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onFinished: {})
            .environmentObject(Localizer())
            .environmentObject(ThemeManager())
    }
}
