# Media-rights readiness

Date: 2026-07-20 (Europe/Amsterdam)

Verdict: **PARTIAL / BLOCKED FOR BLANKET PUBLIC REDISTRIBUTION**

## Evidence found

- A local manifest records 72 exact `nl_*` assets, their source pages, creator text,
  license names, and all but one license URL.
- 65 entries require attribution and seven are marked as not requiring it.
- The 72 IDs are referenced by `LocalNetherlandsImagePackRegistry`.
- `MEDIA_ATTRIBUTION.md` carries a repository-visible, manifest-derived inventory.
- The asset catalog contains 170 imagesets total: 72 manifest-backed `nl_*` items
  and 98 non-manifest imagesets. The latter count is now explicit rather than being
  treated as implicitly cleared.

## Blockers

1. `nl_hoorn_card_01` is marked “Public domain” but its manifest `license_url` is
   empty. The legal basis must be confirmed from the source before release.
2. Ninety-eight non-`nl_*` imagesets and `AppIcon.appiconset` are outside the
   reviewed 72-entry manifest. They comprise 58 city flag/coat-of-arms assets, 12
   province flags, 14 map assets, three legacy home photos, and eleven high-use
   background/category/fallback assets. `ASSET_CREDITS.md` calls some vectors
   project-created while `PLACE_MEDIA_RENDER_AUDIT.md` associates many identity
   assets with Wikimedia sources; the conflicting provenance must be reconciled
   file by file.
3. The eleven high-use non-manifest imagesets include
   `app_amsterdam_evening_background`, `home_emergency_ambulance`,
   `home_language_classroom`, `home_work_zuidas`, `premium_home_documents`,
   `premium_home_emergency`, `premium_home_healthcare`, `premium_home_housing`,
   `premium_home_language`, `premium_home_work`, and
   `premium_netherlands_emergency_fallback`. The three legacy home photos are
   `home_documents_city_hall`, `home_healthcare_pharmacy`, and
   `home_leiden_canals`.
4. A manifest does not prove that attribution is visible where required, that
   modifications are identified, that share-alike obligations are met, or that
   screenshots/video/social distribution is permitted under every source term.
5. OCR/EXIF and reverse-image review were not completed. No owner-signed provenance
   statement or contributor/commission agreement was found.

## Safe remediation

- Verify every source page and license at the final source cutoff; preserve a dated
  record without copying private account data.
- Add visible/app-accessible attribution appropriate to each use and identify
  modifications such as crop, resize, and format conversion where required.
- Obtain owner-created/source evidence for unresolved files, or replace them with
  newly commissioned/generated assets whose terms permit the intended distribution.
- If a blocker cannot be cleared, exclude that media from the public commit and demo
  capture while retaining the corresponding feature with a rights-cleared fallback.
- Have the owner or qualified counsel approve the final package. Do not convert an
  unknown provenance into a guessed license.

## Safe public claim

“YouNew includes a documented 72-asset manifest-backed image inventory. The catalog
also contains 98 imagesets outside that manifest; media rights are partially
verified and unresolved assets remain excluded from a blanket redistribution
claim.”

This report is an engineering inventory, not legal advice.
