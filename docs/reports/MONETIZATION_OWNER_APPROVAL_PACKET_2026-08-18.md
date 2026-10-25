# YouNew monetization — owner approval packet

Date: 2026-08-18 (Europe/Amsterdam)  
Scope: decisions required to continue the master prompt beyond the verified local boundary  
Current production impact: none

## Why this packet exists

The repository now contains the audited content/search work, a fail-closed lead
pipeline, exact-retry suppression, consent-safe lead analytics and a
PII-minimised Admin inbox. None of the five pending database migrations is
applied. The next useful implementation changes affect the public commercial
offer or require a disposable database/runtime, named human reviewers or an
external sales target. Those decisions cannot be inferred safely.

One reply using the answer block at the end is enough to unblock the next work.

## Decision 1 — pilot offer and price posture

### Recommended

Approve the offer contract for design and local implementation:

- name: **90-day international-employee onboarding pilot**;
- customer: employer or relocation provider with international hires;
- deliverables: one scoped onboarding hub, 10–20 approved practical routes,
  city/region and employee-profile scope, anonymous usage/CTA report, export,
  update SLA and explicit editorial independence;
- boundary: navigation information, not individual legal, tax, immigration or
  medical advice;
- public price: **Request proposal**;
- private founding-client hypothesis: **€1,500 for 90 days**, used only in
  interviews/proposals after separate outreach authorization;
- no limited-time discount, reach claim, customer logo, ROI claim or invented
  testimonial.

Alternatives:

- publish the €1,500 hypothesis on the pilot page;
- revise the scope or price before design work.

## Decision 2 — canonical commercial routes

### Recommended

Approve this information architecture for local implementation and review:

| Route | Purpose | Primary action |
| --- | --- | --- |
| `/for-business` | one employer/relocation proposition | `Explore the 90-day pilot` |
| `/for-business/pilot` | scope, process, safeguards, report and qualification | `Request a pilot conversation` |
| `/partners` | verification, sponsorship labels and editorial independence | `Review partner rules` |
| `/partners/apply` | pilot-first qualification form | `Submit inquiry` |

Existing `/business/*` pages remain unchanged during local review. Redirects
or replacement happen only in an approved release, never silently.

### Proposed first-viewport copy

`/for-business`:

- H1: **Give international employees a clearer first 90 days in the Netherlands.**
- Supporting copy: **YouNew combines reviewed practical routes, local scope and
  anonymous usage reporting in one onboarding pilot—without turning sponsored
  content into advice.**
- Primary CTA: **Explore the 90-day pilot**
- Secondary CTA: **Request a conversation**

`/for-business/pilot`:

- H1: **A focused onboarding pilot for international hires.**
- Supporting copy: **Start with one workforce, one region and 10–20 reviewed
  routes. Run for 90 days, measure consented actions and decide from evidence
  whether to continue.**
- Primary CTA: **Request a pilot conversation**
- Price line under the recommended posture: **Request a proposal. Scope and
  price are confirmed after a short qualification call.**

These strings are proposed copy, not approved facts and not deployed content.

## Decision 3 — design source

No authoritative Figma file URL is present in the workspace.

Choose one:

1. **Provide the existing Figma file URL** and the page/frame to use.
2. **Approve an existing-system implementation** using the current YouNew
   public components, typography, colors, spacing and responsive conventions,
   with browser screenshots supplied for review before any deployment.

No new visual language, logo, testimonial, customer mark or decorative redesign
will be introduced under option 2.

## Decision 4 — guide review ownership

All 20 source-backed QA packets are mechanically complete but have no named
human reviewer. Publication remains fail-closed.

Provide a person or accountable role for each review group:

| Review group | Guides |
| --- | --- |
| Immigration/government | BSN/registration, DigiD, residence permit |
| Medical/insurance | health insurance, huisarts, urgent/emergency care |
| Housing/legal | long-term housing, temporary housing, landlord problems |
| Work/tax/debt | job search, employment contract/payslip, taxes/toeslagen, debt help |
| Daily life/education/family | bank, SIM/internet, transport, diploma, language/inburgering, school registration, pets/vet |

One person may own several groups, but high-stakes claims still need a reviewer
qualified for that domain. An AI agent is not a reviewer.

## Decision 5 — disposable Supabase rehearsal

The local machine currently has no Docker, Podman, Postgres or pgTAP runtime.
Production must not be used for testing.

### Recommended authorization

Authorize installation/use of a local disposable container runtime and a
strictly local Supabase rehearsal for the five pending migrations and 81 pgTAP
assertions, with these boundaries:

- no `--linked` command;
- no production project credentials or database URL;
- no `db push` to a remote project;
- disposable data only;
- capture apply order, test output, advisor output and teardown evidence;
- stop on the first migration/test/advisor failure;
- production apply remains a separate later approval.

If runtime installation is not approved, this gate stays unverified.

## Decision 6 — sales systems and external action

For target-account qualification, provide the exact CRM/Linear/Notion target if
records should be written there. Otherwise the existing local research queue
remains the source of truth.

Outreach, email, LinkedIn, Slack, proposal delivery and payment requests remain
separately prohibited until an explicit first-wave authorization names the
channel and scope. Approving this packet does not authorize external contact.

## Reply block

Copy, fill and send this block:

```text
1. Pilot offer: APPROVE RECOMMENDED / PUBLISH €1,500 / REVISE: ...
2. Routes and proposed copy: APPROVE / REVISE: ...
3. Design source: FIGMA URL + frame: ... / USE EXISTING YOUNEW SYSTEM
4. Review owners:
   - immigration/government: ...
   - medical/insurance: ...
   - housing/legal: ...
   - work/tax/debt: ...
   - daily life/education/family: ...
5. Disposable Supabase runtime/rehearsal: APPROVE / DO NOT INSTALL
6. CRM/workspace target: ... / KEEP LOCAL
7. External outreach: NOT AUTHORIZED (default) / separate scope: ...
```

## What approval does not do

It does not publish a page, expose a price, apply a migration, send a message,
create a CRM record, open a paid campaign, issue an invoice or accept payment.
Each external/production action keeps its own release or communication gate.
