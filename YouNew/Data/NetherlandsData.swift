import SwiftUI
import CoreLocation

struct FastFact: Identifiable, Codable {
    let id: String
    let icon: String
    let title: String
    let value: String

    init(icon: String, title: String, value: String) {
        self.id = title
        self.icon = icon
        self.title = title
        self.value = value
    }
}

struct NetherlandsCountry {
    static let name = "Kingdom of the Netherlands"
    static let tagline = "Water, bikes, trade, design, and a practical culture shaped by centuries of engineering."
    static let capital = "Amsterdam (city) · The Hague (government)"
    static let population = "about 18 million"
    static let area = "41,543 km²"
    static let gdp = "about €1.1 trillion"
    static let languages = ["Dutch (Nederlands)", "Frisian (Frysk)", "English (widely spoken)"]
    static let currency = "Euro (€)"
    static let government = "Constitutional monarchy · Parliamentary democracy"
    static let monarch = "King Willem-Alexander"
    static let primeMinister = "Rob Jetten"
    static let founded = "1581 — Republic of the Seven United Netherlands"
    static let eu = "Founding member of the EU (1957)"
    static let nato = "Founding member of NATO (1949)"
    static let timezone = "CET (UTC+1) · CEST (UTC+2 summer)"
    static let drivingSide = "Right"
    static let callingCode = "+31"
    static let internet = ".nl"
    static let flagColors = "Red (#AE1C28) · White · Blue (#21468B)"
    static let anthem = "Het Wilhelmus (oldest national anthem in the world, 1574)"
    static let emoji = "🇳🇱"

    static let overview = """
    The Netherlands (Nederland) is a country in Northwestern Europe, bordered by Germany to the east, Belgium to the south, and the North Sea to the north and west. Despite its small size, it is one of the world's most densely populated countries and the second-largest exporter of food and agricultural products after the USA.

    The country is famous for its flat landscape, extensive canal systems, windmills, tulip fields, cycling culture, and liberal social policies. About 26% of its land lies below sea level, protected by an extensive network of dikes and water management systems that have been UNESCO-recognized as a masterpiece of human ingenuity.

    The Netherlands was a major maritime and colonial power in the 17th century — the Dutch Golden Age — when Amsterdam was the world's most important trading city. The Dutch East India Company (VOC) was the world's first multinational corporation and the first to issue stock.
    """

    static let fastFacts: [FastFact] = [
        FastFact(icon: "🌷", title: "Tulip country", value: "Major flower and bulb export sector"),
        FastFact(icon: "🚲", title: "Bike country", value: "More bicycles than residents"),
        FastFact(icon: "💧", title: "Below sea level", value: "26% of land below sea level"),
        FastFact(icon: "🏗️", title: "Delta Works", value: "Largest flood barrier system in world"),
        FastFact(icon: "⚓", title: "Rotterdam Port", value: "Largest seaport in Europe"),
        FastFact(icon: "🧀", title: "Cheese exports", value: "Important dairy and food export sector"),
        FastFact(icon: "☁️", title: "Rainy days", value: "~130 rainy days per year"),
        FastFact(icon: "🌍", title: "International services", value: "English-friendly services in major cities")
    ]
}

struct NLEconomy {
    let gdp: String
    let gdpPerCapita: String
    let gdpRank: String
    let currency: String
    let mainSectors: [String]
    let topCompanies: [String]
    let stockExchange: String
    let unemployment: String
    let taxRange: String
    let vatRate: String
    let minimumWage: String
    let exportRank: String
    let agriExport: String
    let portRotterdam: String
    let employmentCulture: String
    let newcomerNote: String
}

struct UniInfo: Identifiable, Codable {
    var id: String { name }
    let name: String
    let year: Int
    let rank: String
    let city: String
    let strength: String
}

struct NLEducation {
    let system: String
    let compulsoryAge: String
    let topUniversities: [UniInfo]
    let internationalStudents: String
    let englishPrograms: String
    let tuitionEU: String
    let tuitionNonEU: String
    let scholarships: String
    let duo: String
    let mboHboWo: String
    let internationalSchools: String
    let newcomerNote: String
}

struct NLHealthcare {
    let system: String
    let avgPremium: String
    let deductible: String
    let zorgtoeslag: String
    let huisarts: String
    let topHospitals: [String]
    let emergency: String
    let mentalHealth: String
    let dentist: String
    let pharmacy: String
    let insuranceDeadline: String
    let newcomerNote: String
}

struct NLHousing {
    let avgRentStudio: String
    let avgRentOneBedroom: String
    let avgRentFamily: String
    let avgRentAmsterdam: String
    let avgRentRotterdam: String
    let avgRentUtrecht: String
    let avgRentLeiden: String
    let avgRentGroningen: String
    let socialHousing: String
    let freeMarket: String
    let huurcommissie: String
    let buyingMarket: String
    let platforms: [String]
    let depositRule: String
    let registration: String
    let huurtoeslag: String
    let tenantRights: String
    let newcomerNote: String
}

struct NLTransport {
    let railOperator: String
    let trainCoverage: String
    let fastestRoute: String
    let internationalIC: String
    let internationalRoutes: [String]
    let bikeStats: String
    let bikeParking: String
    let ovPayment: String
    let airports: [String]
    let annualPass: String
    let speedLimit: String
    let bikeRules: String
    let newcomerNote: String
}

extension NetherlandsCountry {
    static let economy = NLEconomy(
        gdp: "about €1.1 trillion",
        gdpPerCapita: "about €61,500 per person",
        gdpRank: "Top 20 globally, top 5 in the EU",
        currency: "Euro (€)",
        mainSectors: ["Finance", "Logistics", "Agriculture", "Technology", "Chemicals"],
        topCompanies: ["Philips", "Shell", "ING", "ABN AMRO", "Heineken", "ASML", "Booking.com", "Adyen"],
        stockExchange: "Euronext Amsterdam - one of the world's oldest stock exchanges",
        unemployment: "Low by EU comparison; check CBS for the latest rate",
        taxRange: "Progressive income tax; check Belastingdienst for current brackets",
        vatRate: "21% standard VAT / 9% reduced rate for selected goods",
        minimumWage: "Statutory hourly minimum wage; check Government.nl before signing a contract",
        exportRank: "One of the world's largest goods exporters",
        agriExport: "Major global exporter of food and agricultural products",
        portRotterdam: "Europe's largest seaport and a key logistics hub",
        employmentCulture: "Direct communication, punctuality, written agreements, and strong work-life balance",
        newcomerNote: "To work, you usually need a BSN, bank account, registered address, health insurance, and a clear employment contract."
    )

    static let education = NLEducation(
        system: "The system includes primary school, secondary school, MBO, HBO, and WO",
        compulsoryAge: "Education is compulsory from around age 5 to 16, with a qualification duty until 18",
        topUniversities: [
            UniInfo(name: "Leiden University", year: 1575, rank: "QS-ranked", city: "Leiden", strength: "law, medicine, humanities"),
            UniInfo(name: "Delft University of Technology", year: 1842, rank: "QS-ranked", city: "Delft", strength: "engineering, architecture, technology"),
            UniInfo(name: "Utrecht University", year: 1636, rank: "QS-ranked", city: "Utrecht", strength: "life sciences, climate, education"),
            UniInfo(name: "University of Amsterdam", year: 1632, rank: "QS-ranked", city: "Amsterdam", strength: "social sciences, economics, AI"),
            UniInfo(name: "Eindhoven University of Technology", year: 1956, rank: "QS-ranked", city: "Eindhoven", strength: "high tech, design, engineering"),
            UniInfo(name: "University of Groningen", year: 1614, rank: "QS-ranked", city: "Groningen", strength: "medicine, energy, northern studies"),
            UniInfo(name: "Maastricht University", year: 1976, rank: "QS-ranked", city: "Maastricht", strength: "international law, medicine, EU studies")
        ],
        internationalStudents: "Large international student population",
        englishPrograms: "Many bachelor's and master's programmes are offered in English",
        tuitionEU: "Statutory tuition applies to many EU/EEA students; check DUO for the current year",
        tuitionNonEU: "Institutional tuition varies by programme and university",
        scholarships: "Scholarships vary by university, nationality, and programme",
        duo: "DUO handles student finance, tuition, and education administration",
        mboHboWo: "MBO is vocational education, HBO is applied sciences, and WO is research university education",
        internationalSchools: "International schools operate in Amsterdam, The Hague, Rotterdam, Utrecht, Eindhoven, Maastricht, and other regions",
        newcomerNote: "Register children with a school through the municipality or directly with the school. Students should verify housing, insurance, and registration before arrival."
    )

    static let healthcare = NLHealthcare(
        system: "Mandatory basic health insurance from private insurers under public regulation",
        avgPremium: "Monthly premiums vary by insurer and package",
        deductible: "A compulsory deductible applies to many healthcare costs",
        zorgtoeslag: "Healthcare allowance may be available depending on income and household situation",
        huisarts: "Register with a huisarts (GP); they are the normal route to specialist care",
        topHospitals: ["Amsterdam UMC", "Erasmus MC Rotterdam", "UMCG Groningen", "UMC Utrecht", "MUMC+ Maastricht"],
        emergency: "112 for emergencies; 0900-8844 for non-emergency police",
        mentalHealth: "GGZ mental healthcare usually starts with a GP referral",
        dentist: "Dental care is usually not covered by the basic package for adults",
        pharmacy: "A pharmacy (apotheek) provides prescribed medicine and advice",
        insuranceDeadline: "Arrange health insurance promptly after registration or once the insurance obligation starts",
        newcomerNote: "Find a GP near your address, save your insurance policy number, and check whether you qualify for healthcare allowance."
    )

    static let housingMarket = NLHousing(
        avgRentStudio: "Studio rents are often high in larger cities; check current listings locally",
        avgRentOneBedroom: "One-bedroom rents are usually highest in the Randstad",
        avgRentFamily: "Family housing is competitive in popular urban areas",
        avgRentAmsterdam: "Amsterdam is usually among the most expensive rental markets",
        avgRentRotterdam: "Rotterdam is competitive but often below Amsterdam prices",
        avgRentUtrecht: "Utrecht has high demand and limited supply",
        avgRentLeiden: "Leiden has strong student and expat demand",
        avgRentGroningen: "Groningen is student-heavy with pressure on rooms",
        socialHousing: "Social housing waiting lists can be long, especially in major cities",
        freeMarket: "Private-sector rents depend on contract type, points system, and local demand",
        huurcommissie: "The Huurcommissie can assess rent, service costs, and some tenancy disputes",
        buyingMarket: "Buying is competitive; mortgage options depend on income, contract, debts, and property valuation",
        platforms: ["Funda.nl", "Pararius.nl", "Kamernet.nl (rooms)", "Huurwoningen.nl"],
        depositRule: "Deposits are commonly one or two months of rent",
        registration: "Check whether BRP registration is allowed at the address; without registration, BSN, DigiD, and allowances can be affected",
        huurtoeslag: "Rent benefit depends on rent, income, assets, age, and household situation",
        tenantRights: "Tenant rights are protected; rent and quality disputes can be checked through Huurcommissie or Juridisch Loket",
        newcomerNote: "Do not transfer a deposit without a contract. Verify the landlord and photograph the home condition when moving in."
    )

    static let transport = NLTransport(
        railOperator: "NS (Nederlandse Spoorwegen)",
        trainCoverage: "Dense national rail network with frequent intercity and regional services",
        fastestRoute: "Amsterdam-Rotterdam is served by fast Intercity Direct services",
        internationalIC: "International trains connect Amsterdam with Belgium, France, Germany, and the UK",
        internationalRoutes: ["Eurostar: Amsterdam-Brussels-Paris", "Eurostar: Amsterdam-London", "ICE: Amsterdam-Frankfurt"],
        bikeStats: "Cycling is a core part of daily transport, with extensive bike lanes",
        bikeParking: "Major stations provide large bicycle parking facilities",
        ovPayment: "OV-chipkaart and OVpay support check-in/check-out across public transport",
        airports: ["Amsterdam Airport Schiphol", "Rotterdam The Hague Airport", "Eindhoven Airport"],
        annualPass: "Student travel products and subscriptions depend on status and eligibility",
        speedLimit: "Speed limits vary by road, time, and vehicle type; always follow local signs",
        bikeRules: "Use lights, working brakes, and correct parking; fines may apply for unsafe or illegal cycling",
        newcomerNote: "For daily life, set up NS, 9292, OVpay, a strong bike lock, and routes to your municipality, GP, and workplace."
    )
}

struct NLProvince: Identifiable {
    let id: String
    let name: String
    let capital: String
    let population: String
    let areaKm2: String
    let cityCount: String
    let description: String
    let history: String
    let highlights: [String]
    let imageURL: String
    let flag: CityFlag
    let germanBorder: Bool
    let belgianBorder: Bool
    let coastline: Bool

    var nameEN: String {
        switch id {
        case "Noord-Holland": return "North Holland"
        case "Zuid-Holland": return "South Holland"
        case "Noord-Brabant": return "North Brabant"
        case "Overijssel": return "Overijssel"
        case "Flevoland": return "Flevoland"
        default: return name
        }
    }

    var nameRU: String {
        switch id {
        case "Noord-Holland": return "Северная Голландия"
        case "Zuid-Holland": return "Южная Голландия"
        case "Utrecht": return "Утрехт"
        case "Gelderland": return "Гелдерланд"
        case "Noord-Brabant": return "Северный Брабант"
        case "Limburg": return "Лимбург"
        case "Overijssel": return "Оверэйссел"
        case "Flevoland": return "Флеволанд"
        case "Groningen": return "Гронинген"
        case "Friesland": return "Фрисландия"
        case "Drenthe": return "Дренте"
        case "Zeeland": return "Зеландия"
        default: return name
        }
    }

    func displayName(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return nameEN
        case .dutch: return name
        case .russian: return nameRU
        }
    }
}

extension NLProvince {
    nonisolated static let all: [NLProvince] = [
        NLProvince(
            id: "Noord-Holland",
            name: "Noord-Holland",
            capital: "Amsterdam",
            population: "2.95 million",
            areaKm2: "2,671 km²",
            cityCount: "47",
            description: "The most economically important province, home to Amsterdam, Schiphol Airport, and the iconic tulip fields of the Bollenstreek. The IJsselmeer and North Sea coastline give it a distinctive maritime character.",
            history: "The heartland of the Dutch Republic and the VOC empire. North Holland's merchant class built the canal rings of Amsterdam and funded the Dutch Golden Age. Alkmaar's famous cheese market dates to 1365.",
            highlights: ["🌷 Keukenhof — 7 million tulips, 32 hectares", "✈️ Amsterdam Schiphol — 3rd busiest EU airport", "🧀 Alkmaar Kaasmarkt — oldest cheese market (1365)", "🌊 Zandvoort aan Zee — Formula 1 Dutch Grand Prix circuit", "🏛️ Haarlem — Frans Hals Museum, medieval city center"],
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Keukenhof%20tulips%20and%20windmill.jpg?width=2400",
            flag: CityFlag(colors: ["#AE1C28","#F5D020"], description: "Rood-geel, provincievlag Noord-Holland", emoji: "🏴", svgStripes: [FlagStripe(color: "#AE1C28", heightFraction: 0.5), FlagStripe(color: "#F5D020", heightFraction: 0.5)]),
            germanBorder: false, belgianBorder: false, coastline: true
        ),
        NLProvince(
            id: "Zuid-Holland",
            name: "Zuid-Holland",
            capital: "Den Haag (The Hague)",
            population: "3.76 million",
            areaKm2: "2,811 km²",
            cityCount: "52",
            description: "The most populous Dutch province and political heart of the Netherlands. Home to the government, parliament, and international courts in Den Haag, the massive port of Rotterdam, and the historic university cities of Leiden and Delft.",
            history: "The powerhouse of medieval Holland. Dordrecht was the first city in the Netherlands (1220). Delft was the home of Johannes Vermeer. The province's coat of arms — the Holland lion — became the basis for the national emblem.",
            highlights: ["⚖️ Den Haag — International Court of Justice, parliament", "⚓ Rotterdam — Europe's largest seaport", "🎓 Leiden University (1575) — oldest in the Netherlands", "🏺 Delft — Vermeer's birthplace, Delftware pottery", "🌸 Westland — greenhouse capital, 80% of Dutch flowers"],
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Kinderdijk_windmills.jpg?width=2400",
            flag: CityFlag(colors: ["#1B5E20","#FFFFFF"], description: "Groen-wit, provincievlag Zuid-Holland", emoji: "🏴", svgStripes: [FlagStripe(color: "#1B5E20", heightFraction: 0.5), FlagStripe(color: "#FFFFFF", heightFraction: 0.5)]),
            germanBorder: false, belgianBorder: false, coastline: true
        ),
        NLProvince(
            id: "Utrecht",
            name: "Utrecht",
            capital: "Utrecht",
            population: "1.38 million",
            areaKm2: "1,449 km²",
            cityCount: "26",
            description: "The geographic and logistical center of the Netherlands. Utrecht Centraal is the country's busiest railway station, connecting all major cities. The province has a high concentration of universities, tech companies, and insurance/financial services.",
            history: "Roman fortress Trajectum (47 AD) grew into a medieval bishopric that controlled northern Netherlands for centuries. The Union of Utrecht (1579) — founding document of the Dutch Republic — was signed here.",
            highlights: ["🛤️ Utrecht Centraal — busiest station in NL", "⛪ Dom Tower — 112m, tallest church tower in NL", "📜 Union of Utrecht (1579) — Dutch Declaration of Independence", "🏢 Rabobank & NS headquarters", "🌿 Utrechtse Heuvelrug — national park, glacial ridges"],
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Dom_Tower_Utrecht.jpg?width=2400",
            flag: CityFlag(colors: ["#FFFFFF","#AE1C28","#FFFFFF"], description: "Wit-rood-wit, kruis van Utrecht", emoji: "🏴", svgStripes: [FlagStripe(color: "#FFFFFF", heightFraction: 0.333), FlagStripe(color: "#AE1C28", heightFraction: 0.334), FlagStripe(color: "#FFFFFF", heightFraction: 0.333)]),
            germanBorder: false, belgianBorder: false, coastline: false
        ),
        NLProvince(
            id: "Gelderland",
            name: "Gelderland",
            capital: "Arnhem",
            population: "2.13 million",
            areaKm2: "5,136 km²",
            cityCount: "51",
            description: "The largest Dutch province by land area, stretching from the Rhine delta to the German border. Known for Arnhem's WWII history (Operation Market Garden), the Veluwe national park, and Nijmegen — the oldest city in the Netherlands.",
            history: "Nijmegen was the oldest city in the Netherlands, with Roman origins (19 BC). The medieval Duchy of Gelderland was one of the most powerful territories in the Low Countries. The Battle of Arnhem (September 1944) — 'A Bridge Too Far' — is the most famous WWII battle on Dutch soil.",
            highlights: ["🌉 Arnhem — 'A Bridge Too Far' (1944), John Frost Bridge", "🏛️ Nijmegen — oldest city in Netherlands (19 BC)", "🌲 De Hoge Veluwe — largest national park in NL, Kröller-Müller Museum", "🎨 Kröller-Müller Museum — world's 2nd largest Van Gogh collection", "🍺 Grolsch and Heineken breweries nearby"],
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Nationaal%20Park%20De%20Hoge%20Veluwe%20-%20De%20Pollen%20-%20panoramio.jpg?width=2400",
            flag: CityFlag(colors: ["#003DA5","#F5D020"], description: "Blauw-geel, provincievlag Gelderland", emoji: "🏴", svgStripes: [FlagStripe(color: "#003DA5", heightFraction: 0.5), FlagStripe(color: "#F5D020", heightFraction: 0.5)]),
            germanBorder: true, belgianBorder: false, coastline: false
        ),
        NLProvince(
            id: "Noord-Brabant",
            name: "Noord-Brabant",
            capital: "Den Bosch ('s-Hertogenbosch)",
            population: "2.61 million",
            areaKm2: "4,916 km²",
            cityCount: "68",
            description: "The industrial and design powerhouse of the southern Netherlands. Home to ASML, Philips (founded Eindhoven), and the Dutch Design capital. Distinctive Burgundian culture, excellent food, and famous carnival celebrations.",
            history: "Part of the historical Duchy of Brabant, which straddled modern Netherlands and Belgium. Den Bosch (founded 1185) was Hieronymus Bosch's birthplace. The province was under Spanish-Habsburg control for most of the Dutch Golden Age, giving it a distinct Catholic and Burgundian culture.",
            highlights: ["🔬 Eindhoven/Brainport — ASML, Philips, more patents/km² than Silicon Valley", "🎨 Hieronymus Bosch Center, Den Bosch — medieval master of surreal art", "🎭 Tilburg Carnival — one of NL's largest, 500,000 visitors", "⛪ Sint-Janskathedraal — finest Gothic cathedral in the Netherlands", "🏞️ Biesbosch — national park, largest freshwater tidal wetland in Europe"],
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Biesbosch%20National%20Park%20Netherlands.jpg?width=2400",
            flag: CityFlag(colors: ["#AE1C28", "#FFFFFF"], description: "Red and white, Brabant colors", emoji: "🏴", svgStripes: [FlagStripe(color: "#AE1C28", heightFraction: 0.5), FlagStripe(color: "#FFFFFF", heightFraction: 0.5)]),
            germanBorder: false, belgianBorder: true, coastline: false
        ),
        NLProvince(
            id: "Groningen",
            name: "Groningen",
            capital: "Groningen",
            population: "591,952",
            areaKm2: "2,326 km²",
            cityCount: "10",
            description: "The northernmost mainland province, bordering Germany and the Wadden Sea. Famous for its distinctive Gronings culture, language (Grönnens), and the now-closed natural gas field that made the Netherlands one of Europe's richest countries.",
            history: "Groningen's wealth came from controlling Baltic grain trade via the Hanseatic League. The city's Martinitoren (1482) was a beacon for North Sea navigation for centuries. Natural gas discovered 1959 — the world's largest onshore field — extracted until 2023 amid thousands of induced earthquakes.",
            highlights: ["⛽ Groningen gas field — largest in world, closed 2023", "🎓 57,000 students — RUG and Hanze Hogeschool", "🌊 Wadden Sea — UNESCO World Heritage mudflats", "⛪ Martinitoren (1482) — 97m, icon of the north", "🎵 Eurosonic Noorderslag — premier European new music festival"],
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Groningen_-_Martinikerk_en_-toren.jpg?width=2400",
            flag: CityFlag(colors: ["#AE1C28", "#FFFFFF"], description: "Rood-wit, provincievlag Groningen", emoji: "🏴", svgStripes: [FlagStripe(color: "#AE1C28", heightFraction: 0.5), FlagStripe(color: "#FFFFFF", heightFraction: 0.5)]),
            germanBorder: true, belgianBorder: false, coastline: true
        ),
        NLProvince(
            id: "Limburg",
            name: "Limburg",
            capital: "Maastricht",
            population: "1.12 million",
            areaKm2: "2,209 km²",
            cityCount: "31",
            description: "The southernmost and most culturally distinct Dutch province. Wedged between Belgium and Germany, Limburg has rolling hills (the Vaalserberg — highest point in Netherlands at 322m), Maastricht's Roman heritage, and a vibrant carnival tradition.",
            history: "Named after Limbourg castle in modern Belgium. Limburg was a Duchy until Napoleon absorbed it into France (1795). After Waterloo it became a complex contested territory — Belgian from 1830–1839 before being divided between Netherlands and Belgium by the Treaty of London.",
            highlights: ["📜 Maastricht Treaty (1992) — created the European Union", "🏔️ Vaalserberg — highest point in Netherlands (322m)", "🗿 Caves of Saint Peter — 280km of marl caves", "⛪ Basilica of St Servatius — oldest church in Netherlands", "🍫 Chocolaterie industry — Merci and other brands nearby"],
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Limburg%20hills%20near%20Vijlen.jpg?width=2400",
            flag: CityFlag(colors: ["#F5D020","#FFFFFF"], description: "Goud-wit, provincievlag Limburg", emoji: "🏴", svgStripes: [FlagStripe(color: "#F5D020", heightFraction: 0.5), FlagStripe(color: "#FFFFFF", heightFraction: 0.5)]),
            germanBorder: true, belgianBorder: true, coastline: false
        ),
        NLProvince(
            id: "Friesland",
            name: "Friesland (Fryslân)",
            capital: "Leeuwarden",
            population: "651,509",
            areaKm2: "3,341 km²",
            cityCount: "18",
            description: "A province with its own language (Frisian — co-official with Dutch), its own culture, and a fierce sense of identity. Home to the legendary Elfstedentocht ice-skating race (11 cities, 200km), and Leeuwarden — 2018 European Capital of Culture.",
            history: "Friesland was never fully conquered by Rome and maintained independence until the 16th century. The Frisians are an ancient Germanic people, and their language — West Frisian — is the closest living relative to English. The Elfstedentocht (Eleven Cities Tour) ice-skating race, held when canals freeze, is the most iconic Dutch sporting event.",
            highlights: ["⛸️ Elfstedentocht — legendary 200km ice-skating race (rare, last 1997)", "🗣️ Frisian language — second official language in NL", "🏛️ Leeuwarden — European Capital of Culture 2018, Escher birthplace", "🐄 Holstein Frisian cattle — the world's most common dairy breed", "🌊 Wadden Sea islands — Texel, Vlieland, Terschelling"],
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Leeuwarden_2019.jpg?width=2400",
            flag: CityFlag(colors: ["#003DA5", "#FFFFFF"], description: "Blue with diagonal white stripes and red lily-pads", emoji: "🏴", svgStripes: [FlagStripe(color: "#003DA5", heightFraction: 0.333), FlagStripe(color: "#FFFFFF", heightFraction: 0.334), FlagStripe(color: "#003DA5", heightFraction: 0.333)]),
            germanBorder: false, belgianBorder: false, coastline: true
        ),
        NLProvince(
            id: "Overijssel",
            name: "Overijssel",
            capital: "Zwolle",
            population: "1.17 million",
            areaKm2: "3,421 km²",
            cityCount: "25",
            description: "Eastern province known for medieval Hanseatic cities (Zwolle, Deventer, Kampen), the lake district of Overijssel (Weerribben-Wieden national park — largest lowland fen in NW Europe), and the textile history of Enschede and Almelo.",
            history: "Overijssel's Hanseatic cities dominated Baltic trade in the Middle Ages. Deventer's manuscript copying industry made it a center of early printing. Enschede's textile industry collapsed in the 20th century; the devastating Enschede fireworks disaster (2000) destroyed an entire neighborhood.",
            highlights: ["🏰 Zwolle — perfectly preserved medieval Hanseatic city", "📚 Deventer — medieval book fair, Dickens Festival (December)", "🌿 Weerribben-Wieden — largest lowland fen in NW Europe", "🏭 Enschede — recovering post-industrial city, Twente campus", "🛶 Giethoorn — 'Dutch Venice', no roads, only waterways"],
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Giethoorn_2019.jpg?width=2400",
            flag: CityFlag(colors: ["#AE1C28","#F5D020"], description: "Rood-geel, provincievlag Overijssel", emoji: "🏴", svgStripes: [FlagStripe(color: "#AE1C28", heightFraction: 0.5), FlagStripe(color: "#F5D020", heightFraction: 0.5)]),
            germanBorder: true, belgianBorder: false, coastline: false
        ),
        NLProvince(
            id: "Drenthe",
            name: "Drenthe",
            capital: "Assen",
            population: "496,947",
            areaKm2: "2,641 km²",
            cityCount: "12",
            description: "The least densely populated province in the Netherlands, known for prehistoric megalithic tombs (hunebedden), national cycling routes, and the Van Gogh connection — he lived here in 1883 and painted the peat landscapes.",
            history: "Drenthe's hunebedden (dolmen burial chambers) built 5,000 years ago are among the oldest monuments in the Netherlands. The province remained largely agricultural until the 20th century. Vincent van Gogh lived in the village of Nieuw-Amsterdam for several months in 1883, producing dark paintings of peat workers.",
            highlights: ["🗿 Hunebedden — 54 megalithic tombs, 5,000 years old", "🎨 Van Gogh in Drenthe — painted peat landscapes (1883)", "🚴 National cycling park — 5,000km of bike routes", "🏡 Kamp Westerbork — WWII deportation camp memorial", "🌿 Dwingelderveld — largest continuous heath in NL"],
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Hunebed_D27_Borger.jpg?width=2400",
            flag: CityFlag(colors: ["#AE1C28", "#FFFFFF"], description: "Red on white, Drenthe arms", emoji: "🏴", svgStripes: [FlagStripe(color: "#AE1C28", heightFraction: 0.5), FlagStripe(color: "#FFFFFF", heightFraction: 0.5)]),
            germanBorder: true, belgianBorder: false, coastline: false
        ),
        NLProvince(
            id: "Zeeland",
            name: "Zeeland",
            capital: "Middelburg",
            population: "385,218",
            areaKm2: "2,934 km²",
            cityCount: "13",
            description: "Sea-land — a province of islands and peninsulas, shaped entirely by water. Home to the Delta Works (the largest flood protection project in world history), beautiful beaches, and a devastating history of floods including the 1953 North Sea Flood that killed 1,836 people.",
            history: "Zeeland's history is defined by the eternal struggle against the sea. The 1953 North Sea Flood — which struck on February 1, killing 1,836 Dutch — shocked the world and led directly to the Delta Works, one of the seven modern wonders of the world. The province was also home to Admiral Michiel de Ruyter, who defeated the English and French fleets in the 17th century.",
            highlights: ["🛡️ Delta Works — world's largest flood protection system", "🏖️ Zeelandse beaches — pristine, quieter than North Holland", "📜 1953 flood memorial — remembering 1,836 victims", "⚓ Admiral de Ruyter — born in Flushing (Vlissingen)", "🦞 Zeeland seafood — mussels, oysters, lobster"],
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Oosterscheldekering_2014.jpg?width=2400",
            flag: CityFlag(colors: ["#003DA5","#F5D020"], description: "Blauw-goud, provincievlag Zeeland", emoji: "🏴", svgStripes: [FlagStripe(color: "#003DA5", heightFraction: 0.5), FlagStripe(color: "#F5D020", heightFraction: 0.5)]),
            germanBorder: false, belgianBorder: true, coastline: true
        ),
        NLProvince(
            id: "Flevoland",
            name: "Flevoland",
            capital: "Lelystad",
            population: "427,386",
            areaKm2: "2,412 km²",
            cityCount: "6",
            description: "The newest province in the Netherlands (1986) and in the world — entirely reclaimed from the IJsselmeer between 1942–1968. Flevoland is the largest artificial land area ever created, a testament to Dutch mastery of water engineering.",
            history: "Flevoland didn't exist until the 20th century. The Zuiderzee Works (1927–1975) drained the former inland sea (Zuiderzee), creating 1,650 km² of new land. The Flevopolder and Oostelijk Flevoland were reclaimed in the 1940s–50s. Flevoland became the 12th province in 1986 — the most recent territorial addition to the Netherlands.",
            highlights: ["🌊 Largest artificial land in world — 1,650 km² reclaimed from sea", "🏙️ Almere — fastest-growing city in the Netherlands", "✈️ Lelystad Airport — expanding to relieve Schiphol", "🎨 Batavia Stad — fashion outlet and replica 17th-century VOC ship", "🌱 Most fertile agricultural land — built on seabed soil"],
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Flevoland_polder_aerial.jpg?width=2400",
            flag: CityFlag(colors: ["#003DA5","#F5D020"], description: "Blauw-geel, provincievlag Flevoland", emoji: "🏴", svgStripes: [FlagStripe(color: "#003DA5", heightFraction: 0.5), FlagStripe(color: "#F5D020", heightFraction: 0.5)]),
            germanBorder: false, belgianBorder: false, coastline: false
        )
    ]
}

struct NLCity: Identifiable, Codable {
    let id: String
    let name: String
    let province: String
    let population: String
    let area: String
    let founded: String
    let postalCode: String
    let coordinates: String
    let flag: CityFlag
    let imageURL: String
    let heroColor: String
    let tagline: String
    let shortDescription: String
    let fullDescription: String
    let history: String
    let highlights: [String]
    let attractions: [Attraction]
    let facts: [CityFact]
    let services: [String]
    let expat: String
    let transport: String

    var placeId: String {
        CuratedPlaceHeroMediaRegistry.cityPlaceId(cityName: name, provinceName: province)
    }
}

struct CityFlag: Codable {
    let colors: [String]
    let description: String
    let emoji: String
    let svgStripes: [FlagStripe]
}

struct FlagStripe: Codable {
    let color: String
    let heightFraction: Double
}

enum TourismCategory: String, CaseIterable, Codable {
    case topAttractions
    case museums
    case castles
    case nature
    case beaches
    case parks
    case historicCentres
    case unescoSites
    case hiddenGems
    case dayTrips

    var title: String {
        switch self {
        case .topAttractions: return "Top Attractions"
        case .museums: return "Museums"
        case .castles: return "Castles"
        case .nature: return "Nature"
        case .beaches: return "Beaches"
        case .parks: return "Parks"
        case .historicCentres: return "Historic Centres"
        case .unescoSites: return "UNESCO Sites"
        case .hiddenGems: return "Hidden Gems"
        case .dayTrips: return "Day Trips"
        }
    }
}

private struct AttractionMetadata {
    let category: TourismCategory
    let location: String
    let whyVisit: String
    let bestSeason: String
    let photoPurpose: String
}

struct Attraction: Identifiable, Codable {
    let id: String
    let name: String
    let type: String
    let description: String
    let openHours: String
    let admission: String
    let imageURL: String
    let category: TourismCategory
    let location: String
    let whyVisit: String
    let bestSeason: String
    let photoPurpose: String

    init(
        id: String,
        name: String,
        type: String,
        description: String,
        openHours: String,
        admission: String,
        imageURL: String,
        category: TourismCategory? = nil,
        location: String? = nil,
        whyVisit: String? = nil,
        bestSeason: String? = nil,
        photoPurpose: String? = nil
    ) {
        let metadata = Self.metadata[id] ?? Self.inferredMetadata(name: name, type: type)
        self.id = id
        self.name = name
        self.type = type
        self.description = description
        self.openHours = openHours
        self.admission = admission
        self.imageURL = imageURL
        self.category = category ?? metadata.category
        self.location = location ?? metadata.location
        self.whyVisit = whyVisit ?? metadata.whyVisit
        self.bestSeason = bestSeason ?? metadata.bestSeason
        self.photoPurpose = photoPurpose ?? metadata.photoPurpose
    }

    private static let metadata: [String: AttractionMetadata] = [
        "rijks": meta(.museums, "Amsterdam, Noord-Holland", "See the Dutch national collection in a building that anchors Museumplein.", "Year-round", "Rijksmuseum facade, not an Amsterdam canal hero."),
        "vangogh": meta(.museums, "Amsterdam, Noord-Holland", "Follow Van Gogh's work through the world's deepest museum collection of his art.", "Year-round", "Van Gogh Museum building with its own Museumplein identity."),
        "annefrank": meta(.historicCentres, "Amsterdam, Noord-Holland", "Connect Amsterdam's canal history with one of Europe's most important wartime memory sites.", "Year-round; reserve ahead", "Anne Frank House exterior on Prinsengracht."),
        "markthal": meta(.topAttractions, "Rotterdam, Zuid-Holland", "Experience Rotterdam's modern public architecture and food culture in one place.", "Year-round", "Markthal exterior or hall artwork, not Erasmus Bridge."),
        "kubus": meta(.topAttractions, "Rotterdam, Zuid-Holland", "Understand Rotterdam's experimental post-war architecture at street level.", "Year-round", "Cube Houses geometry."),
        "euromast": meta(.topAttractions, "Rotterdam, Zuid-Holland", "Get the clearest city-and-port orientation view above the Maas.", "Clear days; sunset", "Euromast tower, not bridge-only imagery."),
        "erasmus": meta(.topAttractions, "Rotterdam, Zuid-Holland", "Walk the city's defining bridge and skyline threshold.", "Year-round; blue hour", "Erasmus Bridge at night, distinct from Rotterdam hero."),
        "binnenhof": meta(.historicCentres, "Den Haag, Zuid-Holland", "See the historic heart of Dutch parliamentary life, even during renovation limits.", "Spring-autumn", "Binnenhof complex, not Peace Palace or windmills."),
        "peacepalace": meta(.topAttractions, "Den Haag, Zuid-Holland", "Recognize The Hague as a city of international law and diplomacy.", "Spring-autumn", "Peace Palace facade."),
        "scheveningen": meta(.beaches, "Scheveningen, Den Haag, Zuid-Holland", "Use the Netherlands' best-known urban beach as the coast-facing side of The Hague.", "Summer; clear winter walks", "Beach, pier, and North Sea."),
        "mauritshuis": meta(.museums, "Den Haag, Zuid-Holland", "See Vermeer, Rembrandt, and Dutch Golden Age art beside the Hofvijver.", "Year-round", "Mauritshuis exterior, not Binnenhof."),
        "hortusleiden": meta(.parks, "Leiden, Zuid-Holland", "Visit one of Europe's historic botanical gardens and Leiden's university science heritage.", "Spring-summer", "Hortus garden structures and planting."),
        "devalk": meta(.topAttractions, "Leiden, Zuid-Holland", "See the windmill that makes Leiden visually distinct from other canal cities.", "Spring-autumn", "Molen de Valk with full sails protected."),
        "oudheden": meta(.museums, "Leiden, Zuid-Holland", "Use Leiden's antiquities museum to connect university city identity with archaeology.", "Year-round", "Rijksmuseum van Oudheden building."),
        "domtoren": meta(.topAttractions, "Utrecht, Utrecht", "Utrecht's defining vertical landmark and historic orientation point.", "Year-round", "Full Dom Tower height protected."),
        "oudegracht": meta(.historicCentres, "Utrecht, Utrecht", "Experience Utrecht's unique wharf-level canals and historic centre.", "Spring-autumn", "Oudegracht wharves with Utrecht's split-level canal structure."),
        "speelklok": meta(.museums, "Utrecht, Utrecht", "A distinctive Utrecht museum experience around self-playing instruments.", "Year-round", "Museum Speelklok facade/interior."),
        "martinitoren": meta(.topAttractions, "Groningen, Groningen", "The northern tower that makes Groningen immediately recognizable.", "Year-round", "Martinitoren with full spire protected."),
        "groningermuseum": meta(.museums, "Groningen, Groningen", "A bold museum building that captures Groningen's cultural personality.", "Year-round", "Groninger Museum architecture."),
        "valkhof-museum": meta(.museums, "Nijmegen, Gelderland", "Connect Nijmegen's Roman and medieval layers through its main museum.", "Year-round", "Museum Het Valkhof."),
        "waalbrug": meta(.topAttractions, "Nijmegen, Gelderland", "The bridge that defines Nijmegen's Waal river skyline.", "Year-round; evening", "Waalbrug arch protected."),
        "valkhof-park": meta(.parks, "Nijmegen, Gelderland", "A hilltop park where Roman and medieval remains overlook the river.", "Spring-autumn", "Valkhof Park ruins and river context."),
        "john-frost-bridge": meta(.topAttractions, "Arnhem, Gelderland", "Arnhem's defining WWII memory landmark and Rhine crossing.", "Year-round", "John Frost Bridge span protected."),
        "hoge-veluwe": meta(.nature, "Otterlo / Arnhem, Gelderland", "Enter the largest national park landscape near Arnhem, with heath, forest, dunes, and white bikes.", "Spring-autumn", "Hoge Veluwe heath or forest, not Arnhem city."),
        "kroller-muller": meta(.museums, "Otterlo, Gelderland", "Combine Van Gogh, sculpture, and national park context in one visit.", "Year-round", "Kroller-Muller Museum in its Hoge Veluwe art-and-nature setting."),
        "vrijthof": meta(.historicCentres, "Maastricht, Limburg", "Stand in Maastricht's main square between basilicas and southern cafe culture.", "Spring-winter", "Vrijthof square and basilica skyline."),
        "servatius": meta(.topAttractions, "Maastricht, Limburg", "See one of the country's oldest church heritage sites.", "Year-round", "Basilica of St. Servatius facade."),
        "dominicanen": meta(.hiddenGems, "Maastricht, Limburg", "A rare reused medieval church bookstore that makes Maastricht's culture tangible.", "Year-round", "Dominicanen bookstore interior."),
        "philipsmuseum": meta(.museums, "Eindhoven, Noord-Brabant", "Understand Eindhoven's transformation from Philips factory city to design-tech hub.", "Year-round", "Philips Museum building."),
        "evoluon": meta(.topAttractions, "Eindhoven, Noord-Brabant", "The futuristic landmark that makes Eindhoven's design-tech identity visible.", "Year-round", "Evoluon circular form protected."),
        "vanabbe": meta(.museums, "Eindhoven, Noord-Brabant", "See Eindhoven's contemporary art side beyond technology.", "Year-round", "Van Abbemuseum building."),
        "nieuwe-kerk-delft": meta(.topAttractions, "Delft, Zuid-Holland", "Visit Delft's royal mausoleum and market-square tower.", "Year-round", "Nieuwe Kerk tower protected."),
        "royal-delft": meta(.hiddenGems, "Delft, Zuid-Holland", "See the surviving Delftware factory that gives the city its blue-and-white identity.", "Year-round", "Royal Delft factory or Delftware work."),
        "prinsenhof-delft": meta(.museums, "Delft, Zuid-Holland", "Connect Delft to William of Orange and the origin story of the Dutch state.", "Year-round", "Prinsenhof Museum as Delft's William of Orange heritage site."),
        "franshals": meta(.museums, "Haarlem, Noord-Holland", "See Haarlem's Golden Age portrait culture in its own city context.", "Year-round", "Frans Hals Museum or collection context."),
        "teylers": meta(.museums, "Haarlem, Noord-Holland", "Visit the oldest museum in the Netherlands.", "Year-round", "Teylers Museum facade."),
        "grotekerk": meta(.topAttractions, "Haarlem, Noord-Holland", "Haarlem's central Gothic church and organ landmark.", "Year-round", "Sint-Bavokerk tower/interior protected.")
    ]

    private static func meta(
        _ category: TourismCategory,
        _ location: String,
        _ whyVisit: String,
        _ bestSeason: String,
        _ photoPurpose: String
    ) -> AttractionMetadata {
        AttractionMetadata(
            category: category,
            location: location,
            whyVisit: whyVisit,
            bestSeason: bestSeason,
            photoPurpose: photoPurpose
        )
    }

    private static func inferredMetadata(name: String, type: String) -> AttractionMetadata {
        let category: TourismCategory
        let lower = type.lowercased()
        if lower.contains("museum") {
            category = .museums
        } else if lower.contains("park") || lower.contains("garden") {
            category = .parks
        } else if lower.contains("beach") {
            category = .beaches
        } else if lower.contains("national") || lower.contains("nature") {
            category = .nature
        } else if lower.contains("historic") || lower.contains("church") {
            category = .historicCentres
        } else {
            category = .topAttractions
        }

        return AttractionMetadata(
            category: category,
            location: "The Netherlands",
            whyVisit: "Visit \(name) for a specific, place-linked Netherlands experience.",
            bestSeason: "Year-round",
            photoPurpose: "Specific photo of \(name), tied to its own city or province context."
        )
    }
}

struct TourismAttractionRecord: Identifiable, Codable {
    let id: String
    let category: TourismCategory
    let name: String
    let location: String
    let description: String
    let whyVisit: String
    let bestSeason: String
    let photoURL: String
}

enum TourismAttractionCatalog {
    static let records: [TourismAttractionRecord] = [
        record("rijksmuseum-amsterdam", .topAttractions, "Rijksmuseum", "Amsterdam, Noord-Holland", "National museum at Museumplein with Dutch art and history.", "A first-time visitor can understand the Dutch Golden Age, national art, and Museumplein in one stop.", "Year-round", "https://commons.wikimedia.org/wiki/Special:FilePath/South%20facade%20of%20the%20Rijksmuseum%20Amsterdam%20%28DSCF0528%29.jpg?width=1600"),
        record("erasmusbrug-rotterdam", .topAttractions, "Erasmus Bridge", "Rotterdam, Zuid-Holland", "Cable-stayed bridge linking central Rotterdam with Kop van Zuid.", "It is the clearest symbol of modern Rotterdam, the Maas, and the city's rebuilt skyline.", "Year-round; blue hour", "https://commons.wikimedia.org/wiki/Special:FilePath/Rotterdam%20Erasmusbrug%20Kop%20van%20Zuid%2020050928%2040201.JPG?width=1600"),
        record("peace-palace-den-haag", .topAttractions, "Peace Palace", "Den Haag, Zuid-Holland", "International law landmark housing global courts and institutions.", "It makes The Hague's peace-and-justice identity immediately visible.", "Spring-autumn", "https://commons.wikimedia.org/wiki/Special:FilePath/Peace%20Palace%20in%20The%20Hague%20%289347428414%29.jpg?width=1600"),
        record("van-gogh-museum", .museums, "Van Gogh Museum", "Amsterdam, Noord-Holland", "Museum dedicated to Vincent van Gogh's paintings, drawings, and letters.", "It gives visitors the most complete Van Gogh story in the world.", "Year-round", "https://commons.wikimedia.org/wiki/Special:FilePath/Van%20Gogh%20Museum%2C%20Kurokawa%20wing.jpg?width=1600"),
        record("mauritshuis", .museums, "Mauritshuis", "Den Haag, Zuid-Holland", "Royal picture gallery with Vermeer, Rembrandt, and Dutch Golden Age masterpieces.", "It pairs museum culture with the Hofvijver government setting.", "Year-round", "https://commons.wikimedia.org/wiki/Special:FilePath/Den%20Haag%20-%20Lange%20Vijverberg%20-%20View%20on%20Hofvijver%2C%20Mauritshuis%20%26%20Binnenhof.jpg?width=1600"),
        record("groninger-museum", .museums, "Groninger Museum", "Groningen, Groningen", "Postmodern museum building and regional cultural landmark.", "It shows Groningen's bold cultural personality beyond the city tower.", "Year-round", "https://commons.wikimedia.org/wiki/Special:FilePath/Brug%20naar%20mseumeiland%20Groningen%201510-006.jpg?width=1600"),
        record("doorwerth-castle", .castles, "Doorwerth Castle", "Doorwerth, Gelderland", "Medieval castle near the Rhine with moat, courtyards, and river-estate setting.", "It represents Gelderland's castle landscape without borrowing city imagery.", "Spring-autumn", "https://commons.wikimedia.org/wiki/Special:FilePath/Netherlands%2C%20Renkum%2C%20Castle%20Doorwerth%20%284%29.JPG?width=1600"),
        record("valkenburg-castle-ruins", .castles, "Valkenburg Castle Ruins", "Valkenburg, Limburg", "Hilltop castle ruins above a marlstone Limburg town.", "It gives Limburg a castle-and-hills identity unlike the flat western provinces.", "Spring-autumn", "https://commons.wikimedia.org/wiki/Special:FilePath/Valkenburg%20Kasteel.jpg?width=1600"),
        record("hoge-veluwe", .nature, "De Hoge Veluwe National Park", "Otterlo, Gelderland", "Heath, forest, sand drifts, wildlife, white bicycles, and museum access.", "It is the strongest inland nature anchor in the Netherlands guide.", "Spring-autumn", "https://commons.wikimedia.org/wiki/Special:FilePath/Zandverstuiving%20hoge%20veluwe%201.jpg?width=1600"),
        record("biesbosch", .nature, "Biesbosch National Park", "Noord-Brabant / Zuid-Holland", "Freshwater tidal wetlands with creeks, willow forests, birds, and beavers.", "It shows a water-rich nature system that is not canals or beaches.", "Spring-summer", "https://commons.wikimedia.org/wiki/Special:FilePath/Biesbosch%202.jpg?width=1600"),
        record("scheveningen-beach", .beaches, "Scheveningen Beach", "Den Haag, Zuid-Holland", "North Sea beach district with pier, sand, restaurants, and events.", "It explains why The Hague is both a government city and a seaside destination.", "Summer; clear winter walks", "https://commons.wikimedia.org/wiki/Special:FilePath/Scheveningen%20beach%20from%20the%20pier%20in%20August%202016.jpg?width=1600"),
        record("domburg-beach", .beaches, "Domburg Beach", "Domburg, Zeeland", "Wide Zeeland beach and dunes near a historic seaside resort.", "It gives Zeeland a tourism image rooted in coast and islands.", "Summer", "https://commons.wikimedia.org/wiki/Special:FilePath/Watertoren%20Domburg%20-%20view%20from%20the%20beach.jpg?width=1600"),
        record("valkhof-park", .parks, "Valkhof Park", "Nijmegen, Gelderland", "Historic hilltop park with Roman and medieval remains above the Waal.", "It turns Nijmegen's oldest-city story into a walkable park experience.", "Spring-autumn", "https://commons.wikimedia.org/wiki/Special:FilePath/2013.05.30.180814%20Valkhof%20Chapel%20Nijmegen%20NL.jpg?width=1600"),
        record("sonsbeek-park", .parks, "Sonsbeek Park", "Arnhem, Gelderland", "Large landscaped city park with greenery, slopes, and water features.", "It gives Arnhem a green identity separate from the John Frost Bridge.", "Spring-autumn", "https://commons.wikimedia.org/wiki/Special:FilePath/Arnhem%20Sonsbeek%20waterval%20A.jpg?width=1600"),
        record("delft-historic-centre", .historicCentres, "Delft Historic Centre", "Delft, Zuid-Holland", "Canals, Nieuwe Kerk, Markt, Delft Blue, and Vermeer heritage.", "It is a compact old-city day trip with a visual identity distinct from Leiden or Amsterdam.", "Year-round", "https://commons.wikimedia.org/wiki/Special:FilePath/0804%20Delft%2C%20Markt%20with%20Nieuwe%20Kerk%2C%20Delft%20407.jpg?width=1600"),
        record("maastricht-historic-centre", .historicCentres, "Maastricht Historic Centre", "Maastricht, Limburg", "Vrijthof, old streets, churches, Maas river, and southern terraces.", "It gives visitors a border-region version of Dutch urban history.", "Spring-winter", "https://commons.wikimedia.org/wiki/Special:FilePath/2016%20Maastricht%2C%20Grote%20Looiersstraat%2009.jpg?width=1600"),
        record("amsterdam-canal-ring", .unescoSites, "Amsterdam Canal Ring", "Amsterdam, Noord-Holland", "Seventeenth-century concentric canal district with merchant houses.", "The UNESCO canal ring explains Amsterdam's water, trade, and urban-planning identity.", "Year-round", "https://commons.wikimedia.org/wiki/Special:FilePath/Amsterdam%20-%20the%20Canal%20Ring%20%288652262148%29.jpg?width=1600"),
        record("kinderdijk", .unescoSites, "Kinderdijk-Elshout Mill Network", "Molenlanden, Zuid-Holland", "UNESCO windmill network with waterways, pumping stations, and polders.", "It is the clearest Dutch water-management heritage image, but only for this site.", "Spring-autumn", "https://commons.wikimedia.org/wiki/Special:FilePath/Overwaard%20Mill%20No.4%2C%20sunrise.jpg?width=1600"),
        record("schokland", .unescoSites, "Schokland", "Noordoostpolder, Flevoland", "Former island preserved inside reclaimed polder land.", "It makes Flevoland's reclaimed-land history visible through a UNESCO site.", "Spring-autumn", "https://commons.wikimedia.org/wiki/Special:FilePath/Schokland.%20UNESCO-Werelderfgoed%2063.jpg?width=1600"),
        record("dominicanen-bookstore", .hiddenGems, "Dominicanen Bookstore", "Maastricht, Limburg", "Bookshop inside a reused medieval Dominican church.", "It is a memorable hidden gem where architecture and everyday culture meet.", "Year-round", "https://commons.wikimedia.org/wiki/Special:FilePath/Boekhandel%20Dominicanen%20%2816865212150%29.jpg?width=1600"),
        record("teylers-museum", .hiddenGems, "Teylers Museum", "Haarlem, Noord-Holland", "Oldest museum in the Netherlands with science, art, and historical interiors.", "It gives Haarlem a culture image beyond Grote Markt and Sint-Bavo.", "Year-round", "https://commons.wikimedia.org/wiki/Special:FilePath/Library%20at%20the%20Teylers%20museum%2C%20photo-1.JPG?width=1600"),
        record("giethoorn-day-trip", .dayTrips, "Giethoorn", "Overijssel", "Canal village with thatched houses, boats, bridges, and quiet waterways.", "It is the strongest water-village day trip outside the Randstad.", "Spring-summer", "https://commons.wikimedia.org/wiki/Special:FilePath/Giethoorn%20Netherlands%20Channels-and-houses-of-Giethoorn-07.jpg?width=1600"),
        record("alkmaar-cheese-market", .dayTrips, "Alkmaar Cheese Market", "Alkmaar, Noord-Holland", "Waagplein cheese weighing ceremony and historic market square.", "It is a specific North Holland tourism ritual with Alkmaar's cheese carriers and Waagplein setting.", "Spring-summer", "https://commons.wikimedia.org/wiki/Special:FilePath/Kaasdragers%20Gilde%20van%20Alkmaar%202013.jpg?width=1600")
    ]

    private static func record(
        _ id: String,
        _ category: TourismCategory,
        _ name: String,
        _ location: String,
        _ description: String,
        _ whyVisit: String,
        _ bestSeason: String,
        _ photoURL: String
    ) -> TourismAttractionRecord {
        TourismAttractionRecord(
            id: id,
            category: category,
            name: name,
            location: location,
            description: description,
            whyVisit: whyVisit,
            bestSeason: bestSeason,
            photoURL: photoURL
        )
    }
}

struct CityFact: Identifiable, Codable {
    var id: String { "\(label)-\(value)" }
    let icon: String
    let label: String
    let value: String
}

extension CityFact {
    func label(_ lang: AppLanguage) -> String {
        switch lang {
        case .english:
            return label
        case .dutch:
            return Self.localizedLabels[label]?.dutch ?? label
        case .russian:
            return Self.localizedLabels[label]?.russian ?? label
        }
    }

    func localizedValue(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return value
        case .dutch: return Self.localizedValues[value]?.dutch ?? value
        case .russian: return Self.localizedValues[value]?.russian ?? value
        }
    }

    private static let localizedValues: [String: (dutch: String, russian: String)] = [
        "Royal seat": ("Koninklijke residentie", "Королевская резиденция"),
        "Scheveningen": ("Scheveningen", "Схевенинген"),
        "Yes": ("Ja", "Да"),
        "No": ("Nee", "Нет")
    ]

    private static let localizedLabels: [String: (dutch: String, russian: String)] = [
        "Population": ("Inwoners", "Население"),
        "Area": ("Oppervlakte", "Площадь"),
        "Founded": ("Gesticht", "Основан"),
        "City rank": ("Stadsrang", "Ранг города"),
        "Rank": ("Rang", "Ранг"),
        "Rank NL": ("Rang NL", "Ранг NL"),
        "Nationalities": ("Nationaliteiten", "Национал."),
        "Bikes": ("Fietsen", "Велосипедов"),
        "Bridges": ("Bruggen", "Мостов"),
        "Museums": ("Musea", "Музеев"),
        "Port cargo": ("Havenlading", "Груз порта"),
        "Port rank": ("Havenrang", "Ранг порта"),
        "Royalty": ("Koningshuis", "Королевство"),
        "Int'l orgs": ("Internat. org.", "Межд. орг."),
        "Beach": ("Strand", "Пляж"),
        "Students": ("Studenten", "Студентов"),
        "Canals": ("Grachten", "Каналов"),
        "University": ("Universiteit", "Университет"),
        "Nobel prizes": ("Nobelprijzen", "Нобелевских"),
        "Distance": ("Afstand", "Расстояние"),
        "Location": ("Ligging", "Расположение"),
        "Rail hub": ("Spoorknooppunt", "Ж/д узел"),
        "Diversity": ("Diversiteit", "Разнообразие"),
        "Airport": ("Luchthaven", "Аэропорт"),
        "Embassies": ("Ambassades", "Посольства"),
        "Ministries": ("Ministeries", "Министерства"),
        "Hofjes": ("Hofjes", "Дворики"),
        "Rembrandt": ("Rembrandt", "Рембрандт"),
        "Mayflower": ("Mayflower", "Mayflower"),
        "Gas field": ("Gasveld", "Газовое поле"),
        "Tower": ("Toren", "Башня"),
        "Wadden Sea": ("Waddenzee", "Ваттовое море"),
        "Liberation": ("Bevrijding", "Освобождение"),
        "EU Treaty": ("EU-verdrag", "Договор ЕС"),
        "Roman": ("Romeins", "Римский"),
        "Basilica": ("Basiliek", "Базилика"),
        "Borders": ("Grenzen", "Границы"),
        "Philips": ("Philips", "Philips"),
        "ASML": ("ASML", "ASML"),
        "TU/e": ("TU/e", "TU/e"),
        "Design Week": ("Design Week", "Неделя дизайна"),
        "Football": ("Voetbal", "Футбол"),
        "Patents": ("Patenten", "Патенты"),
        "Oldest city": ("Oudste stad", "Старейший город"),
        "Radboud": ("Radboud", "Radboud"),
        "Vierdaagse": ("Vierdaagse", "Vierdaagse"),
        "Waal": ("Waal", "Ваал"),
        "Green city": ("Groene stad", "Зелёный город"),
        "WWII battle": ("WOII-slag", "Битва WWII"),
        "Bridge": ("Brug", "Мост"),
        "National park": ("Nationaal park", "Нацпарк"),
        "Van Gogh": ("Van Gogh", "Ван Гог"),
        "Open Air": ("Openlucht", "Open Air")
    ]
}

extension NLCity {
    func desc(short: Bool = false, lang: AppLanguage) -> String {
        guard let content = CityLocalizedContent.priority[id] else {
            return short ? shortDescription : fullDescription
        }
        return short ? content.short.localized(lang) : content.full.localized(lang)
    }

    func hist(lang: AppLanguage) -> String {
        CityLocalizedContent.priority[id]?.history.localized(lang) ?? history
    }

    func highlights(lang: AppLanguage) -> [String] {
        CityLocalizedContent.priority[id]?.highlights[lang] ?? highlights
    }

    func expat(lang: AppLanguage) -> String {
        CityLocalizedContent.priority[id]?.expat.localized(lang) ?? expat
    }

    func transport(lang: AppLanguage) -> String {
        CityLocalizedContent.priority[id]?.transport.localized(lang) ?? transport
    }

    func keywords(lang: AppLanguage) -> String? {
        CityLocalizedContent.priority[id]?.keywords?.localized(lang)
    }
}

struct CityLocalizedText: Codable, Equatable {
    let english: String
    let dutch: String
    let russian: String

    func localized(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return english
        case .dutch: return dutch
        case .russian: return russian
        }
    }
}

struct CityLocalizedContent: Codable, Equatable {
    let short: CityLocalizedText
    let full: CityLocalizedText
    let history: CityLocalizedText
    let highlights: [AppLanguage: [String]]
    let expat: CityLocalizedText
    let transport: CityLocalizedText
    var keywords: CityLocalizedText?

    init(
        short: CityLocalizedText, full: CityLocalizedText,
        history: CityLocalizedText, highlights: [AppLanguage: [String]],
        expat: CityLocalizedText, transport: CityLocalizedText,
        keywords: CityLocalizedText? = nil
    ) {
        self.short = short; self.full = full; self.history = history
        self.highlights = highlights; self.expat = expat; self.transport = transport
        self.keywords = keywords
    }

    static let priority: [String: CityLocalizedContent] = [
        "amsterdam": content(
            short: ("Amsterdam is the Dutch capital: canals, museums, cycling, finance, and a large international community.", "Amsterdam is de hoofdstad: grachten, musea, fietsen, financien en een grote internationale gemeenschap.", "Амстердам — столица Нидерландов: каналы, музеи, велосипеды, финансы и большое международное сообщество."),
            full: ("Amsterdam is built around a UNESCO-listed canal ring and remains the Netherlands' best-known international city. It combines historic neighbourhoods, major museums, cycling infrastructure, universities, finance, tech companies, and public services used by many newcomers.", "Amsterdam is gebouwd rond een UNESCO-grachtengordel en is de bekendste internationale stad van Nederland. De stad combineert historische buurten, grote musea, fietsinfrastructuur, universiteiten, financiele instellingen, techbedrijven en diensten voor nieuwkomers.", "Амстердам построен вокруг канального кольца ЮНЕСКО и остаётся самым известным международным городом Нидерландов. Здесь сочетаются исторические районы, крупные музеи, велосипедная инфраструктура, университеты, финансы, технологические компании и службы для приезжих."),
            history: ("Amsterdam began as a settlement on the Amstel and grew into a major trading centre during the Dutch Golden Age. The canal ring, merchant houses, museums, and wartime memory sites still shape the city today.", "Amsterdam begon als nederzetting aan de Amstel en groeide in de Gouden Eeuw uit tot een belangrijk handelscentrum. De grachtengordel, koopmanshuizen, musea en herinneringsplekken uit de oorlog bepalen nog steeds het stadsbeeld.", "Амстердам возник как поселение на Амстеле и в Золотой век стал крупным торговым центром. Каналы, купеческие дома, музеи и места памяти о войне до сих пор определяют облик города."),
            highlights: (["Rijksmuseum and Van Gogh Museum", "UNESCO canal ring", "Anne Frank House", "Major cycling network"], ["Rijksmuseum en Van Gogh Museum", "UNESCO-grachtengordel", "Anne Frank Huis", "Groot fietsnetwerk"], ["Rijksmuseum и музей Ван Гога", "Канальное кольцо ЮНЕСКО", "Дом Анны Франк", "Большая велосеть"]),
            expat: ("Amsterdam has the largest international community in the Netherlands and many English-friendly services.", "Amsterdam heeft de grootste internationale gemeenschap van Nederland en veel diensten waar Engels gebruikelijk is.", "В Амстердаме самое большое международное сообщество страны и много сервисов, где говорят по-английски."),
            transport: ("Amsterdam Centraal connects trains, metro, trams, buses, ferries, cycling routes, and Schiphol Airport.", "Amsterdam Centraal verbindt trein, metro, tram, bus, ponten, fietsroutes en Schiphol.", "Amsterdam Centraal соединяет поезда, метро, трамваи, автобусы, паромы, веломаршруты и аэропорт Schiphol."),
            keywords: ("Canals • Museums • Cycling • Finance", "Grachten • Musea • Fietsen • Financiën", "Каналы • Музеи • Велосипеды • Финансы")
        ),
        "rotterdam": content(
            short: ("Rotterdam is a modern port city known for architecture, the Maas river, and Europe's largest seaport.", "Rotterdam is een moderne havenstad aan de Maas, bekend om architectuur en de grootste zeehaven van Europa.", "Роттердам — современный портовый город на Маасе, известный архитектурой и крупнейшим морским портом Европы."),
            full: ("Rotterdam rebuilt itself after World War II into a bold modern city. Its skyline, Erasmus Bridge, Markthal, Cube Houses, universities, and port economy make it one of the most practical and international Dutch cities for newcomers.", "Rotterdam bouwde zich na de Tweede Wereldoorlog opnieuw op als uitgesproken moderne stad. Skyline, Erasmusbrug, Markthal, Kubuswoningen, onderwijs en haveneconomie maken de stad praktisch en internationaal.", "После Второй мировой войны Роттердам заново построил себя как смелый современный город. Его skyline, мост Эразма, Markthal, Кубические дома, образование и портовая экономика делают город практичным и международным."),
            history: ("Rotterdam received city rights in 1340. The 1940 bombing destroyed much of the old centre, after which the city chose modern reconstruction, high-rise buildings, and major port expansion.", "Rotterdam kreeg stadsrechten in 1340. Het bombardement van 1940 verwoestte veel van het centrum; daarna koos de stad voor moderne wederopbouw, hoogbouw en havenuitbreiding.", "Роттердам получил городские права в 1340 году. Бомбардировка 1940 года разрушила большую часть центра, после чего город выбрал современную реконструкцию, высотную застройку и расширение порта."),
            highlights: (["Erasmus Bridge", "Port of Rotterdam", "Markthal", "Cube Houses"], ["Erasmusbrug", "Haven van Rotterdam", "Markthal", "Kubuswoningen"], ["Мост Эразма", "Порт Роттердама", "Markthal", "Кубические дома"]),
            expat: ("Rotterdam has diverse communities and practical support through municipal and international arrival services.", "Rotterdam heeft diverse gemeenschappen en praktische ondersteuning via gemeente en internationale loketten.", "В Роттердаме много разных сообществ и есть практическая поддержка через муниципальные и международные службы."),
            transport: ("Rotterdam Centraal connects intercity trains, metro, trams, buses, water transport, and international rail.", "Rotterdam Centraal verbindt intercity's, metro, tram, bus, vervoer over water en internationaal spoor.", "Rotterdam Centraal соединяет междугородние поезда, метро, трамваи, автобусы, водный транспорт и международные поезда."),
            keywords: ("Architecture • Port • Innovation • Business", "Architectuur • Haven • Innovatie • Business", "Архитектура • Порт • Инновации • Бизнес")
        ),
        "den-haag": content(
            short: ("Den Haag is the seat of government, diplomacy, international courts, royal work palaces, and the coast.", "Den Haag is de regeringsstad met diplomatie, internationale hoven, werkpaleizen en de kust.", "Гаага — город правительства, дипломатии, международных судов, рабочих дворцов короля и побережья."),
            full: ("Although Amsterdam is the constitutional capital, Den Haag is where the Dutch government works. Parliament, ministries, the Supreme Court, Noordeinde Palace, international courts, Europol, embassies, and Scheveningen beach are all part of the city.", "Hoewel Amsterdam de constitutionele hoofdstad is, werkt de Nederlandse regering in Den Haag. Parlement, ministeries, Hoge Raad, Paleis Noordeinde, internationale hoven, Europol, ambassades en Scheveningen horen bij de stad.", "Хотя Амстердам является конституционной столицей, именно в Гааге работает правительство. Здесь находятся парламент, министерства, Верховный суд, дворец Noordeinde, международные суды, Europol, посольства и пляж Схевенинген."),
            history: ("Den Haag grew around a medieval court and became the seat of Dutch government. Peace conferences in 1899 and 1907 helped establish its role in international law.", "Den Haag groeide rond een middeleeuws hof en werd de zetel van het Nederlandse bestuur. Vredesconferenties in 1899 en 1907 versterkten de rol in internationaal recht.", "Гаага выросла вокруг средневекового двора и стала местом работы нидерландского правительства. Мирные конференции 1899 и 1907 годов закрепили её роль в международном праве."),
            highlights: (["Binnenhof", "International Court of Justice", "Mauritshuis", "Scheveningen beach"], ["Binnenhof", "Internationaal Gerechtshof", "Mauritshuis", "Scheveningen strand"], ["Binnenhof", "Международный суд ООН", "Mauritshuis", "Пляж Схевенинген"]),
            expat: ("Den Haag has a strong diplomatic, legal, NGO, and international school community.", "Den Haag heeft een sterke diplomatieke, juridische, NGO- en internationale schoolgemeenschap.", "В Гааге сильное дипломатическое, юридическое, НКО- и школьное международное сообщество."),
            transport: ("Den Haag Centraal and HS connect trains, trams, RandstadRail, buses, Rotterdam, Amsterdam, and the coast.", "Den Haag Centraal en HS verbinden trein, tram, RandstadRail, bus, Rotterdam, Amsterdam en de kust.", "Den Haag Centraal и HS соединяют поезда, трамваи, RandstadRail, автобусы, Роттердам, Амстердам и побережье."),
            keywords: ("Government • Diplomacy • Coast • International Law", "Bestuur • Diplomatie • Kust • Internationaal Recht", "Правительство • Дипломатия • Побережье • Международное право")
        ),
        "utrecht": content(
            short: ("Utrecht is the central rail hub of the Netherlands, known for the Dom Tower and wharf-level canals.", "Utrecht is het centrale spoorknooppunt van Nederland, bekend om de Domtoren en werfkelders langs de grachten.", "Утрехт — центральный железнодорожный узел Нидерландов, известный башней Dom и каналами с нижними набережными."),
            full: ("Utrecht sits in the centre of the country and is one of the easiest Dutch cities to reach by train. The Oudegracht, Dom Tower, university, music venues, and compact neighbourhoods make it practical for daily life.", "Utrecht ligt centraal in het land en is per trein zeer goed bereikbaar. De Oudegracht, Domtoren, universiteit, muziekpodia en compacte wijken maken de stad praktisch voor dagelijks leven.", "Утрехт расположен в центре страны и очень удобен для поездок на поезде. Oudegracht, башня Dom, университет, музыкальные площадки и компактные районы делают город удобным для повседневной жизни."),
            history: ("Utrecht began as Roman Trajectum and became an important religious centre. The Dom Tower and the Union of Utrecht remain key symbols in Dutch history.", "Utrecht begon als Romeins Trajectum en werd een belangrijk religieus centrum. De Domtoren en de Unie van Utrecht blijven belangrijke symbolen in de Nederlandse geschiedenis.", "Утрехт начался как римский Trajectum и стал важным религиозным центром. Башня Dom и Утрехтская уния остаются важными символами истории Нидерландов."),
            highlights: (["Dom Tower", "Oudegracht", "Utrecht Centraal", "Utrecht University"], ["Domtoren", "Oudegracht", "Utrecht Centraal", "Universiteit Utrecht"], ["Башня Dom", "Oudegracht", "Utrecht Centraal", "Утрехтский университет"]),
            expat: ("Utrecht has an international community around education, healthcare, rail, tech, and services.", "Utrecht heeft een internationale gemeenschap rond onderwijs, zorg, spoor, technologie en dienstverlening.", "В Утрехте международное сообщество связано с образованием, медициной, железными дорогами, технологиями и сервисами."),
            transport: ("Utrecht Centraal is the busiest station in the Netherlands with direct links to all major cities.", "Utrecht Centraal is het drukste station van Nederland met directe verbindingen naar alle grote steden.", "Utrecht Centraal — самый загруженный вокзал страны с прямыми маршрутами во все крупные города."),
            keywords: ("Rail Hub • History • University • Canals", "Spoorknooppunt • Geschiedenis • Universiteit • Grachten", "Ж/д узел • История • Университет • Каналы")
        ),
        "leiden": content(
            short: ("Leiden is a historic university city with canals, museums, biotech, and strong newcomer services.", "Leiden is een historische universiteitsstad met grachten, musea, biotech en goede diensten voor nieuwkomers.", "Лейден — исторический университетский город с каналами, музеями, биотехом и хорошими службами для приезжих."),
            full: ("Leiden combines a compact historic centre, canals, hofjes, museums, Leiden University, hospitals, and international research communities. It is well connected to Amsterdam, Den Haag, Rotterdam, and Schiphol.", "Leiden combineert een compacte historische binnenstad, grachten, hofjes, musea, Universiteit Leiden, ziekenhuizen en internationale onderzoeksgemeenschappen. De stad is goed verbonden met Amsterdam, Den Haag, Rotterdam en Schiphol.", "Лейден сочетает компактный исторический центр, каналы, hofjes, музеи, Лейденский университет, больницы и международные научные сообщества. Город хорошо связан с Амстердамом, Гаагой, Роттердамом и Schiphol."),
            history: ("Leiden grew as a fortified textile city. After the siege of 1573-1574, the city received a university, now the oldest in the Netherlands. Rembrandt was born here.", "Leiden groeide als versterkte textielstad. Na het beleg van 1573-1574 kreeg de stad een universiteit, nu de oudste van Nederland. Rembrandt werd hier geboren.", "Лейден вырос как укреплённый текстильный город. После осады 1573-1574 годов город получил университет, ныне старейший в Нидерландах. Здесь родился Рембрандт."),
            highlights: (["Leiden University", "Historic canals", "Rembrandt heritage", "Museums"], ["Universiteit Leiden", "Historische grachten", "Rembrandt-erfgoed", "Musea"], ["Лейденский университет", "Исторические каналы", "Наследие Рембрандта", "Музеи"]),
            expat: ("Leiden is international through the university, LUMC, science park, and research institutes.", "Leiden is internationaal door de universiteit, het LUMC, het science park en onderzoeksinstituten.", "Лейден международен благодаря университету, LUMC, научному парку и исследовательским институтам."),
            transport: ("Leiden Centraal has direct trains to Amsterdam, Den Haag, Rotterdam, Schiphol, and Utrecht.", "Leiden Centraal heeft directe treinen naar Amsterdam, Den Haag, Rotterdam, Schiphol en Utrecht.", "Leiden Centraal имеет прямые поезда в Амстердам, Гаагу, Роттердам, Schiphol и Утрехт."),
            keywords: ("University • Science • Canals • Rembrandt", "Universiteit • Wetenschap • Grachten • Rembrandt", "Университет • Наука • Каналы • Рембрандт")
        ),
        "eindhoven": content(
            short: ("Eindhoven is the technology and design city of Brainport, Philips, ASML, and Dutch Design Week.", "Eindhoven is de technologie- en designstad van Brainport, Philips, ASML en Dutch Design Week.", "Эйндховен — город технологий и дизайна: Brainport, Philips, ASML и Dutch Design Week."),
            full: ("Eindhoven grew from a Brabant town into a high-tech and design centre. Philips, ASML, TU/e, Design Academy, High Tech Campus, and Brainport make the city important for international workers and students.", "Eindhoven groeide van Brabantse stad uit tot centrum voor hightech en design. Philips, ASML, TU/e, Design Academy, High Tech Campus en Brainport maken de stad belangrijk voor internationale werknemers en studenten.", "Эйндховен вырос из брабантского города в центр высоких технологий и дизайна. Philips, ASML, TU/e, Design Academy, High Tech Campus и Brainport делают его важным для международных работников и студентов."),
            history: ("Eindhoven received city rights in 1232 but expanded rapidly after Philips was founded in 1891. Later technology and design institutions shaped the modern Brainport region.", "Eindhoven kreeg stadsrechten in 1232 maar groeide snel nadat Philips in 1891 werd opgericht. Later vormden technologie- en designinstellingen de moderne Brainport-regio.", "Эйндховен получил городские права в 1232 году, но быстро вырос после основания Philips в 1891 году. Позднее технологические и дизайнерские институты сформировали регион Brainport."),
            highlights: (["Philips Museum", "ASML and Brainport", "Dutch Design Week", "High Tech Campus"], ["Philips Museum", "ASML en Brainport", "Dutch Design Week", "High Tech Campus"], ["Музей Philips", "ASML и Brainport", "Dutch Design Week", "High Tech Campus"]),
            expat: ("Eindhoven has a large high-tech expat community around ASML, Philips, TU/e, and Brainport.", "Eindhoven heeft een grote hightech-expatgemeenschap rond ASML, Philips, TU/e en Brainport.", "В Эйндховене большое технологическое международное сообщество вокруг ASML, Philips, TU/e и Brainport."),
            transport: ("Eindhoven station connects Dutch intercity routes, regional buses, and Eindhoven Airport.", "Station Eindhoven verbindt intercity's, streekbussen en Eindhoven Airport.", "Вокзал Eindhoven соединяет междугородние поезда, региональные автобусы и аэропорт Eindhoven."),
            keywords: ("Technology • Design • Philips • ASML", "Technologie • Design • Philips • ASML", "Технологии • Дизайн • Philips • ASML")
        ),
        "groningen": content(
            short: ("Groningen is the northern student city, known for the Martinitoren, universities, cycling, and regional services.", "Groningen is de noordelijke studentenstad, bekend om de Martinitoren, universiteiten, fietsen en regionale diensten.", "Гронинген — северный студенческий город, известный Martinitoren, университетами, велосипедами и региональными службами."),
            full: ("Groningen is the largest city in the north, with a young population, universities, hospitals, cultural venues, and strong cycling habits. The province also carries the legacy of gas extraction and earthquake policy.", "Groningen is de grootste stad van het noorden, met een jonge bevolking, universiteiten, ziekenhuizen, cultuur en een sterke fietscultuur. De provincie draagt ook de erfenis van gaswinning en aardbevingsbeleid.", "Гронинген — крупнейший город севера, с молодым населением, университетами, больницами, культурой и сильной велосипедной культурой. Провинция также несёт наследие газодобычи и политики по землетрясениям."),
            history: ("Groningen grew from a northern trading city into a university and service centre. The Martinitoren, liberation history, and gas field debates are important parts of its story.", "Groningen groeide van noordelijke handelsstad uit tot universiteits- en dienstencentrum. De Martinitoren, bevrijdingsgeschiedenis en discussies over gaswinning horen bij het verhaal.", "Гронинген вырос из северного торгового города в университетский и сервисный центр. Martinitoren, история освобождения и дебаты о газовом месторождении — важные части его истории."),
            highlights: (["Martinitoren", "University city", "Groninger Museum", "Wadden Sea nearby"], ["Martinitoren", "Universiteitsstad", "Groninger Museum", "Waddenzee dichtbij"], ["Martinitoren", "Университетский город", "Groninger Museum", "Ваттовое море рядом"]),
            expat: ("Groningen's international life is centred on the university, Hanze, UMCG, DUO, and northern services.", "Het internationale leven in Groningen draait om de universiteit, Hanze, UMCG, DUO en noordelijke diensten.", "Международная жизнь Гронингена связана с университетом, Hanze, UMCG, DUO и северными службами."),
            transport: ("Station Groningen connects regional trains, buses, cycling routes, Zwolle, Assen, Leeuwarden, and Amsterdam via transfers.", "Station Groningen verbindt regionale treinen, bussen, fietsroutes, Zwolle, Assen, Leeuwarden en Amsterdam via overstappen.", "Вокзал Groningen соединяет региональные поезда, автобусы, веломаршруты, Zwolle, Assen, Leeuwarden и Amsterdam с пересадками."),
            keywords: ("Students • North • University • Cycling", "Studenten • Noord • Universiteit • Fietsen", "Студенты • Север • Университет • Велосипеды")
        ),
        "nijmegen": content(
            short: ("Nijmegen is one of the Netherlands' oldest cities, with Roman heritage, Radboud University, the Waal river, and the Vierdaagse walking event.", "Nijmegen is een van de oudste steden van Nederland, met Romeins erfgoed, Radboud Universiteit, de Waal en de Vierdaagse.", "Неймеген — один из старейших городов Нидерландов: римское наследие, Radboud University, река Ваал и Vierdaagse."),
            full: ("Nijmegen combines Roman Noviomagus history, a compact historic centre, the Valkhof area, Radboud University and Radboudumc, green hills near Berg en Dal, and strong student life. It is practical for internationals who want a smaller city with rail links to Arnhem, Utrecht, Den Bosch, Germany, and the Randstad.", "Nijmegen combineert Romeins Noviomagus, een compacte historische binnenstad, het Valkhof, Radboud Universiteit en Radboudumc, groene heuvels bij Berg en Dal en veel studentenleven. De stad is praktisch voor internationals die een kleinere stad met goede verbindingen zoeken.", "Неймеген сочетает римский Noviomagus, компактный исторический центр, Valkhof, Radboud University и Radboudumc, зелёные холмы рядом с Berg en Dal и активную студенческую жизнь. Это удобный город для приезжих, которым нужен меньший масштаб и хорошие поезда."),
            history: ("Nijmegen grew from Roman Ulpia Noviomagus and is often described as the oldest city in the Netherlands. Valkhof hill, medieval remains, World War II memory, and the Waal bridges give the city a layered story.", "Nijmegen groeide uit Romeins Ulpia Noviomagus en wordt vaak de oudste stad van Nederland genoemd. Valkhofheuvel, middeleeuwse resten, oorlogsherinnering en de Waalbruggen geven de stad veel historische lagen.", "Неймеген вырос из римского Ulpia Noviomagus и часто называется старейшим городом Нидерландов. Холм Valkhof, средневековые остатки, память о Второй мировой и мосты через Ваал создают глубокий исторический слой."),
            highlights: (["Roman Noviomagus", "Valkhof and Waalbrug", "Radboud University and Radboudumc", "Vierdaagse walking event"], ["Romeins Noviomagus", "Valkhof en Waalbrug", "Radboud Universiteit en Radboudumc", "Vierdaagse wandelweek"], ["Римский Noviomagus", "Valkhof и Waalbrug", "Radboud University и Radboudumc", "Пешее событие Vierdaagse"]),
            expat: ("Nijmegen's international life is centred on Radboud University, Radboudumc, research institutes, health care, and students.", "Het internationale leven in Nijmegen draait om Radboud Universiteit, Radboudumc, onderzoeksinstellingen, zorg en studenten.", "Международная жизнь Неймегена связана с Radboud University, Radboudumc, исследовательскими институтами, медициной и студентами."),
            transport: ("Nijmegen station connects Arnhem, Utrecht, Den Bosch, Venlo, regional buses, Germany-adjacent routes, and strong cycling corridors.", "Station Nijmegen verbindt Arnhem, Utrecht, Den Bosch, Venlo, streekbussen, routes richting Duitsland en sterke fietsroutes.", "Вокзал Nijmegen соединяет Arnhem, Utrecht, Den Bosch, Venlo, региональные автобусы, маршруты к немецкой границе и сильные велокоридоры."),
            keywords: ("Roman Heritage • Radboud • Waal • Vierdaagse", "Romeins erfgoed • Radboud • Waal • Vierdaagse", "Римское наследие • Radboud • Ваал • Vierdaagse")
        ),
        "arnhem": content(
            short: ("Arnhem is Gelderland's capital, known for the Battle of Arnhem, John Frost Bridge, creative fashion culture, and green access to the Veluwe.", "Arnhem is de hoofdstad van Gelderland, bekend om de Slag om Arnhem, John Frostbrug, modecultuur en groene toegang tot de Veluwe.", "Арнем — столица Gelderland, известная битвой за Арнем, мостом John Frost, модной культурой и зелёным доступом к Veluwe."),
            full: ("Arnhem sits on the Rhine and combines government services, World War II memory, the John Frost Bridge, Arnhem Central Station, art and fashion education, Burgers' Zoo, the Open Air Museum, and access to Hoge Veluwe and the Kröller-Müller Museum. It is a practical regional base between the Randstad and Germany.", "Arnhem ligt aan de Rijn en combineert overheidsdiensten, oorlogsherinnering, de John Frostbrug, Arnhem Centraal, kunst- en modeonderwijs, Burgers' Zoo, het Openluchtmuseum en toegang tot de Hoge Veluwe en het Kröller-Müller Museum.", "Арнем расположен на Рейне и сочетает государственные службы, память о Второй мировой, мост John Frost, Arnhem Centraal, искусство и моду, Burgers' Zoo, Open Air Museum и доступ к Hoge Veluwe и музею Kröller-Müller."),
            history: ("Arnhem became globally known through Operation Market Garden and the 1944 Battle of Arnhem, later remembered through 'A Bridge Too Far'. The city rebuilt around the Rhine and remains the administrative capital of Gelderland.", "Arnhem werd wereldwijd bekend door Operatie Market Garden en de Slag om Arnhem in 1944, later herdacht via 'A Bridge Too Far'. De stad herbouwde zich rond de Rijn en blijft de bestuursstad van Gelderland.", "Арнем стал всемирно известен благодаря Operation Market Garden и битве за Арнем в 1944 году, позднее отражённой в 'A Bridge Too Far'. Город восстановился вокруг Рейна и остаётся административной столицей Gelderland."),
            highlights: (["John Frost Bridge", "Battle of Arnhem heritage", "Hoge Veluwe and Kröller-Müller nearby", "Open Air Museum"], ["John Frostbrug", "Erfgoed Slag om Arnhem", "Hoge Veluwe en Kröller-Müller dichtbij", "Openluchtmuseum"], ["Мост John Frost", "Наследие битвы за Арнем", "Hoge Veluwe и Kröller-Müller рядом", "Open Air Museum"]),
            expat: ("Arnhem supports internationals through regional government, education, creative sectors, healthcare, and cross-border work near Germany.", "Arnhem ondersteunt internationals via regionaal bestuur, onderwijs, creatieve sectoren, zorg en grenswerk richting Duitsland.", "Арнем удобен для приезжих благодаря региональным службам, образованию, креативным секторам, медицине и работе у границы с Германией."),
            transport: ("Arnhem Centraal connects intercity trains, regional rail, trolleybuses, Nijmegen, Utrecht, Zwolle, Germany routes, and Veluwe buses.", "Arnhem Centraal verbindt intercity's, regionale treinen, trolleybussen, Nijmegen, Utrecht, Zwolle, routes naar Duitsland en bussen naar de Veluwe.", "Arnhem Centraal соединяет intercity, региональные поезда, троллейбусы, Nijmegen, Utrecht, Zwolle, маршруты в Германию и автобусы к Veluwe."),
            keywords: ("John Frost Bridge • WWII • Veluwe • Design", "John Frostbrug • WOII • Veluwe • Design", "Мост John Frost • WWII • Veluwe • Дизайн")
        ),
        "maastricht": content(
            short: ("Maastricht is a southern border city with Roman history, university life, European heritage, and cafe culture.", "Maastricht is een zuidelijke grensstad met Romeinse geschiedenis, universiteitsleven, Europees erfgoed en cafecultuur.", "Маастрихт — южный приграничный город с римской историей, университетом, европейским наследием и кафе-культурой."),
            full: ("Maastricht has a distinct southern character shaped by Belgium, Germany, Roman Catholic heritage, old streets, terraces, the Maas river, and Maastricht University. It is important for cross-border life and European history.", "Maastricht heeft een duidelijk zuidelijk karakter door Belgie, Duitsland, katholiek erfgoed, oude straten, terrassen, de Maas en Maastricht University. De stad is belangrijk voor grensoverschrijdend leven en Europese geschiedenis.", "Маастрихт имеет выраженный южный характер благодаря Бельгии, Германии, католическому наследию, старым улицам, террасам, реке Маас и Maastricht University. Город важен для приграничной жизни и европейской истории."),
            history: ("Maastricht began as a Roman crossing on the Maas. It was contested by different powers and later became famous for the 1992 Maastricht Treaty, which shaped the European Union and the euro.", "Maastricht begon als Romeinse oversteekplaats aan de Maas. De stad werd vaak betwist en werd later bekend door het Verdrag van Maastricht uit 1992, belangrijk voor de EU en de euro.", "Маастрихт начался как римская переправа через Маас. За город спорили разные державы, а в 1992 году здесь был подписан Маастрихтский договор, важный для ЕС и евро."),
            highlights: (["Vrijthof", "Maastricht Treaty", "Basilica of Saint Servatius", "Cross-border location"], ["Vrijthof", "Verdrag van Maastricht", "Sint-Servaasbasiliek", "Grensligging"], ["Vrijthof", "Маастрихтский договор", "Базилика Святого Серватия", "Приграничное расположение"]),
            expat: ("Maastricht is international through the university, EU history, tourism, healthcare, and its border location.", "Maastricht is internationaal door de universiteit, EU-geschiedenis, toerisme, zorg en grensligging.", "Маастрихт международен благодаря университету, истории ЕС, туризму, медицине и положению у границы."),
            transport: ("Maastricht station connects Limburg, Eindhoven, Belgium routes, Germany buses, and regional transport.", "Station Maastricht verbindt Limburg, Eindhoven, Belgische routes, bussen naar Duitsland en regionaal vervoer.", "Вокзал Maastricht соединяет Limburg, Eindhoven, маршруты в Бельгию, автобусы в Германию и региональный транспорт."),
            keywords: ("History • Borders • EU Treaty • Culture", "Geschiedenis • Grenzen • EU-verdrag • Cultuur", "История • Границы • Договор ЕС • Культура")
        )
    ]

    private static func content(
        short: (String, String, String),
        full: (String, String, String),
        history: (String, String, String),
        highlights: ([String], [String], [String]),
        expat: (String, String, String),
        transport: (String, String, String),
        keywords: (String, String, String)? = nil
    ) -> CityLocalizedContent {
        CityLocalizedContent(
            short: CityLocalizedText(english: short.0, dutch: short.1, russian: short.2),
            full: CityLocalizedText(english: full.0, dutch: full.1, russian: full.2),
            history: CityLocalizedText(english: history.0, dutch: history.1, russian: history.2),
            highlights: [.english: highlights.0, .dutch: highlights.1, .russian: highlights.2],
            expat: CityLocalizedText(english: expat.0, dutch: expat.1, russian: expat.2),
            transport: CityLocalizedText(english: transport.0, dutch: transport.1, russian: transport.2),
            keywords: keywords.map { CityLocalizedText(english: $0.0, dutch: $0.1, russian: $0.2) }
        )
    }
}

extension NLCity {
    nonisolated static let all: [NLCity] = [
        NLCity(
            id: "amsterdam",
            name: "Amsterdam",
            province: "Noord-Holland",
            population: "921,402",
            area: "219.3 km²",
            founded: "1275 (as toll settlement)",
            postalCode: "1000–1109",
            coordinates: "52.3676° N, 4.9041° E",
            flag: CityFlag(colors: ["#AE1C28","#000000","#AE1C28"], description: "Rood-zwart-rood met drie Andreaskruisen", emoji: "🏴", svgStripes: [FlagStripe(color: "#AE1C28", heightFraction: 0.333), FlagStripe(color: "#000000", heightFraction: 0.334), FlagStripe(color: "#AE1C28", heightFraction: 0.333)]),
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Canal%20houses%20and%20Oude%20Kerk%20at%20blue%20hour%20with%20water%20reflection%20in%20Damrak%20Amsterdam%20Netherlands.jpg?width=2400",
            heroColor: "#1A3040",
            tagline: "Venice of the North — canals, culture and freedom",
            shortDescription: "Amsterdam is the capital and largest city of the Netherlands, home to world-class museums, 165 historic canals, and a cosmopolitan population from 180+ nationalities.",
            fullDescription: """
            Amsterdam is built on 90 islands connected by 1,281 bridges and bisected by its iconic canal ring, designated a UNESCO World Heritage Site in 2010. The city is home to more than 900,000 people and millions of annual visitors drawn to its extraordinary concentration of world-class museums, including the Rijksmuseum, Van Gogh Museum, and Anne Frank House.

            As a major European financial hub, Amsterdam hosts companies such as Heineken, Booking.com, Adyen, and ING. Its compact historic core, creative districts, cycling infrastructure, and international workforce make it one of Europe's most recognizable urban cultures.
            """,
            history: """
            Amsterdam began as a small fishing village on the Amstel river around 1275, when Count Floris V granted its residents a toll exemption, the first written record of the city. By the 17th century, the Dutch Golden Age transformed Amsterdam into one of the world's most powerful trading cities.

            The Dutch East India Company (VOC), founded in 1602, made Amsterdam a center of global trade. The canal ring was built in this period to house merchants' warehouses and mansions, and these same buildings survive today as the city's iconic UNESCO skyline.

            During World War II, the city was occupied by Nazi Germany from 1940 to 1945. Anne Frank hid with her family for over two years in a house on the Prinsengracht canal; her diary became one of the most widely read accounts of the Holocaust. Post-war Amsterdam became a center of counterculture and liberal social policy, including LGBTQ+ rights and drug harm reduction.
            """,
            highlights: ["🏛️ Rijksmuseum — national museum with Rembrandt's Night Watch", "🎨 Van Gogh Museum — world's largest collection of Van Gogh's works", "📖 Anne Frank House — preserved hiding place on Prinsengracht", "🌸 Flower markets and nearby Keukenhof tulip fields", "🍺 Heineken Experience in the original 1867 brewery", "🚲 750km of bike paths across the city"],
            attractions: [
                Attraction(id: "rijks", name: "Rijksmuseum", type: "Museum", description: "Dutch national museum with 800 years of art and history, including Rembrandt, Vermeer, and Hals.", openHours: "Daily 9:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Rijksmuseum%20from%20Museumplein%202523.jpg?width=1600"),
                Attraction(id: "vangogh", name: "Van Gogh Museum", type: "Museum", description: "The most complete Van Gogh collection in existence, with paintings, drawings, and letters.", openHours: "Daily 9:00–18:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Van_Gogh_Museum_Amsterdam.jpg?width=1600"),
                Attraction(id: "annefrank", name: "Anne Frank House", type: "Historic Site", description: "The canal house where Anne Frank and her family hid from 1942 to 1944.", openHours: "Daily 9:00–22:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Amsterdam%20%28NL%29%2C%20Anne-Frank-Huis%2C%202022%20%281%29.jpg?width=1600")
            ],
            facts: [CityFact(icon: "🏙️", label: "City rank", value: "#1 NL"), CityFact(icon: "🌍", label: "Nationalities", value: "180+"), CityFact(icon: "🚲", label: "Bikes", value: "900k"), CityFact(icon: "🌉", label: "Bridges", value: "1,281"), CityFact(icon: "🏛️", label: "Museums", value: "75"), CityFact(icon: "✈️", label: "Airport", value: "Schiphol")],
            services: ["IND (immigration)", "DUO (student finance)", "Belastingdienst", "UWV (employment)"],
            expat: "Amsterdam has the largest expat community in the Netherlands. Expat Center Amsterdam offers one-stop registration for new internationals.",
            transport: "Amsterdam Centraal connects Intercity, Eurostar, metro, tram, and regional bus networks."
        ),
        NLCity(
            id: "rotterdam",
            name: "Rotterdam",
            province: "Zuid-Holland",
            population: "655,468",
            area: "325.8 km²",
            founded: "1340",
            postalCode: "3000–3089",
            coordinates: "51.9244° N, 4.4777° E",
            flag: CityFlag(colors: ["#006B35","#FFFFFF"], description: "Groen-wit, stadskleur Rotterdam", emoji: "🏴", svgStripes: [FlagStripe(color: "#006B35", heightFraction: 0.5), FlagStripe(color: "#FFFFFF", heightFraction: 0.5)]),
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Erasmusbrug%20seen%20from%20Euromast.jpg?width=2400",
            heroColor: "#1A2A3A",
            tagline: "Europe's largest port — architecture capital of the Netherlands",
            shortDescription: "Rotterdam is a global gateway city, home to Europe's largest seaport, avant-garde architecture, and one of the world's most striking urban renewal stories.",
            fullDescription: "Rotterdam reinvented itself after near-total destruction in World War II into one of Europe's most architecturally daring cities. The Erasmus Bridge, Cube Houses, Markthal, and Rotterdam Central Station are icons of Dutch design boldness. Its port handles hundreds of millions of tonnes of cargo annually and connects Europe to global supply chains.",
            history: "Rotterdam received city rights in 1340. Its strategic position on the Rhine-Meuse-Scheldt delta made it a natural trading hub. On 14 May 1940, the Luftwaffe bombed Rotterdam's city center, destroying much of the medieval core. The post-war rebuilding produced a modernist city shaped by experimentation, high-rise architecture, and port expansion.",
            highlights: ["⚓ Port of Rotterdam — Europe's largest seaport", "🌉 Erasmusbrug — cable-stayed bridge nicknamed The Swan", "🏠 Cube Houses — tilted residential cubes by Piet Blom", "🏪 Markthal — market hall with a vast artwork ceiling", "🏗️ Rotterdam Centraal — award-winning station", "🎭 Kunsthal — major art exhibition venue"],
            attractions: [
                Attraction(id: "markthal", name: "Markthal", type: "Market", description: "A horseshoe-shaped market hall with apartments and a monumental ceiling artwork.", openHours: "Mon–Thu 10:00–20:00, Fri–Sat 10:00–21:00, Sun 12:00–18:00", admission: "Free", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Interior%20of%20Markthal%20%28Rotterdam%29.jpg?width=1600"),
                Attraction(id: "kubus", name: "Cube Houses", type: "Architecture", description: "Innovative residential cubes designed by Piet Blom as a village within the city.", openHours: "Show house daily 11:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/De%20besneeuwde%20Oudehaven%20en%20Witte%20Huis%20vanaf%20de%20Kubuswoningen%20%282021%29.jpg?width=1600"),
                Attraction(id: "euromast", name: "Euromast", type: "Landmark", description: "Observation tower overlooking Rotterdam, the Maas, Erasmus Bridge, parks, port edges, and the modern skyline.", openHours: "Daily hours vary", admission: "Varies", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Euromast%20%40%20Erasmus%20Bridge%20%40%20Rotterdam%20%2829930786523%29.jpg?width=1600"),
                Attraction(id: "erasmus", name: "Erasmus Bridge", type: "Landmark", description: "An 808m cable-stayed bridge and the city's best-known modern symbol.", openHours: "Open 24 hours", admission: "Free", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Erasmusbrug%2C%20September%202019.jpg?width=1600")
            ],
            facts: [CityFact(icon: "⚓", label: "Port cargo", value: "469M t/y"), CityFact(icon: "🌍", label: "Port rank", value: "#1 Europe"), CityFact(icon: "🏙️", label: "City rank", value: "#2 NL"), CityFact(icon: "🌈", label: "Diversity", value: "177 nat."), CityFact(icon: "✈️", label: "Airport", value: "RTHA")],
            services: ["Gemeente Rotterdam", "IND Rotterdam", "Sociale Dienst"],
            expat: "Rotterdam has large South Asian, Turkish, Moroccan, and tech communities. Expat Center Rotterdam supports international arrivals.",
            transport: "Rotterdam Centraal serves Intercity, Eurostar, metro lines A-E, trams, buses, and water taxis on the Maas."
        ),
        NLCity(
            id: "den-haag",
            name: "Den Haag",
            province: "Zuid-Holland",
            population: "553,042",
            area: "98.1 km²",
            founded: "13th century",
            postalCode: "2490–2599",
            coordinates: "52.0705° N, 4.3007° E",
            flag: CityFlag(colors: ["#1A5C1A","#FFFFFF"], description: "Groen-wit, gemeentevlag Den Haag (Hert van Holland)", emoji: "🏴", svgStripes: [FlagStripe(color: "#1A5C1A", heightFraction: 0.5), FlagStripe(color: "#FFFFFF", heightFraction: 0.5)]),
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Friedenspalast_Den_Haag.jpg?width=2400",
            heroColor: "#1A2838",
            tagline: "Seat of government — international city of peace and justice",
            shortDescription: "Den Haag is the political capital of the Netherlands, home to Parliament, ministries, royal working palaces, international courts, and Scheveningen beach.",
            fullDescription: "Though Amsterdam is the constitutional capital, The Hague is where the Dutch government works. Parliament, ministries, the Supreme Court, and Royal Palace Noordeinde are located here. The city hosts the International Court of Justice, International Criminal Court, Europol, and many diplomatic missions.",
            history: "The Hague grew around the hunting lodge of Count Floris IV in the 13th century. It became the meeting place of the States General in 1585 and has been the seat of Dutch government ever since. The Hague Peace Conferences of 1899 and 1907 helped establish modern international arbitration, and after World War II the city became a global center of international law.",
            highlights: ["🏛️ Binnenhof — heart of Dutch democracy", "🎨 Mauritshuis — Vermeer's Girl with a Pearl Earring", "⚖️ International Court of Justice", "🏖️ Scheveningen — major North Sea beach resort", "🌿 Madurodam — miniature Netherlands", "👑 Paleis Noordeinde — working royal palace"],
            attractions: [
                Attraction(id: "binnenhof", name: "Binnenhof", type: "Historic Site", description: "Gothic complex that has housed Dutch parliamentary life for centuries.", openHours: "Tours vary during renovation", admission: "Varies", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Den%20Haag%20-%20Buitenhof%20-%20View%20on%20Hofvijver%20%26%20Binnenhof.jpg?width=1600"),
                Attraction(id: "peacepalace", name: "Peace Palace", type: "Landmark", description: "International law landmark housing the International Court of Justice and the Permanent Court of Arbitration.", openHours: "Visitor centre hours vary", admission: "Visitor centre free", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Vredespaleis_Den_Haag.JPG?width=1600"),
                Attraction(id: "scheveningen", name: "Scheveningen Beach", type: "Beach", description: "The Netherlands' best-known seaside district with sand, pier, restaurants, and events.", openHours: "Always open", admission: "Free", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Den%20Haag-Scheveningen%2C%20de%20Pier%20IMG%200095%202021-08-04%2010.46.jpg?width=1600"),
                Attraction(id: "mauritshuis", name: "Mauritshuis", type: "Museum", description: "Royal picture gallery with Vermeer, Rembrandt, and Dutch Golden Age masterpieces.", openHours: "Tue–Sun 10:00–18:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Den%20Haag%20Binnenhof%20Mauritshuis%201.jpg?width=1600")
            ],
            facts: [CityFact(icon: "⚖️", label: "Int'l orgs", value: "200+"), CityFact(icon: "👑", label: "Royalty", value: "Royal seat"), CityFact(icon: "🏖️", label: "Beach", value: "Scheveningen"), CityFact(icon: "🌍", label: "Embassies", value: "150+"), CityFact(icon: "🏛️", label: "Ministries", value: "14")],
            services: ["IND Den Haag", "Gemeente Den Haag", "SVB"],
            expat: "The Hague has one of Europe's strongest diplomatic and legal expat communities, supported by ACCESS and international newcomer networks.",
            transport: "Den Haag Centraal and Den Haag HS connect to Amsterdam, Rotterdam, Utrecht, trams, RandstadRail, and the coast."
        ),
        NLCity.leiden,
        NLCity.utrecht,
        NLCity.groningen,
        NLCity.nijmegen,
        NLCity.arnhem,
        NLCity.maastricht,
        NLCity.eindhoven,
        NLCity.delft,
        NLCity.haarlem
    ]

    static let leiden = NLCity(
        id: "leiden",
        name: "Leiden",
        province: "Zuid-Holland",
        population: "130,862",
        area: "23.6 km²",
        founded: "860 (earliest records)",
        postalCode: "2300–2318",
        coordinates: "52.1601° N, 4.4970° E",
        flag: CityFlag(colors: ["#FFFFFF", "#AE1C28"], description: "Wit met rode balk — Sleutels van Sint Petrus", emoji: "🏴", svgStripes: [FlagStripe(color: "#FFFFFF", heightFraction: 0.5), FlagStripe(color: "#AE1C28", heightFraction: 0.5)]),
        imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Oude%20Vest%20canal%2C%20Leiden%206869.jpg?width=2400",
        heroColor: "#1A3040",
        tagline: "City of keys — oldest university, richest canals",
        shortDescription: "Leiden is a historic student city with the oldest university in the Netherlands, 28 km of canals, and the birthplace of Rembrandt.",
        fullDescription: "Leiden is one of the Netherlands' most beautiful historic cities. Its canal houses, bridges, hidden hofjes, museums, and university culture create a compact city with exceptional cultural depth. Leiden University, founded in 1575 by William of Orange, is the oldest university in the Netherlands and has produced major scientists, artists, and thinkers.",
        history: "Leiden grew as a fortified settlement and cloth-weaving center. Its defining event was the Spanish siege of 1573 to 1574, when the city endured starvation until Dutch forces breached the dikes and sailed in. As a reward, citizens chose a university over tax relief. Rembrandt was born here in 1606, and the Pilgrim Fathers lived in Leiden before sailing to America.",
        highlights: ["🎓 Leiden University — oldest in the Netherlands", "🎨 Birthplace of Rembrandt", "🌿 Hortus Botanicus — historic botanical garden", "🏺 Rijksmuseum van Oudheden", "🍲 3 Oktober Festival", "🚣 28km canals and Molen de Valk"],
        attractions: [
            Attraction(id: "hortusleiden", name: "Hortus Botanicus", type: "Garden", description: "Historic botanical garden with thousands of plant species and university heritage.", openHours: "Daily 10:00–18:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Hortus%20botanicus%20Leiden%20New%20greenhouse.JPG?width=1600"),
            Attraction(id: "devalk", name: "Molen de Valk", type: "Windmill", description: "An 18th-century grain windmill and museum showing miller life and work.", openHours: "Tue–Sat 10:00–17:00, Sun 13:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Leiden%2C%20stellingmolen%20De%20Valk%20RM25655%20IMG%209942%202021-08-02%2015.40.jpg?width=1600"),
            Attraction(id: "oudheden", name: "Rijksmuseum van Oudheden", type: "Museum", description: "National museum of antiquities with Egyptian, Greek, Roman, and Dutch archaeology.", openHours: "Tue–Sun 10:00–17:00", admission: "Check current price", imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Rijksmuseum_van_Oudheden.jpg/1280px-Rijksmuseum_van_Oudheden.jpg")
        ],
        facts: [CityFact(icon: "🎓", label: "Students", value: "30,000"), CityFact(icon: "🌊", label: "Canals", value: "28 km"), CityFact(icon: "🏆", label: "Nobel prizes", value: "16"), CityFact(icon: "🏰", label: "Hofjes", value: "35"), CityFact(icon: "🎨", label: "Rembrandt", value: "Born 1606"), CityFact(icon: "⛵", label: "Mayflower", value: "1609–1620")],
        services: ["Gemeente Leiden", "DUO", "Sociale Dienst", "IND Den Haag nearby"],
        expat: "Leiden has a large international student and academic community. Leiden University supports newcomers with registration, housing, and integration.",
        transport: "Leiden Centraal has direct Intercity service to Amsterdam, The Hague, Rotterdam, Schiphol, and Utrecht."
    )

    static let utrecht = NLCity(
        id: "utrecht",
        name: "Utrecht",
        province: "Utrecht",
        population: "368,580",
        area: "99.3 km²",
        founded: "47 AD (Roman fortress Trajectum)",
        postalCode: "3500–3585",
        coordinates: "52.0907° N, 5.1214° E",
        flag: CityFlag(colors: ["#FFFFFF","#AE1C28","#FFFFFF"], description: "Wit-rood-wit, kruis van Utrecht", emoji: "🏴", svgStripes: [FlagStripe(color: "#FFFFFF", heightFraction: 0.333), FlagStripe(color: "#AE1C28", heightFraction: 0.334), FlagStripe(color: "#FFFFFF", heightFraction: 0.333)]),
        imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Utrecht%2C%20de%20Domtoren%20%28RM36075%29%20vanaf%20de%20Oudegracht%20230%20ongeveer%20foto5%202015-11-01%2008.56.jpg?width=2400",
        heroColor: "#1A2A3A",
        tagline: "Central Netherlands hub — Dom Tower, canal cafés, student energy",
        shortDescription: "Utrecht is the fourth-largest city in the Netherlands and its geographic heart, known for the Dom Tower and unique wharf-level canals.",
        fullDescription: "Utrecht sits near the geographic center of the Netherlands and is one of the country's best-connected cities. Its Oudegracht canal has a distinctive two-level structure, with waterside cellars and terraces below street level. Utrecht University gives the city a youthful academic character, while Dutch Railways and Rabobank anchor its professional economy.",
        history: "Utrecht began as the Roman fortress Trajectum in 47 AD. In the Middle Ages it became the most important ecclesiastical city in the northern Netherlands. The Dom Tower was completed in 1382 and remains the city's icon. The Union of Utrecht, signed in 1579, helped lay the foundation for the Dutch Republic, and the Treaty of Utrecht in 1713 reshaped European politics.",
        highlights: ["⛪ Dom Tower — 112m Gothic tower", "🍽️ Oudegracht — two-level canal terraces", "🎵 TivoliVredenburg music complex", "🌍 Museum Speelklok", "🛤️ Utrecht Centraal rail hub", "🎓 Utrecht University"],
        attractions: [
            Attraction(id: "domtoren", name: "Dom Tower", type: "Monument", description: "The iconic 112m Gothic tower, separated from the church after a 1674 storm.", openHours: "Daily 10:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Domtoren%20Utrecht%20-%201.jpg?width=1600"),
            Attraction(id: "oudegracht", name: "Oudegracht", type: "Canal", description: "The famous two-level canal with lower wharves, restaurants, and historic cellars.", openHours: "Always open", admission: "Free", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/20130401%205%20Utrecht.JPG?width=1600"),
            Attraction(id: "speelklok", name: "Museum Speelklok", type: "Museum", description: "A museum of self-playing musical instruments, from music boxes to fairground organs.", openHours: "Tue–Sun 10:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Wilhelm%20Bruder%20S%C3%B6hne%20-%202%2C%20Museum%20Speelklok.jpg?width=1600")
        ],
        facts: [CityFact(icon: "📍", label: "Location", value: "Center of NL"), CityFact(icon: "🎓", label: "Students", value: "36,000"), CityFact(icon: "🏙️", label: "Rank", value: "#4"), CityFact(icon: "🛤️", label: "Rail hub", value: "Busiest station"), CityFact(icon: "⛪", label: "Dom Tower", value: "112m"), CityFact(icon: "📜", label: "Roman", value: "47 AD")],
        services: ["Gemeente Utrecht", "IND Utrecht", "DUO", "Belastingdienst Utrecht"],
        expat: "Utrecht has a growing expat community driven by the university, health, rail, and technology sectors.",
        transport: "Utrecht Centraal is the largest Dutch rail hub, with direct trains to all major cities and tram lines to the region."
    )

    static let groningen = NLCity(
        id: "groningen",
        name: "Groningen",
        province: "Groningen",
        population: "238,147",
        area: "197.9 km²",
        founded: "c. 1040",
        postalCode: "9700–9778",
        coordinates: "53.2194° N, 6.5665° E",
        flag: CityFlag(colors: ["#FFFFFF", "#AE1C28"], description: "Wit-rode vlag van de stad Groningen", emoji: "🏴", svgStripes: [FlagStripe(color: "#FFFFFF", heightFraction: 0.5), FlagStripe(color: "#AE1C28", heightFraction: 0.5)]),
        imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/20100523%20Grote%20Markt%20en%20Martinitoren%20Groningen%20NL.jpg?width=2400",
        heroColor: "#1A2830",
        tagline: "Capital of the north — student city with gas-field heritage",
        shortDescription: "Groningen is the cultural and economic capital of northern Netherlands, known for students, the Martinitoren, and a complicated gas extraction legacy.",
        fullDescription: "Groningen is the largest city in the northern Netherlands and has one of the youngest populations in the country. The University of Groningen and Hanze University create a lively student culture, while the surrounding province carries the legacy of the Groningen gas field and earthquake damage that reshaped Dutch energy policy.",
        history: "Groningen grew from a mound settlement into a dominant northern trading city and joined the Hanseatic League in 1284. The Martinitoren, completed in 1482, became a landmark visible across the flat landscape. In April 1945, Canadian forces liberated Groningen after intense urban fighting. In the modern era, gas extraction brought wealth but also earthquakes and social conflict.",
        highlights: ["⛪ Martinitoren — 97m northern landmark", "🏫 Major student city", "🌊 Wadden Sea coast nearby", "🔬 UMCG research hospital", "🎵 Eurosonic Noorderslag", "🏛️ Groninger Museum"],
        attractions: [
            Attraction(id: "martinitoren", name: "Martinitoren", type: "Monument", description: "Gothic tower from 1482 with panoramic views over the northern landscape.", openHours: "Daily 12:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/20140621%20Martinitoren%20en%20Mutua%20Fides%20%28soci%C3%ABteit%20Vindicat%29%20Grote%20Markt%20Groningen%20NL.jpg?width=1600"),
            Attraction(id: "groningermuseum", name: "Groninger Museum", type: "Museum", description: "Postmodern museum with international exhibitions and a bold building by Alessandro Mendini.", openHours: "Tue–Sun 10:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/20151009%20Groninger%20Museum.jpg?width=1600")
        ],
        facts: [CityFact(icon: "🎓", label: "Students", value: "57,000"), CityFact(icon: "⛽", label: "Gas field", value: "Closed 2023"), CityFact(icon: "⛪", label: "Tower", value: "97m"), CityFact(icon: "🌊", label: "Wadden Sea", value: "UNESCO"), CityFact(icon: "🇨🇦", label: "Liberation", value: "April 1945")],
        services: ["Gemeente Groningen", "IND Noord-Nederland", "DUO headquarters"],
        expat: "Groningen's international community is strongest around the University of Groningen, Hanze, UMCG, and DUO.",
        transport: "Station Groningen connects to Amsterdam, Leeuwarden, Assen, Zwolle, regional buses, and northern cycling routes."
    )

    static let nijmegen = NLCity(
        id: "nijmegen",
        name: "Nijmegen",
        province: "Gelderland",
        population: "179,662",
        area: "57.6 km²",
        founded: "19 BC (Roman Noviomagus)",
        postalCode: "6500–6546",
        coordinates: "51.8426° N, 5.8528° E",
        flag: CityFlag(colors: ["#AE1C28", "#F5D020"], description: "Rood-geel, kleuren van Nijmegen", emoji: "🏴", svgStripes: [FlagStripe(color: "#AE1C28", heightFraction: 0.5), FlagStripe(color: "#F5D020", heightFraction: 0.5)]),
        imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Nijmegen%20Waalbrug%20R01.jpg?width=2400",
        heroColor: "#1A2410",
        tagline: "Oudste stad van Nederland — 2,000 jaar geschiedenis",
        shortDescription: "Nijmegen is de oudste stad van Nederland, gesticht door de Romeinen in 19 v.Chr. De universiteit, de Vierdaagse en het Valkhof maken de stad uniek.",
        fullDescription: """
        Nijmegen is the oldest city in the Netherlands, founded as a Roman military camp Noviomagus Batavorum in 19 BC. The Valkhof hill has seen Roman emperors, Charlemagne, and medieval dukes, all leaving their mark in stone.

        Today Nijmegen is a vibrant student city with 43,000 students at Radboud University, consistently ranked among the healthiest and greenest cities in the Netherlands. The annual Vierdaagse, the world's largest walking event, attracts 47,000 participants from 70+ countries each July.
        """,
        history: "Founded 19 BC by the Romans as Noviomagus. Charlemagne built his palace here in the 8th century; the Valkhof chapel still stands. During WWII, Nijmegen was accidentally bombed by American aircraft in 1944, killing 800 civilians. The Waalbrug was a key objective in Operation Market Garden.",
        highlights: ["🏛️ Valkhof Museum — Roman artifacts and Charlemagne's chapel", "🚶 Vierdaagse — world's largest walking event (47,000 participants)", "🎓 Radboud University — 43,000 students, top medical research", "🌊 Waal river — widest river in NL, beautiful quayside", "🏰 Oldest city in NL — 2,000+ years of continuous habitation", "🌿 Consistently voted greenest city in the Netherlands"],
        attractions: [
            Attraction(id: "valkhof-museum", name: "Museum Het Valkhof", type: "Museum", description: "Roman artifacts and medieval history on Charlemagne's hill. Chapel dating to 1010 AD.", openHours: "Tue–Sun 11:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Museum%20Het%20Valkhof%20Nijmegen.JPG?width=1600"),
            Attraction(id: "waalbrug", name: "Waalbrug", type: "Landmark", description: "The famous arch bridge over the Waal river, opened in 1936 and central to the city's skyline.", openHours: "Always open", admission: "Free", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Nijmegen%20Waalbrug%20R03.jpg?width=1600"),
            Attraction(id: "valkhof-park", name: "Valkhof Park", type: "Historic Park", description: "Historic hilltop park with Roman and medieval remains overlooking the Waal.", openHours: "Always open", admission: "Free", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/De%20St.%20Nicolaaskapel%20in%20het%20Valkhofpark%20te%20Nijmegen%20gezien%20van%20de%20zuidwestzijde%20-%20Nijmegen%20-%2020383615%20-%20RCE.jpg?width=1600")
        ],
        facts: [CityFact(icon: "📅", label: "Founded", value: "19 BC"), CityFact(icon: "🎓", label: "Students", value: "43,000"), CityFact(icon: "🚶", label: "Vierdaagse", value: "47k/July"), CityFact(icon: "🏛️", label: "Age", value: "2,000+ years"), CityFact(icon: "🌿", label: "Green rank", value: "#1 NL"), CityFact(icon: "📍", label: "Province", value: "Gelderland")],
        services: ["Gemeente Nijmegen", "Radboud University Services", "IND Arnhem (nearby)"],
        expat: "Growing international community driven by Radboud University. International Welcome Center at the university.",
        transport: "Nijmegen station — IC to Utrecht (50 min), Arnhem (15 min), Den Bosch (30 min)."
    )

    static let arnhem = NLCity(
        id: "arnhem",
        name: "Arnhem",
        province: "Gelderland",
        population: "163,506",
        area: "100.5 km²",
        founded: "c. 893",
        postalCode: "6800–6846",
        coordinates: "51.9851° N, 5.8987° E",
        flag: CityFlag(colors: ["#F5D020", "#000000"], description: "Geel-zwart, kleuren van Arnhem", emoji: "🏴", svgStripes: [FlagStripe(color: "#F5D020", heightFraction: 0.5), FlagStripe(color: "#000000", heightFraction: 0.5)]),
        imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Arnhem_John_Frost_Bridge.jpg?width=2400",
        heroColor: "#1A1A0A",
        tagline: "'A Bridge Too Far' — WWII history and national parks",
        shortDescription: "Arnhem is famous for the Battle of Arnhem (1944) and the John Frost Bridge, plus access to De Hoge Veluwe, the largest national park in the Netherlands.",
        fullDescription: """
        Arnhem sits on the Rhine where it splits into two branches, giving it strategic importance throughout history. The city was largely destroyed during WWII and almost entirely rebuilt post-war. The Airborne Museum in Oosterbeek tells the story of Operation Market Garden with original artifacts.

        De Hoge Veluwe national park, 5km from the city center, is the largest national park in the Netherlands and home to the Kröller-Müller Museum, the second-largest Van Gogh collection in the world.
        """,
        history: "The Battle of Arnhem (September 17-26, 1944) was the largest airborne operation in history. British paratroopers of the 1st Airborne Division were tasked with holding the bridge over the Rhine, now John Frost Bridge. Outnumbered by two SS Panzer divisions, they held for 9 days. Of 10,000 paratroopers who landed, only 2,163 escaped. The film 'A Bridge Too Far' (1977) dramatized the battle.",
        highlights: ["🌉 John Frost Bridge — site of WWII battle 'A Bridge Too Far'", "🌲 De Hoge Veluwe — largest NL national park, free bicycles inside", "🎨 Kröller-Müller Museum — 2nd largest Van Gogh collection worldwide", "🪖 Airborne Museum Oosterbeek — WWII airborne operation history", "🦌 Veluwe wildlife — red deer, wild boar, mouflon sheep", "🚴 Free white bicycles in De Hoge Veluwe — 40km of paths"],
        attractions: [
            Attraction(id: "john-frost-bridge", name: "John Frost Bridge", type: "Landmark", description: "The Rhine bridge central to the 1944 Battle of Arnhem and one of the city's defining symbols.", openHours: "Always open", admission: "Free", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/John%20Frost%20Bridge%2C%20September%202019%2C%20Arnhem%207.jpg?width=1600"),
            Attraction(id: "hoge-veluwe", name: "De Hoge Veluwe National Park", type: "National Park", description: "5,400 hectares of dunes, forest and heath. Free white bicycles. Kröller-Müller museum inside.", openHours: "Daily 8:00-sunset (varies by season)", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/White%20bikes%20in%20De%20Hoge%20Veluwe%20%E2%80%94%202024-07-09%2012.55.32.jpg?width=1600"),
            Attraction(id: "kroller-muller", name: "Kröller-Müller Museum", type: "Museum", description: "91 Van Gogh paintings plus Mondrian, Seurat, Picasso. Inside De Hoge Veluwe park.", openHours: "Tue–Sun 10:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Entrance%20Kr%C3%B6ller-M%C3%BCller%20Museum.JPG?width=1600")
        ],
        facts: [CityFact(icon: "🪖", label: "WWII battle", value: "9 days"), CityFact(icon: "🌲", label: "National park", value: "5,400 ha"), CityFact(icon: "🎨", label: "Van Gogh", value: "91 paintings"), CityFact(icon: "🦌", label: "Wildlife", value: "Deer, boar"), CityFact(icon: "🚴", label: "Free bikes", value: "Included"), CityFact(icon: "🏆", label: "Films", value: "A Bridge Too Far")],
        services: ["Gemeente Arnhem", "IND Arnhem (regional office)"],
        expat: "Quiet, affordable expat destination. Close to German border; some expats work in Germany and live in Arnhem for lower costs.",
        transport: "Arnhem Centraal — IC to Utrecht (50 min), Nijmegen (15 min). Bus to De Hoge Veluwe."
    )

    static let maastricht = NLCity(
        id: "maastricht",
        name: "Maastricht",
        province: "Limburg",
        population: "121,469",
        area: "60.0 km²",
        founded: "50 AD (Roman settlement)",
        postalCode: "6200–6229",
        coordinates: "50.8514° N, 5.6910° E",
        flag: CityFlag(colors: ["#AE1C28", "#FFFFFF", "#F5D020"], description: "Rood-wit-geel, kleuren van Maastricht", emoji: "🏴", svgStripes: [FlagStripe(color: "#AE1C28", heightFraction: 0.333), FlagStripe(color: "#FFFFFF", heightFraction: 0.334), FlagStripe(color: "#F5D020", heightFraction: 0.333)]),
        imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/2022_Magisch_Maastricht_%2801%29.jpg?width=2400",
        heroColor: "#2A1A0A",
        tagline: "Southern gem — Roman history, European treaties, Carnival capital",
        shortDescription: "Maastricht is the southernmost major Dutch city, a Roman crossroads on the Maas and the signing place of the Maastricht Treaty.",
        fullDescription: "Maastricht has a southern character shaped by Belgium, Germany, Roman Catholic heritage, café terraces, wine culture, and a long border history. Its old streets show Roman, medieval, early modern, and European layers. Maastricht University is among the most international universities in the Netherlands.",
        history: "Maastricht began as Roman Mosae Trajectum around 50 AD. Its strategic crossing on the Maas made it repeatedly contested by Spanish, French, Belgian, and Dutch powers. Saint Servatius anchored its early Christian importance. On 7 February 1992, the Maastricht Treaty was signed here, creating the European Union framework, EU citizenship, and the path to the euro.",
        highlights: ["📜 Maastricht Treaty — EU and euro framework", "⛪ Basilica of Saint Servatius", "🎭 Carnival", "🗿 Caves of Saint Peter", "🎓 Maastricht University", "🍷 Burgundian terraces and cuisine"],
        attractions: [
            Attraction(id: "vrijthof", name: "Vrijthof Square", type: "Public Square", description: "The heart of Maastricht, flanked by basilicas and lined with café terraces.", openHours: "Always open", admission: "Free", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Montage%20Maastricht%20Vrijthof.jpg?width=1600"),
            Attraction(id: "servatius", name: "Basilica of St. Servatius", type: "Church", description: "One of the Netherlands' oldest churches, containing relics of Saint Servatius.", openHours: "Mon–Sat 10:00–17:00, Sun 12:30–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Maastricht%20Sint-Servaasbasiliek%20BW%202017-08-19%2011-39-13.jpg?width=1600"),
            Attraction(id: "dominicanen", name: "Dominicanen Bookstore", type: "Cultural", description: "A 13th-century Dominican church converted into a celebrated bookstore.", openHours: "Mon–Sat 10:00–18:00, Sun 12:00–18:00", admission: "Free", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Bookshop%20Dominican%20Church%2C%20Maastricht%2C%20Netherlands%20-%20panoramio%20%284%29.jpg?width=1600")
        ],
        facts: [CityFact(icon: "📜", label: "EU Treaty", value: "1992"), CityFact(icon: "🏛️", label: "Roman", value: "50 AD"), CityFact(icon: "🎓", label: "University", value: "60% intl."), CityFact(icon: "⛪", label: "Basilica", value: "Oldest heritage"), CityFact(icon: "🗺️", label: "Borders", value: "BE + DE")],
        services: ["Gemeente Maastricht", "IND Eindhoven nearby", "Maastricht University services"],
        expat: "Maastricht is very international due to the university, EU history, and cross-border location.",
        transport: "Maastricht station connects to Eindhoven, Liège, Brussels routes, Aachen buses, and Limburg regional transit."
    )

    static let eindhoven = NLCity(
        id: "eindhoven",
        name: "Eindhoven",
        province: "Noord-Brabant",
        population: "240,957",
        area: "88.8 km²",
        founded: "1232",
        postalCode: "5600–5658",
        coordinates: "51.4416° N, 5.4697° E",
        flag: CityFlag(colors: ["#AE1C28", "#FFFFFF"], description: "Red and white municipal flag derived from the city arms", emoji: "🏴", svgStripes: [FlagStripe(color: "#AE1C28", heightFraction: 0.5), FlagStripe(color: "#FFFFFF", heightFraction: 0.5)]),
        imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Eindhoven-Witte%20Dame%20%285%29.jpg?width=2400",
        heroColor: "#1A1A2A",
        tagline: "City of Light and Technology — Philips, ASML, Dutch Design capital",
        shortDescription: "Eindhoven is the technology and design capital of the Netherlands, birthplace of Philips and core city of Brainport.",
        fullDescription: "Eindhoven grew from a small Brabant market town into a global technology hub through Philips and later ASML. The Brainport region is central to the semiconductor supply chain, design education, and high-tech manufacturing. Dutch Design Week and the Design Academy give the city a distinctive creative identity.",
        history: "Eindhoven received city rights in 1232 but remained modest until Philips was founded in 1891. Philips turned the city into an industrial center and shaped housing, culture, and research. Eindhoven was liberated on 18 September 1944 during Operation Market Garden. Post-war investment in technology and design led to TU/e, Design Academy Eindhoven, and the high-tech ecosystem around ASML.",
        highlights: ["💡 Philips Museum", "🔬 ASML and Brainport", "🎨 Dutch Design Week", "🏟️ PSV Eindhoven", "🌐 High Tech Campus", "🏛️ Van Abbe Museum"],
        attractions: [
            Attraction(id: "philipsmuseum", name: "Philips Museum", type: "Museum", description: "The story of Philips from light bulbs to global electronics and consumer technology.", openHours: "Tue–Sun 11:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Philips%20Museum%20werkplaats%20%282025%29%20%281%29.jpg?width=1600"),
            Attraction(id: "evoluon", name: "Evoluon", type: "Architecture", description: "A flying-saucer-shaped conference center built by Philips in 1966.", openHours: "Event-dependent", admission: "Varies", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Cmglee%20Evoluon%20side.jpg?width=1600"),
            Attraction(id: "vanabbe", name: "Van Abbe Museum", type: "Museum", description: "A major modern and contemporary art museum with an influential collection.", openHours: "Tue–Sun 11:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Uitbreiding%20Van%20Abbemuseum.jpg?width=1600")
        ],
        facts: [CityFact(icon: "💡", label: "Philips", value: "Est. 1891"), CityFact(icon: "🔬", label: "ASML", value: "EU leader"), CityFact(icon: "🎓", label: "TU/e", value: "TU/e"), CityFact(icon: "🏆", label: "Design Week", value: "350k visitors"), CityFact(icon: "⚽", label: "Football", value: "PSV"), CityFact(icon: "🔑", label: "Patents", value: "Brainport")],
        services: ["Gemeente Eindhoven", "IND Eindhoven", "UWV Eindhoven", "Belastingdienst"],
        expat: "Eindhoven has a large ASML, Philips, university, and high-tech expat community supported by Expat Center Brainport.",
        transport: "Eindhoven station connects to Amsterdam, Venlo, The Hague, Maastricht, and Eindhoven Airport."
    )

    static let delft = NLCity(
        id: "delft",
        name: "Delft",
        province: "Zuid-Holland",
        population: "103,163",
        area: "24.0 km²",
        founded: "1246",
        postalCode: "2600–2629",
        coordinates: "52.0116° N, 4.3571° E",
        flag: CityFlag(colors: ["#F5A623", "#FFFFFF"], description: "Gold and white, Delft city colors", emoji: "🏴", svgStripes: [FlagStripe(color: "#F5A623", heightFraction: 0.5), FlagStripe(color: "#FFFFFF", heightFraction: 0.5)]),
        imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Delft_Markt_overlooking_Nieuwe_Kerk.jpg?width=2400",
        heroColor: "#2A1A10",
        tagline: "City of Vermeer, Delft Blue pottery and the royal mausoleum",
        shortDescription: "Delft is famous for its blue-and-white Delftware pottery, as the birthplace of painter Johannes Vermeer, and as home to the Dutch royal tombs in the Nieuwe Kerk.",
        fullDescription: "Delft is one of the most picturesque Dutch cities — compact, walkable, and full of 17th-century canal houses. The Nieuwe Kerk (New Church, 1381) contains the tombs of the entire Dutch royal family including William of Orange, the founder of the Netherlands. Delft University of Technology (TU Delft), founded 1842, is the largest technical university in the Netherlands and one of the best in Europe for engineering and architecture.",
        history: "Delft received city rights in 1246 and grew as a cloth and beer trading center. William of Orange — the father of the Dutch nation — was assassinated here in 1584 in the Prinsenhof (now a museum). The building still bears the bullet holes in its walls. Johannes Vermeer (1632–1675), born in Delft, painted his masterpieces here including Girl with a Pearl Earring and View of Delft. Royal Delft (De Porceleyne Fles), founded 1653, is the only remaining authentic Delftware factory.",
        highlights: ["🎨 Vermeer Centrum — birthplace of Girl with a Pearl Earring painter", "⛪ Nieuwe Kerk — royal tombs of all Dutch monarchs since William of Orange", "🔫 Prinsenhof Museum — bullet holes still visible from 1584 assassination", "💙 Royal Delft factory — only authentic Delftware pottery (1653)", "🎓 TU Delft — top engineering university in Europe", "🚂 12 km to Den Haag, 12 km to Rotterdam"],
        attractions: [
            Attraction(id: "nieuwe-kerk-delft", name: "Nieuwe Kerk", type: "Church", description: "Royal mausoleum since 1584. 109m tower with panoramic view over Delft.", openHours: "Mon–Sat 10:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/De%20Nieuwe%20Kerk%20en%20omgeving%20vanaf%20de%20Markt%20%282021%29.jpg?width=1600"),
            Attraction(id: "royal-delft", name: "Royal Delft", type: "Factory", description: "Only original Delftware factory from 1653. Watch hand-painters at work.", openHours: "Daily 9:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Digital%20Delft%20Blue%20Painting%20Robot%20in%20Royal%20Delft%202024-12-02.jpg?width=1600"),
            Attraction(id: "prinsenhof-delft", name: "Prinsenhof Museum", type: "Museum", description: "Site of William of Orange's assassination in 1584. Bullet holes still visible.", openHours: "Tue–Sun 10:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Museum%20Prinsenhof%20Delft%20-%20Offici%C3%ABle%20sluiting%2006-01-2025%2001.jpg?width=1600")
        ],
        facts: [CityFact(icon: "🎨", label: "Vermeer", value: "Born 1632"), CityFact(icon: "💙", label: "Delftware", value: "Since 1653"), CityFact(icon: "⛪", label: "Royal tombs", value: "All kings"), CityFact(icon: "🎓", label: "TU Delft", value: "Top EU tech"), CityFact(icon: "🚂", label: "Den Haag", value: "10 min"), CityFact(icon: "🏛️", label: "Founded", value: "1246")],
        services: ["Gemeente Delft", "IND Den Haag (nearby)", "TU Delft International Office"],
        expat: "Large student and academic expat community. TU Delft has 6,000 international students. Close to Den Haag expat services.",
        transport: "Delft station — IC to Rotterdam (12 min), Den Haag (10 min), Amsterdam (1h). New Delft tunnel opened 2015."
    )

    static let haarlem = NLCity(
        id: "haarlem",
        name: "Haarlem",
        province: "Noord-Holland",
        population: "164,024",
        area: "36.1 km²",
        founded: "c. 1245",
        postalCode: "2000–2049",
        coordinates: "52.3873° N, 4.6462° E",
        flag: CityFlag(colors: ["#AE1C28", "#FFFFFF"], description: "Red and white, Haarlem city colors", emoji: "🏴", svgStripes: [FlagStripe(color: "#AE1C28", heightFraction: 0.5), FlagStripe(color: "#FFFFFF", heightFraction: 0.5)]),
        imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Zijlstrat%20Grote%20Markt%20Haarlem.jpg?width=2400",
        heroColor: "#1A1020",
        tagline: "Gateway to the tulip fields — Frans Hals, Grote Kerk, and the Bollenstreek",
        shortDescription: "Haarlem is a beautiful medieval city 20 minutes from Amsterdam, famous for the Frans Hals Museum, the Grote Kerk, and its position at the heart of the Bollenstreek tulip-growing region.",
        fullDescription: "Haarlem was once one of the most important cities in Holland, serving as the regional capital. Its well-preserved medieval center, with the towering Sint-Bavokerk (Grote Kerk) dominating the Grote Markt, gives it a character distinct from Amsterdam. The city is surrounded by the Bollenstreek (bulb district) — fields of tulips, daffodils and hyacinths that bloom spectacularly each spring, drawing visitors from around the world to Keukenhof.",
        history: "Haarlem received city rights around 1245 and became a significant trading and textile city. It was besieged by Spanish forces for seven months in 1572–73 during the Dutch Revolt. Frans Hals (1582–1666) developed a new style of portraiture here, capturing the energy and character of his subjects with loose brushstrokes. The Teylers Museum (1784) — the oldest museum in the Netherlands — is located in Haarlem.",
        highlights: ["🌷 Bollenstreek — tulip fields and Keukenhof (7 million bulbs) nearby", "🎨 Frans Hals Museum — Dutch Golden Age portraiture in an authentic almshouse", "⛪ Sint-Bavokerk — 15th-century Gothic cathedral, Mozart played organ here age 10", "🏛️ Teylers Museum (1784) — oldest museum in Netherlands", "🏖️ Zandvoort aan Zee — F1 Dutch Grand Prix circuit, 10 min by train", "🚂 20 min from Amsterdam Centraal"],
        attractions: [
            Attraction(id: "franshals", name: "Frans Hals Museum", type: "Museum", description: "17th-century Dutch Golden Age portraits in an authentic hofje (almshouse).", openHours: "Tue–Sat 11:00–17:00, Sun 12:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Courtyard-main%20gate-oudemannenhuis%20haarlem.JPG?width=1600"),
            Attraction(id: "teylers", name: "Teylers Museum", type: "Museum", description: "The oldest museum in the Netherlands (1784) with natural history, art, and science.", openHours: "Tue–Sun 10:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Wybrand%20Hendriks%2C%20De%20Ovale%20Zaal%20van%20Teylers%20Museum%2C%20c.%201800-1820..jpg?width=1600"),
            Attraction(id: "grotekerk", name: "Sint-Bavokerk", type: "Church", description: "Gothic cathedral from the 15th century with a famous Müller organ that Mozart played at age 10.", openHours: "Mon–Sat 10:00–17:00", admission: "Check current price", imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Hoofdorgel%20van%20de%20Grote%20of%20Sint-Bavokerk%20in%20Haarlem.jpg?width=1600")
        ],
        facts: [CityFact(icon: "🌷", label: "Tulip fields", value: "Bollenstreek"), CityFact(icon: "🎨", label: "Frans Hals", value: "Lived here"), CityFact(icon: "🚂", label: "Amsterdam", value: "20 min"), CityFact(icon: "🏛️", label: "Teylers", value: "Since 1784"), CityFact(icon: "⛪", label: "Grote Kerk", value: "15th c. Gothic"), CityFact(icon: "🏖️", label: "Zandvoort", value: "F1 10 min")],
        services: ["Gemeente Haarlem", "IND Haarlem", "UWV Haarlem"],
        expat: "Popular with Amsterdam expats due to lower rents and good train connection. Expat Center Amsterdam also serves Haarlem residents.",
        transport: "Haarlem station — direct to Amsterdam Centraal (20 min), Leiden (30 min), Den Haag (40 min)."
    )
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        let alpha: UInt64

        switch cleaned.count {
        case 3:
            red = (value >> 8) * 17
            green = ((value >> 4) & 0xF) * 17
            blue = (value & 0xF) * 17
            alpha = 255
        case 6:
            red = value >> 16
            green = (value >> 8) & 0xFF
            blue = value & 0xFF
            alpha = 255
        case 8:
            red = value >> 24
            green = (value >> 16) & 0xFF
            blue = (value >> 8) & 0xFF
            alpha = value & 0xFF
        default:
            red = 255
            green = 255
            blue = 255
            alpha = 255
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

enum NetherlandsEntityKind: String, CaseIterable, Codable, Hashable {
    case country
    case province
    case city
    case district
    case place
    case attraction
    case museum
    case park
    case restaurant
    case cafe
    case hotel
    case governmentService
    case healthcare
    case university
    case transport
    case localPartner
    case officialSource
    case knowledgeTopic
    case checklist
    case event
}

struct NetherlandsDataCoordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}

struct NetherlandsVisualSet: Codable {
    let hero: AppImageAsset?
    let gallery: [AppImageAsset]
    let thumbnail: AppImageAsset?
    let mapPreview: AppImageAsset?
    let categoryCover: AppImageAsset?

    var allImages: [AppImageAsset] {
        [hero, thumbnail, mapPreview, categoryCover].compactMap { $0 } + gallery
    }
}

struct NetherlandsKnowledgeEntity: Identifiable {
    let id: String
    let kind: NetherlandsEntityKind
    let title: String
    let summary: String
    let cityId: String?
    let provinceId: String?
    let category: String
    let coordinate: NetherlandsDataCoordinate?
    let source: OfficialSource?
    let lastChecked: String
    let images: NetherlandsVisualSet
    let aiSummary: String
    let relatedEntityIDs: [String]
    let route: AppDestination?
    let attributes: [String: String]
    let keywords: [String]
}

struct NetherlandsKnowledgeDatabaseReport {
    let cities: Int
    let places: Int
    let governmentServices: Int
    let localPartners: Int
    let museums: Int
    let restaurants: Int
    let hotels: Int
    let officialSources: Int
    let linkedImages: Int
    let relations: Int

    var lines: [String] {
        [
            "Cities: \(cities)",
            "Places: \(places)",
            "Government Services: \(governmentServices)",
            "Local Partners: \(localPartners)",
            "Museums: \(museums)",
            "Restaurants: \(restaurants)",
            "Hotels: \(hotels)",
            "Official Sources: \(officialSources)",
            "Linked Images: \(linkedImages)",
            "Knowledge Graph Relations: \(relations)"
        ]
    }
}

struct NetherlandsKnowledgeDatabase {
    static let shared = NetherlandsKnowledgeDatabase.build()

    let entities: [NetherlandsKnowledgeEntity]
    let relations: [KnowledgeRelation]

    private let entitiesByID: [String: NetherlandsKnowledgeEntity]

    init(entities: [NetherlandsKnowledgeEntity], relations: [KnowledgeRelation]) {
        var seen = Set<String>()
        let uniqueEntities = entities.filter { seen.insert($0.id).inserted }
        self.entities = uniqueEntities
        self.entitiesByID = Dictionary(uniqueKeysWithValues: uniqueEntities.map { ($0.id, $0) })

        var seenRelations = Set<String>()
        self.relations = relations.filter { relation in
            seenRelations.insert("\(relation.fromID)|\(relation.toID)|\(relation.type.rawValue)").inserted
        }
    }

    func entity(id: String) -> NetherlandsKnowledgeEntity? {
        entitiesByID[id]
    }

    func entities(kind: NetherlandsEntityKind) -> [NetherlandsKnowledgeEntity] {
        entities.filter { $0.kind == kind }
    }

    func entities(cityId: String) -> [NetherlandsKnowledgeEntity] {
        entities.filter { $0.cityId?.caseInsensitiveCompare(cityId) == .orderedSame }
    }

    func knowledgeItems() -> [KnowledgeItem] {
        entities.map { entity in
            KnowledgeItem(
                id: entity.knowledgeItemID,
                type: entity.knowledgeItemType,
                title: LocalizedKnowledgeText(entity.title),
                summary: LocalizedKnowledgeText(entity.aiSummary.isEmpty ? entity.summary : entity.aiSummary),
                category: entity.category,
                city: entity.cityId,
                province: entity.provinceId,
                keywords: entity.searchKeywords,
                route: entity.route,
                routeID: entity.route.flatMap(AppNavigationResolver.routeID(from:)),
                sources: entity.source.map { [$0] } ?? [],
                lastReviewed: nil,
                safetyLevel: entity.source == nil ? .general : .officialSourceRecommended,
                sourcePath: "YouNew/Data/NetherlandsData.swift",
                personaTags: entity.personaTags
            )
        }
    }

    var report: NetherlandsKnowledgeDatabaseReport {
        NetherlandsKnowledgeDatabaseReport(
            cities: entities(kind: .city).count,
            places: entities.filter { [.place, .attraction, .museum, .park, .restaurant, .cafe, .hotel, .healthcare, .transport, .university].contains($0.kind) }.count,
            governmentServices: entities(kind: .governmentService).count,
            localPartners: entities(kind: .localPartner).count,
            museums: entities(kind: .museum).count,
            restaurants: entities(kind: .restaurant).count,
            hotels: entities(kind: .hotel).count,
            officialSources: entities(kind: .officialSource).count,
            linkedImages: entities.reduce(0) { $0 + $1.images.allImages.count },
            relations: relations.count
        )
    }

    private static func build() -> NetherlandsKnowledgeDatabase {
        var entities: [NetherlandsKnowledgeEntity] = []
        var relations: [KnowledgeRelation] = []

        entities.append(countryEntity())
        entities += officialSourceEntities()
        entities += provinceEntities()
        entities += cityEntities()
        entities += attractionEntities()
        entities += dashboardPlaceEntities()
        entities += nearbyPlaceEntities()
        entities += institutionEntities()
        entities += localPartnerEntities()
        entities += calendarEventEntities()
        entities += coreKnowledgeTopicEntities()

        relations += buildRelations(for: entities)
        return NetherlandsKnowledgeDatabase(entities: entities, relations: relations)
    }

    private static func countryEntity() -> NetherlandsKnowledgeEntity {
        entity(
            id: "country:nl",
            kind: .country,
            title: NetherlandsCountry.name,
            summary: NetherlandsCountry.tagline,
            category: "country",
            source: officialSource(title: "CBS", url: "https://www.cbs.nl/en-gb", institution: "Statistics Netherlands"),
            lastChecked: "2026-07-05",
            images: visualSet(
                id: "country:nl",
                title: "Netherlands map",
                url: nil,
                localAssetName: "netherlands_map_base",
                category: .province
            ),
            aiSummary: "Country-level profile used as the root for provinces, cities, services, places, partners, events, and newcomer knowledge.",
            relatedEntityIDs: NLProvince.all.map { "province:\(KnowledgeNormalizer.slug($0.id))" },
            route: .informationHub,
            attributes: [
                "population": NetherlandsCountry.population,
                "capital": NetherlandsCountry.capital,
                "government": NetherlandsCountry.government,
                "timezone": NetherlandsCountry.timezone,
                "currency": NetherlandsCountry.currency
            ],
            keywords: ["Netherlands", "Nederland", "country", "provinces", "cities", "government", "CBS"]
        )
    }

    private static func officialSourceEntities() -> [NetherlandsKnowledgeEntity] {
        [
            officialSourceEntity("source:government-nl", "Government.nl", "Official English-language government information for national rules and public services.", "https://www.government.nl"),
            officialSourceEntity("source:government-brp", "Government.nl BRP", "Official information about the Personal Records Database (BRP), municipalities, residents, non-residents, and BSN registration context.", "https://www.government.nl/themes/government-and-democracy/personal-data/personal-records-database-brp"),
            officialSourceEntity("source:cbs", "CBS", "Statistics Netherlands: official statistics, StatLine, regional and population figures.", "https://www.cbs.nl/en-gb"),
            officialSourceEntity("source:ind", "IND", "Immigration and Naturalisation Service: residence permits, appointments, status, forms, and brochures.", "https://ind.nl/en"),
            officialSourceEntity("source:duo", "DUO", "Education Executive Agency: student finance, tuition, diplomas, and education administration.", "https://www.duo.nl"),
            officialSourceEntity("source:belastingdienst", "Belastingdienst", "Dutch Tax Administration: taxes, allowances, tax letters, and official payment routes.", "https://www.belastingdienst.nl"),
            officialSourceEntity("source:uwv", "UWV", "Employee insurance and employment-support agency for work-related benefits and job transitions.", "https://www.uwv.nl"),
            officialSourceEntity("source:svb", "SVB", "Social Insurance Bank for national insurance schemes such as child benefit and state pension.", "https://www.svb.nl"),
            officialSourceEntity("source:politie", "Politie", "Official Dutch police information and non-emergency reporting routes.", "https://www.politie.nl"),
            officialSourceEntity("source:ns", "NS", "Dutch railway operator for national train travel information.", "https://www.ns.nl/en"),
            officialSourceEntity("source:9292", "9292", "Public transport journey planner for train, tram, bus, metro, and ferry routes.", "https://9292.nl/en"),
            officialSourceEntity("source:ovpay", "OVpay", "Official public transport check-in and payment information.", "https://www.ovpay.nl/en")
        ]
    }

    private static func provinceEntities() -> [NetherlandsKnowledgeEntity] {
        NLProvince.all.map { province in
            entity(
                id: "province:\(KnowledgeNormalizer.slug(province.id))",
                kind: .province,
                title: province.nameEN,
                summary: province.description,
                provinceId: province.id,
                category: "province",
                source: officialSource(title: "CBS", url: "https://www.cbs.nl/en-gb", institution: "Statistics Netherlands"),
                lastChecked: "2026-07-05",
                images: visualSet(
                    id: "province:\(province.id)",
                    title: province.nameEN,
                    url: province.imageURL,
                    localAssetName: nil,
                    category: .province
                ),
                aiSummary: "\(province.nameEN) contains \(province.cityCount) municipalities/cities in the app catalog. Use municipality and official sources for live administrative details.",
                relatedEntityIDs: NLCity.all
                    .filter { $0.province == province.id }
                    .map { "city:\(KnowledgeNormalizer.slug($0.id))" },
                route: .provinceDetail(province.name),
                attributes: [
                    "population": province.population,
                    "area": province.areaKm2,
                    "capital": province.capital,
                    "cityCount": province.cityCount
                ],
                keywords: [province.name, province.nameEN, province.capital, "province", "municipality", "cities"] + province.highlights
            )
        }
    }

    private static func cityEntities() -> [NetherlandsKnowledgeEntity] {
        NLCity.all.map { city in
            let provinceId = provinceID(containingCity: city.name) ?? city.province
            let dashboardCity = CityDashboardContentData.city(for: city.name)
            return entity(
                id: "city:\(KnowledgeNormalizer.slug(city.id))",
                kind: .city,
                title: city.name,
                summary: city.shortDescription,
                cityId: city.name,
                provinceId: provinceId,
                category: "city",
                coordinate: coordinate(from: city.coordinates),
                source: officialSource(title: "\(city.name) municipality", url: municipalityURL(for: city), institution: "Gemeente \(city.name)"),
                lastChecked: "2026-07-05",
                images: visualSet(
                    id: "city:\(city.id)",
                    title: city.name,
                    url: city.imageURL,
                    localAssetName: nil,
                    category: .city
                ),
                aiSummary: city.fullDescription,
                relatedEntityIDs: relatedIDs(forCity: city.name, provinceId: provinceId),
                route: .nlCityDetail(city.id),
                attributes: [
                    "population": city.population,
                    "area": city.area,
                    "coordinates": city.coordinates,
                    "municipality": "Gemeente \(city.name)",
                    "transport": city.transport,
                    "weather": "Use live weather provider for current forecast; city coordinate is stored for lookup.",
                    "dashboardCityId": dashboardCity.id.rawValue
                ],
                keywords: [city.name, city.province, city.tagline, city.expat, city.transport, "city", "municipality", "weather", "local partners"] + city.highlights + city.services
            )
        }
    }

    private static func attractionEntities() -> [NetherlandsKnowledgeEntity] {
        NLCity.all.flatMap { city in
            city.attractions.map { attraction in
                let kind = kind(forAttractionType: attraction.type)
                return entity(
                    id: "place:\(KnowledgeNormalizer.slug(city.id)):\(KnowledgeNormalizer.slug(attraction.id))",
                    kind: kind,
                    title: attraction.name,
                    summary: attraction.description,
                    cityId: city.name,
                provinceId: provinceID(containingCity: city.name) ?? city.province,
                    category: attraction.type,
                    coordinate: coordinate(from: city.coordinates),
                    source: officialSource(title: "\(city.name) visitor information", url: municipalityURL(for: city), institution: "Gemeente \(city.name)"),
                    lastChecked: "2026-07-05",
                    images: visualSet(id: "place:\(city.id):\(attraction.id)", title: attraction.name, url: attraction.imageURL, localAssetName: nil, category: .city),
                    aiSummary: "\(attraction.description) Opening hours and prices should be checked with the official source before visiting.",
                    relatedEntityIDs: ["city:\(KnowledgeNormalizer.slug(city.id))"],
                    route: .nlCityDetail(city.id),
                    attributes: [
                        "openingHours": attraction.openHours,
                        "admission": attraction.admission,
                        "city": city.name
                    ],
                    keywords: [attraction.name, attraction.type, attraction.description, city.name, "attraction", "museum", "place", "visit"]
                )
            }
        }
    }

    private static func dashboardPlaceEntities() -> [NetherlandsKnowledgeEntity] {
        DashboardPlacesData.places.map { place in
            entity(
                id: "place:\(KnowledgeNormalizer.slug(place.id))",
                kind: kind(forVisitCategory: place.primaryCategory),
                title: place.title,
                summary: place.description,
                cityId: place.cityId,
                provinceId: provinceID(containingCity: place.cityId),
                category: place.primaryCategory.rawValue,
                coordinate: place.coordinates.map { NetherlandsDataCoordinate(latitude: $0.lat, longitude: $0.lng) },
                source: place.source,
                lastChecked: place.lastChecked ?? "2026-07-05",
                images: visualSet(id: "dashboard-place:\(place.id)", title: place.title, url: place.image, localAssetName: nil, category: .city),
                aiSummary: "\(place.description) Check the linked source for current opening hours, access, and prices.",
                relatedEntityIDs: ["city:\(KnowledgeNormalizer.slug(place.cityId))"],
                route: place.destination,
                attributes: [
                    "address": place.address ?? "",
                    "visitTime": place.estimatedVisitTime ?? "",
                    "priceHint": place.priceHint?.rawValue ?? "",
                    "indoor": place.indoor.map(String.init) ?? ""
                ],
                keywords: [place.title, place.shortTitle ?? "", place.description, place.cityId, place.address ?? ""] + place.category.map(\.rawValue)
            )
        }
    }

    private static func nearbyPlaceEntities() -> [NetherlandsKnowledgeEntity] {
        MockNearbyPlacesData.places.map { place in
            entity(
                id: "nearby-place:\(KnowledgeNormalizer.slug(place.saveKey))",
                kind: kind(forPlaceCategory: place.category),
                title: place.localizedName(.english),
                summary: place.localizedDescription(.english),
                cityId: place.city,
                provinceId: provinceID(containingCity: place.city),
                category: place.category.rawValue,
                coordinate: NetherlandsDataCoordinate(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude),
                source: place.websiteURL.map { OfficialSource(title: place.sourceLabel, url: $0, institution: place.name) },
                lastChecked: place.lastUpdated,
                images: visualSet(id: "nearby-place:\(place.saveKey)", title: place.name, url: nil, localAssetName: nil, category: .nearbyHelp),
                aiSummary: place.localizedUseCase(.english),
                relatedEntityIDs: ["city:\(KnowledgeNormalizer.slug(place.city))"] + place.relatedLinks.map { "topic:\(KnowledgeNormalizer.slug($0.title))" },
                route: .mapFocus(.place(place.saveKey)),
                attributes: [
                    "address": place.address,
                    "openingHours": place.openingHoursPlaceholder,
                    "phone": place.phone ?? "",
                    "website": place.websiteURL?.absoluteString ?? "",
                    "trustNote": place.trustNote
                ],
                keywords: [place.name, place.address, place.city, place.category.rawValue, place.description, place.newcomerUseCase, place.sourceLabel]
            )
        }
    }

    private static func institutionEntities() -> [NetherlandsKnowledgeEntity] {
        MockInstitutionsData.items.map { institution in
            entity(
                id: "government-service:\(KnowledgeNormalizer.slug(institution.name))",
                kind: .governmentService,
                title: institution.name,
                summary: institution.shortExplanation(.english),
                category: "government",
                source: OfficialSource(title: institution.name, url: institution.officialWebsiteURL, institution: institution.name),
                lastChecked: "2026-07-05",
                images: visualSet(id: "government-service:\(institution.name)", title: institution.name, url: nil, localAssetName: "home_documents_city_hall", category: .government),
                aiSummary: institution.usage(.english),
                relatedEntityIDs: relatedTopicIDs(forInstitution: institution.name),
                route: .institution(institution.name),
                attributes: [
                    "website": institution.officialWebsiteURL.absoluteString,
                    "warning": institution.warning(.english),
                    "whenToUse": institution.whenToUse(.english)
                ],
                keywords: [institution.name, institution.shortExplanation(.english), institution.usage(.english), institution.whenToUse(.english), "government", "official service"]
            )
        }
    }

    private static func localPartnerEntities() -> [NetherlandsKnowledgeEntity] {
        MockLocalPartnersData.partners.map { partner in
            let directImageURL = isDirectImageURL(partner.media.thumbnail.url) ? partner.media.thumbnail.url.absoluteString : nil
            return entity(
                id: "local-partner:\(partner.id)",
                kind: .localPartner,
                title: partner.name,
                summary: partner.description,
                cityId: partner.city,
                provinceId: provinceID(containingCity: partner.city),
                category: partner.subcategory,
                coordinate: NetherlandsDataCoordinate(latitude: partner.coordinate.latitude, longitude: partner.coordinate.longitude),
                source: partner.officialSource,
                lastChecked: partner.lastVerified,
                images: visualSet(id: "local-partner:\(partner.id)", title: partner.name, url: directImageURL, localAssetName: nil, category: .nearbyHelp),
                aiSummary: "\(partner.description) Commercial listing status: \(partner.plan.label(.english)). Verify availability directly with the business.",
                relatedEntityIDs: ["city:\(KnowledgeNormalizer.slug(partner.city))", "source:\(KnowledgeNormalizer.slug(partner.officialSource.title))"],
                route: .localPartnerDetail(partner.id),
                attributes: [
                    "subcategory": partner.subcategory,
                    "plan": partner.plan.label(.english),
                    "address": partner.address,
                    "phone": partner.phone,
                    "email": partner.email,
                    "website": partner.website.absoluteString,
                    "openingHours": partner.openingHours,
                    "verified": String(partner.plan == .verifiedPartner || partner.plan == .premium || partner.plan == .featured || partner.plan == .aiFeatured),
                    "sponsored": String(partner.plan == .sponsoredPlacement)
                ],
                keywords: [partner.name, partner.category.rawValue, partner.category.title(.english), partner.subcategory, partner.description, partner.address, partner.city, partner.openingHours] + partner.languages + partner.photoSymbols
            )
        }
    }

    private static func calendarEventEntities() -> [NetherlandsKnowledgeEntity] {
        DashboardCalendarData.events.map { event in
            entity(
                id: "event:\(KnowledgeNormalizer.slug(event.id))",
                kind: .event,
                title: event.localTitle ?? event.title,
                summary: event.description ?? event.impact ?? event.type.rawValue,
                cityId: event.cityId,
                provinceId: event.cityId.flatMap { provinceID(containingCity: $0) },
                category: event.type.rawValue,
                source: event.source,
                lastChecked: event.lastChecked ?? "2026-07-05",
                images: visualSet(id: "event:\(event.id)", title: event.title, url: nil, localAssetName: nil, category: .city),
                aiSummary: event.impact ?? event.description ?? "Check the official source for current event details.",
                relatedEntityIDs: [event.cityId.map { "city:\(KnowledgeNormalizer.slug($0))" }, event.source.map { "source:\(KnowledgeNormalizer.slug($0.title))" }].compactMap { $0 },
                route: .calendarEvent(event.id),
                attributes: [
                    "official": String(event.official),
                    "affectsServices": event.affectsServices.map(String.init) ?? "",
                    "affectsTransport": event.affectsTransport.map(String.init) ?? ""
                ],
                keywords: [event.title, event.localTitle ?? "", event.description ?? "", event.impact ?? "", event.type.rawValue, "calendar", "event"]
            )
        }
    }

    private static func coreKnowledgeTopicEntities() -> [NetherlandsKnowledgeEntity] {
        [
            topicEntity("topic:registration-bsn", "BSN and BRP registration", "Municipality registration creates or updates BRP records and is the normal path to a BSN for residents.", "government", "source:government-brp", .practicalGuide(.municipalityRegistration)),
            topicEntity("topic:digid", "DigiD", "Digital login for many Dutch government and healthcare services. Usually depends on BSN and official registration context.", "government", "source:government-nl", .institution("DigiD")),
            topicEntity("topic:health-insurance", "Health insurance", "Dutch basic health insurance is mandatory for many residents and workers; eligibility and obligations should be checked with official sources.", "healthcare", "source:government-nl", .practicalGuide(.healthInsuranceBasics)),
            topicEntity("topic:transport-ov", "Public transport", "Use NS, 9292, OVpay, and local operators for routes, check-in rules, and ticketing.", "transport", "source:9292", .practicalGuide(.transportBasics)),
            topicEntity("topic:local-partners", "Local partners", "Commercial listings are stored once and labeled by status: verified, featured, sponsored, or free listing.", "partners", "source:government-nl", .localPartners)
        ]
    }

    private static func buildRelations(for entities: [NetherlandsKnowledgeEntity]) -> [KnowledgeRelation] {
        var relations: [KnowledgeRelation] = []
        let ids = Set(entities.map(\.id))
        let knowledgeIDByEntityID = Dictionary(uniqueKeysWithValues: entities.map { ($0.id, $0.knowledgeItemID) })

        func link(_ from: String, _ to: String, _ type: KnowledgeRelationType, _ reason: String, weight: Double = 0.82) {
            guard ids.contains(from),
                  ids.contains(to),
                  let fromID = knowledgeIDByEntityID[from],
                  let toID = knowledgeIDByEntityID[to]
            else { return }
            relations.append(KnowledgeRelation(fromID: fromID, toID: toID, type: type, weight: weight, reason: reason))
        }

        for entity in entities {
            if let provinceId = entity.provinceId {
                link(entity.id, "province:\(KnowledgeNormalizer.slug(provinceId))", .provinceSpecific, "Entity belongs to province \(provinceId).", weight: 0.74)
            }
            if let cityId = entity.cityId {
                link(entity.id, "city:\(KnowledgeNormalizer.slug(cityId))", .citySpecific, "Entity belongs to city \(cityId).", weight: 0.88)
            }
            if let source = entity.source {
                link(entity.id, "source:\(KnowledgeNormalizer.slug(source.title))", .officialSource, "Entity cites \(source.title).", weight: 0.92)
            }
            for related in entity.relatedEntityIDs {
                link(entity.id, related, .relatedTopic, "Explicit database relation.", weight: 0.76)
            }
        }

        for city in entities where city.kind == .city {
            link(city.id, "topic:registration-bsn", .nextStep, "City setup usually starts with municipality registration and BSN.", weight: 0.90)
            link(city.id, "topic:transport-ov", .relatedTopic, "City exploration depends on transport.", weight: 0.74)
            link(city.id, "topic:local-partners", .relatedTopic, "City pages can surface local partners.", weight: 0.70)
        }

        link("topic:registration-bsn", "topic:digid", .nextStep, "DigiD often follows BSN/BRP registration.", weight: 0.94)
        link("topic:registration-bsn", "source:government-brp", .officialSource, "BRP source explains municipality records and BSN context.", weight: 0.98)
        link("topic:transport-ov", "source:9292", .officialSource, "9292 provides public transport route planning.", weight: 0.90)

        return relations
    }

    private static func entity(
        id: String,
        kind: NetherlandsEntityKind,
        title: String,
        summary: String,
        cityId: String? = nil,
        provinceId: String? = nil,
        category: String,
        coordinate: NetherlandsDataCoordinate? = nil,
        source: OfficialSource? = nil,
        lastChecked: String,
        images: NetherlandsVisualSet = NetherlandsVisualSet(hero: nil, gallery: [], thumbnail: nil, mapPreview: nil, categoryCover: nil),
        aiSummary: String,
        relatedEntityIDs: [String] = [],
        route: AppDestination? = nil,
        attributes: [String: String] = [:],
        keywords: [String] = []
    ) -> NetherlandsKnowledgeEntity {
        NetherlandsKnowledgeEntity(
            id: id,
            kind: kind,
            title: title,
            summary: summary,
            cityId: cityId,
            provinceId: provinceId,
            category: category,
            coordinate: coordinate,
            source: source,
            lastChecked: lastChecked,
            images: images,
            aiSummary: aiSummary,
            relatedEntityIDs: relatedEntityIDs,
            route: route,
            attributes: attributes,
            keywords: keywords
        )
    }

    private static func officialSourceEntity(_ id: String, _ title: String, _ summary: String, _ url: String) -> NetherlandsKnowledgeEntity {
        entity(
            id: id,
            kind: .officialSource,
            title: title,
            summary: summary,
            category: "official source",
            source: officialSource(title: title, url: url, institution: title),
            lastChecked: "2026-07-05",
            images: visualSet(id: id, title: title, url: nil, localAssetName: "home_documents_city_hall", category: .government),
            aiSummary: summary,
            route: .officialSources,
            attributes: ["url": url],
            keywords: [title, summary, url, "official", "source"]
        )
    }

    private static func topicEntity(_ id: String, _ title: String, _ summary: String, _ category: String, _ sourceID: String, _ route: AppDestination) -> NetherlandsKnowledgeEntity {
        entity(
            id: id,
            kind: .knowledgeTopic,
            title: title,
            summary: summary,
            category: category,
            source: nil,
            lastChecked: "2026-07-05",
            images: visualSet(id: id, title: title, url: nil, localAssetName: nil, category: category == "transport" ? .transport : .government),
            aiSummary: summary,
            relatedEntityIDs: [sourceID],
            route: route,
            keywords: [title, summary, category, "knowledge", "topic"]
        )
    }

    private static func visualSet(id: String, title: String, url: String?, localAssetName: String?, category: PremiumImageFallbackCategory) -> NetherlandsVisualSet {
        let asset = appImageAsset(id: id, title: title, url: url, localAssetName: localAssetName, category: category)
        return NetherlandsVisualSet(hero: asset, gallery: asset.map { [$0] } ?? [], thumbnail: asset, mapPreview: asset, categoryCover: asset)
    }

    private static func appImageAsset(id: String, title: String, url: String?, localAssetName: String?, category: PremiumImageFallbackCategory) -> AppImageAsset? {
        if let url, let imageURL = AppURL.validatedWebURL(URL(string: url)) {
            return AppImageAsset(
                id: "\(id):image",
                url: imageURL,
                imageURL: imageURL,
                thumbnailURL: imageURL,
                localAssetName: nil,
                title: title,
                description: "Verified visual for \(title)",
                sourceName: imageURL.host ?? "Verified source",
                sourceURL: imageURL,
                license: nil,
                attribution: nil,
                width: nil,
                height: nil,
                type: .cardThumbnail,
                verified: true
            )
        }

        if let localAssetName {
            return AppImageAsset(
                id: "\(id):local-image",
                url: nil,
                localAssetName: localAssetName,
                title: title,
                description: "Bundled YouNew visual for \(title)",
                sourceName: "YouNew",
                sourceURL: nil,
                license: nil,
                attribution: nil,
                width: nil,
                height: nil,
                type: .cardThumbnail,
                verified: true
            )
        }

        return AppImageAsset(
            id: "\(id):fallback-\(category)",
            url: nil,
            title: title,
            description: "Premium thematic fallback for \(title)",
            sourceName: "YouNew",
            sourceURL: nil,
            license: nil,
            attribution: nil,
            width: nil,
            height: nil,
            type: .cardThumbnail,
            verified: true
        )
    }

    private static func officialSource(title: String, url: String?, institution: String?) -> OfficialSource? {
        guard let url, let sourceURL = AppURL.validatedWebURL(URL(string: url)) else { return nil }
        return OfficialSource(title: title, url: sourceURL, institution: institution)
    }

    private static func municipalityURL(for city: NLCity) -> String? {
        let normalized = KnowledgeNormalizer.slug(city.name)
        let overrides: [String: String] = [
            "den-haag": "https://www.denhaag.nl",
            "s-hertogenbosch": "https://www.s-hertogenbosch.nl"
        ]
        if let override = overrides[normalized] { return override }
        return "https://www.\(normalized).nl"
    }

    private static let provinceIDByCityLookupKey: [String: String] = {
        var values: [String: String] = [:]
        for city in NLCity.all {
            values[KnowledgeNormalizer.slug(city.id)] = city.province
            values[KnowledgeNormalizer.slug(city.name)] = city.province
        }
        return values
    }()

    private static func provinceID(containingCity city: String) -> String? {
        provinceIDByCityLookupKey[KnowledgeNormalizer.slug(city)]
    }

    private static func coordinate(from value: String) -> NetherlandsDataCoordinate? {
        let parts = value
            .replacingOccurrences(of: "°", with: "")
            .replacingOccurrences(of: ",", with: "")
            .split(separator: " ")
            .map(String.init)
        guard parts.count >= 4,
              let latitude = Double(parts[0]),
              let longitude = Double(parts[2])
        else { return nil }
        return NetherlandsDataCoordinate(
            latitude: parts[1].uppercased() == "S" ? -latitude : latitude,
            longitude: parts[3].uppercased() == "W" ? -longitude : longitude
        )
    }

    private static func kind(forAttractionType type: String) -> NetherlandsEntityKind {
        let normalized = type.lowercased()
        if normalized.contains("museum") { return .museum }
        if normalized.contains("park") || normalized.contains("garden") { return .park }
        if normalized.contains("food") || normalized.contains("market") { return .restaurant }
        return .attraction
    }

    private static func kind(forVisitCategory category: VisitPlaceCategory) -> NetherlandsEntityKind {
        switch category {
        case .museum, .rainyDay: return .museum
        case .park, .free: return .park
        case .food, .market: return .restaurant
        default: return .attraction
        }
    }

    private static func kind(forPlaceCategory category: PlaceCategory) -> NetherlandsEntityKind {
        switch category {
        case .healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy:
            return .healthcare
        case .municipality, .ind, .uwv, .duo, .immigrationSupport, .expatCenter, .police:
            return .governmentService
        case .transport, .transportOffice, .bikeRepair:
            return .transport
        case .education, .library, .studentHelp:
            return .university
        default:
            return .place
        }
    }

    private static func relatedIDs(forCity city: String, provinceId: String) -> [String] {
        [
            "province:\(KnowledgeNormalizer.slug(provinceId))",
            "topic:registration-bsn",
            "topic:transport-ov",
            "topic:local-partners"
        ] + MockLocalPartnersData.partners(in: city).prefix(5).map { "local-partner:\($0.id)" }
    }

    private static func relatedTopicIDs(forInstitution name: String) -> [String] {
        let normalized = KnowledgeNormalizer.normalize(name)
        if normalized.contains("digid") { return ["topic:digid", "topic:registration-bsn"] }
        if normalized.contains("ind") { return ["topic:registration-bsn"] }
        if normalized.contains("duo") { return ["topic:registration-bsn"] }
        if normalized.contains("belasting") || normalized.contains("uwv") || normalized.contains("svb") { return ["topic:digid"] }
        return ["topic:registration-bsn"]
    }

    private static func isDirectImageURL(_ url: URL) -> Bool {
        ["jpg", "jpeg", "png", "webp", "gif", "heic"].contains(url.pathExtension.lowercased())
    }
}

private extension NetherlandsKnowledgeEntity {
    var knowledgeItemID: String {
        switch kind {
        case .country, .knowledgeTopic:
            return id
        case .province:
            return id
        case .city:
            return id
        case .localPartner:
            return id.replacingOccurrences(of: "local-partner:", with: "localPartner:")
        case .officialSource:
            return id
        case .event:
            return id.replacingOccurrences(of: "event:", with: "calendarEvent:")
        default:
            return id
        }
    }

    var knowledgeItemType: KnowledgeItemType {
        switch kind {
        case .country, .knowledgeTopic:
            return .topic
        case .province:
            return .province
        case .city:
            return .city
        case .governmentService:
            return .officialService
        case .localPartner:
            return .localPartner
        case .officialSource:
            return .resource
        case .checklist:
            return .checklist
        case .event:
            return .deadline
        default:
            return .nearbyPlace
        }
    }

    var searchKeywords: [String] {
        Array(Set(([title, summary, category, cityId, provinceId, aiSummary] + keywords + attributes.map { "\($0.key) \($0.value)" }).compactMap { $0 }))
    }

    var personaTags: Set<PersonaTag> {
        switch kind {
        case .country, .province, .city, .place, .attraction, .museum, .park, .restaurant, .cafe, .hotel, .transport, .officialSource, .knowledgeTopic, .event:
            return [.universal]
        case .governmentService, .healthcare:
            return [.student, .worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        case .university:
            return [.student, .family, .nonEU, .eu, .highlySkilledMigrant]
        case .localPartner:
            return [.student, .worker, .family, .tourist, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        case .district, .checklist:
            return [.universal]
        }
    }
}
