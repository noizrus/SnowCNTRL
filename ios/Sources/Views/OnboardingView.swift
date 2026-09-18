import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var localizer: Localizer
    var onFinished: () -> Void

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
                Button {
                    onFinished()
                } label: {
                    Text(localizer.s(.onboardingAcceptButton))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onFinished: {})
            .environmentObject(Localizer())
    }
}
