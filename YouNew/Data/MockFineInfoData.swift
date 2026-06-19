import Foundation

enum MockFineInfoData {
    private static let updated = Date(timeIntervalSince1970: 1746057600)
    private static let cjibURL = AppURL.make("https://www.cjib.nl/en")
    private static let govURL = AppURL.make("https://www.government.nl")
    private static let rdwURL = AppURL.make("https://www.rdw.nl/en")
    private static let belastingURL = AppURL.make("https://www.belastingdienst.nl")

    private static let disclaimerByLanguage: [AppLanguage: String] = [
        .english: "This is educational information only. Fine amounts and rules can change. Always verify current amounts and procedures with the official institution. This is not legal advice.",
        .russian: "Это только справочная информация. Суммы штрафов и правила могут меняться. Всегда уточняйте актуальные суммы и процедуры в официальном учреждении. Это не юридическая консультация.",
        .dutch:   "Dit is alleen educatieve informatie. Boetebedragen en regels kunnen veranderen. Controleer altijd de actuele bedragen en procedures bij de officiële instantie. Dit is geen juridisch advies."
    ]

    static let items: [FineInfoItem] = [

        FineInfoItem(
            id: StableRouteID.uuid("fine:traffic-violation"),
            titleByLanguage: [
                .english: "Traffic Violation Fine",
                .russian: "Штраф за нарушение ПДД",
                .dutch:   "Verkeersboete"
            ],
            category: .traffic,
            simpleExplanationByLanguage: [
                .english: "Traffic violations such as speeding, running a red light, or using a phone while driving may result in a fine under the Wahv. Check current amounts on the official CJIB website.",
                .russian: "Нарушения ПДД — превышение скорости, проезд на красный свет, использование телефона за рулём — могут повлечь штраф по закону Wahv. Актуальные суммы смотрите на официальном сайте CJIB.",
                .dutch:   "Verkeersovertredingen zoals te hard rijden, door rood rijden of telefoneren achter het stuur kunnen leiden tot een boete op grond van de Wahv. Controleer actuele bedragen op de officiële CJIB-website."
            ],
            possibleConsequenceByLanguage: [
                .english: "May result in a payment notice from CJIB. Ignoring the notice can lead to increased charges and possible collection measures.",
                .russian: "Может привести к уведомлению об оплате от CJIB. Игнорирование уведомления влечёт увеличение суммы и возможные меры взыскания.",
                .dutch:   "Kan leiden tot een betalingsaanmaning van het CJIB. Negeren kan leiden tot verhoogde bedragen en mogelijke incassomaatregelen."
            ],
            officialSourceName: "CJIB",
            officialSourceURL: cjibURL,
            lastUpdated: updated,
            severity: .moderate,
            userActionByLanguage: [
                .english: "Check the letter for payment reference and deadline. Pay using official CJIB channels only. If you believe the fine is incorrect, check objection options on official CJIB sources.",
                .russian: "Проверьте письмо на реквизиты оплаты и дедлайн. Оплачивайте только через официальные каналы CJIB. Если считаете штраф ошибочным, изучите варианты обжалования на официальном сайте CJIB.",
                .dutch:   "Controleer de brief op betaalreferentie en deadline. Betaal alleen via officiële CJIB-kanalen. Als u de boete betwist, bekijk dan de bezwaarmogelijkheden op de officiële CJIB-website."
            ],
            disclaimerByLanguage: disclaimerByLanguage
        ),

        FineInfoItem(
            id: StableRouteID.uuid("fine:parking"),
            titleByLanguage: [
                .english: "Parking Fine",
                .russian: "Штраф за парковку",
                .dutch:   "Parkeerboete"
            ],
            category: .parking,
            simpleExplanationByLanguage: [
                .english: "Parking without a valid permit, outside allowed hours, or in restricted zones may lead to a parking fine. Municipalities issue these fines. Amounts differ by city.",
                .russian: "Парковка без действующего разрешения, вне разрешённого времени или в запрещённых зонах может повлечь штраф. Штрафы выписываются муниципалитетом. Суммы различаются по городам.",
                .dutch:   "Parkeren zonder geldig vergunning, buiten toegestane tijden of in verboden zones kan leiden tot een parkeerboete. Gemeenten leggen deze boetes op. Bedragen verschillen per stad."
            ],
            possibleConsequenceByLanguage: [
                .english: "May result in a fine notice on the vehicle or sent by post. Repeated violations may escalate.",
                .russian: "Может привести к уведомлению о штрафе на лобовом стекле или по почте. Повторные нарушения могут усугубить последствия.",
                .dutch:   "Kan leiden tot een boetebon op het voertuig of per post. Herhaalde overtredingen kunnen worden geëscaleerd."
            ],
            officialSourceName: "CJIB",
            officialSourceURL: cjibURL,
            lastUpdated: updated,
            severity: .moderate,
            userActionByLanguage: [
                .english: "Check the fine notice for reference details. Verify payment instructions on official CJIB or municipality channels. Object within the deadline if you believe it is incorrect.",
                .russian: "Проверьте уведомление о штрафе на реквизиты. Оплатите через официальные каналы CJIB или муниципалитета. Подайте возражение до дедлайна, если считаете штраф ошибочным.",
                .dutch:   "Controleer de boetebeschikking op referentiegegevens. Volg de betaalinstructies via officiële CJIB- of gemeentekanalen. Maak bezwaar vóór de deadline als u de boete betwist."
            ],
            disclaimerByLanguage: disclaimerByLanguage
        ),

        FineInfoItem(
            id: StableRouteID.uuid("fine:public-transport-ov"),
            titleByLanguage: [
                .english: "Public Transport Fine (OV)",
                .russian: "Штраф за безбилетный проезд (OV)",
                .dutch:   "Boete openbaar vervoer (OV)"
            ],
            category: .publicTransport,
            simpleExplanationByLanguage: [
                .english: "Travelling without a valid ticket, failing to check in/out correctly, or having insufficient OV-chipkaart balance may be treated as fare evasion and result in a fine.",
                .russian: "Проезд без действительного билета, неправильный check-in/check-out или недостаточный баланс OV-chipkaart может быть расценён как безбилетный проезд и повлечь штраф.",
                .dutch:   "Reizen zonder geldig ticket, onjuist in- of uitchecken of onvoldoende saldo op de OV-chipkaart kan worden beschouwd als zwartrijden en leiden tot een boete."
            ],
            possibleConsequenceByLanguage: [
                .english: "May result in a fine issued by the transport operator or CJIB. Amounts can vary and may be significantly higher than the cost of a regular ticket.",
                .russian: "Может повлечь штраф от перевозчика или CJIB. Сумма может значительно превышать стоимость обычного билета.",
                .dutch:   "Kan leiden tot een boete van de vervoerder of het CJIB. Bedragen kunnen variëren en zijn vaak veel hoger dan de prijs van een normaal ticket."
            ],
            officialSourceName: "CJIB",
            officialSourceURL: cjibURL,
            lastUpdated: updated,
            severity: .moderate,
            userActionByLanguage: [
                .english: "Always check in and out on public transport. Check your OV-chipkaart balance before travel. If you receive a fine notice, follow the official payment or objection procedure.",
                .russian: "Всегда выполняйте check-in и check-out в общественном транспорте. Проверяйте баланс OV-chipkaart перед поездкой. Получив уведомление о штрафе, следуйте официальной процедуре оплаты или обжалования.",
                .dutch:   "Check altijd in en uit in het openbaar vervoer. Controleer uw OV-chipkaartsaldo voor vertrek. Volg bij een boetebeschikking de officiële betaal- of bezwaarprocedure."
            ],
            disclaimerByLanguage: disclaimerByLanguage
        ),

        FineInfoItem(
            id: StableRouteID.uuid("fine:health-insurance-administrative-issue"),
            titleByLanguage: [
                .english: "Health Insurance Administrative Issue",
                .russian: "Административные проблемы с медстраховкой",
                .dutch:   "Administratief probleem zorgverzekering"
            ],
            category: .healthInsurance,
            simpleExplanationByLanguage: [
                .english: "If a resident who is required to have Dutch health insurance does not take out coverage or allows it to lapse, the CAK may issue an administrative order.",
                .russian: "Если житель, обязанный иметь голландскую медицинскую страховку, её не оформил или дал ей истечь, CAK может выдать административное предписание.",
                .dutch:   "Als een inwoner die verplicht is een zorgverzekering te hebben dit nalaat of laat verlopen, kan het CAK een bestuursrechtelijke maatregel opleggen."
            ],
            possibleConsequenceByLanguage: [
                .english: "May result in an administrative measure. The CAK may arrange a basic insurance on your behalf at a higher cost.",
                .russian: "Может повлечь административную меру. CAK может оформить базовую страховку за вас, но дороже.",
                .dutch:   "Kan leiden tot een bestuursrechtelijke maatregel. Het CAK kan namens u een basisverzekering afsluiten, maar tegen hogere kosten."
            ],
            officialSourceName: "Government.nl",
            officialSourceURL: govURL,
            lastUpdated: updated,
            severity: .high,
            userActionByLanguage: [
                .english: "Ensure you have valid health insurance as soon as required. If you receive a letter from CAK, read it fully and follow instructions. Verify the process on official CAK or Government.nl sources.",
                .russian: "Оформите медицинскую страховку, как только это становится обязательным. Получив письмо от CAK, прочитайте его полностью и следуйте инструкциям. Проверьте процедуру на официальных сайтах CAK или Government.nl.",
                .dutch:   "Zorg voor een geldige zorgverzekering zodra dit verplicht is. Als u een brief van het CAK ontvangt, lees die volledig en volg de instructies op. Verifieer de procedure via officiële CAK- of Government.nl-bronnen."
            ],
            disclaimerByLanguage: disclaimerByLanguage
        ),

        FineInfoItem(
            id: StableRouteID.uuid("fine:late-tax-payment-surcharge"),
            titleByLanguage: [
                .english: "Late Tax Payment Surcharge",
                .russian: "Надбавка за просрочку налогового платежа",
                .dutch:   "Toeslag voor te late belastingbetaling"
            ],
            category: .tax,
            simpleExplanationByLanguage: [
                .english: "If a tax payment is not made by the deadline shown in the Belastingdienst assessment, a belastingrente or verzuimboete may be added.",
                .russian: "Если налоговый платёж не произведён в срок, указанный в требовании Belastingdienst, может быть начислена belastingrente (процент за просрочку) или verzuimboete (административный штраф).",
                .dutch:   "Als een belastingbetaling niet voor de deadline in de Belastingdienstbeschikking is gedaan, kan belastingrente of een verzuimboete worden opgelegd."
            ],
            possibleConsequenceByLanguage: [
                .english: "May result in additional charges on top of the original tax amount. In serious cases, further enforcement measures may apply.",
                .russian: "Может повлечь дополнительные начисления сверх основной суммы налога. В серьёзных случаях возможны дальнейшие меры взыскания.",
                .dutch:   "Kan leiden tot extra kosten bovenop het oorspronkelijke belastingbedrag. In ernstige gevallen kunnen verdere handhavingsmaatregelen van toepassing zijn."
            ],
            officialSourceName: "Belastingdienst",
            officialSourceURL: belastingURL,
            lastUpdated: updated,
            severity: .high,
            userActionByLanguage: [
                .english: "Pay within the deadline shown in your letter. If you cannot pay on time, contact Belastingdienst before the deadline to discuss options. Do not ignore letters.",
                .russian: "Оплатите в срок, указанный в письме. Если не можете оплатить вовремя, свяжитесь с Belastingdienst до дедлайна для обсуждения вариантов. Не игнорируйте письма.",
                .dutch:   "Betaal vóór de deadline in uw brief. Kunt u niet op tijd betalen, neem dan vóór de deadline contact op met de Belastingdienst om opties te bespreken. Negeer brieven niet."
            ],
            disclaimerByLanguage: disclaimerByLanguage
        ),

        FineInfoItem(
            id: StableRouteID.uuid("fine:municipality-registration-issues"),
            titleByLanguage: [
                .english: "Municipality Registration Issues",
                .russian: "Проблемы с регистрацией в gemeente",
                .dutch:   "Problemen met gemeentelijke inschrijving"
            ],
            category: .municipalityRegistration,
            simpleExplanationByLanguage: [
                .english: "Failing to register at the municipality when required, or registering with incorrect details, may have administrative consequences. The BRP needs to reflect your actual address.",
                .russian: "Неявка на регистрацию в муниципалитет или указание неверных данных может повлечь административные последствия. BRP должна отражать ваш фактический адрес.",
                .dutch:   "Het niet inschrijven bij de gemeente wanneer dat vereist is, of inschrijven met onjuiste gegevens, kan administratieve gevolgen hebben. De BRP moet uw werkelijke adres weergeven."
            ],
            possibleConsequenceByLanguage: [
                .english: "May affect access to services linked to your address or BSN. In some situations, administrative measures by the municipality are possible.",
                .russian: "Может затруднить доступ к услугам, связанным с вашим адресом или BSN. В некоторых случаях возможны административные меры со стороны муниципалитета.",
                .dutch:   "Kan de toegang tot diensten gekoppeld aan uw adres of BSN belemmeren. In sommige gevallen zijn administratieve maatregelen van de gemeente mogelijk."
            ],
            officialSourceName: "Government.nl",
            officialSourceURL: govURL,
            lastUpdated: updated,
            severity: .moderate,
            userActionByLanguage: [
                .english: "Register promptly when you have a fixed address. Report address changes within the required timeframe. Check your municipality's official website for procedures.",
                .russian: "Зарегистрируйтесь сразу, как только у вас появится постоянный адрес. Сообщайте об изменении адреса в установленные сроки. Уточните процедуру на официальном сайте вашего муниципалитета.",
                .dutch:   "Schrijf u direct in zodra u een vast adres heeft. Meld adreswijzigingen binnen de vereiste termijn. Raadpleeg de officiële website van uw gemeente voor procedures."
            ],
            disclaimerByLanguage: disclaimerByLanguage
        ),

        FineInfoItem(
            id: StableRouteID.uuid("fine:waste-disposal-violation"),
            titleByLanguage: [
                .english: "Waste Disposal Violation",
                .russian: "Нарушение правил утилизации отходов",
                .dutch:   "Overtreding afvalverwijdering"
            ],
            category: .wasteDisposal,
            simpleExplanationByLanguage: [
                .english: "Dumping waste outside designated collection points or not following local waste separation rules may result in a municipal fine. Rules differ by city.",
                .russian: "Выброс мусора вне отведённых мест или несоблюдение правил сортировки отходов может повлечь муниципальный штраф. Правила различаются по городам.",
                .dutch:   "Het dumpen van afval buiten aangewezen inzamelpunten of het niet naleven van lokale afvalscheidingsregels kan leiden tot een gemeentelijke boete. Regels verschillen per stad."
            ],
            possibleConsequenceByLanguage: [
                .english: "May result in a municipal fine. Repeated violations may lead to higher fines.",
                .russian: "Может повлечь муниципальный штраф. Повторные нарушения ведут к более высоким штрафам.",
                .dutch:   "Kan leiden tot een gemeentelijke boete. Herhaalde overtredingen kunnen leiden tot hogere boetes."
            ],
            officialSourceName: "Government.nl",
            officialSourceURL: govURL,
            lastUpdated: updated,
            severity: .moderate,
            userActionByLanguage: [
                .english: "Follow your municipality's waste collection schedule and separation rules. Check your local municipality website for specific guidance.",
                .russian: "Следуйте расписанию вывоза мусора и правилам сортировки вашего муниципалитета. Уточните инструкции на официальном сайте вашей gemeente.",
                .dutch:   "Volg het inzamelschema en de scheidingsregels van uw gemeente. Raadpleeg de gemeentelijke website voor specifieke richtlijnen."
            ],
            disclaimerByLanguage: disclaimerByLanguage
        ),

        FineInfoItem(
            id: StableRouteID.uuid("fine:driving-without-valid-licence"),
            titleByLanguage: [
                .english: "Driving Without a Valid Licence",
                .russian: "Управление автомобилем без действительного водительского удостоверения",
                .dutch:   "Rijden zonder geldig rijbewijs"
            ],
            category: .drivingLicence,
            simpleExplanationByLanguage: [
                .english: "Driving in the Netherlands without a valid driving licence, or with a foreign licence no longer valid under Dutch rules, is a traffic offence.",
                .russian: "Управление автомобилем в Нидерландах без действительного водительского удостоверения или с иностранными правами, недействительными по голландским правилам, является нарушением.",
                .dutch:   "Rijden in Nederland zonder geldig rijbewijs, of met een buitenlands rijbewijs dat niet meer geldig is onder Nederlandse regelgeving, is een verkeersovertreding."
            ],
            possibleConsequenceByLanguage: [
                .english: "May result in a fine or more serious consequences. Check current amounts on official CJIB sources.",
                .russian: "Может повлечь штраф или более серьёзные последствия. Актуальные суммы смотрите на официальном сайте CJIB.",
                .dutch:   "Kan leiden tot een boete of ernstigere gevolgen. Controleer actuele bedragen via officiële CJIB-bronnen."
            ],
            officialSourceName: "RDW",
            officialSourceURL: rdwURL,
            lastUpdated: updated,
            severity: .high,
            userActionByLanguage: [
                .english: "Verify whether your foreign licence is valid in the Netherlands and whether an exchange is required. Check the RDW website for rules applicable to your country of origin.",
                .russian: "Проверьте, действительны ли ваши иностранные права в Нидерландах и требуется ли их обмен. Изучите правила на сайте RDW для вашей страны.",
                .dutch:   "Controleer of uw buitenlands rijbewijs geldig is in Nederland en of omwisseling vereist is. Raadpleeg de RDW-website voor de regels die van toepassing zijn op uw land van herkomst."
            ],
            disclaimerByLanguage: disclaimerByLanguage
        ),

        FineInfoItem(
            id: StableRouteID.uuid("fine:ignoring-cjib-letter-escalation-risk"),
            titleByLanguage: [
                .english: "Ignoring a CJIB Letter — Escalation Risk",
                .russian: "Игнорирование письма CJIB — риск эскалации",
                .dutch:   "CJIB-brief negeren — escalatierisico"
            ],
            category: .officialLetters,
            simpleExplanationByLanguage: [
                .english: "A CJIB fine notice has a payment deadline. Ignoring the notice means the amount may increase significantly due to added surcharges. Further escalation can involve collection agencies.",
                .russian: "У уведомления о штрафе CJIB есть дедлайн оплаты. Игнорирование ведёт к значительному увеличению суммы из-за надбавок. Дальнейшая эскалация может включать коллекторные меры.",
                .dutch:   "Een CJIB-boetebeschikking heeft een betalingsdeadline. Negeren kan leiden tot aanzienlijk hogere bedragen door toeslagen. Verdere escalatie kan incassomaatregelen omvatten."
            ],
            possibleConsequenceByLanguage: [
                .english: "May result in substantially higher amounts, collection measures, or in serious cases, further legal consequences.",
                .russian: "Может привести к значительно более высоким суммам, коллекторным мерам или, в серьёзных случаях, дальнейшим правовым последствиям.",
                .dutch:   "Kan leiden tot aanzienlijk hogere bedragen, incassomaatregelen of, in ernstige gevallen, verdere juridische gevolgen."
            ],
            officialSourceName: "CJIB",
            officialSourceURL: cjibURL,
            lastUpdated: updated,
            severity: .high,
            userActionByLanguage: [
                .english: "Never ignore a CJIB letter. Read it fully, note the deadline, and pay or lodge an objection within the allowed period. Verify the process on official CJIB pages.",
                .russian: "Никогда не игнорируйте письма CJIB. Прочитайте полностью, запишите дедлайн, и оплатите или подайте возражение в установленный срок. Проверьте процедуру на официальных страницах CJIB.",
                .dutch:   "Negeer nooit een CJIB-brief. Lees hem volledig, noteer de deadline en betaal of maak bezwaar binnen de toegestane termijn. Verifieer de procedure via officiële CJIB-pagina's."
            ],
            disclaimerByLanguage: disclaimerByLanguage
        ),

        FineInfoItem(
            id: StableRouteID.uuid("fine:toeslagen-overpayment-reclaim"),
            titleByLanguage: [
                .english: "Toeslagen Overpayment Reclaim",
                .russian: "Требование вернуть излишне выплаченные toeslagen",
                .dutch:   "Terugvordering teveel ontvangen toeslagen"
            ],
            category: .tax,
            simpleExplanationByLanguage: [
                .english: "If toeslagen were paid but you were not eligible, or income/household changes were not reported, the Belastingdienst may reclaim overpaid amounts.",
                .russian: "Если toeslagen были выплачены, но вы не имели права на них, или изменения в доходе/составе семьи не были сообщены, Belastingdienst может потребовать вернуть переплату.",
                .dutch:   "Als toeslagen zijn betaald maar u er geen recht op had, of als inkomens- of gezinswijzigingen niet zijn doorgegeven, kan de Belastingdienst te veel betaalde bedragen terugvorderen."
            ],
            possibleConsequenceByLanguage: [
                .english: "May result in a demand for repayment of overpaid allowances.",
                .russian: "Может повлечь требование вернуть излишне выплаченные пособия.",
                .dutch:   "Kan leiden tot een terugbetalingseis voor te veel ontvangen toeslagen."
            ],
            officialSourceName: "Belastingdienst Toeslagen",
            officialSourceURL: AppURL.make("https://www.toeslagen.nl"),
            lastUpdated: updated,
            severity: .moderate,
            userActionByLanguage: [
                .english: "Report changes in income or household situation to Toeslagen promptly. Check your Toeslagen account regularly. If you receive a reclaim notice, verify it on the official Toeslagen portal.",
                .russian: "Своевременно сообщайте в Toeslagen об изменениях дохода или состава семьи. Регулярно проверяйте аккаунт на Toeslagen. Получив требование вернуть средства, проверьте его на официальном портале Toeslagen.",
                .dutch:   "Meld wijzigingen in inkomen of gezinssituatie tijdig bij Toeslagen. Controleer regelmatig uw Toeslageacccount. Verifieer een terugvorderingsaanmaning via het officiële Toeslagen-portaal."
            ],
            disclaimerByLanguage: disclaimerByLanguage
        )
    ]
}
