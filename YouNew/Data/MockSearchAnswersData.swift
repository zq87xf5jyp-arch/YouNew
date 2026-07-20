import Foundation

enum MockSearchAnswersData {
    private static let defaultSafety = "This is general information only. For personal decisions, verify with the official institution or a qualified advisor."
    private static let fallbackSourceURL = AppURL.make("https://www.government.nl")

    private static func item(
        question: String,
        keywords: [String],
        category: SearchCategory,
        shortAnswer: String,
        detailedAnswer: String,
        institution: String?,
        sourceName: String,
        url: String,
        isOfficial: Bool = true,
        safetyNote: String? = nil,
        relatedQuestions: [String]
    ) -> SearchAnswer {
        let parsedURL = AppURL.validatedWebURL(URL(string: url)) ?? fallbackSourceURL

        return SearchAnswer(
            id: SearchAnswer.stableID("search-answer:\(question)"),
            question: question,
            keywords: keywords,
            category: category,
            shortAnswer: shortAnswer,
            detailedAnswer: detailedAnswer,
            relatedInstitution: institution,
            officialSourceName: sourceName,
            officialSourceURL: parsedURL,
            isOfficialSource: isOfficial,
            safetyNote: safetyNote ?? (category.needsSafetyNote ? defaultSafety : nil),
            lastUpdated: Date(timeIntervalSince1970: 1716163200),
            relatedQuestions: relatedQuestions,
            relatedInstitutionNames: institution.map { [$0] } ?? [],
            nextRecommendedStep: defaultNextStep(for: category)
        )
    }

    private static func defaultNextStep(for category: SearchCategory) -> String {
        switch category {
        case .registration, .digid, .healthInsurance, .work, .taxes, .housing, .education, .transport:
            return "Go to Checklist and complete the most relevant step."
        case .fines:
            return "Open Fines & Penalties and verify official payment or objection flow."
        case .legalHelp:
            return "Open Letters and prepare document references before asking legal help."
        case .immigration:
            return "Open Institutions and verify your IND path."
        case .emergency:
            return "Save emergency numbers and verify local emergency guidance."
        case .general:
            return "Open official source and verify current rules for your city and profile."
        }
    }

    static let items: [SearchAnswer] = coreItems + knmAnswers + dutchCourseAnswers + cityNewcomerAnswers + cityInfoAnswers + newcomerFAQ + knowledgeBaseAnswers + lifeScenarioAnswers + MockExpandedSearchAnswers.items

    private static let knmAnswers: [SearchAnswer] = [
        SearchAnswer(
            id: SearchAnswer.stableID("search-answer:what-is-knm"),
            titleByLanguage: [
                .english: "What is KNM?",
                .dutch: "Wat is KNM?",
                .russian: "Что такое KNM?"
            ],
            keywordsByLanguage: [
                .english: ["KNM", "Knowledge of Dutch Society", "Kennis van de Nederlandse Maatschappij", "integration exam", "inburgering", "civic integration"],
                .dutch: ["KNM", "Kennis van de Nederlandse Maatschappij", "inburgeringsexamen", "inburgering", "maatschappijkennis"],
                .russian: ["KNM", "Знание нидерландского общества", "экзамен интеграции", "inburgering", "гражданская интеграция"]
            ],
            category: .general,
            shortAnswerByLanguage: [
                .english: "KNM means Knowledge of Dutch Society: everyday, civic, social, and practical life in the Netherlands.",
                .dutch: "KNM betekent Kennis van de Nederlandse Maatschappij: dagelijks, maatschappelijk en praktisch leven in Nederland.",
                .russian: "KNM означает «Знание нидерландского общества»: быт, общество, государство и практическая жизнь в Нидерландах."
            ],
            detailedAnswerByLanguage: [
                .english: "The app KNM section provides original study summaries and practice questions. It is not an official DUO exam. Use official DUO/Inburgeren pages for current exam details and practice exams.",
                .dutch: "De KNM-sectie in de app bevat eigen samenvattingen en oefenvragen. Het is geen officieel DUO-examen. Gebruik DUO/Inburgeren voor actuele exameninformatie en oefenexamens.",
                .russian: "Раздел KNM в приложении содержит оригинальные краткие объяснения и тренировочные вопросы. Это не официальный экзамен DUO. Для актуальной информации и официальной тренировки используйте DUO/Inburgeren."
            ],
            relatedInstitution: "DUO / Inburgeren",
            officialSourceName: "Inburgeren.nl",
            officialSourceURL: AppURL.make("https://www.inburgeren.nl/en/taking-the-integration-exam/content-knowledge-exams.jsp"),
            isOfficialSource: true,
            safetyNote: defaultSafety,
            lastUpdated: Date(timeIntervalSince1970: 1780272000),
            relatedQuestions: [
                "How do I practice KNM?",
                "What topics are in the integration exam?",
                "Where do I find official inburgering information?"
            ],
            nextRecommendedStep: "Open the KNM section and verify exam details on Inburgeren.nl."
        )
    ]

    private static let dutchCourseAnswers: [SearchAnswer] = [
        SearchAnswer(
            id: SearchAnswer.stableID("search-answer:dutch-a1-a2-for-daily-life"),
            titleByLanguage: [
                .english: "Dutch A1-A2 for daily life",
                .dutch: "Nederlands A1-A2 voor dagelijks leven",
                .russian: "Нидерландский A1-A2 для повседневной жизни"
            ],
            keywordsByLanguage: [
                .english: ["Dutch A1-A2", "Nederlands A1-A2", "afspraak", "gemeente", "huisarts", "trein", "OV-chipkaart", "werk", "huur", "verzekering", "de het", "hebben zijn", "separable verbs", "grammar", "words"],
                .dutch: ["Nederlands A1-A2", "afspraak", "gemeente", "huisarts", "trein", "OV-chipkaart", "werk", "huur", "verzekering", "de het", "hebben zijn", "grammatica", "woorden"],
                .russian: ["Нидерландский A1-A2", "afspraak", "gemeente", "huisarts", "trein", "OV-chipkaart", "werk", "huur", "verzekering", "de het", "hebben zijn", "отделяемые глаголы", "слова", "грамматика"]
            ],
            category: .education,
            shortAnswerByLanguage: [
                .english: "Open Dutch A1-A2 for original vocabulary, phrases, grammar notes, flashcards, and mini tests.",
                .dutch: "Open Nederlands A1-A2 voor originele woorden, zinnen, grammatica, flashcards en minitoetsen.",
                .russian: "Откройте Нидерландский A1-A2: оригинальные слова, фразы, грамматика, карточки и мини-тесты."
            ],
            detailedAnswerByLanguage: [
                .english: "This is app-created beginner Dutch support for practical situations such as municipality, transport, healthcare, housing, work, shopping, time, and A1-A2 grammar. It is not official DUO exam material.",
                .dutch: "Dit is door de app gemaakte ondersteuning voor praktisch Nederlands: gemeente, vervoer, zorg, wonen, werk, winkels, tijd en A1-A2 grammatica. Het is geen officieel DUO-examenmateriaal.",
                .russian: "Это созданная приложением помощь по практическому нидерландскому: gemeente, транспорт, здоровье, жильё, работа, магазины, время и грамматика A1-A2. Это не официальный материал экзамена DUO."
            ],
            relatedInstitution: "CEFR / DUO",
            officialSourceName: "Council of Europe / Inburgeren.nl",
            officialSourceURL: AppURL.make("https://www.coe.int/en/web/portfolio/self-assessment-grid"),
            isOfficialSource: true,
            safetyNote: defaultSafety,
            lastUpdated: Date(timeIntervalSince1970: 1780272000),
            relatedQuestions: ["How do I say afspraak?", "What is de and het?", "How do I talk to the huisarts?"],
            nextRecommendedStep: "Open Dutch A1-A2 and choose the practical module you need today."
        )
    ]

    private static let cityNewcomerAnswers: [SearchAnswer] = [
        SearchAnswer(
            id: SearchAnswer.stableID("search-answer:where-do-i-start-in-my-city-as-a-newcomer"),
            titleByLanguage: [
                .english: "Where do I start in my city as a newcomer?",
                .dutch: "Waar begin ik in mijn stad als nieuwkomer?",
                .russian: "С чего начать в городе после приезда?"
            ],
            keywordsByLanguage: [
                .english: ["BSN", "municipality", "city hall", "library", "Dutch language", "hospital", "legal help", "transport", "police", "housing", "student", "expat"],
                .dutch: ["bsn", "gemeente", "stadhuis", "bibliotheek", "Nederlandse taal", "ziekenhuis", "juridisch loket", "vervoer", "politie", "wonen"],
                .russian: ["bsn", "муниципалитет", "регистрация", "библиотека", "нидерландский язык", "больница", "юридическая помощь", "транспорт", "полиция", "жильё"]
            ],
            category: .registration,
            shortAnswerByLanguage: [
                .english: "Start with the municipality, DigiD, healthcare basics, transport, and local language or library support.",
                .dutch: "Begin bij de gemeente, DigiD, basiszorg, vervoer en lokale taal- of bibliotheeksteun.",
                .russian: "Начните с муниципалитета, DigiD, базовой медицины, транспорта и языковой поддержки или библиотеки."
            ],
            detailedAnswerByLanguage: [
                .english: "Open the city guide for your selected municipality. It links official city pages where available and labels reference-only places clearly. This is general information, not legal, tax, medical, or immigration advice.",
                .dutch: "Open de stadsgids voor jouw gemeente. Waar mogelijk staan officiële stadslinks erbij en referentiepunten zijn duidelijk gemarkeerd. Dit is algemene informatie, geen juridisch, belasting-, medisch of immigratieadvies.",
                .russian: "Откройте городской гид для выбранного муниципалитета. Там есть официальные городские ссылки, где они доступны, а справочные места отмечены отдельно. Это общая информация, не юридический, налоговый, медицинский или иммиграционный совет."
            ],
            relatedInstitution: "Municipality",
            officialSourceName: "Government.nl",
            officialSourceURL: fallbackSourceURL,
            isOfficialSource: true,
            safetyNote: defaultSafety,
            lastUpdated: Date(timeIntervalSince1970: 1779926400),
            relatedQuestions: ["How do I register with municipality?", "What is the emergency number in the Netherlands?"],
            nextRecommendedStep: "Open Nearby Help or the city detail page and verify official sources before action."
        ),
        SearchAnswer(
            id: SearchAnswer.stableID("search-answer:where-can-i-find-city-legal-help"),
            titleByLanguage: [
                .english: "Where can I find city legal help?",
                .dutch: "Waar vind ik juridische hulp in de stad?",
                .russian: "Где найти юридическую помощь в городе?"
            ],
            keywordsByLanguage: [
                .english: ["legal help", "Juridisch Loket", "rights", "tenant help", "work rights"],
                .dutch: ["juridische hulp", "juridisch loket", "rechten", "huurhulp", "werkrechten"],
                .russian: ["юридическая помощь", "Juridisch Loket", "права", "аренда", "трудовые права"]
            ],
            category: .legalHelp,
            shortAnswerByLanguage: [
                .english: "Use Juridisch Loket or official municipal/public-service sources for first-line orientation.",
                .dutch: "Gebruik Juridisch Loket of officiële gemeentelijke/publieke bronnen voor eerste oriëntatie.",
                .russian: "Используйте Juridisch Loket или официальные муниципальные/общественные источники для первичной ориентации."
            ],
            detailedAnswerByLanguage: [
                .english: "City pages list legal and rights help as orientation points only. Do not make legal conclusions from app text; verify your situation with qualified support or official sources.",
                .dutch: "Stadspagina's tonen juridische en rechtenhulp alleen als oriëntatiepunten. Trek geen juridische conclusies uit apptekst; controleer jouw situatie bij gekwalificeerde hulp of officiële bronnen.",
                .russian: "Городские страницы показывают юридическую помощь только как ориентир. Не делайте юридических выводов из текста приложения; проверяйте вашу ситуацию у квалифицированной помощи или официальных источников."
            ],
            relatedInstitution: "Juridisch Loket",
            officialSourceName: "Juridisch Loket",
            officialSourceURL: URL(string: "https://www.juridischloket.nl") ?? fallbackSourceURL,
            isOfficialSource: false,
            safetyNote: defaultSafety,
            lastUpdated: Date(timeIntervalSince1970: 1779926400),
            relatedQuestions: ["Where can I get legal help about letters?", "Can I use this app as legal advice?"],
            nextRecommendedStep: "Open the official source and prepare documents before asking for help."
        )
    ]

    private static let cityInfoAnswers: [SearchAnswer] = MockNetherlandsUnderstandingData.cityInfoProfiles.map { profile in
        let primarySource = MockNetherlandsUnderstandingData.sources(for: profile.officialSourceIds).first
        return SearchAnswer(
            id: SearchAnswer.stableID("search-answer:city-profile:\(profile.cityId)"),
            titleByLanguage: [
                .english: "City profile: \(profile.title.english)",
                .dutch: "Stadsprofiel: \(profile.title.dutch)",
                .russian: "Профиль города: \(profile.title.russian)"
            ],
            keywordsByLanguage: [
                .english: [profile.cityId, profile.provinceId, "city profile", "municipality", "first steps", "attractions", "transport"] + profile.practicalGuideIds + profile.attractionIds + profile.articleIds,
                .dutch: [profile.title.dutch, profile.provinceId, "stadsprofiel", "gemeente", "eerste stappen", "attracties", "vervoer"] + profile.practicalGuideIds + profile.attractionIds + profile.articleIds,
                .russian: [profile.title.russian, profile.provinceId, "профиль города", "муниципалитет", "первые шаги", "достопримечательности", "транспорт"] + profile.practicalGuideIds + profile.attractionIds + profile.articleIds
            ],
            category: .general,
            shortAnswerByLanguage: [
                .english: profile.subtitle.english,
                .dutch: profile.subtitle.dutch,
                .russian: profile.subtitle.russian
            ],
            detailedAnswerByLanguage: [
                .english: profile.summary.english,
                .dutch: profile.summary.dutch,
                .russian: profile.summary.russian
            ],
            relatedInstitution: "Municipality",
            officialSourceName: primarySource?.title ?? "Government.nl",
            officialSourceURL: primarySource?.url ?? fallbackSourceURL,
            isOfficialSource: true,
            safetyNote: nil,
            lastUpdated: Date(timeIntervalSince1970: 1780272000),
            relatedQuestions: ["Where do I start in my city as a newcomer?", "How do I register with municipality?"],
            nextRecommendedStep: "Open Cities, select this city, and verify the official municipality source before acting."
        )
    }

    private static let coreItems: [SearchAnswer] = [
        item(question: "How do I register with municipality?", keywords: ["municipality", "gemeente", "муниципалитет", "register", "registration", "address"], category: .registration, shortAnswer: "Contact your municipality and follow local registration steps.", detailedAnswer: "Municipality registration usually requires identity documents and address details. Requirements may vary by city, so verify local instructions and booking options.", institution: "Municipality", sourceName: "Government.nl", url: "https://www.government.nl/topics/municipalities", relatedQuestions: ["How do I get a BSN?", "How do I change my address?"]),
        item(question: "Do I need an appointment for BSN?", keywords: ["bsn appointment", "appointment"], category: .registration, shortAnswer: "Some municipalities may require an appointment.", detailedAnswer: "BSN handling may be integrated with registration or handled through a separate appointment depending on municipality workflow. Always check your city website directly.", institution: "Municipality", sourceName: "Government.nl", url: "https://www.government.nl/topics/personal-data/citizen-service-number-bsn", relatedQuestions: ["How do I get a BSN?", "How do I register with municipality?"]),
        item(question: "How do I change my address in the Netherlands?", keywords: ["change address", "move", "municipality"], category: .registration, shortAnswer: "Address changes are usually reported to your municipality.", detailedAnswer: "When you move, you may need to report your new address to the municipality. Deadlines and channels may differ by city, so check the local official source.", institution: "Municipality", sourceName: "Government.nl", url: "https://www.government.nl/topics/municipalities", relatedQuestions: ["How do I register with municipality?", "I moved city, what should I update?"]),
        item(question: "I moved city, what should I update?", keywords: ["move city", "address update", "records"], category: .registration, shortAnswer: "Update your address and review institution records.", detailedAnswer: "After moving, check whether your municipality registration and institution contact details are current. You may also need to verify updates in portals you use for official communication.", institution: "Municipality", sourceName: "Government.nl", url: "https://www.government.nl/topics/municipalities", relatedQuestions: ["How do I change my address in the Netherlands?", "What is DigiD?"]),

        item(question: "How do I activate DigiD?", keywords: ["activate digid", "digid code"], category: .digid, shortAnswer: "Follow the official DigiD activation process.", detailedAnswer: "Activation steps may include identity verification and a confirmation process. Use official instructions only and verify timelines directly on the DigiD website.", institution: "DigiD", sourceName: "DigiD", url: "https://www.digid.nl/en", relatedQuestions: ["What is DigiD?", "How do I avoid fake DigiD websites?"]),
        item(question: "How do I avoid fake DigiD websites?", keywords: ["fake digid", "phishing", "scam"], category: .digid, shortAnswer: "Open DigiD directly from the official domain.", detailedAnswer: "Scam messages may imitate official login pages. Avoid unknown links and manually type the official DigiD website when signing in.", institution: "DigiD", sourceName: "DigiD", url: "https://www.digid.nl/en", relatedQuestions: ["What is DigiD?", "I got a suspicious SMS about payment, what now?"]),
        item(question: "Where do I check privacy or personal data rights?", keywords: ["privacy", "personal data", "gdpr", "data protection", "autoriteit persoonsgegevens", "data breach"], category: .digid, shortAnswer: "Autoriteit Persoonsgegevens explains Dutch privacy and personal-data rights.", detailedAnswer: "For privacy requests, complaints, or possible misuse of personal data, keep dates, screenshots, correspondence, and organization details. Check Autoriteit Persoonsgegevens guidance before choosing the next step.", institution: "Autoriteit Persoonsgegevens", sourceName: "Autoriteit Persoonsgegevens", url: "https://www.autoriteitpersoonsgegevens.nl/en", relatedQuestions: ["What is DigiD?", "How do I avoid scam websites?"]),

        item(question: "What is IND?", keywords: ["ind", "residence permit", "immigration"], category: .immigration, shortAnswer: "IND usually handles immigration and residence permit procedures.", detailedAnswer: "The Immigration and Naturalisation Service (IND) manages many residence and immigration processes. Your exact route may depend on your status and permit type.", institution: "IND", sourceName: "IND", url: "https://ind.nl/en", relatedQuestions: ["Where do I check residence permit information?", "Can the app predict IND decisions?"]),
        item(question: "Where do I check residence permit information?", keywords: ["residence permit", "permit info", "ind"], category: .immigration, shortAnswer: "Use IND official information pages.", detailedAnswer: "Residence permit details are typically published on IND channels. Rules can change, so verify current requirements and forms directly with IND.", institution: "IND", sourceName: "IND", url: "https://ind.nl/en", relatedQuestions: ["What is IND?", "Can the app predict IND decisions?"]),
        item(question: "Can the app predict IND decisions?", keywords: ["predict ind", "decision"], category: .immigration, shortAnswer: "No. This app cannot predict official decisions.", detailedAnswer: "This app provides educational guidance only. It cannot predict outcomes or replace official advice. Contact IND directly for case-specific information.", institution: "IND", sourceName: "IND", url: "https://ind.nl/en", relatedQuestions: ["What is IND?", "Where do I check residence permit information?"]),

        item(question: "Where can I find DUO?", keywords: ["duo", "student finance", "education"], category: .education, shortAnswer: "DUO handles many education-related administrative topics.", detailedAnswer: "Students may interact with DUO for education finance and administrative matters. Check official DUO pages for current guidance and conditions.", institution: "DUO", sourceName: "DUO", url: "https://duo.nl", relatedQuestions: ["What does DUO do?", "How do I check student finance information?"]),
        item(question: "What does DUO do?", keywords: ["duo", "education"], category: .education, shortAnswer: "DUO usually manages education administration and student finance topics.", detailedAnswer: "DUO may provide information on educational administration and financial schemes for eligible students. Rules and eligibility can change.", institution: "DUO", sourceName: "DUO", url: "https://duo.nl", relatedQuestions: ["Where can I find DUO?", "How do I check student finance information?"]),
        item(question: "How do I check student finance information?", keywords: ["student finance", "duo"], category: .education, shortAnswer: "Use DUO official pages and your official DUO messages.", detailedAnswer: "Student finance information is usually managed through DUO. Check official instructions and verify deadlines shown in your messages.", institution: "DUO", sourceName: "DUO", url: "https://duo.nl/particulier", relatedQuestions: ["Where can I find DUO?", "What does DUO do?"]),
        item(question: "Where do I apply or enrol for Dutch higher education?", keywords: ["studielink", "higher education", "university application", "enrolment", "study programme"], category: .education, shortAnswer: "Studielink is the central route for many Dutch higher education applications and enrolments.", detailedAnswer: "Use Studielink together with the institution's own instructions. Deadlines, required documents, and next steps can differ by programme, university, nationality, and start date.", institution: "Studielink", sourceName: "Studielink", url: "https://www.studielink.nl", relatedQuestions: ["Where can I find DUO?", "How do I check student finance information?"]),
        item(question: "Where do I evaluate a foreign diploma?", keywords: ["foreign diploma", "diploma evaluation", "idw", "credential evaluation", "nuffic", "sbb"], category: .education, shortAnswer: "IDW provides information about international credential evaluation.", detailedAnswer: "Check first whether your employer, school, or authority requires a diploma evaluation. If it is needed, prepare diplomas, transcripts, translations, and identity documents before applying.", institution: "IDW", sourceName: "IDW", url: "https://www.idw.nl/en", isOfficial: false, relatedQuestions: ["Where can I find DUO?", "Where do I find official Dutch rules?"]),
        item(question: "What should parents know about compulsory education?", keywords: ["leerplicht", "compulsory education", "school attendance", "children school", "absence"], category: .education, shortAnswer: "Parents should follow Dutch school-attendance rules and verify any exception with the school or municipality.", detailedAnswer: "School attendance, absence reporting, exemptions, and qualification-duty questions can involve the school and municipality. Check official local instructions if a child cannot attend or is changing schools.", institution: "Municipality / School", sourceName: "Rijksoverheid", url: "https://www.rijksoverheid.nl/onderwerpen/leerplicht", relatedQuestions: ["How do I register with municipality?", "Where do I apply or enrol for Dutch higher education?"]),

        item(question: "What is UWV?", keywords: ["uwv", "work benefits", "employment"], category: .work, shortAnswer: "UWV usually handles work-related benefits and employment support.", detailedAnswer: "UWV may be relevant for unemployment, sickness-related work benefits, and other work support topics. Check official UWV channels for your case.", institution: "UWV", sourceName: "UWV", url: "https://www.uwv.nl", relatedQuestions: ["Where do I find work-related benefits info?", "What should I check in my work contract?"]),
        item(question: "Where do I find work-related benefits info?", keywords: ["benefits", "uwv", "work"], category: .work, shortAnswer: "Use UWV official resources.", detailedAnswer: "If you need work-related benefits information, UWV is often the relevant institution. Always verify current conditions and application routes on official pages.", institution: "UWV", sourceName: "UWV", url: "https://www.uwv.nl", relatedQuestions: ["What is UWV?", "What should I check in my work contract?"]),
        item(question: "What should I check in my work contract?", keywords: ["work contract", "salary", "work rights"], category: .work, shortAnswer: "Review contract type, salary terms, and key conditions.", detailedAnswer: "Check contract type, pay schedule, probation terms, and working hours. For legal interpretation, contact a qualified advisor or legal help service.", institution: "UWV", sourceName: "UWV", url: "https://www.uwv.nl", relatedQuestions: ["What is UWV?", "Where can I get legal help about contracts?"]),
        item(question: "Where do I check work safety or unfair work concerns?", keywords: ["work safety", "unsafe work", "underpayment", "labour authority", "arbeidsinspectie", "exploitation"], category: .work, shortAnswer: "Use the Netherlands Labour Authority for fair and safe work information.", detailedAnswer: "The Netherlands Labour Authority publishes official information and reporting routes for unsafe, unhealthy, unfair working conditions and labour exploitation. Keep contracts, payslips, schedules, and messages together before asking for help.", institution: "Netherlands Labour Authority", sourceName: "Netherlands Labour Authority", url: "https://www.nllabourauthority.nl", relatedQuestions: ["What should I check in my work contract?", "Where do I find work-related benefits info?"]),
        item(question: "Where can entrepreneurs check official business steps?", keywords: ["entrepreneur", "business", "zzp", "kvk", "self employed", "starting business"], category: .work, shortAnswer: "Business.gov.nl is the English government portal for entrepreneurs.", detailedAnswer: "Business.gov.nl brings Dutch government information for entrepreneurs together, including starting a business, legal forms, permits, staff, finance, taxes, and administration. Verify requirements before signing contracts or registering.", institution: "Netherlands Enterprise Agency", sourceName: "Business.gov.nl", url: "https://business.gov.nl", relatedQuestions: ["What should I check in my work contract?", "Where do I find official Dutch rules?"]),

        item(question: "What is Belastingdienst?", keywords: ["belastingdienst", "налоговая", "tax office", "taxes", "налоги", "письмо"], category: .taxes, shortAnswer: "Belastingdienst is the Dutch tax administration.", detailedAnswer: "Belastingdienst handles many tax and allowance-related topics. Official letters may include deadlines, so read them fully and verify details directly.", institution: "Belastingdienst", sourceName: "Belastingdienst", url: "https://www.belastingdienst.nl", relatedQuestions: ["How do Dutch tax letters work?", "What are toeslagen?"]),
        item(question: "How do Dutch tax letters work?", keywords: ["tax letter", "belastingbrief"], category: .taxes, shortAnswer: "Tax letters may request information, payment, or confirmation.", detailedAnswer: "Some tax letters are informational, while others request action. Check deadlines and reference numbers carefully and verify instructions on official channels.", institution: "Belastingdienst", sourceName: "Belastingdienst", url: "https://www.belastingdienst.nl", relatedQuestions: ["What is Belastingdienst?", "What should I do if I do not understand a tax letter?"]),
        item(question: "What are toeslagen?", keywords: ["toeslagen", "allowances"], category: .taxes, shortAnswer: "Toeslagen are Dutch allowance schemes for specific situations.", detailedAnswer: "Allowances may apply based on income and personal circumstances. Always verify eligibility rules and updates through official Belastingdienst/Toeslagen sources.", institution: "Belastingdienst", sourceName: "Belastingdienst Toeslagen", url: "https://www.toeslagen.nl", relatedQuestions: ["What is Belastingdienst?", "How do Dutch tax letters work?"]),
        item(question: "What should I do if I do not understand a tax letter?", keywords: ["dont understand tax letter", "belasting"], category: .taxes, shortAnswer: "Use official explanations and contact channels first.", detailedAnswer: "Start with official tax information pages and verify the letter reference. If still unclear, contact official support channels listed by Belastingdienst.", institution: "Belastingdienst", sourceName: "Belastingdienst", url: "https://www.belastingdienst.nl", relatedQuestions: ["How do Dutch tax letters work?", "Where can I get legal help about letters?"]),
        item(question: "Where do I file or check my Dutch tax return online?", keywords: ["mijn belastingdienst", "tax return portal", "aangifte online", "assessment", "tax portal"], category: .taxes, shortAnswer: "Use Mijn Belastingdienst through official Belastingdienst channels.", detailedAnswer: "Mijn Belastingdienst is the official online route for many income tax returns, assessments, tax messages, and personal tax details. Compare deadlines and reference numbers with official letters before submitting or paying.", institution: "Belastingdienst", sourceName: "Belastingdienst", url: "https://www.belastingdienst.nl", relatedQuestions: ["What is Belastingdienst?", "How do Dutch tax letters work?"]),
        item(question: "When should I report changes for toeslagen?", keywords: ["toeslagen changes", "allowance change", "income changed", "household changed", "repayment"], category: .taxes, shortAnswer: "Report changes quickly through official Toeslagen channels.", detailedAnswer: "Income, household, rent, childcare, and care-insurance changes can affect allowances. Keep details current because overpaid toeslagen usually have to be repaid.", institution: "Dienst Toeslagen", sourceName: "Toeslagen", url: "https://www.toeslagen.nl", relatedQuestions: ["What are toeslagen?", "Can tax rules change over time?"]),
        item(question: "Where do I check childcare benefit?", keywords: ["childcare benefit", "kinderopvangtoeslag", "childcare", "toeslagen", "parents"], category: .taxes, shortAnswer: "Use official childcare benefit information before applying or reporting changes.", detailedAnswer: "Childcare benefit can depend on childcare type, hours, income, household details, and work or study situation. Keep childcare contracts and changes up to date because overpayments may need to be repaid.", institution: "Dienst Toeslagen", sourceName: "Government.nl", url: "https://www.government.nl/topics/childcare/childcare-benefit", relatedQuestions: ["What are toeslagen?", "When should I report changes for toeslagen?"]),

        item(question: "Where do I pay a traffic fine?", keywords: ["pay fine", "traffic fine", "cjib"], category: .fines, shortAnswer: "Traffic fines are usually handled by CJIB.", detailedAnswer: "Use payment details from your official letter and verify references on CJIB channels. Be cautious with unexpected payment links.", institution: "CJIB", sourceName: "CJIB", url: "https://www.cjib.nl/en", relatedQuestions: ["What is CJIB?", "I got a suspicious SMS about payment, what now?"]),
        item(question: "I got a suspicious SMS about payment, what now?", keywords: ["suspicious sms", "scam", "payment link"], category: .fines, shortAnswer: "Do not pay from unknown links; verify with official websites directly.", detailedAnswer: "Payment scams may imitate official institutions. Open the official institution website manually and check whether the message is legitimate.", institution: "CJIB", sourceName: "CJIB", url: "https://www.cjib.nl/en", relatedQuestions: ["Where do I pay a traffic fine?", "How do I avoid fake DigiD websites?"]),

        item(question: "Do I need health insurance?", keywords: ["health insurance", "mandatory insurance"], category: .healthInsurance, shortAnswer: "Many residents usually need Dutch basic health insurance.", detailedAnswer: "Whether you need insurance may depend on your residency and work situation. Verify current rules and timing on official sources.", institution: "Government.nl", sourceName: "Government.nl", url: "https://www.government.nl/topics/health-insurance", relatedQuestions: ["How quickly should I arrange health insurance?", "Where do I compare health insurance info?"]),
        item(question: "How quickly should I arrange health insurance?", keywords: ["insurance deadline", "health insurance timing"], category: .healthInsurance, shortAnswer: "Arrange it as soon as your situation requires it.", detailedAnswer: "Timing may depend on personal circumstances. Because rules can change, verify current timelines directly on official government health insurance pages.", institution: "Government.nl", sourceName: "Government.nl", url: "https://www.government.nl/topics/health-insurance", relatedQuestions: ["Do I need health insurance?", "Where do I compare health insurance info?"]),
        item(question: "Where do I compare health insurance info?", keywords: ["compare insurance", "healthcare"], category: .healthInsurance, shortAnswer: "Start with official government guidance.", detailedAnswer: "Use official government pages to understand the system first, then compare providers carefully. Always verify policy details before choosing.", institution: "Government.nl", sourceName: "Government.nl", url: "https://www.government.nl/topics/health-insurance", relatedQuestions: ["Do I need health insurance?", "How quickly should I arrange health insurance?"]),
        item(question: "Where do I check symptoms before calling a GP?", keywords: ["symptoms", "huisarts", "gp", "thuisarts", "doctor", "health question"], category: .healthInsurance, shortAnswer: "Thuisarts.nl gives plain-language GP health information.", detailedAnswer: "Use Thuisarts.nl for orientation about symptoms, self-care, and when to contact a huisarts. Do not delay urgent care; call your GP, huisartsenpost, or 112 if symptoms are severe or sudden.", institution: "Nederlands Huisartsen Genootschap", sourceName: "Thuisarts.nl", url: "https://www.thuisarts.nl", isOfficial: false, relatedQuestions: ["Do I need health insurance?", "What is the emergency number in the Netherlands?"]),
        item(question: "How do I verify a Dutch healthcare professional?", keywords: ["big register", "doctor registration", "healthcare professional", "verify doctor", "zorgverlener"], category: .healthInsurance, shortAnswer: "Use the official BIG-register for regulated healthcare professionals.", detailedAnswer: "The BIG-register lets you check whether regulated healthcare professionals are registered in the Netherlands. Compare names carefully and use official contact routes if a result is unclear.", institution: "CIBG", sourceName: "BIG-register", url: "https://english.bigregister.nl", relatedQuestions: ["Where do I check symptoms before calling a GP?", "Where do I compare health insurance info?"]),

        item(question: "What is RDW?", keywords: ["rdw", "driving", "vehicle"], category: .transport, shortAnswer: "RDW handles vehicle and driving-related administration.", detailedAnswer: "RDW is usually relevant for vehicle registration and driving administration topics. Check official RDW pages for current rules.", institution: "RDW", sourceName: "RDW", url: "https://www.rdw.nl/en", relatedQuestions: ["Where do I check vehicle registration rules?", "How do transport ticket rules work?"]),
        item(question: "Where do I check vehicle registration rules?", keywords: ["vehicle registration", "rdw"], category: .transport, shortAnswer: "Use RDW official information.", detailedAnswer: "Vehicle registration requirements and procedures are generally published by RDW. Verify latest requirements before action.", institution: "RDW", sourceName: "RDW", url: "https://www.rdw.nl/en", relatedQuestions: ["What is RDW?", "How do transport ticket rules work?"]),
        item(question: "How do transport ticket rules work?", keywords: ["transport rules", "check in", "check out"], category: .transport, shortAnswer: "Many transport systems require check-in and check-out.", detailedAnswer: "Public transport often uses check-in and check-out rules. Missing a step may cause possible ticket issues or extra charges.", institution: "Government.nl", sourceName: "Government.nl", url: "https://www.government.nl/topics/mobility-public-transport-and-road-safety", relatedQuestions: ["Where do I pay a traffic fine?", "What is RDW?"]),
        item(question: "Can I use my bank card in public transport?", keywords: ["ovpay", "bank card", "debit card", "contactless", "check in", "mobile wallet"], category: .transport, shortAnswer: "OVpay explains contactless check-in and check-out.", detailedAnswer: "OVpay provides official information about checking in and out with a debit card, credit card, or mobile wallet. Use the same card or device for both steps and verify corrections through official OVpay guidance.", institution: "OVpay", sourceName: "OVpay", url: "https://www.ovpay.nl/en", relatedQuestions: ["How do transport ticket rules work?", "Where can I check road safety and transport rules?"]),
        item(question: "Where do I check public transport routes and disruptions?", keywords: ["9292", "public transport planner", "route", "disruption", "train", "bus", "tram"], category: .transport, shortAnswer: "Use 9292 for multi-operator public transport planning.", detailedAnswer: "9292 helps plan routes across bus, tram, metro, train, and ferry operators. Check shortly before departure because disruptions, platforms, and transfers can change.", institution: "9292", sourceName: "9292", url: "https://9292.nl/en", isOfficial: false, relatedQuestions: ["How do transport ticket rules work?", "Can I use my bank card in public transport?"]),

        item(question: "Where can I get legal help about letters?", keywords: ["legal help", "letters", "juridisch loket"], category: .legalHelp, shortAnswer: "For help understanding a letter, Juridisch Loket can provide first-line legal orientation.", detailedAnswer: "For initial legal orientation in plain language, Juridisch Loket may help. This does not replace personalized legal representation.", institution: "Juridisch Loket", sourceName: "Juridisch Loket", url: "https://www.juridischloket.nl", isOfficial: false, relatedQuestions: ["Where can I get legal help about contracts?", "What should I do if I do not understand a tax letter?"]),
        item(question: "Where can I get legal help about contracts?", keywords: ["legal help contract", "work contract legal"], category: .legalHelp, shortAnswer: "You may start with Juridisch Loket for legal orientation.", detailedAnswer: "For general legal orientation about contracts, Juridisch Loket may be a useful first step. For case-specific decisions, contact qualified advisors.", institution: "Juridisch Loket", sourceName: "Juridisch Loket", url: "https://www.juridischloket.nl", isOfficial: false, relatedQuestions: ["Where can I get legal help about letters?", "What should I check in my work contract?"]),
        item(question: "Where do I check consumer rights or company complaints?", keywords: ["consumer rights", "complaint", "subscription", "contract", "refund", "consuwijzer", "acm"], category: .legalHelp, shortAnswer: "ACM ConsuWijzer gives consumer-rights orientation and complaint routes.", detailedAnswer: "Use ACM ConsuWijzer for questions about purchases, subscriptions, bills, delivery problems, online shopping, misleading sales, and complaint letters. Keep receipts, emails, and contract details before contacting a company or reporting a problem.", institution: "ACM", sourceName: "ACM ConsuWijzer", url: "https://www.consuwijzer.nl", relatedQuestions: ["Can I use this app as legal advice?", "How do I avoid scam websites?"]),
        item(question: "Where can victims of crime or serious incidents get support?", keywords: ["victim support", "slachtofferhulp", "crime victim", "violence", "accident", "compensation"], category: .legalHelp, shortAnswer: "Slachtofferhulp Nederland can help after crime, violence, accidents, or serious incidents.", detailedAnswer: "If danger is happening now, call 112. For follow-up support, Slachtofferhulp Nederland offers emotional, practical, compensation-related, and criminal-procedure orientation. Save reports, letters, photos, and case references.", institution: "Slachtofferhulp Nederland", sourceName: "Slachtofferhulp Nederland", url: "https://www.slachtofferhulp.nl/english", isOfficial: false, relatedQuestions: ["What is the emergency number in the Netherlands?", "Where can I get legal help about letters?"]),
        item(question: "Where can I report discrimination?", keywords: ["discrimination", "discriminatie", "racism", "religion", "gender", "sexuality", "disability"], category: .legalHelp, shortAnswer: "Use a discrimination reporting route and save evidence before reporting.", detailedAnswer: "If you experience or witness discrimination, note dates, places, what happened, messages, screenshots, and witness details. Discriminatie.nl can help orient reporting and support options. If there is immediate danger, call 112.", institution: "Discriminatie.nl", sourceName: "Discriminatie.nl", url: "https://discriminatie.nl", isOfficial: false, relatedQuestions: ["Can I use this app as legal advice?", "Where can victims of crime or serious incidents get support?"]),

        item(question: "What is the emergency number in the Netherlands?", keywords: ["112", "emergency"], category: .emergency, shortAnswer: "Call 112 for urgent emergency situations.", detailedAnswer: "For immediate danger or urgent emergency medical/police/fire support, use 112. For non-urgent issues, use regular institution channels.", institution: "Government.nl", sourceName: "Government.nl", url: "https://www.government.nl/themes/justice-security-and-defence/emergency-number-112", relatedQuestions: ["When should I call 112?", "Where do I find non-urgent help?"]),
        item(question: "When should I call 112?", keywords: ["call 112", "urgent danger"], category: .emergency, shortAnswer: "Call 112 in urgent danger or emergency situations.", detailedAnswer: "Use 112 for immediate emergencies. For non-urgent administrative or informational issues, contact the relevant service directly.", institution: "Government.nl", sourceName: "Government.nl", url: "https://www.government.nl/themes/justice-security-and-defence/emergency-number-112", relatedQuestions: ["What is the emergency number in the Netherlands?", "Where do I find non-urgent help?"]),
        item(question: "What should I do if I feel unsafe or have suicidal thoughts?", keywords: ["suicide", "suicidal thoughts", "mental crisis", "113", "unsafe", "zelfmoord"], category: .emergency, shortAnswer: "If there is immediate danger, call 112. For suicide-prevention support, contact 113.", detailedAnswer: "This app is not a crisis service. Call 112 if someone may be in immediate danger. If there are suicidal thoughts or you are worried about someone else, use 113's phone or chat support and follow their guidance.", institution: "113 Zelfmoordpreventie", sourceName: "113 Zelfmoordpreventie", url: "https://www.113.nl/english", isOfficial: false, relatedQuestions: ["What is the emergency number in the Netherlands?", "When should I call 112?"]),
        item(question: "Where do I report a non-urgent police issue?", keywords: ["non urgent police", "police report", "politie", "0900-8844", "report crime"], category: .emergency, shortAnswer: "Use Politie.nl for non-urgent police routes.", detailedAnswer: "If there is immediate danger, call 112. For non-urgent reporting, contact, lost and found, or safety questions, use official Politie.nl routes and avoid sharing details through unknown contacts.", institution: "Politie", sourceName: "Politie.nl", url: "https://www.politie.nl/en", relatedQuestions: ["What is the emergency number in the Netherlands?", "Where do I find non-urgent help?"]),
        item(question: "Where do I find non-urgent help?", keywords: ["non urgent", "support"], category: .general, shortAnswer: "Use the relevant institution or municipality support channels.", detailedAnswer: "For non-urgent questions, contact the responsible institution directly through official websites and contact details.", institution: "Government.nl", sourceName: "Government.nl", url: "https://www.government.nl", relatedQuestions: ["What is the emergency number in the Netherlands?", "What is Government.nl?"]),

        item(question: "What is Government.nl?", keywords: ["government.nl", "official info"], category: .general, shortAnswer: "Government.nl is the official Dutch government information portal.", detailedAnswer: "Government.nl provides public information on many topics. For personal procedures, you may still need institution-specific or municipality-specific instructions.", institution: "Government.nl", sourceName: "Government.nl", url: "https://www.government.nl", relatedQuestions: ["How do I register with municipality?", "Where do I find official Dutch rules?"]),
        item(question: "Where do I find official Dutch rules?", keywords: ["official rules", "rijksoverheid"], category: .general, shortAnswer: "Start with official government and institution websites.", detailedAnswer: "Use Government.nl and relevant institution sites (IND, DUO, UWV, Belastingdienst, CJIB, RDW) for current public guidance. Rules can change.", institution: nil, sourceName: "Rijksoverheid", url: "https://www.rijksoverheid.nl", relatedQuestions: ["What is Government.nl?", "How do I avoid scam websites?"]),
        item(question: "How do I avoid scam websites?", keywords: ["scam websites", "phishing", "fake site"], category: .general, shortAnswer: "Use known official domains directly.", detailedAnswer: "Scam websites may imitate institutions. Type official domains manually and verify contact details before sharing data or making payments.", institution: nil, sourceName: "Fraudehelpdesk", url: "https://www.fraudehelpdesk.nl", isOfficial: false, relatedQuestions: ["How do I avoid fake DigiD websites?", "I got a suspicious SMS about payment, what now?"]),

        item(question: "How do I find municipality appointment pages?", keywords: ["appointment page", "municipality website"], category: .registration, shortAnswer: "Use your municipality’s official website.", detailedAnswer: "Appointment pages and procedures may vary by city. Search your municipality’s official domain and confirm requirements before booking.", institution: "Municipality", sourceName: "Government.nl", url: "https://www.government.nl/topics/municipalities", relatedQuestions: ["How do I register with municipality?", "Do I need an appointment for BSN?"]),
        item(question: "Can I use this app as legal advice?", keywords: ["legal advice", "official advice"], category: .legalHelp, shortAnswer: "No. This app provides educational guidance only.", detailedAnswer: "YouNew is informational and does not provide legal advice. For personal decisions, verify with official institutions or qualified advisors.", institution: nil, sourceName: "Juridisch Loket", url: "https://www.juridischloket.nl", isOfficial: false, relatedQuestions: ["Where can I get legal help about letters?", "Where do I find official Dutch rules?"]),
        item(question: "How do I verify if a government letter is real?", keywords: ["verify letter", "real letter", "fake letter"], category: .general, shortAnswer: "Check sender details via official channels before acting.", detailedAnswer: "If a letter seems unusual, compare contact details with official websites and avoid using unknown payment links or phone numbers in suspicious messages.", institution: nil, sourceName: "Government.nl", url: "https://www.government.nl", relatedQuestions: ["What should I do with official letters?", "I got a suspicious SMS about payment, what now?"]),

        item(question: "Do newcomers usually need to register quickly?", keywords: ["register quickly", "arrival registration"], category: .registration, shortAnswer: "Registration is often an early step after arrival.", detailedAnswer: "Municipality registration is usually one of the first onboarding steps. Check your local municipality timeline and requirements.", institution: "Municipality", sourceName: "Government.nl", url: "https://www.government.nl/topics/municipalities", relatedQuestions: ["How do I register with municipality?", "How do I get a BSN?"]),
        item(question: "Where can I learn about Dutch housing basics?", keywords: ["housing basics", "rent"], category: .housing, shortAnswer: "Use official housing guidance as a starting point.", detailedAnswer: "Housing rules may differ by city and contract type. Start with government housing information and verify municipality-specific requirements.", institution: "Government.nl", sourceName: "Government.nl", url: "https://www.government.nl/themes/building-and-housing/housing", relatedQuestions: ["How do I update my address?", "What should I check in a rental contract?"]),
        item(question: "What should I check in a rental contract?", keywords: ["rental contract", "housing contract"], category: .housing, shortAnswer: "Check terms, address details, and payment conditions.", detailedAnswer: "Review contract duration, payment schedule, deposit details, and registration permissions. For legal interpretation, contact qualified legal support.", institution: nil, sourceName: "Government.nl", url: "https://www.government.nl/themes/building-and-housing/housing", relatedQuestions: ["Where can I learn about Dutch housing basics?", "Where can I get legal help about contracts?"]),
        item(question: "Where do I check a rent or service-cost dispute?", keywords: ["huurcommissie", "rent dispute", "service costs", "huurprijs", "landlord", "maintenance"], category: .housing, shortAnswer: "Use Huurcommissie for rental dispute orientation.", detailedAnswer: "Huurcommissie publishes official information about rent, service costs, maintenance, and some tenant-landlord disputes. Check whether your case is within scope and keep contract, payment, service-cost, and message records together.", institution: "Huurcommissie", sourceName: "Huurcommissie", url: "https://www.huurcommissie.nl", relatedQuestions: ["What should I check in a rental contract?", "Where can I learn about Dutch housing basics?"]),

        item(question: "How do I avoid common newcomer mistakes?", keywords: ["common mistakes", "newcomer"], category: .general, shortAnswer: "Read official letters early and verify each requirement.", detailedAnswer: "Common issues include missing letters, using non-official links, and delaying key registrations. Keep documents organized and verify instructions directly.", institution: nil, sourceName: "Government.nl", url: "https://www.government.nl", relatedQuestions: ["What should I do with official letters?", "How do I avoid scam websites?"]),
        item(question: "Where can I find immigration information in English?", keywords: ["immigration english", "ind english"], category: .immigration, shortAnswer: "Use IND English pages.", detailedAnswer: "IND provides English-language guidance on many immigration topics. Always check whether your specific process has extra requirements.", institution: "IND", sourceName: "IND", url: "https://ind.nl/en", relatedQuestions: ["What is IND?", "Where do I check residence permit information?"]),
        item(question: "How do I find official municipality websites?", keywords: ["municipality website", "city website"], category: .registration, shortAnswer: "Use official municipality domains and government references.", detailedAnswer: "Municipality sites can differ by city. Start from official government references and confirm that the website domain matches the city administration.", institution: "Municipality", sourceName: "Government.nl", url: "https://www.government.nl/topics/municipalities", relatedQuestions: ["How do I find municipality appointment pages?", "How do I register with municipality?"]),

        item(question: "Can tax rules change over time?", keywords: ["tax rules change", "tax updates"], category: .taxes, shortAnswer: "Yes, rules can change, so verify current official guidance.", detailedAnswer: "Tax policy and procedures may change. Use official Belastingdienst or Toeslagen pages for current requirements and updates.", institution: "Belastingdienst", sourceName: "Belastingdienst", url: "https://www.belastingdienst.nl", relatedQuestions: ["What are toeslagen?", "How do Dutch tax letters work?"]),
        item(question: "Can fine amounts change?", keywords: ["fine amount", "cjib amount"], category: .fines, shortAnswer: "Possible amounts and conditions may change.", detailedAnswer: "Fine-related details can be updated by authorities. Verify amounts only from official documents and official CJIB resources.", institution: "CJIB", sourceName: "CJIB", url: "https://www.cjib.nl/en", relatedQuestions: ["Where do I pay a traffic fine?", "What is CJIB?"]),
        item(question: "Where do I report online fraud concerns?", keywords: ["report fraud", "online fraud"], category: .general, shortAnswer: "Use trusted fraud-help channels and official institution contacts.", detailedAnswer: "If you suspect fraud, avoid further interaction with suspicious senders and use trusted reporting/help channels for guidance.", institution: nil, sourceName: "Fraudehelpdesk", url: "https://www.fraudehelpdesk.nl", isOfficial: false, relatedQuestions: ["How do I avoid scam websites?", "I got a suspicious SMS about payment, what now?"]),

        item(question: "How do I find Belastingdienst contact information?", keywords: ["belastingdienst contact", "tax contact"], category: .taxes, shortAnswer: "Use official Belastingdienst contact pages.", detailedAnswer: "Contact information can vary by topic and language support. Use the official site to find the correct channel for your question.", institution: "Belastingdienst", sourceName: "Belastingdienst", url: "https://www.belastingdienst.nl/wps/wcm/connect/nl/contact/contact", relatedQuestions: ["How do Dutch tax letters work?", "What should I do if I do not understand a tax letter?"]),
        item(question: "How do I find UWV contact information?", keywords: ["uwv contact", "work support contact"], category: .work, shortAnswer: "Use official UWV contact pages.", detailedAnswer: "UWV contact channels differ by topic. Check official UWV contact guidance and choose the route matching your situation.", institution: "UWV", sourceName: "UWV", url: "https://www.uwv.nl/en/contact", relatedQuestions: ["What is UWV?", "Where do I find work-related benefits info?"]),
        item(question: "How do I find DUO contact information?", keywords: ["duo contact", "education contact"], category: .education, shortAnswer: "Use official DUO contact pages.", detailedAnswer: "DUO contact routes may differ for students and international visitors. Check official DUO contact pages for current channels.", institution: "DUO", sourceName: "DUO", url: "https://duo.nl/particulier/contact.jsp", relatedQuestions: ["Where can I find DUO?", "How do I check student finance information?"]),

        item(question: "Where can I read about emergency services?", keywords: ["emergency services", "112 info"], category: .emergency, shortAnswer: "Government.nl explains emergency service basics.", detailedAnswer: "You can review emergency service guidance and when to call 112 through official government information pages.", institution: "Government.nl", sourceName: "Government.nl", url: "https://www.government.nl/themes/justice-security-and-defence/emergency-number-112", relatedQuestions: ["What is the emergency number in the Netherlands?", "When should I call 112?"]),
        item(question: "What is Rijksoverheid?", keywords: ["rijksoverheid", "dutch government"], category: .general, shortAnswer: "Rijksoverheid is the Dutch central government domain.", detailedAnswer: "Rijksoverheid provides official central-government information and policy communication. For procedures, use the specific institution pages too.", institution: nil, sourceName: "Rijksoverheid", url: "https://www.rijksoverheid.nl", relatedQuestions: ["Where do I find official Dutch rules?", "What is Government.nl?"]),

        item(question: "How do I find information about inburgering?", keywords: ["inburgering", "integration exam", "duo"], category: .education, shortAnswer: "DUO may be relevant for inburgering administration topics.", detailedAnswer: "Inburgering topics can involve DUO and other institutions depending on your status. Check official DUO and government pages for current guidance.", institution: "DUO", sourceName: "DUO", url: "https://duo.nl", relatedQuestions: ["What does DUO do?", "Where can I find DUO?"]),
        item(question: "Where can I check road safety and transport rules?", keywords: ["road safety", "transport rules"], category: .transport, shortAnswer: "Use official mobility and road safety guidance.", detailedAnswer: "Government and transport authorities publish mobility and road safety guidance. Check official channels for current rules.", institution: "Government.nl", sourceName: "Government.nl", url: "https://www.government.nl/topics/mobility-public-transport-and-road-safety", relatedQuestions: ["How do transport ticket rules work?", "What is RDW?"]),

        item(question: "What should I do if I miss a possible deadline in a letter?", keywords: ["missed deadline", "late response"], category: .general, shortAnswer: "Contact the institution quickly through official channels.", detailedAnswer: "If you may have missed a deadline, contact the institution that sent the letter as soon as possible and verify next steps through official contact points.", institution: nil, sourceName: "Government.nl", url: "https://www.government.nl", relatedQuestions: ["What should I do with official letters?", "How do Dutch tax letters work?"]),
        item(question: "Do rules differ by municipality?", keywords: ["different by city", "municipality differences"], category: .registration, shortAnswer: "Yes, local processes may differ between municipalities.", detailedAnswer: "Municipalities may have different appointment systems and document checklists. Always check your local official municipality pages.", institution: "Municipality", sourceName: "Government.nl", url: "https://www.government.nl/topics/municipalities", relatedQuestions: ["How do I register with municipality?", "How do I find municipality appointment pages?"]),
        item(question: "Can I trust social media legal tips?", keywords: ["social media advice", "legal tips"], category: .legalHelp, shortAnswer: "Treat social posts carefully and verify with official sources.", detailedAnswer: "Social media may be incomplete or inaccurate for personal situations. Use official institutions and qualified advisors for important decisions.", institution: nil, sourceName: "Juridisch Loket", url: "https://www.juridischloket.nl", isOfficial: false, relatedQuestions: ["Can I use this app as legal advice?", "Where do I find official Dutch rules?"]),

        item(question: "How do I find trusted newcomer information in one place?", keywords: ["trusted newcomer info", "official sources"], category: .general, shortAnswer: "Start with official institutions and this app’s source-first links.", detailedAnswer: "Use this app for orientation, then open official sources for final verification. Keep track of deadlines and document references.", institution: nil, sourceName: "Government.nl", url: "https://www.government.nl", relatedQuestions: ["Where do I find official Dutch rules?", "How do I avoid common newcomer mistakes?"]),
        item(question: "What is the safest way to pay official fines?", keywords: ["safe fine payment", "official payment"], category: .fines, shortAnswer: "Use references from your official letter and CJIB website.", detailedAnswer: "Pay only through verified channels and matching reference numbers. If uncertain, check CJIB official contact routes before paying.", institution: "CJIB", sourceName: "CJIB", url: "https://www.cjib.nl/en", relatedQuestions: ["Where do I pay a traffic fine?", "I got a suspicious SMS about payment, what now?"]),
        item(question: "How do I check if a website is an official Dutch institution site?", keywords: ["official domain", "real website"], category: .general, shortAnswer: "Check the exact domain and official references.", detailedAnswer: "Use known official domains and verify links from trusted pages. Avoid sharing personal data on websites you did not verify.", institution: nil, sourceName: "Government.nl", url: "https://www.government.nl", relatedQuestions: ["How do I avoid scam websites?", "How do I avoid fake DigiD websites?"]),
        item(question: "What should I do first after arriving in the Netherlands?", keywords: ["first steps", "arriving"], category: .general, shortAnswer: "Usually start with registration and document organization.", detailedAnswer: "First steps often include municipality registration, BSN-related follow-up, and checking health insurance requirements. Verify your profile-specific steps with official sources.", institution: nil, sourceName: "Government.nl", url: "https://www.government.nl", relatedQuestions: ["How do I register with municipality?", "How do I get a BSN?"]),
        item(question: "Where can I verify DigiD messages?", keywords: ["verify digid message", "digid scam"], category: .digid, shortAnswer: "Use the official DigiD website directly.", detailedAnswer: "If a message looks unusual, do not click embedded links. Open DigiD directly from the official domain and verify communication there.", institution: "DigiD", sourceName: "DigiD", url: "https://www.digid.nl/en", relatedQuestions: ["How do I avoid fake DigiD websites?", "What is DigiD?"]),
        item(question: "Where do I check official digital government messages?", keywords: ["mijnoverheid", "berichtenbox", "official letters", "digital mail", "government messages", "digid"], category: .digid, shortAnswer: "Use MijnOverheid Berichtenbox for official digital government mail.", detailedAnswer: "MijnOverheid can show digital messages from Dutch government organizations. Check sender and deadline details inside the official portal and avoid acting through unknown links in SMS or email.", institution: "MijnOverheid", sourceName: "MijnOverheid", url: "https://mijn.overheid.nl", relatedQuestions: ["What should I do with official letters?", "Where can I verify DigiD messages?"]),
        item(question: "Do I need to keep copies of official letters?", keywords: ["keep copies", "official letters"], category: .general, shortAnswer: "Yes, keeping organized copies is usually helpful.", detailedAnswer: "Keeping copies of letters, confirmations, and references can help with follow-up questions and deadlines. Use secure personal storage habits.", institution: nil, sourceName: "Government.nl", url: "https://www.government.nl", relatedQuestions: ["What should I do with official letters?", "How do I verify if a government letter is real?"])
    ]

    private static let newcomerFAQ: [SearchAnswer] = [
        SearchAnswer(
            id: SearchAnswer.stableID("search-answer:how-do-i-get-a-bsn"),
            titleByLanguage: [
                .english: "How do I get a BSN?",
                .dutch: "Hoe krijg ik een BSN?",
                .russian: "Как получить BSN?"
            ],
            keywordsByLanguage: [
                .english: ["how get bsn", "bsn", "citizen service number"],
                .dutch: ["hoe bsn krijgen", "bsn nummer", "burgerservicenummer"],
                .russian: ["как получить bsn", "bsn получить", "номер bsn"]
            ],
            category: .registration,
            shortAnswerByLanguage: [
                .english: "You usually receive a BSN after registering your address with the municipality.",
                .dutch: "Je ontvangt meestal een BSN na registratie van je adres bij de gemeente.",
                .russian: "BSN обычно присваивают после регистрации адреса в gemeente."
            ],
            detailedAnswerByLanguage: [
                .english: "Register your address first. In most cities the BSN is issued as part of that process or via a separate appointment. Check the exact steps on your municipality's official website.",
                .dutch: "Registreer eerst je adres. In de meeste steden wordt het BSN verstrekt als onderdeel van dat proces of via een aparte afspraak. Controleer de exacte stappen op de officiële website van je gemeente.",
                .russian: "Сначала зарегистрируйте адрес проживания. В большинстве городов BSN выдаётся в рамках этого процесса или после отдельной записи. Проверьте шаги вашей gemeente на официальном сайте."
            ],
            relatedInstitution: "Municipality",
            officialSourceName: "Government.nl",
            officialSourceURL: AppURL.make("https://www.government.nl/topics/personal-data/citizen-service-number-bsn"),
            isOfficialSource: true,
            safetyNote: defaultSafety,
            lastUpdated: Date(timeIntervalSince1970: 1716163200),
            relatedQuestions: ["How do I register with municipality?", "What is DigiD?"],
            relatedInstitutionNames: ["Municipality"],
            nextRecommendedStep: defaultNextStep(for: .registration)
        ),
        SearchAnswer(
            id: SearchAnswer.stableID("search-answer:where-is-my-bsn-used"),
            titleByLanguage: [
                .english: "Where is my BSN used?",
                .dutch: "Waar wordt mijn BSN gebruikt?",
                .russian: "Где используется мой BSN?"
            ],
            keywordsByLanguage: [
                .english: ["bsn used", "share bsn", "citizen service number safety", "employer bsn", "bank bsn"],
                .dutch: ["bsn gebruiken", "bsn delen", "burgerservicenummer veilig", "werkgever bsn", "bank bsn"],
                .russian: ["где используется bsn", "передавать bsn", "безопасность bsn", "bsn работодатель", "bsn банк"]
            ],
            category: .digid,
            shortAnswerByLanguage: [
                .english: "A BSN is used by government services and some organizations that need it for official administration.",
                .dutch: "Een BSN wordt gebruikt door overheidsdiensten en sommige organisaties die het nodig hebben voor officiële administratie.",
                .russian: "BSN используют госслужбы и некоторые организации, которым он нужен для официального администрирования."
            ],
            detailedAnswerByLanguage: [
                .english: "You may need a BSN for government services, tax, healthcare, education, employment administration, and some banking processes. Treat it as sensitive personal data: share it only when there is a legitimate reason and you are using an official or verified channel.",
                .dutch: "U kunt een BSN nodig hebben voor overheid, belasting, zorg, onderwijs, loonadministratie en sommige bankprocessen. Behandel het als gevoelig persoonsgegeven: deel het alleen bij een geldige reden en via een officieel of gecontroleerd kanaal.",
                .russian: "BSN может понадобиться для госуслуг, налогов, медицины, образования, зарплатной администрации и некоторых банковских процессов. Считайте его чувствительными персональными данными: передавайте только при законной причине и через официальный или проверенный канал."
            ],
            relatedInstitution: "Government.nl",
            officialSourceName: "Government.nl",
            officialSourceURL: AppURL.make("https://www.government.nl/topics/personal-data/citizen-service-number-bsn"),
            isOfficialSource: true,
            safetyNote: defaultSafety,
            lastUpdated: Date(timeIntervalSince1970: 1781960745),
            relatedQuestions: ["How do I get a BSN?", "What is DigiD?", "Where do I check privacy or personal data rights?"],
            relatedInstitutionNames: ["Municipality", "Government.nl"],
            nextRecommendedStep: "Open the official BSN source and verify why an organization is asking before sharing your number."
        ),
        SearchAnswer(
            id: SearchAnswer.stableID("search-answer:what-is-digid"),
            titleByLanguage: [
                .english: "What is DigiD?",
                .dutch: "Wat is DigiD?",
                .russian: "Что такое DigiD?"
            ],
            keywordsByLanguage: [
                .english: ["digid", "digital login", "government login"],
                .dutch: ["digid", "digitaal inloggen", "wat is digid"],
                .russian: ["digid", "что такое digid", "дигид", "цифровой логин"]
            ],
            category: .digid,
            shortAnswerByLanguage: [
                .english: "DigiD is a secure digital login for many Dutch government services.",
                .dutch: "DigiD is een beveiligde digitale inlogmethode voor veel overheidsdiensten.",
                .russian: "DigiD — безопасный вход в государственные онлайн-сервисы Нидерландов."
            ],
            detailedAnswerByLanguage: [
                .english: "DigiD is used to access Belastingdienst, DUO, UWV, and other official portals. Keep your login details private and always use official DigiD domains only.",
                .dutch: "DigiD wordt gebruikt om in te loggen bij Belastingdienst, DUO, UWV en andere portalen. Houd je gegevens privé en gebruik altijd officiële DigiD-domeinen.",
                .russian: "Через DigiD вы входите в кабинеты Belastingdienst, DUO, UWV и другие сервисы. Используйте только официальный сайт и не передавайте коды подтверждения."
            ],
            relatedInstitution: "DigiD",
            officialSourceName: "DigiD",
            officialSourceURL: AppURL.make("https://www.digid.nl/en"),
            isOfficialSource: true,
            safetyNote: nil,
            lastUpdated: Date(timeIntervalSince1970: 1716163200),
            relatedQuestions: ["How do I activate DigiD?", "How do I avoid fake DigiD websites?"],
            relatedInstitutionNames: ["DigiD"],
            nextRecommendedStep: defaultNextStep(for: .digid)
        ),
        SearchAnswer(
            id: SearchAnswer.stableID("search-answer:how-do-dutch-fines-work"),
            titleByLanguage: [
                .english: "How do Dutch fines work?",
                .dutch: "Hoe werken boetes in Nederland?",
                .russian: "Как работают штрафы в Нидерландах?"
            ],
            keywordsByLanguage: [
                .english: ["dutch fines", "cjib", "traffic fine", "payment notice"],
                .dutch: ["boetes nederland", "cjib", "verkeersboete", "betalingskenmerk"],
                .russian: ["штрафы нидерланды", "cjib", "как работают штрафы", "оплата штрафа"]
            ],
            category: .fines,
            shortAnswerByLanguage: [
                .english: "Many official fines are handled by CJIB with clear payment or objection deadlines.",
                .dutch: "Veel officiële boetes worden behandeld door CJIB met duidelijke betaal- of bezwaartermijnen.",
                .russian: "Многие официальные штрафы обрабатывает CJIB с чёткими сроками оплаты или обжалования."
            ],
            detailedAnswerByLanguage: [
                .english: "Check the sender, reference number, and deadline in your letter. Never pay via unknown links from SMS or WhatsApp — verify everything directly on cjib.nl.",
                .dutch: "Controleer de afzender, het kenmerk en de deadline in de brief. Betaal nooit via onbekende links uit sms of WhatsApp — verifieer alles via cjib.nl.",
                .russian: "Проверьте отправителя, reference и дедлайн в письме. Не платите по случайным ссылкам из SMS или WhatsApp — сверяйте всё только на cjib.nl."
            ],
            relatedInstitution: "CJIB",
            officialSourceName: "CJIB",
            officialSourceURL: AppURL.make("https://www.cjib.nl/en"),
            isOfficialSource: true,
            safetyNote: defaultSafety,
            lastUpdated: Date(timeIntervalSince1970: 1716163200),
            relatedQuestions: ["What is CJIB?", "I got a suspicious SMS about payment, what now?"],
            relatedInstitutionNames: ["CJIB"],
            nextRecommendedStep: defaultNextStep(for: .fines)
        ),
        SearchAnswer(
            id: SearchAnswer.stableID("search-answer:what-should-i-do-with-official-letters"),
            titleByLanguage: [
                .english: "What should I do with official letters?",
                .dutch: "Wat moet ik doen met officiële brieven?",
                .russian: "Что делать с официальными письмами?"
            ],
            keywordsByLanguage: [
                .english: ["official letters", "government letters", "letter action"],
                .dutch: ["officiële brieven", "overheidsbrief", "brief actie"],
                .russian: ["официальные письма", "письма от государства", "письмо действие"]
            ],
            category: .general,
            shortAnswerByLanguage: [
                .english: "Open the letter immediately and check: the sender, date, deadline, and required action.",
                .dutch: "Open de brief direct en controleer: afzender, datum, deadline en vereiste actie.",
                .russian: "Откройте письмо сразу и проверьте: отправителя, дату, дедлайн и требуемое действие."
            ],
            detailedAnswerByLanguage: [
                .english: "If the letter is unclear, look up the topic on the official website of the institution. For complex cases, Juridisch Loket can provide initial legal orientation.",
                .dutch: "Als de brief onduidelijk is, zoek het onderwerp op de officiële website van de instantie. Voor complexe gevallen kan Juridisch Loket helpen met juridische oriëntatie.",
                .russian: "Если письмо непонятно, найдите эту тему на официальном сайте ведомства. Для сложных случаев используйте Juridisch Loket как стартовую юридическую ориентацию."
            ],
            relatedInstitution: "Government.nl",
            officialSourceName: "Government.nl",
            officialSourceURL: AppURL.make("https://www.government.nl"),
            isOfficialSource: true,
            safetyNote: nil,
            lastUpdated: Date(timeIntervalSince1970: 1716163200),
            relatedQuestions: ["How do Dutch tax letters work?", "Where can I get legal help about letters?"],
            relatedInstitutionNames: ["Government.nl"],
            nextRecommendedStep: defaultNextStep(for: .general)
        ),
        SearchAnswer(
            id: SearchAnswer.stableID("search-answer:how-does-health-insurance-work"),
            titleByLanguage: [
                .english: "How does health insurance work?",
                .dutch: "Hoe werkt zorgverzekering?",
                .russian: "Как работает медицинская страховка?"
            ],
            keywordsByLanguage: [
                .english: ["health insurance", "zorgverzekering", "insurance mandatory"],
                .dutch: ["zorgverzekering", "basisverzekering", "zorgtoeslag"],
                .russian: ["медицинская страховка", "zorgverzekering", "страхование обязательно"]
            ],
            category: .healthInsurance,
            shortAnswerByLanguage: [
                .english: "Basic health insurance is mandatory for many residents; timing depends on your situation.",
                .dutch: "Basisverzekering is verplicht voor veel bewoners; de timing hangt af van je situatie.",
                .russian: "Для многих жителей базовая медстраховка обязательна; сроки зависят от вашей ситуации."
            ],
            detailedAnswerByLanguage: [
                .english: "Check the start date of your insurance obligation, then choose a policy and verify eligibility for zorgtoeslag if applicable. For non-urgent care, contact your huisarts first.",
                .dutch: "Controleer de startdatum van je verzekeringsplicht, kies een polis en bekijk of je recht hebt op zorgtoeslag. Voor niet-spoedeisende zorg raadpleeg je eerst je huisarts.",
                .russian: "Проверьте дату начала обязанности страхования, затем выберите полис и при необходимости проверьте право на zorgtoeslag. Для неэкстренной помощи сначала обращаются к huisarts."
            ],
            relatedInstitution: "Government.nl",
            officialSourceName: "Government.nl",
            officialSourceURL: AppURL.make("https://www.government.nl/topics/health-insurance"),
            isOfficialSource: true,
            safetyNote: nil,
            lastUpdated: Date(timeIntervalSince1970: 1716163200),
            relatedQuestions: ["Do I need health insurance?", "How quickly should I arrange health insurance?"],
            relatedInstitutionNames: ["Government.nl"],
            nextRecommendedStep: defaultNextStep(for: .healthInsurance)
        ),
        SearchAnswer(
            id: SearchAnswer.stableID("search-answer:what-is-cjib"),
            titleByLanguage: [
                .english: "What is CJIB?",
                .dutch: "Wat is CJIB?",
                .russian: "Что такое CJIB?"
            ],
            keywordsByLanguage: [
                .english: ["cjib", "fines agency", "payment notices"],
                .dutch: ["cjib", "boetesinning", "betalingskenmerk"],
                .russian: ["cjib", "что такое cjib", "служба штрафов"]
            ],
            category: .fines,
            shortAnswerByLanguage: [
                .english: "CJIB is a government agency that handles many official fines and payment notices.",
                .dutch: "CJIB is een overheidsinstantie die veel officiële boetes en betalingsberichten verwerkt.",
                .russian: "CJIB — государственная служба, которая ведёт многие официальные штрафы и платёжные уведомления."
            ],
            detailedAnswerByLanguage: [
                .english: "If you receive a letter from CJIB, check the reference number and deadline first. Confirm details only via the official cjib.nl website.",
                .dutch: "Als je een brief van CJIB ontvangt, controleer dan het briefkenmerk en de deadline. Bevestig details alleen via de officiële website cjib.nl.",
                .russian: "Если вы получили письмо от CJIB, сначала проверьте номер письма и срок. Подтверждайте детали только через официальный сайт."
            ],
            relatedInstitution: "CJIB",
            officialSourceName: "CJIB",
            officialSourceURL: AppURL.make("https://www.cjib.nl/en"),
            isOfficialSource: true,
            safetyNote: defaultSafety,
            lastUpdated: Date(timeIntervalSince1970: 1716163200),
            relatedQuestions: ["How do Dutch fines work?", "Where do I pay a traffic fine?"],
            relatedInstitutionNames: ["CJIB"],
            nextRecommendedStep: defaultNextStep(for: .fines)
        ),
        SearchAnswer(
            id: SearchAnswer.stableID("search-answer:how-do-i-contact-my-gemeente"),
            titleByLanguage: [
                .english: "How do I contact my gemeente?",
                .dutch: "Hoe neem ik contact op met mijn gemeente?",
                .russian: "Как связаться с gemeente?"
            ],
            keywordsByLanguage: [
                .english: ["contact municipality", "gemeente contact", "city hall"],
                .dutch: ["gemeente contact opnemen", "gemeentehuis", "afspraak gemeente"],
                .russian: ["как связаться с gemeente", "муниципалитет контакт", "запись в gemeente"]
            ],
            category: .registration,
            shortAnswerByLanguage: [
                .english: "Contact your gemeente through the official city website and the appointments/contact section.",
                .dutch: "Neem contact op via de officiële gemeentewebsite en de afdeling afspraken/contact.",
                .russian: "Свяжитесь с вашей gemeente через официальный сайт города и раздел appointments/contact."
            ],
            detailedAnswerByLanguage: [
                .english: "Each city has its own portal and booking rules. Only use the official city domain and check the required document list before your appointment.",
                .dutch: "Elke gemeente heeft zijn eigen portaal en boekingsregels. Gebruik alleen het officiële domein van de stad en controleer de vereiste documenten vóór je afspraak.",
                .russian: "У каждого города свой портал и правила записи. Ищите только официальный домен города и сверяйте список документов перед приёмом."
            ],
            relatedInstitution: "Municipality",
            officialSourceName: "Government.nl",
            officialSourceURL: AppURL.make("https://www.government.nl/topics/municipalities"),
            isOfficialSource: true,
            safetyNote: nil,
            lastUpdated: Date(timeIntervalSince1970: 1716163200),
            relatedQuestions: ["How do I register with municipality?", "How do I find municipality appointment pages?"],
            relatedInstitutionNames: ["Municipality"],
            nextRecommendedStep: defaultNextStep(for: .registration)
        )
    ]

    private static let knowledgeBaseAnswers: [SearchAnswer] = MockExpansionData.knowledgeTopics.map { topic in
        SearchAnswer(
            id: topic.id,
            titleByLanguage: [
                .english: topic.title,
                .dutch: topic.title,
                .russian: russianTitle(for: topic.title)
            ],
            keywordsByLanguage: [
                .english: topic.tags + [topic.category, topic.officialSourceName],
                .dutch: topic.tags + [topic.category, topic.officialSourceName],
                .russian: topic.tags + russianKeywords(for: topic.title)
            ],
            category: searchCategory(for: topic.category),
            shortAnswerByLanguage: [
                .english: topic.summary,
                .dutch: topic.summary,
                .russian: topic.summary
            ],
            detailedAnswerByLanguage: [
                .english: topic.beginnerExplanation + "\n\nPractical steps:\n" + topic.practicalSteps.joined(separator: "\n"),
                .dutch: topic.beginnerExplanation + "\n\nPraktische stappen:\n" + topic.practicalSteps.joined(separator: "\n"),
                .russian: topic.beginnerExplanation + "\n\nПрактические шаги:\n" + topic.practicalSteps.joined(separator: "\n")
            ],
            relatedInstitution: topic.officialSourceName,
            officialSourceName: topic.officialSourceName,
            officialSourceURL: topic.officialSourceURL,
            isOfficialSource: topic.officialSourceName != "Juridisch Loket" && topic.officialSourceName != "Dutch Payments Association",
            safetyNote: topic.safetyDisclaimer,
            lastUpdated: topic.lastReviewed,
            relatedQuestions: topic.relatedQuestions,
            relatedInstitutionNames: [topic.officialSourceName],
            nextRecommendedStep: topic.practicalSteps.first,
            personaTags: topic.personaTags
        )
    }

    private static let lifeScenarioAnswers: [SearchAnswer] = MockExpansionData.lifeScenarios.map { scenario in
        SearchAnswer(
            id: scenario.id,
            titleByLanguage: [
                .english: scenario.title,
                .dutch: scenario.title,
                .russian: scenario.title
            ],
            keywordsByLanguage: [
                .english: [scenario.title, scenario.situation] + scenario.relatedTopics,
                .dutch: [scenario.title, scenario.situation] + scenario.relatedTopics,
                .russian: [scenario.title, scenario.situation] + scenario.relatedTopics
            ],
            category: .general,
            shortAnswerByLanguage: [
                .english: scenario.situation,
                .dutch: scenario.situation,
                .russian: scenario.situation
            ],
            detailedAnswerByLanguage: [
                .english: "First actions:\n" + scenario.firstActions.joined(separator: "\n") + "\n\nDocuments:\n" + scenario.documentsToPrepare.joined(separator: "\n"),
                .dutch: "Eerste acties:\n" + scenario.firstActions.joined(separator: "\n") + "\n\nDocumenten:\n" + scenario.documentsToPrepare.joined(separator: "\n"),
                .russian: "Первые действия:\n" + scenario.firstActions.joined(separator: "\n") + "\n\nДокументы:\n" + scenario.documentsToPrepare.joined(separator: "\n")
            ],
            relatedInstitution: scenario.officialSourceName,
            officialSourceName: scenario.officialSourceName,
            officialSourceURL: scenario.officialSourceURL,
            isOfficialSource: scenario.officialSourceName != "Juridisch Loket",
            safetyNote: defaultSafety,
            lastUpdated: Date(timeIntervalSince1970: 1772323200),
            relatedQuestions: scenario.relatedTopics,
            relatedInstitutionNames: [scenario.officialSourceName],
            nextRecommendedStep: scenario.firstActions.first,
            personaTags: scenario.personaTags
        )
    }

    private static func searchCategory(for category: String) -> SearchCategory {
        switch category {
        case "Registration": return .registration
        case "Digital Services": return .digid
        case "Money": return .general
        case "Healthcare": return .healthInsurance
        case "Housing": return .housing
        case "Transport": return .transport
        case "Taxes": return .taxes
        case "Work": return .work
        case "Daily Life", "Government": return .general
        default: return .general
        }
    }

    private static func russianTitle(for title: String) -> String {
        switch title {
        case "Registration & BSN": return "Регистрация и BSN"
        case "DigiD": return "DigiD"
        case "Banking": return "Банковский счёт"
        case "Health Insurance": return "Медицинская страховка"
        case "Housing & Rental Rights": return "Жильё и права арендатора"
        case "Transport & OV": return "Транспорт и OV"
        case "Bicycle Rules": return "Велосипедные правила"
        case "Taxes & Toeslagen": return "Налоги и toeslagen"
        case "Work Contracts & Payslips": return "Контракты и payslip"
        case "Healthcare Navigation": return "Как пользоваться медициной"
        case "Waste & Recycling": return "Мусор и переработка"
        case "Dutch Bureaucracy Explained": return "Голландская бюрократия"
        default: return title
        }
    }

    private static func russianKeywords(for title: String) -> [String] {
        switch title {
        case "Registration & BSN": return ["регистрация", "бсн", "муниципалитет", "gemeente"]
        case "DigiD": return ["дигид", "госуслуги", "цифровой вход"]
        case "Banking": return ["банк", "счет", "счёт", "iban", "tikkie"]
        case "Health Insurance": return ["страховка", "медстраховка", "eigen risico", "zorgtoeslag"]
        case "Housing & Rental Rights": return ["жильё", "аренда", "депозит", "договор аренды"]
        case "Transport & OV": return ["транспорт", "поезд", "ns", "ov", "9292"]
        case "Bicycle Rules": return ["велосипед", "штраф велосипед", "фонари", "телефон на велосипеде"]
        case "Taxes & Toeslagen": return ["налоги", "пособия", "toeslagen", "belastingdienst"]
        case "Work Contracts & Payslips": return ["работа", "контракт", "расчетный лист", "зарплата"]
        case "Healthcare Navigation": return ["врач", "huisarts", "аптека", "больница", "112"]
        case "Waste & Recycling": return ["мусор", "переработка", "afval", "контейнер"]
        case "Dutch Bureaucracy Explained": return ["бюрократия", "overheid", "официальное письмо"]
        default: return []
        }
    }

    static let popularQuestions: [String] = [
        "How do I get a BSN?",
        "What is DigiD?",
        "How do Dutch fines work?",
        "What should I do with official letters?",
        "How does health insurance work?",
        "What is CJIB?",
        "How do I contact my gemeente?",
        "How do Dutch tax letters work?",
        "Banking",
        "Housing & Rental Rights",
        "Healthcare Navigation",
        "Taxes & Toeslagen"
    ]
}
