import Foundation

enum MockBeginnerGuidesData {
    static let items: [BeginnerGuideItem] = [

        // MARK: - Identity

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:what-is-bsn"),
            category: .identity,
            titleByLanguage: [
                .english: "What is BSN?",
                .dutch: "Wat is BSN?",
                .russian: "Что такое BSN?"
            ],
            descriptionByLanguage: [
                .english: "BSN (Burgerservicenummer) is your unique personal identification number in the Netherlands, assigned by the municipality when you register.",
                .dutch: "BSN (Burgerservicenummer) is uw unieke persoonlijke identificatienummer in Nederland, toegekend door de gemeente bij inschrijving.",
                .russian: "BSN (Burgerservicenummer) — уникальный личный идентификационный номер в Нидерландах, присваиваемый муниципалитетом при регистрации."
            ],
            simpleAnswerByLanguage: [
                .english: "BSN is a 9-digit number you need for work, taxes, healthcare, banking, and virtually all official services in the Netherlands.",
                .dutch: "BSN is een 9-cijferig nummer dat u nodig heeft voor werk, belasting, zorg, bankieren en vrijwel alle officiële diensten in Nederland.",
                .russian: "BSN — 9-значный номер, необходимый для работы, налогов, медицины, банковских и практически всех официальных сервисов."
            ],
            whyItMattersByLanguage: [
                .english: "Without a BSN you cannot legally work, open a bank account, take out health insurance, or access government benefits.",
                .dutch: "Zonder BSN kunt u niet legaal werken, een bankrekening openen, een zorgverzekering afsluiten of aanspraak maken op overheidsuitkeringen.",
                .russian: "Без BSN вы не можете легально работать, открыть счёт, оформить страховку или получать государственные пособия."
            ],
            whatToCheckByLanguage: [
                .english: ["Valid ID document (passport or residence permit)", "Fixed address in the Netherlands", "Municipality appointment booked", "BSN on your residence permit or municipality registration"],
                .dutch: ["Geldig legitimatiebewijs (paspoort of verblijfsvergunning)", "Vast adres in Nederland", "Afspraak bij gemeente gemaakt", "BSN op verblijfsvergunning of gemeentelijke inschrijving"],
                .russian: ["Действительный документ (паспорт или ВНЖ)", "Постоянный адрес в Нидерландах", "Запись в gemeente", "BSN в ВНЖ или при регистрации"]
            ],
            commonMistakeByLanguage: [
                .english: "Assuming you automatically get a BSN without registering at the municipality. You must register in person with a valid ID and proof of address.",
                .dutch: "Aannemen dat je automatisch een BSN krijgt zonder inschrijving bij de gemeente. U moet persoonlijk inschrijven met geldig ID en adresbewijs.",
                .russian: "Ожидать, что BSN придёт автоматически без похода в gemeente. Регистрация происходит лично с документами."
            ],
            safeNextStepByLanguage: [
                .english: "Book an appointment at your municipality (gemeente) website as soon as you have a fixed address. Bring passport and proof of address.",
                .dutch: "Maak zo snel mogelijk een afspraak via de website van uw gemeente zodra u een vast adres heeft. Neem paspoort en adresbewijs mee.",
                .russian: "Запишитесь в gemeente онлайн, как только появится постоянный адрес. Возьмите паспорт и подтверждение адреса."
            ],
            officialSourceName: "Government.nl — BSN",
            officialSourceURL: URL(string: "https://www.government.nl/topics/personal-data/citizen-service-number-bsn"),
            keywordsByLanguage: [
                .english: ["BSN", "burgerservicenummer", "personal number", "registration", "municipality"],
                .dutch: ["BSN", "burgerservicenummer", "persoonsnummer", "registratie", "gemeente"],
                .russian: ["BSN", "бсн", "личный номер", "регистрация", "gemeente"]
            ],
            relatedTopics: ["DigiD", "Municipality Registration", "Health Insurance", "Bank Account"],
            riskLevel: .high
        ),

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:how-to-get-digid"),
            category: .identity,
            titleByLanguage: [
                .english: "How to Get DigiD",
                .dutch: "Hoe krijg ik DigiD?",
                .russian: "Как получить DigiD?"
            ],
            descriptionByLanguage: [
                .english: "DigiD is the Dutch government's digital identity tool, allowing you to log in securely to hundreds of government and healthcare websites.",
                .dutch: "DigiD is het digitale identiteitsmiddel van de Nederlandse overheid, waarmee u veilig kunt inloggen op honderden overheids- en zorgwebsites.",
                .russian: "DigiD — цифровой идентификатор голландского правительства для безопасного входа на сотни государственных и медицинских сайтов."
            ],
            simpleAnswerByLanguage: [
                .english: "Apply for DigiD on digid.nl after you have your BSN. You'll receive an activation code by post in 5-7 days.",
                .dutch: "Vraag DigiD aan op digid.nl nadat u uw BSN heeft. U ontvangt een activatiecode per post binnen 5-7 dagen.",
                .russian: "Подайте заявку на DigiD на digid.nl после получения BSN. Код активации придёт почтой через 5–7 дней."
            ],
            whyItMattersByLanguage: [
                .english: "DigiD is required to access your healthcare insurer portal, tax return (Belastingdienst), toeslagen (benefits), and most government online services.",
                .dutch: "DigiD is vereist voor toegang tot het portaal van uw zorgverzekeraar, belastingaangifte, toeslagen en de meeste online overheidsdiensten.",
                .russian: "DigiD нужен для доступа к порталу страховщика, налоговой декларации, toeslagen и большинства государственных сервисов."
            ],
            whatToCheckByLanguage: [
                .english: ["BSN received", "Dutch address for postal delivery", "Email address", "Dutch mobile number (for SMS verification)"],
                .dutch: ["BSN ontvangen", "Nederlands adres voor postlevering", "E-mailadres", "Nederlands mobiel nummer (voor sms-verificatie)"],
                .russian: ["BSN получен", "Нидерландский адрес для почты", "Email", "Нидерландский мобильный номер"]
            ],
            commonMistakeByLanguage: [
                .english: "Trying to apply for DigiD before having a BSN and Dutch address. The activation letter is sent by post to your registered address.",
                .dutch: "Proberen DigiD aan te vragen vóór BSN en Nederlands adres. De activatiebrief wordt per post naar uw ingeschreven adres gestuurd.",
                .russian: "Подавать заявку на DigiD до получения BSN и адреса — письмо с кодом приходит на зарегистрированный адрес."
            ],
            safeNextStepByLanguage: [
                .english: "Go to digid.nl and follow the official application steps. Never use unofficial third-party websites.",
                .dutch: "Ga naar digid.nl en volg de officiële aanvraagstappen. Gebruik nooit onofficiële websites van derden.",
                .russian: "Перейдите на digid.nl и следуйте официальным шагам. Никогда не используйте сторонние сайты."
            ],
            officialSourceName: "DigiD.nl",
            officialSourceURL: URL(string: "https://www.digid.nl/en"),
            keywordsByLanguage: [
                .english: ["DigiD", "digital identity", "login", "government portal", "BSN"],
                .dutch: ["DigiD", "digitale identiteit", "inloggen", "overheidsportaal", "BSN"],
                .russian: ["DigiD", "цифровой ID", "вход", "государственный портал", "BSN"]
            ],
            relatedTopics: ["BSN", "Toeslagen", "Belastingdienst", "Health Insurance Portal"],
            riskLevel: .medium
        ),

        // MARK: - Municipality

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:registering-at-the-municipality-gemeente"),
            category: .municipality,
            titleByLanguage: [
                .english: "Registering at the Municipality (Gemeente)",
                .dutch: "Inschrijven bij de gemeente",
                .russian: "Регистрация в муниципалитете (Gemeente)"
            ],
            descriptionByLanguage: [
                .english: "Everyone who lives in the Netherlands must register at their local municipality within 5 days of getting a fixed address. This registers you in the BRP.",
                .dutch: "Iedereen die in Nederland woont moet zich binnen 5 dagen na het krijgen van een vast adres inschrijven bij de gemeente. Dit registreert u in de BRP.",
                .russian: "Все жители Нидерландов обязаны зарегистрироваться в местном муниципалитете в течение 5 дней после получения постоянного адреса."
            ],
            simpleAnswerByLanguage: [
                .english: "Book an appointment at your gemeente as soon as you have a fixed address. Bring your passport and rental contract or housing document.",
                .dutch: "Maak zo snel mogelijk een afspraak bij uw gemeente zodra u een vast adres heeft. Neem uw paspoort en huurcontract of huisvestingsdocument mee.",
                .russian: "Запишитесь в gemeente сразу после получения адреса. Возьмите паспорт и договор аренды или документ о жилье."
            ],
            whyItMattersByLanguage: [
                .english: "Without municipal registration you cannot get a BSN, open a bank account, access benefits, or legally work. It is the first and most critical step.",
                .dutch: "Zonder gemeentelijke inschrijving kunt u geen BSN krijgen, geen bankrekening openen, geen uitkeringen ontvangen of legaal werken.",
                .russian: "Без регистрации нельзя получить BSN, открыть счёт, получать пособия или легально работать. Это первый и важнейший шаг."
            ],
            whatToCheckByLanguage: [
                .english: ["Valid passport or ID", "Proof of address (rental contract, letter from landlord)", "Work permit or visa if applicable", "Completed registration form (varies by city)"],
                .dutch: ["Geldig paspoort of ID", "Adresbewijs (huurcontract, brief van verhuurder)", "Werkvergunning of visum indien van toepassing", "Ingevuld inschrijfformulier"],
                .russian: ["Действительный паспорт", "Подтверждение адреса (договор аренды или письмо арендодателя)", "Разрешение на работу/виза при необходимости"]
            ],
            commonMistakeByLanguage: [
                .english: "Registering at a temporary accommodation (AirBnb, hotel). You need a stable rental or owned property address for official registration.",
                .dutch: "Inschrijven op een tijdelijk verblijf (AirBnb, hotel). U heeft een stabiel huur- of koopwoningadres nodig voor officiële inschrijving.",
                .russian: "Регистрироваться на временном жилье (AirBnB, отель). Нужен стабильный адрес аренды или собственности."
            ],
            safeNextStepByLanguage: [
                .english: "Visit your city's official gemeente website and book a registration appointment. Search '[your city] gemeente inschrijven'.",
                .dutch: "Bezoek de officiële gemeentewebsite van uw stad en maak een inschrijfafspraak. Zoek op '[uw stad] gemeente inschrijven'.",
                .russian: "Зайдите на официальный сайт вашего города и запишитесь. Введите '[название города] gemeente inschrijven'."
            ],
            officialSourceName: "Government.nl — Municipality Registration",
            officialSourceURL: URL(string: "https://www.government.nl/themes/government-and-democracy/personal-data/personal-records-database-brp"),
            keywordsByLanguage: [
                .english: ["gemeente", "municipality", "registration", "BRP", "address", "inschrijven"],
                .dutch: ["gemeente", "inschrijven", "BRP", "adres", "registratie"],
                .russian: ["gemeente", "регистрация", "BRP", "муниципалитет", "адрес"]
            ],
            relatedTopics: ["BSN", "DigiD", "BRP", "Address Change"],
            riskLevel: .high
        ),

        // MARK: - Immigration

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:understanding-your-residence-permit"),
            category: .immigration,
            titleByLanguage: [
                .english: "Understanding Your Residence Permit",
                .dutch: "Uw verblijfsvergunning begrijpen",
                .russian: "Понимание вашего вида на жительство (ВНЖ)"
            ],
            descriptionByLanguage: [
                .english: "A residence permit (verblijfsvergunning) is the official document that allows non-EU citizens to stay and live in the Netherlands. It is issued by the IND.",
                .dutch: "Een verblijfsvergunning is het officiële document dat niet-EU-burgers toestaat in Nederland te verblijven. Het wordt afgegeven door de IND.",
                .russian: "Вид на жительство (verblijfsvergunning) — официальный документ для граждан не-ЕС на проживание в Нидерландах. Выдаётся IND."
            ],
            simpleAnswerByLanguage: [
                .english: "Check the expiry date, conditions, and type of your permit. It determines what you can do in the Netherlands: work, study, or stay.",
                .dutch: "Controleer de vervaldatum, voorwaarden en het type van uw vergunning. Dit bepaalt wat u in Nederland mag doen: werken, studeren of verblijven.",
                .russian: "Проверьте дату истечения, условия и тип разрешения. Это определяет, что вам разрешено: работать, учиться или просто находиться."
            ],
            whyItMattersByLanguage: [
                .english: "Your permit type determines your rights to work, access benefits, and travel within the EU. Violating permit conditions can have serious consequences.",
                .dutch: "Uw type vergunning bepaalt uw rechten om te werken, uitkeringen te ontvangen en binnen de EU te reizen.",
                .russian: "Тип ВНЖ определяет права на работу, пособия и поездки в ЕС. Нарушение условий ВНЖ может иметь серьёзные последствия."
            ],
            whatToCheckByLanguage: [
                .english: ["Permit expiry date", "Conditions written on the permit (e.g. 'arbeid vrij toegestaan')", "Whether renewal is needed 3 months before expiry", "IND portal for your application status"],
                .dutch: ["Vervaldatum vergunning", "Voorwaarden op de vergunning (bijv. 'arbeid vrij toegestaan')", "Of verlenging 3 maanden voor vervaldatum nodig is", "IND-portaal voor uw aanvraagstatus"],
                .russian: ["Дата окончания ВНЖ", "Условия (например, 'arbeid vrij toegestaan')", "Не нужно ли продление за 3 месяца до истечения", "Статус заявки в портале IND"]
            ],
            commonMistakeByLanguage: [
                .english: "Assuming the permit renews automatically. You must actively apply for renewal before the current permit expires.",
                .dutch: "Aannemen dat de vergunning automatisch wordt verlengd. U moet actief een verlenging aanvragen vóór het huidige vergunning verloopt.",
                .russian: "Думать, что ВНЖ продлевается автоматически. Нужно самостоятельно подавать заявку на продление до истечения срока."
            ],
            safeNextStepByLanguage: [
                .english: "Check your permit card for the expiry date. Log in to the IND portal to verify your current status and renewal options.",
                .dutch: "Controleer uw verblijfsvergunningkaart op de vervaldatum. Log in op het IND-portaal om uw status en verlengingsopties te controleren.",
                .russian: "Проверьте карточку ВНЖ на дату истечения. Войдите в портал IND для проверки статуса и вариантов продления."
            ],
            officialSourceName: "IND — Residence Permits",
            officialSourceURL: URL(string: "https://ind.nl/en/residence-permits"),
            keywordsByLanguage: [
                .english: ["residence permit", "verblijfsvergunning", "IND", "visa", "immigration", "renewal"],
                .dutch: ["verblijfsvergunning", "IND", "visum", "immigratie", "verlenging"],
                .russian: ["ВНЖ", "вид на жительство", "verblijfsvergunning", "IND", "иммиграция", "продление"]
            ],
            relatedTopics: ["IND", "BSN", "Inburgering", "MVV visa"],
            riskLevel: .high
        ),

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:asylum-process-in-the-netherlands"),
            category: .immigration,
            titleByLanguage: [
                .english: "Asylum Process in the Netherlands",
                .dutch: "Asielproces in Nederland",
                .russian: "Процедура убежища в Нидерландах"
            ],
            descriptionByLanguage: [
                .english: "If you are seeking asylum in the Netherlands, the process is managed by the IND. The first step is to report to a reception centre (aanmeldcentrum).",
                .dutch: "Als u asiel aanvraagt in Nederland, wordt het proces beheerd door de IND. De eerste stap is melden bij een aanmeldcentrum.",
                .russian: "Если вы ищете убежище в Нидерландах, процессом управляет IND. Первый шаг — явиться в приёмный центр (aanmeldcentrum)."
            ],
            simpleAnswerByLanguage: [
                .english: "Go to the Central Agency for the Reception of Asylum Seekers (COA) or Ter Apel for the first registration. The IND will then conduct interviews.",
                .dutch: "Ga naar het COA of Ter Apel voor de eerste registratie. De IND voert dan interviews af.",
                .russian: "Обратитесь в COA или в Тер-Апел для первичной регистрации. IND проведёт собеседования."
            ],
            whyItMattersByLanguage: [
                .english: "The asylum process determines your legal status, rights to work, and eventual residence permit type. Legal support is available and strongly recommended.",
                .dutch: "Het asielproces bepaalt uw juridische status, rechten om te werken en het type verblijfsvergunning. Juridische ondersteuning is beschikbaar.",
                .russian: "Процедура убежища определяет ваш правовой статус, право на работу и тип ВНЖ. Юридическая поддержка доступна и настоятельно рекомендуется."
            ],
            whatToCheckByLanguage: [
                .english: ["VluchtelingenWerk (Refugee Work) for free legal advice", "COA manages housing during procedure", "Right to interpreter during IND interviews", "Appeal rights if application is rejected"],
                .dutch: ["VluchtelingenWerk voor gratis juridisch advies", "COA beheert huisvesting tijdens procedure", "Recht op tolk tijdens IND-interviews", "Bezwaar- en beroepsrechten bij afwijzing"],
                .russian: ["VluchtelingenWerk для бесплатной юрпомощи", "COA обеспечивает жильём", "Право на переводчика на собеседованиях IND", "Право на апелляцию при отказе"]
            ],
            commonMistakeByLanguage: [
                .english: "Not requesting a lawyer during IND hearings. Everyone has the right to legal support during the asylum procedure.",
                .dutch: "Geen advocaat aanvragen tijdens IND-gehoren. Iedereen heeft recht op juridische ondersteuning.",
                .russian: "Не запрашивать юриста на слушаниях IND. Каждый имеет право на юридическую поддержку."
            ],
            safeNextStepByLanguage: [
                .english: "Contact VluchtelingenWerk Nederland for free guidance. For Ukrainians, check the temporary protection scheme (Tijdelijke Bescherming).",
                .dutch: "Neem contact op met VluchtelingenWerk Nederland voor gratis begeleiding. Voor Oekraïners: check het tijdelijke beschermingsschema.",
                .russian: "Свяжитесь с VluchtelingenWerk Nederland для бесплатной помощи. Для украинцев — проверьте схему временной защиты."
            ],
            officialSourceName: "IND — Asylum",
            officialSourceURL: URL(string: "https://ind.nl/en/asylum"),
            keywordsByLanguage: [
                .english: ["asylum", "refugee", "IND", "COA", "VluchtelingenWerk", "residence permit", "status"],
                .dutch: ["asiel", "vluchteling", "IND", "COA", "VluchtelingenWerk", "verblijfsvergunning"],
                .russian: ["убежище", "беженец", "IND", "COA", "VluchtelingenWerk", "ВНЖ"]
            ],
            relatedTopics: ["IND", "COA", "VluchtelingenWerk", "Legal Aid"],
            riskLevel: .high
        ),

        // MARK: - Healthcare

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:dutch-health-insurance-explained"),
            category: .healthcare,
            titleByLanguage: [
                .english: "Dutch Health Insurance Explained",
                .dutch: "Nederlandse zorgverzekering uitgelegd",
                .russian: "Медицинская страховка в Нидерландах"
            ],
            descriptionByLanguage: [
                .english: "Basic health insurance (basisverzekering) is mandatory for everyone residing in the Netherlands. You must get it within 4 months of registering.",
                .dutch: "Basisverzekering is verplicht voor iedereen die in Nederland woont. U moet die afsluiten binnen 4 maanden na inschrijving.",
                .russian: "Базовая медицинская страховка (basisverzekering) обязательна для всех жителей Нидерландов. Оформить её нужно в течение 4 месяцев после регистрации."
            ],
            simpleAnswerByLanguage: [
                .english: "Choose a health insurer (zorgverzekeraar), sign up online, and pay monthly premiums. The basic package covers GP visits, hospitals, and essential medicines.",
                .dutch: "Kies een zorgverzekeraar, schrijf u online in en betaal maandelijkse premies. Het basispakket dekt huisartsbezoeken, ziekenhuizen en essentiële medicijnen.",
                .russian: "Выберите страховщика, зарегистрируйтесь онлайн и платите ежемесячную премию. Базовый пакет покрывает GP, больницы и основные лекарства."
            ],
            whyItMattersByLanguage: [
                .english: "If you don't get insured, the CAK can enrol you at a higher rate. Medical care is very expensive without insurance.",
                .dutch: "Als u niet verzekerd bent, kan het CAK u inschrijven tegen een hogere prijs. Medische zorg is erg duur zonder verzekering.",
                .russian: "Если вы не застрахованы, CAK может зарегистрировать вас по более высокой ставке. Медицинская помощь без страховки очень дорогостоящая."
            ],
            whatToCheckByLanguage: [
                .english: ["Monthly premium amount", "Annual eigen risico (own risk, €385 in 2024)", "Network of hospitals and GPs covered", "Supplementary dental or physio insurance needed?", "Apply for zorgtoeslag if income is low"],
                .dutch: ["Maandelijkse premiehoogte", "Jaarlijks eigen risico (€385 in 2024)", "Netwerk van gedekte ziekenhuizen en huisartsen", "Aanvullende tand- of fysiotherapieverzekering nodig?", "Vraag zorgtoeslag aan bij laag inkomen"],
                .russian: ["Размер ежемесячной премии", "Eigen risico (собственный риск, €385 в 2024)", "Покрытие больниц и GP", "Нужна доп. страховка (зубы, физио)?", "Подать на zorgtoeslag при низком доходе"]
            ],
            commonMistakeByLanguage: [
                .english: "Not comparing insurers before signing up. Prices and covered extras vary significantly. Use zorgvergelijker.nl to compare.",
                .dutch: "Niet vergelijken vóór inschrijving. Prijzen en gedekte extra's variëren sterk. Gebruik zorgvergelijker.nl om te vergelijken.",
                .russian: "Не сравнивать страховщиков перед подпиской. Цены и покрытие сильно различаются. Используйте zorgvergelijker.nl."
            ],
            safeNextStepByLanguage: [
                .english: "Compare plans on zorgvergelijker.nl, choose a provider, and sign up before the 4-month deadline. Then apply for zorgtoeslag on toeslagen.nl if eligible.",
                .dutch: "Vergelijk plannen op zorgvergelijker.nl, kies een aanbieder en schrijf u in vóór de termijn van 4 maanden. Vraag dan zorgtoeslag aan op toeslagen.nl.",
                .russian: "Сравните на zorgvergelijker.nl, выберите страховщика, оформите до истечения 4 месяцев. Затем подайте на zorgtoeslag на toeslagen.nl при праве."
            ],
            officialSourceName: "Government.nl — Health Insurance",
            officialSourceURL: URL(string: "https://www.government.nl/topics/health-insurance"),
            keywordsByLanguage: [
                .english: ["health insurance", "zorgverzekering", "basisverzekering", "eigen risico", "zorgtoeslag", "CAK"],
                .dutch: ["zorgverzekering", "basisverzekering", "eigen risico", "zorgtoeslag", "CAK"],
                .russian: ["страховка", "медицина", "basisverzekering", "eigen risico", "zorgtoeslag"]
            ],
            relatedTopics: ["Zorgtoeslag", "Huisarts", "Eigen Risico", "CAK"],
            riskLevel: .high
        ),

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:registering-with-a-gp-huisarts"),
            category: .healthcare,
            titleByLanguage: [
                .english: "Registering with a GP (Huisarts)",
                .dutch: "Inschrijven bij een huisarts",
                .russian: "Регистрация у врача общей практики (Huisarts)"
            ],
            descriptionByLanguage: [
                .english: "The huisarts (GP) is the cornerstone of the Dutch healthcare system. You cannot see a specialist without a GP referral.",
                .dutch: "De huisarts is de hoeksteen van het Nederlandse gezondheidssysteem. U kunt geen specialist bezoeken zonder verwijzing van de huisarts.",
                .russian: "Huisarts (врач общей практики) — основа нидерландской системы здравоохранения. Без его направления нельзя попасть к специалисту."
            ],
            simpleAnswerByLanguage: [
                .english: "Find a GP near you, call or email their practice to register as a new patient. Bring your BSN and insurance details.",
                .dutch: "Zoek een huisarts in uw buurt, bel of e-mail hun praktijk om u in te schrijven als nieuwe patiënt. Neem uw BSN en verzekeringsgegevens mee.",
                .russian: "Найдите GP рядом, позвоните или напишите в практику для регистрации. Возьмите BSN и данные страховки."
            ],
            whyItMattersByLanguage: [
                .english: "Without a GP you cannot get referrals, prescriptions, or sick notes. Register even when healthy — popular practices have long waiting lists.",
                .dutch: "Zonder huisarts kunt u geen verwijzingen, recepten of ziektebriefjes krijgen. Schrijf u in ook als u gezond bent.",
                .russian: "Без GP не получить направлений, рецептов и больничных листов. Регистрируйтесь, даже будучи здоровым."
            ],
            whatToCheckByLanguage: [
                .english: ["GP accepts new patients in your area", "BSN number ready", "Health insurance policy number", "ID document"],
                .dutch: ["Huisarts accepteert nieuwe patiënten in uw omgeving", "BSN-nummer gereed", "Polisnummer zorgverzekering", "Legitimatiebewijs"],
                .russian: ["GP принимает новых пациентов", "BSN", "Номер полиса страховки", "Документ, удостоверяющий личность"]
            ],
            commonMistakeByLanguage: [
                .english: "Waiting until you are ill to register. By then you may not be able to access care quickly due to waiting lists.",
                .dutch: "Wachten tot u ziek bent om u in te schrijven. Dan kunt u mogelijk niet snel zorg krijgen vanwege wachtlijsten.",
                .russian: "Откладывать регистрацию до болезни. Тогда можно не попасть к врачу быстро из-за очередей."
            ],
            safeNextStepByLanguage: [
                .english: "Use the GP finder on zorgwijzer.nl or google '[your city] huisarts new patients'. Register within the first 2 weeks of arrival.",
                .dutch: "Gebruik de huisartszoeker op zorgwijzer.nl of zoek op '[uw stad] huisarts nieuwe patiënten'. Schrijf u in binnen de eerste 2 weken.",
                .russian: "Используйте zorgwijzer.nl или поиск '[ваш город] huisarts nieuwe patiënten'. Зарегистрируйтесь в первые 2 недели."
            ],
            officialSourceName: "Zorgwijzer.nl",
            officialSourceURL: URL(string: "https://www.zorgwijzer.nl"),
            keywordsByLanguage: [
                .english: ["huisarts", "GP", "doctor", "healthcare", "referral", "general practitioner"],
                .dutch: ["huisarts", "dokter", "zorg", "verwijzing", "inschrijven"],
                .russian: ["huisarts", "врач", "GP", "медицина", "направление", "запись"]
            ],
            relatedTopics: ["Health Insurance", "Specialist Referral", "Pharmacy", "Mental Health"],
            riskLevel: .medium
        ),

        // MARK: - Benefits

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:dutch-benefits-toeslagen-explained"),
            category: .benefits,
            titleByLanguage: [
                .english: "Dutch Benefits (Toeslagen) Explained",
                .dutch: "Nederlandse toeslagen uitgelegd",
                .russian: "Нидерландские субсидии (Toeslagen)"
            ],
            descriptionByLanguage: [
                .english: "Toeslagen are government benefits to help people with low or middle incomes cover costs for healthcare, rent, childcare, and child maintenance.",
                .dutch: "Toeslagen zijn overheidsbijdragen die mensen met een laag of middeninkomen helpen bij de kosten voor zorg, huur, kinderopvang en kinderonderhoud.",
                .russian: "Toeslagen — государственные субсидии для людей с низким и средним доходом на покрытие расходов на медицину, аренду, детский сад и детские пособия."
            ],
            simpleAnswerByLanguage: [
                .english: "Apply for toeslagen via toeslagen.nl using your DigiD. The main types are: zorgtoeslag (healthcare), huurtoeslag (rent), kinderopvangtoeslag (childcare), kinderbijslag (child benefit).",
                .dutch: "Vraag toeslagen aan via toeslagen.nl met uw DigiD. De belangrijkste soorten zijn: zorgtoeslag, huurtoeslag, kinderopvangtoeslag en kinderbijslag.",
                .russian: "Подайте заявку через toeslagen.nl с DigiD. Основные виды: zorgtoeslag (медицина), huurtoeslag (аренда), kinderopvangtoeslag (детсад), kinderbijslag (детское пособие)."
            ],
            whyItMattersByLanguage: [
                .english: "Many newcomers miss out on hundreds of euros per month by not applying. Always apply if your income is within the qualifying range.",
                .dutch: "Veel nieuwkomers missen honderden euro's per maand door niet aan te vragen. Vraag altijd aan als uw inkomen binnen de grens valt.",
                .russian: "Многие новички теряют сотни евро в месяц, не подавая заявки. Всегда подавайте, если ваш доход в пределах лимита."
            ],
            whatToCheckByLanguage: [
                .english: ["Annual income is within eligibility limits", "DigiD active", "BSN number", "Rental contract (for huurtoeslag)", "Health insurance active (for zorgtoeslag)", "Report income changes immediately"],
                .dutch: ["Jaarlijks inkomen valt binnen de grenswaarden", "DigiD actief", "BSN-nummer", "Huurcontract (voor huurtoeslag)", "Zorgverzekering actief (voor zorgtoeslag)", "Inkomensmutaties direct doorgeven"],
                .russian: ["Доход в пределах лимита", "DigiD активен", "BSN", "Договор аренды (для huurtoeslag)", "Страховка активна (для zorgtoeslag)", "Немедленно сообщать об изменении дохода"]
            ],
            commonMistakeByLanguage: [
                .english: "Not reporting income changes to Toeslagen. If you earn more than declared, you may face repayment demands for the entire year.",
                .dutch: "Inkomensmutaties niet doorgeven aan Toeslagen. Als u meer verdient dan opgegeven, kunt u terugbetalingen voor het hele jaar krijgen.",
                .russian: "Не сообщать об изменении дохода в Toeslagen. При превышении задекларированного дохода придётся вернуть субсидии за весь год."
            ],
            safeNextStepByLanguage: [
                .english: "Log in to toeslagen.nl with DigiD and check which benefits you qualify for. Apply for each one individually.",
                .dutch: "Log in op toeslagen.nl met DigiD en controleer voor welke toeslagen u in aanmerking komt. Vraag ze elk afzonderlijk aan.",
                .russian: "Войдите на toeslagen.nl через DigiD и проверьте, на какие субсидии вы имеете право. Подайте на каждую отдельно."
            ],
            officialSourceName: "Belastingdienst Toeslagen",
            officialSourceURL: URL(string: "https://www.toeslagen.nl"),
            keywordsByLanguage: [
                .english: ["toeslagen", "benefits", "zorgtoeslag", "huurtoeslag", "kinderopvangtoeslag", "kinderbijslag"],
                .dutch: ["toeslagen", "zorgtoeslag", "huurtoeslag", "kinderopvangtoeslag", "kinderbijslag"],
                .russian: ["toeslagen", "субсидии", "zorgtoeslag", "huurtoeslag", "пособия"]
            ],
            relatedTopics: ["DigiD", "Zorgtoeslag", "Huurtoeslag", "Belastingdienst"],
            riskLevel: .medium
        ),

        // MARK: - Work

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:dutch-work-contracts-explained"),
            category: .work,
            titleByLanguage: [
                .english: "Dutch Work Contracts Explained",
                .dutch: "Nederlandse arbeidscontracten uitgelegd",
                .russian: "Трудовые договоры в Нидерландах"
            ],
            descriptionByLanguage: [
                .english: "Understanding your contract type is essential in the Netherlands. There are several types: fixed-term, permanent, flex, and self-employed (ZZP).",
                .dutch: "Het begrijpen van uw contracttype is essentieel in Nederland. Er zijn meerdere types: tijdelijk, vast, flex en zelfstandig (ZZP).",
                .russian: "Понимание типа контракта в Нидерландах очень важно. Типы: срочный, бессрочный, гибкий и самозанятость (ZZP)."
            ],
            simpleAnswerByLanguage: [
                .english: "Always get your contract in writing. Check contract duration, salary, working hours, holiday days (minimum 20 days/year), and trial period (max 2 months).",
                .dutch: "Zorg altijd voor een schriftelijk contract. Controleer contractduur, salaris, werktijden, vakantiedagen (minimaal 20 per jaar) en proeftijd (max. 2 maanden).",
                .russian: "Всегда берите контракт письменно. Проверьте срок, зарплату, рабочие часы, отпуск (минимум 20 дней) и испытательный срок (макс. 2 месяца)."
            ],
            whyItMattersByLanguage: [
                .english: "Your contract type affects your rights to benefits (WW), sick pay (Ziektewet), and notice periods. A permanent contract provides the strongest protections.",
                .dutch: "Uw contracttype beïnvloedt uw rechten op uitkeringen (WW), ziektegeld (Ziektewet) en opzegtermijnen. Een vast contract biedt de sterkste bescherming.",
                .russian: "Тип договора влияет на права на пособия (WW), больничные (Ziektewet) и сроки уведомления. Бессрочный контракт даёт наибольшую защиту."
            ],
            whatToCheckByLanguage: [
                .english: ["Contract type (tijdelijk / vast / oproep)", "Gross salary and payment schedule", "Holiday allowance (vakantiegeld = 8% of annual salary)", "Collective agreement (CAO) applicable to your sector", "Trial period conditions"],
                .dutch: ["Contracttype (tijdelijk / vast / oproep)", "Brutoloon en betalingsschema", "Vakantiegeld (8% van jaarsalaris)", "CAO van toepassing op uw sector", "Proeftijdvoorwaarden"],
                .russian: ["Тип контракта (tijdelijk / vast / oproep)", "Брутозарплата и график выплат", "Vakantiegeld (отпускные = 8% годовой зарплаты)", "Коллективный договор (CAO)", "Условия испытательного срока"]
            ],
            commonMistakeByLanguage: [
                .english: "Not knowing that vakantiegeld (8% holiday allowance) is mandatory and is usually paid out in May/June each year.",
                .dutch: "Niet weten dat vakantiegeld (8% vakantietoeslag) verplicht is en meestal in mei/juni elk jaar wordt uitbetaald.",
                .russian: "Не знать, что vakantiegeld (отпускные 8%) обязательны и выплачиваются в мае/июне каждого года."
            ],
            safeNextStepByLanguage: [
                .english: "Read your full contract before signing. Check minimum wage rates on rijksoverheid.nl. Contact Juridisch Loket for free legal advice if uncertain.",
                .dutch: "Lees uw volledige contract vóór ondertekening. Controleer minimumloonbedragen op rijksoverheid.nl. Neem contact op met het Juridisch Loket voor gratis juridisch advies.",
                .russian: "Прочитайте контракт полностью до подписания. Проверьте минимальную зарплату на rijksoverheid.nl. Обратитесь в Juridisch Loket за бесплатной юрпомощью."
            ],
            officialSourceName: "Rijksoverheid — Employment",
            officialSourceURL: URL(string: "https://www.rijksoverheid.nl/onderwerpen/arbeidsovereenkomst-en-cao/vraag-en-antwoord/wat-staat-er-in-een-arbeidsovereenkomst"),
            keywordsByLanguage: [
                .english: ["work contract", "arbeidscontract", "CAO", "vakantiegeld", "salary", "employment"],
                .dutch: ["arbeidscontract", "CAO", "vakantiegeld", "salaris", "werk"],
                .russian: ["трудовой договор", "контракт", "CAO", "vakantiegeld", "зарплата", "работа"]
            ],
            relatedTopics: ["Payslip", "UWV", "Minimum Wage", "CAO", "ZZP"],
            riskLevel: .medium
        ),

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:reading-your-dutch-payslip-loonstrook"),
            category: .work,
            titleByLanguage: [
                .english: "Reading Your Dutch Payslip (Loonstrook)",
                .dutch: "Uw Nederlandse loonstrook lezen",
                .russian: "Как читать нидерландский расчётный лист (loonstrook)"
            ],
            descriptionByLanguage: [
                .english: "Every Dutch employee receives a monthly payslip (loonstrook) showing gross salary, deductions, and net pay.",
                .dutch: "Elke Nederlandse werknemer ontvangt een maandelijkse loonstrook met brutoloon, inhoudingen en nettoloon.",
                .russian: "Каждый работник получает ежемесячный расчётный лист (loonstrook) с брутозарплатой, удержаниями и нетто."
            ],
            simpleAnswerByLanguage: [
                .english: "Bruto = gross (before tax), Netto = net (what you receive). Key deductions include loonheffing (wage tax) and ZVW premie (health insurance contribution).",
                .dutch: "Bruto = bruto (voor belasting), Netto = netto (wat u ontvangt). Belangrijke inhoudingen zijn loonheffing en ZVW-premie.",
                .russian: "Bruto = до налогов, Netto = на руки. Основные удержания: loonheffing (налог на зарплату) и ZVW premie (взнос на медстраховку)."
            ],
            whyItMattersByLanguage: [
                .english: "Errors on payslips do occur. Checking monthly ensures you are paid correctly for overtime, holidays, and allowances.",
                .dutch: "Fouten op loonstroken komen voor. Maandelijks controleren zorgt voor correcte betaling.",
                .russian: "Ошибки в расчётных листах бывают. Ежемесячная проверка гарантирует правильную оплату."
            ],
            whatToCheckByLanguage: [
                .english: ["Bruto loon (gross salary matches contract)", "Loonheffing (wage tax withheld)", "Pensioen (pension contribution if applicable)", "Vakantiegeld opbouw (holiday pay accrual)", "Net pay matches bank transfer"],
                .dutch: ["Bruto loon (klopt met contract)", "Loonheffing (ingehouden loonbelasting)", "Pensioen (pensioenopbouw)", "Vakantiegeld opbouw", "Nettoloon klopt met bankoverschrijving"],
                .russian: ["Bruto loon = сумма по контракту", "Loonheffing (налог с зарплаты)", "Pensioen (пенсионные взносы)", "Vakantiegeld opbouw (накопление отпускных)", "Netto = зачислено на счёт"]
            ],
            commonMistakeByLanguage: [
                .english: "Confusing bruto and netto salaries during job negotiations. Always clarify whether a quoted salary is gross or net.",
                .dutch: "Verwarring tussen bruto en netto salarissen bij functieonderhandelingen. Vraag altijd of het salaris bruto of netto is.",
                .russian: "Путать bruto и netto при переговорах. Уточняйте: зарплата указывается как bruto или netto."
            ],
            safeNextStepByLanguage: [
                .english: "Save all payslips digitally. Compare with your employment contract. If something looks wrong, ask your employer's HR department.",
                .dutch: "Bewaar alle loonstroken digitaal. Vergelijk met uw arbeidscontract. Als iets niet klopt, vraag dan de HR-afdeling.",
                .russian: "Сохраняйте все loonstrook в цифровом виде. Сравнивайте с договором. При несоответствии обращайтесь в отдел кадров."
            ],
            officialSourceName: "Belastingdienst — Loonheffing",
            officialSourceURL: URL(string: "https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/zakelijk/personeel_en_loon"),
            keywordsByLanguage: [
                .english: ["payslip", "loonstrook", "salary", "bruto", "netto", "loonheffing", "vakantiegeld"],
                .dutch: ["loonstrook", "salaris", "bruto", "netto", "loonheffing"],
                .russian: ["loonstrook", "расчётный лист", "зарплата", "bruto", "netto", "loonheffing"]
            ],
            relatedTopics: ["Work Contract", "Taxes", "Vakantiegeld", "Belastingdienst"],
            riskLevel: .low
        ),

        // MARK: - Taxes

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:filing-your-dutch-tax-return"),
            category: .taxes,
            titleByLanguage: [
                .english: "Filing Your Dutch Tax Return",
                .dutch: "Uw Nederlandse belastingaangifte indienen",
                .russian: "Подача налоговой декларации в Нидерландах"
            ],
            descriptionByLanguage: [
                .english: "Every year, residents who have taxable income may need to file an annual tax return (aangifte) with the Belastingdienst. The deadline is typically May 1st.",
                .dutch: "Elk jaar moeten inwoners met belastbaar inkomen mogelijk een jaarlijkse aangifte indienen bij de Belastingdienst. De deadline is doorgaans 1 mei.",
                .russian: "Ежегодно жители с налогооблагаемым доходом должны подавать декларацию (aangifte) в Belastingdienst. Дедлайн — обычно 1 мая."
            ],
            simpleAnswerByLanguage: [
                .english: "Log in to mijn.belastingdienst.nl with DigiD. Many fields are pre-filled from employer data. Submit by May 1st to avoid surcharges.",
                .dutch: "Log in op mijn.belastingdienst.nl met DigiD. Veel velden zijn vooraf ingevuld vanuit werkgeversgegevens. Dien in vóór 1 mei.",
                .russian: "Войдите на mijn.belastingdienst.nl через DigiD. Многие поля уже заполнены данными работодателя. Подайте до 1 мая."
            ],
            whyItMattersByLanguage: [
                .english: "You may be entitled to a tax refund if you overpaid during the year. If you owe tax and miss the deadline, surcharges apply.",
                .dutch: "U heeft mogelijk recht op belastingteruggaaf als u te veel heeft betaald. Als u belasting verschuldigd bent en de deadline mist, worden toeslagen opgelegd.",
                .russian: "Вы можете получить возврат налога при переплате. Если вы должны налог и пропустили дедлайн, начисляются штрафные надбавки."
            ],
            whatToCheckByLanguage: [
                .english: ["Annual income statements (jaaropgave) from employer", "Bank interest income", "Benefits received (toeslagen)", "Mortgage deductions if applicable", "Charity donations (giften) may be deductible"],
                .dutch: ["Jaarlijkse inkomensopgave (jaaropgave) van werkgever", "Bankrente-inkomsten", "Ontvangen toeslagen", "Hypotheekaftrek indien van toepassing", "Giften zijn mogelijk aftrekbaar"],
                .russian: ["Jaaropgave (справка о доходах) от работодателя", "Доход от процентов по счёту", "Полученные toeslagen", "Ипотечные вычеты при наличии", "Пожертвования (giften) могут быть вычтены"]
            ],
            commonMistakeByLanguage: [
                .english: "Not filing because you think it's not required. Even if your employer already withholds tax, you may get a refund by filing voluntarily.",
                .dutch: "Niet indienen omdat u denkt dat het niet vereist is. Zelfs als uw werkgever al belasting inhoudt, kunt u teruggave krijgen.",
                .russian: "Не подавать декларацию, думая, что это не нужно. Даже при удержании налога работодателем вы можете получить возврат."
            ],
            safeNextStepByLanguage: [
                .english: "In January/February, log in to mijn.belastingdienst.nl and check if you need to file. Gather jaaropgave documents from your employer.",
                .dutch: "Log in januari/februari in op mijn.belastingdienst.nl en controleer of u aangifte moet doen. Verzamel jaaropgavedocumenten van uw werkgever.",
                .russian: "В январе/феврале войдите на mijn.belastingdienst.nl и проверьте необходимость подачи. Соберите jaaropgave от работодателя."
            ],
            officialSourceName: "Belastingdienst",
            officialSourceURL: URL(string: "https://www.belastingdienst.nl"),
            keywordsByLanguage: [
                .english: ["tax return", "aangifte", "belastingdienst", "jaaropgave", "tax refund"],
                .dutch: ["belastingaangifte", "aangifte", "belastingdienst", "jaaropgave", "teruggaaf"],
                .russian: ["налоговая декларация", "aangifte", "belastingdienst", "jaaropgave", "возврат налога"]
            ],
            relatedTopics: ["Toeslagen", "Belastingdienst", "Jaaropgave", "30% Ruling"],
            riskLevel: .medium
        ),

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:the-30-ruling-for-expats"),
            category: .taxes,
            titleByLanguage: [
                .english: "The 30% Ruling for Expats",
                .dutch: "De 30%-regeling voor expats",
                .russian: "Правило 30% для экспатов"
            ],
            descriptionByLanguage: [
                .english: "The 30% ruling is a Dutch tax advantage for highly skilled workers recruited from abroad, allowing 30% of salary to be paid tax-free.",
                .dutch: "De 30%-regeling is een Nederlands belastingvoordeel voor hooggekwalificeerde werknemers van buiten NL, waarbij 30% van het salaris belastingvrij kan worden uitbetaald.",
                .russian: "Правило 30% — налоговая льгота Нидерландов для высококвалифицированных иностранных специалистов: 30% зарплаты выплачивается без налогов."
            ],
            simpleAnswerByLanguage: [
                .english: "If you qualify, your employer can pay 30% of your salary tax-free for up to 5 years. Apply within 4 months of starting work.",
                .dutch: "Als u in aanmerking komt, kan uw werkgever tot 5 jaar lang 30% van uw salaris belastingvrij uitbetalen. Dien in binnen 4 maanden na start.",
                .russian: "При соответствии требованиям работодатель может выплачивать 30% зарплаты без налогов до 5 лет. Подайте заявку в течение 4 месяцев."
            ],
            whyItMattersByLanguage: [
                .english: "The 30% ruling can significantly increase your take-home pay. Missing the 4-month application window means you permanently lose it for this employment.",
                .dutch: "De 30%-regeling kan uw nettoloon aanzienlijk verhogen. Het missen van het aanvraagtijdvenster van 4 maanden betekent permanent verlies.",
                .russian: "Правило 30% значительно увеличивает нетто-зарплату. Пропустив 4-месячное окно, вы навсегда лишаетесь льготы для данного места работы."
            ],
            whatToCheckByLanguage: [
                .english: ["Salary above the annual threshold (changes yearly)", "Position recruited from outside the Netherlands", "Specific expertise not readily available in NL", "Apply within 4 months of start date", "Joint application by employer and employee"],
                .dutch: ["Salaris boven de jaardrempel", "Functie geworven vanuit het buitenland", "Specifieke expertise niet beschikbaar in NL", "Dien in binnen 4 maanden na startdatum", "Gezamenlijke aanvraag werkgever en werknemer"],
                .russian: ["Зарплата выше годового порога", "Нанят из-за рубежа", "Специфическая экспертиза", "Подать в течение 4 месяцев", "Совместная заявка работодателя и работника"]
            ],
            commonMistakeByLanguage: [
                .english: "Assuming your employer will automatically arrange it. You need to actively discuss and apply together within the deadline.",
                .dutch: "Aannemen dat uw werkgever het automatisch regelt. U moet het actief bespreken en samen binnen de deadline aanvragen.",
                .russian: "Ждать, что работодатель всё сделает автоматически. Нужно активно обсудить и совместно подать в срок."
            ],
            safeNextStepByLanguage: [
                .english: "Discuss the 30% ruling with your HR department immediately when hired. Check eligibility criteria on belastingdienst.nl.",
                .dutch: "Bespreek de 30%-regeling meteen bij aanvang met uw HR-afdeling. Controleer de geschiktheidscriteria op belastingdienst.nl.",
                .russian: "При найме сразу обсудите правило 30% с HR. Проверьте критерии на belastingdienst.nl."
            ],
            officialSourceName: "Belastingdienst — 30% Ruling",
            officialSourceURL: URL(string: "https://www.belastingdienst.nl"),
            keywordsByLanguage: [
                .english: ["30% ruling", "expat tax", "tax advantage", "highly skilled", "belastingdienst"],
                .dutch: ["30%-regeling", "expat belasting", "belastingvoordeel", "kennismigrant"],
                .russian: ["30% правило", "экспат", "налоговая льгота", "kennis migrant", "belastingdienst"]
            ],
            relatedTopics: ["Tax Return", "Work Contract", "Expat Registration", "Belastingdienst"],
            riskLevel: .medium
        ),

        // MARK: - Housing

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:renting-a-home-in-the-netherlands"),
            category: .housing,
            titleByLanguage: [
                .english: "Renting a Home in the Netherlands",
                .dutch: "Een woning huren in Nederland",
                .russian: "Аренда жилья в Нидерландах"
            ],
            descriptionByLanguage: [
                .english: "The Dutch rental market is competitive, especially in Amsterdam, Rotterdam, and Utrecht. Understanding social vs private rental is essential.",
                .dutch: "De Nederlandse huurmarkt is competitief, vooral in Amsterdam, Rotterdam en Utrecht. Het verschil tussen sociale en vrije sector is essentieel.",
                .russian: "Рынок аренды в Нидерландах конкурентен. Важно понимать разницу между социальным и частным жильём."
            ],
            simpleAnswerByLanguage: [
                .english: "Social housing (sociale huur) has lower rents but long waiting lists (5-15 years). Private sector (vrije sector) is faster but more expensive — budget €1,000-1,500/month for a studio.",
                .dutch: "Sociale huur heeft lagere huurprijzen maar zeer lange wachtlijsten (5-15 jaar). Vrije sector is sneller maar duurder — budget minimaal €1.000-1.500/maand voor een studio.",
                .russian: "Социальное жильё (sociale huur) дешевле, но очереди 5–15 лет. Частный сектор (vrije sector) быстрее, но дороже — бюджетируйте минимум €1.000–1.500/мес. за студию."
            ],
            whyItMattersByLanguage: [
                .english: "Scam listings are common. Never pay a deposit without viewing the property and signing a contract. Verify landlord identity before transferring money.",
                .dutch: "Nep-advertenties komen veel voor. Betaal nooit een aanbetaling zonder bezichtiging en contract. Verifieer de verhuurderidentiteit vóór geldoverdracht.",
                .russian: "Мошеннические объявления распространены. Никогда не платите залог без просмотра квартиры и подписания договора."
            ],
            whatToCheckByLanguage: [
                .english: ["Rental contract in Dutch/English", "Maximum deposit = 2 months rent (since 2023)", "Energy label of the property", "Utilities included or excluded?", "Register for Huurcommissie rights if in regulated zone"],
                .dutch: ["Huurcontract in NL/EN", "Maximale borgsom = 2 maanden huur (sinds 2023)", "Energielabel van de woning", "Nutsvoorzieningen inbegrepen?", "Huurcommissierechten voor gereguleerde huur"],
                .russian: ["Договор на NL/EN", "Залог максимум 2 месяца аренды (с 2023)", "Энергетический ярлык жилья", "Утилиты включены?", "Права Huurcommissie при регулируемой аренде"]
            ],
            commonMistakeByLanguage: [
                .english: "Paying a deposit before signing a contract. Scammers exploit urgent housing situations. Always use official platforms like Funda, Pararius, or a registered agency.",
                .dutch: "Borgsom betalen vóór contractondertekening. Gebruik altijd officiële platforms zoals Funda of Pararius.",
                .russian: "Платить залог до подписания договора. Мошенники используют срочные ситуации с жильём. Используйте Funda, Pararius или зарегистрированное агентство."
            ],
            safeNextStepByLanguage: [
                .english: "Search on Funda.nl, Pararius.nl, or Kamernet.nl. For social housing, register with your municipality's waiting list early.",
                .dutch: "Zoek op Funda.nl, Pararius.nl of Kamernet.nl. Voor sociale huur, schrijf u vroeg in op de wachtlijst van uw gemeente.",
                .russian: "Ищите на Funda.nl, Pararius.nl или Kamernet.nl. Для социального жилья зарегистрируйтесь в очереди муниципалитета заранее."
            ],
            officialSourceName: "Rijksoverheid — Housing",
            officialSourceURL: URL(string: "https://www.rijksoverheid.nl/onderwerpen/huurwoning"),
            keywordsByLanguage: [
                .english: ["housing", "renting", "huurwoning", "sociale huur", "vrije sector", "Funda", "deposit"],
                .dutch: ["huurwoning", "sociale huur", "vrije sector", "borg", "huurcontract"],
                .russian: ["аренда", "жильё", "huurwoning", "sociale huur", "залог", "Funda"]
            ],
            relatedTopics: ["Huurtoeslag", "Huurcommissie", "Energy Labels", "Deposit Rights"],
            riskLevel: .high
        ),

        // MARK: - Transport

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:using-the-ov-chipkaart"),
            category: .transport,
            titleByLanguage: [
                .english: "Using the OV-chipkaart",
                .dutch: "De OV-chipkaart gebruiken",
                .russian: "Как пользоваться OV-chipkaart"
            ],
            descriptionByLanguage: [
                .english: "The OV-chipkaart is a rechargeable smart card used to pay for all public transport in the Netherlands — buses, trams, metros, and trains.",
                .dutch: "De OV-chipkaart is een oplaadbare chipkaart voor al het openbaar vervoer in Nederland — bussen, trams, metro's en treinen.",
                .russian: "OV-chipkaart — пополняемая смарт-карта для оплаты всего общественного транспорта Нидерландов."
            ],
            simpleAnswerByLanguage: [
                .english: "Always check in (inchecken) when boarding and check out (uitchecken) when leaving. Keep a minimum balance of €20 for train journeys.",
                .dutch: "Check altijd in bij het instappen en uit bij het uitstappen. Houd een minimumsaldo van €20 voor treinreizen.",
                .russian: "Всегда выполняйте check-in при посадке и check-out при выходе. Держите минимальный баланс €20 для поездок на поезде."
            ],
            whyItMattersByLanguage: [
                .english: "Failing to check out results in the maximum fare being charged. Forgetting check-out on a train can cost €20+ per journey.",
                .dutch: "Niet uitchecken leidt tot maximumkosten. Vergeten uit te checken in een trein kan €20+ per rit kosten.",
                .russian: "Забытый check-out означает максимальный тариф. Не выйти в поезде = €20+ за поездку."
            ],
            whatToCheckByLanguage: [
                .english: ["Personal or anonymous OV-chipkaart", "Auto-reload set up to avoid empty balance", "Student OV subscription if eligible", "Check balance at ov-chipkaart.nl or yellow check-in poles", "Always check in and out — even when transferring"],
                .dutch: ["Persoonlijke of anonieme OV-chipkaart", "Automatisch opladen ingesteld", "Studentenabonnement indien in aanmerking", "Saldo controleren op ov-chipkaart.nl of gele palen", "Altijd in- en uitchecken — ook bij overstappen"],
                .russian: ["Личная OV-chipkaart или анонимная", "Автопополнение для избежания нулевого баланса", "Студенческий OV при праве", "Проверка баланса на ov-chipkaart.nl", "Всегда check-in и check-out"]
            ],
            commonMistakeByLanguage: [
                .english: "Not registering your anonymous OV-chipkaart. A registered personal card can be blocked and refunded if lost.",
                .dutch: "Uw anonieme OV-chipkaart niet registreren. Een geregistreerde kaart kan geblokkeerd worden en vergoed bij verlies.",
                .russian: "Не регистрировать анонимную OV-chipkaart. Зарегистрированную карту можно заблокировать и вернуть деньги при потере."
            ],
            safeNextStepByLanguage: [
                .english: "Get an OV-chipkaart at a NS station, supermarket, or order online at ov-chipkaart.nl. Register it online to protect your balance.",
                .dutch: "Haal een OV-chipkaart bij een NS-station, supermarkt of bestel online op ov-chipkaart.nl. Registreer hem online.",
                .russian: "Получите OV-chipkaart на станции NS, в супермаркете или на ov-chipkaart.nl. Зарегистрируйте онлайн для защиты баланса."
            ],
            officialSourceName: "OV-chipkaart.nl",
            officialSourceURL: URL(string: "https://www.ov-chipkaart.nl/en"),
            keywordsByLanguage: [
                .english: ["OV-chipkaart", "public transport", "train", "bus", "tram", "NS", "check in"],
                .dutch: ["OV-chipkaart", "openbaar vervoer", "trein", "bus", "tram", "inchecken"],
                .russian: ["OV-chipkaart", "общественный транспорт", "поезд", "автобус", "трамвай", "check-in"]
            ],
            relatedTopics: ["NS Trains", "Bus/Tram", "Student OV", "9292.nl"],
            riskLevel: .low
        ),

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:cycling-rules-in-the-netherlands"),
            category: .transport,
            titleByLanguage: [
                .english: "Cycling Rules in the Netherlands",
                .dutch: "Fietsregels in Nederland",
                .russian: "Правила езды на велосипеде в Нидерландах"
            ],
            descriptionByLanguage: [
                .english: "Cycling is the primary mode of transport for millions of Dutch people. There are strict traffic rules for cyclists that can result in fines if broken.",
                .dutch: "Fietsen is het primaire vervoermiddel voor miljoenen Nederlanders. Er zijn strenge verkeersregels voor fietsers die kunnen leiden tot boetes.",
                .russian: "Велосипед — основной транспорт для миллионов голландцев. Правила движения для велосипедистов строгие, нарушение влечёт штрафы."
            ],
            simpleAnswerByLanguage: [
                .english: "Use bike lanes (fietspaden), have front and rear lights at night, don't use your phone while cycling, and follow all traffic signals.",
                .dutch: "Gebruik fietspaden, zorg voor voor- en achterlicht 's nachts, gebruik geen telefoon tijdens fietsen en volg alle verkeerssignalen.",
                .russian: "Используйте велодорожки (fietspaden), имейте передний и задний свет ночью, не пользуйтесь телефоном и соблюдайте сигналы."
            ],
            whyItMattersByLanguage: [
                .english: "Cycling fines start at €95 (no lights) and €180+ (phone use). Police actively enforce cycling rules, especially in cities.",
                .dutch: "Fietsboetes beginnen bij €95 (geen lichten) en €180+ (telefoongebruik). Politie handhaaft fietsregels actief in steden.",
                .russian: "Штрафы за велосипед: от €95 (нет фонарей) и €180+ (телефон). Полиция активно следит за правилами."
            ],
            whatToCheckByLanguage: [
                .english: ["Front white light + rear red light required after dark", "Bell (bel) required by law", "No phone use while cycling", "Must use fietspaden where available", "No cycling against traffic on one-way streets"],
                .dutch: ["Voorlicht (wit) + achterlicht (rood) verplicht na donker", "Bel verplicht", "Geen telefoon tijdens fietsen", "Fietspad verplicht waar beschikbaar", "Niet fietsen tegen eenrichtingsverkeer"],
                .russian: ["Белый передний + красный задний свет ночью", "Звонок (bel) обязателен", "Телефон за рулём — штраф", "Велодорожки обязательны где есть", "Нельзя ехать против движения"]
            ],
            commonMistakeByLanguage: [
                .english: "Riding without lights at night. This is one of the most common and most fined offences for newcomers.",
                .dutch: "Rijden zonder lichten 's nachts. Dit is een van de meest beboete overtredingen voor nieuwkomers.",
                .russian: "Езда без фонарей ночью — одно из самых частых и штрафуемых нарушений среди новичков."
            ],
            safeNextStepByLanguage: [
                .english: "Buy a used bike at a second-hand shop or marktplaats.nl. Always buy lights immediately. Register your bike frame number.",
                .dutch: "Koop een tweedehands fiets bij een kringloopwinkel of marktplaats.nl. Koop altijd direct fietslichten.",
                .russian: "Купите велосипед в секондхенде или на marktplaats.nl. Сразу купите фонари. Зарегистрируйте номер рамы."
            ],
            officialSourceName: "Rijksoverheid — Cycling Rules",
            officialSourceURL: URL(string: "https://www.rijksoverheid.nl/onderwerpen/fiets"),
            keywordsByLanguage: [
                .english: ["cycling", "fiets", "bicycle", "bike lane", "fietspad", "lights", "phone fine"],
                .dutch: ["fietsen", "fiets", "fietspad", "fietslicht", "boete"],
                .russian: ["велосипед", "fietsen", "велодорожка", "fietspad", "фонарь", "штраф"]
            ],
            relatedTopics: ["Bicycle Fines", "Traffic Rules", "OV Transport", "Bike Locks"],
            riskLevel: .medium
        ),

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:exchanging-a-foreign-driving-licence"),
            category: .transport,
            titleByLanguage: [
                .english: "Exchanging a Foreign Driving Licence",
                .dutch: "Buitenlands rijbewijs omwisselen",
                .russian: "Обмен иностранного водительского удостоверения"
            ],
            descriptionByLanguage: [
                .english: "Whether you can drive with your foreign licence in the Netherlands depends on your country of origin and residence permit type.",
                .dutch: "Of u met uw buitenlands rijbewijs in Nederland mag rijden hangt af van uw land van herkomst en verblijfsvergunningtype.",
                .russian: "Возможность езды с иностранными правами зависит от страны происхождения и типа ВНЖ."
            ],
            simpleAnswerByLanguage: [
                .english: "EU/EEA licences are valid in the Netherlands indefinitely. Non-EU licences: exchange may be required. Check rdw.nl for your country.",
                .dutch: "EU/EER-rijbewijzen zijn onbeperkt geldig in Nederland. Niet-EU-rijbewijzen: omwisseling kan vereist zijn. Controleer rdw.nl voor uw land.",
                .russian: "Права ЕС/ЕЭЗ действительны бессрочно. Не-ЕС: возможно нужен обмен. Проверьте rdw.nl для своей страны."
            ],
            whyItMattersByLanguage: [
                .english: "Driving with an invalid foreign licence is an offence. Rules differ by country — some have bilateral agreements for direct exchange.",
                .dutch: "Rijden met een ongeldig buitenlands rijbewijs is een overtreding. Regels verschillen per land.",
                .russian: "Езда с недействительными правами — нарушение. Правила зависят от страны — у некоторых есть двусторонние соглашения."
            ],
            whatToCheckByLanguage: [
                .english: ["Check your country on rdw.nl exchange list", "International driving permit (IDP) may help temporarily", "Exchange application goes through your municipality", "Theory/practical test may be needed for some countries"],
                .dutch: ["Controleer uw land op rdw.nl uitwisselingslijst", "Internationaal rijbewijs kan tijdelijk helpen", "Omwisselingsaanvraag via gemeente", "Theorie/praktijkexamen vereist voor sommige landen"],
                .russian: ["Проверьте страну на rdw.nl", "МВУ (международные права) могут помочь временно", "Заявка на обмен через gemeente", "Теория/практика для некоторых стран"]
            ],
            commonMistakeByLanguage: [
                .english: "Assuming all foreign licences automatically work in the Netherlands. Always verify your specific country's status on rdw.nl.",
                .dutch: "Aannemen dat alle buitenlandse rijbewijzen automatisch geldig zijn. Controleer altijd uw land op rdw.nl.",
                .russian: "Думать, что все иностранные права автоматически действуют. Всегда проверяйте rdw.nl."
            ],
            safeNextStepByLanguage: [
                .english: "Visit rdw.nl/en and search 'exchange driving licence' for your country. Then contact your municipality to start the process.",
                .dutch: "Bezoek rdw.nl en zoek naar uw land bij 'rijbewijs omwisselen'. Neem contact op met uw gemeente.",
                .russian: "Зайдите на rdw.nl и найдите вашу страну. Затем обратитесь в gemeente."
            ],
            officialSourceName: "RDW — Driving Licence Exchange",
            officialSourceURL: URL(string: "https://www.rdw.nl/en/driving-licence/foreign-driving-licence"),
            keywordsByLanguage: [
                .english: ["driving licence", "rijbewijs", "RDW", "exchange", "foreign licence", "CBR"],
                .dutch: ["rijbewijs", "omwisselen", "RDW", "buitenlands rijbewijs"],
                .russian: ["водительское удостоверение", "права", "обмен", "RDW", "rijbewijs"]
            ],
            relatedTopics: ["RDW", "CBR", "Driving Rules", "Municipality Appointment"],
            riskLevel: .medium
        ),

        // MARK: - Education

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:inburgering-dutch-integration-course"),
            category: .education,
            titleByLanguage: [
                .english: "Inburgering — Dutch Integration Course",
                .dutch: "Inburgering — Nederlandse integratiecursus",
                .russian: "Inburgering — курс интеграции в Нидерланды"
            ],
            descriptionByLanguage: [
                .english: "Inburgering is the mandatory civic integration programme for most non-EU newcomers. It includes Dutch language learning and Dutch society knowledge.",
                .dutch: "Inburgering is het verplichte inburgeringsprogramma voor de meeste niet-EU-nieuwkomers.",
                .russian: "Inburgering — обязательная программа гражданской интеграции для большинства граждан не-ЕС."
            ],
            simpleAnswerByLanguage: [
                .english: "Most newcomers must pass the inburgering exam within 3 years of getting a residence permit. It includes Dutch language (B1 level), Dutch society knowledge (KNM), and participation declaration (PVT).",
                .dutch: "De meeste nieuwkomers moeten het inburgeringsexamen halen binnen 3 jaar. Dit omvat Nederlands (B1), KNM en PVT.",
                .russian: "Большинство новичков обязаны сдать inburgering в течение 3 лет. Включает нидерландский (B1), KNM и PVT."
            ],
            whyItMattersByLanguage: [
                .english: "Failing to complete inburgering on time can jeopardize your residence permit renewal.",
                .dutch: "Het niet op tijd afronden kan uw verblijfsvergunningverlenging in gevaar brengen.",
                .russian: "Невыполнение inburgering вовремя может поставить под угрозу продление ВНЖ."
            ],
            whatToCheckByLanguage: [
                .english: ["Check if inburgering is mandatory for your permit type", "3-year deadline from permit issuance", "DUO lening (loan) for course costs", "Language components: Listening, Reading, Speaking, Writing", "KNM (Dutch society knowledge) exam"],
                .dutch: ["Of inburgering verplicht is voor uw type", "3-jarige deadline", "DUO-lening voor cursuskosten", "Taalonderdelen: Luisteren, Lezen, Spreken, Schrijven", "KNM-examen"],
                .russian: ["Обязателен ли inburgering для вашего типа ВНЖ", "3-летний дедлайн", "Займ DUO на курсы", "Языковые компоненты", "Экзамен KNM"]
            ],
            commonMistakeByLanguage: [
                .english: "Underestimating the time needed. B1 Dutch from scratch can take 12-18 months of serious study.",
                .dutch: "De benodigde tijd onderschatten. B1-niveau vanuit het niets kan 12-18 maanden vergen.",
                .russian: "Недооценивать нужное время. Нидерландский до B1 с нуля занимает 12–18 месяцев."
            ],
            safeNextStepByLanguage: [
                .english: "Check if inburgering applies to you on inburgering.nl. Contact your municipality for a personal integration plan.",
                .dutch: "Controleer op inburgering.nl of het voor u geldt. Neem contact op met uw gemeente.",
                .russian: "Проверьте на inburgering.nl. Свяжитесь с gemeente для личного плана интеграции."
            ],
            officialSourceName: "Inburgering.nl",
            officialSourceURL: URL(string: "https://www.inburgering.nl"),
            keywordsByLanguage: [
                .english: ["inburgering", "integration", "Dutch language", "KNM", "B1", "DUO"],
                .dutch: ["inburgering", "integratie", "Nederlands", "KNM", "DUO"],
                .russian: ["inburgering", "интеграция", "нидерландский язык", "KNM", "DUO"]
            ],
            relatedTopics: ["Residence Permit", "DUO", "Dutch Language", "Municipality"],
            riskLevel: .high
        ),

        // MARK: - Fines

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:cycling-fines-you-need-to-know"),
            category: .fines,
            titleByLanguage: [
                .english: "Cycling Fines You Need to Know",
                .dutch: "Fietsboetes die u moet kennen",
                .russian: "Штрафы за езду на велосипеде"
            ],
            descriptionByLanguage: [
                .english: "The Netherlands has strict enforcement of cycling laws. Common fines: no lights, phone use, running red lights, and wrong-way cycling.",
                .dutch: "Nederland handhaaft fietsregels streng. Veelvoorkomende boetes: geen lichten, telefoon, rood licht en fietsen verkeerde kant.",
                .russian: "В Нидерландах строго соблюдаются правила. Частые штрафы: нет фонарей, телефон, красный свет, езда против движения."
            ],
            simpleAnswerByLanguage: [
                .english: "Main cycling fines: No lights (€95+), phone use (€180+), running red light (€100+), no bell (€55+), cycling on pavement (€55+).",
                .dutch: "Belangrijkste fietsboetes: Geen lichten (€95+), telefoon (€180+), rood licht (€100+), geen bel (€55+), fietspad trottoir (€55+).",
                .russian: "Основные штрафы: нет фонарей (€95+), телефон (€180+), красный свет (€100+), нет звонка (€55+), тротуар (€55+)."
            ],
            whyItMattersByLanguage: [
                .english: "These are the most commonly issued fines to newcomers unaware of Dutch cycling law.",
                .dutch: "Dit zijn de meest uitgedeelde boetes aan nieuwkomers die niet op de hoogte zijn van de fietsregels.",
                .russian: "Это одни из самых частых штрафов для новичков, не знающих нидерландских правил."
            ],
            whatToCheckByLanguage: [
                .english: ["Front white + rear red light/reflector at night", "Bell must be audible", "Never hold phone while cycling", "Use bike lane, not pavement", "Stop at red lights — no exceptions"],
                .dutch: ["Voorlicht + achterlicht/-reflector 's nachts", "Bel moet hoorbaar zijn", "Nooit telefoon tijdens fietsen", "Fietspad gebruiken, niet trottoir", "Stoppen bij rood licht"],
                .russian: ["Белый передний + красный задний свет ночью", "Звонок слышен", "Никогда не держать телефон", "Только велодорожка", "Стоп на красный"]
            ],
            commonMistakeByLanguage: [
                .english: "Using a phone for navigation while cycling. Even mounted, handheld use while moving is fined.",
                .dutch: "Telefoon voor navigatie tijdens fietsen. Zelfs in houder, vasthouden tijdens rijden is beboet.",
                .russian: "Держать телефон для навигации. Даже при подставке штраф выписывается за ручное использование."
            ],
            safeNextStepByLanguage: [
                .english: "Invest in good rechargeable bike lights. Mount your phone on a handlebar holder for hands-free navigation.",
                .dutch: "Investeer in oplaadbare fietslichten. Monteer telefoon op stuurhouder voor handsfree navigatie.",
                .russian: "Купите хорошие перезаряжаемые фонари. Закрепите телефон на руле для навигации."
            ],
            officialSourceName: "CJIB — Fines",
            officialSourceURL: URL(string: "https://www.cjib.nl/en"),
            keywordsByLanguage: [
                .english: ["cycling fine", "fietsboete", "bike light", "phone cycling", "red light"],
                .dutch: ["fietsboete", "fietslicht", "telefoon fietsen", "rood licht"],
                .russian: ["штраф велосипед", "fietsboete", "фонарь", "телефон велосипед"]
            ],
            relatedTopics: ["Cycling Rules", "Traffic Fines", "CJIB", "Bicycle Equipment"],
            riskLevel: .medium
        ),

        // MARK: - Safety

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:emergency-numbers-in-the-netherlands"),
            category: .safety,
            titleByLanguage: [
                .english: "Emergency Numbers in the Netherlands",
                .dutch: "Noodnummers in Nederland",
                .russian: "Номера экстренных служб в Нидерландах"
            ],
            descriptionByLanguage: [
                .english: "Knowing the correct emergency numbers can save lives. The Netherlands has a unified emergency number (112) plus specialized non-emergency lines.",
                .dutch: "Het kennen van de juiste noodnummers kan levens redden. Nederland heeft een uniform noodnummer (112) plus niet-urgente lijnen.",
                .russian: "Знание правильных номеров экстренных служб спасает жизни. В Нидерландах единый номер (112) и специализированные линии."
            ],
            simpleAnswerByLanguage: [
                .english: "112 — Police, Fire, Ambulance for life-threatening emergencies. 0900-8844 — Police non-emergency. For urgent non-life-threatening medical care, call your GP or local huisartsenpost.",
                .dutch: "112 — Politie, brandweer, ambulance bij levensbedreigende nood. 0900-8844 — Politie niet-spoed. Voor dringende niet-levensbedreigende zorg: bel huisarts of lokale huisartsenpost.",
                .russian: "112 — полиция, пожарные, скорая при угрозе жизни. 0900-8844 — полиция не срочно. Для срочной медицины без угрозы жизни звоните huisarts или местной huisartsenpost."
            ],
            whyItMattersByLanguage: [
                .english: "Calling 112 for non-emergencies delays real emergency responses. Know the difference.",
                .dutch: "Het bellen van 112 voor niet-urgente zaken vertraagt echte noodrespons. Ken het verschil.",
                .russian: "Звонок 112 по несрочным вопросам задерживает реальные экстренные реакции. Знайте разницу."
            ],
            whatToCheckByLanguage: [
                .english: ["112 for life-threatening emergencies only", "0900-8844 for police non-urgent", "Use your GP or local HAP for urgent non-life-threatening care", "Save your local HAP number from your GP practice website", "0800-0113 suicide prevention (24/7 free)"],
                .dutch: ["112 alleen levensbedreigende spoed", "0900-8844 voor politie niet-urgent", "Gebruik huisarts of lokale HAP voor dringende niet-levensbedreigende zorg", "Sla het lokale HAP-nummer op via uw huisartspraktijk", "0800-0113 suïcidepreventie (24/7 gratis)"],
                .russian: ["112 — только угроза жизни", "0900-8844 — полиция (не срочно)", "Huisarts или местная HAP для срочной медицины без угрозы жизни", "Сохраните номер местной HAP с сайта huisarts", "0800-0113 — предотвращение суицида (24/7)"]
            ],
            commonMistakeByLanguage: [
                .english: "Calling 112 for a non-urgent situation. Use 0900-8844 for police questions and your own GP or local huisartsenpost for urgent medical concerns.",
                .dutch: "112 bellen voor een niet-urgente situatie. Gebruik 0900-8844 voor politievragen en eigen huisarts of lokale huisartsenpost voor dringende zorg.",
                .russian: "Звонить 112 по несрочным вопросам. Используйте 0900-8844 для полиции, huisarts или местную huisartsenpost для срочной медицины."
            ],
            safeNextStepByLanguage: [
                .english: "Save all emergency numbers in your phone now. Add your GP's out-of-hours number and your health insurance emergency line.",
                .dutch: "Sla nu alle noodnummers op in uw telefoon. Voeg het spoednummer van uw huisarts en verzekeraar toe.",
                .russian: "Сохраните все номера сейчас. Добавьте номер дежурного врача и экстренную линию страховщика."
            ],
            officialSourceName: "Politie.nl — Emergency",
            officialSourceURL: URL(string: "https://www.politie.nl"),
            keywordsByLanguage: [
                .english: ["112", "emergency", "ambulance", "police", "fire", "HAP", "doctor emergency"],
                .dutch: ["112", "noodgeval", "ambulance", "politie", "brandweer", "HAP"],
                .russian: ["112", "экстренная", "скорая", "полиция", "пожар", "HAP"]
            ],
            relatedTopics: ["Healthcare", "Police", "Huisarts", "Insurance Emergency Line"],
            riskLevel: .high
        ),

        // MARK: - Daily Life

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:waste-separation-in-the-netherlands"),
            category: .dailyLife,
            titleByLanguage: [
                .english: "Waste Separation in the Netherlands",
                .dutch: "Afvalscheiding in Nederland",
                .russian: "Сортировка мусора в Нидерландах"
            ],
            descriptionByLanguage: [
                .english: "The Netherlands has one of Europe's most sophisticated waste separation systems. Getting it wrong can result in municipal fines.",
                .dutch: "Nederland heeft een van Europa's meest geavanceerde afvalscheidingssystemen. Fouten kunnen leiden tot gemeentelijke boetes.",
                .russian: "В Нидерландах одна из самых продвинутых систем сортировки мусора в Европе. Нарушения могут привести к штрафам."
            ],
            simpleAnswerByLanguage: [
                .english: "Separate waste into: GFT (organic/food), PMD (plastic, metal, drinks cartons), Paper, Glass, Rest (general waste). Collection days vary by address.",
                .dutch: "Scheid afval in: GFT, PMD, Papier, Glas, Restafval. Inzameldagen variëren per adres.",
                .russian: "Разделяйте: GFT (органика/еда), PMD (пластик, металл, тетрапаки), Бумага, Стекло, Restafval. Дни вывоза зависят от адреса."
            ],
            whyItMattersByLanguage: [
                .english: "Improper waste disposal can lead to fines and is disrespectful to your neighbours and community.",
                .dutch: "Onjuiste afvalverwijdering kan leiden tot boetes en is onrespectelijk tegenover uw buren.",
                .russian: "Неправильная утилизация может привести к штрафам и неуважению к соседям."
            ],
            whatToCheckByLanguage: [
                .english: ["GFT bin = food scraps, vegetable waste, garden waste", "PMD = plastics, cans, drink cartons (NOT glass)", "Paper/cardboard = clean packaging, newspapers", "Glass = separate containers by colour", "Find collection schedule at your municipality website"],
                .dutch: ["GFT = etensresten, groente-afval, tuinafval", "PMD = plastic, blikjes, drankkartons (GEEN glas)", "Papier = schoon verpakkingsmateriaal, kranten", "Glas = aparte containers per kleur", "Inzamelschema op gemeentewebsite"],
                .russian: ["GFT = пищевые отходы, овощные, садовые", "PMD = пластик, банки, тетрапаки (НЕ стекло)", "Бумага = упаковка, газеты", "Стекло = отдельные контейнеры по цвету", "Расписание вывоза на сайте gemeente"]
            ],
            commonMistakeByLanguage: [
                .english: "Putting all waste in the residual bin (restafval). The Netherlands expects active separation.",
                .dutch: "Al het afval in de restafvalbak gooien. Nederland verwacht actieve scheiding.",
                .russian: "Выбрасывать всё в restafval. В Нидерландах ожидается активная сортировка."
            ],
            safeNextStepByLanguage: [
                .english: "Check your municipality website for the waste calendar and collection points. Download the 'Milieu Centraal' app for sorting guidance.",
                .dutch: "Controleer de afvalkalender op uw gemeentewebsite. Download de 'Milieu Centraal'-app.",
                .russian: "Проверьте сайт gemeente для расписания. Скачайте приложение 'Milieu Centraal'."
            ],
            officialSourceName: "Milieu Centraal",
            officialSourceURL: URL(string: "https://www.milieucentraal.nl"),
            keywordsByLanguage: [
                .english: ["waste", "recycling", "GFT", "PMD", "afvalscheiding", "trash", "bin"],
                .dutch: ["afvalscheiding", "GFT", "PMD", "recycling", "restafval"],
                .russian: ["мусор", "сортировка", "GFT", "PMD", "afvalscheiding", "утилизация"]
            ],
            relatedTopics: ["Waste Fines", "Gemeente", "Environmental Rules", "Recycling Points"],
            riskLevel: .low
        ),

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:how-tikkie-works"),
            category: .dailyLife,
            titleByLanguage: [
                .english: "How Tikkie Works",
                .dutch: "Hoe Tikkie werkt",
                .russian: "Как работает Tikkie"
            ],
            descriptionByLanguage: [
                .english: "Tikkie is a free Dutch mobile payment app that lets you send and receive payment requests via a link — the standard way Dutch people split bills.",
                .dutch: "Tikkie is een gratis Nederlandse betaalapp waarmee u betalingsverzoeken via een link kunt sturen — de standaardmanier voor rekening splitsen.",
                .russian: "Tikkie — бесплатное нидерландское платёжное приложение для отправки и получения запросов на оплату по ссылке."
            ],
            simpleAnswerByLanguage: [
                .english: "Create a Tikkie payment request, share the link via WhatsApp, and recipients pay directly from their Dutch bank account.",
                .dutch: "Maak een Tikkie-verzoek, deel de link via WhatsApp en ontvangers betalen direct vanuit hun bankrekening.",
                .russian: "Создайте запрос в Tikkie, поделитесь ссылкой через WhatsApp, получатели оплачивают прямо со счёта."
            ],
            whyItMattersByLanguage: [
                .english: "Splitting bills is deeply embedded in Dutch culture. Knowing Tikkie helps you navigate social payments with colleagues and friends.",
                .dutch: "Rekening splitsen is diep geworteld in de Nederlandse cultuur. Tikkie kennen helpt bij sociale betalingen.",
                .russian: "Деление счёта — часть нидерландской культуры. Tikkie помогает в социальных платежах."
            ],
            whatToCheckByLanguage: [
                .english: ["Download Tikkie app (App Store / Google Play)", "Connect your Dutch IBAN bank account", "Recipients don't need Tikkie — they pay via iDEAL link", "Free for personal use", "Legitimate links start with tikkie.me"],
                .dutch: ["Download Tikkie-app", "Koppel uw Nederlandse IBAN", "Ontvangers betalen via iDEAL-link", "Gratis voor persoonlijk gebruik", "Legitieme links beginnen met tikkie.me"],
                .russian: ["Скачайте Tikkie", "Подключите нидерландский IBAN", "Получатели платят по iDEAL-ссылке", "Бесплатно для личного использования", "Настоящие ссылки — tikkie.me"]
            ],
            commonMistakeByLanguage: [
                .english: "Confusing Tikkie links for scams. Legitimate Tikkie links start with tikkie.me. Never pay via unknown payment links.",
                .dutch: "Tikkie-links verwarren met oplichting. Legitieme links beginnen met tikkie.me. Betaal nooit via onbekende links.",
                .russian: "Путать Tikkie-ссылки с мошенничеством. Настоящие ссылки начинаются с tikkie.me."
            ],
            safeNextStepByLanguage: [
                .english: "Download Tikkie from the official app store. Connect your Dutch bank. Only pay Tikkie links starting with tikkie.me.",
                .dutch: "Download Tikkie uit de officiële app store. Koppel uw bank. Betaal alleen links die beginnen met tikkie.me.",
                .russian: "Скачайте Tikkie из официального магазина. Подключите банк. Платите только ссылкам tikkie.me."
            ],
            officialSourceName: "Tikkie.me",
            officialSourceURL: URL(string: "https://www.tikkie.me"),
            keywordsByLanguage: [
                .english: ["Tikkie", "payment", "split bill", "iDEAL", "Dutch banking", "WhatsApp payment"],
                .dutch: ["Tikkie", "betaling", "rekening splitsen", "iDEAL"],
                .russian: ["Tikkie", "платёж", "деление счёта", "iDEAL", "банк"]
            ],
            relatedTopics: ["iDEAL", "Dutch Banking", "Social Customs", "iDEAL Scams"],
            riskLevel: .low
        ),

        // MARK: - Legal Help

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:free-legal-help-in-the-netherlands"),
            category: .legalHelp,
            titleByLanguage: [
                .english: "Free Legal Help in the Netherlands",
                .dutch: "Gratis juridische hulp in Nederland",
                .russian: "Бесплатная юридическая помощь в Нидерландах"
            ],
            descriptionByLanguage: [
                .english: "Juridisch Loket (Legal Aid Desk) provides free first-line legal advice to anyone in the Netherlands, regardless of income.",
                .dutch: "Het Juridisch Loket biedt gratis eerstelijnsjuridisch advies aan iedereen in Nederland, ongeacht inkomen.",
                .russian: "Juridisch Loket (юридическая служба) предоставляет бесплатную первичную юридическую помощь всем жителям Нидерландов."
            ],
            simpleAnswerByLanguage: [
                .english: "Call 0900-8020 or visit juridischloket.nl. First consultation is free. They cover work disputes, rental problems, divorce, debt, and more.",
                .dutch: "Bel 0900-8020 of bezoek juridischloket.nl. Het eerste consult is gratis. Ze behandelen arbeidsgeschillen, huurproblemen, echtscheiding, schulden en meer.",
                .russian: "Позвоните 0900-8020 или зайдите на juridischloket.nl. Первая консультация бесплатна."
            ],
            whyItMattersByLanguage: [
                .english: "Legal issues in the Netherlands often have strict deadlines. Missing an objection (bezwaar) deadline can permanently close your case.",
                .dutch: "Juridische kwesties hebben vaak strikte deadlines. Het missen van een bezwaardeadline kan uw zaak definitief sluiten.",
                .russian: "Юридические вопросы в NL имеют строгие дедлайны. Пропуск срока возражения (bezwaar) может закрыть дело навсегда."
            ],
            whatToCheckByLanguage: [
                .english: ["Juridisch Loket: free first advice via phone/online/walk-in", "Legal aid (toevoeging) for lower incomes", "Many legal deadlines are 6 weeks — act fast", "Social counselling at municipality for benefits/debt advice"],
                .dutch: ["Juridisch Loket: gratis eerste advies via telefoon/online/inloop", "Toevoeging bij lager inkomen", "Veel juridische deadlines zijn 6 weken — snel handelen", "Sociaal Raad bij gemeente voor schuldhulpadvies"],
                .russian: ["Juridisch Loket: бесплатный первичный совет", "Toevoeging (субсидированная помощь) при низком доходе", "Многие дедлайны 6 недель — действуйте быстро", "Sociaal Raad в gemeente — помощь с долгами"]
            ],
            commonMistakeByLanguage: [
                .english: "Not seeking help because you assume it's too expensive. First-line legal advice at Juridisch Loket is completely free.",
                .dutch: "Geen hulp zoeken omdat u aanneemt dat het te duur is. Eerstelijnsjuridisch advies is volledig gratis.",
                .russian: "Не обращаться из-за предположения о высокой стоимости. Первичная помощь в Juridisch Loket полностью бесплатна."
            ],
            safeNextStepByLanguage: [
                .english: "For any legal question, call 0900-8020 or go to juridischloket.nl. Act quickly — many legal deadlines are 6 weeks.",
                .dutch: "Bel voor juridische vragen 0900-8020 of ga naar juridischloket.nl. Handel snel.",
                .russian: "При любом юридическом вопросе звоните 0900-8020 или идите на juridischloket.nl. Дедлайны 6 недель."
            ],
            officialSourceName: "Juridisch Loket",
            officialSourceURL: URL(string: "https://www.juridischloket.nl"),
            keywordsByLanguage: [
                .english: ["legal help", "juridisch loket", "free legal", "lawyer", "rights", "bezwaar"],
                .dutch: ["juridisch loket", "rechtshulp", "gratis juridisch", "bezwaar"],
                .russian: ["юридическая помощь", "juridisch loket", "бесплатная помощь", "bezwaar"]
            ],
            relatedTopics: ["Tenant Rights", "Work Disputes", "Benefits Appeals", "Bezwaar Process"],
            riskLevel: .medium
        ),

        // MARK: - Mental Health

        BeginnerGuideItem(
            id: StableRouteID.uuid("beginner-guide:mental-health-support-in-the-netherlands"),
            category: .health,
            titleByLanguage: [
                .english: "Mental Health Support in the Netherlands",
                .dutch: "Geestelijke gezondheidszorg in Nederland",
                .russian: "Психическое здоровье в Нидерландах"
            ],
            descriptionByLanguage: [
                .english: "Mental health care (GGZ) is available in the Netherlands. Access usually starts through your GP who provides a referral.",
                .dutch: "Geestelijke gezondheidszorg (GGZ) is beschikbaar in Nederland. Toegang begint via uw huisarts.",
                .russian: "Психиатрическая помощь (GGZ) доступна в Нидерландах. Доступ обычно начинается через GP."
            ],
            simpleAnswerByLanguage: [
                .english: "Talk to your GP first. For crisis support call 0800-0113 (suicide prevention, free, 24/7). GGZ waiting lists can be 6-12 months — act early.",
                .dutch: "Praat eerst met uw huisarts. Voor crisis: bel 0800-0113 (suïcidepreventie, gratis, 24/7). GGZ-wachtlijsten kunnen 6-12 maanden bedragen.",
                .russian: "Сначала обратитесь к GP. При кризисе: 0800-0113 (бесплатно, 24/7). Очереди в GGZ 6–12 месяцев — действуйте заранее."
            ],
            whyItMattersByLanguage: [
                .english: "Relocation stress, language barriers, and cultural adjustment can significantly affect mental health. Dutch healthcare includes mental health support.",
                .dutch: "Verhuisstress, taalbarrières en culturele aanpassing kunnen de geestelijke gezondheid aanzienlijk beïnvloeden.",
                .russian: "Стресс от переезда, языковой барьер и культурная адаптация существенно влияют на психическое здоровье."
            ],
            whatToCheckByLanguage: [
                .english: ["GP referral required for most GGZ services", "Basic insurance covers many GGZ treatments after eigen risico", "Crisis line: 0800-0113 (24/7 free)", "VluchtelingenWerk supports refugees", "Long waiting lists — get referral early"],
                .dutch: ["Huisartsverwijzing vereist voor GGZ", "Basisverzekering dekt GGZ na eigen risico", "Crisislijn: 0800-0113 (24/7 gratis)", "VluchtelingenWerk ondersteunt vluchtelingen", "Lange wachtlijsten — vroeg verwijzing aanvragen"],
                .russian: ["Направление GP для GGZ-услуг", "Базовая страховка покрывает GGZ", "Кризисная линия: 0800-0113 (24/7 бесплатно)", "VluchtelingenWerk поддерживает беженцев", "Длинные очереди — обращайтесь заранее"]
            ],
            commonMistakeByLanguage: [
                .english: "Waiting too long before seeking help. GGZ waiting lists can be 6-12 months, so early referral is important.",
                .dutch: "Te lang wachten. GGZ-wachtlijsten kunnen 6-12 maanden bedragen, dus vroege verwijzing is belangrijk.",
                .russian: "Слишком долго ждать. Очереди в GGZ 6–12 месяцев — важно обращаться заранее."
            ],
            safeNextStepByLanguage: [
                .english: "If you need support, talk openly to your GP. Mention cultural and language context — they can refer you to a therapist who speaks your language.",
                .dutch: "Praat open met uw huisarts. Noem culturele en taalcontext — ze kunnen u verwijzen naar een therapeut die uw taal spreekt.",
                .russian: "При необходимости поддержки открыто поговорите с GP. Упомяните культурный и языковой контекст."
            ],
            officialSourceName: "Rijksoverheid — Geestelijke gezondheidszorg",
            officialSourceURL: URL(string: "https://www.rijksoverheid.nl/onderwerpen/geestelijke-gezondheidszorg"),
            keywordsByLanguage: [
                .english: ["mental health", "GGZ", "therapy", "psychologist", "crisis", "0800-0113"],
                .dutch: ["geestelijke gezondheid", "GGZ", "therapie", "psycholoog", "crisis"],
                .russian: ["психическое здоровье", "GGZ", "терапия", "психолог", "кризис", "0800-0113"]
            ],
            relatedTopics: ["Huisarts", "Health Insurance", "Crisis Support", "VluchtelingenWerk"],
            riskLevel: .medium
        )
    ]

    static var featuredItems: [BeginnerGuideItem] {
        Array(items.prefix(6))
    }

    static func search(
        _ query: String,
        language: AppLanguage,
        category: BeginnerGuideCategory? = nil,
        activePersona: PersonaTag? = nil,
        scope: PersonaSearchScope = .currentAndUniversal
    ) -> [BeginnerGuideItem] {
        let q = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        return items.filter { item in
            guard item.isVisible(for: activePersona, scope: scope) else {
                return false
            }

            if let category, item.category != category {
                return false
            }

            if q.isEmpty {
                return true
            }

            let title = item.title(language).lowercased()
            let description = item.description(language).lowercased()
            let keywords = item.keywords(language).map { $0.lowercased() }

            return title.contains(q)
                || description.contains(q)
                || keywords.contains(where: { $0.contains(q) })
        }
    }
}
