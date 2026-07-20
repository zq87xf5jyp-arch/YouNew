import Foundation

enum LicensedPartnerMediaRegistry {
    static let leidenUniversity = media(
        url: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Leiden_Academiegebouw.jpg/1280px-Leiden_Academiegebouw.jpg",
        alt: "Leiden University Academy Building at Rapenburg",
        source: "Wikimedia Commons · Leiden Academiegebouw.jpg · CHEN Dadi",
        license: "CC BY-SA 3.0 NL · https://creativecommons.org/licenses/by-sa/3.0/nl/"
    )

    static let lumcLeiden = media(
        url: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Poortgebouw_LUMC_Leiden.jpg/1280px-Poortgebouw_LUMC_Leiden.jpg",
        alt: "Poortgebouw of Leiden University Medical Center",
        source: "Wikimedia Commons · Poortgebouw LUMC Leiden.jpg · Tubantia",
        license: "CC BY-SA 3.0 and GFDL · https://creativecommons.org/licenses/by-sa/3.0/"
    )

    static let leidenCentralContext = media(
        url: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Leiden_Centraal_Station_6838.jpg/1280px-Leiden_Centraal_Station_6838.jpg",
        alt: "Leiden Centraal facade near the station partner location",
        source: "Wikimedia Commons · Leiden Centraal Station 6838.jpg · C messier",
        license: "CC BY-SA 4.0 · https://creativecommons.org/licenses/by-sa/4.0/"
    )

    static let amsterdamUMC = media(
        url: "https://commons.wikimedia.org/wiki/Special:FilePath/Amsterdam%20UMC.jpg?width=1600",
        alt: "Amsterdam University Medical Center building",
        source: "Wikimedia Commons · Amsterdam UMC.jpg · Filipjack",
        license: "CC0 1.0 · https://creativecommons.org/publicdomain/zero/1.0/"
    )

    static let erasmusMC = media(
        url: "https://commons.wikimedia.org/wiki/Special:FilePath/Erasmus%20MC%202012.JPG?width=1600",
        alt: "Erasmus MC hospital building in Rotterdam",
        source: "Wikimedia Commons · Erasmus MC 2012.JPG · Racingfreak",
        license: "CC BY-SA 3.0 · https://creativecommons.org/licenses/by-sa/3.0/"
    )

    static let utrechtUniversity = media(
        url: "https://commons.wikimedia.org/wiki/Special:FilePath/The%20Academiegebouw%20in%20Utrecht.jpg?width=1600",
        alt: "Utrecht University Academy Building at Domplein",
        source: "Wikimedia Commons · The Academiegebouw in Utrecht.jpg · Robert von Oliva (naruciakk)",
        license: "CC0 1.0 · https://creativecommons.org/publicdomain/zero/1.0/"
    )

    private static func media(url: String, alt: String, source: String, license: String) -> LocalPartnerMediaSet {
        let imageURL = AppURL.make(url)
        func asset(_ role: LocalPartnerVisualRole) -> LocalPartnerVisualAsset {
            LocalPartnerVisualAsset(role: role, url: imageURL, altText: alt, sourceTitle: source, licenseNote: license)
        }
        return LocalPartnerMediaSet(
            hero: asset(.hero),
            gallery: [asset(.gallery)],
            thumbnail: asset(.thumbnail),
            mapPreview: asset(.mapPreview),
            logo: nil
        )
    }
}
