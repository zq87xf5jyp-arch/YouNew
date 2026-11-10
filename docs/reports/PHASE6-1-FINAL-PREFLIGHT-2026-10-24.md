# YouNew Phase 6.1 — Final local preflight

Date: 24 October 2026. Local result: **PASS**. Production status: **NO-GO pending owner-authorized live gates**.

## Gate result

| Gate | Result and evidence |
|---|---|
| Content review | **PASS** — 456/456 sitemap URLs pass, 0 review, 0 fail, 0 exact-duplicate groups |
| Seven former warnings | Closed without status inflation: six legacy detail records are `unverified`, `noindex`, absent from sitemap/listings; the remaining governed guide is confirmed and indexable |
| Public package | **PASS** — 498 generated routes, 493 HTML files, 456 sitemap URLs |
| Public unit/schema/search | **PASS** — 201/201 tests; 2608/2608 search checks |
| Links/assets/404 | **PASS** — 37,829 internal references checked; 0 broken; real HTTP 404 verified |
| SEO | **PASS** — canonical, hreflang, robots, sitemap and language post-processing checks pass |
| Package/security | **PASS** — both production dependency audits report no known vulnerabilities; secret/CSP/header scan passes |
| Admin unit/build | **PASS** — 162/162 tests, lint, typecheck and production build |
| Browser/mobile QA | **PASS** — Owner 20 pass/2 role-inapplicable skips on each desktop/mobile matrix; Editor 16 pass/6 skips; QA 16 pass/6 skips; Viewer 16 pass/6 skips; closed-auth profile 2/2 pass; final EN/NL local visual review completed |
| Registration forms | **PASS locally** — validation, honeypot, consent, receipt-gated analytics and stored-receipt contracts pass; unchanged Phase 4 real local Edge NL/EN persistence evidence remains valid |
| Supabase manifest | **PASS** — 34 applied production versions, 18 reviewed pending versions and 6 historical bootstrap files match the manifest |
| Disposable migration/restore | **PASS on current unchanged chain using 23 October definitive evidence** — 15 files/404 pgTAP assertions, DB lint clean, NL/EN HTTP 201 with exact persistence and cleanup, isolated restore rehearsal pass. Docker was unavailable on 24 October, so these database operations were not repeated and no production database was contacted |
| Release freeze | **PASS after this report** — exact archive SHA-256 is recorded in the immutable release manifest |

## Content disposition

- Public release payload: 7 governed records.
- Confirmed and indexable public cards: **1**.
- Legacy cards: **6**, direct-route only, `unverified`, `noindex,follow`, excluded from sitemap and public directory/category listings.
- Freshness exclusions: **170** unchanged.
- `amsterdam-v0.1.9`: **10/10 railway stations** reverified at field level against exact NS routes and OpenStreetMap objects; QA only, not accepted, not in the public runtime.
- Six legacy cards were source-rechecked but remain explicitly not confirmed.

The current public pages are independently useful as orientation and official-source routes, but the Amsterdam business/place catalogue is not yet diverse: one confirmed public card is insufficient for a representative local directory, and ten railway stations would not solve that limitation by themselves.

## Fixes made in Phase 6.1

1. Added source-bound, fail-closed governance for all six legacy records without human or independent-review credit.
2. Removed unconfirmed records from sitemap, public listings, category/province counts and homepage catalogue claims while preserving direct URLs and avoiding broken links.
3. Rechecked all ten Amsterdam station candidate records and bound the receipt to overlay SHA-256 `ef56dc29c01ba4962b5d29b3540254bad0549bb0315b458e6275667b047416c5`.
4. Disabled Admin candidate preparation when its required sources are unread.
5. Corrected the homepage Den Haag municipality route to the canonical `/municipalities/s-gravenhage/`.
6. Updated isolated browser assertions to the current fail-closed Admin UI and completed role/mobile coverage.

## Production-only gate sequence

1. Owner authorizes the exact release archive SHA-256.
2. Take an encrypted production PostgreSQL backup.
3. Take and reconcile a separate encrypted Storage payload backup.
4. Restore both backups into an isolated target and verify identity, schema, object counts and checksums.
5. Run exact-candidate staging smoke plus marked NL/EN submissions through the Edge endpoint; verify persistence and delete only those synthetic rows.
6. Deploy only the authorized archive; do not infer permission for DB migrations, DNS, QA catalogue publication or outreach.
7. Run post-deploy route, form, analytics, sitemap/robots and error smoke.
8. Roll back to the previously recorded artifact if any mandatory check fails.

No production database, Storage, DNS, deployment, Search Console property or commercial contact was changed.
