# Missing City Assets

Generated: 2026-06-10

This file tracks local Retina hero assets still missing from `YouNew/Assets.xcassets`. The app now has city-specific remote hero imagery and a complete fallback chain, but these local assets should still be bundled before App Store release for fully offline premium rendering.

Required format for each asset: 16:9 raster image, 2400 x 1350 px minimum, 3200 x 1800 px preferred, JPG or PNG, added as `<required filename>.imageset`.

| City | Recommended landmark | Required resolution | Required filename |
|---|---|---:|---|
| Amsterdam | Canals, Dam Square, or Rijksmuseum | 2400 x 1350 px min | `hero_amsterdam` |
| Haarlem | Grote Markt or Sint-Bavokerk | 2400 x 1350 px min | `hero_haarlem` |
| Alkmaar | Waagplein cheese market | 2400 x 1350 px min | `hero_alkmaar` |
| Hoorn | Hoofdtoren and harbor | 2400 x 1350 px min | `hero_hoorn` |
| Zaanstad | Zaanse Schans or Zaandam center | 2400 x 1350 px min | `hero_zaanstad` |
| Amstelveen | Cobra Museum or city center | 2400 x 1350 px min | `hero_amstelveen` |
| Purmerend | Koemarkt or historic center | 2400 x 1350 px min | `hero_purmerend` |
| Heerhugowaard | Station, Centrumwaard, or Dijk en Waard civic center | 2400 x 1350 px min | `hero_heerhugowaard` |
| Rotterdam | Erasmus Bridge, modern skyline, or Markthal | 2400 x 1350 px min | `hero_rotterdam` |
| Den Haag | Binnenhof, Peace Palace, or Scheveningen | 2400 x 1350 px min | `hero_den_haag` |
| Leiden | Canals, university buildings, or historic center | 2400 x 1350 px min | `hero_leiden` |
| Delft | Markt, Nieuwe Kerk, or canals | 2400 x 1350 px min | `hero_delft` |
| Utrecht | Dom Tower or Oudegracht | 2400 x 1350 px min | `hero_utrecht` |
| Amersfoort | Koppelpoort or medieval center | 2400 x 1350 px min | `hero_amersfoort` |
| Arnhem | John Frost Bridge, Rhine waterfront, or Musis Sacrum | 2400 x 1350 px min | `hero_arnhem` |
| Nijmegen | Valkhof, Waal bridge, or skyline | 2400 x 1350 px min | `hero_nijmegen` |
| Eindhoven | Modern technology district, Witte Dame, or city center | 2400 x 1350 px min | `hero_eindhoven` |
| Tilburg | City center or Spoorzone | 2400 x 1350 px min | `hero_tilburg` |
| Breda | Grote Kerk or historic center | 2400 x 1350 px min | `hero_breda` |
| 's-Hertogenbosch | Sint-Janskathedraal or Markt | 2400 x 1350 px min | `hero_s_hertogenbosch` |
| Maastricht | Vrijthof or Sint Servaasbrug | 2400 x 1350 px min | `hero_maastricht` |
| Venlo | Stadhuis, Parade, or Maas waterfront | 2400 x 1350 px min | `hero_venlo` |
| Zwolle | Sassenpoort or historic center | 2400 x 1350 px min | `hero_zwolle` |
| Almere | Almere Stad center or modern waterfront | 2400 x 1350 px min | `hero_almere` |
| Lelystad | Bataviawerf, Batavia Stad, or waterfront | 2400 x 1350 px min | `hero_lelystad` |
| Groningen | Martinitoren or historic center | 2400 x 1350 px min | `hero_groningen` |
| Leeuwarden | Waag, canals, or historic center | 2400 x 1350 px min | `hero_leeuwarden` |
| Assen | City center or Drents Museum | 2400 x 1350 px min | `hero_assen` |
| Middelburg | Stadhuis, Lange Jan, or historic center | 2400 x 1350 px min | `hero_middelburg` |

Fallback contract implemented:

1. City-specific local asset, when present.
2. City-specific remote hero image.
3. Province remote hero image.
4. Netherlands premium remote fallback image.
5. Bundled premium emergency fallback asset: `premium_netherlands_emergency_fallback`.
6. Generated branded SwiftUI artwork as the final non-empty layer.
