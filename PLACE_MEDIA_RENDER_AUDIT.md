# Place media render audit

Generated: 2026-07-22

This report records the current runtime coverage of
`VerifiedPlaceMediaRegistry`. Rights and byte-level provenance for the shipped
catalog are governed separately by `BuildWeekFix/ASSET_RIGHTS_STATUS.json`.

## Current result

| Check | Result |
|---|---:|
| Media schema version | 2 |
| Provinces in catalog | 12 |
| Cities in catalog | 29 |
| Registry entries | 41 |
| Places with a hero image or verified fallback | 41 |
| Places with a flag | 41 |
| Places with a coat of arms | 41 |
| Missing hero images | 0 |
| Missing flags | 0 |
| Missing coats of arms | 0 |

Runtime validation command:

```sh
python3 scripts/audit_place_media.py
```

Result: **PASS (exit code 0)**.

## Rendering contract

- Every city and province has flag and coat-of-arms metadata in
  `VerifiedPlaceMediaRegistry`.
- Local symbol names resolve to an imageset in `YouNew/Assets.xcassets`.
- Heroes use a curated local asset when one is available and a verified remote
  URL otherwise.
- Missing or unavailable remote media falls back to the app's bounded visual
  fallback; it is never represented as a locally verified file.
- Production registry URLs use trusted Wikimedia/Wikidata hosts and supported
  image extensions.

## Rights linkage

The 170 shipped catalog assets are covered by the deterministic ledger:

| Rights bucket | Assets |
|---|---:|
| Public-domain city symbols, byte-exact to Wikimedia Commons | 58 |
| Documented project-owned assets | 36 |
| Third-party assets cleared with attribution conditions | 76 |
| Unresolved | 0 |

Canonical evidence:

- `BuildWeekFix/ASSET_RIGHTS_STATUS.json`
- `BuildWeekFix/CITY_SYMBOL_RIGHTS.json`
- `BuildWeekFix/THIRD_PARTY_ASSET_EVIDENCE.json`
- `YouNew/Resources/MediaAttributions.json`
- `ASSET_CREDITS.md`

`scripts/generate-asset-rights-ledger.py --check` and
`scripts/asset-rights-gate.py` verify this linkage in Product CI. Screenshots,
recordings, audio, and public-site media are separate release inventories and
are not cleared by this app-catalog result.
