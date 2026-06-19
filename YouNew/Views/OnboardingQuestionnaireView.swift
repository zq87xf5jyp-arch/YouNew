import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct OnboardingQuestionnaireView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.colorScheme) private var colorScheme

    private var lang: AppLanguage { languageManager.appLanguage }

    @State private var currentStep: Int = 0

    // Answers collected across steps
    @State private var selectedPersona: UserStatus? = nil
    @State private var selectedTimeInNL: TimeInNL? = nil
    @State private var selectedPriorities: Set<String> = []
    @State private var selectedCity: String = ""
    @State private var hasBSN = false
    @State private var hasDigiD = false
    @State private var hasHealthInsurance = false
    @State private var hasBankAccount = false
    @State private var hasRegisteredAddress = false

    private let totalSteps = 5
    private var priorityOptions: [(id: String, icon: String)] {
        priorityOptions(for: selectedPersona)
    }
    private var cities: [String] {
        [
            L10n.t("onboarding.city.amsterdam", lang),
            L10n.t("onboarding.city.rotterdam", lang),
            L10n.t("onboarding.city.den_haag", lang),
            L10n.t("onboarding.city.utrecht", lang),
            L10n.t("onboarding.city.leiden", lang),
            L10n.t("onboarding.city.eindhoven", lang),
            L10n.t("onboarding.city.groningen", lang),
            L10n.t("onboarding.city.other", lang)
        ]
    }

    private var canAdvance: Bool {
        switch currentStep {
        case 1: return selectedPersona != nil
        case 3: return !selectedPriorities.isEmpty
        default: return true
        }
    }

    var body: some View {
        ZStack {
            backgroundLayer
            decorativeArc

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.medium)

                if currentStep > 0 && currentStep <= totalSteps {
                    progressBar
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.small)
                }

                ScrollView(showsIndicators: false) {
                    Group {
                        switch currentStep {
                        case 0:   welcomeStep
                        case 1:   profileTypeStep
                        case 2:   timeInNLStep
                        case 3:   prioritiesStep
                        case 4:   cityStep
                        case 5:   documentsStep
                        default:  readyStep
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.large)
                    .tabBarScrollReserve()
                }

                ctaArea
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.bottom, AppSpacing.large)
                    .background {
                        LinearGradient(
                            colors: [
                                OnboardingDesignTokens.backgroundBase(colorScheme).opacity(0),
                                OnboardingDesignTokens.backgroundBase(colorScheme).opacity(0.86)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .bottom)
                    }
            }
        }
        .animation(AppAnimations.onboardingStep, value: currentStep)
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        GlobalBackgroundView()
    }

    private var decorativeArc: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 100))
            path.addCurve(
                to: CGPoint(x: 380, y: 220),
                control1: CGPoint(x: 90, y: 10),
                control2: CGPoint(x: 270, y: 290)
            )
        }
        .stroke(OnboardingDesignTokens.decorativeStroke(colorScheme),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [10, 10]))
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - Top bar

    private var topBar: some View {
        OnboardingTopBar(
            currentStep: currentStep,
            totalSteps: totalSteps,
            stepText: currentStep > 0 && currentStep <= totalSteps
                ? String(format: L10n.t("onboarding.step_progress", lang), currentStep, totalSteps)
                : nil,
            skipTitle: currentStep <= totalSteps ? L10n.t("onboarding.skip", lang) : nil,
            backLabel: L10n.t("common.back", lang),
            onBack: {
                withAnimation(AppAnimations.onboardingStep) { currentStep -= 1 }
            },
            onSkip: {
                if selectedPersona == nil {
                    withAnimation(AppAnimations.onboardingStep) { currentStep = 1 }
                } else {
                    applyAnswers()
                    appState.completeQuestionnaire()
                }
            }
        )
    }

    // MARK: - Progress bar

    private var progressBar: some View {
        OnboardingProgressBar(currentStep: currentStep, totalSteps: totalSteps)
    }

    // MARK: - CTA area

    private var ctaArea: some View {
        Group {
            if currentStep <= totalSteps {
                OnboardingPrimaryButton(title: ctaLabel, isEnabled: canAdvance) {
                    if currentStep == totalSteps {
                        applyAnswers()
                        withAnimation(AppAnimations.onboardingStep) { currentStep += 1 }
                    } else {
                        withAnimation(AppAnimations.onboardingStep) { currentStep += 1 }
                    }
                }
                .animation(AppAnimations.softSpring, value: canAdvance)
            } else {
                OnboardingPrimaryButton(title: L10n.t("onboarding.start_exploring", lang)) {
                    applyAnswers()
                    appState.completeQuestionnaire()
                }
            }
        }
    }

    private var ctaLabel: String {
        switch currentStep {
        case 0: return L10n.t("onboarding.cta.lets_go", lang)
        case totalSteps: return L10n.t("onboarding.cta.see_guide", lang)
        default: return L10n.t("onboarding.cta.continue", lang)
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            Spacer().frame(height: AppSpacing.medium)

            NetherlandsHeroMark()
                .padding(.bottom, AppSpacing.xSmall)

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text("YouNew.nl")
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(OnboardingDesignTokens.primaryText(colorScheme))

                Text(L10n.t("onboarding.welcome.title", lang))
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(OnboardingDesignTokens.primaryText(colorScheme))

                Text(L10n.t("onboarding.welcome.subtitle", lang))
                    .font(AppTypography.body)
                    .foregroundStyle(OnboardingDesignTokens.secondaryText(colorScheme))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer().frame(height: AppSpacing.medium)

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                welcomeFeatureRow(icon: "lock.shield", text: L10n.t("onboarding.welcome.feature.1", lang))
                welcomeFeatureRow(icon: "arrow.triangle.2.circlepath", text: L10n.t("onboarding.welcome.feature.2", lang))
                welcomeFeatureRow(icon: "clock", text: L10n.t("onboarding.welcome.feature.3", lang))
            }
            .padding(AppSpacing.cardPadding)
            .background(OnboardingDesignTokens.onboardingCardSurface(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(OnboardingDesignTokens.onboardingCardStroke(colorScheme), lineWidth: 1)
            }
            .shadow(color: OnboardingDesignTokens.cardShadow(colorScheme), radius: 18, x: 0, y: 10)
        }
    }

    private func welcomeFeatureRow(icon: String, text: String) -> some View {
        OnboardingInfoRow(icon: icon, text: text)
    }

    // MARK: - Step 1: Profile type

    private var profileTypeStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            stepHeader(title: L10n.t("onboarding.profile.title", lang),
                       subtitle: L10n.t("onboarding.profile.subtitle", lang))

            VStack(spacing: AppSpacing.small) {
                ForEach(UserStatus.allCases) { type in
                    QuestionnaireSelectionCard(
                        icon: type.icon,
                        title: type.localized(lang),
                        subtitle: type.subtitle(lang),
                        landmarkAssetName: landmarkAsset(for: type),
                        isSelected: selectedPersona == type
                    ) {
                        withAnimation(AppAnimations.softSpring) {
                            selectedPersona = type
                            prunePrioritiesForSelectedPersona()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 2: Time in NL

    private var timeInNLStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            stepHeader(title: L10n.t("onboarding.time_in_nl.title", lang),
                       subtitle: L10n.t("onboarding.time_in_nl.subtitle", lang))

            VStack(spacing: AppSpacing.small) {
                ForEach(TimeInNL.allCases) { time in
                    QuestionnaireSelectionCard(
                        icon: time.icon,
                        title: time.localized(lang),
                        subtitle: nil,
                        landmarkAssetName: landmarkAsset(for: time),
                        isSelected: selectedTimeInNL == time
                    ) {
                        withAnimation(AppAnimations.softSpring) { selectedTimeInNL = time }
                    }
                }
            }
        }
    }

    // MARK: - Step 3: Priorities

    private var prioritiesStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            stepHeader(title: L10n.t("onboarding.priorities.title", lang),
                       subtitle: L10n.t("onboarding.priorities.subtitle", lang))

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: AppSpacing.small
            ) {
                ForEach(priorityOptions, id: \.id) { priority in
                    QuestionnairePriorityChip(
                        icon: priority.icon,
                        title: localizedPriority(priority.id),
                        isSelected: selectedPriorities.contains(priority.id)
                    ) {
                        withAnimation(AppAnimations.softSpring) {
                            if selectedPriorities.contains(priority.id) {
                                selectedPriorities.remove(priority.id)
                            } else {
                                selectedPriorities.insert(priority.id)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 4: City

    private var cityStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            stepHeader(title: L10n.t("onboarding.city.title", lang),
                       subtitle: L10n.t("onboarding.city.subtitle", lang))

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: AppSpacing.small
            ) {
                ForEach(cities, id: \.self) { city in
                    QuestionnaireCityCard(
                        city: city,
                        isSelected: selectedCity == city
                    ) {
                        withAnimation(AppAnimations.softSpring) { selectedCity = city }
                    }
                }
            }
        }
    }

    // MARK: - Step 5: Documents

    private var documentsStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            stepHeader(title: L10n.t("onboarding.documents.title", lang),
                       subtitle: L10n.t("onboarding.documents.subtitle", lang))

            VStack(spacing: AppSpacing.xSmall) {
                documentToggleRow(
                    title: L10n.t("onboarding.documents.bsn.title", lang),
                    subtitle: L10n.t("onboarding.documents.bsn.subtitle", lang),
                    icon: "person.text.rectangle",
                    value: $hasBSN
                )
                documentToggleRow(
                    title: L10n.t("onboarding.documents.digid.title", lang),
                    subtitle: L10n.t("onboarding.documents.digid.subtitle", lang),
                    icon: "person.badge.key",
                    value: $hasDigiD
                )
                documentToggleRow(
                    title: L10n.t("onboarding.documents.insurance.title", lang),
                    subtitle: L10n.t("onboarding.documents.insurance.subtitle", lang),
                    icon: "cross.case",
                    value: $hasHealthInsurance
                )
                documentToggleRow(
                    title: L10n.t("onboarding.documents.bank.title", lang),
                    subtitle: L10n.t("onboarding.documents.bank.subtitle", lang),
                    icon: "banknote",
                    value: $hasBankAccount
                )
                documentToggleRow(
                    title: L10n.t("onboarding.documents.address.title", lang),
                    subtitle: L10n.t("onboarding.documents.address.subtitle", lang),
                    icon: "house",
                    value: $hasRegisteredAddress
                )
            }
        }
    }

    private func documentToggleRow(title: String, subtitle: String, icon: String, value: Binding<Bool>) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(value.wrappedValue ? OnboardingDesignTokens.accentCyan : OnboardingDesignTokens.mutedText(colorScheme))
                .frame(width: 38, height: 38)
                .background(OnboardingDesignTokens.iconSurface(colorScheme, isSelected: value.wrappedValue))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
                .animation(AppAnimations.softSpring, value: value.wrappedValue)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(OnboardingDesignTokens.primaryText(colorScheme))
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(OnboardingDesignTokens.secondaryText(colorScheme))
            }

            Spacer()

            Toggle("", isOn: value)
                .toggleStyle(SwitchToggleStyle(tint: AppColors.accentLight))
                .labelsHidden()
        }
        .padding(AppSpacing.cardPaddingCompact)
        .background(OnboardingDesignTokens.surface(colorScheme, isSelected: value.wrappedValue))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                .stroke(value.wrappedValue ? OnboardingDesignTokens.selectedStroke(colorScheme) : OnboardingDesignTokens.surfaceStroke(colorScheme), lineWidth: 1)
        )
        .animation(AppAnimations.softSpring, value: value.wrappedValue)
    }

    // MARK: - Step 6: Ready

    private var readyStep: some View {
        VStack(alignment: .center, spacing: AppSpacing.large) {
            Spacer().frame(height: AppSpacing.large)

            Group {
                if #available(iOS 18.0, *) {
                    Image(systemName: "checkmark.circle.fill")
                        .symbolEffect(.bounce)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .font(.system(size: 68, weight: .light))
            .foregroundStyle(OnboardingDesignTokens.accentCyan)

            VStack(spacing: AppSpacing.small) {
                Text(L10n.t("onboarding.ready.title", lang))
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(OnboardingDesignTokens.primaryText(colorScheme))
                    .multilineTextAlignment(.center)

                Text(L10n.t("onboarding.ready.subtitle", lang))
                    .font(AppTypography.body)
                    .foregroundStyle(OnboardingDesignTokens.secondaryText(colorScheme))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                profileSummaryRow(icon: "person", value: selectedPersona?.localized(lang) ?? L10n.t("onboarding.ready.general_path", lang))
                if !selectedCity.isEmpty {
                    profileSummaryRow(icon: "mappin.circle", value: selectedCity)
                }
                profileSummaryRow(icon: "clock", value: selectedTimeInNL?.localized(lang) ?? L10n.t("onboarding.ready.recently_arrived", lang))
                if !selectedPriorities.isEmpty {
                    profileSummaryRow(
                        icon: "star",
                        value: selectedPriorities.prefix(3).map(localizedPriority).joined(separator: " · ")
                    )
                }
            }
            .padding(AppSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(OnboardingDesignTokens.onboardingCardSurface(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .stroke(OnboardingDesignTokens.onboardingCardStroke(colorScheme), lineWidth: 1)
            )
            .shadow(color: OnboardingDesignTokens.cardShadow(colorScheme), radius: 18, x: 0, y: 10)
        }
        .frame(maxWidth: .infinity)
    }

    private func profileSummaryRow(icon: String, value: String) -> some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.accentLight)
                .frame(width: 18)
            Text(value)
                .font(AppTypography.footnote)
                .foregroundStyle(OnboardingDesignTokens.primaryText(colorScheme))
                .lineLimit(1)
        }
    }

    // MARK: - Shared helpers

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(title)
                .font(AppTypography.title)
                .foregroundStyle(OnboardingDesignTokens.primaryText(colorScheme))
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(AppTypography.body)
                .foregroundStyle(OnboardingDesignTokens.secondaryText(colorScheme))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func applyAnswers() {
        if let persona = selectedPersona {
            appState.selectedUserStatus = persona
            if let profile = persona.correspondingProfileType {
                appState.userProfile.profileType = profile
            }
        }
        if let time = selectedTimeInNL {
            appState.userProfile.timeInNL = time
        }
        if !selectedPriorities.isEmpty {
            appState.userProfile.priorities = selectedPriorities.compactMap { .init(rawValue: $0) }
        }
        if !selectedCity.isEmpty {
            appState.userProfile.municipality = selectedCity
        }
        appState.userProfile.hasBSN = hasBSN
        appState.userProfile.hasDigiD = hasDigiD
        appState.userProfile.hasHealthInsuranceNL = hasHealthInsurance
        appState.userProfile.hasBankAccountNL = hasBankAccount
        appState.userProfile.hasRegisteredAddress = hasRegisteredAddress
    }

    private func localizedPriority(_ id: String) -> String {
        switch id {
        case "documents":       return L10n.t("profile.priority.documents", lang)
        case "housing":         return L10n.t("profile.priority.housing", lang)
        case "work":            return L10n.t("profile.priority.work", lang)
        case "taxes":           return L10n.t("profile.priority.taxes", lang)
        case "healthInsurance": return L10n.t("profile.priority.health_insurance", lang)
        case "education":       return L10n.t("profile.priority.education", lang)
        case "finesAndLetters": return L10n.t("profile.priority.fines_and_letters", lang)
        case "integration":     return L10n.t("profile.priority.integration", lang)
        case "studentFinance":  return localized(en: "Student finance", nl: "Studiefinanciering", ru: "Студенческие финансы")
        case "studentTransport": return localized(en: "Student transport", nl: "Studentenvervoer", ru: "Студенческий транспорт")
        case "studentJobs":     return localized(en: "Student jobs", nl: "Studentenbanen", ru: "Студенческая работа")
        case "language":        return localized(en: "Language", nl: "Taal", ru: "Язык")
        case "cityLife":        return localized(en: "City life", nl: "Stadsleven", ru: "Городская жизнь")
        case "transport":       return localized(en: "Transport", nl: "Vervoer", ru: "Транспорт")
        case "pension":         return localized(en: "Pension", nl: "Pensioen", ru: "Пенсия")
        case "workerTraining":  return localized(en: "Worker training", nl: "Werknemerstraining", ru: "Обучение работников")
        case "benefits":        return localized(en: "Benefits", nl: "Uitkeringen", ru: "Пособия")
        case "healthcare":      return localized(en: "Healthcare", nl: "Zorg", ru: "Медицина")
        case "workPermission":  return localized(en: "Work permission", nl: "Werktoestemming", ru: "Разрешение на работу")
        case "supportOrganizations": return localized(en: "Support organizations", nl: "Steunorganisaties", ru: "Организации поддержки")
        case "schools":         return localized(en: "Schools", nl: "Scholen", ru: "Школы")
        case "childcare":       return localized(en: "Childcare", nl: "Kinderopvang", ru: "Детский сад")
        case "childBenefits":   return localized(en: "Child benefits", nl: "Kinderbijslag", ru: "Детские пособия")
        case "activities":      return localized(en: "Activities", nl: "Activiteiten", ru: "Активности")
        case "municipalServices": return localized(en: "Municipal services", nl: "Gemeentediensten", ru: "Муниципальные услуги")
        case "emergency":       return localized(en: "Emergency", nl: "Noodhulp", ru: "Экстренная помощь")
        case "freeTime":        return localized(en: "Free time", nl: "Vrije tijd", ru: "Свободное время")
        case "businessRegistration": return localized(en: "Business registration", nl: "Bedrijfsregistratie", ru: "Регистрация бизнеса")
        case "banking":         return localized(en: "Banking", nl: "Bankieren", ru: "Банкинг")
        case "permits":         return localized(en: "Permits", nl: "Vergunningen", ru: "Разрешения")
        case "legalSafety":     return localized(en: "Legal safety", nl: "Juridische veiligheid", ru: "Правовая безопасность")
        case "community":       return localized(en: "Community", nl: "Gemeenschap", ru: "Сообщество")
        case "family":          return localized(en: "Family", nl: "Gezin", ru: "Семья")
        default:                return id
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private func priorityOptions(for persona: UserStatus?) -> [(id: String, icon: String)] {
        switch persona?.personaTag {
        case .student:
            return [
                ("education", "book"),
                ("housing", "house"),
                ("healthInsurance", "cross.case"),
                ("studentFinance", "creditcard"),
                ("studentTransport", "tram"),
                ("studentJobs", "briefcase"),
                ("language", "text.book.closed"),
                ("cityLife", "building.2")
            ]
        case .worker:
            return [
                ("documents", "doc.text"),
                ("work", "briefcase"),
                ("taxes", "eurosign.circle"),
                ("healthInsurance", "cross.case"),
                ("housing", "house"),
                ("transport", "tram"),
                ("pension", "person.crop.circle.badge.clock"),
                ("workerTraining", "wrench.and.screwdriver")
            ]
        case .refugee:
            return [
                ("documents", "doc.text"),
                ("housing", "house"),
                ("benefits", "banknote"),
                ("integration", "figure.2"),
                ("language", "text.book.closed"),
                ("healthcare", "cross.case"),
                ("workPermission", "doc.badge.gearshape"),
                ("supportOrganizations", "person.3")
            ]
        case .family:
            return [
                ("schools", "graduationcap"),
                ("childcare", "figure.and.child.holdinghands"),
                ("childBenefits", "person.2"),
                ("housing", "house"),
                ("healthcare", "cross.case"),
                ("activities", "calendar"),
                ("municipalServices", "building.columns")
            ]
        case .tourist:
            return [
                ("transport", "tram"),
                ("healthcare", "cross.case"),
                ("cityLife", "building.2"),
                ("emergency", "phone"),
                ("freeTime", "sparkles")
            ]
        case .entrepreneur:
            return [
                ("documents", "doc.text"),
                ("businessRegistration", "building.columns"),
                ("taxes", "eurosign.circle"),
                ("banking", "creditcard"),
                ("permits", "doc.badge.gearshape"),
                ("housing", "house")
            ]
        case .lgbt:
            return [
                ("healthcare", "cross.case"),
                ("housing", "house"),
                ("legalSafety", "shield"),
                ("supportOrganizations", "person.3"),
                ("community", "heart")
            ]
        case .eu:
            return [
                ("documents", "doc.text"),
                ("healthcare", "cross.case"),
                ("housing", "house"),
                ("transport", "tram"),
                ("work", "briefcase"),
                ("education", "book")
            ]
        case .highlySkilledMigrant:
            return [
                ("documents", "doc.text"),
                ("work", "briefcase"),
                ("taxes", "eurosign.circle"),
                ("housing", "house"),
                ("healthInsurance", "cross.case"),
                ("family", "person.2")
            ]
        case .nonEU, .universal, nil:
            return [
                ("documents", "doc.text"),
                ("housing", "house"),
                ("healthcare", "cross.case"),
                ("language", "text.book.closed")
            ]
        }
    }

    private func prunePrioritiesForSelectedPersona() {
        let allowed = Set(priorityOptions.map(\.id))
        selectedPriorities = selectedPriorities.filter { allowed.contains($0) }
    }

    private func landmarkAsset(for persona: UserStatus) -> String {
        switch persona {
        case .worker:
            return "premium_home_work"
        case .student:
            return "premium_home_language"
        case .expat, .highlySkilledMigrant, .entrepreneur:
            return "premium_home_work"
        case .refugee, .ukrainian, .lgbtNewcomer:
            return "home_documents_city_hall"
        case .euCitizen, .tourist, .family:
            return "premium_home_work"
        }
    }

    private func landmarkAsset(for timeInNL: TimeInNL) -> String {
        switch timeInNL {
        case .justArrived:
            return "premium_home_documents"
        case .lessThan3Months:
            return "premium_home_documents"
        case .threeToTwelveMonths:
            return "premium_home_language"
        case .moreThanYear:
            return "premium_home_work"
        }
    }
}

// MARK: - Selection Card

private struct QuestionnaireSelectionCard: View {
    let icon: String
    let title: String
    let subtitle: String?
    let landmarkAssetName: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        OnboardingOptionCard(
            icon: icon,
            title: title,
            subtitle: subtitle,
            landmarkAssetName: landmarkAssetName,
            isSelected: isSelected,
            action: action
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Premium Onboarding System

private enum OnboardingDesignTokens {
    static let dutchRed = Color(red: 174/255, green: 28/255, blue: 40/255)
    static let dutchBlue = Color(red: 33/255, green: 70/255, blue: 139/255)
    static let accentCyan = Color(red: 40/255, green: 214/255, blue: 232/255)
    static let accentBlue = Color(red: 74/255, green: 163/255, blue: 255/255)
    static let accentOrange = Color(red: 255/255, green: 159/255, blue: 69/255)

    static func backgroundBase(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 7/255, green: 17/255, blue: 31/255)
            : Color(red: 238/255, green: 247/255, blue: 250/255)
    }

    static func primaryText(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white
            : Color(red: 7/255, green: 17/255, blue: 31/255)
    }

    static func onboardingPrimaryText(_ scheme: ColorScheme) -> Color {
        primaryText(scheme)
    }

    static func secondaryText(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 214/255, green: 228/255, blue: 244/255)
            : Color(red: 39/255, green: 58/255, blue: 82/255)
    }

    static func onboardingSecondaryText(_ scheme: ColorScheme) -> Color {
        secondaryText(scheme)
    }

    static func mutedText(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 159/255, green: 181/255, blue: 207/255)
            : Color(red: 82/255, green: 102/255, blue: 128/255)
    }

    static func onboardingMutedText(_ scheme: ColorScheme) -> Color {
        mutedText(scheme)
    }

    static func surface(_ scheme: ColorScheme, isSelected: Bool = false) -> Color {
        if scheme == .dark {
            return Color(red: 22/255, green: 36/255, blue: 60/255).opacity(isSelected ? 0.88 : 0.74)
        }
        return Color(red: 250/255, green: 253/255, blue: 255/255).opacity(isSelected ? 0.97 : 0.91)
    }

    static func onboardingCardSurface(_ scheme: ColorScheme, isSelected: Bool = false) -> Color {
        surface(scheme, isSelected: isSelected)
    }

    static func iconSurface(_ scheme: ColorScheme, isSelected: Bool) -> Color {
        if isSelected {
            return accentCyan.opacity(scheme == .dark ? 0.20 : 0.15)
        }
        return primaryText(scheme).opacity(scheme == .dark ? 0.10 : 0.07)
    }

    static func surfaceStroke(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.20)
            : Color(red: 8/255, green: 34/255, blue: 54/255).opacity(0.16)
    }

    static func onboardingCardStroke(_ scheme: ColorScheme) -> Color {
        surfaceStroke(scheme)
    }

    static func selectedStroke(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? accentCyan.opacity(0.76) : Color(red: 20/255, green: 121/255, blue: 212/255).opacity(0.72)
    }

    static func onboardingAccentBlue(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? accentCyan : Color(red: 18/255, green: 112/255, blue: 198/255)
    }

    static func onboardingAccentRed(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? dutchRed.opacity(0.92) : dutchRed
    }

    static func cardShadow(_ scheme: ColorScheme, isSelected: Bool = false) -> Color {
        if isSelected {
            return onboardingAccentBlue(scheme).opacity(scheme == .dark ? 0.26 : 0.18)
        }
        return Color.black.opacity(scheme == .dark ? 0.24 : 0.08)
    }

    static func decorativeStroke(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.07)
            : Color(red: 7/255, green: 17/255, blue: 31/255).opacity(0.07)
    }

    static func progressTrack(_ scheme: ColorScheme) -> Color {
        primaryText(scheme).opacity(scheme == .dark ? 0.16 : 0.12)
    }

    static var activeGradient: LinearGradient {
        LinearGradient(
            colors: [accentCyan, accentBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct DutchFlagWaveBand: View {
    let color: Color
    let opacity: Double

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 54))
            path.addCurve(
                to: CGPoint(x: 420, y: 42),
                control1: CGPoint(x: 112, y: -8),
                control2: CGPoint(x: 270, y: 108)
            )
            path.addLine(to: CGPoint(x: 420, y: 118))
            path.addCurve(
                to: CGPoint(x: 0, y: 112),
                control1: CGPoint(x: 292, y: 158),
                control2: CGPoint(x: 126, y: 72)
            )
            path.closeSubpath()
        }
        .fill(color.opacity(opacity))
        .rotationEffect(.degrees(-9))
    }
}

private struct OnboardingTopBar: View {
    let currentStep: Int
    let totalSteps: Int
    let stepText: String?
    let skipTitle: String?
    let backLabel: String          // localized "Back" / "Назад" / "Terug"
    let onBack: () -> Void
    let onSkip: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            if currentStep > 0 && currentStep <= totalSteps {
                Button(action: onBack) {
                    Image(systemName: AppIcons.back)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(OnboardingDesignTokens.primaryText(colorScheme))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .background(OnboardingDesignTokens.onboardingCardSurface(colorScheme))
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(OnboardingDesignTokens.onboardingCardStroke(colorScheme), lineWidth: 1)
                        }
                }
                .buttonStyle(OnboardingPressableStyle())
                .accessibilityLabel(backLabel)
            } else {
                Spacer().frame(width: 44)
            }

            Spacer()

            if let stepText {
                Text(stepText)
                    .font(AppTypography.metadata)
                    .foregroundStyle(OnboardingDesignTokens.secondaryText(colorScheme))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(OnboardingDesignTokens.onboardingCardSurface(colorScheme))
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .stroke(OnboardingDesignTokens.onboardingCardStroke(colorScheme), lineWidth: 1)
                    }
            }

            Spacer()

            if let skipTitle {
                Button(action: onSkip) {
                    Text(skipTitle)
                        .font(AppTypography.footnoteStrong)
                        .foregroundStyle(OnboardingDesignTokens.primaryText(colorScheme))
                        .frame(minWidth: 44, minHeight: 44)
                        .padding(.horizontal, 8)
                        .background(OnboardingDesignTokens.onboardingCardSurface(colorScheme))
                        .clipShape(Capsule())
                        .overlay {
                            Capsule()
                                .stroke(OnboardingDesignTokens.onboardingCardStroke(colorScheme), lineWidth: 1)
                        }
                }
                .buttonStyle(OnboardingPressableStyle())
            } else {
                Spacer().frame(width: 44)
            }
        }
    }
}

private struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(OnboardingDesignTokens.progressTrack(colorScheme))
                    .frame(height: 5)
                Capsule()
                    .fill(OnboardingDesignTokens.activeGradient)
                    .frame(
                        width: geo.size.width * (Double(currentStep) / Double(totalSteps)),
                        height: 5
                    )
                    .shadow(color: OnboardingDesignTokens.accentCyan.opacity(0.24), radius: 8, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.35), value: currentStep)
            }
        }
        .frame(height: 5)
    }
}

private struct OnboardingPrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(isEnabled ? Color.white : OnboardingDesignTokens.mutedText(colorScheme))
                .frame(maxWidth: .infinity, minHeight: 56)
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(isEnabled ? OnboardingDesignTokens.activeGradient : LinearGradient(colors: [OnboardingDesignTokens.surface(colorScheme), OnboardingDesignTokens.surface(colorScheme)], startPoint: .leading, endPoint: .trailing))
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(LinearGradient(colors: [Color.white.opacity(isEnabled ? 0.18 : 0.04), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(isEnabled ? Color.white.opacity(0.24) : OnboardingDesignTokens.surfaceStroke(colorScheme), lineWidth: 1)
                }
                .shadow(color: isEnabled ? OnboardingDesignTokens.accentCyan.opacity(0.28) : .clear, radius: 18, x: 0, y: 9)
        }
        .disabled(!isEnabled)
        .buttonStyle(OnboardingPressableStyle())
        .accessibilityLabel(title)
    }
}

private struct OnboardingInfoRow: View {
    let icon: String
    let text: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.small) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(OnboardingDesignTokens.accentCyan)
                .frame(width: 20, height: 20)
                .accessibilityHidden(true)
            Text(text)
                .font(AppTypography.footnote)
                .foregroundStyle(OnboardingDesignTokens.secondaryText(colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct OnboardingOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String?
    let landmarkAssetName: String?
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.medium) {
                OnboardingLandmarkImageBadge(
                    assetName: landmarkAssetName,
                    fallbackSymbol: icon,
                    isSelected: isSelected
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(OnboardingDesignTokens.primaryText(colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                    if let subtitle {
                        Text(subtitle)
                            .font(AppTypography.caption)
                            .foregroundStyle(OnboardingDesignTokens.secondaryText(colorScheme))
                            .lineLimit(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: AppSpacing.small)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? OnboardingDesignTokens.accentCyan : OnboardingDesignTokens.mutedText(colorScheme))
            }
            .padding(.horizontal, AppSpacing.cardPaddingCompact)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 98, alignment: .leading)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(OnboardingDesignTokens.onboardingCardSurface(colorScheme, isSelected: isSelected))
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.10 : 0.34),
                                    OnboardingDesignTokens.onboardingAccentBlue(colorScheme).opacity(isSelected ? 0.11 : 0.025),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    if isSelected {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        OnboardingDesignTokens.accentCyan.opacity(colorScheme == .dark ? 0.10 : 0.06),
                                        .clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(isSelected ? OnboardingDesignTokens.selectedStroke(colorScheme) : OnboardingDesignTokens.onboardingCardStroke(colorScheme), lineWidth: isSelected ? 1.5 : 1)
            }
            .shadow(color: OnboardingDesignTokens.cardShadow(colorScheme, isSelected: isSelected), radius: isSelected ? 24 : 12, x: 0, y: isSelected ? 12 : 6)
            .animation(AppAnimations.softSpring, value: isSelected)
        }
        .buttonStyle(OnboardingPressableStyle())
    }
}

private struct OnboardingLandmarkImageBadge: View {
    let assetName: String?
    let fallbackSymbol: String
    var isSelected: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    private var hasAsset: Bool {
        guard let assetName else { return false }
        return Self.assetExists(named: assetName)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(OnboardingDesignTokens.iconSurface(colorScheme, isSelected: isSelected))

            if let assetName, hasAsset {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .overlay {
                        LinearGradient(
                            colors: [Color.black.opacity(0.04), Color.black.opacity(0.32)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            } else {
                LinearGradient(
                    colors: [
                        OnboardingDesignTokens.dutchBlue.opacity(colorScheme == .dark ? 0.72 : 0.64),
                        OnboardingDesignTokens.dutchRed.opacity(colorScheme == .dark ? 0.46 : 0.42),
                        OnboardingDesignTokens.backgroundBase(colorScheme).opacity(colorScheme == .dark ? 0.12 : 0.32)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: fallbackSymbol)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.92))
            }

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(colorScheme == .dark ? 0.12 : 0.26), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.20 : 0.42), lineWidth: 0.75)
        }
        .frame(width: 58, height: 58)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.22 : 0.10), radius: 10, x: 0, y: 5)
        .accessibilityHidden(true)
    }

    private static func assetExists(named name: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: name) != nil
        #elseif canImport(AppKit)
        return NSImage(named: name) != nil
        #else
        return false
        #endif
    }
}

private struct NetherlandsHeroMark: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(OnboardingDesignTokens.onboardingCardSurface(colorScheme, isSelected: true))
                .overlay {
                    ZStack {
                        DutchFlagWaveBand(color: OnboardingDesignTokens.dutchRed, opacity: colorScheme == .dark ? 0.30 : 0.14)
                            .offset(y: -30)
                        DutchFlagWaveBand(color: Color.white, opacity: colorScheme == .dark ? 0.18 : 0.38)
                            .offset(y: 18)
                        DutchFlagWaveBand(color: OnboardingDesignTokens.dutchBlue, opacity: colorScheme == .dark ? 0.34 : 0.18)
                            .offset(y: 56)
                    }
                    .blur(radius: 9)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                }
                .overlay {
                    // Top-edge highlight for depth
                    LinearGradient(
                        colors: [Color.white.opacity(colorScheme == .dark ? 0.10 : 0.36), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                }

            HStack(spacing: AppSpacing.medium) {
                OnboardingLandmarkImageBadge(
                    assetName: "premium_home_documents",
                    fallbackSymbol: "building.2.crop.circle",
                    isSelected: true
                )
                .frame(width: 68, height: 68)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Nederland")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(OnboardingDesignTokens.primaryText(colorScheme))
                    HStack(spacing: 5) {
                        Capsule()
                            .fill(OnboardingDesignTokens.onboardingAccentRed(colorScheme))
                        Capsule()
                            .fill(colorScheme == .dark ? Color.white.opacity(0.82) : Color.white)
                        Capsule()
                            .fill(OnboardingDesignTokens.dutchBlue)
                    }
                    .frame(width: 64, height: 10)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.22 : 0.08), radius: 5, x: 0, y: 2)
                    .accessibilityHidden(true)
                }

                Spacer()

                Image(systemName: "location.north.circle.fill")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [OnboardingDesignTokens.accentCyan, OnboardingDesignTokens.accentBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(0.72)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.medium)
        }
        .frame(height: 122)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.22 : 0.54),
                            OnboardingDesignTokens.dutchBlue.opacity(colorScheme == .dark ? 0.36 : 0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: OnboardingDesignTokens.dutchBlue.opacity(colorScheme == .dark ? 0.26 : 0.12), radius: 24, x: 0, y: 12)
        .accessibilityLabel(localizedNetherlandsAccessibilityLabel)
    }

    private var localizedNetherlandsAccessibilityLabel: String {
        switch languageManager.appLanguage {
        case .russian: return "Нидерланды"
        case .dutch: return "Nederland"
        case .english: return "Netherlands"
        }
    }
}

private struct OnboardingPressableStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(reduceMotion ? nil : AppAnimations.tactilePress, value: configuration.isPressed)
    }
}

// MARK: - Priority Chip

private struct QuestionnairePriorityChip: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xSmall) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(isSelected ? OnboardingDesignTokens.accentCyan : OnboardingDesignTokens.secondaryText(colorScheme))
                    .animation(AppAnimations.softSpring, value: isSelected)

                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(isSelected ? OnboardingDesignTokens.primaryText(colorScheme) : OnboardingDesignTokens.secondaryText(colorScheme))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 88)
            .background(OnboardingDesignTokens.surface(colorScheme, isSelected: isSelected))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? OnboardingDesignTokens.selectedStroke(colorScheme) : OnboardingDesignTokens.surfaceStroke(colorScheme), lineWidth: 1)
            )
            .shadow(color: isSelected ? OnboardingDesignTokens.accentCyan.opacity(0.16) : .clear, radius: 16, x: 0, y: 8)
            .animation(AppAnimations.softSpring, value: isSelected)
        }
        .buttonStyle(OnboardingPressableStyle())
    }
}

// MARK: - City Card

private struct QuestionnaireCityCard: View {
    let city: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            Text(city)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(isSelected ? OnboardingDesignTokens.primaryText(colorScheme) : OnboardingDesignTokens.secondaryText(colorScheme))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 56)
                .background(OnboardingDesignTokens.surface(colorScheme, isSelected: isSelected))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isSelected ? OnboardingDesignTokens.selectedStroke(colorScheme) : OnboardingDesignTokens.surfaceStroke(colorScheme), lineWidth: 1)
                )
                .shadow(color: isSelected ? OnboardingDesignTokens.accentCyan.opacity(0.14) : .clear, radius: 14, x: 0, y: 7)
                .animation(AppAnimations.softSpring, value: isSelected)
        }
        .buttonStyle(OnboardingPressableStyle())
    }
}
