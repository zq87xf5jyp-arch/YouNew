# YouNew solution-first implementation specification

Date: 2026-08-06
Status: approved for local implementation; production publication requires a separate decision.

## Product rule

The user never searches for information. The user searches for a solution. Every screen must move the user closer to solving one real-life problem.

Primary route:

`task → clarification → solution → official source`

Guardrails:

- a useful action should be reachable in no more than three clicks;
- national guidance must remain visible when local context is absent;
- emergency guidance, official sources and organic ordering are never affected by advertising;
- no verified local provider, price, deadline or eligibility may be invented;
- TTUA is a target hypothesis: median ≤ 60 seconds and P75 ≤ 120 seconds, pending real analytics.

## Accepted visual references

- Homepage: `docs/reports/implementation-concepts/01-homepage.png`
- Task solution: `docs/reports/implementation-concepts/02-task-solution.png`
- Coverage Dashboard: `docs/reports/implementation-concepts/03-coverage-dashboard.png`

Intentional factual deviations:

- the public implementation uses the existing licensed YouNew hero assets instead of artwork embedded in the concept;
- solution copy and official links come only from the reviewed national-guide registry;
- dashboard values are calculated from repository evidence and never copied from concept placeholders.

## Design system

| Token | Value | Use |
|---|---|---|
| Canvas | `#020714` | page background |
| Canvas raised | `#07101f` | alternating bands |
| Surface | `#0a172a` | cards and panels |
| Surface strong | `#10223d` | hover and emphasis |
| Text | `#f7fbff` | headings and critical labels |
| Text secondary | `#bed0e6` | body copy |
| Muted | `#8da5c2` | metadata |
| Border | `#233b5c` | structural separators |
| Cyan | `#66cddd` | trusted/helpful paths |
| Orange | `#f26a21` | primary actions and urgency |

Typography uses the existing YouNew rounded display face and body font. Desktop H1 is 56–64 px, H2 36–52 px, body 16–18 px and control text 13–15 px. Cards use 12–16 px radii, restrained shadows and visible 3 px focus rings.

## Homepage contract

1. Country hero with heading `Your new life in the Netherlands`.
2. One assistant search labelled `What do you need in the Netherlands?`.
3. Exactly ten primary tasks: Housing, Work, Healthcare, Documents, Study, Daily life, Emergency, LGBTIQ+, Pets and Family.
4. Life in the Netherlands direction rail.
5. Popular tasks with a contextual Naruto help panel.
6. Six large cities with verified media.
7. One combined trusted-services block.
8. Why YouNew trust proof.
9. Exactly three recent verified updates.
10. Minimal footer.

The homepage must not contain a profile selector, a 342-municipality select, a standalone business campaign section, parallel Start/Discover/Naruto calls to action or more than ten primary task cards.

## Task hub contract

Every `/tasks/[task]/` page must provide:

- one task context and the outcome the user should leave with;
- one clarification question with direct, verified choices;
- national guidance as the default;
- optional local-context continuation that does not hide national results;
- an `Ask Naruto` escape hatch for users who cannot choose;
- a visible safety exception for emergencies.

## Solution page value contract

Every national solution page exposes:

- quick answer;
- who the route is for and its geographic scope;
- interactive checklist and next step;
- documents/evidence, cost, timing and problem handling;
- official sources with checked dates;
- known limits/local differences;
- page-specific feedback: helpful, not helpful, outdated, missing information or suggestion.

## Admin Coverage Dashboard contract

The dashboard reports task-weighted useful coverage rather than raw page count. A task is considered complete only when the repository evidence provides:

- a verified answer;
- an official source;
- a useful next action;
- requirements/documents;
- a checked date;
- local-difference disclosure;
- QA/release evidence.

Missing denominators and live-only feedback/review data must be labelled `Not established`, never displayed as zero.

## Responsive and accessibility contract

- desktop target: 1440 × 1100;
- mobile target: 390 × 844;
- task grids collapse without horizontal page overflow;
- city and direction rails may scroll horizontally with visible affordance;
- controls have accessible names, keyboard focus and at least 44 px targets;
- colour is never the sole carrier of urgency, verification or status;
- reduced-motion and reduced-transparency preferences remain supported.
