import SwiftUI
import Testing
@testable import YouNew

@MainActor
struct PremiumProvinceHitTestingTests {
    private let compactMapRect = CGRect(x: 106.25, y: 104, width: 141.5, height: 262)

    @Test func exactRepresentativePointResolvesEveryRenderedProvince() {
        let representativePoints: [(provinceID: String, normalizedPoint: CGPoint)] = [
            ("Groningen", CGPoint(x: 0.864, y: 0.092)),
            ("Friesland", CGPoint(x: 0.640, y: 0.172)),
            ("Drenthe", CGPoint(x: 0.868, y: 0.240)),
            ("Noord-Holland", CGPoint(x: 0.388, y: 0.380)),
            ("Flevoland", CGPoint(x: 0.600, y: 0.384)),
            ("Overijssel", CGPoint(x: 0.816, y: 0.400)),
            ("Utrecht", CGPoint(x: 0.520, y: 0.528)),
            ("Gelderland", CGPoint(x: 0.680, y: 0.532)),
            ("Zuid-Holland", CGPoint(x: 0.440, y: 0.600)),
            ("Zeeland", CGPoint(x: 0.112, y: 0.740)),
            ("Noord-Brabant", CGPoint(x: 0.580, y: 0.724)),
            ("Limburg", CGPoint(x: 0.696, y: 0.824))
        ]

        #expect(representativePoints.count == RealProvinceMapData.provinces.count)
        #expect(
            Set(representativePoints.map(\.provinceID))
                == Set(RealProvinceMapData.provinces.map(\.id))
        )

        for sample in representativePoints {
            let hit = PremiumProvinceHitTesting.hitTest(
                mapPoint(sample.normalizedPoint),
                in: compactMapRect,
                fallbackTolerance: 0
            )
            #expect(
                hit == sample.provinceID,
                "Expected exact hit for \(sample.provinceID), got \(hit ?? "nil")"
            )
        }
    }

    @Test func accessibilityRepresentativePointsResolveTheirRenderedProvince() throws {
        for province in RealProvinceMapData.provinces {
            let point = try #require(
                PremiumProvinceHitTesting.representativePoint(
                    for: province.id,
                    in: compactMapRect
                )
            )
            #expect(
                PremiumProvinceHitTesting.hitTest(
                    point,
                    in: compactMapRect,
                    fallbackTolerance: 0
                ) == province.id,
                "Accessibility point must stay inside \(province.id)."
            )
        }
    }

    @Test func physicalCalibrationUtrechtSubpointIsExactInterior() throws {
        // This is the seeded sub-point used by physical tap #28. Keep it as a
        // regression guard so an input-delivery miss is never "fixed" by
        // moving the Utrecht geometry or stealing space from Flevoland.
        let normalizedPoint = CGPoint(
            x: 0.516259966531,
            y: 0.526507101828
        )
        let point = mapPoint(normalizedPoint)
        let exactPath = try #require(
            PremiumProvinceHitTesting.exactPath(
                for: "Utrecht",
                in: compactMapRect
            )
        )

        #expect(exactPath.contains(point))
        #expect(
            PremiumProvinceHitTesting.hitTest(
                point,
                in: compactMapRect,
                fallbackTolerance: 0
            ) == "Utrecht"
        )
    }

    @Test func schematicSVGRepresentativePointsResolveEveryVisibleProvince() throws {
        let schematicMapRect = CGRect(x: 48, y: 20, width: 180, height: 288)

        #expect(ProvinceMapShape.allCases.count == 12)
        for province in ProvinceMapShape.allCases {
            let point = try #require(
                ProvinceSchematicHitTesting.representativePoint(
                    for: province.id,
                    in: schematicMapRect
                )
            )
            #expect(
                ProvinceSchematicHitTesting.hitTest(
                    point,
                    in: schematicMapRect,
                    fallbackTolerance: 0
                ) == province.id,
                "SVG representative point must resolve \(province.id)."
            )
        }
    }

    @Test func oneHundredDeterministicInteriorTapsHaveNoMissesOrWrongSelections() throws {
        let criticalProvinceIDs = Set([
            "Groningen",
            "Zeeland",
            "Limburg",
            "Flevoland",
            "Utrecht"
        ])
        let requestedCounts = Dictionary(
            uniqueKeysWithValues: RealProvinceMapData.provinces.map { province in
                (province.id, criticalProvinceIDs.contains(province.id) ? 13 : 5)
            }
        )
        #expect(requestedCounts.values.reduce(0, +) == 100)

        var generator = DeterministicGenerator(seed: 0x594F_554E_4557_1001)
        let samples = try uniqueInteriorSamples(
            countsByProvinceID: requestedCounts,
            generator: &generator
        )
        var missed: [String] = []
        var wrong: [String] = []

        for (index, sample) in samples.enumerated() {
            let hit = PremiumProvinceHitTesting.hitTest(
                mapPoint(sample.normalizedPoint),
                in: compactMapRect,
                fallbackTolerance: 0
            )
            if hit == nil {
                missed.append("#\(index) \(sample.provinceID)")
            } else if hit != sample.provinceID {
                wrong.append("#\(index) \(sample.provinceID)->\(hit ?? "nil")")
            }
        }

        let actualCounts = Dictionary(grouping: samples, by: \.provinceID).mapValues(\.count)
        #expect(samples.count == 100)
        for provinceID in criticalProvinceIDs {
            #expect((actualCounts[provinceID] ?? 0) >= 12)
        }
        #expect(missed.isEmpty, "Missed deterministic interior taps: \(missed)")
        #expect(wrong.isEmpty, "Wrong deterministic interior selections: \(wrong)")
    }

    @Test func effectiveTargetsMeetMinimumTouchSizeOnCompactMap() throws {
        for province in RealProvinceMapData.provinces {
            let frame = try #require(
                PremiumProvinceHitTesting.effectiveTargetFrame(
                    for: province.id,
                    in: compactMapRect
                )
            )

            #expect(frame.width >= AppButtonMetrics.minTouchSize - 0.001)
            #expect(frame.height >= AppButtonMetrics.minTouchSize - 0.001)
        }
    }

    @Test func seaAndBoundingBoxGapsDoNotBecomeRectangularHits() throws {
        // This point is inside Zeeland's rectangular minimum-target envelope,
        // but well outside every Zeeland island/coast segment. The former
        // rectangle-acceptance algorithm incorrectly treated it as Zeeland.
        let zeelandGap = mapPoint(CGPoint(x: 0.250, y: 0.849))
        let zeelandEnvelope = try #require(
            PremiumProvinceHitTesting.effectiveTargetFrame(
                for: "Zeeland",
                in: compactMapRect
            )
        )
        let zeelandPath = try #require(
            PremiumProvinceHitTesting.exactPath(
                for: "Zeeland",
                in: compactMapRect
            )
        )

        #expect(zeelandEnvelope.contains(zeelandGap))
        #expect(!zeelandPath.contains(zeelandGap))
        #expect(
            PremiumProvinceHitTesting.hitTest(
                zeelandGap,
                in: compactMapRect,
                fallbackTolerance: 0
            ) == nil
        )

        // Groningen's main landmass and tiny northern island make its natural
        // bounds include open sea in the north-east corner. Even the normal
        // 10pt forgiveness must remain a path-distance gate there.
        let groningenSea = mapPoint(CGPoint(x: 0.990, y: 0.005))
        let groningenEnvelope = try #require(
            PremiumProvinceHitTesting.effectiveTargetFrame(
                for: "Groningen",
                in: compactMapRect
            )
        )
        let groningenPath = try #require(
            PremiumProvinceHitTesting.exactPath(
                for: "Groningen",
                in: compactMapRect
            )
        )

        #expect(groningenEnvelope.contains(groningenSea))
        #expect(!groningenPath.contains(groningenSea))
        #expect(
            PremiumProvinceHitTesting.hitTest(
                groningenSea,
                in: compactMapRect,
                fallbackTolerance: 10
            ) == nil
        )
    }

    @Test func exactNeighborWinsBeforeExpandedSmallProvinceFallback() throws {
        // Immediately south of Utrecht's shared boundary: inside Gelderland,
        // while still inside Utrecht's expanded 44pt target envelope.
        let gelderlandPoint = mapPoint(CGPoint(x: 0.500, y: 0.577))
        let gelderlandPath = try #require(
            PremiumProvinceHitTesting.exactPath(
                for: "Gelderland",
                in: compactMapRect
            )
        )
        let utrechtPath = try #require(
            PremiumProvinceHitTesting.exactPath(
                for: "Utrecht",
                in: compactMapRect
            )
        )
        let utrechtTarget = try #require(
            PremiumProvinceHitTesting.effectiveTargetFrame(
                for: "Utrecht",
                in: compactMapRect
            )
        )

        #expect(gelderlandPath.contains(gelderlandPoint))
        #expect(!utrechtPath.contains(gelderlandPoint))
        #expect(utrechtTarget.contains(gelderlandPoint))
        #expect(
            PremiumProvinceHitTesting.hitTest(
                gelderlandPoint,
                in: compactMapRect,
                fallbackTolerance: 10
            ) == "Gelderland"
        )
    }

    @Test func pathDistanceFallbackRecoversNarrowCoastalNearMiss() throws {
        let zeelandPath = try #require(
            PremiumProvinceHitTesting.exactPath(
                for: "Zeeland",
                in: compactMapRect
            )
        )
        let expandedPoint = CGPoint(
            x: compactMapRect.minX - 2,
            y: mapPoint(CGPoint(x: 0, y: 0.8216)).y
        )

        #expect(!zeelandPath.contains(expandedPoint))
        #expect(
            PremiumProvinceHitTesting.hitTest(
                expandedPoint,
                in: compactMapRect,
                fallbackTolerance: 0
            ) == "Zeeland"
        )
    }

    @Test func callerToleranceUsesBoundaryDistanceRatherThanRectangleGrowth() throws {
        let point = CGPoint(
            x: compactMapRect.minX - 6,
            y: mapPoint(CGPoint(x: 0, y: 0.8216)).y
        )
        let minimumRadius = try #require(
            PremiumProvinceHitTesting.fallbackRadius(
                for: "Zeeland",
                in: compactMapRect,
                fallbackTolerance: 0
            )
        )

        #expect(minimumRadius < 6)
        #expect(
            PremiumProvinceHitTesting.hitTest(
                point,
                in: compactMapRect,
                fallbackTolerance: 0
            ) == nil
        )
        #expect(
            PremiumProvinceHitTesting.hitTest(
                point,
                in: compactMapRect,
                fallbackTolerance: 6.5
            ) == "Zeeland"
        )
    }

    @Test func normalizedGeometryCacheIsStableAcrossRepeatedHits() {
        let cacheIdentity = PremiumProvinceHitTesting.normalizedGeometryCacheIdentityForTesting
        #expect(
            PremiumProvinceHitTesting.cachedNormalizedGeometryCountForTesting
                == RealProvinceMapData.provinces.count
        )

        for index in 0..<200 {
            let x = CGFloat(index % 20) / 19
            let y = CGFloat(index / 20) / 9
            _ = PremiumProvinceHitTesting.hitTest(
                mapPoint(CGPoint(x: x, y: y)),
                in: compactMapRect
            )
        }

        #expect(
            PremiumProvinceHitTesting.normalizedGeometryCacheIdentityForTesting
                == cacheIdentity
        )
    }

    @Test func farOutsideAndInvalidGeometryDoNotResolveAProvince() {
        let outsidePoints = [
            CGPoint(x: compactMapRect.minX - 100, y: compactMapRect.midY),
            CGPoint(x: compactMapRect.maxX + 100, y: compactMapRect.midY),
            CGPoint(x: compactMapRect.midX, y: compactMapRect.minY - 100),
            CGPoint(x: compactMapRect.midX, y: compactMapRect.maxY + 100)
        ]

        for point in outsidePoints {
            #expect(PremiumProvinceHitTesting.hitTest(point, in: compactMapRect) == nil)
        }

        #expect(PremiumProvinceHitTesting.hitTest(.zero, in: .zero) == nil)
        #expect(
            PremiumProvinceHitTesting.hitTest(
                CGPoint(x: CGFloat.infinity, y: 0),
                in: compactMapRect
            ) == nil
        )
        #expect(
            PremiumProvinceHitTesting.effectiveTargetFrame(
                for: "Unknown",
                in: compactMapRect
            ) == nil
        )
        #expect(
            PremiumProvinceHitTesting.exactPath(
                for: "Unknown",
                in: compactMapRect
            ) == nil
        )
    }

    private func uniqueInteriorSamples(
        countsByProvinceID: [String: Int],
        generator: inout DeterministicGenerator
    ) throws -> [(provinceID: String, normalizedPoint: CGPoint)] {
        let unitSize = CGSize(width: 1, height: 1)
        let paths = Dictionary(
            uniqueKeysWithValues: RealProvinceMapData.provinces.map {
                ($0.id, $0.path(in: unitSize))
            }
        )
        var result: [(provinceID: String, normalizedPoint: CGPoint)] = []

        for province in RealProvinceMapData.provinces {
            let requestedCount = countsByProvinceID[province.id] ?? 0
            let path = try #require(paths[province.id])
            let bounds = path.boundingRect
            var accepted = 0
            var attempts = 0

            while accepted < requestedCount, attempts < 100_000 {
                attempts += 1
                let point = CGPoint(
                    x: bounds.minX + generator.nextUnit() * bounds.width,
                    y: bounds.minY + generator.nextUnit() * bounds.height
                )
                guard path.contains(point) else { continue }

                let exactOwners = paths.compactMap { entry in
                    entry.value.contains(point) ? entry.key : nil
                }
                guard exactOwners == [province.id] else { continue }

                result.append((province.id, point))
                accepted += 1
            }

            #expect(
                accepted == requestedCount,
                "Could only create \(accepted)/\(requestedCount) interior samples for \(province.id)"
            )
        }

        return result
    }

    private func mapPoint(_ normalizedPoint: CGPoint) -> CGPoint {
        CGPoint(
            x: compactMapRect.minX + normalizedPoint.x * compactMapRect.width,
            y: compactMapRect.minY + normalizedPoint.y * compactMapRect.height
        )
    }

    private struct DeterministicGenerator {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func nextUnit() -> CGFloat {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            let upper53Bits = state >> 11
            return CGFloat(Double(upper53Bits) / Double(UInt64(1) << 53))
        }
    }
}
