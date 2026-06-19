# Tourism Visual Map

Date: 2026-06-17

## Categories

- Top Attractions
- Museums
- Castles
- Nature
- Beaches
- Parks
- Historic Centres
- UNESCO Sites
- Hidden Gems
- Day Trips

## Attraction Requirements

Each attraction must have photo, location, description, why visit, and best season. Images must represent the specific attraction, not the nearest famous city.

Runtime implementation:

- `TourismCategory` defines all required categories in app data.
- `Attraction` now carries category, location, why-visit, best-season, and photo-purpose metadata for city detail cards.
- `TourismAttractionCatalog.records` provides a category-level tourism catalog with unique photos and required descriptive fields.
- `CultureAttractionsView` now presents the tourism catalog as a category rail with attraction cards, 1200px target image loading, location, why-visit, and best-season fields.
- `PriorityCityHeroMediaTests.tourismCatalogCoversAllCategoriesWithUniqueSpecificPhotos` enforces category coverage and unique photo URLs when Xcode tests are available.
- `PriorityCityHeroMediaTests.runtimeTourismAttractionsHaveRequiredRelationshipMetadata` enforces city attraction metadata and card-image sizing when Xcode tests are available.
- `python3 scripts/image-runtime-data-qa.py` now independently enforces all 10 tourism categories, 23 tourism catalog records with photo/location/description/why-visit/best-season fields, and 37 runtime city attractions with explicit relationship metadata.
- `python3 scripts/image-render-static-qa.py` verifies tourism catalog cards use the shared city image rendering path, stable card height, display-aware loading, and a 1200px target request.
- `PriorityCityHeroMediaTests.visibleVisualSurfacesDoNotReuseSourceImageFiles` enforces that tourism catalog photos do not reuse city role, province role, or runtime city attraction source files.
- `python3 scripts/visible-image-remote-qa.py --offline` currently checks 294 visible image assignments across city roles, province roles, city attractions, and tourism catalog cards with 0 normalized source-file duplicate groups.
- The same visible-image gate restricts visible tourism photos to Wikimedia hosts and rejects screenshot, logo, watermark, placeholder, stock, and guessed-image URL tokens.
- `python3 scripts/visible-image-remote-qa.py --commons-metadata --enforce-dimensions --enforce-aspect-ratio --sleep 1.0 --timeout 20 --failure-report VISIBLE_IMAGE_REMOTE_FAILURES.md` currently checks 294 visible assignments, 294 unique URLs, and 294 Commons file titles with 0 duplicate source groups, 0 confirmed missing files, 0 undersized visible sources, and 0 unsafe source aspect ratios.

| Category | Attraction | Location | Photo Identity | Why Visit | Best Season |
|---|---|---|---|---|---|
| Top Attractions | Rijksmuseum | Amsterdam | Rijksmuseum facade / Museumplein | Dutch national art and history collection | Year-round |
| Top Attractions | Erasmus Bridge | Rotterdam | Bridge and Maas skyline | Modern Rotterdam symbol | Year-round, blue hour |
| Top Attractions | Peace Palace | Den Haag | Peace Palace facade | International law landmark | Spring-autumn |
| Museums | Van Gogh Museum | Amsterdam | Museum building | Largest Van Gogh collection | Year-round |
| Museums | Mauritshuis | Den Haag | Mauritshuis exterior | Vermeer and Rembrandt collection | Year-round |
| Museums | Groninger Museum | Groningen | Postmodern museum building | Northern contemporary culture signal | Year-round |
| Castles | Doorwerth Castle | Gelderland | Castle and moat | River estate and medieval history | Spring-autumn |
| Castles | Valkenburg Castle Ruins | Limburg | Hilltop ruins | Limburg marl and castle landscape | Spring-autumn |
| Nature | Hoge Veluwe | Gelderland | Heath, forest, sand | National park plus Kroller-Muller | Spring-autumn |
| Nature | Biesbosch | Noord-Brabant | Freshwater tidal wetlands | Wetland boating and nature | Spring-summer |
| Beaches | Scheveningen Beach | Den Haag | Beach, pier, coast | Most recognizable urban beach | Summer |
| Beaches | Domburg Beach | Zeeland | Dunes and wide beach | Zeeland seaside tourism | Summer |
| Parks | Valkhof Park | Nijmegen | Hilltop park ruins | Roman-medieval city view | Spring-autumn |
| Parks | Sonsbeek Park | Arnhem | Green park landscape | Arnhem green-city identity | Spring-autumn |
| Historic Centres | Delft Historic Centre | Delft | Nieuwe Kerk / canals | Vermeer, Delft Blue, royal history | Year-round |
| Historic Centres | Maastricht Historic Centre | Maastricht | Vrijthof / Maas old city | Southern old-city character | Spring-winter |
| UNESCO Sites | Amsterdam Canal Ring | Amsterdam | Canal ring houses | Water, trade, Golden Age planning | Year-round |
| UNESCO Sites | Kinderdijk | Zuid-Holland | Windmills and waterways | Dutch polder water management | Spring-autumn |
| UNESCO Sites | Schokland | Flevoland | Former island landscape | Reclaimed-land history | Spring-autumn |
| Hidden Gems | Dominicanen Bookstore | Maastricht | Church bookstore interior | Reused sacred architecture | Year-round |
| Hidden Gems | Teylers Museum | Haarlem | Oldest museum facade | Science/art cabinet heritage | Year-round |
| Day Trips | Giethoorn | Overijssel | Canals and thatched houses | Water village experience | Spring-summer |
| Day Trips | Alkmaar Cheese Market | Noord-Holland | Waagplein cheese carriers | Distinct market ritual | Spring-summer |

## Runtime City Attraction Metadata

City attraction cards now expose location, why visit, and best season. Examples:

- Rijksmuseum: Amsterdam, Noord-Holland; museum category; facade image distinct from Amsterdam canal hero.
- Erasmus Bridge: Rotterdam, Zuid-Holland; top-attraction category; night bridge image distinct from Rotterdam hero.
- Peace Palace: Den Haag, Zuid-Holland; top-attraction category; law-and-diplomacy image distinct from Binnenhof and Scheveningen.
- Molen de Valk: Leiden, Zuid-Holland; top-attraction category; windmill identity specific to Leiden, not generic Kinderdijk fallback.
- Dom Tower: Utrecht, Utrecht; top-attraction category; full tower landmark protected.
- Dominicanen Bookstore: Maastricht, Limburg; hidden-gem category; church bookstore image, not city hero imagery.

## Rejection Rules

- Do not use city hero images for attraction cards.
- Do not use province landscapes for museums.
- Do not use Amsterdam canal imagery for Leiden, Delft, Utrecht, or Haarlem.
- Do not use Kinderdijk as generic Netherlands fallback.
- Do not reuse the same source image file between a tourism catalog card and a city or province identity role.
