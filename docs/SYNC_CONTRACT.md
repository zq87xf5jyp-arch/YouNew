# YouNew synchronization contract

Status date: 2026-07-28

## 1. Governed content

### Source and destinations

| Stage | Input | Output | Activation |
|---|---|---|---|
| Editorial release | Immutable DataProject release plus approved overlays | Effective governed record set | Release status and acceptance lock |
| Import | Effective release heads | `YouNew/Resources/Data/younew-runtime-data.json` | Local build command |
| Public projection | Effective release heads | `public-site/src/generated/public-content.json` and static indexes | Public build |
| Admin projection | Effective release heads | `admin-dashboard/src/generated/governed-runtime*.json` | Admin build |
| Admin article sync | Published database articles | `published_content_artifacts` candidate with SHA-256 fingerprint | Manual review only |
| Public Admin feed | Manually approved non-empty candidate | `public_content_feed` active row and `/api/public/content-sync` | Explicit owner/admin activation |
| Public updates page | Versioned active Admin feed | `younew.nl/updates/` | Public-site deployment plus active feed |

### Identity and lifecycle

- Stable record IDs and route slugs must not change during ordinary edits.
- Supported release lifecycle is immutable release plus overlay, never in-place mutation of an accepted release.
- Public projection includes lifecycle `published` records only.
- `retired` records remain auditable but are removed from public routes, search, map and runtime payloads.
- Draft, QA, review and archived data fail closed and never enter public artifacts.
- Timestamps are UTC ISO-8601. User-facing release decisions use Europe/Amsterdam dates.

### Conflict resolution

1. An acceptance lock wins over a mutable working copy.
2. A later approved overlay wins over the locked base release for the same stable ID.
3. A database candidate never overwrites a DataProject record automatically.
4. Divergent fingerprints stop activation and require owner review.
5. Deletion is represented as retirement or a compensating overlay, not physical removal from release history.

## 2. Admin publication gate

An article may become `published` only when all of the following are present:

- verified date;
- reviewer identity;
- evidence URL or evidence note;
- explicit mapping to public destination/type;
- required media review;
- approved `owner` or `admin` actor.

The database trigger enqueues a sync job. `prepare-content-sync`:

- authenticates the JWT and approved role;
- accepts an idempotency key;
- reads only published rows;
- sorts and serializes deterministically;
- stores a candidate artifact and SHA-256 fingerprint;
- marks the job `succeeded` or `failed`;
- never deploys the public site or iOS app.

Retries reuse the idempotency key. A succeeded job is not duplicated. Failures retain error metadata without secrets or personal content.

### Manual activation and public-site projection

`activate_content_artifact(candidate_id)` is the only supported Admin-to-site activation path:

- only authenticated `owner` or `admin` roles may call it;
- the candidate must be non-empty and its version, schema and record counts must match;
- the previous active artifact becomes `superseded`;
- the candidate becomes `active` and replaces the singleton `public_content_feed` row in the same database transaction;
- the activation writes a PII-safe audit event;
- drafts, review rows, rejected artifacts and operational tables are never returned by the public endpoint.

`/api/public/content-sync` reads the active row with the anonymous Supabase client and RLS. It applies a second fail-closed schema check, returns an exact-origin CORS response, an ETag based on the SHA-256 fingerprint, and `503` for unavailable or malformed active data. No service-role credential is used.

The public `/updates/` page validates the versioned payload again before rendering plain text and HTTPS official-source links. It shows an explicit empty or unavailable state instead of unreviewed fallback content. This feed is an operational Admin layer: it does not overwrite DataProject, the canonical public search index, or the iOS runtime.

## 3. Business inquiry flow

`public-site` → `submit-business-inquiry` → `submit_business_inquiry` RPC → `business_inquiries` → Admin.

Contract:

- CORS allowlist: `https://younew.nl`, `http://localhost:3000`, `http://127.0.0.1:3000`, and the local 3001 equivalents;
- maximum request size: 32 KiB;
- server validation repeats client validation;
- honeypot, consent, date, URL, KvK and enumerated-field checks fail closed;
- rate limiting uses a salted, non-reversible request fingerprint;
- the response is successful only after a stored receipt ID is returned;
- logs and audit events omit message, email, phone, KvK and other direct identifiers.

## 4. Public feedback flow

`public-site` → `submit-public-feedback` → `submit_public_feedback` RPC → `feedback` → Admin.

Contract:

- same exact-origin CORS policy;
- maximum request size: 16 KiB;
- controlled feedback type, page path, optional email, 20–2,000 character message, consent and honeypot;
- success only after a stored receipt ID;
- salted rate-limit fingerprint and PII-safe audit.

## 5. Authorization and failure behavior

- Public clients receive no service-role credential.
- Anonymous users cannot select or mutate operational tables directly.
- Admin queries require authenticated `owner` or `admin` roles.
- The workspace status endpoint is private, `no-store`, `noindex`, and returns `503` when operational tables are unavailable.
- A failed write preserves the user-entered form state and offers an explicit user-controlled email fallback; it never claims that data was saved.
- Network, validation and authorization failures are terminal for that attempt and are visible to the user/operator.
