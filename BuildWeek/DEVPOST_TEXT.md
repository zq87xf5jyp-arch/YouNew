# Devpost Submission Copy

## Project name

YouNew

## Tagline

A local-first iOS guide that turns practical newcomer questions into structured journeys, official next steps, and local context across the Netherlands.

## Links

- GitHub repository: `{{GITHUB_REPOSITORY_URL}}`
- Demo video: `{{YOUTUBE_VIDEO_URL}}`

## Inspiration

Moving to the Netherlands often means dealing with several connected systems at once: municipal registration, BSN, DigiD, healthcare, housing, transport, documents, and local services. The information exists, but it is spread across institutions and websites. For a newcomer, the hard part is understanding what comes first, what depends on personal circumstances, and where to verify the next important action.

We built YouNew to make that journey feel navigable. The goal is not to replace an official institution or professional adviser. It is to help someone move from a broad practical question to a clearer sequence, relevant in-app context, and an identifiable official source.

## What it does

YouNew is a native SwiftUI iOS application for people moving to or settling in the Netherlands. It brings together:

- a practical Home experience and structured newcomer guides;
- a deterministic local guided assistant for bounded newcomer workflows;
- typed navigation from assistant responses into relevant app content;
- stored official-source actions for consequential next steps;
- search, saved items, checklists, discovery, and city content;
- an interactive Netherlands map with province and city navigation; and
- a governed content/import pipeline with stable identifiers and explicit releases.

The Build Week demo follows one person rather than presenting a feature tour. A newcomer asks, **“I recently received an address in the Netherlands. What should I do first for BSN, DigiD, health insurance, and a huisarts?”** YouNew turns that situation into an ordered route: municipal registration and BSN first, DigiD after its prerequisites, health insurance according to the person’s situation, and a huisarts as the next recommended step. The journey continues into the BSN guide and a named Government.nl/Rijksoverheid source. Only then does a 30-second montage show the wider Map, Search, Cities, and Categories experience.

## How we built it

The app is written in Swift 5 and SwiftUI for iOS. Typed destinations connect the main app surfaces, while view models, services, repositories, and local workflow engines manage behavior. `ContentRepository` and `KnowledgeIndex` project bundled, governed content into Guide, Search, the assistant, Home, and map-related experiences.

The assistant path demonstrated in the video uses explicit Swift workflow states and indexed YouNew knowledge. It composes bounded sections, next steps, warnings, in-app actions, and official-source records. It does not require an API key or backend for the documented demo.

The interactive map combines province geometry, city selection, typed navigation, and a city-map experience. The content platform uses versioned schemas, lifecycle states, release definitions, migration mappings, duplicate and relation checks, and deterministic runtime import. The current governed city release contains Amsterdam, Rotterdam, Den Haag, Utrecht, and Eindhoven.

The project also includes shared image infrastructure, local and remote fallback behavior, structured QA scripts, and unit/UI coverage across navigation, content, accessibility, assistant workflows, map behavior, and release data.

## How OpenAI tools helped

The owner started with a simple idea rather than a professional software-engineering background. ChatGPT became a product and writing partner, helping shape the experience and explain its purpose. OpenAI Codex became an engineering partner for tracing the existing implementation, closing targeted blockers, stabilizing the app, organizing technical evidence, and preparing the submission package. The human owner retained the vision, product direction, priorities, visual decisions, and final acceptance.

These collaboration roles are separate from the in-app runtime. The demonstrated YouNew assistant is labelled **Local guide mode** and uses a deterministic local fallback over indexed YouNew knowledge. It is not presented as a live ChatGPT, OpenAI, or GPT-5.6 response. The repository contains an optional bounded backend integration boundary, but no verified live-model runtime is part of this submission claim.

## Challenges we ran into

One of the most important stabilization issues was interaction between the map surface and the custom root tab bar. The map remained visually active while the first root-tab tap could be intercepted. The implementation was adjusted so the layout reservation stays noninteractive while the actual tab bar remains the frontmost interactive surface. Targeted evidence covers the critical first-tap Map-to-Home path.

Another challenge was keeping a large content product honest under deadline pressure. Structural import success is not the same as editorial completeness or live URL health, and source code for an optional AI backend is not proof of live model execution. We kept those boundaries explicit instead of turning partial evidence into marketing claims.

## Accomplishments we are proud of

- A coherent native iOS experience that connects questions, guides, official-source actions, map exploration, and city detail.
- A useful local assistant journey that remains reproducible without credentials or a deployed backend.
- A stabilized critical Map-to-root-navigation path for the demo candidate.
- A governed five-city release with canonical identities for Amsterdam, Rotterdam, Den Haag, Utrecht, and Eindhoven.
- A reusable image system and broad engineering checks across content, navigation, accessibility, data, and release behavior.
- A submission story that reflects what the app demonstrably does today.

## What we learned

The most useful assistant experience is not always the most open-ended one. For high-friction newcomer tasks, a bounded workflow can be clearer, safer, and easier to verify than a free-form answer. We also learned that source provenance, content lifecycle, runtime behavior, and public claims need separate evidence: passing one layer does not automatically validate the others.

## Known limitations

YouNew is a Build Week demonstration candidate, not a production-ready or App Store-ready release. The demonstrated assistant is local and deterministic; live OpenAI/GPT-5.6 inference is not verified. Content depth varies by topic and city. The latest recorded wider data-health check includes 18 confirmed broken external URLs, so we do not claim universal link health. Media-rights verification is partial, and no TestFlight or App Store parity claim is made.

The app provides general orientation only. Users should verify consequential legal, medical, immigration, tax, insurance, and municipal decisions with the relevant official institution or qualified professional.

## What is next

After Build Week, the focus is to deepen the highest-value newcomer journeys, improve source and editorial health, resolve remaining media-rights boundaries, and complete distribution-grade validation. A live model path would only become a product claim after a separately reviewed backend, privacy controls, provider/model evidence, and reliable fallback behavior are in place.
