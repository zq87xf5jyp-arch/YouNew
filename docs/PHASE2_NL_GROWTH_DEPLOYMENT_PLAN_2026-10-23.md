# YouNew phase 2 — production deployment and rollback plan

Date: 2026-10-23  
Status: local implementation only; **not published**

## Release contents

- Dutch routes for the home page, categories, search, organization profiles, business pages and Add/Claim form.
- Five bilingual city guides with reviewed official municipal sources.
- English routes remain available and receive reciprocal `hreflang` links where a Dutch counterpart exists.
- Consent-based page, search and lead events use the existing analytics ingestion path.
- The Dutch Add/Claim source route is accepted by both client validation and the Supabase Edge Function source-page allowlist.

## Measurement contract

| Outcome | Existing event/view | Interpretation |
|---|---|---|
| Visits | `page_view` | Consented web page views, grouped by the sanitized `screen` path. |
| Card/profile views | `analytics_page_metrics_periods` filtered to `/organizations/`, `/nl/organisaties/`, `/places/`, `/guides/`, `/city-guides/` and `/nl/stadsgidsen/` | Derived from page views; no new identifier or content payload is collected. |
| Search use | `search`, `search_result_opened` | Privacy-safe normalized terms and bounded filters; raw search text is not sent. |
| Application starts | `lead_start` | First meaningful form interaction after analytics consent. |
| Saved applications | `lead_submit` | Emitted only after a valid server receipt is returned. It is not a unique company, contract or payment count. |

The public analytics client remains consent-gated, honours GPC/Do Not Track, stores no form fields in analytics and keeps the current EU retention policy.

## Search Console readiness

1. A verified owner must provide a Google verification token; no token is stored in the repository.
2. Set `NEXT_PUBLIC_GOOGLE_SITE_VERIFICATION` only in the approved production build environment.
3. Build and inspect the generated meta tag without printing the secret in logs.
4. After the approved release is live, submit `https://younew.nl/sitemap.xml` in Search Console.
5. Inspect the five English and five Dutch city-guide URLs, the Dutch home page, category index and organization index.
6. Monitor discovered/indexed counts, canonical selection and mobile usability. Search Console access is external owner state and cannot be validated from this local checkout.

## Form abuse protection verified in code

- hidden honeypot field;
- exact source-page allowlist;
- origin allowlist and JSON content-type enforcement;
- bounded request body and field lengths;
- server-side validation and KvK rules;
- hashed network-rate key and database-backed rate limiting;
- duplicate-submission protection and a `bot_rejected` state;
- no automatic publication after submission.

## Approval-gated deployment sequence

1. Freeze the intended commit/worktree state and record `git diff --stat` plus checksums of `dist/client` and the Edge Function bundle.
2. Archive the currently deployed static artifact and current `submit-business-inquiry` function source as the rollback package.
3. Re-run structure checks, data QA, unit tests, typecheck, lint, production build, smoke test, link check, IA audit and security check.
4. Deploy the updated `submit-business-inquiry` Edge Function first or in the same maintenance window; the NL form must not go live before its source route is accepted server-side.
5. Upload the static artifact to a versioned release directory. Do not overwrite the previous artifact in place.
6. Switch the web root atomically to the new release only after approval.
7. Smoke-test `/`, `/nl/`, `/nl/zoeken/`, one Dutch category, one Dutch organization, all five Dutch city guides, the Dutch Add/Claim form validation, `robots.txt` and `sitemap.xml`.
8. Verify that consented `page_view`, `search`, `lead_start` and a controlled test `lead_submit` arrive in the admin views. Delete or clearly label the controlled test inquiry according to the existing operations policy.
9. Add the Search Console token and submit the sitemap only with the verified owner's approval.

## Rollback

Rollback triggers include: NL routes returning 404, wrong canonical/hreflang, form receipts failing, material mobile regressions, analytics ingestion errors, or security checks failing.

1. Point the web root back to the archived previous static artifact.
2. Restore the previous Edge Function bundle if the failure is in inquiry handling.
3. Purge only the affected release cache keys; do not delete the archived artifact.
4. Re-run English home/search/form smoke checks and verify the previous release checksum.
5. Record the incident and keep submitted inquiries intact. No database migration is introduced by this phase, so database rollback is not required.

## Remaining external prerequisites

- explicit production approval;
- verified Search Console owner/token;
- access to the production hosting release switch and Supabase function deployment;
- one consented end-to-end analytics test in production;
- manual visual acceptance on physical iOS and Android devices if available.
