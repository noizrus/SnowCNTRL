import SwiftUI

struct TierBadge: View {
    let tier: DataTier
    @EnvironmentObject private var localizer: Localizer

    var body: some View {
        Text(tier.label(for: localizer.language))
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tier.color.opacity(0.15))
            .foregroundStyle(tier.color)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(tier.color.opacity(0.6), lineWidth: 1))
            // A single cheap shadow, not the full 3-pass NeonGlow — this
            // badge can appear 100+ times in a scrolling list, where three
            // stacked shadows per row would visibly cost scroll performance.
            .shadow(color: tier.color.opacity(0.5), radius: 3)
    }
}

struct TierDisclaimerBanner: View {
    let tier: DataTier
    let cityName: String
    @EnvironmentObject private var localizer: Localizer

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(tier.color)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            Text(tier.disclaimer(cityName: cityName, language: localizer.language))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(tier.color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct TierBadgeViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(DataTier.allCases, id: \.self) { tier in
                VStack(alignment: .leading, spacing: 6) {
                    TierBadge(tier: tier)
                    TierDisclaimerBanner(tier: tier, cityName: "Montréal")
                }
            }
        }
        .padding()
        .environmentObject(Localizer())
        .previewLayout(.sizeThatFits)
    }
}
