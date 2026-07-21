# YouNew Public Web — practical assistant continuation report

Date: 20 July 2026  
Scope: `admin-dashboard/public-site` plus the existing DataProject/import pipeline  
Deployment: **not performed**  
Overall status: **NOT READY for the 100% content-production objective; PARTIAL as a public web product**

The current static export passes the listed build, code and package subchecks, but the aggregate pre-deploy and repository static-QA gates fail at external source health. It is not a Hostinger deployment candidate, and the governed production release still contains zero approved full practical guides. The work in this continuation adds the schema, publication gate, 20 safe editorial scaffolds, guide rendering, journeys, enhanced search, map MVP, business media kit and a repeatable fail-closed pre-deploy gate without publishing unreviewed instructions.

## 1. Audit findings

- The public web is a Next.js 15 static export generated from `YouNew/Resources/Data/younew-runtime-data.json`.
- The canonical production artifact has 188 published entities from two accepted releases: 5 cities, 15 brief guide-like records, 30 organizations and 138 places.
- The 15 released guides contain source-checked summaries, relations and metadata, but no procedural `body`, `sections` or `practicalGuide` payload.
- DataProject contains 450 governed records across seven releases. Additional guide-like QA records are not part of the two production releases and therefore remain private.
- The content-readiness matrix identifies 277 guide-capable material records: 15 effectively published summaries and 262 QA records. It finds 0 full guides, 0 production-ready guides and 0 published FAQ.
- Target-volume coverage is 262/3000 (8.7%); production-ready target coverage is 0%. All 36 governed topic families have inventory, but all 36 have zero production-ready output. P1/P2/P3 inventory-slot coverage is 100%/100%/100%; production readiness is 0% for every priority.
- Ten WorldPride 2026 event records are stale under the governed freshness policy. No canonical/staging duplicate or placeholder groups were found.
- The repository contains 799 material `related_entity` links against the brief's 1,000-link goal (79.9% structural proxy). The built site has 14,237 valid internal references, but those repeated navigation/route references are not misreported as 14,237 unique editorial links.
- A fresh live check on 20 July 2026 covered 2,494 source/media URLs: 18 confirmed 404 responses, 597 access-restricted and 32 transient failures. Two broken URLs in the mutable Transport QA batch were replaced with current official OV-chipkaart routes and their claims narrowed; one unavailable Wikimedia thumbnail in current Swift media configuration was replaced with the same file's official original URL. The remaining 18 unique failures belong to the immutable released runtime (mostly obsolete media/licence URLs plus the BREDA route, which needs manual anti-bot verification) and require an approved patch release/verification override; the required network health gate therefore correctly fails.
- Existing release flow is: DataProject batches → JSON Schema and publication gates → release manifests → `scripts/import-data-project.py` → runtime JSON → iOS and public-site projections.
- Legacy Swift mock guides are not a safe publication source: they are mock data and include runtime-generated dates. They were not imported or copied into the web package.
- The production runtime, release approvals and release manifests were not altered. The new 20-topic file is editorial staging only.

## 2. Architecture

```text
DataProject batches / releases / official-source evidence
                     │
                     ├── entity.schema.json
                     ├── seven publication gates
                     └── practical-guide fail-closed QA
                     │
                     ▼
scripts/import-data-project.py
                     │ optional practicalGuide projection
                     │ drafts/review/archived omitted
                     ▼
YouNew/Resources/Data/younew-runtime-data.json
                     │ canonical shared runtime artifact
                     ▼
scripts/generate-public-content.mjs
          ├── strict public practical-guide validator
          ├── src/generated/public-content.json
          ├── public/data/search-index.json (schema v2)
          └── public/data/content-provenance.json
                     │
                     ▼
Next.js static export
          ├── public web + guide/journey/map interactions
          ├── local-only saved/profile/recent/journey state
          ├── PWA/offline policies
          └── business acquisition with user-controlled email handoff
                     │
                     ▼
out/ == dist/client/ → static Hostinger artifact (release blocked until every gate passes and deployment is explicitly approved)
```

This remains one content pipeline. The website does not introduce a second manually maintained production database.

## 3. Practical-guide content model

`DataProject/schema/entity.schema.json` now accepts an optional, backward-compatible `practical_guide` extension with:

- stable schema version, ID, slug, locale, title and status;
- sourced short summary;
- audience profiles;
- city/province applicability and national/provincial/municipal/mixed jurisdiction;
- sourced prerequisites and required documents;
- sourced estimated time and cost, including explicit unknown/not-applicable states;
- ordered numbered steps;
- sourced warnings, common mistakes and additional sections;
- official sources and contact options;
- sourced FAQ, tips, checklist and emergency information;
- related guides and sourced next actions;
- verified/updated dates, reviewer and disclaimer;
- SEO title, description and canonical path;
- synonyms and common questions for search.

Every factual block stores `source_ids`. A guide with `status: published` fails closed unless it has a sourced summary, steps, three FAQ answers, checklist, tips, sourced emergency context, at least one opened official source, valid per-fact source references, current verification/update dates, a registered human reviewer, a matching hashed local QA artifact, explicit canonical `publicWebCategory`, a CSP-compatible local image and the full gate. Municipal guides must identify applicable cities. Draft, QA, review and archived extensions are never projected into runtime or public search. The reviewer and evidence registries are deliberately empty, so automation cannot silently approve a guide.

Backward compatibility is verified: the existing 15 short records remain valid `contentDepth: summary` pages and keep their stable routes.

## 4. First guide wave

Current governed counts:

| Content depth | Count | Public? |
|---|---:|---|
| Approved full practical guides | 0 | No full guide exists to publish yet |
| Editorial practical-guide scaffolds | 20 | No; staging only |
| Released source-summary guide records | 15 | Yes |

All requested topics have draft scaffolds. The deterministic editorial handoff covers 18 topics with 112 research facts and 60 unique official source IDs; Dutch integration exams and Reporting discrimination remain blocked without dedicated dossiers. Three scaffolds — Finding work, Opening a Dutch bank account and Student housing — also lack canonical procedural source entities. None of the 20 has invented steps, dates, cost, reviewer or legal/medical/administrative advice, and none is authorized for publication.

The public guide page now supports the complete practical layout when a future guide passes the gate: audience, short answer, prerequisites, documents, ordered steps, time/cost, warnings, mistakes, sources, contacts, related guides, next actions, verification metadata, table of contents, save/share/report/print and HowTo JSON-LD. Today’s 15 pages honestly render as “Verified summary” and clearly state that a complete step-by-step guide has not yet been released.

## 5. Practical journeys

One functional `/journeys` route contains exactly eight journeys:

- New in the Netherlands;
- International student;
- Starting work;
- Looking for housing;
- Healthcare setup;
- Refugee essentials;
- Tourist essentials;
- Starting a business.

Only released guide IDs can be steps. Four journeys currently have released Amsterdam-specific reading steps; four remain visibly closed because their component guides are drafts. States are `not-started`, `in-progress` and `completed`, stored locally in the versioned browser adapter. The UI explicitly says this is reading progress in one browser, not an official process status, account record or iOS synchronization.

## 6. Search quality

Search index schema v2 adds numbered steps, documents, synonyms, official organization names, Dutch/English terminology and common questions. Ranking uses semantic token coverage in addition to normalization and bounded typo tolerance, while drafts and archived records remain excluded.

Control-query result:

| Query | Released result |
|---|---|
| How do I get a BSN? | First registration in Amsterdam |
| Register gemeente | First registration in Amsterdam |
| Need a doctor | Healthcare category |
| Health insurance | Healthcare category |
| Landlord does not repair | !WOON |
| Lost residence card | No published match |
| Student housing | Housing category |
| DigiD | No published match |
| Work contract | No published match |
| Emergency | Emergency page |

The three empty results are intentional: the current release has no safe procedural destination, and search does not redirect those questions to unrelated content.

## 7. Interactive map MVP

`/map` is a dependency-free, lazy route with 173 released coordinate-backed cities, organizations and places. It provides:

- national coordinate extent without geolocation or paid API keys;
- city, type and category filters reflected in the URL;
- deterministic grouping of nearby/identical coordinates;
- keyboard-selectable markers and released-detail links;
- a complete server-rendered accessible list and `<noscript>` guidance;
- print rules and explicit coverage limitations.

No external map SDK, tile request or tracking service is loaded. This protects static Hostinger compatibility and keeps route JavaScript at 4.57 kB. The current canonical data is concentrated in Amsterdam and many records share coarse coordinates; the route is labelled as a coverage overview, not navigation or a complete map of Dutch services.

## 8. Business acquisition

Added `/business/media-kit` and a shared typed advertising catalogue used by the format page, inquiry form, validation and email handoff. The section includes:

- formats available for discussion;
- Request a quote instead of unapproved fixed pricing;
- sponsored-content rules and editorial independence;
- partner review process and refusal criteria;
- GDPR/data-handling notice;
- a print/PDF action;
- a fictional card labelled `DEMO PARTNER CARD · NOT LIVE`;
- an illustrative report labelled `DEMO REPORT · ILLUSTRATIVE DATA`;
- an explicit statement that no live advertiser dashboard or guaranteed measurement exists.

The existing application remains honest: client validation prepares a user-controlled `mailto:support@younew.nl` draft. Nothing is uploaded, stored or claimed as submitted. Secure submissions, confirmation email, rate limiting and admin notifications still require a backend.

## 9. Public routes

Public utility: `/`, `/discover`, `/search`, `/guides`, `/guides/[slug]`, `/journeys`, `/map`, `/categories`, `/categories/[slug]`, `/cities`, `/cities/[slug]`, `/provinces`, `/provinces/[slug]`, `/places`, `/places/[slug]`, `/organizations`, `/organizations/[slug]`, `/emergency`, `/saved`, `/status`, `/app`, `/offline`.

Business: `/business`, `/business/advertise`, `/business/partners`, `/business/pricing`, `/business/apply`, `/business/media-kit`.

Support/legal: `/support`, `/privacy`, `/terms` and the real exported 404.

The build generated 232 Next static-generation entries, 229 HTML files and 224 indexable sitemap URLs. The three added public routes are functional journeys, map and media kit pages; no empty route set was created.

## 10. Build and automated QA

Final `scripts/pre-deploy.sh` result: **FAIL-CLOSED at source health**. Steps 1–9 pass; step 10 rejects the package because the current immutable runtime still contains 18 confirmed broken external URLs.

- Production build: PASS, Next.js 15.5.19, 232/232 static generation entries.
- TypeScript: PASS.
- ESLint: PASS, zero warnings.
- Unit/schema tests: 43/43 PASS.
- Static smoke: PASS, 224 indexable URLs.
- Links/assets/fragments: PASS, 14,237 references across 229 HTML files.
- External source/media link health: **FAIL**, 18 confirmed 404s remain in the immutable released runtime; 0 remain in mutable governed QA records.
- Security package scan: PASS, required Hostinger headers and no known secret patterns.
- Deployment invariants: PASS, canonical/sitemap parity, manifest, service worker, no localhost/local paths/drafts/secrets, true local HTTP 404.
- `out/` and `dist/client/`: byte-identical tree.
- Practical-guide upstream QA: PASS, 20 drafts, 0 staged publications, fail-closed per-fact source checks and 29 focused schema-bound regressions.
- Full existing iOS/DataProject static QA wrapper: **FAIL-CLOSED at `governed_broken_links=18`** after all preceding code, schema, content, observability and operations checks passed for 450 governed records with no canonical mutation.
- `pnpm audit --prod`: PASS, no known vulnerabilities.

The map adds no dependency. The final build reports 111 kB first-load JavaScript for guide pages, 110 kB for journeys/map and 114 kB for search; the guide, journey and map route payloads are 1.50 kB, 4.08 kB and 4.59 kB respectively.

## 11. Browser, responsive, print and PWA QA

Verified in the current local preview of the production build:

- guide summary semantics, official source, report link, save and persisted saved state after reload;
- journeys local state change and persistence after reload;
- map filters, query URL, marker selection and accessible released-content list;
- positive BSN search and honest DigiD empty result with no draft leak;
- media-kit demo labels and absence of a fixed euro price;
- business application disclosure and disabled incomplete form;
- mobile navigation and semantic heading/breadcrumb structure;
- no representative console errors.

The released summary-guide layout was measured at 320×568, 390×844, 430×932, 768×1024, 1280×800 and 1440×900: one H1 and no horizontal overflow at every size. Journeys, search, map, application and media kit were additionally checked at representative mobile/desktop sizes without horizontal overflow. The future `FullPracticalGuide` React/print/offline/mobile branch is schema- and projection-tested but cannot receive truthful production visual evidence until one human-reviewed guide exists.

Print rules and PWA/offline policies are covered by unit/static tests and current Chrome runtime evidence. After an online load, `/guides/woon/` was controlled by the service worker and added to the guide cache; with network disabled, the document reloaded with HTTP 200 from the service worker and retained the `!WOON` H1 and source summary. Optional Next RSC prefetches logged expected `ERR_INTERNET_DISCONNECTED` messages, but the offline document remained complete and readable. Headless-Chrome print output produced a 2-page guide PDF and an 8-page media-kit PDF. Real iPhone Safari installation/offline behavior remains a release-device check.

## 12. Lighthouse

Lighthouse 13.4.0 against the current local production preview:

| Route/profile | Performance | Accessibility | Best Practices | SEO | FCP | LCP | TBT | CLS |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `/` mobile | 100 | 100 | 100 | 100 | 0.9 s | 1.4 s | 30 ms | 0.001 |
| `/` desktop | 100 | 100 | 100 | 100 | 0.3 s | 0.3 s | 0 ms | 0 |
| `/guides/woon/` mobile | 94 | 100 | 100 | 100 | 1.0 s | 2.1 s | 250 ms | 0 |
| `/journeys/` mobile | 96 | 100 | 100 | 100 | 1.1 s | 2.1 s | 170 ms | 0 |
| `/map/` mobile | 96 | 100 | 100 | 100 | 1.1 s | 2.4 s | 160 ms | 0.001 |
| `/business/media-kit/` mobile | 91 | 100 | 100 | 100 | 1.1 s | 2.5 s | 290 ms | 0 |

These are local lab results and must be repeated against `https://younew.nl` after an explicitly approved deployment.

## 13. Security and GDPR

- No client secrets or API keys were found by the static package scan.
- CSP, clickjacking, MIME-sniffing, referrer, permissions and COOP headers are prepared in `.htaccess` and pass compatibility checks.
- Draft practical guides and business personal data are absent from the public package.
- Search stays local; free business text is not sent to analytics.
- Emergency information is never sponsored and uses network-first/non-permanent cache treatment.
- Advertising stays feature-flagged off; demo content is visibly fictional.
- HSTS remains intentionally deferred until live HTTPS and subdomain behavior are verified.
- Real submissions still require server-side validation, CSRF protection, rate limiting, retention/deletion rules and administrative access controls.

## 14. Hostinger compatibility

Fully static now: all public pages, search/filtering, saved/profile/recent/journey state, map, business information, media kit, mailto handoff, status/config JSON and PWA shell.

Possible later with Hostinger PHP/MySQL: validated inquiry/report endpoints, honeypot/rate limiting, submission queue, admin notification and basic audit records.

Needs Node/VPS/Supabase or equivalent: accounts, iOS/web sync, secure partner authentication, uploads, campaigns, billing/invoices and reliable consent-aware analytics.

Upload only the **contents** of `out/` (or identical `dist/client/`) to the document root after making a recoverable backup. Preserve `.htaccess`, DNS, MX, mail and SSL configuration. Exact commands and post-publish checks are in `PRE_DEPLOY_CHECKLIST.md`. No upload, DNS change or public deployment was performed.

## 15. Remaining blockers

1. Zero of the 20 national practical guides has reviewed composed instructions, per-fact source mapping, reviewer and publication dates.
2. Dutch integration exams and Reporting discrimination lack dedicated research dossiers; Finding work, Dutch bank account and Student housing still lack governed canonical procedural source records.
3. The 15 public guides remain Amsterdam-focused source summaries; national and municipal instructions must stay separated during editorial composition.
4. English is the only reviewed web locale. Dutch/Russian content and legal text cannot be presented as complete.
5. The live source/media gate has 18 confirmed 404 responses in the immutable released runtime. They cannot be corrected by mutating the published Amsterdam batch; a patch candidate must canonicalize licence URLs, remove/replace dead media and manually resolve the probable BREDA anti-bot case.
6. The current importer and global duplicate gate do not yet support same-ID overlay patches. The immutable overlay/lineage mechanism in `DataProject/operations/amsterdam-v0.1.1-remediation-plan.md` must be implemented and tested before a safe `amsterdam-v0.1.1` candidate can exist.
7. Map precision is limited by coarse/repeated coordinates in the canonical release.
8. Secure submissions, accounts, app sync, partner dashboard, campaigns, billing and real analytics require backend and policy decisions.
9. Real iPhone Safari PWA/offline testing and live Hostinger headers/404/MIME/HTTPS checks require a device or approved deployment.
10. The repository path contains `:`, so `node_modules/.bin` is unreliable; CI or a colon-free checkout is recommended.
11. `reviewer-registry.json` and `guide-evidence-registry.json` are empty by policy. A real named human review and hashed QA artifact are non-delegable publication inputs.
12. The autonomous HTML readiness report passes structural/artifact validation, but two local headless-Chrome interactive verification attempts timed out (10 s and 60 s); no visual PASS is claimed for that report.

## 16. Exact next steps

1. Editorially compose one pilot guide from governed sources, preferably Registering at a municipality, then map every factual block to source IDs.
2. Obtain specialist review, reviewer identity and verified/updated dates; validate national versus gemeente-dependent rules.
3. Promote only that complete payload through the existing DataProject release workflow and rerun all gates.
4. Confirm the public detail page, search terms and journey ordering against the released runtime artifact.
5. Repeat for the remaining 19 topics; add governed sources first for the three explicit gaps.
6. Implement the immutable overlay resolver described in `DataProject/operations/amsterdam-v0.1.1-remediation-plan.md`, then create `amsterdam-v0.1.1` as a QA candidate for the 18 immutable-release failures. Do not edit `amsterdam-v0.1.0` in place; do not publish the patch without explicit approval. Rerun `check-external-links.py` and require a passing network health gate.
7. Run `NODE_BINARY=/absolute/path/to/node bash scripts/pre-deploy.sh` and complete the manual checklist.
8. After every content and network gate passes and explicit deployment approval is given, upload the contents of `out/`, then rerun live Lighthouse, headers, PWA, forms, links and true-404 checks.

## 17. Readiness assessment

- Public utility: **PARTIAL / strong catalogue and workflow shell; content depth is the limiting factor**.
- Backup web app: **PARTIAL** — local static/PWA behavior is verified for released content, but external-link health blocks release and iPhone Safari/live-host checks remain.
- SEO: **PASS in local static-export checks within the reviewed English scope** — 224 indexable canonical URLs and no draft indexing; live verification remains pending.
- Business acquisition: **READY for transparent inquiry acquisition without backend; operations are not ready**.
- Production deployment: **NOT READY** — build/type/lint/test/smoke/internal-link/security/package-invariant subchecks pass, but both the aggregate pre-deploy gate and `scripts/run-static-qa.sh` fail at `governed_broken_links=18`; the requested full-guide content is also absent. No public deployment was performed.

## 18. Files and evidence

Changed-file inventory: `CHANGED_FILES.md`  
Deployment procedure: `PRE_DEPLOY_CHECKLIST.md`

Evidence directory:

`/Users/ivan/.codex/visualizations/2026/07/20/019f7e59-d156-7093-89db-85be4b7f0adb/`

Primary content evidence:

- `DataProject/quality/content-readiness-matrix.json` and `.md` — reproducible coverage/readiness matrix.
- `DataProject/quality/priority-1-editorial-handoff.json` and `.md` — exact research-to-editorial queue and blockers.
- `DataProject/research/priority-1-government/priority-1-government-sources-2026-07-20.json` — 58 facts / 24 official sources.
- `DataProject/research/priority-1-daily/priority-1-dossiers.json` — 54 facts / 36 source records.
- `DataProject/operations/amsterdam-v0.1.1-remediation-plan.md` — exact fail-closed plan for the 18 immutable-release URL failures and the required overlay mechanism.
- `content-readiness-artifact.json` and `content-readiness-report.html` — portable report artifact; structural validation passes, while interactive Chrome verification timed out and is not represented as a visual pass.

Current screenshots:

- `younew-home-320x568.png`
- `guide-summary-top-1440x900.png`
- `journeys-390x844.png`
- `map-1280x800.png`
- `map-selected-utrecht-1280x800.png`
- `business-media-kit-1440x900.png`
- `business-media-kit-demo-1440x900.png`
- `phase2-offline-guide.png`

Current Lighthouse reports:

- `phase2-lighthouse-mobile.report.json` and `.html`
- `phase2-lighthouse-desktop.report.json` and `.html`
- `phase2-lighthouse-guides-woon.report.json` and `.html`
- `phase2-lighthouse-journeys.report.json` and `.html`
- `phase2-lighthouse-map.report.json` and `.html`
- `phase2-lighthouse-business-media-kit.report.json` and `.html`

Runtime and print evidence:

- `phase2-offline-guide-check.json`
- `phase2-guide-print.pdf` — 213,631 bytes, 2 pages
- `phase2-media-kit-print.pdf` — 352,779 bytes, 8 pages

Earlier Phase 1 browser/PWA evidence remains in the same directory. No result in this report is presented as a public production check.
