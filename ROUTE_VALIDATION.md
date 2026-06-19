# Route Validation

Date: 2026-06-16

## Result

Status: pass for AI-known route coverage after fix-pass.

Measured in Xcode snippet against `KnowledgeIndex.shared`:

- total indexed items: 781
- indexed route IDs: 23
- missing known AI route IDs: 0
- unresolved indexed route IDs: 0

## Fixed In This Pass

Updated `AppDestination.aiRouteID(from:)`:

- `AppDestination.practicalGuide(.healthInsuranceBasics)` now maps to `healthinsurance`
- `AppDestination.practicalGuide(.findingHuisarts)` now maps to `huisarts`

Updated `KnowledgeIndexBuilder.appScreens()` with route-backed screen entries for:

- assistant
- cities
- provinces
- fines
- letters
- institutions
- settings
- knm
- dutch
- healthinsurance
- huisarts

## Required Regression Tests

Add automated tests that fail when:

- `Set(AppDestination.allKnownAIRouteIDs()).subtracting(Set(KnowledgeIndex.shared.items.compactMap(\.routeID)))` is non-empty
- any `KnowledgeItem.routeID` cannot resolve through `AppNavigationResolver.destination(for:)`
- any `AIResponseAction.destinationID` cannot resolve
- any graph relation points to a missing item ID

## Manual QA Routes

These must open without `Content not found`:

- Search
- Official Sources
- First Steps
- Documents
- Transport
- Housing
- Healthcare
- Health Insurance
- Huisarts
- Government
- Emergency
- Map
- Assistant
- KNM
- Dutch A1-A2
- Cities
- Provinces
- Fines
- Letters
- Institutions
- Settings
- Help
- Language Hub

## App Store Relevance

Apple expects apps to be complete and functional before submission, and broken links/routes are explicitly risky under App Review completeness guidance. Route validation remains a release gate.

Sources:

- Apple App Review: https://developer.apple.com/distribute/app-review/

