import SwiftUI
import MapKit

struct DashboardView: View {
    @EnvironmentObject private var localizer: Localizer
    @StateObject private var viewModel = DashboardViewModel()
    @ObservedObject private var addressStore = AddressStore.shared
    @State private var isPresentingMap = false
    let city: City
    var onChangeCity: () -> Void

    private var myAddress: SavedAddress? {
        addressStore.addresses.first { $0.cityID == city.id }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    myStreetCard

                    statusCard

                    TierDisclaimerBanner(tier: city.tier, cityName: city.name)

                    if let url = city.sourceURL {
                        Link(localizer.s(.dashboardLearnMore), destination: url)
                            .font(.footnote)
                    }

                    AdBannerView()
                        .frame(height: 50)
                }
                .padding()
            }
            .navigationTitle(city.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizer.s(.citySelectionChangeButton), action: onChangeCity)
                }
            }
            .task { await viewModel.load(city: city) }
            .refreshable { await viewModel.load(city: city) }
            .sheet(isPresented: $isPresentingMap) {
                AddressMapView(city: city, existing: myAddress) { saved in
                    addressStore.upsert(saved)
                    if saved.alertsEnabled, city.liveProviderID == nil {
                        NotificationScheduler.scheduleDailyReminder(cityName: city.name, language: localizer.language)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var myStreetCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let address = myAddress {
                Map(
                    coordinateRegion: .constant(
                        MKCoordinateRegion(center: address.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    ),
                    interactionModes: [],
                    annotationItems: [address]
                ) { item in
                    MapMarker(coordinate: item.coordinate, tint: city.tier.color)
                }
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .allowsHitTesting(false)

                HStack {
                    VStack(alignment: .leading) {
                        Text(address.label).font(.subheadline.weight(.semibold))
                        Text(localizer.s(.myStreetAlertsCaption))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { address.alertsEnabled },
                        set: { addressStore.setAlertsEnabled($0, for: address) }
                    ))
                    .labelsHidden()
                }

                Button(localizer.s(.myStreetEditButton)) { isPresentingMap = true }
                    .font(.footnote)
            } else {
                Button {
                    isPresentingMap = true
                } label: {
                    Label(localizer.s(.myStreetPickPrompt), systemImage: "mappin.and.ellipse")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private var statusCard: some View {
        VStack(spacing: 10) {
            if viewModel.isLoading {
                ProgressView(localizer.s(.dashboardLoading))
            } else if let result = viewModel.result {
                statusRow(for: result)
            }

            Button(localizer.s(.dashboardRefreshButton)) {
                Task { await viewModel.load(city: city) }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func statusRow(for result: CityStatusResult) -> some View {
        let (icon, text, color): (String, String, Color) = {
            switch result.state {
            case .activeBanNow:
                return ("exclamationmark.triangle.fill", localizer.s(.dashboardStatusActive), .red)
            case .noActiveBan:
                return ("checkmark.circle.fill", localizer.s(.dashboardStatusInactive), .green)
            case .unknownNoData:
                return ("questionmark.circle.fill", localizer.s(.dashboardStatusUnknown), .secondary)
            }
        }()

        return VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(color)
            Text(text)
                .font(.headline)
                .multilineTextAlignment(.center)
            if let asOf = result.asOf {
                Text(localizer.s(.dashboardLastUpdatedPrefix) + asOf.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
