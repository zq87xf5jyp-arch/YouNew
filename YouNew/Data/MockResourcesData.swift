import Foundation

enum MockResourcesData {
    static let items: [ResourceLinkItem] = [
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:ind-residence-permits-and-immigration"),
            category: "Immigration",
            title: "IND: Residence permits and immigration",
            description: "Official rules on residence permit types, renewals, visas, asylum, and naturalisation.",
            whoItHelps: "Newcomers dealing with residency and immigration questions",
            sourceLabel: "Official source",
            url: AppURL.make("https://ind.nl/en"),
            isOfficial: true,
            reminder: "Always check current requirements before submitting an application. Rules can change.",
            personaTags: [.refugee, .nonEU, .highlySkilledMigrant]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:uwv-employment-and-benefits"),
            category: "Work",
            title: "UWV: Employment and benefits",
            description: "Official information on employment insurance, unemployment benefits, sick leave, and work capacity.",
            whoItHelps: "Workers and temporary employees dealing with employment rights",
            sourceLabel: "Official source",
            url: AppURL.make("https://www.uwv.nl"),
            isOfficial: true,
            reminder: "Check your contract type and work situation against UWV conditions.",
            personaTags: [.worker]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:belastingdienst-tax-administration"),
            category: "Taxes",
            title: "Belastingdienst: Tax administration",
            description: "How to read tax letters, check deadlines, file a tax return, and understand your tax obligations.",
            whoItHelps: "Anyone receiving tax correspondence or needing to file a return",
            sourceLabel: "Official source",
            url: AppURL.make("https://www.belastingdienst.nl"),
            isOfficial: true,
            reminder: "Note response and payment deadlines on tax letters immediately — late action may lead to fines.",
            personaTags: [.worker, .eu, .highlySkilledMigrant, .entrepreneur]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:toeslagen-benefits-and-allowances"),
            category: "Taxes",
            title: "Toeslagen: Benefits and allowances",
            description: "Official portal for applying for and managing healthcare, rent, childcare, and child budget allowances.",
            whoItHelps: "Families, students, and workers who may qualify for income-based allowances",
            sourceLabel: "Official source",
            url: AppURL.make("https://www.toeslagen.nl"),
            isOfficial: true,
            reminder: "Update income and household details after any change — overpayments must be repaid.",
            personaTags: [.family, .worker, .refugee]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:government-nl-health-insurance-explained"),
            category: "Healthcare",
            title: "Government.nl: Health insurance explained",
            description: "Overview of mandatory basic health insurance, who must take it out, timelines, and the annual deductible.",
            whoItHelps: "Newcomers and workers who need to understand their health insurance obligation",
            sourceLabel: "Official source",
            url: AppURL.make("https://www.government.nl/topics/health-insurance"),
            isOfficial: true,
            reminder: "The obligation start date depends on your personal situation. Check early.",
            personaTags: [.student, .worker, .refugee, .family, .eu, .highlySkilledMigrant, .entrepreneur, .lgbt]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:gp-huisarts-and-emergency-care"),
            category: "Healthcare",
            title: "GP (huisarts) and emergency care",
            description: "Practical guide on when to contact your GP, when to go to the hospital, and when to call 112.",
            whoItHelps: "Everyone navigating the Dutch healthcare system for the first time",
            sourceLabel: "Official source",
            url: AppURL.make("https://www.government.nl/themes/justice-security-and-defence/emergency-number-112"),
            isOfficial: true,
            reminder: "Call 112 only for life-threatening situations. For non-urgent care, contact your huisarts.",
            personaTags: [.worker, .refugee, .family, .tourist, .eu, .highlySkilledMigrant, .entrepreneur, .lgbt]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:duo-international-student-info"),
            category: "Education",
            title: "DUO: International student info",
            description: "DUO information on education administration, student finance, and study-related obligations for international students.",
            whoItHelps: "International students",
            sourceLabel: "Official source",
            url: AppURL.make("https://duo.nl/particulier/international-visitor.jsp"),
            isOfficial: true,
            reminder: "Check your DUO portal regularly and save all confirmation messages.",
            personaTags: [.student]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:study-in-nl-student-guide"),
            category: "Student life",
            title: "Study in NL: Student guide",
            description: "Orientation on studying in the Netherlands — application, campus basics, and getting settled.",
            whoItHelps: "New international students arriving in the Netherlands",
            sourceLabel: "Trusted source",
            url: AppURL.make("https://www.studyinnl.org"),
            isOfficial: false,
            reminder: "Verify final requirements directly with DUO and your institution.",
            personaTags: [.student]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:government-nl-housing-and-rental-rights"),
            category: "Housing",
            title: "Government.nl: Housing and rental rights",
            description: "Official guidance on rental rights, address registration, tenant protections, and rental allowance.",
            whoItHelps: "Renters and newcomers looking for housing guidance",
            sourceLabel: "Official source",
            url: AppURL.make("https://www.government.nl/topics/housing"),
            isOfficial: true,
            reminder: "Local municipality rules may differ from national guidelines — check your gemeente.",
            personaTags: [.student, .worker, .refugee, .family, .eu, .highlySkilledMigrant, .entrepreneur, .lgbt]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:rdw-driving-licences-and-vehicles"),
            category: "Transport",
            title: "RDW: Driving licences and vehicles",
            description: "Official rules on driving licences, vehicle registration, APK inspections, and licence exchange for foreign residents.",
            whoItHelps: "Drivers and vehicle owners in the Netherlands",
            sourceLabel: "Official source",
            url: AppURL.make("https://www.rdw.nl/en"),
            isOfficial: true,
            reminder: "Check whether your country has a licence exchange agreement with the Netherlands before applying.",
            personaTags: [.worker, .tourist, .eu, .highlySkilledMigrant, .entrepreneur]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:juridisch-loket-first-line-legal-help"),
            category: "Legal help",
            title: "Juridisch Loket: First-line legal help",
            description: "Plain-language legal orientation for housing, employment, consumer rights, and understanding official letters.",
            whoItHelps: "Anyone who needs to understand their legal rights or respond to official correspondence",
            sourceLabel: "Trusted source",
            url: AppURL.make("https://www.juridischloket.nl"),
            isOfficial: false,
            reminder: "Juridisch Loket provides general guidance — consult a lawyer for complex personal situations.",
            personaTags: [.worker, .refugee, .family, .entrepreneur, .lgbt]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:fraudehelpdesk-scam-reporting"),
            category: "Scams",
            title: "Fraudehelpdesk: Scam reporting",
            description: "Check suspicious messages, report scams, and find out how to protect yourself from phishing, fake fines, and fraud.",
            whoItHelps: "Anyone who has received a suspicious message or believes they are being targeted",
            sourceLabel: "Trusted source",
            url: AppURL.make("https://www.fraudehelpdesk.nl"),
            isOfficial: false,
            reminder: "Never click links in suspicious messages. Always type official URLs manually.",
            personaTags: [.worker, .refugee, .family, .tourist, .eu, .highlySkilledMigrant, .entrepreneur, .lgbt]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:emergency-number-112"),
            category: "Emergencies",
            title: "Emergency number 112",
            description: "Emergency call service for police, fire, and ambulance. Use only for immediate life-threatening situations.",
            whoItHelps: "Anyone in urgent emergencies",
            sourceLabel: "Official source",
            url: AppURL.make("https://www.government.nl/themes/justice-security-and-defence/emergency-number-112"),
            isOfficial: true,
            reminder: "For non-emergency police matters, call 0900-8844. For non-urgent medical questions, contact your GP or GP emergency post.",
            personaTags: [.refugee, .family, .tourist, .lgbt]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:government-nl-coming-to-the-netherlands"),
            category: "Immigration",
            title: "Government.nl: Coming to the Netherlands",
            description: "Overview of registration, BSN, residence, and first steps for newcomers arriving in the Netherlands.",
            whoItHelps: "Anyone newly arriving and starting life in the Netherlands",
            sourceLabel: "Official source",
            url: AppURL.make("https://www.government.nl/topics/moving-to-the-netherlands"),
            isOfficial: true,
            reminder: "Steps and timelines can vary by nationality and purpose of stay.",
            personaTags: [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant]
        ),
        ResourceLinkItem(
            id: StableRouteID.uuid("resource:acm-consuwijzer-consumer-rights"),
            category: "Legal help",
            title: "ACM ConsuWijzer: Consumer rights",
            description: "Advice on consumer rights, complaints against companies, unfair contracts, and online shopping disputes.",
            whoItHelps: "Anyone dealing with a consumer complaint or unfair business practice",
            sourceLabel: "Official source",
            url: AppURL.make("https://www.consuwijzer.nl"),
            isOfficial: true,
            reminder: "For unresolved complaints, you can escalate to the relevant sector regulator.",
            personaTags: [.worker, .family, .tourist, .entrepreneur, .lgbt]
        )
    ]
}
