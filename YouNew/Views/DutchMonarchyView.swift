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
            accent: AppColors.violet,
            asset: ContentMediaRegistry.theHagueBinnenhofImage ?? ContentMediaRegistry.cultureHero
        )
    }

    private var monarchsTimeline: some View {
        LazyVStack(spacing: 10) {
            ForEach(MockDutchHolidaysData.monarchs) { monarch in
                let isExpanded = expandedMonarchID == monarch.id
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        expandedMonarchID = expandedMonarchID == monarch.id ? nil : monarch.id
                    }
                } label: {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        monarchCard(monarch)

                        if isExpanded {
                            ProductInfoBlock(
                                title: monarch.reign(lang),
                                bodyText: monarch.summary(lang),
                                symbol: "text.book.closed.fill",
                                accent: monarch.accentColor
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func monarchCard(_ monarch: DutchMonarch) -> some View {
        HStack(alignment: .top, spacing: 12) {
            PremiumImageHeader(
                title: monarch.name,
                asset: monarchImageAsset(monarch),
                language: lang,
                symbol: "crown.fill",
                accent: monarch.accentColor,
                height: 88,
                width: 96,
                cornerRadius: 18,
                fallbackCategory: .city
            )
            .layoutPriority(0)

            VStack(alignment: .leading, spacing: 7) {
                Text(monarch.emoji)
                    .font(.system(size: 18))
                    .lineLimit(1)

                Text(monarch.name)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Text("\(monarch.years) · \(monarch.reign(lang))")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .appCardStyle()
    }

    private var monarchyCards: some View {
        LazyVStack(spacing: 10) {
            ForEach(MockNetherlandsUnderstandingData.monarchyCards) { card in
                let isExpanded = expandedCardID == card.id
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        expandedCardID = expandedCardID == card.id ? nil : card.id
                    }
                } label: {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        monarchyInfoCard(card)

                        if isExpanded {
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                ProductInfoBlock(
                                    title: card.title(lang),
                                    bodyText: card.detail(lang),
                                    symbol: card.symbol,
                                    accent: AppColors.violet
                                )

                                if let url = card.sourceURL {
                                    Link(destination: AppURL.safeWebURL(url)) {
                                        ProductCTA(
                                            title: officialSourceLabel,
                                            symbol: "arrow.up.right.square",
                                            accent: AppColors.violet
                                        )
                                    }
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func monarchyInfoCard(_ card: CivicInfoCardItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            PremiumImageHeader(
                title: card.title(lang),
                asset: monarchyCardImageAsset(card),
                language: lang,
                symbol: card.symbol,
                accent: AppColors.violet,
                height: 88,
                width: 96,
                cornerRadius: 18,
                fallbackCategory: .government
            )
            .layoutPriority(0)

            VStack(alignment: .leading, spacing: 7) {
                Text(card.title(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Text(card.summary(lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .appCardStyle()
    }

    private func monarchImageAsset(_ monarch: DutchMonarch) -> AppImageAsset? {
        switch monarch.id {
        case "willem-alexander", "beatrix", "juliana", "wilhelmina":
            return ContentMediaRegistry.theHagueBinnenhofImage ?? ContentMediaRegistry.officialSourcesHero
        default:
            return ContentMediaRegistry.theHagueBinnenhofImage ?? ContentMediaRegistry.officialSourcesHero
        }
    }

    private func monarchyCardImageAsset(_ card: CivicInfoCardItem) -> AppImageAsset? {
        switch card.id {
        case "kings-day":
            return ContentMediaRegistry.calendarImage ?? ContentMediaRegistry.theHagueBinnenhofImage
        case "monarchy-funded":
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.theHagueBinnenhofImage
        default:
            return ContentMediaRegistry.theHagueBinnenhofImage ?? ContentMediaRegistry.officialSourcesHero
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

    private var officialSourceLabel: String {
        switch lang {
        case .russian: return "Официальный источник"
        case .dutch:   return "Officiële bron"
        case .english: return "Official source"
        }
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
