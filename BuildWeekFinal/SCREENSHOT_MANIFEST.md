# Screenshot manifest

Recorded: 2026-07-21 (Europe/Amsterdam)

## Status

Final simulator screenshots were not captured in this session.

Reason: after the build succeeded, UI test/app launch attempts exhausted the Simulator launch environment. Xcode reported `Launchd job spawn failed. Resource temporarily unavailable`, and the generated UI result bundle did not finalize with an `Info.plist`. Creating screenshots after that would not be reliable evidence.

## Required final screenshot set

Owner should capture these after restarting Xcode/Simulator or rebooting the machine:

| Screen | Required path | Acceptance check |
|---|---|---|
| Home | `BuildWeekFinal/screenshots/01-home.png` | Home content visible; root tab bar visible and not overlapped |
| AI Assistant | `BuildWeekFinal/screenshots/02-ai-assistant.png` | Assistant clearly described as local/guided/deterministic, not GPT-5.6 |
| Newcomer BSN/address/DigiD flow | `BuildWeekFinal/screenshots/03-newcomer-flow.png` | BSN/address/DigiD journey state visible |
| Guide/content route | `BuildWeekFinal/screenshots/04-guide.png` | Verified guide/content section visible; no placeholder copy such as `will appear here` |
| Official source | `BuildWeekFinal/screenshots/05-official-source.png` | At least one official source visible |
| Map | `BuildWeekFinal/screenshots/06-map.png` | Interactive Netherlands map visible |
| Root tab return | `BuildWeekFinal/screenshots/07-map-to-home.png` | Home visible after one root tab tap from Map |
| Imported city detail | `BuildWeekFinal/screenshots/08-city-detail.png` | One imported city detail visible: Amsterdam, Rotterdam, Den Haag, Utrecht, or Eindhoven |

## Current evidence instead of screenshots

- Build evidence: `BuildWeekSubmission/FINAL_VALIDATION.md`.
- Map/root tab fix evidence: `BuildWeekFinal/MAP_TAB_BLOCKER_FIX.md`.
- Demo steps: `BuildWeekFinal/DEMO_FLOW.md` and `BuildWeekSubmission/DEMO_GUIDE.md`.

Do not claim final screenshot evidence until the files above are actually captured.
