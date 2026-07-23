# YouNew Build Week video

This Remotion project assembles a 2:20, 1920×1080, 30 fps candidate video from
real iPhone Simulator clips, the owner-selected Derya narration, and the English
SRT captions. The edit shows the supported local guided journey, the in-app BSN
guide, Government.nl, Map, Search, Rotterdam and Guide categories.

The composition makes no claim that GPT-5.6, ChatGPT or live OpenAI powers the
in-app assistant. Screenshot 08 and Amsterdam municipal identity tiles are not
used.

## Commands

```bash
pnpm run lint
pnpm run dev
pnpm exec remotion render YouNewBuildWeekReview out/YouNew-BuildWeek-candidate-final.mp4
```

The default composition has `reviewDraft: false` because every product segment
now uses a live simulator clip. The MP4 is still only a local candidate until the
owner reviews it, confirms the map/public-media boundary and separately approves
YouTube publication.

## Local evidence artifacts

`public/clips/*.mp4` and `out/` are intentionally ignored by Git. They are retained
locally; hashes and capture details are recorded in
`BuildWeekSubmission/VIDEO_SCREEN_RECORDING_MANIFEST.md`. A clean clone does not
contain these binary inputs and therefore cannot reproduce the final MP4 without
the retained local artifacts.

The current workspace path contains a colon (`Developer:YouNew`), which can
confuse package-runner binary lookup. TypeScript and ESLint were therefore run
directly in this workspace; both passed. A normal clone path can use the commands
above after the local recording inputs are restored.
