# AI Navigation Report
Generated: 2026-06-15

## Overview

Every AI response can include an `appDestinationID` that routes the user to a specific section. The navigator mode shows quick-access routes after answers. This report audits all route IDs, their destinations, and navigation button reachability.

---

## Route Table (AppDestination.aiRoute)

| Route ID | Destination | Status |
|----------|-------------|--------|
| `search` / `searchlist` | `.searchList` | VERIFIED |
| `officialsources` / `sources` | `.officialSources` | VERIFIED |
| `firststeps` / `registration` | `.firstSteps` | VERIFIED |
| `documents` / `journeydocuments` | `.journeyDocuments` | VERIFIED |
| `transport` | `.practicalGuide(.transportBasics)` | VERIFIED |
| `housing` | `.practicalGuide(.housingBasics)` | VERIFIED |
| `healthcare` / `health` | `.practicalGuide(.healthcareBasics)` | VERIFIED |
| `government` / `municipality` / `immigration` / `ind` | `.governmentHub` | VERIFIED |
| `emergency` / `emergencies` / `police` | `.emergencyHub` | VERIFIED |
| `map` / `maphub` | `.mapHub` | VERIFIED |
| `assistant` / `ai` | `.assistantHub` | VERIFIED |
| `knm` | `.knm` | VERIFIED |
| `dutch` / `language` / `a1` / `a1a2` | `.dutchA1A2` | VERIFIED |
| `cities` / `city` | `.cityList` | VERIFIED |
| `provinces` / `province` | `.provinceList` | VERIFIED |
| `fines` / `rules` | `.finesList` | VERIFIED |
| `institutions` / `institution` | `.institutionsList` | VERIFIED |
| `settings` / `setting` | `.settings` | VERIFIED |
| `help` / `helphub` / `helpcentre` | `.helpHub` | ADDED THIS SESSION |
| `languagehub` / `languagecenter` | `.languageHub` | ADDED THIS SESSION |

**Total: 20 route IDs → 20 distinct destinations**

---

## Navigator Quick Routes (AINavigatorRoute)

| Route ID | Intent (EN) | Destination | Icon | Status |
|----------|-------------|-------------|------|--------|
| `bsn` | Get your BSN number | `.governmentHub` | `person.text.rectangle.fill` | VERIFIED |
| `digid` | Set up DigiD | `.governmentHub` | `lock.shield.fill` | VERIFIED |
| `housing` | Find housing support | `.helpHub` | `house.fill` | VERIFIED (helpHub added) |
| `doctor` | Register with a GP | `.helpHub` | `cross.case.fill` | VERIFIED (helpHub added) |
| `work` | Work permits & rights | `.helpHub` | `briefcase.fill` | VERIFIED (helpHub added) |
| `taxes` | Taxes & toeslagen | `.governmentHub` | `eurosign.circle.fill` | VERIFIED |
| `emergency` | Emergency contacts | `.emergencyHub` | `phone.fill.arrow.up.right` | VERIFIED |
| `dutch` | Learn Dutch | `.languageHub` | `text.bubble.fill` | VERIFIED (languageHub added) |

---

## Reverse Mapping (aiRouteID from destination)

Verified that `aiRouteID(from:)` returns a non-nil string for every destination that `aiRoute(for:)` can produce. Round-trip verified for:

- `.searchList` ↔ `"search"`
- `.officialSources` ↔ `"officialSources"`
- `.firstSteps` ↔ `"firstSteps"`
- `.journeyDocuments` ↔ `"journeyDocuments"`
- `.practicalGuide(.transportBasics)` ↔ `"transport"`
- `.practicalGuide(.housingBasics)` ↔ `"housing"`
- `.practicalGuide(.healthcareBasics)` ↔ `"healthcare"`
- `.governmentHub` ↔ `"government"`
- `.emergencyHub` ↔ `"emergency"`
- `.mapHub` ↔ `"map"`
- `.assistantHub` ↔ `"assistant"`
- `.knm` ↔ `"knm"`
- `.dutchA1A2` ↔ `"dutch"`
- `.cityList` ↔ `"cities"`
- `.provinceList` ↔ `"provinces"`
- `.finesList` ↔ `"fines"`
- `.institutionsList` ↔ `"institutions"`
- `.settings` ↔ `"settings"`
- `.helpHub` ↔ `"help"` ✅ (new)
- `.languageHub` ↔ `"languagehub"` ✅ (new)

---

## AssistantStructuredResponseCard Navigation

`AssistantStructuredResponseCard` renders a `NavigationLink` when `response.appDestinationID != nil` and `AppDestination.aiRoute(for: response.appDestinationID)` returns non-nil. The link is:

```swift
NavigationLink(value: destination) {
    Label(openRelatedSectionLabel, systemImage: "arrow.right.circle.fill")
}
```

This uses the SwiftUI `NavigationStack` path — no programmatic navigation fragility.

---

## Deep Link / Quick Action Routes

`AINavigatorRoute` entries display as tappable route cards in the navigator section. Each card calls:

```swift
navigationPath.append(route.destination)
```

All 8 destinations are valid `AppDestination` cases present in the app's `NavigationStack` switch.

---

## Potential Issues

None blocking. One cosmetic note:

- `"dutch"` via `aiRoute(for:)` routes to `.dutchA1A2` (the A1/A2 course), while the navigator route `dutch` routes to `.languageHub` (the language hub). These are intentionally different: the free-text AI response sends users to the A1/A2 course content directly, while the navigator card sends to the hub overview. Both are correct for their context.
