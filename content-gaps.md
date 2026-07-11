# Content Gaps

Phase 1 audit only. No new factual production content, procedures, contacts, phone numbers, deadlines, amounts, addresses, or source URLs were added.

## Empty Or Restricted Routes

### Expat Route
- Audit classification: (1) data exists, but some cards/routes are too broad and may lead to thin or unrelated destinations; no missing source data was confirmed for the visible route shell.
- Data source: `UserPathProfile.expat` reuses `UserPathProfile.worker.recommendedSteps`; `StatusDirection.forStatus(.expat)` has primary needs, actions, documents, sources, and warnings.
- Render location: `StatusDirectionView`.
- Current risk: top route cards always render their containers. If the underlying steps/actions are unavailable or visually fail, the section has no local empty-state.
- Missing fields before adding new expat-specific content: verified per-step title, summary, destination, source type, last-checked metadata, and audience/persona scope.
- Required source type for new content: existing reviewed official immigration, tax, municipal, employment, or healthcare source already present in project data. Do not invent URLs.

### Legal Help
- Audit classification: (1) data exists, but it is inline UI data rather than structured reusable data.
- Data source: inline rows in `LegalHelpView`.
- Render location: `LegalHelpView` in `MoreHubView.swift`; navigation case `.legalHelp` in `AppDestinationView`.
- Current risk: the route is visible, but content cannot be audited, filtered, or reused consistently while it stays embedded in the view.
- Missing fields before expansion: stable id, localized title, localized description, category, verified source label, existing reviewed source URL if available, audience/persona scope, last-checked metadata, and emergency/legal disclaimer classification.
- Required source type for new content: verified legal/help source already reviewed for production use. Do not add unverified legal procedures, phone numbers, deadlines, eligibility rules, or URLs.

### LGBTQ Support
- Audit classification: (1) data exists, but route visibility is persona-gated.
- Data source: `MockLGBTQSupportData.items`; filtering in `LGBTQSupportViewModel`.
- Render location: `LGBTQSupportView`; navigation case `.lgbtqSupport` in `AppDestinationView`.
- Current gap: `AppDestinationView` opens `LGBTQSupportView` only when `selectedUserStatus?.personaTag == .lgbt`; otherwise it returns `notFoundView`. Several menus only show the route when `RelatedContentEngine.isVisible(.lgbtqSupport, for:)` returns true.
- Missing decision before changing UI: confirm whether this route should remain LGBT-only, be visible as a support library for all personas, or show a neutral access/empty-state outside the LGBT persona.
- Missing fields before expansion: verified item title, localized description, section/category, city/scope, accessibility tags, source label, existing reviewed source URL if available, last-checked metadata, and persona/audience scope.
- Required source type for new content: verified official or reviewed community/support source already approved for production. Do not add unverified crisis, medical, legal, police, or support contacts.

### Emotional Support
- Audit classification: (1) data exists, but it is inline UI data rather than structured reusable data.
- Data source: inline `EmotionalSupportItem.items`.
- Render location: `EmotionalSupportView` in `MoreHubView.swift`; navigation case `.emotionalSupport` in `AppDestinationView`.
- Current risk: the route has an empty-state branch, but the data is embedded in the view and cannot be audited or filtered through the same content model as other support content.
- Missing fields before expansion: stable id, localized title, localized description, category, source label, existing reviewed source URL if available, audience/persona scope, urgency/safety classification, last-checked metadata, and disclaimer classification.
- Required source type for new content: verified official or service source already reviewed for production. Do not add unverified crisis, medical, legal, support contacts, or URLs.

## Empty Container Risks

These views can render a section/container when their backing arrays are empty or too narrow, instead of hiding the section or showing a local empty-state.

- `HomeLifeTimelinePreviewSection`: `ProductScreenSection` renders even when `steps` is empty; source array is `LifeTimelineBuilder.steps(...)`.
- `HomeContextualRecommendationsSection`: `ProductScreenSection` + empty `LazyVGrid` render when `recommendations` is empty.
- `HomeQuickActionsSection`: header + empty grid render when `actions` is empty.
- `HomeCategoriesGridSection`: header remains even if both `categories` and `scenarios` are empty.
- `StatusDirectionView.workspaceTimelineSection`: outer `.appCardStyle()` renders regardless of `pathProfile.recommendedSteps`; currently expat has data, but the component has no empty-state.
- `StatusDirectionView.statusNextActionsSection`: outer `.appCardStyle()` renders regardless of `statusDirectionActions`; current array is static and non-empty, but the component has no guard.
- `ProvinceDirectoryView` city sections: several `ProductScreenSection` wrappers render directly over arrays such as `city.scorecard`, `city.firstWeekSteps`, `city.newcomerPlaces`, `city.localHighlights`, `city.timelineEvents`, `city.newcomerGuide`, `city.localHighlightFacts`, and `city.nearbyCities`.

## Image Asset Mapping

Focused map for the affected screens and shared fallback paths.

### Affected Screens
- Profile / Status route / student: `ContentMediaRegistry.leidenCanalsHero` -> asset id `content-guide-leiden-grachten`.
- Profile / Status route / expat, worker, highly skilled migrant: `ContentMediaRegistry.workImage` -> asset id `cover-work-zuidas` when bundled asset exists; fallback `ContentMediaRegistry.officialSourcesHero` -> asset id `content-guide-leiden-grachten`.
- More hero: `ContentMediaRegistry.officialSourcesHero` -> asset id `content-guide-leiden-grachten`; local fallback `CuratedPlaceHeroMediaRegistry.bundledNeutralFallbackAssetName` -> `home_leiden_canals`.
- Legal Help hero: `ContentMediaRegistry.municipalityCityHallImage` -> asset id `content-government-haarlem-city-hall`; fallback `officialSourcesHero` -> `content-guide-leiden-grachten`.
- LGBTQ Support hero: `ContentMediaRegistry.healthcareBasicsImage` -> asset id `content-healthcare-dutch-pharmacy`; fallback chain includes `profileImage` and `officialSourcesHero`.
- LGBTQ Support thumbnails without item image: generated category artwork; thumbnails with failing image use `CuratedPlaceHeroMediaRegistry.bundledNeutralFallbackAssetName` -> `home_leiden_canals`.
- Emotional Support hero: `ContentMediaRegistry.healthcareBasicsImage`; fallback chain includes `profileImage`, `emergencyImage`, and `officialSourcesHero`.
- AI Assistant hero: `ContentArtworkRegistry.asset(.aiHero)` -> `ContentMediaRegistry.aiImage` -> asset id `cover-ai-assistant`; fallback `officialSourcesHero`.
- AI Assistant prompt previews: `promptImageAsset(for:)` builds ids `assistant-prompt-{localAssetName}`. Known mappings: government/tax -> `home_documents_city_hall`; fines/rules -> `premium_home_documents`; healthcare -> `premium_home_healthcare`; work -> `premium_home_work`; unknown/default -> `home_leiden_canals`.

### Shared Assets And Fallbacks
- `content-guide-leiden-grachten` / local `home_leiden_canals` is used as `officialSourcesHero`, `leidenCanalsHero`, More hero, student route hero, education fallback, AI prompt default, and the default local fallback in `AppContentImageView`.
- `content-home-amsterdam-canal-houses` is exposed as `homeAtmosphereHero` and `canalHousesHero`; `ContentArtworkRegistry.asset(.cityHeroFallback)` uses it before `leidenCanalsHero`.
- `AppContentImageView` default `fallbackLocalAssetName` is `CuratedPlaceHeroMediaRegistry.bundledNeutralFallbackAssetName`, currently `home_leiden_canals`.
- `CuratedPlaceHeroMediaRegistry.cityPlaceholderAssetName` equals the same bundled neutral fallback, so missing city imagery also falls back to `home_leiden_canals`.
- `ContentArtworkRegistry.duplicateArtworkViolations()` already models slot-level duplicate detection, but the current fallback design still allows broad reuse through `officialSourcesHero`, `cityHeroFallback`, and `AppContentImageView` defaults.

## Phase 2 Plan

1. Route/render fixes: keep existing data only; connect route-gated support screens to visible content or an explicit empty/access state. One bug per commit.
2. Empty-container fixes: add guards or neutral empty-states around sections that render headers/cards over empty arrays. Do not add production facts.
3. Structured support data: move inline Legal Help and Emotional Support rows only if using existing values; otherwise record missing fields here.
4. Image dedup: replace generic canal fallbacks with category-neutral generated placeholders or distinct existing assets. Keep `AppContentImageView` intact.
5. AI prompt previews: replace default `home_leiden_canals` behavior with topic-specific existing assets or generated category placeholders.

