import Foundation

enum MockChecklistData {
    static let items: [ChecklistItem] = [
        ChecklistItem(
            id: StableRouteID.uuid("checklist:register-address-at-gemeente"),
            titleByLanguage: [
                .russian: "Зарегистрируйте адрес в gemeente",
                .english: "Register your address at the gemeente",
                .dutch:   "Schrijf je adres in bij de gemeente"
            ],
            descriptionByLanguage: [
                .russian: "Базовый шаг для запуска большинства городских и государственных процессов.",
                .english: "This is the foundation for most city and government processes.",
                .dutch:   "Dit is de basis voor de meeste gemeentelijke en overheidsprocedures."
            ],
            category: .registration,
            priority: .high,
            suggestedTimingByLanguage: [.russian: "Неделя 1", .english: "Week 1", .dutch: "Week 1"],
            officialSourceName: "Government.nl",
            officialSourceURL: AppURL.make("https://www.government.nl/topics/municipalities"),
            isCompleted: false,
            dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
            relevantProfileTypes: nil
        ),
        ChecklistItem(
            id: StableRouteID.uuid("checklist:get-bsn-number"),
            titleByLanguage: [
                .russian: "Получите BSN",
                .english: "Get your BSN number",
                .dutch:   "Haal uw BSN op"
            ],
            descriptionByLanguage: [
                .russian: "BSN нужен для работы, налогов, страховки и банковских сервисов.",
                .english: "BSN is needed for work, taxes, insurance, and banking services.",
                .dutch:   "BSN is nodig voor werk, belasting, verzekering en bankzaken."
            ],
            category: .registration,
            priority: .high,
            suggestedTimingByLanguage: [.russian: "Неделя 1", .english: "Week 1", .dutch: "Week 1"],
            officialSourceName: "Government.nl",
            officialSourceURL: AppURL.make("https://www.government.nl/topics/personal-data/citizen-service-number-bsn"),
            isCompleted: false,
            dueDate: Calendar.current.date(byAdding: .day, value: 8, to: Date()),
            relevantProfileTypes: nil
        ),
        ChecklistItem(
            id: StableRouteID.uuid("checklist:activate-digid"),
            titleByLanguage: [
                .russian: "Активируйте DigiD",
                .english: "Activate DigiD",
                .dutch:   "DigiD activeren"
            ],
            descriptionByLanguage: [
                .russian: "DigiD нужен для безопасного входа в госкабинеты: налоги, DUO, UWV и другие.",
                .english: "DigiD is needed for secure access to government portals: taxes, DUO, UWV, and others.",
                .dutch:   "DigiD is nodig voor veilig inloggen bij overheidsportalen: belasting, DUO, UWV en andere."
            ],
            category: .documents,
            priority: .high,
            suggestedTimingByLanguage: [.russian: "Неделя 1", .english: "Week 1", .dutch: "Week 1"],
            officialSourceName: "DigiD",
            officialSourceURL: AppURL.make("https://www.digid.nl/en"),
            isCompleted: false,
            dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()),
            relevantProfileTypes: nil
        ),
        ChecklistItem(
            id: StableRouteID.uuid("checklist:get-health-insurance"),
            titleByLanguage: [
                .russian: "Оформите медицинскую страховку",
                .english: "Get health insurance",
                .dutch:   "Zorgverzekering afsluiten"
            ],
            descriptionByLanguage: [
                .russian: "Проверьте, когда в вашей ситуации начинается обязанность по zorgverzekering.",
                .english: "Check when you are required to have a zorgverzekering in your situation.",
                .dutch:   "Controleer wanneer je in jouw situatie verplicht bent een zorgverzekering te hebben."
            ],
            category: .insurance,
            priority: .high,
            suggestedTimingByLanguage: [.russian: "Неделя 2", .english: "Week 2", .dutch: "Week 2"],
            officialSourceName: "Government.nl",
            officialSourceURL: AppURL.make("https://www.government.nl/topics/health-insurance"),
            isCompleted: false,
            dueDate: Calendar.current.date(byAdding: .day, value: 28, to: Date()),
            relevantProfileTypes: nil
        ),
        ChecklistItem(
            id: StableRouteID.uuid("checklist:open-bank-account"),
            titleByLanguage: [
                .russian: "Откройте банковский счёт",
                .english: "Open a bank account",
                .dutch:   "Bankrekening openen"
            ],
            descriptionByLanguage: [
                .russian: "Счёт обычно нужен для зарплаты, аренды и официальных платежей.",
                .english: "A bank account is usually needed for salary, rent, and official payments.",
                .dutch:   "Een bankrekening is nodig voor salaris, huur en officiële betalingen."
            ],
            category: .documents,
            priority: .medium,
            suggestedTimingByLanguage: [.russian: "Неделя 2", .english: "Week 2", .dutch: "Week 2"],
            officialSourceName: "Rijksoverheid",
            officialSourceURL: AppURL.make("https://www.rijksoverheid.nl/onderwerpen/schulden"),
            isCompleted: false,
            dueDate: nil,
            relevantProfileTypes: nil
        ),
        ChecklistItem(
            id: StableRouteID.uuid("checklist:learn-emergency-numbers"),
            titleByLanguage: [
                .russian: "Изучите экстренные номера",
                .english: "Learn emergency numbers",
                .dutch:   "Noodnummers leren"
            ],
            descriptionByLanguage: [
                .russian: "112 — только для экстренной угрозы. Для обычных вопросов используйте профильные службы.",
                .english: "112 is only for urgent emergencies. Use the relevant services for non-urgent matters.",
                .dutch:   "112 is alleen voor acute noodsituaties. Gebruik de betreffende diensten voor niet-urgente zaken."
            ],
            category: .documents,
            priority: .medium,
            suggestedTimingByLanguage: [.russian: "Неделя 2", .english: "Week 2", .dutch: "Week 2"],
            officialSourceName: "Government.nl",
            officialSourceURL: AppURL.make("https://www.government.nl/themes/justice-security-and-defence/emergency-number-112"),
            isCompleted: false,
            dueDate: nil,
            relevantProfileTypes: nil
        ),
        ChecklistItem(
            id: StableRouteID.uuid("checklist:learn-ov-chipkaart-public-transport"),
            titleByLanguage: [
                .russian: "Освойте OV-chipkaart и транспорт",
                .english: "Learn OV-chipkaart and public transport",
                .dutch:   "OV-chipkaart en openbaar vervoer"
            ],
            descriptionByLanguage: [
                .russian: "Поймите check-in/check-out и базовые правила поездок, чтобы избегать штрафов.",
                .english: "Understand check-in/check-out and basic travel rules to avoid fines.",
                .dutch:   "Begrijp in- en uitchecken en basisregels voor reizen om boetes te vermijden."
            ],
            category: .transport,
            priority: .medium,
            suggestedTimingByLanguage: [.russian: "Неделя 2", .english: "Week 2", .dutch: "Week 2"],
            officialSourceName: "Government.nl",
            officialSourceURL: AppURL.make("https://www.government.nl/topics/mobility-public-transport-and-road-safety"),
            isCompleted: false,
            dueDate: nil,
            relevantProfileTypes: nil
        ),
        ChecklistItem(
            id: StableRouteID.uuid("checklist:learn-to-read-official-letters"),
            titleByLanguage: [
                .russian: "Разберите официальные письма",
                .english: "Learn to read official letters",
                .dutch:   "Officiële brieven leren lezen"
            ],
            descriptionByLanguage: [
                .russian: "Сначала проверяйте отправителя, дату, дедлайн и требуемое действие.",
                .english: "Always check the sender, date, deadline, and required action first.",
                .dutch:   "Controleer altijd eerst de afzender, datum, deadline en vereiste actie."
            ],
            category: .documents,
            priority: .high,
            suggestedTimingByLanguage: [.russian: "Неделя 3", .english: "Week 3", .dutch: "Week 3"],
            officialSourceName: "Government.nl",
            officialSourceURL: AppURL.make("https://www.government.nl"),
            isCompleted: false,
            dueDate: nil,
            relevantProfileTypes: nil
        ),
        ChecklistItem(
            id: StableRouteID.uuid("checklist:check-taxes-belastingdienst"),
            titleByLanguage: [
                .russian: "Проверьте налоги и Belastingdienst",
                .english: "Check taxes and Belastingdienst",
                .dutch:   "Belastingen en Belastingdienst controleren"
            ],
            descriptionByLanguage: [
                .russian: "Разберитесь, какие письма требуют ответ или оплату, и где смотреть статус онлайн.",
                .english: "Find out which letters require a response or payment and where to check your status online.",
                .dutch:   "Ontdek welke brieven een reactie of betaling vereisen en waar je je status online kunt bekijken."
            ],
            category: .taxes,
            priority: .medium,
            suggestedTimingByLanguage: [.russian: "Неделя 3", .english: "Week 3", .dutch: "Week 3"],
            officialSourceName: "Belastingdienst",
            officialSourceURL: AppURL.make("https://www.belastingdienst.nl"),
            isCompleted: false,
            dueDate: nil,
            relevantProfileTypes: nil
        ),
        ChecklistItem(
            id: StableRouteID.uuid("checklist:save-official-logins-links"),
            titleByLanguage: [
                .russian: "Сохраните официальные логины и ссылки",
                .english: "Save official logins and links",
                .dutch:   "Officiële logins en links opslaan"
            ],
            descriptionByLanguage: [
                .russian: "Храните доступы и официальные URL отдельно от чатов и случайных ссылок.",
                .english: "Keep credentials and official URLs separate from chats and random links.",
                .dutch:   "Bewaar inloggegevens en officiële URL's gescheiden van chats en willekeurige links."
            ],
            category: .documents,
            priority: .medium,
            suggestedTimingByLanguage: [.russian: "Неделя 3", .english: "Week 3", .dutch: "Week 3"],
            officialSourceName: "DigiD",
            officialSourceURL: AppURL.make("https://www.digid.nl/en"),
            isCompleted: false,
            dueDate: nil,
            relevantProfileTypes: nil
        ),
        ChecklistItem(
            id: StableRouteID.uuid("checklist:check-toeslagen-benefits"),
            titleByLanguage: [
                .russian: "Проверьте toeslagen",
                .english: "Check toeslagen benefits",
                .dutch:   "Toeslagen controleren"
            ],
            descriptionByLanguage: [
                .russian: "Уточните право на пособия и обновляйте данные при изменении дохода или адреса.",
                .english: "Verify your benefit entitlement and update your details if income or address changes.",
                .dutch:   "Controleer je recht op toeslagen en update je gegevens als je inkomen of adres verandert."
            ],
            category: .taxes,
            priority: .medium,
            suggestedTimingByLanguage: [.russian: "Неделя 4", .english: "Week 4", .dutch: "Week 4"],
            officialSourceName: "Toeslagen",
            officialSourceURL: AppURL.make("https://www.toeslagen.nl"),
            isCompleted: false,
            dueDate: nil,
            relevantProfileTypes: nil
        ),
        ChecklistItem(
            id: StableRouteID.uuid("checklist:understand-work-contract-payslip"),
            titleByLanguage: [
                .russian: "Поймите рабочие системы: контракт и payslip",
                .english: "Understand work systems: contract and payslip",
                .dutch:   "Werksystemen begrijpen: contract en loonstrook"
            ],
            descriptionByLanguage: [
                .russian: "Проверьте тип контракта, часы, отпускные, удержания и базовую ставку оплаты.",
                .english: "Review your contract type, hours, holiday pay, deductions, and base pay rate.",
                .dutch:   "Controleer je contracttype, uren, vakantiegeld, inhoudingen en basisloon."
            ],
            category: .work,
            priority: .medium,
            suggestedTimingByLanguage: [.russian: "Неделя 4", .english: "Week 4", .dutch: "Week 4"],
            officialSourceName: "UWV",
            officialSourceURL: AppURL.make("https://www.uwv.nl"),
            isCompleted: false,
            dueDate: nil,
            relevantProfileTypes: [.worker, .temporaryWorker, .expat]
        ),
        ChecklistItem(
            id: StableRouteID.uuid("checklist:students-check-duo-registration"),
            titleByLanguage: [
                .russian: "Студентам: проверьте DUO и регистрацию",
                .english: "Students: check DUO and registration",
                .dutch:   "Studenten: DUO en registratie controleren"
            ],
            descriptionByLanguage: [
                .russian: "Уточните шаги DUO, студенческий транспорт и статус регистрации.",
                .english: "Verify your DUO steps, student transport, and registration status.",
                .dutch:   "Controleer uw DUO-stappen, studentenvervoer en registratiestatus."
            ],
            category: .education,
            priority: .medium,
            suggestedTimingByLanguage: [.russian: "Неделя 4", .english: "Week 4", .dutch: "Week 4"],
            officialSourceName: "DUO",
            officialSourceURL: AppURL.make("https://duo.nl/particulier/international-visitor.jsp"),
            isCompleted: false,
            dueDate: nil,
            relevantProfileTypes: [.student]
        )
    ]
}
