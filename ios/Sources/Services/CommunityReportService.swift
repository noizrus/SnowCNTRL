import Foundation
import CloudKit

enum CommunityReportState: String {
    case cleared
    case stillActive
}

/// Crowdsourced cross-check on the city-wide status: since no city
/// publishes a per-street feed, and the official data can lag or go stale,
/// this lets people confirm what they're actually seeing on their own
/// street right now — a signal the official data alone can't give.
///
/// Stored in CloudKit's PUBLIC database (shared across every install), not
/// a custom server: the app already has no backend of its own, and Apple's
/// free-tier CloudKit fits the same "no infrastructure to run" approach
/// used for weather (Open-Meteo) and everything else here.
enum CommunityReportService {
    private static let containerIdentifier = "iCloud.com.snowcntrl.app"
    private static let recordType = "CommunityReport"
    /// Reports older than this don't reflect "right now" any more.
    private static let relevantWindow: TimeInterval = 6 * 60 * 60
    /// One report per city per device in this window — a soft, honor-system
    /// limit (there's no server-side auth here to enforce it harder), just
    /// enough that one person's repeated taps can't dominate the tally.
    private static let cooldown: TimeInterval = 60 * 60

    private static var container: CKContainer { CKContainer(identifier: containerIdentifier) }
    private static var database: CKDatabase { container.publicCloudDatabase }

    struct Tally {
        let clearedCount: Int
        let activeCount: Int
    }

    static func canReport(cityID: String) -> Bool {
        guard let last = lastReportDate(for: cityID) else { return true }
        return Date().timeIntervalSince(last) >= cooldown
    }

    /// Requires the device to be signed into iCloud (Apple's default public
    /// database security only allows writes from authenticated accounts) —
    /// fails silently to `false` otherwise, same "no crash, just no report"
    /// philosophy as every other optional feature in this app.
    @discardableResult
    static func submitReport(cityID: String, state: CommunityReportState) async -> Bool {
        guard canReport(cityID: cityID) else { return false }
        guard let status = try? await container.accountStatus(), status == .available else { return false }

        let record = CKRecord(recordType: recordType)
        record["cityID"] = cityID
        record["state"] = state.rawValue

        guard (try? await database.save(record)) != nil else { return false }
        setLastReportDate(Date(), for: cityID)
        return true
    }

    /// `nil` on any failure (offline, schema not ready yet, no iCloud) —
    /// callers just show nothing rather than an error for what's an
    /// optional, best-effort signal.
    static func tally(for cityID: String) async -> Tally? {
        let since = Date().addingTimeInterval(-relevantWindow)
        let predicate = NSPredicate(format: "cityID == %@ AND creationDate > %@", cityID, since as NSDate)
        let query = CKQuery(recordType: recordType, predicate: predicate)

        guard let result = try? await database.records(matching: query) else { return nil }
        var cleared = 0
        var active = 0
        for (_, recordResult) in result.matchResults {
            guard let record = try? recordResult.get(), let raw = record["state"] as? String else { continue }
            switch raw {
            case CommunityReportState.cleared.rawValue: cleared += 1
            case CommunityReportState.stillActive.rawValue: active += 1
            default: break
            }
        }
        return Tally(clearedCount: cleared, activeCount: active)
    }

    private static func lastReportDate(for cityID: String) -> Date? {
        UserDefaults.standard.object(forKey: cooldownKey(cityID)) as? Date
    }

    private static func setLastReportDate(_ date: Date, for cityID: String) {
        UserDefaults.standard.set(date, forKey: cooldownKey(cityID))
    }

    private static func cooldownKey(_ cityID: String) -> String {
        "snowcntrl.communityReport.lastDate.\(cityID)"
    }
}
