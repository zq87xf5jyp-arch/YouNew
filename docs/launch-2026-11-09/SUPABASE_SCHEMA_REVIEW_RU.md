# Кандидат для человеческого review старой PostgreSQL-схемы

**Статус: ОДОБРЕН владельцем 09.11.2026 для фиксации в CI.** Это проверка сохранённого старого Admin, не миграция production и не новая зависимость сайта от Supabase.

Основа: commit `770d506e202ccf4e188038b600802aed4b6313ee`, [изолированный CI 42637172397](https://github.com/zq87xf5jyp-arch/YouNew/actions/runs/42637172397). Реальные Supabase данные, ключи и удалённый проект не использовались.

Полный исходный diff: [supabase-schema-delta-candidate.json](supabase-schema-delta-candidate.json), SHA-256 `a98ef27665962e87db9b4c8d460081a164f8cbfcce8eb9ca78c98d8d01b12169`. Исходный кандидат сохранён неизменным. Владелец явно одобрил этот digest в чате. Проверяемый manifest `admin-dashboard/supabase/verification/admin-schema-reviewed-delta.json` закрепляет его содержимое со статусом `reviewed` и записью об одобрении.

Код проверки `admin-dashboard/scripts/validate-admin-schema-inventory.py` требует: “after a human reviews the first disposable run”. Это требование выполнено явным ответом владельца; числа объектов и названия сами по себе не использовались как одобрение.

| Тип объекта | Добавлено | Удалено | Изменено |
| --- | ---: | ---: | ---: |
| Relation | 14 | 0 | 0 |
| Column | 173 | 0 | 1 |
| Constraint | 39 | 0 | 2 |
| Function | 19 | 0 | 5 |
| Index | 15 | 0 | 0 |
| Policy | 22 | 8 | 4 |
| Table grant | 251 | 62 | 0 |
| Column grant | 2128 | 289 | 0 |
| Routine grant | 22 | 3 | 0 |
| Default ACL | 0 | 8 | 0 |
| Всего | 2683 | 370 | 12 |

Изменённые существующие определения:

- `public.sync_jobs.started_at` и constraint статуса sync_jobs.
- Constraint допустимых source_page для business_inquiries.
- Функции `enqueue_article_publication`, `request_content_sync`, `submit_business_inquiry`, `submit_public_feedback`, `transition_content_review_task`.
- Три политики insert/update/delete для articles и чтение storage.objects «admins read private files».

Точки проверки безопасности:

- Новых grant для PUBLIC нет. Единственное новое чтение для anon — `legacy_map_points_read_only` и 15 его колонок. Представление имеет `security_invoker=true` и использует RLS исходной map_points. Его следует оценивать вместе с политикой публикации исходной таблицы.
- Политики articles ограничивают editor состояниями draft/review/qa; owner/admin сохраняют управление. Политики content-images запрещают editor менять опубликованные изображения. Приватное чтение storage ограничено bucket content и approved Admin.
- Новые private.content_sync_executions и функции кандидата используют lease, ограничение до трёх попыток и отдельные операции завершения/ошибки. Это не доказательство работы Hostinger cron.
- Большинство добавлений — подробные table/column grants и новые аналитические views. Доступ к реальному Supabase не расширялся.

Фактические результаты изолированного прогона:

- Все 404 проверки полного набора pgTAP прошли; отдельные core/compliance/geo проверки не суммируются с ними как уникальные тесты.
- Зашифрованный backup синтетических данных восстановлен: 52 migration records, 43 public tables, 98 public policies. Точное сравнение application schema/security inventory прошло.
- 36 локальных платформенных default ACL для supabase_admin → anon/authenticated/service_role намеренно удаляются подготовкой disposable target. В целевой схеме их нет; реальные table/routine grants, определения политик и остальные fingerprints сравниваются точно.
- Повторная локальная проверка точного diff с одобренным manifest прошла. Следующий CI проверит это заново. Неактивный удалённый Supabase и его реальные backups этим синтетическим прогоном не проверены.

Одобрение владельца относится именно к этому diff и digest. Manifest закреплён; CI повторяется. Это не разрешает активировать Supabase или применить миграции к реальным данным.

Gitleaks распознал 28 вхождений определений PostgreSQL как generic API keys из-за имён колонок token/key. Все значения сверены с исходным schema inventory: это 23 конкретных MD5 определения, а не секреты. Конфигурация сохраняет все стандартные правила и исключает только эти 23 значения в двух точных путях manifest/candidate одновременно. Проверено, что неизвестное значение в том же файле и известное значение в другом файле по-прежнему обнаруживаются. Сканирование подготовленного commit прошло.
