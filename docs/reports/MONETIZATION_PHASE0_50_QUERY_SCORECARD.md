# Monetization Phase 0: 50-query scorecard

Date: 2026-08-18 (Europe/Amsterdam)  
Source commit: `60accbcb8f8c169e1ef6e09cd7b56824bea6d08e`  
Search index: schema v3, 573 documents, SHA-256 `68a0d201921d8ab2c7ef1078422575132c3a202d30bf1e9678f1b39a93802052`

## Result

- Actionable: **31/50 (62%)**.
- Zero results: **7/50 (14%)**.
- The Phase 1 target of at least 90% actionable is not met.
- The existing exhaustive regression matrix still passes 2,608/2,608 checks because it covers seven established national guide groups, not all mandatory monetization-audit intents below.

Method: rank the production search index with the current search engine and inspect the first five results. A query is actionable only when those results contain a relevant national next-step guide or the dedicated emergency route. Category and municipality directory pages alone are not counted as actionable. A wrong-city result is not counted.

## Queries

| # | Query | Best current destination | Actionable | Finding |
|---:|---|---|:---:|---|
| 1 | BSN | Documents national guide | Yes | Exact national guide is first. |
| 2 | DigiD | Documents national guide | Yes | Exact national guide is first. |
| 3 | gemeente registration | Amsterdam registration, then Documents guide | Yes | National answer exists at rank 3; wrong-city result ranks first. |
| 4 | huisarts | Healthcare national guide | Yes | Exact national guide is first. |
| 5 | health insurance | Healthcare national guide | Yes | Exact national guide is first. |
| 6 | rental contract | Housing national guide | Yes | Exact national guide is first. |
| 7 | landlord problem | !WOON Amsterdam | No | City-specific answer is returned for an unscoped query; no national fallback. |
| 8 | work without Dutch | Work national guide | Yes | Exact national guide is first. |
| 9 | taxes | Taxes category | No | Directory only; no actionable national guide. |
| 10 | toeslagen | Benefits category | No | Directory only; no actionable national guide. |
| 11 | debt help | No result | No | Mandatory intent is absent. |
| 12 | bank account | Banking category | No | Directory only; no actionable national guide. |
| 13 | SIM card | Telecom national guide | Yes | Exact national guide is first. |
| 14 | home internet | Internet category, then Telecom guide | Yes | National guide exists at rank 2. |
| 15 | OV-chipkaart | Transport category | No | Directory only; no actionable national guide. |
| 16 | diploma recognition | Education national guide | Yes | Exact national guide is first. |
| 17 | Dutch language course | Education national guide | Yes | Exact national guide is first. |
| 18 | residence permit | Documents national guide | Yes | Exact national guide is first. |
| 19 | Dutch citizenship | No result | No | Mandatory intent is absent. |
| 20 | register a pet | Pets category | No | Directory only; no actionable national guide. |
| 21 | veterinarian | Pets category | No | Directory only; no actionable national guide. |
| 22 | fines | Rules and fines national guide | Yes | Exact national guide is first. |
| 23 | emergency | Emergency route | Yes | Dedicated emergency next step is first. |
| 24 | childcare | Family category | No | Directory only; no actionable national guide. |
| 25 | pregnancy midwife | No result | No | Published update is not discoverable for this intent. |
| 26 | mental health | Healthcare national guide | Yes | National guide is first. |
| 27 | register with gemeente in Leiden | Leiden municipality page | No | City page does not answer the requested task; national fallback is absent from top 5. |
| 28 | find a huisarts in Leiden | Healthcare national guide | Yes | National fallback is first. |
| 29 | rental contract in Leiden | Housing national guide | Yes | National fallback is first. |
| 30 | work without Dutch in Leiden | Work national guide | Yes | National fallback is first. |
| 31 | debt help in Leiden | No result | No | No national or local fallback. |
| 32 | emergency help in Leiden | Emergency route | Yes | Dedicated emergency route is first. |
| 33 | register with gemeente in Rotterdam | Rotterdam municipality page | No | City page does not answer the requested task; national fallback is absent from top 5. |
| 34 | find a huisarts in Rotterdam | Healthcare national guide | Yes | National fallback is first. |
| 35 | rental contract in Rotterdam | Housing national guide | Yes | National fallback is first. |
| 36 | work without Dutch in Rotterdam | Work national guide | Yes | National fallback is first. |
| 37 | debt help in Rotterdam | No result | No | No national or local fallback. |
| 38 | emergency help in Rotterdam | Emergency route | Yes | Dedicated emergency route is first. |
| 39 | register with gemeente in Utrecht | Utrecht municipality page | No | City page does not answer the requested task; national fallback is absent from top 5. |
| 40 | find a huisarts in Utrecht | Healthcare national guide | Yes | National fallback is first. |
| 41 | rental contract in Utrecht | Housing national guide | Yes | National fallback is first. |
| 42 | work without Dutch in Utrecht | Work national guide | Yes | National fallback is first. |
| 43 | debt help in Utrecht | No result | No | No national or local fallback. |
| 44 | emergency help in Utrecht | Emergency route | Yes | Dedicated emergency route is first. |
| 45 | register with gemeente in Eindhoven | Eindhoven municipality page | No | City page does not answer the requested task; national fallback is absent from top 5. |
| 46 | find a huisarts in Eindhoven | Healthcare national guide | Yes | National fallback is first. |
| 47 | rental contract in Eindhoven | Housing national guide | Yes | National fallback is first. |
| 48 | work without Dutch in Eindhoven | Work national guide | Yes | National fallback is first. |
| 49 | debt help in Eindhoven | No result | No | No national or local fallback. |
| 50 | emergency help in Eindhoven | Emergency route | Yes | Dedicated emergency route is first. |

## Reproduction

1. Build the public projection from the exact commit.
2. Run `pnpm qa:search` in `admin-dashboard/public-site` to verify the established 2,608-check matrix.
3. Run `pnpm qa:monetization` to evaluate the mandatory queries against `public/data/search-index.json` with the current ranker.
4. Reclassify only after reviewing the destination itself; a non-empty result is not automatically actionable.
