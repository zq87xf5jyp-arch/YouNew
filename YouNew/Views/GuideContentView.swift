import SwiftUI

// MARK: - Models

struct GuideSection: Identifiable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    let articles: [GuideArticle]
    let titleEN: String?
    let subtitleEN: String?
    let personaTags: Set<PersonaTag>

    init(
        id: String,
        icon: String,
        title: String,
        subtitle: String,
        tint: Color,
        articles: [GuideArticle],
        titleEN: String? = nil,
        subtitleEN: String? = nil,
        personaTags: Set<PersonaTag> = []
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.tint = tint
        self.articles = articles
        self.titleEN = titleEN
        self.subtitleEN = subtitleEN
        self.personaTags = GuideSection.assignedPersonaTags(
            explicitTags: personaTags,
            id: id,
            title: titleEN ?? title,
            subtitle: subtitleEN ?? subtitle,
            articles: articles
        )
    }

    nonisolated func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }

    nonisolated func visibleArticles(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> [GuideArticle] {
        articles.filter { $0.isVisible(for: persona, scope: scope) }
    }
}

struct GuideArticle: Identifiable {
    let id: String
    let title: String
    let summary: String
    let blocks: [GuideBlock]
    let links: [ExternalLink]
    let updatedDate: String?
    let readingMinutes: Int?
    let isOfficial: Bool
    let titleEN: String?
    let summaryEN: String?
    let blocksEN: [GuideBlock]?
    let personaTags: Set<PersonaTag>

    init(
        id: String,
        title: String,
        summary: String,
        blocks: [GuideBlock],
        links: [ExternalLink],
        updatedDate: String? = nil,
        readingMinutes: Int? = nil,
        isOfficial: Bool = false,
        titleEN: String? = nil,
        summaryEN: String? = nil,
        blocksEN: [GuideBlock]? = nil,
        personaTags: Set<PersonaTag> = []
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.blocks = blocks
        self.links = links
        self.updatedDate = updatedDate
        self.readingMinutes = readingMinutes
        self.isOfficial = isOfficial
        self.titleEN = titleEN
        self.summaryEN = summaryEN
        self.blocksEN = blocksEN
        self.personaTags = PersonaContentPolicy.assignedTags(
            explicitTags: personaTags,
            category: id,
            title: titleEN ?? title,
            summary: summaryEN ?? summary,
            keywords: [id, title, summary],
            sources: links.map {
                OfficialSource(
                    title: $0.title,
                    url: AppURL.validatedWebURL(URL(string: $0.urlString)),
                    institution: $0.institution
                )
            }
        )
    }

    nonisolated func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}

enum GuideBlock {
    case paragraph(String)
    case step(index: Int, text: String)
    case warning(String)
    case tip(String)
    case term(dutch: String, meaning: String)
}

struct ExternalLink: Identifiable {
    let id: String
    let title: String
    let urlString: String
    let institution: String
}

// MARK: - Content Registry

enum GuideContent {
    nonisolated static let sections: [GuideSection] = [
        documentsSection,
        touristDocumentsSection,
        housingSection,
        transportSection,
        healthcareSection,
        finesSection,
        workSection,
        integrationSection,
        emergencySection
    ]

    nonisolated static func section(id: String) -> GuideSection? {
        sections.first { $0.id == id }
    }

    nonisolated static func section(id: String, activePersona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> GuideSection? {
        guard let section = section(id: id), section.isVisible(for: activePersona, scope: scope) else { return nil }
        return section
    }

    nonisolated static func article(sectionID: String, articleID: String) -> (GuideArticle, Color)? {
        guard let sec = section(id: sectionID),
              let art = sec.articles.first(where: { $0.id == articleID })
        else { return nil }
        return (art, sec.tint)
    }

    nonisolated static func article(sectionID: String, articleID: String, activePersona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> (GuideArticle, Color)? {
        guard let sec = section(id: sectionID, activePersona: activePersona, scope: scope),
              let art = sec.articles.first(where: { $0.id == articleID && $0.isVisible(for: activePersona, scope: scope) })
        else { return nil }
        return (art, sec.tint)
    }
}

private extension GuideSection {
    static func assignedPersonaTags(
        explicitTags: Set<PersonaTag>,
        id: String,
        title: String,
        subtitle: String,
        articles: [GuideArticle]
    ) -> Set<PersonaTag> {
        if !explicitTags.isEmpty { return explicitTags }

        switch id {
        case "tourist-documents":
            return [.tourist]
        case "documents":
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case "housing":
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case "transport", "healthcare", "emergency":
            return [.student, .worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case "fines":
            return [.worker, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur]
        case "work":
            return [.worker, .refugee, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur]
        case "integration":
            return [.refugee, .family, .lgbt]
        default:
            let articleTags = articles.reduce(into: Set<PersonaTag>()) { tags, article in
                tags.formUnion(article.personaTags)
            }
            if !articleTags.isEmpty { return articleTags }
            return PersonaContentPolicy.assignedTags(
                category: id,
                title: title,
                summary: subtitle,
                keywords: [id, title, subtitle],
                sources: []
            )
        }
    }
}

private extension GuideSection {
    func localizedTitle(_ lang: AppLanguage) -> String {
        titleEN ?? GuideEnglishFallback.sectionText[id]?.title ?? title
    }

    func localizedSubtitle(_ lang: AppLanguage) -> String {
        subtitleEN ?? GuideEnglishFallback.sectionText[id]?.subtitle ?? subtitle
    }
}

private extension GuideArticle {
    func localizedTitle(_ lang: AppLanguage) -> String {
        titleEN ?? GuideEnglishFallback.articleText[id]?.title ?? title
    }

    func localizedSummary(_ lang: AppLanguage) -> String {
        summaryEN ?? GuideEnglishFallback.articleText[id]?.summary ?? summary
    }

    func localizedBlocks(_ lang: AppLanguage) -> [GuideBlock] {
        blocksEN ?? GuideEnglishFallback.articleText[id]?.blocks ?? blocks
    }

    var hasMetadata: Bool {
        updatedDate != nil || readingMinutes != nil || isOfficial
    }
}

private extension ExternalLink {
    func localizedTitle(_ lang: AppLanguage) -> String {
        GuideEnglishFallback.linkTitles[id] ?? title
    }
}

private enum GuideEnglishFallback {
    static let sectionText: [String: (title: String, subtitle: String)] = [
        "documents": ("Documents", "BSN, DigiD, BRP registration, and official letters for life in the Netherlands"),
        "tourist-documents": ("Lost documents", "Passport, ID, embassy, consulate, and police steps for tourists"),
        "housing": ("Housing", "Renting, huurtoeslag, tenant rights, and registration checks"),
        "transport": ("Transport", "OV-chipkaart, OVpay, bicycles, trains, and everyday travel"),
        "healthcare": ("Healthcare", "Health insurance, huisarts, pharmacy, urgent care, and official sources"),
        "fines": ("Fines", "Cycling fines, parking fines, CJIB letters, and how to respond")
    ]

    static let linkTitles: [String: String] = [
        "bsn-gov": "BSN - Rijksoverheid",
        "expat-center": "Expat Center Amsterdam",
        "digid-official": "Official DigiD website",
        "digid-aanvragen": "Request DigiD",
        "brp-gov": "BRP - Rijksoverheid",
        "juridisch-loket": "Juridisch Loket - legal help",
        "huurcommissie": "Huurcommissie - tenant rights",
        "funda-huur": "Rental housing on Funda",
        "huurtoeslag-belast": "Huurtoeslag - Belastingdienst",
        "toeslagen-portal": "Toeslagen portal",
        "huurcommissie2": "Huurcommissie - dispute resolution",
        "juridisch-loket2": "Juridisch Loket - legal help",
        "ov-site": "OV-chipkaart official website",
        "9292": "9292 route planner",
        "fietsdiefstal": "Report bicycle theft",
        "marktplaats-fiets": "Second-hand bicycles on Marktplaats",
        "ns-site": "NS official website",
        "dal-voordeel": "Dal Voordeel subscription",
        "zorgwijzer": "Compare health insurance - Zorgwijzer",
        "zorgtoeslag-belast": "Zorgtoeslag - Belastingdienst",
        "zorgkaart": "Find a GP - Zorgkaart",
        "huisarts-rijksoverheid": "GP guidance - Rijksoverheid",
        "emergency-112": "Emergency number 112",
        "crisis-113": "113 suicide prevention",
        "boetes-om": "Fine amounts - Openbaar Ministerie",
        "cjib-fiets": "CJIB - pay fines",
        "parkmobile": "ParkMobile - pay parking",
        "cjib-parking": "CJIB - pay parking fines",
        "cjib-main": "CJIB official website",
        "cjib-bezwaar": "Object to a fine online",
        "foreign-embassies": "Foreign embassies and consulates",
        "politie-contact": "Police contact"
    ]

    static let articleText: [String: (title: String, summary: String, blocks: [GuideBlock])] = [
        "bsn": (
            "BSN - citizen service number",
            "The personal number used for banking, work, insurance, tax, and government services",
            [
                .paragraph("BSN stands for Burgerservicenummer. It is your personal number in Dutch public administration and is needed for most official and practical steps after arrival."),
                .step(index: 1, text: "Register with the municipality where you live. The BSN is issued or confirmed during BRP registration."),
                .step(index: 2, text: "Bring a valid passport or ID and proof of address, such as a rental contract or permission letter."),
                .step(index: 3, text: "Use the BSN for DigiD, bank accounts, payroll, health insurance, tax, and benefits."),
                .warning("Treat your BSN as sensitive personal data. Share it only with official institutions, employers, banks, insurers, and other trusted parties that legally need it."),
                .tip("If you stay less than four months, check whether an RNI registration route is more appropriate than full BRP registration."),
                .term(dutch: "Burgerservicenummer", meaning: "Citizen service number, usually shortened to BSN"),
                .term(dutch: "Gemeente", meaning: "Municipality, the local authority that handles address registration")
            ]
        ),
        "digid": (
            "DigiD - digital access to official services",
            "How to request DigiD and avoid phishing",
            [
                .paragraph("DigiD is the official Dutch digital identity system. You use it to sign in to government, tax, healthcare, education, and benefit portals."),
                .step(index: 1, text: "Go directly to digid.nl and request DigiD with your BSN, date of birth, postcode, and address."),
                .step(index: 2, text: "Wait for the activation letter at your registered address, then activate your account before the deadline."),
                .step(index: 3, text: "Install the DigiD app and enable secure login. The app is safer than SMS-only login."),
                .warning("Never sign in through links from text messages, email, or social media. Type digid.nl yourself or use the official app."),
                .tip("Keep your activation letter until setup is complete, then store account recovery information securely."),
                .term(dutch: "Aanvragen", meaning: "To request or apply for a service"),
                .term(dutch: "Activeren", meaning: "To activate your account")
            ]
        ),
        "brp": (
            "BRP registration - your official address",
            "Registering your address in the Dutch population database",
            [
                .paragraph("BRP is the Dutch personal records database. If you live in the Netherlands for more than four months, you normally register your address with the municipality."),
                .step(index: 1, text: "Book an appointment on the official municipality website for your city."),
                .step(index: 2, text: "Bring a valid identity document and address proof, such as a rental contract or signed permission from the main resident."),
                .step(index: 3, text: "Check that your name, address, date of birth, and nationality are entered correctly."),
                .step(index: 4, text: "Save the registration confirmation. You may need it for banking, insurance, work, and benefits."),
                .warning("If a landlord refuses registration at the address where you actually live, ask for legal advice before signing or paying."),
                .tip("After BRP registration, request DigiD so you can use official online services."),
                .term(dutch: "BRP", meaning: "Basisregistratie Personen, the Dutch population register"),
                .term(dutch: "Inschrijven", meaning: "Registering at an address")
            ]
        ),
        "lost-documents": (
            "Lost passport or ID",
            "What tourists should do after losing travel documents in the Netherlands",
            [
                .paragraph("If you lose your passport, ID, residence card, or travel document while visiting the Netherlands, treat it as a document-replacement problem first. It is not the same flow as calling emergency services unless you are in immediate danger."),
                .step(index: 1, text: "Make sure you are safe. If there is life danger, violence, fire, or a crime happening now, call 112."),
                .step(index: 2, text: "Retrace the last place you used the document: hotel, museum, train station, restaurant, taxi, or event desk."),
                .step(index: 3, text: "Contact your embassy or consulate. Only your own country can confirm replacement travel document options."),
                .step(index: 4, text: "If the document was stolen, contact the police through the non-emergency route or official Politie.nl instructions. Keep any report or reference number."),
                .step(index: 5, text: "Before travelling, confirm with your airline, embassy or consulate, and border authority which replacement document is accepted."),
                .warning("Do not type passport numbers, BSN, full address, or document scans into chat. Use official embassy, consulate, police, airline, and border-control channels."),
                .tip("Keep a protected copy of your passport photo page separate from the original. A copy is not a travel document, but it can speed up replacement checks."),
                .term(dutch: "Ambassade", meaning: "Embassy"),
                .term(dutch: "Consulaat", meaning: "Consulate"),
                .term(dutch: "Aangifte", meaning: "Police report or formal report")
            ]
        ),
        "renting": (
            "Renting a home",
            "Where to search, what to check in a contract, and which costs to expect",
            [
                .paragraph("The Dutch rental market is competitive. Check the contract, registration possibility, service costs, deposit, and landlord identity before transferring money."),
                .step(index: 1, text: "Search through trusted platforms, housing corporations, university housing offices, or verified agencies."),
                .step(index: 2, text: "Confirm that BRP registration is allowed at the address. Without registration, many official steps become difficult."),
                .step(index: 3, text: "Check rent, service costs, utilities, deposit, notice period, furniture, and the handover condition report."),
                .step(index: 4, text: "Pay by bank transfer only after you have a written contract and verified the landlord or agency."),
                .warning("Be careful with offers that are too cheap, pressure you to pay quickly, or refuse a viewing or registration."),
                .tip("Photograph the room or apartment at move-in and save all messages about repairs and costs."),
                .term(dutch: "Waarborgsom", meaning: "Deposit"),
                .term(dutch: "Servicekosten", meaning: "Service costs charged in addition to rent")
            ]
        ),
        "huurtoeslag": (
            "Huurtoeslag - rent allowance",
            "Monthly rent support for eligible tenants",
            [
                .paragraph("Huurtoeslag is a Dutch rent allowance for people whose rent, income, household situation, and home type meet the rules."),
                .step(index: 1, text: "Check whether your rent, income, age, assets, and registration address meet the current Belastingdienst rules."),
                .step(index: 2, text: "Apply through toeslagen.nl with DigiD if you appear eligible."),
                .step(index: 3, text: "Keep your rent contract, service cost breakdown, income information, and address registration ready."),
                .step(index: 4, text: "Report changes in income, rent, household members, or address quickly to avoid repayment later."),
                .warning("Allowance estimates can change. If you receive too much, Belastingdienst can ask you to pay it back."),
                .tip("Use the official proefberekening calculator before applying."),
                .term(dutch: "Huurtoeslag", meaning: "Rent allowance"),
                .term(dutch: "Toeslagen", meaning: "Allowances such as rent, healthcare, and childcare support")
            ]
        ),
        "tenant-rights": (
            "Tenant rights",
            "What a landlord must do and where to get help in a dispute",
            [
                .paragraph("Tenants in the Netherlands have strong legal protections. Repairs, privacy, deposit handling, rent rules, and eviction all have legal limits."),
                .step(index: 1, text: "Put repair requests in writing and keep photos, dates, and replies."),
                .step(index: 2, text: "Check whether Huurcommissie can assess rent, service costs, or maintenance issues in your situation."),
                .step(index: 3, text: "Contact Juridisch Loket for first legal guidance if the issue escalates."),
                .warning("A landlord cannot simply evict you without legal procedure. Do not ignore letters about termination or court steps."),
                .tip("Keep your contract, payment records, inspection report, and all landlord communication in one folder."),
                .term(dutch: "Huurcommissie", meaning: "Dutch rent tribunal for many rent and service-cost disputes"),
                .term(dutch: "Opzegtermijn", meaning: "Notice period")
            ]
        ),
        "ov-chipkaart": (
            "OV-chipkaart - public transport card",
            "How to get, top up, and use the Dutch transport card correctly",
            [
                .paragraph("OV-chipkaart is a reusable public transport card for trains, trams, buses, and metro. You check in before travel and check out at the end."),
                .step(index: 1, text: "Buy an anonymous card at a station machine or order a personal card online if you need subscriptions or balance recovery."),
                .step(index: 2, text: "Add enough balance before travelling. Trains usually require a higher minimum balance than city transport."),
                .step(index: 3, text: "Check in at the gate or pole before boarding and check out when you leave the vehicle or station."),
                .step(index: 4, text: "If you forget to check out, request correction through the official channel as soon as possible."),
                .warning("Travelling without a valid check-in can lead to a fine plus the fare."),
                .tip("OVpay lets many travellers check in with a bank card or phone, but subscriptions and discounts may still require a personal OV-chipkaart."),
                .term(dutch: "Inchecken", meaning: "Checking in before travel"),
                .term(dutch: "Uitchecken", meaning: "Checking out after travel")
            ]
        ),
        "bicycle": (
            "Cycling in the Netherlands",
            "Traffic rules, buying a bike, lights, locks, and theft prevention",
            [
                .paragraph("Cycling is everyday transport in the Netherlands. You are expected to follow traffic lights, use lights in the dark, signal clearly, and park in allowed areas."),
                .step(index: 1, text: "Buy from a bike shop, trusted second-hand platform, or university/community marketplace."),
                .step(index: 2, text: "Use two locks: a frame lock and a chain lock attached to a fixed object when possible."),
                .step(index: 3, text: "Use a white front light and red rear light in darkness or poor visibility."),
                .step(index: 4, text: "Park in marked bicycle parking zones, especially around stations and city centres."),
                .warning("Holding a phone while cycling, running a red light, or cycling without lights can result in fines."),
                .tip("Take a photo of the frame number and keep the purchase receipt. It helps with police reports and insurance."),
                .term(dutch: "Fietspad", meaning: "Cycle path"),
                .term(dutch: "Ringslot", meaning: "Frame lock")
            ]
        ),
        "trains": (
            "NS trains - basics",
            "Tickets, classes, discounts, delays, and everyday train travel",
            [
                .paragraph("NS is the main train operator for national rail travel. Intercity and Sprinter services connect most major cities and regions."),
                .step(index: 1, text: "Plan trips with the NS app, 9292, or station displays and check for disruptions before leaving."),
                .step(index: 2, text: "Use OV-chipkaart, OVpay, or a ticket. Always check in and out at the station."),
                .step(index: 3, text: "Choose second class by default unless your ticket or subscription includes first class."),
                .step(index: 4, text: "For frequent travel, compare subscriptions such as off-peak discounts."),
                .warning("A missed check-in or invalid ticket can lead to a fine plus the fare."),
                .tip("If your train is delayed, check NS rules for possible compensation."),
                .term(dutch: "Sprinter", meaning: "Train service that stops more often"),
                .term(dutch: "Intercity", meaning: "Faster city-to-city train service")
            ]
        ),
        "insurance": (
            "Health insurance",
            "Basic insurance, eigen risico, zorgtoeslag, and first setup",
            [
                .paragraph("Dutch basic health insurance is mandatory for many residents and workers. Arrange it on time after you become insurance-obliged."),
                .step(index: 1, text: "Check whether your residence, work, or study situation creates a Dutch insurance obligation."),
                .step(index: 2, text: "Compare basic policies and check premiums, contracted care, deductible options, and customer support language."),
                .step(index: 3, text: "Register with a huisarts after arranging insurance or as soon as possible in your neighbourhood."),
                .step(index: 4, text: "Check whether you qualify for zorgtoeslag through the official allowance portal."),
                .warning("If you are required to have insurance and arrange it late, CAK can issue warnings and fines."),
                .tip("The huisarts visit itself is normally outside the mandatory deductible, but many follow-up services can count toward it."),
                .term(dutch: "Basisverzekering", meaning: "Mandatory basic health insurance"),
                .term(dutch: "Eigen risico", meaning: "Mandatory deductible")
            ]
        ),
        "huisarts": (
            "Huisarts - your GP",
            "How to find a GP and what to do if practices are full",
            [
                .paragraph("The huisarts is the first point of contact for most medical questions. Specialists usually require a referral from the GP."),
                .step(index: 1, text: "Search for GP practices near your registered address and check whether they accept new patients."),
                .step(index: 2, text: "Contact the practice with your address, insurance details, and registration request."),
                .step(index: 3, text: "If practices are full, ask your insurer for help finding available GP care."),
                .step(index: 4, text: "For urgent care outside office hours, call the regional huisartsenpost first."),
                .warning("Do not use hospital emergency care for non-urgent problems when GP or huisartsenpost care is appropriate."),
                .tip("Save your GP phone number, huisartsenpost number, insurance policy number, and pharmacy details."),
                .term(dutch: "Huisarts", meaning: "General practitioner or family doctor"),
                .term(dutch: "Doorverwijzing", meaning: "Referral to specialist care")
            ]
        ),
        "urgent-care": (
            "Urgent medical care",
            "Huisartsenpost, emergency department, and when to call 112",
            [
                .paragraph("Dutch urgent care is organised by severity. Use 112 for life danger, the huisarts during office hours, and huisartsenpost for urgent GP care outside office hours."),
                .step(index: 1, text: "Call your huisarts for non-life-threatening medical problems during office hours."),
                .step(index: 2, text: "Call the huisartsenpost first in evenings, nights, weekends, and holidays."),
                .step(index: 3, text: "Call 112 immediately for life danger, severe injury, stroke symptoms, heart attack symptoms, or serious accidents."),
                .step(index: 4, text: "Bring ID, insurance details, medication list, and address information when you go for urgent care."),
                .warning("Going directly to the emergency department without triage can lead to long waits or redirection."),
                .tip("Write down symptoms, timing, medication, allergies, and temperature before calling triage."),
                .term(dutch: "Huisartsenpost", meaning: "Out-of-hours GP service"),
                .term(dutch: "SEH", meaning: "Hospital emergency department")
            ]
        ),
        "bike-fines": (
            "Cycling fines",
            "Common cycling offences and how to avoid them",
            [
                .paragraph("Cycling rules are enforced in Dutch cities, especially around stations, nightlife areas, and busy intersections."),
                .step(index: 1, text: "Use working front and rear lights when visibility is poor."),
                .step(index: 2, text: "Stop at red lights and follow signs for cyclists."),
                .step(index: 3, text: "Do not hold a phone while cycling."),
                .step(index: 4, text: "Park only where bicycles are allowed, especially near stations."),
                .warning("Confiscated bikes may require a fee and proof of ownership to retrieve."),
                .tip("Use official bicycle parking if you leave a bike in a city centre for more than a short stop."),
                .term(dutch: "Fietslicht", meaning: "Bicycle light"),
                .term(dutch: "Fietsenstalling", meaning: "Bicycle parking facility")
            ]
        ),
        "parking-fines": (
            "Parking fines",
            "Paid zones, apps, parking signs, and what to do after a fine",
            [
                .paragraph("Most Dutch cities have paid parking zones and strict enforcement. Always check signs, payment hours, and permit rules."),
                .step(index: 1, text: "Check whether the street requires paid parking, a resident permit, or a blue parking disc."),
                .step(index: 2, text: "Pay through a meter or trusted parking app and verify the licence plate."),
                .step(index: 3, text: "Stop the parking session when you leave if you use an app."),
                .step(index: 4, text: "If you receive a fine, check the issuer, date, location, licence plate, and objection deadline."),
                .warning("Parking in disabled spaces, bus stops, no-parking zones, or blocking traffic can lead to high fines or towing."),
                .tip("Take a photo of signs if the rules are unclear. It can help if you need to object."),
                .term(dutch: "Parkeerbon", meaning: "Parking fine notice"),
                .term(dutch: "Wegslepen", meaning: "Towing")
            ]
        ),
        "cjib": (
            "CJIB - paying or challenging a fine",
            "Payment deadlines, letters, instalments, and objections",
            [
                .paragraph("CJIB collects many traffic and administrative fines in the Netherlands. Letters include the amount, reference number, payment deadline, and next steps."),
                .step(index: 1, text: "Check that the letter is genuine by using the official cjib.nl website and the reference details on the letter."),
                .step(index: 2, text: "Pay before the deadline if the fine is correct."),
                .step(index: 3, text: "If you disagree, read the objection instructions and submit your response before the deadline."),
                .step(index: 4, text: "If payment is difficult, check whether a payment arrangement is available."),
                .warning("Ignoring CJIB letters can increase the amount and lead to stronger collection measures."),
                .tip("Keep the envelope, letter, screenshots, payment confirmation, and all appeal correspondence together."),
                .term(dutch: "Kenmerk", meaning: "Reference number used in official correspondence"),
                .term(dutch: "Bezwaar", meaning: "Objection or appeal")
            ]
        )
    ]
}

// MARK: - Documents

private extension GuideContent {
    static var touristDocumentsSection: GuideSection {
        GuideSection(
            id: "tourist-documents",
            icon: "doc.badge.exclamationmark.fill",
            title: "Потерянные документы",
            subtitle: "Паспорт, ID, посольство, консульство и полиция для туристов",
            tint: AppColors.cyanGlow,
            articles: [lostDocumentsArticle],
            titleEN: "Lost documents",
            subtitleEN: "Passport, ID, embassy, consulate, and police steps for tourists",
            personaTags: [.tourist]
        )
    }

    static var lostDocumentsArticle: GuideArticle {
        GuideArticle(
            id: "lost-documents",
            title: "Потерян паспорт или ID",
            summary: "Что делать туристу, если документ потерян или украден в Нидерландах",
            blocks: [
                .paragraph("Если вы потеряли паспорт, ID, карту резидента или travel document в Нидерландах, это не обычный emergency flow. Сначала восстановите безопасность, затем идите по маршруту: место потери, посольство/консульство, полиция при краже."),
                .step(index: 1, text: "Убедитесь, что вы в безопасности. Если есть угроза жизни, насилие, пожар или преступление происходит прямо сейчас - звоните 112."),
                .step(index: 2, text: "Проверьте последние места: отель, музей, вокзал, ресторан, такси, стойка мероприятия или lost & found."),
                .step(index: 3, text: "Свяжитесь с посольством или консульством своей страны. Только они могут подтвердить замену паспорта или emergency travel document."),
                .step(index: 4, text: "Если документ украден, используйте официальный маршрут полиции для заявления или несрочного контакта. Сохраните номер заявления/референс."),
                .step(index: 5, text: "Перед поездкой уточните у авиакомпании, посольства/консульства и пограничной службы, какой документ примут для выезда."),
                .warning("Не вводите паспортные номера, BSN, полный адрес или сканы документов в чат. Используйте только официальные каналы посольства, консульства, полиции, авиакомпании и border control."),
                .tip("Храните защищенную копию страницы паспорта отдельно от оригинала. Копия не заменяет документ, но помогает быстрее пройти проверку для замены."),
                .term(dutch: "Ambassade", meaning: "Посольство"),
                .term(dutch: "Consulaat", meaning: "Консульство"),
                .term(dutch: "Aangifte", meaning: "Заявление в полицию")
            ],
            links: [
                ExternalLink(id: "foreign-embassies", title: "Foreign embassies and consulates", urlString: "https://www.government.nl/topics/embassies-consulates-and-other-representations", institution: "Government.nl"),
                ExternalLink(id: "politie-contact", title: "Police contact", urlString: "https://www.politie.nl/en/contact", institution: "Politie.nl")
            ],
            updatedDate: "2026-06-22",
            readingMinutes: 3,
            isOfficial: false,
            titleEN: "Lost passport or ID",
            summaryEN: "What tourists should do after losing travel documents in the Netherlands",
            personaTags: [.tourist]
        )
    }

    static var documentsSection: GuideSection {
        GuideSection(
            id: "documents",
            icon: "doc.text.fill",
            title: "Документы",
            subtitle: "BSN, DigiD и регистрация в BRP — ключевые документы для жизни в Нидерландах",
            tint: AppColors.cyanGlow,
            articles: [bsnArticle, digiDArticle, brpArticle]
        )
    }

    static var bsnArticle: GuideArticle {
        GuideArticle(
            id: "bsn",
            title: "BSN — бюргерский сервисный номер",
            summary: "Уникальный 9-значный номер, необходимый для банка, страховки и работы",
            blocks: [
                .paragraph("BSN (Burgerservicenummer) — ваш личный идентификатор во всех государственных системах Нидерландов. Без него не открыть счёт в банке, не оформить медицинскую страховку, не устроиться на работу и не зарегистрировать DigiD."),
                .step(index: 1, text: "Зарегистрируйтесь в муниципалитете (gemeente) по месту проживания — BSN выдают автоматически при регистрации"),
                .step(index: 2, text: "В некоторых городах expat center помогает с регистрацией, но доступ и сроки зависят от города, работодателя, статуса и записи"),
                .step(index: 3, text: "Срок получения или подтверждения BSN зависит от gemeente и типа регистрации. Проверьте BRP/RNI маршрут для вашей ситуации."),
                .warning("Не считайте один маршрут универсальным: жители обычно идут через BRP, а краткосрочное пребывание может требовать RNI. Проверяйте официальный сайт gemeente или Rijksoverheid."),
                .tip("Храните BSN конфиденциально — он нужен при каждом обращении в госорган, банк или страховую компанию."),
                .term(dutch: "Burgerservicenummer (BSN)", meaning: "Уникальный личный идентификатор гражданина в государственных системах"),
                .term(dutch: "Gemeente", meaning: "Муниципалитет — местный административный орган")
            ],
            links: [
                ExternalLink(id: "bsn-gov", title: "BSN — Rijksoverheid", urlString: "https://www.rijksoverheid.nl/onderwerpen/persoonsgegevens/burgerservicenummer-bsn", institution: "Rijksoverheid"),
                ExternalLink(id: "expat-center", title: "Expat Center Amsterdam", urlString: "https://www.iamsterdam.com/en/live-work-study/in-amsterdam/official-matters/registration-at-the-municipality", institution: "City of Amsterdam")
            ]
        )
    }

    static var digiDArticle: GuideArticle {
        GuideArticle(
            id: "digid",
            title: "DigiD — цифровой ключ к государственным сервисам",
            summary: "Как зарегистрировать DigiD и защититься от фишинга",
            blocks: [
                .paragraph("DigiD — официальная система цифровой идентификации Нидерландов. Без неё нельзя войти на сайты Belastingdienst, DUO, страховых порталов и большинства государственных сервисов."),
                .step(index: 1, text: "Зайдите на digid.nl — только через прямой ввод URL, не через ссылки из писем и СМС"),
                .step(index: 2, text: "Нажмите «Aanvragen» и укажите ваш BSN, дату рождения и адрес"),
                .step(index: 3, text: "Через 5 дней придёт письмо с кодом активации — введите его на сайте"),
                .step(index: 4, text: "Установите мобильное приложение DigiD и подключите вход по лицу или отпечатку пальца"),
                .warning("Фишинг под DigiD — одна из самых частых мошеннических схем в Нидерландах. Никогда не входите по ссылкам из СМС или e-mail. Только digid.nl напрямую."),
                .tip("Приложение DigiD с биометрией безопаснее SMS-кода. После регистрации активируйте его в первую очередь."),
                .term(dutch: "DigiD", meaning: "Digitale Identiteit — официальный цифровой идентификатор для госсервисов Нидерландов"),
                .term(dutch: "Aanvragen", meaning: "Подать заявку / запросить услугу")
            ],
            links: [
                ExternalLink(id: "digid-official", title: "Официальный сайт DigiD", urlString: "https://www.digid.nl", institution: "Logius"),
                ExternalLink(id: "digid-aanvragen", title: "Зарегистрировать DigiD", urlString: "https://www.digid.nl/aanvragen-en-activeren/digid-aanvragen", institution: "Logius")
            ]
        )
    }

    static var brpArticle: GuideArticle {
        GuideArticle(
            id: "brp",
            title: "Регистрация в BRP — ваш официальный адрес",
            summary: "Обязательная регистрация по месту проживания в базе данных населения",
            blocks: [
                .paragraph("BRP (Basisregistratie Personen) — государственный реестр населения. Все, кто живёт в Нидерландах более 4 месяцев в году, обязаны зарегистрироваться. Без регистрации недоступны toeslagen, DigiD и многие госуслуги."),
                .step(index: 1, text: "Запишитесь на приём в gemeente — через официальный сайт муниципалитета или по телефону"),
                .step(index: 2, text: "Возьмите с собой: паспорт или ID-карту и договор аренды или письмо от арендодателя"),
                .step(index: 3, text: "На приёме укажите ваш адрес — gemeente внесёт данные в BRP и выдаст или подтвердит BSN"),
                .step(index: 4, text: "Сохраните подтверждение регистрации — оно нужно для банка, страховой и toeslagen"),
                .warning("Арендодатель обязан дать разрешение на регистрацию по своему адресу. Если отказывает — это нарушение ваших прав. Обратитесь в Juridisch Loket за бесплатной помощью."),
                .tip("После регистрации в BRP можно оформить DigiD — не раньше, так как для DigiD нужны данные из BRP."),
                .term(dutch: "BRP", meaning: "Basisregistratie Personen — база регистрации населения Нидерландов"),
                .term(dutch: "Inschrijven", meaning: "Официальная регистрация по адресу в муниципалитете")
            ],
            links: [
                ExternalLink(id: "brp-gov", title: "BRP на Rijksoverheid.nl", urlString: "https://www.rijksoverheid.nl/onderwerpen/privacy-en-persoonsgegevens/basisregistratie-personen-brp", institution: "Rijksoverheid"),
                ExternalLink(id: "juridisch-loket", title: "Juridisch Loket — бесплатная юрпомощь", urlString: "https://www.juridischloket.nl", institution: "Juridisch Loket")
            ]
        )
    }
}

// MARK: - Housing

private extension GuideContent {
    static var housingSection: GuideSection {
        GuideSection(
            id: "housing",
            icon: "house.fill",
            title: "Жильё",
            subtitle: "Аренда, huurtoeslag и права арендатора в Нидерландах",
            tint: AppColors.violet,
            articles: [rentingArticle, huurtoeslagArticle, tenantRightsArticle]
        )
    }

    static var rentingArticle: GuideArticle {
        GuideArticle(
            id: "renting",
            title: "Аренда жилья",
            summary: "Где искать, что проверять в договоре и какие расходы ожидать",
            blocks: [
                .paragraph("В Нидерландах два сектора аренды: социальное жильё (sociale huur) с длинными очередями и ценовым потолком, и частный сектор (vrije sector) — без очереди, но дороже."),
                .step(index: 1, text: "Ищите жильё через Pararius, Funda.nl/huur, Kamernet или локальные Facebook-группы"),
                .step(index: 2, text: "Изучите договор: размер и дата платежа, что включает коммунальные, срок аренды, условия расторжения"),
                .step(index: 3, text: "Убедитесь, что арендодатель разрешает регистрацию в BRP по этому адресу — это обязательно для получения госуслуг"),
                .step(index: 4, text: "Уточните waarborgsom (депозит) — по закону не более 2 месяцев арендной платы"),
                .warning("Не переводите депозит до подписания официального договора. Мошенничество с жильём распространено: слишком выгодное предложение почти всегда ловушка."),
                .tip("При заселении сфотографируйте все повреждения и дефекты — это защитит ваш депозит при выезде. Составьте акт осмотра."),
                .term(dutch: "Sociale huur", meaning: "Социальное жильё с ценовым потолком — очередь может занять годы"),
                .term(dutch: "Vrije sector", meaning: "Частный рынок аренды без ценовых ограничений"),
                .term(dutch: "Waarborgsom", meaning: "Депозит — арендодатель обязан вернуть в течение 14 дней после выезда")
            ],
            links: [
                ExternalLink(id: "huurcommissie", title: "Huurcommissie — права арендатора", urlString: "https://www.huurcommissie.nl", institution: "Huurcommissie"),
                ExternalLink(id: "funda-huur", title: "Поиск жилья на Funda", urlString: "https://www.funda.nl/huur", institution: "Funda")
            ]
        )
    }

    static var huurtoeslagArticle: GuideArticle {
        GuideArticle(
            id: "huurtoeslag",
            title: "Huurtoeslag — субсидия на аренду",
            summary: "Государственная ежемесячная помощь для снижения расходов на жильё",
            blocks: [
                .paragraph("Huurtoeslag — ежемесячная субсидия от государства для арендаторов с невысоким доходом. Выплачивается Belastingdienst прямо на банковский счёт каждый месяц."),
                .step(index: 1, text: "Проверьте право через официальный портал: учитываются аренда, доход, возраст, состав домохозяйства и тип жилья. Пороги меняются."),
                .step(index: 2, text: "Войдите на toeslagen.nl через DigiD и подайте aanvraag (заявку)"),
                .step(index: 3, text: "Подавайте в год начала аренды — retroactively компенсируют максимум 3 месяца назад"),
                .step(index: 4, text: "Ежегодно продлевайте заявку или настройте автопролонгацию через личный кабинет"),
                .warning("Если доход изменился — сообщите в Belastingdienst немедленно. Переплата субсидии требует возврата, иногда с процентами."),
                .tip("Используйте proefberekening на belastingdienst.nl — предварительный расчёт суммы субсидии без обязательной подачи заявки."),
                .term(dutch: "Huurtoeslag", meaning: "Субсидия на аренду от Belastingdienst"),
                .term(dutch: "Toeslagen", meaning: "Государственные субсидии (huur, zorg, kinderopvang)")
            ],
            links: [
                ExternalLink(id: "huurtoeslag-belast", title: "Huurtoeslag — Belastingdienst", urlString: "https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/privé/toeslagen/huurtoeslag", institution: "Belastingdienst"),
                ExternalLink(id: "toeslagen-portal", title: "Портал toeslagen.nl", urlString: "https://www.toeslagen.nl", institution: "Belastingdienst / Toeslagen")
            ],
            personaTags: [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant]
        )
    }

    static var tenantRightsArticle: GuideArticle {
        GuideArticle(
            id: "tenant-rights",
            title: "Права арендатора",
            summary: "Что арендодатель обязан делать и как защититься при спорах",
            blocks: [
                .paragraph("Нидерландское законодательство надёжно защищает арендаторов. Выселение возможно только по судебному решению, арендодатель обязан поддерживать жильё в нормальном состоянии."),
                .step(index: 1, text: "При заселении составьте акт осмотра — перечислите все дефекты и подпишите оба экземпляра"),
                .step(index: 2, text: "О серьёзных проблемах (плесень, неисправное отопление) сообщайте арендодателю письменно (e-mail достаточно)"),
                .step(index: 3, text: "Если арендодатель не реагирует — обратитесь в Huurcommissie или Juridisch Loket"),
                .warning("Арендодатель не может войти в жильё без предупреждения — это нарушение вашей privacy. Исключение — только крайние случаи безопасности."),
                .tip("При получении уведомления о выселении (ontruiming) немедленно обратитесь за юридической помощью. Незаконное выселение — редкость: суд всегда стоит на стороне арендатора при правильном оформлении."),
                .term(dutch: "Huurcommissie", meaning: "Государственный орган по жилищным спорам"),
                .term(dutch: "Ontruiming", meaning: "Выселение — возможно только по решению суда"),
                .term(dutch: "Opzegtermijn", meaning: "Срок уведомления о расторжении договора — минимум 1 месяц")
            ],
            links: [
                ExternalLink(id: "huurcommissie2", title: "Huurcommissie — разрешение споров", urlString: "https://www.huurcommissie.nl", institution: "Huurcommissie"),
                ExternalLink(id: "juridisch-loket2", title: "Juridisch Loket — юридическая помощь", urlString: "https://www.juridischloket.nl", institution: "Juridisch Loket")
            ]
        )
    }
}

// MARK: - Transport

private extension GuideContent {
    static var transportSection: GuideSection {
        GuideSection(
            id: "transport",
            icon: "tram.fill",
            title: "Транспорт",
            subtitle: "OV-chipkaart, велосипед и поезда NS",
            tint: AppColors.dutchOrange,
            articles: [ovChipkaartArticle, bicycleArticle, trainArticle]
        )
    }

    static var ovChipkaartArticle: GuideArticle {
        GuideArticle(
            id: "ov-chipkaart",
            title: "OV-chipkaart — единая карта транспорта",
            summary: "Как получить, пополнить и правильно использовать транспортную карту",
            blocks: [
                .paragraph("OV-chipkaart — бесконтактная карта для оплаты всего общественного транспорта Нидерландов: поезда NS, трамваи, автобусы и метро. Работает по принципу check-in/check-out."),
                .step(index: 1, text: "Проверьте, подходит ли вам OV-chipkaart, OVpay или билет оператора. Условия и стоимость карты смотрите на официальном сайте."),
                .step(index: 2, text: "Проверьте минимальный баланс и правила check-in/check-out у вашего оператора перед поездкой."),
                .step(index: 3, text: "При посадке: приложите карту к жёлтому считывателю — зелёный свет означает успешный check-in"),
                .step(index: 4, text: "При выходе: обязательно сделайте check-out — без него спишут максимальный тариф маршрута"),
                .warning("Если забыли сделать check-out, деньги не возвращают автоматически. Подайте запрос на ov-chipkaart.nl в течение 30 дней."),
                .tip("Личная карта предпочтительнее: при утере баланс восстановят. Анонимную карту в случае потери не вернут."),
                .term(dutch: "Inchecken", meaning: "Приложить карту при входе — check-in"),
                .term(dutch: "Uitchecken", meaning: "Приложить карту при выходе — check-out"),
                .term(dutch: "Saldo", meaning: "Баланс на OV-chipkaart")
            ],
            links: [
                ExternalLink(id: "ov-site", title: "Сайт OV-chipkaart", urlString: "https://www.ov-chipkaart.nl", institution: "OV-chipkaart"),
                ExternalLink(id: "9292", title: "Планировщик маршрутов 9292", urlString: "https://9292.nl", institution: "9292 OV")
            ]
        )
    }

    static var bicycleArticle: GuideArticle {
        GuideArticle(
            id: "bicycle",
            title: "Велосипед в Нидерландах",
            summary: "Правила дорожного движения, покупка велосипеда и защита от кражи",
            blocks: [
                .paragraph("Велосипед — основной вид транспорта в Нидерландах: более 23 миллионов велосипедов при 17 миллионах жителей. Незнание правил не освобождает от штрафов."),
                .step(index: 1, text: "Покупайте велосипед в магазине, у проверенного продавца или через площадку с понятной историей покупки"),
                .step(index: 2, text: "Установите два замка: рамочный (ringslot) + цепной (kettingslot) — прикрепите к неподвижному объекту"),
                .step(index: 3, text: "Поставьте передний белый и задний красный фонари — закон обязывает при недостаточной видимости"),
                .step(index: 4, text: "Зарегистрируйте велосипед на nationaalregisterfietsdiefstal.nl с серийным номером рамы"),
                .warning("Езда без фонарей ночью, телефон в руке, красный свет и неправильная парковка могут привести к штрафу или эвакуации велосипеда. Суммы проверяйте на официальных страницах."),
                .tip("Для дорогого велосипеда рассмотрите страховку и хороший замок. Условия покрытия отличаются у страховщиков."),
                .term(dutch: "Fietspad", meaning: "Велодорожка — отдельная полоса для велосипедистов"),
                .term(dutch: "Ringslot", meaning: "Рамочный замок — крепится или встроен в раму"),
                .term(dutch: "Fietsdiefstal", meaning: "Кража велосипеда")
            ],
            links: [
                ExternalLink(id: "fietsdiefstal", title: "Регистрация велосипеда — Nationaal Register", urlString: "https://www.nationaalregisterfietsdiefstal.nl", institution: "Nationaal Register Fietsdiefstal"),
                ExternalLink(id: "marktplaats-fiets", title: "Подержанные велосипеды — Marktplaats", urlString: "https://www.marktplaats.nl/l/fietsen-en-brommers/fietsen-heren/", institution: "Marktplaats")
            ]
        )
    }

    static var trainArticle: GuideArticle {
        GuideArticle(
            id: "trains",
            title: "Поезда NS — основы",
            summary: "Тарифы, классы вагонов и скидки для постоянных пассажиров",
            blocks: [
                .paragraph("NS (Nederlandse Spoorwegen) — главная железнодорожная компания страны. Поезда между крупными городами ходят каждые 15–30 минут, расписание стабильное."),
                .step(index: 1, text: "Планируйте маршрут через приложение NS или сайт ns.nl — показывает задержки в реальном времени"),
                .step(index: 2, text: "Покупайте билет в автомате или используйте OV-chipkaart — check-in/check-out на платформе"),
                .step(index: 3, text: "Для частых поездок сравните актуальные подписки NS и региональных операторов: скидки, часы действия и цены меняются."),
                .step(index: 4, text: "2-й класс — стандарт, 1-й класс — тише и просторнее, но дороже на ~40%"),
                .warning("Езда без действительного билета или check-in может привести к штрафу и оплате поездки. Текущие суммы проверяйте у NS или оператора."),
                .tip("Приложение NS уведомляет об изменениях маршрута и задержках в реальном времени. Незаменимо для ежедневных поездок."),
                .term(dutch: "Dal-voordeel", meaning: "Скидка 40% в нерабочие часы — dal означает «впадина/непиковое время»"),
                .term(dutch: "Conducteur", meaning: "Контролёр в поезде NS"),
                .term(dutch: "Spits", meaning: "Час пик — в это время Dal-voordeel не действует")
            ],
            links: [
                ExternalLink(id: "ns-site", title: "Официальный сайт NS", urlString: "https://www.ns.nl", institution: "NS"),
                ExternalLink(id: "dal-voordeel", title: "Dal-voordeel подписка", urlString: "https://www.ns.nl/producten/voordeelurenabonnement", institution: "NS")
            ]
        )
    }
}

// MARK: - Healthcare

private extension GuideContent {
    static var healthcareSection: GuideSection {
        GuideSection(
            id: "healthcare",
            icon: "cross.case.fill",
            title: "Медицина",
            subtitle: "Страховка, huisarts, аптека и экстренная помощь",
            tint: AppColors.error,
            articles: [insuranceArticle, huisartsArticle, urgentCareArticle]
        )
    }

    static var insuranceArticle: GuideArticle {
        GuideArticle(
            id: "insurance",
            title: "Медицинская страховка",
            summary: "Базовая basisverzekering, eigen risico и субсидия zorgtoeslag",
            blocks: [
                .paragraph("В Нидерландах базовая медицинская страховка обязательна для многих жителей и работников. Момент возникновения обязанности зависит от вашей ситуации; проверяйте Government.nl и CAK."),
                .step(index: 1, text: "Сравните страховщиков (verzekeraars), премии, contracted care, eigen risico и поддержку на нужном языке"),
                .step(index: 2, text: "Оформите полис онлайн — потребуется BSN и IBAN-номер банковского счёта"),
                .step(index: 3, text: "Зарегистрируйтесь у huisarts (семейного врача) — без него не попасть к специалисту"),
                .step(index: 4, text: "Проверьте право на zorgtoeslag через официальный портал Toeslagen. Размер зависит от дохода, домохозяйства и текущих правил."),
                .warning("Eigen risico меняется по правилам года и не применяется ко всем видам помощи. Проверяйте актуальную сумму и исключения у страховщика или на официальных источниках."),
                .tip("Aanvullende verzekering (дополнительная страховка) покрывает зубного врача, очки и физиотерапию — базовый пакет их не включает."),
                .term(dutch: "Basisverzekering", meaning: "Обязательная базовая медицинская страховка"),
                .term(dutch: "Eigen risico", meaning: "Обязательная франшиза: актуальную сумму и исключения проверяйте каждый год"),
                .term(dutch: "Zorgtoeslag", meaning: "Государственная субсидия на медицинскую страховку")
            ],
            links: [
                ExternalLink(id: "zorgwijzer", title: "Сравнение полисов — Zorgwijzer", urlString: "https://www.zorgwijzer.nl", institution: "Zorgwijzer"),
                ExternalLink(id: "zorgtoeslag-belast", title: "Zorgtoeslag — Belastingdienst", urlString: "https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/privé/toeslagen/zorgtoeslag", institution: "Belastingdienst")
            ]
        )
    }

    static var huisartsArticle: GuideArticle {
        GuideArticle(
            id: "huisarts",
            title: "Huisarts — ваш семейный врач",
            summary: "Как найти huisarts и что делать, если список пациентов закрыт",
            blocks: [
                .paragraph("Huisarts (врач общей практики) — обязательная первая точка входа в нидерландскую медицину. Без направления от huisarts нельзя попасть к специалисту, кроме экстренных случаев."),
                .step(index: 1, text: "Найдите практику рядом с домом на zorgkaartnederland.nl или через сайт вашей страховой компании"),
                .step(index: 2, text: "Позвоните или напишите e-mail с запросом о регистрации — укажите ваш адрес"),
                .step(index: 3, text: "Практики принимают пациентов по территориальному принципу — ищите ближайшую к вашему адресу"),
                .step(index: 4, text: "Если список закрыт: просите лист ожидания или обратитесь в страховую за помощью с поиском"),
                .warning("Без huisarts нельзя получить направление к специалисту. Если заболели в нерабочие часы — обращайтесь в HAP (huisartsenpost): работает ночью и в выходные."),
                .tip("Запись через онлайн-форму часто быстрее звонка. Многие практики используют dokter.nl или собственный портал."),
                .term(dutch: "Huisarts", meaning: "Врач общей практики / семейный врач"),
                .term(dutch: "Doorverwijzing", meaning: "Направление от huisarts к специалисту"),
                .term(dutch: "HAP", meaning: "Huisartsenpost — дежурная служба врачей в нерабочие часы")
            ],
            links: [
                ExternalLink(id: "zorgkaart", title: "Найти huisarts — Zorgkaart", urlString: "https://www.zorgkaartnederland.nl/huisarts", institution: "Zorgkaart Nederland"),
                ExternalLink(id: "huisarts-rijksoverheid", title: "Совет по поиску — Rijksoverheid", urlString: "https://www.rijksoverheid.nl/onderwerpen/zorgverzekering/vraag-en-antwoord/geen-huisarts-wat-te-doen", institution: "Rijksoverheid")
            ]
        )
    }

    static var urgentCareArticle: GuideArticle {
        GuideArticle(
            id: "urgent-care",
            title: "Срочная медицинская помощь",
            summary: "HAP, Spoedeisende Hulp и когда звонить 112",
            blocks: [
                .paragraph("Нидерландская система экстренной помощи разделена по уровням тяжести. Важно знать, куда обращаться: это влияет на eigen risico и время ожидания."),
                .step(index: 1, text: "Обычные симптомы в рабочие часы → звоните своему huisarts (08:00–17:00, Пн–Пт)"),
                .step(index: 2, text: "Вечером/ночью/в выходные, не экстренное → HAP (huisartsenpost) — номер есть на сайте страховщика"),
                .step(index: 3, text: "Подозрение на инфаркт, инсульт, тяжёлая травма → немедленно звоните 112"),
                .step(index: 4, text: "Психологический кризис → звоните 113 — суицидальная служба помощи, 24/7"),
                .warning("Самостоятельный приезд в Spoedeisende Hulp (SEH) без направления HAP — законно, но SEH вправе перенаправить вас в HAP, если состояние нетяжёлое."),
                .tip("Телефонный triage в HAP: медсестра оценит симптомы и скажет, нужен ли срочный приём или можно ждать до утра. Не пропускайте этот шаг."),
                .term(dutch: "HAP", meaning: "Huisartsenpost — дежурная служба врачей вне рабочих часов"),
                .term(dutch: "SEH", meaning: "Spoedeisende Hulp — отделение неотложной помощи в больнице"),
                .term(dutch: "Triage", meaning: "Первичная оценка тяжести состояния по симптомам")
            ],
            links: [
                ExternalLink(id: "emergency-112", title: "Экстренная служба 112", urlString: "https://www.politie.nl/onderwerpen/112-bellen.html", institution: "Politie / Overheid"),
                ExternalLink(id: "crisis-113", title: "Телефон доверия 113", urlString: "https://www.113.nl", institution: "113 Zelfmoordpreventie")
            ]
        )
    }
}

// MARK: - Fines

private extension GuideContent {
    static var finesSection: GuideSection {
        GuideSection(
            id: "fines",
            icon: "exclamationmark.triangle.fill",
            title: "Штрафы",
            subtitle: "Велосипедные нарушения, парковка, CJIB и как оспорить штраф",
            tint: AppColors.warning,
            articles: [bikeFinesArticle, parkingFinesArticle, cjibArticle]
        )
    }

    static var bikeFinesArticle: GuideArticle {
        GuideArticle(
            id: "bike-fines",
            title: "Штрафы за нарушения на велосипеде",
            summary: "Размеры штрафов и наиболее частые ошибки велосипедистов",
            blocks: [
                .paragraph("В Нидерландах строго контролируют соблюдение велосипедных правил. Полиция штрафует без предупреждений — незнание правил не освобождает от ответственности."),
                .step(index: 1, text: "Езда без света ночью: проверьте текущую сумму штрафа и требования к переднему/заднему свету"),
                .step(index: 2, text: "Проезд на красный свет: велосипедные светофоры обязательны к соблюдению"),
                .step(index: 3, text: "Езда по тротуару: проверьте местные правила и официальную таблицу штрафов"),
                .step(index: 4, text: "Телефон в руке во время движения запрещён; текущую сумму штрафа проверяйте в официальной таблице"),
                .warning("Неправильная парковка велосипеда в центре города может привести к эвакуации. Стоимость возврата и правила зависят от gemeente."),
                .tip("В больших городах работают специальные велосипедные патрули — особенно активны у вокзалов и в историческом центре. Лучше не рисковать."),
                .term(dutch: "Fietslicht", meaning: "Велосипедный фонарь — обязателен при недостаточной видимости"),
                .term(dutch: "Fietsenstalling", meaning: "Официальная велопарковка — там штрафы не выписывают")
            ],
            links: [
                ExternalLink(id: "boetes-om", title: "Таблица штрафов — Openbaar Ministerie", urlString: "https://www.om.nl/onderwerpen/verkeersboetes/boetebedragen", institution: "Openbaar Ministerie"),
                ExternalLink(id: "cjib-fiets", title: "CJIB — оплата штрафов", urlString: "https://www.cjib.nl", institution: "CJIB")
            ]
        )
    }

    static var parkingFinesArticle: GuideArticle {
        GuideArticle(
            id: "parking-fines",
            title: "Штрафы за парковку",
            summary: "Платные зоны, неправильная парковка и приложения для оплаты",
            blocks: [
                .paragraph("В большинстве нидерландских городов действуют платные парковочные зоны. Штрафы выписывают специальные контролёры (parkeercontroleurs) — они работают быстро и без предупреждений."),
                .step(index: 1, text: "Проверяйте знаки: синий P-знак с часами — платная зона, жёлтые линии — запрещённая парковка"),
                .step(index: 2, text: "Оплачивайте через паркомат (parkeerautomaat) или приложения: ParkMobile, Yellowbrick, EasyPark"),
                .step(index: 3, text: "Следите за временем — после истечения срока оплаты штраф выписывают немедленно"),
                .step(index: 4, text: "Получили parkeerbon (штраф на лобовом стекле) — оплатите в срок, иначе дело передадут в CJIB с надбавкой"),
                .warning("Парковка на месте для инвалидов без разрешения, на жёлтой линии или автобусной остановке может привести к штрафу или эвакуации. Суммы проверяйте в официальной таблице."),
                .tip("ParkMobile позволяет продлить парковку через телефон, не возвращаясь к машине. Работает в большинстве нидерландских городов."),
                .term(dutch: "Parkeerbon", meaning: "Квитанция штрафа за нарушение парковки"),
                .term(dutch: "Wegslepen", meaning: "Эвакуация автомобиля: стоимость возврата зависит от города и ситуации"),
                .term(dutch: "Parkeercontroleur", meaning: "Инспектор по парковке — уполномочен выписывать штрафы")
            ],
            links: [
                ExternalLink(id: "parkmobile", title: "ParkMobile — оплата парковки", urlString: "https://www.parkmobile.nl", institution: "ParkMobile"),
                ExternalLink(id: "cjib-parking", title: "CJIB — оплата штрафов", urlString: "https://www.cjib.nl", institution: "CJIB")
            ]
        )
    }

    static var cjibArticle: GuideArticle {
        GuideArticle(
            id: "cjib",
            title: "CJIB — как оплатить или оспорить штраф",
            summary: "Centraal Justitieel Incassobureau: сроки оплаты, рассрочка и обжалование",
            blocks: [
                .paragraph("CJIB (Centraal Justitieel Incassobureau) — государственный орган по сбору административных штрафов. Все неоплаченные штрафы рано или поздно попадают в CJIB с автоматической надбавкой."),
                .step(index: 1, text: "Получили уведомление? Проверьте срок оплаты — стандартно 6 недель с даты выдачи"),
                .step(index: 2, text: "Оплатите через iDEAL на cjib.nl по номеру дела или банковским переводом по реквизитам в письме"),
                .step(index: 3, text: "Хотите оспорить: подайте bezwaar (жалобу) на cjib.nl — срок 6 недель с момента получения"),
                .step(index: 4, text: "Нет денег сейчас: запросите betalingsregeling (рассрочку) — до 12 месяцев при определённых условиях"),
                .warning("Просрочка платежа автоматически удваивает сумму штрафа. Дальнейшая просрочка — дело передаётся deurwaarder (судебному приставу) с дополнительными издержками."),
                .tip("Если вы уедете из Нидерландов с неоплаченными штрафами — CJIB может передать дело в страну вашего проживания через European Enforcement Order."),
                .term(dutch: "CJIB", meaning: "Centraal Justitieel Incassobureau — орган сбора административных штрафов"),
                .term(dutch: "Bezwaar", meaning: "Официальная жалоба на решение государственного органа"),
                .term(dutch: "Deurwaarder", meaning: "Судебный пристав — вступает при систематической неоплате")
            ],
            links: [
                ExternalLink(id: "cjib-main", title: "Официальный сайт CJIB", urlString: "https://www.cjib.nl", institution: "CJIB"),
                ExternalLink(id: "cjib-bezwaar", title: "Подать bezwaar онлайн", urlString: "https://www.cjib.nl/bezwaar-maken", institution: "CJIB")
            ]
        )
    }
}

// MARK: - Work

private extension GuideContent {
    static var workSection: GuideSection {
        GuideSection(
            id: "work",
            icon: "briefcase.fill",
            title: "Работа",
            subtitle: "Трудоустройство, разрешения, зарплата, налоги и поиск работы в Нидерландах",
            tint: AppColors.softBlue,
            articles: [workingPermitArticle, salaryTaxesArticle, jobSearchNLArticle],
            titleEN: "Work",
            subtitleEN: "Employment, permits, salary, taxes, and finding work in the Netherlands"
        )
    }

    static var workingPermitArticle: GuideArticle {
        GuideArticle(
            id: "working-permit",
            title: "Разрешение на работу и право работать",
            summary: "Кому нужен work permit, что проверять в контракте и где смотреть официальные правила",
            blocks: [
                .paragraph("Граждане EU/EEA могут работать в Нидерландах без отдельного разрешения. Обычно нужно зарегистрироваться в gemeente, получить BSN, открыть счёт и подписать нормальный трудовой договор."),
                .paragraph("Гражданам non-EU для работы часто нужен TWV (Tewerkstellingsvergunning) или GVVA (комбинированное разрешение на пребывание и работу). Для highly skilled migrant путь быстрее, но работодатель должен быть recognised sponsor IND, а зарплата должна соответствовать порогу."),
                .paragraph("Исключения зависят от вашего ВНЖ: kennismigrant, intra-corporate transfer, partner permit, orientation year, refugee status и student permit имеют разные условия. У студентов non-EU работа обычно ограничена часами или летним периодом."),
                .step(index: 1, text: "Найдите работодателя и проверьте, является ли он recognised sponsor в IND, если вы идёте по маршруту kennismigrant"),
                .step(index: 2, text: "Проверьте текст на карточке ВНЖ: arbeid vrij toegestaan, arbeid toegestaan met TWV или другие ограничения"),
                .step(index: 3, text: "Попросите работодателя письменно подтвердить, что TWV/GVVA или sponsor procedure оформлены до начала работы"),
                .step(index: 4, text: "После одобрения получите MVV/ВНЖ, зарегистрируйтесь в gemeente, получите BSN и настройте payroll"),
                .step(index: 5, text: "Сохраните контракт, payslips, BSN, адрес регистрации, IND-письма и переписку с работодателем в одном месте"),
                .warning("Не начинайте работу, если ваш ВНЖ требует TWV/GVVA, а разрешение не оформлено. Это риск штрафов, проблем с ВНЖ и потери работы."),
                .tip("Для kennismigrant проверяйте не только зарплату, но и отпускные, испытательный срок, relocation support, 30% ruling и кто оплачивает IND fees.")
            ],
            links: [
                ExternalLink(id: "ind-work", title: "IND — Work in the Netherlands", urlString: "https://ind.nl/en/work", institution: "IND"),
                ExternalLink(id: "uwv-work-permit", title: "UWV — Work permits", urlString: "https://www.uwv.nl/en/work-permit", institution: "UWV"),
                ExternalLink(id: "government-work", title: "Government.nl — Coming to work", urlString: "https://www.government.nl/topics/immigration-to-the-netherlands/question-and-answer/coming-to-the-netherlands-to-work", institution: "Government.nl")
            ],
            updatedDate: "June 2025",
            readingMinutes: 5,
            isOfficial: true,
            titleEN: "Work permit and right to work",
            summaryEN: "Who needs a permit, what to check on your residence card, and where to verify the rules",
            blocksEN: [
                .paragraph("EU/EEA citizens can work in the Netherlands without a separate work permit. In practice you still need registration, a BSN, a bank account, and a proper employment contract."),
                .paragraph("Non-EU workers often need either a TWV work permit or a GVVA combined residence and work permit. The highly skilled migrant route is faster, but the employer must be an IND recognised sponsor and salary thresholds apply."),
                .paragraph("Exceptions depend on your residence status: highly skilled migrant, intra-corporate transfer, partner permit, orientation year, refugee status, and student permits all have different conditions."),
                .step(index: 1, text: "Find an employer and check whether it is an IND recognised sponsor if you are using the highly skilled migrant route"),
                .step(index: 2, text: "Check your residence card for arbeid vrij toegestaan, arbeid toegestaan met TWV, or other work restrictions"),
                .step(index: 3, text: "Ask the employer to confirm in writing that TWV/GVVA or sponsor procedures are complete before you start"),
                .step(index: 4, text: "After approval, collect your MVV/residence permit, register with the municipality, get a BSN, and set up payroll"),
                .step(index: 5, text: "Keep your contract, payslips, BSN, registered address, IND letters, and employer messages together"),
                .warning("Do not start work if your permit requires TWV/GVVA and the permit is not arranged. It can create fines, residence issues, and job loss."),
                .tip("For highly skilled migrant offers, check salary, holiday allowance, probation period, relocation support, 30% ruling, and who pays IND fees.")
            ]
        )
    }

    static var salaryTaxesArticle: GuideArticle {
        GuideArticle(
            id: "salary-taxes",
            title: "Зарплата, payslip и налоги",
            summary: "Как читать bruto/netto, что такое loonheffing и когда подавать декларацию",
            blocks: [
                .paragraph("В Нидерландах зарплата почти всегда обсуждается как bruto — сумма до налогов и социальных взносов. На банковский счёт приходит netto. Разница зависит от дохода, налоговых скидок, пенсионных взносов, отпускных и бонусов."),
                .paragraph("Подоходный налог Box 1 прогрессивный, а ставки и пороги меняются по годам. Проверяйте текущие таблицы Belastingdienst перед расчётом бюджета."),
                .paragraph("Не используйте грубые netto-примеры как обещание. На зарплату после налогов влияют пенсионные взносы, tax credits, holiday allowance и личная ситуация."),
                .step(index: 1, text: "В контракте проверьте bruto salary, количество часов, отпускные 8%, пенсионную схему и срок уведомления"),
                .step(index: 2, text: "Каждый месяц скачивайте loonstrook/payslip и сверяйте bruto, netto, loonheffing, vakantiegeld и reimbursements"),
                .step(index: 3, text: "Укажите только у одного работодателя loonheffingskorting, иначе можно получить недоплату налога"),
                .step(index: 4, text: "После конца года проверьте jaaropgave и подайте income tax return, если получили приглашение или ожидаете возврат"),
                .step(index: 5, text: "Если вы наняты из-за рубежа, попросите работодателя оценить 30% ruling и подать заявку в Belastingdienst"),
                .warning("Не ориентируйтесь только на bruto. Для бюджета жилья, страховки и транспорта считайте netto income после налогов и обязательных расходов."),
                .tip("30% ruling может дать заметную экономию на 5 лет, но требования зависят от зарплаты, навыков и того, были ли вы наняты из-за рубежа.")
            ],
            links: [
                ExternalLink(id: "belastingdienst-income", title: "Belastingdienst — Income tax", urlString: "https://www.belastingdienst.nl/wps/wcm/connect/en/income-in-the-netherlands/income-in-the-netherlands", institution: "Belastingdienst"),
                ExternalLink(id: "government-minimum-wage", title: "Government.nl — Minimum wage", urlString: "https://www.government.nl/topics/minimum-wage", institution: "Government.nl"),
                ExternalLink(id: "30-percent-ruling", title: "Belastingdienst — 30% facility", urlString: "https://www.belastingdienst.nl/wps/wcm/connect/en/individuals/content/30-percent-facility", institution: "Belastingdienst")
            ],
            updatedDate: "June 2025",
            readingMinutes: 6,
            isOfficial: true,
            titleEN: "Salary, payslip, and taxes",
            summaryEN: "How bruto/netto works, what loonheffing means, and when to file taxes",
            blocksEN: [
                .paragraph("Dutch salaries are usually discussed as bruto: the amount before tax and social contributions. Your bank receives netto. The difference depends on income, tax credits, pension contributions, holiday allowance, and bonuses."),
                .paragraph("Box 1 income tax is progressive, and rates and thresholds change by year. Check current Belastingdienst tables before budgeting."),
                .paragraph("Do not treat rough netto examples as a promise. Pension contributions, tax credits, holiday allowance, and personal circumstances all affect take-home pay."),
                .step(index: 1, text: "In the contract, check bruto salary, hours, 8% holiday allowance, pension scheme, and notice period"),
                .step(index: 2, text: "Download every loonstrook/payslip and check bruto, netto, loonheffing, vakantiegeld, and reimbursements"),
                .step(index: 3, text: "Apply loonheffingskorting with only one employer, otherwise you may underpay tax"),
                .step(index: 4, text: "After the year ends, check your jaaropgave and file an income tax return if invited or if you expect a refund"),
                .step(index: 5, text: "If you were recruited from abroad, ask the employer to assess the 30% ruling and submit it to Belastingdienst"),
                .warning("Do not budget from bruto only. Housing, insurance, and transport should be planned from your net income after tax and fixed costs."),
                .tip("The 30% ruling can create meaningful savings for up to 5 years, but requirements depend on salary, expertise, and being recruited from abroad.")
            ]
        )
    }

    static var jobSearchNLArticle: GuideArticle {
        GuideArticle(
            id: "job-search-nl",
            title: "Поиск работы в Нидерландах",
            summary: "Где искать вакансии, как адаптировать CV и что ожидать на интервью",
            blocks: [
                .paragraph("Поиск работы в Нидерландах часто строится вокруг LinkedIn, рекрутеров, прямых откликов и сети контактов. Для англоязычных ролей особенно важны tech, finance, logistics, hospitality, academia и international organisations."),
                .paragraph("Полезные платформы: LinkedIn, Indeed.nl, Nationale Vacaturebank, Intermediair, Werkzoeken, Werk.nl и IamExpat Jobs. Для студентов смотрите university career portals; для временной работы — Randstad, Manpower и Tempo-Team."),
                .paragraph("Культура труда обычно прямолинейная: ценятся честные ответы, пунктуальность, самостоятельность и work-life balance. Part-time и flexwerken нормальны, но условия должны быть прописаны в договоре."),
                .step(index: 1, text: "Сделайте CV на 1-2 страницы: результат, роль, технологии/навыки, языки, право на работу и город"),
                .step(index: 2, text: "Обновите LinkedIn на английском и добавьте ключевые слова из вакансий"),
                .step(index: 3, text: "Ищите через LinkedIn, Indeed, Nationale Vacaturebank, Werk.nl, Undutchables, university career portals и локальные recruiters"),
                .step(index: 4, text: "На интервью готовьте примеры по STAR: ситуация, задача, действие, результат"),
                .step(index: 5, text: "При оффере проверьте CAO, тип договора (vast/tijdelijk), probation, notice period, pension и holiday allowance"),
                .warning("Остерегайтесь вакансий, где просят оплатить оформление документов, обучение или оборудование заранее. Это частый признак мошенничества."),
                .tip("Даже если вакансия на нидерландском, спросите, возможна ли английская рабочая среда. Многие команды гибче, чем текст объявления.")
            ],
            links: [
                ExternalLink(id: "werk-nl", title: "Werk.nl", urlString: "https://www.werk.nl", institution: "UWV"),
                ExternalLink(id: "eures", title: "EURES Netherlands", urlString: "https://eures.europa.eu", institution: "European Union"),
                ExternalLink(id: "linkedin-jobs", title: "LinkedIn Jobs", urlString: "https://www.linkedin.com/jobs", institution: "LinkedIn")
            ],
            updatedDate: "June 2025",
            readingMinutes: 5,
            isOfficial: false,
            titleEN: "Finding a job in the Netherlands",
            summaryEN: "Where to search, how to adapt your CV, and what to expect in interviews",
            blocksEN: [
                .paragraph("Dutch job search often runs through LinkedIn, recruiters, direct applications, and your network. English-speaking roles are common in tech, finance, logistics, hospitality, academia, and international organisations."),
                .paragraph("Useful platforms include LinkedIn, Indeed.nl, Nationale Vacaturebank, Intermediair, Werkzoeken, Werk.nl, and IamExpat Jobs. Students should check university career portals; temporary work often runs through Randstad, Manpower, and Tempo-Team."),
                .paragraph("Work culture is direct: honest answers, punctuality, ownership, and work-life balance are valued. Part-time work and flexible work are normal, but conditions should be written into the contract."),
                .step(index: 1, text: "Build a 1-2 page CV with outcomes, role, tools/skills, languages, work authorisation, and city"),
                .step(index: 2, text: "Update LinkedIn in English and add keywords from target vacancies"),
                .step(index: 3, text: "Search through LinkedIn, Indeed, Nationale Vacaturebank, Werk.nl, Undutchables, university career portals, and local recruiters"),
                .step(index: 4, text: "Prepare interview examples using STAR: situation, task, action, result"),
                .step(index: 5, text: "When you receive an offer, check the CAO, contract type, probation, notice period, pension, and holiday allowance"),
                .warning("Be careful with jobs that ask you to pay upfront for documents, training, or equipment. That is often a scam signal."),
                .tip("Even if a vacancy is in Dutch, ask whether the working language can be English. Some teams are more flexible than the advertisement suggests.")
            ]
        )
    }
}

// MARK: - Integration

private extension GuideContent {
    static var integrationSection: GuideSection {
        GuideSection(
            id: "integration",
            icon: "globe.europe.africa.fill",
            title: "Интеграция",
            subtitle: "Язык, культура, повседневные правила и уверенность в новой среде",
            tint: AppColors.emerald,
            articles: [dutchLanguageArticle, dutchCultureArticle],
            titleEN: "Integration",
            subtitleEN: "Language, culture, everyday rules, and confidence in a new environment"
        )
    }

    static var dutchLanguageArticle: GuideArticle {
        GuideArticle(
            id: "dutch-language",
            title: "Нидерландский язык: как начать",
            summary: "Практичный путь от первых фраз до A2/B1 для жизни, работы и интеграции",
            blocks: [
                .paragraph("В больших городах можно многое делать на английском, но нидерландский резко повышает самостоятельность: huisarts, школа, gemeente, работа, соседи и официальные письма становятся понятнее."),
                .paragraph("Для inburgering обычно нужны экзамены по lezen, schrijven, spreken, luisteren и знанию общества. Для долгосрочного проживания часто целевой уровень B1, но ваш личный маршрут зависит от даты въезда, статуса и письма от DUO/gemeente."),
                .paragraph("Ресурсы для старта: Duolingo Dutch, Oefenen.nl, NT2.nl, Language Transfer, местная библиотека, taalhuis, taalcafe и YouTube-каналы вроде Dutch with Jasmine или Learn Dutch with Bart de Pau."),
                .step(index: 1, text: "Выучите 30 бытовых фраз: afspraak maken, inschrijven, huisarts, rekening, bezwaar, dank u wel"),
                .step(index: 2, text: "Занимайтесь коротко каждый день: 15 минут слов, 10 минут аудио, 5 минут повторения фраз вслух"),
                .step(index: 3, text: "Ищите taalhuis, библиотеку, муниципальные курсы, NT2-школы или разговорные группы рядом с адресом"),
                .step(index: 4, text: "Если вам нужна интеграция/inburgering, проверьте личные сроки, экзамены и финансирование через DUO"),
                .step(index: 5, text: "Смотрите NPO Start или Jeugdjournaal с субтитрами и выписывайте фразы для реальных задач"),
                .warning("Не откладывайте язык до 'после переезда'. Очереди на курсы бывают длинными, а официальные письма начинают приходить сразу."),
                .tip("Даже если вам отвечают на английском, продолжайте первую фразу на нидерландском. Это быстро снимает страх разговора.")
            ],
            links: [
                ExternalLink(id: "duo-inburgering", title: "DUO — Inburgering", urlString: "https://www.inburgeren.nl/en", institution: "DUO"),
                ExternalLink(id: "oefenen", title: "Oefenen.nl", urlString: "https://www.oefenen.nl", institution: "Oefenen.nl"),
                ExternalLink(id: "hetbegintmettaal", title: "Het Begint met Taal", urlString: "https://www.hetbegintmettaal.nl", institution: "Het Begint met Taal")
            ],
            updatedDate: "June 2025",
            readingMinutes: 4,
            isOfficial: false,
            titleEN: "Dutch language: how to start",
            summaryEN: "A practical path from first phrases to A2/B1 for daily life, work, and integration",
            blocksEN: [
                .paragraph("In larger cities you can manage many things in English, but Dutch greatly increases independence: GP visits, school, municipality, work, neighbours, and official letters become easier."),
                .paragraph("For inburgering you usually deal with reading, writing, speaking, listening, and knowledge of Dutch society. Long-term residence often points toward B1, but your personal route depends on arrival date, status, and DUO/municipality letters."),
                .paragraph("Good starting resources include Duolingo Dutch, Oefenen.nl, NT2.nl, Language Transfer, the local library, taalhuis, taalcafe, and YouTube channels such as Dutch with Jasmine or Learn Dutch with Bart de Pau."),
                .step(index: 1, text: "Learn 30 practical words and phrases: afspraak maken, inschrijven, huisarts, rekening, bezwaar, dank u wel"),
                .step(index: 2, text: "Study briefly every day: 15 minutes vocabulary, 10 minutes audio, 5 minutes speaking phrases aloud"),
                .step(index: 3, text: "Look for a taalhuis, library, municipal course, NT2 school, or conversation group near your address"),
                .step(index: 4, text: "If you must complete inburgering, check your deadlines, exams, and funding through DUO"),
                .step(index: 5, text: "Watch NPO Start or Jeugdjournaal with subtitles and collect phrases for real tasks"),
                .warning("Do not postpone Dutch until 'after settling in'. Course waiting lists can be long, and official letters start arriving immediately."),
                .tip("Even when people answer in English, keep your first sentence in Dutch. It reduces speaking anxiety quickly.")
            ]
        )
    }

    static var dutchCultureArticle: GuideArticle {
        GuideArticle(
            id: "dutch-culture",
            title: "Нидерландская культура и повседневные правила",
            summary: "Как понимать прямоту, afspraken, соседей, школу, велосипед и личные границы",
            blocks: [
                .paragraph("Нидерландская культура часто кажется прямой, но обычно это не грубость, а экономия времени и ясность. Люди ожидают пунктуальности, договорённостей в календаре, честного ответа и уважения к личному пространству."),
                .paragraph("Directheid означает, что критику и несогласие могут сказать открыто. Gezelligheid — важное слово для приятной атмосферы, компании и уюта. Borrel после работы часто работает как неформальный networking."),
                .paragraph("Дни рождения часто отмечают сидя в кругу, а поздравлять принято не только именинника, но и близких: 'Gefeliciteerd met je moeder!' звучит нормально."),
                .step(index: 1, text: "Планируйте встречи заранее: afspraak значит конкретное время, место и ожидание, что вы придёте вовремя"),
                .step(index: 2, text: "Если не можете прийти, отменяйте заранее — для врача, школы, gemeente и работы это особенно важно"),
                .step(index: 3, text: "С соседями держите базовый контакт: поздоровайтесь, предупредите о шуме, соблюдайте правила мусора и парковки велосипедов"),
                .step(index: 4, text: "В школе и на работе задавайте прямые вопросы: что ожидается, когда дедлайн, кто отвечает за следующий шаг"),
                .step(index: 5, text: "Купите нормальный велосипед, свет и два замка: велодорожки — часть повседневной культуры, а не туристическая опция"),
                .warning("Не игнорируйте официальные письма. Даже если текст непонятен, там могут быть сроки для штрафа, страховки, налогов или регистрации."),
                .tip("Слова gezellig, afspraak, borrel и op tijd полезны не меньше, чем грамматика: они объясняют социальные ожидания.")
            ],
            links: [
                ExternalLink(id: "government-living", title: "Government.nl — Living in the Netherlands", urlString: "https://www.government.nl/topics/immigration-to-the-netherlands", institution: "Government.nl"),
                ExternalLink(id: "iwcn", title: "International Welcome Center North", urlString: "https://iwcn.nl", institution: "IWCN"),
                ExternalLink(id: "access-nl", title: "ACCESS Netherlands", urlString: "https://access-nl.org", institution: "ACCESS")
            ],
            updatedDate: "June 2025",
            readingMinutes: 5,
            isOfficial: false,
            titleEN: "Dutch culture and everyday rules",
            summaryEN: "How to read directness, appointments, neighbours, school, cycling, and personal boundaries",
            blocksEN: [
                .paragraph("Dutch culture can feel direct, but it is usually meant as clarity rather than rudeness. People expect punctuality, calendar agreements, honest answers, and respect for personal space."),
                .paragraph("Directheid means criticism or disagreement can be stated openly. Gezelligheid is the word for a pleasant, warm, social atmosphere. A work borrel often functions as informal networking."),
                .paragraph("Birthdays are often celebrated seated in a circle, and people may congratulate not only the person having the birthday but also close relatives. That is normal."),
                .step(index: 1, text: "Plan meetings ahead: afspraak means a specific time, place, and expectation that you arrive on time"),
                .step(index: 2, text: "If you cannot attend, cancel early. This matters for GP visits, school, municipality appointments, and work"),
                .step(index: 3, text: "Keep basic contact with neighbours: greet them, warn about noise, follow waste rules, and park bikes correctly"),
                .step(index: 4, text: "At school and work, ask direct questions: what is expected, when is the deadline, and who owns the next step"),
                .step(index: 5, text: "Buy a practical bicycle, lights, and two locks: cycling lanes are daily infrastructure, not a tourist extra"),
                .warning("Do not ignore official letters. Even if the text is difficult, they may contain deadlines for fines, insurance, taxes, or registration."),
                .tip("Gezellig, afspraak, borrel, and op tijd are as useful as grammar because they explain social expectations.")
            ]
        )
    }
}

// MARK: - Emergency

private extension GuideContent {
    static var emergencySection: GuideSection {
        GuideSection(
            id: "emergency",
            icon: "exclamationmark.triangle.fill",
            title: "Экстренные ситуации",
            subtitle: "112, полиция, huisartsenpost, crisis support и что делать в первые минуты",
            tint: AppColors.error,
            articles: [emergencyNumbersArticle],
            titleEN: "Emergency",
            subtitleEN: "112, police, huisartsenpost, crisis support, and what to do in the first minutes"
        )
    }

    static var emergencyNumbersArticle: GuideArticle {
        GuideArticle(
            id: "emergency-numbers",
            title: "Экстренные номера и первые действия",
            summary: "Когда звонить 112, куда обращаться без угрозы жизни и что сказать оператору",
            blocks: [
                .paragraph("112 — единый номер для полиции, скорой и пожарных при угрозе жизни, серьёзной опасности, пожаре, аварии или преступлении в процессе. Если ситуация срочная, но не угрожает жизни, используйте non-emergency каналы."),
                .paragraph("Сохраните заранее: 112 для экстренных случаев, 0900-8844 для полиции без срочности, huisartsenpost вашего региона для врача вне рабочих часов, 0800-0113 для кризисной линии, 0800-2000 для Veilig Thuis и 088 786 77 77 для Fraudehelpdesk."),
                .paragraph("Для дороги сохраните ANWB Wegenwacht 0800 0888, а для юридической страховки — номер вашей rechtsbijstand. Посольские номера храните отдельно вместе с копией паспорта и ВНЖ."),
                .step(index: 1, text: "При непосредственной опасности звоните 112 и скажите: location, what happened, who is injured, whether the danger is still present"),
                .step(index: 2, text: "Для полиции без срочности звоните 0900-8844 или используйте официальный сайт politie.nl"),
                .step(index: 3, text: "Для медицинской помощи вне часов huisarts звоните в huisartsenpost вашего региона; при угрозе жизни — 112"),
                .step(index: 4, text: "Сохраните адрес, postcode, insurance policy number, huisarts, emergency contact и ближайший hospital в телефоне"),
                .step(index: 5, text: "При краже подайте aangifte на politie.nl или в участке; при интернет-мошенничестве сохраните скриншоты и обратитесь в Fraudehelpdesk"),
                .warning("Не едьте в emergency department без необходимости, если нет угрозы жизни. В Нидерландах вход в срочную медицину часто идёт через huisarts/huisartsenpost."),
                .tip("Сейчас добавьте в телефон 112, 0900-8844, адрес huisartsenpost, номер страховки, BSN-карту/фото и emergency contact.")
            ],
            links: [
                ExternalLink(id: "112-nl", title: "112 Netherlands", urlString: "https://www.112.nl", institution: "112 Nederland"),
                ExternalLink(id: "politie-contact", title: "Politie — Contact", urlString: "https://www.politie.nl/en/contact", institution: "Politie"),
                ExternalLink(id: "slachtofferhulp", title: "Victim Support Netherlands", urlString: "https://www.slachtofferhulp.nl/english", institution: "Slachtofferhulp Nederland")
            ],
            updatedDate: "June 2025",
            readingMinutes: 3,
            isOfficial: true,
            titleEN: "Emergency numbers and first actions",
            summaryEN: "When to call 112, where to go without life danger, and what to tell the operator",
            blocksEN: [
                .paragraph("112 is the single emergency number for police, ambulance, and fire services when there is life danger, serious danger, fire, an accident, or a crime in progress. If it is urgent but not life-threatening, use non-emergency channels."),
                .paragraph("Save in advance: 112 for emergencies, 0900-8844 for non-urgent police, your regional huisartsenpost for out-of-hours GP care, 0800-0113 for crisis support, 0800-2000 for Veilig Thuis, and 088 786 77 77 for Fraudehelpdesk."),
                .paragraph("For road trouble, save ANWB Wegenwacht 0800 0888. For legal insurance, save your rechtsbijstand number. Keep embassy numbers separately with passport and residence-permit copies."),
                .step(index: 1, text: "For immediate danger, call 112 and say: location, what happened, who is injured, and whether the danger is still present"),
                .step(index: 2, text: "For police without urgency, call 0900-8844 or use the official politie.nl website"),
                .step(index: 3, text: "For medical help outside GP hours, call your regional huisartsenpost; for life danger, call 112"),
                .step(index: 4, text: "Save your address, postcode, insurance policy number, GP, emergency contact, and nearest hospital in your phone"),
                .step(index: 5, text: "For theft, file aangifte on politie.nl or at a station; for online fraud, keep screenshots and contact Fraudehelpdesk"),
                .warning("Do not go to the emergency department unnecessarily if there is no life danger. In the Netherlands urgent care often starts through the GP or huisartsenpost."),
                .tip("Add 112, 0900-8844, your huisartsenpost address, insurance number, BSN card/photo, and emergency contact to your phone now.")
            ]
        )
    }
}

// MARK: - GuideSectionView

struct GuideSectionView: View {
    let section: GuideSection
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var visibleArticles: [GuideArticle] {
        section.visibleArticles(for: appState.selectedUserStatus?.personaTag)
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    CategoryHeroVisual(
                        assetName: nil,
                        title: section.localizedTitle(lang),
                        subtitle: section.localizedSubtitle(lang),
                        symbol: section.icon,
                        badgeText: articleCountBadge,
                        accent: section.tint,
                        asset: sectionHeroAsset,
                        language: lang
                    )

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        NLSectionHeader(title: articlesLabel)
                        LazyVStack(spacing: AppSpacing.small) {
                            ForEach(visibleArticles) { article in
                                NavigationLink(value: AppDestination.guideArticle(sectionID: section.id, articleID: article.id)) {
                                    GuideArticleRow(article: article, tint: section.tint)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground()
        .navigationTitle(section.localizedTitle(lang))
        .nlNavigationInline()
    }

    private var articleCountBadge: String {
        let n = visibleArticles.count
        switch lang {
        case .russian:
            switch n {
            case 1: return "1 статья"
            case 2...4: return "\(n) статьи"
            default: return "\(n) статей"
            }
        case .dutch: return "\(n) artikel\(n == 1 ? "" : "en")"
        case .english: return "\(n) article\(n == 1 ? "" : "s")"
        }
    }

    private var articlesLabel: String {
        switch lang {
        case .russian: return "Статьи"
        case .dutch: return "Artikelen"
        case .english: return "Articles"
        }
    }

    private var sectionHeroAsset: AppImageAsset? {
        switch section.id {
        case "tourist-documents", "documents":
            return ContentMediaRegistry.savedImage ?? ContentMediaRegistry.officialSourcesHero
        case "housing":
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case "transport":
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case "healthcare":
            return ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.healthcarePharmacyImage
        case "fines":
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.municipalityCityHallImage
        case "work":
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case "integration":
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.profileImage ?? ContentMediaRegistry.mapImage
        case "emergency":
            return ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.healthcareBasicsImage
        default:
            return ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero
        }
    }
}

// MARK: - GuideArticleRow

struct GuideArticleRow: View {
    let article: GuideArticle
    let tint: Color
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: "doc.richtext.fill")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 42, height: 42)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(article.localizedTitle(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(article.localizedSummary(lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                if article.hasMetadata {
                    guideArticleMetadataRow(article: article, tint: tint, compact: true, lang: lang)
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.top, 2)
        }
        .appCardStyle()
        .pressable(scale: 0.98)
    }
}

private func guideArticleMetadataRow(article: GuideArticle, tint: Color, compact: Bool, lang: AppLanguage) -> some View {
    ViewThatFits(in: .horizontal) {
        HStack(spacing: 6) {
            guideArticleMetadataChips(article: article, tint: tint, compact: compact, lang: lang)
        }

        VStack(alignment: .leading, spacing: 6) {
            guideArticleMetadataChips(article: article, tint: tint, compact: compact, lang: lang)
        }
    }
    .accessibilityElement(children: .combine)
}

@ViewBuilder
private func guideArticleMetadataChips(article: GuideArticle, tint: Color, compact: Bool, lang: AppLanguage) -> some View {
    if article.isOfficial {
        guideArticleMetadataChip(
            symbol: "checkmark.shield.fill",
            text: guideArticleOfficialLabel(compact: compact, lang: lang),
            color: AppColors.success,
            compact: compact
        )
    }

    if let readingMinutes = article.readingMinutes {
        guideArticleMetadataChip(
            symbol: "clock.fill",
            text: guideArticleReadingLabel(readingMinutes, compact: compact, lang: lang),
            color: tint,
            compact: compact
        )
    }

    if let updatedDate = article.updatedDate {
        guideArticleMetadataChip(symbol: "calendar", text: updatedDate, color: AppColors.textTertiary, compact: compact)
    }
}

private func guideArticleMetadataChip(symbol: String, text: String, color: Color, compact: Bool) -> some View {
    Label {
        Text(text)
            .lineLimit(1)
            .minimumScaleFactor(0.74)
    } icon: {
        Image(systemName: symbol)
            .font(.system(size: compact ? 9 : 10, weight: .bold))
    }
    .font(.system(size: compact ? 10 : 11, weight: .bold, design: .rounded))
    .foregroundStyle(color)
    .padding(.horizontal, compact ? 7 : 9)
    .padding(.vertical, compact ? 4 : 5)
    .background(color.opacity(0.10))
    .clipShape(Capsule())
    .overlay(Capsule().stroke(color.opacity(0.20), lineWidth: 0.7))
}

private func guideArticleOfficialLabel(compact: Bool, lang: AppLanguage) -> String {
    switch lang {
    case .russian: return compact ? "Офиц." : "Официальные источники"
    case .dutch: return compact ? "Offic." : "Officiële bronnen"
    case .english: return compact ? "Official" : "Official sources"
    }
}

private func guideArticleReadingLabel(_ minutes: Int, compact: Bool, lang: AppLanguage) -> String {
    switch lang {
    case .russian: return "\(minutes) мин"
    case .dutch: return "\(minutes) min"
    case .english: return compact ? "\(minutes) min" : "\(minutes) min read"
    }
}

// MARK: - GuideArticleView

struct GuideArticleView: View {
    let article: GuideArticle
    let sectionTint: Color
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.openURL) private var openURL

    private var lang: AppLanguage { languageManager.appLanguage }
    private var articleAccessibilityIdentifier: String {
        if article.id == "documents:bsn" {
            return "guide.article.bsn"
        }

        return "guide.article.\(article.id.replacingOccurrences(of: ":", with: "."))"
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    articleHeader
                    blocksContent
                    linksSection
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground()
        .navigationTitle(article.localizedTitle(lang))
        .nlNavigationInline()
        .accessibilityIdentifier(articleAccessibilityIdentifier)
    }

    private var articleHeader: some View {
        return VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(article.localizedTitle(lang))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier(articleAccessibilityIdentifier)
            Text(article.localizedSummary(lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if article.hasMetadata {
                guideArticleMetadataRow(article: article, tint: sectionTint, compact: false, lang: lang)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
    }

    private var blocksContent: some View {
        LazyVStack(alignment: .leading, spacing: AppSpacing.small) {
            ForEach(Array(article.localizedBlocks(lang).enumerated()), id: \.offset) { _, block in
                blockView(for: block)
            }
        }
    }

    @ViewBuilder
    private func blockView(for block: GuideBlock) -> some View {
        switch block {
        case .paragraph(let text):
            Text(text)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardStyle()

        case .step(let index, let text):
            HStack(alignment: .top, spacing: AppSpacing.medium) {
                Text("\(index)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(sectionTint)
                    .clipShape(Circle())
                Text(text)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .appCardStyle()

        case .warning(let text):
            HStack(alignment: .top, spacing: AppSpacing.medium) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.warning)
                Text(text)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppSpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.warning.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppColors.warning.opacity(0.30), lineWidth: 1)
            )

        case .tip(let text):
            HStack(alignment: .top, spacing: AppSpacing.medium) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(sectionTint)
                Text(text)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppSpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(sectionTint.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(sectionTint.opacity(0.30), lineWidth: 1)
            )

        case .term(let dutch, let meaning):
            VStack(alignment: .leading, spacing: 3) {
                Text(dutch)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(sectionTint)
                Text(meaning)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCardStyle()
        }
    }

    private var linksSection: some View {
        let validLinks = article.links.compactMap { link -> (ExternalLink, URL)? in
            guard let url = AppURL.validatedWebURL(URL(string: link.urlString)) else { return nil }
            return (link, url)
        }

        return VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: sourcesLabel)

            if validLinks.isEmpty {
                sourceFallbackRows
            } else {
                ForEach(validLinks, id: \.0.id) { link, url in
                    sourceButton(link: link, url: url)
                }
            }
        }
        .accessibilityIdentifier("guide.article.sources.dashboard")
    }

    private func sourceButton(link: ExternalLink, url: URL) -> some View {
        Button {
            openURL(url)
        } label: {
            HStack(spacing: AppSpacing.medium) {
                Image(systemName: "link.circle.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(sectionTint)
                    .frame(width: 42, height: 42)
                    .background(sectionTint.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(link.localizedTitle(lang))
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(link.institution)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer(minLength: 8)

                Image(systemName: AppIcons.external)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .appCardStyle()
        }
        .buttonStyle(.plain)
    }

    private var sourceFallbackRows: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            sourceFallbackRow(
                title: sourcesLabel,
                subtitle: sourceFallbackOfficialSubtitle,
                icon: AppIcons.officialSource,
                destination: .officialSources
            )

            sourceFallbackRow(
                title: searchFallbackTitle,
                subtitle: searchFallbackSubtitle,
                icon: "magnifyingglass",
                destination: .searchList
            )

            sourceFallbackRow(
                title: resourcesFallbackTitle,
                subtitle: resourcesFallbackSubtitle,
                icon: "books.vertical.fill",
                destination: .resourcesHub
            )
        }
        .accessibilityIdentifier("guide.article.sources.empty")
    }

    private func sourceFallbackRow(title: String, subtitle: String, icon: String, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: AppSpacing.medium) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(sectionTint)
                    .frame(width: 42, height: 42)
                    .background(sectionTint.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .appCardStyle()
        }
        .buttonStyle(.plain)
    }

    private var sourcesLabel: String {
        switch lang {
        case .russian: return "Официальные источники"
        case .dutch: return "Officiële bronnen"
        case .english: return "Official sources"
        }
    }

    private var sourceFallbackOfficialSubtitle: String {
        switch lang {
        case .russian: return "Проверьте актуальные правила перед действием."
        case .dutch: return "Controleer actuele regels voordat je handelt."
        case .english: return "Check current rules before you act."
        }
    }

    private var searchFallbackTitle: String {
        switch lang {
        case .russian: return "Поиск"
        case .dutch: return "Zoeken"
        case .english: return "Search"
        }
    }

    private var searchFallbackSubtitle: String {
        switch lang {
        case .russian: return "Найти связанные ответы и документы."
        case .dutch: return "Vind verwante antwoorden en documenten."
        case .english: return "Find related answers and documents."
        }
    }

    private var resourcesFallbackTitle: String {
        switch lang {
        case .russian: return "Ресурсы"
        case .dutch: return "Bronnen"
        case .english: return "Resources"
        }
    }

    private var resourcesFallbackSubtitle: String {
        switch lang {
        case .russian: return "Открыть полезные ссылки по темам."
        case .dutch: return "Open nuttige links per thema."
        case .english: return "Open useful links by topic."
        }
    }
}
