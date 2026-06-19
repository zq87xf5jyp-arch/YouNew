import Foundation

enum MockRisksData {
    static let items: [RiskItem] = [
        item(
            en: ("Ignoring official letters", "Important instructions may be missed.", "Possible delays, extra follow-up steps, or extra costs.", "Verify current rules with the institution that sent the letter."),
            ru: ("Игнорирование официальных писем", "Можно пропустить важные инструкции.", "Возможны задержки, дополнительные шаги или расходы.", "Проверяйте актуальные правила в учреждении, которое отправило письмо."),
            nl: ("Officiële brieven negeren", "Belangrijke instructies kunnen worden gemist.", "Mogelijke vertraging, extra vervolgstappen of kosten.", "Controleer actuele regels bij de instantie die de brief stuurde."),
            section: .topMistakes
        ),
        item(
            en: ("Not updating your address", "Institutions may send mail to the wrong address.", "Possible missed reminders or deadlines.", "Check municipality and institution update procedures."),
            ru: ("Адрес не обновлён", "Учреждения могут отправлять письма на старый адрес.", "Можно пропустить напоминания или сроки.", "Проверьте процедуры обновления адреса в gemeente и нужных учреждениях."),
            nl: ("Adres niet bijwerken", "Instanties kunnen post naar het verkeerde adres sturen.", "Mogelijk mist u herinneringen of termijnen.", "Controleer procedures bij gemeente en betrokken instanties."),
            section: .topMistakes
        ),
        item(
            en: ("Missing mandatory insurance", "Some residents may be required to arrange Dutch basic health insurance.", "Possible financial consequences depending on the situation.", "Verify current insurance rules on official sources."),
            ru: ("Нет обязательной страховки", "Некоторым жителям нужна базовая медицинская страховка в Нидерландах.", "Возможны финансовые последствия в зависимости от ситуации.", "Проверяйте актуальные правила страховки в официальных источниках."),
            nl: ("Verplichte verzekering ontbreekt", "Sommige inwoners moeten een Nederlandse basisverzekering afsluiten.", "Mogelijke financiële gevolgen afhankelijk van de situatie.", "Controleer actuele verzekeringsregels bij officiële bronnen."),
            section: .fines
        ),
        item(
            en: ("Transport ticket violations", "Not checking in or out correctly may be treated as non-compliance.", "Possible fines or correction charges.", "Verify current public transport rules and ticket conditions."),
            ru: ("Ошибки с билетом в транспорте", "Неправильный check-in или check-out может считаться нарушением.", "Возможны штрафы или корректирующие списания.", "Проверяйте актуальные правила общественного транспорта и условия билета."),
            nl: ("Fouten met vervoersbewijs", "Niet correct in- of uitchecken kan als overtreding gelden.", "Mogelijke boetes of correctietarieven.", "Controleer actuele ov-regels en ticketvoorwaarden."),
            section: .fines
        ),
        item(
            en: ("Fake DigiD websites", "Scam pages may imitate login screens.", "Possible credential theft.", "Use known official URLs directly, not links from unknown messages."),
            ru: ("Поддельные сайты DigiD", "Мошеннические страницы могут имитировать экран входа.", "Возможна кража данных для входа.", "Открывайте известные официальные адреса напрямую, не по ссылкам из неизвестных сообщений."),
            nl: ("Valse DigiD-websites", "Oplichtingspagina's kunnen inlogschermen nadoen.", "Mogelijke diefstal van inloggegevens.", "Gebruik bekende officiële URL's rechtstreeks, niet via onbekende berichten."),
            section: .scams
        ),
        item(
            en: ("Fake housing deposit requests", "Scammers may request urgent payment before clear documentation.", "Possible financial loss.", "Verify landlord, contract details, and payment instructions carefully."),
            ru: ("Фальшивый запрос депозита за жильё", "Мошенники могут требовать срочную оплату без понятных документов.", "Возможна потеря денег.", "Тщательно проверяйте арендодателя, договор и реквизиты оплаты."),
            nl: ("Valse waarborgsomverzoeken", "Oplichters kunnen snelle betaling vragen zonder duidelijke documenten.", "Mogelijk financieel verlies.", "Controleer verhuurder, contractgegevens en betaalinstructies zorgvuldig."),
            section: .scams
        ),
        item(
            en: ("Phishing SMS messages", "Messages may claim urgent action from government institutions.", "Possible personal data exposure.", "Confirm requests through official website contact channels."),
            ru: ("Фишинговые SMS", "Сообщения могут требовать срочного действия якобы от госучреждений.", "Возможна утечка персональных данных.", "Подтверждайте запросы через официальные сайты и контакты."),
            nl: ("Phishing-sms'en", "Berichten kunnen dringende actie namens instanties claimen.", "Mogelijke blootstelling van persoonsgegevens.", "Bevestig verzoeken via officiële websitecontacten."),
            section: .scams
        ),
        item(
            en: ("Not keeping document copies", "Important records can be hard to find when needed.", "Possible delays in appointments or follow-ups.", "Keep organized copies and verify retention requirements."),
            ru: ("Нет копий документов", "Важные записи трудно найти, когда они понадобятся.", "Возможны задержки на приёмах или в дальнейших шагах.", "Храните организованные копии и проверяйте требования к хранению."),
            nl: ("Geen documentkopieën bewaren", "Belangrijke stukken zijn moeilijk te vinden wanneer nodig.", "Mogelijke vertraging bij afspraken of vervolgstappen.", "Bewaar geordende kopieën en controleer bewaartermijnen."),
            section: .reminders
        )
    ]

    private static func item(
        en: (String, String, String, String),
        ru: (String, String, String, String),
        nl: (String, String, String, String),
        section: RiskSection
    ) -> RiskItem {
        RiskItem(
            title: [.english: en.0, .russian: ru.0, .dutch: nl.0],
            possibleIssue: [.english: en.1, .russian: ru.1, .dutch: nl.1],
            possibleConsequence: [.english: en.2, .russian: ru.2, .dutch: nl.2],
            verifyRule: [.english: en.3, .russian: ru.3, .dutch: nl.3],
            section: section
        )
    }
}

enum MockRiskData {
    static let items: [RiskItem] = MockRisksData.items
}
