import Foundation

enum MockOnboardingFlows {
    static let educationalTips: [String] = [
        "Неделя 1: адрес, BSN и DigiD — основа большинства сервисов.",
        "Официальные письма лучше читать в день получения.",
        "Для каждого города правила gemeente могут отличаться.",
        "Для важных шагов всегда открывайте официальный сайт напрямую."
    ]

    static let journeys: [OnboardingFlow] = [
        OnboardingFlow(profileType: .worker, periods: firstMonthFlow),
        OnboardingFlow(profileType: .student, periods: firstMonthFlow),
        OnboardingFlow(profileType: .refugeeStatusHolder, periods: firstMonthFlow),
        OnboardingFlow(profileType: .expat, periods: firstMonthFlow),
        OnboardingFlow(profileType: .temporaryWorker, periods: firstMonthFlow)
    ]

    static func flow(for profile: ProfileType) -> OnboardingFlow? {
        journeys.first(where: { $0.profileType == profile })
    }

    // MARK: - First Month in NL
    // Универсальный базовый маршрут, затем пользователь уточняет шаги по своему профилю.
    private static let firstMonthFlow: [OnboardingFlowPeriod] = [
        OnboardingFlowPeriod(periodTitle: "Неделя 1", steps: [
            OnboardingFlowStep(
                title: "Зарегистрируйте адрес в gemeente",
                beginnerExplanation: "Без регистрации часто нельзя полноценно завершить остальные шаги.",
                estimatedImportance: "Высокая",
                commonMistake: "Откладывать запись и пропускать локальные сроки."
            ),
            OnboardingFlowStep(
                title: "Получите BSN",
                beginnerExplanation: "BSN нужен для работы, налогов, страховки и банковских процессов.",
                estimatedImportance: "Высокая",
                commonMistake: "Думать, что BSN везде оформляется одинаково."
            ),
            OnboardingFlowStep(
                title: "Поймите, как работает DigiD",
                beginnerExplanation: "DigiD — ваш вход в госкабинеты: налоги, DUO, UWV и другие сервисы.",
                estimatedImportance: "Высокая",
                commonMistake: "Переходить по случайным ссылкам вместо официального домена."
            )
        ]),
        OnboardingFlowPeriod(periodTitle: "Неделя 2", steps: [
            OnboardingFlowStep(
                title: "Оформите медицинскую страховку",
                beginnerExplanation: "Проверьте, когда в вашей ситуации начинается обязанность страхования.",
                estimatedImportance: "Высокая",
                commonMistake: "Ждать слишком долго после регистрации."
            ),
            OnboardingFlowStep(
                title: "Откройте банковский счёт",
                beginnerExplanation: "Счёт обычно нужен для зарплаты, аренды и официальных оплат.",
                estimatedImportance: "Средняя",
                commonMistake: "Не проверять реквизиты и назначение платежа."
            ),
            OnboardingFlowStep(
                title: "Освойте транспортные основы",
                beginnerExplanation: "Разберитесь с OV-chipkaart, check-in/check-out и правилами штрафов.",
                estimatedImportance: "Средняя",
                commonMistake: "Путать оплату поездки и правила валидатора."
            )
        ]),
        OnboardingFlowPeriod(periodTitle: "Неделя 3", steps: [
            OnboardingFlowStep(
                title: "Разберитесь с налогами",
                beginnerExplanation: "Belastingdienst может прислать письма со сроками ответа или оплаты.",
                estimatedImportance: "Средняя",
                commonMistake: "Игнорировать письмо из-за сложной формулировки."
            ),
            OnboardingFlowStep(
                title: "Научитесь читать официальные письма",
                beginnerExplanation: "Сначала проверяйте отправителя, дату и дедлайн, потом действие.",
                estimatedImportance: "Высокая",
                commonMistake: "Считать письмо спамом и не открывать его."
            ),
            OnboardingFlowStep(
                title: "Проверьте городские сервисы gemeente",
                beginnerExplanation: "У каждого города — свои записи, формы и локальные правила.",
                estimatedImportance: "Средняя",
                commonMistake: "Опираться на правила другого города."
            )
        ]),
        OnboardingFlowPeriod(periodTitle: "Неделя 4", steps: [
            OnboardingFlowStep(
                title: "Проверьте пособия (toeslagen)",
                beginnerExplanation: "Некоторые пособия зависят от дохода, адреса и состава домохозяйства.",
                estimatedImportance: "Средняя",
                commonMistake: "Не обновлять данные после изменений дохода или адреса."
            ),
            OnboardingFlowStep(
                title: "Поймите рабочую систему",
                beginnerExplanation: "Проверьте контракт, payslip, отпускные и больничные правила.",
                estimatedImportance: "Средняя",
                commonMistake: "Подписывать договор, не уточнив тип контракта и условия оплаты."
            ),
            OnboardingFlowStep(
                title: "Закрепите основы здравоохранения",
                beginnerExplanation: "Разница между huisarts, аптекой и экстренной помощью экономит время и стресс.",
                estimatedImportance: "Средняя",
                commonMistake: "Использовать 112 для неэкстренных вопросов."
            )
        ])
    ]
}
