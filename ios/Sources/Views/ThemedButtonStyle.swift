import SwiftUI

/// Solid button in the theme's primary color, with black or white content
/// picked for contrast — readable on the map, in day and in night mode.
struct ThemedFillButtonStyle: ButtonStyle {
    let palette: ThemePalette
    var cornerRadius: CGFloat = 14
    var fillsWidth = true
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(palette.onPrimary)
            .padding(.vertical, 11)
            .padding(.horizontal, 14)
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(palette.primary)
            )
            .shadow(color: palette.primary.opacity(configuration.isPressed ? 0.2 : 0.45), radius: configuration.isPressed ? 2 : 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(isEnabled ? 1 : 0.4)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Secondary action next to a themed button (Annuler, Retirer…).
struct NeutralButtonStyle: ButtonStyle {
    var isDestructive = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isDestructive ? Color.red : Color.primary)
            .padding(.vertical, 11)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(configuration.isPressed ? .systemGray4 : .tertiarySystemBackground))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
