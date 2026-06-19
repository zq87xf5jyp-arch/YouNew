import Foundation

enum MockNewcomerMistakesData {
    private static let govURL = "https://www.government.nl"
    private static let indURL = "https://ind.nl/en"
    private static let belURL = "https://www.belastingdienst.nl"
    private static let uwvURL = "https://www.uwv.nl"
    private static let cjibURL = "https://www.cjib.nl/en"
    private static let digidURL = "https://www.digid.nl/en"
    private static let duoURL = "https://duo.nl"
    private static let toeslagenURL = "https://www.toeslagen.nl"
    private static let juridischURL = "https://www.juridischloket.nl"
    private static let fraudeURL = "https://www.fraudehelpdesk.nl"

    private static func mistake(
        titleByLanguage: [AppLanguage: String],
        whyByLanguage: [AppLanguage: String],
        consequenceByLanguage: [AppLanguage: String],
        preventByLanguage: [AppLanguage: String],
        url: String? = nil,
        sourceName: String? = nil,
        risk: RiskLevel,
        category: MistakeCategory
    ) -> NewcomerMistake {
        let title = titleByLanguage[.english] ?? titleByLanguage[.russian] ?? titleByLanguage[.dutch] ?? "untitled"
        return NewcomerMistake(
            id: StableRouteID.uuid("mistake:\(stableRouteKey(title))"),
            titleByLanguage: titleByLanguage,
            whyItMattersByLanguage: whyByLanguage,
            possibleConsequenceByLanguage: consequenceByLanguage,
            howToPreventByLanguage: preventByLanguage,
            officialSourceURL: url.flatMap { AppURL.validatedWebURL(URL(string: $0)) },
            officialSourceName: sourceName,
            riskLevel: risk,
            category: category
        )
    }

    private static func stableRouteKey(_ value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }

    static let items: [NewcomerMistake] = [
        mistake(
            titleByLanguage: [
                .russian: "Игнорировать официальные письма",
                .english: "Ignoring official letters",
                .dutch: "Officiële brieven negeren"
            ],
            whyByLanguage: [
                .russian: "В письмах часто есть дедлайн ответа, оплаты или записи.",
                .english: "Letters often contain deadlines for response, payment, or appointments.",
                .dutch: "Brieven bevatten vaak deadlines voor reactie, betaling of afspraken."
            ],
            consequenceByLanguage: [
                .russian: "Пропуск срока может привести к штрафу или усложнить ситуацию.",
                .english: "Missing a deadline can result in a fine or complicate your situation.",
                .dutch: "Een deadline missen kan leiden tot een boete of uw situatie bemoeilijken."
            ],
            preventByLanguage: [
                .russian: "Открывайте письма в день получения: отправитель → дата → дедлайн → действие.",
                .english: "Open letters the day you receive them: sender → date → deadline → action.",
                .dutch: "Open brieven de dag dat u ze ontvangt: afzender → datum → deadline → actie."
            ],
            url: govURL,
            sourceName: "Government.nl",
            risk: .high,
            category: .legalLetters
        ),
        mistake(
            titleByLanguage: [
                .russian: "Не зарегистрировать адрес в gemeente вовремя",
                .english: "Not registering your address at the gemeente on time",
                .dutch: "Adres niet op tijd inschrijven bij de gemeente"
            ],
            whyByLanguage: [
                .russian: "Без регистрации тормозятся BSN и другие процессы.",
                .english: "Without registration, BSN and other processes are delayed.",
                .dutch: "Zonder inschrijving worden BSN en andere processen vertraagd."
            ],
            consequenceByLanguage: [
                .russian: "Можно пропустить важные шаги адаптации и официальные уведомления.",
                .english: "You may miss important integration steps and official notifications.",
                .dutch: "U kunt belangrijke integratiestappen en officiële meldingen missen."
            ],
            preventByLanguage: [
                .russian: "Сразу после заселения проверьте местные правила и запишитесь на приём.",
                .english: "Right after moving in, check local rules and book an appointment.",
                .dutch: "Controleer na het intrekken de lokale regels en maak een afspraak."
            ],
            url: govURL,
            sourceName: "Government.nl",
            risk: .high,
            category: .municipality
        ),
        mistake(
            titleByLanguage: [
                .russian: "Откладывать оформление медицинской страховки",
                .english: "Delaying health insurance registration",
                .dutch: "Zorgverzekering uitstellen"
            ],
            whyByLanguage: [
                .russian: "Для многих жителей страхование обязательно.",
                .english: "Health insurance is mandatory for most residents.",
                .dutch: "Zorgverzekering is verplicht voor de meeste inwoners."
            ],
            consequenceByLanguage: [
                .russian: "Возможны административные меры и дополнительные расходы.",
                .english: "Administrative measures and additional costs may apply.",
                .dutch: "Administratieve maatregelen en extra kosten kunnen volgen."
            ],
            preventByLanguage: [
                .russian: "Проверьте дату начала обязанности и оформите полис без задержки.",
                .english: "Check your obligation start date and arrange cover without delay.",
                .dutch: "Controleer uw verplichtingsdatum en sluit zonder vertraging een verzekering af."
            ],
            url: govURL,
            sourceName: "Government.nl",
            risk: .high,
            category: .healthInsurance
        ),
        mistake(
            titleByLanguage: [
                .russian: "Не понимать, что такое CJIB и как оплачивать штраф",
                .english: "Not understanding what CJIB is and how to pay fines",
                .dutch: "CJIB en boetebetaling niet begrijpen"
            ],
            whyByLanguage: [
                .russian: "Письма CJIB — официальные и часто со строгими сроками.",
                .english: "CJIB letters are official and often have strict deadlines.",
                .dutch: "CJIB-brieven zijn officieel en hebben vaak strikte deadlines."
            ],
            consequenceByLanguage: [
                .russian: "Просрочка повышает сумму и может запустить взыскание.",
                .english: "Late payment increases the amount and may trigger enforcement.",
                .dutch: "Te laat betalen verhoogt het bedrag en kan incasso starten."
            ],
            preventByLanguage: [
                .russian: "Проверяйте reference и оплату только на cjib.nl.",
                .english: "Check the reference and pay only on cjib.nl.",
                .dutch: "Controleer de referentie en betaal alleen via cjib.nl."
            ],
            url: cjibURL,
            sourceName: "CJIB",
            risk: .high,
            category: .deadlines
        ),
        mistake(
            titleByLanguage: [
                .russian: "Доверять советам из соцсетей без проверки",
                .english: "Trusting social media advice without verification",
                .dutch: "Social media-advies blindelings vertrouwen"
            ],
            whyByLanguage: [
                .russian: "Советы могут не подходить вашему статусу и городу.",
                .english: "Advice may not apply to your specific status or city.",
                .dutch: "Advies geldt mogelijk niet voor uw specifieke situatie of gemeente."
            ],
            consequenceByLanguage: [
                .russian: "Ошибочные действия по документам, срокам и оплатам.",
                .english: "Incorrect actions on documents, deadlines, and payments.",
                .dutch: "Foute acties bij documenten, deadlines en betalingen."
            ],
            preventByLanguage: [
                .russian: "Используйте соцсети только как ориентир, финальную проверку делайте на официальных сайтах.",
                .english: "Use social media as a starting point only; verify on official websites.",
                .dutch: "Gebruik social media alleen als oriëntatie; controleer altijd op officiële sites."
            ],
            url: govURL,
            sourceName: "Government.nl",
            risk: .medium,
            category: .documents
        ),
        mistake(
            titleByLanguage: [
                .russian: "Пропускать записи и встречи в gemeente",
                .english: "Missing gemeente appointments",
                .dutch: "Gemeenteafspraken missen"
            ],
            whyByLanguage: [
                .russian: "В некоторых городах слоты ограничены, переносы долгие.",
                .english: "Appointment slots are limited in some cities and rescheduling takes time.",
                .dutch: "In sommige steden zijn sloten beperkt en duurt herplannen lang."
            ],
            consequenceByLanguage: [
                .russian: "Задержка регистрации, BSN и других этапов.",
                .english: "Delay in registration, BSN, and other steps.",
                .dutch: "Vertraging bij inschrijving, BSN en andere stappen."
            ],
            preventByLanguage: [
                .russian: "Фиксируйте дату в календаре и готовьте документы заранее.",
                .english: "Add the date to your calendar and prepare documents in advance.",
                .dutch: "Zet de datum in uw agenda en bereid documenten van tevoren voor."
            ],
            url: govURL,
            sourceName: "Government.nl",
            risk: .medium,
            category: .municipality
        ),
        mistake(
            titleByLanguage: [
                .russian: "Недооценивать важность DigiD",
                .english: "Underestimating the importance of DigiD",
                .dutch: "Het belang van DigiD onderschatten"
            ],
            whyByLanguage: [
                .russian: "Через DigiD проходят налоги, DUO, UWV и другие сервисы.",
                .english: "DigiD is needed for tax, DUO, UWV, and many other services.",
                .dutch: "DigiD is nodig voor belasting, DUO, UWV en vele andere diensten."
            ],
            consequenceByLanguage: [
                .russian: "Сложнее получать услуги и отслеживать статус заявок.",
                .english: "It becomes harder to access services and track application status.",
                .dutch: "Het wordt moeilijker om diensten te gebruiken en statussen bij te houden."
            ],
            preventByLanguage: [
                .russian: "Активируйте DigiD на раннем этапе и храните доступ безопасно.",
                .english: "Activate DigiD early and keep your login details secure.",
                .dutch: "Activeer DigiD vroeg en bewaar uw inloggegevens veilig."
            ],
            url: digidURL,
            sourceName: "DigiD",
            risk: .medium,
            category: .documents
        ),
        mistake(
            titleByLanguage: [
                .russian: "Переходить по фейковым ссылкам на оплату штрафа",
                .english: "Clicking fake fine payment links",
                .dutch: "Op nep-betaallinks voor boetes klikken"
            ],
            whyByLanguage: [
                .russian: "Фишинговые сообщения копируют стиль CJIB и налоговых писем.",
                .english: "Phishing messages mimic CJIB and tax correspondence.",
                .dutch: "Phishing-berichten imiteren CJIB- en belastingpost."
            ],
            consequenceByLanguage: [
                .russian: "Риск потери денег и личных данных.",
                .english: "Risk of financial loss and personal data theft.",
                .dutch: "Risico op financieel verlies en diefstal van persoonlijke gegevens."
            ],
            preventByLanguage: [
                .russian: "Никогда не платите по ссылке из сообщения; вводите адрес сайта вручную.",
                .english: "Never pay via a link in a message; always type the website address manually.",
                .dutch: "Betaal nooit via een link in een bericht; typ het websiteadres altijd handmatig in."
            ],
            url: fraudeURL,
            sourceName: "Fraudehelpdesk",
            risk: .urgent,
            category: .scams
        ),
        mistake(
            titleByLanguage: [
                .russian: "Открывать фальшивые письма DigiD",
                .english: "Opening fake DigiD letters",
                .dutch: "Neppe DigiD-brieven openen"
            ],
            whyByLanguage: [
                .russian: "Мошенники просят логин/код под видом срочной проверки.",
                .english: "Fraudsters ask for login credentials under the guise of an urgent check.",
                .dutch: "Fraudeurs vragen om inloggegevens onder het mom van een dringende controle."
            ],
            consequenceByLanguage: [
                .russian: "Компрометация аккаунта и доступ к госкабинетам.",
                .english: "Account compromise and access to government portals.",
                .dutch: "Accountcompromis en toegang tot overheidsdiensten."
            ],
            preventByLanguage: [
                .russian: "Проверяйте домен digid.nl и не сообщайте коды третьим лицам.",
                .english: "Verify the domain is digid.nl and never share codes with anyone.",
                .dutch: "Controleer of het domein digid.nl is en deel codes nooit met anderen."
            ],
            url: digidURL,
            sourceName: "DigiD",
            risk: .urgent,
            category: .scams
        ),
        mistake(
            titleByLanguage: [
                .russian: "Принимать подозрительные звонки от «gemeente» за официальные",
                .english: "Treating suspicious 'gemeente' calls as official",
                .dutch: "Verdachte 'gemeente'-telefoontjes als officieel beschouwen"
            ],
            whyByLanguage: [
                .russian: "Фейковые звонки могут требовать срочный перевод денег или данные.",
                .english: "Fake calls may demand urgent money transfers or personal data.",
                .dutch: "Nepgesprekken kunnen dringende geldovermakingen of persoonsgegevens eisen."
            ],
            consequenceByLanguage: [
                .russian: "Финансовый и персональный риск.",
                .english: "Financial and personal data risk.",
                .dutch: "Financieel en persoonlijk gegevensrisico."
            ],
            preventByLanguage: [
                .russian: "Завершите звонок и перезвоните в службу по номеру с официального сайта.",
                .english: "End the call and call back using the number on the official website.",
                .dutch: "Beëindig het gesprek en bel terug via het nummer op de officiële website."
            ],
            url: fraudeURL,
            sourceName: "Fraudehelpdesk",
            risk: .high,
            category: .scams
        ),
        mistake(
            titleByLanguage: [
                .russian: "Платить депозит за жильё без договора",
                .english: "Paying a housing deposit without a contract",
                .dutch: "Borgsom betalen zonder huurcontract"
            ],
            whyByLanguage: [
                .russian: "Это частая схема мошенничества на рынке аренды.",
                .english: "This is a common scam in the rental market.",
                .dutch: "Dit is een veelvoorkomende oplichterij op de huurmarkt."
            ],
            consequenceByLanguage: [
                .russian: "Потеря денег и отсутствие жилья.",
                .english: "Loss of money and no housing.",
                .dutch: "Geldverlies en geen woning."
            ],
            preventByLanguage: [
                .russian: "Оплачивайте только после проверки объекта и подписания понятного договора.",
                .english: "Pay only after viewing the property and signing a clear contract.",
                .dutch: "Betaal pas nadat u de woning heeft bezichtigd en een duidelijk contract heeft getekend."
            ],
            url: juridischURL,
            sourceName: "Juridisch Loket",
            risk: .high,
            category: .housing
        ),
        mistake(
            titleByLanguage: [
                .russian: "Не проверять payslip и условия контракта",
                .english: "Not checking your payslip and contract terms",
                .dutch: "Loonstrook en contractvoorwaarden niet controleren"
            ],
            whyByLanguage: [
                .russian: "Ошибки в часах, удержаниях или ставке бывают.",
                .english: "Errors in hours, deductions, or pay rates do occur.",
                .dutch: "Fouten in uren, inhoudingen of loonschalen komen voor."
            ],
            consequenceByLanguage: [
                .russian: "Недоплата и сложные споры позже.",
                .english: "Underpayment and difficult disputes later.",
                .dutch: "Onderbetaling en moeilijke geschillen later."
            ],
            preventByLanguage: [
                .russian: "Сверяйте часы, сумму и удержания ежемесячно.",
                .english: "Check hours, amounts, and deductions every month.",
                .dutch: "Controleer uren, bedragen en inhoudingen elke maand."
            ],
            url: uwvURL,
            sourceName: "UWV",
            risk: .medium,
            category: .work
        ),
        mistake(
            titleByLanguage: [
                .russian: "Не обновлять данные для toeslagen",
                .english: "Not updating your toeslagen details",
                .dutch: "Toeslagen-gegevens niet bijwerken"
            ],
            whyByLanguage: [
                .russian: "Пособия чувствительны к доходу и составу домохозяйства.",
                .english: "Benefits are sensitive to income and household composition changes.",
                .dutch: "Toeslagen zijn gevoelig voor veranderingen in inkomen en huishoudsamenstelling."
            ],
            consequenceByLanguage: [
                .russian: "Переплата и требование вернуть деньги.",
                .english: "Overpayment and a demand to repay.",
                .dutch: "Teveel ontvangen toeslag en een terugvorderingseis."
            ],
            preventByLanguage: [
                .russian: "При изменениях сразу обновляйте данные на toeslagen.nl.",
                .english: "Update your details on toeslagen.nl immediately when anything changes.",
                .dutch: "Werk uw gegevens op toeslagen.nl direct bij wanneer er iets verandert."
            ],
            url: toeslagenURL,
            sourceName: "Belastingdienst Toeslagen",
            risk: .medium,
            category: .taxes
        ),
        mistake(
            titleByLanguage: [
                .russian: "Откладывать разбор налоговых писем",
                .english: "Delaying tax letter review",
                .dutch: "Belastingbrieven uitstellen"
            ],
            whyByLanguage: [
                .russian: "Belastingdienst обычно указывает конкретные даты.",
                .english: "Belastingdienst usually specifies concrete deadlines.",
                .dutch: "Belastingdienst geeft doorgaans concrete deadlines aan."
            ],
            consequenceByLanguage: [
                .russian: "Пени, штрафы или пропущенное право на действие.",
                .english: "Penalties, fines, or a missed right to act.",
                .dutch: "Boetes, belastingverhogingen of gemiste handelingsrechten."
            ],
            preventByLanguage: [
                .russian: "Сразу отмечайте дедлайн и проверяйте инструкции в официальном кабинете.",
                .english: "Note the deadline immediately and check instructions in your official portal.",
                .dutch: "Noteer de deadline direct en controleer instructies in uw officiële portaal."
            ],
            url: belURL,
            sourceName: "Belastingdienst",
            risk: .high,
            category: .taxes
        ),
        mistake(
            titleByLanguage: [
                .russian: "Использовать 112 для неэкстренных вопросов",
                .english: "Using 112 for non-emergency questions",
                .dutch: "112 bellen voor niet-noodgevallen"
            ],
            whyByLanguage: [
                .russian: "112 — только для угрозы жизни и неотложной опасности.",
                .english: "112 is only for life-threatening and immediate danger situations.",
                .dutch: "112 is alleen voor levensbedreigende en acute gevaarssituaties."
            ],
            consequenceByLanguage: [
                .russian: "Задержка помощи тем, кто действительно в экстренной ситуации.",
                .english: "Delayed help for those who genuinely need emergency assistance.",
                .dutch: "Vertraagde hulp voor mensen die echt in nood zijn."
            ],
            preventByLanguage: [
                .russian: "Для обычных вопросов используйте профильные неэкстренные каналы.",
                .english: "Use the appropriate non-emergency channels for everyday questions.",
                .dutch: "Gebruik de juiste niet-noodkanalen voor alledaagse vragen."
            ],
            url: govURL,
            sourceName: "Government.nl",
            risk: .medium,
            category: .transport
        ),
        mistake(
            titleByLanguage: [
                .russian: "Не проверять статус ВНЖ и сроки продления",
                .english: "Not checking residence permit status and renewal deadlines",
                .dutch: "Status verblijfsvergunning en verlengingstermijnen niet controleren"
            ],
            whyByLanguage: [
                .russian: "IND-процессы чувствительны к срокам и пакету документов.",
                .english: "IND processes are sensitive to deadlines and document requirements.",
                .dutch: "IND-procedures zijn gevoelig voor deadlines en documentvereisten."
            ],
            consequenceByLanguage: [
                .russian: "Риск проблем со статусом пребывания.",
                .english: "Risk of problems with your residence status.",
                .dutch: "Risico op problemen met uw verblijfsstatus."
            ],
            preventByLanguage: [
                .russian: "Контролируйте даты заранее и проверяйте актуальные условия на ind.nl.",
                .english: "Monitor dates well in advance and check current conditions on ind.nl.",
                .dutch: "Houd data ruim van tevoren bij en controleer actuele voorwaarden op ind.nl."
            ],
            url: indURL,
            sourceName: "IND",
            risk: .urgent,
            category: .documents
        ),
        mistake(
            titleByLanguage: [
                .russian: "Студентам: игнорировать сообщения DUO",
                .english: "Students: ignoring DUO messages",
                .dutch: "Studenten: DUO-berichten negeren"
            ],
            whyByLanguage: [
                .russian: "В сообщениях могут быть сроки и обязательные действия.",
                .english: "Messages may contain deadlines and required actions.",
                .dutch: "Berichten kunnen deadlines en vereiste acties bevatten."
            ],
            consequenceByLanguage: [
                .russian: "Проблемы с финансированием, статусом или inburgering-шагами.",
                .english: "Problems with funding, status, or integration steps.",
                .dutch: "Problemen met financiering, status of inburgeringsstappen."
            ],
            preventByLanguage: [
                .russian: "Проверяйте кабинет DUO регулярно и сохраняйте подтверждения.",
                .english: "Check your DUO portal regularly and save all confirmations.",
                .dutch: "Controleer uw DUO-portaal regelmatig en sla alle bevestigingen op."
            ],
            url: duoURL,
            sourceName: "DUO",
            risk: .medium,
            category: .education
        )
    ]
}
