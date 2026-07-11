import Foundation
import CoreLocation

enum LocalPartnerVisualRole: String, CaseIterable, Sendable {
    case hero
    case gallery
    case thumbnail
    case mapPreview
    case logo
}

struct LocalPartnerVisualAsset: Sendable {
    let role: LocalPartnerVisualRole
    let url: URL
    let altText: String
    let sourceTitle: String
    let licenseNote: String
}

struct LocalPartnerMediaSet: Sendable {
    let hero: LocalPartnerVisualAsset
    let gallery: [LocalPartnerVisualAsset]
    let thumbnail: LocalPartnerVisualAsset
    let mapPreview: LocalPartnerVisualAsset
    let logo: LocalPartnerVisualAsset?

    var allAssets: [LocalPartnerVisualAsset] {
        [hero, thumbnail, mapPreview] + gallery + [logo].compactMap { $0 }
    }

    static func officialWebsiteFallback(
        partnerName: String,
        website: URL,
        symbols: [String]
    ) -> LocalPartnerMediaSet {
        let sourceTitle = "\(partnerName) official website"
        let licenseNote = "Use official page as the visual source reference; cache or replace with licensed optimized assets before production image rendering."

        func asset(_ role: LocalPartnerVisualRole, _ label: String) -> LocalPartnerVisualAsset {
            LocalPartnerVisualAsset(
                role: role,
                url: website,
                altText: "\(partnerName) \(label)",
                sourceTitle: sourceTitle,
                licenseNote: licenseNote
            )
        }

        let galleryLabels = symbols.isEmpty ? ["official visual reference"] : symbols.map { "visual reference \($0)" }
        return LocalPartnerMediaSet(
            hero: asset(.hero, "hero image"),
            gallery: galleryLabels.prefix(3).map { label in asset(.gallery, label) },
            thumbnail: asset(.thumbnail, "thumbnail"),
            mapPreview: asset(.mapPreview, "map preview"),
            logo: asset(.logo, "logo")
        )
    }
}

enum LocalPartnerCategory: String, CaseIterable, Identifiable, Sendable {
    case stay
    case foodDrinks
    case healthcare
    case legal
    case education
    case finance
    case jobs
    case home
    case transport
    case shopping
    case leisure

    var id: String { rawValue }

    var subcategories: [String] {
        switch self {
        case .stay: return ["Hotels", "Apartments", "Hostels", "Student Housing"]
        case .foodDrinks: return ["Restaurants", "Cafes", "Bakeries", "Bars"]
        case .healthcare: return ["Clinics", "Dentists", "Pharmacies", "Physiotherapy"]
        case .legal: return ["Immigration Lawyers", "Lawyers", "Tax Advisors", "Notaries"]
        case .education: return ["Universities", "Dutch Language Schools", "Driving Schools"]
        case .finance: return ["Banks", "Insurance", "Mortgage Advisors"]
        case .jobs: return ["Recruitment Agencies", "Career Coaching", "CV Services"]
        case .home: return ["Real Estate", "Cleaning", "Moving Companies", "Furniture Stores"]
        case .transport: return ["Taxi", "Bike Rental", "Car Rental", "Parking"]
        case .shopping: return ["Supermarkets", "Electronics", "Mobile Operators"]
        case .leisure: return ["Museums", "Gyms", "Beauty", "Tours", "Entertainment"]
        }
    }

    func title(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.stay, .russian): return "Проживание"
        case (.foodDrinks, .russian): return "Еда и напитки"
        case (.healthcare, .russian): return "Медицина"
        case (.legal, .russian): return "Юридическое"
        case (.education, .russian): return "Образование"
        case (.finance, .russian): return "Финансы"
        case (.jobs, .russian): return "Работа"
        case (.home, .russian): return "Дом"
        case (.transport, .russian): return "Транспорт"
        case (.shopping, .russian): return "Покупки"
        case (.leisure, .russian): return "Досуг"
        case (.stay, .dutch): return "Verblijf"
        case (.foodDrinks, .dutch): return "Eten en drinken"
        case (.healthcare, .dutch): return "Zorg"
        case (.legal, .dutch): return "Juridisch"
        case (.education, .dutch): return "Onderwijs"
        case (.finance, .dutch): return "Financien"
        case (.jobs, .dutch): return "Werk"
        case (.home, .dutch): return "Wonen"
        case (.transport, .dutch): return "Vervoer"
        case (.shopping, .dutch): return "Winkelen"
        case (.leisure, .dutch): return "Vrije tijd"
        case (.stay, .english): return "Stay"
        case (.foodDrinks, .english): return "Food & Drinks"
        case (.healthcare, .english): return "Healthcare"
        case (.legal, .english): return "Legal"
        case (.education, .english): return "Education"
        case (.finance, .english): return "Finance"
        case (.jobs, .english): return "Jobs"
        case (.home, .english): return "Home"
        case (.transport, .english): return "Transport"
        case (.shopping, .english): return "Shopping"
        case (.leisure, .english): return "Leisure"
        }
    }

    var symbol: String {
        switch self {
        case .stay: return "bed.double.fill"
        case .foodDrinks: return "fork.knife"
        case .healthcare: return "cross.case.fill"
        case .legal: return "scale.3d"
        case .education: return "graduationcap.fill"
        case .finance: return "creditcard.fill"
        case .jobs: return "briefcase.fill"
        case .home: return "house.fill"
        case .transport: return "tram.fill"
        case .shopping: return "bag.fill"
        case .leisure: return "ticket.fill"
        }
    }

    var mapCategory: PlaceCategory {
        switch self {
        case .stay: return .shelter
        case .foodDrinks, .shopping, .leisure: return .communitySupport
        case .healthcare: return .healthcare
        case .legal: return .legalHelp
        case .education: return .education
        case .finance, .jobs, .home: return .communitySupport
        case .transport: return .transport
        }
    }
}

enum LocalPartnerPlan: String, Sendable {
    case freeListing
    case verifiedPartner
    case premium
    case featured
    case aiFeatured
    case sponsoredPlacement

    func label(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.freeListing, .russian): return "Free Listing"
        case (.verifiedPartner, .russian): return "Verified Partner"
        case (.premium, .russian): return "Premium Partner"
        case (.featured, .russian): return "Featured"
        case (.aiFeatured, .russian): return "Featured Partner"
        case (.sponsoredPlacement, .russian): return "Sponsored"
        case (.freeListing, .dutch): return "Free Listing"
        case (.verifiedPartner, .dutch): return "Verified Partner"
        case (.premium, .dutch): return "Premium Partner"
        case (.featured, .dutch): return "Featured"
        case (.aiFeatured, .dutch): return "Featured Partner"
        case (.sponsoredPlacement, .dutch): return "Sponsored"
        case (.freeListing, .english): return "Free Listing"
        case (.verifiedPartner, .english): return "Verified Partner"
        case (.premium, .english): return "Premium Partner"
        case (.featured, .english): return "Featured"
        case (.aiFeatured, .english): return "Featured Partner"
        case (.sponsoredPlacement, .english): return "Sponsored"
        }
    }
}

struct LocalPartner: Identifiable, Hashable {
    let id: String
    let name: String
    let category: LocalPartnerCategory
    let subcategory: String
    let plan: LocalPartnerPlan
    let description: String
    let photoSymbols: [String]
    let address: String
    let city: String
    let coordinate: CLLocationCoordinate2D
    let phone: String
    let email: String
    let website: URL
    let openingHours: String
    let languages: [String]
    let lastVerified: String
    let isOpenNow: Bool
    let officialSource: OfficialSource
    let sourceReliabilityNote: String
    let media: LocalPartnerMediaSet

    init(
        id: String,
        name: String,
        category: LocalPartnerCategory,
        subcategory: String,
        plan: LocalPartnerPlan,
        description: String,
        photoSymbols: [String],
        address: String,
        city: String,
        coordinate: CLLocationCoordinate2D,
        phone: String,
        email: String,
        website: URL,
        openingHours: String,
        languages: [String],
        lastVerified: String,
        isOpenNow: Bool,
        officialSource: OfficialSource? = nil,
        sourceReliabilityNote: String = "Official website or official locator page. Opening hours and branch availability should be rechecked before visiting.",
        media: LocalPartnerMediaSet? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.subcategory = subcategory
        self.plan = plan
        self.description = description
        self.photoSymbols = photoSymbols
        self.address = address
        self.city = city
        self.coordinate = coordinate
        self.phone = phone
        self.email = email
        self.website = website
        self.openingHours = openingHours
        self.languages = languages
        self.lastVerified = lastVerified
        self.isOpenNow = isOpenNow
        self.officialSource = officialSource ?? OfficialSource(
            title: "\(name) official website",
            url: website,
            institution: name,
            lastChecked: LocalPartner.reviewDate(lastVerified)
        )
        self.sourceReliabilityNote = sourceReliabilityNote
        self.media = media ?? LocalPartnerMediaSet.officialWebsiteFallback(
            partnerName: name,
            website: website,
            symbols: photoSymbols
        )
    }

    static func == (lhs: LocalPartner, rhs: LocalPartner) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    private static func reviewDate(_ value: String) -> Date? {
        ISO8601DateFormatter().date(from: value)
    }
}

extension LocalPartner {
    var mapPlace: NearbyPlace {
        NearbyPlace(
            name: name,
            category: category.mapCategory,
            description: description,
            newcomerUseCase: "\(plan == .freeListing ? "Local service" : "Verified local partner") in \(city): \(subcategory).",
            coordinate: coordinate,
            address: address,
            openingHoursPlaceholder: openingHours,
            websiteURL: website,
            phone: phone,
            isOfficialSource: plan != .freeListing,
            sourceLabel: plan == .sponsoredPlacement ? "Sponsored" : "Partner",
            lastUpdated: lastVerified,
            city: city,
            trustNote: "Commercial local partner. Verify details, price, and availability directly with the business.",
            relatedLinks: [
                PlaceRelatedLink(
                    title: "Local Partners",
                    subtitle: name,
                    symbol: category.symbol,
                    destination: .localPartnerDetail(id)
                )
            ]
        )
    }
}
