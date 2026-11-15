# Leiden nature and culture — batch 2, 15 November 2026

Prepared for owner/editor approval in draft PR #64. **5 revised existing places, 0 new IDs, 0 new approvals, 0 new production publications.** Base: main `f8e0d03` after the approved first batch (#62). The former dependency on draft iOS PR #63 has been removed; no iOS files or PR #59/#60 changes are included.

## Content and evidence

| Existing place | Prepared EN/NL information | Navigation and media |
| --- | --- | --- |
| De Burcht | Defensive mound, wall walk, historic entrance, free admission and access notices | Visit Leiden destination; W. Bulach photo, 2019-05-14, CC BY-SA 4.0 |
| Wereldmuseum Leiden | Visitor entrance, 2026 prices/age bands, December openings/closure, lifts/toilet and scooter/trailer restriction | Visit Leiden destination; Sneeuwvlakte photo, 2024-11-08, CC BY-SA 4.0 |
| Het Plantsoen | Landscape history, paths and gradients, aviary, Singelpark route, current municipal bird notice | Verified area address/postcode and Visit Leiden destination; Rudolphous photo, 2021-08-06, CC BY-SA 4.0 |
| Leidse Hout | Trees/lawns/pond, bandstand, deer enclosure, tea-house planning and bird notice | Visit Leiden destination; Marianne Cornelissen-Kuyt photo, 2017-09-21, CC BY-SA 4.0 |
| Polderpark Cronesteyn | Habitats, walks, arrival, dated maintenance context and bird notice | Visit Leiden destination; Ronald van der Graaf photo, 2016-06-05, CC BY 2.0 |

The batch contains **56 bilingual source-linked blocks, 14 distinct official source pages, five documented route destinations and five visually inspected real photographs**. Fifteen official URLs were fetched successfully (HTTP 200), including one extra travel-information page. Five addresses were rechecked; park pins are source-published navigation references, not surveyed accessible entrances. There is one verified Tickets link, for Wereldmuseum; parks have no invented ticket buttons. Related links connect these places with relevant existing park and museum records.

Wereldmuseum's 2026 tariff distinguishes adults 19+, ages 6–18 and ages 0–5; online/desk prices and proof requirements remain separate. No visit duration, real-time capacity, guaranteed access, 24-hour opening or event availability is invented. Plantsoen's un-rechecked legacy free-entry assertion is omitted from this revision. The Cronesteyn maintenance notice is historical, not a live closure feed. The municipal bird notice is dated 5 November 2026 and paraphrased with a direct source link; park review frequency is seven days. Recheck volatile information before any later publication.

`records.json`, `manifest.json`, `link-checks.json`, `coordinate-evidence.json` and `media-evidence.json` live in the existing `DataProject/editorial/leiden-nature-culture-20261115/` batch. Each photograph has photographer, capture date, source/license links, original checksum and visual review. Fifteen uncropped WebP variants (480/800/1200 px) total about 2 MB; each 480 px image is under 80 KB. No AI imagery or new dependency. Earlier download failures are resolved; unselected gate/toned-wall candidates were not imported into the batch.

## Existing release pipeline preserved

The existing `place-review.mjs` accepts only the two registered batches. Ordinary builds apply explicitly approved revisions and skip this pending batch. Private review selects batch 2 while retaining the five approved first-batch cards/photos. Reapplying an already projected approved revision is idempotent. Publication remains bound to the exact records/media digest and an active human owner in the existing registry.

The batch remains `needs_review`, `publicationAuthorized: false`, with null reviewer/approval. Historical staging records, the 71-record release approval and first-batch content/approval are unchanged. The normal generated public dataset is **byte-identical to main: 76 entities (54 places, 17 summaries, five cities)**. No new catalog, status system, backend, schema migration, hosting charge or production write.

Private review command (Node 24 and existing dependencies):

```sh
cd admin-dashboard/public-site
YOUNEW_PLACE_REVIEW=leiden-nature-culture-20261115 node scripts/build-place-review.mjs
HOST=127.0.0.1 PORT=4184 node scripts/preview.mjs
```

The private artifact has a visible pending-review banner, noindex HTML/headers, disallow-all robots, an empty sitemap and `PRIVATE-REVIEW.json`. The preview server binds only to loopback for this artifact; the production preflight rejects it. Generated private content is not committed or deployed. Public copies continue to be produced by the standard build.

## Validation

- Full existing `bash scripts/pre-deploy.sh`: **PASS**, including build, TypeScript, ESLint, **258 tests**, schema/governance, 608-URL normal smoke check, internal links/assets, security and deployment invariants.
- Four focused batch-2 regressions exercise stable IDs/URLs, 76-record projection, five media/coordinates, optional tickets, source/coordinate/license rejection, schema, draft exclusion, and preservation of the approved first batch.
- Private build: **PASS**. Ten EN/NL place pages checked in Chrome through existing Playwright at 390×844; desktop interaction at 1280×1000. Browser plugin not available; no dependency installed.
- Page identity, nonblank content, one H1, language/canonical, review/noindex state, source date, loaded image with alt, conditional tickets and route links: **PASS**. No horizontal overflow, app console warning/error or framework overlay.
- Actual interactions: home → Leiden → Burcht; Save → Saved → return → remove test save; EN → NL → EN; Website opens official Visit Leiden; outdoors category → Plantsoen; theme toggles and returns: **PASS**.
- Screenshots visually inspected: first viewport on mobile NL and desktop EN. Photo subjects and all five source/licensing records inspected separately.
- GitHub checks on the completed head are recorded in the PR. Production, Safari/native Share, iOS, native MapKit, App Store and field Core Web Vitals are outside this draft's validation.

Evidence outside Git: `/Users/ivan/YouNew-Nature-Evidence-2026-11-15/` — `predeploy.log`, `private-build.log`, `normal-baseline.json`, `private-browser.json`, screenshots, original source/media snapshots and `CONTENT_REVIEW.html` for owner review. The HTML review sheet links all ten local preview routes and their official sources.

## Release boundary and next batch

Owner approval of this exact content/media batch is still required before merging for publication or deploying; approval of #62 does not authorize batch 2. When approved, recheck prices, hours and notices, bind the existing approval manifest, run QA, preserve production backup/rollback and publish through the existing Hostinger release procedure.

After this batch, choose five existing Leiden café/restaurant records for research. No third batch was started. PR #59, #60 and #63 remain separate and unmerged.
