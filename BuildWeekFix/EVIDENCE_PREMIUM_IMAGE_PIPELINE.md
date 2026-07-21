# Evidence packet — Premium image pipeline

Status: **VERIFIED implementation / PARTIAL runtime and rights evidence**

Evidence date: 2026-07-21 (Europe/Amsterdam)

## 2026-07-21 evidence boundary update

Implementation and static image checks do not grant redistribution rights. Public
handoff remains blocked by 39 tracked raster captures (91,034,208 bytes), 98
non-manifest imagesets, the AppIcon, one missing manifest license URL, and seven
untracked public-site media files not protected by the current ignore rules. No
blanket ownership or license claim is made for any unresolved item.

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

Before a public repository or submission, the owner must approve the final media allowlist and either document, replace, or exclude every asset whose source or reuse rights remain unresolved.

## Limitations

- Complete license/source evidence is not yet available for every bundled or
  curated image. In particular, 98 asset-catalog imagesets are outside the reviewed
  72-entry image-pack manifest, and some identity-asset provenance records conflict.
- There is no fresh per-device crop, contrast, Dynamic Type, and slow-network matrix.
- No current Instruments trace proves the memory or decode-latency benefit under sustained scrolling.
- Consumer cancellation prevents stale UI updates but does not prove cancellation of every detached shared network fetch.

## Safe public claim

The repository contains implementation and reports consistent with the documented Codex-assisted workflow.

YouNew contains a role-aware image-loading pipeline with bounded caches, request timeouts, downsampling, placeholders, and fallback behavior. Media rights and complete runtime visual validation remain separate submission gates.

## Screenshot or log still needed

A fresh final-build capture should show hero, card, loading, and forced-fallback states on at least one compact and one large iPhone, plus Dark Mode and Accessibility XXXL. Preserve the relevant static-QA transcript and a redacted Instruments or memory-pressure result if performance is claimed.
