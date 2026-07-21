# YouNew — Build Week Package

YouNew is a native SwiftUI guide that helps newcomers turn practical questions
about life in the Netherlands into clear next steps, relevant in-app guidance,
and stored official-source actions.

This package is the final, truthfully scoped handoff for an OpenAI Build Week
demonstration. The candidate is demo-ready in its established local mode; it is
not described as production-ready, content-complete, or powered by a verified
live OpenAI model.

## Judge quick view

| Question | Answer |
|---|---|
| What problem does it solve? | Newcomers face connected tasks across many Dutch institutions and need sequence, prerequisites, and safe next actions. |
| What is the product? | A native iOS guide with structured journeys, local discovery, map navigation, saved/checklist utilities, governed content, and a local guided assistant. |
| What should be demonstrated? | One newcomer story: Home → ordered BSN/DigiD/health-insurance/huisarts guidance → Guide/source → 30-second breadth montage → creator story. |
| Is the assistant live generative AI? | No. The candidate uses deterministic local workflows and indexed YouNew knowledge. |
| How did OpenAI tools contribute? | ChatGPT supported product thinking and writing; Codex supported implementation, debugging, stabilization, technical auditing, and packaging under owner direction. |
| What is the release target? | A polished Build Week demonstration, not an App Store release. |

## Human-first 2:20 demo

1. Establish the person and their uncertainty on Home.
2. Cut to the already-submitted supported prompt: **“I recently received an
   address in the Netherlands. What should I do first for BSN, DigiD, health
   insurance, and a huisarts?”**
3. By 0:30, show the ordered BSN → DigiD → health-insurance path, with huisarts
   visible as the next recommended step.
4. Continue into the BSN guide and show the named Government.nl/Rijksoverheid
   source card.
5. Give Map, Search, Cities, and Categories one quick shot each in a 30-second
   breadth montage.
6. Close with the creator story: ChatGPT as product and writing partner, Codex as
   engineering partner, and the owner as the source of the vision and decisions.

Use [DEMO_GUIDE.md](DEMO_GUIDE.md) for exact timing, presenter wording, and
fallbacks.

## Submission documents

| Document | Purpose |
|---|---|
| [PROJECT_STORY.md](PROJECT_STORY.md) | Product origin, problem, decisions, and outcome |
| [PROJECT_DESCRIPTION.md](PROJECT_DESCRIPTION.md) | Concise public project description |
| [FEATURES.md](FEATURES.md) | Implemented candidate capabilities |
| [TECHNICAL_OVERVIEW.md](TECHNICAL_OVERVIEW.md) | Architecture and evidence boundary |
| [HOW_CODEX_HELPED.md](HOW_CODEX_HELPED.md) | Codex contribution narrative |
| [HOW_CHATGPT_HELPED.md](HOW_CHATGPT_HELPED.md) | ChatGPT collaboration narrative |
| [DEMO_GUIDE.md](DEMO_GUIDE.md) | Screen order, narration, timing, and fallback plan |
| [DEVPOST_TEXT.md](DEVPOST_TEXT.md) | Copy/paste submission copy |
| [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md) | Honest product and evidence limits |
| [SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md) | Packaging and submission checklist |
| [OWNER_ACTIONS.md](OWNER_ACTIONS.md) | External actions reserved for the owner |
| [FINAL_STATUS.md](FINAL_STATUS.md) | Final readiness decision |

## Candidate highlights

- Native SwiftUI app with typed navigation and a local-first product path.
- Deterministic guided assistant over structured YouNew knowledge.
- Supported newcomer workflow that orders BSN → DigiD → health insurance →
  huisarts and connects to an in-app guide and source action.
- Interactive SwiftUI map with province and city navigation.
- Governed content releases and deterministic import tooling.
- Existing premium image pipeline with local/remote fallback behavior.
- Existing saved items, checklists, search, city discovery, and practical guides.
- Preserved targeted evidence for the Map ↔ Home navigation blocker fix.

## Truthful capability statement

The safe public description is:

> YouNew includes a local guided fallback built from deterministic workflows and
> indexed YouNew knowledge. ChatGPT helped the owner shape the product and its
> story; OpenAI Codex helped implement, debug, stabilize, and package the project.
> Live OpenAI inference is not part of the verified demo.

Do not describe the candidate as live GPT-5.6, generative RAG, a government
service, a legal/medical adviser, production-ready, or content-complete.

## Run the project

Requirements:

- macOS with a compatible Xcode version;
- an iOS runtime supported by the project;
- no backend and no API key for the documented demo.

Open `YouNew.xcodeproj`, select the shared `YouNew` scheme, choose a compatible
iPhone destination, and Run. The app target uses bundle identifier
`nl.younew.app`, version 1.1 (5), with iOS 17.6 as the minimum deployment target.

## Final handoff

Engineering and documentation are frozen around the existing candidate. No remote
was created, no push or publication was performed, and no video was generated.
The remaining external steps are intentionally isolated in
[OWNER_ACTIONS.md](OWNER_ACTIONS.md).
