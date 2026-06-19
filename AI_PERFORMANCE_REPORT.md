# AI Performance Report
Generated: 2026-06-15

## Summary

The AI assistant is designed for 60 FPS scroll performance with all heavy work off the main thread and aggressive caching to avoid redundant backend calls.

---

## Main Thread Safety

| Operation | Thread | Status |
|-----------|--------|--------|
| UI state mutations (`messages`, `isLoading`) | `@MainActor` | SAFE |
| Network request (`AIClient.send`) | Cooperative pool | SAFE |
| JSON decoding (`JSONDecoder`) | Cooperative pool | SAFE |
| Cache read/write | `@MainActor` | SAFE |
| `AIContextBuilder.build()` | Called from `@MainActor` | OK (fast, no I/O) |
| `AISafetyFilter.check()` | Called from `@MainActor` | OK (regex, <1ms) |

No `DispatchQueue.main.async` wrappers needed — `@MainActor` isolation handles this automatically.

---

## Render Performance

### Message List
- `ScrollViewReader` + `scrollTo` on message append — O(1) scroll
- Each `AssistantMessageBubble` is a value-type struct; SwiftUI diffs by identity (`message.id`)
- `AssistantStructuredResponseCard` renders only when `structuredResponses[message.id] != nil`; falls back to `AssistantAnswerSummary` for plain text
- No `GeometryReader` in the message list hot path

### Composer
- `safeAreaInset(edge: .bottom)` — correct safe area handling, no layout conflicts
- Character counter overlay only renders when `inputNearLimit` (>1800 chars) — no per-keystroke layout pass for typical use
- `TextEditor` uses SwiftUI intrinsic sizing with `lineLimit(1...5)`

### Writing Indicator
- `AIWritingIndicator` animates 3 dots via `.task` loop (500ms interval)
- Animation is pure SwiftUI `.scaleEffect` + `.opacity` — compositor-driven, not CPU
- Loop auto-cancels via task cancellation when view disappears

---

## Network Performance

| Parameter | Value |
|-----------|-------|
| Request timeout | 12 seconds |
| Resource timeout | 16 seconds |
| Session type | Ephemeral (no disk cache) |
| `waitsForConnectivity` | `false` (fails fast when offline) |
| Retry policy | None — immediate fallback to local |

Failing fast on connectivity avoids the 30-60s default timeout freeze.

---

## Answer Cache

| Parameter | Value |
|-----------|-------|
| Max entries | 120 |
| TTL | 30 days |
| Frequency threshold | 2 hits before caching |
| Eviction | LRU by `updatedAt` (sort + prefix) |
| Storage | `UserDefaults` (JSON-encoded dict) |
| Key | Normalized question text (lowercased, trimmed) |

**LRU correctness fix (this session):** Previous implementation used `Dictionary.prefix()` which has undefined ordering. Fixed to sort by `updatedAt` descending before taking prefix, ensuring the 120 most-recently-used entries are retained.

---

## Memory

- No `@StateObject` in child views — all state flows from `AIViewModel` via `@ObservedObject`
- `structuredResponses: [UUID: AIResponse]` dictionary in `AIViewModel` holds decoded responses in memory; cleared on view dismissal via `onDisappear`
- Message history capped by `AIViewModel.conversationHistory` array — no explicit cap currently (acceptable for typical session length of 10-30 messages)

---

## Potential Bottlenecks

1. **`AIContextBuilder.assistantHomeContext()`** assembles a large context string synchronously on `@MainActor`. For screens with many checklist items this could add ~1-2ms per request. Acceptable currently; could be moved to background if checklist grows beyond ~200 items.

2. **Cache persistence** uses `UserDefaults` JSON encoding of up to 120 entries. At ~2KB per entry this is ~240KB max. Within UserDefaults limits; no action needed.

3. **`MockAIService` keyword search** iterates all `MockBeginnerGuidesData` entries linearly. At current catalog size (~50 guides) this is fast. Would need indexing if catalog grows beyond ~500 entries.
