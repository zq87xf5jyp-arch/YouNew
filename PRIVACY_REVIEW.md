# PRIVACY_REVIEW

Date: 2026-06-11  
Scope: Pre-TestFlight privacy blockers only. Static code inspection performed.

## Verdict

Status: ACCEPTABLE FOR TESTFLIGHT WITH DISCLOSURE CHECKS

No hidden analytics SDK, tracking SDK, IDFA access, or obvious background data collection was found. The main privacy risk is AI conversation handling: user messages can be stored locally and, when a backend URL is configured, sent to the configured AI proxy.

## Privacy Manifest

`YouNew/PrivacyInfo.xcprivacy` exists and declares:

- `NSPrivacyTracking = false`
- no tracking domains
- no collected data types
- required reason API use:
  - UserDefaults: `CA92.1`
  - File timestamp: `C617.1`

Reference: `YouNew/PrivacyInfo.xcprivacy:5-29`

## Tracking And Analytics

Static search found no app code references to:

- Firebase
- Crashlytics
- Sentry
- Amplitude
- Mixpanel
- AppsFlyer
- IDFA / advertising identifier
- App Tracking Transparency APIs

Result: no hidden analytics or tracking blocker found.

## Location

`LocationService` requests When In Use permission and keeps location in memory through a published property. Accuracy is set to `kCLLocationAccuracyHundredMeters`.

Reference: `YouNew/Services/LocationService.swift:5-60`

No static evidence was found that precise location is stored permanently or sent to a third party.

## Local Storage

The app uses UserDefaults for app state and user convenience data. Notable examples:

- AI conversation storage key: `ai.conversation.v1`
- app language
- saved items
- AI usage-limiter timestamps

AI conversation persistence is implemented in `YouNew/ViewModels/AIViewModel.swift:42` and `YouNew/ViewModels/AIViewModel.swift:345-357`.

Risk: if a tester enters sensitive content that the safety filter does not catch, it can be stored locally in UserDefaults. This is acceptable for TestFlight only if testers are warned and Settings provides a clear reset/delete path.

## AI Backend Transmission

`AIClient` reads `YOUNEW_AI_PROXY_URL` from the app bundle. If configured, user messages, context, and conversation history are sent to that endpoint. If missing, `AIService` falls back to `MockAIService`.

References:

- `YouNew/Services/AIClient.swift:68-74`
- `YouNew/Services/AIService.swift:35-44`

TestFlight requirement: App Store Connect privacy labels, beta notes, and the privacy policy must match the actual backend behavior. If the AI proxy receives user-entered content, that must be disclosed.

## Debug Logs

Image loader, media registry, and AI safety debug prints found in the scan are gated behind `#if DEBUG`. The runtime image debug overlay is also DEBUG-only.

References:

- `YouNew/Components/ImageLoader.swift:140-159`
- `YouNew/Data/CanonicalPlaceImageResolver.swift:81-238`
- `YouNew/Views/ProvinceDirectoryView.swift:3994-3998`
- `YouNew/Components/ImageLoader.swift:348-368`

No release-mode debug logging blocker was found.

## Network URL Privacy

Map place and direction launch URLs now use `https://maps.apple.com` in `YouNew/ViewModels/MapViewModel.swift`, and `scripts/url-source-safety-static-qa.py` rejects shipping Swift references to `http://maps.apple.com`.

## Privacy Blockers

No absolute privacy blocker was found for a controlled TestFlight beta.

Conditional blockers:

1. If external testers can use the AI proxy, privacy labels and beta notes must disclose that user-entered AI content may be sent to the configured backend.
2. If the app is marketed as having real translation/OCR, the mock providers must be labeled or disabled to avoid misleading testers.
