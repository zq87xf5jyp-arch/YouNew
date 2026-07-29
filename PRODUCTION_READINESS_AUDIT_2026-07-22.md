# YouNew ecosystem production-readiness audit

Audit date: 22 July 2026  
Release candidate assessed: local workspace on `main` at `e68abbb207…`; remote `main` observed at `c294dbbe9560…`  
Decision standard: App Store today, public web today, investor diligence today, and government presentation today  
Evidence rule: a control is `PASS` only when this audit produced direct local, runtime, live-service, or connected-GitHub evidence. Anything else is `NOT VERIFIED`.

This report treats the iOS app, public website, Admin, Supabase, repository, CI/CD, content system, domain and operational controls as one product. “Local fixed” does not mean “production fixed”: the current local tree is dirty, the Admin tree is mostly untracked, the branch is two remote commits behind, and no production deployment was made during this audit.

## SECTION 1 — Overall readiness

| Area | Readiness | Evidence summary |
| --- | ---: | --- |
| App | 62% | 461 unit tests and the unsigned generic iOS Release build pass. The complete UI run passed 80/87; the guide hang is fixed and passes in two targeted reruns, including a fresh final-configuration rebuild, but the BSN/Leiden assistant route remains reproducibly broken and tab-latency evidence is variable. Physical-device and distribution evidence is absent. |
| Website | 64% | Patched local package builds 232 routes and passes 57 tests, 16,894 internal-reference checks, security checks and real HTTP 404 validation; live Hostinger output is stale and AASA is 404. |
| Backend | 47% | Admin builds and now fails closed; Supabase public reads and basic RLS behavior were checked; Admin is not deployed, CRUD is read-only, mobile sync returns 503, and live migration parity is not verified. |
| Business | 24% | Contact/business copy exists, but premium entitlement, payments, KPIs, analytics, ownership of legal notices, and a production operating model are absent or not verified. |
| Security | 50% | Local secret/static gates and dependency audits pass with zero known production advisories after remediation; live policy rollout, GitHub controls, privacy-label parity, GDPR completeness, DKIM and recovery controls are not verified. |
| Content | 41% | 450 governed records and 188 published summaries exist; source-health and rights gates pass, but there are zero production-ready full guides and no recorded human publication authorization. |
| Infrastructure | 39% | `younew.nl` and TLS work; hosting is split between Hostinger and a stale Sites project, Admin DNS is absent, and backups/restore/monitoring are not verified. |
| Release | 20% | Local build/test/package evidence is substantial, but the complete UI gate fails, and signed archive, App Store Connect, TestFlight, physical-device QA, production deployment parity and operational sign-off are not verified. |
| **Overall** | **43%** | Equal-weight mean, rounded down conservatively: `(62 + 64 + 47 + 24 + 50 + 41 + 39 + 20) / 8 = 43.375`. Critical release gates override the numeric score. |

The percentages are conservative release-engineering assessments of verified capability, deployability and operational control; they are not raw test-pass ratios. `FAIL` and `NOT VERIFIED` release gates receive no readiness credit, local-only fixes receive partial credit, and confirmed production evidence receives full credit. Critical blockers independently force `NO GO` regardless of the arithmetic score.

### Audit confidence

- `CONFIRMED`: directly observed in source, a completed test/build, live HTTP/DNS/TLS, Sites, Supabase read-only probes, or connected GitHub metadata.
- `CANDIDATE RISK`: evidence suggests a problem but the release environment or a stable reproduction is missing.
- `NOT VERIFIED`: no sufficient evidence was available; this is never counted as a pass.
- Production mutations were deliberately not attempted. Applying migrations, changing DNS, deploying, writing GitHub settings, sending email, and publishing to App Store Connect require controlled credentials and release authorization.

## SECTION 2 — Critical blockers

1. **The ecosystem is not synchronized.** Local `main` is two commits behind the observed remote head, the worktree contains extensive user changes, and most of the Admin/Supabase project plus the new Admin CI workflow are untracked. The current Hostinger site also differs from the verified local package. A release cannot be reproduced from one reviewed commit.
2. **Content is not publication-ready.** The governed inventory reports 450 records and 188 published summaries, but 0 production-ready full guides. Human reviewer and publication authorization evidence is absent. Two priority research dossiers are missing and explicit source gaps remain for finding work, opening a bank account and student housing.
3. **Admin is not a production service.** `admin.younew.nl` has no A/AAAA/CNAME record; login/roles cannot be exercised live; the principal content table is honestly read-only after remediation; mobile sync intentionally returns 503; export, restore and autosave are absent or `NOT VERIFIED`.
4. **The live website is behind the release candidate.** Hostinger serves an older CSP (`img-src 'self' data:`), older privacy text and no deployed AASA file. `https://younew.nl/.well-known/apple-app-site-association` returned 404.
5. **Legal/GDPR publication data is incomplete.** The product does not identify the legal controller and address, complete lawful bases, recipient/transfer rules, retention schedule, all data-subject rights, or the competent supervisory authority. Those are among the disclosures identified in the [European Commission’s GDPR Articles 13–14 guidance](https://commission.europa.eu/law/law-topic/data-protection/information-business-and-organisations/principles-gdpr/what-information-must-be-given-individuals-whose-data-collected_en). These facts cannot be invented and require the owner’s verified legal data and legal review.
6. **No App Store distribution proof exists for the 1.1 candidate.** A public YouNew listing exists and a generic unsigned Release build passes locally, but signed archive/export, distribution certificate/profile, the 1.1 App Store Connect record, privacy-label match, age/export declarations, TestFlight install and physical-device QA are `NOT VERIFIED`.
7. **Published App Store privacy metadata conflicts with the candidate manifest.** The [live App Store listing](https://apps.apple.com/kz/app/younew/id6782617312) discloses broad data categories as not linked to the user and used for third-party advertising/developer marketing; the local candidate manifest declares linked Device ID and Other Diagnostic Data for app functionality with tracking disabled. Actual collection behavior, the correct declaration, and the 1.1 privacy-label update are not reconciled.
8. **Recovery and production observability are not demonstrated.** Supabase/hosting backups, a completed restore drill, alerting, uptime monitoring, centralized logs, crash reporting and incident ownership are `NOT VERIFIED`.
9. **Live Supabase security parity is not proven.** The new analytics-ingest lockdown migration exists locally and closes the permissive policies, but applying migration `0006` to the live project is `NOT VERIFIED`.
10. **The complete iOS UI release gate fails.** The definitive iPhone 17 Pro / iOS 26.5 run executed 87 tests: 80 passed and 7 failed. Clean targeted reruns reduced the stable failures to the AI-assistant BSN/Leiden route and variable root-tab latency; the guide main-thread hang was diagnosed and fixed locally, but the entire 87-case suite has not passed on the final tree. A failing complete release suite is independently `NO GO`.

## SECTION 3 — Major issues

- The public site has two hosting control planes: Hostinger is live, while the connected Sites project is stale and its `younew.nl` custom domain remains `pending` / `pending_validation`.
- GitHub branch protection, required reviews/checks, secret inventory, environment protections, Releases and tags are `NOT VERIFIED`. A tracked README and evaluation-only `LICENSE` notice exist; ownership and contributor-permission completeness remain `NOT VERIFIED`. Remote PR checks observed on the sampled heads were green; open PR #4 remains unmerged.
- The complete UI suite ran for 7,415 seconds and passed 80/87. Its seven failures covered Discover Netherlands routing, the event menu, guide navigation, requested-guide chips, root-tab latency, BSN/Leiden assistant routing and province assistant routing. A clean seven-test rerun passed five and reproduced the guide and BSN failures; later targeted evidence passed the Discover, event, chip and province cases, while root-tab latency failed again with a 204.2 ms maximum against a 100 ms threshold. The full-suite maximum was 442.3 ms.
- The guide failure was a real main-thread stall, not merely an automation timeout. A five-second sample captured 3,729 active main-thread stacks dominated by SwiftUI `LazySubviewPlacements`/AttributeGraph updates. Replacing the small outer `LazyVStack` with `VStack` made the full guide route test pass in two targeted reruns; the second rebuilt the final production configuration and passed in 161.6 seconds. The full suite still requires a clean rerun.
- The BSN/Leiden AI-assistant destination remains reproducibly broken in targeted testing. A direct-navigation implementation experiment did not correct the failure and was reverted; no speculative product change remains in the release tree.
- The live search browser session unexpectedly changed a typed `BSN` query to `First registration in Amsterdam`. Stable reproduction and whether this is stale-production-only are `NOT VERIFIED`.
- Source health contains 596 access-restricted and 29 transient URLs. There are zero confirmed broken URLs, but the 625 non-reachable URLs remain individually `NOT VERIFIED` rather than silently counted as healthy.
- SPF exists and the connected Hostinger API confirms that the `support@younew.nl` mailbox and its standard folders are accessible. DMARC is monitoring-only (`p=none`); DKIM and an explicit end-to-end inbound/outbound delivery test are `NOT VERIFIED`.
- No configured crash reporter, product analytics pipeline, push-notification release configuration or production monitoring was verified. The candidate manifest/App Store privacy conflict above must be resolved from measured runtime behavior, not by copying either declaration blindly.
- The production iOS bundle does not contain a verified `YOUNEW_AI_BACKEND_URL`. The client safely rejects a missing endpoint and the bounded backend sample passes 13 tests, but a live AI endpoint and operational key management are `NOT VERIFIED`.
- Repository storage is excessive for release engineering: `.git` is about 2.1 GiB with 1.88 GiB packed, and the repository contains many audit screenshots, generated artifacts and a modified tracked site ZIP. Cleanup must preserve the user’s current work and therefore was not automated.

## SECTION 4 — Medium issues

- CI covers iOS unit tests, public-site validation and data health. The complete iOS UI suite, signed archive/export, dependency-audit job, deployment verification and restore drill are not remote required checks.
- Admin production routes build, but the `/content` client bundle is approximately 211 kB first-load and deserves profiling after functional completion.
- The live domain has valid TLS and strong baseline headers, but the production CSP is older than the local media allowlist.
- `admin-dashboard/public-site/younew-site.zip` is a tracked generated deployment artifact and is currently modified. A release should derive packages from a clean commit instead of treating a mutable ZIP as source.
- Several exact duplicate tracked binaries are intentional aliases or audit baselines, but they add ambiguity and storage cost. Removal requires an owner-approved asset-retention policy.
- Exhaustive dead-code, unused-asset, duplicated-business-logic and deprecated-API absence is `NOT VERIFIED`. Successful compiles, typechecks and scoped static scans reduce risk but do not prove semantic reachability or scalability under production load.
- Scoped Admin/Web scans found no raw string-built database queries or dynamic code execution. The only `dangerouslySetInnerHTML` uses are JSON-LD scripts passed through a tested script-breakout escaping serializer. An independent penetration test for SQL injection, stored/reflected XSS, CSRF, SSRF and authorization bypass is still `NOT VERIFIED`.
- HTTPS transport was verified on the public domain. Provider-side encryption-at-rest configuration, key rotation, full Git-history secret exposure and secret-revocation history are `NOT VERIFIED`.
- Some route implementations use `preconditionFailure` for supposedly impossible canonical mappings. Unit/UI coverage reduces the immediate risk; production crash behavior for corrupted external state is a candidate robustness risk.
- Admin backup tooling exists as a script, but scheduled execution, encrypted destination, retention, access control and successful restore evidence are `NOT VERIFIED`.
- Accessibility automation covers major entry points and text sizing; Switch Control, Voice Control, reduced-motion behavior and complete manual VoiceOver traversal on a physical device are `NOT VERIFIED`.
- The live App Store listing says no supported accessibility features have been indicated. Candidate accessibility claims and metadata therefore need an owner-reviewed App Store update after manual evidence is complete.
- A Simulator memgraph/leaks capture completed: version 1.1 (7), 170.4 MiB physical footprint, 172.9 MiB peak and one 16-byte leak. This is partial evidence only; physical-device stress and leak ownership are `NOT VERIFIED`.
- Five-second system samples show the home screen main thread idle for about 94% of samples and separately identify the guide’s SwiftUI lazy-layout stall. Attempts to collect Time Profiler and CPU Profiler traces produced incomplete trace documents with `Document Missing Template Error`; ETTrace is unavailable in this environment. Instruments CPU attribution, Main Thread Checker and energy/network profiling therefore remain `NOT VERIFIED`.

## SECTION 5 — Minor improvements

- Consolidate historical audit documents into one current release record and archive contradictory snapshots.
- Add an explicit software license after owner/legal approval; do not infer one from repository visibility.
- Rename or relocate the parent path containing `:`. pnpm warns that this delimiter prevents ordinary `node_modules/.bin` PATH resolution; the builds were verified with direct bundled Node paths.
- Replace mutable generated bundles and screenshots in Git with CI artifacts where retention and provenance are clearer.
- Add stable live-deployment fingerprints (commit SHA and build time) to Website and Admin status pages.
- Record service owners, escalation contacts, RTO/RPO, incident severity definitions and an emergency rollback runbook.

## SECTION 6 — Everything fixed automatically

All items below are fixed **in the local workspace only** unless stated otherwise:

- Admin data access now fails closed when Supabase is missing or errors; fake production fallback data was removed.
- Demo mode now requires non-production plus explicit `YOUNEW_ADMIN_DEMO_MODE=true`; middleware also fails closed.
- Public Admin APIs return 503 with no-store instead of returning demo data as if it were production.
- The Admin sync page now labels Supabase/demo/unavailable states honestly and documents the disabled mobile sync contract.
- Inert create/edit/delete/export controls and fabricated readiness/analytics screenshots were removed; the content UI is explicitly read-only.
- A hard-coded first-owner UUID was removed from migrations; production owner promotion is now a deliberate manual action.
- Migration `0006_lock_down_analytics_ingest.sql` drops permissive ingest policies, revokes inserts from `anon`/`authenticated`, and grants insert only to `service_role`.
- Production seed execution now requires an explicit `younew.allow_demo_seed=on` guard.
- Added Admin production static QA and wired it into the repository gate.
- Added pinned Admin CI for Node 24, frozen dependency install, lint, typecheck, build and production-safety QA.
- Pinned patched transitive `sharp 0.35.0` and `postcss 8.5.20`; post-fix production audits report 0 known vulnerabilities in Admin, Website and BackendExamples.
- Excluded transient `BackendExamples/node_modules` install state from Git while retaining its dependency lockfile.
- Public-site CSP and security checks now allow only the exact verified Wikimedia/Flickr image origins used by content.
- Local privacy notices now disclose Wikimedia/Flickr request delivery and their possible IP/request logging.
- Updated the Night Watch provenance check to the verified Wikimedia Commons source/dimensions and current retrieval date.
- Updated stale pre-deployment/App Store documentation to build 7 and current test evidence without claiming deployment.
- Hardened category-route UI automation with a bounded retry only when the original control proves a Simulator tap/back was ignored. Both isolated affected route tests pass.
- Settings now reads its displayed version and build from the application bundle; the running Simulator accessibility tree and screenshot both confirmed `1.1 (7)` instead of a hard-coded value.
- Replaced the guide root’s nested lazy stack with a bounded ordinary stack after a live main-thread sample proved the lazy placement graph was stalling. The previously failing housing/government/transport/education/explore route test passes in two targeted reruns, including a fresh final-configuration rebuild.

## SECTION 7 — Everything requiring manual action

1. Freeze the worktree, decide which user changes belong to the release, bring local `main` up to the remote head, commit all intended Admin/Supabase/site/iOS changes, and obtain review on one immutable SHA.
2. Run all CI from that SHA and make required checks/approvals/linear history/environment protection enforceable in GitHub.
3. Apply and verify all six Supabase migrations in staging, then production; specifically prove `0006` blocks anonymous/authenticated analytics inserts while service-role ingest works.
4. Provision the first approved Admin owner, deploy Admin, configure `admin.younew.nl`, validate authentication/roles/RLS/storage, and implement the required CRUD/export/restore/autosave flows before claiming Admin readiness.
5. Deploy the verified website package to the actual Hostinger origin; verify the new CSP/privacy copy, AASA MIME/body, sitemap, robots, 404, every legal URL and a visible commit fingerprint from outside the operator network.
6. Choose one authoritative hosting/control plane and retire or synchronize the stale Sites project/custom-domain configuration.
7. Supply verified legal entity/controller details and have Dutch/EU counsel approve Privacy, Terms, cookies, retention, data rights, subprocessors/transfers and the supervisory-authority wording.
8. Assign qualified content reviewers, close missing dossiers/source gaps, approve full guides, record reviewer/date/source/version, and regenerate all App/Web/Admin projections from the same release manifest.
9. Configure backups for Supabase and hosting, encrypt and restrict them, document RTO/RPO, and complete a timed restore drill with evidence.
10. Configure uptime, API, database, certificate, DNS, email, crash and release monitoring with owners and alert routes.
11. Configure DKIM, decide an enforcement path for DMARC, and verify inbound/outbound support email delivery.
12. Configure the live bounded AI backend URL and secrets server-side, then test rate limits, abuse handling, cost caps, PII behavior, outage fallback and source-grounding in production.
13. Resolve the commercial model: whether Premium exists, entitlements, pricing, VAT/refunds, App Store IAP compliance, future payments, KPI definitions and analytics consent. Do not expose premium claims before these are real.
14. Produce a signed archive, validate/export it, upload to App Store Connect, reconcile privacy labels with the manifest/runtime, complete age/export declarations, TestFlight install, physical-device matrix and Apple review metadata/assets.
15. Perform manual accessibility and UX acceptance for tourist, student, refugee, expat/highly-skilled migrant, local, family, disabled user and new resident profiles in English, Dutch and Russian.
16. Fix the reproducible AI-assistant BSN/Leiden destination failure, investigate the variable first-tab-switch latency, rerun all 87 UI cases on the final release SHA, and require a completely green result.

## SECTION 8 — Production checklist

### Source and release control

- [ ] One clean, reviewed, tagged commit contains iOS, Website, Admin, migrations, generated content and CI.
- [ ] Local branch equals remote protected release branch.
- [ ] Required GitHub checks and approvals are enforced and green.
- [ ] Release notes, changelog, license decision and rollback SHA are recorded.

### iOS / App Store

- [x] Bundle ID `nl.younew.app`, version `1.1`, build `7`, minimum iOS `17.6` confirmed in unsigned Release output.
- [x] 461 unit tests pass.
- [x] Generic unsigned iOS Release build passes.
- [ ] Complete updated UI suite passes with final xcresult (current result: 80/87).
- [ ] Time Profiler/ETTrace, Main Thread Checker, memory graph/leaks and energy/network evidence accepted (Simulator memgraph is partial and reports one 16-byte leak).
- [ ] Signed archive/export validation and TestFlight install pass.
- [ ] Physical-device, background/foreground, permission, offline and low-memory matrix pass.
- [ ] Published App Store privacy labels, candidate manifest and measured runtime collection exactly agree.
- [ ] App Store privacy/age/export metadata and screenshots are owner-reviewed.
- [ ] AASA returns 200 with correct JSON and content type from the live domain.

### Website

- [x] Local production package builds 232 routes; 224 sitemap URLs and 229 HTML files validated.
- [x] 57 tests, 16,894 internal references, security scan and real HTTP 404 pass.
- [x] Local production dependency audit reports zero known advisories.
- [x] Live core URLs and TLS respond.
- [ ] Verified local package is deployed to Hostinger and commit fingerprint matches.
- [ ] Live CSP, privacy text and AASA match the release.
- [ ] Cross-browser/mobile/tablet/desktop manual acceptance is signed off.
- [ ] Legal/cookie/analytics behavior is counsel- and privacy-approved.

### Admin and Supabase

- [x] Local Admin lint, typecheck, production build and dependency audit pass.
- [x] Missing/erroring Supabase and public APIs fail closed.
- [x] RLS schema exists locally for all 20 application tables; 39 policies and 7 indexes are present.
- [ ] Admin code and CI are committed and reviewed.
- [ ] Admin DNS, hosting, login and all roles are verified live.
- [ ] Required CRUD, validation, image upload, search/filter, export, restore, audit log and autosave work live.
- [ ] Migrations `0001`–`0006` are verified in production.
- [ ] Storage buckets/policies and service-role separation are verified live.
- [ ] Encrypted backup plus restore drill passes against a non-production target.

### Content, privacy and operations

- [ ] At least the launch-scope full guides have human approval and production-ready status.
- [ ] All restricted/transient source URLs are reviewed or explicitly accepted.
- [x] Asset-rights gate reports 170 catalog assets and 0 unresolved ledger records.
- [ ] Legal controller/GDPR/cookie disclosures are complete and approved.
- [ ] Crash, uptime, API, database, DNS/TLS and email monitoring are alerting to named owners.
- [ ] Incident, rollback, breach response, support and release-on-call runbooks are exercised.
- [ ] Premium/payments/analytics decisions and corresponding privacy/Store policies are approved.

### Evidence ledger — 112 release test cases

| ID | Area | Verification | Result | Classification |
| --- | --- | --- | --- | --- |
| T001 | Repository | Git worktree clean | FAIL — extensive modified/untracked work | CONFIRMED |
| T002 | Repository | Branch name | PASS — `main` | CONFIRMED |
| T003 | Repository | Local equals remote | FAIL — local behind observed remote by 2 | CONFIRMED |
| T004 | Repository | Tracked-file inventory | PASS — 1,361 files enumerated | CONFIRMED |
| T005 | Repository | Git storage | FAIL — `.git` about 2.1 GiB | CONFIRMED |
| T006 | Repository | Duplicate hash review | PASS with debt — aliases/audit baselines identified | CONFIRMED |
| T007 | Repository | Broken imports/type errors | PASS through app/web/admin builds | CONFIRMED |
| T008 | Repository | TODO/FIXME product scan | PASS — none found in scoped product code | CONFIRMED |
| T009 | Repository | Complete static QA | PASS | CONFIRMED |
| T010 | Repository | License notice | PASS — tracked evaluation-only/no-license-grant notice; ownership and contributor permissions `NOT VERIFIED` | CONFIRMED |
| T011 | Repository | Generated deploy ZIP immutable | FAIL — tracked ZIP modified | CONFIRMED |
| T012 | Repository | One reproducible release SHA | FAIL | CONFIRMED |
| T013 | iOS | Unit suite | PASS — 461 tests / 40 suites | CONFIRMED |
| T014 | iOS | Unit failures | PASS — 0 failures | CONFIRMED |
| T015 | iOS | Unsigned generic Release compile | PASS | CONFIRMED |
| T016 | iOS | Release bundle identifier | PASS — `nl.younew.app` | CONFIRMED |
| T017 | iOS | Release marketing version | PASS — `1.1` | CONFIRMED |
| T018 | iOS | Release build number | PASS — `7` | CONFIRMED |
| T019 | iOS | Minimum OS | PASS — iOS `17.6` | CONFIRMED |
| T020 | iOS | Privacy manifest parses | PASS | CONFIRMED |
| T021 | iOS | Privacy tracking flag | PASS — false | CONFIRMED |
| T022 | iOS | Candidate manifest / published privacy-label parity | FAIL — linkage, categories and purposes conflict; actual runtime behavior `NOT VERIFIED` | CONFIRMED |
| T023 | iOS | Signed archive | NOT VERIFIED | NOT VERIFIED |
| T024 | iOS | Distribution certificate/profile | NOT VERIFIED | NOT VERIFIED |
| T025 | iOS | App Store listing / 1.1 upload | PARTIAL — public listing exists; 1.1 record/upload and exact live version `NOT VERIFIED` | CONFIRMED |
| T026 | iOS | TestFlight install | NOT VERIFIED | NOT VERIFIED |
| T027 | iOS | Physical-device matrix | NOT VERIFIED | NOT VERIFIED |
| T028 | iOS | Isolated city list/detail/back runtime | PASS after isolated rerun | CONFIRMED |
| T029 | iOS | Isolated education detail/back runtime | PASS after test hardening | CONFIRMED |
| T030 | iOS | Full updated 87-case UI suite | FAIL — 80 passed / 7 failed in 7,415 seconds | CONFIRMED |
| T031 | iOS | Accessibility runtime entry points | PASS in first complete-suite attempt | CONFIRMED |
| T032 | iOS | Dynamic Type runtime | PASS in accessibility suite | CONFIRMED |
| T033 | iOS | Localization static coverage EN/NL/RU | PASS | CONFIRMED |
| T034 | iOS | Map/search/AI route static contracts | PASS | CONFIRMED |
| T035 | iOS | Offline/static content behavior | PASS in repository gates | CONFIRMED |
| T036 | iOS | Production AI endpoint | NOT VERIFIED | NOT VERIFIED |
| T037 | iOS | AI bounded backend tests | PASS — 13/13 | CONFIRMED |
| T038 | iOS | Push-notification production config | NOT VERIFIED | NOT VERIFIED |
| T039 | iOS | Crash reporting | NOT VERIFIED / no configured provider found | NOT VERIFIED |
| T040 | iOS | Memory graph/leaks | PARTIAL — Simulator capture: 170.4 MiB footprint, 172.9 MiB peak, one 16-byte leak; physical-device/stress ownership `NOT VERIFIED` | CONFIRMED |
| T041 | iOS | Time Profiler/ETTrace | PARTIAL — bounded system samples completed; Instruments traces incomplete and ETTrace unavailable | CONFIRMED |
| T042 | iOS | Main Thread Checker | NOT VERIFIED | NOT VERIFIED |
| T043 | Website | Production build | PASS — 232 routes | CONFIRMED |
| T044 | Website | Unit/schema tests | PASS — 57/57 | CONFIRMED |
| T045 | Website | Sitemap generation | PASS — 224 indexable URLs | CONFIRMED |
| T046 | Website | Robots generation | PASS | CONFIRMED |
| T047 | Website | Metadata/structured-data contract | PASS | CONFIRMED |
| T048 | Website | Internal links/fragments/assets | PASS — 16,894 references | CONFIRMED |
| T049 | Website | Runtime 404 | PASS | CONFIRMED |
| T050 | Website | Local CSP/security package | PASS | CONFIRMED |
| T051 | Website | Production dependency audit | PASS — 0 known advisories | CONFIRMED |
| T052 | Website | 390×844 live overflow check | PASS | CONFIRMED |
| T053 | Website | Live root/privacy/terms/support/status | PASS — HTTP 200 | CONFIRMED |
| T054 | Website | Live robots/sitemap | PASS — HTTP 200 | CONFIRMED |
| T055 | Website | Live AASA | FAIL — HTTP 404 | CONFIRMED |
| T056 | Website | Live CSP equals local | FAIL | CONFIRMED |
| T057 | Website | Live privacy equals local | FAIL | CONFIRMED |
| T058 | Website | Service worker/offline shell | PASS locally | CONFIRMED |
| T059 | Website | Form handoff honesty | PASS — mail draft, no false submission | CONFIRMED |
| T060 | Website | Live search query stability | NOT VERIFIED — anomaly observed | CANDIDATE RISK |
| T061 | Admin | ESLint | PASS | CONFIRMED |
| T062 | Admin | TypeScript | PASS | CONFIRMED |
| T063 | Admin | Production build | PASS — 29 pages | CONFIRMED |
| T064 | Admin | Production dependency audit | PASS — 0 known advisories | CONFIRMED |
| T065 | Admin | Missing Supabase fails closed | PASS | CONFIRMED |
| T066 | Admin | Supabase query error fails closed | PASS | CONFIRMED |
| T067 | Admin | Demo requires explicit local opt-in | PASS | CONFIRMED |
| T068 | Admin | Public API avoids demo fallback | PASS | CONFIRMED |
| T069 | Admin | Public API uses 503/no-store on failure | PASS | CONFIRMED |
| T070 | Admin | Mobile sync | FAIL — intentional 503 | CONFIRMED |
| T071 | Admin | Full CRUD | FAIL — content table read-only | CONFIRMED |
| T072 | Admin | Live login | NOT VERIFIED | NOT VERIFIED |
| T073 | Admin | Live roles/permissions | NOT VERIFIED | NOT VERIFIED |
| T074 | Admin | Image upload live | NOT VERIFIED | NOT VERIFIED |
| T075 | Admin | Search/filter/export | NOT VERIFIED / incomplete | NOT VERIFIED |
| T076 | Admin | Restore | NOT VERIFIED | NOT VERIFIED |
| T077 | Admin | Autosave | NOT VERIFIED | NOT VERIFIED |
| T078 | Admin | Admin DNS | FAIL — no A/AAAA/CNAME | CONFIRMED |
| T079 | Supabase | Auth health with anon key | PASS — HTTP 200 | CONFIRMED |
| T080 | Supabase | Published categories read | PASS | CONFIRMED |
| T081 | Supabase | Published articles read | PASS | CONFIRMED |
| T082 | Supabase | Published cities read | PASS | CONFIRMED |
| T083 | Supabase | Anonymous non-published category query | PASS — zero rows | CONFIRMED |
| T084 | Supabase | Anonymous non-published article query | PASS — zero rows | CONFIRMED |
| T085 | Supabase | Anonymous non-published city query | PASS — zero rows | CONFIRMED |
| T086 | Supabase | Anonymous analytics read | PASS — zero rows | CONFIRMED |
| T087 | Supabase | Local table definitions | PASS — 20 | CONFIRMED |
| T088 | Supabase | Local RLS enablement | PASS — 20/20 | CONFIRMED |
| T089 | Supabase | Local policy inventory | PASS — 39 | CONFIRMED |
| T090 | Supabase | Local index inventory | PASS — 7 | CONFIRMED |
| T091 | Supabase | FK/trigger definitions | PASS statically | CONFIRMED |
| T092 | Supabase | Live migration `0006` | NOT VERIFIED | NOT VERIFIED |
| T093 | Supabase | Storage buckets/policies live | NOT VERIFIED | NOT VERIFIED |
| T094 | Supabase | Backups | NOT VERIFIED | NOT VERIFIED |
| T095 | Supabase | Restore drill | NOT VERIFIED | NOT VERIFIED |
| T096 | GitHub | Repository visibility | PASS — public repo observed | CONFIRMED |
| T097 | GitHub | Sampled PR Actions checks | PASS | CONFIRMED |
| T098 | GitHub | Open issues | PASS — 0 observed | CONFIRMED |
| T099 | GitHub | Open PRs | FAIL/attention — PR #4 open | CONFIRMED |
| T100 | GitHub | Branch protection | NOT VERIFIED | NOT VERIFIED |
| T101 | GitHub | Required reviews/checks | NOT VERIFIED | NOT VERIFIED |
| T102 | GitHub | Secrets/environments | NOT VERIFIED | NOT VERIFIED |
| T103 | GitHub | Releases/tags | NOT VERIFIED | NOT VERIFIED |
| T104 | Content | Governed records | PASS — 450 | CONFIRMED |
| T105 | Content | Published summaries | PASS — 188 | CONFIRMED |
| T106 | Content | Production-ready full guides | FAIL — 0 | CONFIRMED |
| T107 | Content | Source-health confirmed broken | PASS — 0 of 2,560 | CONFIRMED |
| T108 | Content | Source-health restricted/transient | NOT VERIFIED — 596 / 29 | NOT VERIFIED |
| T109 | Content | Rights ledger | PASS — 170 assets, 0 unresolved | CONFIRMED |
| T110 | Infrastructure | Live TLS | PASS — valid Let’s Encrypt chain observed | CONFIRMED |
| T111 | Infrastructure | SPF/DMARC | PARTIAL — SPF present; DMARC `p=none` | CONFIRMED |
| T112 | Infrastructure | Mailbox/DKIM/delivery/backups/monitoring | PARTIAL — Hostinger support mailbox/folders accessible; DKIM, explicit end-to-end delivery, backups and monitoring `NOT VERIFIED` | CONFIRMED |

## SECTION 9 — Final score

**43 / 100**

The codebase has strong local validation, but production readiness is capped by synchronization, content approval, legal completeness, Admin/backend deployment, recovery/monitoring and App Store distribution evidence. Passing local builds cannot override those release gates.

## SECTION 10 — GO / NO GO

NO GO
