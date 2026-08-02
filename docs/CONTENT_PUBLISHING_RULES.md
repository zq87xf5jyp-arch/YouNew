# Public web content publishing rules

## Source of truth

The canonical content source remains the governed DataProject production release. The public web generator projects approved content into `admin-dashboard/public-site/src/generated/public-content.json` and its static routes. Supabase is used for bounded operational services; it is not a second editorial source of truth.

## Publication eligibility

A public item must:

- belong to an approved production release;
- use a stable, unique ID and slug;
- have a non-empty public title and summary;
- have a supported content type and valid category/city relationships;
- include the source data required by its content contract;
- have valid checked/updated dates;
- exclude draft, QA, review and archived state;
- reference only published related content;
- use a valid internal route and canonical URL;
- include valid image metadata and alt text when media is present.

The generator and pre-deploy checks must fail closed on duplicate slugs, unsafe URLs, invalid dates, missing required sources, invalid relationships, orphan routes or missing static assets.

## Guide depth

- `summary` means a published starting point. It must tell the user to verify the current procedure with the responsible source.
- `practical` means the full guide contract passed publication validation.
- A summary must never be presented as a complete step-by-step guide.
- Missing practical coverage must be labelled; no UI or AI path may invent missing instructions.

## Source quality

For administrative, health, migration, tax and emergency topics, prefer the responsible institution: Government.nl, municipality, IND, DUO, Belastingdienst or another accountable public body. A blog or commercial page cannot replace the responsible source for a high-impact instruction.

Store a concise explanation and a direct source link. Do not copy long mutable source text. Link checks should run in a bounded separate pipeline with timeouts and retries rather than making every static build depend on mass live scraping.

## Coverage language

- Detailed city coverage means a published city route with its governed supporting content.
- National guidance is claimed only where a published guide or responsible source exists.
- Municipality directory availability is not equivalent to a detailed city guide.
- App city context is not automatically web city coverage.
- Counts displayed publicly must be derived from the same generated payload used by search and routing.

Current generated scope at this audit: 182 entities, 15 summary-depth guides, 5 detailed city routes, 30 organizations, 132 places, 10 categories and 4 provinces. Recompute these figures on every release; do not copy them into evergreen marketing copy.

## Languages

A locale is public only after routes, navigation, main content, legal pages, emergency information, metadata and source labels are translated and reviewed. Do not publish incomplete locale routes or show pending languages as selectable.

## Images

Every public image needs a stable URL, intrinsic dimensions, useful alt text or an explicit decorative role, attribution where required and a browser-readable format. External image hosts must be allowlisted by the hosting policy. Missing media uses an honest fallback and cannot block the entire directory.

## Editorial separation

Editorial guidance is selected for user value and cannot be purchased. Sponsored placements must be explicitly labelled, must not imitate official guidance and must never influence emergency, legal, health or administrative instructions.
