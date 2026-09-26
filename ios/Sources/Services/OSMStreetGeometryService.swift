import Foundation
import MapKit

/// Real street geometry from OpenStreetMap (Overpass API), loaded by map
/// tile on demand. Works in every city with no API key, which is what
/// makes the glow lines follow the actual roads instead of a made-up grid.
///
/// Before a wide public launch, point `OverpassClient.endpoints` at a
/// self-hosted Overpass or a paid provider — the public instances are
/// rate-limited and meant for low-volume use.
@MainActor
final class OSMStreetGeometryService {
    static let shared = OSMStreetGeometryService()

    private static let tileSize = 0.01
    private static let maxCachedBlocks = 40_000
    /// Past this span (well beyond even a whole metro area) the tile grid
    /// itself would be millions of cells — computing and fetching that would
    /// freeze the app. Lines already loaded stay on screen; the map just
    /// stops asking for more until zoomed back in. No message shown either
    /// way — the lines (or their absence) speak for themselves.
    private static let maxFetchSpanDegrees: CLLocationDegrees = 2.0

    private struct TileKey: Hashable {
        let x: Int
        let y: Int
    }

    private var blocksByID: [String: StreetBlock] = [:]
    private var blockIDsByWay: [Int: [String]] = [:]
    private var loadedTiles: Set<TileKey> = []
    private var pending: [TileKey: Task<Void, Never>] = [:]

    func blocks(in region: MKCoordinateRegion) async -> [StreetBlock] {
        if region.span.latitudeDelta <= Self.maxFetchSpanDegrees {
            let wanted = Self.tiles(covering: region)
            let toFetch = wanted.filter { !loadedTiles.contains($0) && pending[$0] == nil }
            if !toFetch.isEmpty {
                let box = Self.boundingBox(of: toFetch)
                // Unstructured so a fetch already started completes and gets
                // cached even if the caller's task is cancelled by more panning.
                let task = Task {
                    let fetched = await OverpassClient.fetchBlocks(south: box.south, west: box.west, north: box.north, east: box.east)
                    self.store(fetched, for: toFetch)
                }
                for tile in toFetch { pending[tile] = task }
            }

            for task in Set(wanted.compactMap { pending[$0] }) {
                await task.value
            }
        }

        let visible = Self.mapRect(for: region)
        let margin = visible.size.width * 0.15
        let area = visible.insetBy(dx: -margin, dy: -margin)
        return blocksByID.values.filter { $0.bounds.intersects(area) }
    }

    private func store(_ fetched: [StreetBlock]?, for tiles: Set<TileKey>) {
        for tile in tiles { pending[tile] = nil }
        guard let fetched else { return }

        if blocksByID.count > Self.maxCachedBlocks {
            blocksByID.removeAll()
            blockIDsByWay.removeAll()
            loadedTiles.removeAll()
        }

        // A way fetched again (overlapping tiles) replaces its old blocks,
        // since intersection splitting can differ between fetches.
        let byWay = Dictionary(grouping: fetched, by: \.wayID)
        for (wayID, blocks) in byWay {
            for oldID in blockIDsByWay[wayID] ?? [] { blocksByID[oldID] = nil }
            for block in blocks { blocksByID[block.id] = block }
            blockIDsByWay[wayID] = blocks.map(\.id)
        }
        loadedTiles.formUnion(tiles)
    }

    private static func tiles(covering region: MKCoordinateRegion) -> Set<TileKey> {
        let south = region.center.latitude - region.span.latitudeDelta / 2
        let north = region.center.latitude + region.span.latitudeDelta / 2
        let west = region.center.longitude - region.span.longitudeDelta / 2
        let east = region.center.longitude + region.span.longitudeDelta / 2
        let minX = Int((west / tileSize).rounded(.down))
        let maxX = Int((east / tileSize).rounded(.down))
        let minY = Int((south / tileSize).rounded(.down))
        let maxY = Int((north / tileSize).rounded(.down))
        var tiles = Set<TileKey>()
        for x in minX...maxX {
            for y in minY...maxY {
                tiles.insert(TileKey(x: x, y: y))
            }
        }
        return tiles
    }

    private static func boundingBox(of tiles: Set<TileKey>) -> (south: Double, west: Double, north: Double, east: Double) {
        let xs = tiles.map(\.x)
        let ys = tiles.map(\.y)
        return (
            south: Double(ys.min()!) * tileSize,
            west: Double(xs.min()!) * tileSize,
            north: Double(ys.max()! + 1) * tileSize,
            east: Double(xs.max()! + 1) * tileSize
        )
    }

    private static func mapRect(for region: MKCoordinateRegion) -> MKMapRect {
        let topLeft = MKMapPoint(CLLocationCoordinate2D(
            latitude: region.center.latitude + region.span.latitudeDelta / 2,
            longitude: region.center.longitude - region.span.longitudeDelta / 2
        ))
        let bottomRight = MKMapPoint(CLLocationCoordinate2D(
            latitude: region.center.latitude - region.span.latitudeDelta / 2,
            longitude: region.center.longitude + region.span.longitudeDelta / 2
        ))
        return MKMapRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y)
    }
}

/// Network + parsing, kept off the main actor.
enum OverpassClient {
    static let endpoints = [
        URL(string: "https://overpass-api.de/api/interpreter")!,
        URL(string: "https://overpass.kumi.systems/api/interpreter")!,
    ]

    private struct Response: Decodable {
        struct Point: Decodable {
            let lat: Double
            let lon: Double
        }

        struct Element: Decodable {
            let type: String
            let id: Int
            let tags: [String: String]?
            let nodes: [Int]?
            let geometry: [Point?]?
        }

        let elements: [Element]
    }

    static func fetchBlocks(south: Double, west: Double, north: Double, east: Double) async -> [StreetBlock]? {
        // Streets where people park; motorways, service lanes and alleys
        // (ruelles) are left out, like on Info-Neige.
        let query = """
        [out:json][timeout:25];
        way["highway"~"^(primary|secondary|tertiary|unclassified|residential|living_street)$"](\(south),\(west),\(north),\(east));
        out body geom;
        """
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let body = "data=\(encoded)".data(using: .utf8)
        else { return nil }

        for endpoint in endpoints {
            var request = URLRequest(url: endpoint, timeoutInterval: 30)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("SnowCNTRL-iOS/0.1", forHTTPHeaderField: "User-Agent")
            request.httpBody = body

            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let blocks = parseBlocks(from: data)
            else { continue }
            return blocks
        }
        return nil
    }

    /// Overpass JSON (`out body geom`) → street blocks. Separate from the
    /// network call so it can be tested with a fixture.
    static func parseBlocks(from data: Data) -> [StreetBlock]? {
        guard let decoded = try? JSONDecoder().decode(Response.self, from: data) else { return nil }
        return buildBlocks(from: decoded.elements)
    }

    /// Splits each OSM way into blocks at intersections (nodes shared with
    /// another way), so a side of a street is one block long like on
    /// Info-Neige rather than the whole length of the street.
    private static func buildBlocks(from elements: [Response.Element]) -> [StreetBlock] {
        let ways = elements.filter { $0.type == "way" }
        var nodeUse: [Int: Int] = [:]
        for way in ways {
            for node in way.nodes ?? [] {
                nodeUse[node, default: 0] += 1
            }
        }

        var blocks: [StreetBlock] = []
        for way in ways {
            let geometry = way.geometry ?? []
            let points = geometry.compactMap { $0 }.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) }
            guard points.count >= 2 else { continue }
            let nodes = way.nodes ?? []
            let canSplit = nodes.count == points.count && geometry.count == points.count
            let tags = way.tags ?? [:]
            let offset = curbOffsetMeters(tags: tags)

            var current: [CLLocationCoordinate2D] = []
            var index = 0
            func flush() {
                guard current.count >= 2, length(of: current) >= 6 else { return }
                blocks.append(StreetBlock(
                    id: "osm-\(way.id)-\(index)",
                    wayID: way.id,
                    centerline: current,
                    streetName: tags["name"],
                    curbOffsetMeters: offset
                ))
                index += 1
            }

            for (i, point) in points.enumerated() {
                current.append(point)
                let isInterior = i > 0 && i < points.count - 1
                if canSplit, isInterior, nodeUse[nodes[i], default: 0] >= 2 {
                    flush()
                    current = [point]
                }
            }
            flush()
        }
        return blocks
    }

    private static func curbOffsetMeters(tags: [String: String]) -> Double {
        if let widthTag = tags["width"],
           let width = Double(widthTag.split(separator: " ").first ?? ""),
           width > 3 {
            return max(2.5, width / 2 - 0.5)
        }
        switch tags["highway"] {
        case "primary": return 9
        case "secondary": return 7.5
        case "tertiary": return 6
        case "unclassified": return 5
        case "living_street": return 3.5
        default: return 4.5
        }
    }

    private static func length(of points: [CLLocationCoordinate2D]) -> Double {
        zip(points, points.dropFirst()).reduce(0.0) { total, pair in
            total + MKMapPoint(pair.0).distance(to: MKMapPoint(pair.1))
        }
    }
}
