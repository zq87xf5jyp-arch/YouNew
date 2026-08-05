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
| Session | One anonymous browser-tab or app session | Supabase `app_sessions` and distinct `app_events.session_id` | Not a unique person |
| Active instance | Random consented instance identifier | Supabase `app_events` | Web identifier lives in `sessionStorage`; not cross-session identity |
| Page/screen view | `page_view` or `screen_view` for a bounded path without query parameters | Supabase `app_events` | Does not include people who declined analytics |
| Engaged session | Session with duration of at least 10 seconds | `analytics_session_quality_periods` | Diagnostic threshold, not proof of value |
| Median duration | Median non-negative session duration | `analytics_session_quality_periods` | Preferred over the mean for long-open tabs |
| Key action | Source/result open, save, completed step, business intent, or App Store CTA | `analytics_daily_metrics` | Events can occur more than once per session |
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
- Audience breakdowns are hidden in the dashboard below three sessions per
  selected period.
- App Store tables store daily country-level aggregates only; no Apple customer
  or device identifiers are accepted.
- Raw analytics retention remains 90 days.

## Periods and reconciliation

The dashboard supports exact 7, 30 and 90-day periods. The headline session
count uses distinct `session_id` values observed in events. Session quality uses
the session table. If the counts disagree, the dashboard shows the difference
as a data-quality warning instead of selecting the more convenient value.

Average session duration is capped at 30 minutes per session for diagnostics.
Median duration is the primary duration statistic.

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
- the dashboard labels absent App Store data as unconfigured or unconfirmed,
  never as zero downloads;
- the public App Store button emits `app_cta_click` only after analytics consent;
- `app_cta_click` and first-time downloads remain separate dashboard measures.

## Current known measurement boundaries

- Web analytics excludes people who decline optional analytics.
- Web `active_instances` are not unique people.
- iOS product telemetry remains empty until the released app uploads consented
  events and the App Store privacy information matches that behavior.
- App Store downloads remain unconfirmed until the private reporting workflow
  is configured and completes successfully.
- Product error events are not a substitute for Sentry, MetricKit or another
  dedicated crash source.
