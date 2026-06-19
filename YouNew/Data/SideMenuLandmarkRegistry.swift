import Foundation

enum SideMenuLandmarkRegistry {
    static let images: [AppImageAsset] = [
        landmark(
            id: "side-menu-amsterdam-canals",
            title: "Amsterdam canals",
            description: "Canal houses and water routes in Amsterdam's historic centre.",
            placeName: "Amsterdam",
            fileName: "Amsterdam_Canals_%2836728184714%29.jpg",
            sourcePage: "https://commons.wikimedia.org/wiki/File:Amsterdam_Canals_(36728184714).jpg",
            originalFile: "https://upload.wikimedia.org/wikipedia/commons/8/8d/Amsterdam_Canals_%2836728184714%29.jpg",
            creator: "Billie Grace Ward",
            license: "CC BY 2.0",
            licenseName: "Creative Commons Attribution 2.0 Generic",
            licenseURL: "https://creativecommons.org/licenses/by/2.0/",
            attribution: "Billie Grace Ward, via Wikimedia Commons",
            width: 4864,
            height: 3243,
            titleKey: "sideMenu.landmark.amsterdam.title"
        ),
        landmark(
            id: "side-menu-leiden-canals",
            title: "Leiden canals",
            description: "Historic canals in Leiden's old centre.",
            placeName: "Leiden",
            fileName: "Leiden_Grachten_24.jpg",
            sourcePage: "https://commons.wikimedia.org/wiki/File:Leiden_Grachten_24.jpg",
            originalFile: "https://upload.wikimedia.org/wikipedia/commons/f/fb/Leiden_Grachten_24.jpg",
            creator: "Zairon",
            license: "CC BY-SA 4.0",
            licenseName: "Creative Commons Attribution-Share Alike 4.0 International",
            licenseURL: "https://creativecommons.org/licenses/by-sa/4.0/",
            attribution: "Zairon, via Wikimedia Commons",
            width: 4592,
            height: 3117,
            titleKey: "sideMenu.landmark.leiden.title"
        ),
        landmark(
            id: "side-menu-delft-centre",
            title: "Delft historic centre",
            description: "A canal-side street scene in the centre of Delft.",
            placeName: "Delft",
            fileName: "Delft_centre.JPG",
            sourcePage: "https://commons.wikimedia.org/wiki/File:Delft_centre.JPG",
            originalFile: "https://upload.wikimedia.org/wikipedia/commons/1/1d/Delft_centre.JPG",
            creator: "Jens Buurgaard Nielsen",
            license: "CC BY-SA 2.0",
            licenseName: "Creative Commons Attribution-Share Alike 2.0 Generic",
            licenseURL: "https://creativecommons.org/licenses/by-sa/2.0/",
            attribution: "Jens Buurgaard Nielsen, via Wikimedia Commons",
            width: 2560,
            height: 1920,
            titleKey: "sideMenu.landmark.delft.title"
        ),
        landmark(
            id: "side-menu-rotterdam-erasmusbrug",
            title: "Erasmus Bridge, Rotterdam",
            description: "Rotterdam's modern waterfront architecture around the Erasmus Bridge.",
            placeName: "Rotterdam",
            fileName: "Rotterdam_-_Erasmusbrug.jpg",
            sourcePage: "https://commons.wikimedia.org/wiki/File:Rotterdam_-_Erasmusbrug.jpg",
            originalFile: "https://upload.wikimedia.org/wikipedia/commons/8/86/Rotterdam_-_Erasmusbrug.jpg",
            creator: "Fred Romero",
            license: "CC BY 2.0",
            licenseName: "Creative Commons Attribution 2.0 Generic",
            licenseURL: "https://creativecommons.org/licenses/by/2.0/",
            attribution: "Fred Romero, via Wikimedia Commons",
            width: 5184,
            height: 3456,
            titleKey: "sideMenu.landmark.rotterdam.title"
        ),
        landmark(
            id: "side-menu-the-hague-binnenhof",
            title: "Binnenhof, The Hague",
            description: "The Binnenhof area in The Hague.",
            placeName: "The Hague",
            aliases: ["Den Haag", "s-Gravenhage"],
            fileName: "Binnenhof,_The_Hague_1834.jpg",
            sourcePage: "https://commons.wikimedia.org/wiki/File:Binnenhof,_The_Hague_1834.jpg",
            originalFile: "https://upload.wikimedia.org/wikipedia/commons/1/10/Binnenhof%2C_The_Hague_1834.jpg",
            creator: "Hubertl",
            license: "CC BY-SA 4.0",
            licenseName: "Creative Commons Attribution-Share Alike 4.0 International",
            licenseURL: "https://creativecommons.org/licenses/by-sa/4.0/",
            attribution: "Hubertl, via Wikimedia Commons",
            width: 5472,
            height: 3648,
            titleKey: "sideMenu.landmark.hague.title"
        ),
        landmark(
            id: "side-menu-utrecht-oude-gracht",
            title: "Oudegracht, Utrecht",
            description: "The Oudegracht canal in Utrecht.",
            placeName: "Utrecht",
            fileName: "Utrecht_-_Oudegracht_%2816585773556%29.jpg",
            sourcePage: "https://commons.wikimedia.org/wiki/File:Utrecht_-_Oudegracht_(16585773556).jpg",
            originalFile: "https://upload.wikimedia.org/wikipedia/commons/e/e8/Utrecht_-_Oudegracht_%2816585773556%29.jpg",
            creator: "Rob Kemme",
            license: "CC BY-SA 2.0",
            licenseName: "Creative Commons Attribution-Share Alike 2.0 Generic",
            licenseURL: "https://creativecommons.org/licenses/by-sa/2.0/",
            attribution: "Rob Kemme, via Wikimedia Commons",
            width: 1680,
            height: 1118,
            titleKey: "sideMenu.landmark.utrecht.title"
        ),
        landmark(
            id: "side-menu-kinderdijk-windmills",
            title: "Dutch windmill heritage",
            description: "Historic working windmills in a Dutch heritage landscape.",
            placeName: "Windmill heritage",
            fileName: "Zaanse_Schans_2019.jpg",
            sourcePage: "https://commons.wikimedia.org/wiki/File:Zaanse_Schans_2019.jpg",
            originalFile: "https://upload.wikimedia.org/wikipedia/commons/5/59/Zaanse_Schans_2019.jpg",
            creator: "Tarod",
            license: "CC BY-SA 3.0 NL",
            licenseName: "Creative Commons Attribution-Share Alike 3.0 Netherlands",
            licenseURL: "https://creativecommons.org/licenses/by-sa/3.0/nl/deed.en",
            attribution: "Tarod, via Wikimedia Commons",
            width: 3901,
            height: 2601,
            titleKey: "sideMenu.landmark.kinderdijk.title"
        ),
        landmark(
            id: "side-menu-amsterdam-rijksmuseum",
            title: "Rijksmuseum, Amsterdam",
            description: "The Rijksmuseum national museum on Museumplein in Amsterdam.",
            placeName: "Amsterdam",
            aliases: ["Museumplein"],
            fileName: "Rijksmuseum_Amsterdam_2014.jpg",
            sourcePage: "https://commons.wikimedia.org/wiki/File:Rijksmuseum_Amsterdam_2014.jpg",
            originalFile: "https://upload.wikimedia.org/wikipedia/commons/d/d7/Rijksmuseum_Amsterdam_2014.jpg",
            creator: "Timitrius",
            license: "CC BY 2.0",
            licenseName: "Creative Commons Attribution 2.0 Generic",
            licenseURL: "https://creativecommons.org/licenses/by/2.0/",
            attribution: "Timitrius, via Wikimedia Commons",
            width: 4288,
            height: 2848,
            titleKey: "sideMenu.landmark.rijksmuseum.title"
        ),
        landmark(
            id: "side-menu-maastricht-vrijthof",
            title: "Vrijthof, Maastricht",
            description: "The historic Vrijthof square in Maastricht's city centre.",
            placeName: "Maastricht",
            fileName: "Vrijthof_Maastricht.jpg",
            sourcePage: "https://commons.wikimedia.org/wiki/File:Vrijthof_Maastricht.jpg",
            originalFile: "https://upload.wikimedia.org/wikipedia/commons/5/55/Vrijthof_Maastricht.jpg",
            creator: "Raimond Spekking",
            license: "CC BY-SA 4.0",
            licenseName: "Creative Commons Attribution-Share Alike 4.0 International",
            licenseURL: "https://creativecommons.org/licenses/by-sa/4.0/",
            attribution: "Raimond Spekking, via Wikimedia Commons",
            width: 3888,
            height: 2592,
            titleKey: "sideMenu.landmark.maastricht.title"
        )
    ]

    static var fallback: AppImageAsset {
        images.first { $0.id == "side-menu-leiden-canals" } ?? images[0]
    }

    static func hero(for cityName: String?, rotationSeed: Int) -> AppImageAsset {
        if let cityName, let cityImage = image(for: cityName) {
            return cityImage
        }

        guard !images.isEmpty else { return fallback }
        let index = Int(rotationSeed.magnitude % UInt(images.count))
        return images[index]
    }

    static func image(for cityName: String) -> AppImageAsset? {
        let normalized = normalize(cityName)
        return images.first { image in
            citySearchTerms(for: image).contains(normalized)
        }
    }

    nonisolated static func citySearchTerms(for image: AppImageAsset) -> Set<String> {
        var terms: Set<String> = []
        if let description = image.description {
            terms.insert(normalize(description))
        }
        terms.insert(normalize(image.title))

        switch image.id {
        case "side-menu-amsterdam-canals":
            terms.insert(normalize("Amsterdam"))
        case "side-menu-leiden-canals":
            terms.insert(normalize("Leiden"))
        case "side-menu-delft-centre":
            terms.insert(normalize("Delft"))
        case "side-menu-rotterdam-erasmusbrug":
            terms.insert(normalize("Rotterdam"))
        case "side-menu-the-hague-binnenhof":
            terms.formUnion(["the hague", "den haag", "s-gravenhage"].map(normalize))
        case "side-menu-utrecht-oude-gracht":
            terms.insert(normalize("Utrecht"))
        case "side-menu-kinderdijk-windmills":
            terms.insert(normalize("Windmill heritage"))
        case "side-menu-amsterdam-rijksmuseum":
            terms.formUnion(["Amsterdam", "Rijksmuseum", "Museumplein"].map(normalize))
        case "side-menu-maastricht-vrijthof":
            terms.formUnion(["Maastricht", "Vrijthof"].map(normalize))
        default:
            terms.insert(normalize(image.title.components(separatedBy: ",").last ?? image.title))
        }

        return terms
    }

    private static func landmark(
        id: String,
        title: String,
        description: String,
        placeName: String,
        aliases: [String] = [],
        fileName: String,
        sourcePage: String,
        originalFile: String,
        creator: String,
        license: String,
        licenseName: String,
        licenseURL: String,
        attribution: String,
        width: Int,
        height: Int,
        titleKey: String
    ) -> AppImageAsset {
        let encodedFileName = fileName.replacingOccurrences(of: " ", with: "_")
        return AppImageAsset(
            id: id,
            url: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/\(encodedFileName)?width=900"),
            sourcePageURL: URL(string: sourcePage),
            imageURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/\(encodedFileName)"),
            thumbnailURL: URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/\(encodedFileName)?width=900"),
            originalFileURL: URL(string: originalFile),
            title: title,
            description: ([placeName] + aliases + [description]).joined(separator: " | "),
            sourceName: "Wikimedia Commons",
            sourceURL: URL(string: sourcePage),
            creator: creator,
            author: creator,
            license: license,
            licenseName: licenseName,
            licenseURL: URL(string: licenseURL),
            attribution: attribution,
            width: width,
            height: height,
            aspectRatio: Double(width) / Double(height),
            type: .sideMenuHero,
            verified: true,
            retrievedAt: "2026-06-01",
            titleKey: titleKey
        )
    }

    private nonisolated static func normalize(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
