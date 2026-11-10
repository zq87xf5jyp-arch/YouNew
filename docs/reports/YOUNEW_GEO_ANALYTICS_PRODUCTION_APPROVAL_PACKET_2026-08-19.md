# YouNew geo analytics production approval packet — 2026-08-19

Owner: Ivan Chernikov  
Scope: decision packet only  
Production migration, production deployment, merge and external operations:
**not authorized and not performed**

## Decision

**NO-GO for production.**

The disposable database and application regression gates are green, but this
packet does not request or imply deployment approval. The open production gates
are:

1. no fresh encrypted backup and verified disposable restore of the current
   production schema and operational data exists under this validation scope;
2. no independent GitHub Actions run, draft PR or immutable candidate commit
   exists for the final geo changes;
3. consent assurance, Origin spoofing, rotatable abuse identity and canonical
   identifier decisions remain open;
4. the owner must explicitly accept the shared technical event envelope or
   require a narrower geo-specific storage model;
5. the prior release packet's HIGH dependency advisories have not been shown as
   remediated in this scope.

Primary local evidence:
[geo migration validation report](YOUNEW_GEO_ANALYTICS_MIGRATION_VALIDATION_2026-08-19.md).

## 1. Local gate summary

| Gate | Result |
| --- | ---: |
| Core pgTAP | **81/81 PASS** |
| Retention/aggregation pgTAP | **67/67 PASS** |
| Geo pgTAP | **43/43 PASS** |
| Targeted pgTAP | **191/191 PASS** |
| Every checked-in SQL suite | **203/203 PASS** |
| Schema lint | **PASS** |
| Public TypeScript / ESLint / tests / build | **PASS / PASS / 178/178 / PASS** |
| Admin TypeScript / ESLint / tests / build | **PASS / PASS / 72/72 / PASS** |
| Disposable rollback | **PASS; exact normalized schema hash match** |
| Two clean rebuilds | **PASS** |
| Public service-role/secret exposure scan | **PASS** |
| Independent CI | **NOT RUN** |
| Production backup/restore drill | **NOT RUN in this scope** |
| Production apply/deploy | **NOT AUTHORIZED** |

There are no CI run URLs or remote artifact URLs to provide. Local evidence is
under
`admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/`.

## 2. Exact pending migration order

| Order | Version | Name | MD5 |
| ---: | --- | --- | --- |
| 1 | `20260818145801` | `harden_analytics_ingest_windows_rls` | `e702afeef312705d2a5bc5a8858da0c4` |
| 2 | `20260818191112` | `harden_business_inquiry_pipeline` | `716b6222ca3010e4f385082414169440` |
| 3 | `20260818192423` | `deduplicate_business_inquiry_submissions` | `d3010eb22035a572d0b36a8c522e68a0` |
| 4 | `20260818193310` | `extend_lead_analytics_funnel` | `220bfa6bddd463acb67a86b31bbea285` |
| 5 | `20260818194626` | `add_business_inquiry_notification_inbox` | `e9df9c0cbd8828bbe6cfa26f57c5a295` |
| 6 | `20260818235619` | `enforce_monetization_retention_and_private_reports` | `8f7e418080a080e3204106f344836ee0` |
| 7 | `20260819080242` | `allow_geo_relevance_analytics` | `113043c51e207e6d0d7c7ae6da4b5df2` |

The six `0001`–`0006` bootstrap files and the three disposable compatibility
fixtures are not production-forward migrations.

## 3. Required closure before a production approval decision

### Backup and restore

1. Create a dated encrypted logical backup or confirm a restorable PITR point
   for the current production database.
2. Export the live migration manifest separately.
3. Restore the backup into a new disposable target, never into production.
4. Compare table/function/index counts, migration versions, RLS states, grants
   and agreed non-PII operational counts.
5. Record backup duration, restore duration, archive checksum, rollback point
   and the named rollback executor.
6. Resolve every mismatch before considering migration approval.

The previous monetization packet contains a synthetic restore mechanics drill
and a read-only inventory, but not the current-production backup/restore proof
required for this new seven-migration candidate.

### Independent candidate evidence

1. Put only the reviewed final delta on a feature branch.
2. Create a draft PR; do not merge.
3. Run disposable Supabase CI, all 203 SQL assertions, schema lint, Public and
   Admin checks, secret scan and dependency audit.
4. Exercise the final Edge Function through a disposable HTTP runtime, including
   missing/spoofed Origin, absent `Content-Length`, oversized chunked body,
   invalid key, invalid consent contract and storage-failure cases.
5. Retain redacted artifacts. Raw Supabase start output must not be uploaded
   because it can contain generated local credentials.
6. Record candidate commit SHA, PR URL, Actions URLs and artifact checksums.

### Privacy decisions

The owner/privacy reviewer must record one decision for each item:

- whether client-side consent plus a versioned server contract is sufficient,
  or a trusted server-side consent receipt is required;
- whether an allowlisted but spoofable Origin plus publishable key is sufficient
  for aggregate data integrity;
- whether rate limiting needs a non-rotatable server/network signal;
- whether city/intent/content identifiers require a canonical registry;
- whether the shared anonymous technical envelope is accepted under the geo
  allowlist or a dedicated narrower table is required;
- how to handle an analytics POST already in flight when consent is withdrawn.

Do not describe legal completeness as approved without owner or specialist
review.

## 4. Future production procedure — not authorized now

After every blocker above is closed and a new explicit owner approval is
recorded:

1. Freeze the exact candidate commit and verify a clean worktree or documented
   candidate-only diff.
2. Re-run the manifest verifier and compare all seven file hashes with this
   packet.
3. Confirm the encrypted backup/PITR rollback point and named rollback executor.
4. Run the complete independent CI gate against the exact commit.
5. Review a linked `db push --dry-run`; it must list exactly the seven ordered
   migrations above and no other file.
6. Apply the seven migrations once through the managed Supabase migration
   boundary.
7. Verify remote migration versions and hashes, RLS, grants, required indexes,
   function ownership/search paths and zero unauthorized browser access.
8. Deploy only the reviewed `analytics-ingest` Edge Function change.
9. Deploy the reviewed Public/Admin candidate only after the database and Edge
   post-checks pass.
10. Run synthetic consent, event rejection, search/guide/CTA resilience and
    aggregate-isolation smoke tests; do not use real contact data.
11. Monitor rejects, rate limiting and application errors without logging PII.
12. Record the final release SHA, migration versions, deploy timestamps and
    post-deploy evidence.

No command in this section is permission to run `supabase link`, `db push`, Edge
deployment, site deployment or merge.

## 5. Rollback trigger and procedure

Trigger rollback immediately if any of these occurs:

- a migration version/hash mismatch;
- any pgTAP, RLS, grant or unauthorized-access regression;
- accepted raw query/PII or cross-client data;
- search, guide or CTA failure caused by analytics;
- unexplained insert latency/error increase;
- incorrect consent behavior or a material aggregate-integrity incident.

For a failure isolated to migration 7 before dependent application deployment,
restore the captured prior definition/comment of
`public.ingest_analytics_batch(jsonb)` using the reviewed rollback artifact and
verify the normalized schema hash plus all legacy analytics tests. For a wider
failure involving migrations 1–6 or data mutation, stop writes and use the
pre-approved backup/PITR restore procedure. Do not improvise destructive SQL or
perform a production restore without the named owner decision.

Rollback decision owner: **Ivan Chernikov**.  
Technical executor: must be named in the final approval record.

## Final gate

| Dimension | Status |
| --- | --- |
| Local disposable validation | **GO** |
| Local app regression | **GO** |
| Privacy decision closure | **PARTIAL** |
| Backup/restore evidence | **NO-GO** |
| Independent CI evidence | **NO-GO** |
| Production | **NO-GO** |

Production deployment, production migrations, merge, payments and outreach
remain prohibited until a new explicit owner decision.
