# YouNew Build Week Demo Guide

Evidence cutoff: 21 July 2026  
Candidate mode: **local deterministic guided assistant**

## What this demo proves

This walkthrough demonstrates a bounded newcomer journey already implemented in
the iOS app. It shows Home, the local assistant, the BSN → address → DigiD
workflow, an in-app guide, an official-source action, the interactive Netherlands
map, root-tab navigation, and one city from the governed `cities-v0.1.0` release.

It does **not** demonstrate live OpenAI inference, GPT-5.6, App Store readiness,
complete content, or universal external-link availability.

Final build and test status must be read from
[FINAL_VALIDATION.md](FINAL_VALIDATION.md). The map/root-tab remediation is
verified for event delivery in serialized and manual checks. The finalized full
UI aggregate is 79/87, and the isolated rerun of its eight failures is 5/8. One
root-tab latency sample still exceeds the unchanged 100 ms ceiling.

## Pre-demo checklist

- Use the final owner-approved candidate snapshot and the simulator recorded in
  `FINAL_VALIDATION.md`.
- Use English for the most directly exercised workflow wording.
- Do not configure `YOUNEW_AI_BACKEND_URL` and do not add an API key. The recorded
  path must remain the local guide path.
- Start with an empty assistant conversation and no personal data in the app.
- Confirm that the BSN and DigiD source URLs intended for the recording open on
  the recording network. The wider data-health report currently records 18
  confirmed broken URLs, so stored source metadata is not a guarantee of live
  reachability.
- Hide notifications, account names, simulator debug overlays, local paths, and
  credentials before recording.
- Use only the media allowlist in
  [MEDIA_RIGHTS_AND_ATTRIBUTION.md](MEDIA_RIGHTS_AND_ATTRIBUTION.md). Do not open
  category cards that expose the eleven unresolved high-use raster assets.
- Prepare the exact Leiden, Haarlem, and Amsterdam credit block from
  `BuildWeekFinal/MEDIA_RIGHTS_FINAL.md` for the video description/end card.
- Do not use the Assistant **Open Leiden** shortcut or the long Guide-to-Transport
  composite route. Both remain reproducible UI failures outside this bounded flow.

## Primary judge flow

| Step | Judge action | Expected candidate behavior | Evidence anchor |
|---:|---|---|---|
| 1 | Launch YouNew. | Home appears with the root tab bar. | `screen.home`, `tab.home` runtime contracts. |
| 2 | On Home, tap the sparkles control labelled **Open AI assistant**. | The Assistant screen opens and presents its input. | `home.aiButton`, `assistant.input`. |
| 3 | Enter **How do I get BSN?** and send. | A structured local response starts the BSN workflow and asks whether the user has an address. | `AIWorkflowEngine`; `assistant.quickAction.askFollowUp.yes.address`. |
| 4 | Choose the affirmative address option. | The deterministic workflow advances to its DigiD question. | `assistant.quickAction.askFollowUp.yes.digid`. |
| 5 | Choose to include DigiD guidance. | The response exposes municipality/documents navigation, the BSN guide, and at least one official-source action. | `YouNewUITests.testAssistantBSNWorkflowExposesMunicipalityDocumentsGuideAndSource`. |
| 6 | Open **BSN Guide**. | The typed in-app BSN content destination opens. | `article:documents:bsn`, `guide.article.bsn`. |
| 7 | Return to the assistant response and open its official-source action. | The app hands off to the stored official reference. Read the publisher/domain aloud; do not call the whole data set link-clean. | Government.nl BSN or official DigiD source records. |
| 8 | Return to YouNew and open **Guide** if it is not already selected. Briefly show the structured guide surface. | Guide content is visible without leaving the app. | `tab.guide` and typed guide routes. |
| 9 | Tap **Map** in the root tab bar. | The interactive Netherlands map appears. | `tab.map`, `map.hub`. |
| 10 | Tap **Home once** in the root tab bar. | Home appears on that first tap. This is the visible acceptance check for the map/tab event-delivery fix. | `MapChipUITests.testRootTabNavigationLatency`; `/private/tmp/YouNewBuildWeekRootLatencySerialFinal.xcresult`; screenshot 07. |
| 11 | Tap **Map** again, choose Noord-Holland, then select **Amsterdam** from the exposed marker or city control. Hold on the Amsterdam hero/name; do not use the flag/coat tiles as promotional artwork. | An Amsterdam city surface/detail opens. Amsterdam is one of the five governed `cities-v0.1.0` records. | `map.city.amsterdam`; `cities-v0.1.0` release manifest; `BuildWeekFinal/MEDIA_RIGHTS_FINAL.md`. |

The five records in that governed city release are Amsterdam, Rotterdam, Den
Haag, Utrecht, and Eindhoven. Show one only; Amsterdam is recommended because it
has an explicit map marker and governed city record.

## Presenter wording

Use:

> “This is YouNew's local guided assistant. It follows a deterministic BSN,
> address and DigiD workflow, then routes into structured YouNew content and
> stored official sources.”

Do not say:

- “Powered by GPT-5.6.”
- “This is a live OpenAI answer.”
- “The assistant generated this answer.”
- “All links are verified” or “all tests pass.”
- “The app is production ready.”

## Fallback path

Fallbacks keep the demo inside already implemented functionality; they are not
substitutes for a failed delivery gate.

1. If a longer newcomer question does not enter the expected journey, clear the
   conversation and use the exact prompt **How do I get BSN?**.
2. If the external browser has no network, keep the source action and publisher
   visible, state that external reachability is unavailable in the recording
   environment, and continue with the in-app BSN guide. Do not claim the URL was
   opened.
3. If the Amsterdam label is visually crowded, select Noord-Holland first and use
   the Amsterdam city control exposed by the selected province. Do not substitute
   a city outside `cities-v0.1.0` while describing the five-city release.
4. If the first Home tap from Map does not work, stop the candidate recording and
   treat it as a blocker. Do not hide it with repeated taps or an edited cut.
5. Open a city through the demonstrated Map/Home path, not through the Assistant
   **Open Leiden** shortcut.

## Screen-recording checklist

- Record one continuous take of the primary flow.
- Begin on Home and keep the root tab bar visible long enough to orient the judge.
- Capture the assistant's local-guide identification before opening any action.
- Capture the address and DigiD choices, not only the final response.
- Show the guide title and one official-source action.
- Capture Map → one-tap Home → Map as an uninterrupted sequence.
- Show the Amsterdam name on the city surface/detail.
- Add the complete photo attribution block to the video description or end card.
- Do not use screenshot 08 as standalone promotional artwork unless the owner has
  accepted the official-symbol boundary; prefer a hero/name-only replacement.
- Do not enter a real BSN, address, email, phone number, account, or credential.
- Do not show backend configuration, provider secrets, TestFlight metadata, or
  unreviewed media-rights material.
- After recording, compare every spoken claim with
  [AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md](AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md),
  [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md), and
  [FINAL_VALIDATION.md](FINAL_VALIDATION.md).

## Source evidence

- [AIWorkflowEngine.swift](../YouNew/Services/AIWorkflowEngine.swift)
- [AIResponseComposer.swift](../YouNew/Services/AIResponseComposer.swift)
- [BuildWeekNewcomerDemo.swift](../YouNew/Services/BuildWeekNewcomerDemo.swift)
- [YouNewUITests.swift](../YouNewUITests/YouNewUITests.swift)
- [MapChipUITests.swift](../YouNewUITests/MapChipUITests.swift)
- [cities-v0.1.0 release manifest](../DataProject/reports/release-manifests/cities-v0.1.0.json)
- [Media rights and attribution](MEDIA_RIGHTS_AND_ATTRIBUTION.md)
