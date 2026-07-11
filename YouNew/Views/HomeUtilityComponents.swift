import SwiftUI

struct HomeLifeTimelinePreviewSection: View {
    let title: String
    let subtitle: String
    let priority: String
    let steps: [LifeTimelineStep]
    let language: AppLanguage
    let openSourceTitle: String
    let askAITitle: String
    let onOpenSource: (URL) -> Void
    let onAskAI: (String) -> Void

    var body: some View {
        if !steps.isEmpty {
            ProductScreenSection(title: title, subtitle: subtitle, priority: priority) {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    ForEach(Array(steps.prefix(5))) { step in
                        HomeTimelineStepRow(
                            step: step,
                            language: language,
                            openSourceTitle: openSourceTitle,
                            askAITitle: askAITitle,
                            onOpenSource: onOpenSource,
                            onAskAI: onAskAI
                        )
                    }
                }
            }
            .accessibilityIdentifier("home.lifeTimeline")
        }
    }
}

private struct HomeTimelineStepRow: View {
    let step: LifeTimelineStep
    let language: AppLanguage
    let openSourceTitle: String
    let askAITitle: String
    let onOpenSource: (URL) -> Void
    let onAskAI: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ProductSymbolTile(symbol: step.symbol, accent: statusAccent, size: 42)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(step.title.value(language))
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 4)

                        Text(step.status.localized(language))
                            .font(AppTypography.metadata)
                            .foregroundStyle(statusAccent)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }

                    Text(step.explanation.value(language))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(documentSummary)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 8) {
                Button {
                    onOpenSource(step.officialSourceURL)
                } label: {
                    Label(openSourceTitle, systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryPremiumButtonStyle())

                Button {
                    onAskAI(step.aiPrompt.value(language))
                } label: {
                    Label(askAITitle, systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryPremiumButtonStyle())
            }
        }
        .padding(14)
        .appCardStyle()
    }

    private var statusAccent: Color {
        switch step.status {
        case .notStarted: return AppColors.textTertiary
        case .inProgress: return AppColors.cyanGlow
        case .done: return AppColors.success
        case .blocked: return AppColors.error
        }
    }

    private var documentSummary: String {
        let documents = step.requiredDocuments.prefix(3).map { $0.localized(language) }.joined(separator: ", ")
        switch language {
        case .english: return "Documents: \(documents)"
        case .dutch: return "Documenten: \(documents)"
        case .russian: return "Документы: \(documents)"
        }
    }
}

struct HomeChecklistPreviewSection: View {
    let title: String
    let subtitle: String
    let priority: String
    let items: [ChecklistItem]
    let language: AppLanguage
    let openTitle: String
    let sourceTitle: String
    let askTitle: String
    let addDeadlineTitle: String
    let onToggle: (ChecklistItem) -> Void
    let onOpenSource: (URL) -> Void
    let onAskAI: (ChecklistItem) -> Void
    let onAddDeadline: (ChecklistItem) -> Void

    var body: some View {
        ProductScreenSection(title: title, subtitle: subtitle, priority: priority) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                ForEach(Array(items.prefix(4))) { item in
                    HomeChecklistPreviewRow(
                        item: item,
                        language: language,
                        openTitle: openTitle,
                        sourceTitle: sourceTitle,
                        askTitle: askTitle,
                        addDeadlineTitle: addDeadlineTitle,
                        onToggle: onToggle,
                        onOpenSource: onOpenSource,
                        onAskAI: onAskAI,
                        onAddDeadline: onAddDeadline
                    )
                }

                NavigationLink(value: AppDestination.checklistList) {
                    ProductTaskCard(
                        title: openTitle,
                        subtitle: subtitle,
                        symbol: "checklist",
                        accent: AppColors.cyanGlow,
                        cta: openTitle,
                        minHeight: 76,
                        prominence: .quiet
                    )
                }
                .buttonStyle(NLTileButtonStyle())
            }
        }
        .accessibilityIdentifier("home.smartChecklist")
    }
}

private struct HomeChecklistPreviewRow: View {
    let item: ChecklistItem
    let language: AppLanguage
    let openTitle: String
    let sourceTitle: String
    let askTitle: String
    let addDeadlineTitle: String
    let onToggle: (ChecklistItem) -> Void
    let onOpenSource: (URL) -> Void
    let onAskAI: (ChecklistItem) -> Void
    let onAddDeadline: (ChecklistItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Button { onToggle(item) } label: {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(item.isCompleted ? AppColors.success : AppColors.textTertiary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.title(language))

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title(language))
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .strikethrough(item.isCompleted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.description(language))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(item.priority.localized(language)) · \(item.officialSourceName)")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(1)
                }
            }

            LazyVGrid(columns: PremiumVisualMetrics.Grid.adaptiveColumns(minimum: 128), spacing: 8) {
                Button { onOpenSource(item.officialSourceURL) } label: {
                    Label(sourceTitle, systemImage: "safari")
                }
                .buttonStyle(SecondaryPremiumButtonStyle())

                Button { onAskAI(item) } label: {
                    Label(askTitle, systemImage: "sparkles")
                }
                .buttonStyle(SecondaryPremiumButtonStyle())

                Button { onAddDeadline(item) } label: {
                    Label(addDeadlineTitle, systemImage: "calendar.badge.plus")
                }
                .buttonStyle(SecondaryPremiumButtonStyle())
            }
        }
        .padding(14)
        .appCardStyle()
    }
}

struct HomeDocumentsDeadlinesSection: View {
    let title: String
    let subtitle: String
    let priority: String
    let documentCategories: [DocumentCategory]
    let deadlines: [DeadlineReminder]
    let savedDocumentCount: Int
    let language: AppLanguage
    let openDocumentsTitle: String
    let openDeadlinesTitle: String
    let askTitle: String
    let onAskDeadline: (DeadlineReminder) -> Void

    var body: some View {
        ProductScreenSection(title: title, subtitle: subtitle, priority: priority) {
            LazyVGrid(columns: PremiumVisualMetrics.Grid.adaptiveColumns(minimum: 238), spacing: AppSpacing.small) {
                NavigationLink(value: AppDestination.documentVault) {
                    ProductTaskCard(
                        title: documentsTitle,
                        subtitle: documentsSubtitle,
                        symbol: "lock.doc.fill",
                        accent: AppColors.softBlue,
                        cta: openDocumentsTitle,
                        minHeight: 126,
                        prominence: .normal
                    )
                }
                .buttonStyle(NLTileButtonStyle())

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(deadlines.prefix(3))) { reminder in
                        HStack(spacing: 10) {
                            ProductSymbolTile(symbol: "calendar", accent: AppColors.warning, size: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(reminder.title)
                                    .font(AppTypography.captionStrong)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .lineLimit(2)
                                Text(deadlineDate(reminder.possibleDueDate))
                                    .font(AppTypography.metadata)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 6)
                            Button { onAskDeadline(reminder) } label: {
                                Image(systemName: "sparkles")
                                    .frame(width: 36, height: 36)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(askTitle)
                        }
                    }

                    NavigationLink(value: AppDestination.deadlineCenter) {
                        Label(openDeadlinesTitle, systemImage: "calendar.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryPremiumButtonStyle())
                }
                .padding(14)
                .appCardStyle()
            }
        }
        .accessibilityIdentifier("home.documentsDeadlines")
    }

    private var documentsTitle: String {
        switch language {
        case .english: return "Document vault"
        case .dutch: return "Documentkluis"
        case .russian: return "Хранилище документов"
        }
    }

    private var documentsSubtitle: String {
        let categories = documentCategories.prefix(3).map { $0.localized(language) }.joined(separator: ", ")
        switch language {
        case .english: return "\(savedDocumentCount) saved locally. Suggested: \(categories)."
        case .dutch: return "\(savedDocumentCount) lokaal bewaard. Nodig: \(categories)."
        case .russian: return "\(savedDocumentCount) сохранено локально. Нужно: \(categories)."
        }
    }

    private func deadlineDate(_ date: Date?) -> String {
        guard let date else {
            switch language {
            case .english: return "Add a reminder date"
            case .dutch: return "Voeg een herinneringsdatum toe"
            case .russian: return "Добавьте дату напоминания"
            }
        }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

struct HomeExploreNetherlandsSection: View {
    let title: String
    let subtitle: String
    let priority: String
    let language: AppLanguage

    var body: some View {
        ProductScreenSection(title: title, subtitle: subtitle, priority: priority) {
            LazyVGrid(columns: PremiumVisualMetrics.Grid.adaptiveColumns(minimum: 180), spacing: AppSpacing.small) {
                NavigationLink(value: AppDestination.discoverNetherlands) {
                    ProductTaskCard(
                        title: title,
                        subtitle: subtitle,
                        symbol: "sparkles.rectangle.stack.fill",
                        accent: AppColors.violet,
                        cta: priority,
                        minHeight: 110,
                        prominence: .quiet
                    )
                }
                .buttonStyle(NLTileButtonStyle())

                exploreLink(
                    title: localized(en: "History", nl: "Geschiedenis", ru: "История"),
                    subtitle: localized(en: "Context, not an urgent action", nl: "Context, geen urgente actie", ru: "Контекст, не срочное действие"),
                    symbol: "book.closed.fill",
                    accent: AppColors.dutchOrange,
                    destination: .netherlandsHistory
                )

                exploreLink(
                    title: localized(en: "Dutch Figures", nl: "Nederlandse figuren", ru: "Личности Нидерландов"),
                    subtitle: localized(en: "Cultural reference", nl: "Culturele referentie", ru: "Культурная справка"),
                    symbol: "person.crop.square.filled.and.at.rectangle",
                    accent: AppColors.violet,
                    destination: .dutchFigures
                )

                exploreLink(
                    title: localized(en: "Culture", nl: "Cultuur", ru: "Культура"),
                    subtitle: localized(en: "Traditions and places", nl: "Tradities en plekken", ru: "Традиции и места"),
                    symbol: "sparkles",
                    accent: AppColors.emerald,
                    destination: .cultureAttractions
                )
            }
        }
        .accessibilityIdentifier("home.exploreNetherlands")
    }

    private func exploreLink(title: String, subtitle: String, symbol: String, accent: Color, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
            ProductTaskCard(
                title: title,
                subtitle: subtitle,
                symbol: symbol,
                accent: accent,
                cta: localized(en: "Explore", nl: "Verken", ru: "Открыть"),
                minHeight: 112,
                prominence: .quiet
            )
        }
        .buttonStyle(NLTileButtonStyle())
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch language {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}
