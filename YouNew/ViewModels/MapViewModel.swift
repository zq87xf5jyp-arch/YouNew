import Foundation
import MapKit
import CoreLocation
import Combine
#if os(macOS)
import AppKit
#endif

@MainActor
final class MapViewModel: ObservableObject {
    enum QuickFilter: String {
        case emergency
    }

    struct PlaceCluster: Identifiable {
        let id: String
        let coordinate: CLLocationCoordinate2D
        let places: [NearbyPlace]

        var count: Int { places.count }
        var topCategory: PlaceCategory {
            let grouped = Dictionary(grouping: places, by: \.category)
            return grouped.max(by: { $0.value.count < $1.value.count })?.key ?? .communitySupport
        }
    }

    struct RouteHintStep: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
    }

    enum JourneyPreset: String, CaseIterable, Identifiable {
        case bsn = "I need BSN"
        case healthcare = "I need healthcare"
        case legalHelp = "I received a fine"

        var id: String { rawValue }
        var symbol: String {
            switch self {
            case .bsn: return "person.text.rectangle"
            case .healthcare: return "cross.case.fill"
            case .legalHelp: return "doc.text.fill"
            }
        }
        func localized(_ lang: AppLanguage) -> String {
            switch self {
            case .bsn:        return L10n.t("map.preset.bsn", lang)
            case .healthcare: return L10n.t("map.preset.healthcare", lang)
            case .legalHelp:  return L10n.t("map.preset.legal_help", lang)
            }
        }
    }

    enum TravelMode: String, CaseIterable, Identifiable {
        case walking = "Walking"
        case transit = "Transit"
        case cycling = "Cycling"

        var id: String { rawValue }

        var mapsDirectionFlag: String {
            switch self {
            case .walking: return "w"
            case .transit: return "r"
            case .cycling: return "d"
            }
        }

        var symbol: String {
            switch self {
            case .walking: return "figure.walk"
            case .transit: return "tram.fill"
            case .cycling: return "bicycle"
            }
        }
    }

    @Published var selectedCity: String = "Leiden" {
        didSet {
            guard oldValue != selectedCity else { return }
            rebuildCityData()
        }
    }
    @Published var selectedCategory: PlaceCategory? = nil {
        didSet {
            guard oldValue != selectedCategory else { return }
            rebuildFilteredData()
        }
    }
    @Published var selectedQuickFilter: QuickFilter? {
        didSet {
            guard oldValue != selectedQuickFilter else { return }
            rebuildFilteredData()
        }
    }
    @Published var selectedFocus: MapFocus? {
        didSet {
            guard oldValue != selectedFocus else { return }
            rebuildFilteredData()
        }
    }
    @Published var focusedCityId: String?
    @Published var focusedProvinceId: String?
    @Published var focusedPlaceId: String?
    @Published var selectedPlace: NearbyPlace?
    @Published var searchText: String = "" {
        didSet {
            guard oldValue != searchText else { return }
            rebuildFilteredData()
            rebuildSearchSuggestions()
        }
    }
    @Published var recentSearches: [String] = []
    @Published var selectedTravelMode: TravelMode = .cycling
    @Published var activeJourneyPreset: JourneyPreset? {
        didSet {
            guard oldValue != activeJourneyPreset else { return }
            rebuildRouteData()
        }
    }
    @Published var activePersona: PersonaTag? {
        didSet {
            guard oldValue != activePersona else { return }
            rebuildCityData()
            if let selectedCategory, !cityHubPlaces.contains(where: { $0.category == selectedCategory }) {
                self.selectedCategory = nil
            }
            if let selectedPlace, !selectedPlace.isVisible(for: activePersona) {
                self.selectedPlace = nil
            }
        }
    }
    @Published var language: AppLanguage = .english {
        didSet {
            guard oldValue != language else { return }
            rebuildSearchSuggestions()
            rebuildRouteData()
        }
    }
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.1601, longitude: 4.4970), span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18))
    @Published private(set) var cityHubPlaces: [NearbyPlace] = []
    @Published private(set) var filteredPlaces: [NearbyPlace] = []
    @Published private(set) var clusteredPlaces: [PlaceCluster] = []
    @Published private(set) var categoryCounts: [(PlaceCategory, Int)] = []
    @Published private(set) var emergencyCount: Int = 0
    @Published private(set) var searchSuggestions: [String] = []
    @Published private(set) var mapOverlayRouteCoordinates: [CLLocationCoordinate2D] = []
    @Published private(set) var routeHintSteps: [RouteHintStep] = []

    let locationService = LocationService()
    private var cancellables = Set<AnyCancellable>()
    private let recentSearchesKey = "map_recent_searches_v1"
    private let selectedCityKey = "map_selected_city_v1"
    private let selectedCategoryKey = "map_selected_category_v1"
    private let selectedJourneyKey = "map_selected_journey_v1"

    init() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
        if let city = UserDefaults.standard.string(forKey: selectedCityKey),
           MockNearbyPlacesData.supportedCities.contains(city) {
            selectedCity = city
        }
        if let categoryRaw = UserDefaults.standard.string(forKey: selectedCategoryKey) {
            selectedCategory = PlaceCategory(rawValue: categoryRaw)
        }
        if let journeyRaw = UserDefaults.standard.string(forKey: selectedJourneyKey) {
            activeJourneyPreset = JourneyPreset(rawValue: journeyRaw)
        }
        applyCityCenter()
        rebuildCityData()

        locationService.$location
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] location in
                self?.region.center = location.coordinate
            }
            .store(in: &cancellables)

        let cityKey = selectedCityKey
        $selectedCity
            .dropFirst()
            .sink { city in
                UserDefaults.standard.set(city, forKey: cityKey)
            }
            .store(in: &cancellables)

        let categoryKey = selectedCategoryKey
        $selectedCategory
            .dropFirst()
            .sink { category in
                UserDefaults.standard.set(category?.rawValue, forKey: categoryKey)
            }
            .store(in: &cancellables)

        let journeyKey = selectedJourneyKey
        $activeJourneyPreset
            .dropFirst()
            .sink { journey in
                UserDefaults.standard.set(journey?.rawValue, forKey: journeyKey)
            }
            .store(in: &cancellables)
    }

    private func makeFilteredPlaces() -> [NearbyPlace] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return cityHubPlaces.filter { place in
            let matchesQuickFilter = selectedQuickFilter.map { quickFilter in
                switch quickFilter {
                case .emergency:
                    return place.category == .police || place.emergencyNote != nil
                }
            } ?? true
            let matchesFocus = selectedFocus.map { $0.matches(place) } ?? true
            let matchesCategory = selectedCategory == nil || place.category == selectedCategory
            let matchesQuery = query.isEmpty
                || place.name.lowercased().contains(query)
                || place.localizedName(language).lowercased().contains(query)
                || place.localizedDescription(language).lowercased().contains(query)
                || place.localizedUseCase(language).lowercased().contains(query)
                || place.address.lowercased().contains(query)
                || place.category.localized(language).lowercased().contains(query)
            return matchesQuickFilter && matchesFocus && matchesCategory && matchesQuery
        }
    }

    private func makeClusteredPlaces(from places: [NearbyPlace]) -> [PlaceCluster] {
        let cellSize: Double = 0.018
        let grouped = Dictionary(grouping: places) { place -> String in
            let latBucket = Int((place.coordinate.latitude / cellSize).rounded())
            let lonBucket = Int((place.coordinate.longitude / cellSize).rounded())
            return "\(latBucket):\(lonBucket)"
        }

        return grouped.compactMap { key, places in
            guard let first = places.first else { return nil }
            if places.count == 1 {
                return PlaceCluster(id: key, coordinate: first.coordinate, places: places)
            }
            let avgLat = places.map(\.coordinate.latitude).reduce(0, +) / Double(places.count)
            let avgLon = places.map(\.coordinate.longitude).reduce(0, +) / Double(places.count)
            return PlaceCluster(id: key, coordinate: CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon), places: places)
        }
    }

    private func makeCityHubPlaces() -> [NearbyPlace] {
        MockNearbyPlacesData.places.filter {
            $0.city == selectedCity && $0.isVisible(for: activePersona)
        }
    }

    private func makeCategoryCounts() -> [(PlaceCategory, Int)] {
        PlaceCategory.allCases.map { category in
            (category, cityHubPlaces.filter { $0.category == category }.count)
        }.filter { $0.1 > 0 }
    }

    private func makeEmergencyCount() -> Int {
        cityHubPlaces.filter { $0.category == .police || $0.emergencyNote != nil }.count
    }

    func count(for focus: MapFocus) -> Int {
        cityHubPlaces.filter { focus.matches($0) }.count
    }

    private func makeSearchSuggestions() -> [String] {
        let typed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let pool = cityHubPlaces.flatMap { [$0.name, $0.category.localized(language), $0.address] }
        let filtered = typed.isEmpty ? pool : pool.filter { $0.lowercased().contains(typed) }
        return Array(NSOrderedSet(array: filtered)).compactMap { $0 as? String }.prefix(8).map { $0 }
    }

    private func makeMapOverlayRouteCoordinates() -> [CLLocationCoordinate2D] {
        let places = routeFocusPlaces
        guard places.count > 1 else { return [] }
        return places.map(\.coordinate)
    }

    private func makeRouteHintSteps() -> [RouteHintStep] {
        switch activeJourneyPreset {
        case .bsn:
            return [
                RouteHintStep(title: text(en: "Municipality office", nl: "Gemeentekantoor", ru: "Муниципалитет"), subtitle: text(en: "Bring ID and registration documents.", nl: "Neem ID en inschrijvingsdocumenten mee.", ru: "Возьмите ID и документы для регистрации.")),
                RouteHintStep(title: text(en: "BSN onboarding guide", nl: "BSN-startgids", ru: "Гайд по BSN"), subtitle: text(en: "Review process and timing.", nl: "Controleer proces en timing.", ru: "Проверьте процесс и сроки.")),
                RouteHintStep(title: text(en: "Checklist follow-up", nl: "Checklist opvolgen", ru: "Проверить чек-лист"), subtitle: text(en: "Confirm required next actions.", nl: "Bevestig de volgende acties.", ru: "Подтвердите следующие шаги."))
            ]
        case .healthcare:
            return [
                RouteHintStep(title: text(en: "Nearby hospital or GP", nl: "Ziekenhuis of huisarts dichtbij", ru: "Больница или huisarts рядом"), subtitle: text(en: "Use for urgent and non-urgent triage.", nl: "Gebruik dit voor spoed en niet-spoed triage.", ru: "Используйте для срочной и несрочной маршрутизации.")),
                RouteHintStep(title: text(en: "Insurance basics", nl: "Basis zorgverzekering", ru: "Основы страховки"), subtitle: text(en: "Know mandatory coverage rules.", nl: "Ken de verplichte dekkingsregels.", ru: "Проверьте обязательные правила покрытия.")),
                RouteHintStep(title: text(en: "Pharmacy point", nl: "Apotheekpunt", ru: "Аптека"), subtitle: text(en: "Medication and repeat prescriptions.", nl: "Medicatie en herhaalrecepten.", ru: "Лекарства и повторные рецепты."))
            ]
        case .legalHelp:
            return [
                RouteHintStep(title: text(en: "Understand the fine", nl: "Begrijp de boete", ru: "Разобраться со штрафом"), subtitle: text(en: "Read CJIB/legal explanation first.", nl: "Lees eerst CJIB- of juridische uitleg.", ru: "Сначала прочитайте объяснение CJIB или юридический разбор.")),
                RouteHintStep(title: text(en: "Legal help point", nl: "Rechtshulppunt", ru: "Пункт правовой помощи"), subtitle: text(en: "Get first-line guidance in person.", nl: "Krijg eerste hulp ter plaatse.", ru: "Получите первичную консультацию лично.")),
                RouteHintStep(title: text(en: "Prepare response", nl: "Reactie voorbereiden", ru: "Подготовить ответ"), subtitle: text(en: "Use templates and deadline checklist.", nl: "Gebruik sjablonen en deadline-checklist.", ru: "Используйте шаблоны и чек-лист сроков."))
            ]
        case .none:
            return []
        }
    }

    private func text(en: String, nl: String, ru: String) -> String {
        switch language {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private func rebuildCityData() {
        cityHubPlaces = makeCityHubPlaces()
        categoryCounts = makeCategoryCounts()
        emergencyCount = makeEmergencyCount()
        rebuildFilteredData()
        rebuildSearchSuggestions()
        rebuildRouteData()
    }

    private func rebuildFilteredData() {
        let places = makeFilteredPlaces()
        filteredPlaces = places
        clusteredPlaces = makeClusteredPlaces(from: places)
        mapOverlayRouteCoordinates = makeMapOverlayRouteCoordinates()
    }

    private func rebuildSearchSuggestions() {
        searchSuggestions = makeSearchSuggestions()
    }

    private func rebuildRouteData() {
        mapOverlayRouteCoordinates = makeMapOverlayRouteCoordinates()
        routeHintSteps = makeRouteHintSteps()
    }

    func relatedLinks(for place: NearbyPlace) -> [PlaceRelatedLink] {
        if !place.relatedLinks.isEmpty { return place.relatedLinks }
        switch place.category {
        case .municipality, .duo, .uwv, .ind, .transportOffice:
            return [
                PlaceRelatedLink(title: "BSN Guide", subtitle: "Registration essentials", symbol: "person.text.rectangle", destination: .searchList),
                PlaceRelatedLink(title: "Checklist", subtitle: "Required documents", symbol: "checklist", destination: .checklistList)
            ]
        case .healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy, .animalEmergency:
            return [
                PlaceRelatedLink(title: "Healthcare Basics", subtitle: "How NL care system works", symbol: "cross.case.fill", destination: .searchList),
                PlaceRelatedLink(title: "Insurance Basics", subtitle: "Coverage and obligations", symbol: "checkmark.shield", destination: .searchList)
            ]
        case .transport, .bikeRepair:
            return [
                PlaceRelatedLink(title: "OV-Chipkaart", subtitle: "Transit payment basics", symbol: "tram.fill", destination: .searchList),
                PlaceRelatedLink(title: "Transport Fines", subtitle: "Common mistakes and penalties", symbol: "exclamationmark.triangle", destination: .finesList)
            ]
        case .legalHelp, .police:
            return [
                PlaceRelatedLink(title: "Letters", subtitle: "Understand official communication", symbol: "envelope", destination: .lettersList),
                PlaceRelatedLink(title: "Legal Basics", subtitle: "Rights and first actions", symbol: "doc.text.fill", destination: .searchList)
            ]
        case .foodBank, .shelter, .lgbtqSupport:
            return [
                PlaceRelatedLink(title: "Letters", subtitle: "Understand official communication", symbol: "envelope", destination: .lettersList),
                PlaceRelatedLink(title: "Legal Basics", subtitle: "Rights and first actions", symbol: "doc.text.fill", destination: .searchList)
            ]
        case .education, .studentHelp:
            return [
                PlaceRelatedLink(title: "Student Support", subtitle: "Core onboarding topics", symbol: "graduationcap.fill", destination: .searchList)
            ]
        case .library, .communitySupport, .immigrationSupport, .expatCenter:
            return [
                PlaceRelatedLink(title: "City Onboarding", subtitle: "Daily life newcomer guidance", symbol: "map.fill", destination: .searchList),
                PlaceRelatedLink(title: "Institutions", subtitle: "Who handles what", symbol: "building.columns", destination: .institutionsList)
            ]
        }
    }

    func selectPlace(_ place: NearbyPlace) {
        selectedPlace = place
        region.center = place.coordinate
    }

    func selectCluster(_ cluster: PlaceCluster) {
        if cluster.count == 1, let place = cluster.places.first {
            selectPlace(place)
            return
        }
        region.center = cluster.coordinate
        region.span = MKCoordinateSpan(latitudeDelta: max(0.045, region.span.latitudeDelta * 0.65), longitudeDelta: max(0.045, region.span.longitudeDelta * 0.65))
    }

    func commitSearch() {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return }
        recentSearches = [term] + recentSearches.filter { $0.caseInsensitiveCompare(term) != .orderedSame }
        recentSearches = Array(recentSearches.prefix(8))
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    func applyJourneyPreset(_ preset: JourneyPreset) {
        activeJourneyPreset = preset
        selectedFocus = nil
        selectedQuickFilter = nil
        switch preset {
        case .bsn:
            selectedCategory = .municipality
            searchText = PlaceCategory.municipality.localized(language)
        case .healthcare:
            selectedCategory = .healthcare
            searchText = PlaceCategory.healthcare.localized(language)
        case .legalHelp:
            selectedCategory = .legalHelp
            searchText = PlaceCategory.legalHelp.localized(language)
        }
        commitSearch()
    }

    func useMyLocation() {
        switch locationService.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationService.requestLocation()
        case .notDetermined:
            locationService.requestWhenInUsePermission()
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }

    func applyCityCenter() {
        let centers: [String: CLLocationCoordinate2D] = [
            "Amsterdam": CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
            "Rotterdam": CLLocationCoordinate2D(latitude: 51.9225, longitude: 4.4792),
            "Den Haag": CLLocationCoordinate2D(latitude: 52.0705, longitude: 4.3007),
            "Utrecht": CLLocationCoordinate2D(latitude: 52.0907, longitude: 5.1214),
            "Leiden": CLLocationCoordinate2D(latitude: 52.1601, longitude: 4.4970),
            "Eindhoven": CLLocationCoordinate2D(latitude: 51.4416, longitude: 5.4697),
            "Groningen": CLLocationCoordinate2D(latitude: 53.2194, longitude: 6.5665),
            "Maastricht": CLLocationCoordinate2D(latitude: 50.8514, longitude: 5.6910),
            "Haarlem": CLLocationCoordinate2D(latitude: 52.3874, longitude: 4.6462),
            "Arnhem": CLLocationCoordinate2D(latitude: 51.9851, longitude: 5.8987),
            "Nijmegen": CLLocationCoordinate2D(latitude: 51.8126, longitude: 5.8372),
            "Zwolle": CLLocationCoordinate2D(latitude: 52.5168, longitude: 6.0830),
            "Assen": CLLocationCoordinate2D(latitude: 52.9928, longitude: 6.5642),
            "Leeuwarden": CLLocationCoordinate2D(latitude: 53.2012, longitude: 5.7999),
            "Middelburg": CLLocationCoordinate2D(latitude: 51.4988, longitude: 3.6100),
            "Almere": CLLocationCoordinate2D(latitude: 52.3508, longitude: 5.2647)
        ]
        if let center = centers[selectedCity] {
            region.center = center
            region.span = MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
        }
    }

    func clearFilters() {
        selectedFocus = nil
        focusedCityId = nil
        focusedProvinceId = nil
        focusedPlaceId = nil
        selectedCategory = nil
        selectedQuickFilter = nil
    }

    func applyFocus(_ focus: MapFocus) {
        activeJourneyPreset = nil
        focusedCityId = nil
        focusedProvinceId = nil
        focusedPlaceId = nil
        selectedCategory = nil
        selectedQuickFilter = nil
        searchText = ""

        switch focus {
        case .city(let cityId):
            focusedCityId = cityId
            selectedFocus = nil
            if let spotlight = ProvinceCatalog.citySpotlight(matching: cityId),
               MockNearbyPlacesData.supportedCities.contains(spotlight.city.name) {
                selectedCity = spotlight.city.name
                applyCityCenter()
            }
        case .province(let provinceId):
            guard let province = ProvinceCatalog.provinceIfFound(matching: provinceId) else { return }
            focusedProvinceId = province.id
            selectedFocus = nil
            if let city = province.cities.first(where: { MockNearbyPlacesData.supportedCities.contains($0.name) }) {
                selectedCity = city.name
                applyCityCenter()
            }
        case .place(let placeId):
            focusedPlaceId = placeId
            selectedFocus = nil
            if let place = MockNearbyPlacesData.places.first(where: {
                ($0.saveKey == placeId || $0.id.uuidString == placeId) && $0.isVisible(for: activePersona)
            }) {
                selectedCity = place.city
                selectPlace(place)
            }
        case .transport, .healthcare, .government, .education, .emergency:
            selectedFocus = focus
            selectedQuickFilter = focus == .emergency ? .emergency : nil
        case .category(let category):
            selectedFocus = focus
            selectedCategory = category
        }
    }

    func applyProfilePriority(status: UserStatus, availablePlaces: [NearbyPlace]? = nil) {
        let prioritized = MapCategoryPriorityEngine.prioritizedCategories(for: status)
        let pool = availablePlaces ?? cityHubPlaces
        if let firstAvailable = prioritized.first(where: { category in
            pool.contains(where: { $0.category == category })
        }) {
            selectedFocus = nil
            selectedQuickFilter = nil
            selectedCategory = firstAvailable
            return
        }
        selectedFocus = nil
        selectedQuickFilter = nil
        selectedCategory = MapCategoryPriorityEngine.primaryCategory(for: status)
    }

    func openInAppleMaps(_ place: NearbyPlace) {
        let query = place.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Place"
        let urlString: String
        if place.isReferenceLocation {
            urlString = "https://maps.apple.com/?q=\(query)"
        } else {
            urlString = "https://maps.apple.com/?ll=\(place.coordinate.latitude),\(place.coordinate.longitude)&q=\(query)"
        }
        guard let url = AppURL.validatedWebURL(URL(string: urlString)) else { return }
#if os(iOS)
        UIApplication.shared.open(url)
#elseif os(macOS)
        NSWorkspace.shared.open(url)
#endif
    }

    func openInAppleMaps(_ place: NearbyPlace, mode: TravelMode) {
        selectedTravelMode = mode
        let query = place.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Place"
        let urlString: String
        if place.isReferenceLocation {
            urlString = "https://maps.apple.com/?q=\(query)&dirflg=\(mode.mapsDirectionFlag)"
        } else {
            urlString = "https://maps.apple.com/?ll=\(place.coordinate.latitude),\(place.coordinate.longitude)&q=\(query)&dirflg=\(mode.mapsDirectionFlag)"
        }
        guard let url = AppURL.validatedWebURL(URL(string: urlString)) else { return }
#if os(iOS)
        UIApplication.shared.open(url)
#elseif os(macOS)
        NSWorkspace.shared.open(url)
#endif
    }

    func distancePlaceholderText(for place: NearbyPlace) -> String {
        distancePlaceholderText(for: place, language: language)
    }

    func distancePlaceholderText(for place: NearbyPlace, language: AppLanguage) -> String {
        if place.isReferenceLocation {
            switch language {
            case .russian: return "справочный ориентир"
            case .dutch: return "referentiepunt"
            case .english: return "Reference guide"
            }
        }
        let from = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        let to = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        let km = from.distance(from: to) / 1000
        let format: String
        switch language {
        case .russian: format = "примерно %.1f км"
        case .dutch: format = "ca. %.1f km"
        case .english: format = "Approx. %.1f km"
        }
        return String(format: format, km)
    }

    func travelTimePlaceholder(for place: NearbyPlace, mode: TravelMode) -> String {
        travelTimePlaceholder(for: place, mode: mode, language: language)
    }

    func travelTimePlaceholder(for place: NearbyPlace, mode: TravelMode, language: AppLanguage) -> String {
        if place.isReferenceLocation {
            switch language {
            case .russian: return "без расчета расстояния"
            case .dutch: return "geen afstand berekend"
            case .english: return "No distance calculated"
            }
        }
        let from = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        let to = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        let km = from.distance(from: to) / 1000
        let minutes: Double
        switch mode {
        case .walking: minutes = (km / 4.7) * 60
        case .transit: minutes = (km / 22.0) * 60
        case .cycling: minutes = (km / 14.0) * 60
        }
        let rounded = max(4, Int(minutes.rounded()))
        switch language {
        case .russian: return "примерно \(rounded) мин"
        case .dutch: return "ca. \(rounded) min"
        case .english: return "Approx. \(rounded) min"
        }
    }

    private var routeFocusPlaces: [NearbyPlace] {
        switch activeJourneyPreset {
        case .bsn:
            return cityHubPlaces.filter { [.municipality, .immigrationSupport, .expatCenter].contains($0.category) }
        case .healthcare:
            return cityHubPlaces.filter { [.healthcare, .pharmacy].contains($0.category) }
        case .legalHelp:
            return cityHubPlaces.filter { [.legalHelp, .municipality, .police].contains($0.category) }
        case .none:
            return []
        }
    }
}
