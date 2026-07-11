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
        case .placeDetail, .homeExploreList, .localPartners, .localPartnerDetail, .businessGrowth, .businessLogin, .businessDashboard, .cityList, .provinceList, .provinceDetail, .provinceCities, .cityDetail, .nlCityDetail, .netherlandsOverview, .cultureAttractions, .mapHub, .mapFocus:
            return .places
        case .practicalGuide(.transportBasics):
            return .transport
        case .emergencyHub:
            return .emergency
        case .journeyDocuments, .governmentHub, .officialSources, .legalHelp, .lettersList, .document, .practicalGuide(.digidSafety), .practicalGuide(.municipalityRegistration), .practicalGuide(.officialSourcesChecklist), .finesAndLettersHub, .finesList:
            return .documentsGovernment
        case .practicalGuide(.housingBasics):
            return .housing
        case .practicalGuide(.healthcareBasics), .practicalGuide(.findingHuisarts), .practicalGuide(.healthInsuranceBasics):
            return .healthcare
        case .institutionsList, .knm, .knmModule, .dutchA1A2, .dutchA1A2Module, .languageHub, .practicalGuide(.bankingBasics):
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
