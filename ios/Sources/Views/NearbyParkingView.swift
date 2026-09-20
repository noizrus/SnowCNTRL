import SwiftUI
import MapKit

/// Sheet shown from the dashboard's "Where to park?" button. Uses Apple
/// Maps' own points of interest, so it works in all 114 cities even though
/// the ban status itself is only available for a handful of them.
struct NearbyParkingView: View {
    @EnvironmentObject private var localizer: Localizer
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    let coordinate: CLLocationCoordinate2D

    @State private var lots: [NearbyParkingLot] = []
    @State private var isSearching = true

    var body: some View {
        NavigationStack {
            Group {
                if isSearching {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text(localizer.s(.nearbyParkingSearching))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if lots.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "parkingsign.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text(localizer.s(.nearbyParkingEmpty))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            Text(localizer.s(.nearbyParkingSubtitle))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        ForEach(lots) { lot in
                            Button {
                                lot.mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                            } label: {
                                HStack {
                                    Image(systemName: "parkingsign.circle.fill")
                                        .foregroundStyle(themeManager.palette.primary)
                                        .font(.title2)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(lot.name)
                                            .foregroundStyle(.primary)
                                        Text(localizer.s(.nearbyParkingOpenInMaps))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(distanceLabel(lot.distanceMeters))
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(localizer.s(.nearbyParkingTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .tint(themeManager.palette.primary)
        .task {
            lots = await NearbyParkingFinder.search(near: coordinate)
            isSearching = false
        }
    }

    private func distanceLabel(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: localizer.s(.nearbyParkingDistanceKm), meters / 1000)
        }
        return String(format: localizer.s(.nearbyParkingDistanceMeters), Int(meters))
    }
}

struct NearbyParkingView_Previews: PreviewProvider {
    static var previews: some View {
        NearbyParkingView(coordinate: CLLocationCoordinate2D(latitude: 45.5019, longitude: -73.5674))
            .environmentObject(Localizer())
            .environmentObject(ThemeManager())
    }
}
