# Testing and QA

Evidence cutoff: 21 July 2026, Europe/Amsterdam  
Candidate source: branch `build-week-readiness`, HEAD `da8c3fe22e7a5d99b2187aab1141700b2d34f508`, dirty owner workspace

This report separates current finalized evidence from historical results, partial targeted evidence, and runs invalidated by the execution environment. A targeted PASS is not presented as a full-suite PASS.

## Current verified

### Unit tests

- Status: **PASS**.
- Scheme: `YouNewUnitTests` (unit target only).
- Result: **460 total; 460 passed; 0 failed; 0 skipped; 0 expected failures**.
- Device: iPhone 17 Pro Max Simulator, iOS 26.5 (23F77), arm64.
- Result-bundle duration: `857.123 s`; Xcode testing operation: `304.181 s`.
- Artifact: `/private/tmp/YouNewBuildWeekFinalUnitD7.xcresult`.
- Summary: `/private/tmp/YouNewBuildWeekFinalUnitD7.summary.json`.
- Log: `/private/tmp/YouNewBuildWeekFinalUnitD7.log`.

### Static QA

- Aggregate status: **FAIL, bounded to one known data-health gate**.
- Inventory: 44 script invocations in `scripts/run-static-qa.sh`.
- Known per-invocation result: **43 passed; 1 failed; 0 unknown**.
- The aggregate stopped at invocation 35 because the script uses `set -e`.
- The nine not-reached checks were then executed individually and all nine passed.
- Sole failure: `scripts/data-health-gate.py`, reason `governed_broken_links=18`.
- Aggregate duration: `24.93 s`; follow-up remainder duration: `2.855 s`.
- Logs: `/private/tmp/YouNewBuildWeekFinalStaticQA.log` and `/private/tmp/YouNewBuildWeekFinalStaticQARemainder.log`.

This is not “44/44 PASS”. The failed link-health gate remains public in the limitation register.

### Map / root-tab targeted gate

- Status: **PASS**.
- Result: **3 total; 3 passed; 0 failed; 0 skipped**.
- Covered: Leiden city activation, Zeeland/Middelburg city activation, and root Map ↔ Home delivery/latency.
- Delivery: **10/10 first-tap transitions**.
- App-side latency: maximum `94.1 ms` under the unchanged `< 100 ms` contract.
- Test duration: `67.097 s`; testing operation: `73.277 s`.
- Artifact: `/private/tmp/YouNewBuildWeekMapOverlayFix.xcresult`.

### Local assistant targeted gate

- Status: **PASS after a clean Simulator boot**.
- Result: **1 total; 1 passed; 0 failed; 0 skipped**.
- Covered: explicit local fallback without backend, visible local-guide origin, four structured steps, source action, and municipality-registration guide navigation.
- Test duration: `106.162 s`; testing operation: `253.462 s` including post-boot build/launch overhead.
- Artifact: `/private/tmp/YouNewBuildWeekLocalFallbackCleanBoot.xcresult`.

### Guide and accessibility targeted gates

- Guide completed-surface check: **1/1 PASS**; artifact `/private/tmp/YouNewBuildWeekContentPrimaryPostFix.xcresult`.
- Accessibility search-focus check: **5/5 repetitions PASS**; artifact `/private/tmp/YouNewBuildWeekAccessibilitySearchPostFix.xcresult`.
- City cafés route: three isolated route runs plus one discovery route run passed; no routing code was changed because the baseline activation loss was not reproduced.

### Data, import, security, and references

- Structural DataProject QA: **PASS** — 17 work packages, 7 milestones, 7 releases, 27 batches, 450 records.
- `cities-v0.1.0` dry-run import: **PASS** — 5 eligible, 0 excluded, 0 broken relations, 0 technical duplicates.
- Import regression, workflow policy, and dynamic URL-source safety: **PASS**.
- Existing generated public-site internal references: **PASS** — 14,953 references across 229 HTML files; source was not rebuilt by that check.
- Secret scan: **PASS WITH SCOPE** — 1,039 text files / 23,040,033 bytes, 0 high-confidence secret hits and 0 generic literal secret assignments. Ignored binaries, generated/dependency/media trees, and Git history were outside scope.
- Fresh external link health: **FAIL** — 2,494 checked, 1,826 reachable, 18 confirmed broken (404), 617 restricted, 33 transient.
- Consolidated evidence: `/private/tmp/YouNew-final-data-security-validation-summary.json`.

Structural import PASS and external network-health FAIL are separate claims.

## Current UI aggregate

The final aggregate is still being assembled from finalized, non-overlapping class artifacts. Until `FINAL_VALIDATION.md` closes this section, do not publish an aggregate UI pass count.

Two combined demo runs executed while multiple independent Simulator builds/runners were active are retained as negative environment evidence:

- `/private/tmp/YouNewBuildWeekTargetedDemo.xcresult`: 0/4; included launch/window timeouts and delayed/misdirected app state under host contention.
- `/private/tmp/YouNewBuildWeekLocalFallbackIsolated.xcresult`: 0/1; the failure snapshot showed Map (`sequence=1;tab=map`) although the test launched Assistant.
- `/private/tmp/YouNewBuildWeekBSNFlowIsolated.xcresult`: 0/1; the same Map state appeared while a separate Map runner was active.

Those results are not silently discarded, but they are not proof that the deterministic assistant workflow failed: after the competing runner was removed with a clean Simulator boot, the exact local-fallback test passed. The BSN/address/DigiD flow still requires its own uncontended finalized result.

## Historical — not current

- User-provided prior audit: unit `446/450`, static `35/40`, UI `80/86`.
- Last finalized clean-clone UI snapshot at commit `efd1a7c50bf7b5e2f82be047b084b6d73cb009a7`: `84/87`, 3 failures, `7,249.603 s`.
- Current-HEAD control UI run: interrupted after 21 starts; 17 passed, 3 failed, 1 interrupted, 66 not reached. It has no finalized `.xcresult` and supplies no current aggregate.

None of these numbers may be presented as the current candidate result.

## Not reproduced or not yet closed

- The baseline cafés activation loss was not reproduced in four focused PASS runs; retain as a monitored non-demo limitation until the aggregate closes.
- The current control run's deep-scroll test was interrupted without an XCTest verdict. A historical focused PASS does not convert it into a current PASS.
- Clean build, uncontended BSN/address/DigiD, expanded map/root, and final UI aggregate are recorded in `FINAL_VALIDATION.md` when complete.

## Claim boundary

Safe now: the project has a current 460/460 unit PASS, 43/44 known static-check results with one disclosed data-health failure, targeted evidence for the local assistant and map/root fix, structural import PASS, and a scoped secret-scan PASS.

Unsafe: “all tests pass”, “all links pass”, “the app is production ready”, or any historical total presented as current.
