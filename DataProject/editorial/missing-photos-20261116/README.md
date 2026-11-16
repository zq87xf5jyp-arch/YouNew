# Licensed photo candidates — not approved for publication

Checked 2026-11-16. Five media-only revisions of already approved IDs; four other gaps are documented in research.json. The ordinary build excludes this batch. All photographs are historical; Rembrandtpark specifically shows July 1986, not the current layout.

The media files in this directory are supplied under their individual licenses below, not any conflicting repository-wide software license. Responsive WebP copies retain the original license, author, title and date; no retouching or compositing. Resizing, encoding and any display cropping do not remove attribution requirements. CC BY-SA adaptations remain under the same license. No endorsement is implied.

| Card | Photographer / institution | Date | License | Source |
|---|---|---|---|---|
| nature.leiden-rembrandtpark | Gemeente Leiden Afdeling Monumentenzorg; Erfgoed Leiden en Omstreken | 1986-07 | [CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.en) | ['Prins Hendrik', Objectnr PV PV29329R.5](https://commons.wikimedia.org/wiki/File:%27Prins_Hendrik%27,_Objectnr_PV_PV29329R.5.jpg) |
| hotel.leiden-ibis | Vysotsky | 2014-05-09 | [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0) | [Leiden224](https://commons.wikimedia.org/wiki/File:Leiden224.JPG) |
| hotel.leiden-rembrandt-hotel | Xsandriel | 2015-07-10 | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0) | [Nieuwe beestenmarkt 8, 10-12, 14](https://commons.wikimedia.org/wiki/File:Nieuwe_beestenmarkt_8,_10-12,_14.JPG) |
| restaurant.eindhoven-kazerne | Rosemoon | 2020-03-17 | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0) | [0772 WN176 Paradijslaan 4, 4a, 6, 6a, Eindhoven](https://commons.wikimedia.org/wiki/File:0772_WN176_Paradijslaan_4,_4a,_6,_6a,_Eindhoven.jpg) |
| hotel.rotterdam-supernova | Rotterdams Ballonnenbedrijf | 2022-09-03 | [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/) | [Super Deluxe room with temporary balloons](https://www.flickr.com/photos/rotterdamsballonnenbedrijf/52366054870) |

The Supernova photo shows temporary balloon decorations, not a promise of a booking inclusion or every room’s layout.

License evidence from Commons revisions and the public Flickr ImageObject are stored in evidence/ and bound by media-sources.json SHA-256. The four Commons original-file SHA-1 values match Commons. The Flickr source is a downloaded 1024×768 display copy; its SHA-256 is computed locally, not supplied by Flickr. The active variants are 480/800/1024 px, with no upscaling. The earlier 1200 px upscaled file remains unchanged as retained evidence only: excluded from asset copying and srcset. No source was downloaded again. Source and output hashes/dimensions are recorded. The source photos were visually inspected against their descriptions and official addresses.

Only images and EN/NL alt text differ from the hash-bound approved records in baseFiles. Existing prices, hours, descriptions, URLs, coordinates and fact-check dates are preserved. New photo verification dates are 2026-11-16.

Private preview: from admin-dashboard/public-site run `YOUNEW_PLACE_REVIEW=missing-photos-20261116 node scripts/build-place-review.mjs`, then `HOST=127.0.0.1 PORT=4196 node scripts/preview.mjs`. Never deploy this private artifact to production. Its HTML is noindex, sitemap is empty and the preview server is loopback-only/no-store.

Reviewing or merging a draft does not grant photo publication approval. Before any later release: obtain owner approval of the exact batch, refresh source/license checks, run Hostinger QA, save the production backup and verify rollback. PR #59/#60 and iOS are outside this change.

## Placement review after the CI correction

Use [PHOTO_REVIEW.html](PHOTO_REVIEW.html) as the single visual approval package; [visual-review.json](visual-review.json) binds its recommendations to the current record hash. Ibis is a conditional hero candidate with its 2014 date. Rembrandtpark (1986), Rembrandt Hotel (2015, obscured facade), Kazerne (2020, former Benz sign), and Supernova (2022, temporary balloons) are archive-gallery candidates; they need better current hero images. The existing private card template is a technical media preview, not approval of hero placement. Future publication must implement the separately approved placement. No approval fields or publication gates were changed.

`evidence/pre-ci-fix-preservation.json` records the original commit hashes. All 15 original WebP files and five license proofs are byte-identical. The new 1024 derivative uses the saved Flickr JPEG and retains its license, author, date and source hash. The four unresolved cards and follow-up rejections are documented in `research.json`; permission requests remain unsent.
