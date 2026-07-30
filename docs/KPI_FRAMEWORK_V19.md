# YouNew KPI framework — v19

Status: measurement specification for the v19 release candidate. It does not claim current product performance.

## Confirmed measurement baseline

- Production Supabase currently contains 82 consented `app_events`, 13 anonymous app instances, 13 sessions and 3 `business_inquiries`.
- All 3 recorded business inquiries are controlled test records. They must be excluded from demand, conversion and revenue claims.
- The sample is too small to set statistically reliable product or commercial targets.
- Web analytics are consent-based. Every KPI must therefore report the consented sample size and must not be presented as a census of all visitors.
- Planner saves use the production-allowlisted `item_saved` event with `content_id = planner_route`. No location, profile selection or free-text query is sent in that event.

## Primary KPIs

| KPI | Definition | Required dimensions | Decision supported |
|---|---|---|---|
| Route-save activation | Distinct sessions with `item_saved` and `content_id = planner_route` / distinct consented sessions that viewed `/start/` | period, platform, language | Whether the next-step planner produces enough immediate value |
| 28-day returning use | Consented app instances active on at least 2 distinct days in the 28 days after first activity / consented app instances first seen in that cohort | cohort week, platform, language | Whether YouNew becomes a repeat-use utility |
| Qualified business lead conversion | Server-validated, non-spam business inquiries / consented sessions that viewed `/business/apply/` | inquiry type, organization type, target audience | Whether the business proposition creates real demand |

`Qualified` must be a governed admin status, not inferred from message text. Personally identifiable fields must never be copied into analytics.

## Diagnostic drivers

| Driver | Definition | Interpretation |
|---|---|---|
| Search success | Search events with `has_results = true` / all search events | Low values indicate content or vocabulary gaps |
| Official-source continuation | Distinct sessions with `official_source_click` / sessions viewing a guide or record with a source link | Measures whether content leads to a responsible next action |
| Save rate | `item_saved` events excluding planner saves / eligible content-detail sessions | Measures future-use intent |
| Journey completion | Completed published journey steps / started published journey steps | Measures practical progression, reported per journey |
| Business form completion | Accepted server submissions / business apply page sessions | Separates proposition weakness from form friction |

## Guardrails

- Search no-result rate and top zero-result intent categories.
- Content freshness: share of published records within their configured review interval.
- Publication integrity: number of records bypassing schema, source, editorial or human-review gates; target is always zero.
- Public feedback rate, error rate and time to triage.
- Spam/rejected business inquiry rate.
- Core Web Vitals by route template.
- Emergency and legal pages must remain free of commercial placements.

## Provisional benchmark ranges

These are hypotheses for the first measurement cycle, not commitments:

- Route-save activation: 15–25%.
- 28-day returning use: 10–20%.
- Business form completion: 3–8%.

Replace these ranges after at least four complete weeks and enough volume to report each denominator without unstable single-digit changes. Review weekly for operations and monthly for product decisions.

## Instrumentation backlog

1. Add an aggregate admin view for `/start/` page sessions, planner saves and route-save activation.
2. Add cohort-safe returning-use aggregation in SQL; expose aggregates only.
3. Add governed business inquiry lifecycle statuses and a qualified-lead definition.
4. Add publication freshness and zero-result intent reports.
5. Add a versioned analytics contract test that compares every web event name with the production RPC allowlist before release.
