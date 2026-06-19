# City Visual Map

Date: 2026-06-17

## Rule

Each visible city has six unique visual roles. The image must answer why it is there, and role reuse inside a city is a failure.

Enforcement: `PriorityCityHeroMediaTests.activeCitiesHaveUniqueRoleSpecificVisuals` verifies all six roles for every active `NLCity.all` city, unique role URLs per city, no placeholder strings, non-empty purpose text, and minimum role widths. `scripts/image-runtime-data-qa.py` now extends the same six-role requirement to every visible `ProvinceCatalog` city, including province-directory city rows and city-detail heroes. `PriorityCityHeroMediaTests.activeCityRoleVisualsAreGloballyUnique` verifies that active city role files are globally unique across cities, and `PriorityCityHeroMediaTests.visibleVisualSurfacesDoNotReuseSourceImageFiles` checks those city role files against province roles, city attractions, and tourism catalog records.

Remote metadata, dimension, and aspect-ratio release gate: `python3 scripts/visible-image-remote-qa.py --commons-metadata --enforce-dimensions --enforce-aspect-ratio --sleep 1.0 --timeout 20 --failure-report VISIBLE_IMAGE_REMOTE_FAILURES.md` currently checks 294 visible assignments, 294 unique URLs, and 294 Commons file titles with 0 duplicate source groups, 0 confirmed missing files, 0 undersized visible sources, and 0 unsafe source aspect ratios.

## Visible City Map

| City | Hero | Landmark | Culture | Night | Thumbnail | Card |
|---|---|---|---|---|---|---|
| Amsterdam | Damrak canal houses and Oude Kerk | Dam Square / Royal Palace | Rijksmuseum | Canal night reflections | Canal houses | Keizersgracht bridge |
| Rotterdam | Erasmus Bridge from Euromast | Erasmus Bridge | Markthal | Erasmus Bridge by night | Cube Houses | Rotterdam skyline |
| Den Haag | Peace Palace | Binnenhof | Mauritshuis | Scheveningen pier at night | Scheveningen beach | Hofvijver / Binnenhof |
| Leiden | Oude Vest canal | Molen de Valk | Hortus Botanicus | Leiden canals by night | Leiden canal houses | Leiden University |
| Utrecht | Dom Tower from Oudegracht | Dom Tower | Museum Speelklok | Oudegracht by night | Oudegracht wharves | Utrecht Centraal |
| Groningen | Grote Markt and Martinitoren | Martinitoren | Groninger Museum | Groningen by night | Grote Markt | Academiegebouw |
| Nijmegen | Waalbrug | Waalbrug at night | Valkhof Museum | Waal river night | Valkhof Park | Stevenskerk |
| Arnhem | John Frost Bridge | John Frost Bridge close view | Openluchtmuseum | Rhine bridge at night | Sonsbeek Park | Arnhem centre |
| Maastricht | Vrijthof / Magisch Maastricht | Vrijthof Square | Dominicanen Bookstore | Vrijthof by night | Basilica of St. Servatius | Maas river |
| Eindhoven | Witte Dame | Evoluon | Van Abbemuseum | Lichttoren by night | Philips Museum | Strijp-S |
| Delft | Market / Nieuwe Kerk view | Nieuwe Kerk | Royal Delft | Delft canals by night | Delft canal | Prinsenhof |
| Haarlem | Grote Markt | Sint-Bavokerk | Frans Hals Museum | Haarlem by night | Teylers Museum | Historic hofje |
| Alkmaar | Waagplein | Grote Sint-Laurenskerk | Stedelijk Museum | Alkmaar canals by night | Accijnstoren | Molen van Piet |
| Hoorn | Harbor | Hoofdtoren | Westfries Museum | Harbor by night | Roode Steen | Oosterkerk |
| Zaanstad | Inntel / Zaan architecture | Czaar Peterhuisje | Zaans Museum | Zaandam station at night | City hall | Hembrugterrein |
| Amstelveen | Stadshart | Cobra Museum | Jan van der Togt Museum | Stadshart at night | Amsterdamse Bos | Amstelveen tram line |
| Purmerend | Koemarkt | Purmerends Museum | Theater de Purmaryn | Centre by night | Melkwegbrug | Where canal |
| Heerhugowaard | Station / Dijk en Waard hub | Poldermuseum | Cool kunst en cultuur | Middenwaard at night | Park van Luna | Polder setting |
| Amersfoort | Koppelpoort | Onze Lieve Vrouwetoren | Mondriaanhuis | Koppelpoort by night | Muurhuizen | Canal centre |
| Tilburg | Spoorzone | Heuvelse Kerk | TextielMuseum | Tilburg kermis at night | LocHal | Piushaven |
| Breda | Grote Markt | Grote Kerk | Begijnhof | Market at night | Kasteel van Breda | Harbor |
| Den Bosch | Sint-Janskathedraal | Binnendieze | Noordbrabants Museum | Old centre by night | Markt | Jheronimus Bosch Art Center |
| Venlo | Maas waterfront | Town hall | Limburgs Museum | Market at night | Sint Martinuskerk | Maasboulevard |
| Zwolle | Sassenpoort | Peperbus tower | Museum de Fundatie | Centre by night | Thorbeckegracht | Grote Markt |
| Almere | City centre | The Wave | Kunstlinie | Skyline by night | Oostvaardersplassen edge | Weerwater |
| Lelystad | Bataviawerf | Batavia replica | Aviodrome | Batavia Stad at night | Lelystad harbor | Markermeer dike |
| Leeuwarden | Oldehove | Waag | Fries Museum | Canals by night | Blokhuispoort | Nieuwestad |
| Assen | Drents Museum | TT Circuit | Kloosterkerk | Centre by night | Vaart | Asserbos |
| Middelburg | Town hall | Lange Jan | Zeeuws Museum | Market by night | Abbey | Canal |

## Coverage Result

`python3 scripts/image-runtime-data-qa.py` now checks 29 province catalog city role sets. Result: 29 complete, 0 missing role sets, 0 within-city duplicate source files.

The same gate also checks city visual metadata for title, purpose, role width, safe-area/crop-protection wording, and forbidden placeholder/stock/generic markers, plus 37 runtime city attraction photos with explicit location, why-visit, best-season, and photo-purpose metadata.

`python3 scripts/image-render-static-qa.py` checks the shared city image rendering path for aspect-fill, stable height frames, clipping, and display-aware target width so city photos cannot be stretched by a future component edit.

## Crop Rules

Default safe-area policy: aspect fill must keep the focal subject centered while protecting full towers, bridges, windmill sails, castle facades, monuments, waterfront edges, and skylines. `scripts/image-runtime-data-qa.py` fails if the old vague safe-area default returns.

- Amsterdam: protect canal horizon and church skyline.
- Rotterdam: protect bridge pylon and skyline.
- Den Haag: protect Peace Palace, Binnenhof, and pier structure.
- Leiden: protect windmill sails and canal edges.
- Utrecht: protect full Dom Tower height.
- Groningen: protect full Martinitoren height.
- Nijmegen: protect Waalbrug arch.
- Arnhem: protect John Frost Bridge span.
- Maastricht: protect Vrijthof basilica skyline.
- Eindhoven: protect Evoluon circle and Witte Dame facade.
- Delft: protect Nieuwe Kerk tower.
- Haarlem: protect Sint-Bavo roofline and tower.
- Amersfoort, Zwolle, Leeuwarden, Middelburg, Breda, Tilburg, Den Bosch, Assen, and Alkmaar: protect church towers, city gates, and civic spires.
- Hoorn, Purmerend, Venlo, Almere, Lelystad, and Middelburg: protect harbor, canal, bridge, and waterfront edges.
- Alkmaar and Purmerend: protect windmill sails or bridge arcs where used.
