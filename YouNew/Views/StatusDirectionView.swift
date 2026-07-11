import SwiftUI

struct StatusDirectionView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    let status: UserStatus

    private var lang: AppLanguage { languageManager.appLanguage }
    private var direction: StatusDirection { StatusDirection.forStatus(status) }
    private var pathProfile: UserPathProfile { UserPathProfiles.profile(for: status) }

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = max(0, proxy.size.width - AppSpacing.screenHorizontal * 2)

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    workspaceHero

                    workspaceTimelineSection

                    statusNextActionsSection

                    listSection(sectionTitle("status.direction.primary_needs"), items: direction.primaryNeeds)
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
                .frame(width: contentWidth, alignment: .leading)
                .tabBarScrollReserve()
            }
        }
        .appSceneBackground()
        .navigationTitle(sectionTitle("status.direction.title"))
    }

    private var workspaceHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: workspaceTitle,
            subtitle: workspaceSubtitle,
            symbol: status.icon,
            badgeText: workspaceHeroBadge,
            accent: statusTint,
            asset: workspaceHeroAsset,
            height: 286,
            language: lang
        )
        .accessibilityIdentifier("statusDirection.workspace.hero")
    }

    private var workspaceHeroAsset: AppImageAsset? {
        switch status {
        case .tourist:
            return ContentMediaRegistry.mapImage ?? ContentMediaRegistry.leidenCanalsHero ?? ContentMediaRegistry.officialSourcesHero
        case .student:
            return ContentMediaRegistry.leidenCanalsHero ?? ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero
        case .worker, .expat, .highlySkilledMigrant:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case .entrepreneur:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case .family:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage ?? ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.officialSourcesHero
        case .refugee, .ukrainian, .euCitizen:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case .lgbtNewcomer:
            return ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.profileImage ?? ContentMediaRegistry.officialSourcesHero
        }
    }

    private var workspaceHeroBadge: String {
        "\(status.localized(lang)) · \(appState.selectedCity)"
    }

    private var workspaceTimelineSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: localized(en: "Life Timeline", nl: "Tijdlijn", ru: "Timeline"), subtitle: pathProfile.localizedDescription.value(lang))

            VStack(spacing: 10) {
                ForEach(pathProfile.recommendedSteps.prefix(2)) { step in
                    NavigationLink(value: step.destination) {
                        workspaceStepCard(step)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                }
            }
        }
        .appCardStyle()
        .accessibilityIdentifier("statusDirection.workspace.timeline")
    }

    private var statusNextActionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: workspaceToolsTitle, subtitle: workspaceToolsSubtitle)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 10)], spacing: 10) {
                ForEach(statusDirectionActions) { action in
                    NavigationLink(value: action.destination) {
                        StatusDirectionActionCard(action: action)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("statusDirection.action.\(action.id)")
                }
            }
        }
        .appCardStyle()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("statusDirection.actions.dashboard")
    }

    private func workspaceStepCard(_ step: PathStep) -> some View {
        HStack(spacing: 12) {
            ProductSymbolTile(symbol: step.icon, accent: statusTint, size: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text(step.localizedTitle.value(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                Text(step.localizedDescription.value(lang))
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .appCardStyle()
    }

    private var statusDirectionActions: [StatusDirectionAction] {
        [
            StatusDirectionAction(
                id: "checklist",
                icon: "checklist",
                title: localized(en: "Checklist", nl: "Checklist", ru: "Checklist"),
                subtitle: localized(en: "Profile steps", nl: "Profielstappen", ru: "Шаги профиля"),
                color: AppColors.success,
                destination: direction.nextScreenDestination
            ),
            StatusDirectionAction(
                id: "first-steps",
                icon: "figure.walk.motion",
                title: localized(en: "First Steps", nl: "Eerste stappen", ru: "Первые шаги"),
                subtitle: localized(en: "Start here", nl: "Begin hier", ru: "Начать здесь"),
                color: AppColors.dutchOrange,
                destination: .firstSteps
            ),
            StatusDirectionAction(
                id: "documents",
                icon: "folder.fill",
                title: localized(en: "Documents", nl: "Documenten", ru: "Документы"),
                subtitle: localized(en: "Letters and files", nl: "Brieven en bestanden", ru: "Письма и файлы"),
                color: AppColors.softBlue,
                destination: .journeyDocuments
            ),
            StatusDirectionAction(
                id: "deadlines",
                icon: "calendar.badge.clock",
                title: localized(en: "Deadlines", nl: "Deadlines", ru: "Дедлайны"),
                subtitle: localized(en: "Important dates", nl: "Belangrijke datums", ru: "Важные даты"),
                color: AppColors.dutchOrange,
                destination: .deadlineCenter
            ),
            StatusDirectionAction(
                id: "municipality",
                icon: "building.2.fill",
                title: localized(en: "Municipality", nl: "Gemeente", ru: "Gemeente"),
                subtitle: localized(en: appState.selectedCity, nl: appState.selectedCity, ru: appState.selectedCity),
                color: AppColors.routeLine,
                destination: .mapFocus(.government)
            ),
            StatusDirectionAction(
                id: "sources",
                icon: "building.columns.fill",
                title: localized(en: "Official Sources", nl: "Officiële bronnen", ru: "Официальные источники"),
                subtitle: localized(en: "Official routes", nl: "Officiële routes", ru: "Официальные маршруты"),
                color: AppColors.emerald,
                destination: .officialSources
            ),
            StatusDirectionAction(
                id: "resources",
                icon: "books.vertical.fill",
                title: localized(en: "Resources", nl: "Resources", ru: "Ресурсы"),
                subtitle: localized(en: "Guides and links", nl: "Gidsen en links", ru: "Гайды и ссылки"),
                color: AppColors.softBlue,
                destination: .resourcesHub
            ),
            StatusDirectionAction(
                id: "insurance",
                icon: "cross.case.fill",
                title: localized(en: "Insurance", nl: "Verzekering", ru: "Страховка"),
                subtitle: localized(en: "Health basics", nl: "Zorgbasis", ru: "Медицинские основы"),
                color: AppColors.error,
                destination: .practicalGuide(.healthInsuranceBasics)
            ),
            StatusDirectionAction(
                id: "transport",
                icon: "tram.fill",
                title: localized(en: "Transport", nl: "Vervoer", ru: "Транспорт"),
                subtitle: localized(en: "OV and routes", nl: "OV en routes", ru: "OV и маршруты"),
                color: AppColors.warning,
                destination: .practicalGuide(.transportBasics)
            ),
            StatusDirectionAction(
                id: "partners",
                icon: "storefront.fill",
                title: localized(en: "Local Partners", nl: "Local Partners", ru: "Local Partners"),
                subtitle: localized(en: "Services nearby", nl: "Diensten dichtbij", ru: "Сервисы рядом"),
                color: AppColors.violet,
                destination: .localPartners
            )
        ]
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

    private var nextActionsTitle: String {
        switch lang {
        case .russian: return "Следующие действия"
        case .dutch: return "Volgende acties"
        case .english: return "Next actions"
        }
    }

    private var workspaceTitle: String {
        if status == .tourist {
            return localized(en: "Tourist Workspace", nl: "Toerist Workspace", ru: "Workspace туриста")
        }

        switch lang {
        case .russian: return "\(status.localized(lang)) Workspace"
        case .dutch: return "\(status.localized(lang)) Workspace"
        case .english: return "\(status.localized(lang)) Workspace"
        }
    }

    private var workspaceSubtitle: String {
        localized(
            en: "Checklist, documents, deadlines, and AI.",
            nl: "Checklist, documenten, deadlines en AI.",
            ru: "Checklist, документы, дедлайны и AI."
        )
    }

    private var workspaceToolsTitle: String {
        localized(en: "Workspace tools", nl: "Workspace tools", ru: "Инструменты workspace")
    }

    private var workspaceToolsSubtitle: String {
        localized(
            en: "Practical tools for this profile live here, not on Home.",
            nl: "Praktische tools voor dit profiel staan hier, niet op Home.",
            ru: "Практические инструменты профиля находятся здесь, не на Home."
        )
    }

    private var statusTint: Color {
        switch status {
        case .tourist:
            return AppColors.cyanGlow
        case .refugee, .ukrainian:
            return AppColors.softBlue
        case .student:
            return AppColors.emerald
        case .entrepreneur:
            return AppColors.warning
        case .lgbtNewcomer:
            return AppColors.violet
        default:
            return AppColors.dutchOrange
        }
    }

    private var nextActionsSubtitle: String {
        switch lang {
        case .russian: return "Откройте практические разделы, чтобы не оставаться только с описанием статуса."
        case .dutch: return "Open praktische onderdelen zodat de statusuitleg direct bruikbaar wordt."
        case .english: return "Open practical sections so the status explanation turns into action."
        }
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

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }
}

private struct StatusDirectionAction: Identifiable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: AppDestination
}

private struct StatusDirectionActionCard: View {
    let action: StatusDirectionAction

    var body: some View {
        ProductTaskCard(
            title: action.title,
            subtitle: action.subtitle,
            symbol: action.icon,
            accent: action.color,
            minHeight: 104
        )
    }
}
