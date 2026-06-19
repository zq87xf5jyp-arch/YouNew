import Foundation

struct StatusDirection {
    let status: UserStatus
    let title: [AppLanguage: String]
    let shortExplanation: [AppLanguage: String]
    let primaryNeeds: [[AppLanguage: String]]
    let notUsuallyNeeded: [[AppLanguage: String]]
    let firstActions: [[AppLanguage: String]]
    let documentsToCheck: [[AppLanguage: String]]
    let officialSources: [[AppLanguage: String]]
    let warnings: [[AppLanguage: String]]
    let nextScreenDestination: AppDestination

    static func forStatus(_ status: UserStatus) -> StatusDirection {
        switch status {
        case .tourist:
            return StatusDirection(
                status: .tourist,
                title: [.russian: "Временное пребывание", .english: "Temporary Stay", .dutch: "Tijdelijk verblijf"],
                shortExplanation: [
                    .russian: "Если вы приехали ненадолго, обычно важнее проверить визу, страховку, адрес проживания, транспорт и правила пребывания.",
                    .english: "If you are staying for a short period, usually the priority is visa validity, insurance, your address, transport, and stay rules.",
                    .dutch: "Als u kort verblijft, zijn visumduur, verzekering, verblijfadres, vervoer en verblijfsregels meestal het belangrijkst."
                ],
                primaryNeeds: localizedList([
                    ("срок пребывания и виза", "length of stay and visa", "verblijfsduur en visum"),
                    ("туристическая или медицинская страховка", "travel or medical insurance", "reis- of medische verzekering"),
                    ("адрес проживания или бронь", "accommodation address or booking", "verblijfsadres of boeking"),
                    ("транспорт", "transport", "vervoer"),
                    ("экстренные контакты", "emergency contacts", "noodcontacten"),
                    ("правила штрафов и писем", "fines and official letter rules", "regels voor boetes en officiële brieven")
                ]),
                notUsuallyNeeded: localizedList([
                    ("DigiD", "DigiD", "DigiD"),
                    ("BSN", "BSN", "BSN"),
                    ("регистрация в gemeente", "gemeente registration", "gemeente-registratie"),
                    ("DUO", "DUO", "DUO"),
                    ("UWV", "UWV", "UWV")
                ]),
                firstActions: localizedList([
                    ("Проверьте срок разрешённого пребывания", "Check your allowed length of stay", "Controleer uw toegestane verblijfsduur"),
                    ("Сохраните адрес проживания", "Save your accommodation address", "Bewaar uw verblijfsadres"),
                    ("Проверьте страховку", "Check your insurance", "Controleer uw verzekering"),
                    ("Узнайте, куда обращаться в экстренной ситуации", "Learn where to get emergency help", "Weet waar u terechtkunt in noodgevallen"),
                    ("Используйте только официальные сайты", "Use only official websites", "Gebruik alleen officiële websites")
                ]),
                documentsToCheck: localizedList([
                    ("паспорт и виза", "passport and visa", "paspoort en visum"),
                    ("страховой полис", "insurance policy", "verzekeringspolis"),
                    ("подтверждение адреса или брони", "address or booking confirmation", "adres- of boekingsbevestiging")
                ]),
                officialSources: localizedList([
                    ("IND", "IND", "IND"),
                    ("Government.nl", "Government.nl", "Government.nl"),
                    ("Nederlandwereldwijd", "Netherlands Worldwide", "Nederlandwereldwijd")
                ]),
                warnings: localizedList([
                    ("Не полагайтесь на случайные чаты для визовых правил.", "Do not rely on random chats for visa rules.", "Vertrouw niet op willekeurige chats voor visumregels."),
                    ("Нарушение сроков пребывания может привести к ограничениям при следующем въезде.", "Overstaying can cause restrictions for future entry.", "Te lang verblijven kan leiden tot beperkingen bij een volgende binnenkomst.")
                ]),
                nextScreenDestination: .checklistList
            )
        case .worker:
            return baseDirection(
                status: .worker,
                explanationRU: "Для работы в Нидерландах обычно важны регистрация, документы занятости, страховка и налоги.",
                explanationEN: "For work in the Netherlands, registration, employment documents, insurance, and taxes are usually key.",
                explanationNL: "Voor werken in Nederland zijn registratie, arbeidsdocumenten, verzekering en belastingen meestal cruciaal.",
                needs: [("BSN", "BSN", "BSN"), ("DigiD", "DigiD", "DigiD"), ("рабочий контракт", "work contract", "arbeidscontract"), ("loonstrook", "payslip", "loonstrook"), ("медицинская страховка", "health insurance", "zorgverzekering"), ("налоговые письма", "tax letters", "belastingbrieven"), ("регистрация в gemeente при проживании в NL", "gemeente registration if living in NL", "gemeente-registratie als u in NL woont")],
                notNeeded: [("DUO", "DUO", "DUO")],
                actions: [("Проверьте договор", "Review your contract", "Controleer uw contract"), ("Проверьте регистрацию адреса", "Verify address registration", "Controleer uw adresregistratie"), ("Настройте DigiD", "Set up DigiD", "Stel DigiD in"), ("Проверьте страховку", "Check insurance", "Controleer verzekering"), ("Сохраняйте loonstrook", "Keep your payslips", "Bewaar loonstroken")],
                docs: [("паспорт и разрешение на пребывание", "passport and residence permit", "paspoort en verblijfsdocument"), ("рабочий договор", "employment contract", "arbeidsovereenkomst"), ("loonstrook", "payslip", "loonstrook"), ("полис страховки", "insurance policy", "verzekeringspolis")],
                sources: [("UWV", "UWV", "UWV"), ("Belastingdienst", "Belastingdienst", "Belastingdienst"), ("Government.nl", "Government.nl", "Government.nl")],
                warnings: [("Не работайте без понятного договора.", "Do not work without a clear contract.", "Werk niet zonder duidelijk contract."), ("Проверяйте зарплатные документы.", "Check salary documents carefully.", "Controleer salarisdocumenten zorgvuldig."), ("Не игнорируйте письма от Belastingdienst и CJIB.", "Do not ignore letters from Belastingdienst and CJIB.", "Negeer brieven van Belastingdienst en CJIB niet.")]
            )
        case .student:
            return baseDirection(
                status: .student,
                explanationRU: "Для студентов ключевыми обычно являются учебное зачисление, жильё, страховка и правила DUO при наличии права.",
                explanationEN: "For students, enrollment, housing, insurance, and DUO rules (if eligible) are usually central.",
                explanationNL: "Voor studenten zijn inschrijving, huisvesting, verzekering en DUO-regels (indien van toepassing) meestal leidend.",
                needs: [("зачисление в учебное заведение", "university or school enrollment", "inschrijving bij onderwijsinstelling"), ("BSN при длительном пребывании", "BSN if staying longer", "BSN bij langer verblijf"), ("DUO при наличии права", "DUO if eligible", "DUO indien van toepassing"), ("медицинская страховка в зависимости от работы и статуса", "health insurance depending on work and stay", "zorgverzekering afhankelijk van werk en verblijf"), ("жильё", "housing", "huisvesting"), ("транспорт", "transport", "vervoer")],
                notNeeded: [("UWV", "UWV", "UWV"), ("рабочий договор (если не работаете)", "work contract (unless working)", "arbeidscontract (tenzij u werkt)")],
                actions: [("Проверьте регистрацию учебного заведения", "Verify school registration", "Controleer inschrijving van uw opleiding"), ("Проверьте жильё", "Check housing arrangements", "Controleer uw huisvesting"), ("Узнайте, нужна ли страховка", "Check whether insurance is required", "Controleer of verzekering nodig is"), ("Проверьте правила DUO и транспорта, если актуально", "Check DUO and transport rules if relevant", "Controleer DUO- en vervoersregels indien relevant")],
                docs: [("паспорт и виза/ВНЖ", "passport and visa/residence permit", "paspoort en visum/verblijfsdocument"), ("документ о зачислении", "proof of enrollment", "inschrijfbewijs"), ("договор аренды или общежития", "housing contract", "huur- of campuscontract")],
                sources: [("DUO", "DUO", "DUO"), ("IND", "IND", "IND"), ("Government.nl", "Government.nl", "Government.nl")],
                warnings: [("Проверяйте дедлайны учебного заведения и DUO.", "Track university and DUO deadlines.", "Let op deadlines van opleiding en DUO.")]
            )
        case .expat:
            return baseDirection(
                status: .expat,
                explanationRU: "Для экспатов обычно важны регистрация, документы от работодателя, налоги и страховка.",
                explanationEN: "For expats, registration, employer documents, taxes, and insurance are usually core.",
                explanationNL: "Voor expats zijn registratie, werkgeversdocumenten, belastingen en verzekering meestal de kern.",
                needs: [("BSN", "BSN", "BSN"), ("DigiD", "DigiD", "DigiD"), ("документы о работе и проживании", "employment and residence documents", "werk- en verblijfsdocumenten"), ("налоги", "taxes", "belastingen"), ("медицинская страховка", "health insurance", "zorgverzekering"), ("договор жилья", "housing contract", "huurcontract"), ("информация о 30%-regeling при применимости", "30% ruling information if applicable", "informatie over 30%-regeling indien van toepassing")],
                notNeeded: [("DUO", "DUO", "DUO")],
                actions: [("Проверьте регистрацию адреса", "Verify address registration", "Controleer uw adresregistratie"), ("Проверьте документы от работодателя", "Review employer documents", "Controleer werkgeversdocumenten"), ("Настройте DigiD", "Set up DigiD", "Stel DigiD in"), ("Проверьте налоговые вопросы", "Review tax topics", "Controleer belastingzaken"), ("Оформите страховку", "Arrange insurance", "Regel verzekering")],
                docs: [("договор оффера/контракт", "offer letter/contract", "aanbiedingsbrief/contract"), ("разрешение на проживание", "residence permit", "verblijfsvergunning"), ("договор аренды", "rental agreement", "huurovereenkomst")],
                sources: [("Belastingdienst", "Belastingdienst", "Belastingdienst"), ("IND", "IND", "IND"), ("Government.nl", "Government.nl", "Government.nl")],
                warnings: [("Проверяйте сроки подачи налоговых и миграционных документов.", "Watch tax and immigration deadlines.", "Let op belasting- en immigratiedeadlines.")]
            )
        case .highlySkilledMigrant:
            return baseDirection(
                status: .highlySkilledMigrant,
                explanationRU: "Для highly skilled migrant обычно важны IND, признанный спонсор, регистрация, налоги, страховка и жильё.",
                explanationEN: "For highly skilled migrants, IND, the recognized sponsor, registration, taxes, insurance, and housing are usually core.",
                explanationNL: "Voor kennismigranten zijn IND, erkend referent, registratie, belastingen, verzekering en wonen meestal de kern.",
                needs: [("IND и признанный спонсор", "IND and recognized sponsor", "IND en erkend referent"), ("BSN", "BSN", "BSN"), ("DigiD", "DigiD", "DigiD"), ("зарплата и 30%-regeling", "salary and 30% ruling", "salaris en 30%-regeling"), ("медицинская страховка", "health insurance", "zorgverzekering"), ("жильё", "housing", "wonen"), ("семья при переезде вместе", "family relocation if relevant", "gezinsverhuizing indien relevant")],
                notNeeded: [("DUO", "DUO", "DUO"), ("пособия для беженцев", "refugee benefits", "vluchtelingenvoorzieningen")],
                actions: [("Проверьте маршрут IND и спонсора", "Check IND and sponsor route", "Controleer IND- en referentroute"), ("Зарегистрируйтесь в gemeente", "Register with the municipality", "Schrijf u in bij de gemeente"), ("Настройте DigiD", "Set up DigiD", "Stel DigiD in"), ("Проверьте 30%-regeling и налоги", "Review 30% ruling and taxes", "Controleer 30%-regeling en belasting"), ("Оформите страховку", "Arrange insurance", "Regel verzekering")],
                docs: [("документы работодателя/спонсора", "employer/sponsor documents", "documenten werkgever/referent"), ("паспорт и разрешение на проживание", "passport and residence permit", "paspoort en verblijfsdocument"), ("договор аренды", "rental contract", "huurcontract")],
                sources: [("IND", "IND", "IND"), ("Belastingdienst", "Belastingdienst", "Belastingdienst"), ("Government.nl", "Government.nl", "Government.nl")],
                warnings: [("Проверяйте сроки IND, спонсора и налогов.", "Watch IND, sponsor, and tax deadlines.", "Let op IND-, referent- en belastingdeadlines.")]
            )
        case .euCitizen:
            return baseDirection(
                status: .euCitizen,
                explanationRU: "Для граждан ЕС обычно важны регистрация, BSN, DigiD, работа, медицина, жильё и налоги.",
                explanationEN: "For EU citizens, registration, BSN, DigiD, work rights, healthcare, housing, and taxes are usually central.",
                explanationNL: "Voor EU-burgers zijn registratie, BSN, DigiD, werkrechten, zorg, wonen en belastingen meestal leidend.",
                needs: [("регистрация в gemeente", "municipality registration", "gemeentelijke registratie"), ("BSN", "BSN", "BSN"), ("DigiD", "DigiD", "DigiD"), ("права на работу", "work rights", "werkrechten"), ("медицинская страховка", "health insurance", "zorgverzekering"), ("жильё", "housing", "wonen"), ("налоги", "taxes", "belastingen")],
                notNeeded: [("IND residence permit by default", "IND residence permit by default", "IND-verblijfsvergunning standaard"), ("DUO unless studying", "DUO unless studying", "DUO tenzij u studeert")],
                actions: [("Проверьте регистрацию", "Check registration", "Controleer registratie"), ("Получите BSN", "Get BSN", "Regel BSN"), ("Настройте DigiD", "Set up DigiD", "Stel DigiD in"), ("Проверьте страховку", "Check insurance", "Controleer verzekering"), ("Проверьте налоговые основы", "Review tax basics", "Controleer belastingbasis")],
                docs: [("паспорт/ID ЕС", "EU passport/ID", "EU-paspoort/ID"), ("документы адреса", "address documents", "adresdocumenten"), ("рабочие документы при наличии работы", "work documents if employed", "werkdocumenten indien werkzaam")],
                sources: [("Gemeente", "Municipality", "Gemeente"), ("Belastingdienst", "Belastingdienst", "Belastingdienst"), ("Government.nl", "Government.nl", "Government.nl")],
                warnings: [("Не начинайте с IND, если вопрос не связан с не-ЕС членами семьи или особым разрешением.", "Do not start with IND unless non-EU family or special permit context applies.", "Begin niet met IND tenzij niet-EU gezinsleden of bijzondere vergunningen spelen.")]
            )
        case .refugee:
            return baseDirection(
                status: .refugee,
                explanationRU: "При статусе беженца или статус-холдера обычно в приоритете документы статуса, gemeente, страховка и интеграция.",
                explanationEN: "For refugees/status holders, status documents, gemeente processes, insurance, and integration are usually priority.",
                explanationNL: "Voor vluchtelingen/statushouders zijn statusdocumenten, gemeentezaken, verzekering en inburgering meestal prioriteit.",
                needs: [("документы о статусе и проживании", "status and residence documents", "status- en verblijfsdocumenten"), ("gemeente", "gemeente", "gemeente"), ("медицинская страховка", "health insurance", "zorgverzekering"), ("интеграция / inburgering", "integration / inburgering", "integratie / inburgering"), ("пособия / toeslagen при применимости", "benefits/toeslagen if relevant", "toeslagen indien relevant"), ("юридическая помощь и поддерживающие организации", "legal help and support organizations", "juridische hulp en ondersteunende organisaties")],
                notNeeded: [("30%-regeling", "30% ruling", "30%-regeling")],
                actions: [("Проверьте документы о статусе", "Check status documents", "Controleer statusdocumenten"), ("Узнайте, какая gemeente отвечает за ваш адрес", "Confirm your responsible gemeente", "Controleer welke gemeente voor uw adres verantwoordelijk is"), ("Проверьте медицинскую страховку", "Check health insurance", "Controleer zorgverzekering"), ("Сохраняйте письма от официальных органов", "Keep official letters", "Bewaar officiële brieven"), ("Не пропускайте сроки", "Do not miss deadlines", "Mis geen deadlines")],
                docs: [("решение о статусе", "status decision documents", "statusbesluit"), ("документы IND", "IND documents", "IND-documenten"), ("документы gemeente", "gemeente documents", "gemeentedocumenten")],
                sources: [("COA", "COA", "COA"), ("IND", "IND", "IND"), ("Juridisch Loket", "Juridisch Loket", "Juridisch Loket")],
                warnings: [("Не пропускайте письма и назначенные встречи.", "Do not miss official letters or appointments.", "Mis geen officiële brieven of afspraken.")]
            )
        case .ukrainian:
            return baseDirection(
                status: .ukrainian,
                explanationRU: "Для граждан Украины при временной защите обычно важны регистрация, документы защиты, жильё, работа и медицина.",
                explanationEN: "For Ukrainians under temporary protection, registration, protection documents, housing, work rules, and healthcare are usually key.",
                explanationNL: "Voor Oekraïners onder tijdelijke bescherming zijn registratie, beschermingsdocumenten, huisvesting, werkregels en zorg meestal belangrijk.",
                needs: [("временная защита и регистрация", "temporary protection and registration", "tijdelijke bescherming en registratie"), ("gemeente", "gemeente", "gemeente"), ("BSN при применимости", "BSN if applicable", "BSN indien van toepassing"), ("правила права на работу", "work rights information", "informatie over arbeidsrechten"), ("жильё", "housing", "huisvesting"), ("медицинская помощь", "healthcare", "zorg"), ("школа и дети при необходимости", "school/children if relevant", "school/kinderen indien relevant")],
                notNeeded: [("30%-regeling", "30% ruling", "30%-regeling")],
                actions: [("Проверьте регистрацию в gemeente", "Check gemeente registration", "Controleer gemeente-registratie"), ("Проверьте документы временной защиты", "Check temporary protection documents", "Controleer documenten tijdelijke bescherming"), ("Проверьте страховку и медицинскую помощь", "Check insurance/healthcare access", "Controleer verzekering en toegang tot zorg"), ("Узнайте правила работы", "Review work rules", "Controleer werkregels"), ("Сохраняйте официальные письма", "Keep official letters", "Bewaar officiële brieven")],
                docs: [("паспорт", "passport", "paspoort"), ("документы временной защиты", "temporary protection documents", "documenten tijdelijke bescherming"), ("подтверждение адреса", "address confirmation", "adresbevestiging")],
                sources: [("Rijksoverheid", "Government.nl", "Rijksoverheid"), ("IND", "IND", "IND"), ("Gemeente", "Municipality", "Gemeente")],
                warnings: [("Проверяйте обновления правил временной защиты на официальных сайтах.", "Check official updates for temporary protection rules.", "Controleer officiële updates voor regels tijdelijke bescherming.")]
            )
        case .family:
            return baseDirection(
                status: .family,
                explanationRU: "Для семьи обычно важны регистрация адреса, вопросы детей, страховка и семейные выплаты.",
                explanationEN: "For families, address registration, children’s setup, insurance, and benefits are often the main priorities.",
                explanationNL: "Voor gezinnen zijn adresregistratie, zaken rond kinderen, verzekering en toeslagen vaak de hoofdprioriteiten.",
                needs: [("регистрация адреса", "address registration", "adresregistratie"), ("школа или daycare", "school/daycare", "school of opvang"), ("медицинская страховка", "health insurance", "zorgverzekering"), ("пособия / toeslagen при применимости", "benefits/toeslagen if applicable", "toeslagen indien van toepassing"), ("семейные документы", "family documents", "gezinsdocumenten"), ("gemeente", "gemeente", "gemeente")],
                notNeeded: [("UWV (если никто не ищет работу)", "UWV (unless someone is job-seeking)", "UWV (tenzij iemand werk zoekt)")],
                actions: [("Проверьте регистрацию адреса", "Check address registration", "Controleer adresregistratie"), ("Проверьте школу или daycare", "Arrange school or daycare", "Regel school of opvang"), ("Проверьте страховку", "Check insurance", "Controleer verzekering"), ("Узнайте про toeslagen при применимости", "Review toeslagen eligibility if applicable", "Controleer toeslagen indien van toepassing"), ("Сохраняйте документы детей", "Keep children’s documents organized", "Bewaar documenten van kinderen")],
                docs: [("свидетельства о рождении/семейные документы", "birth/family documents", "geboorte- en gezinsdocumenten"), ("документы адреса", "address documents", "adresdocumenten"), ("страховые полисы", "insurance policies", "verzekeringspolissen")],
                sources: [("Gemeente", "Municipality", "Gemeente"), ("Toeslagen", "Toeslagen", "Toeslagen"), ("Government.nl", "Government.nl", "Government.nl")],
                warnings: [("Следите за сроками документов по детям и школе.", "Track deadlines for children and school paperwork.", "Let op deadlines voor school- en kinddocumenten.")]
            )
        case .entrepreneur:
            return baseDirection(
                status: .entrepreneur,
                explanationRU: "Для предпринимателя обычно важны KvK, BTW/VAT, налоги, банк, страховка, разрешения и договоры.",
                explanationEN: "For entrepreneurs, KvK, VAT/BTW, taxes, banking, insurance, permits, and contracts are usually central.",
                explanationNL: "Voor ondernemers zijn KvK, BTW, belastingen, bankzaken, verzekering, vergunningen en contracten meestal leidend.",
                needs: [("KvK", "KvK", "KvK"), ("BTW/VAT", "VAT/BTW", "BTW"), ("налоги", "taxes", "belastingen"), ("банковский счёт", "bank account", "bankrekening"), ("страховка", "insurance", "verzekering"), ("разрешения", "permits", "vergunningen"), ("договоры", "contracts", "contracten")],
                notNeeded: [("DUO", "DUO", "DUO"), ("UWV employee path", "UWV employee path", "UWV-werknemerspad")],
                actions: [("Подготовьте регистрацию KvK", "Prepare KvK registration", "Bereid KvK-registratie voor"), ("Проверьте BTW/VAT", "Check VAT/BTW", "Controleer BTW"), ("Проверьте налоги", "Review taxes", "Controleer belastingen"), ("Настройте банк и страховку", "Set up banking and insurance", "Regel bankzaken en verzekering"), ("Проверьте разрешения", "Check permits", "Controleer vergunningen")],
                docs: [("ID", "ID", "ID"), ("бизнес-данные", "business details", "bedrijfsgegevens"), ("адрес регистрации", "registration address", "registratieadres")],
                sources: [("KvK", "KvK", "KvK"), ("Belastingdienst", "Belastingdienst", "Belastingdienst"), ("Gemeente", "Municipality", "Gemeente")],
                warnings: [("Проверьте налоговые обязанности до выставления счетов.", "Check tax obligations before invoicing.", "Controleer belastingplichten voordat u factureert.")]
            )
        case .lgbtNewcomer:
            return baseDirection(
                status: .lgbtNewcomer,
                explanationRU: "Для LGBT newcomer в приоритете безопасность, права, медицина, психическое здоровье, сообщество и юридическая поддержка.",
                explanationEN: "For LGBT newcomers, safety, rights, healthcare, mental health, community, and legal support are the priorities.",
                explanationNL: "Voor LHBTI-nieuwkomers staan veiligheid, rechten, zorg, mentale gezondheid, gemeenschap en juridische hulp centraal.",
                needs: [("безопасная поддержка", "safe support", "veilige steun"), ("права", "rights", "rechten"), ("медицина", "healthcare", "zorg"), ("психическое здоровье", "mental health", "mentale gezondheid"), ("сообщество", "community", "gemeenschap"), ("юридическая помощь", "legal support", "juridische hulp"), ("безопасность жилья", "housing safety", "woonveiligheid")],
                notNeeded: [("irrelevant bureaucracy first", "irrelevant bureaucracy first", "irrelevante bureaucratie als eerste stap")],
                actions: [("Найдите безопасную поддержку", "Find safe support", "Vind veilige steun"), ("Проверьте медицину и mental health", "Check healthcare and mental health support", "Controleer zorg en mentale ondersteuning"), ("Проверьте права и legal help", "Check rights and legal help", "Controleer rechten en juridische hulp"), ("Найдите сообщество", "Find community", "Vind gemeenschap")],
                docs: [("важные письма", "important letters", "belangrijke brieven"), ("документы адреса при вопросах жилья", "address documents for housing questions", "adresdocumenten bij woonvragen")],
                sources: [("Juridisch Loket", "Juridisch Loket", "Juridisch Loket"), ("Gemeente", "Municipality", "Gemeente"), ("Support organizations", "Support organizations", "Ondersteunende organisaties")],
                warnings: [("Не вводите чувствительные личные данные в AI-запрос.", "Do not enter sensitive personal details in an AI question.", "Voer geen gevoelige persoonsgegevens in een AI-vraag in.")]
            )
        }
    }

    private static func baseDirection(
        status: UserStatus,
        explanationRU: String,
        explanationEN: String,
        explanationNL: String,
        needs: [(String, String, String)],
        notNeeded: [(String, String, String)],
        actions: [(String, String, String)],
        docs: [(String, String, String)],
        sources: [(String, String, String)],
        warnings: [(String, String, String)]
    ) -> StatusDirection {
        StatusDirection(
            status: status,
            title: [.russian: status.localized(.russian), .english: status.localized(.english), .dutch: status.localized(.dutch)],
            shortExplanation: [.russian: explanationRU, .english: explanationEN, .dutch: explanationNL],
            primaryNeeds: localizedList(needs),
            notUsuallyNeeded: localizedList(notNeeded),
            firstActions: localizedList(actions),
            documentsToCheck: localizedList(docs),
            officialSources: localizedList(sources),
            warnings: localizedList(warnings),
            nextScreenDestination: .checklistList
        )
    }

    private static func localizedList(_ items: [(String, String, String)]) -> [[AppLanguage: String]] {
        items.map { [.russian: $0.0, .english: $0.1, .dutch: $0.2] }
    }
}
