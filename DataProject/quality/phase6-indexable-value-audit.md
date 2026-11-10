# Phase 6 indexable-page value audit

Date: 2026-10-24. Grain: one URL from the generated sitemap. Input: the locally built `out/` package.

## Verdict

- Sitemap URLs: **456**
- PASS: **456**
- REVIEW: **0**
- FAIL: **0**
- All pages proven independently useful: **yes**
- Exact duplicate main-content groups: **0**

`REVIEW` is not called a pass. It means the route is technically usable but a human must confirm standalone value or record-level evidence before the whole sitemap can be represented as independently useful.

## Route groups

| Route group | Total | PASS | REVIEW | FAIL |
|---|---:|---:|---:|---:|
| `app` | 1 | 1 | 0 | 0 |
| `arrival-planner` | 1 | 1 | 0 | 0 |
| `categories` | 28 | 28 | 0 | 0 |
| `cities` | 1 | 1 | 0 | 0 |
| `city-guides` | 5 | 5 | 0 | 0 |
| `discover` | 1 | 1 | 0 | 0 |
| `emergency` | 1 | 1 | 0 | 0 |
| `essentials` | 7 | 7 | 0 | 0 |
| `for-business` | 4 | 4 | 0 | 0 |
| `guides` | 2 | 2 | 0 | 0 |
| `home` | 1 | 1 | 0 | 0 |
| `journeys` | 1 | 1 | 0 | 0 |
| `map` | 1 | 1 | 0 | 0 |
| `municipalities` | 343 | 343 | 0 | 0 |
| `nl` | 37 | 37 | 0 | 0 |
| `partners` | 2 | 2 | 0 | 0 |
| `places` | 1 | 1 | 0 | 0 |
| `privacy` | 1 | 1 | 0 | 0 |
| `provinces` | 13 | 13 | 0 | 0 |
| `start` | 1 | 1 | 0 | 0 |
| `status` | 1 | 1 | 0 | 0 |
| `support` | 1 | 1 | 0 | 0 |
| `terms` | 1 | 1 | 0 | 0 |
| `updates` | 1 | 1 | 0 | 0 |

## Pages requiring action

None.

## Method

Each sitemap URL was reconciled to a rendered HTML file and checked for matching canonical, indexability, H1, minimum main text, exact duplicate main content, actionable links/controls, five-word-shingle uniqueness and route-specific evidence. The thresholds are conservative heuristics; they detect risk but do not replace editorial review.
