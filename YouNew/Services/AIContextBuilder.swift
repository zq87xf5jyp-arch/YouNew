import Foundation

@MainActor
enum AIContextBuilder {
    static func automaticContext(
        selectedTab: AppTab,
        activeDestination: AppDestination?,
        language: AppLanguage,
        appState: AppStateViewModel
    ) -> AIContext {
        let currentRouteID = activeDestination.flatMap(AppNavigationResolver.routeID(from:)) ?? AppDestination.aiRouteID(from: selectedTab.destinationForAIContext)
        if let activeDestination {
            return enriched(
                context(for: activeDestination, language: language, appState: appState),
                currentRouteID: currentRouteID,
                appState: appState
            )
        }

        let context: AIContext
        switch selectedTab {
        case .home:
            context = assistantHomeContext(appState: appState, language: language)
        case .search:
            context = searchContext(query: nil, language: language, appState: appState)
        case .map:
            context = build(
                screen: .map,
                language: language,
                appState: appState,
                category: localizedCategory("Nearby help and map", "Hulp dichtbij en kaart", "Помощь рядом и карта", language),
                topicTitle: localizedCategory("Nearby services", "Diensten dichtbij", "Сервисы рядом", language),
                topicSummary: localizedCategory(
                    "Use the map to find municipality offices, healthcare, police, libraries, transport, and official support near the selected city.",
                    "Gebruik de kaart voor gemeente, zorg, politie, bibliotheek, vervoer en officiële hulp dichtbij de gekozen stad.",
                    "Используйте карту, чтобы найти муниципалитет, медицину, полицию, библиотеки, транспорт и официальную помощь рядом с выбранным городом.",
                    language
                ),
                officialSources: [
                    OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl"), institution: "Government of the Netherlands")
                ]
            )
        case .favorites:
            context = build(
                screen: .saved,
                language: language,
                appState: appState,
                category: localizedCategory("Saved items", "Bewaard", "Сохранённое", language),
                topicTitle: localizedCategory("Saved places and guides", "Bewaarde plekken en gidsen", "Сохранённые места и гайды", language),
                topicSummary: localizedCategory(
                    "Help the user continue from saved guides, places, and official sources without assuming any official decision.",
                    "Help de gebruiker verder met bewaarde gidsen, plekken en officiële bronnen zonder officiële beslissing te veronderstellen.",
                    "Помогите продолжить с сохранёнными гайдами, местами и официальными источниками без предположений об официальных решениях.",
                    language
                )
            )
        case .assistant, .more:
            context = assistantHomeContext(appState: appState, language: language)
        }
        return enriched(context, currentRouteID: currentRouteID, appState: appState)
    }

    static func automaticPrompt(language: AppLanguage, selectedTab: AppTab, activeDestination: AppDestination?) -> String {
        let target = activeDestination.map { title(for: $0, language: language) } ?? tabTitle(selectedTab, language: language)
        switch language {
        case .russian:
            return "Помогите мне с экраном «\(target)»: объясните, что здесь важно, что проверить первым и какой безопасный следующий шаг."
        case .dutch:
            return "Help mij met het scherm '\(target)': leg uit wat belangrijk is, wat ik eerst controleer en wat een veilige volgende stap is."
        case .english:
            return "Help me with the '\(target)' screen: explain what matters, what to check first, and the safest next step."
        }
    }

    static func build(
        screen: AIContextScreen,
        language: AppLanguage,
        appState: AppStateViewModel?,
        savedItems: [SavedItemsStore.SavedItem] = [],
        category: String? = nil,
        topicTitle: String? = nil,
        topicSummary: String? = nil,
        officialSources: [OfficialSource] = [],
        lastReviewed: Date? = nil,
        selectedProvince: String? = nil,
        currentRouteID: String? = nil
    ) -> AIContext {
        let activePersona = appState?.selectedUserStatus?.personaTag
        let savedPool = savedItems.isEmpty ? Array(SavedItemsStore.shared.savedItems) : savedItems
        let effectiveSavedItems = savedPool.filter { item in
            guard let destination = item.destination else { return true }
            return RelatedContentEngine.isVisible(destination, for: activePersona)
        }
        let visibleChecklistItems = appState?.checklistItems.filter {
            $0.isVisible(for: activePersona, scope: .currentAndUniversal)
        } ?? []
        let completedChecklistIDs = visibleChecklistItems
            .filter(\.isCompleted)
            .map { $0.id.uuidString }
        let checklistTotal = visibleChecklistItems.count
        let journeyProgress = checklistTotal > 0 ? "\(completedChecklistIDs.count)/\(checklistTotal) checklist" : nil
        let resolvedProvince = selectedProvince ?? provinceName(forCity: appState?.selectedCity)

        return AIContext(
            screen: screen,
            category: category,
            topicTitle: sanitized(topicTitle),
            topicSummary: sanitized(topicSummary),
            officialSources: officialSources,
            lastReviewed: lastReviewed,
            userLanguage: language,
            userSituation: appState?.selectedUserStatus?.localized(language),
            selectedCity: appState?.selectedCity,
            selectedProvince: resolvedProvince,
            savedItemTitles: effectiveSavedItems.prefix(8).compactMap { sanitized($0.displayTitle(language)) },
            savedItemIDs: effectiveSavedItems.prefix(12).map(\.id),
            savedItemKinds: Array(Set(effectiveSavedItems.map { $0.kind.rawValue })).sorted(),
            currentRouteID: currentRouteID,
            recentRouteIDs: appState?.visibleRecentRouteIDs() ?? [],
            lastSearches: recentSearches(),
            completedChecklistItemIDs: completedChecklistIDs,
            completedGuideIDs: appState?.visibleCompletedGuideIDs() ?? [],
            journeyProgress: journeyProgress,
            disclaimer: AISafetyRules.mandatoryDisclaimer(for: language),
            activePersonaTag: activePersona,
            personaSearchScope: .currentAndUniversal
        )
    }

    private static func enriched(_ context: AIContext, currentRouteID: String?, appState: AppStateViewModel) -> AIContext {
        let activePersona = appState.selectedUserStatus?.personaTag
        let visibleSavedItems = SavedItemsStore.shared.savedItems.filter { item in
            guard let destination = item.destination else { return true }
            return RelatedContentEngine.isVisible(destination, for: activePersona)
        }

        return AIContext(
            screen: context.screen,
            category: context.category,
            topicTitle: context.topicTitle,
            topicSummary: context.topicSummary,
            officialSources: context.officialSources,
            lastReviewed: context.lastReviewed,
            userLanguage: context.userLanguage,
            userSituation: context.userSituation,
            selectedCity: context.selectedCity,
            selectedProvince: context.selectedProvince,
            savedItemTitles: context.savedItemTitles,
            savedItemIDs: context.savedItemIDs.isEmpty ? Array(visibleSavedItems.prefix(12).map(\.id)) : context.savedItemIDs,
            savedItemKinds: context.savedItemKinds.isEmpty ? Array(Set(visibleSavedItems.map { $0.kind.rawValue })).sorted() : context.savedItemKinds,
            currentRouteID: currentRouteID ?? context.currentRouteID,
            recentRouteIDs: context.recentRouteIDs.isEmpty ? appState.visibleRecentRouteIDs() : context.recentRouteIDs,
            lastSearches: context.lastSearches.isEmpty ? recentSearches() : context.lastSearches,
            completedChecklistItemIDs: context.completedChecklistItemIDs.isEmpty ? appState.checklistItems.filter { $0.isCompleted && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }.map { $0.id.uuidString } : context.completedChecklistItemIDs,
            completedGuideIDs: context.completedGuideIDs.isEmpty ? appState.visibleCompletedGuideIDs() : context.completedGuideIDs,
            journeyProgress: context.journeyProgress ?? "\(appState.checklistItems.filter { $0.isCompleted && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }.count)/\(appState.checklistItems.filter { $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }.count) checklist",
            disclaimer: context.disclaimer,
            activePersonaTag: context.activePersonaTag ?? activePersona,
            secondaryPersonaTags: context.secondaryPersonaTags,
            personaSearchScope: context.personaSearchScope
        )
    }

    private static func recentSearches() -> [String] {
        Array((UserDefaults.standard.stringArray(forKey: "question_search_recent_v1") ?? []).prefix(8))
    }

    private static func context(
        for destination: AppDestination,
        language: AppLanguage,
        appState: AppStateViewModel
    ) -> AIContext {
        switch destination {
        case .informationHub:
            return build(
                screen: .informationHub,
                language: language,
                appState: appState,
                category: localizedCategory("Information Hub", "Informatiecentrum", "Информационный центр", language),
                topicTitle: localizedCategory("Main newcomer knowledge system", "Kenniscentrum voor nieuwkomers", "Главная база знаний для новичка", language),
                topicSummary: localizedCategory(
                    "The hub connects practical guides, official sources, KNM, Dutch A1-A2, cities, culture, history, transport, healthcare, housing, and safety.",
                    "Het centrum verbindt praktische gidsen, officiële bronnen, KNM, Nederlands A1-A2, steden, cultuur, geschiedenis, vervoer, zorg, wonen en veiligheid.",
                    "Центр связывает практические гайды, официальные источники, KNM, Dutch A1-A2, города, культуру, историю, транспорт, медицину, жильё и безопасность.",
                    language
                )
            )
        case .knm, .knmModule:
            return knmContext(language: language, appState: appState)
        case .dutchA1A2, .dutchA1A2Module:
            return dutchCourseContext(language: language, appState: appState)
        case .practicalGuide(let topic):
            return practicalGuideContext(topic: topic, language: language, appState: appState)
        case .officialSources:
            return officialSourcesContext(language: language, appState: appState)
        case .netherlandsHistory:
            return build(
                screen: .informationHub,
                language: language,
                appState: appState,
                category: localizedCategory("History", "Geschiedenis", "История", language),
                topicTitle: localizedCategory("History of the Netherlands", "Geschiedenis van Nederland", "История Нидерландов", language),
                topicSummary: localizedCategory(
                    "Explain Dutch history in simple newcomer-friendly terms and connect it to modern society, water, cities, trade, democracy, and culture.",
                    "Leg de Nederlandse geschiedenis eenvoudig uit en verbind die met samenleving, water, steden, handel, democratie en cultuur.",
                    "Объясните историю Нидерландов простым языком и свяжите её с современным обществом, водой, городами, торговлей, демократией и культурой.",
                    language
                )
            )
        case .cultureAttractions:
            return build(
                screen: .informationHub,
                language: language,
                appState: appState,
                category: localizedCategory("Culture", "Cultuur", "Культура", language),
                topicTitle: localizedCategory("Culture and attractions", "Cultuur en attracties", "Культура и достопримечательности", language),
                topicSummary: localizedCategory(
                    "Help explain Dutch daily culture, canals, museums, markets, cycling culture, direct communication, and useful official or museum sources.",
                    "Leg Nederlandse dagelijkse cultuur, grachten, musea, markten, fietscultuur, directe communicatie en nuttige bronnen uit.",
                    "Помогите понять повседневную культуру, каналы, музеи, рынки, велосипедную культуру, прямое общение и полезные источники.",
                    language
                )
            )
        case .cityDetail(_, let city):
            return cityContext(cityName: city, provinceName: "", language: language, appState: appState)
        case .provinceDetail(let province):
            return build(
                screen: .province,
                language: language,
                appState: appState,
                category: localizedCategory("Province", "Provincie", "Провинция", language),
                topicTitle: province,
                topicSummary: localizedCategory("Explain this province and useful newcomer actions.", "Leg deze provincie en nuttige nieuwkomersacties uit.", "Объясните эту провинцию и полезные действия для новичка.", language),
                selectedProvince: province
            )
        default:
            return assistantHomeContext(appState: appState, language: language)
        }
    }

    static func practicalGuideContext(
        topic: PracticalGuideTopic,
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        switch topic {
        case .transportBasics:
            return transportContext(language: language, appState: appState)
        case .healthcareBasics, .findingHuisarts, .healthInsuranceBasics:
            return healthcareContext(language: language, appState: appState)
        case .housingBasics:
            return housingContext(language: language, appState: appState)
        case .digidSafety, .municipalityRegistration, .firstStepsNetherlands, .officialSourcesChecklist:
            return documentsContext(language: language, appState: appState)
        case .bankingBasics:
            return build(
                screen: .practicalGuide,
                language: language,
                appState: appState,
                category: localizedCategory("Banking and payments", "Bankieren en betalen", "Банк и платежи", language),
                topicTitle: localizedCategory("Banking basics", "Basis bankieren", "Банковские основы", language),
                topicSummary: localizedCategory(
                    "Explain bank account, iDEAL, payment reminders, budgeting, debt risk, and official checks in simple terms.",
                    "Leg bankrekening, iDEAL, betaalherinneringen, budgetteren, schuldrisico en officiële checks eenvoudig uit.",
                    "Объясните банковский счёт, iDEAL, напоминания об оплате, бюджет, риск долгов и официальные проверки простым языком.",
                    language
                ),
                officialSources: [
                    OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl"), institution: "Government of the Netherlands")
                ]
            )
        }
    }

    static func knmContext(language: AppLanguage, appState: AppStateViewModel?) -> AIContext {
        build(
            screen: .knm,
            language: language,
            appState: appState,
            category: "KNM",
            topicTitle: localizedCategory("Knowledge of Dutch Society", "Kennis van de Nederlandse Maatschappij", "Знание нидерландского общества", language),
            topicSummary: localizedCategory(
                "Use app-created KNM study modules to explain housing, work, healthcare, education, government, norms, transport, safety, participation, and money. This is not an official DUO exam.",
                "Gebruik app-oefenmodules voor wonen, werk, zorg, onderwijs, overheid, normen, vervoer, veiligheid, participatie en geld. Dit is geen officieel DUO-examen.",
                "Используйте учебные модули приложения по жилью, работе, медицине, образованию, государству, нормам, транспорту, безопасности, участию и деньгам. Это не официальный экзамен DUO.",
                language
            ),
            officialSources: [
                OfficialSource(title: "Inburgeren.nl", url: URL(string: "https://www.inburgeren.nl"), institution: "DUO")
            ]
        )
    }

    static func dutchCourseContext(language: AppLanguage, appState: AppStateViewModel?) -> AIContext {
        build(
            screen: .dutchCourse,
            language: language,
            appState: appState,
            category: localizedCategory("Dutch A1-A2", "Nederlands A1-A2", "Нидерландский A1-A2", language),
            topicTitle: localizedCategory("Practical beginner Dutch", "Praktisch beginners-Nederlands", "Практический нидерландский для новичков", language),
            topicSummary: localizedCategory(
                "Help with basic words, phrases, grammar, mini-dialogues, practical situations, and exercises for everyday life. App practice is not an official exam.",
                "Help met basiswoorden, zinnen, grammatica, korte dialogen, praktijksituaties en oefeningen. App-oefening is geen officieel examen.",
                "Помогите со словами, фразами, грамматикой, мини-диалогами, бытовыми ситуациями и упражнениями. Это практика приложения, не официальный экзамен.",
                language
            )
        )
    }

    static func officialSourcesContext(language: AppLanguage, appState: AppStateViewModel?) -> AIContext {
        let activePersona = appState?.selectedUserStatus?.personaTag
        let topicSummary: String
        let sources: [OfficialSource]

        switch activePersona {
        case .student:
            topicSummary = localizedCategory(
                "Help the student verify DUO, education, housing, health insurance, language learning, student work, and public transport sources. Do not start with tax, UWV, IND, or refugee bureaucracy unless the student asks.",
                "Help de student DUO, onderwijs, wonen, zorgverzekering, taal, studentenwerk en openbaar vervoer controleren. Begin niet met belasting, UWV, IND of vluchtelingenbureaucratie tenzij de student dat vraagt.",
                "Помогите студенту проверить DUO, образование, жильё, страховку, язык, студенческую работу и транспорт. Не начинайте с налогов, UWV, IND или бюрократии беженцев, если студент сам не спросит.",
                language
            )
            sources = [
                OfficialSource(title: "DUO", url: URL(string: "https://www.duo.nl"), institution: "DUO"),
                OfficialSource(title: "Study in NL", url: URL(string: "https://www.studyinnl.org"), institution: "Nuffic"),
                OfficialSource(title: "OV-chipkaart", url: URL(string: "https://www.ov-chipkaart.nl/en"), institution: "Translink")
            ]
        case .worker:
            topicSummary = localizedCategory(
                "Help the worker verify BSN, DigiD, work contracts, salary, taxes, UWV, employment rights, health insurance, housing, transport, pension, and training sources. Do not introduce student or refugee-specific paths.",
                "Help de werknemer BSN, DigiD, arbeidscontracten, salaris, belasting, UWV, arbeidsrechten, zorgverzekering, wonen, vervoer, pensioen en scholing controleren. Introduceer geen student- of vluchtelingroutes.",
                "Помогите работнику проверить BSN, DigiD, договоры, зарплату, налоги, UWV, трудовые права, страховку, жильё, транспорт, пенсию и обучение. Не вводите студенческие или беженские маршруты.",
                language
            )
            sources = [
                OfficialSource(title: "UWV", url: URL(string: "https://www.uwv.nl"), institution: "UWV"),
                OfficialSource(title: "Belastingdienst", url: URL(string: "https://www.belastingdienst.nl"), institution: "Tax Authority"),
                OfficialSource(title: "Government.nl employment", url: URL(string: "https://www.government.nl/topics/employment-contracts-and-cao"), institution: "Government of the Netherlands")
            ]
        case .refugee:
            topicSummary = localizedCategory(
                "Help the refugee verify IND, municipality, housing, benefits, integration, language, healthcare, documents, work permission, education access, and support organization sources. Keep unrelated student or worker details out.",
                "Help de vluchteling IND, gemeente, wonen, uitkeringen, integratie, taal, zorg, documenten, werktoestemming, onderwijs en hulporganisaties controleren. Laat onnodige studenten- of werknemersdetails weg.",
                "Помогите беженцу проверить IND, муниципалитет, жильё, пособия, интеграцию, язык, медицину, документы, разрешение на работу, образование и организации поддержки. Не добавляйте лишние студенческие или рабочие детали.",
                language
            )
            sources = [
                OfficialSource(title: "IND", url: URL(string: "https://ind.nl"), institution: "IND"),
                OfficialSource(title: "VluchtelingenWerk", url: URL(string: "https://www.vluchtelingenwerk.nl"), institution: "VluchtelingenWerk Nederland"),
                OfficialSource(title: "Inburgeren.nl", url: URL(string: "https://www.inburgeren.nl"), institution: "DUO")
            ]
        case .family:
            topicSummary = localizedCategory(
                "Help the family verify schools, childcare, kinderopvang, SVB, child benefits, family housing, healthcare, activities, and municipal services. Avoid student, worker, or refugee-specific complexity.",
                "Help het gezin scholen, opvang, kinderopvang, SVB, kinderbijslag, gezinswonen, zorg, activiteiten en gemeentelijke diensten controleren. Vermijd student-, werk- of vluchtelingcomplexiteit.",
                "Помогите семье проверить школы, childcare/kinderopvang, SVB, детские пособия, семейное жильё, медицину, активности и муниципальные услуги. Избегайте лишних студенческих, рабочих или беженских деталей.",
                language
            )
            sources = [
                OfficialSource(title: "SVB", url: URL(string: "https://www.svb.nl"), institution: "SVB"),
                OfficialSource(title: "Government.nl childcare", url: URL(string: "https://www.government.nl/topics/childcare"), institution: "Government of the Netherlands"),
                OfficialSource(title: "Government.nl education", url: URL(string: "https://www.government.nl/topics/primary-education"), institution: "Government of the Netherlands")
            ]
        case .highlySkilledMigrant:
            topicSummary = localizedCategory(
                "Help the highly skilled migrant verify recognized sponsor, IND permit, salary threshold, 30% ruling, housing, health insurance, transport, and employer document sources.",
                "Help de kennismigrant erkend referent, IND-verblijfsrecht, salariscriterium, 30%-regeling, wonen, zorgverzekering, vervoer en werkgeversdocumenten controleren.",
                "Помогите highly skilled migrant проверить recognized sponsor, разрешение IND, зарплатный критерий, 30% ruling, жильё, страховку, транспорт и документы работодателя.",
                language
            )
            sources = [
                OfficialSource(title: "IND highly skilled migrant", url: URL(string: "https://ind.nl/en/residence-permits/work/highly-skilled-migrant"), institution: "IND"),
                OfficialSource(title: "Belastingdienst 30% facility", url: URL(string: "https://www.belastingdienst.nl/wps/wcm/connect/en/individuals/content/30-percent-facility"), institution: "Belastingdienst"),
                OfficialSource(title: "Business.gov.nl recognised sponsor", url: URL(string: "https://business.gov.nl/regulation/recognised-sponsor/"), institution: "Business.gov.nl")
            ]
        case .eu:
            topicSummary = localizedCategory(
                "Help the EU citizen verify municipality registration, BSN, DigiD, work rights, health insurance, housing, transport, taxes, and municipal service sources.",
                "Help de EU-burger gemeente-inschrijving, BSN, DigiD, werkrechten, zorgverzekering, wonen, vervoer, belasting en gemeentelijke diensten controleren.",
                "Помогите гражданину ЕС проверить регистрацию в gemeente, BSN, DigiD, право на работу, страховку, жильё, транспорт, налоги и муниципальные услуги.",
                language
            )
            sources = [
                OfficialSource(title: "Government.nl EU citizens", url: URL(string: "https://www.government.nl/topics/immigration-to-the-netherlands/question-and-answer/eu-eea-or-swiss-citizens-living-in-the-netherlands"), institution: "Government of the Netherlands"),
                OfficialSource(title: "DigiD", url: URL(string: "https://www.digid.nl"), institution: "Logius"),
                OfficialSource(title: "Belastingdienst", url: URL(string: "https://www.belastingdienst.nl"), institution: "Tax Authority")
            ]
        case .nonEU:
            topicSummary = localizedCategory(
                "Help the non-EU newcomer verify IND residence status, municipality registration, BSN, DigiD, health insurance, housing, language, work permission, and official document sources.",
                "Help de niet-EU nieuwkomer IND-verblijfsstatus, gemeente-inschrijving, BSN, DigiD, zorgverzekering, wonen, taal, werktoestemming en officiële documenten controleren.",
                "Помогите non-EU newcomer проверить статус IND, регистрацию gemeente, BSN, DigiD, страховку, жильё, язык, разрешение на работу и официальные документы.",
                language
            )
            sources = [
                OfficialSource(title: "IND", url: URL(string: "https://ind.nl"), institution: "IND"),
                OfficialSource(title: "Government.nl BRP", url: URL(string: "https://www.government.nl/themes/government-and-democracy/personal-data/personal-records-database-brp"), institution: "Government of the Netherlands"),
                OfficialSource(title: "Inburgeren.nl", url: URL(string: "https://www.inburgeren.nl"), institution: "DUO")
            ]
        case .tourist:
            topicSummary = localizedCategory(
                "Help the tourist verify short-stay rules, emergency help, transport, healthcare access, lost documents, accommodation, city life, and official travel sources. Avoid resident-only BSN, tax, benefits, or worker onboarding unless asked.",
                "Help de toerist kort verblijf, noodhulp, vervoer, zorgtoegang, verloren documenten, accommodatie, stadsleven en officiële reisbronnen controleren. Vermijd inwoner-only BSN, belasting, toeslagen of werk-onboarding tenzij gevraagd.",
                "Помогите туристу проверить правила short stay, экстренную помощь, транспорт, медицину, потерянные документы, жильё, городскую жизнь и официальные travel sources. Не начинайте с BSN, налогов, пособий или рабочей адаптации без запроса.",
                language
            )
            sources = [
                OfficialSource(title: "Government.nl short stay", url: URL(string: "https://www.government.nl/topics/immigration-to-the-netherlands/short-stay-visas"), institution: "Government of the Netherlands"),
                OfficialSource(title: "Netherlands Worldwide", url: URL(string: "https://www.netherlandsworldwide.nl"), institution: "Ministry of Foreign Affairs"),
                OfficialSource(title: "9292", url: URL(string: "https://9292.nl/en"), institution: "9292")
            ]
        case .entrepreneur:
            topicSummary = localizedCategory(
                "Help the entrepreneur verify KVK, VAT/BTW, taxes, business permits, banking, insurance, municipality rules, housing, transport, and official business sources.",
                "Help de ondernemer KVK, btw, belasting, bedrijfsvergunningen, bankieren, verzekeringen, gemeentelijke regels, wonen, vervoer en officiële ondernemersbronnen controleren.",
                "Помогите предпринимателю проверить KVK, VAT/BTW, налоги, business permits, банк, страховки, municipal rules, жильё, транспорт и официальные business sources.",
                language
            )
            sources = [
                OfficialSource(title: "KVK", url: URL(string: "https://www.kvk.nl/en/"), institution: "KVK"),
                OfficialSource(title: "Business.gov.nl", url: URL(string: "https://business.gov.nl"), institution: "Business.gov.nl"),
                OfficialSource(title: "Belastingdienst business", url: URL(string: "https://www.belastingdienst.nl/wps/wcm/connect/en/business/business"), institution: "Belastingdienst")
            ]
        case .lgbt:
            topicSummary = localizedCategory(
                "Help the LGBT newcomer verify legal safety, discrimination support, healthcare, housing, documents, municipality services, language, work or education access, and trusted support organizations.",
                "Help de LGBT-nieuwkomer juridische veiligheid, discriminatiesteun, zorg, wonen, documenten, gemeentelijke diensten, taal, werk of onderwijs en betrouwbare hulporganisaties controleren.",
                "Помогите LGBT newcomer проверить правовую безопасность, поддержку при дискриминации, медицину, жильё, документы, муниципальные услуги, язык, работу или образование и trusted support organizations.",
                language
            )
            sources = [
                OfficialSource(title: "Discriminatie.nl", url: URL(string: "https://discriminatie.nl"), institution: "Discriminatie.nl"),
                OfficialSource(title: "COC Nederland", url: URL(string: "https://www.coc.nl"), institution: "COC Nederland"),
                OfficialSource(title: "IND", url: URL(string: "https://ind.nl"), institution: "IND")
            ]
        default:
            topicSummary = localizedCategory(
                "Help the user choose the right official source for their current profile. Prioritize profile-relevant sources and avoid unrelated life paths.",
                "Help de juiste officiële bron kiezen voor het huidige profiel. Geef profielrelevante bronnen voorrang en vermijd irrelevante levenspaden.",
                "Помогите выбрать официальный источник для текущего профиля. Сначала профильные источники, без нерелевантных жизненных путей.",
                language
            )
            sources = [
                OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl"), institution: "Government of the Netherlands")
            ]
        }

        return build(
            screen: .officialLinks,
            language: language,
            appState: appState,
            category: localizedCategory("Official sources", "Officiele bronnen", "Официальные источники", language),
            topicTitle: localizedCategory("Verify current information", "Actuele informatie controleren", "Проверить актуальную информацию", language),
            topicSummary: topicSummary,
            officialSources: sources
        )
    }

    // MARK: - Home

    static func assistantHomeContext(appState: AppStateViewModel, language: AppLanguage) -> AIContext {
        let summary = [
            appState.selectedUserStatus?.localized(language),
            appState.selectedCity,
            "\(appState.visibleChecklistItems.filter(\.isCompleted).count)/\(appState.visibleChecklistItems.count) checklist",
            knowledgeBaseSnapshot
        ]
        .compactMap { $0 }
        .joined(separator: " • ")

        return build(
            screen: .assistant,
            language: language,
            appState: appState,
            category: "General newcomer guidance",
            topicTitle: L10n.t("ai.title", language),
            topicSummary: summary,
            officialSources: [
                OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl"), institution: "Government of the Netherlands")
            ]
        )
    }

    // MARK: - Province

    static func provinceContext(
        province: ProvinceItem,
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .province,
            language: language,
            appState: appState,
            category: "Province",
            topicTitle: province.id,
            topicSummary: "\(province.capital) • \(province.population) • \(province.municipalityCount) municipalities",
            officialSources: [
                OfficialSource(
                    title: province.officialWebsite,
                    url: URL(string: "https://\(province.officialWebsite)"),
                    institution: province.localizedName(language)
                )
            ],
            selectedProvince: province.id
        )
    }

    // MARK: - City

    static func cityContext(
        cityName: String,
        provinceName: String,
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .city,
            language: language,
            appState: appState,
            category: "City",
            topicTitle: cityName,
            topicSummary: "\(cityName) is a city in \(provinceName), the Netherlands.",
            officialSources: [
                OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl"), institution: "Government of the Netherlands")
            ],
            selectedProvince: provinceName
        )
    }

    // MARK: - Fines & Rules

    static func fineTopicContext(
        topic: RuleGuideTopic,
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .fineDetail,
            language: language,
            appState: appState,
            category: topic.category,
            topicTitle: topic.title,
            topicSummary: "\(topic.commonMistake) Fine: \(topic.estimatedFineRange). Authority: \(topic.authority).",
            officialSources: [
                OfficialSource(
                    title: topic.officialSourceName,
                    url: topic.officialSourceURL,
                    institution: topic.authority
                )
            ]
        )
    }

    static func fineInfoDetailContext(
        item: FineInfoItem,
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .fineDetail,
            language: language,
            appState: appState,
            category: item.category.localized(.english),
            topicTitle: item.title(language),
            topicSummary: item.simpleExplanation(language),
            officialSources: [
                OfficialSource(
                    title: item.officialSourceName,
                    url: item.officialSourceURL,
                    institution: nil
                )
            ],
            lastReviewed: item.lastUpdated
        )
    }

    static func rulesAndFinesContext(
        language: AppLanguage,
        appState: AppStateViewModel?,
        selectedCategory: String? = nil
    ) -> AIContext {
        build(
            screen: .rulesAndFines,
            language: language,
            appState: appState,
            category: selectedCategory ?? "Rules & Fines",
            topicTitle: "Dutch rules and fines guide",
            topicSummary: "Overview of common fines, traffic rules, bicycle rules, and what to do if fined in the Netherlands.",
            officialSources: [
                OfficialSource(title: "CJIB (fines)", url: URL(string: "https://www.cjib.nl"), institution: "CJIB"),
                OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl"), institution: "Government of the Netherlands")
            ]
        )
    }

    // MARK: - Documents

    static func documentsContext(
        language: AppLanguage,
        appState: AppStateViewModel?,
        savedItems: [SavedItemsStore.SavedItem] = []
    ) -> AIContext {
        build(
            screen: .documents,
            language: language,
            appState: appState,
            savedItems: savedItems,
            category: "Documents & DigiD",
            topicTitle: "BSN, DigiD, and official letters",
            topicSummary: "Dutch identity documents, BSN registration, DigiD digital authentication, and understanding official letters.",
            officialSources: [
                OfficialSource(title: "DigiD", url: URL(string: "https://www.digid.nl"), institution: "Logius"),
                OfficialSource(title: "BRP registration", url: URL(string: "https://www.government.nl/themes/government-and-democracy/personal-data/personal-records-database-brp"), institution: "Government of the Netherlands")
            ]
        )
    }

    static func letterDetailContext(
        letter: LetterExample,
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .documents,
            language: language,
            appState: appState,
            category: letter.institutionName(language),
            topicTitle: letter.title(language),
            topicSummary: letter.simplifiedExplanation(language),
            officialSources: [
                OfficialSource(
                    title: letter.institutionName(.english),
                    url: nil,
                    institution: letter.institutionName(.english)
                )
            ]
        )
    }

    // MARK: - Transport

    static func transportContext(
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .transport,
            language: language,
            appState: appState,
            category: "Transport",
            topicTitle: localizedCategory("Public transport, cycling, and payment", "OV, fietsen en betalen", "Общественный транспорт, велосипед и оплата", language),
            topicSummary: localizedCategory(
                "Explain trains, bus, tram, metro, OV-chipkaart, OVpay, check-in/check-out, route planning, cycling, accessibility, and safety. Do not give fixed fares; tell the user to verify current prices with official operators.",
                "Leg trein, bus, tram, metro, OV-chipkaart, OVpay, in- en uitchecken, reisplanning, fietsen, toegankelijkheid en veiligheid uit. Geef geen vaste tarieven; laat actuele prijzen bij officiële vervoerders controleren.",
                "Объясните поезда, автобусы, трамвай, метро, OV-chipkaart, OVpay, check-in/check-out, планирование маршрута, велосипед, доступность и безопасность. Не называйте фиксированные тарифы; направляйте проверять актуальные цены у официальных операторов.",
                language
            ),
            officialSources: [
                OfficialSource(title: "NS", url: URL(string: "https://www.ns.nl/en"), institution: "NS"),
                OfficialSource(title: "9292", url: URL(string: "https://9292.nl/en"), institution: "9292"),
                OfficialSource(title: "OVpay", url: URL(string: "https://www.ovpay.nl/en"), institution: "OVpay"),
                OfficialSource(title: "OV-chipkaart", url: URL(string: "https://www.ov-chipkaart.nl/en"), institution: "Translink")
            ]
        )
    }

    // MARK: - Emergency

    static func emergencyContext(
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .emergency,
            language: language,
            appState: appState,
            category: "Emergency",
            topicTitle: "Emergency contacts in the Netherlands",
            topicSummary: "Emergency: 112 (fire, police, ambulance). Non-emergency police: 0900-8844. Poison centre: 030-274-8888. Crisis line: 113.",
            officialSources: [
                OfficialSource(title: "Politie (police)", url: URL(string: "https://www.politie.nl"), institution: "Politie"),
                OfficialSource(title: "Government emergency info", url: URL(string: "https://www.government.nl/themes/justice-security-and-defence/emergency-number-112"), institution: "Government of the Netherlands")
            ]
        )
    }

    // MARK: - Housing

    static func housingContext(
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .housing,
            language: language,
            appState: appState,
            category: "Housing",
            topicTitle: localizedCategory("Renting and housing in the Netherlands", "Huren en wonen in Nederland", "Аренда и жильё в Нидерландах", language),
            topicSummary: localizedCategory(
                "Explain rental checks, registration address, housing corporation, utilities, waste rules, neighbours, repairs, inspection reports, and scam warnings. Do not promise legal outcomes; tell the user to verify current rules with official sources.",
                "Leg huurchecks, inschrijfadres, woningcorporatie, energie, water, afvalregels, buren, reparaties, inspectierapporten en oplichting uit. Beloof geen juridische uitkomsten; laat actuele regels officieel controleren.",
                "Объясните проверку аренды, адрес регистрации, housing corporation, энергию, воду, мусор, соседей, ремонт, акт осмотра и риски мошенничества. Не обещайте юридический результат; направляйте проверять актуальные правила официально.",
                language
            ),
            officialSources: [
                OfficialSource(title: "Huurcommissie", url: URL(string: "https://www.huurcommissie.nl"), institution: "Huurcommissie"),
                OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl/themes/housing"), institution: "Government of the Netherlands")
            ]
        )
    }

    // MARK: - Healthcare

    static func healthcareContext(
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .healthcare,
            language: language,
            appState: appState,
            category: "Healthcare",
            topicTitle: "Healthcare in the Netherlands",
            topicSummary: "Health insurance (zorgverzekering) is mandatory for residents. GP (huisarts) is primary care. Spoedeisende hulp for urgent, 112 for emergency.",
            officialSources: [
                OfficialSource(title: "Zorginstituut Nederland", url: URL(string: "https://www.zorginstituutnederland.nl"), institution: "Zorginstituut"),
                OfficialSource(title: "CAK (healthcare allowance)", url: URL(string: "https://www.hetcak.nl"), institution: "CAK")
            ]
        )
    }

    // MARK: - Work & Taxes

    static func workAndTaxesContext(
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .workAndTaxes,
            language: language,
            appState: appState,
            category: "Work & Taxes",
            topicTitle: "Working and taxes in the Netherlands",
            topicSummary: "Employment contracts, payslips (loonstrook), annual tax return (aangifte), 30% ruling for expats, and UWV for benefits.",
            officialSources: [
                OfficialSource(title: "Belastingdienst", url: URL(string: "https://www.belastingdienst.nl"), institution: "Tax Authority"),
                OfficialSource(title: "UWV (benefits & employment)", url: URL(string: "https://www.uwv.nl"), institution: "UWV")
            ]
        )
    }

    // MARK: - Search

    static func searchContext(
        query: String?,
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        let title = query.map { "Searching for: \($0)" } ?? "Search"
        let expansion = searchExpansionSummary(for: query, appState: appState)
        let indexed = appIndexSearchSummary(for: query, language: language, appState: appState)
        let summary = [
            query.map { "User searched for: \($0)" } ?? "User is looking up information in YouNew.",
            expansion.summary,
            indexed.summary
        ]
        .compactMap { $0 }
        .joined(separator: " ")

        return build(
            screen: .search,
            language: language,
            appState: appState,
            category: "Search",
            topicTitle: title,
            topicSummary: String(summary.prefix(1_200)),
            officialSources: deduplicatedSources(expansion.sources + indexed.sources).isEmpty ? [
                OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl"), institution: "Government of the Netherlands")
            ] : Array(deduplicatedSources(expansion.sources + indexed.sources).prefix(8))
        )
    }

    // MARK: - Settings

    static func settingsContext(
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .settings,
            language: language,
            appState: appState,
            category: "Settings",
            topicTitle: "App settings and your profile",
            topicSummary: "Language, user status, city selection, data privacy, and app preferences.",
            officialSources: [
                OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl"), institution: "Government of the Netherlands")
            ]
        )
    }

    // MARK: - Official Links

    static func officialLinksContext(
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .officialLinks,
            language: language,
            appState: appState,
            category: "Official Links",
            topicTitle: "Official Dutch government links",
            topicSummary: "Curated links to official Dutch government websites, institutions, and services.",
            officialSources: [
                OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl"), institution: "Government of the Netherlands"),
                OfficialSource(title: "IND (immigration)", url: URL(string: "https://ind.nl"), institution: "IND"),
                OfficialSource(title: "Belastingdienst", url: URL(string: "https://www.belastingdienst.nl"), institution: "Tax Authority")
            ]
        )
    }

    // MARK: - Beginner Guide

    static func beginnerGuideDetailContext(
        item: BeginnerGuideItem,
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .onboarding,
            language: language,
            appState: appState,
            category: "Beginner Guide",
            topicTitle: item.title(language),
            topicSummary: item.simpleAnswer(language),
            officialSources: [
                OfficialSource(
                    title: item.officialSourceName,
                    url: item.officialSourceURL,
                    institution: item.officialSourceName
                )
            ],
            lastReviewed: item.lastUpdated
        )
    }

    // MARK: - Institution

    static func institutionContext(
        institution: Institution,
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .officialLinks,
            language: language,
            appState: appState,
            category: "Institution",
            topicTitle: institution.name,
            topicSummary: institution.shortExplanation(language),
            officialSources: [
                OfficialSource(
                    title: institution.name,
                    url: institution.officialWebsiteURL,
                    institution: institution.name
                )
            ]
        )
    }

    // MARK: - Survival Guide

    static func survivalGuideContext(
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .onboarding,
            language: language,
            appState: appState,
            category: "Survival Guide",
            topicTitle: "Newcomer survival guide",
            topicSummary: "Essential practical knowledge for newcomers in the Netherlands: registration, documents, transport, housing, healthcare, daily life, official services, city/province context, and newcomer workflows. \(knowledgeBaseSnapshot)",
            officialSources: [
                OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl"), institution: "Government of the Netherlands"),
                OfficialSource(title: "Rijksoverheid", url: URL(string: "https://www.rijksoverheid.nl"), institution: "Government of the Netherlands")
            ]
        )
    }

    // MARK: - Status Direction

    static func statusDirectionContext(
        status: UserStatus,
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> AIContext {
        build(
            screen: .onboarding,
            language: language,
            appState: appState,
            category: "Status Direction",
            topicTitle: status.localized(language),
            topicSummary: "Guidance for \(status.localized(.english)) newcomers: primary needs, first actions, documents to check, and official sources.",
            officialSources: [
                OfficialSource(title: "IND (immigration)", url: URL(string: "https://ind.nl"), institution: "IND"),
                OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl"), institution: "Government of the Netherlands")
            ]
        )
    }

    // MARK: - Private

    private static func localizedCategory(_ english: String, _ dutch: String, _ russian: String, _ language: AppLanguage) -> String {
        switch language {
        case .english: return english
        case .dutch: return dutch
        case .russian: return russian
        }
    }

    private static func tabTitle(_ tab: AppTab, language: AppLanguage) -> String {
        switch tab {
        case .home: return L10n.t("tab.home", language)
        case .search: return L10n.t("tab.search", language)
        case .map: return L10n.t("tab.map", language)
        case .favorites: return L10n.t("tab.saved", language)
        case .assistant: return L10n.t("tab.explain", language)
        case .more: return L10n.t("tab.more", language)
        }
    }

    private static func title(for destination: AppDestination, language: AppLanguage) -> String {
        switch destination {
        case .informationHub: return L10n.t("sideMenu.informationHub", language)
        case .knm, .knmModule: return "KNM"
        case .dutchA1A2, .dutchA1A2Module: return L10n.t("sideMenu.dutchA1A2", language)
        case .practicalGuide(let topic): return practicalGuideTitle(topic, language: language)
        case .officialSources: return L10n.t("sideMenu.officialSources", language)
        case .netherlandsHistory: return L10n.t("sideMenu.historyNetherlands", language)
        case .cultureAttractions: return L10n.t("sideMenu.cultureAttractions", language)
        case .cityList: return L10n.t("sideMenu.cities", language)
        case .provinceList: return L10n.t("sideMenu.provinces", language)
        case .cityDetail(_, let city): return city
        case .provinceDetail(let province), .provinceCities(let province): return province
        case .searchList: return L10n.t("tab.search", language)
        case .mapHub, .mapFocus: return L10n.t("tab.map", language)
        case .assistantHub: return L10n.t("tab.explain", language)
        default: return localizedCategory("Current screen", "Huidig scherm", "Текущий экран", language)
        }
    }

    private static func practicalGuideTitle(_ topic: PracticalGuideTopic, language: AppLanguage) -> String {
        switch topic {
        case .firstStepsNetherlands:
            return L10n.t("sideMenu.firstSteps", language)
        case .municipalityRegistration:
            return L10n.t("sideMenu.registration", language)
        case .healthcareBasics:
            return L10n.t("sideMenu.healthcare", language)
        case .findingHuisarts:
            return L10n.t("sideMenu.huisarts", language)
        case .healthInsuranceBasics:
            return L10n.t("sideMenu.healthInsurance", language)
        case .digidSafety:
            return L10n.t("sideMenu.digidSafety", language)
        case .transportBasics:
            return L10n.t("sideMenu.transport", language)
        case .housingBasics:
            return L10n.t("sideMenu.housing", language)
        case .officialSourcesChecklist:
            return L10n.t("sideMenu.officialSources", language)
        case .bankingBasics:
            return L10n.t("sideMenu.banking", language)
        }
    }

    private static func sanitized(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return String(redactSensitiveData(in: trimmed).prefix(1_200))
    }

    private static func provinceName(forCity cityName: String?) -> String? {
        guard let cityName,
              !cityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return nil }

        if let city = NLCity.all.first(where: {
            $0.name.caseInsensitiveCompare(cityName) == .orderedSame ||
            $0.id.caseInsensitiveCompare(cityName) == .orderedSame
        }) {
            return city.province
        }

        return MockExpansionData.cityProfiles.first(where: {
            $0.name.caseInsensitiveCompare(cityName) == .orderedSame
        })?.province
    }

    private static var knowledgeBaseSnapshot: String {
        "\(MockExpansionData.knowledgeTopics.count) knowledge topics, \(MockExpansionData.lifeScenarios.count) life scenarios, \(MockExpansionData.officialServices.count) official services, \(MockExpansionData.provinceProfiles.count) province profiles, \(MockExpansionData.cityProfiles.count) city profiles"
    }

    private static func searchExpansionSummary(for query: String?, appState: AppStateViewModel?) -> (summary: String?, sources: [OfficialSource]) {
        let normalizedQuery = normalizeSearchText(query ?? "")
        let selectedCity = appState?.selectedCity
        let activePersona = appState?.selectedUserStatus?.personaTag

        let topics = MockExpansionData.knowledgeTopics
            .filter {
                $0.isVisible(for: activePersona, scope: .currentAndUniversal) &&
                (normalizedQuery.isEmpty ? false : matches(normalizedQuery, values: [$0.title, $0.category, $0.summary, $0.officialSourceName] + $0.tags + $0.relatedQuestions))
            }
            .prefix(3)
        let scenarios = MockExpansionData.lifeScenarios
            .filter {
                $0.isVisible(for: activePersona, scope: .currentAndUniversal) &&
                (normalizedQuery.isEmpty ? false : matches(normalizedQuery, values: [$0.title, $0.situation, $0.officialSourceName] + $0.relatedTopics))
            }
            .prefix(2)
        let services = MockExpansionData.officialServices
            .filter {
                $0.isVisible(for: activePersona, scope: .currentAndUniversal) &&
                (normalizedQuery.isEmpty ? false : matches(normalizedQuery, values: [$0.name, $0.domain, $0.purpose, $0.whenToUse] + $0.tags))
            }
            .prefix(3)
        let cities = MockExpansionData.cityProfiles
            .filter { city in
                if let selectedCity, city.name.caseInsensitiveCompare(selectedCity) == .orderedSame { return true }
                return normalizedQuery.isEmpty ? false : matches(normalizedQuery, values: [city.name, city.province, city.newcomerSummary, city.housingContext, city.transportContext, city.workStudyContext] + city.tags)
            }
            .prefix(2)
        let provinces = MockExpansionData.provinceProfiles
            .filter { province in
                cities.contains(where: { $0.province.caseInsensitiveCompare(province.name) == .orderedSame }) ||
                (!normalizedQuery.isEmpty && matches(normalizedQuery, values: [province.name, province.capital, province.rentContext, province.transportContext, province.workContext, province.universityContext] + province.majorCities))
            }
            .prefix(2)

        let parts = [
            topics.isEmpty ? nil : "Matched topics: \(topics.map(\.title).joined(separator: ", ")).",
            scenarios.isEmpty ? nil : "Matched scenarios: \(scenarios.map(\.title).joined(separator: ", ")).",
            services.isEmpty ? nil : "Official services: \(services.map(\.name).joined(separator: ", ")).",
            provinces.isEmpty ? nil : "Province data: \(provinces.map(\.name).joined(separator: ", ")).",
            cities.isEmpty ? nil : "City data: \(cities.map(\.name).joined(separator: ", "))."
        ].compactMap { $0 }

        let topicSources = topics.map { OfficialSource(title: $0.officialSourceName, url: $0.officialSourceURL, institution: $0.officialSourceName) }
        let scenarioSources = scenarios.map { OfficialSource(title: $0.officialSourceName, url: $0.officialSourceURL, institution: $0.officialSourceName) }
        let serviceSources = services.map { OfficialSource(title: $0.name, url: $0.officialURL, institution: $0.name) }
        let provinceSources = provinces.map { OfficialSource(title: $0.name, url: $0.officialWebsite, institution: $0.name) }
        let citySources = cities.map { OfficialSource(title: $0.name, url: $0.municipalityURL, institution: $0.name) }
        let sources = deduplicatedSources(topicSources + scenarioSources + serviceSources + provinceSources + citySources)

        return (parts.isEmpty ? knowledgeBaseSnapshot : parts.joined(separator: " "), Array(sources.prefix(8)))
    }

    private static func appIndexSearchSummary(
        for query: String?,
        language: AppLanguage,
        appState: AppStateViewModel?
    ) -> (summary: String?, sources: [OfficialSource]) {
        guard let query,
              !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return (nil, [])
        }

        let context = build(
            screen: .search,
            language: language,
            appState: appState,
            category: "Search",
            topicTitle: query
        )
        let indexed = AppSearchEngine().answerContext(for: query, language: language, context: context)
        guard let summary = indexed.summary else { return (nil, []) }
        return ("App index matches: \(summary)", indexed.sources)
    }

    nonisolated private static func matches(_ query: String, values: [String]) -> Bool {
        let normalizedValues = values.map(normalizeSearchText)
        let combined = normalizedValues.joined(separator: " ")
        return normalizedValues.contains { $0.contains(query) } ||
            query.split(separator: " ").allSatisfy { combined.contains($0) }
    }

    nonisolated private static func normalizeSearchText(_ value: String) -> String {
        let synonyms: [String: String] = [
            "дигид": "digid",
            "бсн": "bsn",
            "регистрация": "registration",
            "штраф": "fine",
            "налог": "tax",
            "налоги": "taxes",
            "врач": "huisarts",
            "жилье": "housing",
            "жильё": "housing",
            "работа": "work",
            "gemeente": "municipality",
            "fiets": "bicycle",
            "boete": "fine",
            "zorgverzekering": "health insurance",
            "huur": "rent",
            "werk": "work",
            "uitkering": "benefits",
            "toeslagen": "allowances"
        ]

        var normalized = value.lowercased()
        for (source, target) in synonyms {
            normalized = normalized.replacingOccurrences(of: source, with: target)
        }
        return normalized
    }

    nonisolated private static func deduplicatedSources(_ sources: [OfficialSource]) -> [OfficialSource] {
        var seen = Set<String>()
        return sources.filter { source in
            let key = "\(source.title.lowercased())|\(source.url?.absoluteString ?? "")"
            return seen.insert(key).inserted
        }
    }

    nonisolated private static func redactSensitiveData(in value: String) -> String {
        var output = value
        let patterns = [
            "[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}",
            "\\b\\+?[0-9][0-9 .-]{7,}[0-9]\\b"
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { continue }
            let range = NSRange(output.startIndex..<output.endIndex, in: output)
            output = regex.stringByReplacingMatches(in: output, options: [], range: range, withTemplate: "[redacted]")
        }

        return output
    }
}

private extension AppTab {
    var destinationForAIContext: AppDestination {
        switch self {
        case .home: return .firstSteps
        case .search: return .searchList
        case .map: return .mapHub
        case .favorites: return .checklistList
        case .assistant: return .assistantHub
        case .more: return .helpHub
        }
    }
}
