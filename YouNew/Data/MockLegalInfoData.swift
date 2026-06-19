import Foundation

enum MockLegalInfoData {
    private static let updated = Date(timeIntervalSince1970: 1746057600)
    private static let disclaimer = "This is informational guidance, not legal advice. Always verify current rules with official sources."

    private static func item(
        title: [AppLanguage: String],
        category: LegalInfoCategory,
        short: [AppLanguage: String],
        explanation: [AppLanguage: String],
        sourceName: String,
        url: String,
        institution: String? = nil,
        risk: RiskLevel,
        keywords: [String]
    ) -> LegalInfoItem {
        let englishTitle = title[.english] ?? title.values.first ?? "untitled"
        return LegalInfoItem(
            id: StableRouteID.uuid("legal-info:\(stableKnowledgeKey(englishTitle))"),
            titleByLanguage: title,
            category: category,
            shortSummaryByLanguage: short,
            beginnerExplanationByLanguage: explanation,
            officialSourceName: sourceName,
            officialSourceURL: AppURL.validatedWebURL(URL(string: url)),
            relatedInstitution: institution,
            riskLevel: risk,
            lastUpdated: updated,
            disclaimer: disclaimer,
            keywords: keywords
        )
    }

    private static func stableKnowledgeKey(_ title: String) -> String {
        title.lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    static let items: [LegalInfoItem] = [
        item(
            title: [.english: "Municipal Registration (BRP)", .dutch: "Inschrijving bij de gemeente (BRP)", .russian: "Регистрация в муниципалитете (BRP)"],
            category: .municipality,
            short: [.english: "You usually register at the municipality after arrival with a fixed address.", .dutch: "Na aankomst met een vast adres moet je je meestal bij de gemeente inschrijven.", .russian: "После приезда с постоянным адресом обычно нужно зарегистрироваться в gemeente."],
            explanation: [.english: "BRP registration is often the first formal step and may be needed for many services. Required documents and appointment steps differ by municipality, so check the official municipal website.", .dutch: "Inschrijving in de BRP is vaak een eerste formele stap en kan nodig zijn voor veel diensten. Benodigde documenten en afspraken verschillen per gemeente, dus controleer de officiele website.", .russian: "Регистрация в BRP часто является первым формальным шагом и может понадобиться для многих услуг. Требования и запись отличаются по муниципалитетам, поэтому проверьте на официальном сайте вашей gemeente."],
            sourceName: "Government.nl",
            url: "https://www.government.nl/topics/personal-data/citizen-service-number-bsn",
            institution: "Municipality",
            risk: .high,
            keywords: ["brp", "registration", "gemeente", "муниципалитет", "регистрация"]
        ),
        item(
            title: [.english: "BSN — Citizen Service Number", .dutch: "BSN — Burgerservicenummer", .russian: "BSN — личный номер в Нидерландах"],
            category: .identity,
            short: [.english: "BSN is a personal number used in many official systems.", .dutch: "BSN is een persoonlijk nummer dat in veel officiele systemen wordt gebruikt.", .russian: "BSN — личный номер, который используется во многих официальных системах."],
            explanation: [.english: "BSN is assigned after registration and is used for healthcare, work, taxes, and more. Timing may differ per case, so verify with municipality or IND.", .dutch: "BSN wordt na registratie toegekend en wordt gebruikt voor zorg, werk, belastingen en meer. De timing kan per situatie verschillen, controleer dit bij gemeente of IND.", .russian: "BSN обычно присваивается после регистрации и используется для медицины, работы, налогов и других сервисов. Сроки могут отличаться, поэтому уточняйте в gemeente или IND."],
            sourceName: "Government.nl",
            url: "https://www.government.nl/topics/personal-data/citizen-service-number-bsn",
            institution: "Municipality / IND",
            risk: .high,
            keywords: ["bsn", "burgerservicenummer", "личный номер", "identity", "идентификация"]
        ),
        item(
            title: [.english: "DigiD — Digital Identity Login", .dutch: "DigiD — Digitale inlog", .russian: "DigiD — цифровой вход"],
            category: .identity,
            short: [.english: "DigiD is used to access many government portals.", .dutch: "DigiD wordt gebruikt voor toegang tot veel overheidsportalen.", .russian: "DigiD используется для входа во многие государственные порталы."],
            explanation: [.english: "Use only the official DigiD website and keep credentials private. If a message asks for your password by email or SMS, verify first on the official site.", .dutch: "Gebruik alleen de officiele DigiD-website en houd je gegevens prive. Vraagt een bericht om je wachtwoord via e-mail of sms, controleer dan eerst via de officiele site.", .russian: "Используйте только официальный сайт DigiD и не передавайте данные для входа. Если в письме или SMS просят пароль, сначала проверьте информацию на официальном сайте."],
            sourceName: "DigiD",
            url: "https://www.digid.nl/en",
            institution: "DigiD",
            risk: .medium,
            keywords: ["digid", "inloggen", "вход", "фишинг", "identity"]
        ),
        item(
            title: [.english: "IND — Residence Permit Basics", .dutch: "IND — Basis verblijfsvergunning", .russian: "IND — основы вида на жительство"],
            category: .immigration,
            short: [.english: "IND handles many residence permit procedures.", .dutch: "IND behandelt veel procedures rond verblijfsvergunningen.", .russian: "IND ведет многие процедуры по виду на жительство."],
            explanation: [.english: "Requirements depend on permit type and personal situation. Check deadlines and current document lists directly with IND.", .dutch: "Vereisten hangen af van het type vergunning en je persoonlijke situatie. Controleer deadlines en documentlijsten altijd direct bij IND.", .russian: "Требования зависят от типа разрешения и вашей ситуации. Сроки и список документов может понадобиться проверить напрямую на сайте IND."],
            sourceName: "IND",
            url: "https://ind.nl/en",
            institution: "IND",
            risk: .urgent,
            keywords: ["ind", "verblijfsvergunning", "вид на жительство", "иммиграция", "mvv"]
        ),
        item(
            title: [.english: "Asylum Procedure — Overview", .dutch: "Asielprocedure — Overzicht", .russian: "Процедура убежища — обзор"],
            category: .immigration,
            short: [.english: "Asylum steps are handled through IND and often COA.", .dutch: "Asielstappen lopen via IND en vaak ook COA.", .russian: "Этапы процедуры убежища обычно проходят через IND и COA."],
            explanation: [.english: "The process includes formal interviews and decisions. Timelines and support differ by case, so verify details with official channels.", .dutch: "Het proces bevat formele gesprekken en besluiten. Termijnen en ondersteuning verschillen per dossier, controleer details via officiele kanalen.", .russian: "Процесс включает официальные интервью и решения. Сроки и поддержка зависят от дела, поэтому проверяйте детали в официальных источниках."],
            sourceName: "IND",
            url: "https://ind.nl/en/asylum",
            institution: "IND / COA",
            risk: .urgent,
            keywords: ["asylum", "asiel", "убежище", "ind", "coa"]
        ),
        item(
            title: [.english: "Work Contract Types in the Netherlands", .dutch: "Soorten arbeidscontracten in Nederland", .russian: "Типы трудовых договоров в Нидерландах"],
            category: .work,
            short: [.english: "Contract type affects terms like duration and notice.", .dutch: "Het contracttype bepaalt onder andere duur en opzegregels.", .russian: "Тип договора влияет на срок, условия и порядок прекращения."],
            explanation: [.english: "Contracts may be fixed-term, permanent, or agency-based. Read pay, hours, trial period, and notice terms before signing.", .dutch: "Contracten kunnen tijdelijk, vast of via uitzendwerk zijn. Lees loon, uren, proeftijd en opzegregels goed voor je tekent.", .russian: "Договор может быть срочным, бессрочным или через агентство. Перед подписью проверьте оплату, часы, испытательный срок и условия прекращения."],
            sourceName: "Government.nl",
            url: "https://www.government.nl/themes/work",
            institution: "UWV",
            risk: .medium,
            keywords: ["arbeidsovereenkomst", "work contract", "договор", "работа", "uwv"]
        ),
        item(
            title: [.english: "Minimum Wage Basics", .dutch: "Basis minimumloon", .russian: "Минимальная зарплата: основы"],
            category: .work,
            short: [.english: "Minimum wage levels are set and updated by official authorities.", .dutch: "Minimumloonbedragen worden officieel vastgesteld en aangepast.", .russian: "Размер минимальной зарплаты устанавливается официально и периодически меняется."],
            explanation: [.english: "Amounts can change and may depend on age groups. Check current values on official government pages before making decisions.", .dutch: "Bedragen kunnen wijzigen en kunnen per leeftijd verschillen. Controleer actuele waarden op officiele overheidspagina's.", .russian: "Суммы могут меняться и зависеть от возраста. Перед действиями проверьте актуальные значения на официальном сайте."],
            sourceName: "Rijksoverheid",
            url: "https://www.rijksoverheid.nl/onderwerpen/minimumloon",
            institution: "UWV",
            risk: .medium,
            keywords: ["minimumloon", "minimum wage", "минимальная зарплата", "loon", "работа"]
        ),
        item(
            title: [.english: "Understanding Your Payslip (Loonstrook)", .dutch: "Je loonstrook begrijpen", .russian: "Как читать расчетный лист (loonstrook)"],
            category: .work,
            short: [.english: "Payslips show gross pay, deductions, and net pay.", .dutch: "Op loonstroken staan bruto loon, inhoudingen en netto loon.", .russian: "В loonstrook указаны начисления, удержания и сумма к выплате."],
            explanation: [.english: "Keep payslips for annual tax and income records. If numbers look unclear, ask your employer and verify with official tax information.", .dutch: "Bewaar loonstroken voor je jaarlijkse belasting- en inkomensgegevens. Bij onduidelijkheden vraag je werkgever en controleer officiele belastinginformatie.", .russian: "Сохраняйте loonstrook для налоговой отчетности и подтверждения дохода. Если данные непонятны, уточните у работодателя и проверьте информацию на официальном сайте."],
            sourceName: "Belastingdienst",
            url: "https://www.belastingdienst.nl",
            institution: "Belastingdienst",
            risk: .low,
            keywords: ["loonstrook", "payslip", "зарплата", "налоги", "loonheffing"]
        ),
        item(
            title: [.english: "Annual Tax Declaration (Aangifte Inkomstenbelasting)", .dutch: "Jaarlijkse belastingaangifte", .russian: "Годовая налоговая декларация"],
            category: .tax,
            short: [.english: "Many residents submit yearly income tax declarations.", .dutch: "Veel inwoners doen jaarlijks aangifte inkomstenbelasting.", .russian: "Многие жители подают годовую декларацию по подоходному налогу."],
            explanation: [.english: "Whether you must file and by when depends on your situation. Check letters, deadlines, and portal instructions on Belastingdienst.", .dutch: "Of je moet aangifte doen en wanneer hangt van je situatie af. Controleer brieven, deadlines en portaalinstructies van Belastingdienst.", .russian: "Нужно ли подавать декларацию и в какой срок, зависит от вашей ситуации. Проверьте письма, дедлайны и инструкции в официальном кабинете Belastingdienst."],
            sourceName: "Belastingdienst",
            url: "https://www.belastingdienst.nl",
            institution: "Belastingdienst",
            risk: .high,
            keywords: ["aangifte", "tax return", "налоги", "belastingdienst", "декларация"]
        ),
        item(
            title: [.english: "Income Tax Basics (Box 1)", .dutch: "Inkomstenbelasting basis (Box 1)", .russian: "Подоходный налог: Box 1"],
            category: .tax,
            short: [.english: "Work and primary home income is usually in Box 1.", .dutch: "Inkomen uit werk en hoofdwoning valt meestal in Box 1.", .russian: "Доход от работы и основного жилья обычно относится к Box 1."],
            explanation: [.english: "Rates and thresholds can change over time. Verify current percentages and rules on official Belastingdienst pages.", .dutch: "Tarieven en grenzen kunnen in de tijd veranderen. Controleer actuele percentages en regels op officiele Belastingdienst-pagina's.", .russian: "Ставки и пороги могут меняться. Проверьте актуальные правила и проценты на официальном сайте Belastingdienst."],
            sourceName: "Belastingdienst",
            url: "https://www.belastingdienst.nl",
            institution: "Belastingdienst",
            risk: .medium,
            keywords: ["box 1", "inkomstenbelasting", "подоходный налог", "налоги", "loonheffing"]
        ),
        item(
            title: [.english: "Toeslagen — Dutch Allowance Schemes", .dutch: "Toeslagen — Overzicht", .russian: "Toeslagen — основные виды пособий"],
            category: .benefits,
            short: [.english: "Allowances can support healthcare, rent, and childcare costs.", .dutch: "Toeslagen kunnen helpen met zorg-, huur- en kinderopvangkosten.", .russian: "Пособия могут частично покрывать расходы на страховку, аренду и уход за детьми."],
            explanation: [.english: "Eligibility depends on income and household details. If your situation changes, update data promptly to avoid repayments.", .dutch: "Recht op toeslagen hangt af van inkomen en huishouden. Verandert je situatie, werk je gegevens snel bij om terugbetalingen te voorkomen.", .russian: "Право на пособия зависит от дохода и состава домохозяйства. Если данные меняются, обновите их вовремя, иначе может понадобиться возврат."],
            sourceName: "Belastingdienst Toeslagen",
            url: "https://www.toeslagen.nl",
            institution: "Belastingdienst",
            risk: .medium,
            keywords: ["toeslagen", "пособия", "zorgtoeslag", "huurtoeslag", "налоги"]
        ),
        item(
            title: [.english: "Housing Allowance (Huurtoeslag)", .dutch: "Huurtoeslag", .russian: "Huurtoeslag — пособие на аренду"],
            category: .benefits,
            short: [.english: "Eligible renters may receive support for rent costs.", .dutch: "Huurders die voldoen aan voorwaarden kunnen huurtoeslag krijgen.", .russian: "При выполнении условий арендаторы могут получать поддержку по аренде."],
            explanation: [.english: "Conditions include income and rent limits and can change. Verify current thresholds and report changes through official portals.", .dutch: "Voorwaarden bevatten inkomens- en huurgrenzen en kunnen veranderen. Controleer actuele grenzen en meld wijzigingen via officiele portalen.", .russian: "Условия включают лимиты по доходу и аренде и могут меняться. Проверьте актуальные пороги и сообщайте изменения через официальный портал."],
            sourceName: "Belastingdienst Toeslagen",
            url: "https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/toeslagen/huurtoeslag/",
            institution: "Belastingdienst",
            risk: .medium,
            keywords: ["huurtoeslag", "аренда", "пособие", "toeslagen", "жилье"]
        ),
        item(
            title: [.english: "Health Allowance (Zorgtoeslag)", .dutch: "Zorgtoeslag", .russian: "Zorgtoeslag — пособие на медстраховку"],
            category: .benefits,
            short: [.english: "Eligible residents may get support for insurance premiums.", .dutch: "Inwoners die voldoen aan voorwaarden kunnen steun voor zorgpremie krijgen.", .russian: "При выполнении условий можно получить помощь с оплатой страховки."],
            explanation: [.english: "Amounts depend on current income and other factors. Update your details if income changes and verify current rules on official pages.", .dutch: "Bedragen hangen af van actueel inkomen en andere factoren. Werk je gegevens bij bij inkomenswijziging en controleer officiele regels.", .russian: "Размер зависит от текущего дохода и других факторов. При изменении дохода обновите данные и проверьте правила на официальном сайте."],
            sourceName: "Belastingdienst Toeslagen",
            url: "https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/toeslagen/zorgtoeslag/",
            institution: "Belastingdienst",
            risk: .medium,
            keywords: ["zorgtoeslag", "страховка", "пособие", "toeslagen", "healthcare"]
        ),
        item(
            title: [.english: "Mandatory Health Insurance (Zorgverzekering)", .dutch: "Verplichte zorgverzekering", .russian: "Обязательная медицинская страховка"],
            category: .healthcare,
            short: [.english: "Most people living or working in NL need basic health insurance.", .dutch: "De meeste mensen die in NL wonen of werken hebben een basisverzekering nodig.", .russian: "Большинству людей, живущих или работающих в Нидерландах, нужна базовая страховка."],
            explanation: [.english: "The basic package is set by law, while insurers and prices differ. Check whether insurance is required in your case and from what date.", .dutch: "Het basispakket is wettelijk vastgelegd, maar verzekeraars en prijzen verschillen. Controleer of en vanaf wanneer de plicht voor jou geldt.", .russian: "Базовый пакет определяется законом, но страховщики и цены отличаются. Проверьте, обязаны ли вы оформлять страховку и с какой даты."],
            sourceName: "Government.nl",
            url: "https://www.government.nl/topics/health-insurance",
            institution: "Government.nl",
            risk: .high,
            keywords: ["zorgverzekering", "страховка", "mandatory", "zvw", "health"]
        ),
        item(
            title: [.english: "Eigen Risico — Health Insurance Deductible", .dutch: "Eigen risico", .russian: "Eigen risico — франшиза по страховке"],
            category: .healthcare,
            short: [.english: "Adults usually pay a yearly deductible for many treatments.", .dutch: "Volwassenen betalen meestal een jaarlijks eigen risico voor veel behandelingen.", .russian: "Взрослые обычно оплачивают ежегодную франшизу по многим видам лечения."],
            explanation: [.english: "The deductible amount can change each year and some care is excluded. Verify current amount and exceptions in official sources.", .dutch: "Het bedrag kan jaarlijks wijzigen en sommige zorg valt erbuiten. Controleer actueel bedrag en uitzonderingen bij officiele bronnen.", .russian: "Размер франшизы может меняться каждый год, а часть услуг не входит в нее. Проверьте актуальную сумму и исключения в официальных источниках."],
            sourceName: "Zorginstituut Nederland",
            url: "https://www.zorginstituutnederland.nl",
            institution: "Zorginstituut Nederland",
            risk: .low,
            keywords: ["eigen risico", "франшиза", "страховка", "zorgverzekering", "медицина"]
        ),
        item(
            title: [.english: "Private Rental Rights Overview", .dutch: "Overzicht rechten bij particuliere huur", .russian: "Аренда у частного арендодателя: базовый обзор"],
            category: .housing,
            short: [.english: "Rental agreements include rights and obligations for both sides.", .dutch: "Huurovereenkomsten bevatten rechten en plichten voor beide partijen.", .russian: "Договор аренды содержит обязанности и условия для обеих сторон."],
            explanation: [.english: "Read notice period, rent increase terms, and extra costs before signing. If terms are unclear, check official housing guidance and legal help channels.", .dutch: "Lees opzegtermijn, huurverhoging en bijkomende kosten goed voor je tekent. Bij onduidelijkheid controleer officiele wooninformatie en rechtshulpkanalen.", .russian: "Перед подписанием проверьте срок уведомления, условия повышения аренды и дополнительные платежи. Если не уверены, проверьте официальные разъяснения и обратитесь за юридической помощью."],
            sourceName: "Government.nl",
            url: "https://www.government.nl/topics/housing",
            institution: "Huurcommissie",
            risk: .medium,
            keywords: ["huurcontract", "аренда", "договор", "housing", "huurrecht"]
        ),
        item(
            title: [.english: "Social Housing — Wachtlijst", .dutch: "Sociale huur — wachtlijst", .russian: "Социальное жилье — очередь"],
            category: .housing,
            short: [.english: "Social housing often has long waiting lists.", .dutch: "Voor sociale huur zijn wachtlijsten vaak lang.", .russian: "На социальное жилье обычно действует длинная очередь."],
            explanation: [.english: "Registration and eligibility differ by city and housing corporation. Check local rules early if social housing is your main option.", .dutch: "Inschrijving en voorwaarden verschillen per stad en woningcorporatie. Controleer lokale regels op tijd als sociale huur je hoofdoptie is.", .russian: "Регистрация и условия зависят от города и woningcorporatie. Если это ваш основной вариант, лучше заранее проверить местные правила."],
            sourceName: "Government.nl",
            url: "https://www.government.nl/topics/housing",
            institution: "Municipality / Woningcorporatie",
            risk: .medium,
            keywords: ["wachtlijst", "social housing", "социальное жилье", "аренда", "жилье"]
        ),
        item(
            title: [.english: "OV-chipkaart — Public Transport Card", .dutch: "OV-chipkaart", .russian: "OV-chipkaart — карта для общественного транспорта"],
            category: .transport,
            short: [.english: "You usually check in and out for public transport rides.", .dutch: "Bij openbaar vervoer check je meestal in en uit.", .russian: "В общественном транспорте обычно нужно отмечаться при входе и при выходе."],
            explanation: [.english: "Missing check-out can lead to correction charges. Check official transport provider rules for balance, refunds, and travel products.", .dutch: "Niet uitchecken kan leiden tot correctiekosten. Controleer officiele regels van vervoerders voor saldo, restitutie en reisproducten.", .russian: "Если не отметить выход, может появиться корректирующее списание. Проверьте официальные правила перевозчика по балансу и возвратам."],
            sourceName: "OV-chipkaart",
            url: "https://www.ov-chipkaart.nl/en",
            institution: "NS / Transport providers",
            risk: .low,
            keywords: ["ov-chipkaart", "транспорт", "check in", "check out", "поезд"]
        ),
        item(
            title: [.english: "Driving Licence Exchange", .dutch: "Omwisselen rijbewijs", .russian: "Обмен водительского удостоверения"],
            category: .transport,
            short: [.english: "Rules depend on your country and residence status.", .dutch: "Regels hangen af van je land en verblijfsstatus.", .russian: "Правила зависят от страны выдачи и вашего статуса проживания."],
            explanation: [.english: "Some licences can be exchanged directly, others require tests. Verify your exact route and required documents with RDW.", .dutch: "Sommige rijbewijzen kun je direct omwisselen, voor andere zijn examens nodig. Controleer je route en documenten bij RDW.", .russian: "Часть удостоверений можно обменять напрямую, в других случаях нужны экзамены. Уточните свою процедуру и документы на официальном сайте RDW."],
            sourceName: "RDW",
            url: "https://www.rdw.nl/en/driving-licence/foreign-driving-licence",
            institution: "RDW",
            risk: .medium,
            keywords: ["rijbewijs", "driving licence", "водительское", "rdw", "обмен"]
        ),
        item(
            title: [.english: "Inburgering — Civic Integration", .dutch: "Inburgering", .russian: "Inburgering — интеграция"],
            category: .education,
            short: [.english: "Some newcomers need to complete integration requirements.", .dutch: "Sommige nieuwkomers moeten aan inburgeringseisen voldoen.", .russian: "Некоторым новым жителям нужно выполнить требования по интеграции."],
            explanation: [.english: "Obligations, deadlines, and costs depend on permit type and personal route. Check your current status and deadlines with DUO or IND.", .dutch: "Plichten, deadlines en kosten hangen af van je vergunning en traject. Controleer je actuele status en deadlines bij DUO of IND.", .russian: "Обязанности, сроки и расходы зависят от типа разрешения и вашей ситуации. Проверьте актуальный статус и дедлайны в DUO или IND."],
            sourceName: "DUO",
            url: "https://duo.nl/particulier/inburgeren.jsp",
            institution: "DUO / IND",
            risk: .high,
            keywords: ["inburgering", "duo", "ind", "интеграция", "экзамен"]
        ),
        item(
            title: [.english: "DUO — Student Finance", .dutch: "DUO — Studiefinanciering", .russian: "DUO — финансирование учебы"],
            category: .education,
            short: [.english: "DUO manages loans and grants for eligible students.", .dutch: "DUO beheert leningen en toelagen voor studenten die in aanmerking komen.", .russian: "DUO ведет студенческие займы и выплаты для тех, кто соответствует условиям."],
            explanation: [.english: "Eligibility depends on study type, status, and other conditions. Verify current rules, obligations, and repayment details on official DUO pages.", .dutch: "Recht hangt af van opleiding, status en andere voorwaarden. Controleer actuele regels, verplichtingen en terugbetaling op officiele DUO-pagina's.", .russian: "Право зависит от программы обучения, статуса и других условий. Проверьте актуальные правила, обязательства и порядок возврата на официальном сайте DUO."],
            sourceName: "DUO",
            url: "https://duo.nl/particulier/student-finance.jsp",
            institution: "DUO",
            risk: .medium,
            keywords: ["duo", "studiefinanciering", "учеба", "студент", "loan"]
        ),
        item(
            title: [.english: "Traffic Fine Process (Wahv)", .dutch: "Verkeersboeteproces (Wahv)", .russian: "Дорожные штрафы (Wahv)"],
            category: .fines,
            short: [.english: "Many traffic fines are processed through CJIB.", .dutch: "Veel verkeersboetes worden via CJIB verwerkt.", .russian: "Многие дорожные штрафы обрабатываются через CJIB."],
            explanation: [.english: "Check deadline, payment reference, and official sender details before paying. If you disagree, verify the official bezwaar or beroep route and do not miss deadlines.", .dutch: "Controleer deadline, betalingskenmerk en officiele afzendergegevens voor je betaalt. Ben je het niet eens, controleer de officiele bezwaar- of beroepsroute en mis geen termijnen.", .russian: "Сначала проверьте срок, номер платежа и официальный источник письма. Если вы не согласны, проверьте официальный порядок bezwaar или beroep и не пропускайте сроки."],
            sourceName: "CJIB",
            url: "https://www.cjib.nl/en",
            institution: "CJIB",
            risk: .medium,
            keywords: ["cjib", "boete", "штраф", "письмо", "оплата"]
        ),
        item(
            title: [.english: "Juridisch Loket — Free Legal Information", .dutch: "Juridisch Loket — Gratis juridische info", .russian: "Juridisch Loket — бесплатная правовая информация"],
            category: .legalHelp,
            short: [.english: "Juridisch Loket offers first-line legal information.", .dutch: "Juridisch Loket biedt eerstelijns juridische informatie.", .russian: "Juridisch Loket дает базовую правовую информацию."],
            explanation: [.english: "It can help you understand options and next steps in simple terms. For complex cases, they can explain where to find further legal support.", .dutch: "Het kan helpen om opties en vervolgstappen duidelijk te maken. Bij complexe zaken kunnen zij uitleggen waar je verdere rechtshulp vindt.", .russian: "Сервис помогает понять варианты и следующие шаги простым языком. В сложных случаях там обычно подскажут, куда обратиться дальше за юридической помощью."],
            sourceName: "Juridisch Loket",
            url: "https://www.juridischloket.nl",
            institution: "Juridisch Loket",
            risk: .low,
            keywords: ["juridisch loket", "legal help", "юридическая помощь", "право", "консультация"]
        ),
        item(
            title: [.english: "Rechtbank — Dutch Courts Overview", .dutch: "Rechtbank — Overzicht", .russian: "Суды Нидерландов — обзор"],
            category: .legalHelp,
            short: [.english: "Court letters and deadlines should be taken seriously.", .dutch: "Brieven van de rechtbank en deadlines moet je serieus nemen.", .russian: "Письма из суда и сроки важно не игнорировать."],
            explanation: [.english: "Court procedures differ by case type and strict deadlines often apply. If you receive official court documents, check the deadline and seek legal help quickly.", .dutch: "Procedures verschillen per zaaktype en strikte termijnen gelden vaak. Ontvang je officiele rechtbankdocumenten, controleer de deadline en zoek snel rechtshulp.", .russian: "Процедуры зависят от типа дела, и сроки часто строгие. Если получили официальные документы из суда, сразу проверьте дедлайн и при необходимости обратитесь за юридической помощью."],
            sourceName: "Rechtspraak.nl",
            url: "https://www.rechtspraak.nl/English",
            institution: "Rechtspraak.nl",
            risk: .high,
            keywords: ["rechtbank", "court", "суд", "дедлайн", "rechtspraak"]
        ),
        item(
            title: [.english: "Netherlands Labour Authority — Work Rights", .dutch: "Nederlandse Arbeidsinspectie — Werkrechten", .russian: "Нидерландская инспекция труда — права на работе"],
            category: .work,
            short: [.english: "Use the Labour Authority for work-safety and fair-work information.", .dutch: "Gebruik de Arbeidsinspectie voor informatie over veilig en eerlijk werk.", .russian: "Инспекция труда помогает ориентироваться в вопросах безопасной и честной работы."],
            explanation: [.english: "If a workplace situation involves unsafe conditions, underpayment concerns, or exploitation signals, collect documents and verify the official reporting or information route before acting.", .dutch: "Gaat het om onveilige omstandigheden, mogelijke onderbetaling of signalen van uitbuiting, verzamel documenten en controleer de officiele meld- of informatieroute voordat je handelt.", .russian: "Если есть небезопасные условия, подозрение на недоплату или признаки эксплуатации, сохраните документы и проверьте официальный путь обращения перед действиями."],
            sourceName: "Netherlands Labour Authority",
            url: "https://www.nllabourauthority.nl",
            institution: "Netherlands Labour Authority",
            risk: .high,
            keywords: ["labour authority", "arbeidsinspectie", "work rights", "underpayment", "exploitation", "работа", "недоплата"]
        ),
        item(
            title: [.english: "Business.gov.nl — Starting as an Entrepreneur", .dutch: "Business.gov.nl — Starten als ondernemer", .russian: "Business.gov.nl — начало предпринимательства"],
            category: .work,
            short: [.english: "Business.gov.nl explains official steps for entrepreneurs in English.", .dutch: "Business.gov.nl legt officiele stappen voor ondernemers in het Engels uit.", .russian: "Business.gov.nl объясняет официальные шаги для предпринимателей на английском."],
            explanation: [.english: "Before registering or signing contracts, verify business form, tax, permit, insurance, and administration requirements through official entrepreneur guidance.", .dutch: "Controleer voor inschrijving of contracten eerst rechtsvorm, belasting, vergunningen, verzekeringen en administratie via officiele ondernemersinformatie.", .russian: "Перед регистрацией или договорами проверьте форму бизнеса, налоги, разрешения, страховки и административные обязанности через официальный справочник для предпринимателей."],
            sourceName: "Business.gov.nl",
            url: "https://business.gov.nl",
            institution: "Netherlands Enterprise Agency",
            risk: .medium,
            keywords: ["entrepreneur", "business", "kvk", "zzp", "self-employed", "предприниматель", "бизнес"]
        ),
        item(
            title: [.english: "ACM ConsuWijzer — Consumer Complaints", .dutch: "ACM ConsuWijzer — Consumentenklachten", .russian: "ACM ConsuWijzer — жалобы потребителей"],
            category: .legalHelp,
            short: [.english: "ConsuWijzer explains consumer rights and complaint routes.", .dutch: "ConsuWijzer legt consumentenrechten en klachtroutes uit.", .russian: "ConsuWijzer объясняет права потребителей и порядок жалоб."],
            explanation: [.english: "Use it for orientation about purchases, contracts, subscriptions, delivery problems, and unfair business practices. Keep receipts, emails, and contract details together.", .dutch: "Gebruik dit voor orientatie bij aankopen, contracten, abonnementen, leveringsproblemen en oneerlijke handelspraktijken. Bewaar bonnetjes, e-mails en contractgegevens.", .russian: "Используйте как ориентир по покупкам, договорам, подпискам, доставке и нечестной практике. Сохраняйте чеки, письма и детали договора."],
            sourceName: "ACM ConsuWijzer",
            url: "https://www.consuwijzer.nl",
            institution: "ACM",
            risk: .low,
            keywords: ["consumer rights", "consuwijzer", "complaint", "contract", "subscription", "потребитель", "жалоба"]
        ),
        item(
            title: [.english: "Emergency — 112 and Non-Urgent Help", .dutch: "Noodgeval — 112 en niet-spoed", .russian: "Экстренные случаи — 112 и не срочные обращения"],
            category: .emergency,
            short: [.english: "Use 112 only for real emergencies.", .dutch: "Gebruik 112 alleen bij echte noodgevallen.", .russian: "Номер 112 используйте только в реальной экстренной ситуации."],
            explanation: [.english: "For non-urgent police matters, use the non-emergency route. Keep key numbers saved and verify local guidance on official websites.", .dutch: "Voor niet-spoedeisende politiezaken gebruik je de niet-spoedroute. Sla belangrijke nummers op en controleer lokale richtlijnen op officiele websites.", .russian: "Для несрочных вопросов полиции используйте неэкстренный номер. Сохраните важные контакты и проверьте актуальные инструкции на официальных сайтах."],
            sourceName: "Government.nl",
            url: "https://www.government.nl/themes/justice-security-and-defence/emergency-number-112",
            institution: "Government.nl",
            risk: .urgent,
            keywords: ["112", "emergency", "экстренно", "полиция", "ambulance"]
        ),
        item(
            title: [.english: "Police.nl — Non-Urgent Reporting", .dutch: "Politie.nl — Niet-spoed melden", .russian: "Politie.nl — несрочное обращение"],
            category: .emergency,
            short: [.english: "For non-urgent police issues, use official police contact routes.", .dutch: "Gebruik officiele politiekanalen voor niet-spoedeisende situaties.", .russian: "Для несрочных вопросов используйте официальные каналы полиции."],
            explanation: [.english: "If there is immediate danger, call 112. For non-urgent reporting or questions, verify the correct route on Politie.nl and avoid sharing details through unknown contacts.", .dutch: "Bel 112 bij direct gevaar. Controleer voor niet-spoedmeldingen of vragen de juiste route op Politie.nl en deel geen gegevens via onbekende contacten.", .russian: "При непосредственной опасности звоните 112. Для несрочных заявлений или вопросов проверьте правильный путь на Politie.nl и не передавайте данные неизвестным контактам."],
            sourceName: "Politie.nl",
            url: "https://www.politie.nl/en",
            institution: "Politie",
            risk: .high,
            keywords: ["police", "non urgent", "report", "politie", "melding", "полиция", "заявление"]
        ),
        item(
            title: [.english: "DigiD Phishing and Fake Websites", .dutch: "DigiD-phishing en nepwebsites", .russian: "Фишинг DigiD и поддельные сайты"],
            category: .scams,
            short: [.english: "Scammers copy official login pages to steal account data.", .dutch: "Oplichters kopieren officiele inlogpagina's om gegevens te stelen.", .russian: "Мошенники копируют официальные страницы входа, чтобы украсть данные."],
            explanation: [.english: "Open official websites directly and avoid unknown links in messages. If credentials were shared, change passwords immediately via the official service.", .dutch: "Open officiele websites direct en vermijd onbekende links in berichten. Heb je gegevens gedeeld, wijzig wachtwoorden direct via de officiele dienst.", .russian: "Открывайте официальные сайты вручную и не переходите по сомнительным ссылкам. Если данные уже переданы, сразу смените пароль через официальный сервис."],
            sourceName: "DigiD",
            url: "https://www.digid.nl/en",
            institution: "DigiD",
            risk: .high,
            keywords: ["digid", "phishing", "фишинг", "мошенничество", "сайт"]
        ),
        item(
            title: [.english: "Housing Deposit and Rental Scams", .dutch: "Huurfraude en aanbetalingen", .russian: "Мошенничество с арендой и депозитом"],
            category: .scams,
            short: [.english: "Be careful with listings asking payment before contract or viewing.", .dutch: "Wees voorzichtig bij advertenties die betaling vragen voor contract of bezichtiging.", .russian: "Будьте осторожны, если просят оплату до договора или просмотра жилья."],
            explanation: [.english: "Suspicious offers often pressure fast payment and avoid proper paperwork. Verify owner identity and check trusted channels before transferring money.", .dutch: "Verdachte aanbiedingen zetten vaak druk op snelle betaling en vermijden correcte documenten. Verifieer de identiteit en controleer betrouwbare kanalen voor je betaalt.", .russian: "Подозрительные предложения часто торопят с оплатой и избегают нормальных документов. Перед переводом денег проверьте личность владельца и источник объявления."],
            sourceName: "Fraudehelpdesk",
            url: "https://www.fraudehelpdesk.nl",
            institution: nil,
            risk: .high,
            keywords: ["rental scam", "deposit", "аренда", "депозит", "мошенничество"]
        ),
        item(
            title: [.english: "Fake Government Messages and Spoofing", .dutch: "Valse overheidsberichten en spoofing", .russian: "Поддельные госсообщения и спуфинг"],
            category: .scams,
            short: [.english: "Fraudsters may pretend to be Belastingdienst, CJIB, or police.", .dutch: "Fraudeurs doen zich soms voor als Belastingdienst, CJIB of politie.", .russian: "Мошенники могут выдавать себя за Belastingdienst, CJIB или полицию."],
            explanation: [.english: "Do not pay quickly from unsolicited links or calls. Verify contact details via the institution's official website before you act.", .dutch: "Betaal niet direct via ongevraagde links of telefoontjes. Verifieer contactgegevens via de officiele website van de instelling.", .russian: "Не оплачивайте сразу по ссылкам из неожиданных сообщений или звонков. Сначала проверьте контакты на официальном сайте организации."],
            sourceName: "Fraudehelpdesk",
            url: "https://www.fraudehelpdesk.nl",
            institution: nil,
            risk: .high,
            keywords: ["spoofing", "fake message", "поддельное сообщение", "cjib", "belastingdienst"]
        )
    ]
}
