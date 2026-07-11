import Foundation
import Combine

enum NetherlandsSearchResultKind {
    case city
    case province
    case country
}

struct NetherlandsSearchResult: Identifiable {
    let id: String
    let kind: NetherlandsSearchResultKind
    let city: NLCity?
    let province: NLProvince?

    static func city(_ city: NLCity) -> NetherlandsSearchResult {
        NetherlandsSearchResult(id: "nl-city-\(city.id)", kind: .city, city: city, province: nil)
    }

    static func province(_ province: NLProvince) -> NetherlandsSearchResult {
        NetherlandsSearchResult(id: "nl-province-\(province.id)", kind: .province, city: nil, province: province)
    }

    static var country: NetherlandsSearchResult {
        NetherlandsSearchResult(id: "country-netherlands", kind: .country, city: nil, province: nil)
    }
}

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var language: AppLanguage {
        didSet {
            scheduleSearchRefresh(immediate: true)
        }
    }
    @Published var query = "" {
        didSet {
            alignCategoryWithExplicitQuery()
            scheduleSearchRefresh(immediate: query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
    @Published var selectedCategory: SearchCategory? = nil {
        didSet {
            guard !isAligningCategoryWithQuery else { return }
            refreshSearchResults()
        }
    }
    @Published var activePersona: PersonaTag? {
        didSet {
            if let selectedCategory, !selectedCategory.isVisible(for: activePersona) {
                self.selectedCategory = nil
            }
            refreshSearchState()
        }
    }
    @Published var personaSearchScope: PersonaSearchScope {
        didSet {
            refreshSearchState()
        }
    }
    @Published var recentSearches: [String] = []
    @Published private(set) var netherlandsResults: [NetherlandsSearchResult] = []
    @Published private(set) var displayedResults: [SearchAnswer] = []
    @Published private(set) var beginnerGuideResults: [BeginnerGuideItem] = []

    private let recentKey = "question_search_recent_v1"
    private let allAnswers = MockSearchAnswersData.items
    private var searchRefreshTask: Task<Void, Never>?
    private var isAligningCategoryWithQuery = false

    init(
        initialQuery: String = "",
        language: AppLanguage = .english,
        activePersona: PersonaTag? = nil,
        personaSearchScope: PersonaSearchScope = .currentAndUniversal
    ) {
        self.query = initialQuery
        self.language = language
        self.activePersona = activePersona
        self.personaSearchScope = personaSearchScope
        recentSearches = UserDefaults.standard.stringArray(forKey: recentKey) ?? []
        refreshSearchState()
    }

    deinit {
        searchRefreshTask?.cancel()
    }

    var popularQuestions: [SearchAnswer] {
        MockSearchAnswersData.popularQuestions.compactMap { q in
            personaFilteredAnswers(allAnswers).first(where: { $0.question.caseInsensitiveCompare(q) == .orderedSame })
        }
    }

    var visibleCategories: [SearchCategory] {
        SearchCategory.allCases.filter { $0.isVisible(for: activePersona) }
    }

    private func filteredResults() -> [SearchAnswer] {
        var base = personaFilteredAnswers(allAnswers)
        if let selectedCategory { base = base.filter { $0.category == selectedCategory } }

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return [] }
        if personaSearchScope != .allContentWithOutsidePathWarning,
           PersonaContentPolicy.isOutsidePersonaQuery(trimmed, for: activePersona) {
            return []
        }
        let q = trimmed.lowercased()

        let scored: [(answer: SearchAnswer, score: Int)] = base.map { answer in
            (answer: answer, score: relevanceScore(answer: answer, query: q))
        }

        let relevant = scored.filter { $0.score > 0 }

        let sorted = relevant.sorted { lhs, rhs in
            if lhs.score == rhs.score {
                return lhs.answer.title(language) < rhs.answer.title(language)
            }
            return lhs.score > rhs.score
        }

        return sorted.map(\.answer)
    }

    private func makeDisplayedResults() -> [SearchAnswer] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            if let selectedCategory {
                return personaFilteredAnswers(allAnswers).filter { $0.category == selectedCategory }.sorted { $0.title(language) < $1.title(language) }
            }
            return []
        }
        return filteredResults()
    }

    var beginnerGuidePopular: [BeginnerGuideItem] {
        MockBeginnerGuidesData.featuredItems.filter { $0.isVisible(for: activePersona, scope: personaSearchScope) }
    }

    private func personaFilteredAnswers(_ answers: [SearchAnswer]) -> [SearchAnswer] {
        answers.filter { $0.isVisible(for: activePersona, scope: personaSearchScope) }
    }

    func performSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        refreshSearchState()
        guard !trimmed.isEmpty else { return }
        recentSearches = [trimmed] + recentSearches.filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        recentSearches = Array(recentSearches.prefix(8))
        UserDefaults.standard.set(recentSearches, forKey: recentKey)
    }

    func setQuery(_ value: String) {
        query = value
        performSearch()
    }

    private func refreshSearchState() {
        refreshNetherlandsResults()
        refreshSearchResults()
        refreshBeginnerGuideResults()
    }

    private func alignCategoryWithExplicitQuery() {
        guard !isAligningCategoryWithQuery else { return }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2, let inferredCategory = inferredCategory(for: trimmed) else { return }
        guard inferredCategory.isVisible(for: activePersona) else { return }
        guard selectedCategory != inferredCategory else { return }

        isAligningCategoryWithQuery = true
        selectedCategory = inferredCategory
        isAligningCategoryWithQuery = false
    }

    private func scheduleSearchRefresh(immediate: Bool = false) {
        searchRefreshTask?.cancel()

        if immediate {
            refreshSearchState()
            return
        }

        searchRefreshTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 220_000_000)
            guard !Task.isCancelled else { return }
            self?.refreshSearchState()
        }
    }

    private func refreshSearchResults() {
        displayedResults = makeDisplayedResults()
    }

    private func refreshBeginnerGuideResults() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            beginnerGuideResults = []
            return
        }
        if inferredCategory(for: trimmed) == .fines {
            beginnerGuideResults = uniqueBeginnerGuideItems(beginnerGuideCategories(for: .fines)
                .flatMap {
                    MockBeginnerGuidesData.search(
                        trimmed,
                        language: language,
                        category: $0,
                        activePersona: activePersona,
                        scope: personaSearchScope
                    )
                }
            )
            return
        }
        if let selectedCategory,
           !beginnerGuideCategories(for: selectedCategory).isEmpty {
            beginnerGuideResults = uniqueBeginnerGuideItems(beginnerGuideCategories(for: selectedCategory)
                .flatMap {
                    MockBeginnerGuidesData.search(
                        trimmed,
                        language: language,
                        category: $0,
                        activePersona: activePersona,
                        scope: personaSearchScope
                    )
                }
            )
            return
        }
        beginnerGuideResults = MockBeginnerGuidesData.search(
            query,
            language: language,
            activePersona: activePersona,
            scope: personaSearchScope
        )
    }

    private func uniqueBeginnerGuideItems(_ items: [BeginnerGuideItem]) -> [BeginnerGuideItem] {
        var seen = Set<UUID>()
        return items.filter { item in
            seen.insert(item.id).inserted
        }
    }

    private func refreshNetherlandsResults() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            netherlandsResults = []
            return
        }

        let q = trimmed.lowercased()
        var results: [NetherlandsSearchResult] = []

        results += NLCity.all
            .filter { city in
                explicitGeographyMatch(
                    q,
                    values: [city.name, city.province] + city.facts.map(\.value)
                )
            }
            .map(NetherlandsSearchResult.city)

        results += NLProvince.all
            .filter { province in
                explicitGeographyMatch(
                    q,
                    values: [province.name, province.id, province.capital]
                )
            }
            .map(NetherlandsSearchResult.province)

        if NetherlandsCountry.name.lowercased().contains(q) ||
            NetherlandsCountry.tagline.lowercased().contains(q) ||
            NetherlandsCountry.overview.lowercased().contains(q) ||
            NetherlandsCountry.capital.lowercased().contains(q) ||
            NetherlandsCountry.government.lowercased().contains(q) ||
            NetherlandsCountry.fastFacts.contains(where: { fact in
                fact.title.lowercased().contains(q) ||
                fact.value.lowercased().contains(q)
            }) {
            results.append(.country)
        }

        netherlandsResults = results
    }

    private func relevanceScore(answer: SearchAnswer, query: String) -> Int {
        let normalizedQuery = normalizeSearchText(query)
        let question = normalizeSearchText(answer.title(language).lowercased())
        let short = normalizeSearchText(answer.shortAnswer(language).lowercased())
        let institution = normalizeSearchText(answer.relatedInstitution?.lowercased() ?? "")

        if question == normalizedQuery { return 100 }
        if isFineIntentQuery(normalizedQuery),
           !answerMatchesFineIntent(answer, query: normalizedQuery, question: question, institution: institution) {
            return 0
        }
        if isDutchCourseIntentQuery(normalizedQuery),
           !answerMatchesDutchCourseIntent(answer, question: question, institution: institution) {
            return 0
        }

        var score = 0
        if question.contains(normalizedQuery) { score += 70 }
        let multilingualKeywords = AppLanguage.allCases.flatMap { answer.keywords($0) }
        if multilingualKeywords.contains(where: {
            let keyword = normalizeSearchText($0.lowercased())
            return keyword.contains(normalizedQuery) || normalizedQuery.contains(keyword)
        }) { score += 45 }
        if institution.contains(normalizedQuery) { score += 30 }
        if normalizeSearchText(answer.category.rawValue.lowercased()).contains(normalizedQuery) ||
            normalizeSearchText(answer.category.localized(language).lowercased()).contains(normalizedQuery) { score += 25 }
        if short.contains(normalizedQuery) { score += 20 }
        let detail = normalizeSearchText(answer.detailedAnswer(language).lowercased())
        if detail.contains(normalizedQuery) { score += 10 }
        if answer.relatedQuestions.contains(where: { normalizeSearchText($0.lowercased()).contains(normalizedQuery) }) { score += 5 }
        if score == 0,
           normalizedQuery.count >= 5,
           normalizedQuery.count <= 40 {
            let fuzzyText = [question, short, institution, multilingualKeywords.joined(separator: " ")]
                .map(normalizeSearchText)
                .joined(separator: " ")
            if fuzzyTokenMatch(query: normalizedQuery, in: fuzzyText) { score += 18 }
        }

        return score
    }

    private func isFineIntentQuery(_ query: String) -> Bool {
        ["fine", "fines", "boete", "boetes", "cjib", "штраф", "штрафы"].contains(query)
    }

    private func isDutchCourseIntentQuery(_ query: String) -> Bool {
        let compact = query.replacingOccurrences(of: " ", with: "")
        return query == "dutch a1" ||
            query == "dutch a1 a2" ||
            query == "dutch a1-a2" ||
            query == "nederlands a1" ||
            query == "nederlands a1 a2" ||
            query == "нидерландский a1" ||
            compact == "dutcha1" ||
            compact == "dutcha1-a2" ||
            compact == "nederlandsa1" ||
            compact == "a1a2"
    }

    private func answerMatchesDutchCourseIntent(_ answer: SearchAnswer, question: String, institution: String) -> Bool {
        guard answer.category == .education else { return false }
        if question.contains("dutch a1") || question.contains("nederlands a1") || question.contains("a1 a2") || question.contains("a1-a2") {
            return true
        }
        if institution.contains("duo") || institution.contains("cefr") {
            return true
        }

        let keywords = AppLanguage.allCases
            .flatMap { answer.keywords($0) }
            .map { normalizeSearchText($0.lowercased()) }
            .joined(separator: " ")
        return keywords.contains("dutch a1") || keywords.contains("nederlands a1") || keywords.contains("a1-a2")
    }

    private func answerMatchesFineIntent(_ answer: SearchAnswer, query: String, question: String, institution: String) -> Bool {
        if answer.category == .fines { return true }
        if containsSearchToken(in: question, tokens: ["fine", "fines", "boete", "boetes", "штраф", "штрафы"]) { return true }
        if containsSearchToken(in: institution, tokens: ["cjib"]) { return true }

        guard ["cjib", "boete", "boetes"].contains(query) else { return false }
        let keywords = AppLanguage.allCases
            .flatMap { answer.keywords($0) }
            .map { normalizeSearchText($0.lowercased()) }
            .joined(separator: " ")
        return containsSearchToken(in: keywords, tokens: ["fine", "fines", "boete", "boetes", "cjib", "штраф", "штрафы"])
    }

    private func containsSearchToken(in text: String, tokens: [String]) -> Bool {
        let words = Set(text.split { !$0.isLetter && !$0.isNumber }.map(String.init))
        return tokens.contains { words.contains($0) }
    }

    private func normalizeSearchText(_ value: String) -> String {
        let lowered = value.lowercased()
        let synonyms: [String: String] = [
            "дигид": "digid",
            "цифровой логин": "digital login",
            "госуслуги": "government services",
            "бсн": "bsn",
            "номер bsn": "bsn",
            "регистрация": "registration",
            "штраф": "fine",
            "оплатить штраф": "pay fine",
            "налоговая": "belastingdienst",
            "налог": "tax",
            "налоги": "taxes",
            "административное": "registration",
            "иммиграция": "immigration",
            "пособия": "social benefits",
            "субсидии": "social benefits",
            "транспорт": "transport",
            "письмо": "letter",
            "письмо от overheid": "government letter",
            "официальное письмо": "government letter",
            "муниципалитет": "municipality",
            "gemeente": "municipality",
            "gemeent": "municipality",
            "gemeete": "municipality",
            "мэрия": "municipality",
            "велосипед": "bicycle",
            "велик": "bicycle",
            "фонари": "lights",
            "аренда": "rent",
            "жилье": "housing",
            "жильё": "housing",
            "депозит": "deposit",
            "страховка": "insurance",
            "медстраховка": "health insurance",
            "врач": "huisarts",
            "семейный врач": "huisarts",
            "аптека": "pharmacy",
            "мусор": "waste",
            "переработка": "recycling",
            "зарплата": "salary",
            "работа": "work",
            "расчетный лист": "payslip",
            "расчётный лист": "payslip",
            "увольнение": "dismissal",
            "банк": "bank",
            "счет": "account",
            "счёт": "account",
            "общественный транспорт": "public transport",
            "поезд": "train",
            "boete": "fine",
            "belasting": "tax",
            "belastingen": "taxes",
            "toeslag": "allowance",
            "toeslagen": "allowances",
            "afval": "waste",
            "huur": "rent",
            "zorgverzekering": "health insurance",
            "zorgverzek": "health insurance",
            "zorgverzkering": "health insurance",
            "loonstrook": "payslip",
            "fiets": "bicycle",
            "werk": "work",
            "uitkering": "benefits",
            "нидерландский a1": "dutch a1",
            "нидерландский a2": "dutch a2",
            "знание нидерландского общества": "knowledge of dutch society",
            "слова": "words",
            "грамматика": "grammar",
            "отделяемые глаголы": "separable verbs",
            "afspraak": "appointment",
            "de het": "articles",
            "hebben zijn": "verbs"
        ]

        var normalized = lowered
        for (source, target) in synonyms {
            normalized = normalized.replacingOccurrences(of: source, with: target)
        }
        return normalized
    }

    private func inferredCategory(for value: String) -> SearchCategory? {
        let normalized = normalizeSearchText(value)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()

        var matches: [SearchCategory] = []
        func add(_ category: SearchCategory, when needles: [String]) {
            if needles.contains(where: { normalized.contains($0) }) && !matches.contains(category) {
                matches.append(category)
            }
        }

        add(.registration, when: ["bsn", "burgerservicenummer", "brp", "municipality registration", "registration", "register address"])
        add(.digid, when: ["digid", "digital login", "digital identity"])
        add(.healthInsurance, when: ["health insurance", "zorgverzekering", "medical insurance"])
        add(.taxes, when: ["tax", "taxes", "belastingdienst", "belasting", "toeslag", "toeslagen", "allowance", "allowances"])
        add(.fines, when: ["fine", "boete", "cjib", "traffic ticket", "penalty"])
        add(.immigration, when: ["immigration", "ind", "residence permit", "visa", "asylum"])
        add(.transport, when: ["transport", "ov-chipkaart", "ovpay", "train", "metro", "bus", "fiets", "bicycle"])
        add(.housing, when: ["housing", "rent", "huur", "deposit", "landlord"])
        add(.work, when: ["work", "uwv", "salary", "payslip", "contract", "employer"])
        add(.education, when: ["education", "duo", "student", "study", "school", "university", "knm", "dutch a1", "dutch a2", "dutch a1-a2", "nederlands a1", "nederlands a2", "grammar", "words", "grammatica", "woorden"])
        add(.emergency, when: ["112", "emergency", "police", "ambulance", "fire"])

        return matches.count == 1 ? matches.first : nil
    }

    private func explicitGeographyMatch(_ query: String, values: [String]) -> Bool {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalizedQuery.count >= 2 else { return false }

        return values.contains { rawValue in
            let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard value.count >= 2 else { return false }
            if value == normalizedQuery { return true }
            if normalizedQuery.count >= 3, value.contains(normalizedQuery) { return true }
            if value.count >= 4, normalizedQuery.contains(value) { return true }
            return false
        }
    }

    private func beginnerGuideCategories(for category: SearchCategory) -> [BeginnerGuideCategory] {
        switch category {
        case .registration, .digid:
            return [.identity, .municipality]
        case .immigration:
            return [.immigration]
        case .taxes:
            return [.taxes]
        case .fines:
            return [.fines]
        case .healthInsurance:
            return [.healthcare, .health]
        case .work:
            return [.work]
        case .education:
            return [.education]
        case .housing:
            return [.housing]
        case .transport:
            return [.transport]
        case .legalHelp:
            return [.legalHelp]
        case .emergency:
            return [.safety, .healthcare]
        case .general:
            return []
        }
    }

    private func fuzzyTokenMatch(query: String, in text: String) -> Bool {
        let queryTokens = Array(query
            .split(separator: " ")
            .map(String.init)
            .filter { $0.count >= 4 }
            .prefix(4))
        guard !queryTokens.isEmpty else { return false }

        let textTokens = Set(
            text.split { !$0.isLetter && !$0.isNumber }
                .map { String($0) }
                .filter { $0.count >= 4 && $0.count <= 32 }
                .prefix(90)
        )

        return queryTokens.allSatisfy { queryToken in
            textTokens.contains { textToken in
                textToken.contains(queryToken) ||
                queryToken.contains(textToken) ||
                levenshteinDistance(queryToken, textToken, maximum: 2) <= 2
            }
        }
    }

    private func levenshteinDistance(_ lhs: String, _ rhs: String, maximum: Int) -> Int {
        if lhs == rhs { return 0 }
        if abs(lhs.count - rhs.count) > maximum { return maximum + 1 }

        let lhsCharacters = Array(lhs)
        let rhsCharacters = Array(rhs)
        var previous = Array(0...rhsCharacters.count)

        for (i, lhsCharacter) in lhsCharacters.enumerated() {
            var current = [i + 1]
            var rowMinimum = current.first ?? maximum + 1

            for (j, rhsCharacter) in rhsCharacters.enumerated() {
                let insert = current[j] + 1
                let delete = previous[j + 1] + 1
                let replace = previous[j] + (lhsCharacter == rhsCharacter ? 0 : 1)
                let value = min(insert, delete, replace)
                current.append(value)
                rowMinimum = min(rowMinimum, value)
            }

            if rowMinimum > maximum { return maximum + 1 }
            previous = current
        }

        return previous.last ?? maximum + 1
    }
}
