import SwiftUI

/// The permanent "SNOW CNTRL" wordmark shown top-left across the main
/// screens — glows in the current theme's accent color.
struct SnowCntrlBrandmark: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Text("SNOW CNTRL")
            .font(.system(.footnote, design: .rounded).weight(.heavy))
            .tracking(1.2)
            .foregroundStyle(themeManager.palette.accent)
            .neonGlow(themeManager.palette.accent, radius: 5)
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
