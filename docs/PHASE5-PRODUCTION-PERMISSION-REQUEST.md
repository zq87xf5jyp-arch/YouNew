# YouNew Phase 5 — запрос отдельного разрешения на production deployment

Production deployment **не разрешён** этим документом. Владелец должен сверить `release-artifacts/controlled-launch-2026-10-24/RELEASE-MANIFEST.json` и явно подтвердить точный SHA-256 публичного архива.

Разрешение должно выглядеть так:

> РАЗРЕШАЮ PHASE 5 PRODUCTION DEPLOYMENT `<archive_sha256>` в пределах публичного статического пакета. До публикации обязательны production DB backup, Storage inventory + payload copy и успешный disposable restore. Production database migrations, публикация `amsterdam-v0.1.9`, B2B-рассылка, изменение DNS и удаление пользовательских данных этим разрешением не разрешаются.

После такого ответа исполнитель обязан повторно сверить hash, выполнить live-only backup gates, зафиксировать smoke/E2E и откатить пакет при любом stop condition. Любой другой scope требует отдельного разрешения.
