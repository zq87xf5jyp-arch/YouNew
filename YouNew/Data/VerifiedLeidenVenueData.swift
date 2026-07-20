import Foundation

/// Canonical Leiden venues verified against Visit Leiden and the venue's own website.
/// Reusable photography is limited to media with an explicit Commons licence.
enum VerifiedLeidenVenueData {
    static let entities: [NetherlandsKnowledgeEntity] = [
        venue(
            id: "museum:leiden:lakenhal",
            kind: .museum,
            title: "Museum De Lakenhal",
            summary: "Leiden's museum for visual arts, city history and applied arts, housed in the historic cloth hall.",
            category: "museum",
            latitude: 52.162950,
            longitude: 4.487450,
            address: "Oude Singel 32, 2312 RA Leiden",
            sourceURL: "https://www.visitleiden.nl/en/locations/3053810059/museum-de-lakenhal",
            officialWebsite: "https://www.lakenhal.nl/en",
            media: .lakenhal,
            keywords: ["art", "history", "Rembrandt", "cloth hall", "museum"]
        ),
        venue(
            id: "museum:leiden:naturalis",
            kind: .museum,
            title: "Naturalis Biodiversity Center",
            summary: "National biodiversity museum with family galleries, research collections and T. rex Trix.",
            category: "museum",
            latitude: 52.164928,
            longitude: 4.472697,
            address: "Darwinweg 2, 2333 CR Leiden",
            sourceURL: "https://www.visitleiden.nl/en/locations/658638389/naturalis",
            officialWebsite: "https://www.naturalis.nl/en",
            media: .naturalis,
            keywords: ["biodiversity", "natural history", "Trix", "family", "museum"]
        ),
        venue(
            id: "attraction:leiden:burcht",
            kind: .attraction,
            title: "De Burcht",
            summary: "A freely accessible medieval motte castle with panoramic views over Leiden's historic centre.",
            category: "historic attraction",
            latitude: 52.158277,
            longitude: 4.492207,
            address: "Burgsteeg, 2312 JR Leiden",
            sourceURL: "https://www.visitleiden.nl/en/locations/2380897422/de-burcht",
            officialWebsite: "https://www.visitleiden.nl/en/locations/2380897422/de-burcht",
            media: .burcht,
            keywords: ["castle", "history", "viewpoint", "free", "monument"]
        ),
        venue(
            id: "restaurant:leiden:fat-pelican",
            kind: .restaurant,
            title: "The Fat Pelican",
            summary: "An urban beer garden and comfort-food restaurant on Pelikaanstraat, known for rotisserie chicken and beer.",
            category: "restaurant",
            latitude: 52.1606865,
            longitude: 4.4972782,
            address: "Pelikaanstraat 64, 2312 DW Leiden",
            sourceURL: "https://www.visitleiden.nl/en/locations/2763908267/the-fat-pelican",
            officialWebsite: "https://thefatpelican.nl/",
            media: .fatPelicanFallback,
            keywords: ["comfort food", "chicken", "beer garden", "terrace", "restaurant"]
        ),
        venue(
            id: "restaurant:leiden:pakhuis",
            kind: .restaurant,
            title: "Grand Café Pakhuis",
            summary: "A grand café in a historic coach house serving lunch, dinner, drinks and group arrangements.",
            category: "restaurant",
            latitude: 52.157853,
            longitude: 4.484301,
            address: "Doelensteeg 8, 2311 VL Leiden",
            sourceURL: "https://www.visitleiden.nl/en/locations/998783951/grand-cafe-pakhuis",
            officialWebsite: "https://www.pakhuisleiden.nl/",
            media: .pakhuis,
            keywords: ["grand café", "lunch", "dinner", "historic building", "restaurant"]
        ),
        venue(
            id: "restaurant:leiden:de-apotheek",
            kind: .restaurant,
            title: "Lokaliteit De Apotheek",
            summary: "A restaurant and bar on Nieuwe Rijn focused on seasonal dishes and local ingredients.",
            category: "restaurant",
            latitude: 52.158110,
            longitude: 4.492190,
            address: "Nieuwe Rijn 18, 2312 JC Leiden",
            sourceURL: "https://www.visitleiden.nl/en/locations/3564071811/lokaliteit-de-apotheek",
            officialWebsite: "https://www.visitleiden.nl/en/locations/3564071811/lokaliteit-de-apotheek",
            media: .deApotheek,
            keywords: ["seasonal", "local ingredients", "lunch", "dinner", "drinks"]
        ),
        venue(
            id: "restaurant:leiden:waag",
            kind: .restaurant,
            title: "Waag Leiden",
            summary: "A café-restaurant in Leiden's historic weigh house, serving lunch, dinner and drinks beside the Rhine.",
            category: "historic restaurant",
            latitude: 52.1593318,
            longitude: 4.4904674,
            address: "Aalmarkt 21, 2311 EC Leiden",
            sourceURL: "https://www.visitleiden.nl/en/locations/3402150775/waag-leiden",
            officialWebsite: "https://www.visitleiden.nl/en/locations/3402150775/waag-leiden",
            media: .waag,
            keywords: ["historic weigh house", "lunch", "dinner", "terrace", "restaurant"]
        ),
        venue(
            id: "restaurant:leiden:annies",
            kind: .restaurant,
            title: "Annie's",
            summary: "A waterside café-restaurant at the meeting point of Leiden's Rhine branches, open for coffee, lunch, drinks and dinner.",
            category: "waterside restaurant",
            latitude: 52.1594816,
            longitude: 4.4912311,
            address: "Hoogstraat 1A, 2312 JA Leiden",
            sourceURL: "https://www.visitleiden.nl/nl/locaties/3135249262/cafe-restaurant-annie-s",
            officialWebsite: "https://www.visitleiden.nl/nl/locaties/3135249262/cafe-restaurant-annie-s",
            media: .anniesContext,
            keywords: ["waterside", "coffee", "lunch", "dinner", "terrace"]
        ),
        venue(
            id: "cafe:leiden:floors",
            kind: .cafe,
            title: "Floor's coffee & brunch bar",
            summary: "A coffee and brunch bar with fresh house-made dishes and a fully gluten-free menu.",
            category: "café and brunch",
            latitude: 52.1552051,
            longitude: 4.4889808,
            address: "Doezastraat 1B, 2311 GZ Leiden",
            sourceURL: "https://www.visitleiden.nl/en/locations/2376533067/floor-s-coffee-brunch-bar",
            officialWebsite: "https://floorsfood.nl/english/",
            media: .floors,
            keywords: ["coffee", "brunch", "gluten-free", "lunch", "café"]
        ),
        venue(
            id: "cafe:leiden:hortus-grand-cafe",
            kind: .cafe,
            title: "Hortus Grand Café",
            summary: "A garden café at Hortus botanicus serving coffee, lunch and drinks with ingredients from local suppliers.",
            category: "garden café",
            latitude: 52.157317,
            longitude: 4.485401,
            address: "Rapenburg 73, 2311 GJ Leiden",
            sourceURL: "https://www.visitleiden.nl/en/locations/1038841499/hortus-grand-cafe",
            officialWebsite: "https://hortusleiden.nl/",
            media: .hortus,
            keywords: ["botanical garden", "coffee", "lunch", "terrace", "café"]
        ),
        venue(
            id: "cafe:leiden:borgman-borgman",
            kind: .cafe,
            title: "Borgman & Borgman",
            summary: "An independent coffee bar and roastery on Nieuwe Rijn, specialising in freshly roasted coffee.",
            category: "coffee roastery",
            latitude: 52.1573176,
            longitude: 4.4932443,
            address: "Nieuwe Rijn 41, 2312 JG Leiden",
            sourceURL: "https://www.visitleiden.nl/en/locations/3550956321/borgman-borgman",
            officialWebsite: "https://www.visitleiden.nl/en/locations/3550956321/borgman-borgman",
            media: .borgmanContext,
            keywords: ["specialty coffee", "roastery", "Nieuwe Rijn", "takeaway", "café"]
        ),
        venue(
            id: "cafe:leiden:roos",
            kind: .cafe,
            title: "ROOS",
            summary: "A central Leiden breakfast and lunch café offering coffee, fresh juices, sandwiches and sweet treats.",
            category: "breakfast and lunch café",
            latitude: 52.1573619,
            longitude: 4.4923128,
            address: "Botermarkt 12, 2311 EM Leiden",
            sourceURL: "https://www.visitleiden.nl/nl/locaties/599416677/roos",
            officialWebsite: "https://www.visitleiden.nl/nl/locaties/599416677/roos",
            media: .roos,
            keywords: ["breakfast", "lunch", "coffee", "fresh juice", "café"]
        )
    ]

    private static let checkedAt = "2026-07-13"

    private static func venue(
        id: String,
        kind: NetherlandsEntityKind,
        title: String,
        summary: String,
        category: String,
        latitude: Double,
        longitude: Double,
        address: String,
        sourceURL: String,
        officialWebsite: String,
        media: AppImageAsset,
        keywords: [String]
    ) -> NetherlandsKnowledgeEntity {
        let verifiedSourceURL = AppURL.make(sourceURL)
        return NetherlandsKnowledgeEntity(
            id: id,
            kind: kind,
            title: title,
            summary: summary,
            cityId: "Leiden",
            provinceId: "Zuid-Holland",
            category: category,
            coordinate: NetherlandsDataCoordinate(latitude: latitude, longitude: longitude),
            source: OfficialSource(title: "Visit Leiden", url: verifiedSourceURL, institution: "Leiden Marketing", lastChecked: checkedDate),
            lastChecked: checkedAt,
            images: visualSet(media),
            aiSummary: "(summary) Opening hours, menus and access can change; verify the latest details on the official website before visiting.",
            relatedEntityIDs: ["city:leiden", "province:zuid-holland"],
            route: .informationHub,
            attributes: [
                "address": address,
                "officialWebsite": officialWebsite,
                "verificationStatus": "Verified",
                "updateFrequency": "Monthly",
                "sourceKind": "Official destination listing",
                "photoLicense": media.licenseName ?? media.license ?? "Pending"
            ],
            keywords: [title, address, "Leiden", "Zuid-Holland"] + keywords,
            explicitPersonaTags: nil
        )
    }

    private static func visualSet(_ asset: AppImageAsset) -> NetherlandsVisualSet {
        NetherlandsVisualSet(hero: asset, gallery: [asset], thumbnail: asset, mapPreview: asset, categoryCover: asset)
    }

    private static var checkedDate: Date? {
        ISO8601DateFormatter().date(from: "\(checkedAt)T00:00:00Z")
    }
}

private extension AppImageAsset {
    static let lakenhal = commons(
        id: "media:leiden:lakenhal",
        fileName: "Lakenhal.jpg",
        title: "Museum De Lakenhal",
        description: "The historic Leiden cloth hall used by Museum De Lakenhal.",
        creator: "PeteBobb",
        licenseName: "CC BY-SA 3.0 NL",
        licenseURL: "https://creativecommons.org/licenses/by-sa/3.0/nl/",
        width: 2832,
        height: 2128
    )

    static let naturalis = commons(
        id: "media:leiden:naturalis-2019",
        fileName: "Naturalis-Leiden-2019-3.jpg",
        title: "Naturalis Biodiversity Center",
        description: "The Naturalis expansion in Leiden.",
        creator: "Hay Kranen",
        licenseName: "CC BY 4.0",
        licenseURL: "https://creativecommons.org/licenses/by/4.0/",
        width: 3024,
        height: 4032
    )

    static let burcht = commons(
        id: "media:leiden:burcht",
        fileName: "Burcht, Leiden.JPG",
        title: "De Burcht",
        description: "The medieval Burcht van Leiden.",
        creator: "Effeietsanders",
        licenseName: "CC BY-SA 3.0 NL",
        licenseURL: "https://creativecommons.org/licenses/by-sa/3.0/nl/",
        width: 2736,
        height: 3648
    )

    static let pakhuis = commons(
        id: "media:leiden:pakhuis",
        fileName: "Leiden-doelensteeg-184221.jpg",
        title: "Grand Café Pakhuis building",
        description: "The historic coach house at Doelensteeg 8.",
        creator: "Pim van Tend",
        licenseName: "CC BY-SA 4.0",
        licenseURL: "https://creativecommons.org/licenses/by-sa/4.0/",
        width: 2448,
        height: 3264
    )

    static let floors = commons(
        id: "media:leiden:floors-address",
        fileName: "Doezastraat 1 Leiden.jpg",
        title: "Doezastraat 1",
        description: "The building at Doezastraat 1, the address of Floor's coffee & brunch bar.",
        creator: "Biccie",
        licenseName: "CC BY-SA 3.0",
        licenseURL: "https://creativecommons.org/licenses/by-sa/3.0/",
        width: 5903,
        height: 3542
    )

    static let deApotheek = commons(
        id: "media:leiden:nieuwe-rijn-18",
        fileName: "Nieuwe Rijn 18, Objectnr MO 0367 0030.jpg",
        title: "Nieuwe Rijn 18",
        description: "The building at Nieuwe Rijn 18, the address of Lokaliteit De Apotheek.",
        creator: "Gemeente Leiden Afdeling Monumentenzorg",
        licenseName: "CC0 1.0",
        licenseURL: "https://creativecommons.org/publicdomain/zero/1.0/",
        width: 2406,
        height: 3645
    )

    static let hortus = commons(
        id: "media:leiden:hortus-2024",
        fileName: "Hortus botanicus Leiden.jpg",
        title: "Hortus botanicus Leiden",
        description: "Hortus botanicus Leiden, home of Hortus Grand Café.",
        creator: "Roger Veringmeier",
        licenseName: "CC BY 4.0",
        licenseURL: "https://creativecommons.org/licenses/by/4.0/",
        width: 6016,
        height: 4000
    )

    static let waag = commons(
        id: "media:leiden:waag-aalmarkt-21",
        fileName: "Aalmarkt 21, Objectnr MO 0336 0027.jpg",
        title: "Waag Leiden",
        description: "The historic Waag at Aalmarkt 21, the home of Waag Leiden.",
        creator: "Gemeente Leiden Afdeling Monumentenzorg",
        licenseName: "CC0 1.0",
        licenseURL: "https://creativecommons.org/publicdomain/zero/1.0/",
        width: 3650,
        height: 2409
    )

    static let anniesContext = commons(
        id: "media:leiden:annies-visbrug-context",
        fileName: "Visbrug en Nieuwe Rijn.jpg",
        title: "Visbrug and Nieuwe Rijn near Annie's",
        description: "The waterside Visbrug and Nieuwe Rijn setting beside Annie's Hoogstraat location.",
        creator: "Michiel1972",
        licenseName: "CC BY 2.5",
        licenseURL: "https://creativecommons.org/licenses/by/2.5/",
        width: 2592,
        height: 1944
    )

    static let borgmanContext = commons(
        id: "media:leiden:borgman-nieuwe-rijn-context",
        fileName: "Leiden Nieuwe Rijn met Koornbrug.jpg",
        title: "Nieuwe Rijn near Borgman & Borgman",
        description: "The Nieuwe Rijn streetscape where Borgman & Borgman's Leiden coffee bar is located.",
        creator: "Roger Veringmeier",
        licenseName: "CC BY 4.0",
        licenseURL: "https://creativecommons.org/licenses/by/4.0/",
        width: 6016,
        height: 4000
    )

    static let roos = commons(
        id: "media:leiden:roos-botermarkt-12",
        fileName: "Leiden - Botermarkt 12.JPG",
        title: "ROOS at Botermarkt 12",
        description: "The building at Botermarkt 12, the address of ROOS in Leiden.",
        creator: "Rudolphous",
        licenseName: "CC BY 3.0",
        licenseURL: "https://creativecommons.org/licenses/by/3.0/",
        width: 3056,
        height: 4592
    )

    static let fatPelicanFallback = AppImageAsset(
        id: "media:leiden:fat-pelican-fallback",
        url: nil,
        localAssetName: "nl_leiden_card_01",
        title: "The Fat Pelican",
        description: "YouNew category fallback shown until partner-licensed venue photography is supplied.",
        sourceName: "YouNew",
        sourceURL: AppURL.make("https://www.visitleiden.nl/en/locations/2763908267/the-fat-pelican"),
        license: "Bundled application asset",
        attribution: "YouNew",
        width: nil,
        height: nil,
        type: .cardThumbnail,
        verified: true,
        retrievedAt: "2026-07-13"
    )

    static func commons(
        id: String,
        fileName: String,
        title: String,
        description: String,
        creator: String,
        licenseName: String,
        licenseURL: String,
        width: Int,
        height: Int
    ) -> AppImageAsset {
        let encoded = fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fileName
        let sourcePage = AppURL.make("https://commons.wikimedia.org/wiki/File:\(encoded)")
        let image = AppURL.make("https://commons.wikimedia.org/wiki/Special:FilePath/\(encoded)?width=1600")
        return AppImageAsset(
            id: id,
            url: image,
            sourcePageURL: sourcePage,
            imageURL: image,
            thumbnailURL: image,
            originalFileURL: AppURL.make("https://commons.wikimedia.org/wiki/Special:FilePath/\(encoded)"),
            title: title,
            description: description,
            sourceName: "Wikimedia Commons",
            sourceURL: sourcePage,
            creator: creator,
            author: creator,
            license: licenseName,
            licenseName: licenseName,
            licenseURL: AppURL.make(licenseURL),
            attribution: "\(title) — \(creator), \(licenseName), via Wikimedia Commons",
            width: width,
            height: height,
            type: .cardThumbnail,
            verified: true,
            retrievedAt: "2026-07-13"
        )
    }
}
