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
            explanation: [.english: "BRP registration is often the first formal step and may be needed for many services. Required documents and appointment steps differ by municipality, so check the official municipal website.", .dutch: "Inschrijving in de BRP is vaak een eerste formele stap en kan nodig zijn voor veel diensten. Benodigde documenten en afspraken verschillen per gemeente, dus controleer de officiële website.", .russian: "Регистрация в BRP часто является первым формальным шагом и может понадобиться для многих услуг. Требования и запись отличаются по муниципалитетам, поэтому проверьте на официальном сайте вашей gemeente."],
            sourceName: "Government.nl",
            url: "https://www.government.nl/topics/personal-data/citizen-service-number-bsn",
            institution: "Municipality",
            risk: .high,
            keywords: ["brp", "registration", "gemeente", "муниципалитет", "регистрация"]
        ),
        item(
            title: [.english: "BSN — Citizen Service Number", .dutch: "BSN — Burgerservicenummer", .russian: "BSN — личный номер в Нидерландах"],
            category: .identity,
            short: [.english: "BSN is a personal number used in many official systems.", .dutch: "BSN is een persoonlijk nummer dat in veel officiële systemen wordt gebruikt.", .russian: "BSN — личный номер, который используется во многих официальных системах."],
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
            explanation: [.english: "Use only the official DigiD website and keep credentials private. If a message asks for your password by email or SMS, verify first on the official site.", .dutch: "Gebruik alleen de officiële DigiD-website en houd je gegevens privé. Vraagt een bericht om je wachtwoord via e-mail of sms, controleer dan eerst via de officiële site.", .russian: "Используйте только официальный сайт DigiD и не передавайте данные для входа. Если в письме или SMS просят пароль, сначала проверьте информацию на официальном сайте."],
            sourceName: "DigiD",
            url: "https://www.digid.nl/en",
            institution: "DigiD",
            risk: .medium,
            keywords: ["digid", "inloggen", "вход", "фишинг", "identity"]
        ),
        item(
            title: [.english: "Privacy Rights — Personal Data", .dutch: "Privacyrechten — Persoonsgegevens", .russian: "Права на приватность — персональные данные"],
            category: .identity,
            short: [.english: "You have rights around how organizations use your personal data.", .dutch: "U heeft rechten rond hoe organisaties uw persoonsgegevens gebruiken.", .russian: "У вас есть права относительно того, как организации используют ваши персональные данные."],
            explanation: [.english: "For privacy requests, complaints, or possible misuse of personal data, collect dates, screenshots, correspondence, and organization details. Check Autoriteit Persoonsgegevens guidance before deciding the next step.", .dutch: "Bij privacyverzoeken, klachten of mogelijk misbruik van persoonsgegevens verzamelt u data, screenshots, correspondentie en organisatiegegevens. Controleer informatie van Autoriteit Persoonsgegevens voordat u een vervolgstap kiest.", .russian: "По запросам о приватности, жалобам или возможному неправильному использованию данных сохраните даты, скриншоты, переписку и данные организации. Перед следующим шагом проверьте информацию Autoriteit Persoonsgegevens."],
            sourceName: "Autoriteit Persoonsgegevens",
            url: "https://www.autoriteitpersoonsgegevens.nl/en",
            institution: "Autoriteit Persoonsgegevens",
            risk: .medium,
            keywords: ["privacy", "personal data", "gdpr", "autoriteit persoonsgegevens", "data breach", "персональные данные"]
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
            explanation: [.english: "The process includes formal interviews and decisions. Timelines and support differ by case, so verify details with official channels.", .dutch: "Het proces bevat formele gesprekken en besluiten. Termijnen en ondersteuning verschillen per dossier, controleer details via officiële kanalen.", .russian: "Процесс включает официальные интервью и решения. Сроки и поддержка зависят от дела, поэтому проверяйте детали в официальных источниках."],
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
            explanation: [.english: "Amounts can change and may depend on age groups. Check current values on official government pages before making decisions.", .dutch: "Bedragen kunnen wijzigen en kunnen per leeftijd verschillen. Controleer actuele waarden op officiële overheidspagina's.", .russian: "Суммы могут меняться и зависеть от возраста. Перед действиями проверьте актуальные значения на официальном сайте."],
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
            explanation: [.english: "Keep payslips for annual tax and income records. If numbers look unclear, ask your employer and verify with official tax information.", .dutch: "Bewaar loonstroken voor je jaarlijkse belasting- en inkomensgegevens. Bij onduidelijkheden vraag je werkgever en controleer officiële belastinginformatie.", .russian: "Сохраняйте loonstrook для налоговой отчетности и подтверждения дохода. Если данные непонятны, уточните у работодателя и проверьте информацию на официальном сайте."],
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
            title: [.english: "Mijn Belastingdienst — Online Tax Portal", .dutch: "Mijn Belastingdienst — Online belastingportaal", .russian: "Mijn Belastingdienst — налоговый онлайн-кабинет"],
            category: .tax,
            short: [.english: "Use the official tax portal for returns, assessments, and tax messages.", .dutch: "Gebruik het officiële belastingportaal voor aangiften, aanslagen en belastingberichten.", .russian: "Используйте официальный налоговый кабинет для деклараций, начислений и сообщений."],
            explanation: [.english: "Before filing, paying, or responding, compare deadlines and reference numbers with official Belastingdienst letters or portal messages. Avoid acting through unknown payment links.", .dutch: "Vergelijk voor indienen, betalen of reageren deadlines en referentienummers met officiële brieven of portaalberichten van Belastingdienst. Handel niet via onbekende betaallinks.", .russian: "Перед подачей, оплатой или ответом сверяйте сроки и номера с официальными письмами или сообщениями Belastingdienst. Не действуйте через неизвестные платежные ссылки."],
            sourceName: "Belastingdienst",
            url: "https://www.belastingdienst.nl",
            institution: "Belastingdienst",
            risk: .high,
            keywords: ["mijn belastingdienst", "tax portal", "aangifte", "assessment", "налоговый кабинет", "декларация"]
        ),
        item(
            title: [.english: "Income Tax Basics (Box 1)", .dutch: "Inkomstenbelasting basis (Box 1)", .russian: "Подоходный налог: Box 1"],
            category: .tax,
            short: [.english: "Work and primary home income is usually in Box 1.", .dutch: "Inkomen uit werk en hoofdwoning valt meestal in Box 1.", .russian: "Доход от работы и основного жилья обычно относится к Box 1."],
            explanation: [.english: "Rates and thresholds can change over time. Verify current percentages and rules on official Belastingdienst pages.", .dutch: "Tarieven en grenzen kunnen in de tijd veranderen. Controleer actuele percentages en regels op officiële Belastingdienst-pagina's.", .russian: "Ставки и пороги могут меняться. Проверьте актуальные правила и проценты на официальном сайте Belastingdienst."],
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
            title: [.english: "Toeslagen — Reporting Changes", .dutch: "Toeslagen — Wijzigingen doorgeven", .russian: "Toeslagen — сообщение об изменениях"],
            category: .benefits,
            short: [.english: "Changes in income, rent, childcare, or household can affect allowances.", .dutch: "Wijzigingen in inkomen, huur, kinderopvang of huishouden kunnen toeslagen beinvloeden.", .russian: "Изменения дохода, аренды, childcare или состава семьи могут повлиять на пособия."],
            explanation: [.english: "Report changes promptly through official Toeslagen channels. If too much allowance is paid, you may need to repay it, so keep income and household details current.", .dutch: "Geef wijzigingen snel door via officiële Toeslagen-kanalen. Te veel ontvangen toeslag moet mogelijk worden terugbetaald, dus houd inkomen en huishoudgegevens actueel.", .russian: "Сообщайте изменения через официальные каналы Toeslagen. Если пособие переплачено, его могут потребовать вернуть, поэтому поддерживайте данные о доходе и семье актуальными."],
            sourceName: "Dienst Toeslagen",
            url: "https://www.toeslagen.nl",
            institution: "Dienst Toeslagen",
            risk: .high,
            keywords: ["toeslagen", "changes", "income", "repayment", "allowance", "пособия", "переплата"]
        ),
        item(
            title: [.english: "Childcare Benefit — Kinderopvangtoeslag", .dutch: "Kinderopvangtoeslag", .russian: "Kinderopvangtoeslag — пособие на childcare"],
            category: .benefits,
            short: [.english: "Childcare benefit may help eligible parents with registered childcare costs.", .dutch: "Kinderopvangtoeslag kan ouders helpen met kosten van geregistreerde kinderopvang.", .russian: "Kinderopvangtoeslag может помочь родителям с оплатой зарегистрированного childcare."],
            explanation: [.english: "Eligibility and amounts depend on childcare type, hours, income, household details, and work or study situation. Report changes quickly because overpaid benefit usually has to be repaid.", .dutch: "Recht en bedragen hangen af van opvangsoort, uren, inkomen, huishouden en werk- of studiesituatie. Geef wijzigingen snel door, want te veel ontvangen toeslag moet meestal worden terugbetaald.", .russian: "Право и сумма зависят от типа childcare, часов, дохода, семьи и ситуации с работой или учебой. Сообщайте изменения быстро: переплату обычно нужно вернуть."],
            sourceName: "Government.nl",
            url: "https://www.government.nl/topics/childcare/childcare-benefit",
            institution: "Dienst Toeslagen",
            risk: .high,
            keywords: ["kinderopvangtoeslag", "childcare benefit", "childcare", "toeslagen", "family", "детский сад", "пособие"]
        ),
        item(
            title: [.english: "Housing Allowance (Huurtoeslag)", .dutch: "Huurtoeslag", .russian: "Huurtoeslag — пособие на аренду"],
            category: .benefits,
            short: [.english: "Eligible renters may receive support for rent costs.", .dutch: "Huurders die voldoen aan voorwaarden kunnen huurtoeslag krijgen.", .russian: "При выполнении условий арендаторы могут получать поддержку по аренде."],
            explanation: [.english: "Conditions include income and rent limits and can change. Verify current thresholds and report changes through official portals.", .dutch: "Voorwaarden bevatten inkomens- en huurgrenzen en kunnen veranderen. Controleer actuele grenzen en meld wijzigingen via officiële portalen.", .russian: "Условия включают лимиты по доходу и аренде и могут меняться. Проверьте актуальные пороги и сообщайте изменения через официальный портал."],
            sourceName: "Belastingdienst Toeslagen",
            url: "https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/privé/toeslagen/huurtoeslag/",
            institution: "Belastingdienst",
            risk: .medium,
            keywords: ["huurtoeslag", "аренда", "пособие", "toeslagen", "жилье"]
        ),
        item(
            title: [.english: "Health Allowance (Zorgtoeslag)", .dutch: "Zorgtoeslag", .russian: "Zorgtoeslag — пособие на медстраховку"],
            category: .benefits,
            short: [.english: "Eligible residents may get support for insurance premiums.", .dutch: "Inwoners die voldoen aan voorwaarden kunnen steun voor zorgpremie krijgen.", .russian: "При выполнении условий можно получить помощь с оплатой страховки."],
            explanation: [.english: "Amounts depend on current income and other factors. Update your details if income changes and verify current rules on official pages.", .dutch: "Bedragen hangen af van actueel inkomen en andere factoren. Werk je gegevens bij bij inkomenswijziging en controleer officiële regels.", .russian: "Размер зависит от текущего дохода и других факторов. При изменении дохода обновите данные и проверьте правила на официальном сайте."],
            sourceName: "Belastingdienst Toeslagen",
            url: "https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/privé/toeslagen/zorgtoeslag/",
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
            explanation: [.english: "The deductible amount can change each year and some care is excluded. Verify current amount and exceptions in official sources.", .dutch: "Het bedrag kan jaarlijks wijzigen en sommige zorg valt erbuiten. Controleer actueel bedrag en uitzonderingen bij officiële bronnen.", .russian: "Размер франшизы может меняться каждый год, а часть услуг не входит в нее. Проверьте актуальную сумму и исключения в официальных источниках."],
            sourceName: "Zorginstituut Nederland",
            url: "https://www.zorginstituutnederland.nl",
            institution: "Zorginstituut Nederland",
            risk: .low,
            keywords: ["eigen risico", "франшиза", "страховка", "zorgverzekering", "медицина"]
        ),
        item(
            title: [.english: "Thuisarts.nl — GP Health Information", .dutch: "Thuisarts.nl — Huisartsinformatie", .russian: "Thuisarts.nl — медицинская информация от huisarts"],
            category: .healthcare,
            short: [.english: "Thuisarts explains symptoms, self-care, and GP contact in plain Dutch.", .dutch: "Thuisarts legt klachten, zelfzorg en huisartscontact begrijpelijk uit.", .russian: "Thuisarts простым языком объясняет симптомы, самопомощь и обращение к huisarts."],
            explanation: [.english: "Use it as orientation before a non-urgent GP question, but do not delay urgent care. For severe or sudden symptoms, contact your GP, huisartsenpost, or 112 as appropriate.", .dutch: "Gebruik dit als oriëntatie voor niet-spoedvragen aan de huisarts, maar stel urgente zorg niet uit. Bij ernstige of plotselinge klachten neem contact op met huisarts, huisartsenpost of 112.", .russian: "Используйте как ориентир для несрочных вопросов к врачу, но не откладывайте срочную помощь. При тяжелых или внезапных симптомах обращайтесь к huisarts, huisartsenpost или 112."],
            sourceName: "Thuisarts.nl",
            url: "https://www.thuisarts.nl",
            institution: "Nederlands Huisartsen Genootschap",
            risk: .high,
            keywords: ["thuisarts", "huisarts", "gp", "symptoms", "health", "doctor", "врач", "симптомы"]
        ),
        item(
            title: [.english: "BIG-register — Checking Healthcare Professionals", .dutch: "BIG-register — Zorgverleners controleren", .russian: "BIG-register — проверка медицинских специалистов"],
            category: .healthcare,
            short: [.english: "The BIG-register lets you check regulated healthcare professionals.", .dutch: "In het BIG-register controleer je gereguleerde zorgverleners.", .russian: "BIG-register позволяет проверить регулируемых медицинских специалистов."],
            explanation: [.english: "If you want to verify a doctor, nurse, pharmacist, or other regulated provider, search the official BIG-register and compare names carefully. Use official contact routes if a result is unclear.", .dutch: "Wilt u arts, verpleegkundige, apotheker of andere gereguleerde zorgverlener controleren, zoek in het officiële BIG-register en vergelijk namen zorgvuldig. Gebruik officiële contactroutes bij onduidelijkheid.", .russian: "Если нужно проверить врача, медсестру, фармацевта или другого регулируемого специалиста, ищите в официальном BIG-register и внимательно сравнивайте имя. При неясности используйте официальные контакты."],
            sourceName: "BIG-register",
            url: "https://english.bigregister.nl",
            institution: "CIBG",
            risk: .medium,
            keywords: ["big register", "doctor", "healthcare professional", "registered", "zorgverlener", "врач", "реестр"]
        ),
        item(
            title: [.english: "Mental Health Crisis — 113 and 112", .dutch: "Mentale crisis — 113 en 112", .russian: "Психологический кризис — 113 и 112"],
            category: .healthcare,
            short: [.english: "Use 112 for immediate danger and 113 for suicide-prevention support.", .dutch: "Gebruik 112 bij direct gevaar en 113 voor suïcidepreventie.", .russian: "При непосредственной опасности звоните 112; для поддержки при суицидальных мыслях используйте 113."],
            explanation: [.english: "This app is not a crisis service. If someone may be in immediate danger, call 112. If there are suicidal thoughts or worries about someone else, use 113's phone or chat support and follow their guidance.", .dutch: "Deze app is geen crisisdienst. Is er mogelijk direct gevaar, bel 112. Bij suicidale gedachten of zorgen om iemand anders gebruikt u de telefoon- of chatsteun van 113 en volgt u hun advies.", .russian: "Это приложение не является кризисной службой. Если есть непосредственная опасность, звоните 112. При суицидальных мыслях или тревоге за другого человека используйте телефон или чат 113 и следуйте их советам."],
            sourceName: "113 Zelfmoordpreventie",
            url: "https://www.113.nl/english",
            institution: "113 Zelfmoordpreventie",
            risk: .urgent,
            keywords: ["113", "suicide", "suicidal thoughts", "mental crisis", "zelfmoordpreventie", "112", "кризис", "суицид"]
        ),
        item(
            title: [.english: "Private Rental Rights Overview", .dutch: "Overzicht rechten bij particuliere huur", .russian: "Аренда у частного арендодателя: базовый обзор"],
            category: .housing,
            short: [.english: "Rental agreements include rights and obligations for both sides.", .dutch: "Huurovereenkomsten bevatten rechten en plichten voor beide partijen.", .russian: "Договор аренды содержит обязанности и условия для обеих сторон."],
            explanation: [.english: "Read notice period, rent increase terms, and extra costs before signing. If terms are unclear, check official housing guidance and legal help channels.", .dutch: "Lees opzegtermijn, huurverhoging en bijkomende kosten goed voor je tekent. Bij onduidelijkheid controleer officiële wooninformatie en rechtshulpkanalen.", .russian: "Перед подписанием проверьте срок уведомления, условия повышения аренды и дополнительные платежи. Если не уверены, проверьте официальные разъяснения и обратитесь за юридической помощью."],
            sourceName: "Government.nl",
            url: "https://www.government.nl/themes/building-and-housing/housing",
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
            url: "https://www.government.nl/themes/building-and-housing/housing",
            institution: "Municipality / Woningcorporatie",
            risk: .medium,
            keywords: ["wachtlijst", "social housing", "социальное жилье", "аренда", "жилье"]
        ),
        item(
            title: [.english: "Huurcommissie — Rental Disputes and Rent Checks", .dutch: "Huurcommissie — Huurgeschillen en huurcontrole", .russian: "Huurcommissie — споры и проверка аренды"],
            category: .housing,
            short: [.english: "Huurcommissie can help orient rental disputes and rent checks.", .dutch: "Huurcommissie helpt bij oriëntatie rond huurgeschillen en huurcontrole.", .russian: "Huurcommissie помогает с ориентацией по спорам аренды и проверке платежей."],
            explanation: [.english: "If your issue concerns rent level, service costs, maintenance, or a tenant-landlord dispute, check whether Huurcommissie is the correct route and gather your contract, payment proof, service-cost statements, and messages.", .dutch: "Gaat het om huurprijs, servicekosten, onderhoud of een geschil tussen huurder en verhuurder, controleer of Huurcommissie de juiste route is en verzamel contract, betalingsbewijzen, servicekostenoverzichten en berichten.", .russian: "Если вопрос связан с размером аренды, servicekosten, обслуживанием или спором с арендодателем, проверьте, подходит ли Huurcommissie, и соберите договор, платежи, отчеты по расходам и переписку."],
            sourceName: "Huurcommissie",
            url: "https://www.huurcommissie.nl",
            institution: "Huurcommissie",
            risk: .medium,
            keywords: ["huurcommissie", "rent dispute", "service costs", "huurprijs", "landlord", "аренда", "спор"]
        ),
        item(
            title: [.english: "OV-chipkaart — Public Transport Card", .dutch: "OV-chipkaart", .russian: "OV-chipkaart — карта для общественного транспорта"],
            category: .transport,
            short: [.english: "You usually check in and out for public transport rides.", .dutch: "Bij openbaar vervoer check je meestal in en uit.", .russian: "В общественном транспорте обычно нужно отмечаться при входе и при выходе."],
            explanation: [.english: "Missing check-out can lead to correction charges. Check official transport provider rules for balance, refunds, and travel products.", .dutch: "Niet uitchecken kan leiden tot correctiekosten. Controleer officiële regels van vervoerders voor saldo, restitutie en reisproducten.", .russian: "Если не отметить выход, может появиться корректирующее списание. Проверьте официальные правила перевозчика по балансу и возвратам."],
            sourceName: "OV-chipkaart",
            url: "https://www.ov-chipkaart.nl/en",
            institution: "NS / Transport providers",
            risk: .low,
            keywords: ["ov-chipkaart", "транспорт", "check in", "check out", "поезд"]
        ),
        item(
            title: [.english: "OVpay — Contactless Check-in and Check-out", .dutch: "OVpay — Contactloos in- en uitchecken", .russian: "OVpay — бесконтактный check-in/check-out"],
            category: .transport,
            short: [.english: "OVpay lets travellers check in and out with a payment card or mobile wallet.", .dutch: "Met OVpay kunnen reizigers in- en uitchecken met betaalpas of mobiele wallet.", .russian: "OVpay позволяет отмечаться в транспорте банковской картой или мобильным кошельком."],
            explanation: [.english: "Use the same card or device for check-in and check-out, and verify travel corrections or missing check-outs through official OVpay information before disputing a charge.", .dutch: "Gebruik dezelfde kaart of hetzelfde apparaat voor in- en uitchecken en controleer correcties of gemiste uitchecks via officiële OVpay-informatie voordat u een bedrag betwist.", .russian: "Используйте одну и ту же карту или устройство для входа и выхода. Перед спором по списанию проверьте корректировки или пропущенный check-out через официальный OVpay."],
            sourceName: "OVpay",
            url: "https://www.ovpay.nl/en",
            institution: "OVpay",
            risk: .low,
            keywords: ["ovpay", "contactless", "check in", "check out", "debit card", "public transport", "транспорт", "карта"]
        ),
        item(
            title: [.english: "9292 — Public Transport Planning", .dutch: "9292 — OV-routeplanning", .russian: "9292 — планирование общественного транспорта"],
            category: .transport,
            short: [.english: "9292 helps plan routes across Dutch transport operators.", .dutch: "9292 helpt routes plannen tussen Nederlandse vervoerders.", .russian: "9292 помогает планировать маршруты у разных перевозчиков Нидерландов."],
            explanation: [.english: "Use journey planners shortly before departure because disruptions, platforms, and transfers can change. For operator-specific compensation or ticket questions, verify with the relevant provider.", .dutch: "Gebruik routeplanners kort voor vertrek, want storingen, perrons en overstappen kunnen wijzigen. Voor compensatie of ticketvragen controleert u de betreffende vervoerder.", .russian: "Проверяйте маршрут незадолго до выезда: сбои, платформы и пересадки могут измениться. По компенсации или билетам сверяйтесь с конкретным перевозчиком."],
            sourceName: "9292",
            url: "https://9292.nl/en",
            institution: "9292",
            risk: .low,
            keywords: ["9292", "journey planner", "public transport", "disruption", "route", "train", "bus", "tram", "маршрут"]
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
            explanation: [.english: "Eligibility depends on study type, status, and other conditions. Verify current rules, obligations, and repayment details on official DUO pages.", .dutch: "Recht hangt af van opleiding, status en andere voorwaarden. Controleer actuele regels, verplichtingen en terugbetaling op officiële DUO-pagina's.", .russian: "Право зависит от программы обучения, статуса и других условий. Проверьте актуальные правила, обязательства и порядок возврата на официальном сайте DUO."],
            sourceName: "DUO",
            url: "https://duo.nl/particulier/student-finance.jsp",
            institution: "DUO",
            risk: .medium,
            keywords: ["duo", "studiefinanciering", "учеба", "студент", "loan"]
        ),
        item(
            title: [.english: "Studielink — Higher Education Enrolment", .dutch: "Studielink — Inschrijving hoger onderwijs", .russian: "Studielink — поступление в высшее образование"],
            category: .education,
            short: [.english: "Studielink is used for many higher education applications and enrolments.", .dutch: "Studielink wordt gebruikt voor veel aanmeldingen en inschrijvingen in het hoger onderwijs.", .russian: "Studielink используется для многих заявок и зачислений в высшее образование."],
            explanation: [.english: "Programme deadlines and required steps can differ by institution, programme, nationality, and start date. Check Studielink together with the university or university of applied sciences before submitting.", .dutch: "Deadlines en stappen kunnen verschillen per instelling, opleiding, nationaliteit en startdatum. Controleer Studielink samen met de hogeschool of universiteit voordat u indient.", .russian: "Сроки и шаги могут отличаться по вузу, программе, гражданству и дате начала. Перед подачей сверяйте Studielink с университетом или hogeschool."],
            sourceName: "Studielink",
            url: "https://www.studielink.nl",
            institution: "Studielink",
            risk: .medium,
            keywords: ["studielink", "higher education", "enrolment", "university", "student", "application", "зачисление"]
        ),
        item(
            title: [.english: "IDW — Foreign Diploma Evaluation", .dutch: "IDW — Diplomawaardering", .russian: "IDW — оценка иностранного диплома"],
            category: .education,
            short: [.english: "IDW explains international credential evaluation for foreign diplomas.", .dutch: "IDW legt internationale diplomawaardering voor buitenlandse diploma's uit.", .russian: "IDW объясняет оценку иностранных дипломов для Нидерландов."],
            explanation: [.english: "A diploma evaluation may be requested for work, study, or official procedures. First check whether the employer, institution, or authority requires it, then keep diplomas, transcripts, translations, and identity documents ready.", .dutch: "Een diplomawaardering kan nodig zijn voor werk, studie of officiële procedures. Controleer eerst of werkgever, instelling of instantie dit vereist en houd diploma's, cijferlijsten, vertalingen en identiteitsdocumenten klaar.", .russian: "Оценка диплома может понадобиться для работы, учебы или официальных процедур. Сначала проверьте, требует ли ее работодатель, вуз или орган, и подготовьте дипломы, приложения, переводы и документы личности."],
            sourceName: "IDW",
            url: "https://www.idw.nl/en",
            institution: "IDW / Nuffic / SBB",
            risk: .medium,
            keywords: ["idw", "diploma evaluation", "foreign diploma", "credential evaluation", "nuffic", "sbb", "диплом"]
        ),
        item(
            title: [.english: "Compulsory Education — Leerplicht", .dutch: "Leerplicht", .russian: "Leerplicht — обязательное школьное обучение"],
            category: .education,
            short: [.english: "Children must follow Dutch school attendance rules unless an official exception applies.", .dutch: "Kinderen moeten de Nederlandse leerplichtregels volgen, behalve bij officiële uitzonderingen.", .russian: "Дети должны соблюдать правила обязательного обучения, если нет официального исключения."],
            explanation: [.english: "School attendance, absence reporting, exemptions, and qualification-duty questions can involve the school and municipality. If a child cannot attend or is moving schools, verify the correct route with official local instructions.", .dutch: "Schoolbezoek, ziekmelding, vrijstellingen en kwalificatieplicht kunnen school en gemeente raken. Kan een kind niet naar school of wisselt het van school, controleer de juiste route via officiële lokale instructies.", .russian: "Посещение школы, отсутствие, исключения и квалификационная обязанность могут касаться школы и gemeente. Если ребенок не может посещать школу или меняет школу, проверьте правильный порядок в официальных местных инструкциях."],
            sourceName: "Rijksoverheid",
            url: "https://www.rijksoverheid.nl/onderwerpen/leerplicht",
            institution: "Municipality / School",
            risk: .medium,
            keywords: ["leerplicht", "compulsory education", "school attendance", "school", "municipality", "children", "школа", "дети"]
        ),
        item(
            title: [.english: "Traffic Fine Process (Wahv)", .dutch: "Verkeersboeteproces (Wahv)", .russian: "Дорожные штрафы (Wahv)"],
            category: .fines,
            short: [.english: "Many traffic fines are processed through CJIB.", .dutch: "Veel verkeersboetes worden via CJIB verwerkt.", .russian: "Многие дорожные штрафы обрабатываются через CJIB."],
            explanation: [.english: "Check deadline, payment reference, and official sender details before paying. If you disagree, verify the official bezwaar or beroep route and do not miss deadlines.", .dutch: "Controleer deadline, betalingskenmerk en officiële afzendergegevens voor je betaalt. Ben je het niet eens, controleer de officiële bezwaar- of beroepsroute en mis geen termijnen.", .russian: "Сначала проверьте срок, номер платежа и официальный источник письма. Если вы не согласны, проверьте официальный порядок bezwaar или beroep и не пропускайте сроки."],
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
            explanation: [.english: "Court procedures differ by case type and strict deadlines often apply. If you receive official court documents, check the deadline and seek legal help quickly.", .dutch: "Procedures verschillen per zaaktype en strikte termijnen gelden vaak. Ontvang je officiële rechtbankdocumenten, controleer de deadline en zoek snel rechtshulp.", .russian: "Процедуры зависят от типа дела, и сроки часто строгие. Если получили официальные документы из суда, сразу проверьте дедлайн и при необходимости обратитесь за юридической помощью."],
            sourceName: "Rechtspraak.nl",
            url: "https://www.rechtspraak.nl/English",
            institution: "Rechtspraak.nl",
            risk: .high,
            keywords: ["rechtbank", "court", "суд", "дедлайн", "rechtspraak"]
        ),
        item(
            title: [.english: "Victim Support — After Crime or Serious Incidents", .dutch: "Slachtofferhulp — Na misdrijf of ernstig incident", .russian: "Помощь пострадавшим — после преступления или серьёзного инцидента"],
            category: .legalHelp,
            short: [.english: "Victim support can help after crime, violence, accidents, or serious incidents.", .dutch: "Slachtofferhulp kan helpen na misdrijf, geweld, ongevallen of ernstige incidenten.", .russian: "Slachtofferhulp может помочь после преступления, насилия, аварии или серьёзного инцидента."],
            explanation: [.english: "If danger is happening now, call 112. For follow-up support, Slachtofferhulp Nederland can provide emotional, practical, compensation-related, and criminal-procedure orientation. Keep reports, letters, photos, and case references together.", .dutch: "Bij direct gevaar belt u 112. Voor vervolghulp kan Slachtofferhulp Nederland emotionele, praktische, schadevergoedings- en strafprocesgerichte ondersteuning bieden. Bewaar meldingen, brieven, foto's en zaaknummers bij elkaar.", .russian: "Если опасность происходит сейчас, звоните 112. Для дальнейшей помощи Slachtofferhulp Nederland может дать эмоциональную, практическую поддержку, ориентацию по компенсации и уголовному процессу. Сохраняйте заявления, письма, фото и номера дела."],
            sourceName: "Slachtofferhulp Nederland",
            url: "https://www.slachtofferhulp.nl/english",
            institution: "Slachtofferhulp Nederland",
            risk: .high,
            keywords: ["victim support", "slachtofferhulp", "crime", "violence", "accident", "compensation", "пострадавший", "насилие"]
        ),
        item(
            title: [.english: "Discrimination — Reporting and Support", .dutch: "Discriminatie — Melden en ondersteuning", .russian: "Дискриминация — сообщение и поддержка"],
            category: .legalHelp,
            short: [.english: "Discrimination can be reported for orientation and support.", .dutch: "Discriminatie kan worden gemeld voor oriëntatie en ondersteuning.", .russian: "О дискриминации можно сообщить для ориентации и поддержки."],
            explanation: [.english: "If you experience or witness discrimination, write down dates, places, what happened, messages, screenshots, and witness details. Use a reporting route such as Discriminatie.nl for next-step orientation; call 112 if there is immediate danger.", .dutch: "Ervaart of ziet u discriminatie, noteer data, plaatsen, wat er gebeurde, berichten, screenshots en getuigen. Gebruik een meldroute zoals Discriminatie.nl voor vervolgstappen; bel 112 bij direct gevaar.", .russian: "Если вы столкнулись с дискриминацией или стали свидетелем, запишите даты, место, что произошло, сообщения, скриншоты и свидетелей. Используйте Discriminatie.nl для ориентации по следующим шагам; при немедленной опасности звоните 112."],
            sourceName: "Discriminatie.nl",
            url: "https://discriminatie.nl",
            institution: "Discriminatie.nl",
            risk: .high,
            keywords: ["discrimination", "discriminatie", "racism", "religion", "gender", "sexuality", "disability", "дискриминация"]
        ),
        item(
            title: [.english: "Netherlands Labour Authority — Work Rights", .dutch: "Nederlandse Arbeidsinspectie — Werkrechten", .russian: "Нидерландская инспекция труда — права на работе"],
            category: .work,
            short: [.english: "Use the Labour Authority for work-safety and fair-work information.", .dutch: "Gebruik de Arbeidsinspectie voor informatie over veilig en eerlijk werk.", .russian: "Инспекция труда помогает ориентироваться в вопросах безопасной и честной работы."],
            explanation: [.english: "If a workplace situation involves unsafe conditions, underpayment concerns, or exploitation signals, collect documents and verify the official reporting or information route before acting.", .dutch: "Gaat het om onveilige omstandigheden, mogelijke onderbetaling of signalen van uitbuiting, verzamel documenten en controleer de officiële meld- of informatieroute voordat je handelt.", .russian: "Если есть небезопасные условия, подозрение на недоплату или признаки эксплуатации, сохраните документы и проверьте официальный путь обращения перед действиями."],
            sourceName: "Netherlands Labour Authority",
            url: "https://www.nllabourauthority.nl",
            institution: "Netherlands Labour Authority",
            risk: .high,
            keywords: ["labour authority", "arbeidsinspectie", "work rights", "underpayment", "exploitation", "работа", "недоплата"]
        ),
        item(
            title: [.english: "Business.gov.nl — Starting as an Entrepreneur", .dutch: "Business.gov.nl — Starten als ondernemer", .russian: "Business.gov.nl — начало предпринимательства"],
            category: .work,
            short: [.english: "Business.gov.nl explains official steps for entrepreneurs in English.", .dutch: "Business.gov.nl legt officiële stappen voor ondernemers in het Engels uit.", .russian: "Business.gov.nl объясняет официальные шаги для предпринимателей на английском."],
            explanation: [.english: "Before registering or signing contracts, verify business form, tax, permit, insurance, and administration requirements through official entrepreneur guidance.", .dutch: "Controleer voor inschrijving of contracten eerst rechtsvorm, belasting, vergunningen, verzekeringen en administratie via officiële ondernemersinformatie.", .russian: "Перед регистрацией или договорами проверьте форму бизнеса, налоги, разрешения, страховки и административные обязанности через официальный справочник для предпринимателей."],
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
            explanation: [.english: "Use it for orientation about purchases, contracts, subscriptions, delivery problems, and unfair business practices. Keep receipts, emails, and contract details together.", .dutch: "Gebruik dit voor oriëntatie bij aankopen, contracten, abonnementen, leveringsproblemen en oneerlijke handelspraktijken. Bewaar bonnetjes, e-mails en contractgegevens.", .russian: "Используйте как ориентир по покупкам, договорам, подпискам, доставке и нечестной практике. Сохраняйте чеки, письма и детали договора."],
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
            explanation: [.english: "For non-urgent police matters, use the non-emergency route. Keep key numbers saved and verify local guidance on official websites.", .dutch: "Voor niet-spoedeisende politiezaken gebruik je de niet-spoedroute. Sla belangrijke nummers op en controleer lokale richtlijnen op officiële websites.", .russian: "Для несрочных вопросов полиции используйте неэкстренный номер. Сохраните важные контакты и проверьте актуальные инструкции на официальных сайтах."],
            sourceName: "Government.nl",
            url: "https://www.government.nl/themes/justice-security-and-defence/emergency-number-112",
            institution: "Government.nl",
            risk: .urgent,
            keywords: ["112", "emergency", "экстренно", "полиция", "ambulance"]
        ),
        item(
            title: [.english: "Police.nl — Non-Urgent Reporting", .dutch: "Politie.nl — Niet-spoed melden", .russian: "Politie.nl — несрочное обращение"],
            category: .emergency,
            short: [.english: "For non-urgent police issues, use official police contact routes.", .dutch: "Gebruik officiële politiekanalen voor niet-spoedeisende situaties.", .russian: "Для несрочных вопросов используйте официальные каналы полиции."],
            explanation: [.english: "If there is immediate danger, call 112. For non-urgent reporting or questions, verify the correct route on Politie.nl and avoid sharing details through unknown contacts.", .dutch: "Bel 112 bij direct gevaar. Controleer voor niet-spoedmeldingen of vragen de juiste route op Politie.nl en deel geen gegevens via onbekende contacten.", .russian: "При непосредственной опасности звоните 112. Для несрочных заявлений или вопросов проверьте правильный путь на Politie.nl и не передавайте данные неизвестным контактам."],
            sourceName: "Politie.nl",
            url: "https://www.politie.nl/en",
            institution: "Politie",
            risk: .high,
            keywords: ["police", "non urgent", "report", "politie", "melding", "полиция", "заявление"]
        ),
        item(
            title: [.english: "MijnOverheid Berichtenbox — Official Digital Mail", .dutch: "MijnOverheid Berichtenbox — Officiële digitale post", .russian: "MijnOverheid Berichtenbox — официальная цифровая почта"],
            category: .identity,
            short: [.english: "Some government organizations send digital mail through Berichtenbox.", .dutch: "Sommige overheidsorganisaties sturen digitale post via de Berichtenbox.", .russian: "Некоторые государственные организации отправляют цифровые письма через Berichtenbox."],
            explanation: [.english: "Check MijnOverheid regularly, read sender and deadline details carefully, and avoid acting through unknown SMS or email links. For personal cases, verify the message inside official portals.", .dutch: "Controleer MijnOverheid regelmatig, lees afzender en deadlines goed en handel niet via onbekende links in sms of e-mail. Controleer persoonlijke zaken in officiële portalen.", .russian: "Регулярно проверяйте MijnOverheid, внимательно смотрите отправителя и сроки и не действуйте через неизвестные ссылки из SMS или email. Личные вопросы проверяйте в официальных кабинетах."],
            sourceName: "MijnOverheid",
            url: "https://mijn.overheid.nl",
            institution: "MijnOverheid",
            risk: .high,
            keywords: ["mijnoverheid", "berichtenbox", "official letters", "digital mail", "digid", "письма", "кабинет"]
        ),
        item(
            title: [.english: "DigiD Phishing and Fake Websites", .dutch: "DigiD-phishing en nepwebsites", .russian: "Фишинг DigiD и поддельные сайты"],
            category: .scams,
            short: [.english: "Scammers copy official login pages to steal account data.", .dutch: "Oplichters kopieren officiële inlogpagina's om gegevens te stelen.", .russian: "Мошенники копируют официальные страницы входа, чтобы украсть данные."],
            explanation: [.english: "Open official websites directly and avoid unknown links in messages. If credentials were shared, change passwords immediately via the official service.", .dutch: "Open officiële websites direct en vermijd onbekende links in berichten. Heb je gegevens gedeeld, wijzig wachtwoorden direct via de officiële dienst.", .russian: "Открывайте официальные сайты вручную и не переходите по сомнительным ссылкам. Если данные уже переданы, сразу смените пароль через официальный сервис."],
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
            explanation: [.english: "Do not pay quickly from unsolicited links or calls. Verify contact details via the institution's official website before you act.", .dutch: "Betaal niet direct via ongevraagde links of telefoontjes. Verifieer contactgegevens via de officiële website van de instelling.", .russian: "Не оплачивайте сразу по ссылкам из неожиданных сообщений или звонков. Сначала проверьте контакты на официальном сайте организации."],
            sourceName: "Fraudehelpdesk",
            url: "https://www.fraudehelpdesk.nl",
            institution: nil,
            risk: .high,
            keywords: ["spoofing", "fake message", "поддельное сообщение", "cjib", "belastingdienst"]
        )
    ]
}
