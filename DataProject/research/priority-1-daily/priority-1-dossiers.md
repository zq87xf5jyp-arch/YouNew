# Priority-1 daily official-source dossiers

Status: **research_draft**  
Verified: **2026-07-20**  
Locale: **English research notes**  
Publication: **blocked until editorial review and fail-closed practical-guide validation**

This file is a human-readable companion to `priority-1-dossiers.json`. It records only facts directly supported by the named primary official sources. It is not user-facing guidance, legal or medical advice, and it must not be imported into a published release as-is.

## 1. Finding a huisarts

Jurisdiction: national, with regional/provider availability.

Supported facts:

- `gp.registration-recommended-not-mandatory` → `gp.gov-moving-arrangements`: registering with a family doctor is not mandatory, but Government.nl recommends it so care is accessible when needed.
- `gp.finding-help` → `gp.gov-moving-arrangements`: Government.nl directs people needing help finding a GP to their municipality or insurer.
- `gp.choose-nearby` → `gp.zin-gp-coverage`: Zorginstituut describes a 15-minute home-visit guideline and advises choosing a nearby practice. This is not an acceptance guarantee.
- `gp.care-mediation` → `gp.nza-care-mediation`: where a provider has excessive waiting or a patient stop, an insured patient can ask the insurer for care mediation.
- `gp.coverage-and-deductible` → `gp.zin-gp-coverage`: GP care itself is in the basic package and not subject to the compulsory deductible; prescribed medicines, external tests and referred care may be.

Sources:

- `gp.gov-moving-arrangements` — [What do I need to arrange if I’m moving to the Netherlands?](https://www.government.nl/faq/what-do-i-need-to-arrange-if-im-moving-to-the-netherlands), Government of the Netherlands.
- `gp.nza-care-mediation` — [Zorgbemiddeling](https://www.nza.nl/onderwerpen/i/informatieverstrekking-door-zorgaanbieders/zorgbemiddeling), Nederlandse Zorgautoriteit.
- `gp.zin-gp-coverage` — [Huisarts (Zvw)](https://www.zorginstituutnederland.nl/verzekerde-zorg/h/huisarts-zvw), Zorginstituut Nederland.

Gaps:

- No permitted source provides one national registration form, universal document list, acceptance radius, processing time or guarantee of space.
- A publishable guide still needs a locality-aware practice-finding route.
- No commercial or provider directory was accepted as evidence.

## 2. Dutch health insurance

Jurisdiction: national, with status-dependent exceptions.

Supported facts:

- `insurance.four-month-rule` → `insurance.gov-arrival-duty`: people subject to Dutch insurance duty must arrange coverage as soon as possible and no later than four months after arrival, effective from arrival.
- `insurance.basic-versus-supplementary` → `insurance.gov-taking-out`: the standard package is compulsory when the duty applies; supplementary insurance is optional.
- `insurance.deductible-2026` → `insurance.zin-deductible-2026`: the 2026 compulsory deductible is €385 for insured people aged 18+, with GP and out-of-hours GP care among the listed exemptions.
- `insurance.cak-letter-actions` → `insurance.cak-uninsured-letter`: after an uninsured letter, arrange required insurance or request an SVB Wlz assessment if the duty is disputed.
- `insurance.cak-fine-2026` → `insurance.cak-uninsured-letter`: the CAK page states a €529.74 fine in 2026 after three months without either action; the amount is indexed annually.

Sources:

- `insurance.gov-arrival-duty` — [When do I need to take out compulsory health insurance?](https://www.government.nl/faq/health-insurance/when-do-i-need-to-take-out-health-insurance-if-i-come-to-live-in-the-netherlands), Government of the Netherlands.
- `insurance.gov-taking-out` — [Taking out compulsory health insurance](https://www.government.nl/themes/family-health-and-care/health-insurance/standard-health-insurance/taking-out-compulsory-health-insurance), Government of the Netherlands.
- `insurance.zin-deductible-2026` — [Eigen risico (Zvw)](https://www.zorginstituutnederland.nl/verzekerde-zorg/e/eigen-risico-zvw), Zorginstituut Nederland.
- `insurance.cak-uninsured-letter` — [I received a letter that I'm uninsured](https://www.hetcak.nl/en/uninsured/received-letter-uninsured/), CAK.

Gaps and caveats:

- Foreign-employer, EU-institution, international-student, asylum and residence-status cases require separate branches.
- Premiums, provider contracting and reimbursement details are policy-specific.
- The 2026 deductible and fine must not be reused in another year without reverification.
- Healthcare-benefit eligibility requires a separate Tax Administration dossier.

## 3. Emergency numbers and urgent help

Jurisdiction: national; out-of-hours GP contacts are regional.

Supported facts:

- `emergency.call-112` → `emergency.gov-when-112`: use 112 for immediate danger, serious injury needing prompt medical attention, or witnessing a serious crime.
- `emergency.tell-operator` → `emergency.gov-when-112`: tell the operator what happened, what help is needed and which emergency service appears necessary.
- `emergency.hap-before-ed` → `emergency.rijk-hap-seh`: when the regular GP is closed, contact the out-of-hours GP service before hospital emergency care, except in a life-threatening situation, when 112 is the direct route.
- `emergency.cost-routing` → `emergency.rijk-hap-seh`: GP and out-of-hours GP care do not consume the compulsory deductible; hospital emergency care does.
- `emergency.police-nonurgent` → `emergency.police-contact`: 112 is free for police emergencies; 0900-8844 is the Netherlands Police non-emergency number; +31 343 57 8844 is the police number from abroad.

Sources:

- `emergency.gov-when-112` — [When can I call 112?](https://www.government.nl/faq/emergency-number-112/when-can-i-call-112), Government of the Netherlands.
- `emergency.rijk-hap-seh` — [Wanneer moet ik naar de huisartsenpost of de spoedeisende hulppost?](https://www.rijksoverheid.nl/vraag-en-antwoord/eerstelijnszorg/huisartsenpost-spoedeisende-hulp), Rijksoverheid.
- `emergency.police-contact` — [Contact](https://www.politie.nl/en/contact), Netherlands Police.

Gaps:

- A region-aware source is required for actual out-of-hours GP phone numbers.
- No symptom-by-symptom medical triage is inferred.
- Other crisis lines and specialised emergency contacts need separate official verification.

## 4. Renting a home

Jurisdiction: mixed national/municipal.

Supported facts:

- `renting.check-sector-and-rent` → `renting.gov-tenant-plan`, `renting.huurcommissie-rent-check`: determine the rental sector and use the matching official Rent Check.
- `renting.deposit-contracts-after-2023` → `renting.gov-tenant-plan`: for agreements dated 1 July 2023 or later, the maximum deposit stated by Government.nl is two months' basic rent.
- `renting.written-contract` → `renting.gov-tenant-plan`: agreements from that date must be in writing and specified tenancy information must be provided in writing.
- `renting.contract-content` → `renting.rijk-contract-content`: distinguish basic rent and service costs, record core terms, and record property condition at the start.
- `renting.mediation-fee` → `renting.gov-tenant-plan`: an agent acting for the landlord cannot also charge the tenant mediation fees; an independently instructed agent is different.
- `renting.municipal-permit-variation` → `renting.gov-tenant-plan`: some municipalities require a rental permit and can attach conditions.

Sources:

- `renting.gov-tenant-plan` — [Step-by-step plan for tenants](https://www.government.nl/themes/building-and-housing/housing/rented-housing/step-by-step-plan-for-tenants), Government of the Netherlands.
- `renting.rijk-contract-content` — [Welke afspraken staan er in het huurcontract van mijn woning?](https://www.rijksoverheid.nl/vraag-en-antwoord/woning-huren/welke-afspraken-staan-er-in-het-huurcontract-van-mijn-woning), Rijksoverheid.
- `renting.huurcommissie-rent-check` — [Huurprijscheck](https://www.huurcommissie.nl/support/huurprijscheck), Huurcommissie.

Gaps:

- No permitted source provides a national live inventory or verifies individual listings or landlords.
- Local permits and allocation rules need city-specific sources.
- Annual thresholds and point values must be reverified rather than treated as evergreen text.

## 5. Reporting housing defects

Jurisdiction: mixed national/municipal.

Supported facts:

- `defects.notify-landlord-writing` → `defects.rijk-maintenance`: report defects first by email or letter, ask for repair within six weeks, keep a copy, and request urgency when appropriate.
- `defects.huurcommissie-after-six-weeks` → `defects.huurcommissie-procedure`: the Huurcommissie defect procedure requires the six-week repair opportunity and dated evidence of notification.
- `defects.route-varies-by-sector` → `defects.huurcommissie-procedure`: Huurcommissie authority varies by sector and contract date; private-sector advice requires written agreement by both parties.
- `defects.municipal-building-control` → `defects.rijk-maintenance`: the municipality can assess compliance with the Building Works Living Environment Decree and can order or arrange repair when its order is ignored.
- `defects.good-landlord-reporting-point` → `defects.ministry-reporting-point`: each municipality has a Good Landlordship reporting point for specified landlord-conduct violations. This is not automatically the physical-repair route.

Sources:

- `defects.rijk-maintenance` — [Hoe zorg ik ervoor dat de verhuurder slecht onderhoud aanpakt?](https://www.rijksoverheid.nl/vraag-en-antwoord/woning-huren/hoe-zorg-ik-ervoor-dat-de-verhuurder-slecht-onderhoud-aanpakt), Rijksoverheid.
- `defects.huurcommissie-procedure` — [Hoofdstuk 3 - Procedurele regels](https://www.huurcommissie.nl/support/beleidsboeken/gebreken/procedure-regels), Huurcommissie.
- `defects.ministry-reporting-point` — [Gemeentelijk meldpunt goed verhuurderschap](https://www.volkshuisvestingnederland.nl/onderwerpen/huren-en-wonen/wet-goed-verhuurderschap/gemeentelijk-meldpunt-goed-verhuurderschap), Ministry of the Interior and Kingdom Relations.

Gaps:

- The correct escalation route depends on sector, contract date, defect and municipality.
- Immediate gas, fire and structural dangers need dedicated safety sources.
- Court strategy and legal drafting are outside this research dossier.

## 6. Using public transport

Jurisdiction: national operator services.

Supported facts:

- `transport.plan-and-recheck` → `transport.9292-planner-faq`: use the planner for journey options and planned disruptions, and recheck close to departure for the correct date/time.
- `transport.accessible-planning` → `transport.9292-planner-faq`: the accessible-journey option adds transfer time and routes via stops/stations marked accessible; it is not an operational guarantee.
- `transport.ovpay-contactless` → `transport.ns-debit-card`: valid contactless debit/credit cards or a mobile device can be used without prior activation, using the same card/device to check out.
- `transport.same-operator` → `transport.ns-check-in-out`: check out with the operator used to check in; switching train operator can require check-out/check-in.
- `transport.ovpay-limitations` → `transport.ns-debit-card`: NS describes debit-card travel as second class without discount and directs season-ticket users to the product/card tied to their season ticket.

Sources:

- `transport.9292-planner-faq` — [Frequently asked questions about the 9292 travel planner](https://9292.nl/en/contact/faq/faq-9292-travel-planner/), 9292.
- `transport.ns-debit-card` — [Check in and out with your debit card](https://www.ns.nl/en/travel/check-in-check-out/debit-card), NS.
- `transport.ns-check-in-out` — [Checking in and out](https://www.ns.nl/en/travel/check-in-check-out), NS.

Gaps:

- No fixed fares, supplements or discounts are included.
- Bus, tram, metro and ferry operator exceptions need separate operator evidence.
- Journey advice is time-sensitive and must not be cached as permanent operational truth.

## 7. Finding work

Jurisdiction: national, with EU/EEA/Swiss-specific branches.

Supported facts:

- `work.eures-uwv` → `work.uwv-working-netherlands`: EURES helps jobseekers in the EU/EEA and Switzerland; UWV coordinates it in the Netherlands.
- `work.work-folder-functions` → `work.uwv-portals`: Work Folder supports CV posting, vacancy search and courses/webinars; benefit recipients can also report activities there.
- `work.foreign-benefit-pdu2` → `work.uwv-foreign-job-search`: a person exporting an unemployment benefit with PD U2 from another EU/EEA country or Switzerland must register with UWV by phone within seven days. This does not apply to all jobseekers.
- `work.ww-activities-context` → `work.uwv-job-search-requirement`: UWV lists activities and evidence-retention expectations for people subject to the unemployment-benefit job-search requirement. They are not universal duties.

Sources:

- `work.uwv-working-netherlands` — [Working in the Netherlands](https://www.uwv.nl/en/individuals/working-in-the-netherlands), UWV.
- `work.uwv-portals` — [How to use and access our UWV portals](https://www.uwv.nl/en/accessingoursecureportals/how-to-use-and-access-our-uwv-portals), UWV.
- `work.uwv-foreign-job-search` — [Werk zoeken in Nederland](https://www.uwv.nl/nl/buitenland/werken-in-nederland/werk-zoeken-nederland), UWV.
- `work.uwv-job-search-requirement` — [The job search requirement](https://www.uwv.nl/en/individuals/unemployment-benefit/job-search-requirement), UWV.

Gaps:

- No universal end-to-end job-search workflow or outcome guarantee is supported.
- Work-permit branches need nationality/residence/job-specific primary evidence.
- Commercial job boards, salary advice and recruitment recommendations are excluded.

## 8. Understanding an employment contract

Jurisdiction: national.

Supported facts:

- `contract.information-one-week` → `contract.rijk-content`: specified core information must be provided in writing within one week after employment starts.
- `contract.information-one-month` → `contract.rijk-content`: specified holiday, notice, pension, non-compete and collective-agreement information must be provided within one month.
- `contract.written-advisable` → `contract.rijk-content`: oral contracts can exist, but Rijksoverheid advises writing the agreement down.
- `contract.fixed-versus-permanent` → `contract.rijk-fixed-permanent`: fixed terms normally end automatically and usually cannot be ended early unless agreed; permanent contracts continue until properly ended.
- `contract.cao-priority` → `contract.rijk-cao`: an applicable CAO takes priority over the individual contract, subject to the official favourable/deviation rules.

Sources:

- `contract.rijk-content` — [Wat staat er in een arbeidsovereenkomst?](https://www.rijksoverheid.nl/vraag-en-antwoord/arbeidsovereenkomst-en-cao/wat-staat-er-in-een-arbeidsovereenkomst), Rijksoverheid.
- `contract.rijk-fixed-permanent` — [Wat is het verschil tussen een tijdelijk contract en een vast contract?](https://www.rijksoverheid.nl/vraag-en-antwoord/arbeidsomstandigheden/wat-is-het-verschil-tussen-een-tijdelijk-contract-en-een-vast-contract), Rijksoverheid.
- `contract.rijk-cao` — [Wat is een cao?](https://www.rijksoverheid.nl/vraag-en-antwoord/arbeidsovereenkomst-en-cao/wat-is-een-cao), Rijksoverheid.

Gaps:

- No individual contract or CAO was reviewed.
- Probation, dismissal, notice, non-compete, agency and zero-hours branches need separate evidence.
- Announced future flex-work legislation is not assumed to be law in force.

## 9. Opening a Dutch bank account

Jurisdiction: national consumer banking.

Supported facts:

- `bank.ordinary-account-discretion` → `bank.rijk-rejected-account`, `bank.dnb-kyc`: a bank decides on an ordinary account application and performs legally required KYC/source-of-funds checks.
- `bank.identity-verification` → `bank.dnb-kyc`: identity must be verified; the bank may request an ID copy and other data, and must explain why data is needed. DNB mentions BSN where required by tax laws, not as a universal ordinary-account prerequisite.
- `bank.basic-account-fallback` → `bank.rijk-rejected-account`: a consumer unable to open an ordinary account can apply for a basic payment account, subject to statutory refusal grounds and a genuine Netherlands connection.
- `bank.rejection-complaint` → `bank.rijk-rejected-account`: complain to the bank first, then potentially Kifid or court.

Sources:

- `bank.rijk-rejected-account` — [Wat kan ik als consument doen als ik geen betaalrekening kan krijgen?](https://www.rijksoverheid.nl/vraag-en-antwoord/betalingsverkeer/afwijzing-betaalrekening-consument), Rijksoverheid.
- `bank.dnb-kyc` — [Combating money laundering and fraud](https://www.dnb.nl/en/reliable-financial-sector/combating-money-laundering-and-fraud/), De Nederlandsche Bank.

Gaps:

- No universal document checklist, fee, approval time or remote-onboarding route is supported.
- The evidence does not support saying a BSN is always required for every ordinary account.
- Business accounts, credit, savings and bank comparisons are outside scope.

## 10. Studying in the Netherlands

Jurisdiction: national higher education with institution-specific admission.

Supported facts:

- `study.verify-recognition` → `study.gov-higher-education`: verify official recognition and NVAO accreditation before enrolling.
- `study.application-deadlines` → `study.rijk-deadlines`: the general first bachelor/associate-degree deadline is 1 May via Studielink; numerus fixus uses 15 January; master deadlines are programme-specific.
- `study.admission-institution-specific` → `study.rijk-deadlines`: the institution decides admission and requirements vary.
- `study.tuition-types-2026` → `study.duo-tuition`: statutory and institutional tuition exist; statutory tuition is €2,694 for 2026-2027, subject to criteria; institutional fees are set by institutions.
- `study.finance-conditional` → `study.duo-finance`: student finance depends on enrolment, nationality/equivalent rights and other conditions and is not always a gift.

Sources:

- `study.gov-higher-education` — [Tertiary (higher) education](https://www.government.nl/themes/education/secondary-vocational-education-mbo-and-tertiary-higher-education/tertiary-higher-education), Government of the Netherlands.
- `study.rijk-deadlines` — [Wanneer moet ik me aanmelden voor een opleiding aan de universiteit of hogeschool?](https://www.rijksoverheid.nl/vraag-en-antwoord/hoger-onderwijs/deadline-aanmelden-opleiding-hogeschool-of-universiteit), Rijksoverheid.
- `study.duo-tuition` — [Tuition fees](https://www.duo.nl/particulier/tuition-fees.jsp), DUO.
- `study.duo-finance` — [Student finance](https://duo.nl/particulier/student-finance/), DUO.

Gaps:

- MBO, HBO, WO, bachelor, master, numerus-fixus and February-entry branches need separate treatment.
- Visa, residence permit, foreign qualification and institution document branches remain incomplete.
- No blanket eligibility claim for international students is supported.

## 11. Student housing

Jurisdiction: mixed national/municipal.

Supported facts:

- `student-housing.search-routes` → `student-housing.rijk-study-checklist`, `student-housing.rijk-moving-room`: search routes can include student-room housing associations, private landlords, advertisements, agents and personal networks. This is not a live listing or availability guarantee.
- `student-housing.contract-and-address` → `student-housing.rijk-moving-room`: after finding a room, use a tenancy agreement and report the new address to the municipality on time.
- `student-housing.possible-permit` → `student-housing.rijk-moving-room`: a housing permit may be required depending on the local situation.
- `student-housing.room-rent-check` → `student-housing.gov-tenant-plan`, `student-housing.huurcommissie-rent-check`: shared accommodation is treated as social housing in the national plan and has a dedicated Huurcommissie Rent Check.
- `student-housing.standard-tenant-protections` → `student-housing.gov-tenant-plan`: student rooms remain subject to ordinary written-agreement, deposit, service-cost and landlord-conduct checks.

Sources:

- `student-housing.rijk-moving-room` — [Op kamers: wat moet ik regelen?](https://www.rijksoverheid.nl/vraag-en-antwoord/huurwoning-zoeken/op-kamers-wat-moet-ik-regelen), Rijksoverheid.
- `student-housing.rijk-study-checklist` — [Studeren: check wat je moet regelen](https://www.rijksoverheid.nl/themas/onderwijs/studeren/studeren-regelzaken-op-een-rij), Rijksoverheid.
- `student-housing.gov-tenant-plan` — [Step-by-step plan for tenants](https://www.government.nl/themes/building-and-housing/housing/rented-housing/step-by-step-plan-for-tenants), Government of the Netherlands.
- `student-housing.huurcommissie-rent-check` — [Huurprijscheck](https://www.huurcommissie.nl/support/huurprijscheck), Huurcommissie.

Gaps:

- No official national live inventory, universal waiting time or guaranteed student-housing route exists in the permitted source set.
- Local allocation, permits, campus housing and address registration require city and institution evidence.
- Housing-benefit eligibility for a particular room is not established.

## Publication gate

None of these dossiers is a full practical guide. Before any guide becomes `published`, an editor must:

1. choose only supported facts and map every factual block to the stable source IDs above;
2. add locality-specific sources where the dossier says jurisdiction is municipal or mixed;
3. reverify annual amounts, thresholds and deadlines at publication time;
4. add prerequisites, required documents, numbered steps, warnings, contacts and next actions only where directly supported;
5. assign a named reviewer and `verifiedAt` date;
6. pass the existing fail-closed practical-guide schema and QA pipeline.
