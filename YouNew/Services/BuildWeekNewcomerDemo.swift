import Foundation

/// A bounded, reproducible assistant scenario for the Build Week demonstration.
///
/// The client sends only the question, locale, scenario/version identifiers, and
/// the identifiers of existing in-app knowledge records. Grounding text, source
/// URLs, routes, and model instructions remain server-owned.
enum BuildWeekNewcomerDemo {
    static let scenarioID = "BuildWeekNewcomerDemo"
    static let contextVersion = "newcomer-after-address.v1"
    static let allowedModels: Set<String> = [
        "gpt-5.6",
        "gpt-5.6-sol"
    ]

    struct StepContract: Equatable {
        let id: String
        let knowledgeRecordID: String
        let sourceTitle: String
        let sourceURL: URL
        let appDestination: String
    }

    static let steps: [StepContract] = [
        StepContract(
            id: "bsn",
            knowledgeRecordID: "topic:registration-bsn",
            sourceTitle: "Government.nl — Citizen service number (BSN)",
            sourceURL: URL(string: "https://www.government.nl/themes/government-and-democracy/personal-data/citizen-service-number-bsn")!,
            appDestination: "practicalGuide:municipalityRegistration"
        ),
        StepContract(
            id: "digid",
            knowledgeRecordID: "topic:digid",
            sourceTitle: "DigiD — Apply and activate",
            sourceURL: URL(string: "https://www.digid.nl/en/apply-and-activate/apply-digid")!,
            appDestination: "practicalGuide:digidSafety"
        ),
        StepContract(
            id: "health-insurance",
            knowledgeRecordID: "government-service:health-insurance",
            sourceTitle: "Government.nl — Health insurance",
            sourceURL: URL(string: "https://www.government.nl/themes/family-health-and-care/health-insurance")!,
            appDestination: "practicalGuide:healthInsuranceBasics"
        ),
        StepContract(
            id: "huisarts",
            knowledgeRecordID: "government-service:gp",
            sourceTitle: "Government.nl — Moving to the Netherlands",
            sourceURL: URL(string: "https://www.government.nl/faq/what-do-i-need-to-arrange-if-im-moving-to-the-netherlands")!,
            appDestination: "practicalGuide:findingHuisarts"
        )
    ]

    static var knowledgeRecordIDs: [String] {
        steps.map(\.knowledgeRecordID)
    }

    static func prompt(for language: AppLanguage) -> String {
        switch language {
        case .english:
            return "I recently received an address in the Netherlands. What should I do first for BSN, DigiD, health insurance, and a huisarts?"
        case .dutch:
            return "Ik heb onlangs een adres in Nederland gekregen. Wat moet ik eerst regelen voor BSN, DigiD, zorgverzekering en een huisarts?"
        case .russian:
            return "Я недавно получил адрес в Нидерландах. Что сначала сделать для BSN, DigiD, медицинской страховки и huisarts?"
        }
    }

    static func matches(_ question: String) -> Bool {
        let normalized = question
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
        let mentionsInsurance = normalized.contains("insurance")
            || normalized.contains("verzekering")
            || normalized.contains("страхов")
        return normalized.contains("bsn")
            && normalized.contains("digid")
            && mentionsInsurance
            && normalized.contains("huisarts")
    }

    static func isAllowedModel(_ model: String) -> Bool {
        allowedModels.contains(model)
    }

    static func localResponse(language: AppLanguage) -> AIResponse {
        let copy = localizedCopy(language)
        let sources = steps.map { step in
            OfficialSource(
                title: step.sourceTitle,
                url: step.sourceURL,
                institution: institution(for: step.id)
            )
        }
        let sections = zip(copy.stepTitles, copy.stepBodies).enumerated().map { index, pair in
            AIResponseSection(
                title: pair.0,
                body: pair.1,
                symbol: symbol(for: index)
            )
        }
        let guideActions = zip(copy.openGuideTitles, steps).map { title, step in
            AIResponseAction.openGuide(title: title, destinationID: step.appDestination)
        }
        let sourceActions = zip(copy.openSourceTitles, steps).map { title, step in
            AIResponseAction.openSource(title: title, url: step.sourceURL)
        }

        return AIResponse(
            answer: copy.summary,
            sources: sources,
            safetyNote: copy.warning,
            suggestedActions: copy.openGuideTitles,
            quickActions: guideActions + sourceActions,
            sections: sections,
            nextStep: AINextStep(
                title: copy.nextStepTitle,
                detail: copy.nextStepDetail,
                destinationID: steps[0].appDestination,
                destinationTitle: copy.openGuideTitles[0]
            ),
            appDestinationID: steps[0].appDestination,
            isVerified: true,
            confidence: .medium,
            origin: .localGuide
        )
    }

    private struct LocalizedCopy {
        let summary: String
        let stepTitles: [String]
        let stepBodies: [String]
        let openGuideTitles: [String]
        let openSourceTitles: [String]
        let warning: String
        let nextStepTitle: String
        let nextStepDetail: String
    }

    private static func localizedCopy(_ language: AppLanguage) -> LocalizedCopy {
        switch language {
        case .english:
            return LocalizedCopy(
                summary: "Use this order as a planning guide: check municipality registration and BSN first, then DigiD, then whether Dutch health insurance applies to your situation, and finally arrange a huisarts if appropriate.",
                stepTitles: [
                    "1. Registration-dependent — BSN",
                    "2. After prerequisites — DigiD",
                    "3. Situation-dependent — health insurance",
                    "4. Recommended — huisarts"
                ],
                stepBodies: [
                    "Confirm with your gemeente whether resident registration applies to you and which documents it requires. The route can depend on your stay and registration status.",
                    "After you have a BSN and are registered at an address, use the official DigiD application route. Activation requirements can depend on your registration situation.",
                    "Check the official rules for your residence, work, and study status before choosing a policy. Do not assume the same obligation applies to every newcomer.",
                    "A huisarts is normally the first contact for non-emergency care. Registration is recommended; availability and registration procedures vary locally. Use 112 for immediate danger."
                ],
                openGuideTitles: ["Open BSN guide", "Open DigiD guide", "Open health insurance guide", "Open huisarts guide"],
                openSourceTitles: ["Open official BSN source", "Open official DigiD source", "Open official insurance source", "Open official moving guide"],
                warning: "This is general orientation, not a legal entitlement or deadline. Requirements can depend on your gemeente and immigration, residence, work, or study status; verify before acting.",
                nextStepTitle: "Start with your gemeente",
                nextStepDetail: "Check whether and how you must register your address before relying on the later steps."
            )
        case .dutch:
            return LocalizedCopy(
                summary: "Gebruik deze volgorde als planningshulp: controleer eerst gemeente-inschrijving en BSN, daarna DigiD, vervolgens of een Nederlandse zorgverzekering voor jouw situatie geldt en regel zo nodig een huisarts.",
                stepTitles: [
                    "1. Afhankelijk van inschrijving — BSN",
                    "2. Na de voorwaarden — DigiD",
                    "3. Situatieafhankelijk — zorgverzekering",
                    "4. Aanbevolen — huisarts"
                ],
                stepBodies: [
                    "Vraag je gemeente of inschrijving als inwoner voor jou geldt en welke documenten nodig zijn. De route kan afhangen van je verblijfs- en inschrijfstatus.",
                    "Gebruik na ontvangst van een BSN en adresregistratie de officiële DigiD-aanvraag. Activeringsvoorwaarden kunnen per registratiesituatie verschillen.",
                    "Controleer eerst de officiële regels voor jouw verblijfs-, werk- en studiesituatie. Ga er niet van uit dat voor iedere nieuwkomer dezelfde verplichting geldt.",
                    "Een huisarts is meestal het eerste aanspreekpunt voor niet-spoedeisende zorg. Inschrijving is aanbevolen; beschikbaarheid en procedure verschillen lokaal. Bel 112 bij direct gevaar."
                ],
                openGuideTitles: ["Open BSN-gids", "Open DigiD-gids", "Open zorgverzekeringsgids", "Open huisarts-gids"],
                openSourceTitles: ["Open officiële BSN-bron", "Open officiële DigiD-bron", "Open officiële verzekeringsbron", "Open officiële verhuisgids"],
                warning: "Dit is algemene oriëntatie, geen juridische aanspraak of termijn. Vereisten kunnen afhangen van je gemeente en verblijfs-, werk- of studiesituatie; controleer dit voordat je handelt.",
                nextStepTitle: "Begin bij je gemeente",
                nextStepDetail: "Controleer of en hoe je je adres moet inschrijven voordat je op de vervolgstappen vertrouwt."
            )
        case .russian:
            return LocalizedCopy(
                summary: "Используйте эту последовательность как ориентир: сначала проверьте регистрацию в gemeente и BSN, затем DigiD, после этого — применима ли к вашей ситуации нидерландская медицинская страховка, и при необходимости выберите huisarts.",
                stepTitles: [
                    "1. Зависит от регистрации — BSN",
                    "2. После выполнения условий — DigiD",
                    "3. Зависит от ситуации — медицинская страховка",
                    "4. Рекомендуется — huisarts"
                ],
                stepBodies: [
                    "Уточните в своей gemeente, требуется ли вам регистрация как жителю и какие документы нужны. Порядок зависит от статуса пребывания и регистрации.",
                    "После получения BSN и регистрации адреса используйте официальный путь подачи на DigiD. Условия активации могут зависеть от вашей регистрации.",
                    "До выбора полиса проверьте официальные правила для вашего статуса проживания, работы и учёбы. Не исходите из того, что для всех новых жителей действует одна обязанность.",
                    "Huisarts обычно является первым контактом для несрочной медицинской помощи. Регистрация рекомендуется, но доступность и порядок различаются по месту. При непосредственной опасности звоните 112."
                ],
                openGuideTitles: ["Открыть гайд по BSN", "Открыть гайд по DigiD", "Открыть гайд по страховке", "Открыть гайд по huisarts"],
                openSourceTitles: ["Открыть официальный источник о BSN", "Открыть официальный источник DigiD", "Открыть официальный источник о страховке", "Открыть официальный гайд о переезде"],
                warning: "Это общий ориентир, а не юридическая гарантия или срок. Требования могут зависеть от gemeente и статуса пребывания, работы или учёбы; перепроверьте их до действий.",
                nextStepTitle: "Начните с gemeente",
                nextStepDetail: "Уточните, нужно ли и как регистрировать адрес, прежде чем переходить к следующим шагам."
            )
        }
    }

    private static func institution(for id: String) -> String {
        id == "digid" ? "DigiD" : "Government of the Netherlands"
    }

    private static func symbol(for index: Int) -> String {
        switch index {
        case 0: return "number.circle.fill"
        case 1: return "lock.shield.fill"
        case 2: return "cross.case.fill"
        default: return "stethoscope"
        }
    }
}
