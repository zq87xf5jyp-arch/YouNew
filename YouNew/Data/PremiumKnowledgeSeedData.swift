import Foundation

/// Verified national services that are not represented by the legacy institution catalog.
/// They are projected into the same NetherlandsKnowledgeDatabase used by Search and AI.
enum PremiumKnowledgeSeedData {
    static let entities: [NetherlandsKnowledgeEntity] = sourceEntities + serviceEntities

    private static let checkedAt = "2026-07-13"

    private static let sourceEntities: [NetherlandsKnowledgeEntity] = [
        source("source:digid", "DigiD", "https://www.digid.nl/en/", "Official digital identity and sign-in service."),
        source("source:cak", "CAK", "https://www.hetcak.nl/en/", "Official CAK information about healthcare-related public schemes and payments."),
        source("source:cjib", "CJIB", "https://www.cjib.nl/en", "Official Central Judicial Collection Agency information and payment routes."),
        source("source:rijksoverheid", "Rijksoverheid", "https://www.rijksoverheid.nl/", "Official Dutch central-government information."),
        source("source:thuisarts", "Thuisarts.nl", "https://www.thuisarts.nl/", "Patient information maintained by the Dutch College of General Practitioners."),
        source("source:apotheek", "Apotheek.nl", "https://www.apotheek.nl/", "Official public medicine information from the Royal Dutch Pharmacists Association."),
        source("source:government-health-insurance", "Government.nl health insurance", "https://www.government.nl/topics/health-insurance", "Official explanation of Dutch health-insurance rules."),
        source("source:government-healthcare", "Government.nl healthcare", "https://www.government.nl/themes/family-health-and-care", "Official national healthcare information.")
    ]

    private static let serviceEntities: [NetherlandsKnowledgeEntity] = [
        service("government-service:svb", "SVB", "National social-insurance administration for schemes including child benefit and AOW pension.", "https://www.svb.nl/en/", "SVB", contacts: "Use the official SVB contact page for the correct office and telephone route.", documents: "BSN, DigiD and case-specific supporting documents", checklists: "DigiD; family benefits; pension"),
        service("government-service:cak", "CAK", "Public body that administers specific healthcare contributions, certificates and statutory payment schemes.", "https://www.hetcak.nl/en/", "CAK", contacts: "Use the official CAK contact page; the correct route depends on the scheme.", documents: "CAK letter or reference number; DigiD where requested", checklists: "Official letter review; healthcare payments"),
        service("government-service:rijksoverheid", "Rijksoverheid", "Primary Dutch-language portal for national government policy, rules and public information.", "https://www.rijksoverheid.nl/", "Rijksoverheid", contacts: "Contact details are published on Rijksoverheid.nl.", documents: "Depends on the responsible public authority", checklists: "Verify responsible authority; open official procedure"),
        service("government-service:police", "Police", "Official Dutch police information, reporting routes and non-emergency contact guidance.", "https://www.politie.nl/en", "Politie", contacts: "Emergency: 112. For non-emergency routes use politie.nl.", documents: "Identification and incident details when applicable", checklists: "Immediate danger check; report or appointment"),
        service("government-service:emergency-112", "Emergency", "Call 112 only when urgent assistance is needed because life, safety or property is in immediate danger.", "https://www.government.nl/topics/emergency-number-112", "Government of the Netherlands", contacts: "112 for immediate emergencies.", documents: "No document should delay an emergency call", checklists: "Location; type of emergency; immediate danger"),
        service("government-service:health-insurance", "Health Insurance", "Official national guidance on compulsory Dutch basic health insurance, eligibility and changing insurers.", "https://www.government.nl/topics/health-insurance", "Government of the Netherlands", contacts: "Use the responsible insurer or official authority identified on Government.nl.", documents: "BSN, policy information and employment/residence details where applicable", checklists: "Eligibility; registration deadline; policy comparison"),
        service("government-service:gp", "GP", "A huisarts is normally the first point of contact for non-emergency medical questions and referrals.", "https://www.thuisarts.nl/", "Dutch College of General Practitioners", contacts: "Contact your registered huisarts; use 112 for immediate danger.", documents: "Health-insurance details and medication overview when relevant", checklists: "Register with GP; prepare symptoms; urgent/non-urgent check"),
        service("government-service:hospitals", "Hospitals", "Hospital care usually follows a huisarts or specialist referral, except emergency care.", "https://www.government.nl/themes/family-health-and-care", "Government of the Netherlands", contacts: "Use the hospital's own official contact page for departments and visiting information.", documents: "Referral, identification and insurance details where required", checklists: "Referral; department; appointment documents"),
        service("government-service:pharmacies", "Pharmacies", "Official medicine and pharmacy guidance, including safe use and information supplied by Dutch pharmacists.", "https://www.apotheek.nl/", "Royal Dutch Pharmacists Association", contacts: "Use a pharmacy's official page or local out-of-hours pharmacy route.", documents: "Prescription and identification when required", checklists: "Prescription; medication list; out-of-hours route")
    ]

    private static func service(
        _ id: String,
        _ title: String,
        _ summary: String,
        _ url: String,
        _ institution: String,
        contacts: String,
        documents: String,
        checklists: String
    ) -> NetherlandsKnowledgeEntity {
        let website = AppURL.make(url)
        return NetherlandsKnowledgeEntity(
            id: id,
            kind: .governmentService,
            title: title,
            summary: summary,
            cityId: nil,
            provinceId: nil,
            category: "official services",
            coordinate: nil,
            source: OfficialSource(title: title, url: website, institution: institution, lastChecked: checkedDate),
            lastChecked: checkedAt,
            images: visuals(id: id, title: title, sourceURL: website),
            aiSummary: "(summary) Requirements can change; confirm the current procedure on the linked official domain before acting.",
            relatedEntityIDs: ["country:nl", "topic:digid", "topic:registration-bsn"],
            route: .officialSources,
            attributes: [
                "officialWebsite": website.absoluteString,
                "contacts": contacts,
                "scope": "National",
                "relatedDocuments": documents,
                "relatedChecklists": checklists,
                "verificationStatus": "Verified",
                "updateFrequency": "Monthly"
            ],
            keywords: [title, summary, institution, "official", "government", "Netherlands", "public service"],
            explicitPersonaTags: nil
        )
    }

    private static func source(_ id: String, _ title: String, _ url: String, _ summary: String) -> NetherlandsKnowledgeEntity {
        let website = AppURL.make(url)
        return NetherlandsKnowledgeEntity(
            id: id,
            kind: .officialSource,
            title: title,
            summary: summary,
            cityId: nil,
            provinceId: nil,
            category: "official source",
            coordinate: nil,
            source: OfficialSource(title: title, url: website, institution: title, lastChecked: checkedDate),
            lastChecked: checkedAt,
            images: visuals(id: id, title: title, sourceURL: website),
            aiSummary: summary,
            relatedEntityIDs: ["country:nl"],
            route: .officialSources,
            attributes: ["url": website.absoluteString, "scope": "National"],
            keywords: [title, summary, website.host ?? "", "official source"],
            explicitPersonaTags: nil
        )
    }

    private static func visuals(id: String, title: String, sourceURL: URL) -> NetherlandsVisualSet {
        let asset = AppImageAsset(
            id: "\(id):official-symbol",
            url: nil,
            localAssetName: "home_documents_city_hall",
            title: title,
            description: "YouNew official-service visual",
            sourceName: "YouNew",
            sourceURL: sourceURL,
            license: "Bundled application asset",
            attribution: "YouNew",
            width: nil,
            height: nil,
            type: .officialSymbol,
            verified: true,
            retrievedAt: checkedAt
        )
        return NetherlandsVisualSet(hero: asset, gallery: [asset], thumbnail: asset, mapPreview: asset, categoryCover: asset)
    }

    private static var checkedDate: Date? {
        ISO8601DateFormatter().date(from: "\(checkedAt)T00:00:00Z")
    }
}
