import Foundation

enum MockExpansionData {
    private static let reviewed = Date(timeIntervalSince1970: 1772323200)
    private static let infoOnly = "Informational guidance only. Verify personal decisions with the official institution; this app is not an official government service."

    static let reminders: [ReminderItem] = [
        ReminderItem(title: "Health insurance check", detail: "Verify whether your situation requires Dutch basic health insurance.", category: .insurance, urgency: .high, date: Calendar.current.date(byAdding: .day, value: 6, to: Date()), localOnly: true),
        ReminderItem(title: "Municipality appointment prep", detail: "Prepare passport, rental details, and requested forms.", category: .appointmentPreparation, urgency: .medium, date: Calendar.current.date(byAdding: .day, value: 4, to: Date()), localOnly: true),
        ReminderItem(title: "Tax letter follow-up", detail: "Review recent tax communication and verify response dates.", category: .taxDeadline, urgency: .medium, date: Calendar.current.date(byAdding: .day, value: 18, to: Date()), localOnly: true)
    ]

    static let survivalGuide: [SurvivalGuideItem] = [
        SurvivalGuideItem(title: "Emergency numbers", shortText: "Use 112 for urgent emergencies.", detailText: "For immediate danger or medical emergencies, 112 is the primary emergency number. For non-urgent questions, use regular service channels."),
        SurvivalGuideItem(title: "Dutch communication style", shortText: "Direct communication is common.", detailText: "People may communicate directly in work or public settings. This is often cultural style rather than personal conflict."),
        SurvivalGuideItem(title: "Public transport basics", shortText: "Check in and check out.", detailText: "Many systems require both check-in and check-out. Missing a step may create possible ticket issues or correction charges."),
        SurvivalGuideItem(title: "Bicycle rules", shortText: "Follow local lane and light rules.", detailText: "Cycling is common. Verify local rules, lighting requirements, and right-of-way in your municipality."),
        SurvivalGuideItem(title: "Waste and trash systems", shortText: "Rules can differ by city and area.", detailText: "Collection days and sorting rules may vary. Check your municipality waste guide directly."),
        SurvivalGuideItem(title: "DigiD safety", shortText: "Use official DigiD domain directly.", detailText: "Avoid login links from unknown messages. Open official websites directly in your browser."),
        SurvivalGuideItem(title: "Work culture basics", shortText: "Contracts and expectations may be explicit.", detailText: "Clarify expectations early and keep written confirmations of schedule, pay, and responsibilities."),
        SurvivalGuideItem(title: "Scam awareness", shortText: "Urgent payment messages may be fraudulent.", detailText: "Scammers may imitate institutions. Verify all unusual requests with official channels.")
    ]

    static let knowledgeTopics: [KnowledgeTopic] = [
        topic("Registration & BSN", "Registration", "Register your address with the municipality and receive or confirm your BSN.", "Registration in the BRP connects your address, identity, tax, healthcare, work, and municipality records.", ["Book a gemeente appointment as soon as you have an address", "Prepare passport or residence permit and proof of address", "Save the registration confirmation and BSN letter"], ["Assuming AirBnB or hotel addresses always work", "Missing city-specific document rules"], "Government.nl", "https://www.government.nl/topics/personal-data/citizen-service-number-bsn", ["BSN", "BRP", "gemeente", "registration", "бсн", "регистрация"], ["How do I register?", "How do I get a BSN?"]),
        topic("DigiD", "Digital Services", "DigiD is the secure login for many Dutch public services.", "After BSN and address registration, DigiD unlocks tax, benefits, healthcare insurer, DUO, UWV, and municipality portals.", ["Apply only via digid.nl", "Activate with the postal code sent to your registered address", "Use the DigiD app and never share verification codes"], ["Applying before BSN/address are ready", "Clicking fake SMS login links"], "DigiD", "https://www.digid.nl/en", ["DigiD", "digital identity", "government login", "дигид"], ["How do I get DigiD?", "How do I avoid fake DigiD websites?"]),
        topic("Banking", "Money", "A Dutch or EU bank account is usually needed for salary, rent, Tikkie, insurance, and automatic payments.", "Banks may ask for identity, address, BSN, and sometimes employment or study context. Some banks support newcomers before BSN with temporary limits.", ["Compare account fees and English-language support", "Keep IBAN confirmation for employer and landlord", "Set up secure two-factor authentication"], ["Sending deposit money before verifying a landlord", "Ignoring automatic direct debits"], "Dutch Payments Association", "https://www.betaalvereniging.nl/en/", ["bank account", "IBAN", "Tikkie", "payment", "bank"], ["How do I open a bank account?", "How does Tikkie work?"]),
        topic("Health Insurance", "Healthcare", "Dutch basic health insurance can be mandatory depending on residence and work status.", "Newcomers should check when the obligation starts, compare basic policies, and understand eigen risico before choosing.", ["Check whether your profile requires Dutch insurance", "Compare monthly premium, eigen risico, contracted care, and reimbursement", "Apply for zorgtoeslag if eligible"], ["Waiting for a reminder letter before checking insurance", "Choosing only by monthly price"], "Government.nl", "https://www.government.nl/topics/health-insurance", ["zorgverzekering", "health insurance", "eigen risico", "zorgtoeslag"], ["Do I need health insurance?", "What is eigen risico?"]),
        topic("Housing & Rental Rights", "Housing", "Rental contracts, deposits, registration permission, and scams are critical newcomer risks.", "A legal rental setup should be written, verifiable, and compatible with municipality registration where required.", ["Verify landlord identity and address registration permission", "Do not pay large deposits without a signed contract and traceable payment", "Keep check-in photos and meter readings"], ["Paying via cash or crypto", "Signing without checking service costs and deposit return rules"], "Huurcommissie", "https://www.huurcommissie.nl", ["rent", "housing", "huur", "deposit", "rental rights"], ["How do I find housing?", "What should I check in a rental contract?"]),
        topic("Transport & OV", "Transport", "Public transport usually depends on check-in/check-out, route planning, and operator rules.", "NS, 9292, local operators, and OV-chipkaart/OVpay cover most everyday travel flows.", ["Plan routes with 9292 or NS", "Check in and check out with the same card/device", "Save delay or missed check-out evidence"], ["Checking in with one card and out with another", "Assuming every train surcharge is included"], "9292", "https://9292.nl/en", ["OV", "NS", "9292", "train", "check in", "transport"], ["How do I use NS?", "How does OV-chipkaart work?"]),
        topic("Bicycle Rules", "Transport", "Cycling is normal daily transport but has enforceable rules.", "Lights, phone use, priority, alcohol, bike lanes, and parking rules matter in cities.", ["Use front and rear lights in the dark", "Do not hold a phone while cycling", "Park only where allowed near stations and city centers"], ["Cycling on sidewalks", "Parking in removal zones"], "Government.nl", "https://www.government.nl/topics/mobility-public-transport-and-road-safety", ["bike", "cycling", "fiets", "bicycle fine", "phone cycling"], ["How do I cycle safely?", "Can I get fined on a bike?"]),
        topic("Taxes & Toeslagen", "Taxes", "Belastingdienst handles tax returns, tax letters, and income-based allowances.", "Toeslagen can help with healthcare, rent, childcare, or child budget, but incorrect income or household data can create repayments.", ["Open tax letters immediately", "Keep jaaropgave and payslips", "Update income, address, partner, and household changes in toeslagen portals"], ["Ignoring provisional assessment letters", "Forgetting to update income after a raise"], "Belastingdienst", "https://www.belastingdienst.nl", ["tax", "belastingdienst", "toeslagen", "zorgtoeslag", "huurtoeslag"], ["How do I file taxes?", "How do I apply for toeslagen?"]),
        topic("Work Contracts & Payslips", "Work", "Dutch work rights depend on contract type, CAO, salary, hours, sick leave, and payroll details.", "Employees should understand bruto/netto, vakantiegeld, probation period, notice period, and sick-leave reporting rules.", ["Check contract type and CAO", "Compare bruto salary with loonstrook", "Save payslips and jaaropgave"], ["Confusing bruto and netto salary", "Working trial shifts without clear pay rules"], "Rijksoverheid", "https://www.rijksoverheid.nl/onderwerpen/arbeidsovereenkomst-en-cao/vraag-en-antwoord/wat-staat-er-in-een-arbeidsovereenkomst", ["work", "contract", "loonstrook", "payslip", "vakantiegeld", "CAO"], ["How do I read a payslip?", "What if my employer violates rights?"]),
        topic("Healthcare Navigation", "Healthcare", "The huisarts is the usual first contact for non-emergency healthcare.", "Emergency care is for urgent situations; after-hours GP posts handle urgent care outside regular huisarts hours.", ["Register with a huisarts near your address", "Use pharmacy for prescriptions and medicine questions", "Call 112 only for immediate emergency danger"], ["Going to hospital emergency for non-urgent care", "Waiting too long to register with a GP"], "Government.nl", "https://www.government.nl/topics/health-insurance", ["huisarts", "GP", "pharmacy", "hospital", "112", "mental health"], ["How do I find a huisarts?", "When should I call 112?"]),
        topic("Waste & Recycling", "Daily Life", "Waste systems are local: collection days, underground containers, bulky waste, and sorting vary by municipality.", "Your address determines the calendar and container access. Wrong disposal can trigger local fines.", ["Check the municipality waste calendar", "Learn rules for paper, glass, organic waste, residual waste, and bulky pickup", "Use the correct container and collection day"], ["Leaving bags next to full containers", "Copying rules from another city"], "Municipality websites", "https://www.government.nl/topics/municipalities", ["waste", "trash", "recycling", "afval", "garbage"], ["How does trash collection work?", "Can I get a waste fine?"]),
        topic("Dutch Bureaucracy Explained", "Government", "Dutch administration is document-heavy, deadline-driven, and distributed across institutions.", "Many processes use letters, reference numbers, portals, and municipality-specific workflows.", ["Keep a folder for letters, contracts, payslips, and confirmations", "Track deadlines from every official letter", "Use official portals directly instead of search ads"], ["Assuming no answer means no action required", "Losing reference numbers"], "Rijksoverheid", "https://www.rijksoverheid.nl", ["bureaucracy", "overheid", "official letters", "government websites"], ["What do I do with a letter from overheid?", "How do I know which institution is responsible?"])
    ]

    static let documents: [DocumentReferenceItem] = [
        DocumentReferenceItem(title: "Rental contract", category: "Contracts", tags: ["housing", "address"], note: "Save signed version and landlord contact.", linkedReminderTitle: "Municipality appointment prep"),
        DocumentReferenceItem(title: "Municipality registration confirmation", category: "Municipality", tags: ["registration", "bsn"], note: "Keep copy for onboarding forms.", linkedReminderTitle: nil),
        DocumentReferenceItem(title: "Health insurance policy", category: "Insurance", tags: ["policy", "health"], note: "Store policy number and insurer support details.", linkedReminderTitle: "Health insurance check")
    ]

    static let municipalities: [MunicipalityProfile] = [
        MunicipalityProfile(name: "Leiden", website: AppURL.make("https://www.leiden.nl"), appointmentPage: AppURL.make("https://gemeente.leiden.nl"), registrationInfo: "Check residence registration and BSN appointment details.", wasteGuide: "Waste collection rules may differ by neighborhood.", parkingBasics: "Review permit zones and paid parking times.", emergencyContact: "Emergency 112; non-urgent municipal contact via website."),
        MunicipalityProfile(name: "Amsterdam", website: AppURL.make("https://www.amsterdam.nl"), appointmentPage: AppURL.make("https://www.amsterdam.nl/en/civil-affairs"), registrationInfo: "Review registration requirements and appointment slots.", wasteGuide: "Use local schedule and sorting guidance.", parkingBasics: "Parking zones and permits vary by district.", emergencyContact: "Emergency 112; local support via gemeente website."),
        MunicipalityProfile(name: "Rotterdam", website: AppURL.make("https://www.rotterdam.nl"), appointmentPage: AppURL.make("https://www.rotterdam.nl/english"), registrationInfo: "Check required documents before registration.", wasteGuide: "Follow district-specific collection guidance.", parkingBasics: "Review local parking permit options.", emergencyContact: "Emergency 112; municipal contact details online."),
        MunicipalityProfile(name: "Utrecht", website: AppURL.make("https://www.utrecht.nl"), appointmentPage: AppURL.make("https://www.utrecht.nl/english"), registrationInfo: "Verify appointment requirement and identity documents.", wasteGuide: "Check collection calendar for your address.", parkingBasics: "City center parking may have strict limits.", emergencyContact: "Emergency 112; municipality service contacts online."),
        MunicipalityProfile(name: "Den Haag", website: AppURL.make("https://www.denhaag.nl"), appointmentPage: AppURL.make("https://www.denhaag.nl/en"), registrationInfo: "Review newcomer registration process and booking options.", wasteGuide: "Sorting and container use may vary locally.", parkingBasics: "Verify permit and visitor parking rules.", emergencyContact: "Emergency 112; official municipal contact via website."),
        MunicipalityProfile(name: "Eindhoven", website: AppURL.make("https://www.eindhoven.nl"), appointmentPage: AppURL.make("https://www.eindhoven.nl/en"), registrationInfo: "Check international resident registration and appointment availability.", wasteGuide: "Use the address-based waste calendar.", parkingBasics: "Review permit zones and P+R options.", emergencyContact: "Emergency 112; city service via official website."),
        MunicipalityProfile(name: "Groningen", website: AppURL.make("https://gemeente.groningen.nl"), appointmentPage: AppURL.make("https://gemeente.groningen.nl/english"), registrationInfo: "Verify student/new resident registration instructions.", wasteGuide: "Collection and container access depend on address.", parkingBasics: "City center parking is limited; check permit areas.", emergencyContact: "Emergency 112; municipality contact online."),
        MunicipalityProfile(name: "Maastricht", website: AppURL.make("https://www.gemeentemaastricht.nl"), appointmentPage: AppURL.make("https://www.gemeentemaastricht.nl/en"), registrationInfo: "Check border-region newcomer and registration instructions.", wasteGuide: "Review local waste pass and collection information.", parkingBasics: "Check city center and resident permit zones.", emergencyContact: "Emergency 112; official contact via municipality.")
    ]

    static let lifeScenarios: [LifeScenario] = [
        LifeScenario(title: "I just arrived", situation: "You have entered the Netherlands and need to create the administrative base for daily life.", firstActions: ["Secure a registrable address", "Book municipality registration", "Prepare ID, contract, and arrival documents", "Start a document folder"], documentsToPrepare: ["Passport or ID", "Residence permit or visa documents", "Rental contract or host declaration", "Birth/marriage certificates if requested"], officialSourceName: "Government.nl", officialSourceURL: AppURL.make("https://www.government.nl/topics/municipalities"), relatedTopics: ["Registration & BSN", "DigiD", "Health Insurance"]),
        LifeScenario(title: "How do I register?", situation: "You need to register in the BRP through your local municipality.", firstActions: ["Find your gemeente website", "Book an appointment", "Check exact document list", "Ask whether BSN is issued during registration"], documentsToPrepare: ["Valid ID", "Proof of address", "Residence permit if applicable"], officialSourceName: "Government.nl", officialSourceURL: AppURL.make("https://www.government.nl/themes/government-and-democracy/personal-data/personal-records-database-brp"), relatedTopics: ["Registration & BSN", "Municipality Services"]),
        LifeScenario(title: "I received a fine", situation: "You got a letter, ticket, or message about a fine.", firstActions: ["Do not pay through unknown SMS or WhatsApp links", "Check sender, date, reference, and deadline", "Open CJIB or municipality website directly", "Save the letter"], documentsToPrepare: ["Fine letter", "Payment reference", "Photos or travel proof if objecting"], officialSourceName: "CJIB", officialSourceURL: AppURL.make("https://www.cjib.nl/en"), relatedTopics: ["Fines & Penalties", "Scams & Fraud"]),
        LifeScenario(title: "Employer violates rights", situation: "Your pay, schedule, contract, sickness rules, or dismissal situation seems wrong.", firstActions: ["Collect written evidence", "Compare payslip with contract", "Check CAO if applicable", "Contact Juridisch Loket or union for case-specific help"], documentsToPrepare: ["Contract", "Payslips", "Work schedule", "Messages from employer"], officialSourceName: "Juridisch Loket", officialSourceURL: AppURL.make("https://www.juridischloket.nl"), relatedTopics: ["Employment Rights", "UWV", "Payslips"]),
        LifeScenario(title: "Letter from the Dutch government", situation: "You received an official Dutch letter and do not understand the required action.", firstActions: ["Identify sender and institution", "Find deadline and reference number", "Translate only after preserving exact wording", "Contact the institution through official channels"], documentsToPrepare: ["Original letter", "Envelope if relevant", "DigiD access", "Reference numbers"], officialSourceName: "Rijksoverheid", officialSourceURL: AppURL.make("https://www.rijksoverheid.nl"), relatedTopics: ["Dutch Bureaucracy Explained", "Digital Services"])
    ]

    static let officialServices: [OfficialServiceDirectoryItem] = [
        service("Rijksoverheid", "rijksoverheid.nl", "Central Dutch government information", "Use for national rules, policy explanations, rights, duties, and official public guidance.", "https://www.rijksoverheid.nl", ["government", "rules", "laws"]),
        service("Government.nl", "government.nl", "English-language government information", "Use for newcomer-friendly English explanations of Dutch systems.", "https://www.government.nl", ["english", "government", "newcomer"]),
        service("Overheid.nl", "overheid.nl", "Official directory of Dutch government organizations.", "Use when you need to identify the responsible official institution.", "https://www.overheid.nl", ["government websites", "official"]),
        service("IND", "ind.nl", "Immigration and Naturalisation Service", "Use for residence permits, visas, asylum, naturalisation, and application status.", "https://ind.nl/en", ["immigration", "permit", "visa"]),
        service("Belastingdienst", "belastingdienst.nl", "Tax Administration", "Use for tax returns, tax letters, payroll taxes, and contact details.", "https://www.belastingdienst.nl", ["tax", "aangifte", "belasting"]),
        service("Toeslagen", "toeslagen.nl", "Benefits and allowances portal", "Use for healthcare allowance, rent allowance, childcare allowance, and child budget.", "https://www.toeslagen.nl", ["benefits", "allowances", "zorgtoeslag"]),
        service("UWV", "uwv.nl", "Employee insurance and employment services", "Use for unemployment, sickness, work capacity, and employment benefit questions.", "https://www.uwv.nl", ["work", "benefits", "unemployment"]),
        service("DigiD", "digid.nl", "Secure digital identity", "Use to apply, activate, recover, and manage DigiD access.", "https://www.digid.nl/en", ["digital services", "login"]),
        service("DUO", "duo.nl", "Education administration", "Use for student finance, inburgering administration, and education-related services.", "https://duo.nl", ["education", "student", "inburgering"]),
        service("RDW", "rdw.nl", "Vehicle and driving administration", "Use for driving licence, vehicle registration, APK, and import/export procedures.", "https://www.rdw.nl/en", ["driving", "vehicle", "license"]),
        service("NS", "ns.nl", "National rail operator", "Use for train planning, subscriptions, disruption information, and compensation.", "https://www.ns.nl/en", ["train", "transport"]),
        service("9292", "9292.nl", "Public transport route planner", "Use for multimodal trip planning across operators.", "https://9292.nl/en", ["transport", "OV", "planner"]),
        service("Politie", "politie.nl", "Dutch police", "Use for non-emergency police information and reporting guidance.", "https://www.politie.nl", ["police", "safety"]),
        service("Juridisch Loket", "juridischloket.nl", "First-line legal information", "Use for orientation on housing, work, consumer, and family legal questions.", "https://www.juridischloket.nl", ["legal help", "rights"])
    ]

    static let provinceProfiles: [ProvinceProfile] = [
        province("North Holland", "Haarlem", "about 2.9M", ["Amsterdam", "Haarlem", "Alkmaar", "Hilversum"], "High pressure around Amsterdam; smaller cities may be more practical.", "Dense rail, metro/tram in Amsterdam, strong cycling infrastructure.", "Tech, finance, tourism, creative industries, logistics.", "University of Amsterdam, VU Amsterdam and applied universities.", "Very international in Amsterdam/Haarlem, competitive housing.", "https://www.noord-holland.nl", ["112 emergency", "0900-8844 police non-emergency"], ["https://www.amsterdam.nl", "https://www.haarlem.nl"]),
        province("South Holland", "The Hague", "about 3.8M", ["Rotterdam", "The Hague", "Leiden", "Delft"], "High demand in Randstad cities; student cities need early search.", "Excellent rail, RandstadRail, metro in Rotterdam/The Hague.", "Ports, government, legal, research, universities, logistics.", "Leiden University, TU Delft, Erasmus University Rotterdam.", "Strong expat ecosystem across The Hague, Rotterdam, Leiden and Delft.", "https://www.zuid-holland.nl", ["112 emergency", "0900-8844 police non-emergency"], ["https://www.rotterdam.nl", "https://www.denhaag.nl", "https://www.leiden.nl", "https://www.delft.nl"]),
        province("Utrecht", "Utrecht", "about 1.4M", ["Utrecht", "Amersfoort", "Zeist", "Nieuwegein"], "Central location creates strong housing demand.", "National rail hub, buses, cycling-first city design.", "Business services, healthcare, education, tech.", "Utrecht University and HU University of Applied Sciences.", "International and central, but housing is tight.", "https://www.provincie-utrecht.nl", ["112 emergency", "0900-8844 police non-emergency"], ["https://www.utrecht.nl", "https://www.amersfoort.nl"]),
        province("North Brabant", "Den Bosch", "about 2.6M", ["Eindhoven", "Tilburg", "Breda", "Den Bosch"], "Generally more varied than Randstad; Eindhoven remains competitive.", "Intercity rail and regional buses; car use can be more common outside centers.", "High-tech, manufacturing, logistics, design, agrifood.", "TU/e, Tilburg University, Avans, Fontys.", "Strong in Eindhoven and university cities.", "https://www.brabant.nl", ["112 emergency", "0900-8844 police non-emergency"], ["https://www.eindhoven.nl", "https://www.tilburg.nl", "https://www.breda.nl"]),
        province("Groningen", "Groningen", "about 600K", ["Groningen", "Delfzijl", "Veendam"], "Lower than Randstad on average; student pressure in Groningen city.", "Regional trains/buses; Groningen city is highly bike-oriented.", "Education, healthcare, energy transition, services.", "University of Groningen and Hanze University.", "Friendly for students and researchers; smaller expat market.", "https://www.provinciegroningen.nl", ["112 emergency", "0900-8844 police non-emergency"], ["https://gemeente.groningen.nl"]),
        province("Limburg", "Maastricht", "about 1.1M", ["Maastricht", "Venlo", "Heerlen", "Sittard"], "Often less expensive than Randstad; city center housing can still be tight.", "Regional rail and buses; cross-border mobility matters.", "Healthcare, logistics, tourism, cross-border business.", "Maastricht University and Zuyd University.", "International in Maastricht, useful for border-region newcomers.", "https://www.limburg.nl", ["112 emergency", "0900-8844 police non-emergency"], ["https://www.gemeentemaastricht.nl", "https://www.venlo.nl"])
    ]

    static let cityProfiles: [CityProfile] = [
        city("Amsterdam", "North Holland", "Most international ecosystem, many services in English, severe housing pressure.", "Very expensive and competitive; verify registration permission.", "Metro, tram, bus, ferry, NS, cycling; parking is costly.", "Finance, tech, creative industries, tourism, universities.", "https://www.amsterdam.nl", "High expat friendliness but high cost.", ["Amsterdam", "expat", "housing", "GVB"]),
        city("Rotterdam", "South Holland", "Large international port city with more space than Amsterdam but rising demand.", "Mixed neighborhoods and price ranges; verify landlord and permit rules.", "Metro, tram, bus, NS, waterbus, strong bike growth.", "Port, logistics, engineering, business, Erasmus University.", "https://www.rotterdam.nl", "Practical, diverse, strong worker/student base.", ["Rotterdam", "port", "Erasmus", "housing"]),
        city("Den Haag", "South Holland", "Government, diplomacy, international courts, and many international residents.", "Demand is high around international schools and central districts.", "Tram, bus, NS, RandstadRail, cycling.", "Government, NGOs, legal, diplomacy, services.", "https://www.denhaag.nl", "Very expat-friendly with strong English support.", ["The Hague", "Den Haag", "government", "international"]),
        city("Utrecht", "Utrecht", "Central rail hub and major student/professional city.", "High competition due to central location.", "Excellent trains, buses, cycling; limited car convenience in center.", "Education, healthcare, tech, business services.", "https://www.utrecht.nl", "Friendly but housing-constrained.", ["Utrecht", "student", "rail hub"]),
        city("Eindhoven", "North Brabant", "High-tech city centered around ASML ecosystem, design, and TU/e.", "Competitive near tech corridors; broader region offers alternatives.", "Good rail and buses; cycling common.", "Tech, engineering, design, manufacturing.", "https://www.eindhoven.nl", "Strong expat ecosystem around tech employers.", ["Eindhoven", "ASML", "tech", "TU/e"]),
        city("Groningen", "Groningen", "Young student city with strong cycling culture.", "Student housing can be difficult around semester start.", "Bike-first city; trains and regional buses.", "University, healthcare, services, research.", "https://gemeente.groningen.nl", "Good for students, smaller international labor market.", ["Groningen", "student", "cycling"]),
        city("Leiden", "South Holland", "Historic university city between Amsterdam and The Hague.", "Tight market due to students and Randstad access.", "NS connections, buses, cycling.", "University, biotech, research, healthcare.", "https://www.leiden.nl", "International academic environment.", ["Leiden", "university", "biotech"]),
        city("Maastricht", "Limburg", "International university city near Belgium and Germany.", "Generally less pressured than Randstad, with student peaks.", "Regional trains/buses; cross-border travel relevant.", "University, healthcare, tourism, cross-border business.", "https://www.gemeentemaastricht.nl", "International student-friendly, border-region practicalities.", ["Maastricht", "student", "border"])
    ]

    static let newcomerRoadmap: [NewcomerRoadmapWeek] = [
        NewcomerRoadmapWeek(title: "Week 1", focus: "Identity and registration base", steps: ["Secure registrable address", "Book gemeente registration", "Prepare BSN documents", "Get SIM/mobile access", "Start a document folder"], officialSourceNames: ["Government.nl", "Municipality website"]),
        NewcomerRoadmapWeek(title: "Week 2", focus: "Digital identity, banking, insurance, transport", steps: ["Apply for DigiD after BSN/address are ready", "Open or prepare a bank account", "Check health insurance obligation", "Set up OVpay/OV-chipkaart or NS account"], officialSourceNames: ["DigiD", "Government.nl", "NS", "9292"]),
        NewcomerRoadmapWeek(title: "Week 3", focus: "Work, taxes, GP and local systems", steps: ["Check employment contract or study administration", "Register with huisarts where possible", "Learn Belastingdienst letters", "Check municipality waste and parking rules"], officialSourceNames: ["Belastingdienst", "UWV", "Municipality website"]),
        NewcomerRoadmapWeek(title: "Week 4", focus: "Benefits, language, integration, stability", steps: ["Check toeslagen eligibility", "Review inburgering or language learning path", "Save emergency and non-urgent contacts", "Verify all official portals and deadlines"], officialSourceNames: ["Toeslagen", "DUO", "Overheid.nl"])
    ]

    static let suggestedSearches: [String] = [
        "BSN appointment",
        "Health insurance",
        "DigiD safety",
        "Tax letter",
        "Municipality registration",
        "Open bank account",
        "Find huisarts",
        "Apply toeslagen",
        "Read payslip",
        "Bike fine",
        "Waste collection",
        "Rental contract",
        "OV check in",
        "Letter from the Dutch government"
    ]

    private static func topic(_ title: String, _ category: String, _ summary: String, _ beginnerExplanation: String, _ practicalSteps: [String], _ commonMistakes: [String], _ sourceName: String, _ url: String, _ tags: [String], _ relatedQuestions: [String]) -> KnowledgeTopic {
        KnowledgeTopic(category: category, title: title, summary: summary, beginnerExplanation: beginnerExplanation, practicalSteps: practicalSteps, commonMistakes: commonMistakes, officialSourceName: sourceName, officialSourceURL: AppURL.make(url), relatedLinks: [AppURL.make(url)], relatedQuestions: relatedQuestions, tags: tags, lastReviewed: reviewed, updateStatus: "Source-first starter content", safetyDisclaimer: infoOnly)
    }

    private static func service(_ name: String, _ domain: String, _ purpose: String, _ whenToUse: String, _ url: String, _ tags: [String]) -> OfficialServiceDirectoryItem {
        OfficialServiceDirectoryItem(name: name, domain: domain, purpose: purpose, whenToUse: whenToUse, officialURL: AppURL.make(url), tags: tags)
    }

    private static func province(_ name: String, _ capital: String, _ population: String, _ majorCities: [String], _ rentContext: String, _ transportContext: String, _ workContext: String, _ universityContext: String, _ expatFriendliness: String, _ website: String, _ emergencyContacts: [String], _ municipalityLinks: [String]) -> ProvinceProfile {
        ProvinceProfile(name: name, capital: capital, population: population, majorCities: majorCities, rentContext: rentContext, transportContext: transportContext, workContext: workContext, universityContext: universityContext, expatFriendliness: expatFriendliness, officialWebsite: AppURL.make(website), emergencyContacts: emergencyContacts, municipalityLinks: municipalityLinks.map { AppURL.make($0) })
    }

    private static func city(_ name: String, _ province: String, _ newcomerSummary: String, _ housingContext: String, _ transportContext: String, _ workStudyContext: String, _ municipalityURL: String, _ expatNotes: String, _ tags: [String]) -> CityProfile {
        let assetBaseName = cityAssetBaseName(name)
        let heroImageName = "\(assetBaseName)_hero"
        return CityProfile(
            name: name,
            province: province,
            newcomerSummary: newcomerSummary,
            housingContext: housingContext,
            transportContext: transportContext,
            workStudyContext: workStudyContext,
            municipalityURL: AppURL.make(municipalityURL),
            expatNotes: expatNotes,
            heroImageName: heroImageName,
            imageCredit: [
                .english: "City images must be local, project-owned, public-domain, or properly licensed before release.",
                .dutch: "Stadsbeelden moeten lokaal, projecteigendom, publiek domein of correct gelicenseerd zijn voor release.",
                .russian: "Изображения городов перед релизом должны быть локальными, собственными, public domain или корректно лицензированными."
            ],
            heroImageAssetName: heroImageName,
            tags: tags
        )
    }

    private static func cityAssetBaseName(_ name: String) -> String {
        let normalized = name
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        return "city_\(normalized)"
    }
}
