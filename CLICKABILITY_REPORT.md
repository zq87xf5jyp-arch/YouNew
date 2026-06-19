# Clickability Report

Date: 2026-06-11

## Fixes Applied

| Button / Route | Root Cause | Fix | Working Status |
| --- | --- | --- | --- |
| Saved hub items: Government, Help, Language, History/KNM, Emergency, Categories | `SavedItemsStore` did not persist these `AppDestination` cases, so saved cards could reload without a destination | Added persisted enum cases and round-trip mapping | Fixed statically |
| Documents: My Docs | Button existed but did not navigate or move the user | Added `ScrollViewReader` and scrolls to document list | Fixed statically |
| Documents: Prepare Print | Button did not move the user to printable saved documents | Added scroll to document list | Fixed statically |
| Documents: Needed Docs | Button did not navigate or move the user | Added scroll to required-documents section | Fixed statically |
| Documents: Scan | Camera access could be attempted without a generated privacy key | Added `NSCameraUsageDescription` and kept graceful unavailable alert | Fixed statically |
| Documents: Letters | Opens `LettersView` | Existing destination preserved | Working statically |
| Documents: Official Sources | Opens `OfficialSourceDirectoryView` | Existing destination preserved | Working statically |

## Navigation Surface Checked

| Area | Destination Coverage |
| --- | --- |
| Home | Category, city, province, checklist, search, feedback destinations present |
| Map | Province list/detail, focused map destinations, city detail destinations present |
| Search | Search list and answer detail destinations present |
| Bookmarks | Saved destination persistence improved for hub routes |
| Settings | Settings route present |
| Cities | City list/detail routes present |
| Provinces | Province list/detail/cities routes present |
| Transport | Practical guide route to transport view present |
| Housing | Practical guide route present |
| Healthcare | Practical guide/resources routes present |
| Emergency | Emergency hub route present |
| Government | Government hub/institution routes present |
| History | History/KNM routes present |
| AI Assistant | Assistant route and supporting links present |

## Remaining Runtime QA

Device tap testing is still required. This pass proves route definitions and fixed known dead buttons statically; it does not prove gesture/runtime behavior because simulator runtime is unavailable.
