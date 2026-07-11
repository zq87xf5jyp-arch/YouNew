import Foundation

// MARK: - Content Media Registry
//
// Verified, licensed images used for contextual illustration in guide screens
// (Transport, Culture, History, Official Sources).  All entries point to exact
// Wikimedia Commons File pages and must carry complete attribution metadata.
//
// Rules:
//  • verified: true only for entries whose sourcePageURL has been confirmed.
//  • Only Wikimedia Commons, official museum open-data, or CC-licensed sources.
//  • No AI-generated images, no stock photos, no Google Images.
//  • Each image type accessor returns the appropriate image for its screen context.

enum ContentMediaRegistry {
    static let images: [AppImageAsset] = [

        // MARK: Transport

        AppImageAsset(
            id: "content-transport-amsterdam-bike-parking",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Amsterdam_bicycle_parking.jpg?width=1600"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:Amsterdam_bicycle_parking.jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Amsterdam_bicycle_parking.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Amsterdam_bicycle_parking.jpg?width=1600"),
            originalFileURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/c/c6/Amsterdam_bicycle_parking.jpg"),
            title: "Bicycle parking in Amsterdam",
            description: "Canal-side bicycle parking representing Dutch daily mobility culture.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:Amsterdam_bicycle_parking.jpg"),
            creator: "Tezd",
            author: "Tezd",
            license: "CC BY-SA 3.0",
            licenseName: "Creative Commons Attribution-Share Alike 3.0 Unported",
            licenseURL: URL(string: "https://creativecommons.org/licenses/by-sa/3.0/"),
            attribution: "Tezd, via Wikimedia Commons",
            width: 1620,
            height: 1080,
            aspectRatio: 1620.0 / 1080.0,
            type: .transportHero,
            verified: true,
            retrievedAt: "2026-06-01",
            titleKey: "contentMedia.transport.bikeParking.title",
            descriptionKey: "contentMedia.transport.bikeParking.description"
        ),

        AppImageAsset(
            id: "content-transport-amsterdam-centraal-exterior",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Amsterdam_Centraal_Station_2016.jpg?width=1600"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:Amsterdam_Centraal_Station_2016.jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Amsterdam_Centraal_Station_2016.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Amsterdam_Centraal_Station_2016.jpg?width=1600"),
            title: "Amsterdam Centraal station",
            description: "The main train station of Amsterdam, one of the busiest rail hubs in the Netherlands.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:Amsterdam_Centraal_Station_2016.jpg"),
            creator: "Ymblanter",
            author: "Ymblanter",
            license: "CC BY-SA 4.0",
            licenseName: "Creative Commons Attribution-Share Alike 4.0 International",
            licenseURL: URL(string: "https://creativecommons.org/licenses/by-sa/4.0/"),
            attribution: "Ymblanter, via Wikimedia Commons",
            width: 4000,
            height: 3000,
            aspectRatio: 4000.0 / 3000.0,
            type: .transportHero,
            verified: true,
            retrievedAt: "2026-06-01",
            titleKey: "contentMedia.transport.centraal.title",
            descriptionKey: "contentMedia.transport.centraal.description"
        ),

        AppImageAsset(
            id: "content-transport-ovchipkaart-card",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/OV-chipkaart_Wegwerpkaart-8460.jpg?width=1600"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:OV-chipkaart_Wegwerpkaart-8460.jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/OV-chipkaart_Wegwerpkaart-8460.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/OV-chipkaart_Wegwerpkaart-8460.jpg?width=1600"),
            title: "OV-chipkaart disposable card",
            description: "A close-up of an OV-chipkaart disposable travel card, useful for explaining Dutch public transport payment concepts.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:OV-chipkaart_Wegwerpkaart-8460.jpg"),
            creator: "Raimond Spekking",
            author: "Raimond Spekking",
            license: "CC BY-SA 4.0",
            licenseName: "Creative Commons Attribution-Share Alike 4.0 International",
            licenseURL: URL(string: "https://creativecommons.org/licenses/by-sa/4.0/"),
            attribution: "© Raimond Spekking / CC BY-SA 4.0, via Wikimedia Commons",
            width: 3684,
            height: 2519,
            aspectRatio: 3684.0 / 2519.0,
            type: .cardThumbnail,
            verified: true,
            retrievedAt: "2026-06-01",
            titleKey: "contentMedia.transport.ovChipkaart.title",
            descriptionKey: "contentMedia.transport.ovChipkaart.description"
        ),

        // MARK: Practical life

        AppImageAsset(
            id: "content-healthcare-dutch-pharmacy",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Pharmacy-nl2.JPG?width=1600"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:Pharmacy-nl2.JPG"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Pharmacy-nl2.JPG"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Pharmacy-nl2.JPG?width=1600"),
            localAssetName: "home_healthcare_pharmacy",
            title: "Dutch pharmacy interior",
            description: "A Dutch pharmacy image used as neutral visual context for healthcare and medication guidance.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:Pharmacy-nl2.JPG"),
            creator: "Ciell",
            author: "Ciell",
            license: "CC BY-SA 2.5",
            licenseName: "Creative Commons Attribution-Share Alike 2.5 Generic",
            licenseURL: URL(string: "https://creativecommons.org/licenses/by-sa/2.5/"),
            attribution: "Ciell, via Wikimedia Commons",
            width: 2272,
            height: 1704,
            aspectRatio: 2272.0 / 1704.0,
            type: .cardThumbnail,
            verified: true,
            retrievedAt: "2026-06-01",
            titleKey: "contentMedia.healthcare.pharmacy.title",
            descriptionKey: "contentMedia.healthcare.pharmacy.description"
        ),

        AppImageAsset(
            id: "content-government-haarlem-city-hall",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Haarlem_city_hall.JPG?width=1600"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:Haarlem_city_hall.JPG"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Haarlem_city_hall.JPG"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Haarlem_city_hall.JPG?width=1600"),
            localAssetName: "home_documents_city_hall",
            title: "Haarlem City Hall",
            description: "City hall on the Grote Markt in Haarlem, used as visual context for municipality and registration topics.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:Haarlem_city_hall.JPG"),
            creator: "Jane023",
            author: "Jane023",
            license: "CC BY-SA 3.0",
            licenseName: "Creative Commons Attribution-Share Alike 3.0 Unported",
            licenseURL: URL(string: "https://creativecommons.org/licenses/by-sa/3.0/"),
            attribution: "Jane023, via Wikimedia Commons",
            width: 3072,
            height: 2048,
            aspectRatio: 3072.0 / 2048.0,
            type: .cardThumbnail,
            verified: true,
            retrievedAt: "2026-06-01",
            titleKey: "contentMedia.government.cityHall.title",
            descriptionKey: "contentMedia.government.cityHall.description"
        ),

        AppImageAsset(
            id: "content-housing-rijtjeshuizen",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Rijtjeshuizen%2C_RP-T-1998-70-12%28R%29.jpg?width=1600"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:Rijtjeshuizen,_RP-T-1998-70-12(R).jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Rijtjeshuizen%2C_RP-T-1998-70-12%28R%29.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Rijtjeshuizen%2C_RP-T-1998-70-12%28R%29.jpg?width=1600"),
            title: "Terraced houses",
            description: "A Rijksmuseum public-domain drawing of terraced houses, used as neutral visual context for housing topics.",
            sourceName: "Wikimedia Commons / Rijksmuseum",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:Rijtjeshuizen,_RP-T-1998-70-12(R).jpg"),
            creator: "Cornelis Vreedenburgh / Rijksmuseum",
            author: "Cornelis Vreedenburgh / Rijksmuseum",
            license: "CC0 1.0",
            licenseName: "Creative Commons CC0 1.0 Universal Public Domain Dedication",
            licenseURL: URL(string: "https://creativecommons.org/publicdomain/zero/1.0/"),
            attribution: "Rijksmuseum, via Wikimedia Commons",
            width: 2416,
            height: 1906,
            aspectRatio: 2416.0 / 1906.0,
            type: .cardThumbnail,
            verified: true,
            retrievedAt: "2026-06-01",
            titleKey: "contentMedia.housing.terracedHouses.title",
            descriptionKey: "contentMedia.housing.terracedHouses.description"
        ),

        // MARK: Culture

        AppImageAsset(
            id: "content-culture-vermeer-girl-pearl-earring",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Girl_with_a_Pearl_Earring.jpg?width=1600"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:Girl_with_a_Pearl_Earring.jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Girl_with_a_Pearl_Earring.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Girl_with_a_Pearl_Earring.jpg?width=1200"),
            originalFileURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/d/d7/Meisje_met_de_parel.jpg"),
            title: "Girl with a Pearl Earring",
            description: "A masterpiece of the Dutch Golden Age, painted c. 1665 by Johannes Vermeer and held at the Mauritshuis in The Hague.",
            sourceName: "Wikimedia Commons / Mauritshuis",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:Girl_with_a_Pearl_Earring.jpg"),
            creator: "Johannes Vermeer",
            author: "Johannes Vermeer (c. 1665)",
            license: "Public Domain",
            licenseName: "Public Domain — copyright expired",
            licenseURL: URL(string: "https://creativecommons.org/publicdomain/mark/1.0/"),
            attribution: "Johannes Vermeer (c. 1665), Mauritshuis, The Hague — Public Domain via Wikimedia Commons",
            width: 3906,
            height: 4432,
            aspectRatio: 3906.0 / 4432.0,
            type: .cultureHero,
            verified: true,
            retrievedAt: "2026-06-01",
            titleKey: "contentMedia.culture.pearlEarring.title",
            descriptionKey: "contentMedia.culture.pearlEarring.description"
        ),

        // MARK: Home atmosphere

        AppImageAsset(
            id: "content-home-amsterdam-canal-houses",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Canal%20houses%20and%20Oude%20Kerk%20at%20blue%20hour%20with%20water%20reflection%20in%20Damrak%20Amsterdam%20Netherlands.jpg?width=1600"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:Canal_houses_and_Oude_Kerk_at_blue_hour_with_water_reflection_in_Damrak_Amsterdam_Netherlands.jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Canal%20houses%20and%20Oude%20Kerk%20at%20blue%20hour%20with%20water%20reflection%20in%20Damrak%20Amsterdam%20Netherlands.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Canal%20houses%20and%20Oude%20Kerk%20at%20blue%20hour%20with%20water%20reflection%20in%20Damrak%20Amsterdam%20Netherlands.jpg?width=2400"),
            originalFileURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Canal%20houses%20and%20Oude%20Kerk%20at%20blue%20hour%20with%20water%20reflection%20in%20Damrak%20Amsterdam%20Netherlands.jpg"),
            title: "Amsterdam canal houses at Damrak",
            description: "Amsterdam canal houses and Oude Kerk reflected in Damrak water, used only when the content is explicitly Amsterdam or canal-ring context.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:Canal_houses_and_Oude_Kerk_at_blue_hour_with_water_reflection_in_Damrak_Amsterdam_Netherlands.jpg"),
            creator: "Wikimedia Commons contributor",
            author: "Wikimedia Commons contributor",
            license: "Wikimedia Commons file license",
            licenseName: "Wikimedia Commons file license",
            licenseURL: URL(string: "https://commons.wikimedia.org/wiki/File:Canal_houses_and_Oude_Kerk_at_blue_hour_with_water_reflection_in_Damrak_Amsterdam_Netherlands.jpg"),
            attribution: "Wikimedia Commons contributors",
            width: 2400,
            height: 1350,
            aspectRatio: 2400.0 / 1350.0,
            type: .homeHero,
            verified: true,
            retrievedAt: "2026-06-01",
            titleKey: "contentMedia.home.amsterdamCanals.title",
            descriptionKey: "contentMedia.home.amsterdamCanals.description"
        ),

        // MARK: Culture — windmills

        AppImageAsset(
            id: "content-culture-kinderdijk-windmills",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Kinderdijk%2C%20Nederwaard%20molens%20no%201tm5%20RM30543tm7%20IMG%209354%202021-06-13%2011.04.jpg?width=2400"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:Kinderdijk,_Nederwaard_molens_no_1tm5_RM30543tm7_IMG_9354_2021-06-13_11.04.jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Kinderdijk%2C%20Nederwaard%20molens%20no%201tm5%20RM30543tm7%20IMG%209354%202021-06-13%2011.04.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Kinderdijk%2C%20Nederwaard%20molens%20no%201tm5%20RM30543tm7%20IMG%209354%202021-06-13%2011.04.jpg?width=2400"),
            originalFileURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/9/9d/Kinderdijk%2C_Nederwaard_molens_no_1tm5_RM30543tm7_IMG_9354_2021-06-13_11.04.jpg"),
            title: "Kinderdijk windmills",
            description: "The UNESCO windmill landscape at Kinderdijk, used as a wide premium hero for Dutch water-management and windmill heritage content.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:Kinderdijk,_Nederwaard_molens_no_1tm5_RM30543tm7_IMG_9354_2021-06-13_11.04.jpg"),
            creator: "Wikimedia Commons contributor",
            author: "Wikimedia Commons contributor",
            license: "Wikimedia Commons file license",
            licenseName: "Wikimedia Commons file license",
            licenseURL: URL(string: "https://commons.wikimedia.org/wiki/File:Kinderdijk,_Nederwaard_molens_no_1tm5_RM30543tm7_IMG_9354_2021-06-13_11.04.jpg"),
            attribution: "Wikimedia Commons contributors",
            width: 2400,
            height: 1600,
            aspectRatio: 2400.0 / 1600.0,
            type: .cultureHero,
            verified: true,
            retrievedAt: "2026-06-01",
            titleKey: "contentMedia.culture.kinderdijk.title",
            descriptionKey: "contentMedia.culture.kinderdijk.description"
        ),

        // MARK: Official Sources / Guide

        AppImageAsset(
            id: "content-guide-leiden-grachten",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Leiden_Grachten_20.jpg?width=1600"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:Leiden_Grachten_20.jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Leiden_Grachten_20.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Leiden_Grachten_20.jpg?width=2400"),
            localAssetName: "home_leiden_canals",
            title: "Leiden canals",
            description: "The historic canal network of Leiden, a university city and one of the key centres for newcomer support in the Netherlands.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:Leiden_Grachten_20.jpg"),
            creator: "Willy Horsch",
            author: "Willy Horsch",
            license: "CC BY-SA 3.0",
            licenseName: "Creative Commons Attribution-Share Alike 3.0 Unported",
            licenseURL: URL(string: "https://creativecommons.org/licenses/by-sa/3.0/"),
            attribution: "Willy Horsch, via Wikimedia Commons",
            width: 2592,
            height: 1944,
            aspectRatio: 2592.0 / 1944.0,
            type: .officialSourcesHero,
            verified: true,
            retrievedAt: "2026-06-01",
            titleKey: "contentMedia.guide.leidenCanals.title",
            descriptionKey: "contentMedia.guide.leidenCanals.description"
        ),
    ]

    // MARK: - Typed accessors

    static var transportHero: AppImageAsset? {
        images.first { $0.id == "content-transport-amsterdam-bike-parking" }
    }

    static var transportStationHero: AppImageAsset? {
        images.first { $0.id == "content-transport-amsterdam-centraal-exterior" }
    }

    static var ovChipkaartImage: AppImageAsset? {
        images.first { $0.id == "content-transport-ovchipkaart-card" }
    }

    static var healthcarePharmacyImage: AppImageAsset? {
        images.first { $0.id == "content-healthcare-dutch-pharmacy" }
    }

    static var municipalityCityHallImage: AppImageAsset? {
        images.first { $0.id == "content-government-haarlem-city-hall" }
    }

    static var housingTerracedHousesImage: AppImageAsset? {
        images.first { $0.id == "content-housing-rijtjeshuizen" }
    }

    static var premiumHousingImage: AppImageAsset? {
        localCover(
            id: "content-housing-premium-local",
            localAssetName: "premium_home_housing",
            title: "Modern Dutch housing street",
            description: "A bright residential street used for housing, rent, and address registration topics.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail
        )
    }

    static var cultureHero: AppImageAsset? {
        images.first { $0.id == "content-culture-vermeer-girl-pearl-earring" }
    }

    static var cultureWideHero: AppImageAsset? {
        images.first { $0.id == "content-culture-kinderdijk-windmills" }
    }

    static var officialSourcesHero: AppImageAsset? {
        images.first { $0.id == "content-guide-leiden-grachten" }
    }

    static var homeAtmosphereHero: AppImageAsset? {
        images.first { $0.id == "content-home-amsterdam-canal-houses" }
    }

    static var cultureWindmillHero: AppImageAsset? {
        images.first { $0.id == "content-culture-kinderdijk-windmills" }
    }

    static var workImage: AppImageAsset? {
        localCover(
            id: "cover-work-zuidas",
            localAssetName: "home_work_zuidas",
            title: "Amsterdam Zuidas offices",
            description: "Office-district cover used for work, contracts, and employment topics.",
            sourceName: "Project bundled visual",
            type: .cardThumbnail,
            width: 1642,
            height: 2500
        )
    }

    static var foodImage: AppImageAsset? {
        localCover(
            id: "cover-food-local-life",
            localAssetName: "home_leiden_canals",
            title: "Leiden canals and local terraces",
            description: "Canal-side city scene used for food, cafes, restaurants, and daily local-life discovery.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail,
            width: 1920,
            height: 1207
        )
    }

    static var natureImage: AppImageAsset? {
        cultureWindmillHero
    }

    static var calendarImage: AppImageAsset? {
        localCover(
            id: "cover-calendar-netherlands",
            localAssetName: "premium_home_documents",
            title: "Netherlands calendar and events",
            description: "Premium bundled cover used for holidays, appointments, and event planning surfaces.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail,
            width: 1586,
            height: 992
        )
    }

    static var aiImage: AppImageAsset? {
        localCover(
            id: "cover-ai-assistant",
            localAssetName: "premium_home_language",
            title: "YouNew AI assistant guidance",
            description: "Premium bundled cover for AI guidance, language help, and next-step assistant surfaces.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail,
            width: 1586,
            height: 992
        )
    }

    static var emergencyImage: AppImageAsset? {
        localCover(
            id: "cover-emergency-services",
            localAssetName: "home_emergency_ambulance",
            title: "Dutch emergency services",
            description: "Emergency services cover used for urgent help and 112 topics.",
            sourceName: "Project bundled visual",
            type: .cardThumbnail,
            width: 1920,
            height: 1280
        )
    }

    static var mapImage: AppImageAsset? {
        localCover(
            id: "cover-netherlands-map",
            localAssetName: "netherlands_map_base",
            title: "Netherlands map",
            description: "Map cover used for place discovery and city navigation topics.",
            sourceName: "Project bundled visual",
            type: .cardThumbnail,
            aspectRatio: 1
        )
    }

    static var searchImage: AppImageAsset? {
        localCover(
            id: "cover-search-discovery",
            localAssetName: "premium_home_documents",
            title: "Search across trusted Netherlands services",
            description: "Premium bundled cover used for search, official answers, document topics, and country-wide service lookup.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail,
            width: 1586,
            height: 992
        )
    }

    static var savedImage: AppImageAsset? {
        localCover(
            id: "cover-saved-items",
            localAssetName: "premium_home_documents",
            title: "Saved guides and documents",
            description: "Premium bundled cover for saved places, guides, documents, and official-source bookmarks.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail,
            width: 1586,
            height: 992
        )
    }

    static var profileImage: AppImageAsset? {
        localCover(
            id: "cover-profile-personal-path",
            localAssetName: "premium_home_documents",
            title: "Personal newcomer profile",
            description: "Premium bundled cover for profile, onboarding, saved documents, and personalized newcomer path screens.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail,
            width: 1586,
            height: 992
        )
    }

    static var dailyCultureImage: AppImageAsset? {
        localCover(
            id: "content-culture-daily-life-local",
            localAssetName: "premium_home_language",
            title: "Dutch daily culture",
            description: "Premium bundled visual used for everyday culture and communication topics.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail,
            width: 1586,
            height: 992
        )
    }

    static var marketsLocalLifeImage: AppImageAsset? {
        localCover(
            id: "content-culture-markets-local-life",
            localAssetName: "home_leiden_canals",
            title: "Dutch canals and local life",
            description: "Canal-side city scene used for markets, food errands, and everyday local-life topics.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail,
            width: 1920,
            height: 1207
        )
    }

    static var delftHistoricCentreImage: AppImageAsset? {
        cultureWideHero
    }

    static var utrechtCanalsImage: AppImageAsset? {
        transportStationHero
    }

    static var directCommunicationImage: AppImageAsset? {
        localCover(
            id: "content-culture-direct-communication",
            localAssetName: "premium_home_language",
            title: "Dutch direct communication",
            description: "Premium bundled visual used for communication style and daily-culture guidance.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail,
            width: 1586,
            height: 992
        )
    }

    static var canalsCityCentresImage: AppImageAsset? {
        canalHousesHero
    }

    static var waterManagementImage: AppImageAsset? {
        cultureWideHero
    }

    static var deltaWorksImage: AppImageAsset? {
        mapImage
    }

    static var museumsCultureImage: AppImageAsset? {
        cultureHero
    }

    static var theHagueBinnenhofImage: AppImageAsset? {
        municipalityCityHallImage
    }

    static var governmentBasicsImage: AppImageAsset? {
        municipalityCityHallImage
    }

    static var bsnImage: AppImageAsset? {
        localCover(
            id: "content-government-bsn",
            localAssetName: "premium_home_documents",
            title: "BSN registration documents",
            description: "Premium bundled visual used for BSN, municipality, and document-registration topics.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail,
            width: 1586,
            height: 992
        )
    }

    static var digidImage: AppImageAsset? {
        localCover(
            id: "content-government-digid",
            localAssetName: "premium_home_documents",
            title: "DigiD and online government access",
            description: "Premium bundled visual used for DigiD and online public-service access topics.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail,
            width: 1586,
            height: 992
        )
    }

    static var governmentInstitutionsImage: AppImageAsset? {
        municipalityCityHallImage
    }

    static var healthcareBasicsImage: AppImageAsset? {
        healthcarePharmacyImage
    }

    static var healthInsuranceImage: AppImageAsset? {
        localCover(
            id: "content-healthcare-insurance",
            localAssetName: "premium_home_healthcare",
            title: "Dutch health insurance",
            description: "Premium bundled visual used for health insurance and care-system topics.",
            sourceName: "YouNew bundled artwork",
            type: .cardThumbnail,
            width: 1586,
            height: 992
        )
    }

    static var huisartsImage: AppImageAsset? {
        healthcarePharmacyImage
    }

    static var housingWonenImage: AppImageAsset? {
        premiumHousingImage
    }

    static var transportBasicsImage: AppImageAsset? {
        transportStationHero
    }

    static var ovpayImage: AppImageAsset? {
        mapImage
    }

    static var canalHousesHero: AppImageAsset? {
        images.first { $0.id == "content-home-amsterdam-canal-houses" }
    }

    static var leidenCanalsHero: AppImageAsset? {
        images.first { $0.id == "content-guide-leiden-grachten" }
    }

    private static func localCover(
        id: String,
        localAssetName: String,
        title: String,
        description: String,
        sourceName: String,
        type: AppImageType,
        aspectRatio: Double = 16.0 / 10.0,
        width: Int? = nil,
        height: Int? = nil
    ) -> AppImageAsset? {
        guard VisualAssetHelper.exists(localAssetName) else { return nil }
        return AppImageAsset(
            id: id,
            url: nil,
            localAssetName: localAssetName,
            title: title,
            description: description,
            sourceName: sourceName,
            sourceURL: nil,
            license: "Bundled app asset",
            attribution: "YouNew",
            width: width,
            height: height,
            aspectRatio: aspectRatio,
            type: type,
            verified: true,
            retrievedAt: "2026-06-27"
        )
    }

    static func image(forContentID id: String) -> AppImageAsset? {
        switch id {
        case "amsterdam-canals":
            return canalHousesHero
        case "dutch-daily-culture":
            return dailyCultureImage
        case "canals-city-centres":
            return canalsCityCentresImage
        case "cycling-culture":
            return transportHero
        case "kinderdijk-windmills":
            return cultureWindmillHero
        case "water-and-netherlands":
            return waterManagementImage
        case "delta-works":
            return deltaWorksImage
        case "rijksmuseum-museumplein":
            return cultureHero
        case "museums-public-culture":
            return museumsCultureImage
        case "the-hague-binnenhof":
            return theHagueBinnenhofImage
        case "leiden-old-centre-canals":
            return leidenCanalsHero
        case "markets-local-life":
            return marketsLocalLifeImage
        case "delft-historic-centre":
            return delftHistoricCentreImage
        case "utrecht-canals":
            return utrechtCanalsImage
        case "direct-communication-style":
            return directCommunicationImage
        case "rotterdam-architecture":
            return transportStationHero
        case "maastricht-historic-centre":
            return cultureWideHero
        case "municipality-registration":
            return municipalityCityHallImage
        case "bsn":
            return bsnImage
        case "digid":
            return digidImage
        case "government-institutions":
            return governmentInstitutionsImage
        case "finding-huisarts":
            return healthcarePharmacyImage
        case "healthcare-basics":
            return healthcareBasicsImage
        case "health-insurance":
            return healthInsuranceImage
        case "huisarts":
            return huisartsImage
        case "housing-basics":
            return housingTerracedHousesImage
        case "housing":
            return premiumHousingImage
        case "wonen":
            return housingWonenImage
        case "ov-chipkaart":
            return ovChipkaartImage
        case "transport-basics":
            return transportBasicsImage
        case "ovpay":
            return ovpayImage
        default:
            return nil
        }
    }
}

enum ContentArtworkSlot: String, CaseIterable {
    case aiHero
    case searchHero
    case searchRegistration
    case searchHealthcare
    case searchHousing
    case searchTransport
    case searchWork
    case searchEmergency
    case searchEducation
    case searchLegal
    case searchMap
    case cityHeroFallback
    case provinceHeroFallback
}

enum ContentArtworkRegistry {
    static func asset(for slot: ContentArtworkSlot) -> AppImageAsset? {
        switch slot {
        case .aiHero:
            return ContentMediaRegistry.aiImage ?? ContentMediaRegistry.officialSourcesHero
        case .searchHero:
            return ContentMediaRegistry.searchImage ?? ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero
        case .searchRegistration:
            return ContentMediaRegistry.municipalityCityHallImage
        case .searchHealthcare:
            return ContentMediaRegistry.healthcarePharmacyImage
        case .searchHousing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .searchTransport:
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case .searchWork:
            return ContentMediaRegistry.workImage
        case .searchEmergency:
            return ContentMediaRegistry.emergencyImage
        case .searchEducation:
            return ContentMediaRegistry.cultureHero
        case .searchLegal:
            return ContentMediaRegistry.officialSourcesHero
        case .searchMap:
            return ContentMediaRegistry.mapImage
        case .cityHeroFallback:
            return ContentMediaRegistry.homeAtmosphereHero ?? ContentMediaRegistry.leidenCanalsHero
        case .provinceHeroFallback:
            return ContentMediaRegistry.cultureWindmillHero ?? ContentMediaRegistry.mapImage
        }
    }

    static func duplicateArtworkViolations() -> [String] {
        var seen: [String: ContentArtworkSlot] = [:]
        var violations: [String] = []

        for slot in ContentArtworkSlot.allCases {
            guard let asset = asset(for: slot) else {
                violations.append("\(slot.rawValue): missing asset")
                continue
            }

            let key = normalizedIdentity(for: asset)
            if let previous = seen[key], !allowedDuplicate(slot, previous) {
                violations.append("\(previous.rawValue) and \(slot.rawValue) share \(key)")
            } else {
                seen[key] = slot
            }
        }

        return violations
    }

    private static func allowedDuplicate(_ lhs: ContentArtworkSlot, _ rhs: ContentArtworkSlot) -> Bool {
        false
    }

    private static func normalizedIdentity(for asset: AppImageAsset) -> String {
        if let localAssetName = asset.localAssetName, !localAssetName.isEmpty {
            return "local:\(localAssetName)"
        }
        if let url = asset.thumbnailURL ?? asset.imageURL ?? asset.url {
            return "url:\(url.absoluteString.lowercased())"
        }
        return "asset:\(asset.id.lowercased())"
    }

}
