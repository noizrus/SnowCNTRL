import SwiftUI

/// Stacks a few colored shadows at increasing radius/decreasing opacity to
/// fake a neon glow — SwiftUI has no native glow effect, this is the
/// standard trick (cheap enough for text and small shapes; avoid on large
/// views since each shadow pass re-renders the layer).
struct NeonGlow: ViewModifier {
    let color: Color
    var radius: CGFloat = 6

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.95), radius: radius * 0.25)
            .shadow(color: color.opacity(0.7), radius: radius * 0.6)
            .shadow(color: color.opacity(0.45), radius: radius)
    }
}

extension View {
    func neonGlow(_ color: Color, radius: CGFloat = 6) -> some View {
        modifier(NeonGlow(color: color, radius: radius))
    }
}
