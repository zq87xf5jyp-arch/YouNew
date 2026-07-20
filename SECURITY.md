# Security policy

## Current support status

YouNew has no published production release or security-supported version in this
repository. The `build-week-readiness` branch is under release-readiness review;
it must not be treated as production-ready until the final gates and clean-clone
proof are complete.

## Reporting a vulnerability

Do not post credentials, personal data, unpublished vulnerabilities, or exploit
details in a public issue. No verified public security contact or repository
private-reporting channel is configured yet. Until the owner creates one, share a
minimal non-sensitive description directly with the repository owner through a
previously verified private channel. The owner must publish a durable security
contact before making the repository public.

Include the affected version or commit, platform, reproduction steps, impact, and
whether personal data could be involved. Do not include real newcomer documents,
addresses, identifiers, API keys, or health information in a report.

## Secret handling

- The iOS target must never contain an OpenAI API key.
- Backend credentials belong in the hosting provider's encrypted secret store.
- `.env`, signing certificates, private keys, provisioning profiles, archives,
  result bundles, and local logs are excluded from Git.
- `.env.example` contains names only and is safe to copy locally.
- If a credential is exposed, revoke and rotate it first; removing the text from a
  later commit is not sufficient.

## AI boundary

The optional live path sends requests to a separately operated backend. That
backend must enforce a server-owned prompt and bounded context, strict input/output
limits, a timeout, structured output validation, error handling, and non-sensitive
logging. The deterministic local guide remains the fallback. A response must not
be labelled live GPT-5.6 unless the backend returns validated model metadata for
that request.

## Security scope not yet certified

No penetration test, dependency-vulnerability attestation, production backend
review, app attestation, abuse test, or end-to-end privacy certification is claimed.
Git history author metadata and Xcode signing-team configuration also require owner
review before publication. See `BuildWeekFix/SECRET_SCAN.md` for the bounded scan.
