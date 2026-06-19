# Image Runtime Verification Report

Date: 2026-06-10

## Runtime Status

RUNTIME VERIFICATION NOT PERFORMED

CoreSimulator is unavailable on this machine. `xcrun simctl list runtimes` failed because CoreSimulatorService could not initialize the simulator device set. A generic iOS `xcodebuild` also failed in asset catalog compilation with:

`No available simulator runtimes for platform iphonesimulator. SimServiceContext supportedRuntimes=[]`

Because of that, no new runtime screenshots were captured and I am not claiming screenshot-proven runtime correctness.

## Screenshot Targets Requested

| Target | Runtime screenshot captured | Verification status |
|---|---|---|
| Drenthe province modal | No | Blocked by unavailable simulator runtime. |
| Utrecht province modal | No | Blocked by unavailable simulator runtime. |
| Haarlem detail | No | Blocked by unavailable simulator runtime. |
| Den Haag Places tab | No | Blocked by unavailable simulator runtime. |
| Dutch figures list | No | Blocked by unavailable simulator runtime. |
| Province city cards carousel | No | Blocked by unavailable simulator runtime. |
| Utrecht city detail hero | No | Blocked by unavailable simulator runtime. |
| Groningen city detail hero | No | Blocked by unavailable simulator runtime. |
| Nijmegen city detail hero | No | Blocked by unavailable simulator runtime. |
| Arnhem city detail hero | No | Blocked by unavailable simulator runtime. |

## Static Verification Performed

| Check | Result |
|---|---|
| `python3 scripts/image-runtime-data-qa.py` | Passed. Checked 42 curated place images, 21 province city cards, 10 historical figure portraits. |
| `python3 scripts/content-static-qa.py` | Passed. |
| `python3 scripts/media-static-qa.py` | Passed. |
| `python3 scripts/place-media-static-qa.py` | Passed. |
| `xcrun swiftc -parse` on changed Swift files | Passed. |
| Full source `swiftc -typecheck` with workspace module cache | Did not pass because of existing `AIContextBuilder` main-actor isolation errors outside the image path. The image-specific opaque return type errors found during this pass were fixed. |
| `xcodebuild -project YouNew.xcodeproj -scheme YouNew -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build` | Failed before app build completion because asset catalog compilation requires unavailable simulator runtimes. |

## Before/After Notes

| Issue | Before | After |
|---|---|---|
| Province modal hero | Local image priority could bypass earlier registry fixes. | Uses `resolveProvinceHero(province:)`. |
| Province city cards | Local city hero selection could bypass canonical checks. | Uses `resolveProvinceCityCard(city:)`. |
| City detail hero | Used `NLCity.imageURL` plus legacy `placeId` fallback. | Uses `resolveCityHero(city:)`. |
| City places | Used attraction URL directly. | Uses `resolvePlaceImage(place:)` with Den Haag windmill assertions. |
| Dutch figures | Used `CityImageView` and place-style fallback behavior. | Uses figure portrait loader plus symbolic category fallback. |
| Cache behavior | Fallback could be cached under failed primary URL. | Fallback candidates cache under their own URL only. |
| Haarlem | Previously reported as sky/cloud in runtime. | Static data now points Haarlem to `HaarlemGroteMarkt1.JPG`; static QA blocks sky/cloud tokens. |
| Arnhem | Older curated city image was not the requested bridge/center identity. | Curated hero now uses John Frost Bridge. |
| Nijmegen | Older curated city image was generic skyline. | Curated hero now uses Waalbrug. |

## Remaining Runtime Risk

The remaining risk is runtime-only:

- A device/simulator may still have stale URLCache data from previous app sessions.
- The remote Wikimedia URLs may redirect or fail differently on device networking.
- The bundled emergency fallback may appear if all remote candidates fail, but people thumbnails no longer use city/province fallback behavior.

Manual runtime verification should be performed on device or simulator once CoreSimulator is healthy.
