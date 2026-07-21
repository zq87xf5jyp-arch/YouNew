# Judge Setup

Evidence cutoff: 21 July 2026

## Fastest supported path

YouNew is a native SwiftUI iOS project. The demonstrated assistant path is local
and does not require an API key, backend deployment, user account, or seeded
personal data.

The latest recorded local environment used:

- macOS 26.5.2;
- Xcode 26.6;
- iPhone 17 Pro Simulator;
- iOS 26.5; and
- Apple silicon (`arm64`).

These versions describe the recorded environment, not a compatibility guarantee.
Final candidate environment and result paths belong in
[FINAL_VALIDATION.md](FINAL_VALIDATION.md).

## Open and run in Xcode

1. Open `YouNew.xcodeproj` from the repository root.
2. Select the shared `YouNew` scheme.
3. Select an available iPhone simulator. The evidence environment used **iPhone
   17 Pro / iOS 26.5**.
4. Run the app.
5. Start on Home and follow [DEMO_GUIDE.md](DEMO_GUIDE.md).

No backend URL should be configured for the documented Build Week demo. Never add
`OPENAI_API_KEY` or another provider secret to Swift, an `.xcconfig`, Xcode build
settings, Info.plist, the app bundle, or the repository.

## Command-line simulator build

Run from the repository root. This is the project command used by the existing
technical documentation; its result for the final candidate must still be taken
from `FINAL_VALIDATION.md`.

```sh
xcodebuild \
  -project YouNew.xcodeproj \
  -scheme YouNew \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  clean build \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES
```

If that exact simulator runtime is not installed, choose an available simulator
in Xcode and record the substituted destination with the resulting artifact. Do
not describe an untested substitution as verified.

## Optional verification commands

The repository has three shared schemes: `YouNew`, `YouNewUnitTests`, and
`YouNewUITests`. These commands run existing gates; they do not imply a passing
result.

Unit suite:

```sh
xcodebuild \
  -project YouNew.xcodeproj \
  -scheme YouNewUnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  test \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES
```

Static/data aggregate:

```sh
scripts/run-static-qa.sh
```

Targeted local BSN workflow UI test:

```sh
xcodebuild \
  -project YouNew.xcodeproj \
  -scheme YouNewUITests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  -parallel-testing-enabled NO \
  -only-testing:YouNewUITests/YouNewUITests/testAssistantBSNWorkflowExposesMunicipalityDocumentsGuideAndSource \
  test \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES
```

The UI suite is intentionally serial in the documented configuration. Preserve
the generated `.xcresult` and report its exact device, counts, duration, failures,
commit, and working-tree state.

## Five-minute judge walkthrough

1. Home → **Open AI assistant**.
2. Ask **How do I get BSN?**.
3. Choose **yes, I have an address**.
4. Choose **yes, include DigiD guidance**.
5. Open the BSN in-app guide and inspect an official-source action.
6. Open Map.
7. Tap Home once and verify that Home appears immediately.
8. Return to Map and open Amsterdam through Noord-Holland.

This is a local deterministic knowledge workflow. The app should not be described
as live OpenAI or GPT-5.6-powered.

## Troubleshooting boundaries

- If signing is requested for a simulator build, confirm that
  `CODE_SIGNING_ALLOWED=NO` is present. Physical-device signing remains the
  owner's responsibility.
- If an official source cannot load, distinguish network/link availability from
  the in-app source record and continue with the guide. The current data-health
  report contains 18 confirmed broken URLs across the wider data set.
- If Map → Home requires a second tap, the candidate has failed a primary
  delivery gate. Do not work around it during judging.
- If the local workflow cannot be reproduced with the exact prompt above, record
  the failure and use `FINAL_VALIDATION.md` as the status authority.
- No current claim is made for a clean-clone build, App Store/TestFlight parity,
  broad physical-device coverage, or complete VoiceOver validation.

