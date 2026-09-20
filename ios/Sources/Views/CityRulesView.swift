import SwiftUI

/// Plain-language explanation of how the local ban system usually works,
/// shown on top of (not instead of) the tier disclaimer and the official
/// source link.
struct CityRulesView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    let city: City

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let summary = CityRules.summary(for: city.id, language: localizer.language) {
                        Text(summary)
                            .font(.body)
                    } else {
                        Text(localizer.s(.cityRulesUnavailable))
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    if let url = city.sourceURL {
                        Link(destination: url) {
                            Label(localizer.s(.dashboardLearnMore), systemImage: "arrow.up.right.square")
                        }
                        .font(.subheadline.weight(.semibold))
                    }

                    Divider()

                    Text(localizer.s(.cityRulesFooter))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
            }
            .navigationTitle(localizer.s(.cityRulesTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .tint(themeManager.palette.primary)
    }
}

struct CityRulesView_Previews: PreviewProvider {
    static var previews: some View {
        let montreal = CitiesData.all.first { $0.id == "montreal" }!
        CityRulesView(city: montreal)
            .environmentObject(Localizer())
            .environmentObject(ThemeManager())
    }
}
