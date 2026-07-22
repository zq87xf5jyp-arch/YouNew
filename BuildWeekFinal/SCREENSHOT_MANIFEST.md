# Screenshot manifest

Recorded: 2026-07-21, 15:25–15:31 (Europe/Amsterdam)
Environment: dedicated `YouNew` iPhone 17 Pro Simulator, iOS 26.5
Candidate: branch `main`, HEAD `7a1f6bc8fcffac84e5798338380bb97aca815b3d`, dirty owner workspace

## Result

All eight requested simulator screenshots were captured and visually inspected. They are demo evidence for the rendered screens below, not physical-device, external-network, full-suite, or screenshot-release certification. The underlying shipped asset catalog separately passes its deterministic media-rights gate.

| # | File | Screen and acceptance result |
|---:|---|---|
| 1 | [`screenshots/01-home.png`](screenshots/01-home.png) | **PASS** — Home content and the root tab bar are visible; no overlap blocks the selected Home control. |
| 2 | [`screenshots/02-ai-assistant.png`](screenshots/02-ai-assistant.png) | **PASS WITH WORDING BOUNDARY** — Assistant, sources, search, map, KNM, Dutch, privacy warning, and root navigation render without clipping. The screenshot does not itself say “local deterministic”; that truthful runtime boundary is proved by the UI test and submission documentation. |
| 3 | [`screenshots/03-newcomer-flow.png`](screenshots/03-newcomer-flow.png) | **PASS** — Municipality registration guide visibly includes address registration and BSN-related steps. This is a guide-state screenshot, not a substitute for the serialized BSN → address → DigiD Assistant test. |
| 4 | [`screenshots/04-guide.png`](screenshots/04-guide.png) | **PASS** — Guide categories render with readable content and no placeholder copy in the visible primary surface. |
| 5 | [`screenshots/05-official-source.png`](screenshots/05-official-source.png) | **PASS WITH NETWORK BOUNDARY** — Official Source Directory renders and identifies 23 Dutch institutions/services; the warning about changing rules/contact details is visible. This does not prove every external URL is reachable. |
| 6 | [`screenshots/06-map.png`](screenshots/06-map.png) | **PASS** — interactive Netherlands map, 12 provinces, Amsterdam marker, Noord-Holland selection, city control, and root Map tab are visible. |
| 7 | [`screenshots/07-map-to-home.png`](screenshots/07-map-to-home.png) | **PASS** — captured after one accessibility activation of `tab.home` from Map. Runtime metric changed to `sequence=1;tab=home;delayMs=95.108`; Home became selected. |
| 8 | [`screenshots/08-city-detail.png`](screenshots/08-city-detail.png) | **UI PASS / SCREENSHOT REVIEW REQUIRED** — governed imported city Amsterdam opens with city identity, province, population, flag, and coat of arms. The catalog symbols are byte-exact Public Domain Commons assets, but this screenshot remains a separate release artifact; use symbols only for identification and do not imply municipality endorsement. |

## Capture method

- App routes were launched with the existing `-uiTesting`, `-resetUITestState`, `-launchLanguage`, `-uiTestingStartTab`, `-uiTestingDestination`, and `-uiTestingCity` arguments.
- PNG files were captured from the simulator display with `simctl io screenshot`.
- The Map → Home acceptance step was performed through the live Simulator accessibility element `tab.home`, not by relaunching directly on Home.
- Each key image was visually inspected after capture; no screenshot was generated or edited to conceal a failure.

## Evidence boundaries

- The serialized Assistant test is `/private/tmp/YouNewBuildWeekBSNFlowCleanSerial.xcresult` (1/1 PASS). Screenshot 3 only records the resulting guide surface.
- The serialized root navigation test is `/private/tmp/YouNewBuildWeekRootLatencySerialFinal.xcresult` (10/10 first-tap transitions). Screenshot 7 adds one manual UI activation.
- Known external-link health remains 18 confirmed broken responses among 2,494 checked URLs. Screenshot 5 proves the directory UI, not network health.
- The shipped 170-asset catalog has complete records and zero unresolved assets.
  That catalog result does not itself clear these screenshot files or a video.
- Before publication, review each screenshot/video as a separate release artifact
  and include the required credit and modification lines from
  [`MEDIA_RIGHTS_FINAL.md`](MEDIA_RIGHTS_FINAL.md) for every reproduced licensed
  photograph. For screenshot 08, also avoid any implication of municipality
  endorsement.

## Recording checklist

- Reproduce Home → local Assistant → BSN/address/DigiD → guide/source → Map → one-tap Home → Map → Amsterdam in one continuous take.
- Keep the “local guided assistant” wording; do not say GPT-5.6 or live OpenAI.
- Do not enter real BSN, address, account, health, or identity data.
- Verify the exact official source used in the video on the recording network.
- Stop and reopen the blocker if Map → Home does not work on the first tap.
