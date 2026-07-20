import SwiftUI

struct HomeExploreListView: View {
    let listID: String
    let cityID: CityId

    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.openURL) private var openURL

    init(listID: String, cityID: CityId) {
        self.listID = listID
        self.cityID = cityID
    }

    private var lang: AppLanguage { languageManager.appLanguage }
    private var city: DashboardCity { CityDashboardContentData.city(for: cityID) }
    private var audience: UserContentCategory? { UserContentCategory.from(persona: appState.selectedUserStatus?.personaTag) }
    private var normalizedID: String { listID.lowercased().replacingOccurrences(of: "_", with: "-") }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 760) {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    content
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.map)
        .navigationTitle(title)
        .nlNavigationInline()
        .accessibilityIdentifier("category.list.\(normalizedID).\(cityID.rawValue)")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: symbol)
                .font(.system(size: 28, weight: .semibold, design: .default))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(tint.opacity(0.24), lineWidth: 1))
    }

    @ViewBuilder
    private var content: some View {
        let foodItems = filteredFoodItems
        let actionItems = filteredActionItems
        let placeItems = filteredPlaces
        let eventItems = filteredEvents
        let partnerItems = filteredPartners

        if !foodItems.isEmpty {
            VStack(spacing: 10) {
                ForEach(foodItems) { item in
                    foodRow(item)
                }
            }
        } else if !eventItems.isEmpty {
            VStack(spacing: 10) {
                ForEach(eventItems) { event in
                    NavigationLink(value: AppDestination.calendarEvent(event.id)) {
                        eventRow(event)
                    }
                    .buttonStyle(NLTileButtonStyle())
                    .accessibilityIdentifier("category.detailLink.\(normalizedID).\(event.id)")
                }
            }
        } else if !actionItems.isEmpty {
            VStack(spacing: 10) {
                ForEach(actionItems) { item in
                    actionRow(item)
                }
            }
        } else if !placeItems.isEmpty {
            VStack(spacing: 10) {
                ForEach(placeItems) { place in
                    NavigationLink(value: place.destination) {
                        placeRow(place)
                    }
                    .buttonStyle(NLTileButtonStyle())
                    .accessibilityIdentifier("category.detailLink.\(normalizedID).\(place.id)")
                }
            }
        } else if !partnerItems.isEmpty {
            VStack(spacing: 10) {
                ForEach(partnerItems) { partner in
                    NavigationLink(value: AppDestination.localPartnerDetail(partner.id)) {
                        rowContent(
                            title: partner.name,
                            subtitle: "\(partner.category.title(lang)) · \(partner.city)",
                            symbol: partner.category.symbol,
                            accent: partner.plan == .sponsoredPlacement ? AppColors.warning : AppColors.cyanGlow,
                            trailingSymbol: "chevron.right"
                        )
                    }
                    .buttonStyle(NLTileButtonStyle())
                    .accessibilityIdentifier("category.detailLink.\(normalizedID).\(partner.id)")
                }
            }
        } else {
            emptyState
        }
    }

    private var filteredFoodItems: [FoodGuideItem] {
        let items = CityDashboardContentData.foodGuideItems(for: city, audience: audience, limit: nil)
        switch normalizedID {
        case "restaurants":
            return items.filter { [.restaurant, .localFood, .vegetarian, .budget, .fineDining].contains($0.category) }
        case "cafes":
            return items.filter { [.cafe, .breakfast].contains($0.category) }
        case "local-food":
            return items.filter { [.localFood, .market].contains($0.category) }
        case "vegetarian":
            return items.filter { $0.category == .vegetarian }
        case "breakfast":
            return items.filter { $0.category == .breakfast }
        case "nightlife":
            return []
        default:
            return []
        }
    }

    private var filteredEvents: [CalendarEvent] {
        let items = DashboardCalendarData.upcomingEvents(cityId: city.name, audience: audience, limit: 30)
        switch normalizedID {
        case "events":
            return items
        case "events-today":
            let calendar = CalendarEventData.calendar
            let today = calendar.startOfDay(for: Date())
            return items.filter { event in
                let start = calendar.startOfDay(for: event.date)
                let end = calendar.startOfDay(for: event.endDate ?? event.date)
                return start <= today && end >= today
            }
        default:
            guard let type = DiscoveryListType(rawValue: normalizedID) else { return [] }
            return DiscoveryEventFilter.events(from: items, matching: type)
        }
    }

    private var filteredActionItems: [ExploreListAction] {
        switch normalizedID {
        case "nightlife":
            return [
                mapSearchAction("bars", title: localized(en: "Bars", nl: "Bars", ru: "Бары"), subtitle: localized(en: "Evening spots near the selected city", nl: "Avondplekken in de gekozen stad", ru: "Вечерние места рядом с выбранным городом"), symbol: "moon.stars.fill", accent: AppColors.violet),
                mapSearchAction("live-music", title: localized(en: "Live music", nl: "Live muziek", ru: "Живая музыка"), subtitle: localized(en: "Venues and cultural nights", nl: "Podia en culturele avonden", ru: "Площадки и культурные вечера"), symbol: "music.note", accent: AppColors.softBlue),
                routeAction("late-transport", title: localized(en: "Late transport", nl: "Laat vervoer", ru: "Поздний транспорт"), subtitle: localized(en: "Check night routes before going out", nl: "Controleer nachtroutes voor vertrek", ru: "Проверьте ночные маршруты заранее"), symbol: "tram.fill", accent: AppColors.emerald, destination: .practicalGuide(.transportBasics))
            ]
        case "sports":
            return [
                mapSearchAction("sport-clubs", title: localized(en: "Sports clubs", nl: "Sportclubs", ru: "Спортклубы"), subtitle: localized(en: "Gyms, football, tennis, and local clubs", nl: "Sportscholen, voetbal, tennis en clubs", ru: "Залы, футбол, теннис и местные клубы"), symbol: "figure.run", accent: AppColors.emerald),
                mapSearchAction("swimming", title: localized(en: "Swimming pools", nl: "Zwembaden", ru: "Бассейны"), subtitle: localized(en: "Indoor pools and family swimming", nl: "Binnenbaden en gezinszwemmen", ru: "Крытые бассейны и семейное плавание"), symbol: "drop.fill", accent: AppColors.softBlue),
                routeAction("parks", title: localized(en: "Outdoor routes", nl: "Buitenroutes", ru: "Маршруты на улице"), subtitle: localized(en: "Parks and walking/cycling areas", nl: "Parken en wandel- of fietsroutes", ru: "Парки, прогулки и веломаршруты"), symbol: "leaf.fill", accent: AppColors.success, destination: .natureList(city: cityID))
            ]
        case "family-activities":
            return [
                mapSearchAction("playgrounds", title: localized(en: "Playgrounds", nl: "Speeltuinen", ru: "Детские площадки"), subtitle: localized(en: "Easy nearby options for children", nl: "Makkelijke opties dichtbij met kinderen", ru: "Простые варианты рядом для детей"), symbol: "figure.2.and.child.holdinghands", accent: AppColors.success),
                routeAction("family-museums", title: localized(en: "Family museums", nl: "Familiemusea", ru: "Музеи для семьи"), subtitle: localized(en: "Rainy-day culture options", nl: "Cultuur bij regenachtig weer", ru: "Культура на дождливый день"), symbol: "building.columns.fill", accent: AppColors.violet, destination: .museumList(city: cityID)),
                routeAction("family-parks", title: localized(en: "Parks", nl: "Parken", ru: "Парки"), subtitle: localized(en: "Green spaces and relaxed walks", nl: "Groen en rustige wandelingen", ru: "Зеленые зоны и спокойные прогулки"), symbol: "leaf.fill", accent: AppColors.emerald, destination: .natureList(city: cityID))
            ]
        case "weekend":
            return [
                routeAction("weekend-museums", title: localized(en: "Museums", nl: "Musea", ru: "Музеи"), subtitle: localized(en: "Verified indoor ideas for this weekend", nl: "Gecontroleerde binnenideeën voor dit weekend", ru: "Проверенные идеи в помещении на выходные"), symbol: "building.columns.fill", accent: AppColors.violet, destination: .museumList(city: cityID)),
                routeAction("weekend-nature", title: localized(en: "Nature", nl: "Natuur", ru: "Природа"), subtitle: localized(en: "Parks and outdoor routes", nl: "Parken en buitenroutes", ru: "Парки и маршруты на природе"), symbol: "leaf.fill", accent: AppColors.emerald, destination: .natureList(city: cityID)),
                routeAction("weekend-landmarks", title: localized(en: "Landmarks", nl: "Bezienswaardigheden", ru: "Достопримечательности"), subtitle: localized(en: "Historic places and architecture", nl: "Historische plekken en architectuur", ru: "Исторические места и архитектура"), symbol: "camera.fill", accent: AppColors.cyanGlow, destination: .landmarkList(city: cityID))
            ]
        case "free-activities":
            return [
                routeAction("free-parks", title: localized(en: "Parks and viewpoints", nl: "Parken en uitzichtpunten", ru: "Парки и виды"), subtitle: localized(en: "Low-cost outdoor ideas", nl: "Goedkope buitenideeen", ru: "Бюджетные идеи на улице"), symbol: "leaf.fill", accent: AppColors.emerald, destination: .natureList(city: cityID)),
                routeAction("free-history", title: localized(en: "Historic walks", nl: "Historische wandelingen", ru: "Исторические прогулки"), subtitle: localized(en: "Canals, squares, and landmarks", nl: "Grachten, pleinen en monumenten", ru: "Каналы, площади и памятники"), symbol: "clock.fill", accent: AppColors.cyanGlow, destination: .landmarkList(city: cityID)),
                routeAction("free-events", title: localized(en: "Free events", nl: "Gratis events", ru: "Бесплатные события"), subtitle: localized(en: "Check current city events", nl: "Bekijk actuele stadsevents", ru: "Проверьте городские события"), symbol: "ticket.fill", accent: AppColors.dutchOrange, destination: .eventList(city: cityID))
            ]
        default:
            return []
        }
    }

    private var filteredPlaces: [PlaceItem] {
        let places = DashboardPlacesData.visiblePlaces(cityId: city.name, audience: audience, limit: nil)
        let categories = placeCategories
        guard !categories.isEmpty else { return [] }
        return places.filter { place in
            !Set(place.category).isDisjoint(with: categories)
        }
    }

    private var filteredPartners: [LocalPartner] {
        let partners = MockLocalPartnersData.partners(in: city.name)
        switch normalizedID {
        case "hotels": return partners.filter { $0.category == .stay }
        case "shopping": return partners.filter { $0.category == .shopping }
        default: return []
        }
    }

    private var placeCategories: Set<VisitPlaceCategory> {
        switch normalizedID {
        case "places", "gallery":
            return [.museum, .park, .historic, .landmark, .food]
        case "museums":
            return [.museum]
        case "nature", "parks":
            return [.park, .viewpoint, .hiddenGem]
        case "historic", "historic-places", "landmarks", "architecture":
            return [.historic, .landmark]
        case "attractions":
            return [.landmark, .viewpoint, .hiddenGem]
        case "free-places":
            return [.free]
        case "sports":
            return []
        case "family-activities":
            return []
        case "free-activities":
            return []
        default:
            return []
        }
    }

    @ViewBuilder
    private func foodRow(_ item: FoodGuideItem) -> some View {
        if [.cafe, .breakfast].contains(item.category) {
            NavigationLink(value: AppDestination.cafeDetail(city: cityID, itemID: item.id)) {
                foodRowContent(item)
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityIdentifier("category.detailLink.\(normalizedID).\(item.id)")
        } else {
            NavigationLink(value: AppDestination.restaurantDetail(city: cityID, itemID: item.id)) {
                foodRowContent(item)
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityIdentifier("category.detailLink.\(normalizedID).\(item.id)")
        }
    }

    private func foodRowContent(_ item: FoodGuideItem, trailingSymbol: String = "chevron.right") -> some View {
        rowContent(
            title: item.shortTitle ?? item.title,
            subtitle: item.description,
            symbol: item.icon,
            accent: foodTint(item.category),
            trailingSymbol: trailingSymbol
        )
    }

    @ViewBuilder
    private func actionRow(_ item: ExploreListAction) -> some View {
        if let destination = item.destination {
            NavigationLink(value: destination) {
                actionRowContent(item)
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityIdentifier("home.exploreList.action.\(item.id)")
        } else {
            Button {
                if let url = item.url {
                    openURL(url)
                }
            } label: {
                actionRowContent(item)
            }
            .buttonStyle(NLTileButtonStyle())
            .disabled(item.url == nil)
            .accessibilityIdentifier("home.exploreList.action.\(item.id)")
        }
    }

    private func actionRowContent(_ item: ExploreListAction) -> some View {
        rowContent(
            title: item.title,
            subtitle: item.subtitle,
            symbol: item.symbol,
            accent: item.accent,
            trailingSymbol: item.destination == nil ? "arrow.up.forward" : "chevron.right"
        )
    }

    private func placeRow(_ place: PlaceItem) -> some View {
        rowContent(
            title: place.shortTitle ?? place.title,
            subtitle: place.description,
            symbol: place.primaryCategory.symbol,
            accent: place.primaryCategory.accent,
            trailingSymbol: "chevron.right"
        )
        .accessibilityIdentifier("home.exploreList.place.\(place.id)")
    }

    private func eventRow(_ event: CalendarEvent) -> some View {
        rowContent(
            title: event.title,
            subtitle: event.description ?? city.name,
            symbol: "calendar",
            accent: AppColors.softBlue,
            trailingSymbol: "chevron.right"
        )
        .accessibilityIdentifier("home.exploreList.event.\(event.id)")
    }

    private func rowContent(title: String, subtitle: String, symbol: String, accent: Color, trailingSymbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 42, height: 42)
                .background(accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
            }

            Spacer(minLength: 8)

            Image(systemName: trailingSymbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(AppColors.stroke.opacity(0.65), lineWidth: 0.8))
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(localized(en: "No verified list yet", nl: "Nog geen gecontroleerde lijst", ru: "Пока нет проверенного списка"), systemImage: "checkmark.seal")
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
            Text(localized(
                en: "This category needs verified local entries before YouNew shows individual places here.",
                nl: "Deze categorie heeft gecontroleerde lokale items nodig voordat YouNew individuele plekken toont.",
                ru: "Для этой категории нужны проверенные локальные записи, прежде чем YouNew покажет отдельные места."
            ))
            .font(AppTypography.body)
            .foregroundStyle(AppColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)

            NavigationLink(value: AppDestination.mapFocus(.city(city.name))) {
                Label(localized(en: "Open city map", nl: "Open stadskaart", ru: "Открыть карту города"), systemImage: "map.fill")
                    .font(AppTypography.bodyStrong)
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(tint)
        }
        .padding(16)
        .background(AppColors.glassSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var title: String {
        switch normalizedID {
        case "restaurants": return localized(en: "Restaurants", nl: "Restaurants", ru: "Рестораны")
        case "cafes": return localized(en: "Cafes", nl: "Cafés", ru: "Кафе")
        case "local-food": return localized(en: "Local food", nl: "Lokaal eten", ru: "Местная еда")
        case "vegetarian": return localized(en: "Vegetarian", nl: "Vegetarisch", ru: "Вегетарианское")
        case "breakfast": return localized(en: "Breakfast", nl: "Ontbijt", ru: "Завтраки")
        case "hotels": return localized(en: "Hotels & stay", nl: "Hotels en verblijf", ru: "Отели и проживание")
        case "shopping": return localized(en: "Shopping", nl: "Winkelen", ru: "Покупки")
        case "gallery": return localized(en: "Netherlands gallery", nl: "Galerij Nederland", ru: "Галерея Нидерландов")
        case "events", "events-today": return localized(en: "Events", nl: "Events", ru: "События")
        case "events-week": return localized(en: "This week", nl: "Deze week", ru: "На этой неделе")
        case "events-weekend": return localized(en: "This weekend", nl: "Dit weekend", ru: "На выходных")
        case "events-free": return localized(en: "Free events", nl: "Gratis evenementen", ru: "Бесплатные события")
        case "events-family": return localized(en: "Family events", nl: "Gezinsevenementen", ru: "События для семьи")
        case "events-music": return localized(en: "Music events", nl: "Muziekevenementen", ru: "Музыкальные события")
        case "events-museums": return localized(en: "Museum events", nl: "Museumevenementen", ru: "События в музеях")
        case "events-markets": return localized(en: "Markets", nl: "Markten", ru: "Рынки")
        case "museums": return localized(en: "Museums", nl: "Musea", ru: "Музеи")
        case "nature": return localized(en: "Nature", nl: "Natuur", ru: "Природа")
        case "landmarks": return localized(en: "Landmarks", nl: "Bezienswaardigheden", ru: "Достопримечательности")
        case "historic", "historic-places", "architecture", "attractions": return localized(en: "Places to visit", nl: "Plekken om te bezoeken", ru: "Куда сходить")
        case "nightlife": return localized(en: "Nightlife", nl: "Nachtleven", ru: "Вечерний досуг")
        case "sports": return localized(en: "Sports", nl: "Sport", ru: "Спорт")
        case "festivals", "events-festivals": return localized(en: "Festivals", nl: "Festivals", ru: "Фестивали")
        case "family-activities": return localized(en: "Family activities", nl: "Gezinsactiviteiten", ru: "Для семьи")
        case "free-activities": return localized(en: "Free activities", nl: "Gratis activiteiten", ru: "Бесплатно")
        case "weekend": return localized(en: "Weekend ideas", nl: "Weekendideeën", ru: "Выходные")
        default: return localized(en: "Places", nl: "Plekken", ru: "Места")
        }
    }

    private var subtitle: String {
        switch normalizedID {
        case "sports":
            return localized(en: "\(city.name): gyms, pools, clubs, and outdoor routes.", nl: "\(city.name): sportscholen, zwembaden, clubs en buitenroutes.", ru: "\(city.name): залы, бассейны, клубы и маршруты на улице.")
        case "nightlife":
            return localized(en: "\(city.name): evening spots, live music, and late transport.", nl: "\(city.name): avondplekken, live muziek en laat vervoer.", ru: "\(city.name): вечерние места, музыка и поздний транспорт.")
        case "family-activities":
            return localized(en: "\(city.name): simple options for children and rainy days.", nl: "\(city.name): makkelijke opties met kinderen en regenachtige dagen.", ru: "\(city.name): простые варианты для детей и дождливой погоды.")
        case "free-activities":
            return localized(en: "\(city.name): low-cost ideas without random filler.", nl: "\(city.name): goedkope ideeen zonder willekeurige vulling.", ru: "\(city.name): бюджетные идеи без случайного контента.")
        default:
            return localized(
                en: "\(city.name): choose an item from this category.",
                nl: "\(city.name): kies een item uit deze categorie.",
                ru: "\(city.name): выберите пункт из этой категории."
            )
        }
    }

    private var symbol: String {
        switch normalizedID {
        case "restaurants": return "fork.knife"
        case "cafes": return "cup.and.saucer.fill"
        case "events", "festivals", "weekend", "events-today", "events-week", "events-weekend", "events-festivals": return "calendar"
        case "events-free": return "ticket.fill"
        case "events-family": return "figure.2.and.child.holdinghands"
        case "events-music": return "music.note"
        case "events-museums": return "building.columns.fill"
        case "events-markets": return "basket.fill"
        case "museums": return "building.columns.fill"
        case "nature": return "leaf.fill"
        case "historic": return "clock.fill"
        case "landmarks": return "camera.fill"
        case "nightlife": return "moon.stars.fill"
        case "sports": return "figure.run"
        case "family-activities": return "figure.2.and.child.holdinghands"
        case "free-activities": return "ticket.fill"
        default: return "mappin.and.ellipse"
        }
    }

    private var tint: Color {
        switch normalizedID {
        case "restaurants": return AppColors.dutchOrange
        case "cafes": return AppColors.warning
        case "nature", "sports", "free-activities": return AppColors.emerald
        case "museums", "nightlife": return AppColors.violet
        case "events", "festivals", "family-activities", "weekend", "events-today", "events-week", "events-weekend", "events-free", "events-family", "events-music", "events-museums", "events-markets", "events-festivals": return AppColors.softBlue
        default: return AppColors.cyanGlow
        }
    }

    private func foodTint(_ category: FoodGuideCategory) -> Color {
        switch category {
        case .restaurant, .fineDining: return AppColors.dutchOrange
        case .cafe, .breakfast: return AppColors.warning
        case .localFood, .market: return AppColors.emerald
        case .vegetarian: return AppColors.success
        case .budget: return AppColors.softBlue
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private func mapSearchAction(_ id: String, title: String, subtitle: String, symbol: String, accent: Color) -> ExploreListAction {
        let query = "\(title) in \(city.name) Netherlands"
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return ExploreListAction(
            id: id,
            title: title,
            subtitle: subtitle,
            symbol: symbol,
            accent: accent,
            destination: nil,
            url: AppURL.make("https://www.google.com/maps/search/\(encoded)")
        )
    }

    private func routeAction(_ id: String, title: String, subtitle: String, symbol: String, accent: Color, destination: AppDestination) -> ExploreListAction {
        ExploreListAction(
            id: id,
            title: title,
            subtitle: subtitle,
            symbol: symbol,
            accent: accent,
            destination: destination,
            url: nil
        )
    }
}

struct FoodGuideItemDetailView: View {
    let item: FoodGuideItem
    let city: DashboardCity

    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.openURL) private var openURL

    private var lang: AppLanguage { languageManager.appLanguage }
    private var accent: Color {
        switch item.category {
        case .restaurant, .fineDining: return AppColors.dutchOrange
        case .cafe, .breakfast: return AppColors.warning
        case .localFood, .market: return AppColors.emerald
        case .vegetarian: return AppColors.success
        case .budget: return AppColors.softBlue
        }
    }
    private var routeKind: String {
        [.cafe, .breakfast].contains(item.category) ? "cafe" : "restaurant"
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 720) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Label(categoryTitle, systemImage: item.icon)
                            .font(AppTypography.captionStrong)
                            .foregroundStyle(accent)
                        Text(item.shortTitle ?? item.title)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Label(city.name, systemImage: "mappin.and.ellipse")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(accent.opacity(0.25), lineWidth: 1))

                    Text(item.description)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.glassSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                    if let source = item.source {
                        VStack(alignment: .leading, spacing: 6) {
                            Label(source.institution ?? source.title, systemImage: "checkmark.seal.fill")
                                .font(AppTypography.bodyStrong)
                                .foregroundStyle(AppColors.success)
                            Text(source.title)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.glassSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }

                    if let externalURL = item.externalUrl {
                        Button { openURL(externalURL) } label: {
                            Label(openSourceTitle, systemImage: "arrow.up.forward.square")
                                .font(AppTypography.bodyStrong)
                                .frame(maxWidth: .infinity, minHeight: 48)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(accent)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(item.shortTitle ?? item.title)
        .nlNavigationInline()
        .accessibilityIdentifier("\(routeKind).detail.\(item.id)")
    }

    private var categoryTitle: String {
        switch (routeKind, lang) {
        case ("cafe", .dutch): return "Café"
        case ("cafe", .russian): return "Кафе"
        case ("cafe", .english): return "Café"
        case (_, .dutch): return "Restaurant"
        case (_, .russian): return "Ресторан"
        case (_, .english): return "Restaurant"
        }
    }

    private var openSourceTitle: String {
        switch lang {
        case .english: return "Open verified listing"
        case .dutch: return "Open gecontroleerde vermelding"
        case .russian: return "Открыть проверенную страницу"
        }
    }
}

private struct DiscoveryPlacePreviewSheet: View {
    let place: PlaceItem
    let city: String
    let language: AppLanguage
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .bottomLeading) {
                        if previewAsset != nil {
                            PremiumImageView(
                                asset: previewAsset,
                                language: language,
                                height: 190,
                                cornerRadius: 16
                            )
                        } else {
                            RoundedRectangle(cornerRadius: 16).fill(AppColors.glassSurfaceElevated).frame(height: 190)
                                .overlay(Image(systemName: place.primaryCategory.symbol).font(.system(size: 42)).foregroundStyle(place.primaryCategory.accent))
                        }
                        LinearGradient(colors: [.clear, AppColors.backgroundPrimary.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(place.primaryCategory.title(language)).font(AppTypography.captionStrong).foregroundStyle(place.primaryCategory.accent)
                            Text(place.shortTitle ?? place.title).font(AppTypography.sectionTitle).foregroundStyle(AppColors.textPrimary)
                        }.padding(14)
                    }

                    Text(place.description).font(AppTypography.body).foregroundStyle(AppColors.textSecondary)
                    Label(place.address ?? city, systemImage: "mappin.and.ellipse")
                        .font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)

                    HStack(spacing: 10) {
                        if let externalURL = place.externalUrl {
                            Button { openURL(externalURL) } label: { Label("Website", systemImage: "safari.fill").frame(maxWidth: .infinity, minHeight: 44) }
                                .buttonStyle(.bordered)
                        }
                        ShareLink(item: place.externalUrl ?? AppURL.make("https://younew.nl")) {
                            Label("Share", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                    }

                    NavigationLink(value: place.destination) {
                        Text(localized(en: "Open details", nl: "Open details", ru: "Открыть подробно"))
                            .font(AppTypography.bodyStrong).frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.dutchOrange)
                    .accessibilityIdentifier("placePreview.openDetails.\(place.id)")
                }
                .padding(18)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle(localized(en: "Place preview", nl: "Voorvertoning", ru: "Предпросмотр места"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button(localized(en: "Close", nl: "Sluiten", ru: "Закрыть")) { dismiss() } } }
        }
        .accessibilityIdentifier("placePreview.\(place.id)")
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch language { case .english: return en; case .dutch: return nl; case .russian: return ru }
    }

    private var previewAsset: AppImageAsset? {
        switch place.primaryCategory {
        case .museum, .rainyDay: return ContentMediaRegistry.museumsCultureImage ?? ContentMediaRegistry.dailyCultureImage
        case .park, .viewpoint, .hiddenGem, .free: return ContentMediaRegistry.natureImage ?? ContentMediaRegistry.leidenCanalsHero
        case .food, .market: return ContentMediaRegistry.foodImage ?? ContentMediaRegistry.marketsLocalLifeImage
        case .historic, .landmark, .family: return ContentMediaRegistry.leidenCanalsHero ?? ContentMediaRegistry.canalHousesHero
        }
    }
}

private struct ExploreListAction: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let accent: Color
    let destination: AppDestination?
    let url: URL?
}
