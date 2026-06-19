# Performance Release Report

Date: 2026-06-11

## Result

Status: RUNTIME UNVERIFIED

## Static Findings

| Area | Finding | Gate Impact |
| --- | --- | --- |
| City lists | Lazy grid/list patterns are present in city/province surfaces | No static blocker |
| Province lists | Media QA passes; image resolver/static data is clean | No static blocker |
| Map screens | Gesture-heavy and reported by user as laggy previously | Needs runtime verification |
| Image loading | Image loader has downsampling/cache behavior; duplicate data QA passes | No static blocker |
| Search | Recent searches use UserDefaults; static route/content QA passes | No static blocker |

## Build/Runtime Limitation

Performance could not be measured because Xcode build/runtime is blocked by CoreSimulator/asset catalog failure:

`No available simulator runtimes for platform iphonesimulator. SimServiceContext supportedRuntimes=[]`

## Required Device Test Before Upload Confidence

1. Scroll Cities for 60 seconds.
2. Scroll Province list and open 10 city cards.
3. Pan/zoom map repeatedly.
4. Search `BSN`, `DigiD`, `Belastingdienst`, `Leiden`, `Rotterdam`.
5. Watch memory and device temperature.
6. Toggle airplane mode and confirm no hangs.

## Gate Impact

Because major scrolling issues were previously reported, this remains High runtime risk until verified on device. It is not a source-confirmed blocker, but it blocks a confident "ready" verdict.
