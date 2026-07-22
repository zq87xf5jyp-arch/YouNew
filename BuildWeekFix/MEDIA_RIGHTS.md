# Media-rights readiness

Date: 2026-07-22 (Europe/Amsterdam)

Verdict: **PASS FOR THE SHIPPED ASSET CATALOG**

This is an engineering provenance inventory, not legal advice. The repository
license does not replace the individual third-party licenses recorded below.

## Final catalog inventory

The shipped Xcode catalog contains 170 assets with one ledger record per asset:

- 58 city flags/coats of arms replaced with exact current Wikimedia Commons
  originals whose source pages mark them public domain;
- 72 Netherlands-pack photographs with complete source/license records;
- four additional attributed UI photographs;
- 26 project-owned province/map vectors;
- AppIcon with versioned source, deterministic generators, and owner confirmation;
- six OpenAI-generated `premium_home_*` PNGs with byte-linked C2PA/JUMBF
  structural metadata and owner confirmation (the offline gate does not claim
  cryptographic signature validation);
- three compatibility image IDs that are exact byte aliases of those confirmed
  generated assets.

The unused `premium_netherlands_emergency_fallback` imageset was removed instead
of assigning it unsupported provenance.

Machine-readable evidence:

- `BuildWeekFix/ASSET_RIGHTS_STATUS.json`
- `BuildWeekFix/CITY_SYMBOL_RIGHTS.json`
- `BuildWeekFix/C2PA_MEDIA_EVIDENCE.json`
- `BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md`
- `YouNew/Resources/MediaAttributions.json`

## Remediation completed

- `governed_broken_links` remains a separate Data Health concern and is already
  zero in the successful workflow; it does not stand in for this catalog audit.
- The 53 previously conflicting city-symbol payloads were replaced byte-for-byte
  with their reconciled Commons revisions. All 58 shipped city symbols now have a
  local SHA-1 equal to the recorded Commons SHA-1.
- `app_amsterdam_evening_background` is now an exact alias of the attributed
  `nl_amsterdam_hero_01` photograph.
- `home_documents_city_hall`, `home_healthcare_pharmacy`, and
  `home_leiden_canals` were reconciled to exact Commons sources. Leiden metadata
  was corrected to Zairon, CC BY-SA 4.0.
- The unverified ambulance, classroom, and Zuidas photographs were replaced by
  exact copies of owner-confirmed generated YouNew artwork.
- App-accessible credits now contain 76 records: the original 72-photo pack plus
  four additional third-party UI images.

## Release conditions that remain

- Preserve the in-app credit screen and license links for the 69 records that
  require attribution.
- Keep modification notices with screenshots, videos, and other redistributed
  derivatives when the applicable CC license requires them.
- City symbols are shown only for informational identification. Public-domain
  copyright status does not imply municipality endorsement and does not override
  any independent rules governing official symbols.
- Screenshots, recordings, public-site media, and audio are separate inventories;
  this PASS applies only to `YouNew/Assets.xcassets`.

## Validation

Run:

```sh
python3 scripts/asset-rights-gate.py
```

The release condition is `unresolved = 0`, complete catalog/ledger coverage, and
exit code 0. The same command is enforced by Product CI.
