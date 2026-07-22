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
3. Решить судьбу всех 39 уже tracked captures (13 IA Audit, 5 QA Baseline и 21
   Runtime, около 91 MB) после OCR/privacy/media review; правило `.gitignore`
   не исключит их из будущего remote. Отдельно подтвердить или отклонить текущие
   public-site, `.gitignore`, lockfile и семь untracked public-site media changes,
   которые не входят в evidence commit.
4. Подтвердить права на собственный код и contributor contributions, затем одобрить
   текущий restrictive `LICENSE` либо предоставить юридически проверенную замену.
5. Shipped asset catalog уже имеет 170 governed records и ноль unresolved assets;
   AppIcon подтверждён owner attestation. Отдельно инвентаризировать screenshots,
   recordings, audio, public-site media и другой non-catalog release content;
   неподтверждённое заменить или исключить из публикации/demo.
- Принять release-data решение по 18 подтверждённым недоступным URL в shipped
  runtime data (30 published entities, 85 field occurrences): подтвердить
  проверенные replacement sources/media или разрешить их исключение, затем
  одобрить versioned `amsterdam-v0.1.1` remediation и fresh network verification.
  Нельзя удалять или обнулять generated link evidence ради зелёного отчёта.
6. Одобрить финальные privacy, legal, medical и media disclosures, включая
   применимые GDPR-роли, retention policy, support URL и privacy-policy URL.

## GitHub and judge access

7. Выбрать окончательное имя и private/public visibility repository.
8. Вручную создать GitHub repository без автоматической генерации расходящихся
   README, license или ignore-файлов.
9. После проверки curated snapshot вручную добавить remote и отдельно подтвердить
   первый push. Ни remote, ни push не должны выполняться по подразумеваемому
   согласию.
10. Настроить branch protection и предоставить судьям минимальный Read-доступ по
   официально подтверждённым аккаунтам.
11. Подтвердить, допустимы ли для публикации Git author metadata, signing-team
    metadata и выбранный security contact.

## Live AI backend

12. Предоставить backend credential только через защищённое secret-хранилище
    выбранного hosting provider; не передавать credential в repository, iOS bundle,
    отчёт, screenshot или чат.
13. Подтвердить, что используемый OpenAI account имеет реальный доступ к выбранной
    модели `gpt-5.6-sol`; для runtime proof не использовать недоказанную подмену
    модели или fixture как live ответ.
14. Выбрать privacy-safe design для стабильного `safety_identifier` (например,
    opaque per-install ID с документированным reset), hosting account, region,
    retention, access-control, rate-limit и abuse policy, затем отдельной командой
    разрешить backend deployment.
15. Предоставить owner-approved HTTPS endpoint для финальной конфигурации demo и
    разрешить обезличенную runtime-проверку фактически возвращённых `gpt-5.6-sol`
    metadata и request ID.

## Distribution and submission

16. Настроить Apple signing, certificates и provisioning вне repository, если
    нужен device, TestFlight или App Store build.
17. Предоставить финальные отдельно проверенные App Store/TestFlight screenshots,
    сохранить требуемые photo credits/modification notices и заполнить обязательные
    privacy/distribution declarations. Catalog PASS сам по себе не очищает screenshots.
18. Записать основной live demo video и отдельное fallback evidence без credentials,
    personal data или notifications; провести отдельный release-media review
    итогового видео и использованных кадров.
19. Отдельно подтвердить и вручную выполнить требуемые upload, TestFlight/App Store
    release actions и OpenAI Build Week submission.

Создание remote, push, deployment, release и submission требуют отдельного явного
подтверждения владельца; этот документ не является таким подтверждением.
