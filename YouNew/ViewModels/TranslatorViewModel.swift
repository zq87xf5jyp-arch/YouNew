import Foundation
import Combine
import SwiftUI

@MainActor
final class TranslatorViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var fromLanguage: TranslationLanguage = .dutch
    @Published var toLanguage: TranslationLanguage = .english
    @Published var result: TranslationResult?
    @Published var recent: [TranslationResult] = []
    @Published var isTranslating = false
    @Published var errorMessage: String?

    private let provider: TranslationProviding
    private let storageKey = "recent_translations_v1"

    init() {
        self.provider = MockTranslationProvider()
        loadRecent()
    }

    init(provider: TranslationProviding) {
        self.provider = provider
        loadRecent()
    }

    func detectLanguage() {
        let lower = inputText.lowercased()
        fromLanguage = lower.contains("de") || lower.contains("het") || lower.contains("gemeente") ? .dutch : .english
    }

    func swapLanguages() {
        let oldFrom = fromLanguage
        fromLanguage = toLanguage
        toLanguage = oldFrom
    }

    func translate() async {
        guard !isTranslating else { return }
        let sourceText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sourceText.isEmpty else { return }
        let sourceLanguage = fromLanguage
        let targetLanguage = toLanguage
        errorMessage = nil

        withAnimation(AppAnimations.standard) {
            isTranslating = true
        }
        defer {
            withAnimation(AppAnimations.standard) {
                isTranslating = false
            }
        }

        do {
            let translated = try await provider.translate(text: sourceText, from: sourceLanguage, to: targetLanguage)
            result = translated
            recent = [translated] + recent.filter { $0.id != translated.id }
            recent = Array(recent.prefix(12))
            saveRecent()
        } catch {
            result = nil
            errorMessage = error.localizedDescription
        }
    }

    func copyResult() {
        guard let result else { return }
#if os(iOS)
        UIPasteboard.general.string = result.translatedText
#endif
    }

    private func saveRecent() {
        guard let data = try? JSONEncoder().encode(recent) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func loadRecent() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let items = try? JSONDecoder().decode([TranslationResult].self, from: data) else { return }
        recent = items
    }
}
