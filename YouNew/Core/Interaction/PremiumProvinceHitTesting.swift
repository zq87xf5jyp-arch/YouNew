import SwiftUI

/// Hit testing for the compact Netherlands province map.
///
/// Exact province paths and their boundary segments are cached in normalized
/// coordinates. A hit only has to normalize the touch point; it does not
/// rebuild all twelve rendered paths on every gesture update.
enum PremiumProvinceHitTesting {
    static func hitTest(
        _ point: CGPoint,
        in mapRect: CGRect,
        minimumTouchSize: CGFloat = AppButtonMetrics.minTouchSize,
        fallbackTolerance: CGFloat = 10
    ) -> String? {
        guard point.x.isFinite,
              point.y.isFinite,
              isUsable(mapRect)
        else { return nil }

        let normalizedPoint = CGPoint(
            x: (point.x - mapRect.minX) / mapRect.width,
            y: (point.y - mapRect.minY) / mapRect.height
        )

        // Exact containment is authoritative across the entire map. This pass
        // deliberately happens before any forgiving target is considered, so
        // an expanded small-province target can never steal a neighboring tap.
        var exactMatch: NormalizedProvinceGeometry?
        for geometry in cache.geometries where geometry.normalizedPath.contains(normalizedPoint) {
            if exactMatch.map({ prefersExactMatch(geometry, $0) }) ?? true {
                exactMatch = geometry
            }
        }
        if let exactMatch {
            return exactMatch.provinceID
        }

        let touchSize = sanitizedNonnegative(
            minimumTouchSize,
            fallback: AppButtonMetrics.minTouchSize
        )
        let tolerance = sanitizedNonnegative(fallbackTolerance, fallback: 0)

        var bestFallback: FallbackCandidate?
        for geometry in cache.geometries {
            let naturalBounds = projectedBounds(geometry.normalizedBounds, in: mapRect)
            let minimumExpansion = minimumTouchExpansionRadius(
                for: naturalBounds,
                minimumTouchSize: touchSize
            )
            let fallbackRadius = max(minimumExpansion, tolerance)

            // The rectangle is only a cheap rejection envelope. Acceptance is
            // based on real distance to a province boundary below.
            let rejectionBounds = naturalBounds.insetBy(
                dx: -fallbackRadius,
                dy: -fallbackRadius
            )
            guard rejectionBounds.contains(point) else { continue }

            let distanceSquared = boundaryDistanceSquared(
                from: point,
                to: geometry.normalizedSegments,
                in: mapRect
            )
            guard distanceSquared <= fallbackRadius * fallbackRadius else { continue }

            let candidate = FallbackCandidate(
                provinceID: geometry.provinceID,
                distanceSquared: distanceSquared,
                naturalArea: naturalBounds.width * naturalBounds.height
            )
            if bestFallback.map({ prefersFallbackCandidate(candidate, $0) }) ?? true {
                bestFallback = candidate
            }
        }

        return bestFallback?.provinceID
    }

    /// Bounding envelope used to audit the minimum effective touch size.
    ///
    /// The actual forgiving hit region is the province path dilated by the
    /// corresponding radius, not this rectangle.
    static func effectiveTargetFrame(
        for provinceID: String,
        in mapRect: CGRect,
        minimumTouchSize: CGFloat = AppButtonMetrics.minTouchSize
    ) -> CGRect? {
        guard isUsable(mapRect),
              let geometry = cache.byProvinceID[provinceID]
        else { return nil }

        let naturalBounds = projectedBounds(geometry.normalizedBounds, in: mapRect)
        let touchSize = sanitizedNonnegative(
            minimumTouchSize,
            fallback: AppButtonMetrics.minTouchSize
        )
        let radius = minimumTouchExpansionRadius(
            for: naturalBounds,
            minimumTouchSize: touchSize
        )
        return naturalBounds.insetBy(dx: -radius, dy: -radius)
    }

    /// Projected exact path for the opt-in DEBUG hit-area overlay.
    static func exactPath(for provinceID: String, in mapRect: CGRect) -> Path? {
        guard isUsable(mapRect),
              let geometry = cache.byProvinceID[provinceID]
        else { return nil }

        let transform = CGAffineTransform(
            a: mapRect.width,
            b: 0,
            c: 0,
            d: mapRect.height,
            tx: mapRect.minX,
            ty: mapRect.minY
        )
        return geometry.normalizedPath.applying(transform)
    }

    /// Radius of the real path-dilated fallback target for DEBUG visualization.
    static func fallbackRadius(
        for provinceID: String,
        in mapRect: CGRect,
        minimumTouchSize: CGFloat = AppButtonMetrics.minTouchSize,
        fallbackTolerance: CGFloat = 10
    ) -> CGFloat? {
        guard isUsable(mapRect),
              let geometry = cache.byProvinceID[provinceID]
        else { return nil }

        let naturalBounds = projectedBounds(geometry.normalizedBounds, in: mapRect)
        let touchSize = sanitizedNonnegative(
            minimumTouchSize,
            fallback: AppButtonMetrics.minTouchSize
        )
        let tolerance = sanitizedNonnegative(fallbackTolerance, fallback: 0)
        return max(
            minimumTouchExpansionRadius(
                for: naturalBounds,
                minimumTouchSize: touchSize
            ),
            tolerance
        )
    }

    /// A deterministic point inside the rendered polygon, used to place
    /// virtual accessibility controls without adding a transparent touch layer.
    static func representativePoint(for provinceID: String, in mapRect: CGRect) -> CGPoint? {
        guard isUsable(mapRect),
              cache.byProvinceID[provinceID] != nil,
              let normalizedPoint = representativeNormalizedPoints[provinceID]
        else { return nil }

        return CGPoint(
            x: mapRect.minX + normalizedPoint.x * mapRect.width,
            y: mapRect.minY + normalizedPoint.y * mapRect.height
        )
    }

    // MARK: - Cache diagnostics

    /// Stable identity used by the unit suite to prove repeated hits reuse the
    /// same normalized geometry cache without relying on timing assertions.
    static var normalizedGeometryCacheIdentityForTesting: ObjectIdentifier {
        ObjectIdentifier(cache)
    }

    static var cachedNormalizedGeometryCountForTesting: Int {
        cache.geometries.count
    }

    // MARK: - Cached geometry

    private final class GeometryCache: @unchecked Sendable {
        let geometries: [NormalizedProvinceGeometry]
        let byProvinceID: [String: NormalizedProvinceGeometry]

        init() {
            geometries = RealProvinceMapData.provinces.compactMap { province in
                Self.makeGeometry(province)
            }
            byProvinceID = Dictionary(
                uniqueKeysWithValues: geometries.map { ($0.provinceID, $0) }
            )
        }

        private static func makeGeometry(
            _ province: RealProvinceMapData.Province
        ) -> NormalizedProvinceGeometry? {
            let path = province.path(in: CGSize(width: 1, height: 1))
            let bounds = path.boundingRect
            guard !bounds.isNull,
                  !bounds.isInfinite,
                  bounds.width > 0,
                  bounds.height > 0
            else { return nil }

            let segments = province.rings.flatMap { ring -> [NormalizedSegment] in
                guard ring.count >= 2 else { return [] }

                return ring.indices.map { index in
                    let nextIndex = ring.index(after: index)
                    return NormalizedSegment(
                        start: ring[index],
                        end: nextIndex == ring.endIndex ? ring[ring.startIndex] : ring[nextIndex]
                    )
                }
            }

            return NormalizedProvinceGeometry(
                provinceID: province.id,
                normalizedPath: path,
                normalizedBounds: bounds,
                normalizedSegments: segments
            )
        }
    }

    private struct NormalizedProvinceGeometry: @unchecked Sendable {
        let provinceID: String
        let normalizedPath: Path
        let normalizedBounds: CGRect
        let normalizedSegments: [NormalizedSegment]
    }

    private struct NormalizedSegment: Sendable {
        let start: CGPoint
        let end: CGPoint
    }

    private struct FallbackCandidate {
        let provinceID: String
        let distanceSquared: CGFloat
        let naturalArea: CGFloat
    }

    private static let cache = GeometryCache()
    private static let representativeNormalizedPoints: [String: CGPoint] = [
        "Groningen": CGPoint(x: 0.864, y: 0.092),
        "Friesland": CGPoint(x: 0.640, y: 0.172),
        "Drenthe": CGPoint(x: 0.868, y: 0.240),
        "Noord-Holland": CGPoint(x: 0.388, y: 0.380),
        "Flevoland": CGPoint(x: 0.600, y: 0.384),
        "Overijssel": CGPoint(x: 0.816, y: 0.400),
        "Utrecht": CGPoint(x: 0.520, y: 0.528),
        "Gelderland": CGPoint(x: 0.680, y: 0.532),
        // Exact interior clear of Leiden's compact marker and label targets.
        "Zuid-Holland": CGPoint(x: 0.440, y: 0.600),
        "Zeeland": CGPoint(x: 0.112, y: 0.740),
        "Noord-Brabant": CGPoint(x: 0.580, y: 0.724),
        "Limburg": CGPoint(x: 0.696, y: 0.824)
    ]

    // MARK: - Ranking and distance

    private nonisolated static func prefersExactMatch(
        _ lhs: NormalizedProvinceGeometry,
        _ rhs: NormalizedProvinceGeometry
    ) -> Bool {
        let lhsArea = lhs.normalizedBounds.width * lhs.normalizedBounds.height
        let rhsArea = rhs.normalizedBounds.width * rhs.normalizedBounds.height
        if lhsArea != rhsArea {
            return lhsArea < rhsArea
        }
        return lhs.provinceID < rhs.provinceID
    }

    private nonisolated static func prefersFallbackCandidate(
        _ lhs: FallbackCandidate,
        _ rhs: FallbackCandidate
    ) -> Bool {
        if lhs.distanceSquared != rhs.distanceSquared {
            return lhs.distanceSquared < rhs.distanceSquared
        }
        if lhs.naturalArea != rhs.naturalArea {
            return lhs.naturalArea < rhs.naturalArea
        }
        return lhs.provinceID < rhs.provinceID
    }

    private static func boundaryDistanceSquared(
        from point: CGPoint,
        to normalizedSegments: [NormalizedSegment],
        in mapRect: CGRect
    ) -> CGFloat {
        var closestDistanceSquared = CGFloat.greatestFiniteMagnitude

        for segment in normalizedSegments {
            let start = projected(segment.start, in: mapRect)
            let end = projected(segment.end, in: mapRect)
            closestDistanceSquared = min(
                closestDistanceSquared,
                pointToSegmentDistanceSquared(point, start: start, end: end)
            )
        }

        return closestDistanceSquared
    }

    private static func minimumTouchExpansionRadius(
        for naturalBounds: CGRect,
        minimumTouchSize: CGFloat
    ) -> CGFloat {
        max(
            0,
            max(
                (minimumTouchSize - naturalBounds.width) / 2,
                (minimumTouchSize - naturalBounds.height) / 2
            )
        )
    }

    private static func projectedBounds(_ bounds: CGRect, in mapRect: CGRect) -> CGRect {
        CGRect(
            x: mapRect.minX + bounds.minX * mapRect.width,
            y: mapRect.minY + bounds.minY * mapRect.height,
            width: bounds.width * mapRect.width,
            height: bounds.height * mapRect.height
        )
    }

    private static func projected(_ point: CGPoint, in mapRect: CGRect) -> CGPoint {
        CGPoint(
            x: mapRect.minX + point.x * mapRect.width,
            y: mapRect.minY + point.y * mapRect.height
        )
    }

    private static func pointToSegmentDistanceSquared(
        _ point: CGPoint,
        start: CGPoint,
        end: CGPoint
    ) -> CGFloat {
        let segmentX = end.x - start.x
        let segmentY = end.y - start.y
        let segmentLengthSquared = segmentX * segmentX + segmentY * segmentY

        guard segmentLengthSquared > .ulpOfOne else {
            return squaredDistance(point, start)
        }

        let projection = (
            (point.x - start.x) * segmentX
                + (point.y - start.y) * segmentY
        ) / segmentLengthSquared
        let clampedProjection = min(max(projection, 0), 1)
        let closestPoint = CGPoint(
            x: start.x + clampedProjection * segmentX,
            y: start.y + clampedProjection * segmentY
        )
        return squaredDistance(point, closestPoint)
    }

    private static func squaredDistance(_ lhs: CGPoint, _ rhs: CGPoint) -> CGFloat {
        let x = lhs.x - rhs.x
        let y = lhs.y - rhs.y
        return x * x + y * y
    }

    private static func isUsable(_ rect: CGRect) -> Bool {
        rect.minX.isFinite
            && rect.minY.isFinite
            && rect.width.isFinite
            && rect.height.isFinite
            && rect.width > 0
            && rect.height > 0
    }

    private static func sanitizedNonnegative(_ value: CGFloat, fallback: CGFloat) -> CGFloat {
        guard value.isFinite else { return fallback }
        return max(0, value)
    }
}
