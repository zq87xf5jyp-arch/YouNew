import Foundation

struct AssistantContextSnapshot {
    let status: UserStatus?
    let city: String
    let completedChecklistCount: Int
    let totalChecklistCount: Int
    let hasBSN: Bool
    let hasDigiD: Bool
    let hasHealthInsurance: Bool
}

enum AssistantContextEngine {
    static func systemContextText(_ snapshot: AssistantContextSnapshot, language: AppLanguage) -> String {
        guard let status = snapshot.status else {
            return ""
        }
        let statusTitle = status.localized(language)
        let progress = "\(snapshot.completedChecklistCount)/\(snapshot.totalChecklistCount)"
        let bsn = snapshot.hasBSN ? "yes" : "no"
        let digid = snapshot.hasDigiD ? "yes" : "no"
        let insurance = snapshot.hasHealthInsurance ? "yes" : "no"

        switch language {
        case .russian:
            return """
            Контекст пользователя:
            - Профиль: \(statusTitle)
            - Город: \(snapshot.city)
            - Прогресс чеклиста: \(progress)
            - BSN: \(bsn), DigiD: \(digid), страховка: \(insurance)
            Дайте безопасный, практичный, профильно-релевантный ответ без юридических обещаний.
            """
        case .english:
            return """
            User context:
            - Profile: \(statusTitle)
            - City: \(snapshot.city)
            - Checklist progress: \(progress)
            - BSN: \(bsn), DigiD: \(digid), insurance: \(insurance)
            Provide a safe, practical, profile-relevant answer with no legal guarantees.
            """
        case .dutch:
            return """
            Gebruikerscontext:
            - Profiel: \(statusTitle)
            - Stad: \(snapshot.city)
            - Checklist-voortgang: \(progress)
            - BSN: \(bsn), DigiD: \(digid), verzekering: \(insurance)
            Geef een veilig, praktisch en profielrelevant antwoord zonder juridische garanties.
            """
        }
    }

    static func quickPrompts(for status: UserStatus?, language: AppLanguage) -> [String] {
        guard let status else { return [] }
        switch (status, language) {
        case (.student, .russian):
            return ["Как проверить DUO и транспортные правила?", "Как не попасться на мошенничество с жильём?"]
        case (.worker, .russian):
            return ["Как проверить рабочий контракт и loonstrook?", "Какие налоговые письма нельзя игнорировать?"]
        case (.expat, .russian):
            return ["Что важно по налогам и 30%-regeling?", "Какие документы работодателя проверить сначала?"]
        case (.tourist, .russian):
            return ["Что важно при коротком пребывании?", "Какие шаги можно пропустить туристу?"]
        case (.student, .english):
            return ["How do I verify DUO and student transport rules?", "How to avoid housing scams as a student?"]
        case (.worker, .english):
            return ["How do I verify my contract and payslip?", "Which tax letters should I never ignore?"]
        case (.expat, .english):
            return ["What should I check first about taxes and 30% ruling?", "Which employer documents matter most?"]
        case (.tourist, .english):
            return ["What matters most for short stay?", "Which steps can tourists usually skip?"]
        case (.student, .dutch):
            return ["Hoe controleer ik DUO- en vervoersregels?", "Hoe voorkom ik huisvestingsfraude als student?"]
        case (.worker, .dutch):
            return ["Hoe controleer ik mijn contract en loonstrook?", "Welke belastingbrieven mag ik niet negeren?"]
        case (.expat, .dutch):
            return ["Wat moet ik eerst controleren bij belasting en 30%-regeling?", "Welke werkgeversdocumenten zijn het belangrijkst?"]
        case (.tourist, .dutch):
            return ["Wat is het belangrijkst bij kort verblijf?", "Welke stappen kunnen toeristen meestal overslaan?"]
        default:
            return []
        }
    }
}
