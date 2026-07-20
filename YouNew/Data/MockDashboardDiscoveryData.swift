import Foundation
import CoreLocation

/// The single canonical collection of discoverable places.
/// Feature-specific APIs below are adapters over this collection, not copies.
enum CanonicalPlaceCatalog {
    static let items: [PlaceItem] = buildPlaces()

    static func prewarm() {
        _ = items.count
    }

    static func visiblePlaces(cityId: String, audience: UserContentCategory?, limit: Int? = nil) -> [PlaceItem] {
        let visible = items
            .filter { $0.isVisible(cityId: cityId, audience: audience) }
            .sorted { $0.priority == $1.priority ? $0.title < $1.title : $0.priority < $1.priority }
        guard let limit else { return visible }
        return Array(visible.prefix(limit))
    }

    static func detailPlace(id: String) -> PlaceItem? {
        items.first { place in
            place.id == id
                && !place.hidden
                && !place.draft
                && !place.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !place.cityId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !place.audience.isEmpty
                && place.source != nil
                && place.lastChecked?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }
    }

    private static func place(city: NLCity, attraction: Attraction, priority: Int) -> PlaceItem {
        let categories = categories(for: attraction)
        let center = CityNewcomerPlacesData.cityCenter(for: city.name)
        return PlaceItem(
            id: "\(city.id)-\(attraction.id)",
            cityId: city.name,
            section: IASection.infer(from: categories.first ?? .landmark),
            title: attraction.name,
            shortTitle: attraction.name,
            description: attraction.description,
            category: categories,
            audience: [.tourist, .universal, .student, .family, .worker, .refugee, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt],
            address: "\(attraction.location)",
            coordinates: PlaceCoordinate(lat: center.latitude, lng: center.longitude),
            image: attraction.imageURL,
            estimatedVisitTime: nil,
            priceHint: nil,
            indoor: categories.contains(.museum) || categories.contains(.rainyDay),
            goodForRain: categories.contains(.rainyDay),
            familyFriendly: categories.contains(.family) || attraction.type.localizedCaseInsensitiveContains("museum"),
            priority: priority,
            source: CityDashboardContentData.officialGuideSource(for: city.name),
            lastChecked: "June 2026",
            route: "place:\(city.id)-\(attraction.id)",
            externalUrl: nil,
            action: "openPlaceDetail",
            hidden: false,
            draft: false
        )
    }

    private static func buildPlaces() -> [PlaceItem] {
        let seededPlaces = dashboardSeedPlaces()
        let seededKeys = Set(seededPlaces.map { key(cityId: $0.cityId, title: $0.title) })
        let cityPlaces = NLCity.all.flatMap { city in
            city.attractions.enumerated().map { index, attraction in
                place(city: city, attraction: attraction, priority: index + 20)
            }
            .filter { !seededKeys.contains(key(cityId: $0.cityId, title: $0.title)) }
        }

        let cityNamesWithTourismData = Set(NLCity.all.map(\.name))
        let fallbackPlaces = CityNewcomerPlacesData.priorityCities
            .filter { CityId.resolve($0) != nil && !cityNamesWithTourismData.contains($0) }
            .map { fallbackPlace(cityId: $0) }

        return seededPlaces + cityPlaces + fallbackPlaces
    }

    private static func dashboardSeedPlaces() -> [PlaceItem] {
        CityDashboardContentData.supportedCityIds.flatMap { cityId in
            seedPlaces(for: cityId).enumerated().map { index, seed in
                let city = CityDashboardContentData.city(for: cityId)
                let center = CityNewcomerPlacesData.cityCenter(for: city.name)
                return PlaceItem(
                    id: "\(cityId.rawValue)-seed-\(slug(seed.title))",
                    cityId: city.name,
                    section: IASection.infer(from: seed.categories.first ?? .landmark),
                    title: seed.title,
                    shortTitle: seed.shortTitle,
                    description: seed.description,
                    category: seed.categories,
                    audience: [.tourist, .universal, .student, .family, .worker, .refugee, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt],
                    address: seed.address ?? "\(city.name), Netherlands",
                    coordinates: seed.coordinates ?? PlaceCoordinate(lat: center.latitude, lng: center.longitude),
                    image: seed.image,
                    estimatedVisitTime: seed.estimatedVisitTime,
                    priceHint: seed.priceHint,
                    indoor: seed.categories.contains(.museum) || seed.categories.contains(.rainyDay),
                    goodForRain: seed.categories.contains(.rainyDay),
                    familyFriendly: seed.familyFriendly ?? seed.categories.contains(.family),
                    priority: index + 1,
                    source: CityDashboardContentData.officialGuideSource(for: city.name),
                    lastChecked: seed.lastChecked ?? "June 2026",
                    route: "place:\(cityId.rawValue)-seed-\(slug(seed.title))",
                    externalUrl: seed.externalURL,
                    action: "openPlaceDetail",
                    hidden: false,
                    draft: false
                )
            }
        }
    }

    private struct PlaceSeed {
        let title: String
        let shortTitle: String?
        let description: String
        let categories: [VisitPlaceCategory]
        let image: String?
        let address: String?
        let coordinates: PlaceCoordinate?
        let externalURL: URL?
        let estimatedVisitTime: String?
        let priceHint: PlacePriceHint?
        let familyFriendly: Bool?
        let lastChecked: String?
    }

    private static func seedPlaces(for cityId: CityId) -> [PlaceSeed] {
        switch cityId {
        case .amsterdam:
            return [
                seed("Rijksmuseum", "Museumplein museum for Dutch art and history.", [.museum, .rainyDay]),
                seed("Van Gogh Museum", "Museum focused on Van Gogh and related art history.", [.museum, .rainyDay]),
                seed("Anne Frank House", "Historic canal-house museum connected to Anne Frank's story.", [.museum, .historic, .rainyDay]),
                seed("Vondelpark", "Large urban park used for walking, cycling, and relaxing.", [.park, .family]),
                seed("Dam Square", "Central square near major city landmarks and shopping streets.", [.landmark, .historic]),
                seed("Jordaan", "Canal-side neighbourhood known for streets, galleries, and local atmosphere.", [.historic, .hiddenGem]),
                seed("NEMO Science Museum", "Science museum in a recognizable waterfront building.", [.museum, .family, .rainyDay]),
                seed("Albert Cuyp Market", "Street-market area in De Pijp with food and everyday stalls.", [.market, .food]),
                seed("Amsterdam Canals", "Canal-ring area used for orientation, walks, and city views.", [.landmark, .historic])
            ]
        case .rotterdam:
            return [
                seed("Markthal", "Modern market-hall area combining architecture and food stalls.", [.landmark, .market, .food]),
                seed("Erasmus Bridge", "Recognizable bridge and riverfront orientation point.", [.landmark, .viewpoint]),
                seed("Cube Houses", "Architectural landmark near Blaak station.", [.landmark]),
                seed("Museum Boijmans area", "Museumpark cultural area around Boijmans Van Beuningen.", [.museum, .park]),
                seed("Euromast", "Observation-tower landmark in Rotterdam.", [.landmark, .viewpoint]),
                seed("Maritime Museum", "Museum connected to Rotterdam's port and maritime history.", [.museum, .rainyDay]),
                seed("Delfshaven", "Historic harbour neighbourhood with older city streets.", [.historic, .hiddenGem])
            ]
        case .denHaag:
            return [
                seed("Binnenhof area", "Historic government area in the city centre.", [.historic, .landmark]),
                seed("Mauritshuis", "Art museum next to the Binnenhof area.", [.museum, .rainyDay]),
                seed("Scheveningen Beach", "Beach district for sea views, walks, and the promenade.", [.park, .family, .viewpoint]),
                seed("Peace Palace", "International-law landmark in Den Haag.", [.landmark, .historic]),
                seed("Madurodam", "Family-oriented miniature park with Dutch landmarks.", [.family, .landmark]),
                seed("Escher in Het Paleis", "Museum focused on M. C. Escher in a former palace.", [.museum, .rainyDay])
            ]
        case .leiden:
            return [
                seed("Museum De Lakenhal", "Leiden's municipal museum for art, history and the story of the city's cloth industry.", [.museum, .rainyDay], image: "https://upload.wikimedia.org/wikipedia/commons/a/a8/De_Lakenhal_6864.jpg", address: "Oude Singel 32, 2312 RA Leiden", lat: 52.16306, lng: 4.48750, externalURL: "https://www.lakenhal.nl/en", familyFriendly: true),
                seed("Hortus Botanicus", "The Netherlands' oldest botanical garden, founded by Leiden University in 1590.", [.park, .historic, .family], image: "https://commons.wikimedia.org/wiki/Special:FilePath/Hortus%20botanicus%20Leiden%20New%20greenhouse.JPG?width=1600", address: "Rapenburg 73, 2311 GJ Leiden", lat: 52.157094, lng: 4.484522, externalURL: "https://hortusleiden.nl/", familyFriendly: true),
                seed("Burcht van Leiden", "Public hilltop shell keep with panoramic views over Leiden's historic centre.", [.historic, .viewpoint], image: "https://upload.wikimedia.org/wikipedia/commons/f/f5/De_burcht_leiden_2003.jpg", address: "Van der Sterrepad 5, 2312 EK Leiden", lat: 52.15889, lng: 4.49222, externalURL: "https://www.visitleiden.nl/en/what-to-do", familyFriendly: true),
                seed("Rijksmuseum van Oudheden", "National archaeology museum with Egyptian, Roman, Greek and Dutch collections.", [.museum, .rainyDay, .family], image: "https://upload.wikimedia.org/wikipedia/commons/b/b4/Rijksmuseum_van_Oudheden.jpg", address: "Rapenburg 28, 2311 EW Leiden", lat: 52.15833, lng: 4.48583, externalURL: "https://www.rmo.nl/en/", familyFriendly: true),
                seed("Naturalis Biodiversity Center", "National natural-history museum and research centre, home to the T. rex Trix.", [.museum, .rainyDay, .family], address: "Darwinweg 2, 2333 CR Leiden", lat: 52.16472, lng: 4.47333, externalURL: "https://www.naturalis.nl/en", familyFriendly: true),
                seed("Rijksmuseum Boerhaave", "Museum of Dutch science and medicine in a former convent and hospital.", [.museum, .rainyDay, .family], address: "Lange Sint Agnietenstraat 10, 2312 WC Leiden", lat: 52.16139, lng: 4.48889, externalURL: "https://www.rijksmuseumboerhaave.nl/plan-je-bezoek", familyFriendly: true),
                seed("Wereldmuseum Leiden", "Museum of world cultures in the historic National Museum of Ethnology building.", [.museum, .rainyDay, .family], address: "Steenstraat 1B, 2312 BS Leiden", lat: 52.163056, lng: 4.48250, externalURL: "https://leiden.wereldmuseum.nl/en/tickets", familyFriendly: true),
                seed("Molen de Valk", "Working tower windmill museum with seven floors and views across the city.", [.museum, .historic, .viewpoint], image: "https://commons.wikimedia.org/wiki/Special:FilePath/Leiden%2C%20stellingmolen%20De%20Valk%20RM25655%20IMG%209942%202021-08-02%2015.40.jpg?width=1600", address: "Molenwerf 1, 2312 CH Leiden", lat: 52.16454, lng: 4.48984, externalURL: "https://molenmuseumdevalk.nl/", familyFriendly: true),
                seed("Japanmuseum SieboldHuis", "Museum of Japanese art and culture in Philipp Franz von Siebold's former residence.", [.museum, .rainyDay, .hiddenGem], address: "Rapenburg 19, 2311 GE Leiden", lat: 52.15972, lng: 4.48472, externalURL: "https://www.sieboldhuis.org/en/"),
                seed("Pieterskerk Leiden", "Late-Gothic church connected to Leiden University, the Pilgrims and the city's history.", [.historic, .landmark, .rainyDay], image: "https://commons.wikimedia.org/wiki/Special:FilePath/Leiden%3B_Pieterskerk_a.jpg?width=1600", address: "Pieterskerkhof 1A, 2311 SP Leiden", lat: 52.15750, lng: 4.48778, externalURL: "https://pieterskerk.com/en/", familyFriendly: true)
            ]
        case .utrecht:
            return [
                seed("Dom Tower", "Central tower landmark in Utrecht's old town.", [.landmark, .historic, .viewpoint]),
                seed("Oudegracht", "Canal area with wharves through the city centre.", [.historic, .landmark]),
                seed("Museum Speelklok", "Museum focused on self-playing musical instruments.", [.museum, .rainyDay]),
                seed("Centraal Museum", "Museum for art, design, and Utrecht city culture.", [.museum, .rainyDay]),
                seed("Rietveld Schroder House", "Modernist architecture landmark in Utrecht.", [.landmark, .historic])
            ]
        case .eindhoven:
            return [
                seed("Strijp-S", "Former industrial district now used for design, food, and events.", [.landmark, .food]),
                seed("Van Abbemuseum", "Museum for modern and contemporary art.", [.museum, .rainyDay]),
                seed("Philips Museum", "Museum connected to Eindhoven's Philips history.", [.museum, .historic, .rainyDay]),
                seed("Evoluon", "Futuristic landmark building associated with innovation.", [.landmark]),
                seed("Genneper Parken", "Green recreation area with walking routes, sports, and heritage landscapes south of the city centre.", [.park, .family]),
                seed("Downtown Eindhoven", "Central area for shops, restaurants, and city orientation.", [.landmark, .food])
            ]
        case .maastricht:
            return [
                seed("Vrijthof", "Central square surrounded by historic buildings and terraces.", [.landmark, .historic]),
                seed("Basilica of Saint Servatius", "Historic basilica on Vrijthof square.", [.historic, .landmark]),
                seed("Bonnefanten Museum", "Art museum in a distinctive riverside building.", [.museum, .rainyDay]),
                seed("St. Pietersberg Caves", "Cave-area attraction near Maastricht.", [.historic, .hiddenGem]),
                seed("Maastricht old town", "Historic streets and squares in the city centre.", [.historic, .landmark])
            ]
        case .groningen:
            return [
                seed("Martinitoren", "Tower landmark next to the Grote Markt.", [.landmark, .historic, .viewpoint]),
                seed("Groninger Museum", "Museum for art and design near the station.", [.museum, .rainyDay]),
                seed("Noorderplantsoen", "Urban park north of the city centre.", [.park, .family]),
                seed("Grote Markt", "Central market square and orientation point.", [.landmark, .historic]),
                seed("Forum Groningen", "Cultural building with cinema, library, and city views.", [.landmark, .viewpoint, .rainyDay])
            ]
        case .nijmegen:
            return [
                seed("Museum Het Valkhof", "Museum for Nijmegen's Roman and medieval history.", [.museum, .historic, .rainyDay]),
                seed("Waalbrug", "Landmark bridge over the Waal and a city orientation point.", [.landmark, .historic, .viewpoint]),
                seed("Valkhof Park", "Historic hilltop park with Roman and medieval remains.", [.park, .historic, .family, .viewpoint])
            ]
        case .arnhem:
            return [
                seed("John Frost Bridge", "Landmark bridge central to the 1944 Battle of Arnhem.", [.landmark, .historic, .viewpoint]),
                seed("De Hoge Veluwe National Park", "National park with forest, heath, dunes, wildlife, and cycling routes.", [.park, .family, .viewpoint]),
                seed("Kröller-Müller Museum", "Art museum in De Hoge Veluwe with a major Van Gogh collection.", [.museum, .park, .rainyDay])
            ]
        case .delft:
            return [
                seed("Nieuwe Kerk", "Historic church and royal mausoleum on Delft's Markt.", [.landmark, .historic, .viewpoint]),
                seed("Royal Delft", "Historic Delftware factory and visitor centre.", [.museum, .historic, .rainyDay]),
                seed("Prinsenhof Museum", "Museum at the site connected to William of Orange.", [.museum, .historic, .rainyDay]),
                seed("Delftse Hout", "Green recreation area with walking routes and water east of Delft.", [.park, .family])
            ]
        case .haarlem:
            return [
                seed("Frans Hals Museum", "Museum for Dutch Golden Age art in historic Haarlem.", [.museum, .rainyDay]),
                seed("Teylers Museum", "The Netherlands' oldest museum, focused on art and science.", [.museum, .historic, .rainyDay]),
                seed("Sint-Bavokerk", "Gothic church and landmark on Haarlem's Grote Markt.", [.landmark, .historic, .rainyDay]),
                seed("Haarlemmerhout", "Historic urban woodland and park south of Haarlem's centre.", [.park, .family])
            ]
        }
    }

    private static func seed(
        _ title: String,
        _ description: String,
        _ categories: [VisitPlaceCategory],
        image: String? = nil,
        address: String? = nil,
        lat: Double? = nil,
        lng: Double? = nil,
        externalURL: String? = nil,
        estimatedVisitTime: String? = nil,
        priceHint: PlacePriceHint? = nil,
        familyFriendly: Bool? = nil
    ) -> PlaceSeed {
        let coordinates = lat.flatMap { latitude in lng.map { PlaceCoordinate(lat: latitude, lng: $0) } }
        return PlaceSeed(
            title: title,
            shortTitle: title,
            description: description,
            categories: categories,
            image: image,
            address: address,
            coordinates: coordinates,
            externalURL: externalURL.flatMap(URL.init(string:)),
            estimatedVisitTime: estimatedVisitTime,
            priceHint: priceHint,
            familyFriendly: familyFriendly,
            lastChecked: address == nil ? nil : "July 2026"
        )
    }

    private static func fallbackPlace(cityId: String) -> PlaceItem {
        let center = CityNewcomerPlacesData.cityCenter(for: cityId)
        return PlaceItem(
            id: "\(slug(cityId))-city-centre",
            cityId: cityId,
            section: .places,
            title: "\(cityId) city centre",
            shortTitle: "City centre",
            description: "A city-specific starting point for orientation, hotels, restaurants, cafes, visitor information, and local transport.",
            category: [.landmark, .historic],
            audience: [.tourist, .universal, .student, .family, .worker, .refugee, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt],
            address: "\(cityId), Netherlands",
            coordinates: PlaceCoordinate(lat: center.latitude, lng: center.longitude),
            image: nil,
            estimatedVisitTime: nil,
            priceHint: nil,
            indoor: false,
            goodForRain: false,
            familyFriendly: true,
            priority: 1,
            source: CityDashboardContentData.officialGuideSource(for: cityId),
            lastChecked: "June 2026",
            route: "place:\(slug(cityId))-city-centre",
            externalUrl: nil,
            action: "openPlaceDetail",
            hidden: false,
            draft: false
        )
    }

    private static func categories(for attraction: Attraction) -> [VisitPlaceCategory] {
        var categories: [VisitPlaceCategory]
        switch attraction.category {
        case .museums:
            categories = [.museum, .rainyDay]
        case .parks, .nature, .beaches:
            categories = [.park, .family]
        case .historicCentres, .unescoSites, .castles:
            categories = [.historic, .landmark]
        case .hiddenGems:
            categories = [.hiddenGem]
        case .dayTrips:
            categories = [.landmark, .family]
        case .topAttractions:
            categories = [.landmark]
        }

        let lowerType = attraction.type.lowercased()
        if lowerType.contains("market") || lowerType.contains("food") {
            categories.append(.food)
            categories.append(.market)
        }
        if lowerType.contains("view") || lowerType.contains("tower") {
            categories.append(.viewpoint)
        }
        return categories.reduce(into: [VisitPlaceCategory]()) { result, category in
            if !result.contains(category) {
                result.append(category)
            }
        }
    }

    private static func slug(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: " ", with: "-")
    }

    private static func key(cityId: String, title: String) -> String {
        "\(slug(cityId))::\(slug(title))"
    }
}

/// Backwards-compatible feature adapter. New code should depend on
/// `CanonicalPlaceCatalog`; this facade prevents parallel place storage while
/// existing screens migrate incrementally.
enum DashboardPlacesData {
    static var places: [PlaceItem] { CanonicalPlaceCatalog.items }

    static func prewarm() {
        CanonicalPlaceCatalog.prewarm()
    }

    static func visiblePlaces(cityId: String, audience: UserContentCategory?, limit: Int? = nil) -> [PlaceItem] {
        CanonicalPlaceCatalog.visiblePlaces(cityId: cityId, audience: audience, limit: limit)
    }

    static func detailPlace(id: String) -> PlaceItem? {
        CanonicalPlaceCatalog.detailPlace(id: id)
    }
}

enum CityDashboardContentData {
    static let lastChecked = "June 2026"

    static let supportedCityIds: [CityId] = CityId.allCases
    static var supportedCityNames: [String] { supportedCityIds.map(\.displayName) }

    private struct CityDashboardSeed {
        let province: String
        let tags: [String]
        let stats: [CityDashboardStat]
        let municipalityName: String
        let coordinates: DashboardCityCoordinate
        let bookingQuery: String
        let restaurantQuery: String
        let cafeQuery: String
        let placesQuery: String
        let placeSeed: [String]
    }

    private static let citySeeds: [CityId: CityDashboardSeed] = [
        .amsterdam: seed(
            province: "Noord-Holland",
            tags: ["Canals", "Museums", "Cycling", "Nightlife"],
            stats: safeStats(province: "Noord-Holland"),
            municipalityName: "Gemeente Amsterdam",
            lat: 52.3676,
            lng: 4.9041,
            places: ["Rijksmuseum", "Van Gogh Museum", "Anne Frank House", "Vondelpark", "Dam Square", "Jordaan", "NEMO Science Museum", "Albert Cuyp Market", "Amsterdam Canals"]
        ),
        .rotterdam: seed(
            province: "Zuid-Holland",
            tags: ["Architecture", "Harbor", "Food", "Modern city"],
            stats: safeStats(province: "Zuid-Holland"),
            municipalityName: "Gemeente Rotterdam",
            lat: 51.9244,
            lng: 4.4777,
            places: ["Markthal", "Erasmus Bridge", "Cube Houses", "Museum Boijmans area", "Euromast", "Maritime Museum", "Delfshaven"]
        ),
        .denHaag: seed(
            province: "Zuid-Holland",
            tags: ["Beach", "Politics", "Museums", "International city"],
            stats: safeStats(province: "Zuid-Holland"),
            municipalityName: "Gemeente Den Haag",
            lat: 52.0705,
            lng: 4.3007,
            places: ["Binnenhof area", "Mauritshuis", "Scheveningen Beach", "Peace Palace", "Madurodam", "Escher in Het Paleis"]
        ),
        .leiden: seed(
            province: "Zuid-Holland",
            tags: ["History", "University", "Canals", "Museums"],
            stats: safeStats(province: "Zuid-Holland"),
            municipalityName: "Gemeente Leiden",
            lat: 52.1601,
            lng: 4.4970,
            places: ["Museum De Lakenhal", "Hortus Botanicus", "Burcht van Leiden", "Rijksmuseum van Oudheden", "Naturalis Biodiversity Center"]
        ),
        .utrecht: seed(
            province: "Utrecht",
            tags: ["Canals", "Student city", "Dom Tower", "Old town"],
            stats: safeStats(province: "Utrecht"),
            municipalityName: "Gemeente Utrecht",
            lat: 52.0907,
            lng: 5.1214,
            places: ["Dom Tower", "Oudegracht", "Museum Speelklok", "Centraal Museum", "Rietveld Schroder House"]
        ),
        .eindhoven: seed(
            province: "Noord-Brabant",
            tags: ["Design", "Tech", "Innovation", "Nightlife"],
            stats: safeStats(province: "Noord-Brabant"),
            municipalityName: "Gemeente Eindhoven",
            lat: 51.4416,
            lng: 5.4697,
            places: ["Strijp-S", "Van Abbemuseum", "Philips Museum", "Evoluon", "Downtown Eindhoven"]
        ),
        .maastricht: seed(
            province: "Limburg",
            tags: ["History", "Food", "Architecture", "Shopping"],
            stats: safeStats(province: "Limburg"),
            municipalityName: "Gemeente Maastricht",
            lat: 50.8514,
            lng: 5.6910,
            places: ["Vrijthof", "Basilica of Saint Servatius", "Bonnefanten Museum", "St. Pietersberg Caves", "Maastricht old town"]
        ),
        .groningen: seed(
            province: "Groningen",
            tags: ["Student city", "Cycling", "Culture", "Nightlife"],
            stats: safeStats(province: "Groningen"),
            municipalityName: "Gemeente Groningen",
            lat: 53.2194,
            lng: 6.5665,
            places: ["Martinitoren", "Groninger Museum", "Noorderplantsoen", "Grote Markt", "Forum Groningen"]
        ),
        .nijmegen: seed(
            province: "Gelderland",
            tags: ["Roman history", "Student city", "Waal", "Green city"],
            stats: safeStats(province: "Gelderland"),
            municipalityName: "Gemeente Nijmegen",
            lat: 51.8426,
            lng: 5.8528,
            places: ["Museum Het Valkhof", "Waalbrug", "Valkhof Park"]
        ),
        .arnhem: seed(
            province: "Gelderland",
            tags: ["WWII history", "Veluwe", "Nature", "Museums"],
            stats: safeStats(province: "Gelderland"),
            municipalityName: "Gemeente Arnhem",
            lat: 51.9851,
            lng: 5.8987,
            places: ["John Frost Bridge", "De Hoge Veluwe National Park", "Kröller-Müller Museum"]
        ),
        .delft: seed(
            province: "Zuid-Holland",
            tags: ["Vermeer", "Delftware", "Canals", "University"],
            stats: safeStats(province: "Zuid-Holland"),
            municipalityName: "Gemeente Delft",
            lat: 52.0116,
            lng: 4.3571,
            places: ["Nieuwe Kerk", "Royal Delft", "Prinsenhof Museum", "Delftse Hout"]
        ),
        .haarlem: seed(
            province: "Noord-Holland",
            tags: ["Museums", "Historic centre", "Tulip region", "Coast"],
            stats: safeStats(province: "Noord-Holland"),
            municipalityName: "Gemeente Haarlem",
            lat: 52.3873,
            lng: 4.6462,
            places: ["Frans Hals Museum", "Teylers Museum", "Sint-Bavokerk", "Haarlemmerhout"]
        )
    ]

    static func content(for selectedCity: String) -> CityDashboardContent {
        guard let cityID = CityId.resolve(selectedCity) else {
            preconditionFailure("Dashboard content requires an explicit supported city: \(selectedCity)")
        }
        return content(for: cityID)
    }

    static func content(for cityId: CityId) -> CityDashboardContent {
        let dashboardCity = city(for: cityId)
        let city = resolveCity(cityId)
        let places = DashboardPlacesData.visiblePlaces(cityId: dashboardCity.name, audience: .tourist, limit: 10)
        let links = travelLinks(for: dashboardCity)
        return CityDashboardContent(
            city: dashboardCity,
            heroCity: city,
            places: places,
            travelLinks: links,
            aiSummary: aiSummary(city: city, dashboardCity: dashboardCity, places: places, links: links),
            mapFocus: .mapFocus(.city(dashboardCity.name))
        )
    }

    static func resolveCity(_ selectedCity: String) -> NLCity? {
        guard let id = CityId.resolve(selectedCity) else { return nil }
        return resolveCity(id)
    }

    static func resolveCity(_ cityId: CityId) -> NLCity? {
        NLCity.all.first { cityNameMatches($0.name, cityId.displayName) || slug($0.name) == slug(cityId.displayName) }
    }

    static func city(for selectedCity: String) -> DashboardCity {
        guard let cityID = CityId.resolve(selectedCity) else {
            preconditionFailure("Dashboard city requires an explicit supported city: \(selectedCity)")
        }
        return city(for: cityID)
    }

    static func city(for cityId: CityId) -> DashboardCity {
        let cityName = cityId.displayName
        let nlCity = resolveCity(cityId)
        let seed = citySeeds[cityId] ?? fallbackSeed(for: cityId)
        return DashboardCity(
            id: cityId,
            name: cityName,
            province: seed.province,
            country: "NL",
            heroImage: nlCity?.imageURL,
            heroImageDark: nil,
            tags: seed.tags,
            stats: seed.stats,
            coordinates: seed.coordinates,
            municipalityName: seed.municipalityName,
            bookingQuery: seed.bookingQuery,
            restaurantQuery: seed.restaurantQuery,
            cafeQuery: seed.cafeQuery,
            placesQuery: seed.placesQuery,
            placeSeed: seed.placeSeed,
            routeCityId: nlCity?.id ?? cityName
        )
    }

    static func travelLinks(for cityId: String) -> [TravelLinkItem] {
        travelLinks(for: city(for: cityId))
    }

    static func travelLinks(for city: DashboardCity) -> [TravelLinkItem] {
        let bookingLink = bookingExternalLink(for: city)
        return [
            bookingLink.map {
                makeTravelLink(
                    city,
                    .booking,
                    title: "Booking.com",
                    subtitle: "Find hotels and stays",
                    url: $0.url,
                    source: "Booking.com",
                    official: false,
                    priority: 1,
                    externalLink: $0
                )
            },
            link(city, .restaurants, title: "Restaurants", subtitle: "Search restaurants in \(city.name)", url: googleMapsSearchURL(city.restaurantQuery), source: "Google Maps", official: false, priority: 2),
            link(city, .cafes, title: "Cafes", subtitle: "Coffee and breakfast spots", url: googleMapsSearchURL(city.cafeQuery), source: "Google Maps", official: false, priority: 3),
            link(city, .places, title: "Attractions", subtitle: "Museums and places", url: googleMapsSearchURL(city.placesQuery), source: "Google Maps", official: false, priority: 4),
            link(city, .maps, title: "Public transport", subtitle: "Routes and tickets", url: googleMapsSearchURL("public transport routes tickets \(city.name) Netherlands"), source: "Google Maps", official: false, priority: 5),
            link(city, .officialGuide, title: "Official city info", subtitle: "City visitor information", url: officialGuideURL(for: city.id), source: officialGuideLabel(for: city.id), official: true, priority: 6)
        ]
        .compactMap { $0 }
        .filter(travelLinkIsVisible)
        .sorted { $0.priority < $1.priority }
    }

    static func foodGuideItems(for cityId: String, audience: UserContentCategory?, limit: Int? = nil) -> [FoodGuideItem] {
        foodGuideItems(for: city(for: cityId), audience: audience, limit: limit)
    }

    static func foodGuideItems(for city: DashboardCity, audience: UserContentCategory?, limit: Int? = nil) -> [FoodGuideItem] {
        let items = foodGuideSeed(for: city)
            .filter { item in
                foodGuideItemIsVisible(item)
                    && item.audience.contains { category in
                        category == .general || audience == nil || category == audience
                    }
            }
            .sorted { lhs, rhs in
                lhs.priority == rhs.priority ? lhs.title < rhs.title : lhs.priority < rhs.priority
            }
        guard let limit else { return items }
        return Array(items.prefix(limit))
    }

    static func officialGuideSource(for cityId: String) -> OfficialSource {
        let city = city(for: cityId)
        return OfficialSource(
            title: officialGuideLabel(for: city.id),
            url: AppURL.make(officialGuideURL(for: city.id)),
            institution: officialGuideLabel(for: city.id)
        )
    }

    private static func safeStats(province: String) -> [CityDashboardStat] {
        return [
            CityDashboardStat(id: "province", value: province, label: "Province"),
            CityDashboardStat(id: "guide", value: "City", label: "Guide scope"),
            CityDashboardStat(id: "links", value: "Live", label: "Search links")
        ]
    }

    private static func seed(
        province: String,
        tags: [String],
        stats: [CityDashboardStat],
        municipalityName: String,
        lat: Double,
        lng: Double,
        places: [String]
    ) -> CityDashboardSeed {
        let cityName = municipalityName.replacingOccurrences(of: "Gemeente ", with: "")
        return CityDashboardSeed(
            province: province,
            tags: tags,
            stats: stats,
            municipalityName: municipalityName,
            coordinates: DashboardCityCoordinate(lat: lat, lng: lng),
            bookingQuery: "\(cityName), Netherlands",
            restaurantQuery: "restaurants in \(cityName) Netherlands",
            cafeQuery: "cafes in \(cityName) Netherlands",
            placesQuery: "places to visit in \(cityName) Netherlands",
            placeSeed: places
        )
    }

    private static func fallbackSeed(for cityId: CityId) -> CityDashboardSeed {
        let cityName = cityId.displayName
        let center = CityNewcomerPlacesData.cityCenter(for: cityName)
        return CityDashboardSeed(
            province: ProvinceCatalog.provinceID(containingCity: cityName) ?? "Netherlands",
            tags: ["City guide", "Hotels", "Restaurants", "Places"],
            stats: [],
            municipalityName: "Gemeente \(cityName)",
            coordinates: DashboardCityCoordinate(lat: center.latitude, lng: center.longitude),
            bookingQuery: "\(cityName), Netherlands",
            restaurantQuery: "restaurants in \(cityName) Netherlands",
            cafeQuery: "cafes in \(cityName) Netherlands",
            placesQuery: "places to visit in \(cityName) Netherlands",
            placeSeed: ["\(cityName) city centre"]
        )
    }

    private static func aiSummary(city: NLCity?, dashboardCity: DashboardCity, places: [PlaceItem], links: [TravelLinkItem]) -> String {
        let base = city?.desc(short: true, lang: .english) ?? "\(dashboardCity.name) is a Netherlands city in \(dashboardCity.province) with city-specific travel, local-service, and visitor links."
        let placeNames = places.prefix(4).map(\.title).joined(separator: ", ")
        let linkNames = links.prefix(4).map(\.title).joined(separator: ", ")
        return "\(base) Top dashboard places: \(placeNames). Travel links: \(linkNames)."
    }

    static func bookingExternalLink(for city: DashboardCity) -> DashboardExternalLink? {
        guard let url = buildBookingURL(searchQuery: city.bookingQuery) else { return nil }
        return DashboardExternalLink(
            id: "\(city.id.rawValue)-booking-hotels",
            provider: .booking,
            title: "Hotels in \(city.name)",
            url: url,
            cityId: city.id,
            audience: [.tourist],
            category: .hotels,
            source: "Booking.com",
            lastChecked: CityDashboardContentData.lastChecked
        )
    }

    static func buildBookingURL(searchQuery: String) -> URL? {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return nil }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.booking.com"
        components.path = "/searchresults.html"

        var queryItems = [
            URLQueryItem(name: "ss", value: trimmedQuery)
        ]
        if let affiliateID = bookingAffiliateID {
            queryItems.append(URLQueryItem(name: "aid", value: affiliateID))
        }
        components.queryItems = queryItems

        return AppURL.validatedWebURL(components.url)
    }

    private static var bookingAffiliateID: String? {
        let keys = ["YOUNEW_BOOKING_AID", "BOOKING_AID", "BOOKING_AFFILIATE_ID"]
        for key in keys {
            if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String {
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    return trimmed
                }
            }
        }
        return nil
    }

    private static func foodGuideSeed(for city: DashboardCity) -> [FoodGuideItem] {
        if city.id == .leiden {
            return leidenFoodGuideSeed(city)
        }
        let cityName = city.name
        return [
            foodItem(city, .restaurant, title: "Restaurants in \(cityName)", shortTitle: "Restaurants", description: "City-specific restaurant search for \(cityName).", query: city.restaurantQuery, icon: "fork.knife", priority: 1),
            foodItem(city, .cafe, title: "Cafes in \(cityName)", shortTitle: "Cafes", description: "Coffee, cafes, and casual breakfast searches in \(cityName).", query: city.cafeQuery, icon: "cup.and.saucer.fill", priority: 2),
            foodItem(city, .breakfast, title: "Breakfast spots", shortTitle: "Breakfast", description: "Breakfast and brunch search results for \(cityName).", query: "breakfast spots in \(cityName) Netherlands", icon: "sunrise.fill", priority: 3),
            localFoodItem(for: city),
            marketItem(for: city),
            foodItem(city, .vegetarian, title: "Vegetarian / vegan", shortTitle: "Veggie", description: "Vegetarian and vegan searches for \(cityName).", query: "vegetarian vegan restaurants in \(cityName) Netherlands", icon: "leaf.fill", priority: 6),
            foodItem(city, .budget, title: "Budget eats", shortTitle: "Budget", description: "Affordable food searches for \(cityName). Verify details externally.", query: "budget eats in \(cityName) Netherlands", icon: "eurosign.circle.fill", priority: 7),
            foodItem(city, .fineDining, title: "Fine dining", shortTitle: "Fine dining", description: "Fine dining search results for \(cityName). Verify availability and details externally.", query: "fine dining in \(cityName) Netherlands", icon: "sparkles", priority: 8)
        ]
    }

    private static func leidenFoodGuideSeed(_ city: DashboardCity) -> [FoodGuideItem] {
        [
            verifiedFoodItem(city, .restaurant, title: "The Fat Pelican", description: "Dining at Pelikaanstraat 64, listed by the official Visit Leiden food guide.", path: "/en/locations/2763908267/the-fat-pelican", icon: "fork.knife", priority: 1),
            verifiedFoodItem(city, .restaurant, title: "Grand Café Pakhuis", description: "Restaurant at Doelensteeg 8 in central Leiden, listed by Visit Leiden.", path: "/en/locations/998783951/grand-cafe-pakhuis", icon: "fork.knife", priority: 2),
            verifiedFoodItem(city, .fineDining, title: "Trattoria Italiana City Hall", description: "Italian dining at Stadhuisplein 3, listed by the official city guide.", path: "/en/locations/2477913836/city-hall-itilian-bar-bistro", icon: "sparkles", priority: 3),
            verifiedFoodItem(city, .cafe, title: "Hortus Grand Café", description: "Museum-area café at Rapenburg 73 beside Hortus Botanicus.", path: "/en/locations/1038841499/hortus-grand-cafe", icon: "cup.and.saucer.fill", priority: 4),
            verifiedFoodItem(city, .breakfast, title: "Floor's coffee & brunch bar", description: "Coffee and brunch at Doezastraat 1b, included in Visit Leiden's breakfast and lunch tips.", path: "/en/locations/2376533067/floor-s-coffee-brunch-bar", icon: "sunrise.fill", priority: 5),
            verifiedFoodItem(city, .localFood, title: "Lokaliteit De Apotheek", description: "Local food and drinks at Nieuwe Rijn 18, featured by Visit Leiden.", path: "/en/locations/3564071811/lokaliteit-de-apotheek", icon: "takeoutbag.and.cup.and.straw.fill", priority: 6),
            verifiedFoodItem(city, .vegetarian, title: "Official vegan and vegetarian tips", description: "Current plant-based recommendations maintained by Visit Leiden.", path: "/en/what-to-do/food-drinks", icon: "leaf.fill", priority: 7),
            verifiedFoodItem(city, .market, title: "Leiden food & drinks guide", description: "Official city overview for terraces, cafés, restaurants and seasonal tips.", path: "/en/what-to-do/food-drinks", icon: "basket.fill", priority: 8)
        ]
    }

    private static func verifiedFoodItem(
        _ city: DashboardCity,
        _ category: FoodGuideCategory,
        title: String,
        description: String,
        path: String,
        icon: String,
        priority: Int
    ) -> FoodGuideItem {
        let url = AppURL.make("https://www.visitleiden.nl\(path)")
        return FoodGuideItem(
            id: "\(city.id.rawValue)-verified-food-\(priority)",
            cityId: city.id,
            title: title,
            shortTitle: title,
            description: description,
            category: category,
            audience: [.tourist, .general, .student, .business, .local],
            route: nil,
            externalUrl: url,
            query: title,
            icon: icon,
            priority: priority,
            source: OfficialSource(title: "Visit Leiden food guide", url: url, institution: "Visit Leiden"),
            lastChecked: "July 2026",
            hidden: false,
            draft: false
        )
    }

    private static func localFoodItem(for city: DashboardCity) -> FoodGuideItem {
        if city.id == .rotterdam {
            return foodItem(city, .localFood, title: "Harbor food spots", shortTitle: "Local food", description: "City-specific search for harbor-area food and local food spots in Rotterdam.", query: "harbor food spots in Rotterdam Netherlands", icon: "takeoutbag.and.cup.and.straw.fill", priority: 4)
        }
        if city.id == .amsterdam {
            return foodItem(city, .localFood, title: "Local Dutch food", shortTitle: "Local food", description: "Search for Dutch food and local food spots in Amsterdam.", query: "local Dutch food in Amsterdam Netherlands", icon: "takeoutbag.and.cup.and.straw.fill", priority: 4)
        }
        return foodItem(city, .localFood, title: "Local food", shortTitle: "Local food", description: "Local food searches for \(city.name).", query: "local food in \(city.name) Netherlands", icon: "takeoutbag.and.cup.and.straw.fill", priority: 4)
    }

    private static func marketItem(for city: DashboardCity) -> FoodGuideItem {
        if city.id == .rotterdam {
            return foodItem(city, .market, title: "Market Hall area", shortTitle: "Markets", description: "Search the Markthal and nearby food-market area in Rotterdam.", query: "Markthal food market Rotterdam Netherlands", icon: "basket.fill", priority: 5)
        }
        return foodItem(city, .market, title: "Food markets", shortTitle: "Markets", description: "Food market searches for \(city.name).", query: "food markets in \(city.name) Netherlands", icon: "basket.fill", priority: 5)
    }

    private static func foodItem(
        _ city: DashboardCity,
        _ category: FoodGuideCategory,
        title: String,
        shortTitle: String,
        description: String,
        query: String,
        icon: String,
        priority: Int
    ) -> FoodGuideItem {
        let url = googleMapsSearchURL(query)
        return FoodGuideItem(
            id: "\(city.id.rawValue)-food-\(category.rawValue)",
            cityId: city.id,
            title: title,
            shortTitle: shortTitle,
            description: description,
            category: category,
            audience: [.tourist, .general, .student, .business, .local],
            route: nil,
            externalUrl: url,
            query: query,
            icon: icon,
            priority: priority,
            source: url.map { OfficialSource(title: "Google Maps search", url: $0, institution: "Google Maps") },
            lastChecked: CityDashboardContentData.lastChecked,
            hidden: false,
            draft: false
        )
    }

    private static func link(_ city: DashboardCity, _ kind: TravelLinkKind, title: String, subtitle: String, url: String, source: String, official: Bool, priority: Int, externalLink: DashboardExternalLink? = nil) -> TravelLinkItem? {
        guard let safeURL = AppURL.validatedWebURL(URL(string: url)) else { return nil }
        return makeTravelLink(city, kind, title: title, subtitle: subtitle, url: safeURL, source: source, official: official, priority: priority, externalLink: externalLink)
    }

    private static func link(_ city: DashboardCity, _ kind: TravelLinkKind, title: String, subtitle: String, url: URL?, source: String, official: Bool, priority: Int, externalLink: DashboardExternalLink? = nil) -> TravelLinkItem? {
        guard let safeURL = AppURL.validatedWebURL(url) else { return nil }
        return makeTravelLink(city, kind, title: title, subtitle: subtitle, url: safeURL, source: source, official: official, priority: priority, externalLink: externalLink)
    }

    private static func makeTravelLink(_ city: DashboardCity, _ kind: TravelLinkKind, title: String, subtitle: String, url: URL, source: String, official: Bool, priority: Int, externalLink: DashboardExternalLink? = nil) -> TravelLinkItem {
        let resolvedExternalLink = externalLink ?? dashboardExternalLink(city, kind, title: title, url: url, source: source)
        return TravelLinkItem(
            id: "\(city.id.rawValue)-\(kind.rawValue)",
            cityId: city.id.rawValue,
            kind: kind,
            title: title,
            subtitle: subtitle,
            url: url,
            sourceLabel: source,
            isOfficial: official,
            audience: [.tourist, .general],
            lastChecked: CityDashboardContentData.lastChecked,
            priority: priority,
            externalLink: resolvedExternalLink
        )
    }

    private static func dashboardExternalLink(_ city: DashboardCity, _ kind: TravelLinkKind, title: String, url: URL, source: String) -> DashboardExternalLink {
        DashboardExternalLink(
            id: "\(city.id.rawValue)-\(kind.rawValue)-external",
            provider: externalProvider(for: kind),
            title: title,
            url: url,
            cityId: city.id,
            audience: [.tourist, .general],
            category: externalCategory(for: kind),
            source: source,
            lastChecked: CityDashboardContentData.lastChecked
        )
    }

    nonisolated private static func travelLinkIsVisible(_ item: TravelLinkItem) -> Bool {
        !item.cityId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !item.sourceLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !item.lastChecked.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !item.audience.isEmpty
            && AppURL.validatedWebURL(item.externalLink?.url ?? item.url) != nil
            && item.externalLink?.source?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && item.externalLink?.lastChecked?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    nonisolated private static func foodGuideItemIsVisible(_ item: FoodGuideItem) -> Bool {
        !item.hidden
            && !item.draft
            && !item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !item.cityId.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (item.route != nil || item.externalUrl != nil || item.query != nil)
            && item.externalUrl.flatMap(AppURL.validatedWebURL) != nil
            && !item.audience.isEmpty
            && item.source != nil
            && item.lastChecked?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private static func externalProvider(for kind: TravelLinkKind) -> DashboardExternalProvider {
        switch kind {
        case .booking:
            return .booking
        case .officialGuide:
            return .official
        case .maps, .restaurants, .cafes, .places:
            return .googleMaps
        }
    }

    private static func externalCategory(for kind: TravelLinkKind) -> DashboardExternalLinkCategory {
        switch kind {
        case .booking:
            return .hotels
        case .restaurants:
            return .restaurants
        case .cafes:
            return .cafes
        case .places, .officialGuide:
            return .places
        case .maps:
            return .transport
        }
    }

    private static func officialGuideURL(for cityId: CityId) -> String {
        switch cityId {
        case .amsterdam: return "https://www.iamsterdam.com"
        case .leiden: return "https://www.visitleiden.nl/en"
        case .rotterdam: return "https://www.rotterdam.info/en"
        case .denHaag: return "https://denhaag.com/en"
        case .utrecht: return "https://www.discover-utrecht.com"
        case .eindhoven: return "https://www.thisiseindhoven.com/en"
        case .groningen: return "https://www.visitgroningen.nl/en"
        case .maastricht: return "https://www.visitmaastricht.com/en"
        case .nijmegen: return "https://en.intonijmegen.com"
        case .arnhem: return "https://www.visitarnhem.com"
        case .delft: return "https://www.indelft.nl/en"
        case .haarlem: return "https://www.visithaarlem.com/en"
        }
    }

    private static func officialGuideLabel(for cityId: CityId) -> String {
        switch cityId {
        case .amsterdam: return "I amsterdam"
        case .rotterdam: return "Rotterdam Partners"
        case .denHaag: return "The Hague & Partners"
        case .maastricht: return "Visit Maastricht"
        case .nijmegen: return "Into Nijmegen"
        case .arnhem: return "Visit Arnhem"
        case .delft: return "In Delft"
        case .haarlem: return "Visit Haarlem"
        default: return "\(cityId.displayName) visitor guide"
        }
    }

    private static func cityNameMatches(_ lhs: String, _ rhs: String) -> Bool {
        lhs.caseInsensitiveCompare(rhs) == .orderedSame
            || slug(lhs) == slug(rhs)
            || lhs.lowercased().replacingOccurrences(of: " ", with: "_") == rhs.lowercased().replacingOccurrences(of: " ", with: "_")
    }

    private static func encoded(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
    }

    private static func googleMapsSearchURL(_ query: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.google.com"
        components.percentEncodedPath = "/maps/search/\(encoded(query))"
        return AppURL.validatedWebURL(components.url)
    }

    private static func slug(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: " ", with: "-")
    }
}

enum DashboardCalendarData {
    static let lastChecked = "June 2026"

    static var events: [CalendarEvent] {
        let local = cachedEvents(for: CalendarEventData.calendar.component(.year, from: Date()))
        let live = VisitLeidenCalendarSnapshot.calendarEvents()
        var merged = local + verifiedVisitLeidenSnapshot
        for event in live {
            if let index = merged.firstIndex(where: { $0.id == event.id }) {
                merged[index] = event
            } else {
                merged.append(event)
            }
        }
        return merged
    }

    /// Small offline fallback verified against Visit Leiden on 13 July 2026.
    /// The live adapter replaces matching records as soon as a fresh snapshot is available.
    private static let verifiedVisitLeidenSnapshot: [CalendarEvent] = [
        visitLeidenExhibition(
            id: "4203489830",
            title: "The forest of Suriname",
            summary: "Naturalis exhibition about Suriname's nature and the people who have inhabited its forests for centuries.",
            end: date(2027, 5, 2),
            url: "https://www.visitleiden.nl/en/event-calendar/4203489830/the-forest-of-suriname-1",
            priority: 1_000
        ),
        visitLeidenExhibition(
            id: "1744606890",
            title: "Truth? The art of doubt",
            summary: "Rijksmuseum Boerhaave exhibition in which scientists and artists explore how we determine what is true.",
            end: date(2027, 1, 3),
            url: "https://www.visitleiden.nl/en/event-calendar/1744606890/truth-the-art-of-doubt",
            priority: 1_001
        )
    ]

    static func prewarm() {
        _ = events.count
    }

    static func upcomingEvents(cityId: String, audience: UserContentCategory?, now: Date = Date(), limit: Int? = nil) -> [CalendarEvent] {
        let visible = events
            .filter { $0.isVisible(cityId: cityId, audience: audience, now: now) }
            .sorted {
                if $0.date == $1.date { return $0.priority < $1.priority }
                return $0.date < $1.date
            }
        guard let limit else { return visible }
        return Array(visible.prefix(limit))
    }

    static func detailEvent(id: String, now: Date = Date()) -> CalendarEvent? {
        events.first { event in
            event.id == id
                && !event.hidden
                && !event.draft
                && (event.endDate ?? event.date) >= CalendarEventData.calendar.startOfDay(for: now)
                && !event.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !event.audience.isEmpty
                && event.source != nil
                && event.lastChecked?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }
    }

    static func events(for year: Int) -> [CalendarEvent] {
        let easter = easterSunday(year: year)
        return [
            publicHoliday("new-years-day-\(year)", "New Year's Day", localTitle: "Nieuwjaarsdag", date: date(year, 1, 1), priority: 10, dayOffGuaranteed: false),
            publicHoliday("good-friday-\(year)", "Good Friday", localTitle: "Goede Vrijdag", date: addDays(-2, to: easter), priority: 20, dayOffGuaranteed: false),
            publicHoliday("easter-sunday-\(year)", "Easter Sunday", localTitle: "Eerste Paasdag", date: easter, priority: 30, dayOffGuaranteed: false),
            publicHoliday("easter-monday-\(year)", "Easter Monday", localTitle: "Tweede Paasdag", date: addDays(1, to: easter), priority: 40, dayOffGuaranteed: false),
            publicHoliday("kings-day-\(year)", "King's Day", localTitle: "Koningsdag", date: kingsDay(year), priority: 50, impact: "City centers may be busy and opening hours or transport may differ. Check official local information.", dayOffGuaranteed: false, affectsTransport: true),
            observance("remembrance-day-\(year)", "Remembrance Day", localTitle: "Dodenherdenking", date: date(year, 5, 4), priority: 55, impact: "Evening commemorations may affect some central public spaces."),
            publicHoliday("liberation-day-\(year)", "Liberation Day", localTitle: "Bevrijdingsdag", date: date(year, 5, 5), priority: 60, impact: "Public events may affect busy areas. Paid time off depends on your CAO or contract.", dayOffGuaranteed: false),
            publicHoliday("ascension-day-\(year)", "Ascension Day", localTitle: "Hemelvaartsdag", date: addDays(39, to: easter), priority: 70, dayOffGuaranteed: false),
            publicHoliday("whit-sunday-\(year)", "Whit Sunday", localTitle: "Eerste Pinksterdag", date: addDays(49, to: easter), priority: 80, dayOffGuaranteed: false),
            publicHoliday("whit-monday-\(year)", "Whit Monday", localTitle: "Tweede Pinksterdag", date: addDays(50, to: easter), priority: 90, dayOffGuaranteed: false),
            observance("sinterklaas-\(year)", "Sinterklaas", localTitle: "Sinterklaasavond", date: date(year, 12, 5), priority: 95, impact: "A widely observed cultural evening, not an official public holiday."),
            publicHoliday("christmas-day-\(year)", "Christmas Day", localTitle: "Eerste Kerstdag", date: date(year, 12, 25), priority: 100, dayOffGuaranteed: false),
            publicHoliday("boxing-day-\(year)", "Boxing Day", localTitle: "Tweede Kerstdag", date: date(year, 12, 26), priority: 110, dayOffGuaranteed: false),
            observance("new-years-eve-\(year)", "New Year's Eve", localTitle: "Oudejaarsavond", date: date(year, 12, 31), priority: 120, impact: "Evening crowds and local safety rules may vary by city.")
        ]
    }

    private static let currentYear = CalendarEventData.calendar.component(.year, from: Date())
    private static let currentYearEvents = events(for: currentYear) + events(for: currentYear + 1)

    private static func cachedEvents(for year: Int) -> [CalendarEvent] {
        if year == currentYear {
            return currentYearEvents
        }
        return events(for: year) + events(for: year + 1)
    }

    private static func publicHoliday(
        _ id: String,
        _ title: String,
        localTitle: String,
        date: Date,
        priority: Int,
        impact: String = "Opening hours may differ. Check the official source.",
        dayOffGuaranteed: Bool?,
        affectsTransport: Bool = false
    ) -> CalendarEvent {
        CalendarEvent(
            id: id,
            title: title,
            localTitle: localTitle,
            date: date,
            endDate: nil,
            type: .publicHoliday,
            countryCode: "NL",
            cityId: nil,
            audience: [.universal, .tourist, .student, .worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt],
            description: "\(title) (\(localTitle)) is listed as a Dutch national public holiday by Government.nl.",
            impact: impact,
            source: OfficialSource(title: "Government.nl public holidays", url: URL(string: "https://www.government.nl/faq/work/public-holidays-in-the-netherlands"), institution: "Government of the Netherlands"),
            lastChecked: lastChecked,
            priority: priority,
            official: true,
            dayOffGuaranteed: dayOffGuaranteed,
            affectsServices: true,
            affectsTransport: affectsTransport,
            hidden: false,
            draft: false
        )
    }

    private static func observance(_ id: String, _ title: String, localTitle: String, date: Date, priority: Int, impact: String) -> CalendarEvent {
        CalendarEvent(
            id: id,
            title: title,
            localTitle: localTitle,
            date: date,
            endDate: nil,
            type: .observance,
            countryCode: "NL",
            cityId: nil,
            audience: [.universal, .tourist, .student, .worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt],
            description: "Important Dutch observance. It is not modelled as an official public holiday.",
            impact: impact,
            source: nil,
            lastChecked: lastChecked,
            priority: priority,
            official: false,
            dayOffGuaranteed: false,
            affectsServices: nil,
            affectsTransport: nil,
            hidden: false,
            draft: false
        )
    }

    private static func visitLeidenExhibition(
        id: String,
        title: String,
        summary: String,
        end: Date,
        url: String,
        priority: Int
    ) -> CalendarEvent {
        CalendarEvent(
            id: id,
            title: title,
            localTitle: nil,
            date: date(2026, 7, 13),
            endDate: end,
            type: .touristEvent,
            countryCode: "NL",
            cityId: "Leiden",
            audience: [.universal, .tourist, .student, .family],
            description: summary,
            impact: "Check the official listing for current visiting details.",
            source: OfficialSource(title: "Visit Leiden event calendar", url: AppURL.make(url), institution: "Visit Leiden"),
            lastChecked: "2026-07-13",
            priority: priority,
            official: true,
            dayOffGuaranteed: false,
            affectsServices: false,
            affectsTransport: false,
            hidden: false,
            draft: false
        )
    }

    private static func kingsDay(_ year: Int) -> Date {
        let april27 = date(year, 4, 27)
        let weekday = CalendarEventData.calendar.component(.weekday, from: april27)
        return weekday == 1 ? date(year, 4, 26) : april27
    }

    private static func easterSunday(year: Int) -> Date {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1
        return date(year, month, day)
    }

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        CalendarEventData.calendar.date(from: DateComponents(timeZone: CalendarEventData.calendar.timeZone, year: year, month: month, day: day)) ?? Date()
    }

    private static func addDays(_ days: Int, to date: Date) -> Date {
        CalendarEventData.calendar.date(byAdding: .day, value: days, to: date) ?? date
    }
}
