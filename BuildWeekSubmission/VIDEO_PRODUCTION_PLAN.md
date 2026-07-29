# Build Week video production plan

Status: **local 2:20 candidate rendered; owner playback and publication approval pending**

Target: **2:20, English, 16:9, 1080p**

## Editorial boundary

The video follows one supported newcomer journey. It does not claim live OpenAI
or GPT-5.6 inference, production readiness, universal link health, or complete
media clearance. The in-app experience is labelled **Local guide mode** and is
described as a deterministic local guided assistant.

## Edit sequence

| Time | Picture | Audio |
|---|---|---|
| 0:00–0:08 | Visible Home, large YouNew logo, then `Moving to a new country...` | Human problem hook |
| 0:08–0:20 | Prepared supported question; Local guide mode readable | Address / what-next question |
| 0:20–0:45 | Ordered BSN, DigiD, insurance and huisarts result | Explain the ordered route |
| 0:45–1:20 | BSN guide, preparation details, named official source | Explain verification and limits |
| 1:20–1:27 | Map | Breadth transition |
| 1:27–1:34 | Pre-positioned Search result | Local needs |
| 1:34–1:42 | One approved city view | City context |
| 1:42–1:50 | Guide categories | Connected product surfaces |
| 1:50–2:20 | Finished-screen montage; end on YouNew title card | Owner, ChatGPT and Codex story |

## Recording checklist

- [x] English app state; notifications, keyboard and debug overlays absent.
- [x] Use only synthetic input and the exact supported prompt from `DEMO_GUIDE.md`.
- [x] Record separate clean clips; do not type or navigate during the opening.
- [x] Keep **Local guide mode**, guide title, source publisher and root tabs readable.
- [ ] Confirm the final public media set against
  `MEDIA_RIGHTS_AND_ATTRIBUTION.md`; the simplified map remains owner-gated.
- [x] Exclude screenshot 08 and city identity tiles by default.
- [ ] Confirm the simplified map provenance statement before public use.
- [x] Burn in `VIDEO_CAPTIONS_EN.srt`, maximum two short lines at once.
- [x] Use restrained 2–4% zoom / slow pan motion on static product and montage
  shots without adding screens or extending the edit.
- [x] End cards: Ivan Chernikov product direction, ChatGPT product/writing
  partner, Codex engineering partner, YouNew tagline, the approved purpose
  line, and Build Week.
- [x] Export H.264 MP4, 1920×1080, 30 fps, stereo AAC; inspect representative
  frames and verify media metadata.
- [ ] Owner watches the entire export with sound and captions.

## Fallbacks

- Assistant mismatch: clear the conversation and repeat the exact supported prompt.
- External page unavailable: keep the in-app source card and disclose that opening
  is network-dependent.
- A breadth clip takes more than one clean action: replace it with a pre-positioned
  take instead of extending the video.
- Amsterdam symbols appear: crop to the hero/name or replace the shot.

## Owner approval gates

1. **Completed:** owner selected Derya and the scene-aligned audio is recorded in
   `VIDEO_AUDIO_MANIFEST.md`.
2. **Completed:** owner approved the Canva thumbnail and it was saved as design
   `DAHQCc36A-I` ([edit in Canva](https://www.canva.com/d/u_qWZspiU2GETF_),
   [view](https://www.canva.com/d/xXJ4ug_S4F727wi)).
3. **Completed:** nine real simulator clips were captured and documented in
   `VIDEO_SCREEN_RECORDING_MANIFEST.md`.
4. **Completed:** a 2:20 local candidate was rendered and technically validated;
   see `VIDEO_REVIEW_DRAFT.md`.
5. Confirm map provenance and the exact public media set.
6. Approve the final MP4 after complete playback before YouTube upload.
7. Approve YouTube publication and Devpost submission separately.

## Final title card

Use this exact wording after the spoken creator story:

**Product vision and direction:** Ivan Chernikov  
**Product and writing partner:** ChatGPT  
**Engineering partner:** Codex

Then end on:

**YouNew · A clearer first step in the Netherlands**  
**Built for people starting a new life in the Netherlands.**  
**Built for OpenAI Build Week**
