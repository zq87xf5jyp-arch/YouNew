# Final app media-rights gate

Evidence cutoff: 2026-07-22 (Europe/Amsterdam)

Verdict: **PASS — `YouNew/Assets.xcassets` has complete records and zero unresolved assets**

This is an engineering provenance review, not legal advice.

## Verified inventory

| Family | Count | Basis |
| --- | ---: | --- |
| Netherlands and UI photography | 76 | Source, creator, license, credit, modification notice, in-app attribution |
| City flags and coats of arms | 58 | Exact Commons Public Domain originals; local SHA-1 equals Commons SHA-1 |
| Province flags and maps | 26 | Versioned project-created vectors |
| AppIcon | 1 | Versioned SVG source, deterministic generators, owner confirmation |
| Generated covers and exact aliases | 9 | C2PA/JUMBF structural metadata (signature not cryptographically validated here), byte identity, owner confirmation |
| **Total** | **170** | One governed ledger record per shipped catalog asset |

The unused `premium_netherlands_emergency_fallback` was removed. The former
ambulance, classroom, and Zuidas photos were replaced by exact copies of confirmed
generated artwork. The former Leiden credit was corrected to Zairon, CC BY-SA 4.0.

## Evidence

- `BuildWeekFix/ASSET_RIGHTS_STATUS.json`
- `BuildWeekFix/CITY_SYMBOL_RIGHTS.json`
- `BuildWeekFix/C2PA_MEDIA_EVIDENCE.json`
- `BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md`
- `YouNew/Resources/MediaAttributions.json`
- `MEDIA_ATTRIBUTION.md`
- `ASSET_CREDITS.md`

## Release enforcement

`python3 scripts/asset-rights-gate.py` inventories the catalog, recalculates every
payload SHA-1 and summary count, validates structured evidence, and fails unless
`unresolved == 0`. Product CI runs the same offline gate.

## Distribution conditions

- Preserve exact third-party credit lines and modification notices in app and
  release materials.
- Do not imply municipality endorsement through city symbols.
- Do not describe third-party media as covered by the repository's source-code
  license.
- Review screenshots, video, audio, and public-site media separately; they are not
  part of this catalog-only PASS.
