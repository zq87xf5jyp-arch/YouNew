import SwiftUI
import CoreLocation

enum NewcomerPlaceCategory: String, CaseIterable, Identifiable {
    case municipality
    case bsnRegistration
    case languageLearning
    case library
    case healthcare
    case hospital
    case legalHelp
    case transport
    case police
    case emergency
    case community
    case family
    case student
    case work
    case uwv
    case taxes
    case lgbtq
    case housing
    case documents

    var id: String { rawValue }

    func localized(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.municipality, .english): return "Municipality"
        case (.municipality, .dutch): return "Gemeente"
        case (.municipality, .russian): return "Муниципалитет"
        case (.bsnRegistration, .english): return "BSN registration"
        case (.bsnRegistration, .dutch): return "BSN-registratie"
        case (.bsnRegistration, .russian): return "Регистрация BSN"
        case (.languageLearning, .english): return "Language learning"
        case (.languageLearning, .dutch): return "Taal leren"
        case (.languageLearning, .russian): return "Изучение языка"
        case (.library, .english): return "Library"
        case (.library, .dutch): return "Bibliotheek"
        case (.library, .russian): return "Библиотека"
        case (.healthcare, .english): return "Healthcare"
        case (.healthcare, .dutch): return "Zorg"
        case (.healthcare, .russian): return "Медицина"
        case (.hospital, .english): return "Hospital"
        case (.hospital, .dutch): return "Ziekenhuis"
        case (.hospital, .russian): return "Больница"
        case (.legalHelp, .english): return "Legal help"
        case (.legalHelp, .dutch): return "Juridische hulp"
        case (.legalHelp, .russian): return "Юридическая помощь"
        case (.transport, .english): return "Transport"
        case (.transport, .dutch): return "Vervoer"
        case (.transport, .russian): return "Транспорт"
        case (.police, .english): return "Police"
        case (.police, .dutch): return "Politie"
        case (.police, .russian): return "Полиция"
        case (.emergency, .english): return "Emergency"
        case (.emergency, .dutch): return "Noodhulp"
        case (.emergency, .russian): return "Экстренная помощь"
        case (.community, .english): return "Community"
        case (.community, .dutch): return "Gemeenschap"
        case (.community, .russian): return "Сообщество"
        case (.family, .english): return "Family"
        case (.family, .dutch): return "Gezin"
        case (.family, .russian): return "Семья"
        case (.student, .english): return "Student"
        case (.student, .dutch): return "Student"
        case (.student, .russian): return "Студенты"
        case (.work, .english): return "Work"
        case (.work, .dutch): return "Werk"
        case (.work, .russian): return "Работа"
        case (.uwv, .english): return "UWV"
        case (.uwv, .dutch): return "UWV"
        case (.uwv, .russian): return "UWV"
        case (.taxes, .english): return "Taxes"
        case (.taxes, .dutch): return "Belasting"
        case (.taxes, .russian): return "Налоги"
        case (.lgbtq, .english): return "LGBTQ+ support"
        case (.lgbtq, .dutch): return "LGBTQ+-steun"
        case (.lgbtq, .russian): return "LGBTQ+-поддержка"
        case (.housing, .english): return "Housing"
        case (.housing, .dutch): return "Wonen"
        case (.housing, .russian): return "Жильё"
        case (.documents, .english): return "Documents"
        case (.documents, .dutch): return "Documenten"
        case (.documents, .russian): return "Документы"
        }
    }

    var nearbyCategory: PlaceCategory {
        switch self {
        case .municipality, .bsnRegistration, .documents: return .municipality
        case .languageLearning: return .education
        case .library: return .library
        case .healthcare: return .healthcare
        case .hospital: return .hospital
        case .legalHelp, .taxes, .housing: return .legalHelp
        case .transport: return .transport
        case .police, .emergency: return .police
        case .community, .family: return .communitySupport
        case .student: return .studentHelp
        case .work, .uwv: return .uwv
        case .lgbtq: return .lgbtqSupport
        }
    }

    var iconName: String {
        switch self {
        case .municipality, .bsnRegistration: return "building.columns.fill"
        case .languageLearning, .library: return "books.vertical.fill"
        case .healthcare, .hospital: return "cross.case.fill"
        case .legalHelp: return "scalemass.fill"
        case .transport: return "tram.fill"
        case .police: return "shield.lefthalf.filled"
        case .emergency: return "phone.badge.waveform.fill"
        case .community, .family, .student: return "person.3.fill"
        case .work, .uwv: return "briefcase.fill"
        case .taxes: return "doc.text.fill"
        case .lgbtq: return "checkmark.shield.fill"
        case .housing: return "house.fill"
        case .documents: return "folder.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .municipality, .bsnRegistration, .documents: return AppColors.accent
        case .languageLearning, .library, .student: return AppColors.softBlue
        case .healthcare, .hospital: return AppColors.success
        case .legalHelp, .taxes, .housing: return AppColors.violet
        case .transport: return AppColors.routeLine
        case .police, .emergency: return AppColors.warning
        case .community, .family, .lgbtq: return AppColors.emerald
        case .work, .uwv: return AppColors.dutchOrange
        }
    }
}

enum NewcomerPlaceSourceType: String {
    case official
    case municipal
    case publicService
    case community
    case referenceOnly
}

enum NewcomerPlaceConfidenceLevel: String {
    case verified
    case needsManualVerification
    case generalReference

    func localized(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.verified, .english): return "Official source linked"
        case (.verified, .dutch): return "Officiele bron gekoppeld"
        case (.verified, .russian): return "Есть официальная ссылка"
        case (.needsManualVerification, .english): return "Check source before visiting"
        case (.needsManualVerification, .dutch): return "Controleer de bron voor bezoek"
        case (.needsManualVerification, .russian): return "Проверьте источник перед визитом"
        case (.generalReference, .english): return "General guide"
        case (.generalReference, .dutch): return "Algemene gids"
        case (.generalReference, .russian): return "Общий ориентир"
        }
    }
}

struct NewcomerPlace: Identifiable {
    let id: String
    let localizedTitle: LocalizedCityText
    let localizedDescription: LocalizedCityText
    let category: NewcomerPlaceCategory
    let cityId: String
    let officialWebsiteURL: URL?
    let mapQuery: String
    let sourceType: NewcomerPlaceSourceType
    let confidenceLevel: NewcomerPlaceConfidenceLevel
    let iconName: String
    let accentColor: Color
    let tags: [LocalizedCityText]

    func title(_ lang: AppLanguage) -> String { localizedTitle.value(for: lang) }
    func description(_ lang: AppLanguage) -> String { localizedDescription.value(for: lang) }
    func localizedTags(_ lang: AppLanguage) -> [String] { tags.map { $0.value(for: lang) } }
}

extension NearbyPlace {
    init(newcomerPlace place: NewcomerPlace, cityCenter: CLLocationCoordinate2D) {
        self.init(
            name: place.localizedTitle.english,
            localizedNameText: place.localizedTitle,
            localizedDescriptionText: place.localizedDescription,
            localizedUseCaseText: LocalizedCityText(
                english: place.localizedTags(.english).joined(separator: " • "),
                dutch: place.localizedTags(.dutch).joined(separator: " • "),
                russian: place.localizedTags(.russian).joined(separator: " • ")
            ),
            category: place.category.nearbyCategory,
            description: place.localizedDescription.english,
            newcomerUseCase: place.localizedTags(.english).joined(separator: " • "),
            coordinate: cityCenter,
            address: "Reference map query: \(place.mapQuery)",
            openingHoursPlaceholder: "No opening hours in app — verify official source before visiting.",
            websiteURL: place.officialWebsiteURL,
            phone: nil,
            isOfficialSource: place.confidenceLevel == .verified,
            sourceLabel: place.confidenceLevel == .verified ? "Official source" : "Reference data",
            lastUpdated: "2026-05",
            city: place.cityId,
            trustNote: "Reference / general guide. Use the official source or map query to verify location, appointments, and requirements before visiting.",
            emergencyNote: place.category == .emergency || place.category == .police ? "For immediate danger or urgent emergency help, use 112. For non-urgent questions, use official police or municipality channels." : nil,
            isReferenceLocation: true
        )
    }
}
