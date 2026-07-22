# Media rights and attribution

Status: **app asset catalog cleared by deterministic rights gate**

Last reviewed: 2026-07-22

The release catalog contains no unresolved provenance records. The canonical
machine-readable ledger is
[`BuildWeekFix/ASSET_RIGHTS_STATUS.json`](../BuildWeekFix/ASSET_RIGHTS_STATUS.json),
validated by `scripts/asset-rights-gate.py` in Product CI.

## Submission media basis

- 76 third-party photography records include creator, source page, license link,
  attribution decision, and modification notice. They are visible inside the app
  through **More → About YouNew → Media and licenses**.
- All 58 city flags/coats of arms are exact current Wikimedia Commons revisions
  marked public domain on their recorded pages; local and Commons SHA-1 values
  match.
- AppIcon has a versioned source, deterministic generators, and owner confirmation.
- Six generated YouNew covers retain OpenAI C2PA/JUMBF structural metadata and
  owner approval; the offline gate does not claim cryptographic signature-chain
  validation.
- Three formerly unverified photographs were replaced with exact byte aliases of
  those confirmed generated covers.
- The unused emergency fallback imageset was removed.

## Required public credits

Use the exact credit lines from
[`YouNew/Resources/MediaAttributions.json`](../YouNew/Resources/MediaAttributions.json).
For video descriptions, screenshot pages, or marketing pages that reproduce a
licensed photograph, include its creator, license, source link, and the applicable
resize/crop/conversion notice.

## Safe public wording

> YouNew ships with a source-backed media-rights ledger and in-app attribution.
> Third-party photographs retain their individual Creative Commons conditions.

Do not claim municipality endorsement or suggest that the repository license
relicenses third-party media. Public-domain city symbols are used only for
informational identification.

## Scope boundary

This clearance applies to `YouNew/Assets.xcassets`. New screenshots, recordings,
audio, public-site images, or future assets require their own inventory entry and
review before publication.
