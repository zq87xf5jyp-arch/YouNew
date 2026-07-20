import SwiftUI

struct RootHomeView: View {
    @Binding var selectedTab: AppTab
    var onAskAI: () -> Void = {}
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var savedStore: SavedItemsStore
    @EnvironmentObject private var router: TabRouter
    @Environment(\.openDiscoveryMenu) private var openDiscoveryMenu
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHeaderSearchExpanded = false
    @State private var isDeferredHomeContentReady = false
    @StateObject private var connectivity = ConnectivityStatus.shared
    @StateObject private var weatherModel = HomeWeatherModel()
    @StateObject private var leidenCalendarModel = VisitLeidenCalendarModel()
    @StateObject private var placeCountModel = HomePlaceCountModel()
    @StateObject private var businessCountModel = HomeBusinessCountModel()

    private var language: AppLanguage { languageManager.appLanguage }
    private var selectedCity: String { ProvinceCatalog.localizedCityName(appState.selectedCity, language) }
    private var selectedAudience: UserContentCategory? {
        UserContentCategory.from(persona: appState.selectedUserStatus?.personaTag)
    }
    private var dashboardCity: DashboardCity {
        CityDashboardContentData.city(for: appState.selectedCity)
    }
    private var selectedCityID: CityId {
        guard let cityID = CityId.resolve(appState.selectedCity) else {
            preconditionFailure("AppState selectedCity must be a canonical CityId")
        }
        return cityID
    }
    private var personaTags: Set<String> {
        Set([appState.selectedUserStatus?.personaTag.rawValue].compactMap { $0 })
    }
    private var recommendations: [ContentItem] {
        ContentRepository.shared.homeReferences(audienceTags: personaTags, limit: 4)
            .compactMap(ContentRepository.shared.item(id:))
    }
    private var nearbyPlaces: [NearbyPlace] {
        Array(MockNearbyPlacesData.places.filter { $0.city.caseInsensitiveCompare(appState.selectedCity) == .orderedSame }.prefix(3))
    }
    private var allPlacesToVisit: [PlaceItem] {
        let audience = selectedAudience ?? .tourist
        var seen = Set<String>()
        return DashboardPlacesData.visiblePlaces(cityId: appState.selectedCity, audience: audience, limit: nil)
            .filter { place in
                let key = place.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                return seen.insert(key).inserted
            }
    }
    private var placesToVisit: [PlaceItem] {
        Array(allPlacesToVisit.prefix(6))
    }
    private var upcomingEvents: [CalendarEvent] {
        if appState.selectedCity.caseInsensitiveCompare("Leiden") == .orderedSame,
           !leidenCalendarModel.events.isEmpty {
            return Array(leidenCalendarModel.events.prefix(3))
        }
        return DashboardCalendarData.upcomingEvents(cityId: appState.selectedCity, audience: selectedAudience, limit: 3)
    }
    private var todayEvents: [CalendarEvent] {
        let events: [CalendarEvent]
        if appState.selectedCity.caseInsensitiveCompare("Leiden") == .orderedSame,
           !leidenCalendarModel.events.isEmpty {
            events = leidenCalendarModel.events
        } else {
            events = DashboardCalendarData.upcomingEvents(cityId: appState.selectedCity, audience: selectedAudience, limit: nil)
        }
        let today = CalendarEventData.calendar.startOfDay(for: Date())
        return events.filter { event in
            let start = CalendarEventData.calendar.startOfDay(for: event.date)
            let end = CalendarEventData.calendar.startOfDay(for: event.endDate ?? event.date)
            return start <= today && end >= today
        }
    }
    private var synchronizedPlaceCount: Int {
        placeCountModel.count > 0 ? placeCountModel.count : allPlacesToVisit.count
    }
    private var selectedNLCity: NLCity? {
        NLCity.all.first { $0.name.caseInsensitiveCompare(appState.selectedCity) == .orderedSame }
    }
    private var completedJourneySteps: Int {
        appState.visibleChecklistItems.filter(\.isCompleted).count
    }
    private var totalJourneySteps: Int { appState.visibleChecklistItems.count }
    private var journeyProgress: Double? {
        guard totalJourneySteps > 0 else { return nil }
        return Double(completedJourneySteps) / Double(totalJourneySteps)
    }
    private var officialServicesCount: Int { MockExpansionData.officialServices.count }
    private var housingResourcesCount: Int {
        MockExpansionData.knowledgeTopics.filter { $0.category.caseInsensitiveCompare("Housing") == .orderedSame }.count
    }
    private var transportResourcesCount: Int {
        MockExpansionData.officialServices.filter { service in
            service.tags.contains { $0.localizedCaseInsensitiveContains("transport") || $0.localizedCaseInsensitiveContains("OV") }
        }.count
    }
    private var educationResourcesCount: Int {
        MockExpansionData.knowledgeTopics.filter { $0.category.caseInsensitiveCompare("Education") == .orderedSame }.count
            + MockExpansionData.officialServices.filter { service in
                service.tags.contains { $0.localizedCaseInsensitiveContains("education") || $0.localizedCaseInsensitiveContains("student") }
            }.count
    }
    private var museumCount: Int { allPlacesToVisit.filter { $0.category.contains(.museum) }.count }
    private var natureCount: Int { allPlacesToVisit.filter { $0.category.contains(.park) || $0.category.contains(.hiddenGem) }.count }
    private var landmarkCount: Int { allPlacesToVisit.filter { $0.category.contains(.landmark) || $0.category.contains(.historic) }.count }
    @MainActor private var cityHeroAssetName: String {
        let placeID = selectedNLCity?.placeId
        return placeID
            .flatMap(LocalNetherlandsImagePackRegistry.cityHero(placeId:))?
            .localAssetName ?? "home_leiden_canals"
    }
    @MainActor private var cityPreviewAssetName: String? {
        let placeID = selectedNLCity?.placeId
        return placeID.flatMap { placeID in
            LocalNetherlandsImagePackRegistry.cityShortcut(placeId: placeID)?.localAssetName
                ?? LocalNetherlandsImagePackRegistry.cityCard(placeId: placeID)?.localAssetName
        }
    }
    @MainActor private var placePreviews: [HomeInformationPreview] {
        guard let city = selectedNLCity else { return [] }
        var seen = Set<String>()
        return city.attractions.compactMap { attraction in
            let resolved = CanonicalPlaceImageResolver.resolvePlaceImage(place: attraction)
            let identity = resolved.localAssetName ?? resolved.urlString ?? attraction.id
            guard seen.insert(identity).inserted else { return nil }
            return HomeInformationPreview(
                id: attraction.id,
                localAssetName: resolved.localAssetName,
                remoteURL: resolved.url,
                accessibilityLabel: attraction.name
            )
        }
        .prefix(3)
        .map { $0 }
    }
    @MainActor private var discoverPreviews: [HomeInformationPreview] {
        ["Amsterdam", "Rotterdam", "Utrecht"].compactMap { cityName in
            guard let city = NLCity.all.first(where: { $0.name == cityName }),
                  let asset = LocalNetherlandsImagePackRegistry.cityCard(placeId: city.placeId) else { return nil }
            return HomeInformationPreview(id: city.placeId, localAssetName: asset.localAssetName, accessibilityLabel: city.name)
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    Color.clear.frame(height: 1).id("home.top")
                    premiumHeader
                    if isDeferredHomeContentReady {
                        if !connectivity.isOnline {
                            offlineStatus
                        }
                        cityHeader
                        currentProfileSection
                        officialServicesSection
                        placesToVisitSection
                        housingSection
                        transportSection
                        leisureSection
                        educationSection
                        compactAISection
                        localPartnersSection
                        discoverNetherlandsSection
                    }
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
            }
            .scrollContentBackground(.hidden)
            .accessibilityIdentifier("home.scrollContent")
            .safeAreaPadding(.top, 4)
            .onReceive(router.homeScrollTop) {
                withAnimation(.easeInOut(duration: 0.22)) {
                    proxy.scrollTo("home.top", anchor: .top)
                }
            }
        }
        .accessibilityIdentifier("screen.home")
        .task(id: appState.selectedCity) {
            // Publish the lightweight Home shell first. Data-rich sections and
            // refresh work enter on later run-loop turns, after the tab has a
            // visible destination to present.
            await Task.yield()
            guard !Task.isCancelled else { return }
            isDeferredHomeContentReady = true
            await Task.yield()
            guard !Task.isCancelled else { return }

            async let weather: Void = weatherModel.load(
                cityID: appState.selectedCity,
                latitude: dashboardCity.coordinates.lat,
                longitude: dashboardCity.coordinates.lng
            )
            async let calendar: Void = leidenCalendarModel.load(cityID: appState.selectedCity)
            async let places: Void = placeCountModel.load(cityID: appState.selectedCity, localCount: allPlacesToVisit.count)
            async let businesses: Void = businessCountModel.load(cityID: appState.selectedCity, localCount: allHomePartners.count)
            _ = await (weather, calendar, places, businesses)
        }
    }

    private var premiumHeader: some View {
        HStack(spacing: 12) {
            Button { openDiscoveryMenu() } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.stroke, lineWidth: 0.8))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(localized(en: "Open local discovery menu", nl: "Open lokaal ontdekkingsmenu", ru: "Открыть меню мест и событий"))
            .accessibilityIdentifier("home.discoveryMenu")

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    (Text("You").foregroundStyle(AppColors.textPrimary)
                        + Text("New").foregroundStyle(AppColors.dutchOrange))
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                    Text("🇳🇱")
                        .font(.footnote)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(AppColors.glassSurfaceElevated, in: Capsule())
                }
                Text(localized(en: "Your Netherlands guide", nl: "Jouw gids voor Nederland", ru: "Ваш гид по Нидерландам"))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .foregroundStyle(AppColors.textPrimary)
            Spacer(minLength: 8)
            HStack(spacing: 6) {
                if isHeaderSearchExpanded {
                    NavigationLink(value: AppDestination.searchList) {
                        Text(localized(en: "Search all", nl: "Alles zoeken", ru: "Искать везде"))
                            .font(AppTypography.footnoteStrong)
                            .lineLimit(1)
                            .padding(.leading, 10)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                Button {
                    withAnimation(reduceMotion ? nil : AppAnimations.softSpring) {
                        isHeaderSearchExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isHeaderSearchExpanded ? "xmark" : "magnifyingglass")
                        .font(.body.weight(.semibold))
                        .frame(width: 44, height: 44)
                }
                .accessibilityIdentifier("home.globalSearch")
            }
            .background(AppColors.glassSurfaceElevated, in: Capsule())
            .accessibilityLabel(localized(en: "Search", nl: "Zoeken", ru: "Поиск"))
            .buttonStyle(AppPressableButtonStyle())
            NavigationLink(value: AppDestination.profileSelection) {
                Image(systemName: "person.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(colors: [AppColors.dutchOrange, AppColors.routeLine], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: Circle()
                    )
            }
            .accessibilityLabel(localized(en: "Profile", nl: "Profiel", ru: "Профиль"))
            .buttonStyle(AppPressableButtonStyle())
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("home.premiumHeader")
    }

    private var cityHeader: some View {
        ZStack(alignment: .bottomLeading) {
            Image(cityHeroAssetName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, minHeight: 222, maxHeight: 222)
                .clipped()
            LinearGradient(
                colors: [.black.opacity(0.03), AppColors.navyDeep.opacity(0.94)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
            VStack(alignment: .leading, spacing: 10) {
                NavigationLink(value: cityDestination) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(localized(en: "Your city", nl: "Jouw stad", ru: "Ваш город"))
                                    .font(AppTypography.metadata)
                                    .foregroundStyle(.white.opacity(0.72))
                                    .textCase(.uppercase)
                                Text(selectedCity)
                                    .font(.system(size: 31, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            Label(localizedProvinceName(dashboardCity.province), systemImage: "map.fill")
                                .font(AppTypography.metadata)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .background(.black.opacity(0.34), in: Capsule())
                        }

                        weatherLine
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.currentCity")

                HStack(spacing: 8) {
                    heroMetric(
                        value: synchronizedPlaceCount,
                        label: localized(en: "places", nl: "plekken", ru: "мест"),
                        symbol: "mappin.and.ellipse",
                        destination: .placeList(city: selectedCityID),
                        accessibilityIdentifier: "home.categoryChip.city.places"
                    )
                    if !todayEvents.isEmpty {
                        heroMetric(
                            value: todayEvents.count,
                            label: localized(en: "events today", nl: "events vandaag", ru: "событий сегодня"),
                            symbol: "calendar",
                            destination: .eventList(city: selectedCityID),
                            accessibilityIdentifier: "home.categoryChip.city.today"
                        )
                    }
                }

                NavigationLink(value: cityDestination) {
                    HStack(spacing: 6) {
                        Text(localized(en: "Explore \(selectedCity)", nl: "Ontdek \(selectedCity)", ru: "Исследовать \(selectedCity)"))
                        Image(systemName: "arrow.right")
                    }
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
        }
        .frame(height: 222)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppColors.dutchOrange.opacity(0.34), lineWidth: 0.8)
                .allowsHitTesting(false)
        )
    }

    private var cityDestination: AppDestination {
        guard let city = selectedNLCity else {
            preconditionFailure("The selected CityId must resolve to an NLCity")
        }
        return .cityDetail(province: city.province, city: city.name)
    }

    private func heroMetric(
        value: Int,
        label: String,
        symbol: String,
        destination: AppDestination,
        accessibilityIdentifier: String
    ) -> some View {
        NavigationLink(value: destination) {
            Label("\(value) \(label)", systemImage: symbol)
                .font(AppTypography.metadata)
                .foregroundStyle(.white)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(.white.opacity(0.13), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    @ViewBuilder
    private var weatherLine: some View {
        switch weatherModel.phase {
        case .idle, .loading:
            HStack(spacing: 7) {
                ProgressView()
                    .controlSize(.small)
                    .tint(AppColors.warning)
                Text(localized(en: "Loading local weather…", nl: "Lokaal weer laden…", ru: "Загружаем погоду…"))
            }
            .font(AppTypography.footnote)
            .foregroundStyle(AppColors.textSecondary)
        case .loaded(let snapshot, let cached):
            HStack(spacing: 7) {
                Image(systemName: weatherSymbol(code: snapshot.weatherCode, isDay: snapshot.isDay))
                    .symbolRenderingMode(.multicolor)
                Text("\(Int(snapshot.temperature.rounded()))°")
                    .font(AppTypography.body.weight(.bold))
                    .contentTransition(.numericText())
                Text(weatherDescription(code: snapshot.weatherCode))
                    .lineLimit(1)
                Text("· \(Int(snapshot.windSpeed.rounded())) km/h")
                    .foregroundStyle(AppColors.textSecondary)
                if cached {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(AppColors.textSecondary)
                        .accessibilityLabel(localized(en: "Cached weather", nl: "Opgeslagen weer", ru: "Погода из кеша"))
                }
            }
            .font(AppTypography.footnote)
            .foregroundStyle(AppColors.warning)
        case .unavailable:
            Label(
                localized(en: "Weather unavailable · open city details", nl: "Weer niet beschikbaar · open stadsdetails", ru: "Погода недоступна · откройте город"),
                systemImage: "cloud.slash"
            )
            .font(AppTypography.footnote)
            .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var nextEventSubtitle: String {
        guard let event = upcomingEvents.first else {
            return localized(en: "Museums · culture · activities", nl: "Musea · cultuur · activiteiten", ru: "Музеи · культура · события")
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.localeIdentifier)
        formatter.setLocalizedDateFormatFromTemplate("d MMM")
        let title = language == .dutch ? (event.localTitle ?? event.title) : event.title
        return "\(formatter.string(from: event.date)) · \(title)"
    }

    private func weatherSymbol(code: Int, isDay: Bool) -> String {
        switch code {
        case 0: return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 1 ... 3: return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51 ... 67, 80 ... 82: return "cloud.rain.fill"
        case 71 ... 77, 85, 86: return "cloud.snow.fill"
        case 95 ... 99: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }

    private func weatherDescription(code: Int) -> String {
        switch code {
        case 0:
            return localized(en: "Clear", nl: "Helder", ru: "Ясно")
        case 1 ... 3:
            return localized(en: "Partly cloudy", nl: "Halfbewolkt", ru: "Переменная облачность")
        case 45, 48:
            return localized(en: "Fog", nl: "Mist", ru: "Туман")
        case 51 ... 67, 80 ... 82:
            return localized(en: "Rain", nl: "Regen", ru: "Дождь")
        case 71 ... 77, 85, 86:
            return localized(en: "Snow", nl: "Sneeuw", ru: "Снег")
        case 95 ... 99:
            return localized(en: "Thunderstorm", nl: "Onweer", ru: "Гроза")
        default:
            return localized(en: "Weather", nl: "Weer", ru: "Погода")
        }
    }

    private var currentProfileSection: some View {
        premiumInformationSection(
            title: localized(en: "Current profile", nl: "Huidig profiel", ru: "Текущий профиль"),
            symbol: appState.selectedUserStatus?.icon ?? "person.crop.circle.badge.questionmark",
            subtitle: "\(appState.selectedUserStatus?.localized(language) ?? localized(en: "Profile not selected", nl: "Profiel niet gekozen", ru: "Профиль не выбран")) · \(selectedCity)",
            features: [
                HomeInformationFeature(id: "profile.city", selectedCity, symbol: "location.fill", destination: cityDestination),
                HomeInformationFeature(id: "profile.checklist", localized(en: "Personal checklist", nl: "Persoonlijke checklist", ru: "Личный чек-лист"), symbol: "checklist", destination: .checklistList)
            ],
            metric: totalJourneySteps > 0
                ? localized(en: "\(completedJourneySteps) of \(totalJourneySteps) steps complete", nl: "\(completedJourneySteps) van \(totalJourneySteps) stappen voltooid", ru: "\(completedJourneySteps) из \(totalJourneySteps) шагов выполнено")
                : nil,
            callToAction: localized(en: "Open my journey", nl: "Open mijn route", ru: "Открыть мой маршрут"),
            personality: .profile,
            destination: .checklistList,
            accessibilityIdentifier: "home.currentProfile",
            progress: journeyProgress
        )
    }

    private var officialServicesSection: some View {
        premiumInformationSection(
            title: localized(en: "Official Services", nl: "Officiële diensten", ru: "Государственные сервисы"),
            symbol: "building.columns.fill",
            subtitle: localized(en: "Verified Dutch institutions for essential life admin.", nl: "Geverifieerde Nederlandse instanties voor uw administratie.", ru: "Проверенные нидерландские учреждения для важных дел."),
            features: [
                HomeInformationFeature(id: "government.municipality", localized(en: "Municipality", nl: "Gemeente", ru: "Gemeente"), symbol: "building.2.fill", destination: .governmentSection(.municipality)),
                HomeInformationFeature(id: "government.ind", "IND", symbol: "person.text.rectangle.fill", destination: .governmentSection(.ind)),
                HomeInformationFeature(id: "government.digid", "DigiD", symbol: "lock.shield.fill", destination: .governmentSection(.digid)),
                HomeInformationFeature(id: "government.taxes", localized(en: "Taxes", nl: "Belastingen", ru: "Налоги"), symbol: "banknote.fill", destination: .governmentSection(.taxes)),
                HomeInformationFeature(id: "government.healthcare", localized(en: "Healthcare", nl: "Zorg", ru: "Медицина"), symbol: "cross.case.fill", destination: .governmentSection(.healthcare))
            ],
            metric: localized(en: "\(officialServicesCount) official services available", nl: "\(officialServicesCount) officiële diensten beschikbaar", ru: "Доступно официальных сервисов: \(officialServicesCount)"),
            callToAction: localized(en: "Open directory", nl: "Open overzicht", ru: "Открыть каталог"),
            personality: .official,
            destination: .officialSources,
            accessibilityIdentifier: "home.officialServices"
        )
    }

    private var housingSection: some View {
        premiumInformationSection(
            title: localized(en: "Housing", nl: "Wonen", ru: "Жильё"),
            symbol: "house.fill",
            subtitle: localized(en: "Find the right route before signing or paying.", nl: "Kies de juiste route voordat u tekent of betaalt.", ru: "Выберите правильный путь до подписания договора и оплаты."),
            features: [
                HomeInformationFeature(id: "housing.rent", localized(en: "Rent", nl: "Huren", ru: "Аренда"), symbol: "key.fill", destination: .housingSection(.rent)),
                HomeInformationFeature(id: "housing.buy", localized(en: "Buy", nl: "Kopen", ru: "Покупка"), symbol: "house.and.flag.fill", destination: .housingSection(.buy)),
                HomeInformationFeature(id: "housing.studentHousing", localized(en: "Student housing", nl: "Studentenhuisvesting", ru: "Студенческое жильё"), symbol: "graduationcap.fill", destination: .housingSection(.studentHousing)),
                HomeInformationFeature(id: "housing.socialHousing", localized(en: "Social housing", nl: "Sociale huur", ru: "Социальное жильё"), symbol: "person.3.fill", destination: .housingSection(.socialHousing))
            ],
            metric: housingResourcesCount > 0 ? localized(en: "\(housingResourcesCount) trusted resources", nl: "\(housingResourcesCount) betrouwbare bronnen", ru: "Проверенных материалов: \(housingResourcesCount)") : nil,
            callToAction: localized(en: "Explore housing", nl: "Bekijk wonen", ru: "Открыть жильё"),
            personality: .housing,
            destination: .housingSection(.overview),
            accessibilityIdentifier: "home.housing"
        )
    }

    private var placesToVisitSection: some View {
        premiumInformationSection(
            title: localized(en: "Places to Visit", nl: "Plekken om te bezoeken", ru: "Куда сходить"),
            symbol: "mappin.and.ellipse",
            subtitle: upcomingEvents.first.map { _ in localized(en: "Next nearby: \(nextEventSubtitle)", nl: "Binnenkort: \(nextEventSubtitle)", ru: "Ближайшее событие: \(nextEventSubtitle)") },
            features: placeCountFeatures,
            metric: synchronizedPlaceCount == 0 ? nil : localized(en: "\(synchronizedPlaceCount) verified places", nl: "\(synchronizedPlaceCount) geverifieerde plekken", ru: "Проверенных мест: \(synchronizedPlaceCount)"),
            callToAction: localized(en: "Open city map", nl: "Open stadskaart", ru: "Открыть карту"),
            personality: .places,
            destination: .mapHub,
            accessibilityIdentifier: "home.placesToVisit",
            previews: placePreviews
        )
    }

    private var transportSection: some View {
        premiumInformationSection(
            title: localized(en: "Transport", nl: "Vervoer", ru: "Транспорт"),
            symbol: "tram.fill",
            subtitle: localized(en: "Plan, pay and move around the Netherlands.", nl: "Plan, betaal en reis door Nederland.", ru: "Планируйте, оплачивайте и передвигайтесь по Нидерландам."),
            features: [
                HomeInformationFeature(id: "transport.train", localized(en: "Train", nl: "Trein", ru: "Поезд"), symbol: "train.side.front.car", destination: .transportSection(.train)),
                HomeInformationFeature(id: "transport.bus", localized(en: "Bus", nl: "Bus", ru: "Автобус"), symbol: "bus.fill", destination: .transportSection(.bus)),
                HomeInformationFeature(id: "transport.metro", localized(en: "Metro", nl: "Metro", ru: "Метро"), symbol: "tram.fill", destination: .transportSection(.metro)),
                HomeInformationFeature(id: "transport.bike", localized(en: "Bike", nl: "Fiets", ru: "Велосипед"), symbol: "bicycle", destination: .transportSection(.bike)),
                HomeInformationFeature(id: "transport.parking", localized(en: "Parking", nl: "Parkeren", ru: "Парковка"), symbol: "parkingsign.circle.fill", destination: .transportSection(.parking)),
                HomeInformationFeature(id: "transport.journeyPlanner", "9292", symbol: "point.topleft.down.to.point.bottomright.curvepath", destination: .transportSection(.journeyPlanner)),
                HomeInformationFeature(id: "transport.ovChipkaart", "OV-chipkaart", symbol: "creditcard.fill", destination: .transportSection(.ovChipkaart))
            ],
            metric: transportResourcesCount > 0 ? localized(en: "\(transportResourcesCount) verified transport services", nl: "\(transportResourcesCount) geverifieerde vervoersdiensten", ru: "Проверенных транспортных сервисов: \(transportResourcesCount)") : nil,
            callToAction: localized(en: "Plan a journey", nl: "Plan een reis", ru: "Спланировать маршрут"),
            personality: .transport,
            destination: .practicalGuide(.transportBasics),
            accessibilityIdentifier: "home.transport"
        )
    }

    private var leisureSection: some View {
        premiumInformationSection(
            title: localized(en: "Leisure", nl: "Vrije tijd", ru: "Досуг"),
            symbol: "theatermasks.fill",
            subtitle: upcomingEvents.isEmpty ? nil : nextEventSubtitle,
            features: [
                HomeInformationFeature(id: "leisure.museums", localized(en: "Museums", nl: "Musea", ru: "Музеи"), symbol: "building.columns.fill", destination: .museumList(city: selectedCityID)),
                HomeInformationFeature(id: "leisure.events", localized(en: "Events", nl: "Events", ru: "События"), symbol: "calendar.badge.clock", destination: .eventList(city: selectedCityID)),
                HomeInformationFeature(id: "leisure.parks", localized(en: "Parks", nl: "Parken", ru: "Парки"), symbol: "leaf.fill", destination: .natureList(city: selectedCityID)),
                HomeInformationFeature(id: "leisure.nightlife", localized(en: "Nightlife", nl: "Nachtleven", ru: "Ночная жизнь"), symbol: "moon.stars.fill", destination: .leisureSection(city: selectedCityID, type: .nightlife)),
                HomeInformationFeature(id: "leisure.weekend", localized(en: "Weekend ideas", nl: "Weekendideeën", ru: "Идеи на выходные"), symbol: "sparkles", destination: .leisureSection(city: selectedCityID, type: .weekend)),
                HomeInformationFeature(id: "leisure.family", localized(en: "Family", nl: "Familie", ru: "Семьёй"), symbol: "figure.2.and.child.holdinghands", destination: .leisureSection(city: selectedCityID, type: .family))
            ],
            metric: upcomingEvents.isEmpty ? nil : localized(en: "\(upcomingEvents.count) upcoming events", nl: "\(upcomingEvents.count) aankomende events", ru: "Ближайших событий: \(upcomingEvents.count)"),
            callToAction: localized(en: "Find an idea", nl: "Vind een idee", ru: "Найти идею"),
            personality: .leisure,
            destination: .cultureAttractions,
            accessibilityIdentifier: "home.leisure"
        )
    }

    private var educationSection: some View {
        premiumInformationSection(
            title: localized(en: "Education", nl: "Onderwijs", ru: "Образование"),
            symbol: "graduationcap.fill",
            subtitle: localized(en: "Study, finance and build practical Dutch skills.", nl: "Studeren, financieren en praktische Nederlandse vaardigheden opbouwen.", ru: "Учёба, финансирование и практические навыки для жизни."),
            features: [
                HomeInformationFeature(id: "education.universities", localized(en: "Universities", nl: "Universiteiten", ru: "Университеты"), symbol: "building.columns.fill", destination: .educationSection(.universities)),
                HomeInformationFeature(id: "education.duo", "DUO", symbol: "doc.text.fill", destination: .educationSection(.duo)),
                HomeInformationFeature(id: "education.languageSchools", localized(en: "Language schools", nl: "Taalscholen", ru: "Языковые школы"), symbol: "character.book.closed.fill", destination: .educationSection(.languageSchools)),
                HomeInformationFeature(id: "education.drivingSchools", localized(en: "Driving schools", nl: "Rijscholen", ru: "Автошколы"), symbol: "car.fill", destination: .educationSection(.drivingSchools)),
                HomeInformationFeature(id: "education.studentFinance", localized(en: "Student finance", nl: "Studiefinanciering", ru: "Студенческие финансы"), symbol: "eurosign.circle.fill", destination: .educationSection(.studentFinance))
            ],
            metric: educationResourcesCount > 0 ? localized(en: "\(educationResourcesCount) verified education resources", nl: "\(educationResourcesCount) geverifieerde onderwijsbronnen", ru: "Проверенных учебных материалов: \(educationResourcesCount)") : nil,
            callToAction: localized(en: "Explore education", nl: "Bekijk onderwijs", ru: "Открыть образование"),
            personality: .education,
            destination: .institutionsList,
            accessibilityIdentifier: "home.education"
        )
    }

    private var compactAISection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(localized(en: "Ask YouNew", nl: "Vraag YouNew", ru: "Спросите YouNew"))
            HomePremiumInformationCard(
                symbol: "sparkles",
                subtitle: localized(en: "Need help? AI knows the systems newcomers ask about most.", nl: "Hulp nodig? AI kent de systemen waar nieuwkomers het meest naar vragen.", ru: "Нужна помощь? AI знает системы, о которых чаще всего спрашивают новички."),
                features: [
                    HomeInformationFeature(id: "ai.bsn", "BSN", symbol: "number.square.fill", destination: .governmentSection(.municipality)),
                    HomeInformationFeature(id: "ai.digid", "DigiD", symbol: "lock.shield.fill", destination: .governmentSection(.digid)),
                    HomeInformationFeature(id: "ai.housing", localized(en: "Housing", nl: "Wonen", ru: "Жильё"), symbol: "house.fill", destination: .housingSection(.overview)),
                    HomeInformationFeature(id: "ai.healthcare", localized(en: "Healthcare", nl: "Zorg", ru: "Медицина"), symbol: "cross.case.fill", destination: .governmentSection(.healthcare)),
                    HomeInformationFeature(id: "ai.transport", localized(en: "Transport", nl: "Vervoer", ru: "Транспорт"), symbol: "tram.fill", destination: .transportSection(.overview))
                ],
                metric: nil,
                callToAction: localized(en: "Ask YouNew", nl: "Vraag YouNew", ru: "Спросить YouNew"),
                personality: .ai,
                primaryAction: onAskAI,
                primaryAccessibilityIdentifier: "home.compactAI"
            )
        }
    }

    private var localPartnersSection: some View {
        HomeLocalPartnersSection(
            partners: visibleHomePartners,
            language: language,
            totalCount: businessCountModel.verifiedCount,
            accessibilityIdentifier: "home.localPartners.focused"
        )
    }

    private var discoverNetherlandsSection: some View {
        premiumInformationSection(
            title: localized(en: "Discover Netherlands", nl: "Ontdek Nederland", ru: "Откройте Нидерланды"),
            symbol: "sparkles.rectangle.stack.fill",
            subtitle: localized(en: "Seven visual routes into Dutch culture and landscape.", nl: "Zeven visuele routes door Nederlandse cultuur en landschap.", ru: "Семь визуальных маршрутов по культуре и ландшафтам страны."),
            features: discoverFeatures,
            metric: localized(en: "\(NLCity.all.count) cities · \(NLCity.all.flatMap(\.attractions).count) places", nl: "\(NLCity.all.count) steden · \(NLCity.all.flatMap(\.attractions).count) plekken", ru: "Городов: \(NLCity.all.count) · мест: \(NLCity.all.flatMap(\.attractions).count)"),
            callToAction: localized(en: "Start exploring", nl: "Begin met ontdekken", ru: "Начать исследовать"),
            personality: .discover,
            destination: .discoverNetherlands,
            accessibilityIdentifier: "home.discoverNetherlands",
            sectionTitleIdentifier: "home.lastElement",
            previews: discoverPreviews
        )
    }

    private func premiumInformationSection(
        title: String,
        symbol: String,
        subtitle: String?,
        features: [HomeInformationFeature],
        metric: String?,
        callToAction: String,
        personality: HomeInformationPersonality,
        destination: AppDestination,
        accessibilityIdentifier: String,
        sectionTitleIdentifier: String? = nil,
        previews: [HomeInformationPreview] = [],
        progress: Double? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let sectionTitleIdentifier {
                sectionTitle(title)
                    .accessibilityIdentifier(sectionTitleIdentifier)
            } else {
                sectionTitle(title)
            }
            HomePremiumInformationCard(
                symbol: symbol,
                subtitle: subtitle,
                features: features,
                metric: metric,
                callToAction: callToAction,
                personality: personality,
                previews: previews,
                progress: progress,
                primaryDestination: destination,
                primaryAccessibilityIdentifier: accessibilityIdentifier
            )
        }
    }

    private var allHomePartners: [LocalPartner] {
        MockLocalPartnersData.partners(in: appState.selectedCity)
            .sorted { $0.name < $1.name }
    }

    private var visibleHomePartners: ArraySlice<LocalPartner> {
        allHomePartners.prefix(5)
    }

    private var placeCountFeatures: [HomeInformationFeature] {
        var features: [HomeInformationFeature] = []
        if museumCount > 0 {
            features.append(HomeInformationFeature(id: "places.museums", localized(en: "Museums · \(museumCount)", nl: "Musea · \(museumCount)", ru: "Музеи · \(museumCount)"), symbol: "building.columns.fill", destination: .museumList(city: selectedCityID)))
        }
        if natureCount > 0 {
            features.append(HomeInformationFeature(id: "places.nature", localized(en: "Nature · \(natureCount)", nl: "Natuur · \(natureCount)", ru: "Природа · \(natureCount)"), symbol: "leaf.fill", destination: .natureList(city: selectedCityID)))
        }
        if landmarkCount > 0 {
            features.append(HomeInformationFeature(id: "places.landmarks", localized(en: "Landmarks · \(landmarkCount)", nl: "Bezienswaardigheden · \(landmarkCount)", ru: "Достопримечательности · \(landmarkCount)"), symbol: "camera.fill", destination: .landmarkList(city: selectedCityID)))
        }
        if !todayEvents.isEmpty {
            features.append(HomeInformationFeature(id: "places.today", localized(en: "Today · \(todayEvents.count)", nl: "Vandaag · \(todayEvents.count)", ru: "Сегодня · \(todayEvents.count)"), symbol: "calendar", destination: .eventList(city: selectedCityID)))
        }
        return features
    }

    private var discoverFeatures: [HomeInformationFeature] {
        [
            HomeInformationFeature(id: "discover.cities", localized(en: "Cities", nl: "Steden", ru: "Города"), symbol: "building.2.fill", destination: .cityList),
            HomeInformationFeature(id: "discover.museums", localized(en: "Museums", nl: "Musea", ru: "Музеи"), symbol: "building.columns.fill", destination: .museumList(city: selectedCityID)),
            HomeInformationFeature(id: "discover.nature", localized(en: "Nature", nl: "Natuur", ru: "Природа"), symbol: "leaf.fill", destination: .natureList(city: selectedCityID)),
            HomeInformationFeature(id: "discover.architecture", localized(en: "Architecture", nl: "Architectuur", ru: "Архитектура"), symbol: "square.3.layers.3d", destination: .leisureSection(city: selectedCityID, type: .architecture)),
            HomeInformationFeature(id: "discover.history", localized(en: "History", nl: "Geschiedenis", ru: "История"), symbol: "clock.arrow.circlepath", destination: .netherlandsHistory),
            HomeInformationFeature(id: "discover.culture", localized(en: "Culture", nl: "Cultuur", ru: "Культура"), symbol: "theatermasks.fill", destination: .cultureAttractions),
            HomeInformationFeature(id: "discover.seasonal", localized(en: "Seasonal", nl: "Seizoenen", ru: "Сезоны"), symbol: "calendar.badge.clock", destination: .dutchHolidays)
        ]
    }

    private func localizedProvinceName(_ province: String) -> String {
        switch (province, language) {
        case ("Noord-Holland", .russian): return "Северная Голландия"
        case ("Zuid-Holland", .russian): return "Южная Голландия"
        case ("Noord-Brabant", .russian): return "Северный Брабант"
        case ("Noord-Holland", .english): return "North Holland"
        case ("Zuid-Holland", .english): return "South Holland"
        case ("Noord-Brabant", .english): return "North Brabant"
        default: return province
        }
    }

    private var offlineStatus: some View {
        Label(
            localized(en: "Offline · local guides and saved content remain available", nl: "Offline · lokale gidsen en opgeslagen inhoud blijven beschikbaar", ru: "Офлайн · локальные гайды и сохранённое доступны"),
            systemImage: "wifi.slash"
        )
        .font(AppTypography.captionStrong)
        .foregroundStyle(AppColors.warning)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.warning.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityIdentifier("home.offlineStatus")
    }

    private var globalSearch: some View {
        HStack(spacing: 10) {
            NavigationLink(value: AppDestination.searchList) {
                HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.headline.bold())
                Text(localized(en: "Search guides, services and places", nl: "Zoek gidsen, diensten en plekken", ru: "Поиск материалов, сервисов и мест"))
                    .font(AppTypography.body.weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 4)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: onAskAI) {
                Image(systemName: "sparkles")
                    .font(.headline.bold())
                    .foregroundStyle(AppColors.violet)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(localized(en: "Open AI assistant", nl: "Open AI-assistent", ru: "Открыть AI-помощника"))
            .accessibilityHint(localized(en: "Opens the assistant without starting a search", nl: "Opent de assistent zonder te zoeken", ru: "Открывает помощника без запуска поиска"))
            .accessibilityIdentifier("home.aiButton")
        }
        .foregroundStyle(AppColors.textPrimary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .frame(minHeight: 54)
        .appGlassCardStyle(padding: 0, cornerRadius: 18, accent: AppColors.cyanGlow)
    }

    private var urgentHelp: some View {
        NavigationLink(value: AppDestination.emergencyHub) {
            Label(
                localized(en: "Urgent help", nl: "Dringende hulp", ru: "Срочная помощь"),
                systemImage: "cross.case.fill"
            )
            .font(.headline.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(minHeight: 56)
            .background(AppColors.error.gradient, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint(localized(en: "Opens emergency actions and official numbers", nl: "Opent noodacties en officiële nummers", ru: "Открывает экстренные действия и официальные номера"))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("home.urgentHelp")
    }

    private var nextActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(localized(en: "Next actions", nl: "Volgende stappen", ru: "Следующие действия"))
            actionRow("checklist", title: localized(en: "Continue your checklist", nl: "Ga verder met je checklist", ru: "Продолжить чек-лист"), destination: .checklistList)
            actionRow("doc.text.fill", title: localized(en: "Documents and registration", nl: "Documenten en registratie", ru: "Документы и регистрация"), destination: .firstSteps)
        }
    }

    private var categoryShortcuts: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle(localized(en: "Main categories", nl: "Hoofdcategorieën", ru: "Основные категории"))
                Spacer()
                Button {
                    selectedTab = .guide
                } label: {
                    Text(localized(en: "View Guide", nl: "Open Gids", ru: "Открыть Гид"))
                }
                .font(AppTypography.footnote.weight(.semibold))
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 9), GridItem(.flexible(), spacing: 9)], spacing: 9) {
                ForEach(Array(Category.canonical.sorted { $0.displayOrder < $1.displayOrder }.enumerated()), id: \.element.id) { index, category in
                    NavigationLink(value: categoryDestination(category.id)) {
                        HStack(spacing: 10) {
                            Image(systemName: categorySymbol(category.id))
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 31, height: 31)
                                .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            Text(categoryTitle(category))
                                .font(AppTypography.footnote.weight(.semibold))
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 2)
                            Image(systemName: "arrow.up.right")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white.opacity(0.66))
                                .accessibilityHidden(true)
                        }
                        .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                        .padding(.horizontal, 11)
                        .background(
                            LinearGradient(colors: categoryGradient(category.id), startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 15, style: .continuous)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(.white.opacity(0.12)))
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                    .staggeredAppear(index: index)
                }
            }
        }
    }

    private var cityGallery: some View {
        let motionEnabled = !reduceMotion
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle(localized(en: "Netherlands in focus", nl: "Nederland in beeld", ru: "Нидерланды в кадре"))
                Spacer()
                NavigationLink(value: AppDestination.cityList) {
                    Text(localized(en: "View all", nl: "Bekijk alles", ru: "Смотреть всё"))
                        .font(AppTypography.footnote.weight(.semibold))
                }
                .buttonStyle(AppPressableButtonStyle())
            }

            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(PremiumGalleryItem.items) { item in
                        NavigationLink(value: AppDestination.cityList) {
                            ZStack(alignment: .bottomLeading) {
                                Image(item.assetName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 244, height: 154)
                                    .clipped()
                                LinearGradient(colors: [.clear, AppColors.navyDeep.opacity(0.90)], startPoint: .center, endPoint: .bottom)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.title(language))
                                        .font(AppTypography.cardTitle)
                                        .foregroundStyle(.white)
                                    Text(item.subtitle(language))
                                        .font(AppTypography.caption)
                                        .foregroundStyle(.white.opacity(0.76))
                                }
                                .padding(14)
                            }
                            .frame(width: 244, height: 154)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(.white.opacity(0.10)))
                        }
                        .buttonStyle(AppPressableCardButtonStyle())
                        .immersiveTilt(intensity: 2.2)
                        .contextMenu {
                            Button {
                                selectedTab = .map
                            } label: {
                                Label(localized(en: "Open Map", nl: "Open kaart", ru: "Открыть карту"), systemImage: "map")
                            }
                            Button {
                                selectedTab = .guide
                            } label: {
                                Label(localized(en: "Open Guide", nl: "Open gids", ru: "Открыть Гид"), systemImage: "books.vertical")
                            }
                        }
                        .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(motionEnabled ? 1 - abs(phase.value) * 0.06 : 1)
                                .offset(x: motionEnabled ? phase.value * -18 : 0)
                                .opacity(motionEnabled ? 1 - abs(phase.value) * 0.14 : 1)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .accessibilityIdentifier("home.cityGallery")
        }
    }

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle(localized(en: "Useful nearby", nl: "Handig in de buurt", ru: "Полезное рядом"))
                Spacer()
                Button { selectedTab = .map } label: {
                    Text(localized(en: "Open Map", nl: "Open kaart", ru: "Открыть карту"))
                }
                .font(AppTypography.footnote.weight(.semibold))
            }
            if nearbyPlaces.isEmpty {
                emptyRow(localized(en: "Nearby services will appear here.", nl: "Diensten in de buurt verschijnen hier.", ru: "Здесь появятся полезные места и сервисы рядом."))
            } else {
                ForEach(nearbyPlaces) { place in
                    NavigationLink(value: AppDestination.mapFocus(.place(place.saveKey))) {
                        HStack(spacing: 12) {
                            Image(systemName: place.discoverySymbolName)
                                .foregroundStyle(AppColors.cyanGlow)
                                .frame(width: 36, height: 36)
                                .background(AppColors.cyanGlow.opacity(0.12), in: RoundedRectangle(cornerRadius: 11))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(place.localizedName(language))
                                    .font(AppTypography.body.weight(.semibold))
                                    .foregroundStyle(AppColors.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(place.address)
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .lineLimit(2)
                            }
                            Spacer(minLength: 4)
                            Image(systemName: "chevron.right").accessibilityHidden(true)
                        }
                        .padding(13)
                        .appGlassCardStyle(padding: 0, cornerRadius: 17, accent: AppColors.cyanGlow)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var recentlyViewed: some View {
        let topics = appState.visibleRecentlyViewedTopics().prefix(3)
        return Group {
            if !topics.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle(localized(en: "Recently viewed", nl: "Recent bekeken", ru: "Недавно просмотренное"))
                ForEach(Array(topics), id: \.self) { topic in
                    Text(appState.displayTitle(forRecentlyViewedTopic: topic, language: language))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .appGlassCardStyle(padding: 0, cornerRadius: 17, accent: AppColors.softBlue)
                }
            }
        }
    }
    }

    private var savedSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(localized(en: "Saved", nl: "Bewaard", ru: "Сохранённое"))
            Button {
                selectedTab = .saved
            } label: {
                HStack {
                    Label(localized(en: "Saved items", nl: "Bewaarde items", ru: "Сохранённые материалы"), systemImage: "bookmark.fill")
                    Spacer()
                    Text("\(savedStore.savedItems.count)")
                        .font(.headline.monospacedDigit())
                }
                .font(AppTypography.body.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .padding(15)
                .appGlassCardStyle(padding: 0, cornerRadius: 18, accent: AppColors.softBlue)
            }
            .buttonStyle(.plain)
        }
    }

    private var recommendationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(localized(en: "Recommended for you", nl: "Aanbevolen voor jou", ru: "Рекомендовано для вас"))
            ForEach(recommendations) { item in
                if let destination = ContentRepository.shared.legacyDestination(id: item.id) {
                    NavigationLink(value: destination) {
                        recommendationRow(item)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(item.id == recommendations.last?.id ? "home.lastElement" : "home.recommendation.\(item.id)")
                }
            }
        }
    }

    private func recommendationRow(_ item: ContentItem) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item.title)
                .font(AppTypography.body.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(item.shortDescription)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .appGlassCardStyle(padding: 0, cornerRadius: 18, accent: AppColors.violet)
    }

    private func actionRow(_ icon: String, title: String, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
            Label(title, systemImage: icon)
                .font(AppTypography.body.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .appGlassCardStyle(padding: 0, cornerRadius: 17, accent: AppColors.cyanGlow)
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.plain)
    }

    private func emptyRow(_ text: String) -> some View {
        Text(text)
            .font(AppTypography.footnote)
            .foregroundStyle(AppColors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .appGlassCardStyle(padding: 0, cornerRadius: 17, accent: AppColors.softBlue)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
            .foregroundStyle(AppColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func categoryDestination(_ id: String) -> AppDestination {
        switch id {
        case "getting-started": return .firstSteps
        case "housing": return .housingSection(.overview)
        case "official-services": return .governmentSection(.overview)
        case "work-money": return .workSection(.overview)
        case "study": return .educationSection(.overview)
        case "health-safety": return .healthSection(.overview)
        case "transport": return .transportSection(.overview)
        case "explore": return .discoverNetherlands
        default: preconditionFailure("Unknown canonical Home category: \(id)")
        }
    }

    private func categoryTitle(_ category: Category) -> String {
        switch language {
        case .english: return category.title
        case .dutch: return category.localTitle["nl"] ?? category.title
        case .russian: return category.localTitle["ru"] ?? category.title
        }
    }

    private func categorySymbol(_ id: String) -> String {
        switch id {
        case "getting-started": return "figure.walk"
        case "housing": return "house.fill"
        case "official-services": return "building.columns.fill"
        case "work-money": return "briefcase.fill"
        case "study": return "graduationcap.fill"
        case "health-safety": return "cross.case.fill"
        case "transport": return "tram.fill"
        default: return "sailboat.fill"
        }
    }

    private func categoryGradient(_ id: String) -> [Color] {
        switch id {
        case "getting-started": return [AppColors.routeLine, AppColors.accent]
        case "housing": return AppColors.gradHousing
        case "official-services": return AppColors.gradGovernment
        case "work-money": return AppColors.gradWork
        case "study": return AppColors.gradEducation
        case "health-safety": return AppColors.gradHealth
        case "transport": return AppColors.gradTransport
        default: return [AppColors.dutchOrange, AppColors.warning]
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch language {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private struct PremiumGalleryItem: Identifiable {
    let id: String
    let assetName: String
    let enTitle: String
    let nlTitle: String
    let ruTitle: String
    let enSubtitle: String
    let nlSubtitle: String
    let ruSubtitle: String

    func title(_ language: AppLanguage) -> String {
        switch language { case .english: enTitle; case .dutch: nlTitle; case .russian: ruTitle }
    }

    func subtitle(_ language: AppLanguage) -> String {
        switch language { case .english: enSubtitle; case .dutch: nlSubtitle; case .russian: ruSubtitle }
    }

    static let items = [
        PremiumGalleryItem(id: "leiden", assetName: "nl_leiden_hero_01", enTitle: "Leiden", nlTitle: "Leiden", ruTitle: "Лейден", enSubtitle: "Canals and university life", nlSubtitle: "Grachten en studentenleven", ruSubtitle: "Каналы и университетская жизнь"),
        PremiumGalleryItem(id: "amsterdam", assetName: "nl_amsterdam_hero_01", enTitle: "Amsterdam", nlTitle: "Amsterdam", ruTitle: "Амстердам", enSubtitle: "Museums, neighbourhoods and services", nlSubtitle: "Musea, buurten en diensten", ruSubtitle: "Музеи, районы и сервисы"),
        PremiumGalleryItem(id: "rotterdam", assetName: "nl_rotterdam_hero_01", enTitle: "Rotterdam", nlTitle: "Rotterdam", ruTitle: "Роттердам", enSubtitle: "Architecture and working city", nlSubtitle: "Architectuur en werkstad", ruSubtitle: "Архитектура и деловой город")
    ]
}
