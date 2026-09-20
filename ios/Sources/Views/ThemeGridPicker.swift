import SwiftUI

/// Same chip-grid idiom as ProvinceGridPicker, one chip per theme, each
/// glowing in its own color so the picker itself previews the look.
struct ThemeGridPicker: View {
    @Binding var selection: AppTheme
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(AppTheme.allCases) { theme in
                let isSelected = selection == theme
                let color = theme.curatedPalette?.primary ?? (themeManager.province?.flagPalette.primary ?? .gray)

                Button {
                    selection = theme
                } label: {
                    HStack(spacing: 6) {
                        if theme == .automatic {
                            Image(systemName: "location.fill")
                                .font(.caption)
                        }
                        Text(theme.label(language: localizer.language))
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isSelected ? .white : .clear, lineWidth: 2)
                    )
                    .neonGlow(color, radius: isSelected ? 8 : 0)
                }
            }
        }
    }
}

struct ThemeGridPicker_Previews: PreviewProvider {
    static var previews: some View {
        ThemeGridPicker(selection: .constant(.aurora))
            .padding()
            .environmentObject(Localizer())
            .environmentObject(ThemeManager())
    }
}
