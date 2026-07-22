# Evidence packet — Premium image pipeline

Status: **VERIFIED implementation / CATALOG RIGHTS PASS / PARTIAL runtime visual evidence**

Evidence date: 2026-07-22 (Europe/Amsterdam)

## 2026-07-22 evidence boundary update

The deterministic media-rights gate now inventories all 170 shipped catalog
assets and reports zero unresolved records: 58 byte-exact public-domain city
symbols, 36 documented project-owned assets, and 76 attribution-ready third-party
assets. Screenshots, recordings, audio, and public-site media remain separate
inventories; the catalog result does not clear those release artifacts.

## Original problem

The image-system audit recorded inconsistent image metadata, crop behavior, loading states, and fallback coverage across image-heavy screens. Full-resolution remote images also created avoidable decode and memory-pressure risk.

## Product requirement

Provide one reusable image path for local and remote media with role-aware layout, readable overlays, bounded loading, stable placeholders, validated fallbacks, and no blank image surfaces when a source fails.

## Implementation

- `PremiumImageView` and `AppContentImageView` select local, remote, and fallback sources and expose a consistent accessibility label.
- `PremiumImageRole` centralizes role-specific sizing and display policy; focal alignment and readability overlays are shared rather than screen-specific.
- Remote requests use a 12-second timeout, validate the response, downsample before display, coalesce in-flight work through an actor, and suppress stale view updates.
- Two bounded memory caches are configured: 160 objects / 80 MB for app-content images and 100 objects / 200 MB for the direct loader.

## Files

- `YouNew/Core/Imaging/AppContentImageView.swift`
- `YouNew/Core/Imaging/ImageLoader.swift`
- `YouNew/Core/DesignSystem/Components/NLDesignSystem.swift`
- `YouNew/Data/ContentMediaRegistry.swift`
- `YouNew/Data/CanonicalPlaceImageResolver.swift`
- `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift`

## Tests

- `YouNewTests/MediaRegistryTests.swift`
- `YouNewTests/PriorityCityHeroMediaTests.swift`
- Image, media, visual-system, and performance checks invoked by `scripts/run-static-qa.sh`
- The authoritative clean-clone snapshot is **460/460 unit tests passed** and
  **40/40 static commands passed**. These totals cover more than the image subsystem
  and are not image-only counts.

## Measurable result

The frozen offline media audit recorded 294 visible assignments, 294 unique URLs, and zero duplicate URL groups. This is a structural/offline result, not a live availability or visual-quality guarantee. The implementation also exposes the explicit cache and timeout limits listed above.

The clean-clone visible-image check reused no verified URL cache entries and made
zero network requests. Its PASS therefore proves structural coverage only; it does
not prove current remote reachability.

## Owner decision

The owner confirmed AppIcon and the six generated `premium_home_*` assets on
2026-07-22. Previously disputed catalog payloads were documented, replaced, or
removed. See `MEDIA_RIGHTS_OWNER_ATTESTATION.md` and
`ASSET_RIGHTS_STATUS.json`.

## Limitations

- Catalog clearance does not cover screenshots, recordings, audio, public-site
  media, or future assets; each requires its own inventory and review.
- Third-party Creative Commons conditions, credits, and modification notices
  remain mandatory; the repository source-code license does not replace them.
- There is no fresh per-device crop, contrast, Dynamic Type, and slow-network matrix.
- No current Instruments trace proves the memory or decode-latency benefit under sustained scrolling.
- Consumer cancellation prevents stale UI updates but does not prove cancellation of every detached shared network fetch.

## Safe public claim

The repository contains implementation and reports consistent with the documented Codex-assisted workflow.

YouNew contains a role-aware image-loading pipeline with bounded caches, request timeouts, downsampling, placeholders, and fallback behavior. Its shipped 170-asset catalog has complete deterministic rights records and zero unresolved assets; non-catalog release media and runtime visual validation remain separate gates.

## Screenshot or log still needed

A fresh final-build capture should show hero, card, loading, and forced-fallback states on at least one compact and one large iPhone, plus Dark Mode and Accessibility XXXL. Preserve the relevant static-QA transcript and a redacted Instruments or memory-pressure result if performance is claimed.
