import Foundation

nonisolated enum TransportGuideData {
    static let guide = TransportGuide(
        id: "transport-netherlands",
        title: text(
            "Transport in the Netherlands",
            "Vervoer in Nederland",
            "Транспорт в Нидерландах"
        ),
        summary: text(
            "The Netherlands has an integrated public transport system with trains, buses, trams, metro, ferries, cycling routes, and digital payment options.",
            "Nederland heeft een verbonden vervoerssysteem met treinen, bussen, trams, metro, veerboten, fietsroutes en digitale betaalopties.",
            "В Нидерландах есть связанная система транспорта: поезда, автобусы, трамваи, метро, паромы, велосипеды и цифровая оплата."
        ),
        sections: [
            section(
                "transport.overview",
                "Overview",
                "Overzicht",
                "Обзор",
                "Use official planners and operators for live times, platform changes, tickets, and accessibility information.",
                "Gebruik officiële planners en vervoerders voor actuele tijden, spoorwijzigingen, tickets en toegankelijkheid.",
                "Используйте официальные планировщики и сайты операторов для актуального времени, платформ, билетов и доступности.",
                "map.fill",
                ["source.ns", "source.9292"],
                [
                    point("Most everyday trips combine train, bus, tram, metro, ferry, walking, or cycling.", "Veel dagelijkse reizen combineren trein, bus, tram, metro, veerboot, lopen of fietsen.", "Повседневные поездки часто сочетают поезд, автобус, трамвай, метро, паром, пеший путь или велосипед."),
                    point("Conditions can change; verify important trips and payments at the official source.", "Voorwaarden kunnen wijzigen; controleer belangrijke reizen en betalingen bij de officiële bron.", "Условия могут меняться; важные поездки и оплату проверяйте на официальном сайте.")
                ]
            ),
            section(
                "transport.trains",
                "NS trains",
                "NS-treinen",
                "Поезда NS",
                "NS is the main railway operator in the Netherlands. Check route, platform, transfers, delays, and payment rules on NS.",
                "NS is de belangrijkste spoorvervoerder in Nederland. Controleer route, perron, overstappen, vertragingen en betaalregels bij NS.",
                "NS — главный железнодорожный оператор в Нидерландах. Для поездок проверяйте маршрут, платформу, пересадки, задержки и правила оплаты на официальном сайте или в приложении NS.",
                "train.side.front.car",
                ["source.ns"],
                [
                    point("Use NS for train times, disruption updates, tickets, subscriptions, and station information.", "Gebruik NS voor treintijden, storingen, tickets, abonnementen en stationsinformatie.", "Используйте NS для расписания поездов, сбоев, билетов, абонементов и информации о станциях."),
                    point("For some trains, supplements or specific conditions may apply; verify before boarding.", "Voor sommige treinen gelden toeslagen of voorwaarden; controleer dit voor vertrek.", "Для некоторых поездов могут действовать доплаты или особые условия; проверяйте до посадки.")
                ]
            ),
            section(
                "transport.busTramMetro",
                "Bus, tram, and metro",
                "Bus, tram en metro",
                "Автобусы, трамваи и метро",
                "Cities and regions use different operators. Check the current route and payment rules with the operator before travelling.",
                "Steden en regio's gebruiken verschillende vervoerders. Controleer route en betaalregels bij de vervoerder voordat je reist.",
                "В городах и регионах работают разные операторы. В Амстердаме часто используется GVB, в Роттердаме RET, в Гааге HTM, в Утрехте U-OV. Перед поездкой проверяйте актуальный маршрут и оплату у оператора.",
                "tram.fill",
                ["source.gvb", "source.ret", "source.htm", "source.uov", "source.arriva"],
                [
                    point("Amsterdam commonly uses GVB; Rotterdam uses RET; The Hague uses HTM; Utrecht uses U-OV.", "Amsterdam gebruikt vaak GVB; Rotterdam RET; Den Haag HTM; Utrecht U-OV.", "В Амстердаме часто используется GVB, в Роттердаме RET, в Гааге HTM, в Утрехте U-OV."),
                    point("Regional routes may be run by operators such as Arriva or Qbuzz depending on the area.", "Regionale lijnen kunnen per gebied door bijvoorbeeld Arriva of Qbuzz worden gereden.", "Региональные маршруты могут обслуживаться Arriva, Qbuzz и другими операторами в зависимости от региона.")
                ]
            ),
            section(
                "transport.ovChipkaart",
                "OV-chipkaart",
                "OV-chipkaart",
                "OV-chipkaart",
                "OV-chipkaart is a public transport card for trains, buses, trams, and metro. Check card type, balance, and conditions on the official site.",
                "De OV-chipkaart is een kaart voor trein, bus, tram en metro. Controleer kaarttype, saldo en voorwaarden op de officiële site.",
                "OV-chipkaart — транспортная карта для общественного транспорта. Её можно использовать для поездов, автобусов, трамваев и метро. Условия, баланс и тип карты нужно проверять на официальном сайте.",
                "creditcard.fill",
                ["source.ovchipkaart"],
                [
                    point("Check in and check out where required; use the same card or device for one journey.", "Check in en uit waar dat nodig is; gebruik dezelfde kaart of hetzelfde apparaat voor een reis.", "Делайте check-in и check-out там, где требуется; используйте одну карту или устройство для одной поездки."),
                    point("Personal and anonymous cards can have different options and protections.", "Persoonlijke en anonieme kaarten hebben verschillende opties en bescherming.", "Личная и анонимная карты могут иметь разные функции и защиту.")
                ]
            ),
            section(
                "transport.ovpay",
                "OVpay and bank card",
                "OVpay",
                "OVpay и банковская карта",
                "OVpay lets you pay in public transport with a bank card, phone, or smart watch where the operator supports it.",
                "Met OVpay betaal je in het ov met bankpas, telefoon of smartwatch waar de vervoerder dit ondersteunt.",
                "OVpay позволяет платить в общественном транспорте банковской картой, телефоном или смарт-часами, если поддерживается оператором. Всегда проверяйте, как работает check-in и check-out.",
                "wave.3.right.circle.fill",
                ["source.ovpay"],
                [
                    point("Use one card or device for both check-in and check-out.", "Gebruik een kaart of apparaat voor in- en uitchecken.", "Используйте одну карту или устройство для check-in и check-out."),
                    point("Check OVpay for refunds, missed check-out, and payment overview rules.", "Controleer OVpay voor terugbetalingen, vergeten uitchecken en betaaloverzichten.", "Проверяйте OVpay по вопросам возврата, пропущенного check-out и истории оплат.")
                ]
            ),
            section(
                "transport.journeyPlanning",
                "Journey planning",
                "Reis plannen",
                "Планирование маршрута",
                "Use NS, 9292, and operator websites for route planning. Times, platforms, and cancellations can change.",
                "Gebruik NS, 9292 en vervoerderswebsites voor routeplanning. Tijden, perrons en uitval kunnen veranderen.",
                "Для планирования маршрута используйте NS, 9292 и сайты операторов. Время, платформы и отмены могут меняться.",
                "point.topleft.down.curvedto.point.bottomright.up",
                ["source.ns", "source.9292"],
                [
                    point("9292 is useful for door-to-door public transport planning across operators.", "9292 is handig voor deur-tot-deurplanning met meerdere vervoerders.", "9292 удобен для планирования маршрута от двери до двери между разными операторами."),
                    point("Google or Apple Maps can help orientation, but official transport sources should be checked for important trips.", "Google of Apple Kaarten kunnen helpen met oriëntatie, maar controleer belangrijke reizen bij officiële ov-bronnen.", "Google или Apple Maps помогают ориентироваться, но важные поездки проверяйте в официальных транспортных источниках.")
                ]
            ),
            section(
                "transport.bikes",
                "Bicycles",
                "Fiets",
                "Велосипеды",
                "Cycling is everyday transport in the Netherlands. Check local parking rules and train-bike conditions.",
                "Fietsen is dagelijks vervoer in Nederland. Controleer lokale parkeerregels en voorwaarden voor de fiets in de trein.",
                "Велосипед — важная часть транспорта в Нидерландах. Проверяйте правила парковки, перевозки велосипеда в поезде и местные ограничения.",
                "bicycle",
                ["source.government.bicycles", "source.ns"],
                [
                    point("Stations and city centres can have strict bike parking rules.", "Stations en stadscentra kunnen strenge fietsparkeerregels hebben.", "У станций и в центрах городов могут быть строгие правила парковки велосипедов."),
                    point("Bike-on-train rules can depend on time, ticket type, and bike type.", "Regels voor fietsen in de trein hangen af van tijd, ticket en type fiets.", "Правила перевозки велосипеда в поезде зависят от времени, билета и типа велосипеда.")
                ]
            ),
            section(
                "transport.airports",
                "Airports",
                "Luchthavens",
                "Аэропорты",
                "Check airport, train, bus, and airline information before travel; airport access routes can change.",
                "Controleer luchthaven-, trein-, bus- en luchtvaartinformatie voor vertrek; routes naar luchthavens kunnen wijzigen.",
                "Перед поездкой проверяйте информацию аэропорта, поездов, автобусов и авиакомпании; маршруты до аэропорта могут меняться.",
                "airplane.departure",
                ["source.schiphol", "source.ns", "source.9292"],
                [
                    point("Schiphol has rail and bus connections; check live travel and airport information before departure.", "Schiphol heeft trein- en busverbindingen; controleer actuele reis- en luchthaveninformatie.", "У Schiphol есть железнодорожные и автобусные связи; проверяйте актуальную информацию до выезда."),
                    point("Allow extra time for transfers, security, and disruptions.", "Plan extra tijd voor overstappen, security en verstoringen.", "Оставляйте запас времени на пересадки, контроль и возможные сбои.")
                ]
            ),
            section(
                "transport.accessibility",
                "Accessibility",
                "Toegankelijkheid",
                "Доступность",
                "Accessibility differs by station, vehicle, operator, and route. Verify assistance, lifts, and step-free access before travelling.",
                "Toegankelijkheid verschilt per station, voertuig, vervoerder en route. Controleer assistentie, liften en drempelvrije toegang vooraf.",
                "Доступность зависит от станции, транспорта, оператора и маршрута. Заранее проверяйте помощь, лифты и безбарьерный доступ.",
                "figure.roll",
                ["source.ns", "source.9292"],
                [
                    point("NS and local operators publish accessibility and assistance information.", "NS en lokale vervoerders publiceren informatie over toegankelijkheid en assistentie.", "NS и местные операторы публикуют информацию о доступности и помощи."),
                    point("For critical journeys, contact the operator or check official assistance rules.", "Voor kritieke reizen neem contact op met de vervoerder of controleer assistentieregels.", "Для важных поездок свяжитесь с оператором или проверьте официальные правила помощи.")
                ]
            ),
            section(
                "transport.safetyAndRules",
                "Rules and safety",
                "Regels en veiligheid",
                "Правила и безопасность",
                "Check-in, check-out, peak times, delays, night transport, fines, and bike rules can affect your trip.",
                "Inchecken, uitchecken, spits, vertragingen, nachtvervoer, boetes en fietsregels kunnen je reis beinvloeden.",
                "Check-in, check-out, часы пик, задержки, ночной транспорт, штрафы и правила для велосипедов могут повлиять на поездку.",
                "checkmark.shield.fill",
                ["source.ns", "source.ovpay", "source.ovchipkaart", "source.9292"],
                [
                    point("Keep payment and journey evidence when resolving missed check-out or fine issues.", "Bewaar betaal- en reisgegevens bij vergeten uitchecken of boetes.", "Сохраняйте данные оплаты и поездки при пропущенном check-out или штрафах."),
                    point("Night trains and night buses run only on some routes and times; verify before relying on them.", "Nachttreinen en nachtbussen rijden alleen op bepaalde routes en tijden; controleer dit vooraf.", "Ночные поезда и автобусы ходят только на некоторых маршрутах и в определённое время; проверяйте заранее.")
                ]
            )
        ],
        quickCards: [
            quick("ns", "NS trains", "NS-treinen", "Поезда NS", "Routes, tickets, delays", "Routes, tickets, vertragingen", "Маршруты, билеты, задержки", "train.side.front.car", "source.ns", "transport.trains"),
            quick("ovpay", "OVpay", "OVpay", "OVpay", "Bank card and mobile check-in", "Inchecken met bankpas of mobiel", "Оплата картой или телефоном", "wave.3.right.circle.fill", "source.ovpay", "transport.ovpay"),
            quick("planner", "9292 planner", "9292 planner", "9292", "Door-to-door journey planner", "Deur-tot-deur reisplanner", "Планировщик от двери до двери", "point.topleft.down.curvedto.point.bottomright.up", "source.9292", "transport.journeyPlanning"),
            quick("operators", "Local operators", "Lokale vervoerders", "Операторы", "GVB, RET, HTM, U-OV", "GVB, RET, HTM, U-OV", "GVB, RET, HTM, U-OV", "tram.fill", "source.9292", "transport.busTramMetro"),
            quick("bikes", "Bikes", "Fiets", "Велосипеды", "Parking and bike-on-train rules", "Parkeren en fiets-in-treinregels", "Парковка и велосипед в поезде", "bicycle", "source.government.bicycles", "transport.bikes")
        ],
        sources: [
            source("source.ns", "NS", "NS", "https://www.ns.nl/en", "official operator", "EN/NL"),
            source("source.9292", "9292 — Public transport planner", "9292", "https://9292.nl/en", "official journey planner", "EN/NL"),
            source("source.ovpay", "OVpay", "OVpay", "https://www.ovpay.nl/en", "official payment source", "EN/NL"),
            source("source.ovchipkaart", "OV-chipkaart", "Translink", "https://www.ov-chipkaart.nl/en", "official payment source", "EN/NL"),
            source("source.gvb", "GVB Amsterdam", "GVB", "https://www.gvb.nl", "official operator", "NL/EN"),
            source("source.ret", "RET Rotterdam", "RET", "https://www.ret.nl", "official operator", "NL/EN"),
            source("source.htm", "HTM The Hague", "HTM", "https://www.htm.nl", "official operator", "NL/EN"),
            source("source.uov", "U-OV Utrecht", "U-OV", "https://www.u-ov.info", "official operator", "NL"),
            source("source.arriva", "Arriva", "Arriva", "https://www.arriva.nl", "official operator", "NL"),
            source("source.qbuzz", "Qbuzz", "Qbuzz", "https://www.qbuzz.nl", "official operator", "NL"),
            source("source.government.bicycles", "Bicycles", "Government.nl", "https://www.government.nl/themes/transport/bicycles", "official government", "EN"),
            source("source.schiphol", "Schiphol airport information", "Schiphol", "https://www.schiphol.nl/en", "official airport", "EN/NL")
        ],
        updatedAt: "2026-06-01",
        verified: true,
        searchAliases: [
            "transport", "транспорт", "vervoer", "ns", "поезд", "поезда", "trein", "train",
            "ov-chipkaart", "ov chipkaart", "ovpay", "9292", "bus", "автобус",
            "tram", "трамвай", "metro", "метро", "bike", "bicycle", "велосипед",
            "ferry", "паром", "airport", "schiphol", "аэропорт"
        ]
    )

    static func source(id: String) -> TransportGuideSource? {
        guide.sources.first { $0.id == id }
    }

    private static func section(
        _ id: String,
        _ enTitle: String,
        _ nlTitle: String,
        _ ruTitle: String,
        _ enSummary: String,
        _ nlSummary: String,
        _ ruSummary: String,
        _ symbol: String,
        _ sourceIds: [String],
        _ points: [LocalizedInfoText]
    ) -> TransportGuideSection {
        TransportGuideSection(
            id: id,
            title: text(enTitle, nlTitle, ruTitle),
            summary: text(enSummary, nlSummary, ruSummary),
            points: points,
            costNotes: costNotes(for: id),
            practicalTips: practicalTips(for: id),
            hints: hints(for: id),
            sourceIds: sourceIds,
            symbol: symbol
        )
    }

    private static func costNotes(for sectionId: String) -> [LocalizedInfoText] {
        switch sectionId {
        case "transport.overview":
            return [
                point("Transport cost depends on distance, operator, payment method, discount product, time, and route. Check current fares before important trips.", "Reiskosten hangen af van afstand, vervoerder, betaalmethode, kortingsproduct, tijd en route. Controleer actuele tarieven voor belangrijke reizen.", "Стоимость зависит от расстояния, оператора, способа оплаты, скидочного продукта, времени и маршрута. Перед важной поездкой проверяйте актуальную цену."),
                point("Use official apps or websites to compare a single ticket, OVpay, OV-chipkaart, subscription, or discount option.", "Gebruik officiële apps of websites om een los ticket, OVpay, OV-chipkaart, abonnement of kortingsoptie te vergelijken.", "Сравнивайте разовый билет, OVpay, OV-chipkaart, абонемент или скидку только в официальных приложениях и на сайтах.")
            ]
        case "transport.trains":
            return [
                point("NS train fares and supplements can change by route and product. The NS app or website is the safest place to check the current amount.", "NS-tarieven en toeslagen kunnen per route en product verschillen. De NS-app of website is de veiligste plek om het actuele bedrag te controleren.", "Стоимость поездов NS и доплаты зависят от маршрута и продукта. Актуальную сумму безопаснее проверять в приложении или на сайте NS."),
                point("Discount subscriptions may help frequent travellers, but they are only useful if the rules match your travel pattern.", "Kortingsabonnementen kunnen handig zijn voor regelmatige reizigers, maar alleen als de voorwaarden bij je reispatroon passen.", "Скидочные абонементы полезны при регулярных поездках, но только если их условия подходят вашему графику.")
            ]
        case "transport.busTramMetro":
            return [
                point("Local bus, tram, and metro prices are set by the operator or region. Check the operator before travelling between cities or regions.", "Prijzen voor bus, tram en metro worden door vervoerder of regio bepaald. Controleer de vervoerder bij reizen tussen steden of regio's.", "Цены на автобус, трамвай и метро устанавливает оператор или регион. При поездках между городами и регионами проверяйте сайт оператора."),
                point("A city day ticket can be convenient for many local trips, but it may not cover trains or another operator.", "Een dagkaart in de stad kan handig zijn voor veel lokale ritten, maar geldt mogelijk niet voor trein of een andere vervoerder.", "Дневной билет по городу может быть удобен для нескольких поездок, но не всегда действует на поезд или другого оператора.")
            ]
        case "transport.ovChipkaart":
            return [
                point("You may need enough balance or a valid product before check-in. Requirements can differ for train and local transport.", "Je hebt mogelijk voldoende saldo of een geldig product nodig voor het inchecken. Eisen kunnen verschillen tussen trein en lokaal vervoer.", "Для check-in может требоваться достаточный баланс или активный продукт. Требования могут отличаться для поездов и городского транспорта."),
                point("If you forget to check out, the charged amount and refund route depend on the operator and card rules.", "Bij vergeten uitchecken hangen het bedrag en de terugbetalingsroute af van vervoerder en kaartregels.", "Если забыть check-out, списание и возврат зависят от оператора и правил карты.")
            ]
        case "transport.ovpay":
            return [
                point("OVpay usually charges after travel through your bank card or device. Check the payment overview if the amount looks wrong.", "OVpay rekent meestal na de reis af via je bankpas of apparaat. Controleer het betaaloverzicht als het bedrag niet klopt.", "OVpay обычно списывает оплату после поездки с карты или устройства. Если сумма кажется неверной, проверьте историю оплат."),
                point("Using a different card for check-out can create a missing check-out issue and extra cost.", "Uitchecken met een andere kaart kan zorgen voor een vergeten uitcheck en extra kosten.", "Если сделать check-out другой картой, может возникнуть ошибка пропущенного check-out и лишнее списание.")
            ]
        case "transport.journeyPlanning":
            return [
                point("A planner can show estimated cost, but final payment depends on the operator, route changes, and the payment product used.", "Een planner kan een geschatte prijs tonen, maar de uiteindelijke betaling hangt af van vervoerder, routewijzigingen en het betaalproduct.", "Планировщик может показать примерную цену, но итоговая оплата зависит от оператора, изменений маршрута и способа оплаты."),
                point("For airport, night, or multi-operator trips, check cost and validity rules before departure.", "Controleer prijs en geldigheid vooraf bij luchthavenreizen, nachtreizen of reizen met meerdere vervoerders.", "Для аэропорта, ночных маршрутов и поездок с несколькими операторами заранее проверяйте цену и правила действия билета.")
            ]
        case "transport.bikes":
            return [
                point("Bike parking can be free, paid, time-limited, or removed after local limits. Check signs at stations and city centres.", "Fietsparkeren kan gratis, betaald of tijdgebonden zijn; fietsen kunnen na lokale termijnen worden verwijderd. Controleer borden bij stations en centra.", "Парковка велосипеда может быть бесплатной, платной или ограниченной по времени; велосипед могут убрать после местного срока. Проверяйте таблички у станций и в центре."),
                point("Taking a bike on the train can require a separate product and may be restricted at busy times.", "Een fiets meenemen in de trein kan een apart product vereisen en kan beperkt zijn op drukke tijden.", "Перевозка велосипеда в поезде может требовать отдельный продукт и быть ограничена в часы пик.")
            ]
        case "transport.airports":
            return [
                point("Airport travel cost depends on train, bus, taxi, parking, luggage, and route. Public transport is often predictable, but always check live disruption updates.", "Kosten naar de luchthaven hangen af van trein, bus, taxi, parkeren, bagage en route. Ov is vaak voorspelbaar, maar controleer altijd actuele storingen.", "Стоимость поездки в аэропорт зависит от поезда, автобуса, такси, парковки, багажа и маршрута. Общественный транспорт часто предсказуем, но всегда проверяйте сбои."),
                point("If you use a taxi or parking, check official airport information and avoid unclear offers.", "Gebruik je taxi of parkeren, controleer dan officiële luchthaveninformatie en vermijd onduidelijke aanbiedingen.", "Если едете на такси или парковку, проверяйте официальный сайт аэропорта и избегайте неясных предложений.")
            ]
        case "transport.accessibility":
            return [
                point("Assistance, accessible taxis, and alternative routes can have separate booking or cost rules. Verify before travel.", "Assistentie, toegankelijke taxi's en alternatieve routes kunnen aparte reserverings- of kostenregels hebben. Controleer dit vooraf.", "Помощь, доступные такси и альтернативные маршруты могут иметь отдельные правила бронирования или оплаты. Проверяйте заранее."),
                point("A cheaper route is not always usable if lifts, ramps, or transfer time do not fit your needs.", "Een goedkopere route is niet altijd bruikbaar als liften, hellingen of overstaptijd niet passen bij je behoeften.", "Более дешёвый маршрут не всегда подходит, если лифты, пандусы или время пересадки не соответствуют вашим потребностям.")
            ]
        case "transport.safetyAndRules":
            return [
                point("Fines, missed check-out fees, and replacement tickets can make a trip much more expensive than checking rules first.", "Boetes, vergeten-uitcheckkosten en vervangende tickets kunnen een reis veel duurder maken dan vooraf regels controleren.", "Штрафы, списания за пропущенный check-out и новые билеты могут сделать поездку намного дороже, чем предварительная проверка правил."),
                point("Keep receipts, app screenshots, and payment records until payment or refund issues are resolved.", "Bewaar bonnetjes, app-screenshots en betaalgegevens totdat betaal- of terugbetalingsproblemen zijn opgelost.", "Сохраняйте чеки, скриншоты приложения и данные оплаты, пока вопрос списания или возврата не решён.")
            ]
        default:
            return []
        }
    }

    private static func practicalTips(for sectionId: String) -> [LocalizedInfoText] {
        switch sectionId {
        case "transport.overview":
            return [
                point("Plan door to door, not only station to station: include walking, cycling, transfers, and last transport home.", "Plan van deur tot deur, niet alleen van station naar station: neem lopen, fietsen, overstappen en de laatste rit naar huis mee.", "Планируйте путь от двери до двери: учитывайте пеший путь, велосипед, пересадки и последний транспорт домой."),
                point("For appointments, add extra time for platform changes, delays, and finding the right stop.", "Plan extra tijd voor afspraken: perronwijzigingen, vertragingen en het vinden van de juiste halte kosten tijd.", "Для встреч закладывайте запас времени на смену платформы, задержки и поиск нужной остановки.")
            ]
        case "transport.trains":
            return [
                point("Check the direction and final destination on platform screens before boarding.", "Controleer richting en eindbestemming op de perronschermen voordat je instapt.", "Перед посадкой проверьте направление и конечную станцию на экране платформы."),
                point("If a train is cancelled, look for the next route in NS or 9292 instead of waiting without checking alternatives.", "Als een trein uitvalt, zoek een volgende route in NS of 9292 in plaats van zonder alternatief te wachten.", "Если поезд отменён, сразу ищите новый маршрут в NS или 9292, а не ждите без проверки альтернатив.")
            ]
        case "transport.busTramMetro":
            return [
                point("Stand where the stop screen or signs show your line; large stops can have several platforms.", "Ga staan waar het scherm of bord jouw lijn toont; grote haltes kunnen meerdere perrons hebben.", "На больших остановках несколько платформ: стойте там, где экран или табличка показывает ваш номер."),
                point("Press the stop button in bus or tram before your stop when required.", "Druk op de stopknop in bus of tram voordat je halte komt als dat nodig is.", "В автобусе или трамвае нажмите кнопку остановки заранее, если это требуется.")
            ]
        case "transport.ovChipkaart":
            return [
                point("Hold the card still until the reader confirms check-in or check-out.", "Houd de kaart stil totdat de lezer in- of uitchecken bevestigt.", "Держите карту у считывателя, пока он не подтвердит check-in или check-out."),
                point("Check your balance before a long or important trip.", "Controleer je saldo voor een lange of belangrijke reis.", "Проверяйте баланс перед длинной или важной поездкой.")
            ]
        case "transport.ovpay":
            return [
                point("Use the same physical card, phone wallet, or watch for the whole journey.", "Gebruik dezelfde fysieke kaart, telefoonwallet of smartwatch voor de hele reis.", "Используйте одну и ту же физическую карту, телефон или часы для всей поездки."),
                point("If you travel with another person, each traveller needs a separate card or payment device.", "Reis je samen, dan heeft elke reiziger een eigen kaart of betaalapparaat nodig.", "Если едете не один, каждому пассажиру нужна отдельная карта или устройство оплаты.")
            ]
        case "transport.journeyPlanning":
            return [
                point("Check the return trip before you leave, especially in the evening or outside large cities.", "Controleer de terugreis voordat je vertrekt, vooral 's avonds of buiten grote steden.", "Проверьте обратный путь до выезда, особенно вечером или вне крупных городов."),
                point("Save screenshots only as backup; live screens are more reliable when platforms or delays change.", "Bewaar screenshots alleen als back-up; live schermen zijn betrouwbaarder bij perronwijzigingen of vertraging.", "Скриншоты полезны как запасной вариант, но при смене платформы или задержке надёжнее live-информация.")
            ]
        case "transport.bikes":
            return [
                point("Use lights in the dark and lock the frame and wheel if possible.", "Gebruik verlichting in het donker en zet indien mogelijk frame en wiel op slot.", "В темноте используйте фары и по возможности фиксируйте замком раму и колесо."),
                point("Do not park on tactile paving, emergency routes, or clearly marked no-parking zones.", "Parkeer niet op geleidelijnen, noodroutes of duidelijk gemarkeerde verboden zones.", "Не паркуйте велосипед на тактильных дорожках, аварийных проходах и в зонах запрета.")
            ]
        case "transport.airports":
            return [
                point("Check both your flight time and the train or bus route shortly before leaving.", "Controleer vlak voor vertrek zowel je vluchttijd als je trein- of busroute.", "Незадолго до выезда проверьте и рейс, и маршрут поезда или автобуса."),
                point("For early flights, verify whether public transport starts early enough.", "Controleer bij vroege vluchten of het ov vroeg genoeg rijdt.", "Для раннего рейса проверьте, ходит ли общественный транспорт достаточно рано.")
            ]
        case "transport.accessibility":
            return [
                point("Check lift status and transfer time, not only the route duration.", "Controleer liftstatus en overstaptijd, niet alleen de reistijd.", "Проверяйте не только длительность маршрута, но и лифты, а также время пересадки."),
                point("For assisted travel, follow the operator's booking deadline and confirmation process.", "Volg bij reisassistentie de reserveringstermijn en bevestiging van de vervoerder.", "Для поездки с помощью соблюдайте срок бронирования и подтверждение оператора.")
            ]
        case "transport.safetyAndRules":
            return [
                point("Do not enter tracks, closed platforms, or bicycle tunnels marked as restricted.", "Betreed geen sporen, gesloten perrons of fietstunnels met toegangsverbod.", "Не выходите на пути, закрытые платформы и в велосипедные туннели с запретом доступа."),
                point("If something feels unsafe, move to a staffed area, use emergency points, or call 112 in acute danger.", "Voelt iets onveilig, ga naar een bemande plek, gebruik noodpunten of bel 112 bij acuut gevaar.", "Если ситуация небезопасна, перейдите к сотрудникам, используйте экстренные точки связи или звоните 112 при срочной опасности.")
            ]
        default:
            return []
        }
    }

    private static func hints(for sectionId: String) -> [LocalizedInfoText] {
        switch sectionId {
        case "transport.overview":
            return [
                point("Hint: learn the Dutch words halte, perron, overstappen, vertraging, and uitchecken.", "Tip: leer de woorden halte, perron, overstappen, vertraging en uitchecken.", "Подсказка: выучите слова halte, perron, overstappen, vertraging и uitchecken."),
                point("Hint: if you are new, start with 9292 for the whole trip and NS for train details.", "Tip: begin als nieuwkomer met 9292 voor de hele reis en NS voor treindetails.", "Подсказка: если вы новичок, начинайте с 9292 для всего маршрута и NS для деталей поездов.")
            ]
        case "transport.trains":
            return [
                point("Hint: spoor means track/platform number for trains.", "Tip: spoor betekent het perronnummer voor treinen.", "Подсказка: spoor означает номер пути или платформы для поездов."),
                point("Hint: overstappen means transfer; check how many minutes you have.", "Tip: overstappen betekent transfer; controleer hoeveel minuten je hebt.", "Подсказка: overstappen означает пересадку; проверяйте, сколько минут на неё есть.")
            ]
        case "transport.busTramMetro":
            return [
                point("Hint: halte means stop; lijn means line number.", "Tip: halte betekent stopplaats; lijn betekent lijnnummer.", "Подсказка: halte — остановка, lijn — номер линии."),
                point("Hint: uitstappen means get off; instappen means get on.", "Tip: uitstappen betekent uitgaan; instappen betekent ingaan.", "Подсказка: uitstappen — выйти, instappen — войти.")
            ]
        case "transport.ovChipkaart":
            return [
                point("Hint: inchecken and uitchecken are two separate actions.", "Tip: inchecken en uitchecken zijn twee aparte handelingen.", "Подсказка: inchecken и uitchecken — два отдельных действия."),
                point("Hint: saldo means balance.", "Tip: saldo betekent tegoed op je kaart.", "Подсказка: saldo означает баланс.")
            ]
        case "transport.ovpay":
            return [
                point("Hint: a phone wallet and the physical card can count as different payment devices.", "Tip: een telefoonwallet en fysieke kaart kunnen als verschillende betaalmiddelen tellen.", "Подсказка: карта в телефоне и физическая карта могут считаться разными способами оплаты."),
                point("Hint: check your payment overview if a trip appears twice or is missing.", "Tip: controleer je betaaloverzicht als een reis dubbel staat of ontbreekt.", "Подсказка: проверьте историю оплат, если поездка отображается дважды или отсутствует.")
            ]
        case "transport.journeyPlanning":
            return [
                point("Hint: vertrek means departure and aankomst means arrival.", "Tip: vertrek betekent vertrek en aankomst betekent aankomsttijd.", "Подсказка: vertrek — отправление, aankomst — прибытие."),
                point("Hint: platform changes can happen shortly before departure.", "Tip: perronwijzigingen kunnen kort voor vertrek gebeuren.", "Подсказка: платформа может измениться незадолго до отправления.")
            ]
        case "transport.bikes":
            return [
                point("Hint: fietsenstalling means bicycle parking.", "Tip: fietsenstalling betekent fietsparkeerplaats.", "Подсказка: fietsenstalling — велопарковка."),
                point("Hint: watch for fietspad signs; pedestrians should not stand in cycle lanes.", "Tip: let op fietspadborden; voetgangers horen niet op het fietspad te staan.", "Подсказка: следите за знаками fietspad; пешеходам не стоит стоять на велодорожке.")
            ]
        case "transport.airports":
            return [
                point("Hint: vertrekhal means departure hall and aankomsthal means arrivals hall.", "Tip: vertrekhal betekent vertrekhal en aankomsthal betekent aankomsthal.", "Подсказка: vertrekhal — зал вылета, aankomsthal — зал прилёта."),
                point("Hint: keep enough transfer time when changing from train to airport terminal.", "Tip: houd genoeg overstaptijd aan tussen trein en terminal.", "Подсказка: оставляйте достаточно времени между поездом и терминалом.")
            ]
        case "transport.accessibility":
            return [
                point("Hint: lift means elevator; assistentie means assistance.", "Tip: lift betekent lift; assistentie betekent hulp.", "Подсказка: lift — лифт, assistentie — помощь."),
                point("Hint: step-free access can differ by direction and platform.", "Tip: drempelvrije toegang kan verschillen per richting en perron.", "Подсказка: безбарьерный доступ может отличаться по направлению и платформе.")
            ]
        case "transport.safetyAndRules":
            return [
                point("Hint: boete means fine.", "Tip: boete betekent geldstraf.", "Подсказка: boete означает штраф."),
                point("Hint: nooduitgang means emergency exit.", "Tip: nooduitgang betekent emergency exit.", "Подсказка: nooduitgang — аварийный выход.")
            ]
        default:
            return []
        }
    }

    private static func quick(
        _ id: String,
        _ enTitle: String,
        _ nlTitle: String,
        _ ruTitle: String,
        _ enSubtitle: String,
        _ nlSubtitle: String,
        _ ruSubtitle: String,
        _ symbol: String,
        _ sourceId: String?,
        _ sectionId: String?
    ) -> TransportQuickCard {
        TransportQuickCard(
            id: id,
            title: text(enTitle, nlTitle, ruTitle),
            subtitle: text(enSubtitle, nlSubtitle, ruSubtitle),
            symbol: symbol,
            sourceId: sourceId,
            sectionId: sectionId
        )
    }

    private static func point(_ en: String, _ nl: String, _ ru: String) -> LocalizedInfoText {
        text(en, nl, ru)
    }

    private static func text(_ en: String, _ nl: String, _ ru: String) -> LocalizedInfoText {
        LocalizedInfoText(english: en, dutch: nl, russian: ru)
    }

    private static func source(_ id: String, _ title: String, _ institution: String, _ url: String, _ sourceType: String, _ language: String) -> TransportGuideSource {
        TransportGuideSource(
            id: id,
            title: title,
            institution: institution,
            url: AppURL.make(url),
            sourceType: sourceType,
            language: language,
            retrievedAt: "2026-06-01",
            verified: true
        )
    }
}
