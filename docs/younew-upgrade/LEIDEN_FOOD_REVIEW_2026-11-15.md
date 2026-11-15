# Leiden cafés and restaurants — approved batch 3, 15 November 2026

**Prepared: 5 existing places / 10 EN/NL pages. Approved: 5. New IDs: 0.** The owner approved these five cards together with the 44-card expansion and PR #68/#72 on 15 November 2026. The exact records SHA `28fc12087c3226f81f890a0899c8ffc2722b5593742ad45fac1b9dd008989827` and photos remain unchanged. All 21 sources were rechecked; prices/hours/restrictions match. The manifest now records the registered human owner and approval digest. Deployment follows combined Hostinger QA; final publication evidence is `/Users/ivan/YouNew-Expansion-Publish-Evidence-2026-11-15/RELEASE_REPORT_RU.md`. PR #59/#60 remain separate.

## Review scope

| Existing place / URL slug | Checked menu examples (individual items) | Hours and conditions | Photograph |
| --- | --- | --- | --- |
| Waag Leiden / leiden-waag | Avocado sandwich €11.50; pepper risotto €23.50; flat-iron steak €27.50 | Sun–Wed 09–22; Thu 09–00; Fri–Sat 09–01. Lunch until 16; dinner from 17; check holidays | C messier, 2017-02-03, CC BY-SA 4.0; exterior |
| Grand Café De Burcht / leiden-grand-cafe-burcht | Ham/cheese toastie €8; salmon sandwich €14.50; celeriac steak €21 | Mon on request; Tue/Sun 11–21; Wed/Thu 11–00; Fri 11–01; Sat 10–01. Lunch 11:30–15:30; online booking | G.Th. Delemarre, 1963-03, CC BY-SA 4.0; archival Heerenlogement courtyard façade, not current café décor |
| Oudt Leyden / leiden-oudt-leyden | Syrup pancake €9.90; apple/cinnamon €11.90; bacon/cheese €13.90; children's poffertjes €7.50 | Daily 11:30–21:30. No split bills during busy periods or for large groups | Ngchikit, 2019-04-27, CC BY-SA 4.0; restaurant exterior |
| ROOS / leiden-roos | Cappuccino €3.65; jam croissant €4.60; ham/cheese toastie €8.90 | Daily 08–18; breakfast 08–12; lunch 08–17:30. Walk-ins, no reservations | Rudolphous, 2010-02-06, CC BY 3.0; **Botermarkt 12 before ROOS, former Café Macchiato sign** |
| Het Prentenkabinet / leiden-prentenkabinet | Dinner 3/4-course surprise menus €52.50/€62.50; lunch 2/3 courses €37.50/€42.50 | Lunch Thu–Sat 12:30–15:30, arrival by 14:30; dinner Mon–Sat 17–23:30, arrival by 20:30. Smoke-free terrace | Rudolphous, 2010-02-03, CC BY 3.0; restaurant façade |

Paths remain `/places/<slug>/` and `/nl/plaatsen/<slug>/`. There are 60 original source-linked bilingual sections, 21 distinct official content/route URLs, five verified addresses and five route destinations. The URLs returned HTTP 200 on 15 November; response hashes and timestamps are in the batch's `link-checks.json`. Raw HTML/PDF snapshots are kept outside Git in the local evidence directory. The ROOS PDF was visually checked to distinguish breakfast, lunch and drink prices.

Prices are examples from the linked menu, not estimated meal budgets; drinks/add-ons are excluded where applicable. No availability, dietary safety or accessible entrance is promised. Existing Website, Directions, Save, Share, language and source actions are reused. Restaurants do not get a misleading Tickets button. There are no booking submissions or messages to businesses.

## Source decisions and photo limitations

- ROOS: Visit Leiden gives 08:30 and all-day breakfast; the operator gives 08:00 and its menu specifies breakfast until 12:00. Use the operator for hours/menu; Visit Leiden only for address/route.
- Het Prentenkabinet: the tourism listing's dinner schedule differs from the restaurant's reservation page. Use the operator's service days and arrival cutoffs. An undated year-end closure notice is not converted into a 2026/27 promise; visitors are sent to the reservation page for seasonal closures.
- Waag's holiday notice also has no explicit year; no inferred-year holiday calendar is added.
- Five licensed real exterior photographs are included, each with capture date, author, original URL/checksum and licence. **These are historical exterior images, not verified 2026 interiors or food photography.** ROOS and Grand Café have explicit archival captions in both languages; ROOS's old business sign is disclosed. These two image choices are part of the owner's editorial review, not silently presented as current venue photographs.
- Each original is resized without cropping/content edits into 480/800/1200 px WebP; derivatives retain the source licence. No image is taken from a venue's website without reuse permission. No generated imagery.

## Existing governance and validation

The existing `place-review.mjs` registry gains `leiden-food-20261115`; no new catalogue or approval system. Manifest `needs_review`, `publicationAuthorized=false`, no reviewer/approval date. Original staging files, IDs, URLs and the two approved batches are retained and hash-bound. Pending food revisions stay out of ordinary public content. Private mode requires both the selected batch and `YOUNEW_PRIVATE_REVIEW_BUILD=1`; the existing private build adds noindex/noarchive, disallows crawling and empties sitemap.

Regression coverage checks five-ID isolation, preserved previously published content (allowing only the existing shared preview digest to change), no ordinary food release, EN/NL sections, archival captions, optional ticket absence, exact route destinations, source references, licence/media integrity and the existing DataProject schema. The prior nature pending-manifest fixture now links all other registered batches so it continues testing isolation as the registry grows.

Ordinary local build and all ten existing pre-deploy stages passed: TypeScript, ESLint, 263 tests, governance/schema, 608 sitemap URLs and 37,257 internal references across 636 HTML files. `public-content.json` is byte-identical to main (SHA-256 `2cbe9da2398a62c12be4a433e30bd568943031d144c8de55e5da6e13c9d439c5`). Initial disk-space failures and two test-authoring issues were resolved before this result.

Reproduce ordinary checks from `admin-dashboard/public-site` with Node 24 and `bash scripts/pre-deploy.sh`. Then run `YOUNEW_PLACE_REVIEW=leiden-food-20261115 node scripts/build-place-review.mjs` for a private review build. Serve it through the existing preview script bound to 127.0.0.1. Browser plugin is unavailable; the existing local Playwright/Chrome installation is used without installing dependencies.

Validation results and screenshots are recorded in `/Users/ivan/YouNew-Food-Evidence-2026-11-15/`. The owner review document is `CONTENT_REVIEW.html`. The Draft PR description records the final CI result on the exact submitted commit; local evidence is not a claim of Hostinger QA, production deployment, field Web Vitals or iOS/App Store validation.

## Publication boundary (original Draft before approval)

This PR must remain a draft pending review of this exact batch. Approval would require rechecking volatile menu prices, hours and exceptional dates; then binding owner approval to records/media hashes through the existing mechanism. A later authorized release must snapshot current Hostinger configuration and static files, verify restoration, test an isolated candidate and retain a static-only rollback. No production, DNS, mail, database, iOS or paid-service action is included here.
