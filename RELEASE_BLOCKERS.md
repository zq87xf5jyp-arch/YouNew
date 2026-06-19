# Release Blockers — YouNew.nl
**Audit date:** 2026-06-18  
**Build:** 1.0.0 (1) — iOS 17.6+ minimum  
**Status:** BLOCKED — runtime release certification incomplete

---

## Current Release Blockers

| # | Severity | Area | Evidence | Required action |
|---|---|---|---|---|
| 1 | P0 | Runtime walkthrough | Fresh `xcodebuild ... build-for-testing` was silent for roughly two minutes and was terminated with exit 143. | Restore a stable Xcode/simulator/device run and complete the full tap-through walkthrough. |
| 2 | P0 | Simulator availability | `simctl get_app_container ... nl.younew.app` failed because CoreSimulatorService connection became invalid. | Restart simulator services or move to a physical device, then rerun launch/UI gates. |
| 3 | P0 | Installed app availability | Simulator Spotlight search did not find YouNew on the booted device. | Install the current build before manual or automated walkthrough. |
| 4 | P0 | UI automation | Focused UI regression tests could not be rerun in the current simulator state. | Rerun critical UI tests for More, AI Assistant, tab routing, search, and map chips after simulator recovery. |
| 5 | P0 | Performance | No Instruments or stable runtime FPS trace was captured in this session. | Profile scrolling, search, AI, images, lists, maps, and large screens before App Store claim. |

These are release-certification blockers, not newly confirmed app-code crashes. The static application gates pass, but the requested pass criteria require live verification.

---

## Fixed Before This Report

| # | Severity | File | Line | Issue | Status |
|---|---|---|---|---|---|
| 1 | P1 | `AIAssistantView.swift` | 1574 | Fallback AI section title `"Answer"` hardcoded English — not localized for RU/NL | ✅ Fixed |
| 2 | P1 | `AIAssistantView.swift` | 1640 | Fallback nav button `"Open section"` hardcoded English | ✅ Fixed |
| 3 | P2 | `AIAssistantView.swift` | 230 | Suggestion chip touch target `minHeight: 34` — below Apple HIG 44pt minimum | ✅ Fixed → 44pt |
| 4 | P1 | `MoreHubView.swift` | hero | More hero could visually overgrow and clip content on compact devices | ✅ Fixed with bounded 220 pt local hero and regression marker |
| 5 | P1 | `AIAssistantView.swift` | hero/input | Assistant popular-question cards could sit under the composer on compact devices | ✅ Fixed with compact 300 pt hero and composer dock clearance |

---

## REQUIRES MANUAL ACTION (cannot edit .pbxproj while Xcode is open)

| # | Severity | File | Lines | Issue | Action |
|---|---|---|---|---|---|
| 4 | P2 | `project.pbxproj` | 519 | Test Release bundle ID `com.company.younew.tests` — placeholder | In Xcode: YouNewTests target → Build Settings → Release → Bundle Identifier → set `nl.younew.app.tests` |
| 5 | P2 | `project.pbxproj` | 569 | UITest Release bundle ID `com.company.younew.uitests` — placeholder | In Xcode: YouNewUITests target → Build Settings → Release → Bundle Identifier → set `nl.younew.app.uitests` |

*Items 4–5 are test targets only and do not affect App Store submission of the main app binary.*

---

## Verified Passing Gates This Session

| Gate | Result |
|---|---|
| `scripts/run-static-qa.sh` | PASS |
| Route/action static QA | PASS: 70 AppDestination cases rendered; 51 hardcoded destination references checked |
| Button/action static QA | PASS: no nested Button/NavigationLink controls found |
| Localization key static QA | PASS: 610 literal UI keys covered in EN/NL/RU |
| Search static QA | PASS: valid-content query coverage checked |
| Image runtime/static QA | PASS: 294 visible assignments, 294 unique URLs, 0 duplicate source groups |
| AI subsystem static QA | PASS |
| Apple review static QA | PASS |

---

## NOT BLOCKERS — verified non-issues

| Reported Defect | Verdict | Evidence |
|---|---|---|
| FloatingAI button overlaps content | ✅ Not a bug | `safeAreaInset` + `contextualAIContentReserve` push content correctly |
| Hero headers overlap content | ✅ Not a bug | Headers scroll with content, no sticky z-order conflict |
| Spec note "Each topic now follows…" in UI | ✅ Not in production | Found only in `scripts/*.py`, not in any View |
| Profile shows "Not for this profile" | ✅ Not in code | String absent from all Swift files |
| Official Sources counter mismatch | ✅ Not present | `visibleSourceCount` is dynamically computed |
| Utrecht modal duplicate close button | ✅ Not present | Single xmark button in modal |
| History black hero banners | ✅ By design | 35% image rule — `image: nil` is intentional per content strategy |
| Tab active state mismatch (Map on AI) | ✅ Not a bug | `openGlobalAssistant()` correctly sets `selectedTab = .assistant` |
| Label truncation (Municipali…) | ✅ Not found | All critical text has `lineLimit + minimumScaleFactor` |
