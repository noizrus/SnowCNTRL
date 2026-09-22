import SwiftUI

/// The permanent "SNOW CNTRL" wordmark shown top-left across the main
/// screens — glows in the current theme's accent color.
struct SnowCntrlBrandmark: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Text("SNOW CNTRL")
            .font(.system(.caption2, design: .rounded).weight(.heavy))
            .tracking(0.6)
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(themeManager.palette.accent)
            .neonGlow(themeManager.palette.accent, radius: 3)
    }
}

struct SnowCntrlBrandmark_Previews: PreviewProvider {
    static var previews: some View {
        SnowCntrlBrandmark()
            .padding()
            .background(Color.black)
            .environmentObject(ThemeManager())
    }
}
