# Crash & Concurrency Audit — YouNew iOS App
**Date:** 2026-06-13  
**Scope:** Force unwraps, unsafe casts, `fatalError`/`preconditionFailure`, actor isolation violations, Task lifecycle issues, retain cycles, race conditions

---

## Baseline Scan Results

| Pattern | Matches | Verdict |
|---|---|---|
| `as!`, `fatalError`, `preconditionFailure`, `try!` | **0** | Clean |
| `![^=\s]` (force-unwrap operator) | 278 | All boolean negation (`!isEmpty`, `!Task.isCancelled`) |
| `\w+!` (identifier + bang) | 69 | All string literals (Dutch/Russian exclamation marks) |
| `DispatchQueue` | 3 | Two legitimate, one flagged (see below) |
| `Task.detached` | 1 | Reviewed — acceptable (see below) |
| `AnyCancellable` | 1 | Retain cycle confirmed — fixed |

**No force casts, no fatal errors, no force unwraps anywhere in the codebase.**

---

## FIXED: MapViewModel — Retain Cycle in Combine Sinks

**Severity:** MEDIUM  
**File:** `MapViewModel.swift:166–185`

Three `sink` closures captured `self` strongly via access to `self.selectedCityKey`, `self.selectedCategoryKey`, `self.selectedJourneyKey`:

```swift
// Before — strong self capture:
$selectedCity
    .dropFirst()
    .sink { city in
        UserDefaults.standard.set(city, forKey: self.selectedCityKey)  // ← strong capture
    }
    .store(in: &cancellables)
```

**Retain cycle:** `self → cancellables: Set<AnyCancellable> → AnyCancellable → closure → self`

Since `cancellables` is stored on `self`, and each `AnyCancellable` captures `self` to read a key constant, the reference graph forms a cycle. `MapViewModel` can never reach `deinit` — it leaks for the lifetime of the app once initialized.

**Note:** `locationService.$location.sink` at line 161 already correctly used `[weak self]`. Only the three UserDefaults persistence sinks were affected.

**Fix applied:** Extracted each key constant as a local `let` before the closure, eliminating any `self` capture entirely:

```swift
// After — no self capture:
let cityKey = selectedCityKey
$selectedCity
    .dropFirst()
    .sink { city in
        UserDefaults.standard.set(city, forKey: cityKey)
    }
    .store(in: &cancellables)
```

Same pattern applied to `categoryKey` and `journeyKey`.

**Verification:** 0 diagnostics ✓

---

## FIXED: LocationService — Missing `@MainActor` Annotation

**Severity:** LOW-MEDIUM  
**File:** `LocationService.swift:5`

`LocationService` is an `ObservableObject` with three `@Published` properties that are mutated exclusively in `CLLocationManagerDelegate` callbacks:

```swift
// Before:
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var location: CLLocation?
    @Published var locationFetchFailed: Bool = false
```

`CLLocationManager` invokes its delegate on the run loop of the thread where the manager was initialized. In this app, `LocationService()` is always created inside `MapViewModel.init()`, which is `@MainActor`-isolated — so delegate callbacks always fire on the main thread. The code is correct at runtime.

However, without `@MainActor`, the Swift compiler cannot statically verify this invariant. Any future caller creating `LocationService` outside a `@MainActor` context would invoke CLLocationManager APIs off-main-thread, which is undefined behavior per Apple's documentation. The missing annotation is a correctness guarantee the compiler should be enforcing.

**Fix applied:** Added `@MainActor` to the class declaration:

```swift
// After:
@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
```

**Verification:** 0 diagnostics ✓

---

## FIXED: AIViewModel — Missing Cancellation Check After `suggestResources` Await

**Severity:** LOW  
**File:** `AIViewModel.swift:168–177`

`sendCurrentMessage()` uses an unstructured `Task` (`sendTask`) for the AI request lifecycle. The task has three `guard !Task.isCancelled else { return }` checks — but one was missing:

```swift
// Before:
guard !Task.isCancelled else { return }  // check #2 present ✓

let baseResources = await service.suggestResources(for: message, language: language)
// ← no check here after async suspension
if let status = contextSnapshot?.status {
    suggestedResources = ...  // ← executed even if task was cancelled
}
suggestedMapCategory = suggestedCategory(for: message)  // ← same
```

`clearConversation()` cancels `sendTask` and resets `suggestedResources = []` and `suggestedMapCategory = nil`. If cancellation fires during `suggestResources`, the task resumes after the await, sees a cancelled state, but then re-assigns stale values — undoing the clear. The user would see previously-relevant resource cards reappear briefly after clearing the conversation.

**Fix applied:** Added `guard !Task.isCancelled else { return }` after the await:

```swift
// After:
let baseResources = await service.suggestResources(for: message, language: language)
guard !Task.isCancelled else { return }
if let status = contextSnapshot?.status {
    suggestedResources = ...
}
suggestedMapCategory = suggestedCategory(for: message)
```

**Verification:** 0 diagnostics ✓

---

## REVIEWED: AIViewModel — NWPathMonitor → MainActor Hop

**File:** `AIViewModel.swift:359–366`

```swift
monitor.pathUpdateHandler = { [weak self] path in
    let isOffline = path.status != .satisfied
    Task { @MainActor [weak self] in
        self?.isOffline = isOffline
    }
}
monitor.start(queue: monitorQueue)
```

`NWPathMonitor` fires its handler on `monitorQueue` (a background `DispatchQueue`). The code correctly:
- Reads `path.status` off-main (safe — `path` is a value type)
- Re-enters `@MainActor` before mutating `isOffline` via `Task { @MainActor in }`
- Uses `[weak self]` in both closures to prevent retain cycles

**No fix needed. Correct pattern.**

---

## REVIEWED: AppStateViewModel — `showToast` Task Pattern

**File:** `AppStateViewModel.swift:206–215`

```swift
toastDismissTask = Task { [weak self] in
    try? await Task.sleep(nanoseconds: 2_500_000_000)
    guard !Task.isCancelled else { return }
    await MainActor.run {
        self?.toastMessage = nil
    }
}
```

`AppStateViewModel` is `@MainActor`. An unstructured `Task {}` created inside a `@MainActor` context inherits `@MainActor` isolation — after `Task.sleep`, the task automatically resumes on MainActor. The `await MainActor.run {}` is therefore redundant but harmless. The `[weak self]` prevents any theoretical retain cycle (though on `@MainActor` classes, unstructured task closures that only access `self` don't technically form cycles due to actor isolation semantics). `toastDismissTask?.cancel()` is called before each new toast and in `deinit`.

**No fix needed. Correct behavior; minor redundancy in `MainActor.run`.**

---

## REVIEWED: AppContentImageView — `Task.detached` for Image Fetch

**File:** `AppContentImageView.swift:270–274`

```swift
let prepared = try await Task.detached(priority: .utility) {
    let (data, _) = try await URLSession.shared.data(from: candidate)
    guard let decoded = UIImage(data: data) else { return nil as UIImage? }
    return await decoded.byPreparingThumbnail(ofSize: targetPixelSize) ?? decoded
}.value
```

`Task.detached` is used inside `loadImage()` which is `@MainActor`. The closure captures `candidate: URL` and `targetPixelSize: CGSize` — both value types, no `self` capture, no retain cycle possible.

**Cancellation behavior:** When the `.task(id: cacheKey)` modifier fires (view disappears or `cacheKey` changes), the parent task is cancelled and `await Task.detached(...).value` throws `CancellationError` — the loop exits, no state is mutated. The detached child task continues until its network request completes, then its result is discarded. This wastes network bytes but cannot cause a crash or state corruption, since `AppContentImageView` is a struct with `@State` — if the view is gone, any state mutations in the child task become no-ops.

The `priority: .utility` is intentional — image loading is correctly deprioritized below user-interactive work.

**No fix needed. Acceptable design tradeoff.**

---

## REVIEWED: DirectImageLoader — Static `inFlightTasks` Dictionary

**File:** `ImageLoader.swift:33, 126–168`

```swift
private static var inFlightTasks: [String: Task<UIImage?, Never>] = [:]
```

This deduplicates concurrent requests for the same URL. The dictionary is accessed and mutated in `fetchImage(urlString:targetWidth:)` which runs inside an unstructured `Task` on `@MainActor` (since `DirectImageLoader` is `@MainActor`). All reads/writes to `inFlightTasks` therefore happen on the main actor. No data race is possible.

**No fix needed. Correct.**

---

## NOTED: TapHighlighter — `DispatchQueue.main.asyncAfter`

**Severity:** VERY LOW (DEBUG-only code)  
**File:** `TapHighlighter.swift:21`

```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    withAnimation { flash = false }
}
```

This is inside `#if DEBUG`. The closure captures `flash: @State`, which is a value type; no retain cycle. The delay correctly schedules the animation dismissal on the main thread. Using `Task.sleep` would be more idiomatic Swift Concurrency, but this is non-shipping code with no behavioral issue.

**No fix needed.**

---

## Fix Summary

| # | File | Change | Severity |
|---|---|---|---|
| C1 | `MapViewModel.swift:166–185` | Break retain cycle in 3 Combine sinks by capturing key constants instead of `self` | MEDIUM |
| C2 | `LocationService.swift:5` | Add `@MainActor` annotation to enforce main-thread guarantee at compile time | LOW-MEDIUM |
| C3 | `AIViewModel.swift:168` | Add `guard !Task.isCancelled` after `suggestResources` await to prevent stale state updates after `clearConversation()` | LOW |

**Reviewed and confirmed clean (no fix needed):**

| # | Pattern | Verdict |
|---|---|---|
| R1 | `AIViewModel` NWPathMonitor → `Task { @MainActor }` hop | Correct |
| R2 | `AppStateViewModel.showToast` weak-self Task pattern | Correct (minor `MainActor.run` redundancy) |
| R3 | `AppContentImageView` `Task.detached` image fetch | Acceptable (no crash risk, intentional priority) |
| R4 | `DirectImageLoader.inFlightTasks` static dictionary | Correct (MainActor-isolated) |
| R5 | `TapHighlighter` `DispatchQueue.main.asyncAfter` | Non-shipping debug code, no issue |

---

## Verification

```
MapViewModel.swift     — 0 diagnostics ✓
LocationService.swift  — 0 diagnostics ✓
AIViewModel.swift      — 0 diagnostics ✓
```

**Crash Risk: NONE** — No force casts, force unwraps, or fatal errors anywhere in the codebase.  
**Concurrency Safety: HIGH** — All `@MainActor` classes are correctly isolated. One retain cycle fixed. One missing cancellation guard added. One missing actor annotation added.
