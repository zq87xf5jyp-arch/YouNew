# YouNew content publication workflow

## Principle

Publication is an evidence-backed state transition, not a text edit. Public web, iOS and Admin projections must be reproducible from the same governed release heads.

## DataProject release path

1. Create or update a working record with a stable ID.
2. Add official-source evidence, source-check date, location/category mapping and media rights metadata where applicable.
3. Run schema, content, source-safety, media, link and data-health gates.
4. Obtain editorial approval and create an immutable release plus acceptance lock.
5. Correct an accepted release through a new overlay; use `retired` for content that should leave public surfaces.
6. Run:

```bash
python3 scripts/import-data-project.py --all-approved
python3 scripts/data-project-import-static-qa.py
python3 scripts/generate-data-dashboard.py
python3 scripts/generate-data-observability.py
```

7. Build the public and Admin projections and compare record counts, release heads and fingerprints.
8. Review the local/staging result. Production activation remains a separate `GO LIVE` action.

## Admin article path

Allowed states: draft → QA/review → published, with archive/retirement handled explicitly.

The publish action requires:

- approved owner/admin actor;
- reviewer and verified date;
- evidence;
- destination/type mapping;
- required media review;
- complete title, slug and content fields.

Publication creates a sync job. The authenticated sync function produces a deterministic candidate artifact. The operator must compare the fingerprint, review the candidate and deliberately incorporate it into DataProject. There is no automatic production publish.

## Expired or incorrect content

1. Confirm the issue against an official source.
2. Preserve the stable ID and prior evidence.
3. Add an overlay with corrected fields or lifecycle `retired`.
4. Regenerate runtime and public outputs.
5. Verify the retired record is absent from search, routes, map and iOS runtime while remaining in audit history.

For the 2026-07-29 candidate, the expired Pride Walk and Pride Park records were retired in `amsterdam-v0.1.2`; remaining future WorldPride records stay published.

## Minimum release evidence

- release ID and acceptance lock;
- reviewer/approver;
- source URLs and verification dates;
- public record count;
- excluded/retired count;
- runtime and artifact fingerprints;
- all QA command results;
- deployment SHA and timestamp after authorization.
