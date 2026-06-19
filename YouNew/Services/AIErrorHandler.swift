import Foundation

enum AIErrorHandler {
    static func message(for error: Error, language: AppLanguage) -> String {
        if let clientError = error as? AIClientError {
            switch clientError {
            case .backendNotConfigured:
                return backendNotConfigured(language)
            case .rateLimited:
                return rateLimited(language)
            default:
                return unavailable(language)
            }
        }
        return unavailable(language)
    }

    private static func backendNotConfigured(_ language: AppLanguage) -> String {
        switch language {
        case .russian: return "AI backend пока не настроен. Показываю локальные безопасные подсказки."
        case .dutch: return "AI-backend is nog niet ingesteld. Lokale veilige hulp wordt gebruikt."
        case .english: return "AI backend is not configured yet. Showing local safe guidance."
        }
    }

    private static func rateLimited(_ language: AppLanguage) -> String {
        switch language {
        case .russian: return "Слишком много запросов. Попробуйте позже или откройте официальный источник."
        case .dutch: return "Te veel verzoeken. Probeer later opnieuw of open de officiële bron."
        case .english: return "Too many requests. Please try later or check the official source directly."
        }
    }

    private static func unavailable(_ language: AppLanguage) -> String {
        switch language {
        case .russian: return "Не удалось получить ответ сейчас. Попробуйте позже или проверьте официальный источник напрямую."
        case .dutch: return "Ik kon nu geen antwoord ophalen. Probeer later opnieuw of controleer direct de officiële bron."
        case .english: return "I couldn’t generate an answer right now. Please try again later or check the official source directly."
        }
    }
}

