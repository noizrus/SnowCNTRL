import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var localizer: Localizer
    @StateObject private var viewModel = DashboardViewModel()
    let city: City
    var onChangeCity: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                statusCard

                TierDisclaimerBanner(tier: city.tier, cityName: city.name)

                if let url = city.sourceURL {
                    Link(localizer.s(.dashboardLearnMore), destination: url)
                        .font(.footnote)
                }

                Spacer()
                AdBannerView()
                    .frame(height: 50)
            }
            .padding()
            .navigationTitle(city.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizer.s(.citySelectionChangeButton), action: onChangeCity)
                }
            }
            .task { await viewModel.load(city: city) }
            .refreshable { await viewModel.load(city: city) }
        }
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
