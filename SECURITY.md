# Security policy

## Supported versions and source

YouNew 1.0 is publicly available on the App Store. Security reports are accepted
for the current App Store release and for the latest commit on `main`. The source
candidate on `main` may be newer than the public binary and is not evidence that
an App Store update has shipped.

| Version or branch | Report intake |
|---|---|
| Current App Store release | Supported |
| Latest `main` | Supported as pre-release source |
| Older builds and commits | Best effort |

## Reporting a vulnerability

Do not post credentials, personal data, unpublished vulnerabilities, or exploit
details in a public issue. Email [support@younew.nl](mailto:support@younew.nl)
with the subject `SECURITY: YouNew` and begin with a minimal, non-sensitive
description. If GitHub shows a **Report a vulnerability** button for this
repository, its private report form is also an appropriate channel.

Include the affected version or commit, platform, reproduction steps, impact, and
whether personal data could be involved. Do not include real newcomer documents,
addresses, identifiers, API keys, or health information in the initial report.
The maintainer will arrange a safer channel if sensitive evidence is necessary.

## Secret handling

- The iOS target must never contain an OpenAI API key.
- Backend credentials belong in the hosting provider's encrypted secret store.
- `.env`, signing certificates, private keys, provisioning profiles, archives,
  result bundles, and local logs are excluded from Git.
- `.env.example` contains names only and is safe to copy locally.
- The `Secret Scan` workflow checks pull requests, pushes to `main`, the full
  reachable history each week, and manual runs with a pinned Gitleaks action.
- GitHub native secret scanning and push protection are complementary repository
  controls and should remain enabled; neither replaces credential rotation.
- If a credential is exposed, revoke and rotate it first; removing the text from a
  later commit is not sufficient.

## AI boundary

The optional live path sends requests to a separately operated backend. That
backend must enforce a server-owned prompt and bounded context, strict input/output
limits, a timeout, structured output validation, error handling, and non-sensitive
logging. The deterministic local guide remains the fallback. A response must not
be labelled live GPT-5.6 unless the backend returns validated model metadata for
that request.

## Security scope and disclosure

No penetration test, dependency-vulnerability attestation, production backend
review, app attestation, abuse test, or end-to-end privacy certification is claimed.
Repository media-rights and historical-capture reviews remain separate from this
security contact policy. `BuildWeekFix/SECRET_SCAN.md` is preserved historical
evidence and is not the current automation status. See the `Secret Scan` workflow
for current checks and `MEDIA_ATTRIBUTION.md` for the media-rights inventory.

Please allow a reasonable remediation window before public disclosure. The
maintainer will acknowledge receipt, assess impact, and share a coordinated
disclosure plan when the report is reproducible and in scope.
