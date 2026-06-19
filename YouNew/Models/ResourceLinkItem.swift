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
        case "Belastingdienst: Tax administration":
            return localized(en: title, nl: "Belastingdienst: Belastingadministratie", ru: "Belastingdienst: Налоги", lang: lang)
        case "Toeslagen: Benefits and allowances":
            return localized(en: title, nl: "Toeslagen: Toeslagen en subsidies", ru: "Toeslagen: Пособия и субсидии", lang: lang)
        case "Government.nl: Health insurance explained":
            return localized(en: title, nl: "Government.nl: Zorgverzekering uitgelegd", ru: "Government.nl: Медицинская страховка", lang: lang)
        case "GP (huisarts) and emergency care":
            return localized(en: title, nl: "Huisarts en spoedeisende zorg", ru: "Huisarts и экстренная помощь", lang: lang)
        case "DUO: International student info":
            return localized(en: title, nl: "DUO: Informatie voor internationale studenten", ru: "DUO: Информация для иностранных студентов", lang: lang)
        case "Study in NL: Student guide":
            return localized(en: title, nl: "Study in NL: Studentengids", ru: "Study in NL: Гид для студентов", lang: lang)
        case "Government.nl: Housing and rental rights":
            return localized(en: title, nl: "Government.nl: Wonen en huurrechten", ru: "Government.nl: Жильё и права арендатора", lang: lang)
        case "RDW: Driving licences and vehicles":
            return localized(en: title, nl: "RDW: Rijbewijzen en voertuigen", ru: "RDW: Водительские права и транспорт", lang: lang)
        case "Juridisch Loket: First-line legal help":
            return localized(en: title, nl: "Juridisch Loket: Eerstelijns juridische hulp", ru: "Juridisch Loket: Юридическая помощь", lang: lang)
        case "Fraudehelpdesk: Scam reporting":
            return localized(en: title, nl: "Fraudehelpdesk: Meldpunt fraude", ru: "Fraudehelpdesk: Мошенничество", lang: lang)
        case "Emergency number 112":
            return localized(en: title, nl: "Noodnummer 112", ru: "Экстренный номер 112", lang: lang)
        case "Government.nl: Coming to the Netherlands":
            return localized(en: title, nl: "Government.nl: Naar Nederland komen", ru: "Government.nl: Приезд в Нидерланды", lang: lang)
        case "ACM ConsuWijzer: Consumer rights":
            return localized(en: title, nl: "ACM ConsuWijzer: Consumentenrechten", ru: "ACM ConsuWijzer: Права потребителя", lang: lang)
        default: return title
        }
    }

    func localizedDescription(_ lang: AppLanguage) -> String {
        switch title {
        case "IND: Residence permits and immigration":
            return localized(en: description, nl: "Officiële regels over verblijfsvergunningtypen, verlengingen, visa, asiel en naturalisatie.", ru: "Официальные правила по видам ВНЖ, продлению, визам, убежищу и натурализации.", lang: lang)
        case "UWV: Employment and benefits":
            return localized(en: description, nl: "Officiële informatie over werknemersverzekeringen, WW-uitkering, ziekteverlof en arbeidscapaciteit.", ru: "Официальная информация о страховании занятости, пособиях по безработице, больничном и трудоспособности.", lang: lang)
        case "Belastingdienst: Tax administration":
            return localized(en: description, nl: "Hoe belastingbrieven te lezen, deadlines te controleren, aangifte te doen en uw belastingsituatie te begrijpen.", ru: "Как читать налоговые письма, проверять сроки, подавать декларацию и понимать свою налоговую ситуацию.", lang: lang)
        case "Toeslagen: Benefits and allowances":
            return localized(en: description, nl: "Officieel portaal voor aanvragen en beheer van zorgtoeslag, huurtoeslag, kinderopvangtoeslag en kinderbijslag.", ru: "Официальный портал для подачи заявок на zorgtoeslag, huurtoeslag, kinderopvangtoeslag и kinderbijslag.", lang: lang)
        case "Government.nl: Health insurance explained":
            return localized(en: description, nl: "Overzicht van verplichte basisverzekering: wie moet, termijnen en eigen risico.", ru: "Обзор обязательного базового медицинского страхования: кто обязан, сроки и eigen risico.", lang: lang)
        case "GP (huisarts) and emergency care":
            return localized(en: description, nl: "Praktische uitleg: wanneer huisarts, wanneer ziekenhuis, wanneer 112 bellen.", ru: "Практическое объяснение: когда обращаться к huisarts, когда — в больницу, когда звонить 112.", lang: lang)
        case "DUO: International student info":
            return localized(en: description, nl: "DUO-informatie over onderwijsadministratie voor internationale studenten.", ru: "Информация DUO об администрировании обучения для иностранных студентов.", lang: lang)
        case "Study in NL: Student guide":
            return localized(en: description, nl: "Oriëntatie op studeren in Nederland: aanmelding, campusleven en eerste stappen.", ru: "Ориентация по учёбе в Нидерландах: поступление, кампусная жизнь и первые шаги.", lang: lang)
        case "Government.nl: Housing and rental rights":
            return localized(en: description, nl: "Officiële informatie over huurrechten, adresinschrijving en woonregels.", ru: "Официальное руководство по правам арендаторов, регистрации адреса и жилищным правилам.", lang: lang)
        case "RDW: Driving licences and vehicles":
            return localized(en: description, nl: "Officiële regels over rijbewijzen, kentekenregistratie, APK en omwisseling van buitenlandse rijbewijzen.", ru: "Официальные правила по водительским правам, регистрации авто, APK и обмену иностранных прав.", lang: lang)
        case "Juridisch Loket: First-line legal help":
            return localized(en: description, nl: "Juridische oriëntatie in begrijpelijke taal: wonen, werk, consumentenrechten, officiële brieven.", ru: "Юридическая ориентация простым языком: жильё, работа, права потребителя, официальные письма.", lang: lang)
        case "Fraudehelpdesk: Scam reporting":
            return localized(en: description, nl: "Controleer verdachte berichten, meld fraude en bescherm uzelf tegen phishing en nep-boetes.", ru: "Проверка подозрительных сообщений, сообщение о мошенничестве, защита от фишинга и фейковых штрафов.", lang: lang)
        case "Emergency number 112":
            return localized(en: description, nl: "Noodhulp bij direct levensgevaar: politie, brandweer en ambulance.", ru: "Экстренный номер при непосредственной угрозе жизни: полиция, пожарные, скорая помощь.", lang: lang)
        case "Government.nl: Coming to the Netherlands":
            return localized(en: description, nl: "Overzicht van inschrijving, BSN, verblijf en eerste stappen voor nieuwkomers in Nederland.", ru: "Обзор регистрации, BSN, проживания и первых шагов для новоприбывших в Нидерланды.", lang: lang)
        case "ACM ConsuWijzer: Consumer rights":
            return localized(en: description, nl: "Advies over consumentenrechten, klachten over bedrijven, oneerlijke contracten en online aankopen.", ru: "Советы по правам потребителей, жалобам на компании, несправедливым контрактам и интернет-покупкам.", lang: lang)
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
        case "Anyone receiving tax correspondence or needing to file a return":
            return localized(en: whoItHelps, nl: "Ontvangers van belastingpost en aangevers", ru: "Получателям налоговых писем и тем, кто подаёт декларацию", lang: lang)
        case "Families, students, and workers who may qualify for income-based allowances":
            return localized(en: whoItHelps, nl: "Gezinnen, studenten en werkenden met recht op toeslagen", ru: "Семьям, студентам и работающим с правом на пособия", lang: lang)
        case "Newcomers and workers who need to understand their health insurance obligation":
            return localized(en: whoItHelps, nl: "Nieuwkomers en werkenden die hun verzekeringsplicht willen begrijpen", ru: "Новоприбывшим и работникам, которым нужно разобраться со страховкой", lang: lang)
        case "Everyone navigating the Dutch healthcare system for the first time":
            return localized(en: whoItHelps, nl: "Iedereen die voor het eerst met de Nederlandse zorg te maken heeft", ru: "Всем, кто осваивает нидерландскую систему здравоохранения", lang: lang)
        case "New international students arriving in the Netherlands":
            return localized(en: whoItHelps, nl: "Nieuwe internationale studenten", ru: "Новым иностранным студентам", lang: lang)
        case "Renters and newcomers looking for housing guidance":
            return localized(en: whoItHelps, nl: "Huurders en nieuwkomers op zoek naar woonbegeleiding", ru: "Арендаторам и новоприбывшим, ищущим жильё", lang: lang)
        case "Drivers and vehicle owners in the Netherlands":
            return localized(en: whoItHelps, nl: "Bestuurders en voertuigeigenaren in Nederland", ru: "Водителям и владельцам авто в Нидерландах", lang: lang)
        case "Anyone who needs to understand their legal rights or respond to official correspondence":
            return localized(en: whoItHelps, nl: "Iedereen die zijn rechten wil begrijpen of op officiële post wil reageren", ru: "Тем, кто хочет понять свои права или ответить на официальное письмо", lang: lang)
        case "Anyone who has received a suspicious message or believes they are being targeted":
            return localized(en: whoItHelps, nl: "Iedereen die een verdacht bericht heeft ontvangen of slachtoffer denkt te zijn", ru: "Всем, кто получил подозрительное сообщение или стал жертвой мошенников", lang: lang)
        case "Anyone newly arriving and starting life in the Netherlands":
            return localized(en: whoItHelps, nl: "Iedereen die pas in Nederland aankomt", ru: "Всем, кто только приехал в Нидерланды", lang: lang)
        case "Anyone dealing with a consumer complaint or unfair business practice":
            return localized(en: whoItHelps, nl: "Iedereen met een consumentenklacht of oneerlijke handelspraktijk", ru: "Тем, кто столкнулся с жалобой или нечестной практикой бизнеса", lang: lang)
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
        case "Belastingdienst: Tax administration":
            return localized(en: reminder, nl: "Noteer direct de reactie- en betalingsdeadlines op belastingbrieven — te laat handelen kan boetes geven.", ru: "Сразу фиксируйте даты ответа и оплаты из налоговых писем — просрочка может повлечь штраф.", lang: lang)
        case "Toeslagen: Benefits and allowances":
            return localized(en: reminder, nl: "Werk inkomen en gezinsgegevens direct bij na wijzigingen — teveel ontvangen toeslag moet worden terugbetaald.", ru: "При изменении дохода или состава семьи сразу обновляйте данные — переплату придётся вернуть.", lang: lang)
        case "Government.nl: Health insurance explained":
            return localized(en: reminder, nl: "De startdatum van de verplichting hangt af van uw situatie. Controleer dit vroeg.", ru: "Дата начала обязанности зависит от вашей ситуации. Проверьте заранее.", lang: lang)
        case "GP (huisarts) and emergency care":
            return localized(en: reminder, nl: "Bel 112 alleen bij levensgevaar. Voor niet-urgente zaken: uw huisarts.", ru: "Звоните 112 только при угрозе жизни. По несрочным вопросам обращайтесь к врачу.", lang: lang)
        case "DUO: International student info":
            return localized(en: reminder, nl: "Controleer uw DUO-portaal regelmatig en sla alle bevestigingen op.", ru: "Регулярно проверяйте кабинет DUO и сохраняйте все подтверждения.", lang: lang)
        case "Study in NL: Student guide":
            return localized(en: reminder, nl: "Verifieer definitieve vereisten altijd bij DUO en uw instelling.", ru: "Финальные требования всегда сверяйте с DUO и вашим вузом.", lang: lang)
        case "Government.nl: Housing and rental rights":
            return localized(en: reminder, nl: "Lokale gemeenteregels kunnen afwijken van nationale richtlijnen.", ru: "Локальные правила gemeente могут отличаться от общегосударственных.", lang: lang)
        case "RDW: Driving licences and vehicles":
            return localized(en: reminder, nl: "Controleer of uw land een rijbewijs-uitwisselingsverdrag heeft met Nederland.", ru: "Проверьте, есть ли у вашей страны соглашение об обмене прав с Нидерландами.", lang: lang)
        case "Juridisch Loket: First-line legal help":
            return localized(en: reminder, nl: "Juridisch Loket geeft oriëntatie — raadpleeg een advocaat voor complexe gevallen.", ru: "Juridisch Loket даёт ориентацию — для сложных ситуаций обратитесь к юристу.", lang: lang)
        case "Fraudehelpdesk: Scam reporting":
            return localized(en: reminder, nl: "Klik nooit op links in verdachte berichten. Typ URL's altijd handmatig in.", ru: "Никогда не переходите по ссылкам из подозрительных сообщений. Вводите URL вручную.", lang: lang)
        case "Emergency number 112":
            return localized(en: reminder, nl: "Voor niet-urgent politiecontact: 0900-8844. Voor niet-urgente medische vragen: uw huisarts.", ru: "По неэкстренным вопросам полиции звоните 0900-8844. Для медицинских — обращайтесь к врачу.", lang: lang)
        case "Government.nl: Coming to the Netherlands":
            return localized(en: reminder, nl: "Stappen en termijnen kunnen variëren per nationaliteit en verblijfsdoel.", ru: "Шаги и сроки могут различаться в зависимости от гражданства и цели пребывания.", lang: lang)
        case "ACM ConsuWijzer: Consumer rights":
            return localized(en: reminder, nl: "Bij onopgeloste klachten kunt u escaleren naar de relevante sectortoezichthouder.", ru: "При неразрешённых жалобах можно обратиться в отраслевой регулятор.", lang: lang)
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
