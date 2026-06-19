# Province Visual Map

Date: 2026-06-17

## Rule

Every province has five distinct roles: landscape, culture, nature, architecture, and tourism. The province may use its cities, but only when the city image explains the province's identity.

Enforcement: `PriorityCityHeroMediaTests.provinceVisualRolesAreCompleteAndUnique` verifies all five roles for every province, unique role URLs per province, no placeholder strings, non-empty purpose text, and minimum role widths. `PriorityCityHeroMediaTests.visibleVisualSurfacesDoNotReuseSourceImageFiles` also checks province roles against city roles, city attractions, and tourism catalog records.

Static duplicate audit: `python3 scripts/visible-image-remote-qa.py --offline` currently checks 294 visible image assignments across city roles, province roles, city attractions, and tourism catalog cards with 0 normalized source-file duplicate groups.

Remote metadata, dimension, and aspect-ratio release gate: `python3 scripts/visible-image-remote-qa.py --commons-metadata --enforce-dimensions --enforce-aspect-ratio --sleep 1.0 --timeout 20 --failure-report VISIBLE_IMAGE_REMOTE_FAILURES.md` currently checks 294 visible assignments, 294 unique URLs, and 294 Commons file titles with 0 duplicate source groups, 0 confirmed missing files, 0 undersized visible sources, and 0 unsafe source aspect ratios.

Runtime data QA also checks 12 complete province visual role sets, cross-province source uniqueness, province visual metadata for title, purpose, role width, safe-area/crop-protection wording, and forbidden placeholder/stock/generic markers.

Default safe-area policy: aspect fill must keep the focal subject centered while protecting full towers, bridges, windmill sails, castle facades, monuments, waterfront edges, and skylines. `scripts/image-runtime-data-qa.py` fails if the old vague safe-area default returns.

| Province | Landscape | Culture | Nature | Architecture | Tourism |
|---|---|---|---|---|---|
| Noord-Holland | Keukenhof tulips and windmill | Zaanse Schans heritage | Zandvoort beach | Zaanse Schans | Alkmaar cheese market |
| Zuid-Holland | Kinderdijk windmills | Ridderzaal / Binnenhof | Meijendel dunes | Rotterdam port architecture | Delft canals |
| Utrecht | Utrechtse Heuvelrug | Oudegracht wharf culture | Loosdrechtse Plassen | Rietveld Schroder House | Amersfoort Koppelpoort |
| Gelderland | Hoge Veluwe | Paleis Het Loo | Veluwe heathland | Doorwerth Castle | Nijmegen Waalkade |
| Noord-Brabant | Biesbosch | Brabant carnival | Loonse en Drunense Duinen | Sint-Janskathedraal | Efteling |
| Limburg | Hills near Vijlen | Limburg carnival | Vaalserberg | Valkenburg castle ruins | Maastricht historic centre |
| Overijssel | Giethoorn canals | Deventer book market | Weerribben-Wieden | Zwolle Sassenpoort | Giethoorn boats |
| Flevoland | Oostvaardersplassen | Bataviawerf | Marker Wadden beach | Almere city centre | Schokland |
| Groningen | Hoge der Aa | Noorderzon festival at night | Groningen salt marsh | Goudkantoor / brick architecture | Bourtange fortress |
| Friesland | Frisian coast | Leeuwarden Waag | Frisian lakes sunrise | Sneek Waterpoort | Skutsjesilen spectators |
| Drenthe | Hunebed D27 | Van Gogh House Drenthe | Dwingelderveld heath | Drents Museum | TT Circuit Assen grandstand |
| Zeeland | Oosterscheldekering | Middelburg town hall | Zeeland beach dunes | Delta Works barrier | Domburg beach |

## Uniqueness Decisions

- Windmills are allowed only where they are geographically specific: Kinderdijk for Zuid-Holland, Zaanse Schans for Noord-Holland, Molen de Valk for Leiden.
- Utrecht province no longer relies on generic windmill fallback.
- Drenthe is anchored by hunebedden and heath, not city skylines.
- Flevoland is anchored by reclaimed-land nature and new-town architecture.
- Zeeland is anchored by Delta Works and coast.
