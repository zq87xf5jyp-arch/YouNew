# Scroll Performance Report

Date: 2026-06-11

## Status

Measured FPS and memory usage were not available because local runtime/build is blocked by Xcode CoreSimulator/asset catalog errors. This report is a source-level performance audit plus fixes for obvious interaction blockers.

## Findings

| Area | Risk | Status |
| --- | --- | --- |
| City lists | Image-heavy lists can stutter if every image eagerly resolves | Existing code uses lazy grids/stacks in key list surfaces |
| Province lists | Province/city cards depend on remote media/cache behavior | Media QA and image runtime data QA pass statically |
| City detail screens | Large hero/places content can be expensive | Existing image loader includes downsampling and cache preparation |
| Map city panels | Gesture-heavy map UI requires runtime testing | Not verified in this environment |
| Documents | Action buttons previously felt dead, creating perceived broken scrolling | Scroll targets added with `ScrollViewReader` |

## Fixes Applied

| Issue | Fix |
| --- | --- |
| Documents buttons did not move the user through the long scroll view | Added `ScrollViewReader` and target IDs for document list and needed-docs section |
| Missing image assets could trigger fallback/render churn | Replaced bad asset names with bundled assets or intentional generated fallback |

## Required Device Measurements

Measure before TestFlight external/public release:
- Scroll FPS in Cities Directory.
- Scroll FPS in Province Directory.
- Scroll FPS in City Detail with places.
- Memory while opening 10 city/province detail screens.
- Network request duplication for remote images.
- Map drag/pan smoothness.

Current result: acceptable for internal TestFlight only after manual physical-device smoke test; not public-release-proven.
