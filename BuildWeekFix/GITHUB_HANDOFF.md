# GitHub handoff plan

Дата подготовки: 2026-07-21 (Europe/Amsterdam)
Рабочая ветка: `build-week-readiness`
Базовый commit: `b15a2f2913911763c989f9880f8ce376f903fc6e`
Historical tested source commit: `61e7ce112669f8a6577b5b7d75f4d7cbdfe18459`
Последний closed clean-clone UI snapshot: `efd1a7c50bf7b5e2f82be047b084b6d73cb009a7` — **84/87 RED**
Текущий product/test source: `da8c3fe22e7a5d99b2187aab1141700b2d34f508`

> Исторический 82/87 result ниже не относится к текущему source. Для `da8c3fe2`
> требуется отдельный полный serial UI aggregate. Кроме offline clean-clone static
> evidence, существует отдельный current Data Health blocker: 18 confirmed broken
> URLs в shipped runtime data; он не скрывается удалением generated evidence.

## Решение на текущем этапе

Предлагаемое имя repository: **`younew-build-week-2026`**.

Рекомендуемая начальная видимость: **private**. Переход в public допустим только
после подтверждения владельцем прав на код и медиа, проверки staged diff и Git
history, зелёного clean-clone proof и предоставления судьям корректного доступа.
Наличие приватного repository не устраняет лицензионные ограничения: судьям также
нельзя передавать материалы, на распространение которых нет подтверждённых прав.

На момент составления документа:

- Git remote отсутствует;
- remote, GitHub repository, push, release и deployment не создавались;
- intended product/readiness snapshot локально зафиксирован; essential product
  files больше не зависят от untracked состояния;
- исходный working tree намеренно остаётся dirty: кроме evidence-документов, он
  содержит отдельный большой набор пользовательских изменений public-site,
  root-level IA/content exports, изменения `.gitignore`, deletions и untracked
  files. Они не входят в автоматически разрешённый handoff scope;
- удаление `YouNew/Services/PremiumInteractionServices.swift` классифицировано как
  **essential intentional deletion**: файл из baseline повторно объявляет
  `ConnectivityStatus`, а актуальная реализация типа находится в dedicated
  `YouNew/Services/ConnectivityStatus.swift`; возврат старого файла создаёт
  duplicate `ConnectivityStatus` symbol/type declaration;
- удаление `IA_Audit_Screenshots/strict-reference-pass/02-refined-home.png`
  остаётся unresolved owner decision и не должно автоматически попадать в commit;
- права на часть изображений подтверждены не полностью;
- staged scan 308-path source snapshot и последующие targeted checks не нашли
  подтверждённого секрета; dedicated scanner, binary/OCR/EXIF и owner metadata
  review по-прежнему не выполнены;
- live GPT-5.6 нельзя считать runtime-подтверждённым без доступного backend
  environment и фактического ответа API.

Следовательно, текущий working tree всё ещё **нельзя отправлять целиком** через
`git add -A`, GitHub Desktop “Commit all” или аналогичное действие.

## Local commit record

Локально созданы только commits в `build-week-readiness`; remote и push отсутствуют:

1. `ab358e56` — curated Build Week source snapshot;
2. `81f08cf4` — clean-clone-safe DataProject manifest/import ordering;
3. `303652d9` — first dynamic article resolver correction;
4. `347c9cc8` — actor-safe dynamic resolver/test form;
5. `49acdc66` — UI navigation remediation snapshot;
6. `61e7ce11` — root-tab invalidation reduction, connectivity prewarm, regression
   tests, and latency diagnostics used by the current clean-clone product gates;
7. `efd1a7c5` — restrict the GPT-5.6 client/backend allowlist and fixtures to the
   documented alias and Sol resolution; unconfirmed variants are rejected;
8. `9b74a236` — harden canonical OpenAI Responses completion validation and
   improve bounded UI-query diagnostics;
9. `da8c3fe2` — repair a compile-only Gallery diagnostic string in the UI test;
10. final evidence-only commit — **PENDING** only final exact-path safety checks and
    local documentation commit. No historic UI total is inherited by current code.

Commit 3 is retained as honest local history: its central lookup built successfully
but emitted actor-isolation warnings, corrected by commit 4. No history rewrite,
remote creation, or push is authorized by this document. The owner may later approve
an interactive squash/rebase before first push after reviewing the exact diff.

## Exact commit allowlist

Этот allowlist использован для локального curated snapshot и остаётся границей для
любого последующего history cleanup или remote-facing commit. Он не разрешает push.
Существующие tracked-файлы из базового commit остаются частью repository; список
ниже определяет, какие изменения и новые файлы относятся к intended handoff scope.

### 1. Repository policy и judge documentation

```text
.gitignore
.env.example
LICENSE
README.md
SECURITY.md
PRIVACY.md
MEDIA_ATTRIBUTION.md
PRIVACY_POLICY.md
TERMS_OF_USE.md
APP_STORE_PACKAGE.md
docs/LIVE_DATA_API.md
```

Следующие уже tracked документы также входят в **final evidence-only** commit
только потому, что из них были удалены machine-local paths или уточнён
проверенный backend model contract. Они не меняют product source:

```text
APPSTORE_CERTIFICATION.md
DEVICE_RUNTIME_REPORT.md
TESTFLIGHT_CERTIFICATION.md
BackendExamples/README.md
```

Restrictive no-grant `LICENSE` уже tracked локально, но его remote-публикация и
любая будущая permissive/open-source лицензия требуют отдельного подтверждения
владельца. Текущий текст не предоставляет права на третьесторонние медиа, которые
владелец не вправе лицензировать.

### 2. Audit и remediation evidence

Полный исходный audit packet:

```text
BuildWeekAudit/AI_ASSISTANT_ARCHITECTURE.md
BuildWeekAudit/BUILD_WEEK_READINESS.md
BuildWeekAudit/CODEX_EVIDENCE.md
BuildWeekAudit/CONTENT_RELEASE_EVIDENCE.md
BuildWeekAudit/MISSING_EVIDENCE.md
BuildWeekAudit/OWNER_ACTIONS.md
BuildWeekAudit/PUBLIC_FACTS.json
BuildWeekAudit/REPOSITORY_SECURITY_AUDIT.md
BuildWeekAudit/TECHNICAL_AUDIT.md
BuildWeekAudit/TEST_AND_QA_EVIDENCE.md
```

Финальный remediation packet:

```text
BuildWeekFix/BASELINE.md
BuildWeekFix/TEST_REMEDIATION.md
BuildWeekFix/GPT56_INTEGRATION_EVIDENCE.md
BuildWeekFix/DEMO_FLOW_EVIDENCE.md
BuildWeekFix/SECRET_SCAN.md
BuildWeekFix/MEDIA_RIGHTS.md
BuildWeekFix/DATA_HEALTH_BLOCKER.md
BuildWeekFix/CLEAN_CLONE_PROOF.md
BuildWeekFix/GITHUB_HANDOFF.md
BuildWeekFix/EVIDENCE_PREMIUM_IMAGE_PIPELINE.md
BuildWeekFix/EVIDENCE_INTERACTIVE_MAP.md
BuildWeekFix/EVIDENCE_CONTENT_PLATFORM.md
BuildWeekFix/EVIDENCE_CITIES_RELEASE.md
BuildWeekFix/EVIDENCE_QA_AUTOMATION.md
BuildWeekFix/FINAL_READINESS.md
BuildWeekFix/FINAL_PUBLIC_FACTS.json
BuildWeekFix/OWNER_MANUAL_ACTIONS.md
```

До commit все evidence-файлы должны быть проверены на отсутствие локальных
абсолютных путей, device identifiers, секретов, персональных данных и заявлений,
которые не подтверждены приложенными результатами.

### 3. Essential iOS product files originally untracked

Следующие пути зафиксированы baseline как необходимые для сборки и поведения
текущего filesystem-synchronized Xcode target; named demo добавлен в ходе
remediation:

```text
YouNew/App/Navigation/DiscoveryMenuRouting.swift
YouNew/Core/AppPublicLinks.swift
YouNew/Core/DesignSystem/Tokens/AppHaptics.swift
YouNew/Core/Interaction/PremiumProvinceHitTesting.swift
YouNew/Data/LicensedPartnerMediaRegistry.swift
YouNew/Data/PremiumKnowledgeSeedData.swift
YouNew/Data/VerifiedLeidenVenueData.swift
YouNew/Models/BusinessPortalModels.swift
YouNew/Models/DiscoveryEventFilter.swift
YouNew/Resources/Data/younew-runtime-data.json
YouNew/Services/BuildWeekNewcomerDemo.swift
YouNew/Services/DataProjectRuntimeLoader.swift
YouNew/Services/HomeBusinessSyncService.swift
YouNew/Services/HomePlaceSyncService.swift
YouNew/Services/HomeWeatherService.swift
YouNew/Services/KnowledgeDataGovernance.swift
YouNew/Services/KnowledgeDataHealthService.swift
YouNew/Services/VisitLeidenCalendarService.swift
YouNew/Views/BusinessPortalViews.swift
YouNew/Views/DiscoverySideMenu.swift
YouNew/Views/HomePremiumInformationCard.swift
YouNew/Views/TypedCategorySectionView.swift
```

Включение `YouNew/Data/LicensedPartnerMediaRegistry.swift` не является само по себе
доказательством прав на соответствующие файлы изображений.

### 4. Essential tests originally untracked

```text
YouNewTests/BuildWeekNewcomerDemoTests.swift
YouNewTests/BusinessPortalTests.swift
YouNewTests/DataProjectRuntimeBaselineTests.swift
YouNewTests/DiscoveryEventFilterTests.swift
YouNewTests/DiscoveryMenuRoutingTests.swift
YouNewTests/KnowledgeDataGovernanceTests.swift
YouNewTests/LiveDataIntegrationTests.swift
YouNewTests/PremiumProvinceHitTestingTests.swift
YouNewTests/PublicReleaseLinksTests.swift
YouNewTests/PublishedCitiesDataReleaseTests.swift
YouNewTests/TypedCategoryRouteSerializationTests.swift
YouNewTests/VerifiedLeidenVenueTests.swift
YouNewTests/VisitLeidenCalendarParserTests.swift
YouNewUITests/CategoryRoutingRuntimeUITests.swift
YouNewUITests/PublishedCitiesRuntimeUITests.swift
```

Offline fallback test для named demo добавлен в существующий
`YouNewUITests/YouNewUITests.swift` и имеет отдельный успешный targeted run. Сам
файл уже входит в tracked remediation scope ниже; полный UI gate по финальному
snapshot остаётся обязательным.

### 5. Tracked remediation deltas

Ниже перечислен минимальный известный набор изменённых tracked-файлов для
исправленных gates и AI/demo-контракта. Он не заменяет review остальных 119
изменённых путей, перечисленных в `BuildWeekFix/BASELINE.md`.

```text
YouNew.xcodeproj/project.pbxproj
YouNew/App/AppEntry.swift
YouNew/App/AppTabView.swift
YouNew/App/Navigation/AppDestinationView.swift
YouNew/Data/MockLocalPartnersData.swift
YouNew/Data/NetherlandsData.swift
YouNew/Models/AIContext.swift
YouNew/Models/TabRouter.swift
YouNew/Services/AIClient.swift
YouNew/Services/AIResponseParser.swift
YouNew/Services/AISafetyFilter.swift
YouNew/Services/AIService.swift
YouNew/Services/ConnectivityStatus.swift
YouNew/Services/PremiumInteractionServices.swift
YouNew/ViewModels/AIViewModel.swift
YouNew/Views/AIAssistantView.swift
YouNew/Views/RootHomeView.swift
YouNew/Views/SearchView.swift
YouNewTests/AIFoundationTests.swift
YouNewTests/KnowledgeIndexTests.swift
YouNewTests/TabRouterTests.swift
YouNewUITests/CategoryRoutingRuntimeUITests.swift
YouNewUITests/ContentCompletionRuntimeUITests.swift
YouNewUITests/MapChipUITests.swift
YouNewUITests/PublishedCitiesRuntimeUITests.swift
YouNewUITests/RootNavigationUITests.swift
YouNewUITests/YouNewUITests.swift
scripts/apple-review-static-qa.py
scripts/brand-static-qa.py
scripts/content-static-qa.py
scripts/persona-ia-static-qa.py
```

Для `YouNew/Services/PremiumInteractionServices.swift` allowlisted change — именно
удаление, а не восстановление: dedicated `ConnectivityStatus.swift` является
единственным владельцем `ConnectivityStatus`.

Изменения остальных tracked product-файлов допустимы в product-freeze commit
только если владелец подтверждает, что именно эта версия является intended Build
Week product state, а clean-clone сборка и полный набор tests воспроизводят её.
Точным исходным inventory для этого review служит секция “Tracked changes” в
`BuildWeekFix/BASELINE.md`; добавлять весь список без просмотра нельзя.

### 6. Backend implementation

Допустимый backend scope ограничен example/verification package:

```text
BackendExamples/cloudflare-worker-ai-proxy.js
BackendExamples/cloudflare-worker-ai-proxy.test.mjs
BackendExamples/package.json
BackendExamples/README.md
```

Добавлять следует только реально созданные и протестированные пути. В этих файлах
допустимы имена environment variables и placeholder-значения, но не credentials,
deployment tokens, account identifiers или фактический endpoint. Наличие кода в
этом scope не доказывает deployment или live GPT-5.6 runtime.

### 7. DataProject и reproducibility tooling

Canonical DataProject candidate set:

```text
DataProject/README.md
DataProject/QUALITY_SCORE.md
DataProject/batches/README.md
DataProject/batches/WP-01/M1-government-core-001.json
DataProject/batches/WP-01/M1-government-core-002.json
DataProject/batches/WP-01/M1-government-core-003.json
DataProject/batches/WP-01/M1-government-core-004.json
DataProject/batches/WP-01/M1-government-core-005.json
DataProject/batches/WP-01/M1-government-core-006.json
DataProject/batches/WP-01/M1-government-core-007.json
DataProject/batches/WP-01/M1-government-core-008.json
DataProject/batches/WP-01/M1-government-core-009.json
DataProject/batches/WP-02/M1-housing-buying-002.json
DataProject/batches/WP-02/M1-housing-renting-001.json
DataProject/batches/WP-02/M1-housing-tenant-rights-003.json
DataProject/batches/WP-02/M1-housing-utilities-004.json
DataProject/batches/WP-03/M1-healthcare-emergency-004.json
DataProject/batches/WP-03/M1-healthcare-hospitals-003.json
DataProject/batches/WP-03/M1-healthcare-insurance-002.json
DataProject/batches/WP-03/M1-healthcare-primary-care-001.json
DataProject/batches/WP-04/M1-transport-cycling-003.json
DataProject/batches/WP-04/M1-transport-parking-004.json
DataProject/batches/WP-04/M1-transport-payment-002.json
DataProject/batches/WP-04/M1-transport-rail-001.json
DataProject/batches/WP-05/M1-education-duo-003.json
DataProject/batches/WP-05/M1-education-higher-002.json
DataProject/batches/WP-05/M1-education-integration-004.json
DataProject/batches/WP-05/M1-education-schools-001.json
DataProject/batches/WP-06/M1-priority-cities-001.json
DataProject/batches/WP-06/M2-amsterdam-001.json
DataProject/coverage-dimensions.json
DataProject/coverage-targets.json
DataProject/milestones/WP-01/M1.json
DataProject/milestones/WP-02/M1.json
DataProject/milestones/WP-03/M1.json
DataProject/milestones/WP-04/M1.json
DataProject/milestones/WP-05/M1.json
DataProject/milestones/WP-06/M1.json
DataProject/milestones/WP-06/M2.json
DataProject/observability/consumer-registry.json
DataProject/observability/freshness-policy.json
DataProject/observability/migration-registry.json
DataProject/observability/release-manifest.schema.json
DataProject/observability/source-reliability-policy.json
DataProject/operations/issue-types.json
DataProject/operations/maturity-model.json
DataProject/operations/operations-policy.json
DataProject/operations/release-transition-policy.json
DataProject/operations/source-monitor-baseline.json
DataProject/operations/usage-events.json
DataProject/operations/usage-events.schema.json
DataProject/releases/releases.json
DataProject/schema/entity.schema.json
DataProject/templates/batch.template.json
DataProject/work-packages.json
```

Reproducibility scripts and CI candidate set:

```text
.github/workflows/data-project-health.yml
scripts/amsterdam-batch-qa.py
scripts/amsterdam-data-production.py
scripts/check-external-links.py
scripts/content-text-audit.py
scripts/data-dashboard-static-qa.py
scripts/data-health-gate.py
scripts/data-observability-static-qa.py
scripts/data-operations-static-qa.py
scripts/data-project-import-static-qa.py
scripts/data-project-qa.py
scripts/data-project-workflow-static-qa.py
scripts/generate-data-dashboard.py
scripts/generate-data-observability.py
scripts/generate-data-operations.py
scripts/import-data-project.py
scripts/route-content-audit.py
```

Generated `DataProject/reports/` не входит в blanket allowlist. Конкретный отчёт
можно добавить только если команда генерации документирована, повторный запуск
даёт нулевой diff, файл не содержит локальных/чувствительных данных и он нужен для
judge evidence. Release manifests допустимы по тому же правилу, с отдельной
проверкой источников и лицензий.

Root-файлы `knowledge_data_health.json` и `broken_links.csv` являются generated
network evidence и не входят в snapshot. Offline clean-clone gate воспроизводим
без них: `scripts/generate-data-dashboard.py` использует явный
`OFFLINE_LINK_EVIDENCE` sentinel с epoch timestamp и нулевыми счётчиками, а
`scripts/data-dashboard-static-qa.py` проверяет наличие этого контракта. Sentinel
не является доказательством сетевой проверки: команда
`scripts/data-health-gate.py --require-network` по-прежнему требует свежий
фактический network result и отклоняет offline sentinel.

### 8. Public-site boundary for aggregate static QA

`scripts/run-static-qa.sh` безусловно запускает public-site check. Результат 40/40
относится к exact tracked public-site tree в commit `61e7ce11`; он не разрешает
переносить текущие отдельные пользовательские изменения целиком. Перед remote
следует сформировать commit-bound manifest этих tracked путей:

```text
admin-dashboard/public-site/.gitignore
admin-dashboard/public-site/next-env.d.ts
admin-dashboard/public-site/next.config.ts
admin-dashboard/public-site/package.json
admin-dashboard/public-site/postcss.config.mjs
admin-dashboard/public-site/scripts/build.sh
admin-dashboard/public-site/src/  # only exact paths already present in the tested commit
admin-dashboard/public-site/tailwind.config.ts
admin-dashboard/public-site/tsconfig.json
admin-dashboard/public-site/worker/index.js
```

Это inclusion протестированной версии исходного кода не является deployment
evidence. Текущие modified/untracked public-site routes, components, generated data,
lockfile и scripts требуют отдельного owner review и нового clean-clone proof.
`public/` media остаются вне snapshot до file-by-file подтверждения прав или замены
rights-cleared материалами; build output и hosting metadata также исключены.

## Explicit exclusions

Не добавлять в proposed commits:

```text
TestArtifacts/
DataProject/staging/
DerivedData/
.DerivedData*/
.derivedData*/
.SwiftModuleCache/
.SwiftTypecheckModuleCache/
*.xcresult
*.xcarchive
*.dSYM
*.dSYM.zip
*.ipa
*.log
.env
.env.* (except reviewed `.env.example` templates)
.dev.vars
.dev.vars.* (except reviewed `.dev.vars.example` templates)
.wrangler/
*.p12
*.pfx
*.pem
*.key
*.mobileprovision
*.provisionprofile
*.cer
*.crt
*.der
admin-dashboard/**/node_modules/
admin-dashboard/**/.next/
admin-dashboard/**/out/
admin-dashboard/public-site/.openai/
admin-dashboard/public-site/tsconfig.tsbuildinfo
admin-dashboard/public-site/public/icons/
admin-dashboard/public-site/public/images/
.pnpm-store/
netherlands_app_images/
netherlands_app_images_v*.zip
IA_Audit_Screenshots/
QA_Baseline_Screenshots/
Runtime_Screenshots/
knowledge_data_health.json
broken_links.csv
```

Правила ignore для capture-каталогов скрывают только новые локальные файлы: commit
уже содержит 39 tracked raster captures общей величиной 91,034,208 B — 13 IA Audit
(41,411,859 B), пять QA Baseline (8,214,510 B) и 21 Runtime (41,407,839 B). Они
попадут в remote, если владелец не одобрит sanitized snapshot, removal или retention
после OCR/privacy/media review. Одно пользовательское удаление внутри IA-набора
остаётся unstaged. Для README следует использовать только явно одобренные owner
screenshots с завершённой атрибуцией.

Текущий working tree также содержит семь untracked public-site images/icons. Они не
входят в reviewed app-media manifest и не должны попадать в evidence commit. Текущий
`.gitignore` больше не защищает `admin-dashboard/public-site/public/`, поэтому
исключение обеспечивается только explicit staged-path allowlist, а не ignore policy.

Отдельно заблокированы для blanket public-передачи до file-by-file подтверждения
происхождения и условий использования:

```text
nl_hoorn_card_01
city_*_flag (29 imagesets)
city_*_coat_of_arms (29 imagesets)
noord_holland_flag, zuid_holland_flag, utrecht_flag, gelderland_flag
noord_brabant_flag, limburg_flag, overijssel_flag, flevoland_flag
groningen_flag, friesland_flag, drenthe_flag, zeeland_flag
map_* (12 imagesets)
netherlands_map_base
netherlands_map_provinces
home_documents_city_hall
home_healthcare_pharmacy
home_leiden_canals
app_amsterdam_evening_background
home_emergency_ambulance
home_language_classroom
home_work_zuidas
premium_home_documents
premium_home_emergency
premium_home_healthcare
premium_home_housing
premium_home_language
premium_home_work
premium_netherlands_emergency_fallback
AppIcon.appiconset
```

Первые 72 manifest-backed `nl_*` assets также требуют проверки source-page terms;
65 из них требуют attribution, а у `nl_hoorn_card_01` отсутствует license URL.
Перечисленные выше non-`nl_*` группы составляют 98 imagesets вне manifest, плюс
AppIcon. `ASSET_CREDITS.md` и `PLACE_MEDIA_RENDER_AUDIT.md` дают противоречивое
описание происхождения части identity assets, поэтому ни один такой конфликт нельзя
разрешать предположением о project ownership.

Если эти blobs уже присутствуют в Git history, `.gitignore` не устраняет риск.
Перед public-переходом владелец должен подтвердить права, заменить материалы
rights-cleared версиями либо создать новый санитизированный repository snapshot.
Переписывание истории не входит в этот handoff и не должно выполняться без
отдельного решения владельца.

Также не включать без отдельной классификации:

- root CSV/JSON/Markdown audit exports, не указанные в allowlist;
- `Audit/` и старые runtime reports, которые могут выглядеть как актуальный PASS;
- остальную часть `admin-dashboard/` за пределами exact essential public-site
  source/config scope выше;
- `admin-dashboard/public-site/public/` media до подтверждения прав или замены;
- локальные базы, загруженные документы, simulator containers и diagnostics;
- любые credential values, backend secrets, real `.env`, deployment metadata,
  certificates или provisioning profiles;
- unresolved удаление
  `IA_Audit_Screenshots/strict-reference-pass/02-refined-home.png` до решения
  владельца. Essential deletion
  `YouNew/Services/PremiumInteractionServices.swift` в это исключение не входит.

## Proposed remote commit sequence

If the owner approves history cleanup before the first push, each remote-facing
commit is formed with a precise path allowlist, then checked through
`git diff --cached --name-status`, `git diff --cached --check` и staged secret
scan. Не использовать blanket staging.

1. **`docs: capture Build Week baseline and safety policy`**
   `.gitignore`, исходный `BuildWeekAudit/`, `BuildWeekFix/BASELINE.md`,
   `BuildWeekFix/SECRET_SCAN.md` и `BuildWeekFix/MEDIA_RIGHTS.md` после sanitation.
2. **`feat: freeze intended YouNew product state`**
   Подтверждённые владельцем tracked product changes и exact essential untracked
   iOS files; essential deletion `PremiumInteractionServices.swift` фиксируется
   вместе с dedicated `ConnectivityStatus.swift`, а удаление audit screenshot
   остаётся вне commit до отдельного решения владельца.
3. **`fix: close unit static and UI readiness regressions`**
   Узкий remediation delta, тесты и QA scripts вместе с
   `BuildWeekFix/TEST_REMEDIATION.md`.
4. **`feat: add bounded GPT-5.6 backend contract and local fallback`**
   AI client/model/view files, `BuildWeekNewcomerDemo`, backend example/tests и
   `.env.example`; commit message и evidence не должны утверждать deployment.
5. **`test: add BuildWeekNewcomerDemo verification`**
   Named-flow unit/integration/UI tests и demo evidence. Live proof включается
   только при реальном metadata/request ID без раскрытия данных или credentials.
6. **`data: add canonical content inputs and reproducible release tooling`**
   Только перечисленный DataProject input/policy set, runtime JSON, scripts и CI;
   generated reports — лишь после zero-diff regeneration.
7. **`docs: add judge setup privacy security and attribution`**
   Judge-ready README, policy files, approved LICENSE и evidence packets.
8. **`docs: record clean-clone and final readiness evidence`**
   Clean-clone commands/results, final facts, remaining blockers и manual actions,
   привязанные к точному commit.

При изменении файлов после clean-clone proof доказательство считается устаревшим:
необходимо повторить соответствующие gates и обновить commit hash в final evidence.

## Required pre-remote gates

Перед созданием GitHub repository владелец или release coordinator должен
подтвердить одновременно:

1. `git status` и staged manifest содержат только intended paths.
2. Essential deletion `PremiumInteractionServices.swift` включён вместе с
   dedicated `ConnectivityStatus.swift`; удаление audit screenshot либо отдельно
   подтверждено владельцем, либо исключено из snapshot.
3. Clean build, unit, static QA и UI gates относятся к тому же snapshot.
4. DataProject/import validation относится к тому же runtime JSON.
5. Deterministic local assistant fallback проверен без backend credentials.
6. Live GPT-5.6 описан как unavailable/unverified либо доказан фактическим безопасным
   runtime response с model metadata и request ID.
7. Staged/current/history secret checks не нашли подтверждённых credentials.
8. Absolute local paths, персональные данные и device diagnostics удалены из
   передаваемого snapshot.
9. LICENSE и public/private решение одобрены владельцем.
10. Все передаваемые медиа имеют подтверждённые права; иначе они заменены или
    исключены из snapshot и demo.
11. Clean clone из финального commit воспроизводит документированные команды.
12. `BuildWeekFix/FINAL_READINESS.md` не содержит заявления production-ready, если
    хотя бы один обязательный gate остаётся красным.
13. Для optional public-site создан и проверен lockfile либо явно принят риск
    неповторяемого разрешения semver-зависимостей; текущий snapshot lockfile не содержит.

## Proposed branch protection

После ручного создания repository:

- default branch: `main`; рабочая `build-week-readiness` попадает в неё только через
  pull request;
- запретить force push и удаление `main`;
- запретить прямые push в `main`, включая администратора, кроме документированной
  emergency-процедуры;
- требовать минимум один owner-approved review и повторное одобрение после новых
  commits;
- требовать разрешения всех review conversations;
- требовать линейную историю и up-to-date branch перед merge;
- обязательные checks: clean iOS build, unit tests, aggregate static QA,
  DataProject/import validation, demo/fallback integration test и UI suite в
  доступной macOS/Xcode среде;
- добавить отдельный non-bypass secret scan; не загружать `.xcresult`/device logs
  как публичные artifacts без sanitation;
- ограничить создание release/tag и изменение Actions secrets владельцем;
- не настраивать auto-deploy, TestFlight upload или release publishing в рамках
  первого handoff.

Если GitHub-hosted runner не поддерживает требуемые Xcode/iOS версии, UI check
нельзя фиктивно заменить PASS. Его следует обозначить как внешний обязательный
gate на контролируемом macOS runner и приложить точный artifact/result summary.

## Judge access instructions

### Пока repository private

1. Владелец вручную создаёт `younew-build-week-2026` без README/license/.gitignore
   auto-initialization, чтобы не создавать расходящуюся историю.
2. Владелец выбирает private visibility и добавляет remote только после проверки
   всех pre-remote gates.
3. Первый push выполняется только после отдельной явной команды владельца.
4. Судьи приглашаются с минимальной ролью **Read** по официальным адресам/аккаунтам,
   предоставленным организаторами; список участников не следует угадывать.
5. Владелец проверяет доступ из отдельной сессии без собственных admin cookies:
   clone, README, package resolution, build и local fallback.
6. Судьям передаётся exact commit hash, ветка/тег review snapshot, Xcode/iOS
   requirements, known limitations и инструкция BuildWeekNewcomerDemo.
7. Backend URL или API key не передаются в repository. Для live demo владелец
   предоставляет доступ к уже безопасно настроенному backend отдельно и только в
   объёме, необходимом для демонстрации.

### Перед возможным переходом в public

Повторить secret/history/PII/media review уже для GitHub snapshot, проверить доступ
без авторизации, подтвердить лицензию и каждый screenshot/asset, а затем получить
отдельное письменное решение владельца. Public visibility не должна включаться
автоматически и не является обязательным условием технического handoff.

## Owner approval gates

Только владелец может безопасно выполнить или подтвердить:

- конечное имя и public/private visibility repository;
- intended state ранее начатых локальных изменений и отдельное решение по удалению
  `IA_Audit_Screenshots/strict-reference-pass/02-refined-home.png`; удаление
  `PremiumInteractionServices.swift` уже классифицировано как essential;
- право лицензировать собственный код и выбранный текст `LICENSE`;
- права на изображения, app icon, screenshots, видео и third-party content;
- публичность Git author/signing-team/contact metadata;
- создание GitHub repository, добавление remote и первый push;
- аккаунты судей и предоставление им доступа;
- backend credentials, deployment, endpoint и фактическую live GPT-5.6 проверку;
- release, TestFlight/App Store upload, demo video и submission.

## Handoff status

GitHub preparation: **CURATED LOCAL SNAPSHOT; REMOTE HANDOFF NOT EXECUTED**.
Remote: **ABSENT**.
Recommended visibility: **PRIVATE UNTIL ALL GATES PASS**.
Public handoff: **BLOCKED** by the last closed UI snapshot (84/87 RED), the
current-source UI aggregate requirement, the 18-URL shipped-data health blocker,
unresolved media rights, 39 tracked raster captures (about 91.0 MB), seven
untracked public-site media files whose directory is no longer ignore-protected,
reachable-history local-path/metadata review, owner review of excluded
artifacts/license, and live GPT-5.6/runtime evidence.
Push/publish/deploy/release: **NOT PERFORMED**.
