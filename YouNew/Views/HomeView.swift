import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct HomeView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var router: TabRouter
    @EnvironmentObject private var documentStore: DocumentStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.openURL) private var openURL
    @Binding var selectedTab: AppTab
    var onOpenMenu: () -> Void = {}

    @State private var heroVisible = true
    @State private var contentVisible = true
    @State private var mapGlowPhase: Double = 0.45
    @State private var selectedPlaceFilter: VisitPlaceCategory? = nil
    @State private var selectedCalendarFilter: CalendarEventType? = nil
    @State private var dashboardTimestamp = Date()

    private static var isUITesting: Bool {
#if DEBUG
        ProcessInfo.processInfo.arguments.contains("-uiTesting")
#else
        false
#endif
    }

    private static let clockFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let englishDateFormatter: DateFormatter = HomeView.dateFormatter(localeIdentifier: "en_GB")
    private static let dutchDateFormatter: DateFormatter = HomeView.dateFormatter(localeIdentifier: "nl_NL")
    private static let russianDateFormatter: DateFormatter = HomeView.dateFormatter(localeIdentifier: "ru_RU")

    private var lang: AppLanguage { languageManager.appLanguage }
    private var cityName: String { ProvinceCatalog.localizedCityName(cityDashboard.cityName, lang) }
    private var cityDashboard: CityDashboardContent {
        CityDashboardContentData.content(for: appState.selectedCity)
    }
    private var citySwitcherNames: [String] {
        CityDashboardContentData.supportedCityNames
    }
    private var selectedCityIndex: Int? {
        citySwitcherNames.firstIndex { $0.caseInsensitiveCompare(cityDashboard.cityName) == .orderedSame }
    }
    private var selectedHeroCity: NLCity? {
        cityDashboard.heroCity
    }
    private var selectedHeroCityItem: CityItem? {
        ProvinceCatalog.citySpotlight(matching: cityDashboard.cityName)?.city
    }
    private var selectedAudience: UserContentCategory? {
        UserContentCategory.from(persona: appState.selectedUserStatus?.personaTag)
    }
    private var cityGuideAudience: UserContentCategory {
        selectedAudience ?? .tourist
    }
    private var dashboardRenderContext: DashboardRenderContext {
        DashboardRenderContext(
            selectedAudience: selectedAudience,
            selectedCityID: cityDashboard.cityName
        )
    }
    private var isTouristMode: Bool {
        selectedAudience == .tourist
    }
    private var isRefugeeOrStatusHolderMode: Bool {
        switch appState.selectedUserStatus {
        case .refugee, .ukrainian:
            return true
        default:
            return false
        }
    }
    private var isStudentMode: Bool {
        selectedAudience == .student
    }
    private var isBusinessMode: Bool {
        selectedAudience == .business
    }
    private var isGeneralMode: Bool {
        selectedAudience == .general
    }
    private var selectedHeroCityAsset: AppImageAsset {
        if let city = selectedHeroCity {
            return cityImageAsset(city)
        }
        if let city = selectedHeroCityItem {
            return cityImageAsset(city)
        }
        return cityFallbackImageAsset(for: cityDashboard.city)
    }
    private var dashboardPlaces: [PlaceItem] {
        DashboardPlacesData.visiblePlaces(cityId: cityDashboard.cityName, audience: cityGuideAudience, limit: nil)
    }
    private var filteredDashboardPlaces: [PlaceItem] {
        guard let selectedPlaceFilter else { return dashboardPlaces }
        return dashboardPlaces.filter { $0.category.contains(selectedPlaceFilter) }
    }
    private var dashboardEvents: [CalendarEvent] {
        DashboardCalendarData.upcomingEvents(cityId: cityDashboard.cityName, audience: selectedAudience, limit: 8)
    }
    private var filteredDashboardEvents: [CalendarEvent] {
        guard let selectedCalendarFilter else { return dashboardEvents }
        return dashboardEvents.filter { $0.type == selectedCalendarFilter }
    }
    private var travelLinkByKind: [TravelLinkKind: TravelLinkItem] {
        Dictionary(uniqueKeysWithValues: cityDashboard.travelLinks.map { ($0.kind, $0) })
    }
    private var visibleTravelLinks: [TravelLinkItem] {
        cityDashboard.travelLinks
            .filter { link in
                link.cityId == cityDashboard.city.id.rawValue
                    && AppURL.validatedWebURL(link.externalLink?.url ?? link.url) != nil
                    && canShowTravelLink(link)
            }
            .sorted { $0.priority == $1.priority ? $0.title < $1.title : $0.priority < $1.priority }
    }
    private var mainTravelActions: [HomeCityGuideActionItem] {
        switch audienceDashboardMode {
        case .tourist:
            return stayPlanningActions
        case .refugee:
            return refugeeEssentialsActions
        case .student:
            return studentEssentialsActions
        case .business:
            return businessEssentialsActions
        case .general:
            return generalEssentialsActions
        case .local:
            return residentEssentialsActions
        }
    }
    private enum HomeAudienceDashboardMode {
        case tourist
        case refugee
        case student
        case business
        case general
        case local
    }
    private var audienceDashboardMode: HomeAudienceDashboardMode {
        if selectedAudience == nil || selectedAudience == .tourist { return .tourist }
        if isRefugeeOrStatusHolderMode { return .refugee }
        if isStudentMode { return .student }
        if isBusinessMode { return .business }
        if isGeneralMode { return .general }
        return .local
    }
    private var isStayPlanningMode: Bool {
        selectedAudience == nil || selectedAudience == .tourist
    }
    private func canShowTravelLink(_ link: TravelLinkItem) -> Bool {
        guard !link.audience.isEmpty else { return false }
        switch audienceDashboardMode {
        case .tourist:
            return true
        case .refugee:
            return false
        case .student:
            return [.cafes, .places, .maps, .officialGuide].contains(link.kind)
        case .business:
            return [.booking, .restaurants, .maps, .officialGuide].contains(link.kind)
        case .general:
            return [.places, .maps, .officialGuide].contains(link.kind)
        case .local:
            return false
        }
    }
    private var stayPlanningActions: [HomeCityGuideActionItem] {
        [
            travelAction(.booking, title: "Hotels in \(cityDashboard.cityName)", subtitle: "Open Booking.com", symbol: "bed.double.fill", provider: "Booking", cta: "Find stays"),
            searchAction(id: "plan-restaurants", title: "Restaurants", subtitle: "Food guide", query: cityDashboard.city.restaurantQuery, symbol: "fork.knife", tint: AppColors.dutchOrange),
            searchAction(id: "plan-cafes", title: "Cafes", subtitle: "Coffee & breakfast", query: cityDashboard.city.cafeQuery, symbol: "cup.and.saucer.fill", tint: AppColors.warning),
            HomeCityGuideActionItem(id: "plan-places", title: "Places", subtitle: "Museums & landmarks", symbol: "building.columns.fill", tint: AppColors.cyanGlow, url: nil, destination: cityDashboard.mapFocus, provider: nil, cta: nil, externalLink: nil),
            HomeCityGuideActionItem(id: "plan-transport", title: "Transport", subtitle: "OV, bikes, routes", symbol: "tram.fill", tint: AppColors.emerald, url: nil, destination: .practicalGuide(.transportBasics), provider: nil, cta: nil, externalLink: nil),
            HomeCityGuideActionItem(id: "plan-emergency", title: "Emergency", subtitle: "112 and urgent help", symbol: "phone.fill", tint: AppColors.error, url: nil, destination: .emergencyHub, provider: nil, cta: nil, externalLink: nil)
        ].compactMap { $0 }
    }
    private var cityEssentialsActions: [HomeCityGuideActionItem] {
        residentEssentialsActions
    }
    private var refugeeEssentialsActions: [HomeCityGuideActionItem] {
        [
            routeAction(id: "refugee-ind", title: "IND", subtitle: "Status and documents", symbol: "building.columns.fill", tint: AppColors.softBlue, destination: .governmentHub),
            routeAction(id: "refugee-municipality", title: "Municipality", subtitle: "Registration and local support", symbol: "building.2.fill", tint: AppColors.cyanGlow, destination: .governmentHub),
            routeAction(id: "refugee-housing", title: "Housing", subtitle: "Home and address basics", symbol: "house.fill", tint: AppColors.violet, destination: .practicalGuide(.housingBasics)),
            routeAction(id: "refugee-benefits", title: "Benefits", subtitle: "Official support routes", symbol: "creditcard.fill", tint: AppColors.dutchOrange, destination: .officialSources),
            routeAction(id: "refugee-healthcare", title: "Healthcare", subtitle: "GP, insurance, urgent care", symbol: "cross.case.fill", tint: AppColors.emerald, destination: .practicalGuide(.healthcareBasics)),
            routeAction(id: "refugee-documents", title: "Documents", subtitle: "Papers and official steps", symbol: "doc.text.fill", tint: AppColors.warning, destination: .journeyDocuments)
        ]
    }
    private var studentEssentialsActions: [HomeCityGuideActionItem] {
        [
            routeAction(id: "student-transport", title: "Transport", subtitle: "OV, bikes, routes", symbol: "tram.fill", tint: AppColors.emerald, destination: .practicalGuide(.transportBasics)),
            routeAction(id: "student-housing", title: "Housing", subtitle: "Rooms and address basics", symbol: "house.fill", tint: AppColors.violet, destination: .practicalGuide(.housingBasics)),
            routeAction(id: "student-education", title: "Education", subtitle: "Schools and institutions", symbol: "graduationcap.fill", tint: AppColors.softBlue, destination: .institutionsList),
            HomeCityGuideActionItem(id: "student-places", title: "City places", subtitle: "Museums & landmarks", symbol: "building.columns.fill", tint: AppColors.cyanGlow, url: nil, destination: cityDashboard.mapFocus, provider: nil, cta: nil, externalLink: nil),
            searchAction(id: "student-cafes", title: "Cafes", subtitle: "Coffee & study breaks", query: cityDashboard.city.cafeQuery, symbol: "cup.and.saucer.fill", tint: AppColors.warning),
            routeAction(id: "student-emergency", title: "Emergency", subtitle: "112 and urgent help", symbol: "phone.fill", tint: AppColors.error, destination: .emergencyHub)
        ]
    }
    private var businessEssentialsActions: [HomeCityGuideActionItem] {
        [
            routeAction(id: "business-setup", title: "Business setup", subtitle: "Municipality and KVK basics", symbol: "building.columns.fill", tint: AppColors.softBlue, destination: .officialSources),
            routeAction(id: "business-taxes", title: "Taxes", subtitle: "Business tax basics", symbol: "percent", tint: AppColors.dutchOrange, destination: .guideSection("work")),
            routeAction(id: "business-transport", title: "Transport", subtitle: "Routes and local travel", symbol: "tram.fill", tint: AppColors.emerald, destination: .practicalGuide(.transportBasics)),
            travelAction(.booking, title: "Hotels in \(cityDashboard.cityName)", subtitle: "Business stays", symbol: "bed.double.fill", provider: "Booking"),
            searchAction(id: "business-restaurants", title: "Restaurants", subtitle: "Business meals", query: cityDashboard.city.restaurantQuery, symbol: "fork.knife", tint: AppColors.warning),
            routeAction(id: "business-emergency", title: "Emergency", subtitle: "112 and urgent help", symbol: "phone.fill", tint: AppColors.error, destination: .emergencyHub)
        ].compactMap { $0 }
    }
    private var generalEssentialsActions: [HomeCityGuideActionItem] {
        [
            HomeCityGuideActionItem(id: "general-city-guide", title: "City guide", subtitle: "\(cityDashboard.cityName) essentials", symbol: "map.fill", tint: AppColors.cyanGlow, url: nil, destination: .nlCityDetail(cityDashboard.routeCityId), provider: nil, cta: nil, externalLink: nil),
            HomeCityGuideActionItem(id: "general-places", title: "Places", subtitle: "Museums & landmarks", symbol: "building.columns.fill", tint: AppColors.softBlue, url: nil, destination: cityDashboard.mapFocus, provider: nil, cta: nil, externalLink: nil),
            routeAction(id: "general-transport", title: "Transport", subtitle: "OV, bikes, routes", symbol: "tram.fill", tint: AppColors.emerald, destination: .practicalGuide(.transportBasics)),
            routeAction(id: "general-emergency", title: "Emergency", subtitle: "112 and urgent help", symbol: "phone.fill", tint: AppColors.error, destination: .emergencyHub)
        ]
    }
    private var residentEssentialsActions: [HomeCityGuideActionItem] {
        [
            routeAction(id: "resident-documents", title: "Documents", subtitle: "BSN, DigiD, local steps", symbol: "doc.text.fill", tint: AppColors.softBlue, destination: .journeyDocuments),
            routeAction(id: "resident-municipality", title: "Municipality", subtitle: "Address and city services", symbol: "building.2.fill", tint: AppColors.cyanGlow, destination: .governmentHub),
            routeAction(id: "resident-housing", title: "Housing", subtitle: "Rent and address basics", symbol: "house.fill", tint: AppColors.violet, destination: .practicalGuide(.housingBasics)),
            routeAction(id: "resident-healthcare", title: "Healthcare", subtitle: "GP and insurance basics", symbol: "cross.case.fill", tint: AppColors.emerald, destination: .practicalGuide(.healthcareBasics)),
            routeAction(id: "resident-transport", title: "Transport", subtitle: "OV, bikes, routes", symbol: "tram.fill", tint: AppColors.dutchOrange, destination: .practicalGuide(.transportBasics)),
            routeAction(id: "resident-emergency", title: "Emergency", subtitle: "112 and urgent help", symbol: "phone.fill", tint: AppColors.error, destination: .emergencyHub)
        ]
    }
    private var foodDrinkActions: [HomeCityGuideActionItem] {
        guard shouldShowFoodDrinksSection else { return [] }
        return Array(CityDashboardContentData.foodGuideItems(for: cityDashboard.city, audience: selectedAudience)
            .filter { foodGuideItemIsVisible($0) }
            .map(foodGuideAction)
            .prefix(4))
    }
    private var stayActions: [HomeCityGuideActionItem] {
        guard shouldShowStaySection else { return [] }
        return [
            travelAction(.booking, title: localizedText(en: "Hotels in \(cityDashboard.cityName)", nl: "Hotels in \(cityDashboard.cityName)", ru: "Отели в \(cityDashboard.cityName)"), subtitle: "Open Booking.com", symbol: "bed.double.fill", provider: "Booking", cta: "Find stays"),
            searchAction(id: "stay-apartments", title: localizedText(en: "Apartments", nl: "Appartementen", ru: "Апартаменты"), query: "apartments in \(cityDashboard.cityName) Netherlands", symbol: "building.2.fill", tint: AppColors.cyanGlow),
            searchAction(id: "stay-nearby", title: localizedText(en: "Nearby stays", nl: "Verblijf dichtbij", ru: "Жильё рядом"), query: "stays near \(cityDashboard.cityName) Netherlands", symbol: "mappin.and.ellipse", tint: AppColors.emerald)
        ].compactMap { $0 }
    }
    private var shouldShowPlacesSection: Bool {
        switch audienceDashboardMode {
        case .tourist, .student, .general:
            return true
        case .business, .local, .refugee:
            return false
        }
    }

    private var homeExploreItems: [HomeExploreItem] {
        [
            HomeExploreItem(
                id: "cities",
                title: localizedText(en: "Cities", nl: "Steden", ru: "Города"),
                subtitle: localizedText(en: "Amsterdam, Leiden, Utrecht and more", nl: "Amsterdam, Leiden, Utrecht en meer", ru: "Amsterdam, Leiden, Utrecht и другие"),
                symbol: "building.2.fill",
                tint: AppColors.cyanGlow,
                destination: .cityList
            ),
            HomeExploreItem(
                id: "places",
                title: localizedText(en: "Places", nl: "Plekken", ru: "Места"),
                subtitle: localizedText(en: "Explore the map", nl: "Verken de kaart", ru: "Открыть карту"),
                symbol: "map.fill",
                tint: AppColors.routeLine,
                destination: .homeExploreList("places")
            ),
            HomeExploreItem(
                id: "transport",
                title: localizedText(en: "Transport", nl: "Vervoer", ru: "Транспорт"),
                subtitle: localizedText(en: "OV, trains, bikes, routes", nl: "OV, trein, fiets, routes", ru: "OV, поезда, велосипед, маршруты"),
                symbol: "tram.fill",
                tint: AppColors.emerald,
                destination: .practicalGuide(.transportBasics)
            ),
            HomeExploreItem(
                id: "healthcare",
                title: localizedText(en: "Healthcare", nl: "Zorg", ru: "Медицина"),
                subtitle: localizedText(en: "GP, pharmacies, urgent care", nl: "Huisarts, apotheek, spoedzorg", ru: "Huisarts, аптеки, срочная помощь"),
                symbol: "cross.case.fill",
                tint: AppColors.error,
                destination: .practicalGuide(.healthcareBasics)
            ),
            HomeExploreItem(
                id: "government",
                title: localizedText(en: "Government", nl: "Overheid", ru: "Государство"),
                subtitle: localizedText(en: "Municipality and official services", nl: "Gemeente en officiële diensten", ru: "Gemeente и официальные службы"),
                symbol: "building.columns.fill",
                tint: AppColors.softBlue,
                destination: .governmentHub
            ),
            HomeExploreItem(
                id: "food",
                title: localizedText(en: "Restaurants", nl: "Restaurants", ru: "Рестораны"),
                subtitle: localizedText(en: "Food, cafés, local spots", nl: "Eten, cafés, lokale plekken", ru: "Еда, кафе, локальные места"),
                symbol: "fork.knife",
                tint: AppColors.dutchOrange,
                destination: .homeExploreList("restaurants")
            ),
            HomeExploreItem(
                id: "museums",
                title: localizedText(en: "Museums", nl: "Musea", ru: "Музеи"),
                subtitle: localizedText(en: "Culture and attractions", nl: "Cultuur en attracties", ru: "Культура и достопримечательности"),
                symbol: "building.columns",
                tint: AppColors.violet,
                destination: .homeExploreList("museums")
            ),
            HomeExploreItem(
                id: "events",
                title: localizedText(en: "Events", nl: "Events", ru: "События"),
                subtitle: localizedText(en: "Holidays and city moments", nl: "Feestdagen en stadsmomenten", ru: "Праздники и городские события"),
                symbol: "calendar",
                tint: AppColors.warning,
                destination: .homeExploreList("events")
            ),
            HomeExploreItem(
                id: "nature",
                title: localizedText(en: "Nature", nl: "Natuur", ru: "Природа"),
                subtitle: localizedText(en: "Parks, beaches, green routes", nl: "Parken, stranden, groene routes", ru: "Парки, пляжи, зелёные маршруты"),
                symbol: "leaf.fill",
                tint: AppColors.success,
                destination: .homeExploreList("nature")
            ),
            HomeExploreItem(
                id: "shopping",
                title: localizedText(en: "Shopping", nl: "Winkelen", ru: "Покупки"),
                subtitle: localizedText(en: "Markets and local services", nl: "Markten en lokale diensten", ru: "Рынки и локальные сервисы"),
                symbol: "bag.fill",
                tint: AppColors.accent,
                destination: .localPartners
            )
        ]
    }

    private var officialServicesItems: [HomeExploreItem] {
        [
            HomeExploreItem(id: "municipality", title: "Municipality", subtitle: localizedText(en: "City services and registration", nl: "Gemeentezaken en inschrijving", ru: "Городские услуги и регистрация"), symbol: "building.2.fill", tint: AppColors.cyanGlow, destination: .governmentHub),
            HomeExploreItem(id: "ind", title: "IND", subtitle: localizedText(en: "Residence and immigration", nl: "Verblijf en immigratie", ru: "ВНЖ и иммиграция"), symbol: "building.columns.fill", tint: AppColors.softBlue, destination: .governmentHub),
            HomeExploreItem(id: "digid", title: "DigiD", subtitle: localizedText(en: "Digital access to services", nl: "Digitale toegang tot diensten", ru: "Цифровой доступ к сервисам"), symbol: "lock.shield.fill", tint: AppColors.violet, destination: .officialSources),
            HomeExploreItem(id: "belastingdienst", title: "Belastingdienst", subtitle: localizedText(en: "Taxes and benefits", nl: "Belasting en toeslagen", ru: "Налоги и пособия"), symbol: "percent", tint: AppColors.dutchOrange, destination: .officialSources),
            HomeExploreItem(id: "duo", title: "DUO", subtitle: localizedText(en: "Study finance and exams", nl: "Studiefinanciering en examens", ru: "Учёба, финансирование, экзамены"), symbol: "graduationcap.fill", tint: AppColors.emerald, destination: .officialSources),
            HomeExploreItem(id: "emergency", title: localizedText(en: "Emergency", nl: "Noodhulp", ru: "Экстренно"), subtitle: "112", symbol: "phone.fill", tint: AppColors.error, destination: .emergencyHub)
        ]
    }

    private var placesToVisitItems: [HomeExploreItem] {
        [
            HomeExploreItem(id: "museums", title: localizedText(en: "Museums", nl: "Musea", ru: "Музеи"), subtitle: localizedText(en: "Culture and collections", nl: "Cultuur en collecties", ru: "Культура и коллекции"), symbol: "building.columns.fill", tint: AppColors.violet, destination: .homeExploreList("museums")),
            HomeExploreItem(id: "nature", title: localizedText(en: "Nature", nl: "Natuur", ru: "Природа"), subtitle: localizedText(en: "Parks and green routes", nl: "Parken en groene routes", ru: "Парки и зелёные маршруты"), symbol: "leaf.fill", tint: AppColors.success, destination: .homeExploreList("nature")),
            HomeExploreItem(id: "historic", title: localizedText(en: "Historic places", nl: "Historische plekken", ru: "Исторические места"), subtitle: localizedText(en: "Canals, squares, landmarks", nl: "Grachten, pleinen, monumenten", ru: "Каналы, площади, памятники"), symbol: "clock.fill", tint: AppColors.cyanGlow, destination: .homeExploreList("historic")),
            HomeExploreItem(id: "restaurants", title: localizedText(en: "Restaurants", nl: "Restaurants", ru: "Рестораны"), subtitle: localizedText(en: "Food and local spots", nl: "Eten en lokale plekken", ru: "Еда и локальные места"), symbol: "fork.knife", tint: AppColors.dutchOrange, destination: .homeExploreList("restaurants")),
            HomeExploreItem(id: "cafes", title: localizedText(en: "Cafes", nl: "Cafés", ru: "Кафе"), subtitle: localizedText(en: "Coffee and breakfast", nl: "Koffie en ontbijt", ru: "Кофе и завтраки"), symbol: "cup.and.saucer.fill", tint: AppColors.warning, destination: .homeExploreList("cafes")),
            HomeExploreItem(id: "events", title: localizedText(en: "Events", nl: "Events", ru: "События"), subtitle: localizedText(en: "What is happening nearby", nl: "Wat er dichtbij gebeurt", ru: "Что происходит рядом"), symbol: "calendar", tint: AppColors.softBlue, destination: .homeExploreList("events"))
        ]
    }

    private var housingItems: [HomeExploreItem] {
        [
            HomeExploreItem(id: "rent", title: localizedText(en: "Rent", nl: "Huren", ru: "Аренда"), subtitle: localizedText(en: "Rules and first checks", nl: "Regels en eerste checks", ru: "Правила и первые проверки"), symbol: "key.fill", tint: AppColors.warning, destination: .practicalGuide(.housingBasics)),
            HomeExploreItem(id: "buy", title: localizedText(en: "Buy", nl: "Kopen", ru: "Покупка"), subtitle: localizedText(en: "Ownership basics", nl: "Basis van kopen", ru: "Основы покупки"), symbol: "house.fill", tint: AppColors.cyanGlow, destination: .practicalGuide(.housingBasics)),
            HomeExploreItem(id: "student-housing", title: localizedText(en: "Student housing", nl: "Studentenwoning", ru: "Студенческое жильё"), subtitle: localizedText(en: "Rooms and registration", nl: "Kamers en inschrijving", ru: "Комнаты и регистрация"), symbol: "graduationcap.fill", tint: AppColors.emerald, destination: .practicalGuide(.housingBasics)),
            HomeExploreItem(id: "social-housing", title: localizedText(en: "Social rent", nl: "Sociale huur", ru: "Соц. аренда"), subtitle: localizedText(en: "Waiting lists and rules", nl: "Wachtlijsten en regels", ru: "Очереди и правила"), symbol: "person.3.fill", tint: AppColors.softBlue, destination: .officialSources),
            HomeExploreItem(id: "housing-tips", title: localizedText(en: "Housing tips", nl: "Woontips", ru: "Советы по жилью"), subtitle: localizedText(en: "Avoid common mistakes", nl: "Voorkom veelgemaakte fouten", ru: "Избежать типичных ошибок"), symbol: "lightbulb.fill", tint: AppColors.violet, destination: .practicalGuide(.housingBasics)),
            HomeExploreItem(id: "real-estate", title: localizedText(en: "Agents", nl: "Makelaars", ru: "Агенты"), subtitle: localizedText(en: "Featured local services", nl: "Uitgelichte lokale diensten", ru: "Локальные сервисы"), symbol: "storefront.fill", tint: AppColors.dutchOrange, destination: .localPartners)
        ]
    }

    private var transportItems: [HomeExploreItem] {
        [
            HomeExploreItem(id: "train", title: localizedText(en: "Train", nl: "Trein", ru: "Поезд"), subtitle: localizedText(en: "NS and stations", nl: "NS en stations", ru: "NS и вокзалы"), symbol: "train.side.front.car", tint: AppColors.dutchOrange, destination: .practicalGuide(.transportBasics)),
            HomeExploreItem(id: "bus", title: localizedText(en: "Bus", nl: "Bus", ru: "Автобус"), subtitle: localizedText(en: "Local and regional routes", nl: "Lokale en regionale routes", ru: "Городские и региональные маршруты"), symbol: "bus.fill", tint: AppColors.emerald, destination: .practicalGuide(.transportBasics)),
            HomeExploreItem(id: "metro", title: "Metro", subtitle: localizedText(en: "City networks", nl: "Stadsnetwerken", ru: "Городские сети"), symbol: "tram.fill", tint: AppColors.softBlue, destination: .practicalGuide(.transportBasics)),
            HomeExploreItem(id: "bike", title: localizedText(en: "Bike", nl: "Fiets", ru: "Велосипед"), subtitle: localizedText(en: "Rules and repairs", nl: "Regels en reparatie", ru: "Правила и ремонт"), symbol: "bicycle", tint: AppColors.success, destination: .practicalGuide(.transportBasics)),
            HomeExploreItem(id: "parking", title: localizedText(en: "Parking", nl: "Parkeren", ru: "Парковка"), subtitle: localizedText(en: "City rules and fines", nl: "Stadsregels en boetes", ru: "Правила и штрафы"), symbol: "parkingsign.circle.fill", tint: AppColors.warning, destination: .finesList),
            HomeExploreItem(id: "planner", title: localizedText(en: "Planner", nl: "Planner", ru: "Маршруты"), subtitle: localizedText(en: "Routes and transfers", nl: "Routes en overstappen", ru: "Маршруты и пересадки"), symbol: "location.fill", tint: AppColors.cyanGlow, destination: .mapHub)
        ]
    }

    private var leisureItems: [HomeExploreItem] {
        [
            HomeExploreItem(id: "nightlife", title: localizedText(en: "Nightlife", nl: "Nachtleven", ru: "Вечерний досуг"), subtitle: localizedText(en: "Bars, venues, and late routes", nl: "Bars, podia en late routes", ru: "Бары, площадки и поздние маршруты"), symbol: "moon.stars.fill", tint: AppColors.violet, destination: .homeExploreList("nightlife")),
            HomeExploreItem(id: "sports", title: localizedText(en: "Sports", nl: "Sport", ru: "Спорт"), subtitle: localizedText(en: "Clubs and activities", nl: "Clubs en activiteiten", ru: "Клубы и активности"), symbol: "figure.run", tint: AppColors.emerald, destination: .homeExploreList("sports")),
            HomeExploreItem(id: "festivals", title: localizedText(en: "Festivals", nl: "Festivals", ru: "Фестивали"), subtitle: localizedText(en: "Music, culture, and city events", nl: "Muziek, cultuur en stadsevents", ru: "Музыка, культура и городские события"), symbol: "party.popper.fill", tint: AppColors.softBlue, destination: .homeExploreList("festivals")),
            HomeExploreItem(id: "family-activities", title: localizedText(en: "Family", nl: "Gezin", ru: "Семья"), subtitle: localizedText(en: "Easy options for children", nl: "Makkelijke opties met kinderen", ru: "Простые варианты с детьми"), symbol: "figure.2.and.child.holdinghands", tint: AppColors.success, destination: .homeExploreList("family-activities")),
            HomeExploreItem(id: "free-activities", title: localizedText(en: "Free", nl: "Gratis", ru: "Бесплатно"), subtitle: localizedText(en: "Low-cost city ideas", nl: "Goedkope stadsopties", ru: "Бюджетные идеи в городе"), symbol: "ticket.fill", tint: AppColors.dutchOrange, destination: .homeExploreList("free-activities")),
            HomeExploreItem(id: "weekend", title: localizedText(en: "Weekend", nl: "Weekend", ru: "Выходные"), subtitle: localizedText(en: "Explore without planning stress", nl: "Ontdek zonder planningsstress", ru: "Исследовать без перегруза"), symbol: "sparkles", tint: AppColors.cyanGlow, destination: .homeExploreList("weekend"))
        ]
    }

    private var educationItems: [HomeExploreItem] {
        [
            HomeExploreItem(id: "universities", title: localizedText(en: "Universities", nl: "Universiteiten", ru: "Университеты"), subtitle: localizedText(en: "Institutions and study paths", nl: "Instellingen en studieroutes", ru: "Учебные заведения"), symbol: "graduationcap.fill", tint: AppColors.emerald, destination: .institutionsList),
            HomeExploreItem(id: "language-schools", title: localizedText(en: "Language schools", nl: "Taalscholen", ru: "Языковые школы"), subtitle: localizedText(en: "Dutch learning options", nl: "Nederlands leren", ru: "Изучение Dutch"), symbol: "text.book.closed.fill", tint: AppColors.violet, destination: .dutchA1A2),
            HomeExploreItem(id: "driving-schools", title: localizedText(en: "Driving schools", nl: "Rijscholen", ru: "Автошколы"), subtitle: localizedText(en: "Lessons and local partners", nl: "Lessen en lokale partners", ru: "Уроки и партнёры"), symbol: "car.fill", tint: AppColors.dutchOrange, destination: .localPartners),
            HomeExploreItem(id: "duo-education", title: "DUO", subtitle: localizedText(en: "Study finance and exams", nl: "Studiefinanciering en examens", ru: "Учёба и экзамены"), symbol: "building.columns.fill", tint: AppColors.softBlue, destination: .officialSources),
            HomeExploreItem(id: "student-benefits", title: localizedText(en: "Student benefits", nl: "Studentenvoordelen", ru: "Студенческие льготы"), subtitle: localizedText(en: "Public sources and tips", nl: "Bronnen en tips", ru: "Источники и советы"), symbol: "creditcard.fill", tint: AppColors.warning, destination: .officialSources)
        ]
    }

    private var discoverNetherlandsItems: [HomeExploreItem] {
        [
            HomeExploreItem(id: "history", title: localizedText(en: "History", nl: "Geschiedenis", ru: "История"), subtitle: localizedText(en: "From cities to monarchy", nl: "Van steden tot monarchie", ru: "От городов до монархии"), symbol: "book.closed.fill", tint: AppColors.softBlue, destination: .netherlandsHistory),
            HomeExploreItem(id: "culture", title: localizedText(en: "Culture", nl: "Cultuur", ru: "Культура"), subtitle: localizedText(en: "Habits and everyday life", nl: "Gewoonten en dagelijks leven", ru: "Привычки и жизнь"), symbol: "theatermasks.fill", tint: AppColors.violet, destination: .discoverNetherlands),
            HomeExploreItem(id: "traditions", title: localizedText(en: "Traditions", nl: "Tradities", ru: "Традиции"), subtitle: localizedText(en: "Holidays and rituals", nl: "Feestdagen en rituelen", ru: "Праздники и ритуалы"), symbol: "flag.fill", tint: AppColors.dutchOrange, destination: .netherlandsCalendar),
            HomeExploreItem(id: "facts", title: localizedText(en: "Interesting facts", nl: "Weetjes", ru: "Интересные факты"), subtitle: localizedText(en: "Small things to know", nl: "Kleine dingen om te weten", ru: "Полезные детали"), symbol: "lightbulb.fill", tint: AppColors.warning, destination: .netherlandsOverview),
            HomeExploreItem(id: "people", title: localizedText(en: "Famous people", nl: "Bekende mensen", ru: "Известные люди"), subtitle: localizedText(en: "Stories and figures", nl: "Verhalen en personen", ru: "Истории и личности"), symbol: "person.2.fill", tint: AppColors.cyanGlow, destination: .dutchFigures)
        ]
    }

    private static func dateFormatter(localeIdentifier: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.setLocalizedDateFormatFromTemplate("d MMMM")
        return formatter
    }
    private var shouldShowFoodDrinksSection: Bool {
        switch audienceDashboardMode {
        case .tourist, .student, .business:
            return true
        case .general, .local, .refugee:
            return false
        }
    }
    private var shouldShowStaySection: Bool {
        switch audienceDashboardMode {
        case .tourist, .business:
            return true
        case .student, .general, .local, .refugee:
            return false
        }
    }
    private func foodGuideItemIsVisible(_ item: FoodGuideItem) -> Bool {
        switch audienceDashboardMode {
        case .tourist:
            return true
        case .student:
            return [.cafe, .breakfast, .budget].contains(item.category)
        case .business:
            return [.restaurant, .cafe, .fineDining].contains(item.category)
        case .general, .local, .refugee:
            return false
        }
    }

    private func travelAction(_ kind: TravelLinkKind, title: String, subtitle: String, symbol: String, provider: String? = nil, cta: String? = nil) -> HomeCityGuideActionItem? {
        guard let link = travelLinkByKind[kind] else { return nil }
        let externalLink = link.externalLink
        let safeURL = externalLink?.url ?? link.url
        guard AppURL.validatedWebURL(safeURL) != nil else { return nil }
        return HomeCityGuideActionItem(
            id: kind.rawValue,
            title: title,
            subtitle: subtitle,
            symbol: symbol,
            tint: kind.accent,
            url: safeURL,
            destination: nil,
            provider: externalLink?.provider.label ?? provider,
            cta: cta,
            externalLink: externalLink
        )
    }

    private func routeAction(id: String, title: String, subtitle: String, symbol: String, tint: Color, destination: AppDestination) -> HomeCityGuideActionItem {
        HomeCityGuideActionItem(
            id: id,
            title: title,
            subtitle: subtitle,
            symbol: symbol,
            tint: tint,
            url: nil,
            destination: destination,
            provider: nil,
            cta: nil,
            externalLink: nil
        )
    }

    private func searchAction(
        id: String,
        title: String,
        subtitle: String? = nil,
        query: String,
        symbol: String,
        tint: Color,
        host: String = "www.google.com",
        path: String? = nil,
        queryKey: String? = nil
    ) -> HomeCityGuideActionItem {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString: String
        if let path, let queryKey {
            urlString = "https://\(host)\(path)?\(queryKey)=\(encoded)"
        } else {
            urlString = "https://\(host)/maps/search/\(encoded)"
        }
        return HomeCityGuideActionItem(
            id: id,
            title: title,
            subtitle: subtitle ?? query,
            symbol: symbol,
            tint: tint,
            url: AppURL.make(urlString),
            destination: nil,
            provider: nil,
            cta: nil,
            externalLink: nil
        )
    }

    private func foodGuideAction(_ item: FoodGuideItem) -> HomeCityGuideActionItem {
        HomeCityGuideActionItem(
            id: item.id,
            title: item.title,
            subtitle: item.description,
            symbol: item.icon,
            tint: foodGuideTint(item.category),
            url: item.externalUrl,
            destination: nil,
            provider: item.source?.institution,
            cta: nil,
            externalLink: item.externalUrl.map {
                DashboardExternalLink(
                    id: "\(item.id)-external",
                    provider: .googleMaps,
                    title: item.title,
                    url: $0,
                    cityId: item.cityId,
                    audience: item.audience,
                    category: foodExternalCategory(item.category),
                    source: item.source?.title,
                    lastChecked: item.lastChecked
                )
            }
        )
    }

    private func foodExternalCategory(_ category: FoodGuideCategory) -> DashboardExternalLinkCategory {
        switch category {
        case .cafe, .breakfast:
            return .cafes
        case .restaurant, .localFood, .market, .vegetarian, .budget, .fineDining:
            return .restaurants
        }
    }

    private func foodGuideTint(_ category: FoodGuideCategory) -> Color {
        switch category {
        case .restaurant, .fineDining:
            return AppColors.dutchOrange
        case .cafe, .breakfast:
            return AppColors.warning
        case .localFood, .market:
            return AppColors.emerald
        case .vegetarian:
            return AppColors.success
        case .budget:
            return AppColors.softBlue
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            HomeUnifiedVisualBackdrop(asset: selectedHeroCityAsset, accent: AppColors.cyanGlow)

            ScrollViewReader { scrollProxy in
                ScrollView {
                    PremiumPageContainer(maxWidth: 920, horizontalPadding: AppSpacing.screenHorizontal, verticalPadding: 14) {
                        VStack(alignment: .leading, spacing: AppSpacing.large + 8) {
                            Color.clear
                                .frame(height: 0)
                                .id("homeTop")

                                homeTopChrome

                                productHomeHero

                                homePhotoGallerySection

                                productHomeStatus

                                // What to do now
                                // home.product.askAI
                                compactAISection

                                // Essentials
                                officialServicesSection

                                // Your city
                                placesToVisitHomeSection

                                housingHomeSection

                                transportHomeSection

                                leisureHomeSection

                                educationHomeSection

                                localPartnersHomeSection

                                discoverNetherlandsHomeSection

                                disclaimerFooter

                            Color.clear.frame(height: 1)
                        }
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 18)
                        .animation(.spring(response: 0.52, dampingFraction: 0.86).delay(0.10), value: contentVisible)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .safeAreaInset(edge: .top, spacing: 0) {
                    Color.clear.frame(height: AppSpacing.medium)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: homeBottomReserve)
                }
                .onReceive(router.homeScrollTop) { _ in
                    withAnimation(.easeInOut(duration: 0.24)) {
                        scrollProxy.scrollTo("homeTop", anchor: .top)
                    }
                }
            }
        }
        .coordinateSpace(name: "masterScroll")
        .appSceneBackground(.home)
        .nlNavigationBarHidden()
        .transaction { transaction in
            if Self.isUITesting {
                transaction.animation = nil
            }
        }
        .onAppear {
            dashboardTimestamp = Date()
            heroVisible = true
            contentVisible = true
        }
    }

    private var productHomeHero: some View {
        PremiumHeroSurface(
            title: productHomeTitle,
            subtitle: productHomeSubtitle,
            badge: "\(cityName) · \(homeWeatherSummary)",
            badgeSystemImage: "cloud.sun.fill",
            asset: selectedHeroCityAsset,
            language: lang,
            fallbackCategory: .city,
            accent: AppColors.cyanGlow,
            overlayPolicy: .balanced,
            height: dynamicTypeSize.isAccessibilitySize ? 520 : PremiumVisualMetrics.Hero.regularHeight,
            accessibilityIdentifier: "home.product.hero"
        )
    }

    private var heroJourneyCTA: some View {
        NavigationLink(value: AppDestination.profileSelection) {
            ProductStatusStrip(
                title: localizedText(en: "Who are you?", nl: "Wie bent u?", ru: "Кто вы?"),
                subtitle: localizedText(
                    en: "Choose your journey in the Netherlands.",
                    nl: "Kies uw route in Nederland.",
                    ru: "Выберите свой сценарий в Нидерландах."
                ),
                symbol: "person.crop.circle.badge.questionmark",
                accent: statusTint,
                actionTitle: localizedText(en: "Choose", nl: "Kies", ru: "Выбрать"),
                actionIdentifier: "home.hero.chooseJourney.action",
                prominence: .primary
            )
        }
        .buttonStyle(NLTileButtonStyle())
        .accessibilityIdentifier("home.hero.chooseJourney")
    }

    private var officialServicesSection: some View {
        homeContentSection(
            title: localizedText(en: "Official services", nl: "Officiële diensten", ru: "Государственные сервисы"),
            subtitle: localizedText(en: "Municipality, IND, DigiD, taxes, study finance, work support, healthcare, and emergency help.", nl: "Gemeente, IND, DigiD, belasting, studiefinanciering, werkhulp, zorg en noodhulp.", ru: "Gemeente, IND, DigiD, налоги, DUO, UWV, медицина и экстренная помощь."),
            viewAllDestination: .officialSources,
            items: officialServicesItems
        )
    }

    private var homePhotoGalleryItems: [HomePhotoGalleryItem] {
        [
            HomePhotoGalleryItem(
                id: "city",
                title: cityName,
                subtitle: localizedText(en: "City guide", nl: "Stadsgids", ru: "Гид по городу"),
                asset: selectedHeroCityAsset,
                fallbackCategory: .city,
                destination: .nlCityDetail(cityDashboard.routeCityId)
            ),
            HomePhotoGalleryItem(
                id: "places",
                title: localizedText(en: "Places", nl: "Plekken", ru: "Места"),
                subtitle: localizedText(en: "Museums, nature, food", nl: "Musea, natuur, eten", ru: "Музеи, природа, еда"),
                asset: ContentMediaRegistry.cultureWideHero ?? ContentMediaRegistry.dailyCultureImage,
                fallbackCategory: .map,
                destination: .homeExploreList("places")
            ),
            HomePhotoGalleryItem(
                id: "housing",
                title: localizedText(en: "Housing", nl: "Wonen", ru: "Жильё"),
                subtitle: localizedText(en: "Rent and address basics", nl: "Huur en adresbasis", ru: "Аренда и адрес"),
                asset: ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage,
                fallbackCategory: .housing,
                destination: .practicalGuide(.housingBasics)
            ),
            HomePhotoGalleryItem(
                id: "transport",
                title: localizedText(en: "Transport", nl: "Vervoer", ru: "Транспорт"),
                subtitle: localizedText(en: "OV, bikes, routes", nl: "OV, fiets, routes", ru: "OV, велосипед, маршруты"),
                asset: ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero,
                fallbackCategory: .transport,
                destination: .practicalGuide(.transportBasics)
            ),
            HomePhotoGalleryItem(
                id: "official",
                title: localizedText(en: "Official", nl: "Officieel", ru: "Официально"),
                subtitle: localizedText(en: "Sources and services", nl: "Bronnen en diensten", ru: "Источники и сервисы"),
                asset: ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.governmentBasicsImage,
                fallbackCategory: .government,
                destination: .officialSources
            )
        ]
    }

    private var homePhotoGallerySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            sectionTitle(
                localizedText(en: "Quick shortcuts", nl: "Snelle keuzes", ru: "Быстрые разделы"),
                subtitle: localizedText(
                    en: "City, places, housing, transport, and official services.",
                    nl: "Stad, plekken, wonen, vervoer en officiële diensten.",
                    ru: "Город, места, жильё, транспорт и официальные сервисы."
                )
            )

            ScrollView(.horizontal) {
                HStack(spacing: AppSpacing.small) {
                    ForEach(homePhotoGalleryItems) { item in
                        NavigationLink(value: item.destination) {
                            homePhotoGalleryCard(item)
                        }
                        .buttonStyle(AppPressableCardButtonStyle())
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 1)
                .padding(.top, 1)
                .padding(.bottom, AppSpacing.small)
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
        }
        .accessibilityIdentifier("home.photoGallery")
    }

    private var placesToVisitHomeSection: some View {
        homeContentSection(
            title: localizedText(en: "Places to visit", nl: "Plekken om te bezoeken", ru: "Куда сходить"),
            subtitle: localizedText(en: "Museums, nature, historic places, food, shopping, and events on the map.", nl: "Musea, natuur, historische plekken, eten, winkels en events op de kaart.", ru: "Музеи, природа, история, еда, покупки и события на карте."),
            viewAllDestination: .mapHub,
            items: placesToVisitItems
        )
    }

    private var housingHomeSection: some View {
        homeContentSection(
            title: localizedText(en: "Housing", nl: "Wonen", ru: "Жильё"),
            subtitle: localizedText(en: "Rent, buying, student housing, social housing, useful websites, and real-estate partners.", nl: "Huren, kopen, studentenwoningen, sociale huur, websites en makelaars.", ru: "Аренда, покупка, студенческое жильё, social housing, сайты и партнёры."),
            viewAllDestination: .practicalGuide(.housingBasics),
            items: housingItems
        )
    }

    private var transportHomeSection: some View {
        homeContentSection(
            title: localizedText(en: "Transport", nl: "Vervoer", ru: "Транспорт"),
            subtitle: localizedText(en: "Train, bus, metro, bikes, parking, airports, OV-chipkaart, and journey planning.", nl: "Trein, bus, metro, fiets, parkeren, luchthavens, OV-chipkaart en reisplanning.", ru: "Поезда, автобусы, метро, велосипед, парковка, аэропорты, OV-chipkaart и маршруты."),
            viewAllDestination: .practicalGuide(.transportBasics),
            items: transportItems
        )
    }

    private var leisureHomeSection: some View {
        homeContentSection(
            title: localizedText(en: "Leisure", nl: "Vrije tijd", ru: "Досуг"),
            subtitle: localizedText(en: "Nightlife, sport, local culture, family activities, and relaxed weekend ideas.", nl: "Nachtleven, sport, lokale cultuur, gezinsactiviteiten en rustige weekendideeen.", ru: "Вечерний досуг, спорт, локальная культура, семейные активности и идеи на выходные."),
            viewAllDestination: .cultureAttractions,
            items: leisureItems
        )
    }

    private var educationHomeSection: some View {
        homeContentSection(
            title: localizedText(en: "Education", nl: "Onderwijs", ru: "Образование"),
            subtitle: localizedText(en: "Universities, language schools, driving schools, DUO, and student benefits.", nl: "Universiteiten, taalscholen, rijscholen, DUO en studentenvoordelen.", ru: "Университеты, языковые школы, автошколы, DUO и студенческие льготы."),
            viewAllDestination: .institutionsList,
            items: educationItems
        )
    }

    private var localPartnersHomeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            sectionTitle(
                localizedText(en: "Local partners", nl: "Local partners", ru: "Local Partners"),
                subtitle: localizedText(en: "Top verified services. Sponsored listings are labeled inside partner pages.", nl: "Top geverifieerde diensten. Gesponsorde vermeldingen zijn gelabeld.", ru: "Топ проверенных сервисов. Sponsored карточки честно помечаются.")
            )
            HomeLocalPartnersSection(partners: visibleHomePartners, language: lang)
        }
        .accessibilityIdentifier("home.localPartners.focused")
    }

    private var discoverNetherlandsHomeSection: some View {
        homeContentSection(
            title: localizedText(en: "Discover Netherlands", nl: "Ontdek Nederland", ru: "Откройте Нидерланды"),
            subtitle: localizedText(en: "History, culture, traditions, interesting facts, and famous people.", nl: "Geschiedenis, cultuur, tradities, weetjes en bekende mensen.", ru: "История, культура, традиции, интересные факты и известные люди."),
            viewAllDestination: .discoverNetherlands,
            items: discoverNetherlandsItems
        )
    }

    private func homeContentSection(title: String, subtitle: String, viewAllDestination: AppDestination, items: [HomeExploreItem]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .lastTextBaseline) {
                sectionTitle(title, subtitle: subtitle)
                Spacer(minLength: 12)
                NavigationLink(value: viewAllDestination) {
                    Text(localizedText(en: "View all", nl: "Alles", ru: "Все"))
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColors.accent)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: AppSpacing.xSmall) {
                ForEach(items.prefix(3)) { item in
                    NavigationLink(value: item.destination) {
                        homeExploreCompactRow(item)
                    }
                    .buttonStyle(NLTileButtonStyle())
                }
            }

            if items.count > 3 {
                LazyVGrid(columns: homeCategoryChipColumns, alignment: .leading, spacing: 8) {
                    ForEach(Array(items.dropFirst(3))) { item in
                        NavigationLink(value: item.destination) {
                            homeExploreCategoryChip(item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .accessibilityIdentifier("home.categoryChips.\(sectionIdentifierFragment(title))")
            }
        }
    }

    private var homeCategoryChipColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 132), spacing: 8, alignment: .leading)]
    }

    private func homePhotoGalleryCard(_ item: HomePhotoGalleryItem) -> some View {
        ZStack(alignment: .bottomLeading) {
            PremiumImageView(
                asset: item.asset,
                language: lang,
                height: dynamicTypeSize.isAccessibilitySize ? 184 : 136,
                aspectRatio: nil,
                mode: .fill,
                cornerRadius: 18,
                overlayStyle: .none,
                fallbackCategory: item.fallbackCategory,
                accessibilityLabel: item.title,
                targetPixelWidth: 680,
                role: .thumbnail,
                overlayPolicy: .none,
                focalPoint: .center
            )
            .frame(width: dynamicTypeSize.isAccessibilitySize ? 276 : 214, height: dynamicTypeSize.isAccessibilitySize ? 184 : 136)
            .clipped()

            LinearGradient(
                colors: [Color.clear, AppColors.navyDeep.opacity(0.78)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(.white)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(0.82)
                Text(item.subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.white.opacity(0.82))
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(0.82)
            }
            .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? 14 : 12)
            .padding(.top, dynamicTypeSize.isAccessibilitySize ? 14 : 12)
            .padding(.bottom, dynamicTypeSize.isAccessibilitySize ? 22 : 20)
        }
        .frame(width: dynamicTypeSize.isAccessibilitySize ? 276 : 214, height: dynamicTypeSize.isAccessibilitySize ? 184 : 136)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.stroke.opacity(0.68), lineWidth: 0.8)
        )
        .accessibilityIdentifier("home.photoGallery.\(item.id)")
    }

    private var cityEmotionStrip: some View {
        let snapshot = checklistSnapshot

        return HomeCityEmotionStrip(
            cityTitle: cityName,
            citySubtitle: localizedText(en: "City map", nl: "Stadskaart", ru: "Карта города"),
            mapDestination: cityDashboard.mapFocus,
            statusTitle: statusTitle,
            statusSubtitle: localizedText(en: "Scenario", nl: "Scenario", ru: "Сценарий"),
            statusIcon: statusIcon,
            statusTint: statusTint,
            progressTitle: scenarioProgressValue(snapshot),
            progressSubtitle: localizedText(en: "Progress", nl: "Voortgang", ru: "Прогресс")
        )
    }

    private var productHomeStatus: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            NavigationLink(value: AppDestination.statusDirection(appState.selectedUserStatus ?? .tourist)) {
                ProductStatusStrip(
                    title: localizedText(en: "Who are you?", nl: "Wie bent u?", ru: "Кто вы?"),
                    subtitle: localizedText(
                        en: "\(homeStatusTitle) · \(cityName)",
                        nl: "\(homeStatusTitle) · \(cityName)",
                        ru: "\(homeStatusTitle) · \(cityName)"
                    ),
                    symbol: statusIcon,
                    accent: statusTint,
                    actionTitle: localizedText(en: "Open", nl: "Open", ru: "Открыть"),
                    actionIdentifier: "home.status.openJourney",
                    prominence: .primary
                )
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityIdentifier("home.statusCard")

            NavigationLink(value: AppDestination.profileSelection) {
                HStack(spacing: AppSpacing.small) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(statusTint)
                        .frame(width: 28, height: 28)
                        .background(statusTint.opacity(0.12), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    Text(localizedText(en: "Change profile or city", nl: "Wijzig profiel of stad", ru: "Изменить профиль или город"))
                        .font(AppTypography.footnoteStrong)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.textTertiary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppColors.glassSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(AppColors.stroke.opacity(0.65), lineWidth: 0.8))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.status.change")
        }
    }

    private func homeExploreCompactRow(_ item: HomeExploreItem) -> some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: item.symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(item.tint)
                .frame(width: 38, height: 38)
                .background(item.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Text(item.subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(AppColors.stroke.opacity(0.65), lineWidth: 0.8))
        .accessibilityIdentifier("home.compactRow.\(item.id)")
    }

    private func homeExploreCategoryChip(_ item: HomeExploreItem) -> some View {
        HStack(spacing: 7) {
            Image(systemName: item.symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(item.tint)
                .frame(width: 24, height: 24)
                .background(item.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(item.title)
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .padding(.leading, 8)
        .padding(.trailing, 10)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .background(AppColors.glassSurface, in: Capsule())
        .overlay(Capsule().stroke(AppColors.stroke.opacity(0.58), lineWidth: 0.8))
        .accessibilityIdentifier("home.categoryChip.\(item.id)")
    }

    private func sectionIdentifierFragment(_ title: String) -> String {
        title
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
    }

    private var whoAreYouSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            sectionTitle(
                localizedText(en: "Who are you?", nl: "Wie bent u?", ru: "Кто вы?"),
                subtitle: localizedText(
                    en: "Choose a profile to open your personal journey.",
                    nl: "Kies een profiel om uw persoonlijke route te openen.",
                    ru: "Выберите профиль, чтобы открыть персональный маршрут."
                )
            )

            NavigationLink(value: AppDestination.profileSelection) {
                ProductStatusStrip(
                    title: selectedScenarioTitle,
                    subtitle: whoAreYouSubtitle,
                    symbol: statusIcon,
                    accent: statusTint,
                    actionTitle: selectedAudience == nil ? workspaceChooseTitle : workspaceChangeTitle,
                    actionIdentifier: "home.whoAreYou.change",
                    prominence: .primary
                )
            }
            .buttonStyle(NLTileButtonStyle())
        }
        .accessibilityIdentifier("home.whoAreYou")
    }

    private var workspaceIntroSection: some View {
        NavigationLink(value: AppDestination.profileSelection) {
            ProductStatusStrip(
                title: workspaceIntroTitle,
                subtitle: workspaceIntroSubtitle,
                symbol: selectedAudience == nil ? "person.crop.circle.badge.questionmark" : statusIcon,
                accent: selectedAudience == nil ? AppColors.cyanGlow : statusTint,
                actionTitle: selectedAudience == nil ? workspaceChooseTitle : workspaceChangeTitle,
                actionIdentifier: "home.workspace.choose",
                prominence: selectedAudience == nil ? .primary : .quiet
            )
        }
        .buttonStyle(NLTileButtonStyle())
        .accessibilityIdentifier("home.workspaceIntro")
    }

    private var homeActionCommandCenter: some View {
        HomeActionCommandCenterSection(
            title: localizedText(en: "What you need now", nl: "Wat je nu nodig hebt", ru: "Что вам нужно сейчас"),
            subtitle: localizedText(
                en: "\(statusTitle) in \(cityName): start with this action, then use AI, search, or map only if it helps.",
                nl: "\(statusTitle) in \(cityName): begin met deze actie en gebruik AI, zoeken of kaart alleen als het helpt.",
                ru: "\(statusTitle) в \(cityName): начните с этого действия, а AI, поиск и карту используйте по необходимости."
            ),
            priority: localizedText(en: "Do first", nl: "Eerst doen", ru: "Сделать сначала"),
            continueDestination: continueDestination,
            continueTitle: continueTitle,
            continueSubtitle: continueSubtitle,
            continueIcon: continueIcon,
            nextStepLabel: localizedText(en: "Next step", nl: "Volgende stap", ru: "Следующий шаг"),
            continueCTA: localizedText(en: "Continue", nl: "Verder", ru: "Продолжить"),
            askTitle: localizedText(en: "Ask AI about this step", nl: "Vraag AI over deze stap", ru: "Спросить AI об этом шаге"),
            askSubtitle: localizedText(
                en: "Get a plain answer before you open the route.",
                nl: "Krijg eerst een duidelijk antwoord voordat je doorgaat.",
                ru: "Получите простой ответ перед переходом."
            ),
            askCTA: localizedText(en: "Ask", nl: "Vraag", ru: "Спросить"),
            onAskAI: { openAssistantPrompt(nextActionAIPrompt) }
        )
    }

    private var homeExploreCategoriesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            sectionTitle(
                localizedText(en: "Explore Netherlands", nl: "Verken Nederland", ru: "Исследуйте Нидерланды"),
                subtitle: localizedText(
                    en: "Cities, official services, places, housing, transport, study, food, and culture.",
                    nl: "Steden, officiële diensten, plekken, wonen, vervoer, studie, eten en cultuur.",
                    ru: "Города, госуслуги, места, жильё, транспорт, учёба, еда и культура."
                )
            )

            LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 360, minimumColumnWidth: 150), spacing: AppSpacing.small) {
                ForEach(homeExploreItems.prefix(6)) { item in
                    NavigationLink(value: item.destination) {
                        homeExploreVisualCard(item, minHeight: 168)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                }
            }
        }
        .accessibilityIdentifier("home.exploreNetherlands.grid")
    }

    private func homeExploreVisualCard(_ item: HomeExploreItem, minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            homeExploreCardImage(item)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)
                Text(item.subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .padding(12)
        .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColors.stroke.opacity(0.70), lineWidth: 0.8))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .clipped()
    }

    private func homeExploreCardImage(_ item: HomeExploreItem) -> some View {
        ZStack(alignment: .bottomLeading) {
            PremiumImageView(
                asset: homeExploreImage(for: item),
                language: lang,
                height: 86,
                aspectRatio: nil,
                mode: .fill,
                cornerRadius: 14,
                overlayStyle: .none,
                fallbackCategory: homeExploreFallbackCategory(for: item),
                accessibilityLabel: item.title,
                targetPixelWidth: 520,
                role: .thumbnail,
                overlayPolicy: .none,
                focalPoint: .center
            )
            .frame(height: 86)
            .frame(maxWidth: .infinity)
            .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.02), AppColors.navyDeep.opacity(0.52)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            Image(systemName: item.symbol)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(item.tint.opacity(0.92), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(10)
        }
        .frame(height: 86)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .clipped()
    }

    private func homeExploreImage(for item: HomeExploreItem) -> AppImageAsset? {
        switch item.id {
        case "cities", "cities-explore", "historic", "facts":
            return ContentMediaRegistry.homeAtmosphereHero ?? ContentMediaRegistry.leidenCanalsHero
        case "places", "places-map", "museums":
            return ContentMediaRegistry.cultureWideHero ?? ContentMediaRegistry.dailyCultureImage
        case "transport", "train", "bus", "metro", "planner":
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case "bike":
            return ContentMediaRegistry.transportHero ?? ContentMediaRegistry.transportStationHero
        case "healthcare", "healthcare-service":
            return ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.healthcarePharmacyImage
        case "government", "municipality", "ind", "belastingdienst", "duo", "duo-education":
            return ContentMediaRegistry.governmentBasicsImage ?? ContentMediaRegistry.officialSourcesHero
        case "digid", "official", "student-benefits":
            return ContentMediaRegistry.digidImage ?? ContentMediaRegistry.officialSourcesHero
        case "housing", "rent", "buy", "student-housing", "social-housing", "housing-tips", "real-estate":
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case "restaurants", "cafes", "food":
            return ContentMediaRegistry.foodImage ?? ContentMediaRegistry.leidenCanalsHero
        case "nature", "parks", "weekend":
            return ContentMediaRegistry.natureImage ?? ContentMediaRegistry.cultureWideHero
        case "nightlife":
            return ContentMediaRegistry.foodImage ?? ContentMediaRegistry.cultureWideHero ?? ContentMediaRegistry.homeAtmosphereHero
        case "family-activities", "free-activities":
            return ContentMediaRegistry.natureImage ?? ContentMediaRegistry.homeAtmosphereHero ?? ContentMediaRegistry.cultureWideHero
        case "events", "festivals", "traditions":
            return ContentMediaRegistry.calendarImage ?? ContentMediaRegistry.cultureWideHero
        case "shopping":
            return ContentMediaRegistry.foodImage ?? ContentMediaRegistry.homeAtmosphereHero
        case "emergency":
            return ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.healthcareBasicsImage
        case "universities", "language-schools", "education":
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.officialSourcesHero
        case "driving-schools", "parking":
            return ContentMediaRegistry.transportHero ?? ContentMediaRegistry.transportStationHero
        case "sports":
            return ContentMediaRegistry.natureImage ?? ContentMediaRegistry.mapImage
        case "culture", "history", "people":
            return ContentMediaRegistry.cultureWideHero ?? ContentMediaRegistry.dailyCultureImage
        default:
            return ContentMediaRegistry.mapImage ?? ContentMediaRegistry.homeAtmosphereHero
        }
    }

    private func homeExploreFallbackCategory(for item: HomeExploreItem) -> PremiumImageFallbackCategory {
        switch item.destination {
        case .governmentHub, .officialSources, .institutionsList:
            return .government
        case .emergencyHub:
            return .emergency
        case .practicalGuide(let section):
            switch section {
            case .housingBasics: return .housing
            case .transportBasics: return .transport
            case .healthcareBasics: return .healthcare
            default: return .city
            }
        case .localPartners:
            return .work
        case .mapHub, .mapFocus:
            return .map
        case .cultureAttractions, .discoverNetherlands, .netherlandsHistory, .netherlandsCalendar, .dutchFigures, .netherlandsOverview:
            return .city
        default:
            return .city
        }
    }

    private var compactAISection: some View {
        Button {
            openAssistantPrompt(audienceAIPrompt)
        } label: {
            ProductStatusStrip(
                title: localizedText(en: "Need help?", nl: "Hulp nodig?", ru: "Нужна помощь?"),
                subtitle: localizedText(
                    en: "Ask AI about cities, places, services, or your next route.",
                    nl: "Vraag AI over steden, plekken, diensten of uw volgende route.",
                    ru: "Спросите AI о городах, местах, сервисах или следующем маршруте."
                ),
                symbol: "sparkles",
                accent: AppColors.violet,
                actionTitle: localizedText(en: "Ask AI", nl: "Vraag AI", ru: "Спросить AI"),
                actionIdentifier: "home.ai.compact.action",
                prominence: .quiet
            )
        }
        .buttonStyle(NLTileButtonStyle())
        .accessibilityIdentifier("home.ai.compact")
    }

    private var lifeTimelinePreviewSection: some View {
        HomeLifeTimelinePreviewSection(
            title: localizedText(en: "Life timeline", nl: "Levenslijn", ru: "Жизненный маршрут"),
            subtitle: localizedText(
                en: "Your Netherlands path as practical steps with documents, sources, and due dates.",
                nl: "Je Nederland-route als praktische stappen met documenten, bronnen en datums.",
                ru: "Ваш путь в Нидерландах как практические шаги с документами, источниками и датами."
            ),
            priority: localizedText(en: "Progress", nl: "Voortgang", ru: "Прогресс"),
            steps: lifeTimelineSteps,
            language: lang,
            openSourceTitle: localizedText(en: "Source", nl: "Bron", ru: "Источник"),
            askAITitle: localizedText(en: "Ask AI", nl: "Vraag AI", ru: "AI"),
            onOpenSource: { url in
                if let safeURL = AppURL.validatedWebURL(url) {
                    openURL(safeURL)
                }
            },
            onAskAI: { prompt in openAssistantPrompt(prompt) }
        )
    }

    private var smartChecklistPreviewSection: some View {
        HomeChecklistPreviewSection(
            title: localizedText(en: "Smart checklist", nl: "Slimme checklist", ru: "Умный checklist"),
            subtitle: localizedText(
                en: "\(statusTitle) in \(cityName): focused items saved locally on this device.",
                nl: "\(statusTitle) in \(cityName): gerichte items lokaal op dit toestel.",
                ru: "\(statusTitle) в \(cityName): нужные пункты сохраняются локально на устройстве."
            ),
            priority: localizedText(en: "Do next", nl: "Nu doen", ru: "Дальше"),
            items: smartChecklistItems,
            language: lang,
            openTitle: localizedText(en: "Open checklist", nl: "Open checklist", ru: "Открыть checklist"),
            sourceTitle: localizedText(en: "Source", nl: "Bron", ru: "Источник"),
            askTitle: localizedText(en: "Ask AI", nl: "Vraag AI", ru: "AI"),
            addDeadlineTitle: localizedText(en: "Deadline", nl: "Deadline", ru: "Дедлайн"),
            onToggle: { item in appState.toggleChecklistItem(item) },
            onOpenSource: { url in
                if let safeURL = AppURL.validatedWebURL(url) {
                    openURL(safeURL)
                }
            },
            onAskAI: { item in openAssistantPrompt(checklistAIPrompt(for: item)) },
            onAddDeadline: { item in openAssistantPrompt(deadlineAIPrompt(for: item)) }
        )
    }

    private var documentsDeadlinesPreviewSection: some View {
        HomeDocumentsDeadlinesSection(
            title: localizedText(en: "Documents & deadlines", nl: "Documenten en deadlines", ru: "Документы и дедлайны"),
            subtitle: localizedText(
                en: "Documents stay on this device with Apple file protection; reminders use local dates.",
                nl: "Documenten blijven op dit toestel met Apple-bestandsbeveiliging; reminders gebruiken lokale datums.",
                ru: "Документы остаются на устройстве под защитой Apple; напоминания используют локальные даты."
            ),
            priority: localizedText(en: "Local only", nl: "Alleen lokaal", ru: "Локально"),
            documentCategories: suggestedDocumentCategories,
            deadlines: upcomingDeadlines,
            savedDocumentCount: documentStore.items.count,
            language: lang,
            openDocumentsTitle: localizedText(en: "Open vault", nl: "Open kluis", ru: "Открыть"),
            openDeadlinesTitle: localizedText(en: "Open dates", nl: "Open datums", ru: "Открыть даты"),
            askTitle: localizedText(en: "Ask AI", nl: "Vraag AI", ru: "Спросить AI"),
            onAskDeadline: { reminder in openAssistantPrompt(deadlineAIPrompt(for: reminder)) }
        )
    }

    private var exploreNetherlandsSection: some View {
        HomeExploreNetherlandsSection(
            title: localizedText(en: "Explore Netherlands", nl: "Verken Nederland", ru: "Исследуйте Нидерланды"),
            subtitle: localizedText(
                en: "Culture and history live here, below the practical flow.",
                nl: "Cultuur en geschiedenis staan hier, onder de praktische route.",
                ru: "История и культура здесь, ниже практического сценария."
            ),
            priority: localizedText(en: "Discover", nl: "Ontdek", ru: "Discover"),
            language: lang
        )
    }

    private var businessPartnerPromoSection: some View {
        NavigationLink(value: AppDestination.businessLogin) {
            HomeBusinessPartnerPromoCard(language: lang)
        }
        .buttonStyle(AppPressableCardButtonStyle())
        .accessibilityIdentifier("home.businessPartnerPromo")
    }

    private var homeLocalPartnersSection: some View {
        HomeLocalPartnersSection(partners: visibleHomePartners, language: lang)
    }

    private var personalDashboardSection: some View {
        HomePersonalDashboardSection(
            title: localizedText(en: "Your scenario tools", nl: "Tools voor je scenario", ru: "Инструменты сценария"),
            subtitle: localizedText(
                en: "Use these only when the next step needs an explanation, a source, or a place.",
                nl: "Gebruik dit alleen wanneer de volgende stap uitleg, bron of plek nodig heeft.",
                ru: "Используйте их, когда следующему шагу нужны объяснение, источник или место."
            ),
            priority: localizedText(en: "Support", nl: "Hulp", ru: "Поддержка"),
            aiTitle: localizedText(en: "AI explains next", nl: "AI legt volgende stap uit", ru: "AI объяснит следующий шаг"),
            aiSubtitle: continueTitle,
            aiCTA: localizedText(en: "Ask AI", nl: "Vraag AI", ru: "Спросить"),
            searchTitle: localizedText(en: "Search in context", nl: "Zoek in context", ru: "Поиск в контексте"),
            searchSubtitle: localizedText(
                en: "\(statusTitle) in \(cityName)",
                nl: "\(statusTitle) in \(cityName)",
                ru: "\(statusTitle) в \(cityName)"
            ),
            searchCTA: localizedText(en: "Search", nl: "Zoek", ru: "Искать"),
            mapDestination: cityDashboard.mapFocus,
            mapTitle: localizedText(en: "Open city map", nl: "Open stadskaart", ru: "Открыть карту города"),
            mapSubtitle: localizedText(
                en: "Places for this step",
                nl: "Plekken voor deze stap",
                ru: "Места для этого шага"
            ),
            mapCTA: localizedText(en: "Map", nl: "Kaart", ru: "Карта"),
            onAskAI: { openAssistantPrompt(nextActionAIPrompt) },
            onSearch: { selectedTab = .places }
        ) {
            scenarioProgressCard
        }
    }

    private var scenarioProgressCard: some View {
        let snapshot = checklistSnapshot

        return HomeScenarioProgressCard(
            title: activePathProfile.localizedTitle.value(lang),
            summary: scenarioProgressSummary(snapshot),
            value: scenarioProgressValue(snapshot),
            progress: snapshot.progress,
            symbol: statusIcon,
            accent: statusTint
        )
    }

    private func contextualRecommendationsSection(_ recommendations: [HomeCityGuideActionItem]) -> some View {
        HomeContextualRecommendationsSection(
            title: localizedText(en: "More useful actions", nl: "Meer nuttige acties", ru: "Ещё полезные действия"),
            subtitle: localizedText(
                en: "Secondary shortcuts for the same scenario.",
                nl: "Secundaire snelkoppelingen voor hetzelfde scenario.",
                ru: "Вторичные действия для того же сценария."
            ),
            accessibilityLabel: localizedText(en: "Recommended actions", nl: "Aanbevolen acties", ru: "Рекомендуемые действия"),
            recommendations: recommendations
        ) { action in
            productActionLink(action)
        }
    }

    private var cityMapShortcutSection: some View {
        HomeCityMapShortcutSection(
            title: localizedText(en: "Places for this step", nl: "Plekken voor deze stap", ru: "Места для этого шага"),
            subtitle: localizedText(
                en: "Open the map only when the action depends on location.",
                nl: "Open de kaart alleen wanneer de actie van locatie afhangt.",
                ru: "Открывайте карту, когда действие зависит от места."
            ),
            destination: cityDashboard.mapFocus,
            cardTitle: localizedText(en: "\(cityName) map", nl: "Kaart van \(cityName)", ru: "Карта \(cityName)"),
            cardSubtitle: cityDashboard.aiSummary,
            cta: localizedText(en: "Open map", nl: "Open kaart", ru: "Открыть карту")
        )
    }

    private var productHomeTitle: String {
        cityName
    }

    private var productHomeSubtitle: String {
        localizedText(
            en: "Services, places, housing, transport, study, food, and local life.",
            nl: "Diensten, plekken, wonen, vervoer, studie, eten en lokaal leven.",
            ru: "Сервисы, места, жильё, транспорт, учёба, еда и местная жизнь."
        )
    }

    private var homeWeatherSummary: String {
        localizedText(en: "Check forecast", nl: "Bekijk weer", ru: "Погода")
    }

    @ViewBuilder
    private func productActionLink(_ action: HomeCityGuideActionItem) -> some View {
        if let destination = action.destination {
            NavigationLink(value: destination) {
                productActionCard(action)
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityIdentifier("home.product.action.\(action.id)")
        } else if let url = action.url {
            Button {
                if let safeURL = AppURL.validatedWebURL(action.externalLink?.url ?? url) {
                    openURL(safeURL)
                }
            } label: {
                productActionCard(action)
            }
            .buttonStyle(NLTileButtonStyle())
            .accessibilityIdentifier("home.product.action.external.\(action.id)")
        }
    }

    private func productActionCard(_ action: HomeCityGuideActionItem) -> some View {
        ProductTaskCard(
            title: action.title,
            subtitle: action.subtitle,
            symbol: action.symbol,
            accent: action.tint,
            cta: productActionCTA(action),
            minHeight: 96,
            prominence: .quiet
        )
    }

    private func productActionCTA(_ action: HomeCityGuideActionItem) -> String {
        if let cta = action.cta {
            return cta
        }
        if action.id.contains("places") {
            return localizedText(en: "Open map", nl: "Open kaart", ru: "Открыть карту")
        }
        if action.url != nil {
            return localizedText(en: "Search", nl: "Zoek", ru: "Искать")
        }
        return localizedText(en: "Open guide", nl: "Open gids", ru: "Открыть гид")
    }

    // MARK: - Home Story

    private var homeTopChrome: some View {
        HomeTopChromeBar(
            title: "YouNew.nl",
            tagline: localizedText(en: "Netherlands guide", nl: "Gids voor Nederland", ru: "Гид по Нидерландам"),
            menuAccessibilityLabel: L10n.t("accessibility.openMenu", lang),
            style: .standard,
            onOpenMenu: onOpenMenu
        )
    }

    private var cityCompactOverviewSection: some View {
        HomeCityCompactOverviewCard(
            destination: AppDestination.nlCityDetail(cityDashboard.routeCityId),
            asset: selectedHeroCityAsset,
            language: lang,
            cityName: ProvinceCatalog.localizedCityName(cityDashboard.cityName, lang),
            provinceName: localizedProvinceName(cityDashboard.province),
            cta: localizedText(en: "Open city guide", nl: "Open stadsgids", ru: "Открыть гид по городу")
        )
    }

    private var statusTitle: String {
        appState.selectedUserStatus?.localized(lang)
            ?? localizedText(en: "Tourist", nl: "Toerist", ru: "Турист")
    }

    private var homeStatusTitle: String {
        switch appState.selectedUserStatus {
        case .tourist:
            return localizedText(en: "Tourist", nl: "Toerist", ru: "Турист")
        case .refugee:
            return localizedText(en: "Status holder", nl: "Statushouder", ru: "Статус")
        case .ukrainian:
            return localizedText(en: "Temporary protection", nl: "Tijdelijke bescherming", ru: "Защита")
        case .highlySkilledMigrant:
            return localizedText(en: "Skilled migrant", nl: "Kennismigrant", ru: "Специалист")
        case .lgbtNewcomer:
            return localizedText(en: "LGBTQ+ newcomer", nl: "LGBTQ+ nieuwkomer", ru: "LGBTQ+")
        default:
            return statusTitle
        }
    }

    private var statusIcon: String {
        appState.selectedUserStatus?.icon ?? "suitcase.rolling.fill"
    }

    private var statusTint: Color {
        switch appState.selectedUserStatus {
        case .tourist, nil:
            return AppColors.cyanGlow
        case .refugee, .ukrainian:
            return AppColors.softBlue
        case .student:
            return AppColors.emerald
        case .entrepreneur:
            return AppColors.warning
        case .lgbtNewcomer:
            return AppColors.violet
        default:
            return AppColors.dutchOrange
        }
    }

    private var activePathProfile: UserPathProfile {
        UserPathProfiles.profile(for: appState.selectedUserStatus ?? .tourist)
    }

    private var nextPathStep: PathStep? {
        activePathProfile.nextSteps(limit: 1).first
    }

    private func scenarioProgressValue(_ snapshot: HomeChecklistSnapshot) -> String {
        guard snapshot.totalCount > 0 else { return "0%" }
        return "\(Int((snapshot.progress * 100).rounded()))%"
    }

    private func scenarioProgressSummary(_ snapshot: HomeChecklistSnapshot) -> String {
        switch lang {
        case .russian:
            return "\(snapshot.completedCount) из \(snapshot.totalCount) шагов закрыто. Следующее: \(continueTitle)."
        case .dutch:
            return "\(snapshot.completedCount) van \(snapshot.totalCount) stappen klaar. Volgende: \(continueTitle)."
        case .english:
            return "\(snapshot.completedCount) of \(snapshot.totalCount) steps done. Next: \(continueTitle)."
        }
    }

    private var nextActionAIPrompt: String {
        switch lang {
        case .russian:
            return "Мой текущий сценарий: \(activePathProfile.localizedTitle.value(lang)). Город: \(cityName). Следующий шаг: \(continueTitle). Объясни, что сделать дальше, где искать на карте и что проверить через поиск. Кратко, по пунктам, с официальными источниками."
        case .dutch:
            return "Mijn huidige route: \(activePathProfile.localizedTitle.value(lang)). Stad: \(cityName). Volgende stap: \(continueTitle). Leg uit wat ik nu doe, waar ik op de kaart kijk en wat ik via zoeken controleer. Kort, in stappen, met officiële bronnen."
        case .english:
            return "My current scenario is \(activePathProfile.localizedTitle.value(lang)). City: \(cityName). Next step: \(continueTitle). Explain what to do next, where to look on the map, and what to verify through search. Keep it brief, step by step, with official sources."
        }
    }

    private var continueDestination: AppDestination {
        nextPathStep?.destination ?? cityDashboard.mapFocus
    }

    private var continueIcon: String {
        nextPathStep?.icon ?? "arrow.right.circle.fill"
    }

    private var continueTitle: String {
        if let nextPathStep {
            return nextPathStep.localizedTitle.value(lang)
        }

        switch audienceDashboardMode {
        case .tourist:
            return localizedText(en: "Continue exploring \(cityDashboard.cityName)", nl: "Verken \(cityDashboard.cityName) verder", ru: "Продолжить знакомство с \(cityDashboard.cityName)")
        case .refugee:
            return localizedText(en: "Continue integration", nl: "Ga verder met integratie", ru: "Продолжить интеграцию")
        case .student:
            return localizedText(en: "Continue student setup", nl: "Ga verder met studentenstart", ru: "Продолжить путь студента")
        case .business:
            return localizedText(en: "Continue business planning", nl: "Ga verder met zakelijke planning", ru: "Продолжить бизнес-планирование")
        case .general, .local:
            return localizedText(en: "Continue your Netherlands path", nl: "Ga verder met je Nederland-route", ru: "Продолжить путь в Нидерландах")
        }
    }

    private var continueSubtitle: String {
        nextPathStep?.localizedDescription.value(lang)
            ?? localizedText(en: "Pick up where your current city and status matter most.", nl: "Ga verder waar je stad en status het belangrijkst zijn.", ru: "Продолжайте с того шага, где важны ваш город и статус.")
    }

    private var releaseQuickActions: [HomeCityGuideActionItem] {
        switch audienceDashboardMode {
        case .tourist:
            return [
                routeAction(id: "release-emergency", title: quickActionTitle(.emergency), subtitle: quickActionSubtitle(.emergency), symbol: "phone.fill", tint: AppColors.error, destination: .emergencyHub),
                routeAction(id: "release-transport", title: quickActionTitle(.transport), subtitle: quickActionSubtitle(.transport), symbol: "tram.fill", tint: AppColors.emerald, destination: .practicalGuide(.transportBasics)),
                HomeCityGuideActionItem(id: "release-places", title: quickActionTitle(.places), subtitle: quickActionSubtitle(.places), symbol: "mappin.and.ellipse", tint: AppColors.cyanGlow, url: nil, destination: cityDashboard.mapFocus, provider: nil, cta: nil, externalLink: nil),
                HomeCityGuideActionItem(id: "release-ai", title: quickActionTitle(.aiAssistant), subtitle: quickActionSubtitle(.aiAssistant), symbol: "sparkles", tint: AppColors.violet, url: nil, destination: .assistantHub, provider: nil, cta: nil, externalLink: nil)
            ]
        case .refugee:
            return [
                routeAction(id: "release-emergency", title: quickActionTitle(.emergency), subtitle: quickActionSubtitle(.emergency), symbol: "phone.fill", tint: AppColors.error, destination: .emergencyHub),
                routeAction(id: "release-documents", title: quickActionTitle(.documentsGovernment), subtitle: quickActionSubtitle(.documentsGovernment), symbol: "doc.text.fill", tint: AppColors.softBlue, destination: .journeyDocuments),
                routeAction(id: "release-transport", title: quickActionTitle(.transport), subtitle: quickActionSubtitle(.transport), symbol: "tram.fill", tint: AppColors.emerald, destination: .practicalGuide(.transportBasics)),
                HomeCityGuideActionItem(id: "release-ai", title: quickActionTitle(.aiAssistant), subtitle: quickActionSubtitle(.aiAssistant), symbol: "sparkles", tint: AppColors.violet, url: nil, destination: .assistantHub, provider: nil, cta: nil, externalLink: nil)
            ]
        case .student:
            return [
                routeAction(id: "release-transport", title: quickActionTitle(.transport), subtitle: quickActionSubtitle(.transport), symbol: "tram.fill", tint: AppColors.emerald, destination: .practicalGuide(.transportBasics)),
                routeAction(id: "release-housing", title: quickActionTitle(.housing), subtitle: quickActionSubtitle(.housing), symbol: "house.fill", tint: AppColors.violet, destination: .practicalGuide(.housingBasics)),
                HomeCityGuideActionItem(id: "release-places", title: quickActionTitle(.places), subtitle: quickActionSubtitle(.places), symbol: "mappin.and.ellipse", tint: AppColors.cyanGlow, url: nil, destination: cityDashboard.mapFocus, provider: nil, cta: nil, externalLink: nil),
                HomeCityGuideActionItem(id: "release-ai", title: quickActionTitle(.aiAssistant), subtitle: quickActionSubtitle(.aiAssistant), symbol: "sparkles", tint: AppColors.violet, url: nil, destination: .assistantHub, provider: nil, cta: nil, externalLink: nil)
            ]
        default:
            return [
                routeAction(id: "release-emergency", title: quickActionTitle(.emergency), subtitle: quickActionSubtitle(.emergency), symbol: "phone.fill", tint: AppColors.error, destination: .emergencyHub),
                routeAction(id: "release-transport", title: quickActionTitle(.transport), subtitle: quickActionSubtitle(.transport), symbol: "tram.fill", tint: AppColors.emerald, destination: .practicalGuide(.transportBasics)),
                routeAction(id: "release-documents", title: quickActionTitle(.documentsGovernment), subtitle: quickActionSubtitle(.documentsGovernment), symbol: "doc.text.fill", tint: AppColors.softBlue, destination: .journeyDocuments),
                HomeCityGuideActionItem(id: "release-ai", title: quickActionTitle(.aiAssistant), subtitle: quickActionSubtitle(.aiAssistant), symbol: "sparkles", tint: AppColors.violet, url: nil, destination: .assistantHub, provider: nil, cta: nil, externalLink: nil)
            ]
        }
    }

    private var contextualRecommendationsSnapshot: HomeContextualRecommendationsSnapshot {
        HomeContextualRecommendationsSnapshot(actions: releaseQuickActions)
    }

    private func quickActionTitle(_ section: IASection) -> String {
        section.title(lang)
    }

    private func quickActionSubtitle(_ section: IASection) -> String {
        switch (section, lang) {
        case (.emergency, .english): return "112 and urgent help"
        case (.emergency, .dutch): return "112 en spoedhulp"
        case (.emergency, .russian): return "112 и срочная помощь"
        case (.transport, .english): return "OV, bikes, routes"
        case (.transport, .dutch): return "OV, fiets, routes"
        case (.transport, .russian): return "OV, велосипед, маршруты"
        case (.places, .english): return "Nearby city places"
        case (.places, .dutch): return "Plekken in de stad"
        case (.places, .russian): return "Места рядом"
        case (.aiAssistant, .english): return "Ask about your next step"
        case (.aiAssistant, .dutch): return "Vraag naar je volgende stap"
        case (.aiAssistant, .russian): return "Спросить о следующем шаге"
        case (.documentsGovernment, .english): return "BSN, DigiD, letters"
        case (.documentsGovernment, .dutch): return "BSN, DigiD, brieven"
        case (.documentsGovernment, .russian): return "BSN, DigiD, письма"
        case (.housing, .english): return "Housing and address"
        case (.housing, .dutch): return "Wonen en adres"
        case (.housing, .russian): return "Жильё и адрес"
        default: return localizedText(en: "Open this section", nl: "Open dit onderdeel", ru: "Открыть раздел")
        }
    }

    private func welcomeHeroSection(viewportHeight: CGFloat) -> some View {
        let heroHeight = dynamicTypeSize.isAccessibilitySize
            ? max(640, viewportHeight * 0.86)
            : max(560, viewportHeight * 0.82)

        return ZStack(alignment: .bottomLeading) {
            // Parallax image: lags behind scroll for depth perception.
            ParallaxHero {
                homeHeroImage(height: heroHeight)
            }
            .frame(height: heroHeight)
            .clipped()
            .animation(.easeInOut(duration: 0.28), value: cityDashboard.cityId)

            // Seamless gradient: end color exactly matches AppSurface.base.
            AppSurface.heroGradient()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.40),
                    Color.clear,
                    AppSurface.base.opacity(0.96)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    AppColors.cyanGlow.opacity(0.20),
                    Color.clear,
                    AppColors.dutchOrange.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack {
                HomeTopChromeBar(
                    title: "YouNew.nl",
                    tagline: localizedText(en: "Premium Netherlands Guide", nl: "Premium gids voor Nederland", ru: "Премиальный гид по Нидерландам"),
                    menuAccessibilityLabel: L10n.t("accessibility.openMenu", lang),
                    style: .hero,
                    onOpenMenu: onOpenMenu
                )
                .padding(.horizontal, 22)
                .padding(.top, 18)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 14) {
                HomeHeroCityPagerDots(count: citySwitcherNames.count, selectedIndex: selectedCityIndex)

                Text(localizedProvinceName(cityDashboard.province))
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(AppColors.cyanGlow)
                    .textCase(.uppercase)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                Text(ProvinceCatalog.localizedCityName(cityDashboard.cityName, lang))
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 44 : AppTypography.Scale.hero, weight: .semibold, design: .default))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 390, alignment: .leading)
                    .shadow(color: Color.black.opacity(0.34), radius: 12, x: 0, y: 5)

                if let kw = selectedHeroCity?.keywords(lang: lang) {
                    Text(kw)
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 17 : 13.5, weight: .semibold, design: .default))
                        .foregroundStyle(AppColors.cyanGlow.opacity(0.92))
                        .lineLimit(2)
                        .frame(maxWidth: 520, alignment: .leading)
                } else {
                    Text(cityDescription)
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 18 : 14.5, weight: .regular, design: .default))
                        .foregroundStyle(Color.white.opacity(0.84))
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 5 : 4)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 520, alignment: .leading)
                }

                HomeHeroCityStats(stats: cityDashboard.stats)

                heroQuickIntelligence

                HomeHeroCityActions(
                    destination: AppDestination.nlCityDetail(cityDashboard.routeCityId),
                    exploreTitle: exploreCityTitle,
                    savedTitle: savedToolTitle,
                    onOpenSaved: { selectedTab = .favorites }
                )
            }
            .padding(.horizontal, 22)
            .padding(.bottom, dynamicTypeSize.isAccessibilitySize ? 58 : 52)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: heroHeight, alignment: .bottomLeading)
        .accessibilityIdentifier("home.hero.netherlands")
    }

    @ViewBuilder
    private func homeHeroImage(height: CGFloat) -> some View {
        let city = cityDashboard.city
        let heroImage = sanitizedHeroImage(city.heroImage)
        let placeId = CuratedPlaceHeroMediaRegistry.cityPlaceId(cityName: city.name, provinceName: city.province)

        Group {
            if let heroImage {
                CityImageView(
                    urlString: heroImage,
                    height: height,
                    placeId: placeId,
                    cityName: city.name,
                    fallbackColor: homeHeroFallbackColor(for: city),
                        fallbackURLStrings: [],
                        debugContext: ImageDebugContext(
                            screen: "Home hero",
                            entityType: "city",
                            entityName: city.name,
                            requestedURL: heroImage,
                            fallbackLevel: "city-dashboard-hero",
                            sourceRegistry: "CityDashboardContentData",
                            modelID: placeId
                    ),
                    renderRole: .hero
                )
            } else {
                homeCityFallbackHero(city: city, height: height)
            }
        }
            .id("city-hero-\(city.id.rawValue)-\(heroImage ?? "fallback")")
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.28), value: cityDashboard.cityId)
            .onAppear {
                LaunchDiagnostics.mark("images loaded/scheduled cityHero=\(city.name)")
            }
    }

    private func sanitizedHeroImage(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    private func homeHeroFallbackColor(for city: DashboardCity) -> Color {
        switch city.id {
        case .amsterdam: return Color(hex: "#1A3040")
        case .rotterdam: return Color(hex: "#1A2A3A")
        case .denHaag: return Color(hex: "#1A2838")
        case .leiden: return Color(hex: "#1A3040")
        case .utrecht: return Color(hex: "#24304A")
        case .eindhoven: return Color(hex: "#2E2B44")
        case .maastricht: return Color(hex: "#302A3D")
        case .groningen: return Color(hex: "#17303A")
        }
    }

    private func homeCityFallbackHero(city: DashboardCity, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    AppColors.navyDeep.opacity(0.98),
                    AppColors.cyanGlow.opacity(0.26),
                    AppColors.dutchOrange.opacity(0.18),
                    AppColors.graphite.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            DutchFlagRibbon(opacity: 0.12)
            AbstractCanalLines(color: AppColors.cyanGlow, lineCount: 4)
                .opacity(0.22)

            VStack(alignment: .leading, spacing: 6) {
                Text(city.name)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(city.province)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.cyanGlow)
                    .lineLimit(1)
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .clipped()
    }

    private var heroQuickIntelligence: some View {
        HomeHeroQuickIntelligenceGrid(
            emergencyTitle: "112",
            emergencySubtitle: localizedText(en: "Emergency", nl: "Noodgeval", ru: "Экстренно"),
            emergencyDestination: AppDestination.emergencyHub,
            weatherTitle: localizedText(en: "Weather", nl: "Weer", ru: "Погода"),
            weatherSubtitle: localizedText(en: "Check official forecast", nl: "Controleer officiële verwachting", ru: "Проверьте официальный прогноз"),
            // home.hero.shortcut.ai
            aiTitle: askAITitle,
            aiSubtitle: localizedText(en: "Ask about this city", nl: "Vraag over deze stad", ru: "Спросить о городе"),
            onOpenWeather: { openURL(AppURL.make("https://www.knmi.nl/nederland-nu/weer/verwachtingen")) },
            onOpenAI: { openAssistantPrompt(audienceAIPrompt) }
        )
    }

    private func heroIntelligenceTile() -> some View {
        EmptyView()
    }

    private var cityPillsSection: some View {
        HomeCityPillsSection(
            cities: citySwitcherNames,
            selectedIndex: selectedCityIndex,
            language: lang,
            onSelectCity: selectCityPill
        )
    }

    private func selectCityPill(_ city: String) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            appState.selectedCity = city
            selectedPlaceFilter = nil
        }
    }

    @ViewBuilder
    private var mainTravelActionsSection: some View {
        let actions = mainTravelActions

        HomeTravelActionGridSection(
            title: isStayPlanningMode ? "Plan your stay" : localizedText(en: "What to do now", nl: "Wat nu te doen", ru: "Что сделать сейчас"),
            subtitle: isStayPlanningMode
                ? "Hotels, food, places, and transport in \(cityDashboard.cityName)"
                : localizedText(en: "Food, places, transport, and urgent help in \(cityDashboard.cityName)", nl: "Eten, plekken, vervoer en spoedhulp in \(cityDashboard.cityName)", ru: "Еда, места, транспорт и срочная помощь в \(cityDashboard.cityName)"),
            actions: actions,
            bottomPadding: 28,
            accessibilityIdentifier: "home.mainTravelActions",
            showsExternalDisclaimer: actions.contains(where: { $0.externalLink?.provider == .booking })
        ) { action in
            cityGuideActionButton(action)
        }
    }

    @ViewBuilder
    private var foodDrinksGuideSection: some View {
        let actions = foodDrinkActions

        HomeTravelActionGridSection(
            title: isStayPlanningMode ? "Where to eat" : localizedText(en: "Food & drinks", nl: "Eten & drinken", ru: "Еда и напитки"),
            subtitle: isStayPlanningMode
                ? "Find good places to eat in \(cityDashboard.cityName)"
                : localizedText(en: "Restaurants, cafes, markets, and local spots", nl: "Restaurants, cafés, markten en lokale plekken", ru: "Рестораны, кафе, рынки и локальные места"),
            actions: actions,
            bottomPadding: 34,
            accessibilityIdentifier: "home.foodDrinksGuide",
            showsExternalDisclaimer: false
        ) { action in
            cityGuideActionButton(action)
        }
    }

    @ViewBuilder
    private var stayInThisCitySection: some View {
        let actions = stayActions

        HomeTravelActionGridSection(
            title: localizedText(en: "Where to stay", nl: "Waar verblijven", ru: "Где остановиться"),
            subtitle: localizedText(en: "Hotels, apartments and nearby stays for the selected city.", nl: "Hotels, appartementen en verblijven dichtbij voor de gekozen stad.", ru: "Отели, апартаменты и варианты рядом для выбранного города."),
            actions: actions,
            bottomPadding: 34,
            accessibilityIdentifier: "home.stayInCity",
            showsExternalDisclaimer: actions.contains(where: { $0.externalLink?.provider == .booking })
        ) { action in
            cityGuideActionButton(action)
        }
    }

    @ViewBuilder
    private var travelLinksSection: some View {
        let links = visibleTravelLinks

        HomeTravelLinksSection(
            title: "Travel links",
            subtitle: "Useful links for your stay",
            officialLabel: localizedText(en: "Official", nl: "Officieel", ru: "Официально"),
            links: links,
            onOpenURL: { openURL($0) }
        )
    }

    @ViewBuilder
    private func cityGuideActionButton(_ action: HomeCityGuideActionItem) -> some View {
        HomeCityGuideActionButton(action: action) { url in
            openURL(url)
        }
    }

    private var primaryScenarioSection: some View {
        HomePrimaryScenarioSection(
            title: primaryScenarioTitle,
            subtitle: primaryScenarioSubtitle,
            selectedStatus: appState.selectedUserStatus,
            selectedScenarioTitle: selectedScenarioTitle,
            selectedScenarioSubtitle: selectedScenarioSubtitle,
            selectedScenarioTint: scenarioTint,
            changeScenarioTitle: changeScenarioTitle,
            startAsTouristTitle: startAsTouristTitle,
            touristScenarioSubtitle: touristScenarioSubtitle,
            bottomPadding: selectedAudience == nil ? 30 : 18,
            onStartTourist: { appState.selectedUserStatus = .tourist }
        )
    }

    @ViewBuilder
    private var audienceEssentialsSection: some View {
        let section = dashboardSection(
            id: "audience-essentials",
            title: audienceEssentialsTitle,
            items: audienceEssentialCategories
        )
        let categories = DashboardContentPolicy.visibleCards(section.items, context: dashboardRenderContext)

        HomeAudienceCategorySection(
            shouldShow: DashboardContentPolicy.shouldRenderSection(section, context: dashboardRenderContext),
            title: audienceEssentialsTitle,
            subtitle: nil,
            categories: categories,
            language: lang,
            accessibilityIdentifier: "home.audienceEssentials"
        )
    }

    @ViewBuilder
    private var audienceExploreSection: some View {
        let section = dashboardSection(
            id: "audience-explore",
            title: audienceExploreTitle,
            subtitle: audienceExploreSubtitle,
            items: audienceExploreCategories
        )
        let categories = DashboardContentPolicy.visibleCards(section.items, context: dashboardRenderContext)

        HomeAudienceCategorySection(
            shouldShow: DashboardContentPolicy.shouldRenderSection(section, context: dashboardRenderContext),
            title: audienceExploreTitle,
            subtitle: audienceExploreSubtitle,
            categories: categories,
            language: lang,
            accessibilityIdentifier: "home.audienceExplore"
        )
    }

    @ViewBuilder
    private var placesWorthVisitingSection: some View {
        HomePlacesWorthVisitingSection(
            shouldShow: shouldShowPlacesSection,
            title: placesTitle,
            subtitle: placesSubtitle,
            viewAllLabel: viewAllLabel,
            allFilterLabel: allFilterLabel,
            mapDestination: cityDashboard.mapFocus,
            places: Array(filteredDashboardPlaces.prefix(5)),
            language: lang,
            selectedFilter: $selectedPlaceFilter
        )
    }

    @ViewBuilder
    private var netherlandsCalendarSection: some View {
        HomeNetherlandsCalendarSection(
            title: calendarTitle,
            subtitle: calendarSubtitle,
            nextHolidayLabel: nextHolidayLabel,
            viewCalendarLabel: viewCalendarLabel,
            allFilterLabel: allFilterLabel,
            events: filteredDashboardEvents,
            language: lang,
            selectedFilter: $selectedCalendarFilter
        )
    }

    @ViewBuilder
    private var audienceActionsSection: some View {
        let section = dashboardSection(
            id: "audience-actions",
            title: audienceActionsTitle,
            items: quickActions,
            layout: .list
        )
        let actions = DashboardContentPolicy.visibleCards(section.items, context: dashboardRenderContext, limit: 4)

        HomeAudienceActionsSection(
            shouldShow: DashboardContentPolicy.shouldRenderSection(section, context: dashboardRenderContext),
            title: audienceActionsTitle,
            actions: actions,
            language: lang
        )
    }

    @ViewBuilder
    private var audienceHelpSection: some View {
        let section = dashboardSection(
            id: "audience-help",
            title: helpTopicsTitle,
            items: helpTopics
        )
        let topics = DashboardContentPolicy.visibleCards(section.items, context: dashboardRenderContext, limit: 6)

        HomeAudienceHelpSection(
            shouldShow: DashboardContentPolicy.shouldRenderSection(section, context: dashboardRenderContext),
            title: helpTopicsTitle,
            topics: topics,
            language: lang
        )
    }

    private var aiAudienceHelpSection: some View {
        HomeAIAudienceHelpSection(
            aiTitle: L10n.t("ai.title", lang),
            heroTitle: aiHomeHeroTitle,
            heroSubtitle: aiHomeHeroSubtitle,
            promptPlaceholder: aiHomePromptPlaceholder,
            accessibilityLabel: askAudienceAITitle,
            heroPrompt: audienceAIPrompt,
            topics: aiAudienceTopics,
            tools: aiAudienceTools,
            language: lang,
            onOpenAssistant: openAssistantPrompt
        )
    }

    @ViewBuilder
    private var secondaryToolsSection: some View {
        let section = dashboardSection(
            id: "secondary-tools",
            title: secondaryToolsTitle,
            subtitle: secondaryToolsSubtitle,
            items: secondaryTools,
            layout: .grid
        )
        let tools = DashboardContentPolicy.visibleCards(section.items, context: dashboardRenderContext, limit: 2)

        HomeSecondaryToolsSection(
            shouldShow: DashboardContentPolicy.shouldRenderSection(section, context: dashboardRenderContext),
            title: secondaryToolsTitle,
            subtitle: secondaryToolsSubtitle,
            tools: tools,
            onSelectTab: { selectedTab = $0 }
        )
    }

    @ViewBuilder
    private func sectionTitle(_ title: String, subtitle: String? = nil) -> some View {
        let visibleSubtitle = subtitle?.trimmingCharacters(in: .whitespacesAndNewlines)
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 28 : AppTypography.Scale.section, weight: .semibold, design: .default))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: false, vertical: true)

            if let visibleSubtitle, !visibleSubtitle.isEmpty {
                Text(visibleSubtitle)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var personaJourneySection: some View {
        HomePersonaJourneySection(
            title: personaJourneyTitle,
            subtitle: personaJourneySubtitle,
            journeys: personaJourneys,
            language: lang,
            hasSelectedAudience: selectedAudience != nil
        )
    }

    private var helpTopicsSection: some View {
        HomeHelpTopicsSection(
            title: helpTopicsTitle,
            viewAllLabel: viewAllLabel,
            showAllCategoriesLink: shouldShowAllCategoriesLink,
            topics: helpTopics,
            language: lang
        )
    }

    private var featuredCitySection: some View {
        Group {
            if let city = selectedHeroCity ?? NLCity.all.first {
                HomeFeaturedCitySection(
                    city: city,
                    language: lang,
                    eyebrow: featuredCityEyebrow,
                    exploreCityTitle: exploreCityTitle
                )
            }
        }
    }

    private func localizedProvinceName(_ province: String) -> String {
        switch (province, lang) {
        case ("Noord-Holland", .russian): return "Северная Голландия"
        case ("Zuid-Holland", .russian): return "Южная Голландия"
        case ("Noord-Brabant", .russian): return "Северный Брабант"
        default: return province
        }
    }

    private var netherlandsMapSection: some View {
        HomeNetherlandsMapSection(
            title: netherlandsMapTitle,
            subtitle: netherlandsMapSubtitle,
            mapCardTitle: mapCardTitle,
            mapCardSubtitle: mapCardSubtitle,
            openMapLabel: exploreMapLabel,
            selectedCity: cityDashboard.cityName,
            language: lang,
            glowPhase: mapGlowPhase,
            onOpenMap: { selectedTab = .places }
        )
    }

    // MARK: - 1. Netherlands Map Card

    private var netherlandsMapCard: some View {
        HomeRealisticNetherlandsMapSurface(
            title: mapCardTitle,
            subtitle: mapCardSubtitle,
            openMapLabel: exploreMapLabel,
            selectedCity: cityDashboard.cityName,
            language: lang,
            glowPhase: mapGlowPhase,
            onOpenMap: { selectedTab = .places }
        )
        .accessibilityLabel(netherlandsMapTitle)
    }

    // MARK: - 2. Welcome Greeting Card

    private var welcomeGreetingCard: some View {
        ZStack(alignment: .bottom) {
            HomeImageFill(asset: ContentMediaRegistry.officialSourcesHero, accent: AppColors.cyanGlow)
                .allowsHitTesting(false)

            LinearGradient(
                colors: [Color.black.opacity(0.02), AppColors.navyDeep.opacity(0.36), AppColors.navyDeep.opacity(0.97)],
                startPoint: .top, endPoint: .bottom
            )
            .allowsHitTesting(false)

            DutchFlagRibbon(opacity: 0.22)
                .blendMode(.screen)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                HomeWelcomeHeroTopBar(
                    title: heroAppName,
                    tagline: heroAppTagline,
                    currentTime: currentTime,
                    fullDate: fullDate,
                    dynamicTypeSize: dynamicTypeSize
                )

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    HomeWelcomeHeroCityCopy(
                        cityName: cityName,
                        provinceName: provinceName,
                        cityDescription: cityDescription,
                        dynamicTypeSize: dynamicTypeSize
                    )

                    HomeWelcomeHeroActions(
                        provinceTitle: exploreNetherlandsTitle,
                        cityTitle: exploreCityTitle,
                        journeyTitle: startJourneyTitle,
                        cityDestination: AppDestination.cityDetail(province: provinceName, city: cityDashboard.cityName)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(height: dynamicTypeSize.isAccessibilitySize ? 360 : 310)
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.28), AppColors.cyanGlow.opacity(0.18), Color.white.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.9)
        )
        .shadow(color: AppColors.navyDeep.opacity(0.54), radius: 32, x: 0, y: 18)
        .accessibilityIdentifier("home.welcome.greeting.card")
    }

    private var heroAppName: String {
        switch lang {
        case .russian: return "Добро пожаловать в YouNew"
        case .dutch: return "Welkom bij YouNew"
        case .english: return "Welcome to YouNew"
        }
    }

    private var heroAppTagline: String {
        switch lang {
        case .russian: return "Ваш гид по жизни в Нидерландах."
        case .dutch: return "Uw gids voor het leven in Nederland."
        case .english: return "Your guide to life in the Netherlands."
        }
    }

    private var exploreNetherlandsTitle: String {
        switch lang {
        case .russian: return "Открыть Нидерланды"
        case .dutch: return "Verken Nederland"
        case .english: return "Explore Netherlands"
        }
    }

    private var askAITitle: String {
        switch lang {
        case .russian: return "Спросить AI"
        case .dutch: return "Vraag AI"
        case .english: return "Ask AI"
        }
    }

    private var aiHomeHeroTitle: String {
        switch lang {
        case .russian: return "Ваш гид по Нидерландам"
        case .dutch: return "Uw gids voor Nederland"
        case .english: return "Your Netherlands Guide"
        }
    }

    private var aiHomeHeroSubtitle: String {
        switch lang {
        case .russian: return "Информационные ответы. Источники, где доступны."
        case .dutch: return "Informatieve antwoorden. Bronnen waar beschikbaar."
        case .english: return "Informational answers. Sources where available."
        }
    }

    private var aiHomePromptPlaceholder: String {
        switch lang {
        case .russian: return "Спросите про жизнь в Нидерландах..."
        case .dutch: return "Vraag over leven in Nederland..."
        case .english: return "Ask anything about life in the Netherlands..."
        }
    }

    private var heroCap2LikeHousing: String {
        switch lang {
        case .russian: return "Жильё"
        case .dutch: return "Wonen"
        case .english: return "Housing"
        }
    }

    private var heroCap3LikeHealthcare: String {
        switch lang {
        case .russian: return "Медицина"
        case .dutch: return "Zorg"
        case .english: return "Healthcare"
        }
    }

    private var aiTransportTopicTitle: String {
        switch lang {
        case .russian: return "Транспорт"
        case .dutch: return "Vervoer"
        case .english: return "Transport"
        }
    }

    private var aiGovernmentTopicTitle: String {
        switch lang {
        case .russian: return "Госуслуги"
        case .dutch: return "Gemeente"
        case .english: return "Government"
        }
    }

    private var aiAudienceTopics: [HomeAIAudienceTopic] {
        [
            HomeAIAudienceTopic(id: "housing", title: heroCap2LikeHousing, symbol: "house.fill", tint: AppColors.softBlue, prompt: aiHousingPrompt),
            HomeAIAudienceTopic(id: "healthcare", title: heroCap3LikeHealthcare, symbol: "heart.fill", tint: AppColors.success, prompt: aiHealthcarePrompt),
            HomeAIAudienceTopic(id: "transport", title: aiTransportTopicTitle, symbol: "tram.fill", tint: AppColors.routeLine, prompt: aiTransportPrompt),
            HomeAIAudienceTopic(id: "government", title: aiGovernmentTopicTitle, symbol: "building.columns.fill", tint: AppColors.violet, prompt: aiGovernmentPrompt)
        ]
    }

    private var toolSearchLikeTitle: String {
        switch lang {
        case .russian: return "Поиск"
        case .dutch: return "Zoeken"
        case .english: return "Search"
        }
    }

    private var toolSearchLikeSubtitle: String {
        switch lang {
        case .russian: return "Гайды и ответы"
        case .dutch: return "Gidsen en antwoorden"
        case .english: return "Guides & answers"
        }
    }

    private var toolMapLikeTitle: String {
        switch lang {
        case .russian: return "Карта"
        case .dutch: return "Kaart"
        case .english: return "Map"
        }
    }

    private var toolMapLikeSubtitle: String {
        switch lang {
        case .russian: return "Помощь рядом"
        case .dutch: return "Hulp dichtbij"
        case .english: return "Nearby help"
        }
    }

    private var aiAudienceTools: [HomeAIAudienceTool] {
        [
            HomeAIAudienceTool(id: "search", title: toolSearchLikeTitle, subtitle: toolSearchLikeSubtitle, symbol: "magnifyingglass", tint: AppColors.softBlue, prompt: nil),
            HomeAIAudienceTool(id: "map", title: toolMapLikeTitle, subtitle: toolMapLikeSubtitle, symbol: "map.fill", tint: AppColors.routeLine, prompt: aiMapPrompt)
        ]
    }

    private var aiHousingPrompt: String {
        switch lang {
        case .russian: return "Объясни аренду, права жильца и договор в Нидерландах"
        case .dutch: return "Leg huur, huurdersrechten en contracten in Nederland uit"
        case .english: return "Explain rent, tenant rights, and housing contracts in the Netherlands"
        }
    }

    private var aiHealthcarePrompt: String {
        switch lang {
        case .russian: return "Как устроены huisarts, страховка и аптеки?"
        case .dutch: return "Hoe werken huisarts, verzekering en apotheek?"
        case .english: return "How do GP care, insurance, and pharmacies work?"
        }
    }

    private var aiTransportPrompt: String {
        switch lang {
        case .russian: return "Объясни OV-chipkaart, поезда, трамваи и автобусы"
        case .dutch: return "Leg OV-chipkaart, trein, tram en bus uit"
        case .english: return "Explain OV-chipkaart, trains, trams, and buses"
        }
    }

    private var aiGovernmentPrompt: String {
        switch lang {
        case .russian: return "Что нужно знать про BSN, DigiD и gemeente?"
        case .dutch: return "Wat moet ik weten over BSN, DigiD en gemeente?"
        case .english: return "What should I know about BSN, DigiD, and the municipality?"
        }
    }

    private var aiMapPrompt: String {
        switch lang {
        case .russian: return "Помоги найти официальную помощь рядом со мной"
        case .dutch: return "Help mij officiële hulp in de buurt te vinden"
        case .english: return "Help me find official help nearby"
        }
    }

    private var helpTopicsTitle: String {
        switch lang {
        case .russian: return selectedAudience == nil ? "С чем поможет YouNew?" : "Помощь: \(selectedScenarioTitle)"
        case .dutch: return selectedAudience == nil ? "Waarmee helpt YouNew?" : "Hulp: \(selectedScenarioTitle)"
        case .english: return selectedAudience == nil ? "What can YouNew help with?" : "\(selectedScenarioTitle) help"
        }
    }

    private var personaJourneyTitle: String {
        switch lang {
        case .russian: return "Выберите рабочее пространство"
        case .dutch: return "Kies uw werkruimte"
        case .english: return "Choose your workspace"
        }
    }

    private var personaJourneySubtitle: String {
        switch lang {
        case .russian: return "Персональный маршрут с документами, сроками, источниками и AI"
        case .dutch: return "Persoonlijke route met documenten, datums, bronnen en AI"
        case .english: return "Personal route with documents, dates, sources, and AI"
        }
    }

    private var primaryScenarioTitle: String {
        switch lang {
        case .russian: return selectedAudience == nil ? "Куда вы хотите перейти дальше?" : "Ваше рабочее пространство"
        case .dutch: return selectedAudience == nil ? "Waar wilt u nu naartoe?" : "Uw werkruimte"
        case .english: return selectedAudience == nil ? "Where do you want to go next?" : "Your workspace"
        }
    }

    private var primaryScenarioSubtitle: String {
        switch lang {
        case .russian: return selectedAudience == nil ? "Сначала можно изучить страну. Когда готовы действовать, выберите сценарий." : "Ваши документы, сроки, источники и AI настроены под выбранный сценарий."
        case .dutch: return selectedAudience == nil ? "Verken eerst het land. Kies een route wanneer u klaar bent om te handelen." : "Documenten, datums, bronnen en AI passen bij deze route."
        case .english: return selectedAudience == nil ? "Explore the country first. When you are ready to act, choose a scenario." : "Documents, dates, sources, and AI are tuned to this path."
        }
    }

    private var workspaceIntroTitle: String {
        switch lang {
        case .russian:
            return selectedAudience == nil ? "Персональное рабочее пространство" : "Workspace: \(selectedScenarioTitle)"
        case .dutch:
            return selectedAudience == nil ? "Persoonlijke werkruimte" : "Werkruimte: \(selectedScenarioTitle)"
        case .english:
            return selectedAudience == nil ? "Personal workspace" : "Workspace: \(selectedScenarioTitle)"
        }
    }

    private var workspaceIntroSubtitle: String {
        switch lang {
        case .russian:
            return selectedAudience == nil
                ? "Выберите сценарий, чтобы открыть персональный маршрут."
                : "Откройте персональный маршрут для документов, сроков, источников и AI."
        case .dutch:
            return selectedAudience == nil
                ? "Kies een route om uw persoonlijke werkruimte te openen."
                : "Open uw persoonlijke route voor documenten, datums, bronnen en AI."
        case .english:
            return selectedAudience == nil
                ? "Choose a path to open your personal workspace."
                : "Open your personal route for documents, dates, sources, and AI."
        }
    }

    private var whoAreYouSubtitle: String {
        let progress = scenarioProgressValue(checklistSnapshot)
        return localizedText(
            en: "\(cityName) · \(progress) profile progress · Change profile",
            nl: "\(cityName) · \(progress) profielvoortgang · Route wijzigen",
            ru: "\(cityName) · \(progress) прогресс профиля · Сменить профиль"
        )
    }

    private var workspaceChooseTitle: String {
        switch lang {
        case .russian: return "Выбрать"
        case .dutch: return "Kiezen"
        case .english: return "Choose"
        }
    }

    private var workspaceChangeTitle: String {
        switch lang {
        case .russian: return "Сменить"
        case .dutch: return "Wijzigen"
        case .english: return "Change"
        }
    }

    private var selectedScenarioTitle: String {
        guard let status = appState.selectedUserStatus else {
            return startAsTouristTitle
        }
        return status.localized(lang)
    }

    private var selectedScenarioSubtitle: String {
        guard let status = appState.selectedUserStatus else {
            return touristScenarioSubtitle
        }
        return status.subtitle(lang)
    }

    private var changeScenarioTitle: String {
        switch lang {
        case .russian: return "Сменить сценарий"
        case .dutch: return "Route wijzigen"
        case .english: return "Change scenario"
        }
    }

    private var scenarioTint: Color {
        switch selectedAudience {
        case .tourist:
            return AppColors.cyanGlow
        case .student:
            return AppColors.emerald
        case .business:
            return AppColors.dutchOrange
        case .local:
            return AppColors.softBlue
        case .admin:
            return AppColors.violet
        case .general, nil:
            return AppColors.cyanGlow
        }
    }

    private var startAsTouristTitle: String {
        switch lang {
        case .russian: return "Начать как турист"
        case .dutch: return "Start als toerist"
        case .english: return "Start as Tourist"
        }
    }

    private var touristModeTitle: String {
        switch lang {
        case .russian: return "Tourist mode"
        case .dutch: return "Toeristenmodus"
        case .english: return "Tourist mode"
        }
    }

    private var touristScenarioSubtitle: String {
        switch lang {
        case .russian: return "Правила пребывания, транспорт, экстренная помощь, места в городе"
        case .dutch: return "Verblijfsregels, vervoer, noodhulp en plekken in de stad"
        case .english: return "Stay rules, transport, emergency help, city places"
        }
    }

    private var audienceEssentialsTitle: String {
        switch lang {
        case .russian: return "\(selectedScenarioTitle): важное"
        case .dutch: return "\(selectedScenarioTitle): essentieel"
        case .english: return "\(selectedScenarioTitle) essentials"
        }
    }

    private var audienceEssentialsSubtitle: String {
        switch lang {
        case .russian: return "Главные разделы без контента из других категорий."
        case .dutch: return "Belangrijkste onderdelen zonder content uit andere categorieën."
        case .english: return "Core sections without content from other categories."
        }
    }

    private var audienceExploreTitle: String {
        switch lang {
        case .russian: return selectedAudience == .tourist ? "Исследуйте \(ProvinceCatalog.localizedCityName(cityDashboard.cityName, lang))" : "Обзор для сценария"
        case .dutch: return selectedAudience == .tourist ? "Verken \(ProvinceCatalog.localizedCityName(cityDashboard.cityName, lang))" : "Verken uw route"
        case .english: return selectedAudience == .tourist ? "Explore \(ProvinceCatalog.localizedCityName(cityDashboard.cityName, lang))" : "Explore your scenario"
        }
    }

    private var audienceExploreSubtitle: String {
        switch lang {
        case .russian: return "Только карточки, разрешенные для выбранной категории."
        case .dutch: return "Alleen kaarten die voor deze categorie zijn toegestaan."
        case .english: return "Only cards allowed for the selected category."
        }
    }

    private var audienceActionsTitle: String {
        switch lang {
        case .russian: return "Быстрые действия"
        case .dutch: return "Snelle acties"
        case .english: return "Quick actions"
        }
    }

    private var travelLinksTitle: String {
        switch lang {
        case .russian: return "План поездки в \(ProvinceCatalog.localizedCityName(cityDashboard.cityName, lang))"
        case .dutch: return "Plan \(ProvinceCatalog.localizedCityName(cityDashboard.cityName, lang))"
        case .english: return "Plan \(ProvinceCatalog.localizedCityName(cityDashboard.cityName, lang))"
        }
    }

    private var travelLinksSubtitle: String {
        switch lang {
        case .russian: return "Отели, рестораны, кафе, места, карта и официальный городской гид."
        case .dutch: return "Hotels, restaurants, cafés, plekken, kaart en officiële stadsgids."
        case .english: return "Hotels, restaurants, cafes, places, map, and the official city guide."
        }
    }

    private var placesTitle: String {
        switch lang {
        case .russian: return "Что посетить"
        case .dutch: return "Wat bezoeken"
        case .english: return "What to visit"
        }
    }

    private var placesSubtitle: String {
        "Museums, landmarks, parks, and local spots in \(cityDashboard.cityName)"
    }

    private var calendarTitle: String {
        if isTouristMode {
            switch lang {
            case .russian: return "Что важно знать"
            case .dutch: return "Wat belangrijk is"
            case .english: return "What to know"
            }
        }
        switch lang {
        case .russian: return "Что важно знать"
        case .dutch: return "Wat belangrijk is"
        case .english: return "What to know"
        }
    }

    private var calendarSubtitle: String {
        if isTouristMode {
            switch lang {
            case .russian: return "What may affect your visit"
            case .dutch: return "Wat je bezoek kan beinvloeden"
            case .english: return "What may affect your visit"
            }
        }
        switch lang {
        case .russian: return "Important dates that may affect services"
        case .dutch: return "Belangrijke data die diensten kunnen beinvloeden"
        case .english: return "Important dates that may affect services"
        }
    }

    private var nextHolidayLabel: String {
        switch lang {
        case .russian: return "Ближайшая дата"
        case .dutch: return "Volgende datum"
        case .english: return "Next holiday"
        }
    }

    private var viewCalendarLabel: String {
        switch lang {
        case .russian: return "Открыть календарь"
        case .dutch: return "Bekijk kalender"
        case .english: return "View calendar"
        }
    }

    private var allFilterLabel: String {
        switch lang {
        case .russian: return "Все"
        case .dutch: return "Alle"
        case .english: return "All"
        }
    }

    private var audienceActionsSubtitle: String {
        switch lang {
        case .russian: return "Действия из выбранного сценария, без лишних путей."
        case .dutch: return "Acties uit uw gekozen route, zonder extra ruis."
        case .english: return "Actions from the selected scenario, without extra noise."
        }
    }

    private var audienceHelpSubtitle: String {
        switch lang {
        case .russian: return "Темы помощи фильтруются по выбранной категории."
        case .dutch: return "Hulpthema's worden gefilterd op de gekozen categorie."
        case .english: return "Help topics are filtered by the selected category."
        }
    }

    private var aiAudienceHelpTitle: String {
        switch lang {
        case .russian: return "Спросить о городе"
        case .dutch: return "Vraag over de stad"
        case .english: return "Ask about this city"
        }
    }

    private var aiAudienceHelpSubtitle: String {
        switch lang {
        case .russian: return "AI отвечает в рамках выбранной категории."
        case .dutch: return "AI antwoordt binnen de gekozen categorie."
        case .english: return "AI answers within the selected category."
        }
    }

    private var askAudienceAITitle: String {
        switch lang {
        case .russian: return "Спросить AI для сценария"
        case .dutch: return "Vraag AI voor deze route"
        case .english: return "Ask AI for this scenario"
        }
    }

    private var secondaryToolsTitle: String {
        switch lang {
        case .russian: return "Ещё"
        case .dutch: return "Meer"
        case .english: return "More"
        }
    }

    private var secondaryToolsSubtitle: String {
        switch lang {
        case .russian: return "Сохранённое и дополнительные инструменты без лишнего шума."
        case .dutch: return "Bewaard en extra hulpmiddelen zonder ruis."
        case .english: return "Saved items and extra tools without extra noise."
        }
    }

    private var savedToolTitle: String {
        switch lang {
        case .russian: return "Сохранённое"
        case .dutch: return "Bewaard"
        case .english: return "Saved"
        }
    }

    private var savedToolSubtitle: String {
        switch lang {
        case .russian: return "Материалы выбранного сценария"
        case .dutch: return "Items voor uw gekozen route"
        case .english: return "Items for your selected scenario"
        }
    }

    private var moreToolTitle: String {
        switch lang {
        case .russian: return "More"
        case .dutch: return "Meer"
        case .english: return "More"
        }
    }

    private var moreToolSubtitle: String {
        switch lang {
        case .russian: return "Дополнительные разделы этого сценария"
        case .dutch: return "Extra onderdelen voor deze route"
        case .english: return "More sections for this scenario"
        }
    }

    private var featuredCityEyebrow: String {
        switch lang {
        case .russian: return "Город недели"
        case .dutch: return "Uitgelichte stad"
        case .english: return "Featured City"
        }
    }

    private var featuredCityDescription: String {
        switch lang {
        case .russian: return "Исторический университетский город с каналами, музеями и студенческой жизнью."
        case .dutch: return "Historische universiteitsstad met grachten, musea en studentenleven."
        case .english: return "Historic university city with canals, museums and student life."
        }
    }

    private func localizedText(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }

    // MARK: - 3. Quick Actions

    private var quickActionsSection: some View {
        HomeQuickActionsSection(
            title: quickActionsTitle,
            actions: quickActions,
            language: lang
        )
    }

    // MARK: - 5. Categories Grid

    private var categoriesGridSection: some View {
        HomeCategoriesGridSection(
            title: categoriesTitle,
            viewAllLabel: viewAllLabel,
            showAllCategoriesLink: shouldShowAllCategoriesLink,
            categories: homeCategories,
            scenarios: lifeScenarios,
            language: lang
        )
    }

    // MARK: - 6. History & Culture

    private var historyAndCultureSection: some View {
        HomeHistoryCultureSection(title: historyAndCultureTitle, language: lang)
    }

    // MARK: - 7. Nearby Attractions

    private var nearbyAttractionsSection: some View {
        HomeNearbyAttractionsSection(
            title: nearbyAttractionsTitle,
            moments: cityMoments,
            language: lang
        )
    }

    // MARK: - 8. News & Updates

    private var newsUpdatesSection: some View {
        HomeNewsUpdatesSection(
            title: newsUpdatesTitle,
            items: newsItems,
            language: lang
        )
    }

    // MARK: - 9. Reviews & Feedback

    private var reviewsFeedbackSection: some View {
        HomeReviewsFeedbackCard(
            title: reviewsFeedbackTitle,
            subtitle: reviewsFeedbackSubtitle,
            storageNotice: feedbackStorageNotice
        )
    }

    private var aiNavigatorCard: some View {
        HomeAINavigatorCard(
            title: aiNavigatorTitle,
            subtitle: aiNavigatorSubtitle,
            questionExamples: aiQuestionExamples,
            onOpenAssistant: { openAssistantPrompt(nil) }
        )
    }

    // MARK: - Dutch Phrase of the Day

    private var dutchPhraseCard: some View {
        HomeDutchPhraseCard(language: lang)
    }

    private var progressSection: some View {
        let snapshot = checklistSnapshot
        let milestoneTitles = journeyMilestoneTitles

        return HomeJourneyProgressCard(
            title: myProgressTitle,
            nextStepText: nextStepText(snapshot),
            completedStepsText: completedStepsText(snapshot),
            completedCount: snapshot.completedCount,
            totalCount: snapshot.totalCount,
            progress: snapshot.progress,
            milestoneTitles: milestoneTitles,
            completedMilestones: completedJourneyMilestones(snapshot, milestoneTitles: milestoneTitles)
        )
    }

    private var homeSectionSpacing: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 64 : 54
    }

    private var heroCardHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 470 : 390
    }

    private var homeBottomReserve: CGFloat {
        let base = FloatingTabBarMetrics.rootContentInset + 96
        return dynamicTypeSize.isAccessibilitySize ? base + 56 : base
    }

    private var shouldShowPersonaActionSection: Bool {
        !homeCategories.isEmpty || !lifeScenarios.isEmpty
    }

    private var shouldShowAllCategoriesLink: Bool {
        appState.selectedUserStatus == nil
    }

    private var shouldShowHistoryAndCultureSection: Bool {
        switch appState.selectedUserStatus?.personaTag {
        case .tourist, .eu, .universal, nil:
            return true
        case .student, .worker, .refugee, .family, .entrepreneur, .lgbt, .nonEU, .highlySkilledMigrant:
            return false
        }
    }

    private func homeContentWidth(for viewportWidth: CGFloat) -> CGFloat {
        max(0, min(viewportWidth, 760))
    }

    private func homeInnerContentWidth(for viewportWidth: CGFloat) -> CGFloat {
        max(0, homeContentWidth(for: viewportWidth) - AppSpacing.screenHorizontal * 2)
    }

    private var releaseCommandCenterTop: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            cityCompactOverviewSection
            cityPillsSection
            placesWorthVisitingSection
            foodDrinksGuideSection
            netherlandsCalendarSection
            netherlandsMapSection
            aiAudienceHelpSection
            secondaryToolsSection
        }
    }

    private var disclaimerFooter: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.success)
            Text(disclaimerText)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .homeReadableBand()
        .padding(.top, 8)
        .padding(.bottom, 18)
        .background(.clear)
    }

    private var lifeScenarios: [HomeLifeScenario] {
        switch appState.selectedUserStatus?.personaTag {
        case .student:
            return [
                scenario(id: "universities", title: "Universities", subtitle: "MBO, HBO, research universities", asset: "premium_home_language", accent: AppColors.emerald, destination: .institutionsList),
                scenario(id: "student-housing", title: "Student Housing", subtitle: "Rooms, contracts, registration", asset: "premium_home_housing", accent: AppColors.violet, destination: .practicalGuide(.housingBasics)),
                scenario(id: "duo", title: "DUO", subtitle: "Study finance, insurance, transport", asset: "premium_home_documents", accent: AppColors.softBlue, destination: .officialSources)
            ]
        case .worker, .highlySkilledMigrant:
            return [
                scenario(id: "work-contracts", title: "Work Contracts", subtitle: "Salary, rights, conditions", asset: "premium_home_work", accent: AppColors.violet, destination: .institutionsList),
                scenario(id: "bsn-digid", title: "BSN and DigiD", subtitle: "Registration and identity", asset: "premium_home_documents", accent: AppColors.cyanGlow, destination: .checklistList),
                scenario(id: "taxes", title: "Taxes", subtitle: "Tax and work basics", asset: "premium_home_work", accent: AppColors.emerald, destination: .officialSources)
            ]
        case .refugee:
            return [
                scenario(id: "ind", title: "IND", subtitle: "Status, documents, permissions", asset: "premium_home_documents", accent: AppColors.softBlue, destination: .governmentHub),
                scenario(id: "municipality", title: "Municipality", subtitle: "Registration, benefits, local support", asset: "home_documents_city_hall", accent: AppColors.cyanGlow, destination: .governmentHub),
                scenario(id: "integration", title: "Integration", subtitle: "Language, healthcare, education access", asset: "premium_home_language", accent: AppColors.emerald, destination: .languageHub)
            ]
        case .family:
            return [
                scenario(id: "schools", title: "Schools", subtitle: "Education for children", asset: "premium_home_language", accent: AppColors.emerald, destination: .institutionsList),
                scenario(id: "childcare", title: "Childcare", subtitle: "Kinderopvang and SVB", asset: "premium_home_housing", accent: AppColors.softBlue, destination: .officialSources),
                scenario(id: "family-healthcare", title: "Healthcare", subtitle: "Family care and activities", asset: "premium_home_healthcare", accent: AppColors.dutchOrange, destination: .practicalGuide(.healthcareBasics))
            ]
        case .tourist:
            return [
                scenario(id: "stay-rules", title: "Stay Rules", subtitle: "Short stay and documents", asset: "premium_home_documents", accent: AppColors.softBlue, destination: .officialSources),
                scenario(id: "transport", title: "Transport", subtitle: "OV, city travel, places", asset: ContentMediaRegistry.transportHero, accent: AppColors.dutchOrange, destination: .practicalGuide(.transportBasics)),
                scenario(id: "emergency", title: "Emergency", subtitle: "112, urgent care, lost documents", asset: "premium_home_emergency", accent: AppColors.error, destination: .emergencyHub)
            ]
        case .entrepreneur:
            return [
                scenario(id: "kvk", title: "KVK", subtitle: "Business registration", asset: "premium_home_work", accent: AppColors.softBlue, destination: .officialSources),
                scenario(id: "vat", title: "VAT / BTW", subtitle: "Tax and banking basics", asset: "premium_home_documents", accent: AppColors.dutchOrange, destination: .officialSources),
                scenario(id: "permits", title: "Permits", subtitle: "Municipality rules", asset: "home_documents_city_hall", accent: AppColors.violet, destination: .governmentHub)
            ]
        case .lgbt:
            return [
                scenario(id: "safety", title: "Safety", subtitle: "Rights and legal support", asset: "premium_home_documents", accent: AppColors.softBlue, destination: .lgbtqSupport),
                scenario(id: "healthcare", title: "Healthcare", subtitle: "Inclusive care and mental health", asset: "premium_home_healthcare", accent: AppColors.emerald, destination: .practicalGuide(.healthcareBasics)),
                scenario(id: "community", title: "Community", subtitle: "Support, services, safe places", asset: ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.premiumHousingImage, accent: AppColors.dutchOrange, destination: .lgbtqSupport)
            ]
        case .eu, .nonEU, .universal, nil:
            return [
                scenario(id: "registration", title: "Registration", subtitle: "Municipality, BSN, DigiD", asset: "premium_home_documents", accent: AppColors.cyanGlow, destination: .checklistList),
                scenario(id: "healthcare", title: "Healthcare", subtitle: "GP and insurance", asset: "premium_home_healthcare", accent: AppColors.emerald, destination: .practicalGuide(.healthcareBasics)),
                scenario(id: "housing", title: "Housing", subtitle: "Renting safely", asset: "premium_home_housing", accent: AppColors.violet, destination: .practicalGuide(.housingBasics))
            ]
        }
    }

    private func scenario(id: String, title: String, subtitle: String, asset: String, accent: Color, destination: AppDestination) -> HomeLifeScenario {
        scenario(
            id: id,
            title: title,
            subtitle: subtitle,
            asset: premiumLocalImage(id: "scenario-\(id)", localAssetName: asset, title: title),
            accent: accent,
            destination: destination
        )
    }

    private func scenario(id: String, title: String, subtitle: String, asset: AppImageAsset?, accent: Color, destination: AppDestination) -> HomeLifeScenario {
        HomeLifeScenario(
            id: id,
            titleRU: title,
            titleNL: title,
            titleEN: title,
            subtitleRU: subtitle,
            subtitleNL: subtitle,
            subtitleEN: subtitle,
            asset: asset,
            accent: accent,
            destination: destination
        )
    }

    private var homeHeroCities: [HomeHeroCity] {
        [
            HomeHeroCity(
                id: "amsterdam",
                name: "Amsterdam",
                provinceRU: "Северная Голландия",
                provinceNL: "Noord-Holland",
                provinceEN: "North Holland",
                descriptionRU: "Столица Нидерландов: каналы, музеи, велосипеды и ночная жизнь в одном маршруте.",
                descriptionNL: "De hoofdstad van Nederland: grachten, musea, fietsen en avondleven in een route.",
                descriptionEN: "The Dutch capital: canals, museums, cycling and nightlife in one route.",
                statOneValue: "900k",
                statOneRU: "Население",
                statOneNL: "Inwoners",
                statOneEN: "Population",
                statTwoValue: "165",
                statTwoRU: "Каналы",
                statTwoNL: "Grachten",
                statTwoEN: "Canals",
                statThreeValue: "1275",
                statThreeRU: "Основан",
                statThreeNL: "Ontstaan",
                statThreeEN: "Founded",
                symbol: "🏙",
                asset: cityVisualAsset(cityName: "Amsterdam", provinceName: "Noord-Holland", role: .hero),
                destination: .cityDetail(province: "Noord-Holland", city: "Amsterdam")
            ),
            HomeHeroCity(
                id: "rotterdam",
                name: "Rotterdam",
                provinceRU: "Южная Голландия",
                provinceNL: "Zuid-Holland",
                provinceEN: "South Holland",
                descriptionRU: "Крупнейший порт Европы, мост Эразма и современная архитектура рядом с водой.",
                descriptionNL: "Europa's grootste haven, de Erasmusbrug en moderne architectuur aan het water.",
                descriptionEN: "Europe's largest port, the Erasmus Bridge and modern waterfront architecture.",
                statOneValue: "650k",
                statOneRU: "Население",
                statOneNL: "Inwoners",
                statOneEN: "Population",
                statTwoValue: "#1",
                statTwoRU: "Порт",
                statTwoNL: "Haven",
                statTwoEN: "Port",
                statThreeValue: "1340",
                statThreeRU: "Основан",
                statThreeNL: "Stad",
                statThreeEN: "City",
                symbol: "🌉",
                asset: cityVisualAsset(cityName: "Rotterdam", provinceName: "Zuid-Holland", role: .hero),
                destination: .cityDetail(province: "Zuid-Holland", city: "Rotterdam")
            ),
            HomeHeroCity(
                id: "den-haag",
                name: "Den Haag",
                provinceRU: "Южная Голландия",
                provinceNL: "Zuid-Holland",
                provinceEN: "South Holland",
                descriptionRU: "Парламент, международные суды, посольства и пляж Схевенинген в одном городе.",
                descriptionNL: "Parlement, internationale hoven, ambassades en Scheveningen in een stad.",
                descriptionEN: "Parliament, international courts, embassies and Scheveningen in one city.",
                statOneValue: "550k",
                statOneRU: "Население",
                statOneNL: "Inwoners",
                statOneEN: "Population",
                statTwoValue: "3",
                statTwoRU: "Станции",
                statTwoNL: "Stations",
                statTwoEN: "Stations",
                statThreeValue: "13 c.",
                statThreeRU: "История",
                statThreeNL: "Historie",
                statThreeEN: "History",
                symbol: "⚖️",
                asset: cityVisualAsset(cityName: "Den Haag", provinceName: "Zuid-Holland", role: .hero),
                destination: .cityDetail(province: "Zuid-Holland", city: "Den Haag")
            ),
            HomeHeroCity(
                id: "leiden",
                name: "Leiden",
                provinceRU: "Южная Голландия · ваш город",
                provinceNL: "Zuid-Holland · jouw stad",
                provinceEN: "South Holland · your city",
                descriptionRU: "Исторический университетский город с каналами, музеями и спокойной студенческой жизнью.",
                descriptionNL: "Historische universiteitsstad met grachten, musea en rustig studentenleven.",
                descriptionEN: "Historic university city with canals, museums and calm student life.",
                statOneValue: "130k",
                statOneRU: "Население",
                statOneNL: "Inwoners",
                statOneEN: "Population",
                statTwoValue: "1575",
                statTwoRU: "Университет",
                statTwoNL: "Universiteit",
                statTwoEN: "University",
                statThreeValue: "28 km",
                statThreeRU: "Каналы",
                statThreeNL: "Grachten",
                statThreeEN: "Canals",
                symbol: "🎓",
                asset: cityVisualAsset(cityName: "Leiden", provinceName: "Zuid-Holland", role: .hero),
                destination: .cityDetail(province: "Zuid-Holland", city: "Leiden")
            ),
            HomeHeroCity(
                id: "utrecht",
                name: "Utrecht",
                provinceRU: "Утрехт",
                provinceNL: "Utrecht",
                provinceEN: "Utrecht",
                descriptionRU: "Средневековый центр, башня Дом и каналы с кафе прямо у воды.",
                descriptionNL: "Middeleeuws centrum, de Domtoren en werfkelders direct aan het water.",
                descriptionEN: "Medieval centre, the Dom Tower and canalside wharf cellars.",
                statOneValue: "360k",
                statOneRU: "Население",
                statOneNL: "Inwoners",
                statOneEN: "Population",
                statTwoValue: "112m",
                statTwoRU: "Домторен",
                statTwoNL: "Domtoren",
                statTwoEN: "Dom Tower",
                statThreeValue: "47 BC",
                statThreeRU: "Корни",
                statThreeNL: "Wortels",
                statThreeEN: "Roots",
                symbol: "⛪",
                asset: cityVisualAsset(cityName: "Utrecht", provinceName: "Utrecht", role: .hero),
                destination: .cityDetail(province: "Utrecht", city: "Utrecht")
            )
        ]
    }

    private func premiumLocalImage(id: String, localAssetName: String, title: String) -> AppImageAsset {
        return AppImageAsset(
            id: id,
            url: nil,
            localAssetName: localAssetName,
            title: title,
            description: "Premium editorial category image for the YouNew home screen.",
            sourceName: "Generated project asset",
            sourceURL: nil,
            creator: "OpenAI image generation",
            license: nil,
            attribution: "Generated for YouNew",
            width: nil,
            height: nil,
            aspectRatio: 16.0 / 10.0,
            type: .cardThumbnail,
            verified: true,
            retrievedAt: "2026-06-02"
        )
    }

    private func cityVisualAsset(cityName: String, provinceName: String, role: CityVisualRole) -> AppImageAsset? {
        let placeId = CuratedPlaceHeroMediaRegistry.cityPlaceId(cityName: cityName, provinceName: provinceName)
        if role == .card || role == .thumbnail,
           let localAsset = LocalNetherlandsImagePackRegistry.cityCard(placeId: placeId) {
            return localAsset
        }
        if role == .hero,
           let localAsset = LocalNetherlandsImagePackRegistry.cityHero(placeId: placeId) {
            return localAsset
        }
        return CuratedPlaceHeroMediaRegistry.cityVisual(for: placeId, role: role)?
            .appImageAsset(id: "home-\(placeId)-\(role.rawValue)", type: .cityHero)
    }

    private func cityFallbackImageAsset(for city: DashboardCity) -> AppImageAsset {
        if let registryAsset = ContentArtworkRegistry.asset(for: .cityHeroFallback) {
            return registryAsset
        }

        return AppImageAsset(
            id: "city-fallback-\(city.id.rawValue)",
            url: nil,
            localAssetName: "home_leiden_canals",
            title: "\(city.name) city guide",
            description: "Bundled Dutch city photo fallback for \(city.name) when no verified hero image is available.",
            sourceName: "Project bundled visual",
            sourceURL: nil,
            creator: "YouNew",
            license: "Bundled app asset",
            attribution: "YouNew",
            width: nil,
            height: nil,
            aspectRatio: 16.0 / 10.0,
            type: .cityHero,
            verified: true,
            retrievedAt: "2026-06-23"
        )
    }

    private func cityImageAsset(_ city: NLCity) -> AppImageAsset {
        let resolvedImage = CanonicalPlaceImageResolver.resolveCityHero(city: city)
        let url = resolvedImage.url
        return AppImageAsset(
            id: city.placeId,
            url: url,
            imageURL: url,
            thumbnailURL: url,
            localAssetName: resolvedImage.localAssetName ?? ContentArtworkRegistry.asset(for: .cityHeroFallback)?.localAssetName ?? "home_leiden_canals",
            title: "\(city.name) hero",
            description: city.shortDescription,
            sourceName: "Wikimedia Commons",
            sourceURL: url,
            creator: nil,
            license: "CC BY-SA 4.0",
            attribution: nil,
            width: nil,
            height: nil,
            aspectRatio: 16.0 / 10.0,
            type: .cityHero,
            verified: true,
            retrievedAt: "2026-06-07"
        )
    }

    private func cityImageAsset(_ city: CityItem) -> AppImageAsset {
        let resolvedImage = CanonicalPlaceImageResolver.resolveCityHero(city: city)
        let url = resolvedImage.url
        return AppImageAsset(
            id: city.media.heroImage?.placeId ?? city.id,
            url: url,
            imageURL: url,
            thumbnailURL: url,
            localAssetName: resolvedImage.localAssetName ?? ContentArtworkRegistry.asset(for: .cityHeroFallback)?.localAssetName ?? "home_leiden_canals",
            title: "\(city.name) hero",
            description: city.shortDescription.english,
            sourceName: resolvedImage.sourceLabel,
            sourceURL: url,
            creator: nil,
            license: nil,
            attribution: resolvedImage.attribution,
            width: nil,
            height: nil,
            aspectRatio: 16.0 / 10.0,
            type: .cityHero,
            verified: true,
            retrievedAt: "2026-06-23"
        )
    }

    // MARK: - Quick Actions Data

    private var quickActions: [HomeQuickAction] {
        DashboardContentPolicy.visibleCards(
            activePersonaDashboard.quickActions,
            context: dashboardRenderContext,
            limit: 4
        )
    }

    private var helpTopics: [HomeHelpTopic] {
        DashboardContentPolicy.visibleCards(
            activePersonaDashboard.helpTopics,
            context: dashboardRenderContext,
            limit: 6
        )
    }

    private var personaJourneys: [HomePersonaJourney] {
        activePersonaDashboard.journeys
    }

    // MARK: - Categories Grid Data

    private var homeCategories: [HomeCategoryItem] {
        guard selectedAudience != nil else { return [] }
        let personaCategories = activePersonaDashboard.categories.filter { personaCategory in
            !defaultHomeCategories.contains { $0.id == personaCategory.id }
        }
        return (defaultHomeCategories + personaCategories)
            .filter { DashboardContentPolicy.shouldRenderCard($0, context: dashboardRenderContext) }
            .sorted { lhs, rhs in
                if lhs.priority != rhs.priority { return lhs.priority < rhs.priority }
                return lhs.id < rhs.id
            }
    }

    private func dashboardSection<Item: DashboardRenderableCard>(
        id: String,
        title: String,
        subtitle: String? = nil,
        items: [Item],
        layout: DashboardSectionLayout = .grid
    ) -> DashboardSection<Item> {
        DashboardSection(
            id: id,
            title: title,
            subtitle: subtitle,
            layout: layout,
            priority: 1,
            audienceTags: dashboardAudienceTags,
            items: items
        )
    }

    private var audienceEssentialCategories: [HomeCategoryItem] {
        orderedHomeCategories(ids: audienceEssentialCategoryIDs)
    }

    private var audienceExploreCategories: [HomeCategoryItem] {
        orderedHomeCategories(ids: audienceExploreCategoryIDs)
    }

    private var audienceEssentialCategoryIDs: [String] {
        // id: "documents"
        // id: "lost_documents"
        switch selectedAudience {
        case .tourist:
            return ["emergency_112", "transport", "rules_fines", "lost_documents", "healthcare"]
        case .student:
            return ["documents", "education", "housing", "healthcare", "transport", "emergency_112"]
        case .business:
            return ["work_taxes", "documents", "government", "healthcare", "transport", "emergency_112"]
        case .local:
            return ["documents", "housing", "healthcare", "transport", "government", "emergency_112"]
        case .admin:
            return ["government", "documents", "work_taxes", "housing", "healthcare", "transport"]
        case .general:
            return ["emergency_112", "transport", "healthcare", "help_nearby"]
        case nil:
            return []
        }
    }

    private var audienceExploreCategoryIDs: [String] {
        switch selectedAudience {
        case .tourist:
            return ["places", "museums", "cycling", "food_events"]
        case .student:
            return ["student-jobs", "libraries", "student-communities", "study-spaces", "student-events", "city-life"]
        case .business:
            return ["help_nearby"]
        case .local:
            return ["help_nearby"]
        case .admin, .general, nil:
            return []
        }
    }

    private func orderedHomeCategories(ids: [String]) -> [HomeCategoryItem] {
        ids.compactMap { id in homeCategories.first(where: { $0.id == id }) }
    }

    private var secondaryTools: [HomeSecondaryTool] {
        [
            HomeSecondaryTool(
                id: "saved",
                title: savedToolTitle,
                subtitle: savedToolSubtitle,
                icon: "bookmark.fill",
                tint: AppColors.dutchOrange,
                tab: .favorites,
                audienceTags: dashboardAudienceTags,
                priority: 1
            ),
            HomeSecondaryTool(
                id: "more",
                title: moreToolTitle,
                subtitle: moreToolSubtitle,
                icon: "ellipsis.circle.fill",
                tint: AppColors.softBlue,
                tab: .more,
                audienceTags: dashboardAudienceTags,
                priority: 2
            )
        ]
    }

    private var defaultHomeCategories: [HomeCategoryItem] {
        HomeDefaultCategoryCatalog.defaultCategories(selectedCityName: cityDashboard.cityName)
    }

    private var activePersonaDashboard: HomePersonaDashboard {
        guard let status = appState.selectedUserStatus else {
            return HomePersonaDashboard(quickActions: [], helpTopics: [], journeys: [], categories: [])
        }
        return dashboard(for: status)
    }

    private func dashboard(for status: UserStatus) -> HomePersonaDashboard {
        switch status {
        case .student:
            return HomePersonaDashboard(
                quickActions: [
                    action("universities", "Universities", "graduationcap.fill", AppColors.emerald, .institutionsList),
                    action("duo", "DUO", "building.columns.fill", AppColors.softBlue, .officialSources),
                    action("student-housing", "Student Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    action("student-transport", "Public Transport Discounts", "tram.fill", AppColors.dutchOrange, .practicalGuide(.transportBasics))
                ],
                helpTopics: [
                    topic("mbo", "MBO", "book.closed.fill", AppColors.emerald, .knm),
                    topic("hbo", "HBO", "books.vertical.fill", AppColors.softBlue, .knm),
                    topic("research-universities", "Research Universities", "building.2.fill", AppColors.violet, .institutionsList),
                    topic("student-finance", "Student Finance", "creditcard.fill", AppColors.dutchOrange, .officialSources),
                    topic("student-insurance", "Student Insurance", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthInsuranceBasics)),
                    topic("dutch-language-courses", "Dutch Language Courses", "text.book.closed.fill", AppColors.routeLine, .languageHub)
                ],
                journeys: [
                    journey(.student, "Student", "DUO, university, housing, insurance, transport, student jobs")
                ],
                categories: [
                    category("student-jobs", "Student Jobs", "briefcase.fill", AppColors.gradWork, .institutionsList),
                    category("libraries", "Libraries", "books.vertical.fill", AppColors.gradEducation, .mapFocus(.education)),
                    category("student-communities", "Student Communities", "person.3.fill", AppColors.gradProvince, .mapFocus(.category(.studentHelp))),
                    category("student-events", "Student Events", "calendar", AppColors.gradTransport, .mapFocus(.city(cityDashboard.cityName))),
                    category("study-spaces", "Study Spaces", "deskclock.fill", AppColors.gradGovernment, .mapFocus(.education)),
                    category("city-life", "City Life", "building.2.fill", AppColors.gradProvince, .mapFocus(.city(cityDashboard.cityName))),
                    category("free-time", "Free Time", "sparkles", AppColors.gradTransport, .mapFocus(.category(.communitySupport)))
                ]
            )
        case .worker, .expat:
            return HomePersonaDashboard(
                quickActions: [
                    action("bsn", "BSN", "person.text.rectangle.fill", AppColors.cyanGlow, .checklistList),
                    action("digid", "DigiD", "lock.shield.fill", AppColors.softBlue, .practicalGuide(.digidSafety)),
                    action("contracts", "Work Contracts", "doc.text.fill", AppColors.violet, .institutionsList),
                    action("taxes", "Taxes", "creditcard.fill", AppColors.dutchOrange, .officialSources)
                ],
                helpTopics: [
                    topic("uwv", "UWV", "building.columns.fill", AppColors.softBlue, .governmentHub),
                    topic("salary", "Salary", "eurosign.circle.fill", AppColors.emerald, .institutionsList),
                    topic("employment-rights", "Employment Rights", "shield.lefthalf.filled", AppColors.violet, .officialSources),
                    topic("health-insurance", "Health Insurance", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthInsuranceBasics)),
                    topic("housing", "Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    topic("transport", "Transport", "tram.fill", AppColors.routeLine, .practicalGuide(.transportBasics))
                ],
                journeys: [
                    journey(status, status == .expat ? "Expat Worker" : "Worker", "BSN, DigiD, work rights, salary, taxes, insurance, pension")
                ],
                categories: [
                    category("pension", "Pension", "chart.line.uptrend.xyaxis", AppColors.gradGovernment, .officialSources),
                    category("worker-training", "Worker Training", "wrench.and.screwdriver.fill", AppColors.gradEducation, .institutionsList)
                ]
            )
        case .refugee, .ukrainian:
            return HomePersonaDashboard(
                quickActions: [
                    action("ind", "IND", "building.columns.fill", AppColors.softBlue, .governmentHub),
                    action("municipality", "Municipality", "building.2.fill", AppColors.cyanGlow, .governmentHub),
                    action("refugee-housing", "Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    action("benefits", "Benefits", "creditcard.fill", AppColors.dutchOrange, .officialSources)
                ],
                helpTopics: [
                    topic("integration", "Integration", "figure.2.arms.open", AppColors.success, .firstSteps),
                    topic("language", "Language", "text.book.closed.fill", AppColors.routeLine, .languageHub),
                    topic("healthcare", "Healthcare", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthcareBasics)),
                    topic("documents", "Documents", "doc.text.fill", AppColors.dutchOrange, .journeyDocuments),
                    topic("work-permissions", "Work Permissions", "briefcase.fill", AppColors.softBlue, .officialSources),
                    topic("education-access", "Education Access", "graduationcap.fill", AppColors.emerald, .knm)
                ],
                journeys: [
                    journey(status, status == .ukrainian ? "Ukrainian Newcomer" : "Refugee", "IND, municipality, housing, benefits, integration, documents")
                ],
                categories: [
                    category("support-organizations", "Support Organizations", "hands.and.sparkles.fill", AppColors.gradDocs, .survivalHub)
                ]
            )
        case .family:
            return HomePersonaDashboard(
                quickActions: [
                    action("schools", "Schools", "graduationcap.fill", AppColors.emerald, .mapFocus(.education)),
                    action("childcare", "Childcare", "figure.and.child.holdinghands", AppColors.softBlue, .institutionsList),
                    action("kinderopvang", "Kinderopvang", "figure.2.and.child.holdinghands", AppColors.violet, .officialSources),
                    action("svb", "SVB", "building.columns.fill", AppColors.dutchOrange, .officialSources)
                ],
                helpTopics: [
                    topic("child-benefits", "Child Benefits", "creditcard.fill", AppColors.dutchOrange, .officialSources),
                    topic("family-housing", "Family Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    topic("healthcare", "Healthcare", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthcareBasics)),
                    topic("activities", "Activities", "calendar", AppColors.routeLine, .mapFocus(.category(.communitySupport))),
                    topic("municipal-services", "Municipal Services", "building.2.fill", AppColors.softBlue, .governmentHub)
                ],
                journeys: [
                    journey(.family, "Family", "Schools, childcare, SVB, benefits, housing, healthcare, activities")
                ],
                categories: []
            )
        case .highlySkilledMigrant:
            return HomePersonaDashboard(
                quickActions: [
                    action("sponsor", "Recognized Sponsor", "checkmark.seal.fill", AppColors.softBlue, .officialSources),
                    action("ind", "IND", "building.columns.fill", AppColors.cyanGlow, .governmentHub),
                    action("bsn-digid", "BSN and DigiD", "person.text.rectangle.fill", AppColors.violet, .checklistList),
                    action("salary-tax", "Salary and Tax", "eurosign.circle.fill", AppColors.dutchOrange, .officialSources)
                ],
                helpTopics: [
                    topic("housing", "Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    topic("insurance", "Health Insurance", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthInsuranceBasics)),
                    topic("family-relocation", "Family Relocation", "person.3.fill", AppColors.softBlue, .statusDirection(.family)),
                    topic("transport", "Transport", "tram.fill", AppColors.routeLine, .practicalGuide(.transportBasics))
                ],
                journeys: [
                    journey(.highlySkilledMigrant, "Highly Skilled Migrant", "Sponsor, IND, BSN, DigiD, salary, tax, housing, family")
                ],
                categories: []
            )
        case .euCitizen:
            return HomePersonaDashboard(
                quickActions: [
                    action("registration", "Municipality Registration", "building.2.fill", AppColors.cyanGlow, .governmentHub),
                    action("bsn", "BSN", "person.text.rectangle.fill", AppColors.softBlue, .checklistList),
                    action("work-rights", "Work Rights", "briefcase.fill", AppColors.violet, .officialSources),
                    action("healthcare", "Healthcare", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthcareBasics))
                ],
                helpTopics: [
                    topic("housing", "Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    topic("taxes", "Taxes", "creditcard.fill", AppColors.dutchOrange, .officialSources),
                    topic("transport", "Transport", "tram.fill", AppColors.routeLine, .practicalGuide(.transportBasics)),
                    topic("municipal-services", "Municipal Services", "building.columns.fill", AppColors.softBlue, .governmentHub)
                ],
                journeys: [
                    journey(.euCitizen, "EU Citizen", "Registration, BSN, work rights, healthcare, housing, taxes")
                ],
                categories: []
            )
        case .tourist:
            return HomePersonaDashboard(
                quickActions: [
                    action("stay-rules", "Stay Rules", "calendar.badge.clock", AppColors.softBlue, .officialSources),
                    action("transport", "Transport", "tram.fill", AppColors.dutchOrange, .practicalGuide(.transportBasics)),
                    action("emergency", "Emergency", "phone.fill", AppColors.error, .emergencyHub),
                    action("places", "Places", "mappin.circle.fill", AppColors.emerald, .mapFocus(.city(cityDashboard.cityName)))
                ],
                helpTopics: [
                    topic("city-life", "City Life", "building.2.fill", AppColors.softBlue, .mapFocus(.city(cityDashboard.cityName))),
                    topic("healthcare", "Healthcare", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthcareBasics)),
                    topic("official-sources", "Official Sources", "checkmark.shield.fill", AppColors.violet, .officialSources)
                ],
                journeys: [
                    journey(.tourist, "Tourist", "Stay rules, transport, emergency help, city places")
                ],
                categories: []
            )
        case .entrepreneur:
            return HomePersonaDashboard(
                quickActions: [
                    action("kvk", "KVK", "building.columns.fill", AppColors.softBlue, .officialSources),
                    action("btw", "VAT", "percent", AppColors.dutchOrange, .officialSources),
                    action("business-banking", "Business Banking", "creditcard.fill", AppColors.emerald, .practicalGuide(.bankingBasics)),
                    action("permits", "Permits", "doc.text.fill", AppColors.violet, .governmentHub)
                ],
                helpTopics: [
                    topic("taxes", "Taxes", "eurosign.circle.fill", AppColors.dutchOrange, .officialSources),
                    topic("insurance", "Insurance", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthInsuranceBasics)),
                    topic("housing", "Housing", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    topic("networking", "Networking", "person.3.fill", AppColors.softBlue, .institutionsList)
                ],
                journeys: [
                    journey(.entrepreneur, "Entrepreneur", "KVK, VAT, banking, permits, tax, insurance")
                ],
                categories: []
            )
        case .lgbtNewcomer:
            return HomePersonaDashboard(
                quickActions: [
                    action("rights", "Rights", "shield.lefthalf.filled", AppColors.softBlue, .lgbtqSupport),
                    action("healthcare", "Healthcare", "cross.case.fill", AppColors.emerald, .practicalGuide(.healthcareBasics)),
                    action("mental-health", "Mental Health", "heart.fill", AppColors.violet, .emotionalSupport),
                    action("community", "Community", "person.3.fill", AppColors.dutchOrange, .lgbtqSupport)
                ],
                helpTopics: [
                    topic("legal-support", "Legal Support", "doc.text.fill", AppColors.softBlue, .officialSources),
                    topic("housing-safety", "Housing Safety", "house.fill", AppColors.violet, .practicalGuide(.housingBasics)),
                    topic("emergency", "Emergency", "phone.fill", AppColors.error, .emergencyHub),
                    topic("municipality", "Municipality", "building.2.fill", AppColors.cyanGlow, .governmentHub)
                ],
                journeys: [
                    journey(.lgbtNewcomer, "LGBT Newcomer", "Safety, rights, healthcare, community, legal support")
                ],
                categories: []
            )
        }
    }

    private func action(_ id: String, _ title: String, _ icon: String, _ accent: Color, _ destination: AppDestination) -> HomeQuickAction {
        HomeQuickAction(
            id: id,
            titleRU: title,
            titleNL: title,
            titleEN: title,
            shortTitleRU: dashboardShortTitle(for: id, fallback: title),
            shortTitleNL: dashboardShortTitle(for: id, fallback: title),
            shortTitleEN: dashboardShortTitle(for: id, fallback: title),
            subtitleRU: dashboardSubtitle(for: id),
            subtitleNL: dashboardSubtitle(for: id),
            subtitleEN: dashboardSubtitle(for: id),
            icon: icon,
            accent: accent,
            destination: destination,
            audienceTags: dashboardAudienceTags,
            priority: dashboardPriority(for: id),
            hidden: false,
            draft: false
        )
    }

    private func topic(_ id: String, _ title: String, _ icon: String, _ tint: Color, _ destination: AppDestination) -> HomeHelpTopic {
        HomeHelpTopic(
            id: id,
            titleEN: title,
            titleNL: title,
            titleRU: title,
            shortTitleEN: dashboardShortTitle(for: id, fallback: title),
            shortTitleNL: dashboardShortTitle(for: id, fallback: title),
            shortTitleRU: dashboardShortTitle(for: id, fallback: title),
            subtitleEN: dashboardSubtitle(for: id),
            subtitleNL: dashboardSubtitle(for: id),
            subtitleRU: dashboardSubtitle(for: id),
            icon: icon,
            tint: tint,
            destination: destination,
            audienceTags: dashboardAudienceTags,
            priority: dashboardPriority(for: id),
            hidden: false,
            draft: false
        )
    }

    private var dashboardAudienceTags: Set<PersonaTag> {
        guard let persona = appState.selectedUserStatus?.personaTag else { return [.universal] }
        return [persona, .universal]
    }

    private func dashboardShortTitle(for id: String, fallback: String) -> String {
        switch id {
        case "ind": return "IND"
        case "municipality", "registration", "municipal-services": return "Municipality"
        case "integration": return "Integration"
        case "language", "dutch-language-courses": return "Language"
        case "healthcare", "health-insurance", "insurance", "student-insurance": return "Healthcare"
        case "documents": return "Documents"
        case "work-permissions", "work-rights": return "Work Permit"
        case "education-access", "schools", "universities", "research-universities": return "Education"
        case "refugee-housing", "housing", "student-housing", "family-housing": return "Housing"
        case "benefits", "child-benefits", "duo", "student-finance": return "Benefits"
        case "student-transport": return "Transport"
        case "recognized-sponsor", "sponsor": return "Sponsor"
        case "business-banking": return "Banking"
        case "mental-health": return "Mental Health"
        case "legal-support": return "Legal"
        case "support-organizations": return "Support"
        case "education-options": return "Education"
        default: return fallback
        }
    }

    private func dashboardSubtitle(for id: String) -> String {
        switch id {
        case "ind": return "Residence and status"
        case "municipality", "registration", "municipal-services": return "Registration and local help"
        case "refugee-housing", "housing", "student-housing", "family-housing": return "Find housing support"
        case "benefits", "child-benefits": return "Payments and allowances"
        case "integration": return "Settle in"
        case "language", "dutch-language-courses": return "Dutch learning"
        case "healthcare", "health-insurance", "insurance", "student-insurance": return "Doctors and insurance"
        case "documents": return "Status and papers"
        case "work-permissions", "work-rights": return "Work rules"
        case "education-access", "education-options", "schools", "universities", "research-universities": return "Study options"
        case "transport", "student-transport": return "Routes and OV"
        case "emergency": return "112 and urgent help"
        case "places", "city-life": return "Nearby places"
        case "stay-rules": return "Short-stay basics"
        case "duo", "student-finance": return "Study finance"
        case "kvk": return "Business registration"
        case "btw", "taxes", "salary-tax": return "Tax basics"
        case "business-banking": return "Business accounts"
        case "permits": return "Local business rules"
        case "sponsor": return "Employer recognition"
        case "rights": return "Safety and rights"
        case "mental-health": return "Support options"
        case "community": return "Safe community"
        case "legal-support": return "Official legal help"
        default: return selectedScenarioTitle
        }
    }

    private func dashboardPriority(for id: String) -> Int {
        switch id {
        case "ind", "municipality", "refugee-housing", "benefits": return 1
        case "transport", "emergency", "stay-rules", "places": return 1
        case "integration", "language", "healthcare", "documents", "work-permissions", "education-access": return 2
        default: return 3
        }
    }

    private func journey(_ status: UserStatus, _ title: String, _ subtitle: String) -> HomePersonaJourney {
        HomePersonaJourney(
            id: status.rawValue,
            titleEN: title,
            titleNL: title,
            titleRU: title,
            subtitleEN: subtitle,
            subtitleNL: subtitle,
            subtitleRU: subtitle,
            icon: status.icon,
            tint: AppColors.cyanGlow,
            destination: .statusDirection(status)
        )
    }

    private func category(
        _ id: String,
        _ title: String,
        _ icon: String,
        _ gradient: [Color],
        _ destination: AppDestination,
        audience: Set<PersonaTag>? = nil,
        priority: Int = 3
    ) -> HomeCategoryItem {
        HomeCategoryItem(
            id: id,
            titleRU: title,
            titleNL: title,
            titleEN: title,
            icon: icon,
            gradient: gradient,
            destination: destination,
            audienceTags: audience ?? Set([appState.selectedUserStatus?.personaTag].compactMap { $0 }),
            priority: priority
        )
    }

    // MARK: - History & Culture Data

    private var historyCultureCards: [HistoryCultureItem] {
        HomeEditorialContentCatalog.historyCultureCards
    }

    // MARK: - News Data

    private var newsItems: [HomeNewsItem] {
        HomeEditorialContentCatalog.newsItems
    }

    // MARK: - Localised strings for new sections

    private var netherlandsMapTitle: String {
        switch lang {
        case .russian: return "Как передвигаться"
        case .dutch: return "Hoe je reist"
        case .english: return "How to get around"
        }
    }

    private var netherlandsMapSubtitle: String {
        switch lang {
        case .russian: return "Карта, транспорт и места рядом в выбранном городе."
        case .dutch: return "Kaart, vervoer en plekken dichtbij in de gekozen stad."
        case .english: return "Map, transport, and nearby places in the selected city."
        }
    }

    private var mapCardTitle: String {
        switch lang {
        case .russian: return "Интерактивная карта"
        case .dutch: return "Interactieve kaart"
        case .english: return "Interactive Map"
        }
    }

    private var mapCardSubtitle: String {
        switch lang {
        case .russian: return "Города, провинции и ближайшая помощь"
        case .dutch: return "Steden, provincies en hulp dichtbij"
        case .english: return "Explore cities, provinces, and nearby services"
        }
    }

    private var exploreMapLabel: String {
        switch lang {
        case .russian: return "Открыть карту"
        case .dutch: return "Open kaart"
        case .english: return "Explore Map"
        }
    }

    private var quickActionsTitle: String {
        switch lang {
        case .russian: return "Быстрые действия"
        case .dutch: return "Snelle acties"
        case .english: return "Quick Actions"
        }
    }

    private var categoriesTitle: String {
        switch lang {
        case .russian: return "Разделы"
        case .dutch: return "Categorieën"
        case .english: return "Categories"
        }
    }

    private var historyAndCultureTitle: String {
        switch lang {
        case .russian: return "История и культура"
        case .dutch: return "Geschiedenis & Cultuur"
        case .english: return "History & Culture"
        }
    }

    private var nearbyAttractionsTitle: String {
        switch lang {
        case .russian: return "Рядом с вами"
        case .dutch: return "Bij jou in de buurt"
        case .english: return "Nearby & Around You"
        }
    }

    private var newsUpdatesTitle: String {
        switch lang {
        case .russian: return "Новости и обновления"
        case .dutch: return "Nieuws & Updates"
        case .english: return "News & Updates"
        }
    }

    private var reviewsFeedbackTitle: String {
        switch lang {
        case .russian: return "Отзывы и пожелания"
        case .dutch: return "Reviews & Feedback"
        case .english: return "Reviews & Feedback"
        }
    }

    private var reviewsFeedbackSubtitle: String {
        switch lang {
        case .russian: return "Расскажите, что помогло — это улучшает гид для всех"
        case .dutch: return "Vertel wat hielp — dit verbetert de gids voor iedereen"
        case .english: return "Tell us what helped — it improves the guide for everyone"
        }
    }

    private var feedbackStorageNotice: String {
        switch lang {
        case .russian: return "Отзыв сохраняется локально с видимым подтверждением."
        case .dutch: return "Feedback wordt lokaal bewaard met zichtbare bevestiging."
        case .english: return "Feedback is saved locally with visible confirmation."
        }
    }

    private var viewAllLabel: String {
        switch lang {
        case .russian: return "Все"
        case .dutch: return "Alles"
        case .english: return "See all"
        }
    }

    private var feedbackPrompt: String {
        switch lang {
        case .russian: return "Я хочу оставить отзыв о приложении YouNew. Что мне следует знать?"
        case .dutch: return "Ik wil feedback geven over de YouNew-app. Wat moet ik weten?"
        case .english: return "I'd like to give feedback about the YouNew app. What should I know?"
        }
    }

    private var cityMoments: [HomeCityMoment] {
        [
            HomeCityMoment(id: "weather", titleRU: "Погода", titleNL: "Weer", titleEN: "Weather", subtitleRU: "Проверьте день перед выходом", subtitleNL: "Check je dag voor vertrek", subtitleEN: "Check your day before leaving", asset: selectedHeroCityAsset, accent: AppColors.softBlue, destination: nil),
            HomeCityMoment(id: "transport", titleRU: "Транспорт", titleNL: "Openbaar vervoer", titleEN: "Transport", subtitleRU: "OV, поезд, велосипед и маршруты рядом", subtitleNL: "OV, trein, fiets en routes dichtbij", subtitleEN: "OV, trains, bikes, and nearby routes", asset: ContentMediaRegistry.transportHero, accent: AppColors.emerald, destination: .practicalGuide(.transportBasics)),
            HomeCityMoment(id: "municipality", titleRU: "Муниципалитет", titleNL: "Gemeente", titleEN: "Municipality", subtitleRU: "Адрес, BSN и городские услуги", subtitleNL: "Adres, BSN en stadsdiensten", subtitleEN: "Address, BSN, and city services", asset: ContentMediaRegistry.municipalityCityHallImage, accent: AppColors.cyanGlow, destination: .governmentHub),
            HomeCityMoment(id: "emergency", titleRU: "Экстренно", titleNL: "Noodhulp", titleEN: "Emergency", subtitleRU: "112 и помощь рядом", subtitleNL: "112 en hulp dichtbij", subtitleEN: "112 and nearby help", asset: premiumLocalImage(id: "premium-home-emergency", localAssetName: "premium_home_emergency", title: "Dutch emergency services"), accent: AppColors.error, destination: .emergencyHub),
            HomeCityMoment(id: "events", titleRU: "События", titleNL: "Evenementen", titleEN: "Events", subtitleRU: "Что происходит в городе", subtitleNL: "Wat er in de stad gebeurt", subtitleEN: "What is happening nearby", asset: selectedHeroCityAsset, accent: AppColors.dutchOrange, destination: .mapFocus(.city(cityDashboard.cityName))),
            HomeCityMoment(id: "tip", titleRU: "Совет дня", titleNL: "Tip van de dag", titleEN: "Local tip", subtitleRU: "Маленький шаг, который поможет сегодня", subtitleNL: "Een kleine stap voor vandaag", subtitleEN: "A small step that helps today", asset: ContentMediaRegistry.officialSourcesHero, accent: AppColors.violet, destination: nil),
            HomeCityMoment(id: "official", titleRU: "Официальные сервисы", titleNL: "Officiële diensten", titleEN: "Official services", subtitleRU: "Источники для проверки следующего шага", subtitleNL: "Bronnen om je volgende stap te controleren", subtitleEN: "Sources to check before your next step", asset: ContentMediaRegistry.officialSourcesHero, accent: AppColors.cyanGlow, destination: .officialSources)
        ]
    }

    private var currentTime: String {
        Self.clockFormatter.string(from: dashboardTimestamp)
    }

    private var fullDate: String {
        switch lang {
        case .russian:
            return Self.russianDateFormatter.string(from: dashboardTimestamp)
        case .dutch:
            return Self.dutchDateFormatter.string(from: dashboardTimestamp)
        case .english:
            return Self.englishDateFormatter.string(from: dashboardTimestamp)
        }
    }

    private var checklistSnapshot: HomeChecklistSnapshot {
        HomeChecklistSnapshot(
            visibleItems: appState.visibleChecklistItems,
            recommendedItems: appState.prioritizedChecklist.recommended
        )
    }

    private var lifeTimelineSteps: [LifeTimelineStep] {
        LifeTimelineBuilder.steps(
            for: appState.selectedUserStatus,
            checklistItems: appState.visibleChecklistItems,
            documents: documentStore.items,
            now: dashboardTimestamp
        )
    }

    private var smartChecklistItems: [ChecklistItem] {
        let recommended = appState.prioritizedChecklist.recommended
            .filter { !$0.isCompleted }
        let fallback = appState.visibleChecklistItems
            .filter { !$0.isCompleted }
            .sorted { lhs, rhs in
                if lhs.priority == rhs.priority {
                    return (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
                }
                return checklistPriorityRank(lhs.priority) < checklistPriorityRank(rhs.priority)
            }
        let items = recommended.isEmpty ? fallback : recommended
        return Array(items.prefix(4))
    }

    private var suggestedDocumentCategories: [DocumentCategory] {
        let timelineCategories = lifeTimelineSteps
            .prefix(4)
            .flatMap(\.requiredDocuments)
        let merged = timelineCategories + documentStore.suggestedCategories(for: appState.selectedUserStatus)
        var seen = Set<DocumentCategory>()
        return merged.filter { category in
            guard !seen.contains(category) else { return false }
            seen.insert(category)
            return true
        }
    }

    private var upcomingDeadlines: [DeadlineReminder] {
        let checklistReminders = appState.visibleChecklistItems.compactMap { item -> DeadlineReminder? in
            guard let dueDate = item.dueDate, !item.isCompleted else { return nil }
            return DeadlineReminder(
                title: item.title(lang),
                detail: item.description(lang),
                possibleDueDate: dueDate,
                institutionName: item.officialSourceName,
                sourceURL: item.officialSourceURL
            )
        }
        return (checklistReminders + MockDeadlinesData.reminders)
            .sorted { ($0.possibleDueDate ?? .distantFuture) < ($1.possibleDueDate ?? .distantFuture) }
    }

    private var nextDeadlineSummary: String {
        guard let date = upcomingDeadlines.first?.possibleDueDate else {
            switch lang {
            case .english: return "none"
            case .dutch: return "geen"
            case .russian: return "нет"
            }
        }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    private func checklistPriorityRank(_ priority: ChecklistPriority) -> Int {
        switch priority {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }

    private func checklistAIPrompt(for item: ChecklistItem) -> String {
        switch lang {
        case .russian:
            return "Мой сценарий: \(statusTitle), город: \(cityName). Объясни checklist-пункт: \(item.title(lang)). Какие документы нужны, какой следующий шаг, какой официальный источник проверить? Не давай юридических гарантий."
        case .dutch:
            return "Mijn scenario: \(statusTitle), stad: \(cityName). Leg checklist-item uit: \(item.title(lang)). Welke documenten zijn nodig, wat is de volgende stap en welke officiële bron moet ik controleren? Geef geen juridische garanties."
        case .english:
            return "My scenario: \(statusTitle), city: \(cityName). Explain this checklist item: \(item.title(lang)). Which documents do I need, what is the next step, and which official source should I check? Do not give legal guarantees."
        }
    }

    private func deadlineAIPrompt(for item: ChecklistItem) -> String {
        let dateText = item.dueDate?.formatted(date: .abbreviated, time: .omitted) ?? localizedText(en: "not selected yet", nl: "nog niet gekozen", ru: "ещё не выбрана")
        switch lang {
        case .russian:
            return "Помоги добавить дедлайн для шага \(item.title(lang)). Текущая дата: \(dateText). Что подготовить и когда поставить напоминание? Используй только осторожную практическую подсказку."
        case .dutch:
            return "Help een deadline toe te voegen voor \(item.title(lang)). Huidige datum: \(dateText). Wat moet ik voorbereiden en wanneer zet ik een reminder? Geef alleen voorzichtige praktische hulp."
        case .english:
            return "Help me add a deadline for \(item.title(lang)). Current date: \(dateText). What should I prepare and when should I set a reminder? Keep it practical and cautious."
        }
    }

    private func deadlineAIPrompt(for reminder: DeadlineReminder) -> String {
        let dateText = reminder.possibleDueDate?.formatted(date: .abbreviated, time: .omitted) ?? localizedText(en: "not selected yet", nl: "nog niet gekozen", ru: "ещё не выбрана")
        switch lang {
        case .russian:
            return "Дедлайн: \(reminder.title), дата: \(dateText), источник: \(reminder.institutionName). Что подготовить и какие документы проверить? Не выдумывай правила."
        case .dutch:
            return "Deadline: \(reminder.title), datum: \(dateText), bron: \(reminder.institutionName). Wat moet ik voorbereiden en welke documenten controleer ik? Verzin geen regels."
        case .english:
            return "Deadline: \(reminder.title), date: \(dateText), source: \(reminder.institutionName). What should I prepare and which documents should I check? Do not invent rules."
        }
    }

    private var visibleHomePartners: ArraySlice<LocalPartner> {
        MockLocalPartnersData.partners(in: appState.selectedCity)
            .sorted { lhs, rhs in
                let leftRank = homePartnerRank(lhs)
                let rightRank = homePartnerRank(rhs)
                if leftRank != rightRank { return leftRank < rightRank }
                return lhs.name < rhs.name
            }
            .prefix(5)
    }

    private func homePartnerRank(_ partner: LocalPartner) -> Int {
        switch partner.plan {
        case .verifiedPartner, .premium:
            return 0
        case .featured, .aiFeatured:
            return 1
        case .sponsoredPlacement:
            return 2
        case .freeListing:
            return 3
        }
    }

    private var recentBookmarks: [String] {
        let topics = appState.visibleRecentlyViewedTopics().prefix(3).map { appState.displayTitle(forRecentlyViewedTopic: $0, language: lang) }
        return topics.isEmpty ? defaultBookmarks : Array(topics)
    }

    private var provinceName: String {
        cityDashboard.province
    }

    private func openTodayPrompt() {
        openAssistantPrompt(todayPrompt)
    }

    private func openAssistantPrompt(_ prompt: String?) {
        LaunchDiagnostics.mark("AI context initialization start")
        appState.pendingAIContext = AIContext(
            screen: .home,
            category: "Personal guide",
            topicTitle: aiNavigatorTitle,
            topicSummary: cityDashboard.aiSummary,
            officialSources: [CityDashboardContentData.officialGuideSource(for: cityDashboard.cityName)],
            lastReviewed: nil,
            userLanguage: lang,
            userSituation: appState.selectedUserStatus?.rawValue,
            selectedCity: cityDashboard.cityName,
            selectedProvince: provinceName,
            savedItemTitles: recentBookmarks + cityDashboard.places.prefix(3).map(\.title) + cityDashboard.travelLinks.prefix(3).map(\.title),
            disclaimer: AISafetyRules.mandatoryDisclaimer(for: lang),
            activePersonaTag: appState.selectedUserStatus?.personaTag,
            personaSearchScope: .currentAndUniversal
        )
        LaunchDiagnostics.mark("AI context initialization end")
        appState.pendingAIPrompt = prompt
        selectedTab = .assistant
    }

    private var cityDescription: String {
        if let city = selectedHeroCity {
            return city.desc(short: true, lang: lang)
        }
        switch lang {
        case .russian: return "\(ProvinceCatalog.localizedCityName(cityDashboard.cityName, lang)): городской гид с отелями, местами, ресторанами, кафе и проверенными ссылками."
        case .dutch: return "\(ProvinceCatalog.localizedCityName(cityDashboard.cityName, lang)): stadsgids met hotels, plekken, restaurants, cafés en gecontroleerde links."
        case .english: return "\(ProvinceCatalog.localizedCityName(cityDashboard.cityName, lang)): city guide with hotels, places, restaurants, cafes, and checked links."
        }
    }

    private var heroPromise: String {
        switch lang {
        case .russian: return "Ваш гид по жизни в Нидерландах"
        case .dutch: return "Uw gids voor het leven in Nederland"
        case .english: return "Your guide to life in the Netherlands"
        }
    }

    private var exploreCityTitle: String {
        switch lang {
        case .russian: return "Открыть город"
        case .dutch: return "Verken stad"
        case .english: return "Explore city"
        }
    }

    private var todayQuestionTitle: String {
        switch lang {
        case .russian: return "Что делать сегодня?"
        case .dutch: return "Wat vandaag?"
        case .english: return "What today?"
        }
    }

    private var startJourneyTitle: String {
        switch lang {
        case .russian: return "Начать путь"
        case .dutch: return "Start route"
        case .english: return "Start journey"
        }
    }

    private var lifeScenariosTitle: String {
        switch lang {
        case .russian: return "Что вам нужно сегодня?"
        case .dutch: return "Wat heeft u vandaag nodig?"
        case .english: return "What do you need today?"
        }
    }

    private var aiNavigatorTitle: String {
        switch lang {
        case .russian: return "AI-навигатор"
        case .dutch: return "AI-navigator"
        case .english: return "AI Navigator"
        }
    }

    private var aiNavigatorSubtitle: String {
        switch lang {
        case .russian: return "Спросите о жизни в Нидерландах и получите следующий шаг"
        case .dutch: return "Vraag over onderwerpen die in YouNew staan"
        case .english: return "Ask about topics covered in YouNew"
        }
    }

    private var todayInCityTitle: String {
        switch lang {
        case .russian: return "Сегодня в моём городе"
        case .dutch: return "Vandaag in mijn stad"
        case .english: return "Today in My City"
        }
    }

    private var myProgressTitle: String {
        switch lang {
        case .russian: return "Мой путь"
        case .dutch: return "Mijn route"
        case .english: return "My Progress"
        }
    }

    private func completedStepsText(_ snapshot: HomeChecklistSnapshot) -> String {
        switch lang {
        case .russian: return "\(snapshot.completedCount) из \(snapshot.totalCount) шагов выполнено"
        case .dutch: return "\(snapshot.completedCount) van \(snapshot.totalCount) stappen klaar"
        case .english: return "\(snapshot.completedCount) of \(snapshot.totalCount) steps completed"
        }
    }

    private func nextStepText(_ snapshot: HomeChecklistSnapshot) -> String {
        let next = snapshot.nextItem?.title(lang) ?? defaultNextStep
        switch lang {
        case .russian: return "Дальше: \(next)"
        case .dutch: return "Volgende stap: \(next)"
        case .english: return "Next: \(next)"
        }
    }

    private var defaultNextStep: String {
        if isTouristMode {
            switch lang {
            case .russian: return "Проверить правила пребывания и транспорт"
            case .dutch: return "Controleer verblijfsregels en vervoer"
            case .english: return "Check stay rules and transport"
            }
        }
        switch lang {
        case .russian: return "Зарегистрировать адрес"
        case .dutch: return "Adres registreren"
        case .english: return "Register your address"
        }
    }

    private func completedJourneyMilestones(_ snapshot: HomeChecklistSnapshot, milestoneTitles: [String]) -> Int {
        guard !milestoneTitles.isEmpty else { return 0 }
        let calculated = Int((snapshot.progress * Double(milestoneTitles.count)).rounded(.up))
        return min(milestoneTitles.count, max(1, calculated))
    }

    private var journeyMilestoneTitles: [String] {
        HomeLocalizedSuggestions.journeyMilestoneTitles(language: lang, isTouristMode: isTouristMode)
    }

    private var defaultBookmarks: [String] {
        HomeLocalizedSuggestions.defaultBookmarks(language: lang, isTouristMode: isTouristMode)
    }

    private var aiQuestionExamples: [String] {
        HomeLocalizedSuggestions.aiQuestionExamples(
            language: lang,
            isTouristMode: isTouristMode,
            cityName: cityDashboard.cityName
        )
    }

    private var todayPrompt: String {
        let snapshot = checklistSnapshot
        let next = snapshot.nextItem?.title(lang) ?? defaultNextStep

        switch lang {
        case .russian: return "Что мне сделать сегодня в \(cityName), если мой следующий шаг: \(next)? Ответь кратко, по шагам, с официальными источниками."
        case .dutch: return "Wat moet ik vandaag doen in \(cityName) als mijn volgende stap is: \(next)? Antwoord kort, stap voor stap, met officiële bronnen."
        case .english: return "What should I do today in \(cityName) if my next step is: \(next)? Answer briefly, step by step, with official sources."
        }
    }

    private var audienceAIPrompt: String {
        switch lang {
        case .russian: return "Мой сценарий: \(selectedScenarioTitle). Я в \(cityDashboard.cityName). Помоги только с информацией для этой категории и общими официальными темами. Не добавляй контент для других категорий."
        case .dutch: return "Mijn route: \(selectedScenarioTitle). Ik ben in \(cityDashboard.cityName). Help alleen met informatie voor deze categorie en algemene officiële onderwerpen. Voeg geen content voor andere categorieën toe."
        case .english: return "My scenario is \(selectedScenarioTitle). I am in \(cityDashboard.cityName). Help only with this category and general official topics. Do not add content for other categories."
        }
    }

    private var disclaimerText: String {
        switch lang {
        case .russian: return "Только для ориентации. Всегда проверяйте официальные источники."
        case .dutch: return "Alleen ter oriëntatie. Controleer altijd officiële bronnen."
        case .english: return "Information only. Always verify with official sources."
        }
    }
}

private struct HomeExploreItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color
    let destination: AppDestination
}

private struct HomePhotoGalleryItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let asset: AppImageAsset?
    let fallbackCategory: PremiumImageFallbackCategory
    let destination: AppDestination
}

#if DEBUG && os(iOS)
private struct HomeViewPreviewContainer: View {
    @StateObject private var appState: AppStateViewModel
    @StateObject private var languageManager: LanguageManager
    @StateObject private var savedItemsStore = SavedItemsStore()
    @StateObject private var documentStore = DocumentStore()
    @StateObject private var router = TabRouter()
    @State private var selectedTab: AppTab = .home

    init(language: AppLanguage, status: UserStatus? = nil, city: String = "Leiden") {
        let manager = LanguageManager()
        manager.appLanguage = language
        _languageManager = StateObject(wrappedValue: manager)

        let state = AppStateViewModel()
        state.selectedUserStatus = status
        state.selectedCity = city
        _appState = StateObject(wrappedValue: state)
    }

    var body: some View {
        NavigationStack {
            HomeView(selectedTab: $selectedTab)
                .navigationDestination(for: AppDestination.self) { destination in
                    AppDestinationView(destination: destination)
                }
        }
        .environmentObject(appState)
        .environmentObject(languageManager)
        .environmentObject(savedItemsStore)
        .environmentObject(documentStore)
        .environmentObject(router)
    }
}

#Preview("Home RU - iPhone 15", traits: .fixedLayout(width: 390, height: 844)) {
    HomeViewPreviewContainer(language: .russian)
        .environment(\.dynamicTypeSize, .large)
        .transaction { $0.animation = nil }
}

#Preview("Home EN - iPhone SE", traits: .fixedLayout(width: 375, height: 667)) {
    HomeViewPreviewContainer(language: .english)
        .environment(\.dynamicTypeSize, .large)
        .transaction { $0.animation = nil }
}

#Preview("Home NL - iPhone 15 Pro Max", traits: .fixedLayout(width: 430, height: 932)) {
    HomeViewPreviewContainer(language: .dutch, city: "Amsterdam")
        .environment(\.dynamicTypeSize, .accessibility2)
        .transaction { $0.animation = nil }
}

#Preview("Home Map Section - iPhone 15", traits: .fixedLayout(width: 390, height: 844)) {
    ZStack {
        GlobalBackgroundView()
        VStack(alignment: .leading, spacing: 16) {
            Text("Netherlands Map")
                .font(.system(size: 26, weight: .semibold, design: .default))
                .foregroundStyle(.white)
            Text("Explore provinces, cities and services through the interactive map.")
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundStyle(Color.white.opacity(0.70))
            HomeRealisticNetherlandsMapSurface(
                title: "Interactive Map",
                subtitle: "Tap a province or city",
                openMapLabel: "Explore Map",
                selectedCity: "Leiden",
                language: .english,
                glowPhase: 0.45,
                onOpenMap: {}
            )
        }
        .padding(.horizontal, 16)
    }
    .environment(\.dynamicTypeSize, .large)
    .transaction { $0.animation = nil }
}
#endif
