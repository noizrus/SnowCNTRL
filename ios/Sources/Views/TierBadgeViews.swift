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
