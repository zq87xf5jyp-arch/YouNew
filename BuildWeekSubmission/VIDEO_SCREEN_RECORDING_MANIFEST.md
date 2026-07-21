# Build Week simulator recording manifest

Captured: 2026-07-21 (Europe/Amsterdam)
Device: iPhone 17 Pro Simulator, iOS 26.5
App bundle: `nl.younew.app`
Language: English
Input: synthetic demo text only

## Local source clips

The clips are retained under `BuildWeekVideo/public/clips/` and intentionally
ignored by Git because the raw capture set is large. Each source is portrait
H.264 at 1206 × 2622. Simulator capture uses variable/high-frequency timing;
the Remotion output normalizes the submission candidate to 30 fps.

| Clip | Verified duration | What it proves | SHA-256 |
|---|---:|---|---|
| `01-home.mp4` | 17.653 s | Clean English Home state | `d695a828e4aba32b7d69182907d8cf357b4dfa1daf6cdd6313f0b36458554e3a` |
| `02-assistant-question.mp4` | 39.655 s | Exact supported synthetic prompt | `821804e2cc04ae6afc51eb3bce773da8885167bce654bd431f64b3a9becfc3df` |
| `03-assistant-result.mp4` | 37.175 s | Local guide mode and ordered BSN → DigiD → insurance → huisarts result | `8642fc7fe0bac914788baec129babcdec201d3e9ae627d06c91dcdee379d3b6d` |
| `04-bsn-guide.mp4` | 40.393 s | Municipality-registration guide and practical preparation steps | `73533e7ec265485f34b556dbf2f4c8ca5d8c62806e173f918acba6f2ddf0f1d9` |
| `05-map.mp4` | 20.017 s | Root Map tab delivery and interactive province selection | `537e5484db87d1e6912b472df62b5bf323eb981c6b199467254726382fea5083` |
| `06-search.mp4` | 16.198 s | Actual BSN indexed-content search results | `1dc2c0874a9ac1bc3fa25314865a9a416f7e17b179c12a89eb50c545dd38b32a` |
| `07-rotterdam.mp4` | 19.457 s | Imported Rotterdam city map without Amsterdam identity tiles | `d3b41bf25b6c89eecb0fdfac3391bb0d19c4f5a9a1b43ffa4b5c89aaaa065a1f` |
| `08-guide-categories.mp4` | 19.605 s | Root Guide tab and the current category surface | `2c063e1e7756585896b3e8ff86eba571130f40dc705c050f93833167058c5d47` |
| `09-government-bsn-source.mp4` | 14.898 s | Government of the Netherlands BSN page and `government.nl` domain | `0cdcb8a1610af33373a2d4ff0d5934a44b295b151bc8482a1b21b335c3aa188b` |

## Interaction evidence

- The exact supported prompt was submitted twice and produced the same local
  structured route.
- Assistant accessibility evidence exposed the visible **Local guide mode**
  label, `assistant.response.step.1` through `.step.4`, source actions for
  `government.nl` and `digid.nl`, and source-labeled Government.nl cards.
- Map was opened through `tab.map`; North Holland selection changed the live
  province interaction value, and Rotterdam opened from South Holland.
- Root navigation then delivered Map → Home and Map → Guide taps. The previously
  reported map/tab interception was not reproduced in this recording pass.
- Search returned the current BSN registration and guide results.
- Government.nl was opened from the in-app official BSN source action. This is
  network-dependent evidence of the page as fetched during capture, not a claim
  that every external link is permanently available.

## Public boundary

- No BSN number, passport number, medical record or other personal data appears.
- Screenshot 08 and Amsterdam municipal flag/coat-of-arms tiles are excluded.
- The Rotterdam segment uses the live map surface and does not claim ownership
  of map-provider cartography.
- The owner confirmed the simplified map provenance and bounded public media set
  for this release; no official-map or government-endorsement claim is allowed.
- These recordings do not prove live OpenAI or GPT-5.6 inference.
