# Asset-rights release gate

- Status: **implemented and enabled in Product CI**
- Scope: `YouNew/Assets.xcassets`
- Validator: `scripts/asset-rights-gate.py`
- Ledger: `BuildWeekFix/ASSET_RIGHTS_STATUS.json`

This is an engineering provenance control, not legal advice. The validator does
not infer ownership from repository presence and does not trust the summary
stored in the ledger. It inventories the catalog and recomputes the result.

## Baseline

The 22 July 2026 baseline contains 171 catalog assets and 68 unresolved rights
records:

- 53 city flags/coats of arms with conflicting or incomplete provenance;
- 14 UI/background assets without reconciled file-level provenance;
- AppIcon, which has a source and generator but lacks owner attestation.

This baseline must fail the release gate. A green build, Data Health result, or
successful Xcode archive does not resolve these rights records.

## Approved remediation target

The intended final catalog contains 170 assets:

- 72 attributed Netherlands photographs;
- 26 documented project-owned province flags and map vectors;
- 58 byte-exact public-domain city symbols; 54 catalog payloads were refreshed
  from their reconciled Commons revisions and four already matched the current
  official bytes;
- AppIcon with owner provenance evidence;
- six owner-approved/generated `premium_home_*` PNGs;
- four byte-exact UI aliases derived from already cleared assets;
- three freshly retrieved Commons UI photographs with complete attribution.

All 58 city-symbol payloads are reconciled against exact Commons revisions. The
unused
`premium_netherlands_emergency_fallback` imageset and its unused code constant
are removed instead of claiming weak provenance.

The count `170` is a remediation expectation, not a hardcoded bypass. The gate
always derives the actual count from `Contents.json` files and requires a
one-to-one ledger record for every `.imageset` and `.appiconset`.

## Deterministic checks

Run:

```sh
python3 scripts/asset-rights-gate.py
```

The command verifies:

1. Every asset manifest is valid and every referenced payload exists.
2. No unreferenced payload is hidden in an asset directory.
3. Ledger IDs and asset-catalog IDs match exactly, with no duplicates.
4. `localDirectory`, payload path, and SHA-1 match the current bytes.
5. Bucket and status combinations use the governed status model.
6. Repository evidence paths exist.
7. Project-owned app/UI records include an explicit ownership basis and its
   required evidence.
8. Byte-exact public-domain records include source and Commons hash evidence.
9. Third-party records include source, creator, license, credit line,
   attribution decision, and modification notice.
10. Every summary count is recomputed from the records.
11. The process exits successfully only when `unresolved == 0`.

SHA-1 is used only as the byte identity represented by Wikimedia Commons
revision metadata. It is not used for security or signature verification.

## Ledger update rules

Do not copy hashes from a plan or invent them before the final files exist. For
each remediated file, compute the hash from the exact catalog payload after the
replacement is complete.

Third-party or derivative records require:

- exact source page URL;
- creator/rightsholder;
- exact license name and HTTPS license URL;
- attribution-required boolean;
- complete credit line naming creator and license;
- modification notice covering crop, resize, conversion, or aliasing;
- repository evidence references;
- exact local payload path and SHA-1.

The four approved byte-exact aliases are fixed policy, not arbitrary ledger
claims:

| Alias | Required source |
|---|---|
| `app_amsterdam_evening_background` | `nl_amsterdam_hero_01` |
| `home_emergency_ambulance` | `premium_home_emergency` |
| `home_language_classroom` | `premium_home_language` |
| `home_work_zuidas` | `premium_home_work` |

Each alias requires:

- `derivedFromAssetID`, pointing to a resolved record in the same ledger;
- `derivationKind: "exact_copy"`;
- source, creator, license URL, license name, and attribution decision identical
  to the referenced source record;
- a payload SHA-1 present in the referenced source record.

The freshly retrieved `home_documents_city_hall`,
`home_healthcare_pharmacy`, and `home_leiden_canals` records are direct
third-party records. They require their own Commons source, creator, license,
credit line, modification notice, and evidence; they must not claim a false
derivation.

Project-owned records require:

- creator;
- `licenseName: "Project-owned"`;
- `attributionRequired: false`;
- source/generator or owner-attestation evidence in the repository;
- exact local payload path and SHA-1;
- no invented external source or license URL.

Every project-owned record additionally requires one of these explicit
`ownershipBasis` values:

- `owner_attestation`: evidence must include
  `BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md`;
- `generated_for_project`: evidence must include both the owner attestation and
  `BuildWeekFix/C2PA_MEDIA_EVIDENCE.json`;
- `repository_original`: limited to the 14 project maps and 12 simplified
  province-flag vectors; path, SHA-1, family, creator, and evidence must match
  `BuildWeekFix/PROJECT_OWNED_ASSET_EVIDENCE.json`.

These checks apply to the project-owned aliases as well as their source assets.

The owner attestation is not satisfied by an unsigned template. Its
machine-readable header must contain:

```text
Attestation status: CONFIRMED
Attested by: <named repository owner>
Attested on: YYYY-MM-DD
```

It must also name every directly covered asset and include the current SHA-1 of
every covered payload. An exact-copy alias may inherit the attested source asset
name, but its payload hash must still match the attested hash.

`C2PA_MEDIA_EVIDENCE.json` uses `schemaVersion: 1`, explicitly declares
`validationLevel: structural_markers_and_metadata_only` and
`signatureValidated: false`, and contains a `records` array. Each record has
`assetID`, repository-relative `path`, `sha1`, `generator`, `provider`,
`xmpInstanceID`, and `createdAt`. The gate recomputes the file hash, validates
the PNG chunk boundaries and CRCs, requires a single `caBX` chunk, parses its
JUMBF box tree, binds the evidence asset ID to the covered source asset, and
then checks the claimed embedded metadata inside that container. Appended text
or a JSON assertion alone therefore cannot clear a different file. This is
intentionally not a cryptographic C2PA signature-chain verification;
distribution clearance comes from the explicit owner confirmation.

All 76 third-party catalog records are cross-checked by asset ID against the
in-app `YouNew/Resources/MediaAttributions.json` registry. The gate requires a
Wikimedia Commons File source, an allowed Creative Commons/Public Domain license
combination, correct attribution semantics, exact creator/license/credit fields,
one of the five categories rendered by `MediaCreditsView`, category-to-asset-ID
consistency, and exact coverage of the 72 Netherlands photographs plus four UI
aliases/assets. City-symbol evidence separately requires a Wikimedia Commons
File page, `Public domain`, and the canonical Creative Commons Public Domain
Mark URL.

Status/family combinations are fail-closed for this catalog: only governed
`city_symbol` records may use `public_domain_byte_exact`, and every
`third_party_attribution_ready` record must belong to the exact attribution
registry cohort. A new asset therefore cannot self-declare a cleared status with
an arbitrary evidence file.

## GitHub Actions enforcement

Product CI runs all three commands through `scripts/run-static-qa.sh`:

```sh
python3 scripts/generate-asset-rights-ledger.py --check
python3 scripts/asset-rights-gate.py
python3 -m unittest scripts/tests/test_asset_rights_gate.py
python3 -m unittest scripts/tests/test_generate_asset_rights_ledger.py
```

The workflow triggers on changes to the asset catalog, ledger/evidence folder,
attribution inventory, AppIcon sources, validator, generator, and tests. The
ledger and every evidence file it references must therefore remain in the same
reviewed commit as the corresponding payload changes.
