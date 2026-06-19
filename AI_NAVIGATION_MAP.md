# AI Navigation Map

## Principle

Assistant navigation must be route-backed. An answer may recommend a screen only if the destination resolves through `AppDestination` and `AppNavigationResolver`.

## Current Route Model

Primary type:

```swift
enum AppDestination: Hashable
```

Resolver entry points:

- `AppDestination.aiRoute(for:)`
- `AppDestination.aiRouteID(from:)`
- `AppDestination.allKnownAIRouteIDs()`
- `AppNavigationResolver.routeID(from:)`

Assistant response field:

```swift
AIResponse.appDestinationID
```

Quick action destination field:

```swift
AIResponseAction.destinationID
```

## Known AI Route IDs

Current known route IDs:

| Route ID | Destination |
| --- | --- |
| search | Search |
| officialSources | Official Sources |
| firstSteps | First Steps |
| checklist | Checklist |
| journeyDocuments | Documents |
| transport | Transport guide |
| housing | Housing guide |
| healthcare | Healthcare guide |
| healthinsurance | Health insurance guide |
| huisarts | Finding huisarts guide |
| government | Government hub |
| emergency | Emergency hub |
| map | Map |
| assistant | AI Assistant |
| knm | KNM |
| dutch | Dutch A1-A2 |
| cities | Cities directory |
| provinces | Province directory |
| fines | Fines and rules |
| letters | Letters |
| institutions | Institutions |
| settings | Settings |
| help | Help hub |
| languagehub | Language hub |

## Required Route Coverage

Every route ID above must have:

- one `KnowledgeItem`
- one localized title
- one summary
- one category
- route or route ID
- quick action behavior
- test coverage proving it resolves

Current audit issue:

The knowledge index directly covers 12 indexed route IDs out of 23 known AI route IDs. Missing direct route entries:

- assistant
- cities
- dutch
- fines
- healthinsurance
- huisarts
- institutions
- knm
- letters
- provinces
- settings

## Navigation Actions

Assistant quick actions must map as follows:

| Action | Required behavior |
| --- | --- |
| Open Guide | Push the typed guide destination |
| Open Screen | Push or select the typed screen destination |
| Open City | Open city detail by city ID/name |
| Open Province | Open province detail by province ID/name |
| Open Source | Open external official URL |
| Save | Save the knowledge item or answer |
| Share | Share the answer or linked item |
| Related Topic | Run app search for topic |
| Ask Follow-Up | Send workflow/user choice back to `AIViewModel` |

## Navigation Flow Examples

### BSN

Question:

> How do I get BSN?

Expected assistant route plan:

1. Retrieve `topic:registration-bsn`.
2. Expand graph neighbors:
   - municipality registration
   - BRP
   - documents
   - DigiD
   - government hub
3. If address status is unknown, start BSN workflow.
4. Render actions:
   - Open Municipality / Government
   - Open Documents
   - Open BSN Guide
   - Open Official Source
   - Save
   - Share
   - Related Topic: DigiD

### Health Insurance

Question:

> I need health insurance.

Expected assistant route plan:

1. Start `healthInsurance` workflow.
2. Ask work status.
3. Ask municipality/BSN registration status.
4. Retrieve healthcare and insurance guide.
5. Render actions:
   - Open Health Insurance Guide
   - Open Healthcare Guide
   - Open City if selected city exists
   - Open Province if selected province exists
   - Open Official Source
   - Save
   - Share

### Explain Current Screen

Launcher mode:

> Explain Screen

Expected assistant route plan:

1. Build `AIContext` from current tab and active destination.
2. Retrieve current route item by `currentRouteID`.
3. Expand graph neighbors.
4. Explain what the screen is for, what to check first, and safe next action.
5. Show route-specific actions only.

### Find In App

Launcher mode:

> Find in App

Expected assistant route plan:

1. Prompt user for search query if empty.
2. Query `AppSearchEngine`.
3. Return ranked content as structured answer.
4. Provide Open Guide/Open Screen for top results.

## Navigation Safety Rules

- Never navigate to a nil destination.
- Never push a route ID that cannot resolve.
- Never open external sources unless URL is valid and displayed to the user.
- For sensitive flows, always include official source action.
- For city/province actions, prefer canonical IDs from `NLCity` and `NLProvince`.
- Do not mutate navigation path while another assistant route is being resolved.

## Required Tests

Add or maintain tests for:

- every `AppDestination.allKnownAIRouteIDs()` value resolves through `aiRoute(for:)`
- every known route ID has a `KnowledgeItem`
- every `KnowledgeItem.routeID` is known or explicitly accepted
- every assistant quick action with destination ID resolves
- every city item opens a city destination
- every province item opens a province destination
- no graph relation points to a missing node
- BSN query returns destination and official source
- health insurance workflow ends in healthcare/insurance destination

## Release Gate

The assistant navigation audit passes only when:

- no missing known route IDs
- no dead graph destinations
- all high-priority queries produce at least one navigation action
- all quick action destination IDs resolve
- source-opening actions only use valid URLs
