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
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Canal%20houses%20and%20Oude%20Kerk%20at%20blue%20hour%20with%20water%20reflection%20in%20Damrak%20Amsterdam%20Netherlands.jpg?width=1200"),
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
            url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/2/2c/The_windmills_of_Kinderdijk.JPG"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:The_windmills_of_Kinderdijk.JPG"),
            imageURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/2/2c/The_windmills_of_Kinderdijk.JPG"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/The%20windmills%20of%20Kinderdijk.JPG?width=1600"),
            originalFileURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/2/2c/The_windmills_of_Kinderdijk.JPG"),
            title: "Kinderdijk windmills",
            description: "The UNESCO windmill landscape at Kinderdijk, used for Dutch water-management and windmill heritage content.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:The_windmills_of_Kinderdijk.JPG"),
            creator: "Wikimedia Commons contributor",
            author: "Wikimedia Commons contributor",
            license: "Wikimedia Commons file license",
            licenseName: "Wikimedia Commons file license",
            licenseURL: URL(string: "https://commons.wikimedia.org/wiki/File:The_windmills_of_Kinderdijk.JPG"),
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
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Leiden_Grachten_20.jpg?width=1200"),
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

    static var cultureHero: AppImageAsset? {
        images.first { $0.id == "content-culture-vermeer-girl-pearl-earring" }
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

    static var canalHousesHero: AppImageAsset? {
        images.first { $0.id == "content-home-amsterdam-canal-houses" }
    }

    static var leidenCanalsHero: AppImageAsset? {
        images.first { $0.id == "content-guide-leiden-grachten" }
    }

    static func image(forContentID id: String) -> AppImageAsset? {
        switch id {
        case "amsterdam-canals":
            return canalHousesHero
        case "dutch-daily-culture":
            return nil
        case "canals-city-centres":
            return nil
        case "cycling-culture":
            return transportHero
        case "kinderdijk-windmills":
            return cultureWindmillHero
        case "water-and-netherlands", "delta-works":
            return nil
        case "rijksmuseum-museumplein":
            return cultureHero
        case "museums-public-culture", "the-hague-binnenhof":
            return nil
        case "leiden-old-centre-canals":
            return leidenCanalsHero
        case "markets-local-life", "delft-historic-centre", "utrecht-canals":
            return nil
        case "direct-communication-style":
            return nil
        case "rotterdam-architecture":
            return transportStationHero
        case "maastricht-historic-centre":
            return nil
        case "municipality-registration":
            return municipalityCityHallImage
        case "bsn", "digid", "government-institutions":
            return nil
        case "finding-huisarts":
            return healthcarePharmacyImage
        case "healthcare-basics", "health-insurance", "huisarts":
            return nil
        case "housing-basics":
            return housingTerracedHousesImage
        case "housing", "wonen":
            return nil
        case "ov-chipkaart":
            return ovChipkaartImage
        case "transport-basics", "ovpay":
            return nil
        default:
            return nil
        }
    }
}
