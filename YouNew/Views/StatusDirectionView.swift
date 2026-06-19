import SwiftUI

struct StatusDirectionView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    let status: UserStatus

    private var lang: AppLanguage { languageManager.appLanguage }
    private var direction: StatusDirection { StatusDirection.forStatus(status) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                InfoCard(
                    title: direction.title[lang] ?? "",
                    subtitle: sectionTitle("status.direction.what_matters"),
                    detail: direction.shortExplanation[lang] ?? "",
                    icon: status.icon
                )

                listSection(sectionTitle("status.direction.primary_needs"), items: direction.primaryNeeds)
                listSection(sectionTitle("status.direction.not_needed"), items: direction.notUsuallyNeeded)
                listSection(sectionTitle("status.direction.first_actions"), items: direction.firstActions)
                listSection(sectionTitle("status.direction.documents"), items: direction.documentsToCheck)
                listSection(sectionTitle("status.direction.sources"), items: direction.officialSources)
                listSection(sectionTitle("status.direction.warnings"), items: direction.warnings)

                AIAskButton(
                    title: askAITitle,
                    context: AIContextBuilder.statusDirectionContext(status: status, language: lang, appState: nil),
                    prompt: askAIPrompt
                )
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(sectionTitle("status.direction.title"))
    }

    @ViewBuilder
    private func listSection(_ title: String, items: [[AppLanguage: String]]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                SectionHeader(title: title, subtitle: nil)
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: AppSpacing.small) {
                        Circle()
                            .fill(AppColors.accent)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        Text(item[lang] ?? "")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)
                }
            }
            .appCardStyle()
        }
    }

    private func sectionTitle(_ key: String) -> String {
        L10n.t(key, lang)
    }

    private var askAITitle: String {
        switch lang {
        case .russian: return "Спросить AI о моём статусе"
        case .dutch: return "Vraag AI over mijn situatie"
        case .english: return "Ask AI about my status"
        }
    }

    private var askAIPrompt: String {
        switch lang {
        case .russian: return "Что важно знать и сделать в первую очередь как \(status.localized(lang)) в Нидерландах?"
        case .dutch: return "Wat is het belangrijkste om te weten als \(status.localized(lang)) in Nederland?"
        case .english: return "What should a \(status.localized(.english)) prioritize first after arriving in the Netherlands?"
        }
    }
}
