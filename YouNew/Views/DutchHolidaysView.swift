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
    }

    // MARK: - Sections

    private var heroSection: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: navTitle,
            subtitle: heroSubtitle,
            symbol: "calendar.badge.clock",
            badgeText: badgeText,
            accent: AppColors.dutchOrange
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
                HolidayCard(
                    holiday: holiday,
                    lang: lang,
                    isExpanded: expandedID == holiday.id,
                    onToggle: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            expandedID = expandedID == holiday.id ? nil : holiday.id
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

// MARK: - HolidayCard

private struct HolidayCard: View {
    let holiday: DutchHoliday
    let lang: AppLanguage
    let isExpanded: Bool
    let onToggle: () -> Void

    private var accent: Color { holiday.type.accentColor }

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
        .appGlassCardStyle(padding: 14, cornerRadius: 18, accent: accent)
    }

    private var header: some View {
        HStack(spacing: 12) {
            typeIcon
            VStack(alignment: .leading, spacing: 3) {
                Text(holiday.name(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    Text(holiday.date(lang))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Text("·")
                        .foregroundStyle(AppColors.textTertiary)
                    Text(holiday.dayOffStatus(lang))
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(holiday.isAutomaticDayOff ? accent : AppColors.textSecondary)
                }
            }
            Spacer(minLength: 4)
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    private var typeIcon: some View {
        Image(systemName: holiday.type.symbol)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(accent)
            .frame(width: 42, height: 42)
            .background(accent.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider().background(accent.opacity(0.18)).padding(.top, 10)

            infoRow(icon: "text.bubble.fill", label: summaryLabel, text: holiday.summary(lang))
            infoRow(icon: "clock.arrow.circlepath", label: originLabel, text: holiday.origin(lang))
            infoRow(icon: "hand.raised.fill", label: practicalLabel, text: holiday.practical(lang))

            typeBadge
        }
        .padding(.top, 2)
    }

    private func infoRow(icon: String, label: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(accent.opacity(0.8))
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.textTertiary)
                    .tracking(AppTypography.overlineTracking)
                    .textCase(.uppercase)
                Text(text)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var typeBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: holiday.type.symbol)
                .font(.system(size: 10, weight: .bold))
            Text(holiday.type.title(lang))
                .font(.system(size: 10, weight: .bold, design: .rounded))
            Spacer()
            Text(holiday.lastChecked)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
        }
        .foregroundStyle(accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(accent.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
}
