import SwiftUI

struct DiscoverySideMenuOverlay: View {
    let onClose: () -> Void
    let onNavigate: (AppDestination) -> Void

    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var businessStore = BusinessPortalStore.shared
    @State private var activeGroup: DiscoveryMenuGroup?

    private var language: AppLanguage { languageManager.appLanguage }
    private var city: String { ProvinceCatalog.localizedCityName(appState.selectedCity, language) }
    private var audience: UserContentCategory? { UserContentCategory.from(persona: appState.selectedUserStatus?.personaTag) }
    private var verifiedPlaces: [PlaceItem] {
        DashboardPlacesData.visiblePlaces(cityId: appState.selectedCity, audience: audience, limit: nil)
    }
    private var foodItems: [FoodGuideItem] {
        CityDashboardContentData.foodGuideItems(
            for: CityDashboardContentData.city(for: appState.selectedCity),
            audience: audience,
            limit: nil
        )
    }
    private var partners: [LocalPartner] { MockLocalPartnersData.partners(in: appState.selectedCity) }
    private var events: [CalendarEvent] {
        DashboardCalendarData.upcomingEvents(cityId: appState.selectedCity, audience: audience, limit: 30)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Color.black.opacity(0.58)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture(perform: closeWithFeedback)
                    .accessibilityIdentifier("sideMenu.backdrop")

                menuPanel(width: min(proxy.size.width * 0.86, 430))
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 18)
                            .onEnded { value in
                                if value.translation.width < -70,
                                   abs(value.translation.height) < abs(value.translation.width) {
                                    closeWithFeedback()
                                }
                            }
                    )
            }
        }
        .sheet(item: $activeGroup) { group in
            DiscoveryCategorySheet(
                group: group,
                options: options(for: group),
                city: city,
                language: language,
                onSelect: navigate
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(AppColors.backgroundSecondary)
        }
        .accessibilityIdentifier("sideMenu.overlay")
    }

    private func menuPanel(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            menuHeader
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    menuGroup(.places, identifier: "sideMenu.places")
                    menuGroup(.food, identifier: "sideMenu.food")
                    if !options(for: .shopping).isEmpty { menuGroup(.shopping, identifier: "sideMenu.shopping") }
                    if !options(for: .stay).isEmpty { menuGroup(.stay, identifier: "sideMenu.stay") }
                    if !options(for: .events).isEmpty { menuGroup(.events, identifier: "sideMenu.events") }
                    directRow(localized(en: "Gallery", nl: "Galerij", ru: "Галерея"), symbol: "photo.on.rectangle.angled", route: .gallery, identifier: "sideMenu.gallery")
                    directRow(localized(en: "Services nearby", nl: "Diensten dichtbij", ru: "Сервисы рядом"), symbol: "mappin.and.ellipse", route: .servicesNearby, identifier: "sideMenu.services.nearby")
                    if !partners.isEmpty {
                        directRow(localized(en: "Local Partners", nl: "Lokale partners", ru: "Местные партнёры"), symbol: "checkmark.seal.fill", route: .localPartners, identifier: "sideMenu.partners")
                    }
                    businessCard
                    Color.clear.frame(height: 24)
                        .accessibilityIdentifier("sideMenu.lastElement")
                }
                .padding(16)
            }
        }
        .frame(width: width)
        .frame(maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [AppColors.backgroundPrimary, AppColors.backgroundSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(AppColors.dutchOrange.opacity(0.34))
                .frame(width: 1)
                .allowsHitTesting(false)
        }
        .shadow(color: .black.opacity(0.44), radius: 24, x: 10)
    }

    private var menuHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                (Text("You").foregroundStyle(AppColors.textPrimary) + Text("New").foregroundStyle(AppColors.dutchOrange))
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                Spacer()
                Button(action: closeWithFeedback) {
                    Image(systemName: "xmark").font(.headline.bold()).frame(width: 44, height: 44)
                }
                .buttonStyle(AppPressableButtonStyle())
                .foregroundStyle(AppColors.textPrimary)
                .accessibilityIdentifier("sideMenu.close")
            }

            HStack(spacing: 10) {
                Image(systemName: "location.fill").foregroundStyle(AppColors.dutchOrange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(city).font(AppTypography.bodyStrong).foregroundStyle(AppColors.textPrimary)
                    Text(appState.selectedUserStatus?.localized(language) ?? localized(en: "Choose profile", nl: "Kies profiel", ru: "Выберите профиль"))
                        .font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                Label(localized(en: "Weather unavailable", nl: "Weer niet beschikbaar", ru: "Погода недоступна"), systemImage: "cloud")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(AppColors.cyanGlow)
                    .accessibilityLabel(localized(en: "Weather data unavailable", nl: "Weergegevens niet beschikbaar", ru: "Данные погоды недоступны"))
            }

            HStack(spacing: 8) {
                headerButton(localized(en: "Change city", nl: "Wijzig stad", ru: "Сменить город"), route: .cityList, identifier: "sideMenu.changeCity")
                headerButton(localized(en: "Change profile", nl: "Wijzig profiel", ru: "Сменить профиль"), route: .profileSelection, identifier: "sideMenu.changeProfile")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .background(AppColors.glassSurfaceElevated)
        .overlay(alignment: .bottom) { Rectangle().fill(AppColors.stroke).frame(height: 0.5) }
    }

    private func headerButton(_ title: String, route: AppDestination, identifier: String) -> some View {
        Button { onNavigate(route) } label: {
            Text(title)
                .font(AppTypography.captionStrong)
                .frame(maxWidth: .infinity, minHeight: AppButtonMetrics.minTouchSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(AppPressableButtonStyle())
        .foregroundStyle(AppColors.textPrimary)
        .background(AppColors.glassSurface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.stroke, lineWidth: 0.8))
        .accessibilityIdentifier(identifier)
    }

    private func menuGroup(_ group: DiscoveryMenuGroup, identifier: String) -> some View {
        Button {
            AppHaptics.selection()
            activeGroup = group
        } label: {
            HStack(spacing: 12) {
                Image(systemName: group.symbol)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(group.tint)
                    .frame(width: 40, height: 40)
                    .background(group.tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 3) {
                    Text(group.title(language)).font(AppTypography.bodyStrong).foregroundStyle(AppColors.textPrimary)
                    Text(group.subtitle(language, city: city)).font(AppTypography.caption).foregroundStyle(AppColors.textSecondary).lineLimit(2)
                }
                Spacer(minLength: 6)
                Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(AppColors.textTertiary)
            }
            .padding(12)
            .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(group.tint.opacity(0.2), lineWidth: 0.8))
        }
        .buttonStyle(AppPressableCardButtonStyle())
        .accessibilityIdentifier(identifier)
    }

    private func directRow(_ title: String, symbol: String, route: DiscoveryMenuRoute, identifier: String) -> some View {
        Button { navigate(route) } label: {
            HStack(spacing: 12) {
                Image(systemName: symbol).font(.headline.bold()).foregroundStyle(AppColors.cyanGlow).frame(width: 34)
                Text(title).font(AppTypography.bodyStrong).foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(AppColors.textTertiary)
            }
            .frame(minHeight: 50)
            .padding(.horizontal, 12)
            .background(AppColors.glassSurface, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(AppPressableButtonStyle())
        .accessibilityIdentifier(identifier)
    }

    private var businessCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("YouNew Business", systemImage: "storefront.fill")
                .font(AppTypography.sectionTitle).foregroundStyle(AppColors.textPrimary)
            Text(localized(en: "Promote your place or service to people in the Netherlands.", nl: "Promoot je zaak of dienst bij mensen in Nederland.", ru: "Продвигайте своё место или услугу среди людей в Нидерландах."))
                .font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
            HStack(spacing: 8) {
                businessButton(localized(en: "Add business", nl: "Bedrijf toevoegen", ru: "Добавить бизнес"), route: .businessRegister, identifier: "sideMenu.business.register", primary: true)
                businessButton(localized(en: "Log in", nl: "Inloggen", ru: "Войти"), route: .businessLogin, identifier: "sideMenu.business.login", primary: false)
            }
            if businessStore.snapshot.account != nil {
                businessButton(localized(en: "Manage listing", nl: "Beheer vermelding", ru: "Управлять размещением"), route: .businessManage, identifier: "sideMenu.business.manage", primary: false)
            }
        }
        .padding(14)
        .background(AppColors.dutchOrange.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.dutchOrange.opacity(0.34), lineWidth: 1))
    }

    private func businessButton(_ title: String, route: DiscoveryMenuRoute, identifier: String, primary: Bool) -> some View {
        Button { navigate(route) } label: {
            Text(title)
                .font(AppTypography.captionStrong)
                .frame(maxWidth: .infinity, minHeight: AppButtonMetrics.minTouchSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(AppPressableButtonStyle())
        .foregroundStyle(AppColors.textPrimary)
        .background(primary ? AppColors.dutchOrange : AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 10))
        .accessibilityIdentifier(identifier)
    }

    private func navigate(_ route: DiscoveryMenuRoute) {
        activeGroup = nil
        guard let cityID = CityId.resolve(appState.selectedCity) else {
            preconditionFailure("Discovery routing requires a canonical selected city")
        }
        onNavigate(route.destination(city: cityID))
    }

    private func closeWithFeedback() {
        AppHaptics.lightImpact()
        onClose()
    }

    private func options(for group: DiscoveryMenuGroup) -> [DiscoveryMenuOption] {
        switch group {
        case .places:
            return placeOption(.museums, categories: [.museum], title: ("Museums", "Musea", "Музеи"), symbol: "building.columns.fill")
                + placeOption(.attractions, categories: [.landmark, .viewpoint], title: ("Attractions", "Attracties", "Достопримечательности"), symbol: "sparkles")
                + placeOption(.historicPlaces, categories: [.historic], title: ("Historic places", "Historische plekken", "Исторические места"), symbol: "clock.fill")
                + placeOption(.parks, categories: [.park], title: ("Parks", "Parken", "Парки"), symbol: "leaf.fill")
                + placeOption(.familyActivities, categories: [.family], title: ("Family activities", "Gezinsactiviteiten", "Для семьи"), symbol: "figure.2.and.child.holdinghands")
                + placeOption(.freePlaces, categories: [.free], title: ("Free places", "Gratis plekken", "Бесплатные места"), symbol: "ticket.fill")
        case .food:
            return foodOption(.restaurants, categories: [.restaurant, .fineDining], title: ("Restaurants", "Restaurants", "Рестораны"), symbol: "fork.knife")
                + foodOption(.cafes, categories: [.cafe], title: ("Cafés", "Cafés", "Кафе"), symbol: "cup.and.saucer.fill")
                + foodOption(.localFood, categories: [.localFood, .market], title: ("Local food", "Lokaal eten", "Местная еда"), symbol: "basket.fill")
                + foodOption(.vegetarian, categories: [.vegetarian], title: ("Vegetarian", "Vegetarisch", "Вегетарианское"), symbol: "leaf.fill")
                + foodOption(.breakfast, categories: [.breakfast], title: ("Breakfast", "Ontbijt", "Завтраки"), symbol: "sunrise.fill")
        case .shopping:
            return partnerOption(.shopping, title: ("Shopping", "Winkelen", "Покупки"), symbol: "bag.fill")
        case .stay:
            return partnerOption(.stay, title: ("Hotels & stay", "Hotels en verblijf", "Отели и проживание"), symbol: "bed.double.fill")
        case .events:
            guard !events.isEmpty else { return [] }
            return [option(.eventsToday, ("Today", "Vandaag", "Сегодня"), "calendar.day.timeline.left", events.count)]
                + eventOption(.eventsWeekend, type: .eventsWeekend, title: ("This weekend", "Dit weekend", "На выходных"), symbol: "calendar.badge.clock")
                + eventOption(.eventsWeek, type: .eventsWeek, title: ("This week", "Deze week", "На этой неделе"), symbol: "calendar")
                + eventOption(.eventsFree, type: .eventsFree, title: ("Free", "Gratis", "Бесплатно"), symbol: "ticket.fill")
                + eventOption(.eventsFamily, type: .eventsFamily, title: ("Family", "Gezin", "Для семьи"), symbol: "figure.2.and.child.holdinghands")
                + eventOption(.eventsMusic, type: .eventsMusic, title: ("Music", "Muziek", "Музыка"), symbol: "music.note")
                + eventOption(.eventsMuseums, type: .eventsMuseums, title: ("Museums", "Musea", "Музеи"), symbol: "building.columns.fill")
                + eventOption(.eventsMarkets, type: .eventsMarkets, title: ("Markets", "Markten", "Рынки"), symbol: "basket.fill")
                + eventOption(.eventsFestivals, type: .eventsFestivals, title: ("Festivals", "Festivals", "Фестивали"), symbol: "music.note.list")
        }
    }

    private func eventOption(
        _ route: DiscoveryMenuRoute,
        type: DiscoveryListType,
        title: (String, String, String),
        symbol: String
    ) -> [DiscoveryMenuOption] {
        let count = DiscoveryEventFilter.events(from: events, matching: type).count
        return count == 0 ? [] : [option(route, title, symbol, count)]
    }

    private func placeOption(_ route: DiscoveryMenuRoute, categories: Set<VisitPlaceCategory>, title: (String, String, String), symbol: String) -> [DiscoveryMenuOption] {
        let count = verifiedPlaces.filter { !Set($0.category).isDisjoint(with: categories) }.count
        return count == 0 ? [] : [option(route, title, symbol, count)]
    }

    private func foodOption(_ route: DiscoveryMenuRoute, categories: Set<FoodGuideCategory>, title: (String, String, String), symbol: String) -> [DiscoveryMenuOption] {
        let count = foodItems.filter { categories.contains($0.category) }.count
        return count == 0 ? [] : [option(route, title, symbol, count)]
    }

    private func partnerOption(_ category: LocalPartnerCategory, title: (String, String, String), symbol: String) -> [DiscoveryMenuOption] {
        let count = partners.filter { $0.category == category }.count
        guard count > 0 else { return [] }
        let route: DiscoveryMenuRoute = category == .stay ? .hotels : .shopping
        return [option(route, title, symbol, count)]
    }

    private func option(_ route: DiscoveryMenuRoute, _ title: (String, String, String), _ symbol: String, _ count: Int?) -> DiscoveryMenuOption {
        DiscoveryMenuOption(route: route, title: localized(en: title.0, nl: title.1, ru: title.2), symbol: symbol, count: count)
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch language { case .english: return en; case .dutch: return nl; case .russian: return ru }
    }
}

private enum DiscoveryMenuGroup: String, Identifiable {
    case places, food, shopping, stay, events
    var id: String { rawValue }
    var symbol: String { switch self { case .places: return "binoculars.fill"; case .food: return "fork.knife"; case .shopping: return "bag.fill"; case .stay: return "bed.double.fill"; case .events: return "calendar" } }
    var tint: Color { switch self { case .places: return AppColors.dutchOrange; case .food: return AppColors.warning; case .shopping: return AppColors.cyanGlow; case .stay: return AppColors.violet; case .events: return AppColors.softBlue } }
    func title(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.places, .english): return "Places to visit"; case (.places, .dutch): return "Plekken om te bezoeken"; case (.places, .russian): return "Куда сходить"
        case (.food, .english): return "Food & Drinks"; case (.food, .dutch): return "Eten en drinken"; case (.food, .russian): return "Еда и напитки"
        case (.shopping, .english): return "Shopping"; case (.shopping, .dutch): return "Winkelen"; case (.shopping, .russian): return "Покупки"
        case (.stay, .english): return "Hotels & Stay"; case (.stay, .dutch): return "Hotels en verblijf"; case (.stay, .russian): return "Отели и проживание"
        case (.events, .english): return "Events"; case (.events, .dutch): return "Evenementen"; case (.events, .russian): return "События"
        }
    }
    func subtitle(_ language: AppLanguage, city: String) -> String {
        switch language { case .english: return "Verified choices in \(city)"; case .dutch: return "Gecontroleerde keuzes in \(city)"; case .russian: return "Проверенные варианты в городе \(city)" }
    }
}

private struct DiscoveryMenuOption: Identifiable {
    let route: DiscoveryMenuRoute
    let title: String
    let symbol: String
    let count: Int?
    var id: String { route.id }
}

private struct DiscoveryCategorySheet: View {
    let group: DiscoveryMenuGroup
    let options: [DiscoveryMenuOption]
    let city: String
    let language: AppLanguage
    let onSelect: (DiscoveryMenuRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(options) { option in
                Button { dismiss(); onSelect(option.route) } label: {
                    HStack(spacing: 12) {
                        Image(systemName: option.symbol).foregroundStyle(group.tint).frame(width: 30)
                        Text(option.title).foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        if let count = option.count { Text("\(count)").foregroundStyle(AppColors.textSecondary).monospacedDigit() }
                        Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(AppColors.textTertiary)
                    }
                    .frame(minHeight: 44)
                }
                .buttonStyle(AppPressableButtonStyle())
                .listRowBackground(AppColors.glassSurface)
                .accessibilityIdentifier("sideMenu.\(group.rawValue).\(option.route.rawValue)")
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.backgroundSecondary)
            .navigationTitle(group.title(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        AppHaptics.lightImpact()
                        dismiss()
                    }
                }
            }
        }
    }
}
