# YouNew information architecture audit

Date: 2026-08-06  
Scope: public website, generated production content, static export, global navigation, homepage and primary newcomer journeys.

## Executive conclusion

The previous homepage treated most content collections as equally important. The rebuilt homepage now follows one narrowing journey:

1. understand the YouNew promise;
2. describe or choose one task;
3. narrow to one life area, city or service;
4. open a concrete guide or responsible official source.

The content catalogue remains searchable and indexable, but no longer controls the homepage hierarchy.

## Confirmed evidence

| Check | Result |
| --- | ---: |
| Generated public records | 181 |
| Generated city records | 5 |
| Generated guide records | 15 |
| Generated organization records | 30 |
| Generated place records | 131 |
| Generated categories | 32 |
| Static HTML files | 606 |
| Next.js generated routes | 609 |
| Checked internal references, fragments and assets | 47,402 |
| Broken internal references | 0 |
| Duplicate entity routes | 0 |
| Duplicate canonical URLs | 0 |
| Static orphan routes after the IA fixes | 0 |
| Main-content pages with less than 120 readable characters | 0 |

The only repeated HTML title belongs to the two expected static representations of the 404 page (`/404/` and `/404.html`). This is an export detail, not duplicate user content.

Evidence was produced by:

- `pnpm build:sites`;
- `pnpm check:links`;
- `pnpm check:security`;
- `pnpm audit:ia`;
- the generated `src/generated/public-content.json` snapshot.

Visual evidence:

- before: `/Users/ivan/.codex/visualizations/2026/08/05/019fd1c2-51b1-7923-b9c3-7cc4304ddd07/homepage-rebuild-before-viewport.png`;
- after, desktop: `/Users/ivan/.codex/visualizations/2026/08/05/019fd1c2-51b1-7923-b9c3-7cc4304ddd07/homepage-rebuild-after-desktop.png`;
- after, mobile: `/Users/ivan/.codex/visualizations/2026/08/05/019fd1c2-51b1-7923-b9c3-7cc4304ddd07/homepage-rebuild-after-mobile.png`.

## Confirmed structural risks

### 1. Twenty-two categories have no linked published entities

The affected slugs are:

`banking`, `benefits`, `business`, `children`, `daily-life`, `documents`, `emergency`, `family`, `fines`, `integration`, `internet`, `language-learning`, `legal-help`, `municipal-services`, `pets`, `rules`, `safety`, `shopping`, `sim-telecom`, `taxes`, `utilities`, `work`.

These are not automatically blank pages. Where a governed life-domain route exists, YouNew renders a national starting route with official sources. The correct description is therefore **zero linked published entities**, not **empty page**.

Implemented correction: category copy now states this distinction, and national guide pages are linked from their matching category routes. The `sim-telecom` category is explicitly linked to the governed national guide whose content category is `telecom`, while retaining its existing taxonomy route.

### 2. Some screens expose few static next links

The export audit finds limited static main-content links on `emergency`, `my-younew`, `privacy`, `saved`, `search`, `start`, `support` and `terms`.

This is not the same as being orphaned: several of these screens use client-side controls, saved state or external official actions. However, `terms` and `support` should receive an explicit contextual next step in a later content pass.

### 3. The generated content is unevenly distributed

Most published entities are places and organizations, while many practical newcomer topics are currently national starting routes. The new architecture prevents this dataset imbalance from making cultural and directory content dominate the first screen.

## Implemented information architecture

```text
Home
├── Hero: promise + emotional Netherlands photography
├── Task search
├── What do you need? (10 task destinations)
├── Life in the Netherlands (12 directions)
├── Popular tasks (10 direct actions)
├── Cities (6 featured routes)
├── Useful services
│   └── Trusted official resources
├── Why YouNew
├── Business
│   ├── Advertising standards
│   └── Partnerships
└── Latest updates

Second level
├── Task-aware search results
├── Category or national starting route
├── City / municipality route
├── Service / organization route
└── Business route

Resolution level
├── Practical guide
├── Published entity detail
└── Responsible official source
```

Global navigation is limited to eight product destinations plus Search and the persistent Emergency action:

`Explore`, `Housing`, `Work`, `Healthcare`, `Services`, `Cities`, `Guides`, `Business`.

## Three-click model

| User intent | Click 1 | Click 2 | Click 3 or resolution |
| --- | --- | --- | --- |
| Find housing | Housing task | Housing category/search | Guide or official source |
| Get a BSN | Popular task | Published BSN guide | Municipality/official source |
| Find a GP | Healthcare task | Ranked search result | Guide or provider/source |
| Learn Dutch | Popular task | Ranked education route | School, guide or official source |
| Explore a city | Featured city | City/municipality page | Place or responsible service |
| Advertise | Business block | Advertising standards | Application route |

Emergency remains a direct one-click route and is not mixed with advertising.

## Content and routing policy

- Keep existing stable URLs during the IA transition; do not delete routes solely to simplify navigation.
- Remove catalogue counts and internal operational evidence from the homepage.
- Keep categories as the second level, not the main homepage model.
- Link national starting guides from matching category routes so search-only destinations remain crawlable.
- Keep official sources visible for consequential tasks.
- Keep sponsored placements out of emergency guidance, official-source responsibility and organic ranking.
- Show no live advertisement until a real campaign has passed review and activation.

## Recommended backlog

### P1 — content depth

1. Prioritize source-checked practical content for `work`, `documents`, `benefits`, `taxes`, `banking`, `pets` and `family`.
2. Add an explicit contextual next step to `terms` and `support` without turning them into navigation hubs.
3. Measure hero search use, task selection and successful guide/source opens with privacy-bounded events.

### P2 — controlled consolidation

1. Review overlap between `children` and `family`, `internet` and `sim-telecom`, and `fines` and `rules`.
2. If categories are merged, preserve old URLs with permanent redirects and update the sitemap atomically.
3. Review whether `/my-younew/` and `/saved/` should remain separate after real usage data exists.

## Assumptions requiring product data

The new order is based on the supplied product vision and common newcomer tasks, not on production funnel analytics. The design should be validated with task-success, search refinement and exit-rate data after release. No testimonials, advertiser logos, conversion claims or user-volume claims were invented.
