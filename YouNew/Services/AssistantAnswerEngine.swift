import Foundation

enum AssistantAnswerEngine {
    static func getAssistantAnswer(
        userText: String,
        language: AppLanguage,
        context: AIContext
    ) -> AIResponse? {
        let trimmed = userText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let normalized = normalize(trimmed)
        if isAmbiguousBigQuery(normalized) {
            return clarificationResponse(language: language)
        }

        if let partnerResponse = localPartnerResponseIfNeeded(normalized: normalized, language: language, context: context) {
            return partnerResponse
        }

        if containsStay(normalized) || containsBooking(normalized) {
            return cityStayResponse(language: language, context: context)
        }
        if containsRestaurants(normalized) {
            return cityFoodGuideResponse(category: .restaurant, language: language, context: context)
        }
        if containsCafes(normalized) {
            return cityFoodGuideResponse(category: .cafe, language: language, context: context)
        }
        if containsVisitPlaces(normalized) {
            return cityPlacesGuideResponse(language: language, context: context)
        }

        if context.activePersonaTag == .tourist {
            if containsBSN(normalized) {
                return touristBSNResponse(language: language, context: context)
            }
            if containsDigiD(normalized) {
                return touristDigiDResponse(language: language, context: context)
            }
            if containsEmergency(normalized) {
                return touristEmergencyResponse(language: language, context: context)
            }
            if containsLostDocument(normalized) {
                return touristLostDocumentsResponse(language: language, context: context)
            }
            if containsTransport(normalized) {
                return touristTransportResponse(language: language, context: context)
            }
            if containsBikeRules(normalized) {
                return touristBikeRulesResponse(language: language, context: context)
            }
            if containsFinesOrRules(normalized) {
                return touristRulesAndFinesResponse(language: language, context: context)
            }
            if containsPlaces(normalized) {
                return touristPlacesResponse(language: language, context: context)
            }
            if containsHealthcare(normalized) {
                return touristHealthcareResponse(language: language, context: context)
            }
        }

        if isVeryShortAmbiguousQuery(normalized) {
            return shortClarificationResponse(language: language)
        }

        return nil
    }

    private static func localPartnerResponseIfNeeded(normalized: String, language: AppLanguage, context: AIContext) -> AIResponse? {
        let partnerIntentTokens = [
            "dentist", "dental", "clinic", "clinics", "lawyer", "legal", "hotel", "cafe", "restaurant",
            "стоматолог", "дантист", "клиника", "юрист", "отель", "кафе", "ресторан",
            "tandarts", "kliniek", "advocaat"
        ]
        guard partnerIntentTokens.contains(where: { normalized.contains($0) }) else { return nil }

        let city = context.selectedCity ?? cityFromPartnerQuery(normalized) ?? "Leiden"
        let partners = Array(MockLocalPartnersData.matching(query: normalized, city: city).prefix(3))
        guard !partners.isEmpty else { return nil }

        let lines = partners.map { partner in
            let status = partner.isOpenNow ? "Open Now" : "Check hours"
            let marker = partner.plan == .aiFeatured ? "Featured Partner" : "Partner"
            return "\(partner.name) · \(marker) · Verified · \(status) · Map · Call · Website"
        }.joined(separator: "\n")

        let explanation = "This recommendation is based on your city and available local partners."
        let answer: String
        let next: String
        switch language {
        case .russian:
            answer = "Recommended Clinics\n\(lines)"
            next = "Откройте Local Partners или Map, чтобы посмотреть адрес, карту, звонок и сайт."
        case .dutch:
            answer = "Recommended Clinics\n\(lines)"
            next = "Open Local Partners of Map voor adres, kaart, bellen en website."
        case .english:
            answer = "Recommended Clinics\n\(lines)"
            next = "Open Local Partners or Map to see address, map, call, and website actions."
        }

        let sources = partners.map {
            OfficialSource(title: $0.name, url: $0.website, institution: $0.plan.label(language))
        }
        let first = partners.first
        return AIResponse(
            answer: "\(answer)\n\n\(explanation)",
            sources: sources,
            safetyNote: explanation,
            suggestedActions: ["Map", "Call", "Website"],
            quickActions: [
                AIResponseAction.openScreen(title: "Local Partners", destinationID: "localPartners"),
                AIResponseAction.openScreen(title: "Map", destinationID: "map"),
                first.map { AIResponseAction.openSource(title: "Website", url: $0.website) }
            ].compactMap { $0 },
            sections: [
                AIResponseSection(title: "Recommended Clinics", body: lines, symbol: "cross.case.fill"),
                AIResponseSection(title: "Why this recommendation", body: explanation, symbol: "checkmark.seal.fill"),
                AIResponseSection(title: "Actions", body: "Map · Call · Website", symbol: "map.fill")
            ],
            nextStep: AINextStep(
                title: "Local Partners",
                detail: next,
                destinationID: first.map { "localPartner:\($0.id)" } ?? "localPartners",
                destinationTitle: "Local Partners"
            ),
            appDestinationID: first.map { "localPartner:\($0.id)" } ?? "localPartners",
            isVerified: true,
            confidence: .high
        )
    }

    private static func cityFromPartnerQuery(_ normalized: String) -> String? {
        MockLocalPartnersData.partners.first { partner in
            normalized.contains(partner.city.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX")).lowercased())
        }?.city
    }

    private static func cityStayResponse(language: AppLanguage, context: AIContext) -> AIResponse {
        let city = assistantCityName(context)
        guard let booking = context.travelLinks.first(where: { $0.kind == .booking && sameCity($0, context: context) }) else {
            return missingInformationResponse(language: language)
        }

        let source = OfficialSource(title: "Booking.com", url: booking.url, institution: booking.sourceLabel)
        let answer: String
        let why: String
        let next: String
        switch language {
        case .russian:
            answer = "Для проживания в \(city) откройте карточку “Hotels in \(city)” через Booking.com. Я не показываю и не придумываю цены или availability."
            why = "External website. Prices and availability are provided by Booking.com."
            next = "Откройте Booking.com и проверьте даты, район и условия напрямую у провайдера."
        case .dutch:
            answer = "Voor verblijf in \(city) opent u de kaart “Hotels in \(city)” via Booking.com. Ik toon of verzin geen prijzen of beschikbaarheid."
            why = "External website. Prices and availability are provided by Booking.com."
            next = "Open Booking.com en controleer data, wijk en voorwaarden rechtstreeks bij de provider."
        case .english:
            answer = "For stays in \(city), use the “Hotels in \(city)” Booking.com card. I won’t invent prices or availability."
            why = "External website. Prices and availability are provided by Booking.com."
            next = "Open Booking.com and check dates, area, and conditions directly with the provider."
        }
        return directResponse(answer: answer, why: why, next: next, sources: [source], routeID: nil, language: language, verified: true, confidence: .high)
    }

    private static func cityFoodGuideResponse(category: FoodGuideCategory, language: AppLanguage, context: AIContext) -> AIResponse {
        let city = assistantCityName(context)
        guard let item = context.foodGuide.first(where: { $0.category == category && sameCity($0, context: context) }) else {
            return missingInformationResponse(language: language)
        }

        let source = item.externalUrl.map {
            OfficialSource(title: item.shortTitle ?? item.title, url: $0, institution: item.source?.institution ?? "External search")
        }
        let answer: String
        let why: String
        let next: String
        switch (category, language) {
        case (.cafe, .russian):
            answer = "Для кафе в \(city) откройте cafe guide: \(item.title). Я не придумываю рейтинги, часы работы или цены."
            why = "Показываем city-specific search/guide card, а фактические рейтинги и часы проверяйте у внешнего провайдера."
            next = "Откройте \(item.shortTitle ?? item.title) для coffee и breakfast spots в \(city)."
        case (.cafe, .dutch):
            answer = "Voor cafés in \(city) opent u de cafe guide: \(item.title). Ik verzin geen ratings, openingstijden of prijzen."
            why = "We tonen een city-specific search/guide card; controleer actuele ratings en tijden bij de externe provider."
            next = "Open \(item.shortTitle ?? item.title) voor coffee en breakfast spots in \(city)."
        case (.cafe, .english):
            answer = "For cafes in \(city), open the cafe guide: \(item.title). I won’t invent ratings, opening hours, or prices."
            why = "This uses a city-specific search/guide card; check live ratings and hours with the external provider."
            next = "Open \(item.shortTitle ?? item.title) for coffee and breakfast spots in \(city)."
        case (_, .russian):
            answer = "Для ресторанов в \(city) откройте Food & drinks guide: \(item.title). Я не придумываю рейтинги, часы работы или цены."
            why = "Если своей базы ресторанов нет, YouNew показывает city-specific search links, а не fake rankings."
            next = "Откройте \(item.shortTitle ?? item.title) и проверяйте детали у внешнего провайдера."
        case (_, .dutch):
            answer = "Voor restaurants in \(city) opent u de Food & drinks guide: \(item.title). Ik verzin geen ratings, openingstijden of prijzen."
            why = "Als er geen eigen restaurantdatabase is, toont YouNew city-specific search links, geen fake rankings."
            next = "Open \(item.shortTitle ?? item.title) en controleer details bij de externe provider."
        case (_, .english):
            answer = "For restaurants in \(city), open the Food & drinks guide: \(item.title). I won’t invent ratings, opening hours, or prices."
            why = "When there is no owned restaurant database, YouNew shows city-specific search links instead of fake rankings."
            next = "Open \(item.shortTitle ?? item.title) and verify details with the external provider."
        }

        return directResponse(answer: answer, why: why, next: next, sources: source.map { [$0] } ?? [], routeID: "search", language: language, verified: source != nil, confidence: .high)
    }

    private static func cityPlacesGuideResponse(language: AppLanguage, context: AIContext) -> AIResponse {
        let city = assistantCityName(context)
        let places = context.places.filter { sameCity($0, context: context) }.prefix(5)
        guard !places.isEmpty else {
            return missingInformationResponse(language: language)
        }

        let placeTitles = places.map(\.title).joined(separator: ", ")
        let answer: String
        let next: String
        switch language {
        case .russian:
            answer = "В \(city) можно посмотреть: \(placeTitles). Это места только выбранного города, без контента из другого города."
            next = "Откройте Places to visit или Map, чтобы увидеть карточки и координаты, если они есть."
        case .dutch:
            answer = "In \(city) kunt u bezoeken: \(placeTitles). Dit zijn alleen plekken voor de gekozen stad, zonder content uit een andere stad."
            next = "Open Places to visit of Map voor kaarten en coördinaten als die beschikbaar zijn."
        case .english:
            answer = "In \(city), you can visit: \(placeTitles). These are selected-city places only, without content from another city."
            next = "Open Places to visit or Map to see cards and coordinates when available."
        }

        return directResponse(
            answer: answer,
            why: nil,
            next: next,
            sources: places.compactMap(\.source),
            routeID: "map",
            language: language,
            verified: false,
            confidence: .high
        )
    }

    private static func clarificationResponse(language: AppLanguage) -> AIResponse {
        let answer: String
        let sectionTitle: String
        let nextTitle: String
        switch language {
        case .russian:
            answer = "Уточните, что вы имеете в виду: BIG-register для проверки врача, большой штраф, крупный багаж в транспорте или большие события в городе?"
            sectionTitle = "Уточнение"
            nextTitle = "Выберите тему"
        case .dutch:
            answer = "Bedoelt u BIG-register voor zorgverleners, een hoge boete, grote bagage in het OV, of grote evenementen in de stad?"
            sectionTitle = "Verduidelijking"
            nextTitle = "Kies een onderwerp"
        case .english:
            answer = "What do you mean by “big”: BIG-register for healthcare professionals, a big fine, large luggage on transport, or big events in the city?"
            sectionTitle = "Clarification"
            nextTitle = "Choose a topic"
        }

        return AIResponse(
            answer: answer,
            sources: [],
            safetyNote: nil,
            suggestedActions: relatedTopicTitles(language: language),
            quickActions: relatedTopicActions(language: language),
            sections: [
                AIResponseSection(title: sectionTitle, body: answer, symbol: "questionmark.circle.fill")
            ],
            nextStep: AINextStep(
                title: nextTitle,
                detail: answer,
                destinationID: nil,
                destinationTitle: nil
            ),
            appDestinationID: nil,
            isVerified: false
        )
    }

    private static func touristBSNResponse(language: AppLanguage, context: AIContext) -> AIResponse {
        let city = context.selectedCity ?? "the Netherlands"
        let answer: String
        let why: String
        let next: String
        switch language {
        case .russian:
            answer = "Для туриста BSN обычно не нужен. BSN — это Dutch citizen service number для людей, которые регистрируются в Нидерландах, работают, учатся или пользуются резидентскими госуслугами."
            why = "Если вы в \(city) как short-stay tourist, начните с транспорта, правил пребывания, экстренной помощи, медицины для туристов или потерянных документов. Не вводите BSN в чат."
            next = "Если вы переезжаете, работаете или учитесь в Нидерландах, смените сценарий с Tourist на подходящую категорию."
        case .dutch:
            answer = "Als toerist heeft u meestal geen BSN nodig. Een BSN is een burgerservicenummer voor mensen die zich in Nederland inschrijven, werken, studeren of overheidsdiensten voor inwoners gebruiken."
            why = "Bent u als short-stay tourist in \(city), begin dan met vervoer, verblijfsregels, noodhulp, toeristenzorg of verloren documenten. Voer geen BSN in de chat in."
            next = "Als u verhuist, werkt of studeert in Nederland, wissel dan van Tourist naar de passende categorie."
        case .english:
            answer = "Most short-stay tourists do not need a BSN. A BSN is a Dutch citizen service number for people who register in the Netherlands, work, study, or use resident government services."
            why = "If you are in \(city) as a tourist, start with transport, stay rules, emergency help, tourist healthcare, or lost documents. Do not type your BSN into chat."
            next = "If you are moving, working, or studying in the Netherlands, switch from Tourist to the matching category first."
        }
        return directResponse(answer: answer, why: why, next: next, routeID: "documents", language: language, verified: false, confidence: .high)
    }

    private static func touristDigiDResponse(language: AppLanguage, context: AIContext) -> AIResponse {
        let city = context.selectedCity ?? "the Netherlands"
        let answer: String
        let why: String
        let next: String
        switch language {
        case .russian:
            answer = "Туристу обычно не нужен DigiD. DigiD — это официальный логин для Dutch government services, чаще нужен резидентам, работникам, студентам или людям с регистрацией."
            why = "Для туристического сценария в \(city) YouNew покажет транспорт, правила, emergency, healthcare и lost documents, а не resident-only бюрократию."
            next = "Если у вас есть резидентская задача, смените категорию перед вопросом."
        case .dutch:
            answer = "Een toerist heeft meestal geen DigiD nodig. DigiD is de officiële login voor Nederlandse overheidsdiensten en is vooral relevant voor inwoners, werknemers, studenten of mensen met registratie."
            why = "Voor de toeristische route in \(city) toont YouNew vervoer, regels, noodhulp, zorg en verloren documenten, geen inwoner-only bureaucratie."
            next = "Heeft u een inwonerstaak, wissel dan eerst van categorie."
        case .english:
            answer = "Tourists usually do not need DigiD. DigiD is the official login for Dutch government services and is mainly for residents, workers, students, or people with registration."
            why = "For a tourist in \(city), YouNew should focus on transport, rules, emergency help, healthcare, and lost documents instead of resident-only bureaucracy."
            next = "If your question is about moving, work, or study, switch category before asking."
        }
        return directResponse(answer: answer, why: why, next: next, routeID: "documents", language: language, verified: false, confidence: .high)
    }

    private static func touristEmergencyResponse(language: AppLanguage, context: AIContext) -> AIResponse {
        let city = context.selectedCity ?? "the Netherlands"
        let source = firstMatchingSource(in: context, keywords: ["112", "politie", "police", "emergency"])
        let answer: String
        let why: String
        let next: String
        switch language {
        case .russian:
            answer = "В экстренной ситуации в \(city) звоните 112: опасность для жизни, пожар, преступление сейчас или срочная медицинская помощь."
            why = "112 работает по всей территории Нидерландов и подходит туристам. Не отправляйте медицинские детали или номера документов в чат."
            next = "Если это не срочно, используйте non-emergency police или туристическую медицинскую помощь."
        case .dutch:
            answer = "Bel in een noodsituatie in \(city) 112: levensgevaar, brand, een misdrijf dat nu gebeurt of spoedeisende medische hulp."
            why = "112 werkt overal in Nederland en is ook voor toeristen. Deel geen medische details of documentnummers in de chat."
            next = "Is het niet dringend, gebruik dan geen-spoed politie of toeristische zorg."
        case .english:
            answer = "In an emergency in \(city), call 112 for life danger, fire, a crime happening now, or urgent medical help."
            why = "112 works across the Netherlands and applies to tourists. Do not share medical details or document numbers in chat."
            next = "If it is not urgent, use non-emergency police or tourist healthcare instead."
        }
        return directResponse(answer: answer, why: why, next: next, sources: source.map { [$0] } ?? [], routeID: "emergency", language: language, verified: source != nil, confidence: .high)
    }

    private static func touristLostDocumentsResponse(language: AppLanguage, context: AIContext) -> AIResponse {
        let city = context.selectedCity ?? "the Netherlands"
        let source = embassySource(language: language)
        let answer: String
        let why: String
        let next: String
        switch language {
        case .russian:
            answer = "Если турист потерял паспорт или документы в \(city), сначала проверьте безопасность, затем свяжитесь с посольством или консульством своей страны. При краже или опасной ситуации используйте 112 для emergency или полицию для заявления."
            why = "Паспортные данные нельзя вводить в чат. YouNew может подсказать порядок действий, но документ заменяет только ваше консульство."
            next = "Откройте Emergency или сохраните контакты посольства/консульства и номера 112."
        case .dutch:
            answer = "Bent u als toerist uw paspoort of documenten kwijt in \(city), controleer eerst uw veiligheid en neem daarna contact op met uw ambassade of consulaat. Bij diefstal of gevaar gebruikt u 112 of de politie."
            why = "Voer geen paspoortnummers in de chat in. YouNew kan stappen uitleggen, maar alleen uw consulaat kan een reisdocument regelen."
            next = "Open Emergency of bewaar de contactgegevens van uw ambassade/consulaat en 112."
        case .english:
            answer = "If you are a tourist and lose your passport or documents in \(city), first make sure you are safe, then contact your embassy or consulate. If it was stolen or you are in danger, use 112 for emergencies or contact the police."
            why = "Do not type passport numbers into chat. YouNew can guide the steps, but only your embassy or consulate can arrange replacement travel documents."
            next = "Open Emergency, then save your embassy or consulate contact and 112."
        }
        return directResponse(answer: answer, why: why, next: next, sources: [source], routeID: "emergency", language: language, verified: true, confidence: .high)
    }

    private static func touristTransportResponse(language: AppLanguage, context: AIContext) -> AIResponse {
        let city = context.selectedCity ?? "the Netherlands"
        let sources = [
            OfficialSource(title: "9292", url: URL(string: "https://9292.nl/en"), institution: "9292"),
            OfficialSource(title: "OVpay", url: URL(string: "https://www.ovpay.nl/en"), institution: "OVpay")
        ]
        let answer: String
        let why: String
        let next: String
        switch language {
        case .russian:
            answer = "Для туриста в \(city) начните с маршрута через 9292 или NS, а оплату в OV проверяйте через OVpay/OV-chipkaart. В транспорте важно делать check-in и check-out."
            why = "Так YouNew не смешивает туристический транспорт с резидентскими BSN/DigiD задачами."
            next = "Откройте Transport или карту, чтобы найти станции, tram/metro/bus и ближайшие transport points."
        case .dutch:
            answer = "Voor een toerist in \(city): plan de route via 9292 of NS en controleer betalen via OVpay/OV-chipkaart. In het OV moet u in- en uitchecken."
            why = "Zo blijft de toeristische vervoersroute gescheiden van inwoner-only BSN/DigiD-taken."
            next = "Open Transport of Map voor stations, tram/metro/bus en transportpunten in de buurt."
        case .english:
            answer = "For a tourist in \(city), plan routes with 9292 or NS and check payment with OVpay/OV-chipkaart. Remember to check in and check out on public transport."
            why = "This keeps tourist transport separate from resident-only BSN/DigiD tasks."
            next = "Open Transport or Map to find stations, tram/metro/bus routes, and nearby transport points."
        }
        return directResponse(answer: answer, why: why, next: next, sources: sources, routeID: "transport", language: language, verified: true, confidence: .high)
    }

    private static func touristBikeRulesResponse(language: AppLanguage, context: AIContext) -> AIResponse {
        let city = context.selectedCity ?? "the Netherlands"
        let answer: String
        let why: String
        let next: String
        switch language {
        case .russian:
            answer = "В \(city) туристу на велосипеде важно ехать по велодорожке, соблюдать светофоры, не держать телефон в руке и парковать велосипед только там, где это разрешено."
            why = "За телефон, красный свет или неправильную парковку могут быть штрафы, а в центре велосипеды часто убирают."
            next = "Откройте Rules & fines или Transport перед поездкой."
        case .dutch:
            answer = "In \(city) moet een toerist op de fiets fietspaden gebruiken, verkeerslichten volgen, geen telefoon vasthouden en alleen toegestaan parkeren."
            why = "Telefoon vasthouden, rood licht of verkeerd parkeren kan een boete opleveren; in het centrum worden fietsen vaak verwijderd."
            next = "Open Rules & fines of Transport voordat u gaat fietsen."
        case .english:
            answer = "In \(city), tourists cycling should use bike lanes, follow traffic lights, not hold a phone, and park only where allowed."
            why = "Phone use, red lights, or wrong parking can lead to fines, and bikes may be removed in busy areas."
            next = "Open Rules & fines or Transport before riding."
        }
        return directResponse(answer: answer, why: why, next: next, routeID: "rulesAndFines", language: language, verified: false, confidence: .medium)
    }

    private static func touristRulesAndFinesResponse(language: AppLanguage, context: AIContext) -> AIResponse {
        let city = context.selectedCity ?? "the Netherlands"
        let source = firstMatchingSource(in: context, keywords: ["cjib", "fine", "boete", "rules"])
        let answer: String
        let why: String
        let next: String
        switch language {
        case .russian:
            answer = "Для туриста в \(city) самые частые риски штрафов: транспорт без check-in/out, велосипедные нарушения, алкоголь/шум в запрещённых местах и неправильная парковка."
            why = "Штрафы могут прийти позже или потребовать оплаты на месте через официальный процесс. Не платите по подозрительным ссылкам."
            next = "Откройте Rules & fines и проверяйте конкретный штраф только по официальной ссылке."
        case .dutch:
            answer = "Voor toeristen in \(city) zijn veelvoorkomende boeterisico's: OV zonder check-in/out, fietsregels, alcohol/overlast waar verboden en verkeerd parkeren."
            why = "Boetes kunnen later komen of via een officieel proces betaald worden. Betaal niet via verdachte links."
            next = "Open Rules & fines en controleer een specifieke boete alleen via een officiële link."
        case .english:
            answer = "For tourists in \(city), common fine risks are public transport without check-in/out, bike rule violations, alcohol/noise where prohibited, and wrong parking."
            why = "Fines may arrive later or need payment through an official process. Do not pay through suspicious links."
            next = "Open Rules & fines and verify any specific fine only through an official link."
        }
        return directResponse(answer: answer, why: why, next: next, sources: source.map { [$0] } ?? [], routeID: "rulesAndFines", language: language, verified: source != nil, confidence: .high)
    }

    private static func touristPlacesResponse(language: AppLanguage, context: AIContext) -> AIResponse {
        let city = context.selectedCity ?? "the Netherlands"
        let answer: String
        let next: String
        switch language {
        case .russian:
            answer = "Ищите места именно в \(city): музеи, популярные районы, transport hubs и безопасные nearby services. YouNew не будет подставлять другой город, если вы не спросите."
            next = "Откройте Places или Map и фильтруйте по нужной категории."
        case .dutch:
            answer = "Zoek plekken specifiek in \(city): musea, populaire buurten, vervoerspunten en veilige diensten dichtbij. YouNew gebruikt geen andere stad tenzij u daarom vraagt."
            next = "Open Places of Map en filter op de juiste categorie."
        case .english:
            answer = "Look for places specifically in \(city): museums, popular areas, transport hubs, and safe nearby services. YouNew should not switch cities unless you ask."
            next = "Open Places or Map and filter by the category you need."
        }
        return directResponse(answer: answer, why: nil, next: next, routeID: "map", language: language, verified: false, confidence: .medium)
    }

    private static func touristHealthcareResponse(language: AppLanguage, context: AIContext) -> AIResponse {
        let city = context.selectedCity ?? "the Netherlands"
        let answer: String
        let why: String
        let next: String
        switch language {
        case .russian:
            answer = "Туристу в \(city): при угрозе жизни звоните 112; при несрочной проблеме ищите huisartsenspoedpost/GP out-of-hours или аптеку. Берите travel insurance details, но не вводите медицинские данные в чат."
            why = "Туристический healthcare отличается от резидентской страховки и регистрации у huisarts."
            next = "Откройте Emergency для срочного случая или Map для healthcare/pharmacy рядом."
        case .dutch:
            answer = "Als toerist in \(city): bel 112 bij levensgevaar; zoek bij niet-spoed een huisartsenpost/GP out-of-hours of apotheek. Houd reisverzekeringsgegevens bij de hand, maar deel geen medische details in chat."
            why = "Toeristische zorg is anders dan inwonerszorgverzekering en inschrijving bij een huisarts."
            next = "Open Emergency bij spoed of Map voor healthcare/pharmacy dichtbij."
        case .english:
            answer = "As a tourist in \(city): call 112 for life-threatening emergencies; for non-urgent care, look for a GP out-of-hours service or pharmacy. Keep travel insurance details ready, but do not type medical details into chat."
            why = "Tourist healthcare is different from resident health insurance and GP registration."
            next = "Open Emergency for urgent cases or Map for nearby healthcare/pharmacy."
        }
        return directResponse(answer: answer, why: why, next: next, routeID: "healthcare", language: language, verified: false, confidence: .medium)
    }

    private static func directResponse(
        answer: String,
        why: String?,
        next: String,
        sources: [OfficialSource] = [],
        routeID: String?,
        language: AppLanguage,
        verified: Bool,
        confidence: AIResponseConfidence
    ) -> AIResponse {
        let actionTitle: String
        switch language {
        case .russian: actionTitle = "Открыть раздел"
        case .dutch: actionTitle = "Sectie openen"
        case .english: actionTitle = "Open section"
        }
        var actions: [AIResponseAction] = []
        if let routeID {
            actions.append(.openScreen(title: actionTitle, destinationID: routeID))
        }
        actions += sources.compactMap { source in
            source.url.map { .openSource(title: source.title, url: $0) }
        }

        var sections = [
            AIResponseSection(title: label(.answer, language), body: answer, symbol: "checkmark.circle.fill")
        ]
        if let meaning = directMeaningText(language: language) {
            sections.append(AIResponseSection(title: label(.meaning, language), body: meaning, symbol: "info.circle.fill"))
        }
        if let why, !why.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            sections.append(AIResponseSection(title: label(.why, language), body: why, symbol: "exclamationmark.circle.fill"))
        }
        if !next.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            sections.append(AIResponseSection(title: label(.next, language), body: next, symbol: "arrow.right.circle.fill"))
        }
        let actionText = actions.prefix(5).map { "- \($0.title)" }.joined(separator: "\n")
        if !actionText.isEmpty {
            sections.append(AIResponseSection(title: label(.actions, language), body: actionText, symbol: "square.grid.2x2.fill"))
        }
        let related = relatedTopics(for: routeID, language: language)
        if !related.isEmpty {
            sections.append(AIResponseSection(title: label(.related, language), body: related, symbol: "arrow.triangle.branch"))
        }
        let sourceText = directSourceText(sources: sources, language: language)
        if !sourceText.isEmpty {
            sections.append(AIResponseSection(title: label(.source, language), body: sourceText, symbol: "checkmark.seal.fill"))
        }

        return AIResponse(
            answer: answer,
            sources: sources,
            safetyNote: nil,
            suggestedActions: actions.map(\.title),
            quickActions: actions,
            sections: sections,
            nextStep: AINextStep(title: label(.next, language), detail: next, destinationID: routeID, destinationTitle: actionTitle),
            appDestinationID: routeID,
            isVerified: verified,
            confidence: confidence
        )
    }

    private static func directMeaningText(language: AppLanguage) -> String? {
        switch language {
        case .russian:
            return "YouNew связывает ответ с вашим сценарием, текущим городом и безопасным следующим шагом в приложении."
        case .dutch:
            return "YouNew koppelt dit antwoord aan uw situatie, huidige stad en een veilige volgende stap in de app."
        case .english:
            return "YouNew connects this answer to your profile, current city, and a safe next step in the app."
        }
    }

    private static func relatedTopics(for routeID: String?, language: AppLanguage) -> String {
        let topics: [String]
        switch routeID {
        case "documents":
            topics = localizedList(
                english: ["DigiD", "Municipality registration", "Official sources"],
                dutch: ["DigiD", "Gemeentelijke inschrijving", "Officiele bronnen"],
                russian: ["DigiD", "Регистрация в gemeente", "Официальные источники"],
                language: language
            )
        case "transport":
            topics = localizedList(
                english: ["OVpay", "9292", "Bike rules"],
                dutch: ["OVpay", "9292", "Fietsregels"],
                russian: ["OVpay", "9292", "Правила велосипеда"],
                language: language
            )
        case "emergency":
            topics = localizedList(
                english: ["112", "Police", "Healthcare"],
                dutch: ["112", "Politie", "Zorg"],
                russian: ["112", "Полиция", "Медицина"],
                language: language
            )
        case "rulesAndFines":
            topics = localizedList(
                english: ["CJIB", "Bike fines", "Transport rules"],
                dutch: ["CJIB", "Fietsboetes", "OV-regels"],
                russian: ["CJIB", "Велоштрафы", "Правила транспорта"],
                language: language
            )
        case "healthcare":
            topics = localizedList(
                english: ["Emergency", "Pharmacy", "Health insurance"],
                dutch: ["Noodhulp", "Apotheek", "Zorgverzekering"],
                russian: ["Экстренная помощь", "Аптека", "Медицинская страховка"],
                language: language
            )
        case "map":
            topics = localizedList(
                english: ["Nearby places", "Transport", "Local partners"],
                dutch: ["Plekken dichtbij", "Vervoer", "Lokale partners"],
                russian: ["Места рядом", "Транспорт", "Локальные партнеры"],
                language: language
            )
        default:
            topics = localizedList(
                english: ["Search", "Official sources", "Saved items"],
                dutch: ["Zoeken", "Officiele bronnen", "Bewaard"],
                russian: ["Поиск", "Официальные источники", "Сохраненное"],
                language: language
            )
        }
        return topics.map { "- \($0)" }.joined(separator: "\n")
    }

    private static func directSourceText(sources: [OfficialSource], language: AppLanguage) -> String {
        guard !sources.isEmpty else {
            switch language {
            case .russian: return "Официальный источник не привязан к этому быстрому ответу. Проверьте важные детали в Official Sources."
            case .dutch: return "Geen officiele bron gekoppeld aan dit snelle antwoord. Controleer belangrijke details in Official Sources."
            case .english: return "No official source is attached to this quick answer. Check important details in Official Sources."
            }
        }
        return sources.prefix(4).map { source in
            let institution = source.institution.map { " · \($0)" } ?? ""
            return "- \(source.title)\(institution)"
        }.joined(separator: "\n")
    }

    private static func localizedList(english: [String], dutch: [String], russian: [String], language: AppLanguage) -> [String] {
        switch language {
        case .russian: return russian
        case .dutch: return dutch
        case .english: return english
        }
    }

    private static func shortClarificationResponse(language: AppLanguage) -> AIResponse {
        let answer: String
        switch language {
        case .russian:
            answer = "Уточните, что именно вы хотите узнать?"
        case .dutch:
            answer = "Kunt u kort verduidelijken wat u wilt weten?"
        case .english:
            answer = "What exactly do you want to know?"
        }
        return AIResponse(
            answer: answer,
            sources: [],
            safetyNote: nil,
            suggestedActions: [],
            sections: [AIResponseSection(title: label(.answer, language), body: answer, symbol: "questionmark.circle.fill")],
            isVerified: false,
            confidence: .low
        )
    }

    private static func missingInformationResponse(language: AppLanguage) -> AIResponse {
        let answer: String
        let next: String
        switch language {
        case .russian:
            answer = "У меня пока нет проверенной информации об этом в YouNew."
            next = "Попробуйте поиск по приложению или выберите ближайший раздел: Transport, Emergency, Rules & fines, Healthcare или Places."
        case .dutch:
            answer = "Ik heb hierover nog geen geverifieerde informatie in YouNew."
            next = "Probeer zoeken in de app of kies de dichtstbijzijnde sectie: Transport, Emergency, Rules & fines, Healthcare of Places."
        case .english:
            answer = "I don’t have verified information for this in YouNew yet."
            next = "Try app search or open the closest section: Transport, Emergency, Rules & fines, Healthcare, or Places."
        }
        return AIResponse(
            answer: answer,
            sources: [],
            safetyNote: nil,
            suggestedActions: [],
            sections: [
                AIResponseSection(title: label(.answer, language), body: answer, symbol: "exclamationmark.shield.fill"),
                AIResponseSection(title: label(.next, language), body: next, symbol: "arrow.right.circle.fill")
            ],
            nextStep: AINextStep(title: label(.next, language), detail: next, destinationID: "search", destinationTitle: "Search"),
            appDestinationID: "search",
            isVerified: false,
            confidence: .low
        )
    }

    private static func relatedTopicTitles(language: AppLanguage) -> [String] {
        relatedTopicActions(language: language).map(\.title)
    }

    private static func relatedTopicActions(language: AppLanguage) -> [AIResponseAction] {
        switch language {
        case .russian:
            return [
                .relatedTopic("BIG-register", query: "BIG-register"),
                .relatedTopic("Штрафы", query: "big fine"),
                .relatedTopic("Транспорт", query: "large luggage transport")
            ]
        case .dutch:
            return [
                .relatedTopic("BIG-register", query: "BIG-register"),
                .relatedTopic("Hoge boete", query: "big fine"),
                .relatedTopic("Vervoer", query: "large luggage transport")
            ]
        case .english:
            return [
                .relatedTopic("BIG-register", query: "BIG-register"),
                .relatedTopic("Big fine", query: "big fine"),
                .relatedTopic("Transport luggage", query: "large luggage transport")
            ]
        }
    }

    private static func embassySource(language: AppLanguage) -> OfficialSource {
        switch language {
        case .russian:
            return OfficialSource(title: "Netherlands Worldwide", url: URL(string: "https://www.netherlandsworldwide.nl"), institution: "Ministry of Foreign Affairs")
        case .dutch:
            return OfficialSource(title: "Netherlands Worldwide", url: URL(string: "https://www.netherlandsworldwide.nl"), institution: "Ministerie van Buitenlandse Zaken")
        case .english:
            return OfficialSource(title: "Netherlands Worldwide", url: URL(string: "https://www.netherlandsworldwide.nl"), institution: "Ministry of Foreign Affairs")
        }
    }

    private enum SectionLabel {
        case answer
        case meaning
        case why
        case next
        case actions
        case related
        case source
    }

    private static func label(_ label: SectionLabel, _ language: AppLanguage) -> String {
        switch (label, language) {
        case (.answer, .russian): return "Ответ"
        case (.answer, .dutch): return "Antwoord"
        case (.answer, .english): return "Answer"
        case (.meaning, .russian): return "Что это означает"
        case (.meaning, .dutch): return "Wat dit betekent"
        case (.meaning, .english): return "What This Means"
        case (.why, .russian): return "Почему это важно"
        case (.why, .dutch): return "Waarom dit belangrijk is"
        case (.why, .english): return "Why it matters"
        case (.next, .russian): return "Следующий шаг"
        case (.next, .dutch): return "Volgende stap"
        case (.next, .english): return "Next step"
        case (.actions, .russian): return "Полезные действия"
        case (.actions, .dutch): return "Nuttige acties"
        case (.actions, .english): return "Useful Actions"
        case (.related, .russian): return "Связанные темы"
        case (.related, .dutch): return "Verwante onderwerpen"
        case (.related, .english): return "Related Topics"
        case (.source, .russian): return "Официальный источник"
        case (.source, .dutch): return "Officiele bron"
        case (.source, .english): return "Official Source"
        }
    }

    private static func normalize(_ value: String) -> String {
        value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func isAmbiguousBigQuery(_ normalized: String) -> Bool {
        normalized == "big"
    }

    private static func assistantCityName(_ context: AIContext) -> String {
        context.selectedCityData?.name
            ?? nonEmpty(context.selectedCity)
            ?? "the Netherlands"
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func sameCity(_ link: TravelLinkItem, context: AIContext) -> Bool {
        guard let city = context.selectedCityData else {
            return context.selectedCity.map { link.cityId.caseInsensitiveCompare($0) == .orderedSame } ?? true
        }
        return link.cityId.caseInsensitiveCompare(city.id.rawValue) == .orderedSame
    }

    private static func sameCity(_ item: FoodGuideItem, context: AIContext) -> Bool {
        guard let city = context.selectedCityData else {
            return context.selectedCity.flatMap(CityId.resolve).map { item.cityId == $0 } ?? true
        }
        return item.cityId == city.id
    }

    private static func sameCity(_ place: PlaceItem, context: AIContext) -> Bool {
        let selectedName = context.selectedCityData?.name ?? context.selectedCity
        guard let selectedName else { return true }
        return place.cityId.caseInsensitiveCompare(selectedName) == .orderedSame
    }

    private static func containsStay(_ normalized: String) -> Bool {
        normalized.contains("where can i stay")
            || normalized.contains("hotel")
            || normalized.contains("hotels")
            || normalized.contains("stay")
            || normalized.contains("stays")
            || normalized.contains("accommodation")
            || normalized.contains("overnachten")
            || normalized.contains("verblijf")
            || normalized.contains("отел")
            || normalized.contains("жиль")
            || normalized.contains("где останов")
    }

    private static func containsBooking(_ normalized: String) -> Bool {
        normalized == "booking"
            || normalized.contains("booking.com")
            || normalized.contains("booking")
    }

    private static func containsRestaurants(_ normalized: String) -> Bool {
        normalized == "restaurants"
            || normalized == "restaurant"
            || normalized.contains("restaurants")
            || normalized.contains("restaurant")
            || normalized.contains("where can i eat")
            || normalized.contains("food")
            || normalized.contains("dinner")
            || normalized.contains("lunch")
            || normalized.contains("eten")
            || normalized.contains("restaurant")
            || normalized.contains("ресторан")
            || normalized.contains("еда")
            || normalized.contains("поесть")
    }

    private static func containsCafes(_ normalized: String) -> Bool {
        normalized == "cafes"
            || normalized == "cafe"
            || normalized.contains("cafes")
            || normalized.contains("cafe")
            || normalized.contains("coffee")
            || normalized.contains("breakfast")
            || normalized.contains("koffie")
            || normalized.contains("ontbijt")
            || normalized.contains("кафе")
            || normalized.contains("кофе")
            || normalized.contains("завтрак")
    }

    private static func containsVisitPlaces(_ normalized: String) -> Bool {
        normalized.contains("what can i visit")
            || normalized.contains("where can i visit")
            || normalized.contains("visit")
            || normalized.contains("attraction")
            || normalized.contains("attractions")
            || normalized.contains("sightseeing")
            || normalized.contains("places to visit")
            || normalized.contains("что посмотреть")
            || normalized.contains("куда сходить")
            || normalized.contains("bezoeken")
    }

    private static func containsBSN(_ normalized: String) -> Bool {
        normalized.contains("bsn") || normalized.contains("burgerservicenummer") || normalized.contains("citizen service number")
    }

    private static func containsDigiD(_ normalized: String) -> Bool {
        normalized.contains("digid") || normalized.contains("digi d")
    }

    private static func containsLostDocument(_ normalized: String) -> Bool {
        (normalized.contains("lost") || normalized.contains("stolen") || normalized.contains("потер") || normalized.contains("украл") || normalized.contains("kwijt") || normalized.contains("gestolen"))
            && (normalized.contains("passport") || normalized.contains("document") || normalized.contains("паспорт") || normalized.contains("документ") || normalized.contains("paspoort"))
    }

    private static func containsTransport(_ normalized: String) -> Bool {
        normalized == "transport"
            || normalized.contains("transport")
            || normalized.contains("ov")
            || normalized.contains("train")
            || normalized.contains("tram")
            || normalized.contains("metro")
            || normalized.contains("bus")
            || normalized.contains("транспорт")
            || normalized.contains("vervoer")
    }

    private static func containsEmergency(_ normalized: String) -> Bool {
        normalized == "112"
            || normalized.contains("emergency")
            || normalized.contains("urgent")
            || normalized.contains("spoed")
            || normalized.contains("nood")
            || normalized.contains("экстр")
            || normalized.contains("сроч")
    }

    private static func containsBikeRules(_ normalized: String) -> Bool {
        normalized.contains("bike")
            || normalized.contains("bicycle")
            || normalized.contains("cycling")
            || normalized.contains("fiets")
            || normalized.contains("велосип")
    }

    private static func containsFinesOrRules(_ normalized: String) -> Bool {
        normalized.contains("fine")
            || normalized.contains("fines")
            || normalized.contains("rule")
            || normalized.contains("rules")
            || normalized.contains("boete")
            || normalized.contains("regels")
            || normalized.contains("штраф")
            || normalized.contains("правил")
    }

    private static func containsPlaces(_ normalized: String) -> Bool {
        normalized.contains("museum")
            || normalized.contains("museums")
            || normalized.contains("place")
            || normalized.contains("places")
            || normalized.contains("attraction")
            || normalized.contains("where to go")
            || normalized.contains("музе")
            || normalized.contains("мест")
            || normalized.contains("plek")
            || normalized.contains("bezienswaard")
    }

    private static func containsHealthcare(_ normalized: String) -> Bool {
        normalized.contains("health")
            || normalized.contains("healthcare")
            || normalized.contains("doctor")
            || normalized.contains("hospital")
            || normalized.contains("pharmacy")
            || normalized.contains("huisarts")
            || normalized.contains("ziekenhuis")
            || normalized.contains("apotheek")
            || normalized.contains("мед")
            || normalized.contains("врач")
            || normalized.contains("аптек")
    }

    private static func isVeryShortAmbiguousQuery(_ normalized: String) -> Bool {
        normalized.count <= 3
    }

    private static func firstMatchingSource(in context: AIContext, keywords: [String]) -> OfficialSource? {
        context.officialSources.first { source in
            let haystack = [source.title, source.institution ?? "", source.url?.absoluteString ?? ""]
                .joined(separator: " ")
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
                .lowercased()
            return keywords.contains { haystack.contains($0.lowercased()) }
        }
    }
}
