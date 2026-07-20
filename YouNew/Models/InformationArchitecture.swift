import Foundation
import SwiftUI

enum IASection: String, CaseIterable, Codable, Hashable, Identifiable {
    case startHere
    case places
    case transport
    case emergency
    case documentsGovernment
    case housing
    case healthcare
    case workStudy
    case foodLifestyle
    case calendarEvents
    case aiAssistant

    var id: String { rawValue }

    var priority: Int {
        switch self {
        case .startHere: return 1
        case .places: return 2
        case .transport: return 3
        case .emergency: return 4
        case .documentsGovernment: return 5
        case .housing: return 6
        case .healthcare: return 7
        case .workStudy: return 8
        case .foodLifestyle: return 9
        case .calendarEvents: return 10
        case .aiAssistant: return 11
        }
    }

    var symbol: String {
        switch self {
        case .startHere: return "figure.walk"
        case .places: return "mappin.and.ellipse"
        case .transport: return "tram.fill"
        case .emergency: return "phone.fill"
        case .documentsGovernment: return "building.columns.fill"
        case .housing: return "house.fill"
        case .healthcare: return "cross.case.fill"
        case .workStudy: return "briefcase.fill"
        case .foodLifestyle: return "fork.knife"
        case .calendarEvents: return "calendar"
        case .aiAssistant: return "sparkles"
        }
    }

    var accent: Color {
        switch self {
        case .startHere: return AppColors.cyanGlow
        case .places: return AppColors.softBlue
        case .transport: return AppColors.emerald
        case .emergency: return AppColors.error
        case .documentsGovernment: return AppColors.dutchOrange
        case .housing: return AppColors.violet
        case .healthcare: return AppColors.success
        case .workStudy: return AppColors.warning
        case .foodLifestyle: return AppColors.dutchOrange
        case .calendarEvents: return AppColors.cyanGlow
        case .aiAssistant: return AppColors.violet
        }
    }

    func title(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.startHere, .russian): return "Start Here"
        case (.startHere, .dutch): return "Begin hier"
        case (.startHere, .english): return "Start Here"
        case (.places, .russian): return "Места"
        case (.places, .dutch): return "Plekken"
        case (.places, .english): return "Places"
        case (.transport, .russian): return "Транспорт"
        case (.transport, .dutch): return "Vervoer"
        case (.transport, .english): return "Transport"
        case (.emergency, .russian): return "Экстренно"
        case (.emergency, .dutch): return "Noodhulp"
        case (.emergency, .english): return "Emergency"
        case (.documentsGovernment, .russian): return "Документы и государство"
        case (.documentsGovernment, .dutch): return "Documenten & overheid"
        case (.documentsGovernment, .english): return "Documents & Government"
        case (.housing, .russian): return "Жилье"
        case (.housing, .dutch): return "Wonen"
        case (.housing, .english): return "Housing"
        case (.healthcare, .russian): return "Медицина"
        case (.healthcare, .dutch): return "Zorg"
        case (.healthcare, .english): return "Healthcare"
        case (.workStudy, .russian): return "Работа и учеба"
        case (.workStudy, .dutch): return "Werk & studie"
        case (.workStudy, .english): return "Work & Study"
        case (.foodLifestyle, .russian): return "Еда и жизнь"
        case (.foodLifestyle, .dutch): return "Eten & leven"
        case (.foodLifestyle, .english): return "Food & Lifestyle"
        case (.calendarEvents, .russian): return "Календарь"
        case (.calendarEvents, .dutch): return "Kalender"
        case (.calendarEvents, .english): return "Calendar & Events"
        case (.aiAssistant, .russian): return "AI Assistant"
        case (.aiAssistant, .dutch): return "AI Assistant"
        case (.aiAssistant, .english): return "AI Assistant"
        }
    }

    static func infer(from destination: AppDestination) -> IASection {
        switch destination {
        case .firstSteps, .checklistList, .beginnerGuidesList, .practicalGuide(.firstStepsNetherlands):
            return .startHere
        case .placeDetail, .discoveryList, .localPartners, .localPartnerDetail, .businessGrowth, .businessLogin, .businessDashboard, .cityList, .provinceList, .provinceDetail, .provinceCities, .cityDetail, .nlCityDetail, .netherlandsOverview, .cultureAttractions, .mapHub, .mapFocus:
            return .places
        case .practicalGuide(.transportBasics), .transportSection:
            return .transport
        case .emergencyHub:
            return .emergency
        case .journeyDocuments, .governmentHub, .governmentSection, .officialSources, .legalHelp, .lettersList, .document, .practicalGuide(.digidSafety), .practicalGuide(.municipalityRegistration), .practicalGuide(.officialSourcesChecklist), .finesAndLettersHub, .finesList:
            return .documentsGovernment
        case .practicalGuide(.housingBasics), .housingSection:
            return .housing
        case .practicalGuide(.healthcareBasics), .practicalGuide(.findingHuisarts), .practicalGuide(.healthInsuranceBasics), .healthSection:
            return .healthcare
        case .institutionsList, .knm, .knmModule, .dutchA1A2, .dutchA1A2Module, .languageHub, .educationSection, .workSection, .practicalGuide(.bankingBasics):
            return .workStudy
        case .netherlandsCalendar, .calendarEvent, .dutchHolidays:
            return .calendarEvents
        case .assistantHub:
            return .aiAssistant
        default:
            return .startHere
        }
    }

    static func infer(from category: VisitPlaceCategory) -> IASection {
        switch category {
        case .food, .market:
            return .foodLifestyle
        default:
            return .places
        }
    }
}

enum IAUserMode: String, CaseIterable, Codable, Hashable, Identifiable {
    case tourist
    case refugeeStatusHolder
    case student
    case resident
    case business

    var id: String { rawValue }

    static func from(persona: PersonaTag?) -> IAUserMode {
        switch persona {
        case .tourist, nil:
            return .tourist
        case .refugee:
            return .refugeeStatusHolder
        case .student:
            return .student
        case .entrepreneur:
            return .business
        case .worker, .family, .lgbt, .eu, .nonEU, .highlySkilledMigrant, .universal:
            return .resident
        }
    }

    static func from(contentCategory: UserContentCategory?) -> IAUserMode {
        switch contentCategory {
        case .tourist, nil:
            return .tourist
        case .student:
            return .student
        case .business:
            return .business
        case .local, .general, .admin:
            return .resident
        }
    }

    var allowedSections: Set<IASection> {
        switch self {
        case .tourist:
            return [.startHere, .places, .transport, .emergency, .healthcare, .foodLifestyle, .calendarEvents, .aiAssistant]
        case .refugeeStatusHolder:
            return [.startHere, .transport, .emergency, .documentsGovernment, .housing, .healthcare, .workStudy, .calendarEvents, .aiAssistant]
        case .student:
            return [.startHere, .places, .transport, .emergency, .documentsGovernment, .housing, .healthcare, .workStudy, .foodLifestyle, .calendarEvents, .aiAssistant]
        case .resident:
            return [.startHere, .places, .transport, .emergency, .documentsGovernment, .housing, .healthcare, .workStudy, .calendarEvents, .aiAssistant]
        case .business:
            return [.startHere, .places, .transport, .emergency, .documentsGovernment, .housing, .healthcare, .workStudy, .foodLifestyle, .calendarEvents, .aiAssistant]
        }
    }

    func canSee(_ section: IASection) -> Bool {
        allowedSections.contains(section)
    }
}

enum InformationArchitecture {
    static let canonicalSections = IASection.allCases.sorted { $0.priority < $1.priority }

    static func section(for destination: AppDestination) -> IASection {
        IASection.infer(from: destination)
    }

    static func userMode(for persona: PersonaTag?) -> IAUserMode {
        IAUserMode.from(persona: persona)
    }

    static func canShow(destination: AppDestination, persona: PersonaTag?) -> Bool {
        userMode(for: persona).canSee(section(for: destination))
    }
}

/// Canonical metadata for every top-level content category.
/// Views render shortcuts from an ID and never own a second title, subtitle, icon or route.
struct CanonicalContentCategory: Identifiable, Hashable {
    let section: IASection
    let destination: AppDestination

    var id: String { section.id }
    var symbol: String { section.symbol }
    var accent: Color { section.accent }

    func title(_ language: AppLanguage) -> String { section.title(language) }

    func subtitle(_ language: AppLanguage) -> String {
        switch (section, language) {
        case (.startHere, .english): return "First steps and practical checklists"
        case (.startHere, .dutch): return "Eerste stappen en praktische checklists"
        case (.startHere, .russian): return "Первые шаги и практические чек-листы"
        case (.places, .english): return "Cities, sights and nearby services"
        case (.places, .dutch): return "Steden, bezienswaardigheden en diensten dichtbij"
        case (.places, .russian): return "Города, достопримечательности и сервисы рядом"
        case (.transport, .english): return "OV, trains, bikes and route planning"
        case (.transport, .dutch): return "OV, trein, fiets en reisplanning"
        case (.transport, .russian): return "OV, поезда, велосипед и маршруты"
        case (.emergency, .english): return "112 and urgent help"
        case (.emergency, .dutch): return "112 en dringende hulp"
        case (.emergency, .russian): return "112 и срочная помощь"
        case (.documentsGovernment, .english): return "Municipality, DigiD and official sources"
        case (.documentsGovernment, .dutch): return "Gemeente, DigiD en officiële bronnen"
        case (.documentsGovernment, .russian): return "Gemeente, DigiD и официальные источники"
        case (.housing, .english): return "Rent, address and housing basics"
        case (.housing, .dutch): return "Huur, adres en wonen"
        case (.housing, .russian): return "Аренда, адрес и основы жилья"
        case (.healthcare, .english): return "GP, insurance and urgent care"
        case (.healthcare, .dutch): return "Huisarts, verzekering en spoedzorg"
        case (.healthcare, .russian): return "Huisarts, страховка и срочная помощь"
        case (.workStudy, .english): return "Work, education and language"
        case (.workStudy, .dutch): return "Werk, onderwijs en taal"
        case (.workStudy, .russian): return "Работа, учеба и язык"
        case (.foodLifestyle, .english): return "Food, culture and free time"
        case (.foodLifestyle, .dutch): return "Eten, cultuur en vrije tijd"
        case (.foodLifestyle, .russian): return "Еда, культура и досуг"
        case (.calendarEvents, .english): return "Holidays and local events"
        case (.calendarEvents, .dutch): return "Feestdagen en lokale events"
        case (.calendarEvents, .russian): return "Праздники и местные события"
        case (.aiAssistant, .english): return "Ask for a personalized next step"
        case (.aiAssistant, .dutch): return "Vraag om een persoonlijke volgende stap"
        case (.aiAssistant, .russian): return "Персональная помощь со следующим шагом"
        }
    }
}

enum CanonicalContentRegistry {
    static let all: [CanonicalContentCategory] = [
        .init(section: .startHere, destination: .firstSteps),
        .init(section: .places, destination: .mapHub),
        .init(section: .transport, destination: .practicalGuide(.transportBasics)),
        .init(section: .emergency, destination: .emergencyHub),
        .init(section: .documentsGovernment, destination: .officialSources),
        .init(section: .housing, destination: .practicalGuide(.housingBasics)),
        .init(section: .healthcare, destination: .practicalGuide(.healthcareBasics)),
        .init(section: .workStudy, destination: .institutionsList),
        .init(section: .foodLifestyle, destination: .cultureAttractions),
        .init(section: .calendarEvents, destination: .netherlandsCalendar),
        .init(section: .aiAssistant, destination: .assistantHub)
    ]

    static func category(_ section: IASection) -> CanonicalContentCategory {
        guard let category = all.first(where: { $0.section == section }) else {
            preconditionFailure("Missing canonical category: \(section.rawValue)")
        }
        return category
    }
}
