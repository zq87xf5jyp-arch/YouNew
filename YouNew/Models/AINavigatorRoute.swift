import Foundation

struct AINavigatorRoute: Identifiable {
    let id: String
    let intentEN: String
    let intentNL: String
    let intentRU: String
    let icon: String
    let recommendedDestination: AppDestination
    let stepsEN: [String]
    let officialSources: [String]

    func intent(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return intentEN
        case .dutch:   return intentNL
        case .russian: return intentRU
        }
    }
}

enum AINavigatorRoutes {
    static let disclaimer = "Information only. Always verify with official sources. Not legal or medical advice."

    static let quickRoutes: [AINavigatorRoute] = [
        AINavigatorRoute(
            id: "bsn",
            intentEN: "Get BSN number",
            intentNL: "BSN-nummer aanvragen",
            intentRU: "Получить номер BSN",
            icon: "person.text.rectangle.fill",
            recommendedDestination: .governmentHub,
            stepsEN: [
                "1. Register at your municipality (Gemeente)",
                "2. Bring valid ID and proof of address",
                "3. You will receive BSN after registration",
                "4. Use BSN for DigiD, healthcare, work"
            ],
            officialSources: ["rijksoverheid.nl", "rvig.nl"]
        ),
        AINavigatorRoute(
            id: "digid",
            intentEN: "Get DigiD",
            intentNL: "DigiD aanvragen",
            intentRU: "Получить DigiD",
            icon: "lock.shield.fill",
            recommendedDestination: .governmentHub,
            stepsEN: [
                "1. Go to digid.nl (official only)",
                "2. You need BSN number first",
                "3. Request activation code by post",
                "4. Complete verification in app"
            ],
            officialSources: ["digid.nl"]
        ),
        AINavigatorRoute(
            id: "housing",
            intentEN: "Find housing",
            intentNL: "Woning zoeken",
            intentRU: "Найти жильё",
            icon: "house.fill",
            recommendedDestination: .helpHub,
            stepsEN: [
                "1. Register at housing corporation (woningcorporatie)",
                "2. Check private rental platforms",
                "3. Ask municipality about social housing waiting list",
                "4. Verify rental contract is legal"
            ],
            officialSources: ["woningnet.nl", "huurcommissie.nl"]
        ),
        AINavigatorRoute(
            id: "doctor",
            intentEN: "Find a doctor",
            intentNL: "Huisarts vinden",
            intentRU: "Найти врача",
            icon: "stethoscope",
            recommendedDestination: .helpHub,
            stepsEN: [
                "1. Find a huisarts (GP) in your area",
                "2. Register as a patient",
                "3. For urgent care use huisartsenpost",
                "4. For emergencies call 112"
            ],
            officialSources: ["zoekdokter.nl", "zorgwijzer.nl"]
        ),
        AINavigatorRoute(
            id: "work",
            intentEN: "Find work",
            intentNL: "Werk vinden",
            intentRU: "Найти работу",
            icon: "briefcase.fill",
            recommendedDestination: .helpHub,
            stepsEN: [
                "1. Check if you need a work permit (TWV)",
                "2. Register at UWV if unemployed",
                "3. Use werk.nl for job listings",
                "4. Check minimum wage rules"
            ],
            officialSources: ["werk.nl", "uwv.nl", "ind.nl"]
        ),
        AINavigatorRoute(
            id: "taxes",
            intentEN: "Taxes and income",
            intentNL: "Belastingen en inkomen",
            intentRU: "Налоги и доходы",
            icon: "banknote.fill",
            recommendedDestination: .governmentHub,
            stepsEN: [
                "1. Register at Belastingdienst (tax office)",
                "2. File annual tax return (aangifte)",
                "3. Check toeslagen (benefits/allowances)",
                "4. Use MijnBelastingdienst portal"
            ],
            officialSources: ["belastingdienst.nl", "toeslagen.nl"]
        ),
        AINavigatorRoute(
            id: "emergency",
            intentEN: "Emergency help",
            intentNL: "Noodhulp",
            intentRU: "Экстренная помощь",
            icon: "phone.fill",
            recommendedDestination: .emergencyHub,
            stepsEN: [
                "1. Life-threatening: call 112 immediately",
                "2. Police (non-emergency): 0900-8844",
                "3. Doctor (urgent): huisartsenpost",
                "4. Mental crisis: 0800-0113"
            ],
            officialSources: ["112.nl"]
        ),
        AINavigatorRoute(
            id: "dutch",
            intentEN: "Learn Dutch",
            intentNL: "Nederlands leren",
            intentRU: "Учить нидерландский",
            icon: "text.book.closed.fill",
            recommendedDestination: .languageHub,
            stepsEN: [
                "1. Start with A1–A2 basics",
                "2. Practice daily with common phrases",
                "3. Register for inburgeringscursus if required",
                "4. Take NT2 exam when ready"
            ],
            officialSources: ["duo.nl", "inburgeren.nl"]
        )
    ]
}
