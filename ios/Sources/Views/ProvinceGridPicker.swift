import SwiftUI

/// Grid of province "chips" colored from each province's flag palette —
/// shared between onboarding and Settings so picking or changing a
/// province always looks and behaves the same way.
struct ProvinceGridPicker: View {
    @Binding var selection: ProvinceCode?
    @EnvironmentObject private var localizer: Localizer

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(ProvinceCode.allCases, id: \.self) { code in
                let palette = code.flagPalette
                let isSelected = selection == code
                Button {
                    selection = code
                } label: {
                    HStack(spacing: 4) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        Text(code.displayName(for: localizer.language))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.onPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(palette.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isSelected ? Color.primary : .clear, lineWidth: 3)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ProvinceGridPicker_Previews: PreviewProvider {
    static var previews: some View {
        ProvinceGridPicker(selection: .constant(.qc))
            .padding()
            .environmentObject(Localizer())
    }
}
