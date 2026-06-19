import Foundation

struct PriorityItem {
    let text: [AppLanguage: String]
}

struct DocumentRequirement {
    let text: [AppLanguage: String]
}

enum InstitutionType: String {
    case gemeente
    case ind
    case duo
    case uwv
    case belastingdienst
    case juridischLoket
    case coa
}

enum LegalTopic: String {
    case residenceRules
    case workContract
    case taxLetters
    case registration
    case insurance
    case studentSupport
}

struct WarningItem {
    let text: [AppLanguage: String]
}

struct OnboardingStepBlueprint {
    let title: [AppLanguage: String]
}

struct ProfileBlueprint {
    let id: UserStatus
    let title: [AppLanguage: String]
    let topPriorities: [PriorityItem]
    let requiredDocuments: [DocumentRequirement]
    let recommendedInstitutions: [InstitutionType]
    let recommendedLegalTopics: [LegalTopic]
    let emergencyWarnings: [WarningItem]
    let onboardingFlow: [OnboardingStepBlueprint]
    let checklistIncludeKeywords: [String]
    let checklistExcludeKeywords: [String]

    static func forStatus(_ status: UserStatus) -> ProfileBlueprint {
        switch status {
        case .tourist:
            return ProfileBlueprint(
                id: .tourist,
                title: [.russian: "Турист / временное пребывание", .english: "Tourist / Temporary Stay", .dutch: "Toerist / Tijdelijk verblijf"],
                topPriorities: [p("виза и срок пребывания", "visa and allowed stay", "visum en toegestane verblijfsduur"), p("страховка", "insurance", "verzekering"), p("адрес проживания", "accommodation address", "verblijfsadres"), p("правила штрафов и писем", "fines and letter rules", "regels rond boetes en brieven")],
                requiredDocuments: [d("паспорт и виза", "passport and visa", "paspoort en visum"), d("подтверждение проживания", "proof of accommodation", "bewijs van verblijf"), d("страховой полис", "insurance policy", "verzekeringspolis")],
                recommendedInstitutions: [.ind, .gemeente],
                recommendedLegalTopics: [.residenceRules, .insurance],
                emergencyWarnings: [w("Не превышайте срок пребывания.", "Do not overstay your allowed period.", "Overschrijd uw toegestane verblijfsduur niet.")],
                onboardingFlow: [s("Проверить срок пребывания", "Check stay duration", "Controleer verblijfsduur"), s("Проверить страховку", "Check insurance", "Controleer verzekering")],
                checklistIncludeKeywords: ["insurance", "official letters", "emergency", "transport", "documents"],
                checklistExcludeKeywords: ["digid", "bsn", "duo", "uwv", "register your address", "work systems"]
            )
        case .student:
            return ProfileBlueprint(
                id: .student,
                title: [.russian: "Студент", .english: "Student", .dutch: "Student"],
                topPriorities: [p("зачисление и жильё", "enrollment and housing", "inschrijving en huisvesting"), p("DUO и транспорт", "DUO and transport", "DUO en vervoer"), p("страховка и регистрация", "insurance and registration", "verzekering en registratie")],
                requiredDocuments: [d("документ о зачислении", "proof of enrollment", "inschrijfbewijs"), d("договор жилья", "housing contract", "huurcontract"), d("паспорт/ВНЖ", "passport/residence permit", "paspoort/verblijfsdocument")],
                recommendedInstitutions: [.duo, .gemeente],
                recommendedLegalTopics: [.studentSupport, .registration, .insurance],
                emergencyWarnings: [w("Проверяйте дедлайны DUO и университета.", "Track DUO and university deadlines.", "Let op deadlines van DUO en opleiding.")],
                onboardingFlow: [s("Подтвердить зачисление", "Confirm enrollment", "Bevestig inschrijving"), s("Проверить DUO", "Check DUO eligibility", "Controleer DUO")],
                checklistIncludeKeywords: ["duo", "student", "housing", "transport", "insurance", "register your address", "bsn"],
                checklistExcludeKeywords: ["30% ruling"]
            )
        case .worker:
            return ProfileBlueprint(
                id: .worker,
                title: [.russian: "Работник", .english: "Worker", .dutch: "Werknemer"],
                topPriorities: [p("контракт и loonstrook", "contract and payslips", "contract en loonstroken"), p("BSN и DigiD", "BSN and DigiD", "BSN en DigiD"), p("налоги и страховка", "taxes and insurance", "belasting en verzekering")],
                requiredDocuments: [d("рабочий контракт", "work contract", "arbeidscontract"), d("loonstrook", "payslip", "loonstrook"), d("BSN", "BSN", "BSN")],
                recommendedInstitutions: [.uwv, .belastingdienst, .gemeente],
                recommendedLegalTopics: [.workContract, .taxLetters, .insurance, .registration],
                emergencyWarnings: [w("Не работайте без понятного договора.", "Do not work without a clear contract.", "Werk niet zonder duidelijk contract.")],
                onboardingFlow: [s("Проверить договор", "Review contract", "Controleer contract"), s("Сохранить loonstrook", "Store payslips", "Bewaar loonstroken")],
                checklistIncludeKeywords: ["work", "bsn", "digid", "tax", "insurance", "register your address", "payslip"],
                checklistExcludeKeywords: ["duo", "student housing"]
            )
        case .expat:
            return ProfileBlueprint(
                id: .expat,
                title: [.russian: "Экспат", .english: "Expat", .dutch: "Expat"],
                topPriorities: [p("BSN и DigiD", "BSN and DigiD", "BSN en DigiD"), p("налоги и 30%-regeling", "taxes and 30% ruling", "belasting en 30%-regeling"), p("жильё и страховка", "housing and insurance", "huisvesting en verzekering")],
                requiredDocuments: [d("документы работодателя", "employer documents", "werkgeversdocumenten"), d("договор жилья", "rental contract", "huurcontract"), d("страховой полис", "insurance policy", "verzekeringspolis")],
                recommendedInstitutions: [.belastingdienst, .gemeente, .ind],
                recommendedLegalTopics: [.taxLetters, .registration, .insurance],
                emergencyWarnings: [w("Проверяйте дедлайны по налогам и миграции.", "Check tax and immigration deadlines.", "Controleer belasting- en immigratiedeadlines.")],
                onboardingFlow: [s("Настроить DigiD", "Set up DigiD", "Stel DigiD in"), s("Проверить налоги", "Review tax setup", "Controleer belastingzaken")],
                checklistIncludeKeywords: ["bsn", "digid", "tax", "insurance", "register your address", "housing"],
                checklistExcludeKeywords: ["duo", "student"]
            )
        case .highlySkilledMigrant:
            return ProfileBlueprint(
                id: .highlySkilledMigrant,
                title: [.russian: "Высококвалифицированный мигрант", .english: "Highly Skilled Migrant", .dutch: "Kennismigrant"],
                topPriorities: [p("IND и работодатель-спонсор", "IND and recognized sponsor", "IND en erkend referent"), p("BSN, DigiD и 30%-regeling", "BSN, DigiD, and 30% ruling", "BSN, DigiD en 30%-regeling"), p("жильё, страховка и семья", "housing, insurance, and family", "wonen, verzekering en gezin")],
                requiredDocuments: [d("документы работодателя", "employer/sponsor documents", "documenten werkgever/referent"), d("договор жилья", "rental contract", "huurcontract"), d("страховой полис", "insurance policy", "verzekeringspolis")],
                recommendedInstitutions: [.ind, .belastingdienst, .gemeente],
                recommendedLegalTopics: [.residenceRules, .taxLetters, .registration, .insurance],
                emergencyWarnings: [w("Проверяйте сроки IND, спонсора и налогов.", "Check IND, sponsor, and tax deadlines.", "Controleer IND-, referent- en belastingdeadlines.")],
                onboardingFlow: [s("Проверить маршрут IND", "Check IND route", "Controleer IND-route"), s("Настроить BSN и DigiD", "Set up BSN and DigiD", "Regel BSN en DigiD")],
                checklistIncludeKeywords: ["ind", "sponsor", "bsn", "digid", "30% ruling", "tax", "insurance", "register your address", "housing"],
                checklistExcludeKeywords: ["duo", "student", "refugee"]
            )
        case .euCitizen:
            return ProfileBlueprint(
                id: .euCitizen,
                title: [.russian: "Гражданин ЕС", .english: "EU Citizen", .dutch: "EU-burger"],
                topPriorities: [p("регистрация и BSN", "registration and BSN", "registratie en BSN"), p("работа и медицина", "work rights and healthcare", "werkrechten en zorg"), p("жильё и налоги", "housing and taxes", "wonen en belasting")],
                requiredDocuments: [d("паспорт/ID ЕС", "EU passport/ID", "EU-paspoort/ID"), d("документы адреса", "address documents", "adresdocumenten")],
                recommendedInstitutions: [.gemeente, .belastingdienst],
                recommendedLegalTopics: [.registration, .insurance, .taxLetters],
                emergencyWarnings: [w("Не откладывайте регистрацию, если вы переезжаете надолго.", "Do not postpone registration if you are moving for longer-term stay.", "Stel registratie niet uit bij langer verblijf.")],
                onboardingFlow: [s("Зарегистрироваться в gemeente", "Register with municipality", "Schrijf u in bij de gemeente"), s("Проверить медстраховку", "Check health insurance", "Controleer zorgverzekering")],
                checklistIncludeKeywords: ["register your address", "bsn", "digid", "insurance", "work", "tax", "housing"],
                checklistExcludeKeywords: ["ind", "duo", "asylum"]
            )
        case .refugee:
            return ProfileBlueprint(
                id: .refugee,
                title: [.russian: "Беженец / статус-холдер", .english: "Refugee / Status Holder", .dutch: "Vluchteling / Statushouder"],
                topPriorities: [p("документы статуса", "status documents", "statusdocumenten"), p("gemeente и жильё", "gemeente and housing", "gemeente en huisvesting"), p("страховка и поддержка", "insurance and support", "verzekering en ondersteuning")],
                requiredDocuments: [d("решение о статусе", "status decision", "statusbesluit"), d("документы IND", "IND documents", "IND-documenten")],
                recommendedInstitutions: [.ind, .coa, .juridischLoket, .gemeente],
                recommendedLegalTopics: [.residenceRules, .registration, .insurance],
                emergencyWarnings: [w("Не пропускайте письма и встречи.", "Do not miss official letters and appointments.", "Mis geen officiële brieven en afspraken.")],
                onboardingFlow: [s("Проверить статусные документы", "Check status documents", "Controleer statusdocumenten"), s("Определить вашу gemeente", "Confirm your municipality", "Bevestig uw gemeente")],
                checklistIncludeKeywords: ["documents", "insurance", "register", "official letters", "housing"],
                checklistExcludeKeywords: ["30% ruling"]
            )
        case .ukrainian:
            return ProfileBlueprint(
                id: .ukrainian,
                title: [.russian: "Украинец", .english: "Ukrainian", .dutch: "Oekraïner"],
                topPriorities: [p("временная защита", "temporary protection", "tijdelijke bescherming"), p("регистрация и BSN", "registration and BSN", "registratie en BSN"), p("работа и медицина", "work rules and healthcare", "werkregels en zorg")],
                requiredDocuments: [d("паспорт", "passport", "paspoort"), d("документы временной защиты", "temporary protection documents", "documenten tijdelijke bescherming")],
                recommendedInstitutions: [.ind, .gemeente],
                recommendedLegalTopics: [.residenceRules, .registration, .insurance],
                emergencyWarnings: [w("Проверяйте обновления правил защиты.", "Check updates to protection rules.", "Controleer updates van beschermingsregels.")],
                onboardingFlow: [s("Проверить регистрацию", "Check registration", "Controleer registratie"), s("Проверить условия работы", "Check work conditions", "Controleer werkvoorwaarden")],
                checklistIncludeKeywords: ["documents", "insurance", "register your address", "bsn", "official letters"],
                checklistExcludeKeywords: ["30% ruling"]
            )
        case .family:
            return ProfileBlueprint(
                id: .family,
                title: [.russian: "Семья", .english: "Family", .dutch: "Gezin"],
                topPriorities: [p("адрес и дети", "address and children setup", "adres en kindzaken"), p("школа/daycare", "school/daycare", "school/opvang"), p("страховка и пособия", "insurance and benefits", "verzekering en toeslagen")],
                requiredDocuments: [d("семейные документы", "family documents", "gezinsdocumenten"), d("документы адреса", "address documents", "adresdocumenten")],
                recommendedInstitutions: [.gemeente, .belastingdienst],
                recommendedLegalTopics: [.registration, .insurance, .taxLetters],
                emergencyWarnings: [w("Следите за дедлайнами по детям и школе.", "Track children and school deadlines.", "Let op deadlines voor kinderen en school.")],
                onboardingFlow: [s("Зарегистрировать адрес", "Register address", "Registreer adres"), s("Проверить школу/daycare", "Arrange school/daycare", "Regel school/opvang")],
                checklistIncludeKeywords: ["register your address", "housing", "insurance", "official letters", "tax", "student"],
                checklistExcludeKeywords: []
            )
        case .entrepreneur:
            return ProfileBlueprint(
                id: .entrepreneur,
                title: [.russian: "Предприниматель", .english: "Entrepreneur", .dutch: "Ondernemer"],
                topPriorities: [p("KvK и регистрация бизнеса", "KvK and business registration", "KvK en bedrijfsregistratie"), p("BTW/VAT и налоги", "VAT/BTW and taxes", "BTW en belasting"), p("банк, страховка и разрешения", "banking, insurance, and permits", "bank, verzekering en vergunningen")],
                requiredDocuments: [d("документ личности", "identity document", "identiteitsdocument"), d("бизнес-данные", "business details", "bedrijfsgegevens")],
                recommendedInstitutions: [.belastingdienst, .gemeente],
                recommendedLegalTopics: [.taxLetters, .registration, .insurance],
                emergencyWarnings: [w("Проверяйте налоговые обязательства до выставления счетов.", "Check tax obligations before invoicing.", "Controleer belastingplichten voordat u factureert.")],
                onboardingFlow: [s("Подготовить KvK", "Prepare KvK registration", "Bereid KvK-registratie voor"), s("Проверить BTW/VAT", "Check VAT/BTW", "Controleer BTW")],
                checklistIncludeKeywords: ["business", "kvk", "btw", "vat", "tax", "bank", "insurance", "permit"],
                checklistExcludeKeywords: ["duo", "student", "refugee"]
            )
        case .lgbtNewcomer:
            return ProfileBlueprint(
                id: .lgbtNewcomer,
                title: [.russian: "ЛГБТ-новичок", .english: "LGBT Newcomer", .dutch: "LHBTI-nieuwkomer"],
                topPriorities: [p("безопасность и права", "safety and rights", "veiligheid en rechten"), p("медицина и психическое здоровье", "healthcare and mental health", "zorg en mentale gezondheid"), p("сообщество и юридическая поддержка", "community and legal support", "gemeenschap en juridische hulp")],
                requiredDocuments: [d("важные письма и документы", "important letters and documents", "belangrijke brieven en documenten")],
                recommendedInstitutions: [.juridischLoket, .gemeente],
                recommendedLegalTopics: [.residenceRules, .insurance],
                emergencyWarnings: [w("В экстренной ситуации используйте 112; для небезопасного жилья ищите местную помощь.", "Use 112 in emergencies; for unsafe housing, seek local support.", "Gebruik 112 bij spoed; zoek lokale hulp bij onveilige woonsituaties.")],
                onboardingFlow: [s("Найти безопасную поддержку", "Find safe support", "Vind veilige steun"), s("Проверить медицинскую помощь", "Check healthcare support", "Controleer zorgondersteuning")],
                checklistIncludeKeywords: ["lgbt", "support", "healthcare", "legal help", "housing", "community"],
                checklistExcludeKeywords: []
            )
        }
    }

    private static func p(_ ru: String, _ en: String, _ nl: String) -> PriorityItem {
        PriorityItem(text: [.russian: ru, .english: en, .dutch: nl])
    }

    private static func d(_ ru: String, _ en: String, _ nl: String) -> DocumentRequirement {
        DocumentRequirement(text: [.russian: ru, .english: en, .dutch: nl])
    }

    private static func w(_ ru: String, _ en: String, _ nl: String) -> WarningItem {
        WarningItem(text: [.russian: ru, .english: en, .dutch: nl])
    }

    private static func s(_ ru: String, _ en: String, _ nl: String) -> OnboardingStepBlueprint {
        OnboardingStepBlueprint(title: [.russian: ru, .english: en, .dutch: nl])
    }
}
