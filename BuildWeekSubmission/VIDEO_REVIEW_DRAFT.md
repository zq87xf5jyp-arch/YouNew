# Build Week video candidate

Recorded and rendered: 2026-07-21 (Europe/Amsterdam)
Status: **LOCAL CANDIDATE READY FOR OWNER REVIEW — NOT UPLOADED**

## Verified render

| Property | Verified value |
|---|---|
| Composition | `YouNewBuildWeekReview` |
| Duration | 140.000 seconds |
| Dimensions | 1920 × 1080 |
| Frame rate | 30 fps |
| Video codec | H.264 |
| Audio codec | AAC, stereo, 48 kHz |
| File size | 73,022,439 bytes |
| SHA-256 | `cd6258122aa717532ab68d8bce54ca6bcae279dd12e62c8234d763ec7b25eec3` |
| Local output | `BuildWeekVideo/out/YouNew-BuildWeek-candidate-polished.mp4` |

The MP4 and raw clips are intentionally ignored by Git. They are retained only
in the local workspace. No upload, publication or submission was performed.

## Verified inputs

- Nine real iPhone 17 Pro Simulator clips; see
  `VIDEO_SCREEN_RECORDING_MANIFEST.md`.
- Exact supported synthetic prompt from `DEMO_GUIDE.md`.
- Owner-selected HeyGen voice: Derya — Lifelike Broadcaster,
  `04d0ae1d0af2489ca7d3bb402a39a890`.
- Scene-aligned MP3 clips from `BuildWeekSubmission/audio/`.
- `VIDEO_CAPTIONS_EN.srt`, parsed through `@remotion/captions`.
- Canva thumbnail `DAHQCc36A-I` remains a separate YouTube asset.
- Screenshot 08 and Amsterdam municipal identity tiles are excluded.

## Visual and content QA

Representative frames across Home, the submitted question, the structured
response, the guide, Government.nl, Map, Rotterdam, Guide categories, creator
montage and final title card were rendered and inspected. The checks confirmed:

- the opening begins with visible product imagery and a large animated YouNew
  brand instead of an almost-black hold;
- `Moving to a new country...` enters after one second, while the edit remains
  exactly 2:20;
- restrained 2–4% zoom and slow pan movement is applied to otherwise static
  product and montage shots without changing the demonstrated flow;
- **Local guide mode** and the exact synthetic question are readable;
- the actual result shows BSN → DigiD → health insurance → huisarts;
- the BSN guide shows preparation steps;
- the Government of the Netherlands BSN page and `government.nl` domain are
  readable;
- Map, BSN Search, Rotterdam and Guide use real simulator recordings;
- captions remain in the lower safe area and do not cover core UI evidence;
- no review watermark, screenshot 08 or Amsterdam identity tile appears;
- the larger final logo, the approved role wording, and the purpose line
  `Built for people starting a new life in the Netherlands.` are readable;
- the narration contains no claim that GPT-5.6, ChatGPT or live OpenAI powers
  the in-app assistant;
- ESLint and TypeScript validation pass.

Frames were also extracted from the encoded MP4 at 1.2, 10.5 and 138 seconds
and visually inspected, confirming that the opening, main product layout,
burned-in captions and final card survived encoding as intended.

## Current limitations

- The file has not yet received an end-to-end human playback approval from the
  owner. Representative-frame inspection and media metadata validation do not
  replace that approval.
- The Government.nl segment is network-dependent evidence captured on
  2026-07-21; it does not prove universal or permanent external-link health.
- The owner confirmed the custom simplified map provenance and bounded public
  media set for this release; the map must not be described as official.
- The local binary inputs are not in Git, so a clean clone cannot reproduce this
  MP4 unless the retained clips are restored.

## Remaining owner gates

1. Watch the complete MP4 with sound and captions.
2. Approve this exact SHA-256 for upload.
3. Approve YouTube publication separately.
4. Approve Devpost submission separately.
