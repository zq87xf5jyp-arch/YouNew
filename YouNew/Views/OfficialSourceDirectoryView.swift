import SwiftUI

private struct OfficialSourceItem: Identifiable {
    let id = UUID()
    let name: String
    let handlesByLanguage: [AppLanguage: String]
    let whenNeededByLanguage: [AppLanguage: String]
    let officialURL: URL
    let scamWarningByLanguage: [AppLanguage: String]
    var personaTags: Set<PersonaTag> {
        let lowerName = name.lowercased()
        if lowerName.contains("ind") {
            return [.refugee, .nonEU, .highlySkilledMigrant]
        }
        if lowerName.contains("duo") {
            return [.student, .refugee, .family]
        }
        if lowerName.contains("uwv") {
            return [.worker, .refugee]
        }
        if lowerName.contains("belastingdienst") {
            return [.worker, .family, .eu, .highlySkilledMigrant, .entrepreneur]
        }
        if lowerName.contains("toeslagen") {
            return [.worker, .refugee, .family]
        }
        if lowerName.contains("svb") {
            return [.family]
        }
        if lowerName.contains("rdw") || lowerName.contains("cjib") {
            return [.worker, .tourist, .eu, .highlySkilledMigrant, .entrepreneur]
        }
        if lowerName.contains("juridisch") || lowerName.contains("rechtspraak") {
            return [.worker, .refugee, .family, .entrepreneur, .lgbt]
        }
        if lowerName.contains("rijksoverheid") || lowerName.contains("government.nl") || lowerName.contains("112") {
            return [.universal]
        }
        return PersonaContentPolicy.assignedTags(
            category: "Official Source",
            title: name,
            summary: "\(handlesByLanguage[.english] ?? "") \(whenNeededByLanguage[.english] ?? "")",
            keywords: [name, officialURL.host ?? ""],
            sources: [OfficialSource(title: name, url: officialURL, institution: name)]
        )
    }

    func handles(_ lang: AppLanguage) -> String {
        handlesByLanguage[lang] ?? handlesByLanguage[.english] ?? "—"
    }
    func whenNeeded(_ lang: AppLanguage) -> String {
        whenNeededByLanguage[lang] ?? whenNeededByLanguage[.english] ?? "—"
    }
    func scamWarning(_ lang: AppLanguage) -> String {
        scamWarningByLanguage[lang] ?? scamWarningByLanguage[.english] ?? "—"
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}

private enum OfficialSourceSection: String, CaseIterable, Identifiable {
    case government
    case municipalities
    case healthcare
    case transport
    case identity
    case housing
    case cultureHistory
    case mediaLicenses

    var id: String { rawValue }

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.government, .russian): return "Государство"
        case (.government, .dutch): return "Overheid"
        case (.government, _): return "Government"
        case (.municipalities, .russian): return "Муниципалитеты"
        case (.municipalities, .dutch): return "Gemeenten"
        case (.municipalities, _): return "Municipalities"
        case (.healthcare, .russian): return "Здравоохранение"
        case (.healthcare, .dutch): return "Zorg"
        case (.healthcare, _): return "Healthcare"
        case (.transport, .russian): return "Транспорт"
        case (.transport, .dutch): return "Vervoer"
        case (.transport, _): return "Transport"
        case (.identity, .russian): return "Документы и DigiD"
        case (.identity, .dutch): return "Documenten en DigiD"
        case (.identity, _): return "Identity & DigiD"
        case (.housing, .russian): return "Жильё"
        case (.housing, .dutch): return "Wonen"
        case (.housing, _): return "Housing"
        case (.cultureHistory, .russian): return "Культура и история"
        case (.cultureHistory, .dutch): return "Cultuur en geschiedenis"
        case (.cultureHistory, _): return "Culture & history"
        case (.mediaLicenses, .russian): return "Медиа и лицензии"
        case (.mediaLicenses, .dutch): return "Media en licenties"
        case (.mediaLicenses, _): return "Media and licenses"
        }
    }

    var icon: String {
        switch self {
        case .government: return "building.columns.fill"
        case .municipalities: return "building.2.fill"
        case .healthcare: return "cross.case.fill"
        case .transport: return "tram.fill"
        case .identity: return "person.text.rectangle.fill"
        case .housing: return "house.fill"
        case .cultureHistory: return "photo.on.rectangle.angled"
        case .mediaLicenses: return "play.rectangle.on.rectangle.fill"
        }
    }

    var accent: Color {
        switch self {
        case .government, .municipalities, .identity:
            return AppColors.success
        case .healthcare:
            return AppColors.error
        case .transport:
            return AppColors.routeLine
        case .housing:
            return AppColors.cyanGlow
        case .cultureHistory, .mediaLicenses:
            return AppColors.dutchOrange
        }
    }
}

struct OfficialSourceDirectoryView: View {
    @State private var searchText = ""
    @State private var selectedSection: OfficialSourceSection? = nil
    @State private var selectedSource: OfficialSourceItem? = nil
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

    private var allSources: [OfficialSourceItem] = [
        OfficialSourceItem(
            name: "IND — Immigration and Naturalisation Service",
            handlesByLanguage: [
                .english: "Residence permits, MVV visas, nationality, asylum procedures.",
                .dutch:   "Verblijfsvergunningen, MVV-visa, nationaliteit, asielprocedures.",
                .russian: "Разрешения на проживание, визы MVV, гражданство, процедуры предоставления убежища."
            ],
            whenNeededByLanguage: [
                .english: "When applying for or renewing a residence permit, checking permit conditions, or navigating immigration procedures.",
                .dutch:   "Bij het aanvragen of verlengen van een verblijfsvergunning, controleren van vergunningsvoorwaarden of navigeren door immigratieprocedures.",
                .russian: "При подаче заявления на разрешение на проживание, проверке условий разрешения или навигации в иммиграционных процедурах."
            ],
            officialURL: AppURL.make("https://ind.nl/en"),
            scamWarningByLanguage: [
                .english: "Only use ind.nl. Third-party 'permit helpers' may not be authorised agents.",
                .dutch:   "Gebruik alleen ind.nl. Externe 'vergunninghelpers' zijn mogelijk geen geautoriseerde agenten.",
                .russian: "Используйте только ind.nl. Сторонние «помощники по разрешениям» могут не быть уполномоченными агентами."
            ]
        ),
        OfficialSourceItem(
            name: "DUO — Education Executive Agency",
            handlesByLanguage: [
                .english: "Student finance, inburgering administration, education records.",
                .dutch:   "Studiefinanciering, inburgeringsadministratie, onderwijsdossiers.",
                .russian: "Студенческие финансы, администрирование интеграции (inburgering), образовательные записи."
            ],
            whenNeededByLanguage: [
                .english: "When applying for studiefinanciering, managing inburgering obligations, or accessing education records.",
                .dutch:   "Bij het aanvragen van studiefinanciering, beheren van inburgeringsverplichtingen of inzien van onderwijsdossiers.",
                .russian: "При подаче заявления на studiefinanciering, управлении обязательствами по inburgering или доступе к образовательным записям."
            ],
            officialURL: AppURL.make("https://duo.nl"),
            scamWarningByLanguage: [
                .english: "Only use duo.nl. Do not share DigiD credentials with any third-party study finance helpers.",
                .dutch:   "Gebruik alleen duo.nl. Deel geen DigiD-gegevens met externe studiefinancieringshelpers.",
                .russian: "Используйте только duo.nl. Не сообщайте данные DigiD сторонним помощникам по студенческим финансам."
            ]
        ),
        OfficialSourceItem(
            name: "UWV — Employee Insurance Agency",
            handlesByLanguage: [
                .english: "Unemployment benefits (WW), sickness benefits, work disability, employer payroll information.",
                .dutch:   "Werkloosheidsuitkering (WW), ziektegeld, arbeidsongeschiktheid, salarisgegevens werkgever.",
                .russian: "Пособия по безработице (WW), больничные пособия, инвалидность по труду, информация о заработной плате работодателя."
            ],
            whenNeededByLanguage: [
                .english: "When you lose your job, become ill and unable to work, or need information about work-related benefits.",
                .dutch:   "Als je je baan verliest, ziek wordt en niet kunt werken, of informatie nodig hebt over werkgerelateerde uitkeringen.",
                .russian: "Когда вы потеряли работу, не можете работать из-за болезни, или вам нужна информация о пособиях."
            ],
            officialURL: AppURL.make("https://www.uwv.nl"),
            scamWarningByLanguage: [
                .english: "Only use uwv.nl. Unsolicited calls claiming to help with UWV benefits may be scams.",
                .dutch:   "Gebruik alleen uwv.nl. Ongevraagde telefoontjes die hulp bij UWV-uitkeringen aanbieden, kunnen oplichterij zijn.",
                .russian: "Используйте только uwv.nl. Нежелательные звонки с предложением помочь с пособиями UWV могут быть мошенничеством."
            ]
        ),
        OfficialSourceItem(
            name: "Belastingdienst — Dutch Tax Administration",
            handlesByLanguage: [
                .english: "Income tax, VAT, wage tax, and allowance debt recovery.",
                .dutch:   "Inkomstenbelasting, btw, loonheffing en terugvordering toeslagschulden.",
                .russian: "Подоходный налог, НДС, налог на заработную плату и взыскание задолженности по пособиям."
            ],
            whenNeededByLanguage: [
                .english: "When filing income tax, receiving tax assessments, understanding wage tax, or checking overpayments.",
                .dutch:   "Bij het indienen van de aangifte, ontvangen van aanslagen, begrijpen van loonheffing of controleren van terugvorderingen.",
                .russian: "При подаче налоговой декларации, получении налоговых уведомлений, понимании налога на зарплату или проверке переплат."
            ],
            officialURL: AppURL.make("https://www.belastingdienst.nl"),
            scamWarningByLanguage: [
                .english: "Belastingdienst does not request urgent payment via SMS links. Verify messages at belastingdienst.nl.",
                .dutch:   "Belastingdienst vraagt niet om urgente betaling via sms-links. Verifieer berichten op belastingdienst.nl.",
                .russian: "Belastingdienst не запрашивает срочную оплату через SMS-ссылки. Проверяйте сообщения на belastingdienst.nl."
            ]
        ),
        OfficialSourceItem(
            name: "Toeslagen — Allowances Office",
            handlesByLanguage: [
                .english: "Huurtoeslag, zorgtoeslag, kinderopvangtoeslag, and other income-dependent allowances.",
                .dutch:   "Huurtoeslag, zorgtoeslag, kinderopvangtoeslag en andere inkomensafhankelijke toeslagen.",
                .russian: "Huurtoeslag, zorgtoeslag, kinderopvangtoeslag и другие пособия в зависимости от дохода."
            ],
            whenNeededByLanguage: [
                .english: "When applying for allowances, reporting income changes, or understanding overpayment reclaims.",
                .dutch:   "Bij het aanvragen van toeslagen, melden van inkomstenwijzigingen of begrijpen van terugvorderingen.",
                .russian: "При подаче заявления на пособия, сообщении об изменении дохода или понимании требований о возврате переплаты."
            ],
            officialURL: AppURL.make("https://www.toeslagen.nl"),
            scamWarningByLanguage: [
                .english: "Only use toeslagen.nl. Fake portals may harvest your DigiD details.",
                .dutch:   "Gebruik alleen toeslagen.nl. Nepsites kunnen uw DigiD-gegevens stelen.",
                .russian: "Используйте только toeslagen.nl. Поддельные порталы могут похищать данные DigiD."
            ]
        ),
        OfficialSourceItem(
            name: "DigiD — Digital Identity",
            handlesByLanguage: [
                .english: "Secure digital login for government portals.",
                .dutch:   "Veilig digitaal inloggen voor overheidsportalen.",
                .russian: "Безопасный цифровой вход для государственных порталов."
            ],
            whenNeededByLanguage: [
                .english: "To access MijnBelastingdienst, MijnOverheid, UWV portals, DUO, healthcare portals, and hundreds of other services.",
                .dutch:   "Voor toegang tot MijnBelastingdienst, MijnOverheid, UWV-portalen, DUO, zorgportalen en honderden andere diensten.",
                .russian: "Для доступа к MijnBelastingdienst, MijnOverheid, порталам UWV, DUO, медицинским порталам и сотням других сервисов."
            ],
            officialURL: AppURL.make("https://www.digid.nl/en"),
            scamWarningByLanguage: [
                .english: "Only access DigiD at digid.nl. DigiD never asks for your password via SMS or email.",
                .dutch:   "Ga alleen naar DigiD via digid.nl. DigiD vraagt nooit om uw wachtwoord via sms of e-mail.",
                .russian: "Заходите в DigiD только через digid.nl. DigiD никогда не запрашивает ваш пароль по SMS или электронной почте."
            ]
        ),
        OfficialSourceItem(
            name: "CJIB — Central Fine Collection Agency",
            handlesByLanguage: [
                .english: "Collection of traffic fines, parking fines, and other administrative payment notices.",
                .dutch:   "Inning van verkeersboetes, parkeerboetes en andere administratieve betalingskennisgevingen.",
                .russian: "Взыскание штрафов за нарушения ПДД, штрафов за парковку и других административных платёжных уведомлений."
            ],
            whenNeededByLanguage: [
                .english: "When you receive a traffic or parking fine, or any official CJIB payment notice.",
                .dutch:   "Als je een verkeers- of parkeerboete ontvangt, of een officiële CJIB-betalingskennisgeving.",
                .russian: "Когда вы получили штраф за нарушение ПДД или парковку, или любое официальное платёжное уведомление CJIB."
            ],
            officialURL: AppURL.make("https://www.cjib.nl/en"),
            scamWarningByLanguage: [
                .english: "Only pay via references in your official CJIB letter. Fake payment links may impersonate CJIB.",
                .dutch:   "Betaal alleen via de referentie in uw officiële CJIB-brief. Valse betaallinks kunnen CJIB nabootsen.",
                .russian: "Оплачивайте только по реквизитам из официального письма CJIB. Поддельные ссылки для оплаты могут имитировать CJIB."
            ]
        ),
        OfficialSourceItem(
            name: "RDW — Vehicle Authority",
            handlesByLanguage: [
                .english: "Vehicle registration, driving licences, APK inspection, import rules.",
                .dutch:   "Voertuigregistratie, rijbewijzen, APK-keuring, invoerregels.",
                .russian: "Регистрация транспортных средств, водительские удостоверения, технический осмотр APK, правила ввоза."
            ],
            whenNeededByLanguage: [
                .english: "When importing or registering a vehicle, exchanging a foreign driving licence, or checking APK validity.",
                .dutch:   "Bij het invoeren of registreren van een voertuig, omwisselen van een buitenlands rijbewijs of controleren van de APK-geldigheid.",
                .russian: "При ввозе или регистрации транспортного средства, обмене иностранных прав или проверке действительности APK."
            ],
            officialURL: AppURL.make("https://www.rdw.nl/en"),
            scamWarningByLanguage: [
                .english: "Only use rdw.nl for official registration information.",
                .dutch:   "Gebruik alleen rdw.nl voor officiële registratie-informatie.",
                .russian: "Используйте только rdw.nl для официальной информации о регистрации."
            ]
        ),
        OfficialSourceItem(
            name: "Rijksoverheid — Dutch Central Government",
            handlesByLanguage: [
                .english: "Official central government information across all topics.",
                .dutch:   "Officiële centrale overheidsinformatie over alle onderwerpen.",
                .russian: "Официальная информация центрального правительства по всем темам."
            ],
            whenNeededByLanguage: [
                .english: "For authoritative general information about Dutch laws, policies, and official processes.",
                .dutch:   "Voor gezaghebbende algemene informatie over Nederlandse wetten, beleid en officiële processen.",
                .russian: "Для авторитетной общей информации о голландских законах, политиках и официальных процессах."
            ],
            officialURL: AppURL.make("https://www.rijksoverheid.nl"),
            scamWarningByLanguage: [
                .english: "Verify the domain is rijksoverheid.nl or government.nl before relying on information.",
                .dutch:   "Controleer of het domein rijksoverheid.nl of government.nl is voordat u op de informatie vertrouwt.",
                .russian: "Проверяйте, что домен — rijksoverheid.nl или government.nl, прежде чем полагаться на информацию."
            ]
        ),
        OfficialSourceItem(
            name: "Government.nl — English Language Portal",
            handlesByLanguage: [
                .english: "Official Dutch government information in English.",
                .dutch:   "Officiële Nederlandse overheidsinformatie in het Engels.",
                .russian: "Официальная информация правительства Нидерландов на английском языке."
            ],
            whenNeededByLanguage: [
                .english: "When looking for official guidance in English on topics such as health insurance, immigration, and registration.",
                .dutch:   "Voor officiële informatie in het Engels over onderwerpen zoals zorgverzekering, immigratie en registratie.",
                .russian: "При поиске официальных инструкций на английском языке по темам медицинского страхования, иммиграции и регистрации."
            ],
            officialURL: AppURL.make("https://www.government.nl"),
            scamWarningByLanguage: [
                .english: "Verify the domain is government.nl.",
                .dutch:   "Controleer of het domein government.nl is.",
                .russian: "Проверяйте, что домен — government.nl."
            ]
        ),
        OfficialSourceItem(
            name: "Juridisch Loket — Legal Services Counter",
            handlesByLanguage: [
                .english: "Free first-line legal information for residents, referrals to legal aid.",
                .dutch:   "Gratis eerstelijns juridische informatie voor bewoners, doorverwijzingen naar rechtshulp.",
                .russian: "Бесплатная первичная юридическая информация для жителей, направление к юридической помощи."
            ],
            whenNeededByLanguage: [
                .english: "When you need general legal orientation, help understanding a letter, or a referral to subsidised legal help.",
                .dutch:   "Als je algemene juridische oriëntatie nodig hebt, hulp bij het begrijpen van een brief, of een verwijzing naar gesubsidieerde rechtshulp.",
                .russian: "Когда вам нужна общая юридическая ориентация, помощь в понимании письма или направление к субсидированной юридической помощи."
            ],
            officialURL: AppURL.make("https://www.juridischloket.nl"),
            scamWarningByLanguage: [
                .english: "Juridisch Loket is a free public service. You should not pay for its basic advice.",
                .dutch:   "Juridisch Loket is een gratis openbare dienst. U hoeft niet te betalen voor het basisadvies.",
                .russian: "Juridisch Loket — бесплатная государственная служба. Вы не должны платить за базовые консультации."
            ]
        ),
        OfficialSourceItem(
            name: "Rechtspraak.nl — Dutch Court System",
            handlesByLanguage: [
                .english: "Court information, judgment records, court procedures.",
                .dutch:   "Rechtbankinformatie, vonnisregisters, gerechtelijke procedures.",
                .russian: "Информация о судах, записи решений, судебные процедуры."
            ],
            whenNeededByLanguage: [
                .english: "When you need information about a court procedure, or have received a summons or judgment.",
                .dutch:   "Als je informatie nodig hebt over een gerechtelijke procedure, of een dagvaarding of vonnis hebt ontvangen.",
                .russian: "Когда вам нужна информация о судебном процессе, или вы получили повестку или решение суда."
            ],
            officialURL: AppURL.make("https://www.rechtspraak.nl/English"),
            scamWarningByLanguage: [
                .english: "Official court correspondence uses postal mail. Verify at rechtspraak.nl before responding to unexpected messages claiming to be courts.",
                .dutch:   "Officiële gerechtelijke correspondentie gaat via post. Verifieer op rechtspraak.nl voordat u reageert op onverwachte berichten die van rechtbanken beweren te zijn.",
                .russian: "Официальная судебная корреспонденция приходит по почте. Проверяйте на rechtspraak.nl перед ответом на неожиданные сообщения от имени суда."
            ]
        ),
        OfficialSourceItem(
            name: "Politie.nl — Dutch Police",
            handlesByLanguage: [
                .english: "Crime reporting, non-urgent police help, public safety information.",
                .dutch:   "Aangifte doen, niet-urgente politiehulp, informatie over openbare veiligheid.",
                .russian: "Сообщения о преступлениях, несрочная полицейская помощь, информация об общественной безопасности."
            ],
            whenNeededByLanguage: [
                .english: "To report a non-urgent crime or incident, or find local police contact information. Call 112 in emergencies.",
                .dutch:   "Voor het melden van een niet-urgent misdrijf of incident, of het vinden van lokale politiecontactgegevens. Bel 112 bij noodgevallen.",
                .russian: "Чтобы сообщить о несрочном преступлении или инциденте, или найти контакты местной полиции. При экстренных ситуациях звоните 112."
            ],
            officialURL: AppURL.make("https://www.politie.nl"),
            scamWarningByLanguage: [
                .english: "Police do not request payments via phone or email. If asked, it is a scam.",
                .dutch:   "De politie vraagt geen betalingen via telefoon of e-mail. Als dat wel gebeurt, is het oplichterij.",
                .russian: "Полиция не запрашивает платежи по телефону или электронной почте. Если просят — это мошенничество."
            ]
        ),
        OfficialSourceItem(
            name: "112.nl — Emergency Services",
            handlesByLanguage: [
                .english: "Emergency coordination for police, fire, and ambulance.",
                .dutch:   "Noodcoördinatie voor politie, brandweer en ambulance.",
                .russian: "Координация экстренных служб: полиция, пожарные, скорая помощь."
            ],
            whenNeededByLanguage: [
                .english: "Use only for urgent emergencies requiring immediate response. For non-urgent matters use 0900-8844.",
                .dutch:   "Gebruik alleen bij urgente noodgevallen die onmiddellijke respons vereisen. Voor niet-urgente zaken bel 0900-8844.",
                .russian: "Используйте только при срочных экстренных ситуациях, требующих немедленного реагирования. При несрочных вопросах звоните 0900-8844."
            ],
            officialURL: AppURL.make("https://www.government.nl/themes/justice-security-and-defence/emergency-number-112"),
            scamWarningByLanguage: [
                .english: "112 is free and official. No payment is involved in emergency services.",
                .dutch:   "112 is gratis en officieel. Bij hulpdiensten is geen betaling betrokken.",
                .russian: "Номер 112 бесплатный и официальный. Экстренные службы не берут плату."
            ]
        ),
        OfficialSourceItem(
            name: "Zorginstituut Nederland",
            handlesByLanguage: [
                .english: "Standards for the Dutch basic health insurance package (basisverzekering).",
                .dutch:   "Normen voor het Nederlandse basispakket zorgverzekering.",
                .russian: "Стандарты базового пакета медицинского страхования Нидерландов (basisverzekering)."
            ],
            whenNeededByLanguage: [
                .english: "When checking what the basisverzekering covers, or understanding coverage standards.",
                .dutch:   "Bij het controleren van wat de basisverzekering dekt of het begrijpen van dekkingsstandaarden.",
                .russian: "При проверке того, что входит в базовое страхование, или понимании стандартов покрытия."
            ],
            officialURL: AppURL.make("https://www.zorginstituutnederland.nl"),
            scamWarningByLanguage: [
                .english: "Zorginstituut Nederland does not sell insurance. Contact your insurer for individual policies.",
                .dutch:   "Zorginstituut Nederland verkoopt geen verzekeringen. Neem contact op met uw verzekeraar voor individuele polissen.",
                .russian: "Zorginstituut Nederland не продаёт страховку. По индивидуальным полисам обращайтесь к своему страховщику."
            ]
        ),
        OfficialSourceItem(
            name: "CAK — Administrative Healthcare Office",
            handlesByLanguage: [
                .english: "Health insurance administrative enforcement, contribution schemes.",
                .dutch:   "Administratieve handhaving zorgverzekering, bijdrageregelingen.",
                .russian: "Административное исполнение требований медицинского страхования, схемы взносов."
            ],
            whenNeededByLanguage: [
                .english: "If you receive a CAK letter about health insurance compliance, or need information about specific contribution schemes.",
                .dutch:   "Als je een CAK-brief ontvangt over zorgverzekeringsconformiteit, of informatie nodig hebt over specifieke bijdrageregelingen.",
                .russian: "Если вы получили письмо от CAK о соблюдении требований медицинского страхования, или вам нужна информация о конкретных схемах взносов."
            ],
            officialURL: AppURL.make("https://www.hetcak.nl"),
            scamWarningByLanguage: [
                .english: "Only interact with CAK via hetcak.nl or postal letters.",
                .dutch:   "Communiceer met CAK alleen via hetcak.nl of schriftelijke brieven.",
                .russian: "Взаимодействуйте с CAK только через hetcak.nl или почтовые письма."
            ]
        ),
        OfficialSourceItem(
            name: "SVB — Social Insurance Bank",
            handlesByLanguage: [
                .english: "AOW (state pension), child benefit, and other social insurance schemes.",
                .dutch:   "AOW (staatspensioen), kinderbijslag en andere socialeverzekeringsstelsels.",
                .russian: "AOW (государственная пенсия), детские пособия и другие схемы социального страхования."
            ],
            whenNeededByLanguage: [
                .english: "When you need information about child benefit (kinderbijslag), state pension eligibility, or other SVB-administered schemes.",
                .dutch:   "Als je informatie nodig hebt over kinderbijslag, AOW-rechten of andere SVB-regelingen.",
                .russian: "Когда вам нужна информация о детских пособиях (kinderbijslag), праве на государственную пенсию или других схемах SVB."
            ],
            officialURL: AppURL.make("https://www.svb.nl/en"),
            scamWarningByLanguage: [
                .english: "Only use svb.nl for official social insurance information.",
                .dutch:   "Gebruik alleen svb.nl voor officiële socialeverzekeringsinformatie.",
                .russian: "Используйте только svb.nl для официальной информации о социальном страховании."
            ]
        ),
        OfficialSourceItem(
            name: "Fraudehelpdesk",
            handlesByLanguage: [
                .english: "Reporting and information about fraud, scams, and phishing in the Netherlands.",
                .dutch:   "Melden van en informatie over fraude, oplichting en phishing in Nederland.",
                .russian: "Информация о мошенничестве, аферах и фишинге в Нидерландах, а также приём сообщений о них."
            ],
            whenNeededByLanguage: [
                .english: "When you receive a suspicious message, want to check a known scam, or want to report fraud.",
                .dutch:   "Als je een verdacht bericht ontvangt, een bekende oplichterij wilt controleren of fraude wilt melden.",
                .russian: "Когда вы получили подозрительное сообщение, хотите проверить известную схему мошенничества или сообщить о мошенничестве."
            ],
            officialURL: AppURL.make("https://www.fraudehelpdesk.nl"),
            scamWarningByLanguage: [
                .english: "Fraudehelpdesk.nl is free. If someone charges you to 'report fraud', that itself is suspicious.",
                .dutch:   "Fraudehelpdesk.nl is gratis. Als iemand u vraagt te betalen om 'fraude te melden', is dat zelf verdacht.",
                .russian: "Fraudehelpdesk.nl — бесплатная служба. Если кто-то берёт деньги за «сообщение о мошенничестве» — это само по себе подозрительно."
            ]
        ),
        OfficialSourceItem(
            name: "Huurcommissie — Rent Disputes",
            handlesByLanguage: [
                .english: "Mediation and decisions on rent disputes between tenants and landlords.",
                .dutch:   "Bemiddeling en beslissingen bij huurgeschillen tussen huurders en verhuurders.",
                .russian: "Посредничество и решения по спорам об аренде между арендаторами и арендодателями."
            ],
            whenNeededByLanguage: [
                .english: "When you have a dispute about service costs, rent level (social housing), or deposit return.",
                .dutch:   "Als je een geschil hebt over servicekosten, huurprijs (sociale huur) of terugbetaling van de borg.",
                .russian: "При споре о стоимости услуг, уровне арендной платы (социальное жильё) или возврате залога."
            ],
            officialURL: AppURL.make("https://www.huurcommissie.nl"),
            scamWarningByLanguage: [
                .english: "Only use huurcommissie.nl. Be cautious of unofficial 'housing dispute' services charging fees.",
                .dutch:   "Gebruik alleen huurcommissie.nl. Wees voorzichtig met onofficiële 'woninggeschil'-diensten die kosten in rekening brengen.",
                .russian: "Используйте только huurcommissie.nl. Остерегайтесь неофициальных служб по «жилищным спорам», взимающих плату."
            ]
        ),
        OfficialSourceItem(
            name: "NS — Dutch Railways",
            handlesByLanguage: [
                .english: "Train route planning, disruption information, subscriptions, and rail-service questions.",
                .dutch: "Treinreisplanning, storingsinformatie, abonnementen en vragen over treinreizen.",
                .russian: "Маршруты поездов, сбои, абонементы и вопросы по железнодорожным поездкам."
            ],
            whenNeededByLanguage: [
                .english: "When planning train travel, checking disruptions, managing train subscriptions, or claiming rail-related compensation.",
                .dutch: "Bij treinreizen plannen, storingen controleren, abonnementen beheren of compensatie rond treinreizen bekijken.",
                .russian: "Для планирования поездов, проверки сбоев, управления абонементами или компенсаций по поездкам."
            ],
            officialURL: AppURL.make("https://www.ns.nl/en"),
            scamWarningByLanguage: [
                .english: "Use ns.nl or the official NS app. Verify payment requests before entering bank details.",
                .dutch: "Gebruik ns.nl of de officiële NS-app. Controleer betaalverzoeken voordat je bankgegevens invult.",
                .russian: "Используйте ns.nl или официальное приложение NS. Проверяйте платежи перед вводом банковских данных."
            ]
        ),
        OfficialSourceItem(
            name: "9292 — Public Transport Planner",
            handlesByLanguage: [
                .english: "Route planning across Dutch public transport operators.",
                .dutch: "Reisplanning voor Nederlandse ov-vervoerders.",
                .russian: "Планирование маршрутов по операторам общественного транспорта Нидерландов."
            ],
            whenNeededByLanguage: [
                .english: "When comparing train, tram, metro, bus, and walking connections across different operators.",
                .dutch: "Bij het vergelijken van trein-, tram-, metro-, bus- en loopverbindingen tussen vervoerders.",
                .russian: "Когда нужно сравнить поезд, трамвай, метро, автобус и пешие пересадки между операторами."
            ],
            officialURL: AppURL.make("https://9292.nl/en"),
            scamWarningByLanguage: [
                .english: "Use 9292 for planning; buy or manage tickets only through the relevant official operator or payment provider.",
                .dutch: "Gebruik 9292 voor planning; koop of beheer tickets via de relevante officiële vervoerder of betaaldienst.",
                .russian: "Используйте 9292 для маршрутов; билеты покупайте или управляйте ими у официального оператора или платежного сервиса."
            ]
        ),
        OfficialSourceItem(
            name: "OVpay / OV-chipkaart",
            handlesByLanguage: [
                .english: "Public-transport payment, check-in/check-out, and card/account support.",
                .dutch: "Ov-betalen, in- en uitchecken, en ondersteuning voor kaart of account.",
                .russian: "Оплата OV, check-in/check-out и поддержка карты или аккаунта."
            ],
            whenNeededByLanguage: [
                .english: "When learning how to pay for public transport, correct missed check-outs, or manage OV payment products.",
                .dutch: "Als je wilt weten hoe je ov betaalt, gemiste check-outs corrigeert of ov-producten beheert.",
                .russian: "Когда нужно разобраться с оплатой транспорта, исправлением check-out или OV-продуктами."
            ],
            officialURL: AppURL.make("https://www.ovpay.nl/en"),
            scamWarningByLanguage: [
                .english: "Use official OVpay or OV-chipkaart domains; transport payment phishing can imitate balance or refund pages.",
                .dutch: "Gebruik officiële OVpay- of OV-chipkaart-domeinen; phishing kan saldo- of terugbetaalpagina's nabootsen.",
                .russian: "Используйте официальные домены OVpay или OV-chipkaart; фишинг может имитировать баланс или возврат."
            ]
        ),
        OfficialSourceItem(
            name: "Municipality (Gemeente)",
            handlesByLanguage: [
                .english: "Local registration (BRP), local permits, waste, parking, and many local services.",
                .dutch:   "Lokale registratie (BRP), lokale vergunningen, afval, parkeren en vele lokale diensten.",
                .russian: "Местная регистрация (BRP), местные разрешения, вывоз мусора, парковка и многие местные услуги."
            ],
            whenNeededByLanguage: [
                .english: "For address registration, local permits, waste collection information, and municipality-specific services.",
                .dutch:   "Voor adresregistratie, lokale vergunningen, afvalinzamelingsinformatie en gemeentespecifieke diensten.",
                .russian: "Для регистрации адреса, местных разрешений, информации о вывозе мусора и услуг конкретного муниципалитета."
            ],
            officialURL: AppURL.make("https://www.government.nl/topics/municipalities"),
            scamWarningByLanguage: [
                .english: "Each municipality has its own official website. Verify the domain matches your city name.",
                .dutch:   "Elke gemeente heeft een eigen officiële website. Controleer of het domein overeenkomt met uw stadsnaam.",
                .russian: "У каждого муниципалитета есть свой официальный сайт. Проверяйте, что домен соответствует названию вашего города."
            ]
        )
    ]

    private var filtered: [OfficialSourceItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return sectionFilteredSources }
        return sectionFilteredSources.filter {
            $0.name.lowercased().contains(q) ||
            $0.handles(lang).lowercased().contains(q) ||
            $0.whenNeeded(lang).lowercased().contains(q)
        }
    }

    private var sectionFilteredSources: [OfficialSourceItem] {
        guard let selectedSection else { return visibleSources }
        return visibleSources.filter { sourceSection($0) == selectedSection }
    }

    private var visibleSources: [OfficialSourceItem] {
        allSources.filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }

    private var visibleSections: [OfficialSourceSection] {
        OfficialSourceSection.allCases.filter { section in
            visibleSources.contains { sourceSection($0) == section }
        }
    }

    private var visibleSourceCount: Int {
        visibleSources.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                officialSourcesHero
                DisclaimerBanner(text: L10n.t("official_sources.disclaimer", lang))

                SectionHeader(
                    title: L10n.t("official_sources.title", lang),
                    subtitle: String(format: L10n.t("official_sources.subtitle", lang), visibleSourceCount)
                )
                .accessibilityIdentifier("officialSources.screen")

                TextField(L10n.t("official_sources.search_placeholder", lang), text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)

                officialSourceFilterChips

                if filtered.isEmpty {
                    noSourcesDashboard
                } else {
                    ForEach(OfficialSourceSection.allCases) { section in
                        let sources = filtered.filter { sourceSection($0) == section }
                        if !sources.isEmpty {
                            SectionHeader(title: section.title(lang))
                            ForEach(sources) { source in
                                Button {
                                    selectedSource = source
                                } label: {
                                    sourceCard(source: source)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                OutdatedInfoReportCard()
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground(.settings)
        .navigationTitle(L10n.t("resources.official_sources", lang))
        .animation(AppAnimations.standard, value: searchText)
        .animation(AppAnimations.standard, value: selectedSection)
        .sheet(item: $selectedSource) { source in
            OfficialSourceDetailView(source: source)
        }
    }

    private var officialSourceFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.small) {
                officialSourceFilterChip(
                    title: allSourcesFilterTitle,
                    count: visibleSourceCount,
                    icon: "square.grid.2x2.fill",
                    accent: AppColors.dutchOrange,
                    isSelected: selectedSection == nil
                ) {
                    selectedSection = nil
                }

                ForEach(visibleSections) { section in
                    officialSourceFilterChip(
                        title: section.title(lang),
                        count: visibleSources.filter { sourceSection($0) == section }.count,
                        icon: section.icon,
                        accent: section.accent,
                        isSelected: selectedSection == section
                    ) {
                        selectedSection = section
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .accessibilityIdentifier("officialSources.filter.chips")
    }

    private func officialSourceFilterChip(
        title: String,
        count: Int,
        icon: String,
        accent: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(AppTypography.captionStrong)
                    .lineLimit(1)
                Text("\(count)")
                    .font(AppTypography.metadata)
                    .foregroundStyle(isSelected ? .white.opacity(0.82) : AppColors.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isSelected ? .white.opacity(0.18) : AppColors.cardElevated)
                    )
            }
            .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(isSelected ? accent : AppColors.cardElevated)
            )
            .overlay {
                Capsule()
                    .stroke(isSelected ? accent.opacity(0.25) : AppSurface.b2, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("officialSources.filter.\(title)")
    }

    private var noSourcesDashboard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            InfoCard(
                title: L10n.t("official_sources.no_match", lang),
                subtitle: noSourcesSubtitle,
                detail: noSourcesDetail,
                icon: "checkmark.shield.fill"
            )

            Button {
                searchText = ""
                selectedSection = nil
            } label: {
                Label(noSourcesResetTitle, systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryPremiumButtonStyle())
            .accessibilityIdentifier("officialSources.empty.reset")

            LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 360, minimumColumnWidth: 156), spacing: AppSpacing.small) {
                ForEach(noSourcesRecoveryActions) { action in
                    NavigationLink(value: action.destination) {
                        OfficialSourceRecoveryActionCard(action: action)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                    .accessibilityIdentifier("officialSources.empty.action.\(action.id)")
                }
            }
        }
        .accessibilityIdentifier("officialSources.empty.dashboard")
    }

    private var officialSourcesHero: some View {
        CategoryHeroVisual(
            assetName: "home_documents_city_hall",
            title: L10n.t("official_sources.title", lang),
            subtitle: String(format: L10n.t("official_sources.subtitle", lang), visibleSourceCount),
            symbol: "building.columns.fill",
            badgeText: verifiedBadgeText,
            accent: AppColors.success,
            asset: ContentMediaRegistry.municipalityCityHallImage
        )
    }

    private var verifiedBadgeText: String {
        switch lang {
        case .russian: return "Проверяйте домены"
        case .dutch: return "Controleer domeinen"
        case .english: return "Verify domains"
        }
    }

    private var noSourcesSubtitle: String {
        localized(en: "Try a broader route", nl: "Probeer een bredere route", ru: "Попробуйте более широкий маршрут")
    }

    private var noSourcesDetail: String {
        localized(
            en: "Clear the search or start from a practical area. Many services are listed under broader institutions.",
            nl: "Wis de zoekopdracht of begin bij een praktisch onderdeel. Veel diensten vallen onder bredere organisaties.",
            ru: "Сбросьте поиск или начните с практического раздела. Многие сервисы находятся внутри более крупных организаций."
        )
    }

    private var noSourcesResetTitle: String {
        localized(en: "Show all sources", nl: "Toon alle bronnen", ru: "Показать все источники")
    }

    private var allSourcesFilterTitle: String {
        localized(en: "All", nl: "Alles", ru: "Все")
    }

    private var noSourcesRecoveryActions: [OfficialSourceRecoveryAction] {
        [
            OfficialSourceRecoveryAction(
                id: "search",
                title: L10n.t("tab.search", lang),
                subtitle: localized(en: "Search answers, guides, and institutions.", nl: "Zoek antwoorden, gidsen en instanties.", ru: "Искать ответы, гайды и организации."),
                icon: "magnifyingglass.circle.fill",
                tint: AppColors.dutchOrange,
                destination: .searchList
            ),
            OfficialSourceRecoveryAction(
                id: "map",
                title: L10n.t("tab.map", lang),
                subtitle: localized(en: "Find local municipality, legal, health, and support places.", nl: "Vind gemeente, juridische hulp, zorg en ondersteuning dichtbij.", ru: "Найдите gemeente, юридическую помощь, медицину и поддержку рядом."),
                icon: "map.fill",
                tint: AppColors.softBlue,
                destination: .mapHub
            ),
            OfficialSourceRecoveryAction(
                id: "documents",
                title: localized(en: "Documents", nl: "Documenten", ru: "Документы"),
                subtitle: localized(en: "Prepare files before opening an official portal.", nl: "Bereid bestanden voor voordat je een officieel portaal opent.", ru: "Подготовьте файлы перед официальным порталом."),
                icon: "doc.text.fill",
                tint: AppColors.cyanGlow,
                destination: .journeyDocuments
            ),
            OfficialSourceRecoveryAction(
                id: "legal",
                title: localized(en: "Legal help", nl: "Juridische hulp", ru: "Юридическая помощь"),
                subtitle: localized(en: "Use support when the question is personal or urgent.", nl: "Gebruik hulp als de vraag persoonlijk of dringend is.", ru: "Используйте помощь, если вопрос личный или срочный."),
                icon: "person.fill.questionmark",
                tint: AppColors.violet,
                destination: .legalHelp
            )
        ]
        .filter { RelatedContentEngine.isVisible($0.destination, for: activePersona) }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private func sourceCard(source: OfficialSourceItem) -> some View {
        OfficialSourceVisualCard(
            title: source.name,
            subtitle: source.officialURL.host ?? source.officialURL.absoluteString,
            detail: "\(sourceSection(source).title(lang)) • \(source.handles(lang))",
            symbol: sourceSymbol(for: source),
            accent: sourceAccent(for: source),
            asset: sourceImageAsset(for: source),
            language: lang,
            fallbackCategory: sourceFallbackCategory(for: source)
        )
    }

    private func sourceSection(_ source: OfficialSourceItem) -> OfficialSourceSection {
        let name = source.name.lowercased()
        if name.contains("digid") || name.contains("rdw") || name.contains("duo") { return .identity }
        if name.contains("zorg") || name.contains("cak") || name.contains("svb") { return .healthcare }
        if name.contains("ns") || name.contains("9292") || name.contains("ovpay") || name.contains("ov-chipkaart") { return .transport }
        if name.contains("huurcommissie") { return .housing }
        if name.contains("municipality") || name.contains("gemeente") { return .municipalities }
        if name.contains("rijksmuseum") || name.contains("unesco") || name.contains("wikimedia") { return .cultureHistory }
        if name.contains("media") || name.contains("license") { return .mediaLicenses }
        return .government
    }

    private func sourceImageAsset(for source: OfficialSourceItem) -> AppImageAsset? {
        let name = source.name.lowercased()
        if name.contains("digid") {
            return ContentMediaRegistry.digidImage ?? ContentMediaRegistry.municipalityCityHallImage
        }
        if name.contains("112") || name.contains("politie") {
            return ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.officialSourcesHero
        }

        switch sourceSection(source) {
        case .government, .municipalities, .identity:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case .healthcare:
            return ContentMediaRegistry.healthInsuranceImage ?? ContentMediaRegistry.healthcarePharmacyImage
        case .transport:
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case .housing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .cultureHistory, .mediaLicenses:
            return ContentMediaRegistry.cultureWindmillHero ?? ContentMediaRegistry.officialSourcesHero
        }
    }

    private func sourceFallbackCategory(for source: OfficialSourceItem) -> PremiumImageFallbackCategory {
        let name = source.name.lowercased()
        if name.contains("112") || name.contains("politie") { return .emergency }

        switch sourceSection(source) {
        case .government, .municipalities, .identity:
            return .government
        case .healthcare:
            return .healthcare
        case .transport:
            return .transport
        case .housing:
            return .housing
        case .cultureHistory, .mediaLicenses:
            return .province
        }
    }

    private func sourceSymbol(for source: OfficialSourceItem) -> String {
        let name = source.name.lowercased()
        if name.contains("digid") { return "lock.shield.fill" }
        if name.contains("112") { return "cross.case.circle.fill" }
        if name.contains("politie") { return "shield.lefthalf.filled" }

        switch sourceSection(source) {
        case .government, .municipalities:
            return "building.columns.fill"
        case .healthcare:
            return "cross.case.fill"
        case .transport:
            return "tram.fill"
        case .identity:
            return "person.text.rectangle.fill"
        case .housing:
            return "house.fill"
        case .cultureHistory, .mediaLicenses:
            return "photo.on.rectangle.angled"
        }
    }

    private func sourceAccent(for source: OfficialSourceItem) -> Color {
        let name = source.name.lowercased()
        if name.contains("112") || name.contains("politie") { return AppColors.error }
        if name.contains("digid") { return AppColors.violet }

        switch sourceSection(source) {
        case .government, .municipalities, .identity:
            return AppColors.success
        case .healthcare:
            return AppColors.error
        case .transport:
            return AppColors.routeLine
        case .housing:
            return AppColors.cyanGlow
        case .cultureHistory, .mediaLicenses:
            return AppColors.dutchOrange
        }
    }
}

// MARK: - Detail View

private struct OfficialSourceRecoveryAction: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let destination: AppDestination
}

private struct OfficialSourceRecoveryActionCard: View {
    let action: OfficialSourceRecoveryAction

    var body: some View {
        ProductTaskCard(
            title: action.title,
            subtitle: action.subtitle,
            symbol: action.icon,
            accent: action.tint,
            minHeight: 104
        )
    }
}

private struct OfficialSourceDetailView: View {
    let source: OfficialSourceItem
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        PremiumImageHeader(
                            title: source.name,
                            asset: sourceImageAsset(for: source),
                            language: lang,
                            symbol: sourceSymbol(for: source),
                            accent: sourceAccent(for: source),
                            height: 184,
                            cornerRadius: 22,
                            fallbackCategory: sourceFallbackCategory(for: source)
                        )

                        Text(source.name)
                            .font(AppTypography.title)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                    .appCardStyle()

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        SectionHeader(title: L10n.t("official_sources.what_handles", lang))
                        Text(source.handles(lang))
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .appCardStyle()

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        SectionHeader(title: L10n.t("official_sources.when_needed", lang))
                        Text(source.whenNeeded(lang))
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .appCardStyle()

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        SectionHeader(title: L10n.t("official_sources.scam_warning", lang))
                        HStack(alignment: .top, spacing: AppSpacing.small) {
                            Image(systemName: "shield.slash")
                                .foregroundStyle(AppColors.error)
                                .font(.title3)
                            Text(source.scamWarning(lang))
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .appCardStyle()

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        SectionHeader(title: L10n.t("beginner.official_source", lang))
                        Text(L10n.t("official_sources.start_here", lang))
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                        Button(openOfficialSourceTitle) {
                            openURL(AppURL.safeWebURL(source.officialURL))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.accent)
                    }
                    .appCardStyle()

                    OutdatedInfoReportCard()
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
                .tabBarScrollReserve()
            }
            .appSceneBackground(.settings)
            .navigationTitle(L10n.t("search.related_institution", lang))
#if os(iOS)
            .nlNavigationInline()
#endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(L10n.t("common.done", lang)) { dismiss() }
                }
            }
        }
    }

    private func sourceSection(_ source: OfficialSourceItem) -> OfficialSourceSection {
        let name = source.name.lowercased()
        if name.contains("digid") || name.contains("rdw") || name.contains("duo") { return .identity }
        if name.contains("zorg") || name.contains("cak") || name.contains("svb") { return .healthcare }
        if name.contains("ns") || name.contains("9292") || name.contains("ovpay") || name.contains("ov-chipkaart") { return .transport }
        if name.contains("huurcommissie") { return .housing }
        if name.contains("municipality") || name.contains("gemeente") { return .municipalities }
        if name.contains("rijksmuseum") || name.contains("unesco") || name.contains("wikimedia") { return .cultureHistory }
        if name.contains("media") || name.contains("license") { return .mediaLicenses }
        return .government
    }

    private func sourceImageAsset(for source: OfficialSourceItem) -> AppImageAsset? {
        let name = source.name.lowercased()
        if name.contains("digid") {
            return ContentMediaRegistry.digidImage ?? ContentMediaRegistry.municipalityCityHallImage
        }
        if name.contains("112") || name.contains("politie") {
            return ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.officialSourcesHero
        }

        switch sourceSection(source) {
        case .government, .municipalities, .identity:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case .healthcare:
            return ContentMediaRegistry.healthInsuranceImage ?? ContentMediaRegistry.healthcarePharmacyImage
        case .transport:
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case .housing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .cultureHistory, .mediaLicenses:
            return ContentMediaRegistry.cultureWindmillHero ?? ContentMediaRegistry.officialSourcesHero
        }
    }

    private func sourceFallbackCategory(for source: OfficialSourceItem) -> PremiumImageFallbackCategory {
        let name = source.name.lowercased()
        if name.contains("112") || name.contains("politie") { return .emergency }

        switch sourceSection(source) {
        case .government, .municipalities, .identity:
            return .government
        case .healthcare:
            return .healthcare
        case .transport:
            return .transport
        case .housing:
            return .housing
        case .cultureHistory, .mediaLicenses:
            return .province
        }
    }

    private func sourceSymbol(for source: OfficialSourceItem) -> String {
        let name = source.name.lowercased()
        if name.contains("digid") { return "lock.shield.fill" }
        if name.contains("112") { return "cross.case.circle.fill" }
        if name.contains("politie") { return "shield.lefthalf.filled" }

        switch sourceSection(source) {
        case .government, .municipalities:
            return "building.columns.fill"
        case .healthcare:
            return "cross.case.fill"
        case .transport:
            return "tram.fill"
        case .identity:
            return "person.text.rectangle.fill"
        case .housing:
            return "house.fill"
        case .cultureHistory, .mediaLicenses:
            return "photo.on.rectangle.angled"
        }
    }

    private func sourceAccent(for source: OfficialSourceItem) -> Color {
        let name = source.name.lowercased()
        if name.contains("112") || name.contains("politie") { return AppColors.error }
        if name.contains("digid") { return AppColors.violet }

        switch sourceSection(source) {
        case .government, .municipalities, .identity:
            return AppColors.success
        case .healthcare:
            return AppColors.error
        case .transport:
            return AppColors.routeLine
        case .housing:
            return AppColors.cyanGlow
        case .cultureHistory, .mediaLicenses:
            return AppColors.dutchOrange
        }
    }

    private var openOfficialSourceTitle: String {
        switch lang {
        case .russian: return "Открыть официальный источник"
        case .dutch: return "Open officiële bron"
        case .english: return "Open official source"
        }
    }
}
