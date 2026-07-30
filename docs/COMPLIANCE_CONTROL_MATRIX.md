# YouNew compliance control matrix

Status: engineering control assessment, not legal advice or a conformity opinion. Formal applicability and legal review remain required.

| Area | Current engineering control | Confirmed gap / release condition |
|---|---|---|
| GDPR transparency and minimisation | Consent-gated bounded analytics; no free-text query, precise location, ad identifiers or profile selection in the documented planner event; protected public writes; PII-safe Admin export | Complete record of processing, controller/processor register, retention execution evidence, data-subject request rehearsal and counsel review |
| Security | RLS, server-side role checks, rate limits, secret scanning, CSP/headers, fail-closed publication and runbooks | Fresh database backup/restore evidence; authenticated production Admin E2E; leaked-password protection unavailable on Free plan; independent penetration test absent |
| DSA advertising transparency | Sponsored label, advertiser identity, safe destination, explicit excluded surfaces, organic-ranking separation and global disable flag | Determine whether and which DSA obligations apply; implement advertiser verification, “why shown”, complaint/redress and audit evidence before live campaigns |
| AI transparency | AI drafts cannot bypass source evidence or human publication approval; AI proxy rejects malformed model output | Complete system inventory and user-facing disclosures for applicable AI-generated/manipulated content before the 2 August 2026 transparency obligations apply |
| WCAG 2.2 AA | Semantic/accessibility fields, responsive QA, keyboard-conscious public UI and local Lighthouse accessibility evidence | Formal WCAG 2.2 AA audit, assistive-technology matrix and issue remediation record are absent |
| Media/IP | 170 iOS assets inventoried; rights gate passes; 27 derived city symbols retain byte-exact source artifacts and derivation evidence | Corporate IP title chain, contributor assignments, trademark/emblem review and legal opinion remain outside engineering evidence |

Authoritative references:

- GDPR business obligations: <https://commission.europa.eu/law/law-topic/data-protection/rules-business-and-organisations_en>
- Digital Services Act: <https://digital-strategy.ec.europa.eu/en/policies/digital-services-act>
- EU AI Act Article 50 transparency guidelines: <https://digital-strategy.ec.europa.eu/en/library/guidelines-transparency-obligations-providers-and-deployers-ai-systems>
- WCAG 2.2 Recommendation: <https://www.w3.org/TR/WCAG22/>
