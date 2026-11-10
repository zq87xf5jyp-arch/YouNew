# YouNew analytics operating guide

## Purpose

The protected Admin analytics page is the source-backed operating view for:

- website visits and product actions;
- privacy-safe search quality;
- website-to-business intent;
- App Store acquisition and usage reports;
- source freshness and data-quality checks.

The dashboard never equates a browser session with a person or an App Store CTA
click with a completed download.

## Metric definitions

| Metric | Definition | Source | Important limit |
|---|---|---|---|
| Period session | One distinct consented `app_events.session_id` observed inside the selected UTC period and platform scope | `analytics_v2_overview_periods` | Not a unique person; never derived by summing daily distinct sessions |
| Active instance | Random consented instance identifier | Supabase `app_events` | Web identifier lives in `sessionStorage`; not cross-session identity |
| Page/screen view | `page_view` or `screen_view` for a bounded path without query parameters | `analytics_v2_overview_periods` | Does not include people who declined analytics |
| Engaged matched session | A period session with a matching `app_sessions` row and duration of at least 10 seconds | `analytics_v2_session_quality_periods` | Diagnostic threshold; missing/mismatched session rows are shown separately |
| Median duration | Median non-negative duration among matched session rows | `analytics_v2_session_quality_periods` | Preferred over the mean for long-open tabs |
| Key action | Official-source/result open, save, completed step, business intent, or App Store CTA | `analytics_v2_overview_periods` | Action Panel CTA is contextual telemetry and is not counted again as a canonical key action |
| Geo relevance signal | One allowlisted, normalized geo event such as local result/fallback/correction | `analytics_v2_overview_periods` | Aggregate count only; no raw query, coordinates, address or individual timeline |
| App Store intent | `app_cta_click` on younew.nl | Web analytics | A click, not a download |
| First-time download | App Store Connect Summary Sales app unit | `app_store_metrics_daily` | Confirmed only after the private Apple report sync |
| Redownload | App Store Connect redownload unit | `app_store_metrics_daily` | Separate from first-time download |
| Update | App Store Connect update unit | `app_store_metrics_daily` | Not a new user or installation |
| Error event | `app_error` or `sync_failed` | Supabase `app_events` | Does not replace crash monitoring |

## Privacy and access boundary

- Analytics is opt-in on the public website.
- Raw free-form search text, form contents, email, IP addresses, advertising IDs,
  precise location and user-agent values are not stored in analytics events.
- Admin analytics views use `security_invoker = true` and are readable only by
  approved Supabase `owner` and `admin` accounts through RLS.
- Each analytics v2 view explicitly revokes `public` and `anon` access, grants
  read-only access to `authenticated`, and relies on the base-table Admin RLS
  policy. The views expose aggregates, not identifiers or raw event properties.
- Audience breakdowns are hidden in the dashboard below three sessions per
  selected period.
- App Store tables store daily country-level aggregates only; no Apple customer
  or device identifiers are accepted.
- Raw analytics retention remains 90 days.

## Scope, periods and reconciliation

The dashboard URL contract is `?days=7|30|90&platform=web|ios|all`. Invalid or
missing values safely default to `days=30&platform=web`. A Web selection never
falls back to iOS data (and vice versa); an absent selected scope is displayed as
no data. `all` is an explicit cross-platform scope and is never implicit.

The headline period covers the selected number of UTC calendar dates including
the current partial UTC date. Its session count is the exact number of distinct
`session_id` values observed in the selected event rows. Daily session values
are retained for the trend only and must not be summed to reconstruct the
headline. Session quality starts with that same event-period denominator, then
reports matched, missing and platform-mismatched `app_sessions` rows.

The comparison card has a deliberately different boundary: the last seven
complete UTC days versus the preceding seven complete UTC days. It never mixes
the partial current UTC day into either comparison window.

Average session duration is capped at 30 minutes per session for diagnostics.
Median duration is the primary duration statistic.

The event distribution lists the twelve most frequent event names. Everything
outside that list is reconciled to the headline event total as `Other`; it is
not silently dropped.

## Freshness semantics

Freshness is scoped to the selected platform and uses the most recent accepted
ingestion timestamp, not activity from another platform:

- `recent`: accepted telemetry within six hours;
- `quiet`: last accepted telemetry is more than six and no more than 24 hours old;
- `stale`: last accepted telemetry is more than 24 hours old;
- `no-data`: the selected scope has no accepted ingestion timestamp.

`quiet` and `stale` describe the age of the latest accepted record. They do not
by themselves prove that ingestion is broken; query health is shown separately.

## Geo and Action Panel interpretation

Geo counters are aggregate operational signals for explicit city detection,
city filter use/correction, local-result availability, national fallback and
wrong-geo reports. First-result opens and median time to first action remain
aggregate measures. No report exposes event properties, raw queries, person or
device identifiers, or individual navigation timelines.

`action_panel_cta_clicked` is shown as its own contextual counter. If the same
interaction also emits a canonical destination event, only the canonical event
contributes to key-action and source-open KPIs. This prevents one interaction
from inflating headline conversion measures.

## App Store Connect setup

The scheduled workflow `.github/workflows/app-store-analytics-sync.yml` reads
Apple Summary Sales reports and writes only aggregates to Supabase. Add these
GitHub Actions secrets:

1. `APP_STORE_CONNECT_ISSUER_ID`
2. `APP_STORE_CONNECT_KEY_ID`
3. `APP_STORE_CONNECT_PRIVATE_KEY`
4. `APP_STORE_CONNECT_VENDOR_NUMBER`
5. `SUPABASE_URL`
6. `SUPABASE_SERVICE_ROLE_KEY`

The Apple API key must be a Team key with the minimum suitable reporting role.
Never expose it to the website, iOS app, Admin browser bundle or Workspace app.
The fixed Apple application ID is `6782617312`.

The workflow runs daily at 18:20 UTC and can also be started manually. Missing
secrets produce an explicit "not configured" workflow summary and do not create
fake zero values. A successful report with no matching units records an `empty`
source state: this means no confirmed downloads, not an outage.

Apple references:

- [Downloading Analytics Reports](https://developer.apple.com/documentation/AppStoreConnectAPI/downloading-analytics-reports)
- [Download Sales and Trends reports](https://developer.apple.com/documentation/appstoreconnectapi/get-v1-salesreports)
- [Product type identifiers](https://developer.apple.com/help/app-store-connect/reference/reporting/product-type-identifiers)

## Operational checks

Run before release:

```bash
cd admin-dashboard
pnpm test
pnpm typecheck
pnpm lint
pnpm build

cd public-site
pnpm test
pnpm typecheck
pnpm lint
pnpm build:sites
```

After the migration is applied, verify:

- RLS is enabled for `app_store_metrics_daily` and
  `analytics_source_sync_state`;
- `anon` cannot read any protected analytics table or view;
- approved Admin can read all 7/30/90-day views;
- Web, iOS and explicit Web+iOS scopes return their own exact period totals;
- daily session totals are not used as the period-session headline;
- the complete-week comparison excludes the current partial UTC day;
- Action Panel context does not increase canonical key-action/source-open KPIs;
- event totals reconcile through the top twelve events plus `Other`;
- freshness never falls through to a different platform;
- the dashboard labels absent App Store data as unconfigured or unconfirmed,
  never as zero downloads;
- the public App Store button emits `app_cta_click` only after analytics consent;
- `app_cta_click` and first-time downloads remain separate dashboard measures.

## Current known measurement boundaries

- Web analytics excludes people who decline optional analytics.
- Web `active_instances` are not unique people.
- iOS product telemetry is intentionally labelled as not connected until a
  consent-gated ingest route passes privacy/security validation. The Admin must
  show no data in iOS scope; it must not substitute Web totals.
- App Store downloads remain unconfirmed until the private reporting workflow
  is configured and completes successfully.
- Product error events are not a substitute for Sentry, MetricKit or another
  dedicated crash source.
