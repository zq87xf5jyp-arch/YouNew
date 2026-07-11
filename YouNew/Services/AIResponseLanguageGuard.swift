import Foundation

enum AIResponseLanguageGuard {
    private static let allowedLatinTokens: Set<String> = [
        "bsn", "digid", "ind", "uwv", "duo", "belastingdienst", "work", "nl",
        "gemeente", "ovpay", "ov", "ns", "knm", "brp", "cjib", "rdw",
        "government", "mijnoverheid", "toeslagen", "huisarts", "huisartsenpost",
        "leiden", "zuid", "holland", "zuid-holland", "noord", "noord-holland",
        "amsterdam", "rotterdam",
        "utrecht", "den", "haag", "eindhoven", "groningen"
    ]

    static func isVisibleTextAcceptable(_ text: String?, for language: AppLanguage) -> Bool {
        guard let text else { return true }
        let cleaned = normalizedVisibleText(text)
        guard !cleaned.isEmpty else { return true }

        switch language {
        case .english:
            return cyrillicCharacterCount(in: cleaned) == 0
        case .dutch:
            return cyrillicCharacterCount(in: cleaned) == 0
        case .russian:
            return isRussianVisibleText(cleaned)
        }
    }

    static func isResponseAcceptable(_ response: AIResponse, for language: AppLanguage) -> Bool {
        let values: [String?] = [
            response.answer,
            response.safetyNote,
            response.nextStep?.title,
            response.nextStep?.detail,
            response.nextStep?.destinationTitle
        ]

        if values.contains(where: { !isVisibleTextAcceptable($0, for: language) }) {
            return false
        }

        if response.sections.contains(where: {
            !isVisibleTextAcceptable($0.title, for: language) ||
            !isVisibleTextAcceptable($0.body, for: language)
        }) {
            return false
        }

        if response.quickActions.contains(where: { !isVisibleTextAcceptable($0.title, for: language) }) {
            return false
        }

        return !response.suggestedActions.contains(where: { !isVisibleTextAcceptable($0, for: language) })
    }

    private static func isRussianVisibleText(_ text: String) -> Bool {
        let cyrillicCount = cyrillicCharacterCount(in: text)
        let latinWords = latinWords(in: text).filter { !allowedLatinTokens.contains($0) }

        if latinWords.isEmpty { return true }
        if cyrillicCount == 0 { return latinWords.count <= 1 }

        let latinCharacterCount = latinWords.reduce(0) { $0 + $1.count }
        let visibleCharacterCount = max(cyrillicCount + latinCharacterCount, 1)
        return Double(latinCharacterCount) / Double(visibleCharacterCount) <= 0.35
    }

    private static func normalizedVisibleText(_ text: String) -> String {
        text
            .replacingOccurrences(of: #"https?://\S+"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"www\.\S+"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"[0-9]+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func cyrillicCharacterCount(in text: String) -> Int {
        text.unicodeScalars.filter {
            (0x0400...0x04FF).contains(Int($0.value))
        }.count
    }

    private static func latinWords(in text: String) -> [String] {
        let pattern = #"[A-Za-z][A-Za-z.'-]*"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            guard let wordRange = Range(match.range, in: text) else { return nil }
            return String(text[wordRange])
                .lowercased()
                .trimmingCharacters(in: CharacterSet(charactersIn: ".-'"))
        }
        .filter { !$0.isEmpty }
    }
}
