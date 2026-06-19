import Testing
@testable import YouNew

@MainActor
struct PriorityCityLocalizationTests {
    private let priorityCityIds = [
        "amsterdam",
        "rotterdam",
        "den-haag",
        "utrecht",
        "leiden",
        "eindhoven",
        "groningen",
        "maastricht"
    ]

    @Test func priorityCitiesHaveLocalizedDescriptionsAndHistory() throws {
        for city in NLCity.all.filter({ priorityCityIds.contains($0.id) }) {
            let englishDescription = city.desc(lang: .english)
            let dutchDescription = city.desc(lang: .dutch)
            let russianDescription = city.desc(lang: .russian)

            #expect(!englishDescription.isEmpty)
            #expect(!dutchDescription.isEmpty)
            #expect(!russianDescription.isEmpty)
            #expect(dutchDescription != englishDescription)
            #expect(russianDescription != englishDescription)
            #expect(!containsCyrillic(englishDescription))
            #expect(!containsCyrillic(dutchDescription))
            #expect(containsCyrillic(russianDescription))

            #expect(city.hist(lang: .dutch) != city.hist(lang: .english))
            #expect(city.hist(lang: .russian) != city.hist(lang: .english))
            #expect(containsCyrillic(city.hist(lang: .russian)))
        }
    }

    @Test func priorityCityHighlightsAndLivingCopyAreLocalized() {
        for city in NLCity.all.filter({ priorityCityIds.contains($0.id) }) {
            #expect(city.highlights(lang: .english).isEmpty == false)
            #expect(city.highlights(lang: .dutch).isEmpty == false)
            #expect(city.highlights(lang: .russian).isEmpty == false)
            #expect(city.highlights(lang: .dutch) != city.highlights(lang: .english))
            #expect(city.highlights(lang: .russian) != city.highlights(lang: .english))
            #expect(containsCyrillic(city.highlights(lang: .russian).joined(separator: " ")))

            #expect(city.expat(lang: .dutch) != city.expat(lang: .english))
            #expect(city.transport(lang: .russian) != city.transport(lang: .english))
            #expect(containsCyrillic(city.transport(lang: .russian)))
        }
    }

    @Test func cityDetailVisibleLabelsAreLocalized() {
        let keys: [CityDetailTextKey] = [
            .overview,
            .history,
            .places,
            .life,
            .back,
            .population,
            .area,
            .founded,
            .highlights,
            .cityFlag,
            .forInternationals,
            .transport,
            .services,
            .postalCode,
            .coordinates,
            .phone
        ]

        for key in keys {
            let english = cityDetailText(key, .english)
            let dutch = cityDetailText(key, .dutch)
            let russian = cityDetailText(key, .russian)

            #expect(!english.isEmpty)
            #expect(!dutch.isEmpty)
            #expect(!russian.isEmpty)
            #expect(!containsCyrillic(english))
            #expect(!containsCyrillic(dutch))
            #expect(containsCyrillic(russian) || key == .transport)
        }
    }

    @Test func factLabelsAreLocalizedForSupportedLanguages() {
        let facts = [
            CityFact(icon: "", label: "City rank", value: ""),
            CityFact(icon: "", label: "Port cargo", value: ""),
            CityFact(icon: "", label: "Students", value: ""),
            CityFact(icon: "", label: "University", value: ""),
            CityFact(icon: "", label: "Design Week", value: "")
        ]

        for fact in facts {
            #expect(fact.label(.english) == fact.label)
            #expect(fact.label(.dutch) != fact.label || fact.label == "Design Week")
            #expect(fact.label(.russian) != fact.label)
            #expect(containsCyrillic(fact.label(.russian)))
        }
    }

    private func containsCyrillic(_ value: String) -> Bool {
        value.unicodeScalars.contains { scalar in
            (0x0400...0x04FF).contains(Int(scalar.value))
        }
    }
}
