# Phase 3 production launch checklist

Status: **not approved for production deployment**. This checklist does not grant deployment authority.

## Release candidate

- [ ] Freeze the exact commit/SHA and record the dirty-worktree diff separately.
- [ ] Re-run structure checks, public/admin unit tests, typecheck, lint, builds, link/IA/security checks and mobile visual review.
- [ ] Verify the Supabase migration manifest and exact pending-file hashes.
- [ ] Rebuild the complete disposable Supabase chain with the required synthetic fixtures; all pgTAP suites must pass.
- [ ] Apply the local-business route migration in disposable staging and obtain a stored receipt plus read-back.
- [ ] Confirm no real production data, credentials or personal contacts appear in test artifacts.

## Content and SEO

- [ ] Recheck all five municipal city-guide sources on release day.
- [ ] Confirm the site never presents the 410 pending records as current.
- [ ] Confirm EN/NL self-canonical URLs and reciprocal hreflang, including `x-default`.
- [ ] Confirm `robots.txt` and `sitemap.xml` return 200 and only canonical indexable URLs are in the sitemap.
- [ ] Check image load, dimensions, alt text, source/license metadata and mobile crop for home, five guides and organization profiles.
- [ ] Resolve all broken internal links, duplicate titles, accidental noindex and 404 targets.

## Forms, privacy and security

- [ ] Submit synthetic EN and NL local-business applications to staging and read them back in Admin.
- [ ] Verify confirmation format, one notification per new inquiry and duplicate suppression.
- [ ] Verify honeypot, origin allowlist, JSON-only request, actual 32 KiB body limit, five-per-hour rate limit and generic error responses.
- [ ] Verify consent and accuracy checkboxes are required server-side and in the database.
- [ ] Verify analytics remains opt-in, honors GPC/DNT, uses tab-scoped random identifiers, sends no form data/search text/referrer and retains raw events for at most 90 days.
- [ ] Confirm the optional Business/Premium signal is explicitly non-binding and unavailable.

## Backup, staging and rollback

- [ ] Create a timestamped logical database backup and record checksum, encryption/location and restore owner.
- [ ] Complete a restore rehearsal into a disposable database; query critical counts and functions.
- [ ] Export the current production deployment artifact/configuration and DNS/CDN settings without secrets.
- [ ] Deploy the exact release candidate to staging; never point staging forms at production.
- [ ] Record pre-deploy health checks, migration versions and current production artifact ID.
- [ ] Rollback trigger: form save failure, 5xx increase, broken canonical/hreflang, missing critical pages, privacy regression or corrupted content.
- [ ] Rollback order: stop traffic to new artifact; restore previous web artifact; roll back only explicitly reversible DB changes or roll forward with a reviewed fix; verify read paths and form receipts.

## Approval gate

- [ ] Owner provides explicit production approval after reviewing the evidence pack.
- [ ] Deployment operator, timestamp, monitoring owner and rollback operator are named.
- [ ] Search Console submission and any external outreach remain separate post-deploy approvals.

