# AI Architecture Report
Generated: 2026-06-15

## Overview

The YouNew AI assistant uses a layered, safety-first architecture where the iOS client never calls OpenAI directly. All AI requests route through a backend proxy that injects app knowledge before calling the model.

---

## Component Map

```
AIAssistantView (UI)
    └── AIViewModel (@MainActor, ObservableObject)
            ├── AIService (strategy: local-first or backend)
            │       ├── AIClient (URLSession, 12s timeout, ephemeral session)
            │       ├── MockAIService (local keyword fallback)
            │       └── AIUsageLimiter (20 req/hour, UserDefaults)
            ├── AIResponseParser (validates verified:true + non-empty sources)
            ├── AISafetyFilter (PII detection, blocked terms EN/NL/RU)
            ├── AIContextBuilder (per-screen context + official sources)
            └── Answer cache (LRU, 30-day TTL, 120 entries max)
```

---

## Data Flow

1. User types question → `AIViewModel.sendMessage()`
2. `AISafetyFilter` rejects PII (BSN patterns, passport, medical data)
3. `AIUsageLimiter` checks 20 req/hour quota
4. Cache lookup by normalized question key
5. `AIContextBuilder` assembles screen context + user situation
6. `AIService` selects strategy:
   - Local-first if offline or `shouldPreferLocalResponse`
   - Backend (`AIClient`) with 12s request / 16s resource timeout
   - All errors (including timeout) fall through to `MockAIService`
7. `AIResponseParser` validates `isVerified: true` + non-empty sources
8. `AISafetyFilter` re-scans response for unsafe content
9. Response cached, UI updated on `@MainActor`

---

## Thread Safety

- `AIViewModel` is `@MainActor` — all state mutations happen on the main actor
- `AIClient` network call runs on cooperative thread pool via `async/await`
- No Combine publishers; pure Swift concurrency throughout
- `.task` modifier in SwiftUI views auto-cancels on view disappear (used for AIWritingIndicator animation loop)

---

## State Machine (AIViewModel)

| State | Description |
|-------|-------------|
| `idle` | No active request |
| `loading` | Backend request in flight |
| `localFallback` | Mock response being used |
| `error(String)` | Non-recoverable error shown to user |

Transitions are all on `@MainActor`; no race conditions possible.

---

## Cancellation

- `currentTask: Task<Void, Never>?` is cancelled and replaced on each new `sendMessage()`
- Cancel button in composer sets `isCancelled = true` and calls `currentTask?.cancel()`
- `AIClient` uses `URLSession.data(for:delegate:)` which respects task cancellation

---

## Safety Layers

1. **Input filter** — blocks BSN (8-9 digit patterns), passport, medical record keywords in EN/NL/RU
2. **Usage limit** — 20 requests/hour prevents abuse; resets hourly via `UserDefaults` timestamp
3. **Response validator** — `AIResponseParser` rejects any response where `verified != true` or `sources` is empty
4. **Fallback sentinel** — `AIResponse.unverifiedAnswer` constant used as comparison guard; display text is localized
5. **Emergency escalation** — `AISafetyRules.emergencyEscalation` message always shown for life-safety keywords
6. **Mandatory disclaimer** — appended to every response, fully localized in EN/NL/RU

---

## Known Limitations

- `AINavigatorRoute` quick routes are hardcoded (8 routes); adding new routes requires code change
- Cache key is normalized question text — semantically identical questions with different wording get separate cache entries
- `MockAIService` keyword matching is basic substring search; no semantic similarity

---

## Files

| File | Lines | Role |
|------|-------|------|
| `ViewModels/AIViewModel.swift` | 572 | Central state + orchestration |
| `Views/AIAssistantView.swift` | 1749 | Full UI (composer, messages, navigator) |
| `Services/AIService.swift` | 113 | Strategy selection |
| `Services/AIClient.swift` | 157 | HTTP transport |
| `Services/AIContextBuilder.swift` | 892 | Per-screen context assembly |
| `Services/AISafetyRules.swift` | 142 | Blocked terms, prompts, disclaimers |
| `Models/AIContext.swift` | 170 | Response/context data models |
| `Models/AppDestination.swift` | 303 | Navigation route table (20 AI routes) |
| `Models/AINavigatorRoute.swift` | 148 | 8 quick navigator routes |
| `YouNewTests/AIFoundationTests.swift` | 461 | 30+ unit tests |
| `YouNewTests/AINavigatorRouteTests.swift` | 211 | 22 navigator route tests |
