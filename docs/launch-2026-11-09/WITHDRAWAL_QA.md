# Operational withdrawal evidence — 2026-11-09

Scope: owner-authorized suppression of unconfirmed/stale content. No new factual content or reviewer identity is approved by this operation.

- Accepted Amsterdam 0.1.8: 183 complete records, 172 published, all 172 beyond their stored review deadlines.
- Candidate 0.1.10: the same 183 IDs; exactly 172 lifecycle changes from `published` to `retired`. Every other record field is identical, including URLs, coordinates, media references, verification dates and text.
- Original batches and acceptance locks remain unchanged. The unpublished 0.1.9 replacement overlay remains complete, marked retired for a later rebase; none of its ten reverified replacements was published.
- Runtime: five current city records plus explicit withdrawal IDs. Mobile loading and legacy mapping use these IDs to prevent withdrawn records from returning through old aliases. Web generation rejects a runtime that attempts to republish a withdrawn ID.
- The build rejects a canonical runtime whose published IDs differ from effective published releases. Admin map/link artifacts are generated after the filtered public artifact, avoiding data from the previous build.

Observed validation: strict Data Project QA PASS; strict Data Health PASS; full repository static QA PASS; withdrawal field-preservation regression PASS; public predeploy PASS (236 tests, 2608 search cases, 454 sitemap URLs, 492 HTML files, 28147 internal references). No network source-reverification claim is made by these checks. iOS compilation and its new withdrawal/route tests still require the current GitHub CI result.

The seven data gates apply to a withdrawal containing zero newly published facts: build/static/duplicate checks validate the resulting package and stable IDs; source/media checks prove field preservation and no newly introduced material; search/AI checks enforce exclusion. This does not authorize the 71 new drafts or the held editorial review packets.

Rollback: preserve 0.1.8, 0.1.9, 0.1.10 and their locks. Restore a record through a separately reviewed replacement overlay with current evidence. A code rollback must retain freshness suppression; do not republish old records solely to recover a previous UI or satisfy a count assertion.

Production was not changed by these local checks. The Hostinger QA backend currently runs archive commit `1dab9d8`, independently of this data withdrawal candidate.
