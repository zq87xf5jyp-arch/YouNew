# AI_DISCLOSURE_REPORT

Date: 2026-06-11  
Scope: final pre-TestFlight blocker pass.

Reference: Apple App Privacy Details, https://developer.apple.com/app-store/app-privacy-details/

## Is AI Used?

Yes.

The app includes an AI Assistant path:

- `AIViewModel` sends user messages through `AIService`.
- `AIService` calls `AIClient` when a backend endpoint is configured.
- `AIService` falls back to `MockAIService` when the backend endpoint is not configured.
- Translation and OCR helper protocols currently use local mock providers.

Relevant files:

- `YouNew/ViewModels/AIViewModel.swift`
- `YouNew/Services/AIService.swift`
- `YouNew/Services/AIClient.swift`
- `YouNew/Services/MockAIService.swift`
- `YouNew/Services/AIAssistanceProtocols.swift`

## Which Provider?

Provider is not hardcoded in the iOS app.

The app reads `YOUNEW_AI_PROXY_URL` from the bundle and posts to that endpoint if present. No direct OpenAI, Anthropic, Gemini, Firebase, Sentry, Crashlytics, Amplitude, Mixpanel, AppsFlyer, IDFA, or App Tracking Transparency integration was found in the local iOS code scan.

Disclosure wording should therefore say:

> The AI Assistant uses a YouNew-controlled AI proxy when configured. The proxy may process user-entered messages to generate assistant responses.

If the proxy forwards requests to a third-party model provider, the Privacy Policy must name that provider or describe it as an AI processing provider, depending on the final legal policy wording.

## What Data Leaves The Device?

When `YOUNEW_AI_PROXY_URL` is configured, this request body can leave the device:

- user message, trimmed to the first 2,000 characters
- current AI context
- last 12 conversation messages
- system prompt / safety rules

The AI context can include:

- current screen/category
- topic title and summary
- official source titles, URLs, and institutions
- app language
- user situation/status label
- selected city
- selected province
- up to 8 saved item titles
- safety disclaimer

Local-only storage:

- AI conversation is stored in UserDefaults under `ai.conversation.v1`.
- AI usage limiter timestamps are stored locally under `ai.usageLimiter.timestamps.v1`.
- Translation recent history is stored locally under `recent_translations_v1`.

Not found in the AI request path:

- precise GPS location
- advertising identifier
- contact list
- photos
- health records
- payment data
- hidden analytics identifiers

## What Must Be Disclosed In Privacy Policy?

The Privacy Policy should disclose:

- AI Assistant is available in the app.
- User-entered AI messages may be sent to a configured YouNew AI proxy.
- The request may include recent conversation messages and app context such as language, selected city/province, topic, official source links, user situation label, and saved item titles.
- AI conversation history may be stored locally on the device and can be cleared from the app.
- The AI Assistant is informational only and does not replace official government, legal, medical, immigration, tax, or emergency advice.
- If the backend proxy uses a third-party AI provider, that provider/process must be disclosed.
- If the backend stores logs, retention period and deletion/contact process must be disclosed.
- Location is used only for nearby services/places and is not stored by the app, based on current local code inspection.
- No tracking/advertising SDK was found in the app code.

## What Must Be Disclosed In App Store Privacy Questionnaire?

If the AI proxy is enabled for TestFlight/App Store builds:

- Data type: User Content
- Examples: AI prompts/messages and conversation content
- Purpose: App Functionality
- Tracking: No, unless the backend uses the data for tracking across apps/websites
- Linked to user: depends on backend logging. If logs contain IP/device/account identifiers that can be associated with a tester, answer as linked to user.
- Used for third-party advertising: No, unless backend policy says otherwise.

Potential additional disclosure depending on backend logs:

- Identifiers: disclose only if backend stores device/user/account identifiers.
- Diagnostics: disclose only if backend collects crash/error/performance logs.
- Usage Data/Product Interaction: disclose only if backend records AI usage analytics beyond local-only rate limiting.

If the AI proxy is not configured:

- The app uses local mock AI responses.
- No AI prompt data leaves the device through `AIClient`.
- Privacy questionnaire should still reflect any other remote services actually enabled in the final build.

## Blocker Status

Resolved:

- AI data path has been identified.
- Provider model is confirmed as configurable proxy, not hardcoded third-party SDK.
- Disclosure requirements are documented.

Requires manual action:

- Confirm production value of `YOUNEW_AI_PROXY_URL`.
- Confirm whether the proxy forwards data to a third-party model provider.
- Confirm whether the proxy stores logs and for how long.
- Complete App Store privacy questionnaire using actual backend behavior.

Release blocking:

- None in iOS code if the build is internal TestFlight and testers are told whether AI is proxy-backed or mock-backed.
- External beta/public release is blocked until privacy labels and policy match the actual AI proxy behavior.
