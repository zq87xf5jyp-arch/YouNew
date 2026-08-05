# ADR-013 — Research evidence and editorial publication boundary

- Status: proposed
- Date: 2026-08-05
- Draft author: Codex implementation agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: `DataProject/staging/practical-guides-wave-1.json`; `DataProject/research/priority-1-daily/priority-1-dossiers.json`; `scripts/practical-guide-static-qa.py`; `scripts/priority-research-static-qa.py`; `scripts/build-priority-1-editorial-handoff.py`
- Related migrations: none; research and QA records do not mutate the production publication state

## Problem and context

Search usefulness requires evidence for critical life tasks even when a complete
editorial guide is not yet ready. Treating an adjacent record as an end-to-end
answer creates misleading coverage. Promoting a research packet directly to a
published guide would be worse: no named human reviewer has approved its steps,
wording, applicability, costs, dates, warnings or source-to-fact interpretation.

The first-wave queue previously had dedicated governed-source gaps for finding
work, opening a Dutch bank account and student housing. Official primary sources
now exist for those topics, but their presence is evidence coverage rather than
publication authorization.

## Considered options

1. Keep the three gaps explicit until a full guide is written.
2. Reuse adjacent work, commercial-bank and general-renting records as if they
   covered the missing tasks.
3. Add narrowly scoped QA entities backed by responsible official sources,
   connect them to the draft guides and retain every editorial publication gate.

## Decision

Use option 3. Governed QA entities may close an evidence-source gap only when
their exact official HTTPS pages have been opened, their claims remain inside
the source boundary, their relations resolve and all seven batch QA gates pass.
Commercial partner records cannot act as editorial evidence.

The practical-guide collection remains `draft`. Research dossiers remain
`research_draft`, `publication_authorized` remains false and the reviewer remains
absent. A guide still cannot project to the public runtime until it has complete
per-fact source IDs, steps, FAQs, warnings, estimates, assets where required,
chronology, a registered human reviewer and publication evidence.

## Consequences and risks

All twenty Priority-1 guide topics now have dedicated research and governed QA
sources, so editors have an explicit handoff rather than an undefined gap. This
does not create twenty production-ready guides: the current production-ready
count remains zero and the public site continues to expose only already released
summary-depth content.

Official pages can change and several tasks are case-specific. Their records use
review intervals and caveats, and must be revalidated before an editor turns
research into instructions. Human review remains an external release dependency
that automation cannot fabricate.

## Verification

Data Project QA validates unique IDs, canonical websites, relationships, source
status, search terms and substantive summaries across 454 governed records.
Priority research QA requires 20/20 topics, bidirectional fact/source mappings,
approved official hosts and fail-closed draft status. Practical-guide QA proves
that every required topic has governed evidence while incomplete guides still
fail the published schema and runtime projection. The generated editorial
handoff and content-readiness report preserve the remaining human-review,
step, FAQ, media and publication-evidence gaps.
