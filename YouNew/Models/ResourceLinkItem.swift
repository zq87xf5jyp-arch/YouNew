import Foundation

struct ResourceLinkItem: Identifiable {
    let id: UUID
    let category: String
    let title: String
    let description: String
    let whoItHelps: String
    let sourceLabel: String
    let url: URL
    let isOfficial: Bool
    let reminder: String?
    let personaTags: Set<PersonaTag>

    init(
        id: UUID = UUID(),
        category: String,
        title: String,
        description: String,
        whoItHelps: String,
        sourceLabel: String,
        url: URL,
        isOfficial: Bool,
        reminder: String?,
        personaTags: Set<PersonaTag> = []
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.description = description
        self.whoItHelps = whoItHelps
        self.sourceLabel = sourceLabel
        self.url = url
        self.isOfficial = isOfficial
        self.reminder = reminder
        self.personaTags = PersonaContentPolicy.assignedTags(
            explicitTags: personaTags,
            category: category,
            title: title,
            summary: "\(description) \(whoItHelps) \(sourceLabel)",
            keywords: [category, title, whoItHelps, sourceLabel],
            sources: [OfficialSource(title: sourceLabel, url: url, institution: sourceLabel)]
        )
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}

extension ResourceLinkItem {
    func localizedCategory(_ lang: AppLanguage) -> String {
        switch category {
        case "Emergencies": return localized(en: category, nl: "Noodsituaties", ru: "Экстренные ситуации", lang: lang)
        case "Healthcare": return localized(en: category, nl: "Gezondheidszorg", ru: "Здравоохранение", lang: lang)
        case "Transport": return localized(en: category, nl: "Vervoer", ru: "Транспорт", lang: lang)
        case "Taxes": return localized(en: category, nl: "Financiën en toeslagen", ru: "Финансы и пособия", lang: lang)
        case "Legal help": return localized(en: category, nl: "Juridische zaken", ru: "Юридические вопросы", lang: lang)
        case "Immigration": return localized(en: category, nl: "Immigratie en verblijf", ru: "Иммиграция и проживание", lang: lang)
        case "Work": return localized(en: category, nl: "Werk en uitkering", ru: "Работа и занятость", lang: lang)
        case "Education": return localized(en: category, nl: "Onderwijs", ru: "Образование", lang: lang)
        case "Student life": return localized(en: category, nl: "Studentenleven", ru: "Студенческая жизнь", lang: lang)
        case "Housing": return localized(en: category, nl: "Wonen en huur", ru: "Жильё и аренда", lang: lang)
        case "Identity": return localized(en: category, nl: "Identiteit", ru: "Идентификация", lang: lang)
        case "Mental support": return localized(en: category, nl: "Mentale ondersteuning", ru: "Психологическая поддержка", lang: lang)
        case "Scams": return localized(en: category, nl: "Fraude en veiligheid", ru: "Мошенничество и безопасность", lang: lang)
        default: return category
        }
    }

    func localizedTitle(_ lang: AppLanguage) -> String {
        switch title {
        case "IND: Residence permits and immigration":
            return localized(en: title, nl: "IND: Verblijfsvergunningen en immigratie", ru: "IND: ВНЖ и иммиграция", lang: lang)
        case "UWV: Employment and benefits":
            return localized(en: title, nl: "UWV: Werk en uitkeringen", ru: "UWV: Работа и пособия", lang: lang)
        case "Netherlands Labour Authority: Work rights":
            return localized(en: title, nl: "Nederlandse Arbeidsinspectie: Werkrechten", ru: "Инспекция труда: права на работе", lang: lang)
        case "Business.gov.nl: Starting a business":
            return localized(en: title, nl: "Business.gov.nl: Starten met ondernemen", ru: "Business.gov.nl: начало бизнеса", lang: lang)
        case "Belastingdienst: Tax administration":
            return localized(en: title, nl: "Belastingdienst: Belastingadministratie", ru: "Belastingdienst: Налоги", lang: lang)
        case "Toeslagen: Benefits and allowances":
            return localized(en: title, nl: "Toeslagen: Toeslagen en subsidies", ru: "Toeslagen: Пособия и субсидии", lang: lang)
        case "Mijn Belastingdienst: Tax portal":
            return localized(en: title, nl: "Mijn Belastingdienst: Belastingportaal", ru: "Mijn Belastingdienst: налоговый кабинет", lang: lang)
        case "Toeslagen: Report changes":
            return localized(en: title, nl: "Toeslagen: Wijzigingen doorgeven", ru: "Toeslagen: сообщить об изменениях", lang: lang)
        case "Government.nl: Childcare benefit":
            return localized(en: title, nl: "Government.nl: Kinderopvangtoeslag", ru: "Government.nl: пособие на childcare", lang: lang)
        case "Government.nl: Health insurance explained":
            return localized(en: title, nl: "Government.nl: Zorgverzekering uitgelegd", ru: "Government.nl: Медицинская страховка", lang: lang)
        case "GP (huisarts) and emergency care":
            return localized(en: title, nl: "Huisarts en spoedeisende zorg", ru: "Huisarts и экстренная помощь", lang: lang)
        case "Thuisarts.nl: GP health information":
            return localized(en: title, nl: "Thuisarts.nl: Huisartsinformatie", ru: "Thuisarts.nl: информация от huisarts", lang: lang)
        case "BIG-register: Healthcare professionals":
            return localized(en: title, nl: "BIG-register: Zorgverleners", ru: "BIG-register: медицинские специалисты", lang: lang)
        case "DUO: International student info":
            return localized(en: title, nl: "DUO: Informatie voor internationale studenten", ru: "DUO: Информация для иностранных студентов", lang: lang)
        case "Study in NL: Student guide":
            return localized(en: title, nl: "Study in NL: Studentengids", ru: "Study in NL: Гид для студентов", lang: lang)
        case "Studielink: Higher education enrolment":
            return localized(en: title, nl: "Studielink: Inschrijving hoger onderwijs", ru: "Studielink: поступление в высшее образование", lang: lang)
        case "IDW: International credential evaluation":
            return localized(en: title, nl: "IDW: Internationale diplomawaardering", ru: "IDW: оценка иностранного диплома", lang: lang)
        case "Rijksoverheid: Compulsory education":
            return localized(en: title, nl: "Rijksoverheid: Leerplicht", ru: "Rijksoverheid: обязательное обучение", lang: lang)
        case "Government.nl: Housing and rental rights":
            return localized(en: title, nl: "Government.nl: Wonen en huurrechten", ru: "Government.nl: Жильё и права арендатора", lang: lang)
        case "Huurcommissie: Rental disputes and rent checks":
            return localized(en: title, nl: "Huurcommissie: Huurgeschillen en huurcontrole", ru: "Huurcommissie: споры и проверка аренды", lang: lang)
        case "MijnOverheid: Berichtenbox":
            return localized(en: title, nl: "MijnOverheid: Berichtenbox", ru: "MijnOverheid: Berichtenbox", lang: lang)
        case "Government.nl: BSN use and safety":
            return localized(en: title, nl: "Government.nl: BSN-gebruik en veiligheid", ru: "Government.nl: использование и безопасность BSN", lang: lang)
        case "Autoriteit Persoonsgegevens: Privacy rights":
            return localized(en: title, nl: "Autoriteit Persoonsgegevens: Privacyrechten", ru: "Autoriteit Persoonsgegevens: права на приватность", lang: lang)
        case "RDW: Driving licences and vehicles":
            return localized(en: title, nl: "RDW: Rijbewijzen en voertuigen", ru: "RDW: Водительские права и транспорт", lang: lang)
        case "OVpay: Contactless public transport":
            return localized(en: title, nl: "OVpay: Contactloos reizen", ru: "OVpay: бесконтактная оплата транспорта", lang: lang)
        case "9292: Public transport planner":
            return localized(en: title, nl: "9292: Openbaarvervoerplanner", ru: "9292: планировщик общественного транспорта", lang: lang)
        case "Juridisch Loket: First-line legal help":
            return localized(en: title, nl: "Juridisch Loket: Eerstelijns juridische hulp", ru: "Juridisch Loket: Юридическая помощь", lang: lang)
        case "Fraudehelpdesk: Scam reporting":
            return localized(en: title, nl: "Fraudehelpdesk: Meldpunt fraude", ru: "Fraudehelpdesk: Мошенничество", lang: lang)
        case "Emergency number 112":
            return localized(en: title, nl: "Noodnummer 112", ru: "Экстренный номер 112", lang: lang)
        case "Politie.nl: Non-urgent reporting":
            return localized(en: title, nl: "Politie.nl: Niet-spoed melden", ru: "Politie.nl: несрочное обращение", lang: lang)
        case "Government.nl: Coming to the Netherlands":
            return localized(en: title, nl: "Government.nl: Naar Nederland komen", ru: "Government.nl: Приезд в Нидерланды", lang: lang)
        case "ACM ConsuWijzer: Consumer rights":
            return localized(en: title, nl: "ACM ConsuWijzer: Consumentenrechten", ru: "ACM ConsuWijzer: Права потребителя", lang: lang)
        case "113: Suicide prevention":
            return localized(en: title, nl: "113: Zelfmoordpreventie", ru: "113: профилактика суицида", lang: lang)
        case "Slachtofferhulp Nederland: Victim support":
            return localized(en: title, nl: "Slachtofferhulp Nederland: Slachtofferhulp", ru: "Slachtofferhulp Nederland: помощь пострадавшим", lang: lang)
        case "Discriminatie.nl: Report discrimination":
            return localized(en: title, nl: "Discriminatie.nl: Discriminatie melden", ru: "Discriminatie.nl: сообщить о дискриминации", lang: lang)
        default: return title
        }
    }

    func localizedDescription(_ lang: AppLanguage) -> String {
        switch title {
        case "IND: Residence permits and immigration":
            return localized(en: description, nl: "Officiële regels over verblijfsvergunningtypen, verlengingen, visa, asiel en naturalisatie.", ru: "Официальные правила по видам ВНЖ, продлению, визам, убежищу и натурализации.", lang: lang)
        case "UWV: Employment and benefits":
            return localized(en: description, nl: "Officiële informatie over werknemersverzekeringen, WW-uitkering, ziekteverlof en arbeidscapaciteit.", ru: "Официальная информация о страховании занятости, пособиях по безработице, больничном и трудоспособности.", lang: lang)
        case "Netherlands Labour Authority: Work rights":
            return localized(en: description, nl: "Officiele route voor informatie over veilig werk, eerlijk werk, onderbetaling en arbeidsuitbuiting.", ru: "Официальный ориентир по безопасности труда, честным условиям, недоплате и трудовой эксплуатации.", lang: lang)
        case "Business.gov.nl: Starting a business":
            return localized(en: description, nl: "Engelstalige officiele informatie voor ondernemers over inschrijving, rechtsvormen, vergunningen, belasting en administratie.", ru: "Официальная информация на английском для предпринимателей: регистрация, формы бизнеса, разрешения, налоги и администрация.", lang: lang)
        case "Belastingdienst: Tax administration":
            return localized(en: description, nl: "Hoe belastingbrieven te lezen, deadlines te controleren, aangifte te doen en uw belastingsituatie te begrijpen.", ru: "Как читать налоговые письма, проверять сроки, подавать декларацию и понимать свою налоговую ситуацию.", lang: lang)
        case "Toeslagen: Benefits and allowances":
            return localized(en: description, nl: "Officieel portaal voor aanvragen en beheer van zorgtoeslag, huurtoeslag, kinderopvangtoeslag en kinderbijslag.", ru: "Официальный портал для подачи заявок на zorgtoeslag, huurtoeslag, kinderopvangtoeslag и kinderbijslag.", lang: lang)
        case "Mijn Belastingdienst: Tax portal":
            return localized(en: description, nl: "Officieel online portaal voor aangifte inkomstenbelasting, belastingberichten, aanslagen en persoonlijke belastinggegevens.", ru: "Официальный онлайн-кабинет для декларации, налоговых сообщений, начислений и личных налоговых данных.", lang: lang)
        case "Toeslagen: Report changes":
            return localized(en: description, nl: "Officiele route om wijzigingen in inkomen, huishouden, kinderopvang, huur en zorgverzekering voor toeslagen door te geven.", ru: "Официальный путь для изменений дохода, семьи, childcare, аренды и медстраховки по пособиям.", lang: lang)
        case "Government.nl: Childcare benefit":
            return localized(en: description, nl: "Officieel overzicht van kinderopvangtoeslag en wat ouders moeten controleren voor aanvraag of wijzigingen.", ru: "Официальный обзор пособия на childcare и того, что родителям нужно проверить перед заявкой или изменениями.", lang: lang)
        case "Government.nl: Health insurance explained":
            return localized(en: description, nl: "Overzicht van verplichte basisverzekering: wie moet, termijnen en eigen risico.", ru: "Обзор обязательного базового медицинского страхования: кто обязан, сроки и eigen risico.", lang: lang)
        case "GP (huisarts) and emergency care":
            return localized(en: description, nl: "Praktische uitleg: wanneer huisarts, wanneer ziekenhuis, wanneer 112 bellen.", ru: "Практическое объяснение: когда обращаться к huisarts, когда — в больницу, когда звонить 112.", lang: lang)
        case "Thuisarts.nl: GP health information":
            return localized(en: description, nl: "Begrijpelijke Nederlandse gezondheidsinformatie over klachten, zelfzorg en wanneer u de huisarts belt.", ru: "Понятная медицинская информация на нидерландском о симптомах, самопомощи и обращении к huisarts.", lang: lang)
        case "BIG-register: Healthcare professionals":
            return localized(en: description, nl: "Officieel register om te controleren of gereguleerde zorgverleners in Nederland geregistreerd zijn.", ru: "Официальный реестр для проверки регистрации регулируемых медицинских специалистов в Нидерландах.", lang: lang)
        case "DUO: International student info":
            return localized(en: description, nl: "DUO-informatie over onderwijsadministratie voor internationale studenten.", ru: "Информация DUO об администрировании обучения для иностранных студентов.", lang: lang)
        case "Study in NL: Student guide":
            return localized(en: description, nl: "Oriëntatie op studeren in Nederland: aanmelding, campusleven en eerste stappen.", ru: "Ориентация по учёбе в Нидерландах: поступление, кампусная жизнь и первые шаги.", lang: lang)
        case "Studielink: Higher education enrolment":
            return localized(en: description, nl: "Officiele route voor aanmelding en inschrijving voor veel opleidingen in het hoger onderwijs.", ru: "Официальный путь подачи заявки и зачисления на многие программы высшего образования.", lang: lang)
        case "IDW: International credential evaluation":
            return localized(en: description, nl: "Informatie over waardering van buitenlandse diploma's voor werk, studie of officieel gebruik in Nederland.", ru: "Информация об оценке иностранных дипломов для работы, учебы или официального использования в Нидерландах.", lang: lang)
        case "Rijksoverheid: Compulsory education":
            return localized(en: description, nl: "Officiele Nederlandse informatie over schoolbezoek, leerplicht en kwalificatieplicht voor kinderen.", ru: "Официальная информация о посещении школы, leerplicht и квалификационной обязанности детей.", lang: lang)
        case "Government.nl: Housing and rental rights":
            return localized(en: description, nl: "Officiële informatie over huurrechten, adresinschrijving en woonregels.", ru: "Официальное руководство по правам арендаторов, регистрации адреса и жилищным правилам.", lang: lang)
        case "Huurcommissie: Rental disputes and rent checks":
            return localized(en: description, nl: "Onafhankelijke informatie over huurprijs, servicekosten en geschillen tussen huurders en verhuurders.", ru: "Независимая информация об аренде, servicekosten и спорах между арендатором и арендодателем.", lang: lang)
        case "MijnOverheid: Berichtenbox":
            return localized(en: description, nl: "Officiele digitale brievenbus voor berichten van Nederlandse overheidsorganisaties.", ru: "Официальный цифровой ящик для сообщений от государственных организаций Нидерландов.", lang: lang)
        case "Government.nl: BSN use and safety":
            return localized(en: description, nl: "Officiele informatie over het burgerservicenummer, waar het wordt gebruikt en waarom u er zorgvuldig mee omgaat.", ru: "Официальная информация о BSN: где он используется и почему с ним нужно обращаться осторожно.", lang: lang)
        case "Autoriteit Persoonsgegevens: Privacy rights":
            return localized(en: description, nl: "Informatie van de Nederlandse privacytoezichthouder over privacyrechten, persoonsgegevens, klachten en datalekken.", ru: "Информация нидерландского органа по защите данных о правах на приватность, персональных данных, жалобах и утечках.", lang: lang)
        case "RDW: Driving licences and vehicles":
            return localized(en: description, nl: "Officiële regels over rijbewijzen, kentekenregistratie, APK en omwisseling van buitenlandse rijbewijzen.", ru: "Официальные правила по водительским правам, регистрации авто, APK и обмену иностранных прав.", lang: lang)
        case "OVpay: Contactless public transport":
            return localized(en: description, nl: "Officiele informatie over in- en uitchecken met betaalpas, creditcard of mobiele wallet in het OV.", ru: "Официальная информация о check-in/out банковской картой, кредитной картой или мобильным кошельком в транспорте.", lang: lang)
        case "9292: Public transport planner":
            return localized(en: description, nl: "Landelijke OV-planner voor bus, tram, metro, trein, veerboot, storingen en overstappen.", ru: "Национальный планировщик маршрутов: автобус, трамвай, метро, поезд, паром, сбои и пересадки.", lang: lang)
        case "Juridisch Loket: First-line legal help":
            return localized(en: description, nl: "Juridische oriëntatie in begrijpelijke taal: wonen, werk, consumentenrechten, officiële brieven.", ru: "Юридическая ориентация простым языком: жильё, работа, права потребителя, официальные письма.", lang: lang)
        case "Fraudehelpdesk: Scam reporting":
            return localized(en: description, nl: "Controleer verdachte berichten, meld fraude en bescherm uzelf tegen phishing en nep-boetes.", ru: "Проверка подозрительных сообщений, сообщение о мошенничестве, защита от фишинга и фейковых штрафов.", lang: lang)
        case "Emergency number 112":
            return localized(en: description, nl: "Noodhulp bij direct levensgevaar: politie, brandweer en ambulance.", ru: "Экстренный номер при непосредственной угрозе жизни: полиция, пожарные, скорая помощь.", lang: lang)
        case "Politie.nl: Non-urgent reporting":
            return localized(en: description, nl: "Officiele politieroute voor niet-spoedmeldingen, veiligheidsvragen en contactinformatie.", ru: "Официальный канал полиции для несрочных заявлений, вопросов безопасности и контактов.", lang: lang)
        case "Government.nl: Coming to the Netherlands":
            return localized(en: description, nl: "Overzicht van inschrijving, BSN, verblijf en eerste stappen voor nieuwkomers in Nederland.", ru: "Обзор регистрации, BSN, проживания и первых шагов для новоприбывших в Нидерланды.", lang: lang)
        case "ACM ConsuWijzer: Consumer rights":
            return localized(en: description, nl: "Advies over consumentenrechten, klachten over bedrijven, oneerlijke contracten en online aankopen.", ru: "Советы по правам потребителей, жалобам на компании, несправедливым контрактам и интернет-покупкам.", lang: lang)
        case "113: Suicide prevention":
            return localized(en: description, nl: "Nederlandse crisissteun met chat en telefoon voor mensen met suicidale gedachten of zorgen om iemand anders.", ru: "Кризисная поддержка в Нидерландах через чат и телефон для людей с суицидальными мыслями или тревогой за другого человека.", lang: lang)
        case "Slachtofferhulp Nederland: Victim support":
            return localized(en: description, nl: "Steun na misdrijf, verkeersongeval, calamiteit of vermissing, inclusief emotionele en praktische begeleiding.", ru: "Поддержка после преступления, ДТП, чрезвычайного события или пропажи человека, включая эмоциональную и практическую помощь.", lang: lang)
        case "Discriminatie.nl: Report discrimination":
            return localized(en: description, nl: "Landelijke meldroute voor incidenten rond herkomst, religie, gender, beperking, seksualiteit of andere discriminatiegronden.", ru: "Национальный путь сообщения о дискриминации по происхождению, религии, полу, инвалидности, сексуальности и другим основаниям.", lang: lang)
        default: return description
        }
    }

    func localizedWhoItHelps(_ lang: AppLanguage) -> String {
        switch whoItHelps {
        case "International students":
            return localized(en: whoItHelps, nl: "Internationale studenten", ru: "Иностранные студенты", lang: lang)
        case "Anyone in urgent emergencies":
            return localized(en: whoItHelps, nl: "Iedereen bij acute nood", ru: "Все при экстренной угрозе", lang: lang)
        case "Newcomers dealing with residency and immigration questions":
            return localized(en: whoItHelps, nl: "Nieuwkomers met vragen over verblijf en immigratie", ru: "Новоприбывшим с вопросами о статусе и иммиграции", lang: lang)
        case "Workers and temporary employees dealing with employment rights":
            return localized(en: whoItHelps, nl: "Werknemers en tijdelijke medewerkers", ru: "Работникам и временным сотрудникам", lang: lang)
        case "Workers and newcomers worried about unsafe or unfair work conditions":
            return localized(en: whoItHelps, nl: "Werknemers en nieuwkomers met zorgen over onveilig of oneerlijk werk", ru: "Работникам и новым жителям, которых беспокоят небезопасные или нечестные условия труда", lang: lang)
        case "Entrepreneurs and self-employed newcomers planning business activity":
            return localized(en: whoItHelps, nl: "Ondernemers en zelfstandige nieuwkomers die bedrijfsactiviteiten plannen", ru: "Предпринимателям и самозанятым новым жителям, которые планируют бизнес", lang: lang)
        case "Anyone receiving tax correspondence or needing to file a return":
            return localized(en: whoItHelps, nl: "Ontvangers van belastingpost en aangevers", ru: "Получателям налоговых писем и тем, кто подаёт декларацию", lang: lang)
        case "Families, students, and workers who may qualify for income-based allowances":
            return localized(en: whoItHelps, nl: "Gezinnen, studenten en werkenden met recht op toeslagen", ru: "Семьям, студентам и работающим с правом на пособия", lang: lang)
        case "Residents and workers managing Dutch tax returns or tax letters":
            return localized(en: whoItHelps, nl: "Inwoners en werkenden die aangifte of belastingpost beheren", ru: "Жителям и работникам, которые ведут декларации или налоговые письма", lang: lang)
        case "People receiving allowances who need to avoid overpayments":
            return localized(en: whoItHelps, nl: "Mensen met toeslagen die terugbetalingen willen voorkomen", ru: "Получателям пособий, которым важно избежать переплат", lang: lang)
        case "Parents checking childcare benefit or childcare cost support":
            return localized(en: whoItHelps, nl: "Ouders die kinderopvangtoeslag of opvangkosten controleren", ru: "Родителям, которые проверяют пособие или поддержку расходов на childcare", lang: lang)
        case "Newcomers and workers who need to understand their health insurance obligation":
            return localized(en: whoItHelps, nl: "Nieuwkomers en werkenden die hun verzekeringsplicht willen begrijpen", ru: "Новоприбывшим и работникам, которым нужно разобраться со страховкой", lang: lang)
        case "Everyone navigating the Dutch healthcare system for the first time":
            return localized(en: whoItHelps, nl: "Iedereen die voor het eerst met de Nederlandse zorg te maken heeft", ru: "Всем, кто осваивает нидерландскую систему здравоохранения", lang: lang)
        case "Anyone deciding whether to contact a huisarts or prepare for a GP visit":
            return localized(en: whoItHelps, nl: "Iedereen die wil beslissen of huisartscontact nodig is of zich wil voorbereiden", ru: "Тем, кто решает, обращаться ли к huisarts, или готовится к визиту", lang: lang)
        case "Patients who want to verify a regulated healthcare professional":
            return localized(en: whoItHelps, nl: "Patienten die een gereguleerde zorgverlener willen controleren", ru: "Пациентам, которые хотят проверить регулируемого медицинского специалиста", lang: lang)
        case "New international students arriving in the Netherlands":
            return localized(en: whoItHelps, nl: "Nieuwe internationale studenten", ru: "Новым иностранным студентам", lang: lang)
        case "Students applying to Dutch universities or universities of applied sciences":
            return localized(en: whoItHelps, nl: "Studenten die zich aanmelden bij Nederlandse universiteiten of hogescholen", ru: "Студентам, которые подают заявку в университеты или hogeschool в Нидерландах", lang: lang)
        case "Newcomers who need a Dutch evaluation of foreign education documents":
            return localized(en: whoItHelps, nl: "Nieuwkomers die een Nederlandse waardering van buitenlandse onderwijsdocumenten nodig hebben", ru: "Новоприбывшим, которым нужна нидерландская оценка иностранных учебных документов", lang: lang)
        case "Parents and guardians checking school attendance duties":
            return localized(en: whoItHelps, nl: "Ouders en verzorgers die schoolbezoekplichten controleren", ru: "Родителям и опекунам, которые проверяют обязанности посещения школы", lang: lang)
        case "Renters and newcomers looking for housing guidance":
            return localized(en: whoItHelps, nl: "Huurders en nieuwkomers op zoek naar woonbegeleiding", ru: "Арендаторам и новоприбывшим, ищущим жильё", lang: lang)
        case "Renters who need to verify rent, service costs, or landlord disputes":
            return localized(en: whoItHelps, nl: "Huurders die huurprijs, servicekosten of verhuurdergeschillen willen controleren", ru: "Арендаторам, которым нужно проверить аренду, servicekosten или спор с арендодателем", lang: lang)
        case "Anyone who receives Dutch government mail digitally":
            return localized(en: whoItHelps, nl: "Iedereen die digitale post van de Nederlandse overheid ontvangt", ru: "Тем, кто получает цифровые письма от государства Нидерландов", lang: lang)
        case "Anyone who needs to share a BSN with employers, schools, healthcare providers, banks, or government services":
            return localized(en: whoItHelps, nl: "Iedereen die een BSN moet delen met werkgever, school, zorgverlener, bank of overheid", ru: "Тем, кому нужно передавать BSN работодателю, школе, врачу, банку или госслужбе", lang: lang)
        case "People worried about misuse of personal data or privacy rights":
            return localized(en: whoItHelps, nl: "Mensen met zorgen over misbruik van persoonsgegevens of privacyrechten", ru: "Тем, кого беспокоит неправильное использование персональных данных или права на приватность", lang: lang)
        case "Drivers and vehicle owners in the Netherlands":
            return localized(en: whoItHelps, nl: "Bestuurders en voertuigeigenaren in Nederland", ru: "Водителям и владельцам авто в Нидерландах", lang: lang)
        case "Travellers who want to use contactless payment instead of an OV-chipkaart":
            return localized(en: whoItHelps, nl: "Reizigers die contactloos willen betalen in plaats van met OV-chipkaart", ru: "Пассажирам, которые хотят платить бесконтактно вместо OV-chipkaart", lang: lang)
        case "Travellers planning routes across different Dutch transport operators":
            return localized(en: whoItHelps, nl: "Reizigers die routes met verschillende vervoerders plannen", ru: "Пассажирам, которые планируют маршруты у разных перевозчиков", lang: lang)
        case "Anyone who needs to understand their legal rights or respond to official correspondence":
            return localized(en: whoItHelps, nl: "Iedereen die zijn rechten wil begrijpen of op officiële post wil reageren", ru: "Тем, кто хочет понять свои права или ответить на официальное письмо", lang: lang)
        case "Anyone who has received a suspicious message or believes they are being targeted":
            return localized(en: whoItHelps, nl: "Iedereen die een verdacht bericht heeft ontvangen of slachtoffer denkt te zijn", ru: "Всем, кто получил подозрительное сообщение или стал жертвой мошенников", lang: lang)
        case "Anyone newly arriving and starting life in the Netherlands":
            return localized(en: whoItHelps, nl: "Iedereen die pas in Nederland aankomt", ru: "Всем, кто только приехал в Нидерланды", lang: lang)
        case "Anyone dealing with a consumer complaint or unfair business practice":
            return localized(en: whoItHelps, nl: "Iedereen met een consumentenklacht of oneerlijke handelspraktijk", ru: "Тем, кто столкнулся с жалобой или нечестной практикой бизнеса", lang: lang)
        case "Anyone who needs police help when there is no immediate danger":
            return localized(en: whoItHelps, nl: "Iedereen die politiehulp nodig heeft zonder direct gevaar", ru: "Тем, кому нужна помощь полиции без непосредственной опасности", lang: lang)
        case "Anyone in mental health crisis or worried about suicidal thoughts":
            return localized(en: whoItHelps, nl: "Iedereen in mentale crisis of met zorgen over suicidale gedachten", ru: "Тем, кто в психологическом кризисе или переживает из-за суицидальных мыслей", lang: lang)
        case "People affected by crime, accidents, violence, or serious incidents":
            return localized(en: whoItHelps, nl: "Mensen geraakt door misdrijf, ongeval, geweld of ernstig incident", ru: "Людям, пострадавшим от преступления, аварии, насилия или серьёзного инцидента", lang: lang)
        case "People who experienced or witnessed discrimination":
            return localized(en: whoItHelps, nl: "Mensen die discriminatie hebben ervaren of gezien", ru: "Людям, которые столкнулись с дискриминацией или стали свидетелями", lang: lang)
        default: return whoItHelps
        }
    }

    func localizedReminder(_ lang: AppLanguage) -> String? {
        guard let reminder else { return nil }
        switch title {
        case "IND: Residence permits and immigration":
            return localized(en: reminder, nl: "Controleer altijd actuele vereisten voor indiening. Regels kunnen veranderen.", ru: "Всегда проверяйте актуальные требования перед подачей документов. Правила могут меняться.", lang: lang)
        case "UWV: Employment and benefits":
            return localized(en: reminder, nl: "Vergelijk voorwaarden met uw contracttype.", ru: "Сравняйте условия со своим типом контракта.", lang: lang)
        case "Netherlands Labour Authority: Work rights":
            return localized(en: reminder, nl: "Bewaar contracten, loonstroken, roosters en berichten voordat u hulp vraagt.", ru: "Сохраните договоры, расчетные листы, графики и сообщения перед обращением за помощью.", lang: lang)
        case "Business.gov.nl: Starting a business":
            return localized(en: reminder, nl: "Controleer rechtsvorm, belasting, verzekering en vergunningen voordat u verplichtingen aangaat.", ru: "Проверьте форму бизнеса, налоги, страховки и разрешения до подписания обязательств.", lang: lang)
        case "Belastingdienst: Tax administration":
            return localized(en: reminder, nl: "Noteer direct de reactie- en betalingsdeadlines op belastingbrieven — te laat handelen kan boetes geven.", ru: "Сразу фиксируйте даты ответа и оплаты из налоговых писем — просрочка может повлечь штраф.", lang: lang)
        case "Toeslagen: Benefits and allowances":
            return localized(en: reminder, nl: "Werk inkomen en gezinsgegevens direct bij na wijzigingen — teveel ontvangen toeslag moet worden terugbetaald.", ru: "При изменении дохода или состава семьи сразу обновляйте данные — переплату придётся вернуть.", lang: lang)
        case "Mijn Belastingdienst: Tax portal":
            return localized(en: reminder, nl: "Controleer deadlines en referentienummers in officiele belastingbrieven voordat u indient of betaalt.", ru: "Проверяйте сроки и номера из официальных налоговых писем перед подачей или оплатой.", lang: lang)
        case "Toeslagen: Report changes":
            return localized(en: reminder, nl: "Geef wijzigingen snel door; te veel ontvangen toeslag moet meestal worden terugbetaald.", ru: "Сообщайте изменения быстро; переплату по пособиям обычно нужно вернуть.", lang: lang)
        case "Government.nl: Childcare benefit":
            return localized(en: reminder, nl: "Houd opvangcontracten, uren, inkomenswijzigingen en huishoudgegevens actueel om terugbetalingen te voorkomen.", ru: "Поддерживайте актуальными договоры childcare, часы, изменения дохода и данные семьи, чтобы избежать возвратов.", lang: lang)
        case "Government.nl: Health insurance explained":
            return localized(en: reminder, nl: "De startdatum van de verplichting hangt af van uw situatie. Controleer dit vroeg.", ru: "Дата начала обязанности зависит от вашей ситуации. Проверьте заранее.", lang: lang)
        case "GP (huisarts) and emergency care":
            return localized(en: reminder, nl: "Bel 112 alleen bij levensgevaar. Voor niet-urgente zaken: uw huisarts.", ru: "Звоните 112 только при угрозе жизни. По несрочным вопросам обращайтесь к врачу.", lang: lang)
        case "Thuisarts.nl: GP health information":
            return localized(en: reminder, nl: "Gebruik dit als orientatie; bel huisarts, huisartsenpost of 112 bij urgente klachten.", ru: "Используйте как ориентир; при срочных симптомах звоните huisarts, huisartsenpost или 112.", lang: lang)
        case "BIG-register: Healthcare professionals":
            return localized(en: reminder, nl: "Controleer namen zorgvuldig en gebruik officiele contactroutes als een resultaat onduidelijk is.", ru: "Внимательно проверяйте имя и используйте официальные контакты, если результат неясен.", lang: lang)
        case "DUO: International student info":
            return localized(en: reminder, nl: "Controleer uw DUO-portaal regelmatig en sla alle bevestigingen op.", ru: "Регулярно проверяйте кабинет DUO и сохраняйте все подтверждения.", lang: lang)
        case "Study in NL: Student guide":
            return localized(en: reminder, nl: "Verifieer definitieve vereisten altijd bij DUO en uw instelling.", ru: "Финальные требования всегда сверяйте с DUO и вашим вузом.", lang: lang)
        case "Studielink: Higher education enrolment":
            return localized(en: reminder, nl: "Controleer opleidingsdeadlines en instellingseisen voordat u een inschrijvingsverzoek indient.", ru: "Проверьте сроки программы и требования вуза перед отправкой заявки на зачисление.", lang: lang)
        case "IDW: International credential evaluation":
            return localized(en: reminder, nl: "Houd originele diploma's, cijferlijsten, vertalingen en identiteitsdocumenten bij elkaar voordat u aanvraagt.", ru: "Перед подачей держите вместе оригиналы дипломов, приложения, переводы и документы личности.", lang: lang)
        case "Rijksoverheid: Compulsory education":
            return localized(en: reminder, nl: "Controleer instructies van gemeente en school als een kind niet naar school kan of van school wisselt.", ru: "Проверьте инструкции gemeente и школы, если ребенок не может посещать школу или меняет школу.", lang: lang)
        case "Government.nl: Housing and rental rights":
            return localized(en: reminder, nl: "Lokale gemeenteregels kunnen afwijken van nationale richtlijnen.", ru: "Локальные правила gemeente могут отличаться от общегосударственных.", lang: lang)
        case "Huurcommissie: Rental disputes and rent checks":
            return localized(en: reminder, nl: "Bewaar huurcontract, betalingen, servicekostenoverzichten en berichten voordat u een stap zet.", ru: "Сохраните договор аренды, платежи, отчеты по servicekosten и переписку перед обращением.", lang: lang)
        case "MijnOverheid: Berichtenbox":
            return localized(en: reminder, nl: "Controleer afzender en deadline in officiele portalen; gebruik geen onbekende links uit sms of e-mail.", ru: "Проверяйте отправителя и срок в официальных кабинетах; не используйте неизвестные ссылки из SMS или email.", lang: lang)
        case "Government.nl: BSN use and safety":
            return localized(en: reminder, nl: "Deel uw BSN alleen als de organisatie een geldige reden heeft en u een officieel kanaal gebruikt.", ru: "Передавайте BSN только если у организации есть законная причина и вы используете официальный канал.", lang: lang)
        case "Autoriteit Persoonsgegevens: Privacy rights":
            return localized(en: reminder, nl: "Bewaar verzoeken, reacties, screenshots, data en organisatienamen voordat u hulp vraagt.", ru: "Сохраните запросы, ответы, скриншоты, даты и названия организаций перед обращением за помощью.", lang: lang)
        case "RDW: Driving licences and vehicles":
            return localized(en: reminder, nl: "Controleer of uw land een rijbewijs-uitwisselingsverdrag heeft met Nederland.", ru: "Проверьте, есть ли у вашей страны соглашение об обмене прав с Нидерландами.", lang: lang)
        case "OVpay: Contactless public transport":
            return localized(en: reminder, nl: "Check altijd in en uit met dezelfde kaart of hetzelfde apparaat om correcties te voorkomen.", ru: "Всегда делайте check-in и check-out одной и той же картой или устройством, чтобы избежать корректировок.", lang: lang)
        case "9292: Public transport planner":
            return localized(en: reminder, nl: "Controleer kort voor vertrek: storingen, perrons en overstappen kunnen wijzigen.", ru: "Проверяйте перед выездом: сбои, платформы и пересадки могут измениться.", lang: lang)
        case "Juridisch Loket: First-line legal help":
            return localized(en: reminder, nl: "Juridisch Loket geeft oriëntatie — raadpleeg een advocaat voor complexe gevallen.", ru: "Juridisch Loket даёт ориентацию — для сложных ситуаций обратитесь к юристу.", lang: lang)
        case "Fraudehelpdesk: Scam reporting":
            return localized(en: reminder, nl: "Klik nooit op links in verdachte berichten. Typ URL's altijd handmatig in.", ru: "Никогда не переходите по ссылкам из подозрительных сообщений. Вводите URL вручную.", lang: lang)
        case "Emergency number 112":
            return localized(en: reminder, nl: "Voor niet-urgent politiecontact: 0900-8844. Voor niet-urgente medische vragen: uw huisarts.", ru: "По неэкстренным вопросам полиции звоните 0900-8844. Для медицинских — обращайтесь к врачу.", lang: lang)
        case "Politie.nl: Non-urgent reporting":
            return localized(en: reminder, nl: "Gebruik 112 bij direct gevaar; gebruik officiele politiekanalen voor niet-spoedmeldingen.", ru: "При непосредственной опасности используйте 112; для несрочных обращений используйте официальные каналы полиции.", lang: lang)
        case "Government.nl: Coming to the Netherlands":
            return localized(en: reminder, nl: "Stappen en termijnen kunnen variëren per nationaliteit en verblijfsdoel.", ru: "Шаги и сроки могут различаться в зависимости от гражданства и цели пребывания.", lang: lang)
        case "ACM ConsuWijzer: Consumer rights":
            return localized(en: reminder, nl: "Bij onopgeloste klachten kunt u escaleren naar de relevante sectortoezichthouder.", ru: "При неразрешённых жалобах можно обратиться в отраслевой регулятор.", lang: lang)
        case "113: Suicide prevention":
            return localized(en: reminder, nl: "Bij direct gevaar belt u eerst 112. Gebruik 113 voor suicidepreventie en begeleiding.", ru: "При непосредственной опасности сначала звоните 112. Используйте 113 для поддержки и профилактики суицида.", lang: lang)
        case "Slachtofferhulp Nederland: Victim support":
            return localized(en: reminder, nl: "Bij direct gevaar belt u 112. Bewaar meldingen, brieven, foto's en zaaknummers voor vervolghulp.", ru: "При текущей опасности звоните 112. Для дальнейшей помощи сохраните заявления, письма, фото и номера дела.", lang: lang)
        case "Discriminatie.nl: Report discrimination":
            return localized(en: reminder, nl: "Bewaar data, locaties, berichten, screenshots, getuigen en brieven voordat u meldt.", ru: "Перед обращением сохраните даты, места, сообщения, скриншоты, свидетелей и письма.", lang: lang)
        default: return reminder
        }
    }

    private func localized(en: String, nl: String, ru: String, lang: AppLanguage) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}
