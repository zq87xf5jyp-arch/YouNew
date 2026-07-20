import Foundation

enum AISafetyDecision: Equatable {
    case allowed
    case blocked(String)
    case privacyWarning(String)
}

enum AISafetyFilter {
    private static let sensitivePatterns: [(label: String, regex: String)] = [
        ("bsnDigits", #"(?i)\b\d{8,9}\b"#),
        ("passportLikeIdentifier", #"(?i)\b[A-Z]{2}(?=[A-Z0-9]{6,9}\b)(?=[A-Z0-9]*\d)[A-Z0-9]{6,9}\b"#),
        ("passportWord", #"(?i)\bpassport\b"#),
        ("bsnWithDigits", #"(?i)\bbsn\b.*\d"#),
        ("medicalRecord", #"(?i)\bmedical record\b"#),
        ("diagnosis", #"(?i)\bdiagnosis\b"#),
        ("russianPassport", #"(?i)\bпаспорт\b"#),
        ("russianMedical", #"(?i)\bмедицинск"#),
        ("dutchPassport", #"(?i)\bпасpoort\b"#),
        ("dutchMedicalRecord", #"(?i)\bmedisch dossier\b"#)
    ]

    private static let safeTextPatterns: [(label: String, regex: String)] = [
        ("digidRegistrationQuestion", #"(?i)\bwhat\s+is\s+digid\b.*\bregister\b"#)
    ]

    static func evaluate(_ message: String, language: AppLanguage) -> AISafetyDecision {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .blocked(AISafetyRules.emptyInputMessage(for: language))
        }

        if let emergency = AISafetyRules.emergencyEscalationIfNeeded(for: trimmed, languageCode: language.rawValue) {
            return .privacyWarning(emergency)
        }

        if let blocked = AISafetyRules.blockedResponseIfNeeded(for: trimmed, languageCode: language.rawValue) {
            return .blocked(blocked)
        }

        if containsSensitivePersonalData(trimmed) {
            return .privacyWarning(AISafetyRules.privacyWarning(for: language))
        }

        return .allowed
    }

    static func containsSensitivePersonalData(_ message: String) -> Bool {
        for safePattern in safeTextPatterns where message.range(of: safePattern.regex, options: .regularExpression) != nil {
            debugLog("PII whitelist hit: \(safePattern.label)")
            return false
        }

        for pattern in sensitivePatterns where message.range(of: pattern.regex, options: .regularExpression) != nil {
            debugLog("Detected PII pattern: \(pattern.label)")
            return true
        }

        return false
    }

    private static func debugLog(_ event: String) {
        #if DEBUG
        print(event)
        #endif
    }

    static func enforceResponseSafety(_ response: AIResponse, context: AIContext) -> AIResponse {
        guard response.answer != AIResponse.unverifiedAnswer else {
            return response
        }

        let note = response.safetyNote ?? AISafetyRules.sourceReminder(languageCode: context.userLanguage.rawValue)
        let answer = response.answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? AISafetyRules.emptyAnswerMessage(for: context.userLanguage)
            : response.answer

        return AIResponse(
            answer: answer,
            sources: response.sources,
            safetyNote: note,
            suggestedActions: response.suggestedActions,
            quickActions: response.quickActions,
            sections: response.sections,
            nextStep: response.nextStep,
            appDestinationID: response.appDestinationID,
            isVerified: response.isVerified,
            cacheKey: response.cacheKey,
            confidence: response.confidence,
            origin: response.origin,
            model: response.model,
            requestID: response.requestID
        )
    }
}
