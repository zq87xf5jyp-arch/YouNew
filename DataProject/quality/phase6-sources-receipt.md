# YouNew Phase 6 — evidence and source receipt

Date: 2026-10-24. Scope: local candidate preparation and read-only production observation. No production write, deployment, migration, DNS change, catalogue acceptance or outreach was performed.

## Release integrity and dependency evidence

- The Phase 5 public archive still hashes to the owner-supplied SHA-256 `ba0b0cbfa6c298ae2ae6d2f9b8ecf52675986b8c0ea66380b2973550f6a13dec`.
- Byte integrity does not make that archive deployable. Its frozen dependency set is affected by security advisories published or updated after the freeze.
- The local Phase 6 candidate uses Next.js `15.5.28`, `eslint-config-next` `15.5.28`, Zod `4.6.6`, Sharp override `0.35.5` and `source-map-js` override `1.2.2`.
- Production audits for the admin and public workspaces report `No known vulnerabilities found` on 2026-10-24.

Primary advisory evidence:

- Next.js SVG/RCE advisory and patched version: <https://github.com/advisories/GHSA-2464-fhr4-w9xw>
- Next.js Server Actions denial-of-service advisory and patched version: <https://github.com/advisories/GHSA-p3m5-59mp-jv5r>
- Zod out-of-memory advisory and patched version: <https://github.com/advisories/GHSA-mrhx-c7xc-m3w5>
- Sharp remote-code-execution advisory and patched version: <https://github.com/advisories/GHSA-wq5f-xc86-pv6w>

The Phase 5 hash is therefore recorded as **intact but superseded**, not approved.

## Local verification evidence

- Public suite: 199/199 tests passed; static package contains 464 sitemap URLs and 493 HTML files.
- Internal public references: 37,956 checked, 0 broken.
- Public security/package/404 gates: passed.
- Admin suite after adding the Storage backup contract: 162/162 tests passed.
- Admin lint, typecheck and Next.js 15.5.28 production build: passed. The build emits a non-fatal Edge-runtime warning through the existing `@supabase/ssr` dependency; staging parity remains mandatory.
- Local browser path: home → Amsterdam city → search for `driving licence amsterdam` → governed guide → official Amsterdam source. Search returned the expected governed guide and municipality result; the external source target was present; browser console log was empty.
- Local NL home rendered with NL navigation, five city-guide links and the free-business-registration route.

## Independent-value audit of every indexable URL

The executable audit `scripts/audit-phase6-indexable-value.py` reconciles every sitemap URL to rendered HTML and checks canonical, H1, indexability, minimum main content, actions, duplicate content, route-specific evidence and shingle uniqueness.

Result:

- 464 sitemap URLs assessed;
- 457 PASS;
- 7 REVIEW;
- 0 FAIL;
- 0 exact duplicate main-content groups;
- `all_pages_independently_useful = false`.

The seven review routes are `/categories/things-to-do/`, `/cities/amsterdam/`, `/places/begijnhof-amsterdam/`, `/cities/den-haag/`, `/cities/eindhoven/`, `/cities/rotterdam/` and `/cities/utrecht/`. Six detail pages explicitly disclose that record-level verification is not established; the category links to those records. The report is `DataProject/quality/phase6-indexable-value-audit.md`.

## Amsterdam catalogue evidence

- The current local public runtime contains 7 governed records and preserves all 170 freshness exclusions.
- Only the driving-licence guide currently exposes affirmative record-level verification in the rendered pilot path. Six legacy detail records carry an explicit unverified warning and are not represented as confirmed here.
- Ten Amsterdam railway-station records are field-confirmed in the QA-only release `amsterdam-v0.1.9`.
- The QA overlay SHA-256 is `ef56dc29c01ba4962b5d29b3540254bad0549bb0315b458e6275667b047416c5`.
- That data release is not accepted, has no acceptance lock and is not authorised for public output. All 170 exclusions therefore remain active.

## Production read-only observation

At 2026-10-24T08:37Z, direct HTTPS reads returned:

| Path | HTTP | Observation |
|---|---:|---|
| `https://younew.nl/` | 200 | Existing public home is reachable. |
| `https://younew.nl/robots.txt` | 200 | References the production sitemap. |
| `https://younew.nl/sitemap.xml` | 200 | Contains 595 URL entries, not the candidate's 464. |
| `https://younew.nl/guides/driving-licence-amsterdam/` | 200 | Existing guide is reachable. |
| `https://younew.nl/nl/` | 404 | Current production does not pass the required NL-home smoke. |

These observations prove only availability of the pre-existing live site. They do not prove that the Phase 6 package is deployed or that production analytics, forms or persistence work.

## Backup and restore boundary

Supabase database backups do not include Storage object payload bytes; they cover database content and Storage metadata. Primary documentation: <https://supabase.com/docs/guides/platform/backups>.

The local operator scripts now provide:

- encrypted PostgreSQL backup and isolated restore verification from the existing Phase 4/5 flow;
- read-only Storage bucket/object inventory;
- recursive Storage payload copy into a local staging directory, encrypted with `age`;
- archive hash and per-object hash verification without remote writes.

Relevant Storage API documentation:

- list objects: <https://supabase.com/docs/reference/javascript/file-buckets-list>
- download objects: <https://supabase.com/docs/reference/javascript/file-buckets-download>
- bulk download guidance: <https://supabase.com/docs/guides/storage/management/download-objects>

No production backup was taken and no restore rehearsal against production data was run in Phase 6 because no production authorisation or production credentials were supplied. “Prepared” must not be reported as “executed”.

## Measurement evidence boundary

- No Search Console account evidence is available in the local workspace.
- No verified production analytics dataset was queried.
- No actual visitor, application, registration, partner or revenue number is claimed.
- The dashboard must continue to display unavailable sources as `—`, not as zero and not as estimated performance.

