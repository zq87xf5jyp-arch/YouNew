import Foundation

enum PersonaTag: String, CaseIterable, Codable, Hashable, Identifiable {
    case student
    case worker
    case refugee
    case family
    case tourist
    case entrepreneur
    case lgbt
    case eu
    case nonEU
    case highlySkilledMigrant
    case universal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .student: return "Student"
        case .worker: return "Worker"
        case .refugee: return "Refugee"
        case .family: return "Family"
        case .tourist: return "Tourist"
        case .entrepreneur: return "Entrepreneur"
        case .lgbt: return "LGBT Newcomer"
        case .eu: return "EU Citizen"
        case .nonEU: return "Non-EU"
        case .highlySkilledMigrant: return "Highly Skilled Migrant"
        case .universal: return "Universal"
        }
    }
}

enum PersonaSearchScope: String, CaseIterable, Codable, Hashable {
    case currentPersonaOnly
    case currentAndUniversal
    case allContentWithOutsidePathWarning
}

extension UserStatus {
    var personaTag: PersonaTag {
        switch self {
        case .student: return .student
        case .worker: return .worker
        case .refugee, .ukrainian: return .refugee
        case .expat, .highlySkilledMigrant: return .highlySkilledMigrant
        case .euCitizen: return .eu
        case .family: return .family
        case .tourist: return .tourist
        case .entrepreneur: return .entrepreneur
        case .lgbtNewcomer: return .lgbt
        }
    }
}

enum PersonaContentPolicy {
    nonisolated static func assignedTags(
        explicitTags: Set<PersonaTag> = [],
        category: String,
        title: String,
        summary: String,
        keywords: [String],
        sources: [OfficialSource]
    ) -> Set<PersonaTag> {
        if !explicitTags.isEmpty { return explicitTags }
        let inferred = inferredTags(category: category, title: title, summary: summary, keywords: keywords, sources: sources)
        return inferred.isEmpty ? [.universal] : inferred
    }

    nonisolated static func inferredTags(
        category: String,
        title: String,
        summary: String,
        keywords: [String],
        sources: [OfficialSource]
    ) -> Set<PersonaTag> {
        let haystack = ([category, title, summary] + keywords + sources.flatMap { [$0.title, $0.institution ?? ""] })
            .joined(separator: " ")
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()

        var tags = Set<PersonaTag>()
        func add(_ tag: PersonaTag, when needles: [String]) {
            if needles.contains(where: { haystack.contains($0) }) {
                tags.insert(tag)
            }
        }

        add(.student, when: ["student", "duo", "university", "universities", "mbo", "hbo", "research university", "study", "studying", "student housing", "student finance", "student job", "library", "libraries"])
        add(.worker, when: ["work", "worker", "uwv", "contract", "salary", "payslip", "loonstrook", "employment", "job", "pension", "training"])
        add(.refugee, when: ["refugee", "asylum", "status holder", "statusholder", "coa", "ind", "integration", "inburgering", "work permission", "support organization"])
        add(.family, when: ["family", "child", "children", "school", "childcare", "kinderopvang", "svb", "child benefit", "activities"])
        add(.tourist, when: ["tourist", "temporary stay", "visa", "accommodation", "lost passport", "attractions", "museum"])
        add(.entrepreneur, when: ["entrepreneur", "business", "kvk", "vat", "btw", "startup", "self-employed", "zzp", "permit"])
        add(.lgbt, when: ["lgbt", "lgbtq", "queer", "discrimination", "pride"])
        add(.eu, when: ["eu citizen", "european union", "eu/eea", "eea"])
        add(.nonEU, when: ["non-eu", "non eu", "residence permit", "recognized sponsor", "sponsor", "ind"])
        add(.highlySkilledMigrant, when: ["highly skilled", "kennismigrant", "recognized sponsor", "30% ruling", "30%-regeling", "expat"])

        if tags.isEmpty, ["emergency", "healthcare", "housing", "transport", "documents", "municipality", "government", "official sources"].contains(where: { haystack.contains($0) }) {
            tags.insert(.universal)
        }

        return tags
    }

    nonisolated static func isVisible(tags: Set<PersonaTag>, activePersona: PersonaTag?, scope: PersonaSearchScope) -> Bool {
        true
    }

    nonisolated static func isOutsidePersonaQuery(_ query: String, for persona: PersonaTag?) -> Bool {
        false
    }

    nonisolated static func sanitizedPendingAIPrompt(_ prompt: String, context: AIContext) -> String {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed
    }

    private nonisolated static func containsOutsidePersonaTerms(_ prompt: String, for persona: PersonaTag) -> Bool {
        let normalized = prompt
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
        let words = normalized
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        let paddedText = " \(words.joined(separator: " ")) "

        return outsidePersonaTerms(for: persona).contains { term in
            let normalizedTerm = term
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
                .lowercased()
            let termWords = normalizedTerm
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }
            guard !termWords.isEmpty else { return false }
            if termWords.count == 1 {
                return words.contains(termWords[0])
            }
            return paddedText.contains(" \(termWords.joined(separator: " ")) ")
        }
    }

    private nonisolated static func outsidePersonaTerms(for persona: PersonaTag) -> [String] {
        switch persona {
        case .student:
            return ["uwv", "work contract", "employment rights", "pension", "worker training", "belastingdienst", "tax", "taxes", "ind", "refugee", "asylum", "benefits", "work permission", "svb", "child benefit", "kinderopvang", "cjib", "fine"]
        case .worker:
            return ["duo", "university", "mbo", "hbo", "student housing", "student finance", "student insurance", "student discount", "ind asylum", "refugee", "coa", "svb", "child benefit", "kinderopvang"]
        case .refugee:
            return ["duo", "university", "mbo", "hbo", "student finance", "student insurance", "uwv", "salary", "pension", "worker training", "svb", "child benefit", "startup", "kvk", "btw"]
        case .family:
            return ["duo", "university", "mbo", "hbo", "student finance", "student jobs", "uwv", "salary", "pension", "worker training", "ind asylum", "refugee", "startup", "kvk"]
        case .tourist:
            return ["duo", "student finance", "uwv", "salary", "pension", "integration", "inburgering", "svb", "child benefit", "kvk", "btw"]
        case .entrepreneur:
            return ["duo", "student finance", "uwv", "salary", "pension", "ind asylum", "refugee", "svb", "child benefit", "kinderopvang"]
        case .lgbt:
            return ["duo", "student finance", "uwv", "salary", "pension", "svb", "child benefit", "kvk", "btw"]
        case .eu:
            return ["duo", "student finance", "ind asylum", "refugee", "coa", "svb", "child benefit", "kvk", "btw"]
        case .nonEU, .highlySkilledMigrant:
            return ["duo", "student finance", "ind asylum", "refugee", "coa", "svb", "child benefit", "kinderopvang"]
        case .universal:
            return []
        }
    }

    private nonisolated static func defaultAIPrompt(for persona: PersonaTag, language: AppLanguage) -> String {
        switch (persona, language) {
        case (.student, .english):
            return "Help me with my student path: DUO, universities, student housing, insurance, transport discounts, Dutch courses, student jobs, libraries, communities, events, study spaces, city life, and free time."
        case (.student, .dutch):
            return "Help mij met mijn studentenpad: DUO, universiteiten, studentenhuisvesting, verzekering, vervoerskortingen, Nederlandse taalcursussen, studentenbanen, bibliotheken, communities, events, studieplekken, stadsleven en vrije tijd."
        case (.student, .russian):
            return "Помогите мне со студенческим маршрутом: DUO, университеты, студенческое жилье, страховка, скидки на транспорт, курсы нидерландского, студенческая работа, библиотеки, сообщества, события, места для учебы, городская жизнь и свободное время."
        case (.worker, .english):
            return "Help me with my worker path: BSN, DigiD, work contracts, taxes, UWV, salary, employment rights, health insurance, housing, transport, pension, and worker training."
        case (.worker, .dutch):
            return "Help mij met mijn werkpad: BSN, DigiD, arbeidscontracten, belasting, UWV, salaris, arbeidsrechten, zorgverzekering, wonen, vervoer, pensioen en scholing."
        case (.worker, .russian):
            return "Помогите мне с рабочим маршрутом: BSN, DigiD, трудовые договоры, налоги, UWV, зарплата, трудовые права, медицинская страховка, жилье, транспорт, пенсия и обучение."
        case (.refugee, .english):
            return "Help me with my refugee path: IND, municipality, housing, benefits, integration, language, healthcare, documents, work permissions, education access, and support organizations."
        case (.refugee, .dutch):
            return "Help mij met mijn vluchtelingenpad: IND, gemeente, huisvesting, uitkeringen, inburgering, taal, zorg, documenten, werkvergunningen, toegang tot onderwijs en hulporganisaties."
        case (.refugee, .russian):
            return "Помогите мне с маршрутом беженца: IND, муниципалитет, жилье, пособия, интеграция, язык, здравоохранение, документы, разрешение на работу, доступ к образованию и организации поддержки."
        case (.family, .english):
            return "Help me with my family path: schools, childcare, kinderopvang, SVB, child benefits, family housing, healthcare, activities, and municipal services."
        case (.family, .dutch):
            return "Help mij met mijn gezinspad: scholen, kinderopvang, SVB, kinderbijslag, gezinswoning, zorg, activiteiten en gemeentelijke diensten."
        case (.family, .russian):
            return "Помогите мне с семейным маршрутом: школы, детский сад, kinderopvang, SVB, детские пособия, семейное жилье, здравоохранение, занятия и муниципальные услуги."
        case (.tourist, .english):
            return "Help me with my tourist path: visa or stay rules, accommodation, transport, emergency help, healthcare access, lost documents, attractions, and local services."
        case (.tourist, .dutch):
            return "Help mij met mijn toeristenpad: visum- of verblijfsregels, accommodatie, vervoer, noodhulp, toegang tot zorg, verloren documenten, attracties en lokale diensten."
        case (.tourist, .russian):
            return "Помогите мне с туристическим маршрутом: правила визы или пребывания, жилье, транспорт, экстренная помощь, доступ к медицине, потерянные документы, достопримечательности и местные службы."
        case (.entrepreneur, .english):
            return "Help me with my entrepreneur path: KVK, business registration, permits, VAT, banking, insurance, housing, transport, and local business support."
        case (.entrepreneur, .dutch):
            return "Help mij met mijn ondernemerspad: KVK, bedrijfsregistratie, vergunningen, btw, bankzaken, verzekering, wonen, vervoer en lokale ondernemershulp."
        case (.entrepreneur, .russian):
            return "Помогите мне с предпринимательским маршрутом: KVK, регистрация бизнеса, разрешения, VAT/BTW, банк, страховка, жилье, транспорт и местная поддержка бизнеса."
        case (.lgbt, .english):
            return "Help me with my LGBT newcomer path: safety, healthcare, legal protection, housing, community support, discrimination help, language, and trusted services."
        case (.lgbt, .dutch):
            return "Help mij met mijn LGBT-nieuwkomerspad: veiligheid, zorg, juridische bescherming, huisvesting, community support, hulp bij discriminatie, taal en betrouwbare diensten."
        case (.lgbt, .russian):
            return "Помогите мне с маршрутом LGBT-новичка: безопасность, здравоохранение, правовая защита, жилье, поддержка сообщества, помощь при дискриминации, язык и надежные службы."
        case (.eu, .english):
            return "Help me with my EU citizen path: registration, BSN, DigiD, health insurance, housing, work rules, transport, and municipal services."
        case (.eu, .dutch):
            return "Help mij met mijn EU-burgerpad: inschrijving, BSN, DigiD, zorgverzekering, wonen, werkregels, vervoer en gemeentelijke diensten."
        case (.eu, .russian):
            return "Помогите мне с маршрутом гражданина ЕС: регистрация, BSN, DigiD, медицинская страховка, жилье, правила работы, транспорт и муниципальные услуги."
        case (.nonEU, .english), (.highlySkilledMigrant, .english):
            return "Help me with my highly skilled migrant path: IND, recognized sponsor, residence permit, BSN, DigiD, 30% ruling, housing, healthcare, taxes, and work rights."
        case (.nonEU, .dutch), (.highlySkilledMigrant, .dutch):
            return "Help mij met mijn kennismigrantenpad: IND, erkend referent, verblijfsvergunning, BSN, DigiD, 30%-regeling, wonen, zorg, belasting en werkrechten."
        case (.nonEU, .russian), (.highlySkilledMigrant, .russian):
            return "Помогите мне с маршрутом высококвалифицированного мигранта: IND, признанный спонсор, вид на жительство, BSN, DigiD, 30% ruling, жилье, медицина, налоги и трудовые права."
        case (.universal, .english):
            return "Help me with the next practical step for my move to the Netherlands."
        case (.universal, .dutch):
            return "Help mij met de volgende praktische stap voor mijn verhuizing naar Nederland."
        case (.universal, .russian):
            return "Помогите мне со следующим практическим шагом для переезда в Нидерланды."
        }
    }
}
