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

/// Minimal native client for the bounded BuildWeekNewcomerDemo backend.
///
/// OpenAI credentials, system instructions, source URLs, route allowlists, and
/// grounding text intentionally do not exist in the request or app bundle.
struct AIClient {
    static let requestTimeoutSeconds: TimeInterval = 12
    static let resourceTimeoutSeconds: TimeInterval = 16
    static let endpointPath = "/v1/newcomer-demo"
    static let maximumQuestionLength = 800
    static let maximumQuestionBytes = 1_600
    static let maximumResponseBytes = 64 * 1_024

    struct NewcomerRequestBody: Encodable, Equatable {
        let question: String
        let locale: String
        let scenario: String
        let contextVersion: String
        let knowledgeRecordIDs: [String]

        init(question: String, language: AppLanguage) {
            self.question = AIClient.boundedQuestion(question)
            locale = language.rawValue
            scenario = BuildWeekNewcomerDemo.scenarioID
            contextVersion = BuildWeekNewcomerDemo.contextVersion
            knowledgeRecordIDs = BuildWeekNewcomerDemo.knowledgeRecordIDs
        }
    }

    let endpoint: URL?
    var session: URLSession
    let timeoutInterval: TimeInterval

    var isConfigured: Bool { endpoint != nil }

    init(
        endpoint: URL? = Self.configuredEndpoint(),
        session: URLSession = Self.defaultSession(),
        timeoutInterval: TimeInterval = requestTimeoutSeconds
    ) {
        self.endpoint = endpoint
        self.session = session
        self.timeoutInterval = timeoutInterval
    }

    func send(
        userMessage: String,
        context: AIContext,
        conversation _: [AIMessage]
    ) async throws -> AIResponse {
        guard BuildWeekNewcomerDemo.matches(userMessage) else {
            // This endpoint is intentionally not a general-purpose chat proxy.
            throw AIClientError.invalidRequest
        }
        guard let endpoint else { throw AIClientError.backendNotConfigured }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = timeoutInterval
        request.httpBody = try JSONEncoder().encode(
            NewcomerRequestBody(question: userMessage, language: context.userLanguage)
        )

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw AIClientError.invalidRequest
            }
            switch http.statusCode {
            case 200..<300:
                guard !data.isEmpty,
                      data.count <= Self.maximumResponseBytes
                else { throw AIClientError.emptyResponse }
                let parsed = try AIResponseParser.parse(data, language: context.userLanguage)
                guard parsed.isLiveOpenAI else { throw AIClientError.emptyResponse }
                return parsed
            case 400..<500 where http.statusCode != 429:
                throw AIClientError.invalidRequest
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

    static func validatedEndpoint(
        _ raw: String,
        allowInsecureLoopback: Bool = false
    ) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let components = URLComponents(string: trimmed),
              let host = components.host,
              !host.isEmpty,
              components.user == nil,
              components.password == nil,
              components.query == nil,
              components.fragment == nil,
              components.path == endpointPath
        else { return nil }

        if components.scheme == "https" {
            return components.url
        }

        let loopbackHosts = Set(["localhost", "127.0.0.1", "::1"])
        if allowInsecureLoopback,
           components.scheme == "http",
           loopbackHosts.contains(host.lowercased()) {
            return components.url
        }
        return nil
    }

    private static func boundedQuestion(_ question: String) -> String {
        var bounded = String(question.prefix(maximumQuestionLength))
        while bounded.utf8.count > maximumQuestionBytes {
            bounded.removeLast()
        }
        return bounded
    }

    private static func defaultSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = requestTimeoutSeconds
        configuration.timeoutIntervalForResource = resourceTimeoutSeconds
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.waitsForConnectivity = false
        configuration.httpShouldSetCookies = false
        configuration.urlCredentialStorage = nil
        return URLSession(configuration: configuration)
    }

    private static func configuredEndpoint() -> URL? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "YOUNEW_AI_BACKEND_URL") as? String else {
            return nil
        }
#if DEBUG
        return validatedEndpoint(raw, allowInsecureLoopback: true)
#else
        return validatedEndpoint(raw)
#endif
    }
}
