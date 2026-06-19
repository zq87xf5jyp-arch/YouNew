import SwiftUI

struct DutchMonarchyView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    @State private var expandedMonarchID: String?
    @State private var expandedCardID: String?

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    heroSection

                    NLSectionHeader(title: monarchsTitle, subtitle: monarchsSubtitle)
                    monarchsTimeline

                    NLSectionHeader(title: howItWorksTitle, subtitle: howItWorksSubtitle)
                    monarchyCards

                    sourceNote
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(navTitle)
        .nlNavigationInline()
    }

    // MARK: - Sections

    private var heroSection: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: navTitle,
            subtitle: heroSubtitle,
            symbol: "crown.fill",
            badgeText: badgeText,
            accent: AppColors.violet
        )
    }

    private var monarchsTimeline: some View {
        LazyVStack(spacing: 10) {
            ForEach(MockDutchHolidaysData.monarchs) { monarch in
                MonarchCard(
                    monarch: monarch,
                    lang: lang,
                    isExpanded: expandedMonarchID == monarch.id,
                    onToggle: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            expandedMonarchID = expandedMonarchID == monarch.id ? nil : monarch.id
                        }
                    }
                )
            }
        }
    }

    private var monarchyCards: some View {
        LazyVStack(spacing: 10) {
            ForEach(MockNetherlandsUnderstandingData.monarchyCards) { card in
                CivicCard(
                    item: card,
                    lang: lang,
                    isExpanded: expandedCardID == card.id,
                    onToggle: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            expandedCardID = expandedCardID == card.id ? nil : card.id
                        }
                    }
                )
            }
        }
    }

    private var sourceNote: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(sourceTitle, systemImage: "checkmark.seal.fill")
                .font(AppTypography.footnoteStrong)
                .foregroundStyle(AppColors.cyanGlow)
            Text(sourceBody)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cyanGlow.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(AppColors.cyanGlow.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Strings

    private var navTitle: String {
        switch lang {
        case .russian: return "Монархия Нидерландов"
        case .dutch:   return "Nederlandse Monarchie"
        case .english: return "Dutch Monarchy"
        }
    }

    private var heroSubtitle: String {
        switch lang {
        case .russian: return "Короли и королевы от Виллема I до Виллема-Александра. Как работает конституционная монархия сегодня."
        case .dutch:   return "Koningen en koninginnen van Willem I tot Willem-Alexander. Hoe de constitutionele monarchie vandaag werkt."
        case .english: return "Kings and queens from Willem I to Willem-Alexander. How the constitutional monarchy works today."
        }
    }

    private var badgeText: String {
        switch lang {
        case .russian: return "1815–настоящее время · Конституционная монархия"
        case .dutch:   return "1815–heden · Constitutionele monarchie"
        case .english: return "1815–present · Constitutional monarchy"
        }
    }

    private var monarchsTitle: String {
        switch lang {
        case .russian: return "Короли и королевы"
        case .dutch:   return "Koningen en koninginnen"
        case .english: return "Kings & Queens"
        }
    }

    private var monarchsSubtitle: String {
        switch lang {
        case .russian: return "Хронология с 1815 года до наших дней"
        case .dutch:   return "Tijdlijn van 1815 tot heden"
        case .english: return "Timeline from 1815 to the present"
        }
    }

    private var howItWorksTitle: String {
        switch lang {
        case .russian: return "Как работает монархия сегодня"
        case .dutch:   return "Hoe de monarchie vandaag werkt"
        case .english: return "How the monarchy works today"
        }
    }

    private var howItWorksSubtitle: String {
        switch lang {
        case .russian: return "Роль короля, ответственность министров, Prinsjesdag, День короля"
        case .dutch:   return "Rol van de Koning, ministeriele verantwoordelijkheid, Prinsjesdag, Koningsdag"
        case .english: return "Role of the King, ministerial responsibility, Prinsjesdag, King's Day"
        }
    }

    private var sourceTitle: String {
        switch lang {
        case .russian: return "Источник: Royal House of the Netherlands · Government.nl"
        case .dutch:   return "Bron: Koninklijk Huis der Nederlanden · Government.nl"
        case .english: return "Source: Royal House of the Netherlands · Government.nl"
        }
    }

    private var sourceBody: String {
        switch lang {
        case .russian: return "Информация о монархии основана на официальных данных Королевского дома Нидерландов (royal-house.nl) и Government.nl. Нидерланды — конституционная монархия: министры политически ответственны за решения правительства, а не монарх."
        case .dutch:   return "Monarchie-informatie is gebaseerd op officiële gegevens van het Koninklijk Huis der Nederlanden (royal-house.nl) en Government.nl. Nederland is een constitutionele monarchie: ministers zijn politiek verantwoordelijk voor regeringsbesluiten, niet de monarch."
        case .english: return "Monarchy information is based on official data from the Royal House of the Netherlands (royal-house.nl) and Government.nl. The Netherlands is a constitutional monarchy: ministers are politically responsible for government decisions, not the monarch."
        }
    }
}

// MARK: - MonarchCard

private struct MonarchCard: View {
    let monarch: DutchMonarch
    let lang: AppLanguage
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 0) {
                header
                if isExpanded {
                    expandedContent
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .appGlassCardStyle(padding: 14, cornerRadius: 18, accent: monarch.accentColor)
    }

    private var header: some View {
        HStack(spacing: 12) {
            emojiIcon
            VStack(alignment: .leading, spacing: 3) {
                Text(monarch.name)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                HStack(spacing: 4) {
                    Text(monarch.years)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Text("·")
                        .foregroundStyle(AppColors.textTertiary)
                    Text(monarch.reign(lang))
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(monarch.accentColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            Spacer(minLength: 4)
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    private var emojiIcon: some View {
        Text(monarch.emoji)
            .font(.system(size: 22))
            .frame(width: 48, height: 48)
            .background(monarch.accentColor.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider().background(monarch.accentColor.opacity(0.2)).padding(.top, 10)
            Text(monarch.summary(lang))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 2)
    }
}

// MARK: - CivicCard (reusable for monarchyCards)

private struct CivicCard: View {
    let item: CivicInfoCardItem
    let lang: AppLanguage
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 0) {
                header
                if isExpanded {
                    expandedContent
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .appGlassCardStyle(padding: 14, cornerRadius: 18, accent: AppColors.violet)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: item.symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppColors.violet)
                .frame(width: 42, height: 42)
                .background(AppColors.violet.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(item.summary(lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 4)
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider().background(AppColors.violet.opacity(0.2)).padding(.top, 10)
            Text(item.detail(lang))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if let url = item.sourceURL {
                Link(destination: AppURL.safeWebURL(url)) {
                    Label(officialSourceLabel, systemImage: "arrow.up.right.square")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppColors.violet)
                }
            }
        }
        .padding(.top, 2)
    }

    private var officialSourceLabel: String {
        switch lang {
        case .russian: return "Официальный источник"
        case .dutch:   return "Officiële bron"
        case .english: return "Official source"
        }
    }
}
