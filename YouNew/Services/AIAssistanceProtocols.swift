import Foundation

protocol TranslationProviding {
    func translate(text: String, from: TranslationLanguage, to: TranslationLanguage) async throws -> TranslationResult
}

protocol OCRProviding {
    func extractText(fromDocumentPlaceholderName: String, language: AppLanguage) async -> String
}

protocol SummarizationProviding {
    func summarize(text: String) async -> String
}

struct MockTranslationProvider: TranslationProviding {
    func translate(text: String, from: TranslationLanguage, to: TranslationLanguage) async throws -> TranslationResult {
        let detectedInstitution = detectInstitution(in: text)
        let dates = detectDates(in: text)
        return TranslationResult(
            id: UUID(),
            sourceText: text,
            translatedText: localizedTranslationStub(text: text, target: to),
            fromLanguage: from.rawValue,
            toLanguage: to.rawValue,
            simpleExplanation: localizedExplanation(target: to),
            detectedInstitution: localizedInstitution(detectedInstitution, target: to),
            possibleDates: dates,
            createdAt: Date()
        )
    }

    private func detectInstitution(in text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("belasting") { return "Belastingdienst (possible match)" }
        if lower.contains("gemeente") { return "Municipality (possible match)" }
        if lower.contains("digid") { return "DigiD (possible match)" }
        if lower.contains("cjib") { return "CJIB (possible match)" }
        if lower.contains("duo") { return "DUO (possible match)" }
        return "No clear institution detected"
    }

    private func detectDates(in text: String) -> [String] {
        let patterns = ["\\b\\d{1,2}[-/]\\d{1,2}[-/]\\d{2,4}\\b", "\\b\\d{1,2}\\s+[A-Za-z]+\\s+\\d{4}\\b"]
        return patterns.flatMap { pattern -> [String] in
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
            let ns = text as NSString
            return regex.matches(in: text, range: NSRange(location: 0, length: ns.length)).map { ns.substring(with: $0.range) }
        }
    }

    private func localizedTranslationStub(text: String, target: TranslationLanguage) -> String {
        switch target {
        case .russian: return "Локальный черновой перевод: \(text)"
        case .dutch: return "Lokale conceptvertaling: \(text)"
        case .ukrainian, .arabic, .turkish, .polish:
            return "Local draft translation: \(text)"
        case .english: return "Local draft translation: \(text)"
        }
    }

    private func localizedExplanation(target: TranslationLanguage) -> String {
        switch target {
        case .russian: return "Это может быть административный запрос. Проверьте действия и сроки в официальном источнике."
        case .dutch: return "Dit kan een administratief verzoek zijn. Controleer acties en termijnen bij de officiële bron."
        case .ukrainian, .arabic, .turkish, .polish:
            return "This may describe an administrative request. Verify exact actions and deadlines on official sources."
        case .english: return "This may describe an administrative request. Verify exact actions and deadlines on official sources."
        }
    }

    private func localizedInstitution(_ value: String, target: TranslationLanguage) -> String {
        switch target {
        case .russian:
            if value.contains("possible match") { return value.replacingOccurrences(of: "possible match", with: "возможное совпадение") }
            return "Организация не определена"
        case .dutch:
            if value.contains("possible match") { return value.replacingOccurrences(of: "possible match", with: "mogelijke match") }
            return "Geen duidelijke instantie gevonden"
        case .ukrainian, .arabic, .turkish, .polish:
            return value
        case .english:
            return value
        }
    }
}

struct MockOCRProvider: OCRProviding {
    func extractText(fromDocumentPlaceholderName: String, language: AppLanguage) async -> String {
        switch language {
        case .russian:
            return "Локальное распознавание недоступно для этого документа. Проверьте оригинал и официальный источник."
        case .dutch:
            return "Lokale tekstherkenning is niet beschikbaar voor dit document. Controleer het origineel en de officiële bron."
        case .english:
            return "Local text recognition is unavailable for this document. Verify the original and official source."
        }
    }
}

struct MockSummarizationProvider: SummarizationProviding {
    func summarize(text: String) async -> String {
        "Possible summary: This message may request follow-up. Verify deadlines and instructions on official sources."
    }
}
