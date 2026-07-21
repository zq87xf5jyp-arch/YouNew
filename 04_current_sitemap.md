# Current sitemap

## Root

- Home
- Places (internally absorbs legacy Search and Map states)
- AI Assistant
- Saved
- More (opens overlapping full side-menu/navigation system)

`AppTab` additionally contains Search and Map, but `TabRouter.TabItem` maps both to Places. On regular width the same items can move to left/right/top; Home, More and side menu own separate navigation paths.

## Major branches

- Home → status, next steps, categories, city, map preview, travel, language, history, help, AI, partners
- Places → places list, map, search, province, city, place detail
- AI → assistant modes and linked answers
- Saved → saved articles, places, answers, routes
- More/side menu → country, provinces, cities, daily life, work, housing, healthcare, education, language, documents, money, transport, government, emergencies, culture, history, settings

## Structural defects

- Three navigation vocabularies: `AppTab`, `TabItem`, `IASection`.
- Geography is both category (`places`) and scope.
- Settings and useful content coexist in More.
- Guide is a collection of screens rather than one canonical index.
- Orphan/legacy risks: LegalInfoView, TranslatorView, SurvivalGuideView, MunicipalitySupportView, RisksView.

