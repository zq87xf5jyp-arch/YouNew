# Build Week media-rights gate

Evidence cutoff: 2026-07-21 (Europe/Amsterdam)
Repository HEAD inspected before this report: `2723960c3c15383cf76b4166fed13e6143eda293`
Verdict: **DEMO ALLOWLIST AVAILABLE / REPOSITORY-WIDE CLEARANCE NOT PROVED**

This is an engineering provenance review, not legal advice.

## Current inventory

- 170 asset-catalog imagesets plus AppIcon.
- 72 `nl_*` assets have a manifest-backed source, creator, license, and now a
  resolved license/public-domain link for every record.
- 98 non-`nl_*` imagesets remain outside that manifest. Three legacy photographs
  used by the content registry have exact Wikimedia records, but that does not
  clear the other 95 files or AppIcon.
- 44 tracked PNG simulator/audit captures exist outside the asset catalog. Only
  the eight files under `BuildWeekFinal/screenshots/` were reviewed as the current
  demo set; the 36 older audit/runtime captures are excluded from the public
  media allowlist.

## Primary-source checks completed

| Material | Source result | Conditions / boundary | Decision |
|---|---|---|---|
| Leiden hero `nl_leiden_hero_01` | Wikimedia Commons identifies C messier and CC BY-SA 4.0. | Credit, license link, change note; ShareAlike if the crop is an adaptation. | Allowed for the bounded demo with the credit below. |
| Haarlem City Hall `home_documents_city_hall` | Wikimedia Commons identifies Jane023 and offers CC BY-SA 3.0 (or GFDL). | Use the CC BY-SA 3.0 option; credit, license link, and crop/resize note. | Allowed for the bounded demo with the credit below. |
| Amsterdam hero `nl_amsterdam_hero_01` | Wikimedia Commons identifies Basile Morin and CC BY-SA 4.0. | Credit, license link, change note; ShareAlike if adapted. | Allowed for the bounded demo with the credit below. |
| Hoorn card `nl_hoorn_card_01` | The exact Commons Licensing section records a worldwide public-domain release by the copyright holder. | Preserve source/provenance even though attribution is not required by that statement. | Metadata defect resolved. |
| Netherlands/province map | `ASSET_CREDITS.md` records simplified vectors created for YouNew; the owner confirmed this provenance for the release handoff. | Do not call the map official or imply government endorsement. | Allowed for the bounded demo. |
| Amsterdam flag and coat of arms | Commons marks the displayed files free of known copyright restrictions, while warning that official-symbol restrictions can apply independently. | Informational display only; no endorsement claim; owner/legal review remains advisable. | Conditional. Do not use screenshot 08 as promotional artwork until owner accepts this boundary. |

## Public demo allowlist

The current recording may show only:

1. programmatic UI, SF Symbols, and YouNew typography/colour surfaces;
2. `nl_leiden_hero_01`;
3. `home_documents_city_hall`;
4. `nl_amsterdam_hero_01`;
5. the simplified YouNew map, with the confirmed provenance statement in
   `ASSET_CREDITS.md` and no official-map claim;
6. Amsterdam identity symbols only in an informational city-detail shot and only
   after the owner accepts the official-symbol boundary above.

Do not introduce the eleven unresolved high-use raster assets into the recording:
`app_amsterdam_evening_background`, `home_emergency_ambulance`,
`home_language_classroom`, `home_work_zuidas`, `premium_home_documents`,
`premium_home_emergency`, `premium_home_healthcare`, `premium_home_housing`,
`premium_home_language`, `premium_home_work`, and
`premium_netherlands_emergency_fallback`.

The 36 older tracked screenshots under `IA_Audit_Screenshots/`,
`QA_Baseline_Screenshots/`, and `Runtime_Screenshots/` are excluded from the
public handoff allowlist. They should be removed from a future public branch or
kept in private evidence storage after owner review.

## Required demo/video credits

Include these lines in the video description or end card; do not shorten away the
creator, license, source, or modification note.

- Leiden hero: “Oude Vest canal, Leiden 6869” by C messier, CC BY-SA 4.0,
  https://commons.wikimedia.org/wiki/File:Oude_Vest_canal,_Leiden_6869.jpg —
  cropped/resized and converted for YouNew.
- Haarlem City Hall by Jane023, CC BY-SA 3.0,
  https://commons.wikimedia.org/wiki/File:Haarlem_city_hall.JPG — cropped/resized
  for YouNew.
- Amsterdam hero: “Water reflection of canal houses at blue hour in Damrak
  Amsterdam the Netherlands” by Basile Morin, CC BY-SA 4.0,
  https://commons.wikimedia.org/wiki/File:Water_reflection_of_canal_houses_at_blue_hour_in_Damrak_Amsterdam_the_Netherlands.jpg
  — cropped/resized and converted for YouNew.
- Licenses: https://creativecommons.org/licenses/by-sa/4.0/ and
  https://creativecommons.org/licenses/by-sa/3.0/.

## Screenshot decision

- Screenshots 01–07: eligible for the bounded submission package when the credit
  block above accompanies their public use.
- Screenshot 08: **conditional / excluded from promotional use by default** because
  it visibly includes municipal flag/coat-of-arms imagery with independent symbol
  restrictions. A replacement crop showing the Amsterdam hero/name without the
  identity tiles is preferred.
- All legacy audit/runtime screenshots: excluded from the public allowlist.

## Remaining repository-wide gates

- Confirm or replace AppIcon and all eleven unresolved high-use raster assets.
- Accept the official-symbol boundary or exclude city identity tiles from the
  public recording and screenshots.
- Do not claim “all images are fully licensed.”

Completed release decisions: the simplified map/vector provenance is confirmed;
the repository is public; screenshots 01–07 form the bounded promotional set;
screenshot 08 and city identity tiles remain excluded by default.
