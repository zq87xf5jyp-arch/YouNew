import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var router: TabRouter
    @ObservedObject private var savedStore = SavedItemsStore.shared

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var visibleSavedItems: [SavedItemsStore.SavedItem] {
        savedStore.savedItems.filter { item in
            guard let destination = item.destination else { return true }
            return RelatedContentEngine.isVisible(destination, for: activePersona)
        }
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                ResponsiveContentContainer(maxWidth: 920) {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Color.clear
                            .frame(height: 0)
                            .id("favoritesTop")

                        SectionHeader(title: titleText, subtitle: subtitleText)

                        if visibleSavedItems.isEmpty {
                            VisualEmptyState(
                                title: emptyTitle,
                                detail: emptyDetail,
                                symbol: "bookmark.fill",
                                accent: AppColors.dutchOrange,
                                suggestedActions: emptySuggestions
                            )
                        } else {
                            ForEach(SavedItemsStore.SavedItemKind.allCases, id: \.rawValue) { kind in
                                let items = visibleSavedItems.filter { $0.kind == kind }
                                if !items.isEmpty {
                                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                                        SectionHeader(title: title(for: kind))
                                        ForEach(items) { item in
                                            favoriteRow(item)
                                        }
                                    }
                                }
                            }
                        }

                        Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.vertical, AppSpacing.medium)
                }
            }
            .onReceive(router.savedScrollTop) { _ in
                withAnimation(.easeInOut(duration: 0.24)) {
                    scrollProxy.scrollTo("favoritesTop", anchor: .top)
                }
            }
        }
        .appSceneBackground(.saved)
        .navigationTitle(titleText)
    }

    private var titleText: String {
        switch lang {
        case .russian: return "Избранное"
        case .english: return "Saved"
        case .dutch: return "Opgeslagen"
        }
    }

    @ViewBuilder
    private func favoriteRow(_ item: SavedItemsStore.SavedItem) -> some View {
        if let destination = item.destination {
            NavigationLink(value: destination) {
                rowContent(item)
            }
            .buttonStyle(.plain)
        } else {
            rowContent(item)
        }
    }

    private func rowContent(_ item: SavedItemsStore.SavedItem) -> some View {
        HStack {
            Image(systemName: icon(for: item.kind))
                .foregroundStyle(AppColors.dutchOrange)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayTitle(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                if let subtitle = item.displaySubtitle(lang), !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            Spacer()
            Button {
                savedStore.remove(item.id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(AppColors.textTertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.t("common.remove_bookmark", lang))
        }
        .appCardStyle()
    }

    private func icon(for kind: SavedItemsStore.SavedItemKind) -> String {
        switch kind {
        case .rule: return "exclamationmark.octagon.fill"
        case .city: return "building.2.fill"
        case .institution: return "building.columns.fill"
        case .document: return "doc.text.fill"
        case .resource: return "link.circle.fill"
        case .place: return "map.fill"
        case .other: return "bookmark.fill"
        }
    }

    private func title(for kind: SavedItemsStore.SavedItemKind) -> String {
        switch (kind, lang) {
        case (.rule, .russian): return "Правила и штрафы"
        case (.city, .russian): return "Города"
        case (.institution, .russian): return "Организации"
        case (.document, .russian): return "Документы"
        case (.resource, .russian): return "Ресурсы"
        case (.place, .russian): return "Места рядом"
        case (.other, .russian): return "Другое"
        case (.rule, .dutch): return "Regels en boetes"
        case (.city, .dutch): return "Steden"
        case (.institution, .dutch): return "Instellingen"
        case (.document, .dutch): return "Documenten"
        case (.resource, .dutch): return "Bronnen"
        case (.place, .dutch): return "Locaties in de buurt"
        case (.other, .dutch): return "Overig"
        case (.rule, .english): return "Rules and fines"
        case (.city, .english): return "Cities"
        case (.institution, .english): return "Institutions"
        case (.document, .english): return "Documents"
        case (.resource, .english): return "Resources"
        case (.place, .english): return "Nearby places"
        case (.other, .english): return "Other"
        }
    }

    private var subtitleText: String {
        switch lang {
        case .russian: return "Сохранённые правила, места и материалы"
        case .english: return "Saved rules, places, and resources"
        case .dutch: return "Opgeslagen regels, locaties en bronnen"
        }
    }

    private var emptyTitle: String {
        switch lang {
        case .russian: return "Пока ничего не сохранено"
        case .english: return "No saved items yet"
        case .dutch: return "Nog niets opgeslagen"
        }
    }

    private var emptyDetail: String {
        switch lang {
        case .russian: return "Нажимайте на иконку закладки в карточках, чтобы собрать важное в одном месте."
        case .english: return "Use bookmark icons in cards to collect important items here."
        case .dutch: return "Gebruik bladwijzericonen in kaarten om belangrijke items hier te bewaren."
        }
    }

    private var emptySuggestions: [String] {
        switch lang {
        case .russian: return ["Города", "Документы", "Места рядом"]
        case .english: return ["Cities", "Documents", "Nearby places"]
        case .dutch: return ["Steden", "Documenten", "Locaties dichtbij"]
        }
    }
}
