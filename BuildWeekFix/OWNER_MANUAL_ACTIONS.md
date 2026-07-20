# Owner manual actions

Ниже перечислены только решения и внешние действия, которые release coordinator
не может безопасно выполнить вместо владельца.

## Product ownership and rights

1. Подтвердить intended Build Week product state для ранее начатых локальных
   изменений.
2. Решить, должно ли удаление
   `IA_Audit_Screenshots/strict-reference-pass/02-refined-home.png` войти в
   repository snapshot. Не восстанавливать и не фиксировать это удаление по
   умолчанию.
3. Подтвердить права на собственный код и contributor contributions, затем одобрить
   текущий restrictive `LICENSE` либо предоставить юридически проверенную замену.
4. Предоставить доказательства происхождения и условий использования AppIcon,
   screenshots и всех unresolved media; всё неподтверждённое заменить
   rights-cleared материалом или исключить из public repository и demo.
5. Одобрить финальные privacy, legal, medical и media disclosures, включая
   применимые GDPR-роли, retention policy, support URL и privacy-policy URL.

## GitHub and judge access

6. Выбрать окончательное имя и private/public visibility repository.
7. Вручную создать GitHub repository без автоматической генерации расходящихся
   README, license или ignore-файлов.
8. После проверки curated snapshot вручную добавить remote и отдельно подтвердить
   первый push. Ни remote, ни push не должны выполняться по подразумеваемому
   согласию.
9. Настроить branch protection и предоставить судьям минимальный Read-доступ по
   официально подтверждённым аккаунтам.
10. Подтвердить, допустимы ли для публикации Git author metadata, signing-team
    metadata и выбранный security contact.

## Live AI backend

11. Предоставить backend credential только через защищённое secret-хранилище
    выбранного hosting provider; не передавать credential в repository, iOS bundle,
    отчёт, screenshot или чат.
12. Подтвердить, что используемый OpenAI account имеет реальный доступ к выбранной
    GPT-5.6 model configuration.
13. Выбрать hosting account, region, retention, access-control, rate-limit и abuse
    policy, затем отдельной командой разрешить backend deployment.
14. Предоставить owner-approved HTTPS endpoint для финальной конфигурации demo и
    разрешить обезличенную runtime-проверку фактически возвращённых model metadata
    и request ID.

## Distribution and submission

15. Настроить Apple signing, certificates и provisioning вне repository, если
    нужен device, TestFlight или App Store build.
16. Предоставить финальные rights-cleared App Store/TestFlight screenshots и
    заполнить обязательные privacy/distribution declarations.
17. Записать основной live demo video и отдельное fallback evidence без credentials,
    personal data, notifications или неподтверждённых media.
18. Отдельно подтвердить и вручную выполнить требуемые upload, TestFlight/App Store
    release actions и OpenAI Build Week submission.

Создание remote, push, deployment, release и submission требуют отдельного явного
подтверждения владельца; этот документ не является таким подтверждением.
