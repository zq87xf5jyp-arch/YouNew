# Repository handoff

Updated: 21 July 2026, Europe/Amsterdam

## Current public source

- Repository: https://github.com/zq87xf5jyp-arch/YouNew
- Branch: `main`, tracking `origin/main`
- Visibility: public
- Delivery decision: owner-authorized direct synchronization to `origin/main`
- Judge source of truth: the public `main` branch

The evidence-producing validation runs occurred before the final documentation
handoff. Their exact artifact paths and bounded results remain recorded in
`FINAL_VALIDATION.md`; the release-readiness commit does not recharacterize those
historical results.

## Intentionally included

- iOS application source, project, unit tests, and UI-test sources;
- governed content and import tooling;
- root README, privacy, security, evaluation-only license, and attribution;
- Build Week story, demo guide, limitations, validation summaries, submission
  copy, captions, and media manifests;
- screenshots 01–07 as the bounded public promotional set.

## Intentionally excluded

- unrelated local public-site changes;
- raw simulator clips, narration MP3s, rendered MP4s, and Remotion workspace;
- generated Devpost upload variants;
- local build/test caches, DerivedData, `xcuserdata`, credentials, signing
  material, and temporary files;
- screenshot 08 and unresolved raster assets from promotional use.

The rendered candidate is reviewed and distributed separately using the exact
SHA-256 in `VIDEO_REVIEW_DRAFT.md`. A clean clone does not reproduce the MP4
without the intentionally retained local binary inputs.

## Release verification

Before and after each approved documentation push:

1. Confirm the staged paths match the bounded submission scope.
2. Run whitespace, JSON, Markdown-link, image-path, and scoped secret checks.
3. Confirm local `main` and `origin/main` resolve to the same commit.
4. Open the repository from a signed-out session and verify README rendering,
   screenshots, links, visibility, and absence of placeholders.

No deploy, App Store upload, or Devpost submission is implied by the GitHub
handoff.
