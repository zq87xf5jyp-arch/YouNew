import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct PlaceItemDetailView: View {
    let place: PlaceItem
    let relatedPlaces: [PlaceItem]
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var savedStore: SavedItemsStore
    @Environment(\.dismiss) private var dismiss

    private var lang: AppLanguage { languageManager.appLanguage }
    private var category: VisitPlaceCategory { place.primaryCategory }
    private var isSaved: Bool { savedStore.isSaved(place.id) }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 760) {
                VStack(alignment: .leading, spacing: 18) {
                    hero
                    details
                    if let source = place.source {
                        sourceBlock(source)
                    }
                    relatedSection
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(place.shortTitle ?? place.title)
        .nlNavigationInline()
        .accessibilityIdentifier("place.detail.\(place.id)")
        .toolbar {
            ToolbarItem(placement: savedToolbarPlacement) {
                Button(action: toggleSaved) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(saveLabel)
            }
        }
    }

    private var savedToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            PremiumImageHeader(
                title: place.shortTitle ?? place.title,
                asset: placeHeroAsset,
                language: lang,
                symbol: category.symbol,
                accent: category.accent,
                height: 190,
                cornerRadius: 8,
                fallbackCategory: fallbackCategory(for: category)
            )

            HStack(spacing: 10) {
                Image(systemName: category.symbol)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(category.accent)
                    .frame(width: 46, height: 46)
                    .background(category.accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(place.title)
                        .font(.system(size: 28, weight: .semibold, design: .default))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(category.title(lang))
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(category.accent)
                }
                Spacer(minLength: 0)
            }

            Text(place.description)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [category.accent.opacity(0.18), AppColors.graphite.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(category.accent.opacity(0.20), lineWidth: 1))
    }

    private var placeHeroAsset: AppImageAsset? {
        guard let image = place.image?.trimmingCharacters(in: .whitespacesAndNewlines),
              !image.isEmpty,
              let url = URL(string: image)
        else { return nil }

        return AppImageAsset(
            id: "place-detail-\(place.id)",
            url: url,
            imageURL: url,
            thumbnailURL: url,
            title: place.shortTitle ?? place.title,
            description: place.description,
            sourceName: place.source?.institution ?? place.source?.title ?? "City guide",
            sourceURL: place.source?.url ?? place.externalUrl,
            license: nil,
            attribution: place.source?.title,
            width: nil,
            height: nil,
            type: .cityHero,
            verified: true
        )
    }

    private func fallbackCategory(for category: VisitPlaceCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .museum, .rainyDay:
            return .city
        case .park, .viewpoint, .free, .hiddenGem:
            return .province
        case .market, .food:
            return .integration
        case .landmark, .historic, .family:
            return .city
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 12) {
            infoRow(icon: "building.2.fill", title: cityLabel, value: ProvinceCatalog.localizedCityName(place.cityId, lang))
            if let address = place.address {
                infoRow(icon: "mappin.and.ellipse", title: addressLabel, value: address)
            }
            if place.goodForRain == true {
                infoRow(icon: "cloud.rain.fill", title: goodToKnowLabel, value: rainyDayLabel)
            }
            if place.familyFriendly == true {
                infoRow(icon: "figure.2.and.child.holdinghands", title: goodToKnowLabel, value: familyFriendlyLabel)
            }
            if place.source == nil {
                infoRow(icon: "exclamationmark.triangle.fill", title: sourceMissingTitle, value: sourceMissingBody)
            }
            if place.coordinates != nil {
                Button(action: openInMaps) {
                    Label(mapButtonTitle, systemImage: "map.fill")
                        .font(AppTypography.bodyStrong)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(category.accent)
            }

            touristInfo
        }
        .padding(16)
        .background(AppColors.graphite.opacity(0.54))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var touristInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            infoRow(icon: "lightbulb.fill", title: goodToKnowLabel, value: "Opening hours, prices, and booking rules are not shown unless verified in an official source.")
            infoRow(icon: "tram.fill", title: howToGetThereLabel, value: "Use 9292, NS, GVB, or your map app for current route information.")
            infoRow(icon: "cross.case.fill", title: nearbyHelpLabel, value: "For urgent help in the Netherlands, call 112.")
        }
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(category.accent)
                .frame(width: 30, height: 30)
                .background(category.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColors.textTertiary)
                Text(value)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func sourceBlock(_ source: OfficialSource) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(sourceTitle, systemImage: "checkmark.seal.fill")
                .font(AppTypography.footnoteStrong)
                .foregroundStyle(AppColors.success)
            Text(source.title)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
            if let lastChecked = place.lastChecked {
                Text("\(lastCheckedLabel): \(lastChecked)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            if let url = source.url {
                OfficialSourceButton(title: openSourceLabel, url: url)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.success.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var relatedSection: some View {
        let related = relatedPlaces.filter { $0.id != place.id }.prefix(3)
        if !related.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(relatedLabel)
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                ForEach(Array(related), id: \.id) { item in
                    NavigationLink(value: item.destination) {
                        HStack(spacing: 12) {
                            Image(systemName: item.primaryCategory.symbol)
                                .foregroundStyle(item.primaryCategory.accent)
                                .frame(width: 34, height: 34)
                                .background(item.primaryCategory.accent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.title)
                                    .font(AppTypography.bodyStrong)
                                    .foregroundStyle(AppColors.textPrimary)
                                Text(item.primaryCategory.title(lang))
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                        .padding(12)
                        .background(AppColors.graphite.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(NLTileButtonStyle())
                }
            }
        }
    }

    private func toggleSaved() {
        savedStore.toggle(
            id: place.id,
            kind: .place,
            title: place.title,
            subtitle: place.cityId,
            destination: place.destination
        )
    }

    private func openInMaps() {
        guard let coordinates = place.coordinates else { return }
        let title = place.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? place.title
        let url = URL(string: "https://maps.apple.com/?ll=\(coordinates.lat),\(coordinates.lng)&q=\(title)")
        #if canImport(UIKit)
        if let url {
            UIApplication.shared.open(url)
        }
        #endif
    }

    private var cityLabel: String { localized(en: "City", nl: "Stad", ru: "Город") }
    private var addressLabel: String { localized(en: "Address", nl: "Adres", ru: "Адрес") }
    private var goodToKnowLabel: String { localized(en: "Good to know", nl: "Goed om te weten", ru: "Полезно знать") }
    private var rainyDayLabel: String { localized(en: "Good for rainy days", nl: "Geschikt bij regen", ru: "Подходит для дождливого дня") }
    private var familyFriendlyLabel: String { localized(en: "Family-friendly", nl: "Geschikt voor gezinnen", ru: "Подходит для семьи") }
    private var howToGetThereLabel: String { localized(en: "How to get there", nl: "Hoe kom je er", ru: "Как добраться") }
    private var nearbyHelpLabel: String { localized(en: "Nearby help", nl: "Hulp dichtbij", ru: "Помощь рядом") }
    private var mapButtonTitle: String { localized(en: "Open in Maps", nl: "Open in Kaarten", ru: "Открыть на карте") }
    private var saveLabel: String { localized(en: "Save for later", nl: "Bewaar voor later", ru: "Сохранить") }
    private var sourceTitle: String { localized(en: "Source", nl: "Bron", ru: "Источник") }
    private var openSourceLabel: String { localized(en: "Open official source", nl: "Officiële bron openen", ru: "Открыть источник") }
    private var lastCheckedLabel: String { localized(en: "Last checked", nl: "Laatst gecontroleerd", ru: "Проверено") }
    private var relatedLabel: String { localized(en: "Related places", nl: "Gerelateerde plekken", ru: "Похожие места") }
    private var sourceMissingTitle: String { localized(en: "Source", nl: "Bron", ru: "Источник") }
    private var sourceMissingBody: String { localized(en: "Use the related official resources before making decisions.", nl: "Gebruik de gerelateerde officiële bronnen voordat je beslist.", ru: "Перед решением используйте связанные официальные источники.") }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

struct NetherlandsCalendarView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedType: CalendarEventType?
    @State private var monthOffset = 0
    @StateObject private var leidenCalendarModel = VisitLeidenCalendarModel()

    private var lang: AppLanguage { languageManager.appLanguage }
    private var selectedAudience: UserContentCategory? { UserContentCategory.from(persona: appState.selectedUserStatus?.personaTag) }
    private var selectedDashboardCity: DashboardCity { CityDashboardContentData.city(for: appState.selectedCity) }
    private var monthDate: Date {
        CalendarEventData.calendar.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }
    private var events: [CalendarEvent] {
        mergedEvents
            .filter { event in
                selectedType == nil || event.type == selectedType
            }
            .filter { event in
                CalendarEventData.calendar.isDate(event.date, equalTo: monthDate, toGranularity: .month)
            }
    }

    private var mergedEvents: [CalendarEvent] {
        let stored = DashboardCalendarData.upcomingEvents(
            cityId: selectedDashboardCity.name,
            audience: selectedAudience,
            limit: nil
        )
        guard selectedDashboardCity.id == .leiden else { return stored }

        var seen = Set<String>()
        return (leidenCalendarModel.events + stored)
            .filter { seen.insert($0.id).inserted }
            .sorted { $0.date == $1.date ? $0.priority < $1.priority : $0.date < $1.date }
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 840) {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    monthControls
                    filters
                    eventList
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(title)
        .nlNavigationInline()
        .accessibilityIdentifier("calendar.screen")
        .task(id: selectedDashboardCity.id) {
            await leidenCalendarModel.load(cityID: selectedDashboardCity.name)
        }
        .refreshable {
            await leidenCalendarModel.load(cityID: selectedDashboardCity.name, forceRefresh: true)
        }
    }

    private var header: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: title,
            subtitle: subtitle,
            symbol: "calendar.badge.clock",
            badgeText: "NL",
            accent: AppColors.dutchOrange,
            asset: ContentMediaRegistry.calendarImage ?? ContentMediaRegistry.cultureWideHero ?? ContentMediaRegistry.mapImage
        )
    }

    private var monthControls: some View {
        HStack(spacing: 10) {
            Button { monthOffset -= 1 } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(.bordered)

            Text(monthTitle(monthDate))
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)

            Button { monthOffset += 1 } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(.bordered)
        }
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                calendarChip(allLabel, selected: selectedType == nil) { selectedType = nil }
                ForEach(CalendarEventType.allCases) { type in
                    calendarChip(type.title(lang), selected: selectedType == type) {
                        selectedType = selectedType == type ? nil : type
                    }
                }
            }
        }
    }

    private var eventList: some View {
        LazyVStack(spacing: 10) {
            if events.isEmpty {
                Text(noEventsLabel)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(AppColors.graphite.opacity(0.45))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                ForEach(events) { event in
                    NavigationLink(value: AppDestination.calendarEvent(event.id)) {
                        CalendarEventRow(event: event, language: lang)
                    }
                    .buttonStyle(NLTileButtonStyle())
                }
            }
        }
    }

    private func calendarChip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppTypography.captionStrong)
                .foregroundStyle(selected ? .black : AppColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selected ? AppColors.dutchOrange : AppColors.graphite.opacity(0.60))
                .clipShape(Capsule())
        }
    }

    private var title: String { localized(en: "Netherlands Calendar", nl: "Nederlandse kalender", ru: "Календарь Нидерландов") }
    private var subtitle: String { localized(en: "Public holidays and important dates", nl: "Feestdagen en belangrijke data", ru: "Праздники и важные даты") }
    private var allLabel: String { localized(en: "All", nl: "Alle", ru: "Все") }
    private var noEventsLabel: String { localized(en: "Use the filters or official calendar sources to check current dates.", nl: "Gebruik filters of officiële kalenderbronnen om actuele datums te controleren.", ru: "Используйте фильтры или официальные календарные источники, чтобы проверить актуальные даты.") }

    private func monthTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = CalendarEventData.calendar
        formatter.locale = locale
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }

    private var locale: Locale {
        switch lang {
        case .english: return Locale(identifier: "en_US")
        case .dutch: return Locale(identifier: "nl_NL")
        case .russian: return Locale(identifier: "ru_RU")
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

struct CalendarEventDetailView: View {
    let event: CalendarEvent
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var savedStore: SavedItemsStore

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 720) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(event.type.title(lang), systemImage: event.type.symbol)
                            .font(AppTypography.captionStrong)
                            .foregroundStyle(event.type.accent)
                        Text(event.title)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(eventDate(event.date))
                            .font(AppTypography.title)
                            .foregroundStyle(AppColors.dutchOrange)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.graphite.opacity(0.58))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    if let description = event.description {
                        detailBlock(title: aboutLabel, text: description, icon: "text.bubble.fill")
                    }
                    if let impact = event.impact {
                        detailBlock(title: impactLabel, text: impact, icon: "exclamationmark.triangle.fill")
                    }
                    detailBlock(title: dayOffLabel, text: dayOffText, icon: "calendar.badge.exclamationmark")
                    if let source = event.source {
                        sourceBlock(source)
                    }
                    Button(action: toggleSaved) {
                        Label(savedStore.isSaved(event.id) ? savedLabel : saveLabel, systemImage: savedStore.isSaved(event.id) ? "bookmark.fill" : "bookmark")
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.dutchOrange)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(event.title)
        .nlNavigationInline()
        .accessibilityIdentifier("event.detail.\(event.id)")
    }

    private func detailBlock(title: String, text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(event.type.accent)
                .frame(width: 34, height: 34)
                .background(event.type.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColors.textTertiary)
                Text(text)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.graphite.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func sourceBlock(_ source: OfficialSource) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(sourceLabel, systemImage: "checkmark.seal.fill")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.success)
            Text(source.title)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
            if let lastChecked = event.lastChecked {
                Text("\(lastCheckedLabel): \(lastChecked)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            if let url = source.url {
                OfficialSourceButton(title: openSourceLabel, url: url)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.success.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func toggleSaved() {
        savedStore.toggle(id: event.id, kind: .other, title: event.title, subtitle: eventDate(event.date), destination: .calendarEvent(event.id))
    }

    private var dayOffText: String {
        if event.dayOffGuaranteed == true {
            return localized(en: "Marked as a day off in the app data.", nl: "Gemarkeerd als vrije dag in de appdata.", ru: "Отмечено как выходной в данных приложения.")
        }
        return localized(en: "Not shown as a guaranteed paid day off. Check your CAO, contract, school, or official source.", nl: "Niet getoond als gegarandeerde betaalde vrije dag. Controleer uw CAO, contract, school of officiële bron.", ru: "Не показано как гарантированный оплачиваемый выходной. Проверьте CAO, договор, учебное заведение или официальный источник.")
    }

    private func eventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = CalendarEventData.calendar
        formatter.locale = locale
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private var locale: Locale {
        switch lang {
        case .english: return Locale(identifier: "en_US")
        case .dutch: return Locale(identifier: "nl_NL")
        case .russian: return Locale(identifier: "ru_RU")
        }
    }

    private var aboutLabel: String { localized(en: "About", nl: "Over", ru: "Описание") }
    private var impactLabel: String { localized(en: "Possible impact", nl: "Mogelijke impact", ru: "Возможное влияние") }
    private var dayOffLabel: String { localized(en: "Day off", nl: "Vrije dag", ru: "Выходной") }
    private var saveLabel: String { localized(en: "Save", nl: "Bewaar", ru: "Сохранить") }
    private var savedLabel: String { localized(en: "Saved", nl: "Bewaard", ru: "Сохранено") }
    private var sourceLabel: String { localized(en: "Source", nl: "Bron", ru: "Источник") }
    private var openSourceLabel: String { localized(en: "Open official source", nl: "Officiële bron openen", ru: "Открыть источник") }
    private var lastCheckedLabel: String { localized(en: "Last checked", nl: "Laatst gecontroleerd", ru: "Проверено") }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

struct CalendarEventRow: View {
    let event: CalendarEvent
    let language: AppLanguage

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(day)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                Text(month)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.dutchOrange)
                    .textCase(.uppercase)
            }
            .frame(width: 52, height: 52)
            .background(AppColors.dutchOrange.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                Text(event.type.title(language))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: event.type.symbol)
                .foregroundStyle(event.type.accent)
        }
        .padding(14)
        .background(AppColors.graphite.opacity(0.46))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var day: String {
        let formatter = DateFormatter()
        formatter.calendar = CalendarEventData.calendar
        formatter.dateFormat = "d"
        return formatter.string(from: event.date)
    }

    private var month: String {
        let formatter = DateFormatter()
        formatter.calendar = CalendarEventData.calendar
        formatter.locale = Locale(identifier: language == .dutch ? "nl_NL" : language == .russian ? "ru_RU" : "en_US")
        formatter.dateFormat = "MMM"
        return formatter.string(from: event.date)
    }
}
