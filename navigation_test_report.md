# Navigation test report

Date: 2026-07-11  
Verdict: **FAIL — release gate not satisfied**

## Verified

- `AppTab` and `TabItem` contain exactly Home, Guide, Map, Saved and More.
- Compact navigation and regular-width navigation are both derived from the same five canonical cases.
- Root order is stable: Home → Guide → Map → Saved → More.
- Search is a navigation destination, not a sixth tab.
- AI Assistant is a floating/global action and routes into the Guide navigation path.
- Every root owns an independent `NavigationPath`; selecting an already-active tab resets only that tab.
- Full route/action static QA passed.

## Failed or unproven routes

### NAV-001 — canonical deep links do not resolve

- Severity: Critical
- Screen: external deep link / any canonical detail
- Steps: obtain any `ContentItem.deepLink`; open `younew://content/<canonical-id>`.
- Expected: app selects the correct root context and opens the canonical item.
- Actual: `AppNavigationResolver` has no `content` route and the app has no matching `onOpenURL` handler.
- Proposed fix: introduce a canonical content destination, parse the URL scheme centrally, resolve aliases, select the owning tab and append one canonical destination.

### NAV-002 — Saved canonical row can be non-interactive

- Severity: High
- Screen: Saved
- Steps: save a canonical ID whose `legacyDestination(id:)` is nil; reopen Saved; tap the row.
- Expected: row opens the canonical item.
- Actual: `favoriteRow` renders plain `rowContent` when destination is nil.
- Proposed fix: Saved should always resolve ID to the canonical content destination; legacy destinations should be fallback-only.

### NAV-003 — back-navigation runtime proof unavailable

- Severity: Medium
- Screen: all root navigation stacks
- Steps: run root UI suite and traverse Home/Search/detail/back, Guide/category/detail/back, Map/detail/back and Saved/detail/back.
- Expected: each back action returns to the originating root and preserves that root's stack.
- Actual: source ownership is correct, but the iOS 26.5 test runner stalled after build; runtime assertion did not execute.
- Proposed fix: reset Simulator test-runner services and rerun `RootNavigationUITests` on standard, SE and Pro Max destinations.

## Test execution

- Full static QA: PASS.
- Canonical unit suite: build started successfully on iOS 26.5; runner stalled before results and was terminated.
- An iOS 26.4 device was rejected correctly because the test target requires iOS 26.5.
- No runtime PASS is claimed for deep links, Saved return navigation, SE/Pro Max, landscape or back-stack restoration.
