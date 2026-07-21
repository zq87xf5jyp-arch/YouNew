# Screen responsibilities

| Screen | Owns | May display | Must not own |
|---|---|---|---|
| Home | Current context, urgent action, next tasks, compact recommendations | References to canonical content, current city summary, search/AI entry | Full category catalog, copied article bodies, audience access rules |
| Guide | Complete thematic browse across eight categories | Every published canonical item, filters, related geography | Duplicate bodies, city/province hierarchy as categories |
| Map | Spatial browse and nearby discovery | Places, cities, provinces and coordinate-bearing services; linked articles | Nonspatial article catalog, persona-based omissions |
| Saved | User collections and progress references | Canonical item references from every content type | Independent copies or stale snapshots of content |
| More | Profile, language, accessibility, notifications, privacy, legal, feedback, about | Preference controls and account/product utilities | Guide categories, useful-content library, duplicated global menu |
| Global Search | Retrieval across the complete repository | All canonical content and entities with localized aliases | Separate search-only content records |
| AI action | Navigate, explain, summarize and translate repository content | Canonical citations, official links, current screen/geography context | Independent knowledge base, final medical/legal/tax authority |

## Home composition

Order: emergency/status → next action → current journey → current city → saved/recent → one discovery recommendation. Maximum seven sections. Audience and selected city change ordering only.

## Guide behavior

Guide opens to all eight categories. Optional chips may boost an audience, geography or content type. An active chip is always visible and removable. A “Show all” state returns every published item.

## Map behavior

Country, province and city are navigation scopes, not thematic tabs. Theme chips filter map markers by primary category. An article without coordinates can appear only as related content for a selected geographic entity.

## Search behavior

Search indexes titles, summaries, bodies where permitted, aliases, official acronyms, Dutch terminology and geographic names. Results deduplicate strictly by `canonical_id`; multiple matching contexts become badges, not duplicate rows.

## iOS navigation ownership

Each primary tab owns an independent navigation history. Search and AI present destinations inside the owning tab or a documented global route; they do not masquerade as another selected tab. Compact and regular layouts may change orientation, never count, order or meaning.

