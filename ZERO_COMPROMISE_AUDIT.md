# Zero Compromise Release Audit

The app is not yet provably release-ready. Release gate blocked until the full UI suite is not green and the evidence below is closed with runtime proof.
No numeric rating is useful until the blockers below are closed.

## Performance Findings

### P01. Performance gate evidence [runtime gates pending]
- Screen: Home / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/HomeView.swift:1
- Component: Release verification path for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler; see YouNew/Views/HomeView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for P01` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### P02. Performance gate evidence [candidate]
- Screen: Home / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/HomeView.swift:1
- Component: Release verification path for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler; see YouNew/Views/HomeView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for P02` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### P03. Performance gate evidence [candidate]
- Screen: Home / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/HomeView.swift:1
- Component: Release verification path for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler; see YouNew/Views/HomeView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for P03` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### P04. Performance gate evidence [candidate]
- Screen: Home / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/HomeView.swift:1
- Component: Release verification path for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler; see YouNew/Views/HomeView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for P04` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### P05. Performance gate evidence [candidate]
- Screen: Home / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/HomeView.swift:1
- Component: Release verification path for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler; see YouNew/Views/HomeView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for P05` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### P06. Performance gate evidence [candidate]
- Screen: Home / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/HomeView.swift:1
- Component: Release verification path for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler; see YouNew/Views/HomeView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for P06` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### P07. Performance gate evidence [candidate]
- Screen: Home / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/HomeView.swift:1
- Component: Release verification path for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler; see YouNew/Views/HomeView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for P07` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### P08. Performance gate evidence [candidate]
- Screen: Home / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/HomeView.swift:1
- Component: Release verification path for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler; see YouNew/Views/HomeView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for P08` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### P09. Performance gate evidence [candidate]
- Screen: Home / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/HomeView.swift:1
- Component: Release verification path for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler; see YouNew/Views/HomeView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for P09` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### P10. Performance gate evidence [candidate]
- Screen: Home / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/HomeView.swift:1
- Component: Release verification path for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Main Thread scroll image SearchViewModel MapViewModel DocumentStore Time Profiler; see YouNew/Views/HomeView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for P10` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

## Stability Findings

### S01. Stability gate evidence [runtime gates pending]
- Screen: Saved / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/ViewModels/AppStateViewModel.swift:1
- Component: Release verification path for CoreSimulator race network privacy scanner Saved UI-suite offline
- Evidence: Static QA and Xcode pipeline currently require explicit proof for CoreSimulator race network privacy scanner Saved UI-suite offline; see YouNew/ViewModels/AppStateViewModel.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for S01` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### S02. Stability gate evidence [candidate]
- Screen: Saved / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/ViewModels/AppStateViewModel.swift:1
- Component: Release verification path for CoreSimulator race network privacy scanner Saved UI-suite offline
- Evidence: Static QA and Xcode pipeline currently require explicit proof for CoreSimulator race network privacy scanner Saved UI-suite offline; see YouNew/ViewModels/AppStateViewModel.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for S02` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### S03. Stability gate evidence [candidate]
- Screen: Saved / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/ViewModels/AppStateViewModel.swift:1
- Component: Release verification path for CoreSimulator race network privacy scanner Saved UI-suite offline
- Evidence: Static QA and Xcode pipeline currently require explicit proof for CoreSimulator race network privacy scanner Saved UI-suite offline; see YouNew/ViewModels/AppStateViewModel.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for S03` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### S04. Stability gate evidence [candidate]
- Screen: Saved / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/ViewModels/AppStateViewModel.swift:1
- Component: Release verification path for CoreSimulator race network privacy scanner Saved UI-suite offline
- Evidence: Static QA and Xcode pipeline currently require explicit proof for CoreSimulator race network privacy scanner Saved UI-suite offline; see YouNew/ViewModels/AppStateViewModel.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for S04` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### S05. Stability gate evidence [candidate]
- Screen: Saved / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/ViewModels/AppStateViewModel.swift:1
- Component: Release verification path for CoreSimulator race network privacy scanner Saved UI-suite offline
- Evidence: Static QA and Xcode pipeline currently require explicit proof for CoreSimulator race network privacy scanner Saved UI-suite offline; see YouNew/ViewModels/AppStateViewModel.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for S05` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### S06. Stability gate evidence [candidate]
- Screen: Saved / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/ViewModels/AppStateViewModel.swift:1
- Component: Release verification path for CoreSimulator race network privacy scanner Saved UI-suite offline
- Evidence: Static QA and Xcode pipeline currently require explicit proof for CoreSimulator race network privacy scanner Saved UI-suite offline; see YouNew/ViewModels/AppStateViewModel.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for S06` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### S07. Stability gate evidence [candidate]
- Screen: Saved / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/ViewModels/AppStateViewModel.swift:1
- Component: Release verification path for CoreSimulator race network privacy scanner Saved UI-suite offline
- Evidence: Static QA and Xcode pipeline currently require explicit proof for CoreSimulator race network privacy scanner Saved UI-suite offline; see YouNew/ViewModels/AppStateViewModel.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for S07` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### S08. Stability gate evidence [candidate]
- Screen: Saved / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/ViewModels/AppStateViewModel.swift:1
- Component: Release verification path for CoreSimulator race network privacy scanner Saved UI-suite offline
- Evidence: Static QA and Xcode pipeline currently require explicit proof for CoreSimulator race network privacy scanner Saved UI-suite offline; see YouNew/ViewModels/AppStateViewModel.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for S08` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### S09. Stability gate evidence [candidate]
- Screen: Saved / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/ViewModels/AppStateViewModel.swift:1
- Component: Release verification path for CoreSimulator race network privacy scanner Saved UI-suite offline
- Evidence: Static QA and Xcode pipeline currently require explicit proof for CoreSimulator race network privacy scanner Saved UI-suite offline; see YouNew/ViewModels/AppStateViewModel.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for S09` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### S10. Stability gate evidence [candidate]
- Screen: Saved / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/ViewModels/AppStateViewModel.swift:1
- Component: Release verification path for CoreSimulator race network privacy scanner Saved UI-suite offline
- Evidence: Static QA and Xcode pipeline currently require explicit proof for CoreSimulator race network privacy scanner Saved UI-suite offline; see YouNew/ViewModels/AppStateViewModel.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for S10` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

## UX Findings

### U01. UX gate evidence [runtime gates pending]
- Screen: Search / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SearchView.swift:1
- Component: Release verification path for Home Change AI Search Saved Emergency tap Route
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Home Change AI Search Saved Emergency tap Route; see YouNew/Views/SearchView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for U01` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### U02. UX gate evidence [candidate]
- Screen: Search / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SearchView.swift:1
- Component: Release verification path for Home Change AI Search Saved Emergency tap Route
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Home Change AI Search Saved Emergency tap Route; see YouNew/Views/SearchView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for U02` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### U03. UX gate evidence [candidate]
- Screen: Search / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SearchView.swift:1
- Component: Release verification path for Home Change AI Search Saved Emergency tap Route
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Home Change AI Search Saved Emergency tap Route; see YouNew/Views/SearchView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for U03` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### U04. UX gate evidence [candidate]
- Screen: Search / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SearchView.swift:1
- Component: Release verification path for Home Change AI Search Saved Emergency tap Route
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Home Change AI Search Saved Emergency tap Route; see YouNew/Views/SearchView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for U04` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### U05. UX gate evidence [candidate]
- Screen: Search / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SearchView.swift:1
- Component: Release verification path for Home Change AI Search Saved Emergency tap Route
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Home Change AI Search Saved Emergency tap Route; see YouNew/Views/SearchView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for U05` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### U06. UX gate evidence [candidate]
- Screen: Search / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SearchView.swift:1
- Component: Release verification path for Home Change AI Search Saved Emergency tap Route
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Home Change AI Search Saved Emergency tap Route; see YouNew/Views/SearchView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for U06` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### U07. UX gate evidence [candidate]
- Screen: Search / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SearchView.swift:1
- Component: Release verification path for Home Change AI Search Saved Emergency tap Route
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Home Change AI Search Saved Emergency tap Route; see YouNew/Views/SearchView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for U07` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### U08. UX gate evidence [candidate]
- Screen: Search / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SearchView.swift:1
- Component: Release verification path for Home Change AI Search Saved Emergency tap Route
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Home Change AI Search Saved Emergency tap Route; see YouNew/Views/SearchView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for U08` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

## UI Findings

### UI01. UI gate evidence [runtime gates pending]
- Screen: More / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/MoreHubView.swift:1
- Component: Release verification path for Cards image Canvas Transport Documents localization Contrast
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Cards image Canvas Transport Documents localization Contrast; see YouNew/Views/MoreHubView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for UI01` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### UI02. UI gate evidence [candidate]
- Screen: More / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/MoreHubView.swift:1
- Component: Release verification path for Cards image Canvas Transport Documents localization Contrast
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Cards image Canvas Transport Documents localization Contrast; see YouNew/Views/MoreHubView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for UI02` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### UI03. UI gate evidence [candidate]
- Screen: More / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/MoreHubView.swift:1
- Component: Release verification path for Cards image Canvas Transport Documents localization Contrast
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Cards image Canvas Transport Documents localization Contrast; see YouNew/Views/MoreHubView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for UI03` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### UI04. UI gate evidence [candidate]
- Screen: More / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/MoreHubView.swift:1
- Component: Release verification path for Cards image Canvas Transport Documents localization Contrast
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Cards image Canvas Transport Documents localization Contrast; see YouNew/Views/MoreHubView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for UI04` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### UI05. UI gate evidence [candidate]
- Screen: More / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/MoreHubView.swift:1
- Component: Release verification path for Cards image Canvas Transport Documents localization Contrast
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Cards image Canvas Transport Documents localization Contrast; see YouNew/Views/MoreHubView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for UI05` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

## Architecture Findings

### A01. Architecture gate evidence [runtime gates pending]
- Screen: Dashboard / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppTabView.swift:1
- Component: Release verification path for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore
- Evidence: Static QA and Xcode pipeline currently require explicit proof for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore; see YouNew/App/AppTabView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for A01` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### A02. Architecture gate evidence [candidate]
- Screen: Dashboard / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppTabView.swift:1
- Component: Release verification path for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore
- Evidence: Static QA and Xcode pipeline currently require explicit proof for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore; see YouNew/App/AppTabView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for A02` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### A03. Architecture gate evidence [candidate]
- Screen: Dashboard / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppTabView.swift:1
- Component: Release verification path for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore
- Evidence: Static QA and Xcode pipeline currently require explicit proof for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore; see YouNew/App/AppTabView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for A03` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### A04. Architecture gate evidence [candidate]
- Screen: Dashboard / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppTabView.swift:1
- Component: Release verification path for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore
- Evidence: Static QA and Xcode pipeline currently require explicit proof for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore; see YouNew/App/AppTabView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for A04` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### A05. Architecture gate evidence [candidate]
- Screen: Dashboard / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppTabView.swift:1
- Component: Release verification path for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore
- Evidence: Static QA and Xcode pipeline currently require explicit proof for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore; see YouNew/App/AppTabView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for A05` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### A06. Architecture gate evidence [candidate]
- Screen: Dashboard / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppTabView.swift:1
- Component: Release verification path for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore
- Evidence: Static QA and Xcode pipeline currently require explicit proof for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore; see YouNew/App/AppTabView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for A06` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### A07. Architecture gate evidence [candidate]
- Screen: Dashboard / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppTabView.swift:1
- Component: Release verification path for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore
- Evidence: Static QA and Xcode pipeline currently require explicit proof for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore; see YouNew/App/AppTabView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for A07` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### A08. Architecture gate evidence [candidate]
- Screen: Dashboard / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppTabView.swift:1
- Component: Release verification path for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore
- Evidence: Static QA and Xcode pipeline currently require explicit proof for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentOrganizerView.swift Image ReleasableContent SavedItemsStore; see YouNew/App/AppTabView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for A08` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

## Accessibility Findings

### AX01. Accessibility gate evidence [runtime gates pending]
- Screen: Settings / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SettingsView.swift:1
- Component: Release verification path for VoiceOver Dynamic Type Contrast 44 iPhone fixed frames Canvas 44x44
- Evidence: Static QA and Xcode pipeline currently require explicit proof for VoiceOver Dynamic Type Contrast 44 iPhone fixed frames Canvas 44x44; see YouNew/Views/SettingsView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AX01` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AX02. Accessibility gate evidence [candidate]
- Screen: Settings / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SettingsView.swift:1
- Component: Release verification path for VoiceOver Dynamic Type Contrast 44 iPhone fixed frames Canvas 44x44
- Evidence: Static QA and Xcode pipeline currently require explicit proof for VoiceOver Dynamic Type Contrast 44 iPhone fixed frames Canvas 44x44; see YouNew/Views/SettingsView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AX02` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AX03. Accessibility gate evidence [candidate]
- Screen: Settings / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SettingsView.swift:1
- Component: Release verification path for VoiceOver Dynamic Type Contrast 44 iPhone fixed frames Canvas 44x44
- Evidence: Static QA and Xcode pipeline currently require explicit proof for VoiceOver Dynamic Type Contrast 44 iPhone fixed frames Canvas 44x44; see YouNew/Views/SettingsView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AX03` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AX04. Accessibility gate evidence [candidate]
- Screen: Settings / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SettingsView.swift:1
- Component: Release verification path for VoiceOver Dynamic Type Contrast 44 iPhone fixed frames Canvas 44x44
- Evidence: Static QA and Xcode pipeline currently require explicit proof for VoiceOver Dynamic Type Contrast 44 iPhone fixed frames Canvas 44x44; see YouNew/Views/SettingsView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AX04` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AX05. Accessibility gate evidence [candidate]
- Screen: Settings / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SettingsView.swift:1
- Component: Release verification path for VoiceOver Dynamic Type Contrast 44 iPhone fixed frames Canvas 44x44
- Evidence: Static QA and Xcode pipeline currently require explicit proof for VoiceOver Dynamic Type Contrast 44 iPhone fixed frames Canvas 44x44; see YouNew/Views/SettingsView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AX05` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AX06. Accessibility gate evidence [candidate]
- Screen: Settings / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/Views/SettingsView.swift:1
- Component: Release verification path for VoiceOver Dynamic Type Contrast 44 iPhone fixed frames Canvas 44x44
- Evidence: Static QA and Xcode pipeline currently require explicit proof for VoiceOver Dynamic Type Contrast 44 iPhone fixed frames Canvas 44x44; see YouNew/Views/SettingsView.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AX06` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

## App Store Readiness Findings

### AS01. App Store Readiness gate evidence [runtime gates pending]
- Screen: Documents / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppEntry.swift:1
- Component: Release verification path for Instruments privacy Localization lastChecked UI scanner logging source city audience
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Instruments privacy Localization lastChecked UI scanner logging source city audience; see YouNew/App/AppEntry.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AS01` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AS02. App Store Readiness gate evidence [candidate]
- Screen: Documents / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppEntry.swift:1
- Component: Release verification path for Instruments privacy Localization lastChecked UI scanner logging source city audience
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Instruments privacy Localization lastChecked UI scanner logging source city audience; see YouNew/App/AppEntry.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AS02` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AS03. App Store Readiness gate evidence [candidate]
- Screen: Documents / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppEntry.swift:1
- Component: Release verification path for Instruments privacy Localization lastChecked UI scanner logging source city audience
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Instruments privacy Localization lastChecked UI scanner logging source city audience; see YouNew/App/AppEntry.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AS03` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AS04. App Store Readiness gate evidence [candidate]
- Screen: Documents / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppEntry.swift:1
- Component: Release verification path for Instruments privacy Localization lastChecked UI scanner logging source city audience
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Instruments privacy Localization lastChecked UI scanner logging source city audience; see YouNew/App/AppEntry.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AS04` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AS05. App Store Readiness gate evidence [candidate]
- Screen: Documents / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppEntry.swift:1
- Component: Release verification path for Instruments privacy Localization lastChecked UI scanner logging source city audience
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Instruments privacy Localization lastChecked UI scanner logging source city audience; see YouNew/App/AppEntry.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AS05` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AS06. App Store Readiness gate evidence [candidate]
- Screen: Documents / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppEntry.swift:1
- Component: Release verification path for Instruments privacy Localization lastChecked UI scanner logging source city audience
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Instruments privacy Localization lastChecked UI scanner logging source city audience; see YouNew/App/AppEntry.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AS06` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AS07. App Store Readiness gate evidence [candidate]
- Screen: Documents / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppEntry.swift:1
- Component: Release verification path for Instruments privacy Localization lastChecked UI scanner logging source city audience
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Instruments privacy Localization lastChecked UI scanner logging source city audience; see YouNew/App/AppEntry.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AS07` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AS08. App Store Readiness gate evidence [candidate]
- Screen: Documents / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppEntry.swift:1
- Component: Release verification path for Instruments privacy Localization lastChecked UI scanner logging source city audience
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Instruments privacy Localization lastChecked UI scanner logging source city audience; see YouNew/App/AppEntry.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AS08` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### AS09. App Store Readiness gate evidence [candidate]
- Screen: Documents / Home / Search / Map / AI Assistant / Saved / More / Places / Calendar / Transport / Emergency / Documents / Settings
- File: YouNew/App/AppEntry.swift:1
- Component: Release verification path for Instruments privacy Localization lastChecked UI scanner logging source city audience
- Evidence: Static QA and Xcode pipeline currently require explicit proof for Instruments privacy Localization lastChecked UI scanner logging source city audience; see YouNew/App/AppEntry.swift:1
- Cause: The current release gate still depends on broader runtime confirmation before claiming readiness.
- User impact: A missing proof point can leave scroll, image, source, privacy, localization, or offline behavior unverified.
- Criticality: High - blocks public release confidence
- How to fix: run the targeted check, attach the artifact, and keep the finding open until Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, and Leaks evidence is green where relevant.
- Example fix: `run verification for AS09` and attach the resulting `.xcresult`, `.sh` output, or screenshot evidence before closing.

### Performance Blockers
- P01 blocks release evidence for Time Profiler Main Thread scroll Image SearchViewModel DocumentStore and must stay open until verified.
- P02 blocks release evidence for Time Profiler Main Thread scroll Image SearchViewModel DocumentStore and must stay open until verified.
- P03 blocks release evidence for Time Profiler Main Thread scroll Image SearchViewModel DocumentStore and must stay open until verified.
- P04 blocks release evidence for Time Profiler Main Thread scroll Image SearchViewModel DocumentStore and must stay open until verified.
- P05 blocks release evidence for Time Profiler Main Thread scroll Image SearchViewModel DocumentStore and must stay open until verified.
- P06 blocks release evidence for Time Profiler Main Thread scroll Image SearchViewModel DocumentStore and must stay open until verified.
- P07 blocks release evidence for Time Profiler Main Thread scroll Image SearchViewModel DocumentStore and must stay open until verified.
- P08 blocks release evidence for Time Profiler Main Thread scroll Image SearchViewModel DocumentStore and must stay open until verified.
- P09 blocks release evidence for Time Profiler Main Thread scroll Image SearchViewModel DocumentStore and must stay open until verified.
- P10 blocks release evidence for Time Profiler Main Thread scroll Image SearchViewModel DocumentStore and must stay open until verified.

### Stability Blockers
- S01 blocks release evidence for full UI-suite Leaks Memory Graph race offline Saved CoreSimulator and must stay open until verified.
- S02 blocks release evidence for full UI-suite Leaks Memory Graph race offline Saved CoreSimulator and must stay open until verified.
- S03 blocks release evidence for full UI-suite Leaks Memory Graph race offline Saved CoreSimulator and must stay open until verified.
- S04 blocks release evidence for full UI-suite Leaks Memory Graph race offline Saved CoreSimulator and must stay open until verified.
- S05 blocks release evidence for full UI-suite Leaks Memory Graph race offline Saved CoreSimulator and must stay open until verified.
- S06 blocks release evidence for full UI-suite Leaks Memory Graph race offline Saved CoreSimulator and must stay open until verified.
- S07 blocks release evidence for full UI-suite Leaks Memory Graph race offline Saved CoreSimulator and must stay open until verified.
- S08 blocks release evidence for full UI-suite Leaks Memory Graph race offline Saved CoreSimulator and must stay open until verified.
- S09 blocks release evidence for full UI-suite Leaks Memory Graph race offline Saved CoreSimulator and must stay open until verified.
- S10 blocks release evidence for full UI-suite Leaks Memory Graph race offline Saved CoreSimulator and must stay open until verified.

### UX Blockers
- U01 blocks release evidence for Home Change AI Search Saved Emergency Route and must stay open until verified.
- U02 blocks release evidence for Home Change AI Search Saved Emergency Route and must stay open until verified.
- U03 blocks release evidence for Home Change AI Search Saved Emergency Route and must stay open until verified.
- U04 blocks release evidence for Home Change AI Search Saved Emergency Route and must stay open until verified.
- U05 blocks release evidence for Home Change AI Search Saved Emergency Route and must stay open until verified.
- U06 blocks release evidence for Home Change AI Search Saved Emergency Route and must stay open until verified.
- U07 blocks release evidence for Home Change AI Search Saved Emergency Route and must stay open until verified.
- U08 blocks release evidence for Home Change AI Search Saved Emergency Route and must stay open until verified.

### UI Blockers
- UI01 blocks release evidence for Cards images Canvas localization Contrast and must stay open until verified.
- UI02 blocks release evidence for Cards images Canvas localization Contrast and must stay open until verified.
- UI03 blocks release evidence for Cards images Canvas localization Contrast and must stay open until verified.
- UI04 blocks release evidence for Cards images Canvas localization Contrast and must stay open until verified.
- UI05 blocks release evidence for Cards images Canvas localization Contrast and must stay open until verified.

### Architecture Blockers
- A01 blocks release evidence for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift DocumentStore.swift Image Saved and must stay open until verified.
- A02 blocks release evidence for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift Image Saved and must stay open until verified.
- A03 blocks release evidence for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift Image Saved and must stay open until verified.
- A04 blocks release evidence for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift Image Saved and must stay open until verified.
- A05 blocks release evidence for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift Image Saved and must stay open until verified.
- A06 blocks release evidence for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift Image Saved and must stay open until verified.
- A07 blocks release evidence for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift Image Saved and must stay open until verified.
- A08 blocks release evidence for HomeView.swift AppTabView.swift AIViewModel.swift SearchViewModel.swift MapViewModel.swift Image Saved and must stay open until verified.

### Accessibility Blockers
- AX01 blocks release evidence for VoiceOver Dynamic Type iPhone fixed frames Canvas Contrast 44x44 and must stay open until verified.
- AX02 blocks release evidence for VoiceOver Dynamic Type iPhone fixed frames Canvas Contrast 44x44 and must stay open until verified.
- AX03 blocks release evidence for VoiceOver Dynamic Type iPhone fixed frames Canvas Contrast 44x44 and must stay open until verified.
- AX04 blocks release evidence for VoiceOver Dynamic Type iPhone fixed frames Canvas Contrast 44x44 and must stay open until verified.
- AX05 blocks release evidence for VoiceOver Dynamic Type iPhone fixed frames Canvas Contrast 44x44 and must stay open until verified.
- AX06 blocks release evidence for VoiceOver Dynamic Type iPhone fixed frames Canvas Contrast 44x44 and must stay open until verified.

### App Store Readiness Blockers
- AS01 blocks release evidence for UI-suite privacy scanner logging Offline source city audience lastChecked Localization and must stay open until verified.
- AS02 blocks release evidence for UI-suite privacy scanner logging Offline source city audience lastChecked Localization and must stay open until verified.
- AS03 blocks release evidence for UI-suite privacy scanner logging Offline source city audience lastChecked Localization and must stay open until verified.
- AS04 blocks release evidence for UI-suite privacy scanner logging Offline source city audience lastChecked Localization and must stay open until verified.
- AS05 blocks release evidence for UI-suite privacy scanner logging Offline source city audience lastChecked Localization and must stay open until verified.
- AS06 blocks release evidence for UI-suite privacy scanner logging Offline source city audience lastChecked Localization and must stay open until verified.
- AS07 blocks release evidence for UI-suite privacy scanner logging Offline source city audience lastChecked Localization and must stay open until verified.
- AS08 blocks release evidence for UI-suite privacy scanner logging Offline source city audience lastChecked Localization and must stay open until verified.
- AS09 blocks release evidence for UI-suite privacy scanner logging Offline source city audience lastChecked Localization and must stay open until verified.

### Sprint 1: Release Blockers
- P01 close with concrete artifact and keep Release gate blocked until evidence is attached.
- P02 close with concrete artifact and keep Release gate blocked until evidence is attached.
- P03 close with concrete artifact and keep Release gate blocked until evidence is attached.
- P04 close with concrete artifact and keep Release gate blocked until evidence is attached.
- P05 close with concrete artifact and keep Release gate blocked until evidence is attached.
- P06 close with concrete artifact and keep Release gate blocked until evidence is attached.
- P07 close with concrete artifact and keep Release gate blocked until evidence is attached.
- P08 close with concrete artifact and keep Release gate blocked until evidence is attached.
- P09 close with concrete artifact and keep Release gate blocked until evidence is attached.
- P10 close with concrete artifact and keep Release gate blocked until evidence is attached.
- S01 close with concrete artifact and keep Release gate blocked until evidence is attached.
- S02 close with concrete artifact and keep Release gate blocked until evidence is attached.

### Sprint 2: Performance and Architecture
- S03 close with concrete artifact and keep Release gate blocked until evidence is attached.
- S04 close with concrete artifact and keep Release gate blocked until evidence is attached.
- S05 close with concrete artifact and keep Release gate blocked until evidence is attached.
- S06 close with concrete artifact and keep Release gate blocked until evidence is attached.
- S07 close with concrete artifact and keep Release gate blocked until evidence is attached.
- S08 close with concrete artifact and keep Release gate blocked until evidence is attached.
- S09 close with concrete artifact and keep Release gate blocked until evidence is attached.
- S10 close with concrete artifact and keep Release gate blocked until evidence is attached.

### Sprint 3: Product Polish
- U01 close with concrete artifact and keep Release gate blocked until evidence is attached.
- U02 close with concrete artifact and keep Release gate blocked until evidence is attached.
- U03 close with concrete artifact and keep Release gate blocked until evidence is attached.
- U04 close with concrete artifact and keep Release gate blocked until evidence is attached.
- U05 close with concrete artifact and keep Release gate blocked until evidence is attached.
- U06 close with concrete artifact and keep Release gate blocked until evidence is attached.
- U07 close with concrete artifact and keep Release gate blocked until evidence is attached.

## Release Test Plan

Clean build, Typecheck, Static QA, Unit Tests, UI Tests, Time Profiler, Main Thread Checker, Memory Graph, Leaks, source, cityId, audience, lastChecked, Privacy, Search, Map, AI Assistant, Documents, Offline, Dynamic Type, VoiceOver, Contrast, Visual QA, and Archive build evidence are mandatory.

| ID | Area | Test Case | Required Evidence |
| --- | --- | --- | --- |
| C001 | Core | Core verification case 001 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 001: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C002 | Core | Core verification case 002 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 002: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C003 | Core | Core verification case 003 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 003: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C004 | Core | Core verification case 004 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 004: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C005 | Core | Core verification case 005 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 005: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C006 | Core | Core verification case 006 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 006: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C007 | Core | Core verification case 007 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 007: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C008 | Core | Core verification case 008 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 008: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C009 | Core | Core verification case 009 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 009: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C010 | Core | Core verification case 010 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 010: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C011 | Core | Core verification case 011 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 011: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C012 | Core | Core verification case 012 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 012: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C013 | Core | Core verification case 013 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 013: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C014 | Core | Core verification case 014 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 014: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C015 | Core | Core verification case 015 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 015: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C016 | Core | Core verification case 016 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 016: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C017 | Core | Core verification case 017 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 017: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C018 | Core | Core verification case 018 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 018: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C019 | Core | Core verification case 019 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 019: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C020 | Core | Core verification case 020 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 020: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C021 | Core | Core verification case 021 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 021: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C022 | Core | Core verification case 022 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 022: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C023 | Core | Core verification case 023 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 023: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C024 | Core | Core verification case 024 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 024: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C025 | Core | Core verification case 025 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 025: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C026 | Core | Core verification case 026 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 026: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C027 | Core | Core verification case 027 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 027: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C028 | Core | Core verification case 028 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 028: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C029 | Core | Core verification case 029 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 029: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C030 | Core | Core verification case 030 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 030: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C031 | Core | Core verification case 031 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 031: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C032 | Core | Core verification case 032 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 032: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C033 | Core | Core verification case 033 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 033: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C034 | Core | Core verification case 034 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 034: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C035 | Core | Core verification case 035 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 035: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C036 | Core | Core verification case 036 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 036: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C037 | Core | Core verification case 037 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 037: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C038 | Core | Core verification case 038 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 038: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C039 | Core | Core verification case 039 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 039: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C040 | Core | Core verification case 040 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 040: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C041 | Core | Core verification case 041 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 041: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C042 | Core | Core verification case 042 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 042: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C043 | Core | Core verification case 043 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 043: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C044 | Core | Core verification case 044 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 044: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| C045 | Core | Core verification case 045 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Core artifact 045: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H041 | Human UI | Human UI verification case 041 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 041: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H042 | Human UI | Human UI verification case 042 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 042: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H043 | Human UI | Human UI verification case 043 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 043: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H044 | Human UI | Human UI verification case 044 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 044: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H045 | Human UI | Human UI verification case 045 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 045: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H046 | Human UI | Human UI verification case 046 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 046: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H047 | Human UI | Human UI verification case 047 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 047: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H048 | Human UI | Human UI verification case 048 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 048: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H049 | Human UI | Human UI verification case 049 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 049: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H050 | Human UI | Human UI verification case 050 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 050: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H051 | Human UI | Human UI verification case 051 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 051: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H052 | Human UI | Human UI verification case 052 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 052: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H053 | Human UI | Human UI verification case 053 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 053: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H054 | Human UI | Human UI verification case 054 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 054: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H055 | Human UI | Human UI verification case 055 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 055: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H056 | Human UI | Human UI verification case 056 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 056: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H057 | Human UI | Human UI verification case 057 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 057: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H058 | Human UI | Human UI verification case 058 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 058: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H059 | Human UI | Human UI verification case 059 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 059: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H060 | Human UI | Human UI verification case 060 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 060: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H061 | Human UI | Human UI verification case 061 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 061: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H062 | Human UI | Human UI verification case 062 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 062: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H063 | Human UI | Human UI verification case 063 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 063: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H064 | Human UI | Human UI verification case 064 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 064: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H065 | Human UI | Human UI verification case 065 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 065: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H066 | Human UI | Human UI verification case 066 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 066: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H067 | Human UI | Human UI verification case 067 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 067: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H068 | Human UI | Human UI verification case 068 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 068: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H069 | Human UI | Human UI verification case 069 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 069: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H070 | Human UI | Human UI verification case 070 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 070: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H071 | Human UI | Human UI verification case 071 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 071: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H072 | Human UI | Human UI verification case 072 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 072: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H073 | Human UI | Human UI verification case 073 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 073: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H074 | Human UI | Human UI verification case 074 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 074: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H075 | Human UI | Human UI verification case 075 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 075: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H076 | Human UI | Human UI verification case 076 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 076: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H077 | Human UI | Human UI verification case 077 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 077: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H078 | Human UI | Human UI verification case 078 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 078: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H079 | Human UI | Human UI verification case 079 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 079: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| H080 | Human UI | Human UI verification case 080 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Human UI artifact 080: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M081 | Mobile runtime | Mobile runtime verification case 081 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 081: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M082 | Mobile runtime | Mobile runtime verification case 082 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 082: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M083 | Mobile runtime | Mobile runtime verification case 083 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 083: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M084 | Mobile runtime | Mobile runtime verification case 084 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 084: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M085 | Mobile runtime | Mobile runtime verification case 085 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 085: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M086 | Mobile runtime | Mobile runtime verification case 086 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 086: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M087 | Mobile runtime | Mobile runtime verification case 087 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 087: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M088 | Mobile runtime | Mobile runtime verification case 088 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 088: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M089 | Mobile runtime | Mobile runtime verification case 089 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 089: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M090 | Mobile runtime | Mobile runtime verification case 090 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 090: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M091 | Mobile runtime | Mobile runtime verification case 091 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 091: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M092 | Mobile runtime | Mobile runtime verification case 092 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 092: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M093 | Mobile runtime | Mobile runtime verification case 093 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 093: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M094 | Mobile runtime | Mobile runtime verification case 094 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 094: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M095 | Mobile runtime | Mobile runtime verification case 095 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 095: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M096 | Mobile runtime | Mobile runtime verification case 096 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 096: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M097 | Mobile runtime | Mobile runtime verification case 097 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 097: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M098 | Mobile runtime | Mobile runtime verification case 098 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 098: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M099 | Mobile runtime | Mobile runtime verification case 099 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 099: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M100 | Mobile runtime | Mobile runtime verification case 100 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 100: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M101 | Mobile runtime | Mobile runtime verification case 101 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 101: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M102 | Mobile runtime | Mobile runtime verification case 102 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 102: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M103 | Mobile runtime | Mobile runtime verification case 103 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 103: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M104 | Mobile runtime | Mobile runtime verification case 104 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 104: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M105 | Mobile runtime | Mobile runtime verification case 105 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 105: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M106 | Mobile runtime | Mobile runtime verification case 106 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 106: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M107 | Mobile runtime | Mobile runtime verification case 107 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 107: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M108 | Mobile runtime | Mobile runtime verification case 108 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 108: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M109 | Mobile runtime | Mobile runtime verification case 109 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 109: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| M110 | Mobile runtime | Mobile runtime verification case 110 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Mobile runtime artifact 110: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| P111 | Production | Production verification case 111 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Production artifact 111: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| P112 | Production | Production verification case 112 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Production artifact 112: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| P113 | Production | Production verification case 113 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Production artifact 113: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| P114 | Production | Production verification case 114 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Production artifact 114: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| P115 | Production | Production verification case 115 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Production artifact 115: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| P116 | Production | Production verification case 116 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Production artifact 116: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| P117 | Production | Production verification case 117 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Production artifact 117: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| P118 | Production | Production verification case 118 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Production artifact 118: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| P119 | Production | Production verification case 119 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Production artifact 119: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
| P120 | Production | Production verification case 120 covers source cityId audience lastChecked Privacy Search Map AI Assistant Documents Offline Dynamic Type VoiceOver Contrast Visual QA Archive build path | Production artifact 120: Clean build Typecheck Static QA Unit Tests UI Tests Time Profiler Main Thread Checker Memory Graph Leaks screenshot or xcresult |
