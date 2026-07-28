# YouNew release evidence — 28 July 2026

These files support the release-readiness decision for the proposed 29 July 2026 release.

## Browser QA

| File | Source | Viewport | Purpose |
|---|---|---:|---|
| `browser-home-390x844.jpg` | Local release candidate at `http://127.0.0.1:4173/` | 390×844 | Mobile homepage evidence |
| `browser-home-1440x900.jpg` | Local release candidate at `http://127.0.0.1:4173/` | 1440×900 | Desktop homepage evidence |
| `browser-admin-login-1280x720.jpg` | Local production build at `http://127.0.0.1:3002/login` | 1280×720 | Protected Admin Dashboard login evidence |

The screenshots show the local release candidate, not the unchanged production website.

## Hostinger artifact

- File: `younew-hostinger-c34ce61-20260728.zip`
- Artifact code commit: `c34ce61209dbda45b1ef82fe57af914c56404707`
- SHA-256: `7541723b3535ae1431a6dde350cd92a30c715993d0ebb072d5cd09d191af9471`
- Archive contents: 707 regular files plus 270 directory entries
- Layout: `index.html` and `.htaccess` at the ZIP root; no `out/` directory prefix
- Dataset fingerprint: `0997fa89245b53f6d53f59c5f5544a34cd29a8632047bbe25b09a9389c7261cc`

The ZIP is intentionally ignored by Git because it is a reproducible deployment artifact. Do not upload or extract it to production until every mandatory gate passes and the owner sends the exact command `GO LIVE`.
