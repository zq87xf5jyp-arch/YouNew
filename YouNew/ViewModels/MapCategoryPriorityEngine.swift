import Foundation

enum MapCategoryPriorityEngine {
    static func prioritizedCategories(for status: UserStatus) -> [PlaceCategory] {
        switch status {
        case .refugee:
            return [.legalHelp, .immigrationSupport, .municipality, .healthcare, .communitySupport]
        case .ukrainian:
            return [.immigrationSupport, .municipality, .legalHelp, .healthcare, .communitySupport]
        case .student:
            return [.studentHelp, .education, .library, .transport, .municipality]
        case .worker:
            return [.municipality, .transport, .legalHelp, .healthcare, .communitySupport]
        case .expat:
            return [.expatCenter, .municipality, .immigrationSupport, .legalHelp, .healthcare]
        case .highlySkilledMigrant:
            return [.expatCenter, .immigrationSupport, .municipality, .healthcare, .legalHelp]
        case .euCitizen:
            return [.municipality, .healthcare, .transport, .communitySupport, .legalHelp]
        case .family:
            return [.healthcare, .education, .municipality, .communitySupport, .transport]
        case .tourist:
            return [.transport, .healthcare, .police, .municipality, .legalHelp]
        case .entrepreneur:
            return [.municipality, .legalHelp, .communitySupport, .transport, .healthcare]
        case .lgbtNewcomer:
            return [.communitySupport, .healthcare, .legalHelp, .municipality, .police]
        }
    }

    static func primaryCategory(for status: UserStatus) -> PlaceCategory {
        prioritizedCategories(for: status).first ?? .municipality
    }
}
