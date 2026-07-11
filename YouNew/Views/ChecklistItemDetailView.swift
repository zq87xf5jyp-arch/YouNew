import SwiftUI

struct ChecklistItemDetailView: View {
    let item: ChecklistItem
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    private var related: [RelatedNavigationItem] {
        RelatedContentEngine.relatedItems(for: item).filter { RelatedContentEngine.isVisible($0.destination, for: appState.selectedUserStatus?.personaTag) }
    }

    private var mistakes: [NewcomerMistake] {
        RelatedContentEngine.commonMistakes(for: item).filter { $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }
    }

    private var nextStep: ChecklistItem? {
        guard let nextID = item.nextRecommendedStepID else { return nil }
        return appState.checklistItems.first(where: { $0.id == nextID })
    }

    private var stepInsight: StepInsight {
        ProfileChecklistEngine.insight(for: item, status: appState.selectedUserStatus)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                BreadcrumbTrail(segments: [
                    L10n.t("tab.home", lang),
                    L10n.t("tab.checklist", lang),
                    item.title(lang)
                ])

                PremiumImageHeader(
                    title: item.title(lang),
                    asset: checklistDetailImageAsset,
                    language: lang,
                    symbol: checklistDetailSymbol,
                    accent: checklistDetailAccent,
                    height: 210,
                    cornerRadius: 22,
                    fallbackCategory: checklistDetailFallbackCategory
                )
                .appCardStyle()

                headerCard
                    .accessibilityIdentifier("checklist.detail.screen")

                whyThisMattersSection

                InfoCard(
                    title: L10n.t("checklist.detail.suggested_timing_section", lang),
                    subtitle: item.suggestedTiming(lang),
                    detail: L10n.t("checklist.detail.timing_note", lang),
                    icon: "clock"
                )

                HStack(spacing: AppSpacing.small) {
                    OfficialSourceButton(title: L10n.t("beginner.open_official_source", lang), url: item.officialSourceURL)
                    QuickActionButton(title: L10n.t("checklist.detail.open_checklist", lang), symbol: "checklist", destination: .checklistList)
                }

                HStack(spacing: AppSpacing.small) {
                    NavigationLink(value: AppDestination.mapFocus(.category(mapCategory(for: item.category)))) {
                        Label(L10n.t("checklist.find_on_map", lang), systemImage: "map.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryPremiumButtonStyle())

                    Button {
                        appState.toggleChecklistItem(item)
                        appState.showToast(L10n.t("checklist.step_marked_complete", lang))
                    } label: {
                        Label(L10n.t("checklist.mark_step_complete", lang), systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryPremiumButtonStyle())
                }

                if let next = nextStep {
                    NextStepCard(
                        title: next.title(lang),
                        subtitle: next.description(lang),
                        destination: .checklist(next.id)
                    )
                }

                CommonMistakesSection(mistakes: mistakes)

                RelatedContentSection(title: L10n.t("checklist.detail.related_content", lang), items: related)

                SafetyBanner(text: L10n.t("checklist.detail.safety_note", lang))
                OutdatedInfoReportCard()
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
            .accessibilityIdentifier("checklist.detail.screen")
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("checklist.detail.nav_title", lang))
        .nlNavigationInline()
        .onAppear {
            appState.addRecentlyViewedTopic("checklist::\(item.id.uuidString)")
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                SaveItemButton(
                    itemID: item.id.uuidString,
                    kind: .other,
                    title: item.title(lang),
                    subtitle: item.category.localized(lang),
                    destination: .checklist(item.id)
                )
            }
        }
    }

    private func mapCategory(for category: ChecklistCategory) -> PlaceCategory {
        switch category {
        case .registration: return .municipality
        case .documents: return .immigrationSupport
        case .insurance: return .healthcare
        case .work: return .legalHelp
        case .taxes: return .municipality
        case .housing: return .communitySupport
        case .education: return .studentHelp
        case .transport: return .transport
        }
    }

    private var checklistDetailImageAsset: AppImageAsset? {
        switch item.category {
        case .registration:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case .documents:
            return ContentMediaRegistry.savedImage ?? ContentMediaRegistry.officialSourcesHero
        case .insurance:
            return ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.healthcarePharmacyImage ?? ContentMediaRegistry.officialSourcesHero
        case .work, .taxes:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case .housing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage ?? ContentMediaRegistry.officialSourcesHero
        case .education:
            return ContentMediaRegistry.museumsCultureImage ?? ContentMediaRegistry.cultureHero ?? ContentMediaRegistry.officialSourcesHero
        case .transport:
            return ContentMediaRegistry.transportHero ?? ContentMediaRegistry.ovChipkaartImage ?? ContentMediaRegistry.officialSourcesHero
        }
    }

    private var checklistDetailFallbackCategory: PremiumImageFallbackCategory {
        switch item.category {
        case .registration, .taxes:
            return .government
        case .documents:
            return .documents
        case .insurance:
            return .healthcare
        case .work:
            return .work
        case .housing:
            return .housing
        case .education:
            return .integration
        case .transport:
            return .transport
        }
    }

    private var checklistDetailSymbol: String {
        switch item.category {
        case .registration: return "building.columns.fill"
        case .documents: return "doc.text.fill"
        case .insurance: return "cross.case.fill"
        case .work: return "briefcase.fill"
        case .taxes: return "eurosign.circle.fill"
        case .housing: return "house.fill"
        case .education: return "graduationcap.fill"
        case .transport: return "tram.fill"
        }
    }

    private var checklistDetailAccent: Color {
        switch item.category {
        case .registration, .taxes:
            return AppColors.routeLine
        case .documents:
            return AppColors.dutchOrange
        case .insurance:
            return AppColors.error
        case .work:
            return AppColors.violet
        case .housing:
            return AppColors.emerald
        case .education:
            return AppColors.softBlue
        case .transport:
            return AppColors.dutchOrange
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack {
                Text(item.category.localized(lang))
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.chipBackground)
                    .clipShape(Capsule())
                Spacer()
                priorityBadge(item.priority)
            }
            Text(item.title(lang))
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
            Text(item.description(lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appCardStyle()
    }

    private var whyThisMattersSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(
                title: localized(en: "Why This Matters", nl: "Waarom Dit Belangrijk Is", ru: "Почему это важно"),
                subtitle: nil
            )
            InfoCard(
                title: localized(en: "Why do this", nl: "Waarom doen", ru: "Зачем делать"),
                subtitle: localized(en: "Step context", nl: "Stapcontext", ru: "Контекст шага"),
                detail: stepInsight.why[lang] ?? "",
                icon: "questionmark.circle"
            )
            InfoCard(
                title: localized(en: "If ignored", nl: "Als overgeslagen", ru: "Если пропустить"),
                subtitle: localized(en: "Risk", nl: "Risico", ru: "Риск"),
                detail: stepInsight.riskIfIgnored[lang] ?? "",
                icon: "exclamationmark.octagon"
            )
            InfoCard(
                title: localized(en: "What you need", nl: "Wat nodig is", ru: "Что нужно"),
                subtitle: localized(en: "Documents and inputs", nl: "Documenten en gegevens", ru: "Документы и данные"),
                detail: stepInsight.needed[lang] ?? "",
                icon: "doc.text"
            )
            InfoCard(
                title: localized(en: "Typical wait", nl: "Gemiddelde wachttijd", ru: "Обычно занимает"),
                subtitle: localized(en: "Time", nl: "Tijd", ru: "Срок"),
                detail: stepInsight.typicalWait[lang] ?? "",
                icon: "hourglass"
            )
            InfoCard(
                title: localized(en: "Common beginner mistake", nl: "Veelgemaakte beginnersfout", ru: "Частая ошибка новичков"),
                subtitle: localized(en: "Avoid this", nl: "Vermijd dit", ru: "Избегайте этого"),
                detail: stepInsight.commonMistake[lang] ?? "",
                icon: "xmark.shield"
            )
            InfoCard(
                title: localized(en: "Appointment required?", nl: "Afspraak nodig?", ru: "Нужна запись?"),
                subtitle: localized(en: "Check in advance", nl: "Controleer vooraf", ru: "Проверьте заранее"),
                detail: stepInsight.appointmentNeeded[lang] ?? "",
                icon: "calendar.badge.clock"
            )
            InfoCard(
                title: localized(en: "Possible cost", nl: "Mogelijke kosten", ru: "Возможная стоимость"),
                subtitle: localized(en: "Can vary", nl: "Kan verschillen", ru: "Может отличаться"),
                detail: stepInsight.possibleCost[lang] ?? "",
                icon: "eurosign.circle"
            )
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private func priorityBadge(_ priority: ChecklistPriority) -> some View {
        let color: Color = {
            switch priority {
            case .high: return AppColors.error
            case .medium: return AppColors.warning
            case .low: return AppColors.success
            }
        }()
        return Text(String(format: L10n.t("checklist.detail.priority_label", lang), priority.localized(lang)))
            .font(AppTypography.metadata)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}
