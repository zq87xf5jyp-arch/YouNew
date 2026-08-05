# Release-critical practical guides v2 — editorial handoff

Status: **DRAFT / NOT AUTHORISED FOR PUBLICATION**

Prepared: 2026-08-05

Bundle: `DataProject/staging/release-critical-practical-guides-v2.json`

## Scope

The bundle contains eight English schema-v2 draft guides covering the seven distinct journeys behind the eight required production searches:

| Guide | Release-critical search coverage | Jurisdiction risk |
|---|---|---|
| Getting a BSN | `BSN + Eindhoven` | National BRP/RNI split; municipal execution |
| Finding a huisarts | `huisarts + Rotterdam` | National coverage rules; local practice capacity |
| Renting a home safely | `rent + Den Haag + Worker`; `housing rent + Den Haag + Worker` | National tenancy rules; municipal permits/allocation |
| Finding work | `work + Leiden` | National work-authorisation branches; local vacancies |
| Understanding an employment contract | Follow-on from the work journey | CAO, sector and individual-contract variation |
| Registering a child at school | `Dutch school + Groningen` | Municipal/school-board allocation and support |
| Choosing a SIM card | `SIM card + Maastricht` | National consumer rules; provider/location coverage |
| Handling a parking or traffic fine | `parking fine + Utrecht` | Utrecht/BghU parking tax versus national CJIB M fine |

Each draft includes the user need, audience, prerequisites, documents, timing, costs, numbered steps, warnings, mistakes, tips, checklist, at least three FAQs, urgent context, local variation, official contacts, related topics and per-fact source IDs.

## Confirmed source risks

1. **Rental deposit conflict:** an older Government.nl deposit FAQ surfaced a different maximum, while the current 2026 tenant step plan states two months' basic rent for agreements dated 1 July 2023 or later. The draft uses only the newer, more specific tenant step plan. A housing reviewer must recheck both live pages and contract-date scope.
2. **Utrecht amount changed:** the live Utrecht page checked on 2026-08-05 states a €78.80 enforcement surcharge plus the unpaid hourly tariff. Do not reuse an earlier €77.70 figure.
3. **CJIB access restriction:** official search results exposed the current six-week appeal, eight-week payment and up-to-sixteen-week decision wording, but direct automated opening returned HTTP 403. These sources are marked `access_restricted`; a human must reopen them before approval.
4. **School dates are volatile:** the national secondary-school page states 25–31 March, but the applicable school year and Groningen process must be checked before publication.
5. **SIM source language:** the ACM ConsuWijzer evidence is Dutch. The English draft wording needs bilingual consumer-rights review. Provider-specific prepaid, eSIM, identity, credit and activation rules are intentionally not inferred.
6. **No fake locality:** Leiden vacancies, Rotterdam GP capacity, Groningen school allocation, Maastricht coverage and Den Haag housing permits need current local sources or a safe official local handoff. A city name in search metadata is not evidence for a city-specific procedure.

## Required human review

For each guide, the reviewer must:

1. reopen every official source and record the final URL, access result and checked date;
2. verify every source-to-text mapping, deadline, amount and jurisdiction statement;
3. add the missing municipality/provider branches or keep the limitation explicit;
4. select licensed local media, accessible alt text and a safe local asset path;
5. edit the English copy and commission independently reviewed Dutch and Russian translations;
6. register a real reviewer in `DataProject/operations/reviewer-registry.json`;
7. run schema, source, link, language, media, duplicate-content and accessibility QA;
8. store hashed QA evidence in `DataProject/operations/guide-evidence-registry.json`;
9. only then set `verified_at`, `reviewer`, `confidence_level: high`, and a passed `publication_gate` before moving a parent entity to `published`.

Until every step is complete, the bundle must remain outside the runtime dataset and public search index.
