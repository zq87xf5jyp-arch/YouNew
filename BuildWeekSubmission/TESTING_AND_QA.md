# Testing and QA

Evidence cutoff: 21 July 2026, Europe/Amsterdam  
Candidate: branch `main`, HEAD `7a1f6bc8fcffac84e5798338380bb97aca815b3d`, dirty owner workspace

Targeted results are never presented as replacements for the finalized aggregate.

## Current verified

### Clean build

- Result: **PASS** after the final source change.
- Destination: dedicated iPhone 17 Pro Simulator, iOS 26.5.
- Artifact: `/private/tmp/YouNewBuildWeekCleanBuildPostFixFinal.xcresult`.
- The first sandboxed attempt could not resolve package hosts; the authorized rerun resolved the declared cached packages and completed `BUILD SUCCEEDED`.

### Unit

- Result: **460 total; 460 passed; 0 failed; 0 skipped**.
- Duration from result summary: `141.594 s`.
- Device: iPhone 17 Pro Simulator, iOS 26.5 (23F77), arm64.
- Artifact: `/private/tmp/YouNewBuildWeekUnitFinalPreserved.xcresult`.
- Persistent summary: [`../BuildWeekFinal/artifacts/UNIT_FINAL_SUMMARY.json`](../BuildWeekFinal/artifacts/UNIT_FINAL_SUMMARY.json).

### Static QA

- Result: **43/44 known checks PASS; 1 FAIL**.
- Sole failure: `scripts/data-health-gate.py`, `governed_broken_links=18`.
- Localization, routing, button/action, URL/source safety, Apple review, accessibility, performance, search, route-ID stability, report honesty, AppIcon, content, DataProject, import, dashboard, observability, and operations checks passed.
- This is not “44/44” or “all checks pass.”

### Full UI aggregate

- Result: **87 total; 79 passed; 8 failed; 0 skipped**.
- Test duration: `6203.559 s`; Xcode elapsed `6242.627 s`.
- Device: iPhone 17 Pro Simulator `YouNew`, iOS 26.5 (23F77), arm64.
- Artifact: `/private/tmp/YouNewBuildWeekFullUISerialFinal.xcresult`.
- Persistent summary: [`../BuildWeekFinal/artifacts/UI_FINAL_SUMMARY.json`](../BuildWeekFinal/artifacts/UI_FINAL_SUMMARY.json).

The eight aggregate failures were:

1. Guide composite category routing.
2. Leisure/education typed routes.
3. Discovery chip typed routes.
4. Transport chip typed routes.
5. Root-tab latency.
6. Published-city traversal.
7. Assistant selected-city route.
8. Assistant health-insurance guide.

### Isolated rerun of all eight failures

- Result: **8 total; 5 passed; 3 failed; 0 skipped**.
- Duration: `1777.498 s`.
- Artifact: `/private/tmp/YouNewBuildWeekEightFailuresRerun.xcresult`.
- Persistent summary: [`../BuildWeekFinal/artifacts/UI_FAILURE_RERUN_SUMMARY.json`](../BuildWeekFinal/artifacts/UI_FAILURE_RERUN_SUMMARY.json).

Passed unchanged in isolation:

- Leisure/education typed routes.
- Discovery typed routes.
- Transport typed routes.
- All five published-city traversals.
- Assistant health-insurance guide.

Still failed:

- Guide composite route: the original First Steps assertion was diagnosed as a missing accessibility marker. A local hero marker fixes that step and preserves its detail/back flow. The expanded composite test then reproducibly times out evaluating the Guide UI query after scrolling to Transport; `/private/tmp/YouNewBuildWeekGuideFixFinal2.xcresult`.
- Root-tab latency: all transitions delivered, but one sample was `191.158 ms`, above the unchanged `<100 ms` ceiling.
- Assistant selected-city route: `Open Leiden` did not reach city detail. Two implementation alternatives were tested and reverted because neither produced a verified improvement.

## Map/root evidence

- Original delivery blocker: fixed by separating the noninteractive safe-area reservation from the frontmost interactive root tab bar.
- Isolated serialized delivery: 10/10 first action; artifact `/private/tmp/YouNewBuildWeekRootLatencySerialFinal.xcresult`.
- Manual Computer Use: one Map → Home accessibility activation; `sequence=1;tab=home;delayMs=95.108`.
- Map calibration run 1: 99/100; unchanged repeat: 100/100. The first miss is retained.
- Latest isolated latency gate: FAIL at `191.158 ms`. Delivery and latency are reported separately.

## Assistant evidence

- Explicit local fallback: PASS.
- BSN → address → DigiD: PASS.
- Health-insurance guided route: PASS in the isolated rerun.
- Published-city AI responses: PASS across five cities in isolated traversal.
- Selected-city `Open Leiden` shortcut: FAIL; excluded from the demo.
- Live OpenAI/GPT-5.6 runtime: not verified.

## Data, import, security, and references

- DataProject/import structure: **PASS** — 17 work packages, 7 milestones, 7 releases, 27 batches, 450 records.
- `cities-v0.1.0`: **PASS** — Amsterdam, Rotterdam, Den Haag, Utrecht, Eindhoven.
- Scoped secret scan: **PASS WITH SCOPE** — 1,039 files, 23,040,033 bytes, 0 high-confidence hits.
- Existing generated-site internal references: **PASS** — 14,953 references across 229 HTML files.
- Fresh external links: **FAIL** — 2,494 checked; 1,821 reachable, 18 confirmed broken, 623 restricted, 32 transient.

## Visual and manual smoke

- Eight simulator screenshots were captured and visually inspected: Home, Assistant, newcomer guide, Guide, official sources, Map, Map → Home, and city detail.
- The stable demo path is documented in [DEMO_GUIDE.md](DEMO_GUIDE.md).
- No full physical-device, VoiceOver, older-OS, thermal, memory, offline, TestFlight, or App Store parity certification was performed.

## Historical — not current

- Prior audit supplied by the owner: unit `446/450`, static `35/40`, UI `80/86`.
- These values must not be used as current submission totals.

## Claim boundary

Safe: clean build PASS; unit 460/460; static 43/44 known gates; full UI 79/87; isolated failure rerun 5/8; map/root delivery fixed with disclosed latency failure; structural import PASS; scoped secret scan PASS.

Unsafe: all tests pass; all links work; production ready; full accessibility certification; historical totals presented as current.
