# Home / More / Places — information architecture audit

## Current entry points

Home contains: Quick shortcuts (City, Places, Housing, Transport, Official), Official services, Places to visit, Housing, Transport, Leisure, Education, Local partners and Discover the Netherlands. Each category section is now a preview of at most four items followed by `View all`; the destination owns the full list.

More contains tab shortcuts (Home, Places, AI Assistant), persona-specific category shortcuts and reference/support libraries. Places contains map/list filters for Places, Food, Hotels, Transport, Healthcare, Government, Shopping, Education and Local partners.

## Duplicate matrix

Percentages compare destination/content identity, not just wording. `100%` means both entries resolve to the same full screen and data; lower values are semantic overlap between different datasets.

| Category | Screen A | Screen B | Match | Resolution |
|---|---|---:|---:|---|
| Places | Home → Quick shortcuts / Places to visit | Places tab → full map/list | 100% route/data | Home is a preview/shortcut; Places is canonical full browser. |
| Places to visit / Leisure | Home → Places to visit / Leisure | Places → Places/Food filters | 65% semantic | Home shows ≤4 curated shortcuts; full place data stays in Places. |
| Transport | Home → Transport | More → persona categories → Transport | 100% destination | Both use canonical `transport` ID and open the same Transport guide. |
| Transport nearby | Home/More → Transport guide | Places → Transport filter | 35% semantic | Guide is canonical editorial category; Places is only a location filter, not a second guide. |
| Housing | Home → Housing | More → persona categories → Housing | 100% destination | Both open the same Housing guide; Home is limited to four preview links. |
| Housing nearby | Home/More → Housing guide | Places → partner category Home/Hotels | 25% semantic | Places entries are local inventory; no copied housing guide text. |
| Official services | Home → Official services | More → Official sites / Government | 90% | Canonical top-level ID is `documentsGovernment`; shortcuts converge on Official Sources/Government routes. |
| Government nearby | Official services | Places → Government filter | 45% semantic | Places is a filtered directory of physical locations; editorial/official content remains canonical elsewhere. |
| Healthcare | Home → category shortcuts | More → Healthcare | 100% destination | Canonical `healthcare` points to the same Healthcare guide. |
| Healthcare nearby | Healthcare guide | Places → Healthcare filter | 40% semantic | Places is a nearby-service filter only. |
| Education | Home → Education | More → Study/language persona links | 60% semantic | Home is a four-item preview; institutions/course screens own full data. |
| Education nearby | Education category | Places → Education filter | 35% semantic | Places exposes nearby institutions only. |
| Local partners | Home → Local partners | More → Local partners | 100% data/destination | Both reference `MockLocalPartnersData` / the same partner detail route. Home remains a short preview. |
| Events | Home → Leisure / Discover | Places-related discovery lists | 55% semantic | Calendar is canonical for full event lists; Home entries are shortcuts. |
| AI Assistant | Home → Ask AI | AI Assistant tab / More shortcut | 100% feature | Home and More are entry points only; Assistant tab owns the conversation. |
| Saved | Cards throughout app | Saved tab | 100% item identity | Source screens only toggle a stable saved-item ID; Saved owns the complete list. |

## Canonical source of truth

`CanonicalContentRegistry` is the single registry for top-level IDs, localized titles/subtitles, symbols, accents and canonical routes. Its categories are: `startHere`, `places`, `transport`, `emergency`, `documentsGovernment`, `housing`, `healthcare`, `workStudy`, `foodLifestyle`, `calendarEvents`, and `aiAssistant`.

Content ownership remains deliberately separate from navigation metadata:

- Housing/editorial articles: Guide repository, reached through `housing`.
- Transport: `TransportGuideData`, reached through `transport`.
- Official services: official-source directory data, reached through `documentsGovernment`.
- Places and nearby filters: nearby-place/local-partner datasets, reached through `places`.
- Leisure/events: culture and calendar datasets, reached through `foodLifestyle` / `calendarEvents`.

## Header and safe-area rule

Category and detail screens use the native `NavigationStack` title with inline display (`nlNavigationInline`). The navigation bar owns the status-bar safe area; scroll views contain only the hero/preview content. Home intentionally hides the navigation bar and applies a top `safeAreaInset`. No screen positions its navigation title with a hard-coded status-bar offset.

## Post-change invariant

A top-level category has exactly one canonical full destination. Home and More render shortcuts; Places renders only place inventory and filters. A filter label such as Transport or Healthcare is not treated as an independent editorial category.
