# Release Hardening Report

Date: 2026-06-14

## Fixed

| Blocker | Fix |
|---|---|
| History cards clipped offscreen | Timeline rail is fixed-width; cards flex inside remaining width. |
| History teaching image pushes timeline offscreen | Teaching image view is constrained to the available card width. |
| Key-figure chips overflowing in History | Chips now wrap to two lines and use smaller adaptive grid minimums. |
| Root bottom black slab | Root background now fills the whole shell directly; floating tab bar capsule cannot paint outside its pill. |
| Hidden iOS-only RootTabView compile risk | Restored the `GeometryReader` proxy in the iOS root shell after the background refactor. |
| AI Assistant bottom black slab | Empty state uses shared composer reserve, duplicated safety text was removed, and full-width bottom host backgrounds were removed. |
| More/Profile feels internal | Main More path now hides diagnostics/control/about rows and keeps Settings only in Account. |
| Mixed model-driven language fallback | Implicit model accessors now prefer English for release. |

## Build Results

- macOS Debug build: PASS.
- Latest macOS Debug build after RootTabView / AIAssistantView / NetherlandsHistoryView changes: PASS.
- iOS Debug generic build: BLOCKED BY ENVIRONMENT.
  - Failure point: asset catalog compilation.
  - Error: `No available simulator runtimes for platform iphonesimulator`.
  - Swift compilation did not report the red-marker fixes as compile errors before the environment failure.

## Release Gate Status

| Gate | Status |
|---|---|
| 0 black rectangular slabs | Source fix applied; runtime proof not available. |
| 0 bottom clipping defects | Source fix applied for observed AI defect; runtime proof not available. |
| 0 mixed-language screens | Release language forced to English; runtime proof not available. |
| 0 dead routes | Bare "Content not found" route replaced by release fallback; full runtime route walk not available. |
| 0 internal-only diagnostics exposed in main path | Fixed in More primary path. |
| 0 obvious stutter on AI / More / Search / tab switching | Source-level layout fixes applied; runtime FPS not measured. |

## Verdict

Source and macOS build state improved, but public-release proof is incomplete.

Final verdict: NEEDS PHYSICAL-DEVICE VERIFICATION BEFORE PUBLIC RELEASE.
