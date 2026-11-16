# Amsterdam attractions — private continuation of PR #75

Continuation from `63024764d029a1c26f3a71405a96ef44baba0bb0`, 16 November 2026. Existing ten IDs, text, coordinates and source research are reused. All records and photos remain needs_review / privateOnly / publicationAuthorized=false.

## Editorial decisions

- Nieuwe Kerk: both official pages were opened in normal visible Chrome (HTTP 200). Visit page: daily 10:00–17:00. FAQ: Wednesday–Sunday 11:00–18:00. Neither identifies a validity period or applicable exhibition. The FAQ is not labelled obsolete without proof. Numbers are omitted from both card languages and retained only in review-issues.json; official schedule links remain.
- OBA: direct visible Chrome HTTP 200 on 16 November. Hours, facilities and accessibility were read from the live page. The indexed observation remains history, not a new direct check. One paired accessibility block was added.
- 102 EN/NL source-linked blocks; 10 retained BAG address points; 33 source-check entries. Map points do not certify accessible entrances.

## Media

Ten candidates and 30 WebP variants (480/800/1200 px). media-sources.json binds Commons revision, author, date, original hashes, licence, commercial reuse/adaptation, identity and placement. Sources retain their aspect ratios; no retouching or enlargement. Dates appear in EN/NL alt text and credits. An archive_gallery_only entry requires replacement for a contemporary main photo; the existing renderer is a technical preview, not placement approval. CC does not imply endorsement, model releases or trademark rights.

All 32 files of the original five-photo package remain byte-identical, including the natural 1024px Supernova file. Four old gaps and four hero replacements remain independent in media-followup.json. No permission requests were sent.

## Review and reproduction

[REVIEW.html](REVIEW.html) combines these ten cards with ten revisions in priority-cities-followup-20261116 and links to the unchanged five-photo package. Regenerate with `python3 DataProject/editorial/amsterdam-attractions-20261116/build-review.py` from repository root.

Private build from public-site: `YOUNEW_PLACE_REVIEW=amsterdam-attractions-20261116,priority-cities-followup-20261116 node scripts/build-place-review.mjs`. Preview the original five-photo package separately: overlapping Kazerne/Supernova revisions cannot be combined, to avoid overwriting either review.

Ordinary output remains 96 entities / 50 places with photos; this is a local artifact count, not a fresh production audit. Raw new evidence and original downloads: `/Users/ivan/YouNew-Expansion-20261116-Next-Evidence`. [QA report](QA_REPORT_RU.md) separates current checks from the earlier audit.

No production, merge, paid service, outreach or iOS change. Human text/photo/placement approval and fresh operational checks are required before a separately authorised release.
