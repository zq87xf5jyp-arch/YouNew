# YouNew v19 release readiness — 2026-07-29

Overall status: **NO-GO**

This report separates confirmed environment facts from work still requiring production authority or evidence.

## Confirmed

- Supabase project `pgdzdxsiagfjioxwuqxf` is `ACTIVE_HEALTHY` in `eu-west-1` on PostgreSQL 17.6.1.
- Eleven remote migrations are recorded, including production operations, public feed, analytics and publication-gate changes.
- Four Edge Functions are active: `analytics-ingest`, `submit-business-inquiry`, `submit-public-feedback` and `prepare-content-sync`.
- Relevant public tables have RLS enabled and explicit grants have been checked.
- Current aggregate baseline is 65 consented analytics events and 3 business inquiries.
- The v19 web candidate keeps new planner telemetry within the existing production `item_saved` event contract.
- The local v19 site builds 584 static pages with 575 indexable URLs; 83 unit/contract tests, 46,802 internal-reference checks, smoke tests and package security checks pass.
- Browser QA confirms the retention dashboard, saved planner route, 390 px mobile layout/menu, map filters and business inquiry UI without console errors or horizontal overflow.
- Data health passes with 2,560 checked source URLs and no confirmed broken links. Editorial QA confirms 20 guide scaffolds, 18 research-backed topics, 15 public summary guides and 0 production-ready practical guides.

## Remaining GO LIVE blockers

| Blocker | Required evidence |
|---|---|
| Exact production authority | Explicit `GO LIVE` instruction for this release |
| Fresh recoverable backup | Timestamped Supabase backup/export and rollback owner |
| Admin production path | `admin.younew.nl` DNS/TLS, authenticated owner/editor E2E and authorization-denial tests |
| Repository integrity | Reconcile branch divergence; separate and commit intended v19 changes without overwriting unrelated local work |
| Editorial readiness | Complete the two missing research dossiers, FAQs/steps/assets and human review; current result is 0 production-ready practical guides |
| Web production verification | Deploy from a known commit, then run canonical-domain, form, PWA, analytics and responsive E2E |
| Rollback rehearsal | Confirm previous site artifact and database rollback procedure |

## Security items requiring owner review

- Supabase reports authenticated execution exposure for two `SECURITY DEFINER` functions. Their bodies enforce the internal admin-role check, but execute privileges should still be reviewed before GO LIVE.
- Leaked-password protection is disabled on the current plan.
- Performance advisors report unused indexes and overlapping read policies. Current volume is too small to justify deleting indexes without query evidence.

## Safe release sequence

1. Finish local v19 tests and browser QA.
2. Freeze intended files and produce a reviewable commit.
3. Reconcile the branch with remote without discarding unrelated work.
4. Create and verify a fresh backup.
5. Verify admin DNS, authentication, roles and production forms.
6. Obtain exact `GO LIVE`.
7. Deploy the known commit and run authenticated and public E2E.
8. Monitor error, analytics-ingest and form-submission aggregates; roll back on predefined thresholds.
