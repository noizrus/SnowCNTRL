import SwiftUI

/// "My car was towed?" — the city's official lookup page and the numbers to
/// call, for the city currently shown.
struct CityHelpView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    let city: City

    private var entry: CityHelp.Entry? { CityHelp.entry(for: city) }
    private var lookupURL: URL? { entry?.towedVehicleURL ?? city.sourceURL }
    /// Always offered next to "Voiture remorquée ?", not just when the city
    /// has no verified towing number — a missing/incorrect snow-ban sign is
    /// a separate problem from not knowing who to call about a tow. Prefers
    /// the city's own 311/services line (a real way to reach them) over
    /// just linking their website.
    private var reportSignageURL: URL? {
        entry?.contacts.first { $0.kind == .cityServices }?.dialURL ?? city.sourceURL
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label(localizer.s(.helpMovedNearbyTip), systemImage: "car.2.fill")
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let lookupURL {
                    Section {
                        Link(destination: lookupURL) {
                            Label(
                                localizer.s(entry?.towedVehicleURL != nil ? LocKey.helpFindMyCar : LocKey.helpCityWebsite),
                                systemImage: "magnifyingglass"
                            )
                        }
                        .buttonStyle(ThemedFillButtonStyle(palette: themeManager.palette))
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                }

                if let reportSignageURL {
                    Section {
                        Link(destination: reportSignageURL) {
                            Label(localizer.s(.helpReportSignageIssue), systemImage: "exclamationmark.bubble.fill")
                        }
                        .buttonStyle(NeutralButtonStyle())
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                }

                Section(localizer.s(.helpContactsTitle)) {
                    if let contacts = entry?.contacts, !contacts.isEmpty {
                        ForEach(contacts) { contact in
                            callRow(title: localizer.s(contact.kind.labelKey), number: contact.number, url: contact.dialURL)
                        }
                    } else {
                        Text(localizer.s(.helpNoVerifiedNumber))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    callRow(title: localizer.s(.helpEmergency), number: "911", url: URL(string: "tel:911"), isEmergency: true)
                }

                Section {
                    Text(localizer.s(.helpSourceNote))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .navigationTitle(localizer.s(.helpTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text(localizer.s(.helpTitle))
                            .font(.headline)
                            .foregroundStyle(themeManager.palette.onAccent)
                        Text(city.name)
                            .font(.caption)
                            .foregroundStyle(themeManager.palette.onAccent.opacity(0.75))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(themeManager.palette.onAccent)
                    }
                }
            }
            .themedNavigationBar(themeManager.palette)
        }
        .tint(themeManager.palette.primaryText)
    }

    private func callRow(title: String, number: String, url: URL?, isEmergency: Bool = false) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                Text(number)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(isEmergency ? Color.red : Color.primary)
            }
            Spacer()
            if let url {
                Link(destination: url) {
                    Image(systemName: "phone.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(isEmergency ? Color.white : themeManager.palette.onPrimary)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(isEmergency ? Color.red : themeManager.palette.primary))
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("\(title) \(number)")
            }
        }
    }
}

struct CityHelpView_Previews: PreviewProvider {
    static var previews: some View {
        CityHelpView(city: CitiesData.all.first { $0.id == "montreal" }!)
            .environmentObject(Localizer())
            .environmentObject(ThemeManager())
    }
}
