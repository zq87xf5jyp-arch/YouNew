import Foundation

nonisolated enum MockLettersData {
    static let examples: [LetterExample] = [
        LetterExample(
            title: [
                .english: "Municipality registration letter",
                .russian: "Письмо от gemeente о регистрации",
                .dutch: "Brief van gemeente over inschrijving"
            ],
            institutionName: [.english: "Gemeente", .russian: "Gemeente", .dutch: "Gemeente"],
            simplifiedExplanation: [
                .english: "Usually confirms address registration or asks you to provide missing documents.",
                .russian: "Обычно подтверждает регистрацию адреса или просит донести документы.",
                .dutch: "Bevestigt meestal uw adresinschrijving of vraagt om ontbrekende documenten."
            ],
            possibleDeadline: [
                .english: "Deadline: usually shown in the letter, often within 1-2 weeks.",
                .russian: "Срок: обычно указан в письме, часто 1-2 недели.",
                .dutch: "Termijn: staat meestal in de brief, vaak binnen 1-2 weken."
            ],
            safeNextStep: [
                .english: "Check sender, date, and document list first. Then follow the letter step by step.",
                .russian: "Сначала проверьте отправителя, дату и список документов. Затем действуйте по шагам из письма.",
                .dutch: "Controleer eerst afzender, datum en documentenlijst. Volg daarna de stappen in de brief."
            ],
            officialSourceReminder: [
                .english: "Verify details on your gemeente's official website.",
                .russian: "Проверяйте детали на официальном сайте вашей gemeente.",
                .dutch: "Controleer details op de officiële website van uw gemeente."
            ]
        ),
        LetterExample(
            title: [.english: "Belastingdienst letter", .russian: "Письмо Belastingdienst", .dutch: "Brief van Belastingdienst"],
            institutionName: [.english: "Belastingdienst", .russian: "Belastingdienst", .dutch: "Belastingdienst"],
            simplifiedExplanation: [
                .english: "May contain a tax notice, a request for information, or a payment deadline.",
                .russian: "Может содержать уведомление о налоге, запрос данных или срок оплаты.",
                .dutch: "Kan een belastingbericht, informatieverzoek of betaaltermijn bevatten."
            ],
            possibleDeadline: [
                .english: "Deadline: check the exact date in the letter.",
                .russian: "Срок: смотрите точную дату в письме.",
                .dutch: "Termijn: controleer de exacte datum in de brief."
            ],
            safeNextStep: [
                .english: "Check the kenmerk/reference and deadline. Verify actions in the official portal.",
                .russian: "Проверьте reference/kenmerk и дедлайн. Сверьте действия в официальном кабинете.",
                .dutch: "Controleer het kenmerk en de termijn. Verifieer acties in het officiële portaal."
            ],
            officialSourceReminder: [
                .english: "Use only the official belastingdienst.nl website.",
                .russian: "Используйте только официальный сайт belastingdienst.nl.",
                .dutch: "Gebruik alleen de officiële website belastingdienst.nl."
            ]
        ),
        LetterExample(
            title: [.english: "CJIB fine letter", .russian: "Письмо CJIB о штрафе", .dutch: "CJIB-brief over een boete"],
            institutionName: [.english: "CJIB", .russian: "CJIB", .dutch: "CJIB"],
            simplifiedExplanation: [
                .english: "Usually an official notice about payment of a fine or a collection step.",
                .russian: "Обычно это официальное уведомление об оплате штрафа или этапе взыскания.",
                .dutch: "Meestal een officiële melding over betaling van een boete of invorderingsstap."
            ],
            possibleDeadline: [
                .english: "Deadline: payment or objection date is shown in the letter.",
                .russian: "Срок: дата оплаты или обжалования указана в письме.",
                .dutch: "Termijn: betaal- of bezwaar datum staat in de brief."
            ],
            safeNextStep: [
                .english: "Do not pay through random links. Check the letter number and payment details on cjib.nl first.",
                .russian: "Не платите по случайным ссылкам. Сначала проверьте номер письма и реквизиты на cjib.nl.",
                .dutch: "Betaal niet via willekeurige links. Controleer eerst briefnummer en betaalgegevens op cjib.nl."
            ],
            officialSourceReminder: [
                .english: "Verify authenticity on the official CJIB website.",
                .russian: "Подлинность проверяйте на официальном сайте CJIB.",
                .dutch: "Controleer echtheid op de officiële CJIB-website."
            ]
        ),
        LetterExample(
            title: [.english: "DUO message", .russian: "Сообщение DUO", .dutch: "Bericht van DUO"],
            institutionName: [.english: "DUO", .russian: "DUO", .dutch: "DUO"],
            simplifiedExplanation: [
                .english: "May relate to study status, student finance, or an inburgering process.",
                .russian: "Может касаться статуса обучения, студенческих выплат или inburgering-процесса.",
                .dutch: "Kan gaan over studiegegevens, studiefinanciering of inburgering."
            ],
            possibleDeadline: [
                .english: "Deadline: shown in the DUO message.",
                .russian: "Срок: указан в сообщении DUO.",
                .dutch: "Termijn: staat in het DUO-bericht."
            ],
            safeNextStep: [
                .english: "Open your DUO account and check which action is required.",
                .russian: "Откройте личный кабинет DUO и проверьте, какое действие требуется.",
                .dutch: "Open uw DUO-account en controleer welke actie nodig is."
            ],
            officialSourceReminder: [
                .english: "Check final requirements only on duo.nl.",
                .russian: "Финальные требования проверяйте только на duo.nl.",
                .dutch: "Controleer definitieve vereisten alleen op duo.nl."
            ]
        ),
        LetterExample(
            title: [.english: "Health insurance letter", .russian: "Письмо о медицинской страховке", .dutch: "Brief over zorgverzekering"],
            institutionName: [.english: "Government.nl / CAK", .russian: "Government.nl / CAK", .dutch: "Government.nl / CAK"],
            simplifiedExplanation: [
                .english: "Usually reminds you to check whether Dutch basic health insurance is required.",
                .russian: "Обычно напоминает проверить обязанность по zorgverzekering или оформить полис.",
                .dutch: "Herinnert u meestal om te controleren of basiszorgverzekering verplicht is."
            ],
            possibleDeadline: [
                .english: "Deadline: depends on your situation and is shown in the letter.",
                .russian: "Срок: зависит от вашей ситуации и указан в письме.",
                .dutch: "Termijn: hangt af van uw situatie en staat in de brief."
            ],
            safeNextStep: [
                .english: "Compare your situation with official insurance rules and act promptly.",
                .russian: "Сверьте свою ситуацию с официальными правилами страхования и действуйте сразу.",
                .dutch: "Vergelijk uw situatie met officiële verzekeringsregels en handel op tijd."
            ],
            officialSourceReminder: [
                .english: "Verify requirements through government.nl and official insurance channels.",
                .russian: "Проверяйте требования через government.nl и официальные каналы страхования.",
                .dutch: "Controleer vereisten via government.nl en officiële verzekeringskanalen."
            ]
        ),
        LetterExample(
            title: [.english: "Rental housing letter", .russian: "Письмо по аренде жилья", .dutch: "Brief over huurwoning"],
            institutionName: [.english: "Housing corporation / Landlord", .russian: "Woningcorporatie / Verhuurder", .dutch: "Woningcorporatie / Verhuurder"],
            simplifiedExplanation: [
                .english: "May concern rent increase, inspection, contract terms, or payment.",
                .russian: "Может касаться повышения аренды, проверки жилья, условий договора или оплаты.",
                .dutch: "Kan gaan over huurverhoging, inspectie, contractvoorwaarden of betaling."
            ],
            possibleDeadline: [
                .english: "Deadline: check the response or payment date in the letter.",
                .russian: "Срок: смотрите дату ответа/оплаты в письме.",
                .dutch: "Termijn: controleer de reactie- of betaaldatum in de brief."
            ],
            safeNextStep: [
                .english: "Check what action is required and ask the landlord in writing if anything is unclear.",
                .russian: "Проверьте, какое действие требуется, и при сомнениях уточните у арендодателя письменно.",
                .dutch: "Controleer welke actie nodig is en vraag schriftelijk uitleg als iets onduidelijk is."
            ],
            officialSourceReminder: [
                .english: "For disputes and tenant rights, check Huurcommissie and Juridisch Loket resources.",
                .russian: "Для споров и прав арендатора проверяйте официальные ресурсы Huurcommissie и Juridisch Loket.",
                .dutch: "Controleer bij geschillen en huurdersrechten Huurcommissie en Juridisch Loket."
            ]
        )
    ]
}
