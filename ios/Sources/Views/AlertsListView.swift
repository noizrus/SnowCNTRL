import SwiftUI
import MapKit

/// The favorites list opened from the top-left button — same idea as
/// Info-Neige's own list icon: every alert in one place, tap to jump to
/// it on the map. Deleting is a visible trash button on every row (plus
/// the standard swipe-to-delete), not just a hidden gesture.
struct AlertsListView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    let alerts: [SavedAddress]
    let currentStatus: SnowClearingStatus
    var onSelect: (SavedAddress) -> Void
    var onRemove: (SavedAddress) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if alerts.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "bell.slash")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text(localizer.s(.alertsEmptyHint))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(alerts) { alert in
                            HStack(spacing: 12) {
                                Button {
                                    dismiss()
                                    onSelect(alert)
                                } label: {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(currentStatus.neonColor)
                                            .frame(width: 12, height: 12)
                                            .shadow(color: currentStatus.neonColor, radius: 4)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(alert.label)
                                                .foregroundStyle(.primary)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Text(currentStatus.label(language: localizer.language))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)

                                Spacer(minLength: 8)

                                // A visible delete button on every row, not
                                // just the swipe gesture — easy to find, not
                                // something the user has to discover.
                                Button {
                                    onRemove(alert)
                                } label: {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.red, Color.red.opacity(0.15))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(localizer.s(.alertRemove))
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    onRemove(alert)
                                } label: {
                                    Label(localizer.s(.alertRemove), systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(localizer.s(.alertsListTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SnowCntrlBrandmark()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(themeManager.palette.onAccent)
                    }
                }
            }
            .themedNavigationBar(themeManager.palette)
        }
        .tint(themeManager.palette.primaryText)
    }
}

struct AlertsListView_Previews: PreviewProvider {
    static var previews: some View {
        AlertsListView(
            alerts: [SavedAddress(label: "6702 Rue Saint-Denis — côté est", coordinate: CLLocationCoordinate2D(latitude: 45.53, longitude: -73.6), cityID: "montreal")],
            currentStatus: .cleared,
            onSelect: { _ in },
            onRemove: { _ in }
        )
        .environmentObject(Localizer())
        .environmentObject(ThemeManager())
    }
}
