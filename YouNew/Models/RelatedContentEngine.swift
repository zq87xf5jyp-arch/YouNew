import Foundation

struct RelatedNavigationItem: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let destination: AppDestination
}

enum RelatedContentEngine {
    static func isVisible(_ destination: AppDestination, for persona: PersonaTag?) -> Bool {
        // Audience metadata ranks recommendations; it never restricts navigation.
        // Entity-backed routes must still resolve to a canonical object so that
        // saved items, search results, and AI deep links cannot open dead screens.
        switch destination {
        case .knmModule(let moduleID):
            return KNMGuideData.module(with: moduleID) != nil
        case .dutchA1A2Module(let moduleID):
            return DutchA1A2CourseData.module(with: moduleID) != nil
        case .checklist(let id):
            return MockChecklistData.items.contains { $0.id == id }
        case .institution(let name):
            return MockInstitutionsData.items.contains { $0.name.caseInsensitiveCompare(name) == .orderedSame }
        case .searchAnswer(let id):
            return MockSearchAnswersData.items.contains { $0.id == id }
        case .beginnerGuide(let id):
            return MockBeginnerGuidesData.items.contains { $0.id == id }
        case .resource(let id):
            return MockResourcesData.items.contains { $0.id == id }
        case .mistake(let id):
            return MockNewcomerMistakesData.items.contains { $0.id == id }
        case .dutchTerm(let id):
            return MockDutchTermsData.items.contains { $0.id == id }
        case .fineInfo(let id):
            return MockFineInfoData.items.contains { $0.id == id }
        case .letter(let title):
            return MockLettersData.examples.contains { $0.title.caseInsensitiveCompare(title) == .orderedSame }
        case .ruleTopic(let id):
            return MockRulesGuideData.topics.contains { $0.id == id }
        case .ruleScenario(let id):
            return MockRulesGuideData.scenarios.contains { $0.id == id }
        case .guideSection(let id):
            return GuideContent.section(id: id) != nil
        case .guideArticle(let sectionID, let articleID):
            if sectionID == GuideContent.dataProjectSectionID {
                return ContentRepository.shared.item(id: articleID)?.status == .published
            }
            return GuideContent.article(sectionID: sectionID, articleID: articleID) != nil
        case .workSection(let type):
            switch type {
            case .overview: return GuideContent.section(id: "work") != nil
            case .permitsAndRights: return GuideContent.article(sectionID: "work", articleID: "working-permit") != nil
            case .salaryTaxes: return GuideContent.article(sectionID: "work", articleID: "salary-taxes") != nil
            case .jobSearch: return GuideContent.article(sectionID: "work", articleID: "job-search-nl") != nil
            }
        case .healthSection(let type):
            switch type {
            case .overview: return GuideContent.section(id: "healthcare") != nil
            case .insurance: return GuideContent.article(sectionID: "healthcare", articleID: "insurance") != nil
            case .huisarts: return GuideContent.article(sectionID: "healthcare", articleID: "huisarts") != nil
            case .urgentCare: return GuideContent.article(sectionID: "healthcare", articleID: "urgent-care") != nil
            }
        case .placeDetail(let id):
            return DashboardPlacesData.detailPlace(id: id) != nil
        case .calendarEvent(let id):
            return DashboardCalendarData.detailEvent(id: id) != nil
        case .mapFocus(.place(let placeID)):
            return MockNearbyPlacesData.places.contains { $0.saveKey == placeID || $0.id.uuidString == placeID }
                || MockLocalPartnersData.partners.contains { $0.mapPlace.saveKey == placeID || $0.id == placeID }
        default:
            return true
        }
        /* Legacy existence/persona matrix retained temporarily for migration reference.
        switch destination {
        case .settings, .profileSelection, .savedTopics, .recentlyViewedTopics, .resourcesHub, .localPartners, .localPartnerDetail, .businessGrowth, .businessLogin, .businessDashboard, .finesAndLettersHub, .legalHelp, .aboutYouNew, .supportFeedback, .privacyDataControl, .termsOfUse, .legalDisclaimer, .assistantHub, .searchList:
            return true
        case .categoriesHub:
            return persona != nil
        case .checklistList:
            return MockChecklistData.items.contains { $0.isVisible(for: persona, scope: .currentAndUniversal) }
        case .institutionsList:
            return MockInstitutionsData.items.contains { $0.isVisible(for: persona, scope: .currentAndUniversal) }
        case .officialSources:
            return true
        case .finesList, .scamWarningsList, .scamWarning:
            return isPersona(persona, in: [.worker, .tourist, .entrepreneur, .eu, .highlySkilledMigrant])
        case .lettersList, .journeyDocuments:
            return isPersona(persona, in: [.worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt])
        case .dutchTermsList, .languageHub, .dutchA1A2:
            return isPersona(persona, in: [.student, .refugee, .worker, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt])
        case .dutchA1A2Module(let moduleID):
            return DutchA1A2CourseData.module(with: moduleID) != nil
                && isPersona(persona, in: [.student, .refugee, .worker, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt])
        case .mistakesList:
            return isPersona(persona, in: [.worker, .refugee, .family, .tourist, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt])
        case .beginnerGuidesList, .firstSteps:
            return persona != nil
        case .survivalHub:
            return isPersona(persona, in: [.refugee, .nonEU, .lgbt])
        case .emotionalSupport:
            return isPersona(persona, in: [.refugee, .family, .lgbt])
        case .lgbtqSupport:
            return persona == .lgbt
        case .mapHub:
            return true
        case .mapFocus(.place(let placeId)):
            return MockNearbyPlacesData.places.contains {
                ($0.saveKey == placeId || $0.id.uuidString == placeId) && $0.isVisible(for: persona)
            } || MockLocalPartnersData.partners.contains {
                $0.mapPlace.saveKey == placeId || $0.id == placeId
            }
        case .mapFocus(let focus):
            return isMapFocus(focus, visibleFor: persona)
        case .informationHub:
            return persona != nil
        case .knm:
            return isPersona(persona, in: [.refugee, .nonEU, .family, .lgbt])
        case .knmModule(let moduleID):
            return KNMGuideData.module(with: moduleID) != nil
                && isPersona(persona, in: [.refugee, .nonEU, .family, .lgbt])
        case .practicalGuide(let topic):
            return isPracticalGuide(topic, visibleFor: persona)
        case .netherlandsOverview, .netherlandsHistory, .historyKNMHub, .dutchHolidays, .dutchFigures, .dutchMonarchy:
            return isPersona(persona, in: [.tourist, .family, .refugee, .eu, .nonEU])
        case .cultureAttractions, .cityList, .provinceList, .provinceDetail, .provinceCities, .cityDetail, .discoveryList, .nlCityDetail:
            return true
        case .netherlandsCalendar:
            return isPersona(persona, in: [.tourist, .student, .worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt])
        case .placeDetail(let id):
            return DashboardPlacesData.places.contains {
                $0.id == id && ContentAccessPolicy.canShowToUser(audience: $0.audience, selectedPersona: persona)
            }
        case .calendarEvent(let id):
            return DashboardCalendarData.events.contains {
                $0.id == id && ContentAccessPolicy.canShowToUser(audience: $0.audience, selectedPersona: persona)
            }
        case .governmentHub:
            return isPersona(persona, in: [.worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt])
        case .helpHub:
            return isPersona(persona, in: [.refugee, .family, .tourist, .lgbt, .nonEU])
        case .emergencyHub:
            return isPersona(persona, in: [.tourist, .refugee, .family, .lgbt, .student, .worker, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur])
        case .checklist(let id):
            return MockChecklistData.items.contains {
                $0.id == id && $0.isVisible(for: persona, scope: .currentAndUniversal)
            }
        case .institution(let name):
            return MockInstitutionsData.items.contains {
                $0.name.caseInsensitiveCompare(name) == .orderedSame &&
                $0.isVisible(for: persona, scope: .currentAndUniversal)
            }
        case .searchAnswer(let id):
            return MockSearchAnswersData.items.contains {
                $0.id == id && $0.isVisible(for: persona, scope: .currentAndUniversal)
            }
        case .statusDirection(let status):
            guard let persona else { return true }
            return status.personaTag == persona
        case .beginnerGuide(let id):
            return MockBeginnerGuidesData.items.contains {
                $0.id == id && $0.isVisible(for: persona, scope: .currentAndUniversal)
            }
        case .resource(let id):
            return MockResourcesData.items.contains {
                $0.id == id && $0.isVisible(for: persona, scope: .currentAndUniversal)
            }
        case .mistake(let id):
            return MockNewcomerMistakesData.items.contains {
                $0.id == id && $0.isVisible(for: persona, scope: .currentAndUniversal)
            }
        case .dutchTerm(let id):
            return MockDutchTermsData.items.contains {
                $0.id == id && $0.isVisible(for: persona, scope: .currentAndUniversal)
            }
        case .fineInfo(let id):
            return MockFineInfoData.items.contains {
                $0.id == id && $0.isVisible(for: persona, scope: .currentAndUniversal)
            }
        case .letter(let title):
            return MockLettersData.examples.contains {
                $0.title.caseInsensitiveCompare(title) == .orderedSame &&
                $0.isVisible(for: persona, scope: .currentAndUniversal)
            }
        case .ruleTopic(let id):
            return MockRulesGuideData.topics.contains {
                $0.id == id && $0.isVisible(for: persona, scope: .currentAndUniversal)
            }
        case .ruleScenario(let id):
            return MockRulesGuideData.scenarios.contains {
                $0.id == id && $0.isVisible(for: persona, scope: .currentAndUniversal)
            }
        case .guideSection(let id):
            return GuideContent.section(id: id, activePersona: persona) != nil
        case .guideArticle(let sectionID, let articleID):
            return GuideContent.article(sectionID: sectionID, articleID: articleID, activePersona: persona) != nil
        default:
            return true
        }
        */
    }

    private static func isPracticalGuide(_ topic: PracticalGuideTopic, visibleFor persona: PersonaTag?) -> Bool {
        switch topic {
        case .firstStepsNetherlands:
            return persona != nil
        case .municipalityRegistration, .digidSafety, .officialSourcesChecklist:
            return isPersona(persona, in: [.worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt])
        case .healthcareBasics, .findingHuisarts:
            return isPersona(persona, in: [.student, .worker, .refugee, .family, .tourist, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt])
        case .healthInsuranceBasics:
            return isPersona(persona, in: [.student, .worker, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt])
        case .transportBasics, .housingBasics:
            return isPersona(persona, in: [.student, .worker, .refugee, .family, .tourist, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt])
        case .bankingBasics:
            return isPersona(persona, in: [.worker, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant])
        }
    }

    private static func isMapFocus(_ focus: MapFocus, visibleFor persona: PersonaTag?) -> Bool {
        switch focus {
        case .transport:
            return isPersona(persona, in: [.student, .worker, .refugee, .family, .tourist, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant])
        case .healthcare:
            return isPersona(persona, in: [.worker, .refugee, .family, .tourist, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant])
        case .government:
            return isPersona(persona, in: [.worker, .refugee, .family, .tourist, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant])
        case .education:
            return isPersona(persona, in: [.student, .refugee, .family, .lgbt, .eu, .nonEU, .highlySkilledMigrant])
        case .emergency:
            return isPersona(persona, in: [.student, .worker, .refugee, .family, .tourist, .entrepreneur, .lgbt, .eu, .nonEU, .highlySkilledMigrant])
        case .category(let category):
            return MockNearbyPlacesData.places.contains {
                $0.category == category && $0.isVisible(for: persona)
            }
        case .city, .province:
            return true
        case .place(let placeId):
            return MockNearbyPlacesData.places.contains {
                ($0.saveKey == placeId || $0.id.uuidString == placeId) && $0.isVisible(for: persona)
            }
        }
    }

    private static func isPersona(_ persona: PersonaTag?, in allowed: Set<PersonaTag>) -> Bool {
        guard let persona else { return false }
        return allowed.contains(persona)
    }

    static func relatedArticles(cityId: String) -> [InfoArticle] {
        let profile = MockNetherlandsUnderstandingData.cityInfoProfile(matching: cityId)
        let ids = Set((profile?.articleIds ?? []) + (profile?.attractionIds ?? []))
        let direct = (MockNetherlandsUnderstandingData.cultureArticles + MockNetherlandsUnderstandingData.attractionArticles).filter { ids.contains($0.id) }
        if !direct.isEmpty { return direct }
        return (MockNetherlandsUnderstandingData.cultureArticles + MockNetherlandsUnderstandingData.attractionArticles)
            .filter { $0.relatedPlaceIds.contains(where: { $0.caseInsensitiveCompare(cityId) == .orderedSame }) }
    }

    static func relatedSources(cityId: String) -> [InfoSourceMetadata] {
        guard let profile = MockNetherlandsUnderstandingData.cityInfoProfile(matching: cityId) else { return [] }
        return MockNetherlandsUnderstandingData.sources(for: profile.officialSourceIds)
    }

    static func relatedGuides(cityId: String) -> [PracticalGuideTopic] {
        guard let profile = MockNetherlandsUnderstandingData.cityInfoProfile(matching: cityId) else { return [] }
        return profile.practicalGuideIds.compactMap(PracticalGuideTopic.init(rawValue:))
    }

    // MARK: - People Also Search

    static func peopleAlsoSearch(for answer: SearchAnswer) -> [SearchAnswer] {
        answer.relatedQuestions.compactMap { question in
            MockSearchAnswersData.items.first { $0.question.caseInsensitiveCompare(question) == .orderedSame }
        }
    }

    // MARK: - Common Mistakes

    static func commonMistakes(for answer: SearchAnswer) -> [NewcomerMistake] {
        let byCategory = MockNewcomerMistakesData.items.filter { $0.category == mistakeCategory(for: answer.category) }
        if !byCategory.isEmpty { return Array(byCategory.prefix(3)) }
        return Array(MockNewcomerMistakesData.items.filter {
            matches($0.title, answer.question) || matches($0.whyItMatters, answer.detailedAnswer)
        }.prefix(3))
    }

    static func commonMistakes(for item: ChecklistItem) -> [NewcomerMistake] {
        let byCategory = MockNewcomerMistakesData.items.filter { checklistMistakeMatch($0.category, item.category) }
        if !byCategory.isEmpty { return Array(byCategory.prefix(3)) }
        return Array(MockNewcomerMistakesData.items.filter {
            matches($0.title, item.title) || matches($0.whyItMatters, item.description)
        }.prefix(3))
    }

    static func commonMistakes(for institution: Institution) -> [NewcomerMistake] {
        Array(MockNewcomerMistakesData.items.filter {
            matches($0.title, institution.name) ||
            matches($0.whyItMatters, institution.name) ||
            matches($0.howToPrevent, institution.name)
        }.prefix(3))
    }

    static func commonMistakes(for term: DutchTerm) -> [NewcomerMistake] {
        if !term.relatedMistakeIDs.isEmpty {
            let explicit = MockNewcomerMistakesData.items.filter { term.relatedMistakeIDs.contains($0.id) }
            if !explicit.isEmpty { return explicit }
        }
        return Array(MockNewcomerMistakesData.items.filter {
            matches($0.title, term.dutchTerm) || matches($0.whyItMatters, term.newcomerExplanation)
        }.prefix(3))
    }

    static func commonMistakes(for fine: FineInfoItem) -> [NewcomerMistake] {
        let byCategory = MockNewcomerMistakesData.items.filter {
            matches($0.category.rawValue, fine.category.rawValue)
        }
        if !byCategory.isEmpty { return Array(byCategory.prefix(3)) }
        return Array(MockNewcomerMistakesData.items.filter {
            matches($0.title, fine.title) || matches($0.whyItMatters, fine.simpleExplanation)
        }.prefix(3))
    }

    static func commonMistakes(for letter: LetterExample) -> [NewcomerMistake] {
        let byLetters = MockNewcomerMistakesData.items.filter { $0.category == .legalLetters }
        if !byLetters.isEmpty { return Array(byLetters.prefix(2)) }
        return Array(MockNewcomerMistakesData.items.filter {
            matches($0.title, letter.title) || matches($0.whyItMatters, letter.institutionName)
        }.prefix(3))
    }

    // MARK: - Next Recommended Step Text

    static func nextRecommendedStepText(for answer: SearchAnswer) -> String {
        nextRecommendedStepText(for: answer, language: .english)
    }

    static func nextRecommendedStepText(for answer: SearchAnswer, language: AppLanguage) -> String {
        if language == .english, let step = answer.nextRecommendedStep, !step.isEmpty { return step }
        switch language {
        case .russian:
            switch answer.category {
            case .registration:    return "Откройте чеклист и завершите шаг регистрации в gemeente."
            case .digid:           return "Активируйте DigiD и используйте только официальный сайт DigiD."
            case .immigration:     return "Проверьте маршрут IND и требования к документам на IND.nl."
            case .taxes:           return "Проверьте сроки и номера писем в Belastingdienst."
            case .fines:           return "Перед оплатой или обжалованием проверьте официальный источник CJIB."
            case .healthInsurance: return "Уточните, обязательна ли страховка в вашей ситуации."
            case .work:            return "Проверьте договор и сохраняйте расчетные листы."
            case .education:       return "Проверьте процессы DUO и свои учебные обязательства."
            case .housing:         return "Проверьте местные правила регистрации адреса."
            case .transport:       return "Проверьте правила RDW или транспорта для вашей ситуации."
            case .legalHelp:       return "Подготовьте документы перед обращением за юридической помощью."
            case .emergency:       return "Сохраните экстренные номера и неэкстренные альтернативы."
            case .general:         return "Откройте официальный источник и проверьте актуальные правила."
            }
        case .dutch:
            switch answer.category {
            case .registration:    return "Open de checklist en rond de gemeentelijke registratie af."
            case .digid:           return "Activeer DigiD en gebruik alleen officiële DigiD-pagina's."
            case .immigration:     return "Controleer uw IND-route en documentvereisten op IND.nl."
            case .taxes:           return "Controleer actuele deadlines en kenmerkgegevens bij Belastingdienst."
            case .fines:           return "Controleer officiële CJIB-informatie voordat u betaalt of bezwaar maakt."
            case .healthInsurance: return "Controleer of zorgverzekering verplicht is voor uw situatie."
            case .work:            return "Controleer uw contract en bewaar loonstroken."
            case .education:       return "Controleer DUO-processen en uw studentenverplichtingen."
            case .housing:         return "Controleer lokale regels voor adresregistratie."
            case .transport:       return "Controleer RDW- of vervoersregels die voor u gelden."
            case .legalHelp:       return "Bereid uw documenten voor voordat u juridische hulp vraagt."
            case .emergency:       return "Bewaar noodnummers en bekijk niet-spoedeisende alternatieven."
            case .general:         return "Open de officiële bron en controleer de actuele regels."
            }
        case .english:
            switch answer.category {
            case .registration:    return "Open Checklist and complete your municipality registration step."
            case .digid:           return "Activate DigiD and verify you only use official DigiD pages."
            case .immigration:     return "Review your IND route and verify document requirements on IND.nl."
            case .taxes:           return "Check Belastingdienst for current deadlines and references."
            case .fines:           return "Open official CJIB guidance before paying or objecting."
            case .healthInsurance: return "Confirm whether health insurance is mandatory for your situation."
            case .work:            return "Review work contract basics and keep payslip records."
            case .education:       return "Check DUO processes and confirm your student obligations."
            case .housing:         return "Verify local municipality rules for address registration."
            case .transport:       return "Check RDW or official transport rules relevant to your case."
            case .legalHelp:       return "Prepare your documents and contact a legal help channel."
            case .emergency:       return "Save emergency numbers and review non-urgent alternatives."
            case .general:         return "Open the related official source and validate this guidance."
            }
        }
    }

    // MARK: - Related Items: SearchAnswer

    static func relatedItems(for answer: SearchAnswer) -> [RelatedNavigationItem] {
        var items: [RelatedNavigationItem] = []

        let institutionNames = answer.relatedInstitutionNames.isEmpty
            ? [answer.relatedInstitution].compactMap { $0 }
            : answer.relatedInstitutionNames
        for name in institutionNames {
            guard let inst = MockInstitutionsData.items.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) else { continue }
            items.append(.init(id: "institution-\(inst.name)", title: inst.name, subtitle: "Institution", symbol: "building.columns", destination: .institution(inst.name)))
        }

        let termIDs = answer.relatedTermIDs.isEmpty ? explicitTermIDsForSearchAnswer(answer) : answer.relatedTermIDs
        let explicitTerms = MockDutchTermsData.items.filter { termIDs.contains($0.id) }
        for term in explicitTerms.prefix(2) {
            items.append(.init(id: "term-\(term.id.uuidString)", title: term.dutchTerm, subtitle: "Glossary term", symbol: "book.closed", destination: .dutchTerm(term.id)))
        }
        if explicitTerms.isEmpty {
            for term in MockDutchTermsData.items.filter({ matches($0.newcomerExplanation, answer.question) || matches(answer.detailedAnswer, $0.dutchTerm) }).prefix(2) {
                items.append(.init(id: "term-\(term.id.uuidString)", title: term.dutchTerm, subtitle: "Glossary term", symbol: "book.closed", destination: .dutchTerm(term.id)))
            }
        }

        let fineIDs = answer.relatedFineIDs.isEmpty ? explicitFineIDsForSearchAnswer(answer) : answer.relatedFineIDs
        let explicitFines = MockFineInfoData.items.filter { fineIDs.contains($0.id) }
        for fine in explicitFines.prefix(1) {
            items.append(.init(id: "fine-\(fine.id.uuidString)", title: fine.title, subtitle: "Related fine guidance", symbol: "exclamationmark.triangle", destination: .fineInfo(fine.id)))
        }
        if explicitFines.isEmpty {
            for fine in MockFineInfoData.items.filter({ matches($0.title, answer.question) || matches($0.simpleExplanation, answer.shortAnswer) }).prefix(1) {
                items.append(.init(id: "fine-\(fine.id.uuidString)", title: fine.title, subtitle: "Related fine guidance", symbol: "exclamationmark.triangle", destination: .fineInfo(fine.id)))
            }
        }

        return deduplicated(items)
    }

    // MARK: - Related Items: ChecklistItem

    static func relatedItems(for item: ChecklistItem) -> [RelatedNavigationItem] {
        var items: [RelatedNavigationItem] = []

        if !item.relatedInstitutionNames.isEmpty {
            for name in item.relatedInstitutionNames {
                if let inst = MockInstitutionsData.items.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
                    items.append(.init(id: "institution-\(inst.name)", title: inst.name, subtitle: "Related institution", symbol: "building.columns", destination: .institution(inst.name)))
                }
            }
        } else if let inst = MockInstitutionsData.items.first(where: {
            matches($0.name, item.title) || matches($0.name, item.description) || matches(item.officialSourceName, $0.name)
        }) {
            items.append(.init(id: "institution-\(inst.name)", title: inst.name, subtitle: "Related institution", symbol: "building.columns", destination: .institution(inst.name)))
        }

        // Related checklist items (explicit)
        for related in MockChecklistData.items.filter({ item.relatedChecklistIDs.contains($0.id) }).prefix(2) {
            items.append(.init(id: "check-\(related.id.uuidString)", title: related.title, subtitle: "Related step", symbol: "checkmark.circle", destination: .checklist(related.id)))
        }

        // Fines
        let explicitFines = MockFineInfoData.items.filter { item.relatedFineIDs.contains($0.id) }
        if !explicitFines.isEmpty {
            for fine in explicitFines.prefix(1) {
                items.append(.init(id: "fine-\(fine.id.uuidString)", title: fine.title, subtitle: "Related fine risk", symbol: "exclamationmark.triangle", destination: .fineInfo(fine.id)))
            }
        } else if let fine = MockFineInfoData.items.first(where: {
            matches($0.title, item.title) || matches($0.simpleExplanation, item.description)
        }) {
            items.append(.init(id: "fine-\(fine.id.uuidString)", title: fine.title, subtitle: "Related fine risk", symbol: "exclamationmark.triangle", destination: .fineInfo(fine.id)))
        }

        // Terms
        let explicitTerms = MockDutchTermsData.items.filter { item.relatedTermIDs.contains($0.id) }
        if !explicitTerms.isEmpty {
            for term in explicitTerms.prefix(2) {
                items.append(.init(id: "term-\(term.id.uuidString)", title: term.dutchTerm, subtitle: "Related glossary term", symbol: "book.closed", destination: .dutchTerm(term.id)))
            }
        } else {
            for term in MockDutchTermsData.items.filter({
                matches($0.dutchTerm, item.title) || matches($0.englishExplanation, item.description)
            }).prefix(2) {
                items.append(.init(id: "term-\(term.id.uuidString)", title: term.dutchTerm, subtitle: "Related glossary term", symbol: "book.closed", destination: .dutchTerm(term.id)))
            }
        }

        // Search answers (explicit)
        for answer in MockSearchAnswersData.items.filter({ item.relatedSearchAnswerIDs.contains($0.id) }).prefix(2) {
            items.append(.init(id: "search-\(answer.id.uuidString)", title: answer.question, subtitle: "Related question", symbol: "magnifyingglass", destination: .searchAnswer(answer.id)))
        }

        return deduplicated(items)
    }

    // MARK: - Related Items: DutchTerm

    static func relatedItems(for term: DutchTerm) -> [RelatedNavigationItem] {
        var items: [RelatedNavigationItem] = []

        if !term.relatedInstitutionNames.isEmpty {
            for name in term.relatedInstitutionNames {
                if let inst = MockInstitutionsData.items.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
                    items.append(.init(id: "institution-\(inst.name)", title: inst.name, subtitle: "Institution", symbol: "building.columns", destination: .institution(inst.name)))
                }
            }
        } else {
            for inst in MockInstitutionsData.items.filter({
                matches($0.name, term.newcomerExplanation) || matches($0.name, term.englishExplanation)
            }).prefix(2) {
                items.append(.init(id: "institution-\(inst.name)", title: inst.name, subtitle: "Institution", symbol: "building.columns", destination: .institution(inst.name)))
            }
        }

        let explicitAnswers = MockSearchAnswersData.items.filter { term.relatedSearchAnswerIDs.contains($0.id) }
        if !explicitAnswers.isEmpty {
            for answer in explicitAnswers.prefix(2) {
                items.append(.init(id: "search-\(answer.id.uuidString)", title: answer.question, subtitle: "Related explanation", symbol: "magnifyingglass", destination: .searchAnswer(answer.id)))
            }
        } else {
            for answer in MockSearchAnswersData.items.filter({
                matches($0.question, term.dutchTerm) || matches($0.detailedAnswer, term.dutchTerm)
            }).prefix(2) {
                items.append(.init(id: "search-\(answer.id.uuidString)", title: answer.question, subtitle: "Related explanation", symbol: "magnifyingglass", destination: .searchAnswer(answer.id)))
            }
        }

        if !term.relatedLetterTitles.isEmpty {
            for title in term.relatedLetterTitles.prefix(2) {
                if let letter = MockLettersData.examples.first(where: { $0.title == title }) {
                    items.append(.init(id: "letter-\(letter.title)", title: letter.title, subtitle: "Letter example", symbol: "envelope", destination: .letter(letter.title)))
                }
            }
        } else {
            for letter in MockLettersData.examples.filter({
                matches($0.simplifiedExplanation, term.dutchTerm) || matches($0.title, term.dutchTerm)
            }).prefix(1) {
                items.append(.init(id: "letter-\(letter.title)", title: letter.title, subtitle: "Letter example", symbol: "envelope", destination: .letter(letter.title)))
            }
        }

        return deduplicated(items)
    }

    // MARK: - Related Items: FineInfoItem

    static func relatedItems(for fine: FineInfoItem) -> [RelatedNavigationItem] {
        var items: [RelatedNavigationItem] = []

        if let inst = MockInstitutionsData.items.first(where: { matches($0.name, fine.officialSourceName) }) {
            items.append(.init(id: "institution-\(inst.name)", title: inst.name, subtitle: "Official institution", symbol: "building.columns", destination: .institution(inst.name)))
        }

        for answer in MockSearchAnswersData.items.filter({
            matches($0.question, fine.title) || matches($0.detailedAnswer, fine.category.rawValue)
        }).prefix(2) {
            items.append(.init(id: "search-\(answer.id.uuidString)", title: answer.question, subtitle: "Payment and legal basics", symbol: "doc.text.magnifyingglass", destination: .searchAnswer(answer.id)))
        }

        if let term = MockDutchTermsData.items.first(where: {
            matches($0.newcomerExplanation, fine.title) || matches(fine.simpleExplanation, $0.dutchTerm)
        }) {
            items.append(.init(id: "term-\(term.id.uuidString)", title: term.dutchTerm, subtitle: "Term in fine letters", symbol: "book.closed", destination: .dutchTerm(term.id)))
        }

        for checklist in MockChecklistData.items.filter({
            matches($0.title, fine.title) || matches($0.description, fine.category.rawValue)
        }).prefix(2) {
            items.append(.init(id: "check-\(checklist.id.uuidString)", title: checklist.title, subtitle: "Step to avoid this fine", symbol: "checkmark.circle", destination: .checklist(checklist.id)))
        }

        return deduplicated(items)
    }

    // MARK: - Related Items: Institution

    static func relatedItems(for institution: Institution) -> [RelatedNavigationItem] {
        var items: [RelatedNavigationItem] = []

        let explicitChecklist = MockChecklistData.items.filter { institution.relatedChecklistIDs.contains($0.id) }
        if !explicitChecklist.isEmpty {
            for item in explicitChecklist.prefix(3) {
                items.append(.init(id: "check-\(item.id.uuidString)", title: item.title, subtitle: "Checklist step", symbol: "checkmark.circle", destination: .checklist(item.id)))
            }
        } else {
            for item in MockChecklistData.items.filter({
                matches($0.title, institution.name) || matches($0.description, institution.name) || matches($0.officialSourceName, institution.name)
            }).prefix(3) {
                items.append(.init(id: "check-\(item.id.uuidString)", title: item.title, subtitle: "Checklist step", symbol: "checkmark.circle", destination: .checklist(item.id)))
            }
        }

        let explicitAnswers = MockSearchAnswersData.items.filter { institution.relatedSearchAnswerIDs.contains($0.id) }
        if !explicitAnswers.isEmpty {
            for answer in explicitAnswers.prefix(3) {
                items.append(.init(id: "search-\(answer.id.uuidString)", title: answer.question, subtitle: "Related question", symbol: "magnifyingglass", destination: .searchAnswer(answer.id)))
            }
        } else {
            for answer in MockSearchAnswersData.items.filter({
                matches($0.relatedInstitution ?? "", institution.name) || matches($0.question, institution.name)
            }).prefix(3) {
                items.append(.init(id: "search-\(answer.id.uuidString)", title: answer.question, subtitle: "Related question", symbol: "magnifyingglass", destination: .searchAnswer(answer.id)))
            }
        }

        for term in MockDutchTermsData.items.filter({ institution.relatedTermIDs.contains($0.id) }).prefix(2) {
            items.append(.init(id: "term-\(term.id.uuidString)", title: term.dutchTerm, subtitle: "Related term", symbol: "book.closed", destination: .dutchTerm(term.id)))
        }

        for title in institution.relatedLetterTitles.prefix(2) {
            if let letter = MockLettersData.examples.first(where: { $0.title == title }) {
                items.append(.init(id: "letter-\(letter.title)", title: letter.title, subtitle: "Letter from this institution", symbol: "envelope", destination: .letter(letter.title)))
            }
        }

        return deduplicated(items)
    }

    // MARK: - Related Items: LetterExample

    static func relatedItems(for letter: LetterExample) -> [RelatedNavigationItem] {
        var items: [RelatedNavigationItem] = []

        if let inst = MockInstitutionsData.items.first(where: { matches($0.name, letter.institutionName) }) {
            items.append(.init(id: "institution-\(inst.name)", title: inst.name, subtitle: "Sender institution", symbol: "building.columns", destination: .institution(inst.name)))
        }

        for term in MockDutchTermsData.items.filter({
            matches(letter.simplifiedExplanation, $0.dutchTerm) || matches($0.newcomerExplanation, letter.simplifiedExplanation)
        }).prefix(2) {
            items.append(.init(id: "term-\(term.id.uuidString)", title: term.dutchTerm, subtitle: "Term in this letter", symbol: "book.closed", destination: .dutchTerm(term.id)))
        }

        for fine in MockFineInfoData.items.filter({
            matches(fineLikeText(from: letter), $0.title) || matches($0.simpleExplanation, letter.simplifiedExplanation)
        }).prefix(1) {
            items.append(.init(id: "fine-\(fine.id.uuidString)", title: fine.title, subtitle: "If ignored, may escalate", symbol: "exclamationmark.triangle", destination: .fineInfo(fine.id)))
        }

        return deduplicated(items)
    }

    // MARK: - Related Items: NewcomerMistake

    static func relatedItems(for mistake: NewcomerMistake) -> [RelatedNavigationItem] {
        var items: [RelatedNavigationItem] = []

        for inst in MockInstitutionsData.items.filter({
            matches($0.name, mistake.title) || matches($0.shortExplanation(.english), mistake.whyItMatters)
        }).prefix(2) {
            items.append(.init(id: "institution-\(inst.name)", title: inst.name, subtitle: "Related institution", symbol: "building.columns", destination: .institution(inst.name)))
        }

        for answer in MockSearchAnswersData.items.filter({
            matches($0.question, mistake.title) || matches($0.detailedAnswer, mistake.whyItMatters)
        }).prefix(2) {
            items.append(.init(id: "search-\(answer.id.uuidString)", title: answer.question, subtitle: "Related explanation", symbol: "magnifyingglass", destination: .searchAnswer(answer.id)))
        }

        for fine in MockFineInfoData.items.filter({
            matches($0.title, mistake.title) || matches($0.simpleExplanation, mistake.possibleConsequence)
        }).prefix(1) {
            items.append(.init(id: "fine-\(fine.id.uuidString)", title: fine.title, subtitle: "Possible consequence", symbol: "exclamationmark.triangle", destination: .fineInfo(fine.id)))
        }

        for checklist in MockChecklistData.items.filter({
            matches($0.title, mistake.title) || matches($0.description, mistake.howToPrevent)
        }).prefix(2) {
            items.append(.init(id: "check-\(checklist.id.uuidString)", title: checklist.title, subtitle: "Step to prevent this", symbol: "checkmark.circle", destination: .checklist(checklist.id)))
        }

        return deduplicated(items)
    }

    // MARK: - Private Helpers

    private static func matches(_ lhs: String, _ rhs: String) -> Bool {
        let left = lhs.lowercased()
        let right = rhs.lowercased()
        guard !left.isEmpty && !right.isEmpty else { return false }
        return left.contains(right) || right.contains(left)
    }

    private static func fineLikeText(from letter: LetterExample) -> String {
        "\(letter.title) \(letter.simplifiedExplanation) \(letter.possibleDeadline)"
    }

    private static func explicitTermIDsForSearchAnswer(_ answer: SearchAnswer) -> [UUID] {
        let map: [String: [String]] = [
            "How do I get a BSN?": ["beschikking", "kenmerk"],
            "What is DigiD?": ["aangetekende post", "kenmerk"],
            "Where do I pay a traffic fine?": ["aanmaning", "termijn"],
            "Do I need health insurance?": ["zorgverzekering", "eigen risico"],
            "What should I check in my work contract?": ["termijn", "bezwaar"]
        ]
        let termNames = map[answer.question] ?? []
        return MockDutchTermsData.items.filter { term in
            termNames.contains { name in name.caseInsensitiveCompare(term.dutchTerm) == .orderedSame }
        }.map(\.id)
    }

    private static func explicitFineIDsForSearchAnswer(_ answer: SearchAnswer) -> [UUID] {
        let map: [String: [String]] = [
            "Where do I pay a traffic fine?": ["Traffic Violation Fine", "Ignoring a CJIB Letter — Escalation Risk"],
            "I got a suspicious SMS about payment, what now?": ["Ignoring a CJIB Letter — Escalation Risk"],
            "Do I need health insurance?": ["Health Insurance Administrative Issue"]
        ]
        let fineTitles = map[answer.question] ?? []
        return MockFineInfoData.items.filter { fine in
            fineTitles.contains { title in title.caseInsensitiveCompare(fine.title) == .orderedSame }
        }.map(\.id)
    }

    private static func mistakeCategory(for searchCategory: SearchCategory) -> MistakeCategory {
        switch searchCategory {
        case .registration:    return .municipality
        case .digid:           return .scams
        case .immigration:     return .documents
        case .taxes:           return .taxes
        case .fines:           return .legalLetters
        case .healthInsurance: return .healthInsurance
        case .work:            return .work
        case .education:       return .education
        case .housing:         return .housing
        case .transport:       return .transport
        case .legalHelp:       return .legalLetters
        case .emergency:       return .documents
        case .general:         return .documents
        }
    }

    private static func checklistMistakeMatch(_ mistake: MistakeCategory, _ checklist: ChecklistCategory) -> Bool {
        switch checklist {
        case .registration: return mistake == .municipality || mistake == .documents
        case .documents:    return mistake == .documents || mistake == .legalLetters
        case .insurance:    return mistake == .healthInsurance
        case .work:         return mistake == .work
        case .taxes:        return mistake == .taxes
        case .housing:      return mistake == .housing
        case .education:    return mistake == .education
        case .transport:    return mistake == .transport
        }
    }

    private static func deduplicated(_ items: [RelatedNavigationItem]) -> [RelatedNavigationItem] {
        var seen = Set<String>()
        return items.filter { seen.insert($0.id).inserted }
    }
}
