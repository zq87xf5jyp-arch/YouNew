# YouNew: visual, information and technical audit

Date: 2026-07-30  
Scope: public website, guide catalogue, guide detail, business surface, authenticated admin dashboard, responsive web layout and attempted iOS Simulator launch.

## Executive verdict

YouNew is visually close to a production-grade premium product and technically represents a real connected platform. Its principal weakness is not the shell, but the depth of the core practical content and the remaining release-verification gaps.

| Dimension | Score | Verdict |
|---|---:|---|
| Public visual design | 8.5/10 | Strong, distinctive and consistent |
| Admin visual design | 7.8/10 | Operationally credible, dense but coherent |
| Information architecture | 7.2/10 | Broad and well-labelled |
| Practical content depth | 5.0/10 | Too many summaries, no complete practical guides |
| Technical product readiness | 7.8/10 | Strong verification base, incomplete release proof |
| Overall product experience | 6.9/10 | Strong shell, incomplete core utility |

These scores are an evidence-based assessment, not a market valuation or a compliance certification.

## Confirmed facts

- The public surface exposes 585 static routes and 575 indexable URLs.
- The live website has a coherent design language across the home page, guide catalogue, guide detail and business pages.
- The responsive home page has no horizontal overflow at 390 px.
- The five primary mobile hero actions measure 358 × 48 px.
- The mobile navigation control measures 42 × 42 px.
- No browser console warnings or errors were observed during the current live audit.
- The governed data project contains 450 records and a public projection of 186 records.
- Content depth consists of 15 verified summaries, 20 scaffolds and 0 production-ready step-by-step guides.
- Admin shows 186 published and 450 verified records.
- Public web tests previously recorded 83 passes; admin recorded 10 passes; the AI proxy recorded 13 passes.
- Supabase was recorded as `ACTIVE_HEALTHY`, with 11 migrations and 4 active Edge Functions.
- The unsigned generic-device iOS Release build succeeded.
- The current iOS Simulator installation did not complete within the tool timeout, so the runtime iOS interface was not visually accepted in this audit.
- The repository is on `admin-dashboard-integration` at `a3e59642`, with a dirty working tree and no clean release identity.

## Surface audit

### Step 1 — Public home page

Health: **strong**

Evidence: [01-home-desktop.png](01-home-desktop.png)

Strengths:

- Distinctive dark navy, orange and cyan brand palette.
- Strong typography and immediate premium positioning.
- iPhone product image makes the ecosystem understandable quickly.
- Primary actions, App Store route, search and emergency help are visible.
- Source-backed positioning creates trust.

Risks:

- The first screen contains five competing actions, which weakens the primary conversion path.
- Very large headings consume much of the first viewport.
- The complete landing page is long and repeats the same proposition in several sections.
- The floating privacy control competes with lower-right actions and content.

### Step 2 — Mobile home page

Health: **structurally healthy; visual evidence limited by capture scaling**

Evidence: [02-home-mobile.png](02-home-mobile.png)

Confirmed:

- No horizontal overflow at 390 px.
- Primary actions become full-width 48 px targets.
- Desktop navigation collapses to a mobile menu.
- The menu target is 42 × 42 px.

Limit:

- The in-app Browser returned a downscaled mobile screenshot. Responsive structure was verified through the live DOM and element dimensions, but this is not a complete visual QA pass for all mobile breakpoints.

### Step 3 — Guide catalogue

Health: **visually strong, informationally underfilled**

Evidence: [03-guides-desktop.png](03-guides-desktop.png)

Strengths:

- Clear publication-level labelling.
- Strong hierarchy and consistent cards.
- Sources and verification dates are visible.
- Honest differentiation between summaries and complete guides.

Risks:

- The hero explicitly states `0 step-by-step guides`, making the content gap the dominant message.
- The catalogue looks more mature than the underlying procedural depth.
- Most entries are starting points, not end-to-end task completion paths.

### Step 4 — Guide detail

Health: **good trust UX, insufficient task depth**

Evidence: [04-guide-detail-desktop.png](04-guide-detail-desktop.png)

Strengths:

- Source, verification date, save, share and print actions are clearly exposed.
- Publication status is honest.
- Official-source routing and outdated-information reporting support trust.
- Reading progress and related content create a complete editorial shell.

Risks:

- The page does not yet provide documents, prerequisites, costs, timing, exceptions, warnings and a verified step sequence.
- Users still have to reconstruct the task on the external official source.
- The visual treatment suggests a complete guide while the content is only a verified summary.

### Step 5 — Business page

Health: **credible inquiry surface, not yet an advertiser product**

Evidence: [05-business-desktop.png](05-business-desktop.png)

Strengths:

- Professional B2B presentation.
- Clear editorial/commercial separation.
- Honest wording about the reviewed inquiry model.
- Strong visual consistency with the consumer product.

Risks:

- No advertiser login, campaign purchase, campaign dashboard or guaranteed analytics.
- No real audience-size, partner or paid-pilot evidence.
- The surface is suitable for lead intake, not for demonstrating an operating advertising platform.

### Step 6 — Admin dashboard

Health: **technically credible, metric semantics need correction**

Evidence: [06-admin-dashboard-desktop.png](06-admin-dashboard-desktop.png)

Strengths:

- Dense but coherent operational layout.
- Clear separation of product, data, releases, bugs, AI knowledge, feedback and audit log.
- Coverage and data health are visible in one workspace.
- Visual hierarchy supports expert users.

Risks:

- Empty work packages can show `100%` quality while containing `0 published` records. They should show `N/A`, `not started` or a separate structural-readiness score.
- The main dashboard mixes data quality, publication progress and long-term targets, which can produce misleading executive interpretation.
- The navigation is long and would benefit from grouping into Content, Quality, Operations and Governance.

### Step 7 — iOS runtime

Health: **build verified; current visual runtime not verified**

Confirmed:

- Debug targets compile and link.
- The unsigned generic-device Release build succeeded.
- A Simulator `.app` bundle exists.

Blocker:

- Build/install calls stalled at the CoreSimulator boundary. The app did not launch during this audit, so no current runtime screenshot was accepted.

## Visual assessment

The product has a recognizable design system rather than a collection of unrelated screens. Typography, colors, cards, spacing and calls to action are consistent. The public web surface is already strong enough for investor demos and buyer presentations.

The largest visual risk is that presentation maturity exceeds functional and informational maturity. This creates a credibility gap when a user opens a polished guide page and discovers that it is only a summary.

Visible accessibility risks still requiring dedicated testing:

- muted grey secondary text on dark and gradient backgrounds;
- keyboard focus order and focus visibility;
- zoom/reflow beyond the single tested mobile width;
- screen-reader output;
- motion and Reduce Motion behavior;
- iOS Dynamic Type, VoiceOver and target-size verification.

No WCAG 2.2 AA or platform accessibility compliance claim is established by this audit.

## Information richness

### Breadth

Breadth is high:

- 186 published records;
- 5 public city guides;
- 10 published categories;
- public routes for discovery, guides, journeys, map, cities, organizations, updates, saved content, emergency help and business;
- visible sources, dates and content-governance states.

### Depth

Depth is low for the product's central promise:

- 0 production-ready practical guides;
- 15 verified summaries;
- 20 guide scaffolds;
- only English is reviewed on the web; Dutch, Russian, Ukrainian and Polish are explicitly pending review;
- current content is concentrated around Amsterdam and several broad government/housing topics.

Conclusion: YouNew is **information-rich as a catalogue**, but **not yet instruction-rich as a task-completion product**.

## Technical assessment

| Component | Status | Assessment |
|---|---|---|
| Public web | Verified | Strong route generation, SEO surface and automated checks |
| Admin | Verified with semantic risk | Good operational breadth; authenticated E2E and metric semantics remain |
| Supabase | Verified with release gaps | Healthy runtime; backup/restore proof and password protection remain |
| Data project | Verified | Strong governance and freshness; practical content depth is insufficient |
| AI proxy | Verified structurally | Tests pass; production usefulness still depends on guide quality and live evaluation |
| iOS | Partially verified | Release builds, but runtime tests and current visual launch remain blocked |
| GitHub/release identity | Not release-ready | Dirty divergent branch prevents a trustworthy source-to-artifact release identity |
| Accessibility | Incomplete evidence | Structural strengths exist; manual and assistive-technology evidence is missing |

## Priority actions

1. **P0 — Core utility:** publish the first 10 complete flagship guides, including prerequisites, documents, cost, timing, steps, exceptions, warnings, source citations and reviewer identity.
2. **P0 — Release proof:** create a clean release branch/SHA and require green web, admin, Edge Function and iOS gates.
3. **P0 — iOS:** obtain a successful Simulator launch, executable unit/UI tests and signed App Store archive evidence.
4. **P0 — Resilience:** perform encrypted Supabase backup and isolated restore with integrity checks.
5. **P1 — Admin semantics:** replace `100%` on empty work packages with `N/A/not started` and separate quality from coverage.
6. **P1 — UX focus:** make search or a profile-based next step the single dominant home-page action.
7. **P1 — Localization:** complete human review of Dutch first, then the remaining declared languages.
8. **P1 — Accessibility:** run keyboard, contrast, reflow, screen-reader, Dynamic Type and VoiceOver tests.

## Final assessment

YouNew is not an empty prototype. It is a technically credible, visually professional ecosystem with a substantial governed catalogue and real operational tooling.

It is also not yet a complete task-solving product. The next maturity jump will come from deeper practical guides and release evidence, not from adding more landing-page sections or visual decoration.
