import Foundation

enum LifeTimelineStepStatus: String, CaseIterable, Hashable {
    case notStarted
    case inProgress
    case done
    case blocked

    func localized(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.notStarted, .english): return "Not started"
        case (.notStarted, .dutch): return "Niet gestart"
        case (.notStarted, .russian): return "Не начато"
        case (.inProgress, .english): return "In progress"
        case (.inProgress, .dutch): return "Bezig"
        case (.inProgress, .russian): return "В процессе"
        case (.done, .english): return "Done"
        case (.done, .dutch): return "Klaar"
        case (.done, .russian): return "Готово"
        case (.blocked, .english): return "Blocked"
        case (.blocked, .dutch): return "Geblokkeerd"
        case (.blocked, .russian): return "Заблокировано"
        }
    }
}

struct LifeTimelineStep: Identifiable, Hashable {
    let id: String
    let title: PathLocalizedText
    let explanation: PathLocalizedText
    let status: LifeTimelineStepStatus
    let priority: ChecklistPriority
    let requiredDocuments: [DocumentCategory]
    let officialSourceName: String
    let officialSourceURL: URL
    let relatedActions: [AppDestination]
    let aiPrompt: PathLocalizedText
    let dueDate: Date?
    let symbol: String
}

enum LifeTimelineBuilder {
    static func steps(
        for status: UserStatus?,
        checklistItems: [ChecklistItem],
        documents: [DocumentItem],
        now: Date = Date()
    ) -> [LifeTimelineStep] {
        let path = UserPathProfile.profile(for: status)
        let completedTitles = Set(
            checklistItems
                .filter(\.isCompleted)
                .map { $0.title.lowercased() }
        )
        let savedCategories = Set(documents.map(\.category))

        return path.recommendedSteps.map { pathStep in
            let documents = requiredDocuments(for: pathStep, status: status)
            let source = source(for: pathStep, status: status)
            let relatedChecklist = checklistItems.first { item in
                item.title.lowercased().contains(pathStep.localizedTitle.english.lowercased())
                    || pathStep.localizedTitle.english.lowercased().contains(item.title.lowercased())
            }
            let hasRequiredDocument = !documents.isEmpty && documents.contains { savedCategories.contains($0) }
            let isCompleted = completedTitles.contains { completed in
                completed.contains(pathStep.localizedTitle.english.lowercased())
            }
            let statusValue: LifeTimelineStepStatus

            if isCompleted {
                statusValue = .done
            } else if pathStep.status == .recommended || relatedChecklist?.priority == .high || hasRequiredDocument {
                statusValue = .inProgress
            } else if pathStep.status == .later {
                statusValue = .notStarted
            } else {
                statusValue = .notStarted
            }

            return LifeTimelineStep(
                id: "timeline:\(path.id):\(pathStep.id)",
                title: pathStep.localizedTitle,
                explanation: pathStep.localizedDescription,
                status: statusValue,
                priority: priority(for: pathStep),
                requiredDocuments: documents,
                officialSourceName: source.name,
                officialSourceURL: source.url,
                relatedActions: [pathStep.destination],
                aiPrompt: aiPrompt(for: pathStep),
                dueDate: relatedChecklist?.dueDate ?? inferredDueDate(for: pathStep, now: now),
                symbol: pathStep.icon
            )
        }
    }

    private static func priority(for step: PathStep) -> ChecklistPriority {
        switch step.priority {
        case 0...3: return .high
        case 4...7: return .medium
        default: return .low
        }
    }

    private static func requiredDocuments(for step: PathStep, status: UserStatus?) -> [DocumentCategory] {
        let id = step.id.lowercased()
        if id.contains("ind") || id.contains("permit") { return [.passportID, .indResidence, .gemeenteLetters] }
        if id.contains("bsn") || id.contains("registration") || id.contains("municipality") { return [.passportID, .brpRegistration, .bsn] }
        if id.contains("housing") { return [.rentalContract, .gemeenteLetters] }
        if id.contains("insurance") || id.contains("health") { return [.healthInsurance, .bsn] }
        if id.contains("bank") { return [.bankDocuments, .bsn] }
        if id.contains("duo") || id.contains("student") { return [.duoLetters, .schoolUniversity] }
        if id.contains("work") || id.contains("contract") { return [.workContract, .bsn] }
        if id.contains("tax") { return [.belastingdienstLetters, .bsn] }
        if status == .tourist { return [.passportID] }
        return [.passportID]
    }

    private static func source(for step: PathStep, status: UserStatus?) -> (name: String, url: URL) {
        let id = step.id.lowercased()
        if id.contains("ind") || id.contains("permit") {
            return ("IND", AppURL.make("https://ind.nl/en"))
        }
        if id.contains("duo") || id.contains("student") {
            return ("DUO", AppURL.make("https://www.duo.nl/particulier/international-student/"))
        }
        if id.contains("tax") || id.contains("toeslagen") {
            return ("Belastingdienst", AppURL.make("https://www.belastingdienst.nl"))
        }
        if id.contains("digid") {
            return ("DigiD", AppURL.make("https://www.digid.nl/en"))
        }
        if id.contains("health") || id.contains("insurance") {
            return ("Government.nl", AppURL.make("https://www.government.nl/topics/health-insurance"))
        }
        if status == .tourist {
            return ("Government.nl", AppURL.make("https://www.government.nl/themes/migration-and-travel"))
        }
        return ("Government.nl", AppURL.make("https://www.government.nl/topics/municipalities"))
    }

    private static func aiPrompt(for step: PathStep) -> PathLocalizedText {
        PathLocalizedText(
            english: "Explain my next step: \(step.localizedTitle.english). Include documents, deadline risk, and official sources. Do not give legal guarantees.",
            dutch: "Leg mijn volgende stap uit: \(step.localizedTitle.dutch). Noem documenten, deadline-risico en officiële bronnen. Geef geen juridische garanties.",
            russian: "Объясни мой следующий шаг: \(step.localizedTitle.russian). Укажи документы, риск дедлайна и официальные источники. Не давай юридических гарантий."
        )
    }

    private static func inferredDueDate(for step: PathStep, now: Date) -> Date? {
        guard step.priority <= 4 else { return nil }
        return Calendar.current.date(byAdding: .day, value: step.priority * 7, to: now)
    }
}
