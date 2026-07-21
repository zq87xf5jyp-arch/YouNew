# YouNew

YouNew is a local-first SwiftUI guide for people building a life in the
Netherlands. It turns practical newcomer questions into structured next steps,
relevant in-app guidance, and stored official-source actions.

> **Build Week status:** prepared as a polished demonstration candidate. YouNew
> is not presented as an App Store-ready release, a government service, or a
> verified live-LLM product.

## Why YouNew

New residents often need to coordinate municipal registration, BSN, DigiD,
healthcare, housing, transport, work, study, and local services. The hard part is
not finding one webpage; it is understanding prerequisites, sequence, and which
official action comes next.

YouNew brings those tasks into one navigable iOS experience:

- structured newcomer journeys and practical guides;
- a deterministic local guided assistant;
- typed routes from guidance into relevant app content;
- stored official-source actions and verification context;
- search, saved items, checklists, city discovery, and local utilities;
- an interactive Netherlands map; and
- a governed content and import model.

## Build Week demo

The primary candidate flow uses functionality already implemented in the app:

1. Start on Home and frame the newcomer problem.
2. Cut to the supported newcomer question about what follows after receiving an
   address.
3. Show the ordered BSN → DigiD → health insurance → huisarts guidance.
4. Open the BSN guide and its named official-source action.
5. Use a 30-second montage for Map, Search, Cities, and Guide categories.
6. End with the owner’s story: ChatGPT as product and writing partner, Codex as
   engineering partner, and the human owner retaining the vision and decisions.

The complete 2:10–2:30 human-first sequence, narration, captions, and fallback plan are in
[BuildWeek/DEMO_GUIDE.md](BuildWeek/DEMO_GUIDE.md).

## Truthful AI positioning

The demonstrated assistant is local and deterministic. `AIWorkflowEngine`
selects a bounded workflow, `KnowledgeIndex` and `ContentRepository` provide
structured YouNew knowledge, and `AIResponseComposer` builds sections, warnings,
next steps, routes, and source actions.

The demo needs no backend or API key. Optional backend example code exists, but
it is not deployed evidence and is not part of the candidate claim. Do not
describe YouNew as using live OpenAI or GPT-5.6 inference.

OpenAI Codex supported implementation, debugging, stabilization, technical
auditing, and Build Week packaging under human direction. See
[BuildWeek/HOW_CODEX_HELPED.md](BuildWeek/HOW_CODEX_HELPED.md).

The owner describes ChatGPT as a product and writing partner for shaping the
problem, journeys, content, and public story. This creator collaboration is
separate from the in-app assistant runtime. See
[BuildWeek/HOW_CHATGPT_HELPED.md](BuildWeek/HOW_CHATGPT_HELPED.md).

## Candidate features

- Native SwiftUI interface with typed root and feature navigation
- Local BSN, DigiD, health, housing, letter/fine, and next-step workflows
- Indexed content lookup with explicit source actions
- Interactive SwiftUI map with province and city navigation
- Governed `cities-v0.1.0` release for Amsterdam, Rotterdam, Den Haag, Utrecht,
  and Eindhoven
- Premium image pipeline with local/remote candidates, fallbacks, downsampling,
  bounded caches, and accessibility labels
- Saved items, checklists, search, city discovery, and newcomer guides
- Governed JSON content, schema, release, and deterministic import tooling

The detailed implemented scope is in [BuildWeek/FEATURES.md](BuildWeek/FEATURES.md).

## Architecture

```text
SwiftUI screens
    ↓
RootTabView + typed AppDestination routes
    ↓
Feature view models and services
    ↓
ContentRepository / KnowledgeIndex / workflow engines
    ↓
Bundled Swift content + governed runtime JSON
```

The project uses a pragmatic SwiftUI architecture with environment-provided
shared state, typed destinations, repositories, feature services, and local
persistence. See
[BuildWeek/TECHNICAL_OVERVIEW.md](BuildWeek/TECHNICAL_OVERVIEW.md).

## Project facts

| Item | Value |
|---|---|
| Platform | Native iOS |
| Language and UI | Swift 5, SwiftUI |
| Bundle identifier | `nl.younew.app` |
| Version | 1.1 (5) |
| Minimum deployment target | iOS 17.6 |
| Demonstrated assistant | Local deterministic guide |
| Backend required for demo | No |

## Repository structure

| Path | Purpose |
|---|---|
| `YouNew/` | iOS application source, resources, content, and UI |
| `YouNewTests/` | unit and local integration coverage |
| `YouNewUITests/` | runtime navigation and demo contracts |
| `DataProject/` | governed content source, schema, releases, and import model |
| `scripts/` | static, data, media, and release checks |
| `BackendExamples/` | optional backend reference outside the demo claim |
| `BuildWeek/` | final Build Week narrative, demo, and submission package |
| `BuildWeekFinal/` | preserved targeted remediation evidence |

## Run locally

Requirements:

- macOS with a compatible Xcode version;
- an iOS runtime supported by the project;
- no backend or provider credential for the documented demo.

Open `YouNew.xcodeproj`, select the shared `YouNew` scheme, choose a compatible
iPhone destination, and Run.

For a command-line Debug build, select an installed destination appropriate to
your Xcode environment:

```sh
xcodebuild \
  -project YouNew.xcodeproj \
  -scheme YouNew \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=<AVAILABLE_IPHONE>' \
  build \
  CODE_SIGNING_ALLOWED=NO
```

The documented local assistant path requires no environment variable. Never add
an OpenAI key to Swift source, the application bundle, Xcode settings, fixtures,
or screenshots.

## Preserved readiness evidence

This README reports existing evidence; it does not promote historical results to
universal certification.

- The final candidate status records a successful build.
- A bounded prior candidate artifact records 460/460 unit checks passing.
- The targeted Map ↔ Home fix records 3/3 targeted checks and 10/10 first-tap
  transitions.
- Targeted evidence also covers the Guide loading state and shared search-field
  hit testing.
- Structural validation covers the governed five-city content release.

See [BuildWeek/FINAL_STATUS.md](BuildWeek/FINAL_STATUS.md) for the decision and
[BuildWeek/KNOWN_LIMITATIONS.md](BuildWeek/KNOWN_LIMITATIONS.md) for the evidence
boundary.

## Privacy, safety, and media

YouNew provides educational orientation, not professional or government advice.
Do not enter real BSNs, addresses, health details, account data, documents, or
credentials into a demo.

The image system is implemented, but repository-wide media rights are only
partially reconciled. Historical captures are not automatically approved for
public use. See `PRIVACY.md`, `SECURITY.md`, and `MEDIA_ATTRIBUTION.md` for the
detailed project records.

## Build Week package

Start with [BuildWeek/README_BUILD_WEEK.md](BuildWeek/README_BUILD_WEEK.md). It
links the project story, description, feature inventory, technical overview,
Codex/ChatGPT narratives, demo guide, Devpost copy, checklist, limitations,
owner actions, and final status.

No remote was created, no push or publication was performed, and no video was
generated during repository preparation.

## License

See [LICENSE](LICENSE). Third-party content and media retain their respective
terms; repository inclusion does not grant redistribution rights.
