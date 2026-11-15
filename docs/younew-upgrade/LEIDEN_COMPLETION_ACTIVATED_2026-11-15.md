# Leiden iOS: activation of the exact approved completion

## Result

Connected exactly **4 photographs, 5 coordinates and 6 ticket URLs** to the existing seven iOS cards through the governed exporter. No new place IDs or Saved IDs were created. All other fields remain those of the previously approved compact release.

| Existing card | Newly connected photo | Newly connected coordinate | Tickets |
| --- | --- | --- | --- |
| Lakenhal | Existing photo retained | Existing coordinate retained | Connected |
| Hortus | Roger Veringmeier, CC BY 4.0 | Existing coordinate retained | Connected |
| Burcht | Existing photo retained | 52.15831, 4.492962 | No button; no approved ticket URL |
| RMO | Steven Lek, CC BY-SA 4.0 | 52.1584668, 4.4858978 | Connected |
| Naturalis | Existing photo retained | 52.1646451, 4.4730775 | Connected |
| Boerhaave | Goodness Shamrock, CC BY-SA 3.0 | 52.16134171, 4.48917759 | Connected |
| Wereldmuseum | Sneeuwvlakte, CC BY-SA 4.0 | 52.16324, 4.48245 | Connected |

Four approved 1200 px WebP derivatives are bundled byte-for-byte, totaling **871,710 bytes**. No transcoding or content edits were performed. Existing image loaders now decode bundled file URLs off the main thread and retain their existing memory caching/downsampling. These four photos can load without network access. Source pages, author, license name/URL, attribution and resize disclosure are preserved in the runtime media and visible through existing detail credits. Original remote URLs remain available as fallback for the same licensed photo.

Existing Discover/list/detail components consume the shared resolver. The active Home preview also consumes its URLs, including bundled resources. Six place details now show localized Tickets actions using SwiftUI Link; Burcht does not. Existing Directions uses Apple Maps with `daddr` from the confirmed coordinates; the seven selected cards now all have coordinates. Boerhaave is explicitly an address centroid, not a surveyed entrance.

## Exact approval and scope

The owner explicitly authorized this activation in the conversation after reviewing PR #66. The separate receipt is `DataProject/editorial/leiden-ios-completion-20261115-approval.json`, referencing registered reviewer `owner.ivan`, the full review source commit and the exact selection SHA-256:

`bfada10e8b2ef709ab52bfebf347131fec619545717b8e9246c0b87e8f30cead`

The receipt approves only the listed four photos, five coordinates and six ticket URLs. It does not change the approval status of either historical review package or of the selection document itself.

The existing exporter `scripts/export-approved-ios-places.mjs` now applies `scripts/approved-ios-completion.mjs` after validating the original compact release. It validates the registered owner, explicit scope, selection hash, source-record and manifest hashes, all reviewed image variants and source relationships. Only selected media, coordinate/evidence fields and ticket URL/source/date fields are copied. It never merges entire draft attribute dictionaries or enrichment text. The receipt hash and selection hash are included in the generated artifact. `--check` verifies both generated JSON and the four copied media files.

Regression tests compare every other field to the original web projection: descriptions EN/NL, original addresses, categories, source dates, related IDs and original attributes remain unchanged. No additional photo, price, opening-hour change or park record was imported. Pending replacement photos for Lakenhal/Naturalis remain pending. The two historical manifests remain `needs_review` and `publicationAuthorized: false`.

## Validation results

- Final Xcode command: `xcodebuild -project YouNew.xcodeproj -scheme YouNew -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/younew-leiden-build CODE_SIGNING_ALLOWED=NO build-for-testing`, with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. **TEST BUILD SUCCEEDED**, arm64 and x86_64, **0 warnings / 0 errors** in the final log.
- All four WebP files and the generated JSON were checked inside `Debug-iphonesimulator/YouNew.app`; bytes match approved/generated sources exactly.
- Native Apple ImageIO decoding on macOS: Hortus 1200x798, RMO 1200x800, Boerhaave 1200x1883, Wereldmuseum 1200x900. This is an actual decoder check, not a Simulator rendering claim. An initial sandboxed Swift invocation could not write the compiler module cache; the explicit temporary-cache invocation outside that sandbox succeeded.
- **20 data/governance tests passed**, 0 failures: original editorial and review tests, exact approved projection, approval-selection bindings, and negative tests for missing approval status, changed selection, changed image bytes and widened whole-batch scope.
- Swift Testing regressions for bundled image decoding/rights, preserved Saved IDs, seven coordinates, Apple Maps `daddr` construction and six ticket actions compile successfully. Their runtime execution is not claimed.
- All six exported ticket URLs returned **HTTP 200**. RMO's approved `/en-EN/tickets` redirects to the same official service's `/en-US/tickets`. No transaction, booking or purchase was submitted. Full URLs and responses are in the adjacent evidence JSON.
- `simctl list runtimes` returned no runtimes; no available Simulator devices. A fresh `test-without-building` attempt for iPhone 16 failed because no matching destination exists. Actual Apple Maps launch/route calculation, ticket-button interaction, rendered photographs, Save-to-Saved, EN/NL UI, small-screen layout and light/dark appearance remain **unverified in iOS**.
- `git diff --check` passed. No Bundle ID, signing, entitlement or publication configuration was edited.

Logs: `/tmp/leiden-completion-activation-final-build.log`, `/tmp/leiden-activation-data-tests-final.log`, `/tmp/leiden-completion-activation-test.log`, `/tmp/leiden-approved-native-image-check.log`. Persistent evidence: [LEIDEN_COMPLETION_ACTIVATED_EVIDENCE_2026-11-15.json](LEIDEN_COMPLETION_ACTIVATED_EVIDENCE_2026-11-15.json).

## Changed files

- Separate approval receipt and editorial README documentation.
- Existing iOS exporter, field-scoped approval validator and their regression tests.
- Generated `YouNew/Resources/Data/younew-approved-places.json` and four files under `ApprovedLeidenMedia/`.
- `DataProjectRuntimeLoader.swift`: optional backward-compatible bundled filename/author decoding.
- `CanonicalPlaceImageResolver.swift`: prefer the four approved media records, preserving legacy media elsewhere.
- `AppContentImageView.swift`, `ImageLoader.swift`: bundled URL decoding in existing loaders.
- `DashboardDiscoveryModels.swift`, `DashboardDiscoveryViews.swift`: validated approved ticket URLs and conditional Tickets action.
- `CityPlacesCalendarRegressionTests.swift` and this report/evidence.

Production, web release artifacts, TestFlight, App Store Connect and user data were not changed. No PR was merged. Remaining verification requires an available iOS Simulator runtime; it does not require another content approval for this exact selection.
