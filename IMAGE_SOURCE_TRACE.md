# Image Source Trace

Date: 2026-06-10

Scope: runtime image paths for city, province, place, figure, featured city, map preview, and content media screens.

## Canonical Runtime Resolver

| Component | File reference | Model/data source | Fallback path | Cache key | Registry use | Notes |
|---|---:|---|---|---|---|---|
| Canonical place resolver | `YouNew/Data/CanonicalPlaceImageResolver.swift:85` | `NLCity`, `CityItem`, `NLProvince`, `ProvinceItem`, `HistoricalFigure`, `Attraction` | city -> province -> Netherlands -> bundled emergency, figure portrait -> symbolic category fallback | `ResolvedPlaceImage.cacheKey` at line 27 | Yes | New single resolver for place/person image decisions. |
| Debug image logging | `YouNew/Data/CanonicalPlaceImageResolver.swift:52` | `ImageDebugContext` from each caller | n/a | caller-provided cache key | n/a | Prints `[IMAGE DEBUG]` only under `#if DEBUG`. |
| Runtime assertions | `YouNew/Data/CanonicalPlaceImageResolver.swift:119`, `:157`, `:179`, `:201`, `:404` | city, province, figure, place resolved URLs | n/a | n/a | Yes | Catches duplicate visible city URLs, figure landscape URLs, Den Haag windmill places, Haarlem sky/cloud, and city fallback misuse. |

## Runtime Image Loaders

| Component | File reference | Model/data source | Fallback path | Cache key | Registry use | Bypass/hardcoded risk |
|---|---:|---|---|---|---|---|
| `CityImageView` | `YouNew/Components/ImageLoader.swift:240` | `urlString`, `fallbackURLStrings`, optional `placeId` | supplied URL -> supplied fallbacks -> registry fallbacks -> generated/bundled fallback | joined URL list at line 62, per candidate in loader | Uses registry only when a legacy `placeId` is supplied | Existing shared renderer; now accepts resolver fallback URLs and debug context. |
| `ImageLoader` | `YouNew/Components/ImageLoader.swift:47` | URL candidates from `CityImageView` | candidate variants in order | candidate URL, not failed primary when fallback succeeds | n/a | Fixed cache poisoning: fallback success is cached under fallback candidate, not the failed primary URL. |
| `AppContentImageView` | `YouNew/Components/AppContentImageView.swift:11` | `AppImageAsset` | local asset -> thumbnail/image/url -> original/fallback URLs -> bundled fallback | `([url] + fallbackURLs)` at line 230 | Indirect through assets, often verified media | Still used for non-place content and official symbol/media cards. |
| `CachedRemoteContentImage` | `YouNew/Components/AppContentImageView.swift:201` | `AppContentImageView` URL candidates | URL -> fallback URLs -> fallback view | each candidate absolute URL | n/a | DEBUG logging added for cache hits and remote loads. |

## Screen-Level Trace

| Screen/component | File reference | Source now used | Fallback path | Uses resolver | Previous risk |
|---|---:|---|---|---|---|
| Map province modal hero | `YouNew/Views/NetherlandsInteractiveMapView.swift:1248`, `:1272` | `resolveProvinceHero(province: ProvinceItem)` | province hero -> Netherlands fallback | Yes | Previously selected `province.media.heroImage?.url` locally before registry logic. |
| Map province city cards | `YouNew/Views/NetherlandsInteractiveMapView.swift:1499`, `:1506` | `resolveProvinceCityCard(city: CityItem)` | city hero -> province -> Netherlands | Yes | Previously local `city.media.heroImage?.url` path could bypass canonical checks. |
| Province detail hero | `YouNew/Views/ProvinceDirectoryView.swift:293`, `:299` | `resolveProvinceHero(province: ProvinceItem)` | province hero -> Netherlands fallback | Yes | Previously rendered through verified media view only. |
| Province city detail hero | `YouNew/Views/ProvinceDirectoryView.swift:1646`, `:1652` | `resolveCityHero(city: CityItem)` | city hero -> province -> Netherlands | Yes | Previously used verified media view only. |
| City detail hero | `YouNew/Components/NetherlandsCityViews.swift:104`, `:107` | `resolveCityHero(city: NLCity)` | city hero -> province -> Netherlands | Yes | Previously used `NLCity.imageURL` plus local `placeId`. |
| City places cards | `YouNew/Components/NetherlandsCityViews.swift:260`, `:263` | `resolvePlaceImage(place: Attraction)` | attraction URL -> Netherlands fallback | Yes | Previously used `Attraction.imageURL` directly. |
| Sidebar city cards | `YouNew/Components/NetherlandsCityViews.swift:716`, `:719` | `resolveCityThumbnail(city: NLCity)` | city hero -> province -> Netherlands | Yes | Previously used `NLCity.imageURL` directly. |
| Home hero | `YouNew/Views/HomeView.swift:364`, `:367` | `resolveCityHero(city: selectedHeroCity)` | city hero -> province -> Netherlands | Yes | Previously used `selectedHeroCity.imageURL` directly. |
| Home featured city | `YouNew/Views/HomeView.swift:829`, `:836` | `resolveCityHero(city:)` | city hero -> province -> Netherlands | Yes | Previously used `city.imageURL` directly. |
| Home backdrop asset | `YouNew/Views/HomeView.swift:2050` | `resolveCityHero(city:)` converted into `AppImageAsset` | asset fallback | Yes | Previously built asset from `city.imageURL`. |
| Cities directory tiles | `YouNew/Views/CitiesDirectoryView.swift:110`, `:113` | `resolveCityThumbnail(city: CityItem)` | city hero -> province -> Netherlands | Yes | Previously local helper picked `city.media.heroImage?.url`. |
| Cities directory rows | `YouNew/Views/CitiesDirectoryView.swift:176`, `:180` | `resolveCityThumbnail(city: CityItem)` | city hero -> province -> Netherlands | Yes | Same. |
| Nearby map city preview | `YouNew/Views/NearbyMapView.swift:405`, `:407` | `resolveCityThumbnail(city: CityItem)` | city hero -> province -> Netherlands | Yes | Previously used `AsyncImage` with `CityMediaValidator` directly. |
| Historical figures | `YouNew/Views/RootTabView.swift:1562`, `:1607` | `resolveFigureThumbnail(figure:)` | portrait URL -> symbolic category fallback | Yes | Previously used `CityImageView`, so people could inherit place-style fallbacks. |

## Remaining Documented Non-Place Image Paths

| Component | File reference | Source | Reason not replaced |
|---|---:|---|---|
| Country overview hero | `YouNew/Views/NetherlandsOverviewView.swift:8` | hardcoded Netherlands/Amsterdam canal URL | Country-level decorative hero, not city/province/person card. |
| Category hero visuals | `YouNew/Components/NetherlandsVisualComponents.swift:557` | `CategoryHeroVisual` asset/image URL | Category content, not place identity. |
| Side menu landmark hero | `YouNew/Views/RootTabView.swift:3908` | `SideMenuLandmarkRegistry` | Landmark gallery intentionally includes Kinderdijk as a landmark item. |
| Official symbols | `YouNew/Views/ProvinceDirectoryView.swift:1939` | flag/coat-of-arms symbol URLs | Official symbols, not hero photos. |
| LGBTQ support content images | `YouNew/Views/LGBTQSupportView.swift:436` | support item image URLs | Non-city content cards. |

## Summary

- City/province/person runtime-visible paths now route through `CanonicalPlaceImageResolver`.
- Known content-only image paths remain documented because they are not place identity images.
- DEBUG logging now reports screen, entity type, entity name, requested URL, resolved URL, fallback level, cache key, cache hit, and source registry.
