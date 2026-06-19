import Foundation

enum AIClientError: LocalizedError, Equatable {
    case backendNotConfigured
    case invalidRequest
    case backendUnavailable
    case rateLimited
    case emptyResponse
    case timedOut

    var errorDescription: String? {
        switch self {
        case .backendNotConfigured: return "AI backend is not configured."
        case .invalidRequest: return "The request could not be sent."
        case .backendUnavailable: return "AI backend is temporarily unavailable."
        case .rateLimited: return "Too many AI requests. Please try again later."
        case .emptyResponse: return "AI backend returned an empty response."
        case .timedOut: return "The AI request timed out."
        }
    }
}

struct AIClient {
    static let requestTimeoutSeconds: TimeInterval = 12
    static let resourceTimeoutSeconds: TimeInterval = 16

    struct RequestBody: Encodable {
        let userMessage: String
        let language: String
        let screen: AIContextScreen
        let contextRetrieval: RetrievalContext
        let responseFormat: String
        let policy: RequestPolicy
        let policyVersion = "v1"
        let conversation: [ConversationTurn]
    }

    struct RetrievalContext: Encodable {
        let sourceTitles: [String]
        let sourceCount: Int
        let userSituation: String?
        let activePersonaTag: String?
        let secondaryPersonaTags: [String]
        let personaSearchScope: String
        let selectedCity: String?
        let selectedProvince: String?
        let category: String?
        let topicTitle: String?
        let topicSummary: String?
        let preferredDestination: String?
        let currentRouteID: String?
        let recentRouteIDs: [String]
        let lastSearches: [String]
        let completedChecklistItemIDs: [String]
        let completedGuideIDs: [String]
        let journeyProgress: String?
        let savedItemTitles: [String]
        let savedItemIDs: [String]
        let savedItemKinds: [String]

        init(context: AIContext) {
            sourceTitles = context.officialSources.map(\.title)
            sourceCount = context.officialSources.count
            userSituation = context.userSituation
            activePersonaTag = context.activePersonaTag?.rawValue
            secondaryPersonaTags = context.secondaryPersonaTags.map(\.rawValue)
            personaSearchScope = context.personaSearchScope.rawValue
            selectedCity = context.selectedCity
            selectedProvince = context.selectedProvince
            category = context.category
            topicTitle = context.topicTitle
            topicSummary = context.topicSummary
            preferredDestination = context.screen.rawValue
            currentRouteID = context.currentRouteID
            recentRouteIDs = context.recentRouteIDs
            lastSearches = context.lastSearches
            completedChecklistItemIDs = context.completedChecklistItemIDs
            completedGuideIDs = context.completedGuideIDs
            journeyProgress = context.journeyProgress
            savedItemTitles = context.savedItemTitles
            savedItemIDs = context.savedItemIDs
            savedItemKinds = context.savedItemKinds
        }

        var isVerified: Bool {
            sourceCount > 0
        }
    }

    struct ConversationTurn: Encodable {
        let role: String
        let content: String

        init(_ message: AIMessage) {
            self.role = message.role == .assistant ? "assistant" : "user"
            self.content = message.text
        }
    }

    struct RequestPolicy: Encodable {
        let backendMustRetrieveVerifiedContext = true
        let strictJSONOnly = true
        let noPrivateData = true
        let fallbackAnswer = AIResponse.unverifiedAnswer
        let maxSourceCount = 8
        let maxConversationTurns = 6
        let requestTimeoutSeconds = Int(AIClient.requestTimeoutSeconds)
    }

    let endpoint: URL?
    var session: URLSession
    let timeoutInterval: TimeInterval

    init(endpoint: URL? = Self.configuredEndpoint(), session: URLSession = Self.defaultSession(), timeoutInterval: TimeInterval = requestTimeoutSeconds) {
        self.endpoint = endpoint
        self.session = session
        self.timeoutInterval = timeoutInterval
    }

    func send(
        userMessage: String,
        context: AIContext,
        conversation: [AIMessage]
    ) async throws -> AIResponse {
        guard let endpoint else { throw AIClientError.backendNotConfigured }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeoutInterval

        request.httpBody = try JSONEncoder().encode(
            RequestBody(
                userMessage: String(userMessage.prefix(2_000)),
                language: context.userLanguage.rawValue,
                screen: context.screen,
                contextRetrieval: RetrievalContext(context: context),
                responseFormat: "younew.ai.response.v1.strict_json",
                policy: RequestPolicy(),
                conversation: conversation.suffix(6).map(ConversationTurn.init)
            )
        )

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw AIClientError.invalidRequest }
            switch http.statusCode {
            case 200..<300:
                guard !data.isEmpty else { throw AIClientError.emptyResponse }
                return try AIResponseParser.parse(data, language: context.userLanguage)
            case 429:
                throw AIClientError.rateLimited
            default:
                throw AIClientError.backendUnavailable
            }
        } catch {
            if let error = error as? URLError, error.code == .timedOut {
                throw AIClientError.timedOut
            }
            if let clientError = error as? AIClientError { throw clientError }
            throw AIClientError.backendUnavailable
        }
    }

    private static func defaultSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = requestTimeoutSeconds
        configuration.timeoutIntervalForResource = resourceTimeoutSeconds
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }

    private static func configuredEndpoint() -> URL? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "YOUNEW_AI_PROXY_URL") as? String,
              !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return AppURL.validatedWebURL(URL(string: trimmed))
    }
}
