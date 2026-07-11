# Runtime scroll report

## Implemented coverage

`RootNavigationUITests` opens each root, locates a real last element, swipes until it is hittable, asserts an 8-point gap above `root.tabBar`, checks AI intersections, attaches a screenshot, returns to the first element, and repeats at Accessibility XXXL.

## Execution result

- Test bundle compilation: PASS (`TEST BUILD SUCCEEDED`).
- Test execution: NOT TESTED.
- Blocker: Xcode repeatedly failed before launching XCTest with `DebuggerLLDB.DebuggerVersionStore.StoreError` / `no debugger version`.
- No scroll screen is marked PASS without a completed XCTest run.

