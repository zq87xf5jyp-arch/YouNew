# Amsterdam v0.1.1 source-health remediation record

Status: **completed / approved / published**
Prepared: 20 July 2026
Completed: 22 July 2026
Base release: `amsterdam-v0.1.0`
Effective release: `amsterdam-v0.1.1`
Immutable base batch SHA-256: `a24f464c86e1880a542b23f1606f8622218cc0c7aa75464a9a19402847813b07`

This record supersedes the pre-release remediation plan. It documents the approved source-health correction; it does not authorize deployment to Hostinger or any other external publishing target.

## Completed remediation

- Preserved the accepted `amsterdam-v0.1.0` batch byte-for-byte and added a separate immutable acceptance lock.
- Published `amsterdam-v0.1.1` as a fail-closed full-record overlay with original and replacement canonical hashes, evidence references and all seven QA gates passed.
- Replaced obsolete Creative Commons deed routes with their live canonical English URLs.
- Replaced unavailable Flickr, ScraperWiki and other removed media/provenance routes with reviewed official or Wikimedia Commons sources carrying current attribution and licence evidence.
- Replaced the removed BREDA operator route with the current official I amsterdam venue listing; no manual override or allowlist was used.
- Regenerated the shipped runtime, public content, search index and content-provenance artifacts from the effective published release head.
- Updated dashboard, observability, operations and import validation to resolve effective release heads instead of treating the superseded base batch as current.

## Governance controls

- `DataProject/releases/acceptance-locks/amsterdam-v0.1.0.json` proves the immutable accepted base.
- `DataProject/overlays/WP-06/amsterdam-v0.1.1.json` contains the complete reviewed replacements and evidence.
- `DataProject/releases/releases.json` marks `amsterdam-v0.1.1` published and `supersedes: amsterdam-v0.1.0`.
- The external-link checker scans every governed effective head (`planned`, `qa`, and `published`), the shipped app runtime, source registry and generated public artifacts.
- Every failed HEAD request receives a browser-like GET verification. Non-restricted 4xx responses remain fail-closed.
- The overlay schema rejects unknown override fields; no allowlist, skip, warning downgrade or manual-verification bypass exists.

## Acceptance outcome

- Effective Amsterdam record count remains 183.
- Published runtime record count remains 188.
- Stable entity IDs are unchanged.
- All changed records have before/after canonical hashes and replacement evidence.
- `governed_broken_links` is required to equal zero before the nightly gate can pass.
- Public-host deployment remains a separate explicit operation and is outside this remediation.
