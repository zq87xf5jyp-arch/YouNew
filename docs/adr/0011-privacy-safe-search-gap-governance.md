# ADR-011 — Privacy-safe search gap governance

- Status: proposed
- Date: 2026-08-05
- Draft author: Codex implementation agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: admin-dashboard/public-site/src/lib/search/taxonomy.ts; admin-dashboard/public-site/src/lib/analytics/client.ts; admin-dashboard/tests/search-analytics-contract.test.ts
- Related migrations: admin-dashboard/supabase/migrations/20260805122546_search_gap_analytics.sql

## Problem and context

The production search could return no results because profile and city choices
were treated as hard filters. Fixing ranking and national fallback prevents the
known failure, but content gaps will recur as users use new language. Storing
raw free-form searches would create unnecessary privacy and governance risk,
especially when a query contains an identifier or sensitive personal detail.

## Considered options

1. Do not collect search-quality telemetry and rely on manual reports.
2. Collect every raw query for maximum diagnostic detail.
3. Collect only consented, controlled-vocabulary search signals and create
   review tasks after repeated zero-result events.

## Decision

Propose option 3. Profiles influence ordering and never exclude otherwise
eligible results. Municipality and province filters retain national guidance.
The browser may send a normalized term only when every token maps to the public
EN/NL/RU taxonomy; identifier-like or unknown input becomes `[redacted]` or
`[unmapped]` before transmission. The database accepts only allowlisted event
properties, exposes aggregated search gaps through a security-invoker view and
creates an administrator task after three repeated production zero results.
Only approved administrators or the service role can read or manage tasks.

## Consequences and risks

The system can prioritize repeated gaps without retaining raw free text. This
deliberately reduces diagnostic detail, so editorial review must infer the user
need from controlled intents and filters. National fallback is useful but must
be labelled clearly and cannot be presented as municipality-specific advice.
Automatic tasks are evidence for review, not publication authorization. A
large controlled vocabulary could still make queries more distinctive, so the
allowlist, consent gate, retention policy and RLS remain mandatory controls.

## Verification

Automated tests cover the eight release-critical searches, every supported
profile, all 342 municipalities, all 12 provinces, EN/NL/RU aliases, substring
false positives, privacy markers, event-property allowlisting, RLS and task
thresholds. Pre-deploy checks additionally validate static output, links,
security headers and governance. Production verification must confirm the
public search result and analytics/Admin behavior after deployment; a critical
useless zero result remains NO-GO.
