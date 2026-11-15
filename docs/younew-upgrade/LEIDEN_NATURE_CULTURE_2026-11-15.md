# Leiden content batch 2 — 2026-11-15

Status: prepared for review, not activated in iOS or production.
Branch: `feature/leiden-nature-culture-content-20261115`, based on `ff9acbe` (draft #63; #62 contains batch 1).

## What was already present

All five IDs are in the 71-record compact editorial release. Their historical staging files and owner approval remain byte-identical. Existing private review tooling previously supported only the first five museums with mandatory photos, coordinates and ticket links. No second catalog, SwiftUI screen, storage service, dependency or publication system was created.

## Prepared content

| Existing ID | Added EN/NL material | Geography | Tickets |
| --- | --- | --- | --- |
| place.leiden-burcht | History, viewpoint, entrance, admission, visit planning | Visit Leiden route destination | None supplied |
| museum.leiden-wereldmuseum | Introduction, visitor address, opening pattern, accessibility, booking | No confirmed coordinate; no marker | Official museum ticket page |
| nature.leiden-plantsoen | Landscape history, waterside walk, aviary, location, wider route | Area name retained; no invented entrance pin | None supplied |
| nature.leiden-leidse-hout | Landscape, things to see, deer enclosure, arrival, tea-house planning | Visit Leiden route destination | None supplied |
| nature.leiden-cronesteyn | Habitats, wildlife, walks, arrival, maintenance caveat | Visit Leiden route destination | None supplied |

Counts: **5 revised existing records; 50 source-linked EN/NL blocks; 10 official source pages inspected; 3 coordinate destinations documented; 1 confirmed ticket page; 4 addresses rechecked, 1 existing park-area address retained. 0 new IDs, 0 approvals, 0 published changes, 0 photos imported.**

Source set includes Visit Leiden, Wereldmuseum Leiden, Gemeente Leiden and the Singelpark foundation's route document. Every block has source IDs and a check date. Source excerpts were rewritten into concise original English and Dutch descriptions. HTTP codes are not invented: link evidence records web-tool inspection and leaves HTTP status null.

Cronesteyn's dated municipal maintenance notice is not treated as live access status. The copy tells visitors to obey current signs and barriers; no expired event is surfaced as upcoming. No prices, availability, travel times or unsupported accessibility guarantees were added. The Wereldmuseum access section explicitly preserves the restriction on mobility scooters.

## Photography evidence and limits

Four candidates have confirmed Commons rights metadata, but file downloads returned HTTP 403 in this environment. They are therefore **not imported, optimized, visually inspected or exposed as verified card images**:

- Burcht: Effeietsanders, CC BY-SA 3.0 NL, 2010-09-11.
- Wereldmuseum: Sneeuwvlakte, CC BY-SA 4.0, 2024-11-08.
- Plantsoen: Rudolphous, CC BY-SA 4.0, 2021-08-06.
- Cronesteyn park: Ronald van der Graaf, CC BY 2.0, 2016-06-05.

Source and license links, attribution obligations, failures and review state are in `DataProject/editorial/leiden-nature-culture-20261115/media-evidence.json`. Leidse Hout photography remains unconfirmed. A different `Cronesteyn.jpg` candidate was excluded because its metadata points to Utrecht and its subject is castle grounds. Camera coordinates were never used as venue pins.

## Compatible review support

The existing `place-review.mjs` now accepts two explicitly registered batch IDs. Unknown IDs/path traversal fail. The first batch remains the default and retains its existing validation requirements. Batch 2 can explicitly omit unsourced photos, ticket links and coordinates; present coordinates must match the source-linked route destination and ticket URLs must match their declared source. The existing preview component omits Tickets when null.

Both batches require `YOUNEW_PRIVATE_REVIEW_BUILD=1`; all records remain draft/needs_review, publicationAuthorized false, with null reviewer/approval. Default exports remain unchanged. The asset helper clears only its existing generated review directory and does not leave batch-1 images behind when previewing a batch without images.

Private preview command, when adequate build disk space is available:

```sh
cd admin-dashboard/public-site
YOUNEW_PLACE_REVIEW=leiden-nature-culture-20261115 node scripts/build-place-review.mjs
```

This command produces a private, noindex review artifact using existing tooling. It is not an instruction or authorization to deploy it. No full website build or deployment was performed in this iteration; free disk space was approximately 1.3 GiB. Projection was exercised in memory by tests.

## Validation

- Existing first-batch tests plus new batch-2 tests: **8 passed, 0 failed**.
- Both data batches conform to the existing DataProject entity schema.
- Tests verify unchanged approved release, stable IDs, 76 projected total records, 5 revised records, 3 markers, 1 ticket link, 0 imported images; reject unknown batches, duplicate IDs, invented coordinate destinations, unsourced text/tickets and unverified imagery.
- TypeScript `tsc --noEmit`: passed.
- ESLint for changed TS/TSX: passed.
- iOS `xcodebuild -project YouNew.xcodeproj -scheme YouNew -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/younew-leiden-build CODE_SIGNING_ALLOWED=NO build-for-testing`: **TEST BUILD SUCCEEDED**. This compiles the existing app/test targets; pending batch data is deliberately not in its release bundle.
- Swift unit execution and Simulator UI checks remain unavailable: no usable simulator runtime was available in the preceding check; macOS unit execution was blocked by existing iOS-only navigation APIs. No new Simulator, preview, photo rendering, Save/MapKit, EN/NL layout, small-screen or theme verification is claimed.
- `git diff --check`: passed.

## Files

New batch JSON documents: records, manifest, source link checks, coordinate evidence, media evidence (five JSON files total). Review script/type declarations, media-copy helper and private build selector were extended. One nullable ticket field and its existing component were updated. `tests/leiden-nature-review.test.ts` adds three tests. This report documents the result.

## Next step

Review the prepared text and source evidence for both batches; obtain and visually inspect licensed photo files before accepting them. Activate only through the governed delivery process after review. Restore an iPhone Simulator runtime for actual device QA. The next content batch can cover five existing Leiden cafés/restaurants rather than creating duplicate attractions.

No production, App Store, signing, entitlement, user progress or approved source files changed.
