import Testing
import Foundation
import CoreLocation
@testable import YouNew

struct ContentExpansionCompletenessTests {
    @Test func knowledgePlatformCoversRequestedCoreCategories() {
        let categories = Set(MockExpansionData.knowledgeTopics.map(\.category))
        let requiredCategories: Set<String> = [
            "Transport",
            "Housing",
            "Healthcare",
            "Emergency",
            "Government",
            "Documents",
            "Taxes",
            "Benefits",
            "Education",
            "Universities",
            "Language",
            "Work",
            "Business",
            "Banking",
            "Insurance",
            "Driving",
            "Shopping",
            "Food",
            "Restaurants",
            "Cafes",
            "Nature",
            "Museums",
            "Culture",
            "Events",
            "Weather",
            "Tourism",
            "Family",
            "Children",
            "Pets",
            "LGBTQ+",
            "Safety",
            "Utilities",
            "Digital Services",
            "Communication"
        ]

        #expect(requiredCategories.isSubset(of: categories))
    }

    @Test func expandedKnowledgeTopicsAreActionableAndSourceBacked() {
        for topic in MockExpansionData.knowledgeTopics {
            #expect(topic.practicalSteps.count >= 3, "Missing action steps for \(topic.title)")
            #expect(!topic.relatedQuestions.isEmpty, "Missing related questions for \(topic.title)")
            #expect(!topic.tags.isEmpty, "Missing search tags for \(topic.title)")
            #expect(topic.officialSourceURL.scheme == "https", "Non-HTTPS source for \(topic.title)")
            #expect(topic.officialSourceURL.host?.isEmpty == false, "Missing source host for \(topic.title)")
            #expect(!topic.safetyDisclaimer.isEmpty, "Missing safety disclaimer for \(topic.title)")
        }
    }

    @Test func localPartnersCoverRequestedCommercialDirectoryTypes() {
        let subcategories = Set(MockLocalPartnersData.partners.map(\.subcategory))
        let requiredSubcategories: Set<String> = [
            "Hotels",
            "Restaurants",
            "Cafes",
            "Clinics",
            "Dentists",
            "Lawyers",
            "Banks",
            "Insurance",
            "Bike Rental",
            "Taxi",
            "Real Estate",
            "Dutch Language Schools",
            "Universities",
            "Gyms",
            "Shopping",
            "Beauty",
            "Cleaning",
            "Moving Companies"
        ]

        #expect(requiredSubcategories.isSubset(of: subcategories))
    }

    @Test func localPartnersUseRealRecognizableOrganizationsInsteadOfTemplates() {
        let partnerNames = Set(MockLocalPartnersData.partners.map(\.name))
        let requestedRealPartners: Set<String> = [
            "Van der Valk Hotel Amsterdam-Amstel",
            "citizenM Amsterdam South",
            "Albert Heijn Amsterdam",
            "Lidl Amsterdam",
            "Jumbo Amsterdam",
            "Basic-Fit Amsterdam",
            "McDonald's Amsterdam",
            "Leiden University",
            "Amsterdam UMC",
            "Erasmus MC",
            "IKEA Amsterdam",
            "NS Service Point Amsterdam Centraal",
            "GVB Service & Tickets Amsterdam Centraal",
            "IND Desk Amsterdam",
            "Municipality Eindhoven Service Center"
        ]

        #expect(requestedRealPartners.isSubset(of: partnerNames))

        for partner in MockLocalPartnersData.partners {
            #expect(!partner.name.localizedCaseInsensitiveContains("template"), "Template partner visible: \(partner.name)")
            #expect(!partner.name.localizedCaseInsensitiveContains("finder"), "Finder placeholder visible: \(partner.name)")
            #expect(!partner.name.localizedCaseInsensitiveContains("guide"), "Guide placeholder visible: \(partner.name)")
            #expect(!partner.name.localizedCaseInsensitiveContains("directory"), "Directory placeholder visible: \(partner.name)")
            #expect(partner.website.host?.localizedCaseInsensitiveContains("example.com") != true, "Example URL visible for \(partner.name)")
        }
    }

    @Test func localPartnerCardsExposeRealDatabaseQualityFields() {
        for partner in MockLocalPartnersData.partners {
            #expect(!partner.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Missing name")
            #expect(!partner.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Missing description for \(partner.name)")
            #expect(!partner.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Missing address for \(partner.name)")
            #expect(abs(partner.coordinate.latitude) > 0.1, "Missing latitude for \(partner.name)")
            #expect(abs(partner.coordinate.longitude) > 0.1, "Missing longitude for \(partner.name)")
            #expect(partner.website.scheme == "https", "Website must be HTTPS for \(partner.name)")
            #expect(!partner.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Missing phone for \(partner.name)")
            #expect(!partner.openingHours.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Missing opening hours for \(partner.name)")
            #expect(!partner.languages.isEmpty, "Missing service languages for \(partner.name)")
            #expect(partner.officialSource.url?.scheme == "https", "Missing HTTPS official source for \(partner.name)")
            #expect(!partner.sourceReliabilityNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Missing source note for \(partner.name)")

            let mediaRoles = Set(partner.media.allAssets.map(\.role))
            #expect(mediaRoles.isSuperset(of: Set(LocalPartnerVisualRole.allCases)), "Missing visual roles for \(partner.name)")
            #expect(partner.media.allAssets.allSatisfy { $0.url.scheme == "https" }, "Visual source URLs must be HTTPS for \(partner.name)")
            #expect(partner.media.allAssets.allSatisfy { !$0.altText.isEmpty }, "Missing visual alt text for \(partner.name)")
        }
    }

    @Test func expandedSearchFindsNewCategoryAndPartnerContent() {
        let search = AppSearchEngine()

        #expect(search.search("weather warning", language: .english, activePersona: .tourist).contains {
            $0.item.title(.english) == "Weather Planning"
        })
        #expect(search.search("pets vet microchip", language: .english, activePersona: .family).contains {
            $0.item.title(.english) == "Pets in the Netherlands"
        })
        #expect(search.search("taxi Rotterdam", language: .english, activePersona: .tourist).contains {
            $0.item.type == .localPartner && $0.item.city == "Rotterdam" && $0.item.category == "Taxi"
        })
        #expect(search.search("cleaning Eindhoven", language: .english, activePersona: .worker).contains {
            $0.item.type == .localPartner && $0.item.city == "Eindhoven" && $0.item.category == "Cleaning"
        })
        #expect(search.search("Van der Valk Amsterdam", language: .english, activePersona: .tourist).contains {
            $0.item.type == .localPartner && $0.item.title(.english) == "Van der Valk Hotel Amsterdam-Amstel"
        })
        #expect(search.search("Leiden University", language: .english, activePersona: .student).contains {
            $0.item.type == .localPartner && $0.item.title(.english) == "Leiden University"
        })
        #expect(search.search("IND desk Amsterdam", language: .english, activePersona: .nonEU).contains {
            $0.item.type == .localPartner && $0.item.title(.english) == "IND Desk Amsterdam"
        })
        #expect(search.search("IKEA Amsterdam", language: .english, activePersona: .student).contains {
            $0.item.type == .localPartner && $0.item.title(.english) == "IKEA Amsterdam"
        })
    }
}
