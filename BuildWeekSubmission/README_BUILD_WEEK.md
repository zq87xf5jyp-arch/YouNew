# YouNew — OpenAI Build Week Candidate

YouNew is a native SwiftUI iOS application that helps newcomers navigate
practical life in the Netherlands. It combines structured guides, official-source
actions, local discovery, an interactive Netherlands map, governed content
releases, and a deterministic local knowledge assistant.

This repository is being prepared as an honest demonstration candidate. It is
not presented as production ready, content complete, or powered by a verified
live OpenAI model.

## Problem

New residents often face interdependent tasks—municipal registration, BSN,
DigiD, healthcare, housing, transport, and local services—across many institutions
and websites. The difficult part is not finding one page; it is understanding the
order of actions, prerequisites, and safe official next steps.

## Solution

YouNew turns those tasks into navigable in-app journeys:

- a structured Home and Guide experience;
- a local assistant that advances through explicit workflow states;
- typed routes from an answer into relevant YouNew content;
- stored official-source actions;
- an interactive map with province and city navigation;
- governed data releases and deterministic import validation; and
- shared image, accessibility, unit, UI, static, and content QA infrastructure.

## Target users

The current candidate is designed for people moving to or recently settled in the
Netherlands who need practical orientation. It is not a substitute for a lawyer,
doctor, immigration adviser, tax professional, municipality, or other competent
authority.

## Current candidate status

| Area | Honest status |
|---|---|
| iOS application | Native SwiftUI implementation present. Final candidate build result is reported separately. |
| Main demo | Home → local Assistant → BSN/address/DigiD → Guide/source → Map → first-tap Home → Amsterdam. |
| Assistant | Local deterministic guided assistant backed by workflow engines and indexed YouNew knowledge. |
| Live OpenAI / GPT-5.6 | Not verified in candidate runtime; not a public capability claim. |
| Map/root tabs | The reproduced event-delivery blocker is fixed in a preserved targeted simulator artifact: 3/3 PASS, including 10/10 first-tap Map ↔ Home transitions. Expanded UI totals remain separate. |
| Content data | Governed releases and import tooling are present; content is not complete. |
| External links | Current report includes 18 confirmed broken URLs. |
| Tests | Extensive suites exist. Current final totals must come only from `FINAL_VALIDATION.md`; no all-tests-pass claim is made here. |
| Distribution | TestFlight/App Store parity is not verified. No Git remote is configured. |
| Media | Attribution infrastructure exists; complete rights clearance is still an owner gate. |

## Main demo flow

1. Launch YouNew and show Home.
2. Tap **Open AI assistant**.
3. Ask **How do I get BSN?**.
4. Confirm that an address is available.
5. Request DigiD guidance.
6. Open the BSN guide and show one official-source action.
7. Open Map.
8. Return to Home with one root-tab tap.
9. Return to Map and open Amsterdam through Noord-Holland.

See [DEMO_GUIDE.md](DEMO_GUIDE.md) for presenter wording, expected screens,
fallbacks, and the recording checklist.

## Key implementation evidence

### Hybrid SwiftUI architecture

`YouNewApp` creates the SwiftUI scene and shared state. `RootTabView` owns root
tabs and navigation paths. Typed `AppDestination` routes connect views, while
repositories, loaders, workflow engines, search/index services, and observable
state objects provide application behavior. This is a pragmatic hybrid SwiftUI
architecture, not a claim of strict pure MVVM.

### Local guided assistant

The candidate assistant is local and deterministic:

1. `AIWorkflowEngine` selects a bounded workflow and explicit state.
2. The BSN workflow asks whether the user has an address and whether DigiD
   guidance is needed.
3. `AIResponseComposer` searches indexed YouNew knowledge and constructs sections,
   warnings, in-app destinations, next steps, and source actions.
4. The UI identifies a local-guide response.

The repository includes optional bounded backend-client code, but its presence is
not proof that a backend is deployed, an OpenAI request succeeded, or GPT-5.6 ran.
Read [AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md](AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md).

### Interactive Netherlands map

The map is implemented in SwiftUI with province geometry, labels, markers,
selection, zoom/pan behavior, and typed navigation into app content. Geometry and
hit-testing contracts have dedicated tests. The final targeted runtime artifact
passes Leiden and Middelburg city activation plus 10/10 first-tap Map ↔ Home
transitions; this evidence is simulator- and path-bounded, not a claim that every
map interaction passes on every device.

### Content and import platform

`DataProject/` contains schemas, work packages, release definitions, validation
rules, deterministic import tooling, manifests, and the bundled runtime payload.
The governed `cities-v0.1.0` release imported five cities: Amsterdam, Rotterdam,
Den Haag, Utrecht, and Eindhoven. Internal release status does not mean App Store
publication, and structural import success does not imply that every external URL
is healthy.

### Premium image system

The shared image layer supports role-aware sizing, local/remote candidates,
fallback states, focal-point policy, downsampling, bounded caches, in-flight
request coalescing, HTTP validation, and accessibility labels. Complete media
rights clearance remains separate from implementation quality.

## How Codex was used

The repository contains implementation and reports consistent with the documented
human-directed Codex-assisted workflow. The five strongest evidence areas are:

1. the premium image pipeline;
2. the interactive map;
3. the governed content/import platform;
4. the `cities-v0.1.0` release; and
5. QA, accessibility, and release automation.

The human owner defined the product vision, requirements, priorities, visual
direction, release boundaries, and final acceptance decisions. Codex assisted
with implementation, debugging, refactoring, testing, and technical auditing
within those directions. Repository artifacts are not, by themselves, proof of
the exact author of every line or session. See
[HOW_CODEX_WAS_USED.md](HOW_CODEX_WAS_USED.md).

## Verification approach

The project includes shared build, unit, and UI schemes plus static, content,
accessibility, privacy, media, data, import, and release checks. Historical totals
are intentionally omitted here. The current candidate's build/test counts,
failures, duration, device, commit/tree state, and artifact paths must be read from
[FINAL_VALIDATION.md](FINAL_VALIDATION.md).

## Setup

Recorded local environment:

- macOS 26.5.2;
- Xcode 26.6;
- iPhone 17 Pro Simulator on iOS 26.5;
- Python 3 for repository QA scripts.

Open `YouNew.xcodeproj`, select the shared `YouNew` scheme and an available iPhone
simulator, then Run. No backend or API key is required for the documented local
assistant demo.

Command-line simulator build:

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

The command is an instruction, not a current PASS claim. This repository does not
claim that the final candidate has been reproduced from a clean clone until that
exact check appears in `FINAL_VALIDATION.md`. For focused commands and setup
boundaries, see [JUDGE_SETUP.md](JUDGE_SETUP.md).

## Privacy and security

- The documented BSN workflow selection and local answer construction run in the
  app and require no provider credential.
- Never enter a real BSN, address, health detail, account, or credential in the
  demo.
- Never place `OPENAI_API_KEY` or another provider secret in the iOS app,
  repository, build settings, or recording.
- Optional backend code is outside the candidate claim until its server ownership,
  privacy, provider/model, failure behavior, and runtime evidence are reviewed.
- Stored official links are references, not official advice and not a guarantee
  of present reachability.

## Media attribution status

The project has media manifests, license metadata, source references, and image
QA. That work does not establish complete rights clearance for every asset or
capture. The owner must confirm rights or remove disputed material before public
distribution. Do not use “all images are fully licensed” in the submission.

## Known limitations

- No verified live GPT-5.6/OpenAI runtime path.
- Uneven and incomplete content outside the curated demo.
- 18 confirmed broken URLs in the current data-health report.
- Map/root-tab targeted evidence is green; aggregate full-UI evidence remains pending.
- No verified TestFlight/App Store parity.
- Partial media-rights clearance.
- No complete physical-device/VoiceOver certification.
- Current final test totals unresolved until the final validation pass closes.
- No current clean-clone reproducibility claim and no configured Git remote.

The tracked detail and owner actions are in
[KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md).

## Build Week notes

The submission should focus on the functionality that is reproducible now: a
native iOS experience, a structured local newcomer workflow, typed content
navigation, a rich map, governed city imports, a shared image system, and a broad
QA platform. Public copy, video narration, screenshots, and technical answers
must stay within the evidence boundary above.

No push, deployment, TestFlight upload, App Store upload, credential provisioning,
or submission action is part of this candidate-preparation pass. Those remain
explicit owner approvals.

## Documentation map

- [TECHNICAL_OVERVIEW.md](TECHNICAL_OVERVIEW.md)
- [HOW_CODEX_WAS_USED.md](HOW_CODEX_WAS_USED.md)
- [AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md](AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md)
- [CONTENT_PLATFORM.md](CONTENT_PLATFORM.md)
- [DEMO_GUIDE.md](DEMO_GUIDE.md)
- [JUDGE_SETUP.md](JUDGE_SETUP.md)
- [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md)
- [FINAL_VALIDATION.md](FINAL_VALIDATION.md)
