# Duplicate Image Report

Date: 2026-06-17

## Current Status

Static duplicate checks pass for curated city heroes and province city-card images. The city role system now enforces unique URLs per city across hero, landmark, culture, night, thumbnail, and card roles for all 29 visible province-directory cities.

Runtime tests also enforce unique photo URLs for all city attractions and all `TourismAttractionCatalog` records.

The visible-surface duplicate audit now checks city visual roles, province visual roles, runtime city attractions, and tourism catalog records together. Wikimedia thumbnail URLs are normalized to their underlying source file before comparison.

Result: 294 visible image assignments checked, 0 exact normalized source-file duplicate groups.

Visible source consistency: 294 visible image assignments are restricted to Wikimedia hosts (`commons.wikimedia.org` or `upload.wikimedia.org`) and are checked for screenshot, logo, watermark, placeholder, stock, and guessed-image tokens.

Repeatable command: `python3 scripts/visible-image-remote-qa.py --offline`

Remote metadata, dimension, and aspect-ratio status: `python3 scripts/visible-image-remote-qa.py --commons-metadata --enforce-dimensions --enforce-aspect-ratio --sleep 1.0 --timeout 20 --failure-report VISIBLE_IMAGE_REMOTE_FAILURES.md` checked 294 visible assignments, 294 unique URLs, and 294 Commons file titles with 0 duplicate source groups, 0 confirmed missing files, 0 undersized visible source files, and 0 unsafe source aspect ratios.

Current unresolved-title worklist: 0 city-role images, 0 province-role images, 0 runtime city-attraction images, and 0 tourism catalog images in `VISIBLE_IMAGE_REMOTE_FAILURES.md`.

The validator now distinguishes confirmed `missing` Commons titles from transient API/network failures. A throttled run should be treated as unproven, not as a definitive missing-file list.

## Duplicate Classes Checked

- Same city hero across multiple cities: none in curated active registry.
- Same province hero across multiple provinces: none in curated active registry.
- Same city thumbnail and city hero: removed for all province-directory cities with role metadata.
- Same province city card and city hero: removed for all province-directory cities with role metadata.
- Same attraction photo across city attraction cards: none in runtime `NLCity.all`.
- Same tourism catalog photo across tourism categories: none in `TourismAttractionCatalog.records`.
- Same source image reused between city roles, province roles, city attractions, and tourism catalog cards: none.
- Same subject title or same asset identity reused inside the city visual system: none. `scripts/image-runtime-data-qa.py` now checks city role titles and asset names globally across city visuals.
- Same subject title or same asset identity reused inside the province visual system: none. `scripts/image-runtime-data-qa.py` now checks province role titles and asset names globally across province visuals.
- Missing six-role city visual coverage in the province directory: none. `scripts/image-runtime-data-qa.py` checks 29 city role sets.
- Weak visual metadata, placeholder markers, stock/generic markers, and missing safe-area purpose text: none. `scripts/image-runtime-data-qa.py` checks title, purpose, minimum width, and crop-protection wording for city and province roles.
- Legacy weak safe-area default: none. The active default policy explicitly protects full towers, bridges, windmill sails, castle facades, monuments, waterfront edges, and skylines, and `scripts/image-runtime-data-qa.py` fails if the old vague default returns.
- Missing province role sets, reused province role files across provinces, missing tourism categories, weak tourism metadata, and runtime attraction records without explicit relationship metadata: none. `scripts/image-runtime-data-qa.py` checks 12 province role sets, 23 tourism catalog records, and 37 runtime city attractions.
- Stretch-prone rendering paths on city, province, tourism, and shared content image surfaces: none detected by `scripts/image-render-static-qa.py`. The gate checks stable frames, aspect-fill clipping, documentary fit behavior, display-aware city image targets, and 1200px tourism catalog requests.
- 960px legacy card/hero requests in visual registries: removed from curated city/province roles and runtime attractions.
- Wrong Den Haag attraction imagery: no Kinderdijk/windmill fallback on Binnenhof, Peace Palace, Scheveningen, or Mauritshuis.
- Historical figure using place landscape image: blocked by static QA.

## Replaced Duplicate Classes

- City attractions no longer reuse city role source files for Rijksmuseum, Markthal, Cube Houses, Erasmus Bridge, Binnenhof, Mauritshuis, Scheveningen, Molen de Valk, Hortus Leiden, Dom Tower, Oudegracht, Museum Speelklok, Martinitoren, Groninger Museum, Nijmegen attractions, Arnhem bridge/Veluwe cards, Maastricht attractions, Eindhoven attractions, Delft attractions, Haarlem museums, Hoge Veluwe, and Kroller-Muller.
- Province roles no longer reuse city role source files for Rotterdam skyline, Binnenhof, Scheveningen, Dom Tower, Martinitoren, Groninger Museum, Nijmegen Waalbrug, Vrijthof, Delft, or Haarlem Grote Markt.
- Tourism catalog records no longer reuse city attraction or province role source files for Van Gogh Museum, Erasmus Bridge, Peace Palace, Mauritshuis, Groninger Museum, Valkenburg, Hoge Veluwe, Biesbosch, Scheveningen, Domburg, Valkhof, Sonsbeek, Maastricht, Kinderdijk, Dominicanen, or Teylers.
- Confirmed exact-title replacement work cleared every visible city-role metadata failure while preserving 0 visible source duplicates.

## Intentional Non-Duplicates

Some locations are visually related but use separate URLs and roles:

- Amsterdam canal hero, canal thumbnail, and bridge card are separate files.
- Rotterdam hero, bridge landmark, night bridge, cube houses, and skyline are separate files.
- The Hague uses Peace Palace, Binnenhof, Mauritshuis, Scheveningen, Hofvijver, and pier imagery separately.
- Utrecht uses Dom Tower, Oudegracht, Museum Speelklok, and Utrecht Centraal separately.

## Remaining Manual QA

- Load city directory, city detail, province directory, province detail, culture, history, and tourism screens on device.
- Open `VISUAL_AUDIT_GALLERY.html` for simulator-independent crop review of current city, province, and tourism records in aspect-fill frames.
- Confirm no remote image fails into emergency fallback.
- Confirm aspect-fill crops do not cut Dom Tower, Martinitoren, Nieuwe Kerk, Molen de Valk, Erasmus Bridge, Waalbrug, John Frost Bridge, castles, or Delta Works.
- Keep `python3 scripts/image-render-static-qa.py` in the static gate before final release so shared render paths cannot regress to stretched or uncropped image behavior.
- Re-run Commons metadata, dimension, and aspect-ratio validation with `python3 scripts/visible-image-remote-qa.py --commons-metadata --enforce-dimensions --enforce-aspect-ratio --sleep 1.0 --timeout 20 --failure-report VISIBLE_IMAGE_REMOTE_FAILURES.md` when doing final network/device release QA.
- `simctl` screenshot/crop QA remains blocked by CoreSimulatorService connection failure in this environment.
