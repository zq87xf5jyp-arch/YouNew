import SwiftUI

struct DutchHolidaysView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    @State private var expandedID: String?
    @State private var selectedType: DutchHolidayType? = nil

    private var holidays: [DutchHoliday] { MockDutchHolidaysData.all2026 }

    private var filteredHolidays: [DutchHoliday] {
        guard let type = selectedType else { return holidays }
        return holidays.filter { $0.type == type }
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    heroSection
                    filterChips
                    holidaysList
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
        .accessibilityIdentifier("holidays.screen")
    }

    // MARK: - Sections

    private var heroSection: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: navTitle,
            subtitle: heroSubtitle,
            symbol: "calendar.badge.clock",
            badgeText: badgeText,
            accent: AppColors.dutchOrange,
            asset: ContentMediaRegistry.calendarImage
        )
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(label: allLabel, isSelected: selectedType == nil) {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.8)) {
                        selectedType = nil
                    }
                }
                ForEach(DutchHolidayType.allCases, id: \.rawValue) { type in
                    chip(label: type.title(lang), isSelected: selectedType == type) {
                        withAnimation(.spring(response: 0.26, dampingFraction: 0.8)) {
                            selectedType = selectedType == type ? nil : type
                        }
                    }
                }
            }
        }
    }

    private func chip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? .black : AppColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? AppColors.dutchOrange : AppColors.graphite.opacity(0.55))
                .clipShape(Capsule())
        }
    }

    private var holidaysList: some View {
        LazyVStack(spacing: 10) {
            ForEach(filteredHolidays) { holiday in
                let isExpanded = expandedID == holiday.id
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        expandedID = expandedID == holiday.id ? nil : holiday.id
                    }
                } label: {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        holidayCard(holiday, isExpanded: isExpanded)

                        if isExpanded {
                            holidayExpandedDetails(holiday)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .accessibilityIdentifier("holiday.detail.\(holiday.id)")
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("holiday.card.\(holiday.id)")
                .accessibilityValue(isExpanded ? "expanded" : "collapsed")
            }
        }
    }

    private func holidayCard(_ holiday: DutchHoliday, isExpanded: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            PremiumImageHeader(
                title: holiday.name(lang),
                asset: holidayImageAsset(holiday),
                language: lang,
                symbol: holiday.type.symbol,
                accent: holiday.type.accentColor,
                height: 88,
                width: 96,
                cornerRadius: 18,
                fallbackCategory: holidayFallbackCategory(holiday)
            )
            .layoutPriority(0)

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    Text(holiday.type.title(lang))
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(holiday.type.accentColor)
                        .lineLimit(1)
                }

                Text(holiday.name(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Text("\(holiday.date(lang)) · \(holiday.dayOffStatus(lang))")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .appCardStyle()
    }

    private func holidayExpandedDetails(_ holiday: DutchHoliday) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            ProductInfoBlock(
                title: summaryLabel,
                bodyText: holiday.summary(lang),
                symbol: "text.bubble.fill",
                accent: holiday.type.accentColor
            )
            ProductInfoBlock(
                title: originLabel,
                bodyText: holiday.origin(lang),
                symbol: "clock.arrow.circlepath",
                accent: holiday.type.accentColor
            )
            ProductInfoBlock(
                title: practicalLabel,
                bodyText: holiday.practical(lang),
                symbol: "hand.raised.fill",
                accent: holiday.type.accentColor
            )
        }
    }

    private var summaryLabel: String {
        switch lang {
        case .russian: return "Описание"
        case .dutch:   return "Omschrijving"
        case .english: return "Description"
        }
    }

    private var originLabel: String {
        switch lang {
        case .russian: return "История"
        case .dutch:   return "Geschiedenis"
        case .english: return "History"
        }
    }

    private var practicalLabel: String {
        switch lang {
        case .russian: return "Практическая заметка"
        case .dutch:   return "Praktische opmerking"
        case .english: return "Practical note"
        }
    }

    private func holidayImageAsset(_ holiday: DutchHoliday) -> AppImageAsset? {
        switch holiday.type {
        case .monarchy:
            return ContentMediaRegistry.theHagueBinnenhofImage ?? ContentMediaRegistry.calendarImage
        case .remembrance:
            return ContentMediaRegistry.cultureHero ?? ContentMediaRegistry.calendarImage
        case .christian:
            return ContentMediaRegistry.calendarImage ?? ContentMediaRegistry.dailyCultureImage
        case .cultural:
            return ContentMediaRegistry.cultureHero ?? ContentMediaRegistry.dailyCultureImage
        case .publicHoliday:
            return ContentMediaRegistry.calendarImage ?? ContentMediaRegistry.homeAtmosphereHero
        }
    }

    private func holidayFallbackCategory(_ holiday: DutchHoliday) -> PremiumImageFallbackCategory {
        switch holiday.type {
        case .monarchy, .remembrance, .cultural:
            return .city
        case .christian, .publicHoliday:
            return .integration
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
        case .russian: return "Праздники Нидерландов"
        case .dutch:   return "Nederlandse feestdagen"
        case .english: return "Dutch Holidays"
        }
    }

    private var heroSubtitle: String {
        switch lang {
        case .russian: return "Официальные праздники 2026 года: что закрыто, история и практические заметки."
        case .dutch:   return "Officiële feestdagen 2026: wat gesloten is, geschiedenis en praktische opmerkingen."
        case .english: return "Official public holidays 2026: what's closed, history, and practical notes."
        }
    }

    private var badgeText: String {
        switch lang {
        case .russian: return "2026 · Официальные данные"
        case .dutch:   return "2026 · Officieel"
        case .english: return "2026 · Official"
        }
    }

    private var allLabel: String {
        switch lang {
        case .russian: return "Все"
        case .dutch:   return "Alle"
        case .english: return "All"
        }
    }

    private var sourceTitle: String {
        switch lang {
        case .russian: return "Источник: Government.nl · National Committee 4 en 5 mei · Royal House NL"
        case .dutch:   return "Bron: Government.nl · Nationaal Comité 4 en 5 mei · Koninklijk Huis NL"
        case .english: return "Source: Government.nl · National Committee 4 and 5 May · Royal House NL"
        }
    }

    private var sourceBody: String {
        switch lang {
        case .russian: return "Даты и характеристика выходных дней основаны на официальном календаре правительства Нидерландов. Является ли день праздника оплачиваемым выходным — зависит от вашего CAO или индивидуального трудового договора. Проверяйте актуальные данные на Government.nl."
        case .dutch:   return "Data en kenmerken van vrije dagen zijn gebaseerd op de officiële feestdagenkalender van de Nederlandse overheid. Of een feestdag een betaalde vrije dag is, hangt af van uw CAO of individueel arbeidscontract. Controleer actuele informatie op Government.nl."
        case .english: return "Dates and day-off status are based on the official Dutch government holiday calendar. Whether a holiday is a paid day off depends on your CAO or individual employment contract. Verify current details at Government.nl."
        }
    }
}
