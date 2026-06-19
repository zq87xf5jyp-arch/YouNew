import Foundation

struct CuratedPlaceHeroMedia: Equatable {
    let placeId: String
    let assetName: String
    let license: String?
    let sourceURL: URL?
    let remoteURL: URL?
}

enum CityVisualRole: String, CaseIterable, Equatable {
    case hero
    case landmark
    case culture
    case night
    case thumbnail
    case card
}

enum ProvinceVisualRole: String, CaseIterable, Equatable {
    case landscape
    case culture
    case nature
    case architecture
    case tourism
}

struct CuratedPlaceVisualMedia: Equatable {
    let placeId: String
    let role: String
    let title: String
    let why: String
    let assetName: String
    let remoteURL: URL?
    let sourceURL: URL?
    let license: String?
    let minimumPixelWidth: Int
    let safeAreaNote: String
}

enum CuratedPlaceHeroMediaRegistry {
    static let cityPlaceholderAssetName = bundledEmergencyFallbackAssetName
    static let provincePlaceholderAssetName = bundledEmergencyFallbackAssetName
    static let bundledEmergencyFallbackAssetName = "premium_netherlands_emergency_fallback"
    static let netherlandsPremiumFallbackURL: URL? = nil

    static let mediaByPlaceId: [String: CuratedPlaceHeroMedia] = [
        // ── Cities ──
        "nl-city-noord_holland-amsterdam": media("nl-city-noord_holland-amsterdam", "hero_amsterdam", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Canal%20houses%20and%20Oude%20Kerk%20at%20blue%20hour%20with%20water%20reflection%20in%20Damrak%20Amsterdam%20Netherlands.jpg?width=2400"),
        "nl-city-noord_holland-haarlem": media("nl-city-noord_holland-haarlem", "hero_haarlem", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Zijlstrat%20Grote%20Markt%20Haarlem.jpg?width=2400"),
        "nl-city-noord_holland-alkmaar": media("nl-city-noord_holland-alkmaar", "hero_alkmaar", remote: "https://upload.wikimedia.org/wikipedia/commons/6/61/Alkmaar_-_Waagplein_-_De_Waag_-_Cheese_Weighhouse_1583.jpg"),
        "nl-city-noord_holland-hoorn": media("nl-city-noord_holland-hoorn", "hero_hoorn", remote: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Hoorn_Harbor_Dawn_%2828288594445%29.jpg/3840px-Hoorn_Harbor_Dawn_%2828288594445%29.jpg"),
        "nl-city-noord_holland-zaanstad": media("nl-city-noord_holland-zaanstad", "hero_zaanstad", remote: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Zaanse_Schans_2019.jpg/3840px-Zaanse_Schans_2019.jpg"),
        "nl-city-noord_holland-amstelveen": media("nl-city-noord_holland-amstelveen", "hero_amstelveen", remote: "https://upload.wikimedia.org/wikipedia/commons/2/2a/Amstelveen_Laan_van_Deshima.jpg"),
        "nl-city-noord_holland-purmerend": media("nl-city-noord_holland-purmerend", "hero_purmerend", remote: "https://upload.wikimedia.org/wikipedia/commons/3/31/Koemarkt_Purmerend_in_de_zomer.JPG"),
        "nl-city-noord_holland-heerhugowaard": media("nl-city-noord_holland-heerhugowaard", "hero_heerhugowaard", remote: "https://upload.wikimedia.org/wikipedia/commons/4/42/Station_Heerhugowaard_%282024%29-11.jpg"),
        "nl-city-zuid_holland-rotterdam": media("nl-city-zuid_holland-rotterdam", "hero_rotterdam", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Erasmusbrug%20seen%20from%20Euromast.jpg?width=2400"),
        "nl-city-zuid_holland-den_haag": media("nl-city-zuid_holland-den_haag", "hero_den_haag", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Friedenspalast_Den_Haag.jpg?width=2400"),
        "nl-city-zuid_holland-leiden": media("nl-city-zuid_holland-leiden", "hero_leiden", remote: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Leiden_Grachten_20.jpg/3840px-Leiden_Grachten_20.jpg"),
        "nl-city-zuid_holland-delft": media("nl-city-zuid_holland-delft", "hero_delft", remote: "https://upload.wikimedia.org/wikipedia/commons/c/c2/Delft_Blick_von_der_Nieuwe_Kerk_auf_die_Oude_Kerk_1.jpg"),
        "nl-city-utrecht-utrecht": media("nl-city-utrecht-utrecht", "hero_utrecht", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Utrecht%2C%20de%20Domtoren%20%28RM36075%29%20vanaf%20de%20Oudegracht%20230%20ongeveer%20foto5%202015-11-01%2008.56.jpg?width=2400"),
        "nl-city-utrecht-amersfoort": media("nl-city-utrecht-amersfoort", "hero_amersfoort", remote: "https://upload.wikimedia.org/wikipedia/commons/e/e3/Amersfoort_Zuidsingel.JPG"),
        "nl-city-gelderland-arnhem": media("nl-city-gelderland-arnhem", "hero_arnhem", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Arnhem%2C%20de%20John%20Frostbrug%20RM529907%20IMG%203795%202024-07-15%2013.06.jpg?width=2400"),
        "nl-city-gelderland-nijmegen": media("nl-city-gelderland-nijmegen", "hero_nijmegen", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Nijmegen%20Waalbrug%20R01.jpg?width=2400"),
        "nl-city-noord_brabant-eindhoven": media("nl-city-noord_brabant-eindhoven", "hero_eindhoven", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Eindhoven-Witte%20Dame%20%285%29.jpg?width=2400"),
        "nl-city-noord_brabant-tilburg": media("nl-city-noord_brabant-tilburg", "hero_tilburg", remote: "https://upload.wikimedia.org/wikipedia/commons/3/3f/De_heuvel_in_Tilburg.jpg"),
        "nl-city-noord_brabant-breda": media("nl-city-noord_brabant-breda", "hero_breda", remote: "https://upload.wikimedia.org/wikipedia/commons/2/2d/2010-05-21-breda-by-RalfR-06.jpg"),
        "nl-city-noord_brabant-s_hertogenbosch": media("nl-city-noord_brabant-s_hertogenbosch", "hero_s_hertogenbosch", remote: "https://upload.wikimedia.org/wikipedia/commons/f/f1/St._Jans_cathedral_%27s-Hertogenbosch.jpg"),
        "nl-city-noord_brabant-den_bosch": media("nl-city-noord_brabant-den_bosch", "hero_s_hertogenbosch", remote: "https://upload.wikimedia.org/wikipedia/commons/f/f1/St._Jans_cathedral_%27s-Hertogenbosch.jpg"),
        "nl-city-limburg-maastricht": media("nl-city-limburg-maastricht", "hero_maastricht", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/2022_Magisch_Maastricht_%2801%29.jpg?width=2400"),
        "nl-city-limburg-venlo": media("nl-city-limburg-venlo", "hero_venlo", remote: "https://upload.wikimedia.org/wikipedia/commons/7/75/Venlo_%E2%80%93_Parade_-_panoramio.jpg"),
        "nl-city-overijssel-zwolle": media("nl-city-overijssel-zwolle", "hero_zwolle", remote: "https://upload.wikimedia.org/wikipedia/commons/1/12/Sassenstraat_1-15%2C_Zwolle.jpg"),
        "nl-city-flevoland-almere": media("nl-city-flevoland-almere", "hero_almere", remote: "https://upload.wikimedia.org/wikipedia/commons/1/1e/Centrum_Almere_Stad%2C_Almere%2C_Netherlands_-_panoramio.jpg"),
        "nl-city-flevoland-lelystad": media("nl-city-flevoland-lelystad", "hero_lelystad", remote: "https://upload.wikimedia.org/wikipedia/commons/6/6b/Lelystad%2C_reconstructie_van_de_Batavia_op_de_Bataviawerf_IMG_4212_2024-07-28_13.28.jpg"),
        "nl-city-groningen-groningen": media("nl-city-groningen-groningen", "hero_groningen", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/20100523%20Grote%20Markt%20en%20Martinitoren%20Groningen%20NL.jpg?width=2400"),
        "nl-city-friesland-leeuwarden": media("nl-city-friesland-leeuwarden", "hero_leeuwarden", remote: "https://upload.wikimedia.org/wikipedia/commons/8/88/Nieuwestad-_Leeuwarden.jpg"),
        "nl-city-drenthe-assen": media("nl-city-drenthe-assen", "hero_assen", remote: "https://upload.wikimedia.org/wikipedia/commons/9/9d/AssenMarkt.JPG"),
        "nl-city-zeeland-middelburg": media("nl-city-zeeland-middelburg", "hero_middelburg", remote: "https://upload.wikimedia.org/wikipedia/commons/0/03/Middelburg_Stadhuis_01.JPG"),
        // ── Provinces ──
        "nl-province-noord_holland": media("nl-province-noord_holland", "hero_province_noord_holland", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Keukenhof%20tulips%20and%20windmill.jpg?width=2400"),
        "nl-province-zuid_holland": media("nl-province-zuid_holland", "hero_province_zuid_holland", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/South%20Holland%20by%20Sentinel-2%2C%202018-06-30.jpg?width=2400"),
        "nl-province-utrecht": media("nl-province-utrecht", "hero_province_utrecht", remote: "https://upload.wikimedia.org/wikipedia/commons/8/8d/Dom_Tower_Utrecht%2C_Netherlands.jpg"),
        "nl-province-gelderland": media("nl-province-gelderland", "hero_province_gelderland", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Nationaal%20Park%20De%20Hoge%20Veluwe%20-%20De%20Pollen%20-%20panoramio.jpg?width=2400"),
        "nl-province-noord_brabant": media("nl-province-noord_brabant", "hero_province_noord_brabant", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Biesbosch%20National%20Park%20Netherlands.jpg?width=2400"),
        "nl-province-limburg": media("nl-province-limburg", "hero_province_limburg", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Limburg%20hills%20near%20Vijlen.jpg?width=2400"),
        "nl-province-overijssel": media("nl-province-overijssel", "hero_province_overijssel", remote: "https://upload.wikimedia.org/wikipedia/commons/d/d7/Giethoorn_Netherlands_Channels-and-houses-of-Giethoorn-05.jpg"),
        "nl-province-flevoland": media("nl-province-flevoland", "hero_province_flevoland", remote: "https://upload.wikimedia.org/wikipedia/commons/b/b6/Oostvaardersplassen._Nieuwe_natuur_op_de_bodem_van_de_voormalige_Zuiderzee_09.jpg"),
        "nl-province-groningen": media("nl-province-groningen", "hero_province_groningen", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Hoge%20der%20Aa2.jpg?width=2400"),
        "nl-province-friesland": media("nl-province-friesland", "hero_province_friesland", remote: "https://upload.wikimedia.org/wikipedia/commons/9/90/Wierum_%28Noardeast-Frysl%C3%A2n%29%2C_10-07-2023._%28d.j.b%29_01.jpg"),
        "nl-province-drenthe": media("nl-province-drenthe", "hero_province_drenthe", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Hunebed_D27_in_Borger_flickr.jpg?width=2400"),
        "nl-province-zeeland": media("nl-province-zeeland", "hero_province_zeeland", remote: "https://upload.wikimedia.org/wikipedia/commons/0/01/Vrouwenpolder_%28NL%29%2C_Oosterscheldekering_--_2022_--_5016.jpg")
    ]

    static let cityVisualsByPlaceId: [String: [CityVisualRole: CuratedPlaceVisualMedia]] = [
        "nl-city-noord_holland-amsterdam": [
            .hero: visual("nl-city-noord_holland-amsterdam", "hero", "Damrak canal houses", "Instant Amsterdam signal: canal water, narrow houses, Oude Kerk skyline.", "hero_amsterdam", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Canal%20houses%20and%20Oude%20Kerk%20at%20blue%20hour%20with%20water%20reflection%20in%20Damrak%20Amsterdam%20Netherlands.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-noord_holland-amsterdam", "landmark", "Dam Square and Royal Palace", "Civic centre image for Amsterdam, distinct from canal hero and museum culture.", "landmark_amsterdam_dam_square", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Dam%20Square%2C%20Amsterdam.jpg?width=1600"),
            .culture: visual("nl-city-noord_holland-amsterdam", "culture", "Rijksmuseum", "Culture screen image: national art museum, not a city skyline.", "culture_amsterdam_rijksmuseum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Rijksmuseum_Amsterdam.jpg?width=1600"),
            .night: visual("nl-city-noord_holland-amsterdam", "night", "Amsterdam canals at night", "Night role uses lit bridges and canal reflections, not daytime hero reuse.", "night_amsterdam_canals", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Canal-In-Amsterdam-At-Night-2009.jpg?width=1600"),
            .thumbnail: visual("nl-city-noord_holland-amsterdam", "thumbnail", "Amsterdam canal thumbnail", "Compact canal identity for lists without repeating the hero file.", "thumb_amsterdam_canal", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Colorful%20canal%20houses%20at%20golden%20hour%20in%20Damrak%20avenue%20Amsterdam%20the%20Netherlands.jpg?width=1200"),
            .card: visual("nl-city-noord_holland-amsterdam", "card", "Amsterdam bridge card", "Card view emphasizes walkable canal bridges, separate from hero and thumbnail.", "card_amsterdam_bridge", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/KeizersgrachtReguliersgrachtAmsterdam.jpg?width=1200")
        ],
        "nl-city-zuid_holland-rotterdam": [
            .hero: visual("nl-city-zuid_holland-rotterdam", "hero", "Erasmus Bridge from Euromast", "Rotterdam identity: bridge, river, skyline, modern rebuild.", "hero_rotterdam", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Erasmusbrug%20seen%20from%20Euromast.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-zuid_holland-rotterdam", "landmark", "Erasmus Bridge", "Landmark role isolates the city symbol without reusing the hero perspective.", "landmark_rotterdam_erasmusbrug", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Rotterdam%2C%20de%20Erasmusbrug%20vanaf%20Hotel%20New%20York%20IMG%201782%202018-03-18%2010.32.jpg?width=1600"),
            .culture: visual("nl-city-zuid_holland-rotterdam", "culture", "Markthal", "Culture role shows contemporary public food and architecture.", "culture_rotterdam_markthal", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Markthal_Rotterdam.jpg?width=1600"),
            .night: visual("nl-city-zuid_holland-rotterdam", "night", "Erasmus Bridge at night", "Night role uses lit skyline/bridge mood unique to Rotterdam.", "night_rotterdam_erasmusbrug", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Rotterdam%2C%20de%20Erasmusbrug%20en%20de%20Kop%20van%20Zuid%20IMG%200684%202022-03-27%2020.24.jpg?width=1600"),
            .thumbnail: visual("nl-city-zuid_holland-rotterdam", "thumbnail", "Cube Houses", "List thumbnail uses Rotterdam's experimental housing geometry.", "thumb_rotterdam_cube_houses", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Cube%20Houses%20Rotterdam%2001.jpg?width=1200"),
            .card: visual("nl-city-zuid_holland-rotterdam", "card", "Rotterdam skyline", "Card image reinforces high-rise city identity rather than repeating bridge hero.", "card_rotterdam_skyline", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Skyline%20of%20Rotterdam%20%2833475685218%29.jpg?width=1200")
        ],
        "nl-city-zuid_holland-den_haag": [
            .hero: visual("nl-city-zuid_holland-den_haag", "hero", "Peace Palace", "The Hague identity: international law and diplomacy.", "hero_den_haag", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Friedenspalast_Den_Haag.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-zuid_holland-den_haag", "landmark", "Binnenhof", "Political centre role: Dutch parliament history, not a beach or windmill.", "landmark_den_haag_binnenhof", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Binnenhof%2C%20Den%20Haag%202019.jpg?width=1600"),
            .culture: visual("nl-city-zuid_holland-den_haag", "culture", "Mauritshuis", "Culture role uses the royal picture gallery and Dutch Golden Age collection.", "culture_den_haag_mauritshuis", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Den%20Haag%20-%20Mauritshuis%20%2825949040908%29.jpg?width=1600"),
            .night: visual("nl-city-zuid_holland-den_haag", "night", "Scheveningen pier at night", "Night role gives The Hague its coastal evening identity.", "night_den_haag_scheveningen", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/De%20Pier%20by%20night%20-%20Scheveningen%20-%202010%20-%20panoramio.jpg?width=1600"),
            .thumbnail: visual("nl-city-zuid_holland-den_haag", "thumbnail", "Scheveningen beach", "Thumbnail marks the seaside district, unique inside Zuid-Holland.", "thumb_den_haag_scheveningen", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/.00%201091%20Seebad%20Scheveningen%20-%20Niederlande.jpg?width=1200"),
            .card: visual("nl-city-zuid_holland-den_haag", "card", "Hofvijver and Binnenhof", "Card view protects the government skyline over Hofvijver.", "card_den_haag_hofvijver", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Den%20Haag%2C%20het%20Binnenhof%20diverse%20RM%20met%20de%20Hofvijver%20op%20de%20voorgrond%20foto8%202015-08-05%2018.56.jpg?width=1200")
        ],
        "nl-city-zuid_holland-leiden": [
            .hero: visual("nl-city-zuid_holland-leiden", "hero", "Leiden canals", "Leiden identity: historic university canal city.", "hero_leiden", remote: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Leiden_Grachten_20.jpg/3840px-Leiden_Grachten_20.jpg", minimumPixelWidth: 3840),
            .landmark: visual("nl-city-zuid_holland-leiden", "landmark", "Molen de Valk", "Landmark role uses Leiden's own windmill museum beside the old canal city.", "landmark_leiden_molen_de_valk", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/De%20Valk%20Leiden%206847.jpg?width=1600"),
            .culture: visual("nl-city-zuid_holland-leiden", "culture", "Hortus Botanicus Leiden", "Culture role reflects university science heritage.", "culture_leiden_hortus", remote: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Hortus_Botanicus_Leiden.jpg/1280px-Hortus_Botanicus_Leiden.jpg"),
            .night: visual("nl-city-zuid_holland-leiden", "night", "Leiden illuminated canals", "Night role uses illuminated historic centre, separate from Oude Vest hero.", "night_leiden_canals", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Harbour%20area%2C%20Leiden%2C%20by%20night%20%284079027076%29%20%283%29.jpg?width=1600"),
            .thumbnail: visual("nl-city-zuid_holland-leiden", "thumbnail", "Leiden canal houses", "Thumbnail keeps compact canal recognition without reusing the hero file.", "thumb_leiden_canal", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/00%200876%20Canal%20with%20bridges%20-%20Leiden.jpg?width=1200"),
            .card: visual("nl-city-zuid_holland-leiden", "card", "Leiden university building", "Card role points to Leiden's university identity.", "card_leiden_university", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Leiden%20-%20Rapenburg%2073.jpg?width=1200")
        ],
        "nl-city-utrecht-utrecht": [
            .hero: visual("nl-city-utrecht-utrecht", "hero", "Dom Tower from Oudegracht", "Utrecht identity: Dom Tower protected in frame above canal.", "hero_utrecht", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Utrecht%2C%20de%20Domtoren%20%28RM36075%29%20vanaf%20de%20Oudegracht%20230%20ongeveer%20foto5%202015-11-01%2008.56.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-utrecht-utrecht", "landmark", "Dom Tower", "Landmark role isolates the tower; safe area must keep full tower visible.", "landmark_utrecht_domtoren", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Domtoren_Utrecht.jpg?width=1600", safeArea: "Protect full tower height; prefer fit if vertical crop is tight."),
            .culture: visual("nl-city-utrecht-utrecht", "culture", "Museum Speelklok", "Culture role reflects Utrecht's museum offering.", "culture_utrecht_speelklok", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Museum%20speelklok%20tot%20pierement%20%28103%29%20%288201930833%29.jpg?width=1600"),
            .night: visual("nl-city-utrecht-utrecht", "night", "Oudegracht at night", "Night role shows wharf canal atmosphere unique to Utrecht.", "night_utrecht_oudegracht", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Utrecht-by-Night.jpg?width=1600"),
            .thumbnail: visual("nl-city-utrecht-utrecht", "thumbnail", "Oudegracht wharves", "Thumbnail uses the two-level canal instead of repeating the Dom hero.", "thumb_utrecht_oudegracht", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/View%20of%20the%20Oudegracht%20street%2C%20Utrecht%20%282019%29%2003.jpg?width=1200"),
            .card: visual("nl-city-utrecht-utrecht", "card", "Utrecht Centraal area", "Card role reflects practical central rail identity.", "card_utrecht_centraal", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Station%20Utrecht%20Centraal%20%2831460804413%29.jpg?width=1200")
        ],
        "nl-city-groningen-groningen": [
            .hero: visual("nl-city-groningen-groningen", "hero", "Grote Markt and Martinitoren", "Groningen identity: northern market square and tower.", "hero_groningen", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/20100523%20Grote%20Markt%20en%20Martinitoren%20Groningen%20NL.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-groningen-groningen", "landmark", "Martinitoren", "Landmark role protects the tower silhouette.", "landmark_groningen_martinitoren", remote: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Martinitoren_Groningen.jpg/1280px-Martinitoren_Groningen.jpg", safeArea: "Protect full tower height."),
            .culture: visual("nl-city-groningen-groningen", "culture", "Groninger Museum", "Culture role uses the city's distinctive museum architecture.", "culture_groningen_museum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Chihuly%20at%20the%20Groninger%20Museum%2C%20Groningen%20%282019%29%2001.jpg?width=1600"),
            .night: visual("nl-city-groningen-groningen", "night", "Groningen at night", "Night role gives student-city evening energy.", "night_groningen_city", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Groningen%20Street%20by%20Night%20%287965450068%29.jpg?width=1600"),
            .thumbnail: visual("nl-city-groningen-groningen", "thumbnail", "Grote Markt Groningen", "Thumbnail keeps the market-square identity distinct from the hero crop.", "thumb_groningen_grote_markt", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Grote%20Markt%20Groningen.jpg?width=1200"),
            .card: visual("nl-city-groningen-groningen", "card", "Groningen student city", "Card role points to public life around the university city.", "card_groningen_academiegebouw", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/20090529%20Academiegebouw%20Groningen%20NL.jpg?width=1200")
        ],
        "nl-city-gelderland-nijmegen": [
            .hero: visual("nl-city-gelderland-nijmegen", "hero", "Waalbrug", "Nijmegen identity: Waal river bridge and oldest-city skyline.", "hero_nijmegen", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Nijmegen%20Waalbrug%20R01.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-gelderland-nijmegen", "landmark", "Waalbrug at night", "Landmark role isolates the famous arch bridge.", "landmark_nijmegen_waalbrug", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Dusk%20bikers%20-%20Flickr%20-%20josef.stuefer.jpg?width=1600"),
            .culture: visual("nl-city-gelderland-nijmegen", "culture", "Valkhof Museum", "Culture role covers Roman and medieval heritage.", "culture_nijmegen_valkhof_museum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Museum-Het-Valkhof-Nijmegen.jpg?width=1600"),
            .night: visual("nl-city-gelderland-nijmegen", "night", "Waal river night view", "Night role uses river lights without reusing daytime hero.", "night_nijmegen_waal", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Nijmegen%20%40%20Night%20%2823307479409%29.jpg?width=1600"),
            .thumbnail: visual("nl-city-gelderland-nijmegen", "thumbnail", "Valkhof Park", "Thumbnail shows the historic hill rather than bridge hero.", "thumb_nijmegen_valkhof", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Sint-Nicolaaskapel%2C%20Valkhof%20park%20Nijmegen.jpg?width=1200"),
            .card: visual("nl-city-gelderland-nijmegen", "card", "Stevenskerk Nijmegen", "Card role gives old-city church identity.", "card_nijmegen_stevenskerk", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Stevenskerk%20Nijmegen.jpg?width=1200")
        ],
        "nl-city-gelderland-arnhem": [
            .hero: visual("nl-city-gelderland-arnhem", "hero", "John Frost Bridge", "Arnhem identity: Rhine bridge and WWII memory.", "hero_arnhem", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Arnhem%2C%20de%20John%20Frostbrug%20RM529907%20IMG%203795%202024-07-15%2013.06.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-gelderland-arnhem", "landmark", "John Frost Bridge close view", "Landmark role ties Arnhem to its named Rhine bridge and WWII memory.", "landmark_arnhem_john_frost", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Arnhem%2C%20de%20John%20Frostbrug%20RM529907%20met%20uiterwaarden%20IMG%203811%202024-07-15%2013.08.jpg?width=1600"),
            .culture: visual("nl-city-gelderland-arnhem", "culture", "Openluchtmuseum", "Culture role represents Dutch open-air heritage in Arnhem.", "culture_arnhem_openluchtmuseum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Arnhem-Veluwse%20papiermolen%20in%20Nederlands%20Openluchtmuseum%20%282%29.jpg?width=1600"),
            .night: visual("nl-city-gelderland-arnhem", "night", "Arnhem bridge at night", "Night role uses lit Rhine crossing.", "night_arnhem_bridge", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/John%20Frost%20Bridge%20at%20night%201.jpg?width=1600"),
            .thumbnail: visual("nl-city-gelderland-arnhem", "thumbnail", "Sonsbeek Park", "Thumbnail uses Arnhem's green city identity.", "thumb_arnhem_sonsbeek", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Waterfall-Sonsbeek-Park-Arnhem.jpg?width=1200"),
            .card: visual("nl-city-gelderland-arnhem", "card", "Arnhem city centre", "Card role shows daily urban centre rather than bridge hero.", "card_arnhem_centre", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/2018-01-20%20Arnhem%20Koepelkerk.jpg?width=1200")
        ],
        "nl-city-limburg-maastricht": [
            .hero: visual("nl-city-limburg-maastricht", "hero", "Magisch Maastricht Vrijthof", "Maastricht identity: Vrijthof, basilicas, southern city atmosphere.", "hero_maastricht", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/2022_Magisch_Maastricht_%2801%29.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-limburg-maastricht", "landmark", "Vrijthof Square", "Landmark role centers Maastricht's best-known square.", "landmark_maastricht_vrijthof", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Maastricht%20Vrijthof%2015%20BW%202017-08-19%2012-06-24.jpg?width=1600"),
            .culture: visual("nl-city-limburg-maastricht", "culture", "Dominicanen Bookstore", "Culture role shows reused church heritage.", "culture_maastricht_dominicanen", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Maastricht%20-%20Boekhandel%20Dominicanen%202025%201.jpg?width=1600"),
            .night: visual("nl-city-limburg-maastricht", "night", "Maastricht evening lights", "Night role keeps the southern square atmosphere distinct.", "night_maastricht_vrijthof", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/2022%20Magisch%20Maastricht%20%2805%29.jpg?width=1600"),
            .thumbnail: visual("nl-city-limburg-maastricht", "thumbnail", "Basilica of Saint Servatius", "Thumbnail uses basilica profile rather than Christmas hero.", "thumb_maastricht_servaas", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Basiliek%20van%20Sint%20Servaas%20in%20Maastricht%2C%20provincie%20Limburg%20in%20Nederland%2002.jpg?width=1200"),
            .card: visual("nl-city-limburg-maastricht", "card", "Maas river Maastricht", "Card role adds river-city identity.", "card_maastricht_maas", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Maastricht%2C%20Maas%2C%20Sint-Servaasbrug.jpg?width=1200")
        ],
        "nl-city-noord_brabant-eindhoven": [
            .hero: visual("nl-city-noord_brabant-eindhoven", "hero", "Witte Dame", "Eindhoven identity: Philips-era design and technology city.", "hero_eindhoven", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Eindhoven-Witte%20Dame%20%285%29.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-noord_brabant-eindhoven", "landmark", "Evoluon", "Landmark role shows the flying-saucer modernist icon.", "landmark_eindhoven_evoluon", remote: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Evoluon_Eindhoven.jpg/1280px-Evoluon_Eindhoven.jpg"),
            .culture: visual("nl-city-noord_brabant-eindhoven", "culture", "Van Abbemuseum", "Culture role uses contemporary art, not city hero.", "culture_eindhoven_van_abbe", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Eindhoven%2C%20het%20Van%20Abbemuseum%20IMG%208587%202019-01-20%2010.50.jpg?width=1600"),
            .night: visual("nl-city-noord_brabant-eindhoven", "night", "Lichttoren Eindhoven", "Night role anchors Eindhoven's Philips light heritage.", "night_eindhoven_lichttoren", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Lichttoren%20Eindhoven%201%20-%20Cropped.jpg?width=1600"),
            .thumbnail: visual("nl-city-noord_brabant-eindhoven", "thumbnail", "Philips Museum", "Thumbnail ties the city to Philips origins.", "thumb_eindhoven_philips", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Eindhoven%2C%20het%20Philps%20Museum%20IMG%208543%202019-01-20%2009.44.jpg?width=1200"),
            .card: visual("nl-city-noord_brabant-eindhoven", "card", "Strijp-S Eindhoven", "Card role shows creative tech district identity.", "card_eindhoven_strijp_s", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Station%20Eindhoven%20Strijp-S%20%282024%29-1.jpg?width=1200")
        ],
        "nl-city-zuid_holland-delft": [
            .hero: visual("nl-city-zuid_holland-delft", "hero", "Delft market and Nieuwe Kerk", "Delft identity: canals, Vermeer, Nieuwe Kerk, Delft Blue.", "hero_delft", remote: "https://upload.wikimedia.org/wikipedia/commons/c/c2/Delft_Blick_von_der_Nieuwe_Kerk_auf_die_Oude_Kerk_1.jpg", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-zuid_holland-delft", "landmark", "Nieuwe Kerk Delft", "Landmark role protects tower and royal church identity.", "landmark_delft_nieuwe_kerk", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/00%200725%20Tower%20of%20Nieuwe%20Kerk%20-%20Delft.jpg?width=1600", safeArea: "Protect full church tower where possible."),
            .culture: visual("nl-city-zuid_holland-delft", "culture", "Royal Delft", "Culture role shows Delftware production.", "culture_delft_royal_delft", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Netherlands-4541%20-%20Royal%20Delft%20Factory%20%2812170775183%29.jpg?width=1600"),
            .night: visual("nl-city-zuid_holland-delft", "night", "Delft canals at night", "Night role uses canal evening atmosphere unique to Delft.", "night_delft_canals", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Oude%20Delft%20by%20night%20-%20Delft%20-%202009%20-%20panoramio.jpg?width=1600"),
            .thumbnail: visual("nl-city-zuid_holland-delft", "thumbnail", "Delft canal thumbnail", "Thumbnail differentiates Delft from Leiden canal imagery.", "thumb_delft_canal", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Delft%20Oude%20Delft%20016%206224.jpg?width=1200"),
            .card: visual("nl-city-zuid_holland-delft", "card", "Prinsenhof Delft", "Card role points to William of Orange history.", "card_delft_prinsenhof", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/0804%20Delft%2C%20Prinsenhof%20Delft%20392.jpg?width=1200")
        ],
        "nl-city-noord_holland-haarlem": [
            .hero: visual("nl-city-noord_holland-haarlem", "hero", "Grote Markt Haarlem", "Haarlem identity: Grote Markt and Sint-Bavo, not Amsterdam spillover.", "hero_haarlem", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Zijlstrat%20Grote%20Markt%20Haarlem.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-noord_holland-haarlem", "landmark", "Sint-Bavokerk", "Landmark role protects Haarlem church identity.", "landmark_haarlem_bavokerk", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Haarlem%2C%20het%20Teylermuseum%20RM315441%20en%20de%20Sint%20Bavokerk%20RM19264%20vanaf%20de%20Korte%20Spaarne%20foto4%202015-01-04%2010.05.jpg?width=1600", safeArea: "Protect church tower and roofline."),
            .culture: visual("nl-city-noord_holland-haarlem", "culture", "Frans Hals Museum", "Culture role is Golden Age portraiture, not city hero.", "culture_haarlem_frans_hals", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Frans%20Hals%20-%20De%20regentessen%20van%20het%20oudemannenhuis.jpg?width=1600"),
            .night: visual("nl-city-noord_holland-haarlem", "night", "St Bavo by night", "Night role shows medieval centre lighting around the Grote Kerk.", "night_haarlem_grote_markt", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/St.Bavo%20Haarlem%20by%20night.jpg?width=1600", safeArea: "Protect the church tower."),
            .thumbnail: visual("nl-city-noord_holland-haarlem", "thumbnail", "Teylers Museum facade", "Thumbnail uses the oldest museum in the Netherlands.", "thumb_haarlem_teylers", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Teylers%20Museum%20Haarlem%202019.jpg?width=1200"),
            .card: visual("nl-city-noord_holland-haarlem", "card", "Haarlem hofje", "Card role shows intimate historic courtyard identity.", "card_haarlem_hofje", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Hofje%20van%20Bakenes%20-%20DSC%201020.jpg?width=1200")
        ],
        "nl-city-noord_holland-alkmaar": [
            .hero: visual("nl-city-noord_holland-alkmaar", "hero", "Waagplein Alkmaar", "Alkmaar identity: cheese-market square and Waag building, not Amsterdam canals.", "hero_alkmaar_waagplein", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Waagplein%20%2823097595791%29.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-noord_holland-alkmaar", "landmark", "Grote Sint-Laurenskerk", "Landmark role protects Alkmaar's main church tower and roofline.", "landmark_alkmaar_laurenskerk", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Alkmaar%20-%20Begijnenstraat%20-%20View%20East%20on%20Grote%20of%20Sint%20Laurenskerk%20-%20March%202011.jpg?width=1600", safeArea: "Protect church tower and full roofline."),
            .culture: visual("nl-city-noord_holland-alkmaar", "culture", "Stedelijk Museum Alkmaar", "Culture role points to Alkmaar history and art, separate from cheese tourism.", "culture_alkmaar_stedelijk_museum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Bibliotheek%20en%20Stedelijk%20Museum%2C%20Alkmaar.JPG?width=1600"),
            .night: visual("nl-city-noord_holland-alkmaar", "night", "Alkmaar canals at night", "Night role uses the old canal centre after dark.", "night_alkmaar_canals", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Alkmaar%20City%20Run%20by%20night.jpg?width=1600"),
            .thumbnail: visual("nl-city-noord_holland-alkmaar", "thumbnail", "Accijnstoren Alkmaar", "Thumbnail uses a compact historic canal landmark.", "thumb_alkmaar_accijnstoren", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Accijnstoren%20%28Alkmaar%29.jpg?width=1200"),
            .card: visual("nl-city-noord_holland-alkmaar", "card", "Molen van Piet", "Card image adds Alkmaar's named city windmill as a local identity marker.", "card_alkmaar_molen_van_piet", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Alkmaar%2C%20Molen%20De%20Groot%20of%20de%20Molen%20van%20Piet%20RM7460%20IMG%203485%202024-06-24%2015.56.jpg?width=1200", safeArea: "Protect windmill sails.")
        ],
        "nl-city-noord_holland-hoorn": [
            .hero: visual("nl-city-noord_holland-hoorn", "hero", "Hoorn harbor", "Hoorn identity: VOC-era harbor on the Markermeer.", "hero_hoorn_harbor", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Haven%20Hoorn%20met%20Hoofdtoren1.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-noord_holland-hoorn", "landmark", "Hoofdtoren", "Landmark role isolates the harbor tower and waterfront.", "landmark_hoorn_hoofdtoren", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Hoorn%2C%20de%20Haven%20vanaf%20de%20Oude%20Doelenkade%20met%20de%20Hoofdtoren%20RM22411%20IMG%209177%202021-05-30%2010.26.jpg?width=1600", safeArea: "Protect tower roof and harbor edge."),
            .culture: visual("nl-city-noord_holland-hoorn", "culture", "Westfries Museum", "Culture role represents West Frisian and Golden Age heritage.", "culture_hoorn_westfries_museum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Poort%20Westfries%20Museum%2C%20Hoorn1.JPG?width=1600"),
            .night: visual("nl-city-noord_holland-hoorn", "night", "Hoofdtoren by night", "Night role uses waterfront lights, not daytime harbor reuse.", "night_hoorn_harbor", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Hoofdtoren%20bij%20nacht%2C%20landschap%2C%20Hoorn.jpg?width=1600", safeArea: "Protect the harbor tower."),
            .thumbnail: visual("nl-city-noord_holland-hoorn", "thumbnail", "Roode Steen and Waag", "Thumbnail marks Hoorn's central square.", "thumb_hoorn_roode_steen", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Roode%20Steen%20Hoorn%20met%20waaggebouw.jpg?width=1200"),
            .card: visual("nl-city-noord_holland-hoorn", "card", "Oosterkerk Hoorn", "Card role adds Hoorn's historic church street identity.", "card_hoorn_oosterkerk", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Hoorn%20Oosterkerk%20012.jpg?width=1200", safeArea: "Protect church tower.")
        ],
        "nl-city-noord_holland-zaanstad": [
            .hero: visual("nl-city-noord_holland-zaanstad", "hero", "Zaanstad Inntel houses", "Zaanstad identity: stacked Zaan house architecture in the modern centre.", "hero_zaanstad_inntel", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Zaandam%20-%20Poeskinstraat%20-%20View%20NNW%20towards%20Inntel%20Hotel%202010%20by%20Wilfried%20van%20Winden.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-noord_holland-zaanstad", "landmark", "Czaar Peterhuisje", "Landmark role uses the preserved wooden house tied to Zaandam history.", "landmark_zaanstad_czaar_peterhuisje", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Zaandam%20-%20Krimp%20-%20Czar%20Peter%20House%20-%20%D0%94%D0%BE%D0%BC%D0%B8%D0%BA%20%D0%9F%D0%B5%D1%82%D1%80%D0%B0%20I%20-%20View%20WSW%20towards%20Czaar%20Peterplantsoen.jpg?width=1600"),
            .culture: visual("nl-city-noord_holland-zaanstad", "culture", "Zaans Museum", "Culture role represents Zaan industrial and design heritage.", "culture_zaanstad_zaans_museum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Zaans%20Museum%202017.jpg?width=1600"),
            .night: visual("nl-city-noord_holland-zaanstad", "night", "Bullekerk Zaandam", "Night role keeps Zaanstad in its own centre, not Amsterdam overflow.", "night_zaanstad_station", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Bullekerk%2C%20Zaandam%2001.png?width=1600", safeArea: "Protect church tower."),
            .thumbnail: visual("nl-city-noord_holland-zaanstad", "thumbnail", "Zaandam city hall", "Thumbnail uses the green Zaan architectural style.", "thumb_zaanstad_city_hall", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Gevel%20van%20het%20nieuwe%20gemeentehuis%2C%20Bestanddeelnr%20927-9270.jpg?width=1200"),
            .card: visual("nl-city-noord_holland-zaanstad", "card", "Hembrugterrein", "Card role adds industrial waterfront identity beyond windmills.", "card_zaanstad_hembrug", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Wapenfabriek%20Hembrug%2C%20Zaandam%2C%201914%2C%20SFA022800496.jpg?width=1200")
        ],
        "nl-city-noord_holland-amstelveen": [
            .hero: visual("nl-city-noord_holland-amstelveen", "hero", "Stadshart Amstelveen", "Amstelveen identity: planned town centre and civic square.", "hero_amstelveen_stadshart", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Amstelveen%20Stadshart%20DSCF7118.JPG?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-noord_holland-amstelveen", "landmark", "Cobra Museum facade", "Landmark role centers the city around its modern art museum.", "landmark_amstelveen_cobra", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Cobra%20Museum%20Amstelveen.jpg?width=1600"),
            .culture: visual("nl-city-noord_holland-amstelveen", "culture", "Jan van der Togt Museum", "Culture role shows Amstelveen's local museum scene.", "culture_amstelveen_togt", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Museum%20Jan%20van%20der%20Togt.%20Amstelveen%20001.JPG?width=1600"),
            .night: visual("nl-city-noord_holland-amstelveen", "night", "Sint Urbanuskerk at night", "Night role uses a lit Amstelveen landmark after dark.", "night_amstelveen_stadshart", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Sint%20Urbanskerk%20in%20de%20nacht%20-%20WLM%202011%20-%20Shirley%20de%20Jong.jpg?width=1600", safeArea: "Protect church tower."),
            .thumbnail: visual("nl-city-noord_holland-amstelveen", "thumbnail", "Amsterdamse Bos", "Thumbnail anchors Amstelveen in its major urban forest edge.", "thumb_amstelveen_amsterdamse_bos", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Stedenmaagd%20Amsterdamse%20Bos3.jpg?width=1200"),
            .card: visual("nl-city-noord_holland-amstelveen", "card", "Amstelveen tram line", "Card role reflects the city's metro/tram suburb connection.", "card_amstelveen_tram", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Amstelveenlijn%201990%2001.jpg?width=1200")
        ],
        "nl-city-noord_holland-purmerend": [
            .hero: visual("nl-city-noord_holland-purmerend", "hero", "Koemarkt Purmerend", "Purmerend identity: market-square heritage and regional trade.", "hero_purmerend_koemarkt", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Koemarkt%20Purmerend%20in%20de%20zomer.JPG?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-noord_holland-purmerend", "landmark", "Purmerends Museum", "Landmark role protects the old town-hall museum facade.", "landmark_purmerend_museum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Purmerends%20Museum%20Stadthuis%202014.jpg?width=1600"),
            .culture: visual("nl-city-noord_holland-purmerend", "culture", "Theater de Purmaryn", "Culture role uses the city's performing arts venue.", "culture_purmerend_purmaryn", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Theater%20de%20Purmaryn%200905%20162259.jpg?width=1600"),
            .night: visual("nl-city-noord_holland-purmerend", "night", "Koemarkt by evening", "Night role keeps the market-town centre distinct after dark.", "night_purmerend_centre", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Dubbele%20buurt%20bij%20avond%20genomen%20vanaf%20de%20Koemarkt%2C%20op%20de%20hoek%20bij%20de%20Koestraat%20e%2C%20Bestanddeelnr%20926-2864.jpg?width=1600"),
            .thumbnail: visual("nl-city-noord_holland-purmerend", "thumbnail", "Melkwegbrug Purmerend", "Thumbnail uses the modern bridge as a compact local marker.", "thumb_purmerend_melkwegbrug", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Purmerend%2C%20de%20Melkwegbrug%20voor%20langzaam%20verkeer%20IMG%209196%202021-05-30%2012.15.jpg?width=1200", safeArea: "Protect the bridge arc and canal edge."),
            .card: visual("nl-city-noord_holland-purmerend", "card", "Where and Purmerend canals", "Card role adds canal-town identity without Amsterdam reuse.", "card_purmerend_canal", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Where%2020211228%20150811.jpg?width=1200")
        ],
        "nl-city-noord_holland-heerhugowaard": [
            .hero: visual("nl-city-noord_holland-heerhugowaard", "hero", "Heerhugowaard station", "Heerhugowaard identity: Dijk en Waard transport hub and planned polder town.", "hero_heerhugowaard_station", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Station%20Heerhugowaard%20%282024%29-4.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-noord_holland-heerhugowaard", "landmark", "Poldermuseum Heerhugowaard", "Landmark role ties the town to reclaimed-land history.", "landmark_heerhugowaard_poldermuseum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Poldermuseum%20Heerhugowaard.jpg?width=1600"),
            .culture: visual("nl-city-noord_holland-heerhugowaard", "culture", "Cool kunst en cultuur", "Culture role uses the town's theatre and arts centre.", "culture_heerhugowaard_cool", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Cool%20kunst%20en%20cultuur%20-%20Kulturhuset%2C%20Heerhugowaard%2C%20Nederl%C3%A4nderna.jpg?width=1600"),
            .night: visual("nl-city-noord_holland-heerhugowaard", "night", "Dijk en Waard town hall", "Night role keeps the civic core distinct from nearby Alkmaar.", "night_heerhugowaard_middenwaard", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Gemeentehuis%20Dijk%20en%20Waard.jpg?width=1600"),
            .thumbnail: visual("nl-city-noord_holland-heerhugowaard", "thumbnail", "Stad van de Zon", "Thumbnail anchors the city in its planned solar district.", "thumb_heerhugowaard_luna", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Stad%20van%20de%20Zon%20woonwijk%20Dhr.%20K.%20Davidse%20heeft%20in%20het%20jaar%202009%20in%20opdracht%20van%20het%20Regionaal%20Archie%20-%20RAA003024642%20-%20RAA%20Davidse.jpg?width=1200"),
            .card: visual("nl-city-noord_holland-heerhugowaard", "card", "Dijk en Waard polder", "Card role shows the open polder settlement setting.", "card_heerhugowaard_polder", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Poldermolen%20van%20polder%20%22De%20Berkmeer%22%20-%20Heerhugowaard%20-%2020106182%20-%20RCE.jpg?width=1200")
        ],
        "nl-city-utrecht-amersfoort": [
            .hero: visual("nl-city-utrecht-amersfoort", "hero", "Koppelpoort Amersfoort", "Amersfoort identity: medieval water and land gate.", "hero_amersfoort_koppelpoort", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Amersfoort%2C%20de%20Koppelpoort%20RM79287%20foto17%202017-07-09%2019.21.jpg?width=2400", minimumPixelWidth: 2400, safeArea: "Protect gate towers and bridge."),
            .landmark: visual("nl-city-utrecht-amersfoort", "landmark", "Onze Lieve Vrouwetoren", "Landmark role protects the full tower height.", "landmark_amersfoort_lieve_vrouwetoren", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Amersfoort%20Onze-Lieve-Vrouwetoren%20and%20Krankeledenstraat.jpg?width=1600", safeArea: "Protect full tower height."),
            .culture: visual("nl-city-utrecht-amersfoort", "culture", "Mondriaanhuis", "Culture role reflects Amersfoort as Mondrian's birthplace.", "culture_amersfoort_mondriaanhuis", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Amersfoort%20Mondriaanhuis%20seen%20from%20the%20north.jpg?width=1600"),
            .night: visual("nl-city-utrecht-amersfoort", "night", "Koppelpoort by night", "Night role uses the gate lit after dark, not daytime hero reuse.", "night_amersfoort_koppelpoort", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Koppelpoort%20Amersfoort%20at%20night.jpg?width=1600"),
            .thumbnail: visual("nl-city-utrecht-amersfoort", "thumbnail", "Muurhuizen Amersfoort", "Thumbnail uses the circular medieval street pattern.", "thumb_amersfoort_muurhuizen", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Amersfoort%20Muurhuizen%2097-109.jpg?width=1200"),
            .card: visual("nl-city-utrecht-amersfoort", "card", "Amersfoort canal centre", "Card role adds canal-town texture distinct from Utrecht city.", "card_amersfoort_canal", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/20100615-048%20Amersfoort%20-%20Sculptuur%20in%20de%20gracht%20bij%20Museum%20Flehite.jpg?width=1200")
        ],
        "nl-city-noord_brabant-tilburg": [
            .hero: visual("nl-city-noord_brabant-tilburg", "hero", "Tilburg Spoorzone", "Tilburg identity: railway workshops reborn as creative district.", "hero_tilburg_spoorzone", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Spoorzone%20Tilburg.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-noord_brabant-tilburg", "landmark", "Heuvelse Kerk", "Landmark role protects Tilburg's central church towers.", "landmark_tilburg_heuvelse_kerk", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Heuvelse%20kerk%20front%20facade.jpg?width=1600", safeArea: "Protect twin towers."),
            .culture: visual("nl-city-noord_brabant-tilburg", "culture", "TextielMuseum Tilburg", "Culture role uses Tilburg's textile-industrial heritage.", "culture_tilburg_textielmuseum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Textielmuseum%20Tilburg%2C%2030%20oktober%202016%20-%2003.jpg?width=1600"),
            .night: visual("nl-city-noord_brabant-tilburg", "night", "Tilburg at night", "Night role captures the city's urban evening energy.", "night_tilburg_kermis", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Tilburg%20at%20Night%20%2817%29.jpg?width=1600"),
            .thumbnail: visual("nl-city-noord_brabant-tilburg", "thumbnail", "LocHal Tilburg", "Thumbnail uses the library in the restored rail hall.", "thumb_tilburg_lochal", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Exterieur%20aanzicht%20Bibliotheek%20LocHal%20Tilburg%2C%20april%202019.jpg?width=1200"),
            .card: visual("nl-city-noord_brabant-tilburg", "card", "Piushaven Tilburg", "Card role shows Tilburg's urban water redevelopment.", "card_tilburg_piushaven", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Piushaven%20Tilburg.jpg?width=1200")
        ],
        "nl-city-noord_brabant-breda": [
            .hero: visual("nl-city-noord_brabant-breda", "hero", "Grote Markt Breda", "Breda identity: lively historic market and church skyline.", "hero_breda_grote_markt", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Breda%20Sint%20Janstraat%20zicht%20op%20de%20Grote%20Markt%202024-09-20.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-noord_brabant-breda", "landmark", "Grote Kerk Breda", "Landmark role protects Breda's church tower.", "landmark_breda_grote_kerk", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Grote%20Kerk%20Breda%20grafmonument%20Jan%20I%20van%20Nassau%202.jpg?width=1600", safeArea: "Protect full church tower."),
            .culture: visual("nl-city-noord_brabant-breda", "culture", "Begijnhof Breda", "Culture role shows quiet historic courtyard life.", "culture_breda_begijnhof", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/10116%20Breda%20-%20Begijnhof%20%284%29.jpg?width=1600"),
            .night: visual("nl-city-noord_brabant-breda", "night", "Breda market at night", "Night role uses illuminated cafe-square atmosphere.", "night_breda_grote_markt", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Grote%20Markt%20Breda%20P1600074.jpg?width=1600"),
            .thumbnail: visual("nl-city-noord_brabant-breda", "thumbnail", "Kasteel van Breda", "Thumbnail uses the Nassau castle identity.", "thumb_breda_castle", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Breda%2C%20Kasteel%20van%20Breda%20RM10235%20IMG%206759%202023-06-11%2009.46.jpg?width=1200", safeArea: "Protect castle facade."),
            .card: visual("nl-city-noord_brabant-breda", "card", "Breda harbor", "Card role adds the old harbor and city-water edge.", "card_breda_harbor", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/13-06-27-breda-by-RalfR-083.jpg?width=1200")
        ],
        "nl-city-noord_brabant-s_hertogenbosch": [
            .hero: visual("nl-city-noord_brabant-s_hertogenbosch", "hero", "Sint-Janskathedraal", "Den Bosch identity: Gothic cathedral and old Brabant city.", "hero_den_bosch_sint_jan", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Sint-Janskathedraal%20%27s-Hertogenbosch.jpg?width=2400", minimumPixelWidth: 2400, safeArea: "Protect cathedral towers and roofline."),
            .landmark: visual("nl-city-noord_brabant-s_hertogenbosch", "landmark", "Binnendieze", "Landmark role uses the canals running beneath the old city.", "landmark_den_bosch_binnendieze", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Binnendieze%20%27s-Hertogenbosch.jpg?width=1600"),
            .culture: visual("nl-city-noord_brabant-s_hertogenbosch", "culture", "Noordbrabants Museum", "Culture role represents Bosch, Van Gogh, and Brabant art.", "culture_den_bosch_noordbrabants", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Voorgevel%20Noordbrabants%20Museum.jpg?width=1600"),
            .night: visual("nl-city-noord_brabant-s_hertogenbosch", "night", "Sint-Jan at night", "Night role shows the cathedral city lit after dark.", "night_den_bosch_centre", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/St.%20Janskathedraal%2C%20%27s-Hertegonbosch%2C%20Netherlands%2C%20Jan.%202007%20%28352744190%29.jpg?width=1600", safeArea: "Protect cathedral height."),
            .thumbnail: visual("nl-city-noord_brabant-s_hertogenbosch", "thumbnail", "Markt Den Bosch", "Thumbnail uses market-square urban identity.", "thumb_den_bosch_markt", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Markt%20-%20Den%20Bosch%20-%202010%20-%20panoramio.jpg?width=1200"),
            .card: visual("nl-city-noord_brabant-s_hertogenbosch", "card", "Jheronimus Bosch Art Center", "Card role anchors the city in Bosch heritage.", "card_den_bosch_bosch_center", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Overzicht%20westgevel%20met%20ingangspartij%20en%20klokketoren%20-%20%27s-Hertogenbosch%20-%2020534559%20-%20RCE.jpg?width=1200", safeArea: "Protect the former church tower.")
        ],
        "nl-city-limburg-venlo": [
            .hero: visual("nl-city-limburg-venlo", "hero", "Venlo Maas riverfront", "Venlo identity: Maas river city near the German border.", "hero_venlo_maas", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/2016%20Maas%20-%20Blerick.%20Natuurgebied%20Maascorridor%20op%20een%20grijze%20dag%2C%202016.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-limburg-venlo", "landmark", "Venlo town hall", "Landmark role protects the Renaissance stadhuis facade.", "landmark_venlo_stadhuis", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Stadhuis%20Venlo.jpg?width=1600"),
            .culture: visual("nl-city-limburg-venlo", "culture", "Limburgs Museum Venlo", "Culture role uses the regional museum for Venlo's border-city heritage.", "culture_venlo_limburgs_museum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Limburgs%20Museum%20Venlo.jpg?width=1600"),
            .night: visual("nl-city-limburg-venlo", "night", "Venlo at night", "Night role shows the old city after dark.", "night_venlo_market", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/20211022%20021%20Venlo%20nachtfotografie%20%2851622692193%29.jpg?width=1600"),
            .thumbnail: visual("nl-city-limburg-venlo", "thumbnail", "Sint-Martinuskerk Venlo", "Thumbnail uses the church tower skyline.", "thumb_venlo_martinuskerk", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Sint-Martinuskerk%20Venlo.jpg?width=1200", safeArea: "Protect church tower."),
            .card: visual("nl-city-limburg-venlo", "card", "Maasboulevard Venlo", "Card role adds the modern riverfront promenade.", "card_venlo_maasboulevard", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Venlo%20-%20Maasboulevard.jpg?width=1200")
        ],
        "nl-city-overijssel-zwolle": [
            .hero: visual("nl-city-overijssel-zwolle", "hero", "Sassenpoort Zwolle", "Zwolle identity: Hanseatic city gate and medieval centre.", "hero_zwolle_sassenpoort", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Zwolle%2C%20de%20Sassenpoort%20RM41788%20foto5%202016-06-05%2010.11.jpg?width=2400", minimumPixelWidth: 2400, safeArea: "Protect gate towers."),
            .landmark: visual("nl-city-overijssel-zwolle", "landmark", "Peperbus tower", "Landmark role protects Zwolle's church tower silhouette.", "landmark_zwolle_peperbus", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/De%20Peperbus%20van%20Zwolle.jpg?width=1600", safeArea: "Protect full tower height."),
            .culture: visual("nl-city-overijssel-zwolle", "culture", "Museum de Fundatie", "Culture role uses the city's distinctive museum dome.", "culture_zwolle_fundatie", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Museum%20de%20Fundatie%20Zwolle%202019.jpg?width=1600"),
            .night: visual("nl-city-overijssel-zwolle", "night", "Luna Lights Zwolle", "Night role uses lit Hanseatic streets and city-centre light art.", "night_zwolle_centre", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Luna%20Lights%2C%20Zwolle%20%282019%29%2001.jpg?width=1600"),
            .thumbnail: visual("nl-city-overijssel-zwolle", "thumbnail", "Thorbeckegracht Zwolle", "Thumbnail uses canal-side historic houses.", "thumb_zwolle_thorbeckegracht", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Thorbeckewal%20en%20Thorbeckegracht%20Zwolle%20Overijssel.jpg?width=1200"),
            .card: visual("nl-city-overijssel-zwolle", "card", "Grote Markt Zwolle", "Card role adds central-square life.", "card_zwolle_grote_markt", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Zwolle%20Grote%20Markt%20Bovenaanzicht.JPG?width=1200")
        ],
        "nl-city-flevoland-almere": [
            .hero: visual("nl-city-flevoland-almere", "hero", "Almere city centre", "Almere identity: planned new-town architecture on reclaimed land.", "hero_almere_centrum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Centrum%20Almere%20Stad%2C%20Almere%2C%20Netherlands%20-%20panoramio%20%2810%29.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-flevoland-almere", "landmark", "The Wave Almere", "Landmark role uses contemporary architecture specific to Almere.", "landmark_almere_wave", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Almere%20Blick%20auf%20The%20Wave.jpg?width=1600"),
            .culture: visual("nl-city-flevoland-almere", "culture", "Kunstlinie Almere", "Culture role represents the city's theatre and arts venue.", "culture_almere_kunstlinie", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Kunstlinie%20Almere.jpg?width=1600"),
            .night: visual("nl-city-flevoland-almere", "night", "Almere station at night", "Night role shows the new city lit after dark.", "night_almere_skyline", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Almere%20CS%20at%20night%20-%20panoramio.jpg?width=1600"),
            .thumbnail: visual("nl-city-flevoland-almere", "thumbnail", "Oostvaardersplassen Almere", "Thumbnail anchors Almere beside new-land nature.", "thumb_almere_oostvaardersplassen", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Loopbrug%20naar%20vogelkijkhut%20Zeearend.%20Locatie%2C%20Oostvaardersplassen%2008.jpg?width=1200"),
            .card: visual("nl-city-flevoland-almere", "card", "Weerwater Almere", "Card role uses the city lake and waterfront.", "card_almere_weerwater", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Almere%2C%20skyline%20met%20het%20Weerwater%20foto5%202014-03-09%2016.08.jpg?width=1200")
        ],
        "nl-city-flevoland-lelystad": [
            .hero: visual("nl-city-flevoland-lelystad", "hero", "Bataviawerf Lelystad", "Lelystad identity: reclaimed-land capital with maritime reconstruction.", "hero_lelystad_bataviawerf", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Lelystad%2C%20reconstructie%20van%20de%20Batavia%20op%20de%20Bataviawerf%20IMG%204212%202024-07-28%2013.28.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-flevoland-lelystad", "landmark", "Batavia replica", "Landmark role uses the VOC ship replica as a clear visual anchor.", "landmark_lelystad_batavia", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Lelystad%20-%20Houtribdijk%20-%20View%20ENE%20on%20Bataviastad%20%26%20VOC%2017th%20Century%20Replica%20Batavia.jpg?width=1600"),
            .culture: visual("nl-city-flevoland-lelystad", "culture", "Aviodrome", "Culture role adds aviation heritage.", "culture_lelystad_aviodrome", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/20170831%20019%20Lelystad%20Aviodrome%20%2836758869246%29.jpg?width=1600"),
            .night: visual("nl-city-flevoland-lelystad", "night", "Lelystad centre night lights", "Night role shows the planned city centre after dark.", "night_lelystad_batavia_stad", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Lelystad%20centrum%20night%20lights.JPG?width=1600"),
            .thumbnail: visual("nl-city-flevoland-lelystad", "thumbnail", "Lelystad harbor", "Thumbnail uses the IJsselmeer harbor setting.", "thumb_lelystad_harbor", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/20140612%20Jachthaven%20Lelystad%20Haven.jpg?width=1200"),
            .card: visual("nl-city-flevoland-lelystad", "card", "Markermeer dike Lelystad", "Card role shows new-land engineering and water edge.", "card_lelystad_markermeer", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Lelystad%20-%20Houtribdijk%20-%20View%20NW%20on%20Markermeer.jpg?width=1200")
        ],
        "nl-city-friesland-leeuwarden": [
            .hero: visual("nl-city-friesland-leeuwarden", "hero", "Oldehove Leeuwarden", "Leeuwarden identity: leaning Oldehove tower and Frisian capital.", "hero_leeuwarden_oldehove", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/20190227%20Oldehove%20Leeuwarden.jpg?width=2400", minimumPixelWidth: 2400, safeArea: "Protect full leaning tower."),
            .landmark: visual("nl-city-friesland-leeuwarden", "landmark", "Waag Leeuwarden", "Landmark role uses the historic weighing house in the city centre.", "landmark_leeuwarden_waag", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Waag%20Leeuwarden.jpg?width=1600"),
            .culture: visual("nl-city-friesland-leeuwarden", "culture", "Fries Museum", "Culture role represents Frisian language, design, and history.", "culture_leeuwarden_fries_museum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/20140531%20Fries%20Museum%20Leeuwarden%20Fr%20NL.jpg?width=1600"),
            .night: visual("nl-city-friesland-leeuwarden", "night", "Leeuwarden Achmeatoren at night", "Night role uses the canal centre after dark.", "night_leeuwarden_canals", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Leeuwarden%20%E2%80%94%20Achmeatoren%20at%20night%2C%202.jpg?width=1600"),
            .thumbnail: visual("nl-city-friesland-leeuwarden", "thumbnail", "Blokhuispoort", "Thumbnail shows the reused prison cultural complex.", "thumb_leeuwarden_blokhuispoort", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Blokhuispoort%20Leeuwarden.jpg?width=1200"),
            .card: visual("nl-city-friesland-leeuwarden", "card", "Nieuwestad Leeuwarden", "Card role adds shopping-canal street identity.", "card_leeuwarden_nieuwestad", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Nieuwestad%20Leeuwarden.jpg?width=1200")
        ],
        "nl-city-drenthe-assen": [
            .hero: visual("nl-city-drenthe-assen", "hero", "Drents Museum Assen", "Assen identity: provincial capital and museum city.", "hero_assen_drents_museum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Overzicht%20voorzijde%20Drents%20Museum%20-%20Assen%20-%2020527986%20-%20RCE.jpg?width=2400", minimumPixelWidth: 2400),
            .landmark: visual("nl-city-drenthe-assen", "landmark", "TT Circuit Assen", "Landmark role uses the city's globally known motorsport venue.", "landmark_assen_tt_circuit", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/TT-Assen-circuit-DSC%200666.jpg?width=1600"),
            .culture: visual("nl-city-drenthe-assen", "culture", "Kloosterkerk Assen", "Culture role points to Assen's monastery-origin centre.", "culture_assen_kloosterkerk", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Kloosterkerk%2C%20Assen.jpg?width=1600", safeArea: "Protect church tower."),
            .night: visual("nl-city-drenthe-assen", "night", "TT-Hall at night", "Night role shows Assen's event identity after dark.", "night_assen_centre", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/TT-Hall%20Assen%20in%202018%20at%20night.jpg?width=1600"),
            .thumbnail: visual("nl-city-drenthe-assen", "thumbnail", "Vaart Assen", "Thumbnail uses the canal approach into the city.", "thumb_assen_vaart", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Vaart%20Assen%20%282022%29.jpg?width=1200"),
            .card: visual("nl-city-drenthe-assen", "card", "Asserbos", "Card role adds the urban forest edge.", "card_assen_asserbos", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Asserbos%20-%20Assen%20-%20Drenthe%20-%20Sfeerimpressie%20januari%202025%2003.jpg?width=1200")
        ],
        "nl-city-zeeland-middelburg": [
            .hero: visual("nl-city-zeeland-middelburg", "hero", "Middelburg town hall", "Middelburg identity: Gothic town hall and Zeeland capital square.", "hero_middelburg_stadhuis", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Middelburg%20Stadhuis%2001.JPG?width=2400", minimumPixelWidth: 2400, safeArea: "Protect town-hall spires."),
            .landmark: visual("nl-city-zeeland-middelburg", "landmark", "Lange Jan", "Landmark role protects the abbey tower skyline.", "landmark_middelburg_lange_jan", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Lange%20Jan%20Middelburg.jpg?width=1600", safeArea: "Protect full tower height."),
            .culture: visual("nl-city-zeeland-middelburg", "culture", "Zeeuws Museum", "Culture role represents Zeeland history and maritime identity.", "culture_middelburg_zeeuws_museum", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Middelburg%2C%20Zeeuws%20Museum.jpg?width=1600"),
            .night: visual("nl-city-zeeland-middelburg", "night", "Middelburg market at night", "Night role uses the illuminated market square.", "night_middelburg_market", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Stadhuis%20Middelburg%20at%20night.jpg?width=1600", safeArea: "Protect city hall tower."),
            .thumbnail: visual("nl-city-zeeland-middelburg", "thumbnail", "Middelburg abbey", "Thumbnail uses the abbey complex as compact identity.", "thumb_middelburg_abbey", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Middelburg%20%28NL%29%2C%20Onze-Lieve-Vrouwe-Abdij%20--%202022%20--%204915.jpg?width=1200"),
            .card: visual("nl-city-zeeland-middelburg", "card", "Middelburg canal", "Card role adds the island-capital canal setting.", "card_middelburg_canal", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Middelburg%20Dam%20en%20Prins%20Hendrikdok.%20Zeeland.jpg?width=1200")
        ]
    ]

    static let provinceVisualsByPlaceId: [String: [ProvinceVisualRole: CuratedPlaceVisualMedia]] = [
        "nl-province-noord_holland": [
            .landscape: visual("nl-province-noord_holland", "landscape", "Keukenhof tulips and windmill", "North Holland landscape: tulips, polders, coast-facing lowlands.", "province_noord_holland_landscape", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Flower%20field%20%40%20View%20from%20the%20windmill%20%40%20Keukenhof%20%2817184246682%29.jpg?width=2400", minimumPixelWidth: 2400),
            .culture: visual("nl-province-noord_holland", "culture", "Zaanse Schans heritage", "Culture role shows Golden Age and industrial heritage beyond Amsterdam.", "province_noord_holland_culture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Zaanse-Schans-Rene-Cortin-1.jpg?width=1600"),
            .nature: visual("nl-province-noord_holland", "nature", "Zandvoort beach", "North Sea coastline identity.", "province_noord_holland_nature", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Zandvoort-Beach-Sunset.jpg?width=1600"),
            .architecture: visual("nl-province-noord_holland", "architecture", "Zaanse Schans", "Wooden industrial heritage architecture.", "province_noord_holland_architecture", remote: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Zaanse_Schans_2019.jpg/3840px-Zaanse_Schans_2019.jpg"),
            .tourism: visual("nl-province-noord_holland", "tourism", "Alkmaar cheese market", "Recognizable tourism ritual outside Amsterdam.", "province_noord_holland_tourism", remote: "https://upload.wikimedia.org/wikipedia/commons/6/61/Alkmaar_-_Waagplein_-_De_Waag_-_Cheese_Weighhouse_1583.jpg")
        ],
        "nl-province-zuid_holland": [
            .landscape: visual("nl-province-zuid_holland", "landscape", "Kinderdijk windmills", "South Holland water-management landscape.", "province_zuid_holland_landscape", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Kinderdijk%2C%20Nederwaard%20molens%20no%201tm5%20RM30543tm7%20IMG%209354%202021-06-13%2011.04.jpg?width=2400", minimumPixelWidth: 2400),
            .culture: visual("nl-province-zuid_holland", "culture", "Ridderzaal Binnenhof", "Government and parliamentary culture.", "province_zuid_holland_culture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Ridderzaal%20-%20Binnenhof%20-%20Den%20Haag%20-%20NL.jpg?width=1600"),
            .nature: visual("nl-province-zuid_holland", "nature", "Meijendel dunes", "Coastal tourism and dunes.", "province_zuid_holland_nature", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Wassenaar%20Dunes%20%2831367287052%29.jpg?width=1600"),
            .architecture: visual("nl-province-zuid_holland", "architecture", "Rotterdam port architecture", "Modern urban architecture and port-city rebuild.", "province_zuid_holland_architecture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Rotterdam%20skyline%20from%20The%20Esch.jpg?width=1600"),
            .tourism: visual("nl-province-zuid_holland", "tourism", "Delft canals day trip", "Vermeer, Delft Blue, canals, and day-trip tourism.", "province_zuid_holland_tourism", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Delft%20Blick%20von%20der%20Nieuwe%20Kerk%20auf%20die%20Grachten%209.jpg?width=1600")
        ],
        "nl-province-utrecht": [
            .landscape: visual("nl-province-utrecht", "landscape", "Utrechtse Heuvelrug", "Province identity beyond the city: wooded ridge and estates.", "province_utrecht_landscape", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Utrechtse%20Heuvelrug.jpg?width=2400", minimumPixelWidth: 2400),
            .culture: visual("nl-province-utrecht", "culture", "Utrecht Oudegracht culture", "Historic bishopric and central city culture.", "province_utrecht_culture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Oudegracht%20304%2C%20Utrecht%20-%20Werf%20met%20planten%20en%20Puur%20Utrecht%2C%202021.jpg?width=1600"),
            .nature: visual("nl-province-utrecht", "nature", "Loosdrechtse Plassen", "Lakes and water recreation.", "province_utrecht_nature", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Bij%20Oud-Loosdrecht%2C%20de%20Loosdrechtse%20Plassen%20foto5%202017-07-09%2015.53.jpg?width=1600"),
            .architecture: visual("nl-province-utrecht", "architecture", "Rietveld Schroder House", "UNESCO modernist architecture.", "province_utrecht_architecture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Rietveld%20Schr%C3%B6derhuis%20HayKranen-20.JPG?width=1600"),
            .tourism: visual("nl-province-utrecht", "tourism", "Amersfoort Koppelpoort", "Medieval city day-trip identity.", "province_utrecht_tourism", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Koppelpoort%20Amersfoort.jpg?width=1600")
        ],
        "nl-province-gelderland": [
            .landscape: visual("nl-province-gelderland", "landscape", "Hoge Veluwe", "Large inland nature province: heath, forest, sand.", "province_gelderland_landscape", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/20161026%20De%20Pollen5%20Hoge%20Veluwe.jpg?width=2400", minimumPixelWidth: 2400),
            .culture: visual("nl-province-gelderland", "culture", "Paleis Het Loo", "Royal house-museum culture in Apeldoorn, distinct from city bridge imagery.", "province_gelderland_culture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Apeldoorn%20Paleis%20Het%20Loo%201.jpg?width=1600"),
            .nature: visual("nl-province-gelderland", "nature", "Veluwe heathland", "Nature role stays distinct from city bridge images.", "province_gelderland_nature", remote: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Hoge_Veluwe.jpg/1280px-Hoge_Veluwe.jpg"),
            .architecture: visual("nl-province-gelderland", "architecture", "Doorwerth Castle", "Castles and river estates identity.", "province_gelderland_architecture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Kasteel%20Doorwerth.jpg?width=1600"),
            .tourism: visual("nl-province-gelderland", "tourism", "Nijmegen river quay", "Oldest city and river tourism.", "province_gelderland_tourism", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Nijmegen%20Rijksmonument%2031187%20Waalkade%2080-83.JPG?width=1600")
        ],
        "nl-province-noord_brabant": [
            .landscape: visual("nl-province-noord_brabant", "landscape", "Biesbosch National Park", "Freshwater tidal wetland landscape.", "province_noord_brabant_landscape", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Nationaal%20park%20De%20Biesbosch%2009.jpg?width=2400", minimumPixelWidth: 2400),
            .culture: visual("nl-province-noord_brabant", "culture", "Carnival in Brabant", "Culture role shows Brabant carnival and Burgundian regional identity.", "province_noord_brabant_culture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Carnaval%20Oeteldonk%20Den%20Bosch%20en%20Bergen%20op%20Zoom%2C%20Bestanddeelnr%20907-5869.jpg?width=1600"),
            .nature: visual("nl-province-noord_brabant", "nature", "Loonse en Drunense Duinen", "Sand-dune nature unique to Brabant.", "province_noord_brabant_nature", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Loonse%20en%20Drunense%20Duinen.jpg?width=1600"),
            .architecture: visual("nl-province-noord_brabant", "architecture", "Sint-Janskathedraal", "Gothic cathedral and Den Bosch identity.", "province_noord_brabant_architecture", remote: "https://upload.wikimedia.org/wikipedia/commons/f/f1/St._Jans_cathedral_%27s-Hertogenbosch.jpg"),
            .tourism: visual("nl-province-noord_brabant", "tourism", "Efteling", "Major Brabant tourism anchor.", "province_noord_brabant_tourism", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Efteling%20The%20House%20of%20the%20Five%20Senses.jpg?width=1600")
        ],
        "nl-province-limburg": [
            .landscape: visual("nl-province-limburg", "landscape", "Limburg hills near Vijlen", "Only rolling-hills province identity.", "province_limburg_landscape", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Heuvellandschap%20Epen%20en%20Vijlen%20-%20Zuid-Limburg%20-%20NL%20%2851121594975%29.jpg?width=2400", minimumPixelWidth: 2400),
            .culture: visual("nl-province-limburg", "culture", "Limburg carnival", "Southern square culture, carnival, and border-region identity.", "province_limburg_culture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Maastricht%20Carnaval%202023%2001.jpg?width=1600"),
            .nature: visual("nl-province-limburg", "nature", "Vaalserberg", "Highest point and hill-country nature.", "province_limburg_nature", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Vaalserberg.jpg?width=1600"),
            .architecture: visual("nl-province-limburg", "architecture", "Valkenburg castle ruins", "Castle ruins and marl landscape architecture.", "province_limburg_architecture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Kasteelru%C3%AFne%20Valkenburg.jpg?width=1600"),
            .tourism: visual("nl-province-limburg", "tourism", "Maastricht historic centre", "Tourism role anchors the province in Maastricht old city.", "province_limburg_tourism", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Maastricht%20Vrijthof%20at%20sunset.jpg?width=1600")
        ],
        "nl-province-overijssel": [
            .landscape: visual("nl-province-overijssel", "landscape", "Giethoorn canals", "Overijssel water-village landscape.", "province_overijssel_landscape", remote: "https://upload.wikimedia.org/wikipedia/commons/d/d7/Giethoorn_Netherlands_Channels-and-houses-of-Giethoorn-05.jpg", minimumPixelWidth: 2400),
            .culture: visual("nl-province-overijssel", "culture", "Deventer book market", "Hanseatic and book-city culture.", "province_overijssel_culture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Book%20market%2C%20Nieuwe%20Markt%2C%20Deventer%2C%202015.jpg?width=1600"),
            .nature: visual("nl-province-overijssel", "nature", "Weerribben-Wieden", "Lowland fen national park.", "province_overijssel_nature", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Nationaal%20Park%20Weerribben-Wieden.%20Oude%20molen.JPG?width=1600"),
            .architecture: visual("nl-province-overijssel", "architecture", "Zwolle Sassenpoort", "Hanseatic gate architecture.", "province_overijssel_architecture", remote: "https://upload.wikimedia.org/wikipedia/commons/1/12/Sassenstraat_1-15%2C_Zwolle.jpg"),
            .tourism: visual("nl-province-overijssel", "tourism", "Giethoorn boats", "Tourism role: boating village day trip.", "province_overijssel_tourism", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Giethoorn.tif?width=1600")
        ],
        "nl-province-flevoland": [
            .landscape: visual("nl-province-flevoland", "landscape", "Oostvaardersplassen", "New land nature on former seabed.", "province_flevoland_landscape", remote: "https://upload.wikimedia.org/wikipedia/commons/b/b6/Oostvaardersplassen._Nieuwe_natuur_op_de_bodem_van_de_voormalige_Zuiderzee_09.jpg", minimumPixelWidth: 2400),
            .culture: visual("nl-province-flevoland", "culture", "Bataviawerf", "Culture role shows VOC replica craft and reclaimed-land heritage.", "province_flevoland_culture", remote: "https://upload.wikimedia.org/wikipedia/commons/6/6b/Lelystad%2C_reconstructie_van_de_Batavia_op_de_Bataviawerf_IMG_4212_2024-07-28_13.28.jpg"),
            .nature: visual("nl-province-flevoland", "nature", "Marker Wadden beach", "New nature and bird islands.", "province_flevoland_nature", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Beach%2C%20Marker%20Wadden%2C%202022.jpg?width=1600"),
            .architecture: visual("nl-province-flevoland", "architecture", "Almere city centre", "Planned new-town architecture.", "province_flevoland_architecture", remote: "https://upload.wikimedia.org/wikipedia/commons/1/1e/Centrum_Almere_Stad%2C_Almere%2C_Netherlands_-_panoramio.jpg"),
            .tourism: visual("nl-province-flevoland", "tourism", "Schokland", "UNESCO reclaimed-land memory site.", "province_flevoland_tourism", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Schokland.%20UNESCO-Werelderfgoed%20actm%2091.jpg?width=1600")
        ],
        "nl-province-groningen": [
            .landscape: visual("nl-province-groningen", "landscape", "Hoge der Aa", "Northern canal and brick-city landscape.", "province_groningen_landscape", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Hoge%20der%20Aa2.jpg?width=2400", minimumPixelWidth: 2400),
            .culture: visual("nl-province-groningen", "culture", "Noorderzon festival at night", "Bold regional museum and festival culture.", "province_groningen_culture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Noorderzon%20bij%20nacht.jpg?width=1600"),
            .nature: visual("nl-province-groningen", "nature", "Groningen salt marsh", "Mudflats and northern coastline.", "province_groningen_nature", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Kwelder%20%28Groningen%29.jpg?width=1600"),
            .architecture: visual("nl-province-groningen", "architecture", "Groningen Goudkantoor", "Tower and brick architecture identity.", "province_groningen_architecture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Goudkantoor%20Groningen.jpg?width=1600"),
            .tourism: visual("nl-province-groningen", "tourism", "Bourtange fortress", "Star fortress tourism in the province.", "province_groningen_tourism", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Bourtange%20%2844465%29.jpg?width=1600")
        ],
        "nl-province-friesland": [
            .landscape: visual("nl-province-friesland", "landscape", "Frisian coast", "Wide northern water-and-sky landscape.", "province_friesland_landscape", remote: "https://upload.wikimedia.org/wikipedia/commons/9/90/Wierum_%28Noardeast-Frysl%C3%A2n%29%2C_10-07-2023._%28d.j.b%29_01.jpg", minimumPixelWidth: 2400),
            .culture: visual("nl-province-friesland", "culture", "Leeuwarden Waag", "Frisian capital and language culture.", "province_friesland_culture", remote: "https://upload.wikimedia.org/wikipedia/commons/8/88/Nieuwestad-_Leeuwarden.jpg"),
            .nature: visual("nl-province-friesland", "nature", "Frisian lakes sunrise", "Lakes and sailing identity.", "province_friesland_nature", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Bevroren%20landschap%20bij%20zonsopgang.%20It%20S%C3%BAd%20De%20Fryske%20Marren%2002.jpg?width=1600"),
            .architecture: visual("nl-province-friesland", "architecture", "Sneek Waterpoort", "Water-gate architecture and boating routes.", "province_friesland_architecture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Waterpoort%20Sneek.jpg?width=1600"),
            .tourism: visual("nl-province-friesland", "tourism", "Skutsjesilen spectators", "Sailing tourism and Frisian water culture.", "province_friesland_tourism", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Sk%C3%BBtsjesilen.%20Toeschouwers%20Sk%C3%BBtsjesilen%20op%20volgschepen%2001.jpg?width=1600")
        ],
        "nl-province-drenthe": [
            .landscape: visual("nl-province-drenthe", "landscape", "Hunebed D27", "Prehistoric megaliths, unmistakably Drenthe.", "province_drenthe_landscape", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Hunebed_D27_in_Borger_flickr.jpg?width=2400", minimumPixelWidth: 2400),
            .culture: visual("nl-province-drenthe", "culture", "Van Gogh House Drenthe", "Culture role shows Van Gogh and peat-worker regional history.", "province_drenthe_culture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Van%20Gogh%20Huis%202019%2002.jpg?width=1600"),
            .nature: visual("nl-province-drenthe", "nature", "Dwingelderveld heath", "Largest wet heathland identity.", "province_drenthe_nature", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Nationaal%20Park%20Dwingelderveld%2020-08-2019%20%28actm.%29%2011.jpg?width=1600"),
            .architecture: visual("nl-province-drenthe", "architecture", "Drents Museum", "Provincial museum architecture in the capital.", "province_drenthe_architecture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Drents%20Museum%20trappen.jpg?width=1600"),
            .tourism: visual("nl-province-drenthe", "tourism", "TT Circuit Assen grandstand", "Recognizable tourism/event anchor.", "province_drenthe_tourism", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/TT-circuit-Assen0605.jpg?width=1600")
        ],
        "nl-province-zeeland": [
            .landscape: visual("nl-province-zeeland", "landscape", "Oosterscheldekering", "Delta Works and sea-land identity.", "province_zeeland_landscape", remote: "https://upload.wikimedia.org/wikipedia/commons/0/01/Vrouwenpolder_%28NL%29%2C_Oosterscheldekering_--_2022_--_5016.jpg", minimumPixelWidth: 2400),
            .culture: visual("nl-province-zeeland", "culture", "Middelburg town hall", "Historic capital and maritime trading culture.", "province_zeeland_culture", remote: "https://upload.wikimedia.org/wikipedia/commons/0/03/Middelburg_Stadhuis_01.JPG"),
            .nature: visual("nl-province-zeeland", "nature", "Zeeland beach dunes", "Coast, dunes, and islands.", "province_zeeland_nature", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Nollestrand%2C%20Vlissingen.jpg?width=1600"),
            .architecture: visual("nl-province-zeeland", "architecture", "Delta Works barrier", "Engineering architecture protecting the province.", "province_zeeland_architecture", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Stormvloedkering%20Oosterschelde%2013.JPG?width=1600"),
            .tourism: visual("nl-province-zeeland", "tourism", "Domburg beach", "Seaside tourism identity.", "province_zeeland_tourism", remote: "https://commons.wikimedia.org/wiki/Special:FilePath/Duinen%20Strand%20Domburg%20P1390201.jpg?width=1600")
        ]
    ]

    static func media(for placeId: String) -> CuratedPlaceHeroMedia? {
        let result = mediaByPlaceId[placeId]
        #if DEBUG
        if result == nil {
            print("Missing hero image for placeId=\(placeId)")
        }
        #endif
        return result
    }

    static func cityVisual(for placeId: String, role: CityVisualRole) -> CuratedPlaceVisualMedia? {
        cityVisualsByPlaceId[placeId]?[role]
    }

    static func provinceVisual(for placeId: String, role: ProvinceVisualRole) -> CuratedPlaceVisualMedia? {
        provinceVisualsByPlaceId[placeId]?[role]
    }

    static func fallbackRemoteURLs(forCityPlaceId placeId: String?) -> [URL] {
        fallbackRemoteURLs(forPlaceId: placeId)
    }

    static func fallbackRemoteURLs(forPlaceId placeId: String?) -> [URL] {
        var urls: [URL] = []
        if let placeId, !placeId.isEmpty {
            if placeId.hasPrefix("nl-city-"),
               let provinceId = provinceId(fromCityPlaceId: placeId),
               let provinceURL = mediaByPlaceId["nl-province-\(provinceId)"]?.remoteURL {
                urls.append(provinceURL)
            }
        }
        if let netherlandsPremiumFallbackURL {
            urls.append(netherlandsPremiumFallbackURL)
        }
        return urls.reduce(into: [URL]()) { unique, url in
            if !unique.contains(url) {
                unique.append(url)
            }
        }
    }

    static func provinceFallbackURL(forCityPlaceId placeId: String?) -> URL? {
        fallbackRemoteURLs(forCityPlaceId: placeId).first
    }

    static func cityPlaceId(cityName: String, provinceName: String) -> String {
        let provinceId = normalize(provinceName)
        let nameId = normalize(cityName)
        return "nl-city-\(provinceId)-\(nameId)"
    }

    static func provincePlaceId(provinceName: String) -> String {
        "nl-province-\(normalize(provinceName))"
    }

    private static func media(_ placeId: String, _ assetName: String, license: String? = nil, source: String? = nil, remote: String? = nil) -> CuratedPlaceHeroMedia {
        CuratedPlaceHeroMedia(
            placeId: placeId,
            assetName: assetName,
            license: license,
            sourceURL: source.flatMap(URL.init(string:)),
            remoteURL: remote.flatMap(URL.init(string:))
        )
    }

    private static func visual(
        _ placeId: String,
        _ role: String,
        _ title: String,
        _ why: String,
        _ assetName: String,
        remote: String,
        source: String? = nil,
        license: String? = "Wikimedia Commons file license",
        minimumPixelWidth: Int = 1200,
        safeArea: String = "Aspect fill with focal subject centered; protect full towers, bridges, windmill sails, castle facades, monuments, waterfront edges, and skyline."
    ) -> CuratedPlaceVisualMedia {
        CuratedPlaceVisualMedia(
            placeId: placeId,
            role: role,
            title: title,
            why: why,
            assetName: assetName,
            remoteURL: URL(string: remote),
            sourceURL: source.flatMap(URL.init(string:)),
            license: license,
            minimumPixelWidth: minimumPixelWidth,
            safeAreaNote: safeArea
        )
    }

    private static func provinceId(fromCityPlaceId placeId: String) -> String? {
        guard placeId.hasPrefix("nl-city-") else { return nil }
        let remainder = String(placeId.dropFirst("nl-city-".count))
        let knownProvinceIds = mediaByPlaceId.keys
            .compactMap { key -> String? in
                guard key.hasPrefix("nl-province-") else { return nil }
                return String(key.dropFirst("nl-province-".count))
            }
            .sorted { $0.count > $1.count }
        return knownProvinceIds.first { remainder.hasPrefix("\($0)-") }
    }

    private static func normalize(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
    }
}
