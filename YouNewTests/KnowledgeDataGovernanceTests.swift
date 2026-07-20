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
        #expect(report.events > 0)
        #expect(report.images > 0)
        #expect(report.verifiedWebsites > 0)
        #expect((0 ... 100).contains(report.currentRecordPercentage))
        #expect((0 ... 100).contains(report.uniquePhotoPercentage))
        #expect(report.lines.count == 11)
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
