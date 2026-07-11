import Foundation

struct AppSearchEngine {
    private let index: KnowledgeIndex

    init(index: KnowledgeIndex = .shared) {
        self.index = index
    }

    func search(
        _ query: String,
        language: AppLanguage,
        context: AIContext? = nil,
        activePersona: PersonaTag? = nil,
        scope: PersonaSearchScope = .currentAndUniversal,
        limit: Int = 8
    ) -> [KnowledgeSearchResult] {
        index.search(query, language: language, context: context, activePersona: activePersona, scope: scope, limit: limit)
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
}
