# AI Critical Fix Report

Date: 2026-06-16

## Status

AI Assistant critical fixes are implemented and the Xcode project builds successfully.

## P0 Fixes

### Duplicate Answer Rendering

Root cause:
- Assistant messages were appended as independent rows with no ownership link to the user question.
- Every response path could append another assistant card for the same question.
- Structured response state was keyed only by assistant message ID, so stale duplicated assistant messages could keep rendering old cards.

Fix:
- Added `AIMessage.replyToMessageID`.
- `AIConversation.appendUser` and `appendAssistant` now return the created message.
- `AIViewModel` now captures the user message ID for each request and upserts the assistant reply through one path.
- Before writing a reply, existing assistant replies for that user message are removed and their structured response state is cleared.

Verification:
- One user question now owns one assistant answer.
- Cache, workflow, local composer, and remote response paths all use the same reply ownership.

### Composer Overlay

Root cause:
- The Assistant screen used `safeAreaInset`, but also reserved bottom space using a fixed composer estimate.
- The fixed estimate did not reliably match dynamic text/composer growth or the floating tab bar.

Fix:
- Added measured composer height via a SwiftUI preference key.
- Scroll bottom padding now equals measured composer height plus tab bar height, tab bar bottom offset, safe area, and a small breathing gap.
- Composer remains in `safeAreaInset(edge: .bottom)` and is not overlay-based.

Verification:
- No manual offset is used for the composer.
- Scroll content receives deterministic bottom clearance.

### Floating AI Button

Root cause:
- The root contextual AI launcher continued rendering above the Assistant tab and could cover answer cards.

Fix:
- `RootTabView.shouldShowContextualAIButton` now hides the contextual launcher when `selectedTab == .assistant`.

Verification:
- Assistant answer content is no longer covered by the floating AI launcher.

### Wrong Answer Mapping

Root cause:
- Verified local data existed, but response safety could strip structured action metadata from local/remote verified responses.
- The mapping path needed verification for short topic queries.

Fix:
- `AISafetyFilter.enforceResponseSafety` now preserves `quickActions`, `sections`, `nextStep`, `appDestinationID`, `isVerified`, and `cacheKey`.

Verification:
- Xcode snippet result:
  - `BSN` returns a verified BSN answer.
  - `transport` returns a verified transport answer.
  - `housing` returns a verified housing answer.

## P1 Fixes

### Source Rendering

Fix:
- Replaced raw URL display with a verified source card containing:
  - Title
  - Source/institution
  - Last checked
  - Open Source button

### Message Layout

Fix:
- Removed reliance on fixed composer estimate.
- Source card text uses wrapping instead of raw URL labels.
- Structured answer sections already use vertical fixed sizing and no card height cap.

## Build

Result:
- `BuildProject` completed successfully.

