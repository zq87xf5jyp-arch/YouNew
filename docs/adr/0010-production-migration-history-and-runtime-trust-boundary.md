# ADR-010 — Production migration history and runtime trust boundary

- Status: proposed
- Date: 2026-08-01
- Draft author: Codex drafting agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: DataProject release manifests; governed runtime checksum and publication gates; production migration manifest
- Related migrations: admin-dashboard/supabase/migrations/20260728152529_deny_direct_business_inquiry_rate_limit_access.sql through admin-dashboard/supabase/migrations/20260728200449_harden_content_image_listing_and_fk_indexes.sql

## Problem and context

The checked-in timestamped migration files had drifted from the immutable SQL
already recorded in the production migration history. At the same time, iOS
treated the canonical governed runtime as if it were unaudited legacy data and
reapplied a legacy five-image completeness rule after publication. The first
problem makes a future database deployment ambiguous; the second can hide
records that already passed governance, publication, provenance and checksum
verification.

## Considered options

1. Keep the locally rewritten migration files and rely only on matching version
   numbers, while continuing to apply one completeness filter to every runtime
   source.
2. Restore every managed migration byte-for-byte from production evidence,
   verify the immutable set with a committed manifest, and distinguish
   canonical governed records from legacy records at the runtime boundary.
3. Squash the production migration history into a new baseline and remove the
   legacy completeness guard globally.

## Decision

Propose option 2. Managed timestamped migrations are immutable evidence: local
bytes, sizes and digests must match the production manifest before any database
command runs. Historical bootstrap files remain documented separately and must
not be presented as pending managed migrations.

Canonical runtime records are admitted only after the release, publication,
governance, provenance and checksum gates pass. They are not rejected again by
the legacy five-image rule. Legacy records keep the strict completeness filter,
and event records remain subject to their time window. Unknown, unpublished or
checksum-invalid records continue to fail closed.

## Consequences and risks

Deployment becomes reproducible and migration drift becomes a hard failure
instead of an implicit overwrite. Published canonical content remains
available without weakening the legacy-data boundary. The manifest must be
updated only when production records a genuinely new reviewed migration.
Restoring historical migration bytes does not execute SQL and does not alter
the live database.

The runtime distinction depends on preserving release provenance. A future
importer that drops source classification could either hide valid canonical
records or weaken legacy validation, so parity and fail-closed tests remain
mandatory.

## Verification

Run `scripts/verify-supabase-migration-manifest.py` and require 13 managed
versions plus six separately classified bootstrap files. Compare the linked
production migration list before and after deployment and stop on any pending
or mismatched version. Run the complete static QA suite.

For iOS, run the full unit suite and the targeted Universal Link tests, then
open one published guide, place and organization on a runtime device or
simulator. Verify unknown and unpublished slugs remain rejected, legacy
incomplete records remain hidden, expired events remain excluded and canonical
published records resolve to their exact native destination.
