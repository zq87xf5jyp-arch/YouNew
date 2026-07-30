import Foundation
import Testing
@testable import YouNew

@MainActor
struct KnowledgeDataGovernanceTests {
    @Test func governmentIntegrityIncludesEveryRequiredService() {
        let services = NetherlandsKnowledgeDatabase.shared.publishedEntities.filter { $0.kind == .governmentService }
        let names = Set(services.map(\.title))
        let required = [
            "Municipality", "IND", "DigiD", "Belastingdienst", "DUO", "UWV", "SVB", "CAK", "CJIB",
            "Rijksoverheid", "Police", "Emergency", "Health Insurance", "GP", "Hospitals", "Pharmacies"
        ]

        for name in required {
            #expect(names.contains(name), "Missing verified government-service entity: \(name)")
        }
        #expect(services.allSatisfy { $0.source?.url?.scheme == "https" })
        #expect(services.allSatisfy { !$0.aiSummary.isEmpty && !$0.lastChecked.isEmpty })
    }

    @Test func placesAndCityProvinceIntegrityUseCanonicalEntities() {
        let database = NetherlandsKnowledgeDatabase.shared
        let cities = Set(database.entities(kind: .city).map { KnowledgeNormalizer.normalize($0.title) })
        let placeKinds: Set<NetherlandsEntityKind> = [.place, .attraction, .museum, .park, .restaurant, .cafe, .hotel, .healthcare, .university, .transport]
        let places = database.publishedEntities.filter { placeKinds.contains($0.kind) }

        #expect(!places.isEmpty)
        #expect(places.allSatisfy { $0.coordinate != nil })
        #expect(places.allSatisfy { $0.source?.url?.scheme == "https" })
        let invalidCities = places.filter { entity in
            guard let city = entity.cityId else { return false }
            return !cities.contains(KnowledgeNormalizer.normalize(city))
        }
        let invalidCityDetails = invalidCities.map { $0.id + "=" + ($0.cityId ?? "nil") }.joined(separator: ", ")
        #expect(invalidCities.isEmpty, "Unknown city references: \(invalidCityDetails)")
    }

    @Test func ongoingEventsRemainVisibleAndExpiredEventsAreHidden() {
        let calendar = CalendarEventData.calendar
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let source = OfficialSource(title: "Official calendar", url: URL(string: "https://www.visitleiden.nl/en/event-calendar"), institution: "Visit Leiden")
        let ongoing = event(id: "ongoing", start: yesterday, end: tomorrow, source: source)
        let expired = event(id: "expired", start: yesterday, end: yesterday, source: source)

        #expect(ongoing.isVisible(cityId: "Leiden", audience: .tourist, now: now))
        #expect(!expired.isVisible(cityId: "Leiden", audience: .tourist, now: now))
        #expect(NetherlandsKnowledgeDatabase.shared.publishedEntities.filter { $0.kind == .event }.allSatisfy { $0.isActiveEvent(now: now) })
    }

    @Test func partnerVerificationRequiresRealWebsiteAndStatus() {
        let partners = NetherlandsKnowledgeDatabase.shared.publishedEntities.filter { $0.kind == .localPartner }

        #expect(!partners.isEmpty)
        #expect(partners.allSatisfy { $0.source?.url?.scheme == "https" })
        #expect(partners.allSatisfy { !($0.attributes["plan"] ?? "").isEmpty })
        #expect(partners.allSatisfy { $0.attributes["verified"] != nil && $0.attributes["sponsored"] != nil })
    }

    @Test func imageCompletenessAndLicensingMetadataAreAuditable() {
        let records = NetherlandsKnowledgeDatabase.shared.publishedEntities
        #expect(records.allSatisfy { $0.hasCompleteVisualSet })
        #expect(records.flatMap { $0.images.allImages }.allSatisfy { !$0.sourceName.isEmpty && $0.verified })

        let report = NetherlandsKnowledgeDatabase.shared.premiumReport()
        #expect(report.images >= records.count * 4)
        #expect((0 ... 100).contains(report.uniquePhotoPercentage))
    }

    @Test func officialSourceValidationAcceptsOnlySecureSeededServices() {
        let seededIDs = Set(PremiumKnowledgeSeedData.entities.filter { $0.kind == .governmentService }.map(\.id))
        let services = NetherlandsKnowledgeDatabase.shared.publishedEntities.filter { seededIDs.contains($0.id) }
        let hosts = Set(services.compactMap { $0.source?.url?.host?.replacingOccurrences(of: "www.", with: "") })
        let allowed = Set(["svb.nl", "hetcak.nl", "rijksoverheid.nl", "politie.nl", "government.nl", "thuisarts.nl", "apotheek.nl"])

        #expect(!services.isEmpty)
        #expect(hosts.isSubset(of: allowed))
    }

    @Test func searchAndAIRoutingUseTheCentralDatabase() {
        let engine = AppSearchEngine()
        let results = engine.search("CAK healthcare payment", language: .english, scope: .allContentWithOutsidePathWarning, limit: 20)
        let item = results.first { $0.item.id == "government-service:cak" }

        #expect(item != nil)
        #expect(item?.item.sources.first?.url?.host == "www.hetcak.nl")
        #expect(KnowledgeIndex.shared.itemsByID["government-service:cak"] != nil)
    }

    @Test func duplicateDetectionCatchesEntityAndWebsiteCopies() throws {
        let entity = try #require(NetherlandsKnowledgeDatabase.shared.entities.first { $0.kind == .governmentService })
        let issues = KnowledgeDataValidator.validate(entities: [entity, entity])
        let kinds = Set(issues.map(\.kind))

        #expect(kinds.contains(.duplicateEntity))
        #expect(kinds.contains(.duplicateWebsite))
    }

    @Test func finalReportContainsEveryRequestedMetric() {
        let report = NetherlandsKnowledgeDatabase.shared.premiumReport()

        #expect(report.cities >= 12)
        #expect(report.museums > 0)
        #expect(report.governmentServices >= 16)
        #expect(report.partners > 0)
        #expect(!DashboardCalendarData.events.isEmpty)
        #expect(report.lines.contains("Events: \(report.events)"))
        #expect(report.images > 0)
        #expect(report.verifiedWebsites > 0)
        #expect((0 ... 100).contains(report.currentRecordPercentage))
        #expect((0 ... 100).contains(report.uniquePhotoPercentage))
        #expect(report.lines.count == 11)
    }

    @Test func governedEffectiveStatusUsesFailClosedPrecedenceAndFreshnessWindow() {
        let now = Date(timeIntervalSince1970: 1_785_412_800) // 2026-07-30T12:00:00Z

        #expect(envelope(publication: .archived).effectiveStatus(at: now) == .archived)
        #expect(envelope(verification: .disputed).effectiveStatus(at: now) == .disputed)
        #expect(envelope(verification: .sourceUnavailable).effectiveStatus(at: now) == .sourceUnavailable)
        #expect(envelope(sourceURL: nil).effectiveStatus(at: now) == .unverified)
        #expect(
            envelope(
                nextReviewAt: now.addingTimeInterval(6 * 86_400),
                reviewIntervalDays: 90
            ).effectiveStatus(at: now) == .reviewDueSoon
        )
        #expect(
            envelope(
                nextReviewAt: now.addingTimeInterval(-1),
                reviewIntervalDays: 90
            ).effectiveStatus(at: now) == .overdue
        )
    }

    @Test func confidenceIndexIsVersionedEvidenceCoverageNotProbability() {
        let valid = envelope()
        #expect(valid.confidenceScore == 100)
        #expect(valid.hasValidConfidenceEvidence)

        let inconsistent = envelope(confidenceScore: 99)
        #expect(!inconsistent.hasValidConfidenceEvidence)
        #expect(ContentGovernanceEnvelope.reviewDueLeadDays(reviewIntervalDays: 2) == 1)
        #expect(ContentGovernanceEnvelope.reviewDueLeadDays(reviewIntervalDays: 90) == 14)
        #expect(ContentGovernanceEnvelope.reviewDueLeadDays(reviewIntervalDays: 365) == 14)
    }

    @Test func governedRetrievalExcludesUnsafeStatusesBeforeConfidenceRanking() {
        let now = Date(timeIntervalSince1970: 1_785_412_800)
        #expect(envelope(verification: .unverified).aiEligibility(at: now) == .excluded)
        #expect(envelope(verification: .disputed).aiEligibility(at: now) == .excluded)
        #expect(envelope(verification: .sourceUnavailable).aiEligibility(at: now) == .excluded)
        #expect(
            envelope(
                verification: .verified,
                nextReviewAt: now.addingTimeInterval(-1)
            ).aiEligibility(at: now) == .secondaryOnly
        )
        #expect(envelope().aiEligibility(at: now) == .primary)
    }

    @Test func governedRetrievalRanksExactMunicipalityBeforeNationalAndExplainsExclusions() {
        let now = Date(timeIntervalSince1970: 1_785_412_800)
        let amsterdam = ContentJurisdiction(
            countryCode: "NL",
            level: .municipal,
            municipalityDependent: true,
            applicabilityVerified: true,
            provinceCode: "PV27",
            provinceName: "Noord-Holland",
            municipalityCode: "GM0363",
            municipalityName: "Amsterdam"
        )
        let rotterdam = ContentJurisdiction(
            countryCode: "NL",
            level: .municipal,
            municipalityDependent: true,
            applicabilityVerified: true,
            provinceCode: "PV28",
            provinceName: "Zuid-Holland",
            municipalityCode: "GM0599",
            municipalityName: "Rotterdam"
        )
        let result = GovernedRetrievalPolicy.rank(
            [
                GovernedRetrievalCandidate(recordID: "national", governance: envelope(id: "national")),
                GovernedRetrievalCandidate(recordID: "amsterdam", governance: envelope(id: "amsterdam", jurisdiction: amsterdam)),
                GovernedRetrievalCandidate(recordID: "rotterdam", governance: envelope(id: "rotterdam", jurisdiction: rotterdam)),
                GovernedRetrievalCandidate(recordID: "disputed", governance: envelope(id: "disputed", verification: .disputed))
            ],
            municipality: "Amsterdam",
            at: now
        )

        #expect(result.primary.map(\.recordID) == ["amsterdam", "national"])
        #expect(result.excludedCandidateReasons == ["wrong_municipality": 1, "disputed": 1])
        #expect(result.policyVersion == "retrieval-policy-v1")
    }

    @Test func decisionTraceIsDeterministicEvidenceNotHiddenReasoning() {
        let trace = AIDecisionTrace(
            selectedRecordIDs: ["brp-national"],
            sourceCitations: [
                AIDecisionSourceCitation(
                    recordID: "brp-national",
                    sourceTitle: "Registering in the BRP",
                    sourcePublisher: "Government of the Netherlands",
                    sourceURL: URL(string: "https://www.government.nl/topics/personal-data/question-and-answer/when-should-i-register-in-the-personal-records-database")!
                )
            ],
            freshnessEvidence: [
                AIDecisionEvidence(recordID: "brp-national", summary: "Checked 2026-07-30")
            ],
            jurisdictionEvidence: [
                AIDecisionEvidence(recordID: "brp-national", summary: "National applicability verified")
            ],
            rankingFactors: ["exact jurisdiction", "official source", "freshness"],
            confidenceBreakdown: ["officialSource": 40],
            excludedCandidateReasons: ["wrong_municipality": 2],
            policyVersion: "retrieval-policy-v1",
            modelVersion: nil,
            contextVersion: "context-v1"
        )

        #expect(trace.isMachineValid)
        #expect(
            AIDecisionTrace(
                selectedRecordIDs: ["brp-national"],
                sourceCitations: [],
                freshnessEvidence: [],
                jurisdictionEvidence: [],
                rankingFactors: [],
                confidenceBreakdown: [:],
                excludedCandidateReasons: [:],
                policyVersion: "",
                modelVersion: nil,
                contextVersion: ""
            ).isMachineValid == false
        )
    }

    private func envelope(
        id: String = "fixture",
        publication: GovernancePublicationStatus = .published,
        verification: GovernanceVerificationStatus = .verified,
        sourceURL: URL? = URL(string: "https://example.nl/source"),
        nextReviewAt: Date? = Date(timeIntervalSince1970: 1_793_188_800),
        reviewIntervalDays: Int? = 90,
        confidenceScore: Int = 100,
        jurisdiction: ContentJurisdiction? = nil
    ) -> ContentGovernanceEnvelope {
        ContentGovernanceEnvelope(
            id: id,
            title: "Fixture",
            contentType: "article",
            jurisdiction: jurisdiction ?? ContentJurisdiction(
                countryCode: "NL",
                level: .national,
                municipalityDependent: false,
                applicabilityVerified: true,
                provinceCode: nil,
                provinceName: nil,
                municipalityCode: nil,
                municipalityName: nil
            ),
            officialSourceURL: sourceURL,
            sourceTitle: "Official source",
            sourcePublisher: "Official publisher",
            lastVerifiedAt: Date(timeIntervalSince1970: 1_785_326_400),
            nextReviewAt: nextReviewAt,
            reviewIntervalDays: reviewIntervalDays,
            contentOwner: "content-owner",
            reviewedBy: "reviewer-a",
            verificationStatus: verification,
            confidenceLevel: .high,
            validityStart: nil,
            validityEnd: nil,
            changeNotes: nil,
            version: 1,
            updatedAt: Date(timeIntervalSince1970: 1_785_326_400),
            publicationStatus: publication,
            reviewState: .monitoring,
            criticality: .critical,
            contentOrigin: .governmentPublication,
            originReference: "https://example.nl/source",
            originCapturedAt: Date(timeIntervalSince1970: 1_785_326_400),
            originArtifactDigest: "sha256:\(String(repeating: "a", count: 64))",
            confidenceScore: confidenceScore,
            confidenceScoreVersion: 1,
            confidenceBreakdown: GovernanceConfidenceBreakdown(
                officialSource: 40,
                humanReviewer: 20,
                independentReview: 15,
                freshness: 10,
                jurisdictionApplicability: 15
            )
        )
    }

    private func event(id: String, start: Date, end: Date?, source: OfficialSource) -> CalendarEvent {
        CalendarEvent(
            id: id,
            title: id,
            localTitle: nil,
            date: start,
            endDate: end,
            type: .cityEvent,
            countryCode: "NL",
            cityId: "Leiden",
            audience: [.tourist],
            description: "Verified event",
            impact: nil,
            source: source,
            lastChecked: "2026-07-13",
            priority: 1,
            official: true,
            dayOffGuaranteed: false,
            affectsServices: false,
            affectsTransport: false,
            hidden: false,
            draft: false
        )
    }
}
