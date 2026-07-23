import Foundation

enum HistoryMediaRegistry {
    static var teachingImages: [AppImageAsset] {
        images.filter {
            [
                "history-netherlands-map-1631",
                "history-amsterdam-westerkerk-1660",
                "history-afsluitdijk-aerial"
            ].contains($0.id)
        }
    }

    static let images: [AppImageAsset] = [
        AppImageAsset(
            id: "history-netherlands-map-1631",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Kaart_van_de_Nederlanden_%281631%29_by_Henricus_Hondius._Original_from_The_Rijksmuseum._Digitally_enhanced_by_rawpixel._%2850623712477%29.jpg?width=1600"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:Kaart_van_de_Nederlanden_(1631)_by_Henricus_Hondius._Original_from_The_Rijksmuseum._Digitally_enhanced_by_rawpixel._(50623712477).jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Kaart_van_de_Nederlanden_%281631%29_by_Henricus_Hondius._Original_from_The_Rijksmuseum._Digitally_enhanced_by_rawpixel._%2850623712477%29.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Kaart_van_de_Nederlanden_%281631%29_by_Henricus_Hondius._Original_from_The_Rijksmuseum._Digitally_enhanced_by_rawpixel._%2850623712477%29.jpg?width=1600"),
            originalFileURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/b/b1/Kaart_van_de_Nederlanden_%281631%29_by_Henricus_Hondius._Original_from_The_Rijksmuseum._Digitally_enhanced_by_rawpixel._%2850623712477%29.jpg"),
            title: "Map of the Netherlands, 1631",
            description: "A historical map used here as contextual visual material for early modern Dutch trade and provinces.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:Kaart_van_de_Nederlanden_(1631)_by_Henricus_Hondius._Original_from_The_Rijksmuseum._Digitally_enhanced_by_rawpixel._(50623712477).jpg"),
            creator: "Rijksmuseum; map by Henricus Hondius; digitally enhanced by rawpixel",
            author: "Rijksmuseum; Henricus Hondius; rawpixel",
            license: "CC BY 2.0",
            licenseName: "Creative Commons Attribution 2.0 Generic",
            licenseURL: URL(string: "https://creativecommons.org/licenses/by/2.0/"),
            attribution: "Rijksmuseum / Henricus Hondius / rawpixel, via Wikimedia Commons",
            width: 4476,
            height: 3566,
            aspectRatio: 4476.0 / 3566.0,
            type: .timeline,
            verified: true,
            retrievedAt: "2026-05-31",
            titleKey: "historyNetherlands.images.map.title",
            descriptionKey: "historyNetherlands.images.map.description"
        ),
        AppImageAsset(
            id: "history-amsterdam-westerkerk-1660",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/View_of_the_Westerkerk_Amsterdam_1660_Jan_van_der_Heyden.jpg?width=1400"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:View_of_the_Westerkerk_Amsterdam_1660_Jan_van_der_Heyden.jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/View_of_the_Westerkerk_Amsterdam_1660_Jan_van_der_Heyden.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/View_of_the_Westerkerk_Amsterdam_1660_Jan_van_der_Heyden.jpg?width=1400"),
            originalFileURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/b/b2/View_of_the_Westerkerk_Amsterdam_1660_Jan_van_der_Heyden.jpg"),
            title: "View of the Westerkerk, Amsterdam, 1660",
            description: "A Dutch Golden Age city view that connects the timeline to Amsterdam's urban and commercial growth.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:View_of_the_Westerkerk_Amsterdam_1660_Jan_van_der_Heyden.jpg"),
            creator: "Jan van der Heyden",
            author: "Jan van der Heyden",
            license: "Public domain",
            licenseName: "Public Domain Mark 1.0",
            licenseURL: URL(string: "https://creativecommons.org/publicdomain/mark/1.0/"),
            attribution: "Jan van der Heyden, via Wikimedia Commons",
            width: 3575,
            height: 2815,
            aspectRatio: 3575.0 / 2815.0,
            type: .timeline,
            verified: true,
            retrievedAt: "2026-05-31",
            titleKey: "historyNetherlands.images.goldenAge.title",
            descriptionKey: "historyNetherlands.images.goldenAge.description"
        ),
        AppImageAsset(
            id: "history-afsluitdijk-aerial",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/NIMH_-_2011_-_3550_-_Aerial_photograph_of_Afsluitdijk%2C_The_Netherlands.jpg?width=1400"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:NIMH_-_2011_-_3550_-_Aerial_photograph_of_Afsluitdijk,_The_Netherlands.jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/NIMH_-_2011_-_3550_-_Aerial_photograph_of_Afsluitdijk%2C_The_Netherlands.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/NIMH_-_2011_-_3550_-_Aerial_photograph_of_Afsluitdijk%2C_The_Netherlands.jpg?width=1400"),
            originalFileURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/1/1a/NIMH_-_2011_-_3550_-_Aerial_photograph_of_Afsluitdijk%2C_The_Netherlands.jpg"),
            title: "Aerial photograph of Afsluitdijk",
            description: "A modern water-management image that links Dutch history to the continuing relationship with water.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:NIMH_-_2011_-_3550_-_Aerial_photograph_of_Afsluitdijk,_The_Netherlands.jpg"),
            creator: "Unknown; Nederlands Instituut voor Militaire Historie collection",
            author: "Unknown; Nederlands Instituut voor Militaire Historie",
            license: "CC BY-SA 4.0",
            licenseName: "Creative Commons Attribution-Share Alike 4.0 International",
            licenseURL: URL(string: "https://creativecommons.org/licenses/by-sa/4.0/"),
            attribution: "Nederlands Instituut voor Militaire Historie / Wikimedia Commons",
            width: 3500,
            height: 2630,
            aspectRatio: 3500.0 / 2630.0,
            type: .timeline,
            verified: true,
            retrievedAt: "2026-05-31",
            titleKey: "historyNetherlands.images.water.title",
            descriptionKey: "historyNetherlands.images.water.description"
        ),

        // MARK: Golden Age Masterworks

        AppImageAsset(
            id: "history-rembrandt-night-watch-1642",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/The%20Nightwatch%20by%20Rembrandt%20-%20Rijksmuseum.jpg?width=1600"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:The_Nightwatch_by_Rembrandt_-_Rijksmuseum.jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/The%20Nightwatch%20by%20Rembrandt%20-%20Rijksmuseum.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/The%20Nightwatch%20by%20Rembrandt%20-%20Rijksmuseum.jpg?width=1600"),
            originalFileURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/9/94/The_Nightwatch_by_Rembrandt_-_Rijksmuseum.jpg"),
            title: "The Night Watch, 1642",
            description: "Rembrandt's most celebrated group portrait, depicting Amsterdam's militia company — a defining work of the Dutch Golden Age.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:The_Nightwatch_by_Rembrandt_-_Rijksmuseum.jpg"),
            creator: "Rembrandt van Rijn",
            author: "Rembrandt van Rijn (1642)",
            license: "Public Domain",
            licenseName: "Public Domain — copyright expired",
            licenseURL: URL(string: "https://creativecommons.org/publicdomain/mark/1.0/"),
            attribution: "Rembrandt van Rijn (1642), Rijksmuseum Amsterdam — Public Domain via Wikimedia Commons",
            width: 14168,
            height: 11528,
            aspectRatio: 14168.0 / 11528.0,
            type: .timeline,
            verified: true,
            retrievedAt: "2026-07-22",
            titleKey: "historyNetherlands.images.nightWatch.title",
            descriptionKey: "historyNetherlands.images.nightWatch.description"
        ),

        AppImageAsset(
            id: "history-rembrandt-anatomy-lesson-1632",
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Rembrandt_-_The_Anatomy_Lesson_of_Dr_Nicolaes_Tulp.jpg?width=1600"),
            sourcePageURL: URL(string: "https://commons.wikimedia.org/wiki/File:Rembrandt_-_The_Anatomy_Lesson_of_Dr_Nicolaes_Tulp.jpg"),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Rembrandt_-_The_Anatomy_Lesson_of_Dr_Nicolaes_Tulp.jpg"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Rembrandt_-_The_Anatomy_Lesson_of_Dr_Nicolaes_Tulp.jpg?width=1600"),
            originalFileURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/4/4d/Rembrandt_-_The_Anatomy_Lesson_of_Dr_Nicolaes_Tulp.jpg"),
            title: "The Anatomy Lesson of Dr Nicolaes Tulp, 1632",
            description: "Rembrandt's early masterpiece showing a public anatomy lecture in Amsterdam, reflecting the scientific spirit of the Dutch Golden Age.",
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:Rembrandt_-_The_Anatomy_Lesson_of_Dr_Nicolaes_Tulp.jpg"),
            creator: "Rembrandt van Rijn",
            author: "Rembrandt van Rijn (1632)",
            license: "Public Domain",
            licenseName: "Public Domain — copyright expired",
            licenseURL: URL(string: "https://creativecommons.org/publicdomain/mark/1.0/"),
            attribution: "Rembrandt van Rijn (1632), Mauritshuis, The Hague — Public Domain via Wikimedia Commons",
            width: 3576,
            height: 2808,
            aspectRatio: 3576.0 / 2808.0,
            type: .timeline,
            verified: true,
            retrievedAt: "2026-06-01",
            titleKey: "historyNetherlands.images.anatomyLesson.title",
            descriptionKey: "historyNetherlands.images.anatomyLesson.description"
        ),
    ]

    static var heroImage: AppImageAsset? {
        images.first
    }
}
