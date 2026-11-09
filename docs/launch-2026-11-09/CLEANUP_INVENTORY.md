# Pre-cleanup inventory - 2026-11-09

Read-only metadata inspection. Deleted: 0. Quarantined: 0. Cleanup remains deferred until verified production and rollback, as requested by the owner.

21 local YouNew directories; 45 nested Git repositories. Sizes exclude node_modules, .git, .next, DerivedData, out/dist and other generated directories; they are not estimates of reclaimable space.

| Directory | Files excluding generated directories | MiB | Current disposition |
| --- | ---: | ---: | --- |
| `YouNew` | 2571 | 309.0 | Preserve |
| `YouNew-Catalog-2026-11-03` | 2718 | 316.3 | Preserve |
| `YouNew-Catalog-R2-2026-11-03` | 2812 | 317.5 | Preserve |
| `YouNew-Content-2026-11-09` | 2926 | 258.3 | Preserve |
| `YouNew-Cron-Review-2026-11-03` | 38 | 0.1 | Preserve |
| `YouNew-Cron-Test-2026-11-03` | 6065 | 761.1 | Preserve |
| `YouNew-Hostinger-Architecture-2026-11-03` | 24 | 0.6 | Preserve |
| `YouNew-Hostinger-Preparation-2026-11-03` | 2847 | 358.0 | Preserve |
| `YouNew-Hostinger-QA-2026-11-03` | 42 | 28.2 | Preserve |
| `YouNew-Hostinger-R3-2026-11-03` | 14442 | 2785.5 | Preserve |
| `YouNew-Hostinger-R4-2026-11-03` | 3022 | 1000.7 | Preserve |
| `YouNew-Hostinger-R4B-2026-11-03` | 3559 | 484.6 | Preserve |
| `YouNew-Integration-2026-11-03` | 3605 | 1155.7 | Preserve |
| `YouNew-Launch-Evidence-2026-11-09` | 90 | 9.0 | Preserve |
| `YouNew-Leiden-2026-11-09` | 2518 | 170.8 | Preserve |
| `YouNew-Local-2026-09-18` | 68017 | 4751.4 | Preserve |
| `YouNew-Monitoring-2026-11-04` | 1 | 0.0 | Preserve |
| `YouNew-R4B-Hostinger-Review-2026-11-03` | 1029 | 170.8 | Preserve |
| `YouNew-R4B-Verify-2026-11-03` | 546 | 153.3 | Preserve |
| `YouNew-R4B-Verify2-2026-11-03` | 549 | 153.3 | Preserve |
| `YouNew-Release-2026-11-02` | 8603 | 1299.1 | Preserve |

Canonical project: `/Users/ivan/YouNew`. Private evidence: `/Users/ivan/YouNew-Launch-Evidence-2026-11-09`. The detailed local inventory is mode 0600 and is not uploaded to GitHub.

No directory is approved for removal by this inventory. Untracked files, databases, uploads, configuration, unique commits and dependencies still need per-object reconciliation. The import manifest retains 104 paths in the original local source that were not imported automatically. Names such as old/temp/backup are not removal evidence.

Production, previous release, eight SQLite databases, backups, legacy Supabase Admin and QA resources are preserved. Real Supabase database and Storage exports have now been obtained without activation and preserved locally and on Hostinger; see SUPABASE_PRESERVATION_EVIDENCE.json.
