import Foundation

enum AISafetyRules {
    private static var currentLanguageCode: String {
        "en"
    }

    static let safeFallback = "I can explain general information and guide you to official sources, but I cannot provide legal advice or predict official decisions."

    static func mandatoryDisclaimer(for language: AppLanguage) -> String {
        switch language {
        case .russian:
            return "YouNew предоставляет только информационную помощь. Ответы AI могут содержать неточности. Всегда проверяйте важную информацию в официальных учреждениях. Приложение не предоставляет юридические, иммиграционные, налоговые или медицинские консультации."
        case .dutch:
            return "YouNew biedt alleen informatieve hulp. AI-antwoorden kunnen onnauwkeurigheden bevatten. Controleer belangrijke informatie altijd bij officiële instanties. Deze app geeft geen juridisch, immigratie-, belasting- of medisch advies."
        case .english:
            return "YouNew provides informational guidance only. AI-generated informational assistance may contain inaccuracies. Always verify important information with official institutions. This app does not provide legal, immigration, tax or medical advice."
        }
    }

    static let systemPrompt = """
    You are YouNew Assistant, an informational guide for newcomers in the Netherlands.
    Your role:
    - explain Dutch public services, documents, transport, housing, healthcare, work, taxes, fines, cities and emergency numbers in simple language;
    - help users understand what to check next;
    - recommend official sources;
    - answer based only on the provided app context and safe general information;
    - clearly say when information must be verified.
    Strict rules:
    - You are not a lawyer, tax advisor, doctor, immigration consultant, police service or government authority.
    - Do not provide legal, medical, tax or immigration advice.
    - Do not claim that YouNew is official.
    - Do not guarantee that information is complete or always up to date.
    - Do not invent fines, laws, deadlines, documents, rights or procedures.
    - AI-generated informational assistance may contain inaccuracies. Always verify important information with official institutions.
    - If official source data is missing, say that the user should verify it with the relevant institution.
    - For emergency situations, tell the user to call 112 in the Netherlands.
    - Keep answers short, practical and structured.
    - Always include "Check official sources" when the topic involves law, tax, immigration, health, benefits or fines.
    """

    private static let blockedTermsEN = [
        "guarantee", "predict decision", "appeal strategy", "fake document", "tax evasion",
        "how to bypass", "avoid paying fine", "avoid taxes", "work illegally", "illegal work",
        "immigration outcome", "legal advice", "medical diagnosis"
    ]
    private static let blockedTermsNL = [
        "garantie", "beslissing voorspellen", "beroepsstrategie", "nep document", "belastingontduiking",
        "omzeilen", "boete vermijden", "belasting vermijden", "illegaal werken",
        "immigratie uitkomst", "juridisch advies", "medische diagnose"
    ]
    private static let blockedTermsRU = [
        "гарантировать", "предсказать решение", "стратегия обжалования", "фальшивый документ", "уклонение от налогов",
        "как обойти", "избежать штрафа", "избежать налог", "работать нелегально", "нелегальная работа",
        "исход по иммиграции", "юридическая консультация", "медицинский диагноз"
    ]

    static func blockedResponseIfNeeded(for message: String, languageCode: String? = nil) -> String? {
        let lang = languageCode ?? currentLanguageCode
        let lower = message.lowercased()
        let allBlocked = blockedTermsEN + blockedTermsNL + blockedTermsRU
        guard allBlocked.contains(where: { lower.contains($0) }) else { return nil }

        switch lang {
        case "ru":
            return "Я могу объяснить общую информацию и показать официальные источники, но не могу давать юридическую консультацию или предсказывать решения государственных органов. При срочной опасности звоните 112."
        case "nl":
            return "Ik kan algemene informatie uitleggen en u naar officiële bronnen verwijzen, maar ik kan geen juridisch advies geven of officiële beslissingen voorspellen. Bij acuut gevaar, bel 112."
        default:
            return safeFallback + " For urgent danger, call 112."
        }
    }

    static func sourceReminder(languageCode: String? = nil) -> String {
        switch languageCode ?? currentLanguageCode {
        case "ru":
            return "Всегда проверяйте важную информацию в официальных источниках."
        case "nl":
            return "Controleer altijd belangrijke informatie bij officiële instanties."
        default:
            return "Always verify important information with official institutions."
        }
    }

    static func sourceMissingMessage(for language: AppLanguage) -> String {
        switch language {
        case .russian:
            return "Официальный источник пока не добавлен в приложение. Проверьте это в соответствующем учреждении Нидерландов."
        case .dutch:
            return "Officiële bron is nog niet beschikbaar in de app. Controleer dit bij de relevante Nederlandse instantie."
        case .english:
            return "Official source not available in the app yet. Please verify this with the relevant Dutch institution."
        }
    }

    static func emptyInputMessage(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Введите вопрос без BSN, номера паспорта, медицинских записей или других чувствительных данных."
        case .dutch: return "Typ een vraag zonder BSN, paspoortnummer, medische gegevens of andere gevoelige gegevens."
        case .english: return "Enter a question without BSN, passport numbers, medical records or other sensitive personal data."
        }
    }

    static func emptyAnswerMessage(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Не удалось получить полезный ответ. Попробуйте ещё раз или проверьте официальный источник напрямую."
        case .dutch: return "Ik kon geen bruikbaar antwoord maken. Probeer opnieuw of controleer direct de officiële bron."
        case .english: return "I couldn’t generate a useful answer right now. Please try again or check the official source directly."
        }
    }

    static func privacyWarning(for language: AppLanguage) -> String {
        switch language {
        case .russian:
            return "Не отправляйте BSN, номер паспорта, медицинские записи или другие чувствительные персональные данные. Переформулируйте вопрос без этих деталей."
        case .dutch:
            return "Voer geen BSN, paspoortnummer, medische gegevens of andere gevoelige persoonsgegevens in. Formuleer de vraag zonder deze details."
        case .english:
            return "Do not enter BSN, passport numbers, medical records or other sensitive personal data. Please rephrase without those details."
        }
    }

    static func emergencyEscalationIfNeeded(for message: String, languageCode: String? = nil) -> String? {
        let lower = message.lowercased()
        let emergencyTerms = [
            "emergency", "urgent", "danger",
            "noodgeval", "dringend", "gevaar",
            "экстренн", "срочно", "опасн"
        ]
        guard emergencyTerms.contains(where: { lower.contains($0) }) else { return nil }

        switch languageCode ?? currentLanguageCode {
        case "ru":
            return "При срочной опасности звоните 112 немедленно."
        case "nl":
            return "Bij acuut gevaar, bel onmiddellijk 112."
        default:
            return "If there is urgent danger, call 112 immediately."
        }
    }
}
