# Amsterdam v0.1.1 source-health remediation plan

Status: **planned / not approved / not published**  
Prepared: 20 July 2026  
Base release: `amsterdam-v0.1.0`  
Immutable base batch SHA-256: `a24f464c86e1880a542b23f1606f8622218cc0c7aa75464a9a19402847813b07`

This is an operations plan, not a release artifact. It authorizes no content mutation or publication.

## Evidence and scope

The live audit in `knowledge_data_health.json` checked 2,494 unique URLs at `2026-07-20T22:19:32.345270+00:00` and recorded:

- 1,847 reachable;
- 18 confirmed HTTP 404 responses;
- 597 access-restricted;
- 32 transient failures.

The 18 URLs occur 85 times across 30 entities in the release-generated runtime. All 30 entities report `dataProjectRelease: amsterdam-v0.1.0`. The current gate fails closed with `governed_broken_links=18`.

## Remediation groups

1. **BREDA official route (1 URL).** The automated client receives 404 while browser/search evidence suggests an anti-bot response. Do not replace the official source automatically. Add an expiring, evidence-backed manual-verification override only after a human browser check.
2. **Creative Commons canonicalization (2 URLs).** Replace the obsolete CC0 deed URL with `https://creativecommons.org/publicdomain/zero/1.0/` and the obsolete Dutch CC BY-SA 3.0 deed URL with `https://creativecommons.org/licenses/by-sa/3.0/nl/`. Update both `license_url` and the same URL embedded in attribution text. These two URLs account for 68 runtime occurrences across 34 media objects.
3. **Unavailable Flickr assets (5 URLs).** Four belong to `restaurant.wils`; remove those optional media objects and use the neutral fallback until a newly reviewed image exists. Replace the unrelated Canal Ring gallery object with a separately verified, locally managed image and complete provenance rather than guessing another Flickr URL.
4. **Unavailable provenance pages (9 URLs).** Replace the complete media objects for Wils, Canal Ring, MacBike, Dam Square, Amsterdam Bijlmer ArenA and Amsterdam UMC VUmc. A live CDN byte without an auditable source page is insufficient evidence of author, licence or subject relevance.
5. **Obsolete URL embedded in Funda attribution (1 URL).** Remove the optional third-party screenshot media object unless the original Flickr work, licence and subject relevance can be independently reverified.

Every replacement media object must carry a new stable media ID, live source page, live asset or repository-local public asset, licence URL, author attribution, retrieved date, relevance review and modification note where applicable.

## Required patch-release support

The current pipeline cannot safely accept a second ordinary batch with the same stable entity IDs:

- `scripts/import-data-project.py` rejects duplicate IDs across selected releases;
- `scripts/data-project-qa.py` rejects duplicate IDs across all batches;
- `scripts/check-external-links.py` scans historical batches without resolving the effective release head;
- the accepted base batch must remain byte-for-byte immutable.

Before creating `amsterdam-v0.1.1`, implement a fail-closed overlay model with:

- `base_release_id`, `supersedes` and the immutable base-batch hash;
- the original canonical hash of every replaced entity;
- full replacement records with the same stable entity IDs;
- explicit reason/evidence references and all seven QA gates;
- an effective-release resolver used by importer, QA, dashboard and link checker;
- a separate immutable acceptance lock rather than treating regenerated observability output as the release lock;
- an expiring manual-verification override model that cannot turn a dead content URL into a silent PASS.

## Candidate acceptance criteria

- `amsterdam-v0.1.0` batch hash is unchanged;
- effective Amsterdam count remains 183 and total public runtime count remains 188;
- all unchanged Amsterdam records are canonical-serialization equivalent to the base;
- every changed entity has an explicit before/after hash and evidence;
- candidate external-link audit reports zero unresolved confirmed failures;
- BREDA is either manually verified with expiry/evidence or remains a blocker;
- all seven release gates pass;
- production runtime and public export remain unchanged until explicit release approval;
- public Hostinger deployment remains a separate explicit approval.

## Required verification order

1. Implement and test immutable-lock and overlay resolution.
2. Create `amsterdam-v0.1.1` as a QA candidate, not published.
3. Apply reviewed URL/media replacements to the overlay only.
4. Run patch, importer, DataProject, external-link, full static and public pre-deploy QA.
5. Obtain explicit release approval before changing the effective production runtime.
6. Rebuild the public export and repeat browser/Lighthouse checks.
7. Obtain separate explicit approval before any Hostinger upload.

