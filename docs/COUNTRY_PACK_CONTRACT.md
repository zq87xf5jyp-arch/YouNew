# YouNew Country Pack contract

Status: architecture contract. It is not evidence that a second country is production-ready.

## Purpose

A Country Pack isolates country-specific law, administration, sources, language review, emergency boundaries and commercial taxonomy from the shared YouNew product. A new country must be introduced by data and governed adapters, not by forking the iOS, web, Admin or analytics core.

## Required package

Each pack must declare:

1. ISO country code, semantic version, owner and lifecycle state;
2. country → region → municipality → responsible-organization hierarchy;
3. official-source registry with jurisdiction, language, owner, verification date and freshness SLA;
4. categories, high-intent journeys, eligibility boundaries and escalation routes;
5. supported locales, translation provenance and named human reviewers;
6. emergency and public-interest boundaries that are never commercial surfaces;
7. business taxonomy, verification rules and prohibited placement categories;
8. privacy, analytics and retention configuration;
9. acceptance lock, release fingerprint and rollback head.

## Invariants

- A source from one jurisdiction cannot substantiate a rule in another jurisdiction without an explicit cross-border legal basis.
- Translation cannot change eligibility, cost, timing, responsible authority or emergency meaning.
- AI output is draft/supporting material and cannot bypass source mapping or human approval.
- Sponsored content cannot modify organic ranking or appear inside emergency, official-source or procedural-step blocks.
- A failed or expired pack remains auditable; corrections use immutable overlays.

## Release gate

A Country Pack is production-ready only when:

- schema, source, media, localization, accessibility and security gates pass;
- high-intent journeys have human approval in every claimed language;
- at least 95% of governed active sources are inside freshness SLA;
- a country-specific legal/compliance review is recorded;
- public, iOS and Admin projections have matching fingerprints;
- backup, rollback and production smoke evidence exist.

The investor target of a second country in 90 days should be measured from approved discovery scope to production verification. Belgium is the preferred first repeatability pilot; no Belgium production claim is made today.
