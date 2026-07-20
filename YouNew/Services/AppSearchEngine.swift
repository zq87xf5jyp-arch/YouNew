import Foundation

struct AppSearchEngine {
    private let index: KnowledgeIndex
    private let repository: ContentRepository

    init(index: KnowledgeIndex = .shared, repository: ContentRepository = .shared) {
        self.index = index
        self.repository = repository
    }

    func search(
        _ query: String,
        language: AppLanguage,
        context: AIContext? = nil,
        activePersona: PersonaTag? = nil,
        scope: PersonaSearchScope = .currentAndUniversal,
        limit: Int = 8
    ) -> [KnowledgeSearchResult] {
        var seenCanonicalIDs = Set<ContentID>()
        return index.search(
            query,
            language: language,
            context: context,
            activePersona: activePersona,
            scope: .allContentWithOutsidePathWarning,
            limit: limit
        )
        .filter { result in
            guard let canonical = repository.item(id: result.item.id), canonical.isSearchable else {
                return false
            }
            return seenCanonicalIDs.insert(canonical.id).inserted
        }
        .prefix(limit)
        .map { $0 }
    }

    func searchContent(
        _ query: String,
        language: AppLanguage,
        context: AIContext? = nil,
        activePersona: PersonaTag? = nil,
        limit: Int = 8
    ) -> [ContentSearchResult] {
        let normalizedQuery = ContentNormalization.text(query)
        guard !normalizedQuery.isEmpty else { return [] }
        let queryTokens = normalizedQuery.split(separator: " ").map(String.init)
        let persona = activePersona ?? context?.activePersonaTag
        let personaID = persona?.rawValue
        let contextCity = context?.selectedCity.map { ContentNormalization.text($0) }

        return repository.searchableItems().compactMap { item -> ContentSearchResult? in
            let localizedTitle = localizedTitle(item, language: language)
            let searchable = ContentNormalization.text([
                item.title,
                localizedTitle,
                item.shortDescription,
                item.fullDescription,
                item.keywords.joined(separator: " ")
            ].joined(separator: " "))
            let matchedTokens = queryTokens.filter(searchable.contains)
            guard searchable.contains(normalizedQuery) || !matchedTokens.isEmpty else { return nil }

            var score = Double(matchedTokens.count * 12)
            var fields = matchedTokens.isEmpty ? [] : ["tokens"]
            let normalizedTitle = ContentNormalization.text(localizedTitle)
            if normalizedTitle == normalizedQuery {
                score += 140
                fields.append("exact-title")
            } else if normalizedTitle.contains(normalizedQuery) {
                score += 80
                fields.append("title")
            }
            if item.keywords.map({ ContentNormalization.text($0) }).contains(normalizedQuery) {
                score += 120
                fields.append("keyword")
            }
            if let personaID, item.audienceTags.contains(personaID) {
                score += 24
                fields.append("audience-boost")
            }
            if let contextCity,
               item.cityIDs.contains(where: { ContentNormalization.text($0).contains(contextCity) }) {
                score += 18
                fields.append("city-boost")
            }
            score += Double(item.priority) / 10
            return ContentSearchResult(item: item, score: score, matchedFields: fields)
        }
        .sorted { ($0.score, $0.item.priority, $0.item.title) > ($1.score, $1.item.priority, $1.item.title) }
        .prefix(limit)
        .map { $0 }
    }

    func answerContext(
        for query: String,
        language: AppLanguage,
        context: AIContext? = nil
    ) -> (summary: String?, sources: [OfficialSource], destination: AppDestination?) {
        let results = search(
            query,
            language: language,
            context: context,
            activePersona: context?.activePersonaTag,
            scope: context?.personaSearchScope ?? .currentAndUniversal,
            limit: 6
        )
        guard !results.isEmpty else { return (nil, [], nil) }

        let summary = results.prefix(4).map { result in
            let related = result.graphNeighbors.prefix(2).map { $0.title(language) }
            let relatedText = related.isEmpty ? "" : " Related: \(related.joined(separator: ", "))."
            return "\(result.item.type.rawValue): \(result.item.title(language)) - \(result.item.summary(language))\(relatedText)"
        }
        .joined(separator: " ")

        var seenSourceKeys = Set<String>()
        let sources = results
            .flatMap { [$0.item] + $0.graphNeighbors }
            .flatMap(\.sources)
            .filter { source in
                let key = "\(source.title)|\(source.url?.absoluteString ?? "")"
                return seenSourceKeys.insert(key).inserted
            }

        let destination = results.first?.item.route ?? results.first?.graphNeighbors.first?.route
        return (String(summary.prefix(1_200)), Array(sources.prefix(8)), destination)
    }

    func answerContentContext(
        for query: String,
        language: AppLanguage,
        context: AIContext? = nil
    ) -> (contentIDs: [ContentID], deepLinks: [String], summary: String?) {
        let results = searchContent(query, language: language, context: context, limit: 8)
        return (
            results.map(\.item.id),
            results.compactMap(\.item.deepLink),
            results.prefix(4).map { "\($0.item.title): \($0.item.shortDescription)" }.joined(separator: " ")
        )
    }

    private func localizedTitle(_ item: ContentItem, language: AppLanguage) -> String {
        switch language {
        case .english: return item.title
        case .dutch: return item.localTitle["nl"] ?? item.title
        case .russian: return item.localTitle["ru"] ?? item.title
        }
    }
}

struct ContentSearchResult: Identifiable, Hashable {
    let item: ContentItem
    let score: Double
    let matchedFields: [String]

    var id: ContentID { item.id }
}
