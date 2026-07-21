# YouNew Build Week Demo Guide

Target length: **2:10–2:30**  
Recommended language: **English**  
Recommended format: **a short edited screen recording with narration and burned-in English captions**

## Demo promise

This is not a feature tour. It follows one newcomer from “I have an address—what now?” to an understandable sequence, a detailed guide, and a named official source. Only after that human story is clear does the video briefly show the wider product and explain how the owner built it with ChatGPT and Codex as collaborators.

The value must be understandable before **0:30** even if a judge watches no further: YouNew turns one confusing life moment into ordered next steps. The demonstrated fallback is a **local deterministic guided assistant** backed by structured YouNew content and visibly labelled **Local guide mode**. Do not imply that ChatGPT or Codex is the in-app runtime, or describe YouNew as legal advice or a government service.

## Before recording

- Use the final prepared candidate in English, with no debug overlays or notifications.
- Clear the assistant conversation so the recording starts from a clean state.
- Record the Home shot and the assistant journey as separate clips. Do not spend the opening navigating through tabs or typing the prompt in real time.
- Before recording the assistant clip, submit the supported prompt: **I recently received an address in the Netherlands. What should I do first for BSN, DigiD, health insurance, and a huisarts?**
- Begin the assistant clip with the submitted question already visible and the ordered response appearing below it.
- Use only synthetic input. Never enter a real BSN, address, passport number, DigiD code, email address, health detail, or credential.
- Keep the external browser out of the primary take. Showing the named official-source card is sufficient and avoids making network availability part of the demo.
- Frame the app so the root tabs, **Local guide mode** label, guide title, source publisher, map, search result, and selected city remain readable.

## Mandatory 0:00–0:30 human-first opening

Use one clean cut from Home to the prepared assistant response. Burn in the spoken English as subtitles; do not add competing feature slogans.

| Time | Screen and action | Exact voice-over | What the judge must understand |
|---|---|---|---|
| 0:00–0:08 | **Home.** Hold on the current city and newcomer profile. No splash or menu navigation. | “Moving to a new country is exciting—until you need to understand how everything actually works.” | The story is about a person facing an unfamiliar system. |
| 0:08–0:20 | Cut to the already-submitted newcomer question. Keep the question bubble and **Local guide mode** readable. | “You have an address in the Netherlands. But what comes next—and where do you even start?” | YouNew begins with the person’s real situation, not a catalogue of features. |
| 0:20–0:25 | Show **1. Registration-dependent — BSN** and **2. After prerequisites — DigiD**. | “YouNew turns that uncertainty into a simple sequence: first, register with the municipality and receive a BSN.” | The product converts uncertainty into an ordered route. |
| 0:25–0:30 | Cut or scroll once to **3. Situation-dependent — health insurance**. | “Then use it to set up DigiD. After that, check Dutch health insurance.” | By 0:30 the judge has seen the problem and three concrete next steps. |

## Full timed screen order and narration

| Time | Screen and action | Exact voice-over |
|---|---|---|
| 0:00–0:08 | **Home** — current city and newcomer profile. | “Moving to a new country is exciting—until you need to understand how everything actually works.” |
| 0:08–0:20 | **Prepared Assistant question** — show the supported address/newcomer prompt without typing it on camera. | “You have an address in the Netherlands. But what comes next—and where do you even start?” |
| 0:20–0:45 | **Ordered Assistant result** — clearly frame BSN, DigiD, and health insurance; show huisarts only as the next recommended step. | “YouNew turns that uncertainty into a simple sequence: first, register with the municipality and receive a BSN. Then use it to set up DigiD. After that, check Dutch health insurance. One question becomes clear next steps, in the right order.” |
| 0:45–1:20 | **BSN guide and official source** — open the BSN guide, show what to prepare, then the named Government.nl/Rijksoverheid source card. | “When a step needs more detail, the guide explains what it means, what to prepare, and where to verify it. Official sources stay visible, so the user can continue with the responsible Dutch institution—not another anonymous blog. YouNew does not replace government advice. It helps a newcomer understand where to begin and what to do next.” |
| 1:20–1:27 | **Map** — one clean map frame. | “And life is bigger than one checklist.” |
| 1:27–1:34 | **Search** — show one relevant result set, without typing. | “A newcomer may need a nearby service or information for a specific city…” |
| 1:34–1:42 | **Cities** — show city selection or one city page. | “…or help finding healthcare, housing, work, and legal resources.” |
| 1:42–1:50 | **Categories** — one quick Guide category overview. | “Map, search, cities, and categories keep those needs connected in one place—without turning the first weeks into twenty open tabs.” |
| 1:50–2:20 | **Creator story** — a calm montage of the strongest finished screens, ending on the YouNew name. Never show code, terminal, QA, or architecture. | “YouNew started as a simple idea: make the first months in a new country less confusing. I wasn’t a professional software engineer. ChatGPT helped me shape the product and its story. Codex helped me build, stabilize, and prepare the iOS app. They expanded what I could create, while the vision and decisions stayed mine. This is YouNew—a clearer first step in the Netherlands.” |

Target finish: **2:20**. Let the final YouNew frame breathe; do not fill spare seconds with another feature.

### Final title cards

- **ChatGPT · Product & writing partner**
- **Codex · Engineering partner**
- **YouNew · A clearer first step in the Netherlands**
- **Built for OpenAI Build Week**

## Recording rules

- Keep the exact supported prompt in the recorded app. The shorter line “I have an address. What should I do next?” belongs in the narration; by itself it does not trigger the intended four-step response.
- Do not show the Home → Guide → Assistant navigation in the opening. The next shot after Home must already contain the useful question.
- Burn in the narration as readable English subtitles. Keep each subtitle to two short lines at most.
- Keep the **Local guide mode** label readable for at least two seconds.
- Do not show a splash animation, login, loading state, keyboard, long scrolling, repeated taps, or debug UI.
- Show the official-source publisher and title, but do not say that every external link in the wider data set is healthy.
- Present YouNew as a guide that links to official sources, never as an official authority itself.
- Keep Map, Search, Cities, and Categories to one clear shot each. Together they get 30 seconds, not a second product tour.
- In the creator story, show finished product screens only. The narration is about what the owner was able to create, not about code or tooling mechanics.
- Do not extend the recording into settings, unfinished categories, TestFlight, App Store, backend configuration, or internal QA artifacts.

## Safe fallback during recording

- If the workflow does not show all four ordered steps, clear the conversation and repeat the exact supported address/newcomer prompt from **Before recording**.
- If the assistant clip begins with the keyboard or typing cursor visible, reset the take; it should begin on the submitted question and response.
- If an action is below the fold, scroll the current response; do not switch to another scenario.
- If an external source cannot open, keep the in-app source card visible and say, “External opening is network-dependent.” Continue without claiming that the page opened.
- If any breadth clip takes more than one clean action to understand, replace it with a pre-positioned take rather than extending the montage.

## Final narration guardrails

Keep these roles separate:

- **ChatGPT** — the owner’s product and writing partner.
- **Codex** — the owner’s engineering partner for implementation, stabilization, and Build Week preparation.
- **YouNew Assistant** — the demonstrated in-app guided experience, shown with its actual mode label and official-source links.

Do not say:

- “Powered by GPT-5.6.”
- “This is a live OpenAI answer.”
- “ChatGPT powers the assistant shown in the app.”
- “The assistant generated this advice.”
- “All links work,” “all tests pass,” or “the app is production ready.”

Evidence boundary: [existing submission demo guide](../BuildWeekSubmission/DEMO_GUIDE.md), [final demo flow](../BuildWeekFinal/DEMO_FLOW.md), and [truthful assistant description](../BuildWeekSubmission/AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md).
