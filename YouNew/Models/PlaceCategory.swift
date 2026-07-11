import Foundation

enum PlaceCategory: String, CaseIterable, Identifiable, Sendable {
    case municipality
    case healthcare
    case hospital
    case huisarts
    case pharmacy
    case nightPharmacy
    case police
    case library
    case transport
    case transportOffice
    case legalHelp
    case foodBank
    case shelter
    case duo
    case uwv
    case ind
    case bikeRepair
    case education
    case communitySupport
    case immigrationSupport
    case expatCenter
    case studentHelp
    case lgbtqSupport
    case animalEmergency

    var id: String { rawValue }

    func localized(_ lang: AppLanguage) -> String {
        switch lang {
        case .english:
            switch self {
            case .municipality: return "Municipality"
            case .healthcare: return "Healthcare"
            case .hospital: return "Hospitals"
            case .huisarts: return "GP / Huisarts"
            case .pharmacy: return "Pharmacies"
            case .nightPharmacy: return "Night pharmacies"
            case .police: return "Police"
            case .library: return "Libraries"
            case .transport: return "Transport"
            case .transportOffice: return "Public transport offices"
            case .legalHelp: return "Legal help"
            case .foodBank: return "Food banks"
            case .shelter: return "Shelters"
            case .duo: return "DUO"
            case .uwv: return "UWV"
            case .ind: return "IND"
            case .bikeRepair: return "Bike repair"
            case .education: return "Education"
            case .communitySupport: return "Community support"
            case .immigrationSupport: return "Immigration support"
            case .expatCenter: return "Expat centers"
            case .studentHelp: return "Student support"
            case .lgbtqSupport: return "LGBTQ support"
            case .animalEmergency: return "Animal emergency"
            }
        case .dutch:
            switch self {
            case .municipality: return "Gemeente"
            case .healthcare: return "Zorg"
            case .hospital: return "Ziekenhuizen"
            case .huisarts: return "Huisarts"
            case .pharmacy: return "Apotheken"
            case .nightPharmacy: return "Dienstapotheken"
            case .police: return "Politie"
            case .library: return "Bibliotheken"
            case .transport: return "Vervoer"
            case .transportOffice: return "OV-kantoren"
            case .legalHelp: return "Juridische hulp"
            case .foodBank: return "Voedselbanken"
            case .shelter: return "Opvang"
            case .duo: return "DUO"
            case .uwv: return "UWV"
            case .ind: return "IND"
            case .bikeRepair: return "Fietsreparatie"
            case .education: return "Onderwijs"
            case .communitySupport: return "Buurtsteun"
            case .immigrationSupport: return "Immigratiehulp"
            case .expatCenter: return "Expatcentra"
            case .studentHelp: return "Studentenhulp"
            case .lgbtqSupport: return "LGBTQ-steun"
            case .animalEmergency: return "Dierennood"
            }
        case .russian:
            switch self {
            case .municipality: return "Муниципалитет"
            case .healthcare: return "Медицина"
            case .hospital: return "Больницы"
            case .huisarts: return "Семейный врач"
            case .pharmacy: return "Аптеки"
            case .nightPharmacy: return "Дежурные аптеки"
            case .police: return "Полиция"
            case .library: return "Библиотеки"
            case .transport: return "Транспорт"
            case .transportOffice: return "Офисы транспорта"
            case .legalHelp: return "Юридическая помощь"
            case .foodBank: return "Продуктовая помощь"
            case .shelter: return "Приюты"
            case .duo: return "DUO"
            case .uwv: return "UWV"
            case .ind: return "IND"
            case .bikeRepair: return "Ремонт велосипедов"
            case .education: return "Образование"
            case .communitySupport: return "Поддержка сообщества"
            case .immigrationSupport: return "Иммиграционная помощь"
            case .expatCenter: return "Центры для экспатов"
            case .studentHelp: return "Помощь студентам"
            case .lgbtqSupport: return "LGBTQ-поддержка"
            case .animalEmergency: return "Помощь животным"
            }
        }
    }

    var title: String { localized(.english) }

    var systemImageName: String {
        switch self {
        case .municipality: return "building.2.fill"
        case .healthcare: return "cross.case.fill"
        case .hospital: return "cross.vial.fill"
        case .huisarts: return "stethoscope"
        case .pharmacy: return "pills.fill"
        case .nightPharmacy: return "moon.stars.fill"
        case .police: return "shield.fill"
        case .library: return "books.vertical.fill"
        case .transport: return "tram.fill"
        case .transportOffice: return "building.2.crop.circle"
        case .legalHelp: return "doc.text.fill"
        case .foodBank: return "takeoutbag.and.cup.and.straw.fill"
        case .shelter: return "house.lodge.fill"
        case .duo: return "graduationcap.circle.fill"
        case .uwv: return "briefcase.circle.fill"
        case .ind: return "person.text.rectangle.fill"
        case .bikeRepair: return "wrench.and.screwdriver.fill"
        case .education: return "graduationcap.fill"
        case .communitySupport: return "person.3.fill"
        case .immigrationSupport: return "person.text.rectangle.fill"
        case .expatCenter: return "globe.europe.africa.fill"
        case .studentHelp: return "studentdesk"
        case .lgbtqSupport: return "heart.circle.fill"
        case .animalEmergency: return "pawprint.circle.fill"
        }
    }

    var tintColor: String {
        switch self {
        case .municipality: return "municipality"
        case .healthcare: return "healthcare"
        case .pharmacy: return "pharmacy"
        case .police: return "police"
        case .library: return "library"
        case .transport: return "transport"
        case .legalHelp: return "legal"
        case .education: return "education"
        case .communitySupport: return "community"
        case .immigrationSupport: return "immigration"
        case .expatCenter: return "expat"
        case .studentHelp: return "student"
        case .hospital: return "healthcare"
        case .huisarts: return "healthcare"
        case .nightPharmacy: return "pharmacy"
        case .transportOffice: return "transport"
        case .foodBank: return "community"
        case .shelter: return "community"
        case .duo: return "student"
        case .uwv: return "legal"
        case .ind: return "immigration"
        case .bikeRepair: return "transport"
        case .lgbtqSupport: return "community"
        case .animalEmergency: return "community"
        }
    }
}
