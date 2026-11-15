# Leiden nature and culture — approved batch 2, 15 November 2026

The owner approved the five EN/NL cards and PR #64, including production after an official-source recheck, in this conversation on 15 November 2026. Approval is bound to review commit `9fc8d2037796eef000cca422f80db81cdbb49da7` and unchanged records SHA-256 `69e33fc1e50ce0dd813ff385be98c4966e394042252299c5cd62371f47323c0f`.

**Prepared: 5 existing places. Approved: 5. New IDs: 0.** Deployment is a separate Hostinger operation after CI and authenticated QA; its outcome and rollback record are saved in `/Users/ivan/YouNew-Nature-Publish-Evidence-2026-11-15/RELEASE_REPORT_RU.md`.

## Approved content

| Place / existing URL slug | EN/NL information | Photograph |
| --- | --- | --- |
| De Burcht / leiden-burcht | Defensive mound, wall walk, historic entrance, free admission, access notices | W. Bulach, 2019-05-14, CC BY-SA 4.0 |
| Wereldmuseum Leiden / leiden-wereldmuseum | Visitor entrance, 2026 admission/age bands, December hours, scooter/trailer restrictions | Sneeuwvlakte, 2024-11-08, CC BY-SA 4.0 |
| Het Plantsoen / leiden-plantsoen | Landscape history, gradients, aviary, Singelpark route, municipal bird notice | Rudolphous, 2021-08-06, CC BY-SA 4.0 |
| Leidse Hout / leiden-leidse-hout | Trees, lawns, pond, bandstand, deer enclosure, tea-house planning, bird notice | Marianne Cornelissen-Kuyt, 2017-09-21, CC BY-SA 4.0 |
| Polderpark Cronesteyn / leiden-cronesteyn | Habitats, walks, arrival, historical maintenance context, bird notice | Ronald van der Graaf, 2016-06-05, CC BY 2.0 |

Public paths retain `/places/<slug>/` and `/nl/plaatsen/<slug>/`. The batch has 56 bilingual source-linked blocks, 14 distinct official content sources, five rechecked addresses, five documented route destinations and five visually inspected real photographs. Fifteen official URLs returned HTTP 200 in the fresh prepublication check, including the additional museum travel-information page.

Prices, hours and constraints matched the approved text: Wereldmuseum distinguishes online/desk tariffs, age bands and evidence required for concessions. Its dated December exceptions are retained. Exact hours for De Burcht, Leidse Hout and Cronesteyn remain unspecified; park admission prices and step-free entrances are not invented. The March Cronesteyn maintenance notice is historical, not a live closure feed. The 5 November municipal bird notice is linked and dated; park review frequency is seven days.

Each image records photographer, capture date, source, license and original checksum. Fifteen uncropped WebP variants (480/800/1200 px) total about 2 MB; 480 px variants are under 80 KB. Responsive ContentMedia now recognizes the approved second-batch public paths. No AI images or new dependencies.

## Existing publication contract

`DataProject/editorial/leiden-nature-culture-20261115/manifest.json` is approved by the existing registered human owner `owner.ivan`. The approval digest binds IDs, records and all media variants. Records retain their archived draft lifecycle; only the existing governed projection publishes approved revisions. A temporary pending-manifest fixture confirms that removing approval withholds this batch from ordinary builds.

The original 71-record release and the first five approved revisions remain intact. Public output still contains **76 entities: 54 places, 17 summary guides, five cities, zero full practical guides**, now with ten photographed places. Both approved revision digests are exposed in provenance; every editorial entity shares the resulting batch digest. `src/config/status.json` remains the single status source and receives the matching content fingerprint through the normal build. PARTIAL, static-monitoring, field-CWV and iOS limitations remain unchanged.

A private preview remains explicitly selectable using `YOUNEW_PLACE_REVIEW=leiden-nature-culture-20261115 node scripts/build-place-review.mjs`. It is never the production candidate. The production preflight rejects private review markers/assets, and the ordinary candidate contains no draft banner or private review directory.

## Validation and release safety

- Full existing `bash scripts/pre-deploy.sh`: **PASS** — build, TypeScript, ESLint, **259 tests**, schema/governance, internal links/assets, security, 608 sitemap URLs and deployment invariants.
- Regression coverage checks stable IDs/URLs, exactly five second-batch revisions, media/coordinates, optional tickets, source/coordinate/license rejection, approval binding, pending-batch exclusion and preservation of the first batch.
- Private review before approval passed all ten EN/NL pages at 390×844 plus desktop interactions at 1280×1000 in existing Chrome/Playwright. Browser plugin unavailable; no dependency installed. Actual home → Leiden → place, Save/Saved/remove, EN/NL, official Website, Tickets, map search → record, category → park and theme checks passed. Clipboard Share fallback was tested with missing native API explicitly simulated; the OS share sheet was not tested.
- Approved build repeats browser checks locally and after publication; authenticated Hostinger QA verifies exact file hashes and restores its preceding pointer and G01 EN/NL pages. Results are recorded in the release evidence, not inferred from the previous draft.
- GitHub checks must pass on the exact publication head before merge. Only #64 is authorized; #59/#60/#63 remain separate. No iOS files are included.
- Snapshot all current public files/configuration; verify archive restoration and rehearse candidate/backup directory exchange in isolation. Preserve PHP endpoints, server directives, old static assets, private queue and Admin configuration. The rollback swaps static files only and never restores the database or discards new submissions.

Release evidence: `/Users/ivan/YouNew-Nature-Publish-Evidence-2026-11-15/` (source recheck, predeploy/CI logs, authenticated QA result, backup/checksums, stage/activation results, browser results and screenshots). Previous private-review evidence remains in `/Users/ivan/YouNew-Nature-Evidence-2026-11-15/`.

No purchased services, DNS/mail changes, database migration or new dependencies. The next content priority is five existing Leiden café/restaurant records, requiring its own research and approval.
