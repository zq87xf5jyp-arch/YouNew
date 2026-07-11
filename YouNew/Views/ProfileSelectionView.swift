import SwiftUI

struct ProfileSelectionView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                profileHero

                workspaceSection

                SectionHeader(title: L10n.t("profile.section.type", lang))

                ForEach(OnboardingProfile.allCases) { profile in
                    let status = profile.userStatus
                    NavigationLink(value: AppDestination.statusDirection(status)) {
                        HStack {
                            Image(systemName: profile.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(appState.selectedUserStatus == status ? AppColors.accent : AppColors.textSecondary)
                                .frame(width: 38, height: 38)
                                .background((appState.selectedUserStatus == status ? AppColors.accent : AppColors.textSecondary).opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.localized(lang))
                                    .font(AppTypography.bodyStrong)
                                    .foregroundStyle(AppColors.textPrimary)

                                Text(status.subtitle(lang))
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .lineLimit(2)
                            }

                            Spacer()

                            if appState.selectedUserStatus == status {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCardStyle()
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        select(profile)
                    })
                    .buttonStyle(.plain)
                }

                SectionHeader(title: L10n.t("profile.section.arrival", lang))
                Picker(L10n.t("profile.picker.arrival", lang), selection: $appState.userProfile.arrivalStatus) {
                    ForEach(ArrivalStatus.allCases) { status in
                        Text(status.localized(lang)).tag(status)
                    }
                }
                .pickerStyle(.menu)
                .appCardStyle()

                SectionHeader(title: L10n.t("profile.section.work_study", lang))
                Picker(L10n.t("profile.picker.work_status", lang), selection: $appState.userProfile.workStatus) {
                    ForEach(WorkStatus.allCases) { status in
                        Text(status.localized(lang)).tag(status)
                    }
                }
                .pickerStyle(.menu)
                .appCardStyle()

                Picker(L10n.t("profile.picker.student_status", lang), selection: $appState.userProfile.studentStatus) {
                    ForEach(StudentStatus.allCases) { status in
                        Text(status.localized(lang)).tag(status)
                    }
                }
                .pickerStyle(.menu)
                .appCardStyle()

                SectionHeader(title: L10n.t("profile.section.additional", lang))
                TextField(L10n.t("profile.field.nationality", lang), text: $appState.userProfile.nationalityPlaceholder)
                    .textFieldStyle(.plain)
                    .appInputStyle()
                TextField(L10n.t("profile.municipality", lang), text: $appState.userProfile.municipality)
                    .textFieldStyle(.plain)
                    .appInputStyle()
                TextField(L10n.t("profile.field.arrival_date", lang), text: $appState.userProfile.arrivalMonthYear)
                    .textFieldStyle(.plain)
                    .appInputStyle()
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .bottomTabSafeAreaPadding()
        }
        .topChromeSafeAreaPadding()
        .appSceneBackground()
        .navigationTitle(L10n.t("profile.title", lang))
    }

    private var profileHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: L10n.t("profile.title", lang),
            subtitle: profileHeroSubtitle,
            symbol: "person.crop.circle.badge.checkmark",
            badgeText: profileHeroBadge,
            accent: AppColors.cyanGlow,
            asset: ContentMediaRegistry.profileImage ?? ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 240,
            language: lang
        )
        .accessibilityIdentifier("profileSelection.hero")
    }

    private var workspaceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: workspaceTitle, subtitle: workspaceSubtitle)
            workspaceRow(
                title: localized(en: "My journey", nl: "Mijn route", ru: "Мой путь"),
                subtitle: localized(en: "Timeline and profile-specific steps", nl: "Tijdlijn en profielstappen", ru: "Timeline и шаги профиля"),
                icon: "figure.walk",
                tint: AppColors.cyanGlow,
                destination: .lifeTimeline
            )
            workspaceRow(
                title: localized(en: "Checklist", nl: "Checklist", ru: "Checklist"),
                subtitle: localized(en: "Recommended actions for your profile", nl: "Aanbevolen acties voor uw profiel", ru: "Рекомендованные действия для профиля"),
                icon: "checklist.checked",
                tint: AppColors.emerald,
                destination: .checklistList
            )
            workspaceRow(
                title: localized(en: "Documents", nl: "Documenten", ru: "Документы"),
                subtitle: localized(en: "BSN, DigiD, address, insurance readiness", nl: "BSN, DigiD, adres, verzekering", ru: "BSN, DigiD, адрес, страховка"),
                icon: "doc.text.fill",
                tint: AppColors.softBlue,
                destination: .journeyDocuments
            )
            workspaceRow(
                title: localized(en: "Deadlines", nl: "Deadlines", ru: "Дедлайны"),
                subtitle: localized(en: "Local reminders and important dates", nl: "Lokale herinneringen en belangrijke datums", ru: "Локальные напоминания и важные даты"),
                icon: "calendar.badge.clock",
                tint: AppColors.warning,
                destination: .deadlineCenter
            )
            documentReadinessToggles
        }
    }

    private func workspaceRow(title: String, subtitle: String, icon: String, tint: Color, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(AppColors.stroke.opacity(0.65), lineWidth: 0.8))
        }
        .buttonStyle(.plain)
    }

    private var documentReadinessToggles: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Toggle(localized(en: "I already have BSN", nl: "Ik heb al een BSN", ru: "У меня уже есть BSN"), isOn: $appState.userProfile.hasBSN)
            Toggle(localized(en: "I already have DigiD", nl: "Ik heb al DigiD", ru: "У меня уже есть DigiD"), isOn: $appState.userProfile.hasDigiD)
            Toggle(localized(en: "I have Dutch health insurance", nl: "Ik heb Nederlandse zorgverzekering", ru: "У меня есть нидерландская страховка"), isOn: $appState.userProfile.hasHealthInsuranceNL)
            Toggle(localized(en: "My address is registered", nl: "Mijn adres is ingeschreven", ru: "Мой адрес зарегистрирован"), isOn: $appState.userProfile.hasRegisteredAddress)
        }
        .font(AppTypography.footnote)
        .toggleStyle(SwitchToggleStyle(tint: AppColors.accentLight))
        .appCardStyle()
    }

    private func select(_ profile: OnboardingProfile) {
        let status = profile.userStatus
        appState.selectedUserStatus = status
        appState.userProfile.onboardingProfile = profile
        if let profileType = status.correspondingProfileType {
            appState.userProfile.profileType = profileType
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private var profileHeroSubtitle: String {
        switch lang {
        case .english:
            return "Choose the journey that matches your situation. Your workspace, checklist, documents, and AI guidance adapt from here."
        case .dutch:
            return "Kies de route die bij uw situatie past. Uw workspace, checklist, documenten en AI-hulp passen zich hierop aan."
        case .russian:
            return "Выберите сценарий под вашу ситуацию. Workspace, checklist, документы и AI-подсказки настроятся под него."
        }
    }

    private var profileHeroBadge: String {
        switch lang {
        case .english: return "Choose your journey"
        case .dutch: return "Kies uw route"
        case .russian: return "Выберите сценарий"
        }
    }

    private var workspaceTitle: String {
        localized(en: "Profile workspace", nl: "Profielworkspace", ru: "Профильный workspace")
    }

    private var workspaceSubtitle: String {
        localized(
            en: "Timeline, checklist, documents, and deadlines live here, not on the main Home.",
            nl: "Tijdlijn, checklist, documenten en deadlines staan hier, niet op Home.",
            ru: "Timeline, checklist, документы и дедлайны находятся здесь, а не на Home."
        )
    }
}
