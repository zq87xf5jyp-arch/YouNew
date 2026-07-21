# Priority-1 government source dossier

Status: `research_draft`  
Source verification date: 2026-07-20  
Reviewer: not assigned  
Publication authorised: no

This dossier is research input for the first YouNew practical guides. It is not published content. Every factual statement below has a matching fact ID and official source ID in [`priority-1-government-sources-2026-07-20.json`](./priority-1-government-sources-2026-07-20.json). A named human reviewer and the practical-guide fail-closed checks are still required before any guide can move to `published`.

Only Dutch government, executive-agency and municipality sources were used. No blogs, forums or commercial explainers were used.

## Editorial guardrails

- Keep national law and policy separate from municipal execution.
- Do not turn the residence-permit topic into one universal checklist. The correct IND route depends on nationality, purpose, sponsor and circumstances.
- Do not determine tax, allowance, residence or KVK eligibility for a user.
- Recheck operational instructions, deadlines and fees on the live source before review or publication.
- Do not add a reviewer, confidence level or verification date to a production guide until a real human review takes place.

## 1. Municipality registration, BRP and RNI

Target guide: `guide.registering-at-a-municipality`

### National baseline

- `REG-001`: A person planning to live in the Netherlands for longer than 4 months registers as a resident in the BRP with the municipality where they live.
- `REG-002`: The national deadline for a newly arrived resident is within 5 days of arrival. Accompanying partner and children attend too. A BSN is assigned through registration.
- `REG-003`: Registration is at a permanent home address or, when the legal conditions are met, a correspondence address.
- `REG-004`: Lawful-residence and identity checks can require extra evidence or investigation.
- `REG-005`: A person who lives abroad or will stay in the Netherlands for less than 4 months uses the RNI and receives a BSN on registration.
- `REG-006`: RNI desk registration is in person and free. The current national instructions list 19 desks. Dutch and EU/EEA/Swiss nationals can choose an eligible desk; other nationalities are currently directed to Breda or Venlo.
- `REG-007`: Registration of a child under 16 requires the child's identity document plus parentage evidence; foreign documents may need translation or legalisation.

Primary national sources:

- `src.gov.brp-resident` — [When should I register with the Personal Records Database as a resident?](https://www.government.nl/faq/when-should-i-register-with-the-personal-records-database-as-a-resident), Government of the Netherlands.
- `src.nww.rni-register` — [How can I register in the Non-residents Records Database (RNI)?](https://www.netherlandsworldwide.nl/non-residents-records-database/register), NetherlandsWorldwide.

### Amsterdam execution

- `REG-008`: Amsterdam's page specifies its own identity, occupancy and civil-status evidence for registration from abroad.
- `REG-009`: Amsterdam currently says first registration is in person without an appointment, except in Weesp; students follow a separate pre-registration route.
- `REG-010`: Amsterdam's local RNI route currently requires an appointment and an eligible European passport or identity card, and says the BSN is provided immediately. Other applicants are directed to Breda or Venlo.

Primary municipal sources:

- `src.amsterdam.first-registration` — [Moving from abroad (immigration)](https://www.amsterdam.nl/en/civil-affairs/first-registration/), City of Amsterdam.
- `src.amsterdam.rni` — [Registering in the Non-residents Records Database (RNI)](https://www.amsterdam.nl/en/civil-affairs/registering-rni/), City of Amsterdam.

Important caveat: the Amsterdam pages cannot be presented as the procedure for another municipality. Appointment availability and RNI desk rules are volatile and have a short reverification interval in the JSON dossier.

## 2. Getting a BSN

Target guide: `guide.getting-a-bsn`

- `BSN-001`: A BSN is a unique personal number automatically allocated to a person registered in the BRP.
- `BSN-002`: Residents get a BSN through municipal BRP registration. Eligible non-residents get one through RNI registration. Limited government-organisation routes exist only for specified circumstances.
- `BSN-003`: Someone who previously lived, worked or studied in the Netherlands may already have a BSN and should check before attempting another registration.
- `BSN-004`: For the ordinary resident and RNI routes, the BSN is a result of registration, not a separate standalone application.

Primary sources:

- `src.gov.bsn-overview` — [Citizen service number (BSN)](https://www.government.nl/themes/government-and-democracy/personal-data/citizen-service-number-bsn), Government of the Netherlands.
- `src.nww.bsn-get` — [How can I get a citizen service number (BSN) if I live abroad?](https://www.netherlandsworldwide.nl/bsn/how-to-get), NetherlandsWorldwide.
- The BRP, RNI and Amsterdam sources in section 1 supply the route-specific details.

Required UX branch before drafting steps:

1. Becoming a resident for longer than 4 months.
2. Living abroad or staying for less than 4 months.
3. Possibly already assigned a BSN.

## 3. Applying for DigiD

Target guide: `guide.applying-for-digid`

- `DIG-001`: DigiD identifies a user for online matters with participating government, education, healthcare and pension organisations.
- `DIG-002`: The standard resident application requires a BSN, an address registered with a Dutch municipality and a mobile phone.
- `DIG-003`: The activation letter goes to the address recorded in the BRP. The detailed official workflow says to allow up to 5 working days.
- `DIG-004`: The activation code must be used within 21 days; after expiry, the user applies again.
- `DIG-005`: DigiD is personal. The official delegation mechanism is DigiD Authorisation, not credential sharing.
- `DIG-006`: The route for someone living abroad requires a BSN, RNI registration, valid passport or identity card, a phone that receives Dutch SMS messages abroad and an email address. Activation depends on the available official method.

Primary sources:

- `src.digid.apply` — [Apply for a DigiD](https://www.digid.nl/en/apply-and-activate/apply-digid), DigiD / Logius.
- `src.digid.activate` — [Activate your DigiD](https://www.digid.nl/en/apply-and-activate/activate-your-digid), DigiD / Logius.
- `src.digid.abroad` — [I live abroad](https://www.digid.nl/en/living-abroad/), DigiD / Logius.

Important caveat: the application page uses both a 3-business-day summary and a maximum-5-working-day detailed statement. The dossier keeps the conservative maximum of 5 working days and flags it for reverification. Resident and abroad flows must be separate.

## 4. Residence permits and residence cards

Target guide: `guide.residence-permits`

### Safe route-selection facts

- `RES-001`: There is no universal application; the IND route depends on nationality, purpose, sponsor and circumstances.
- `RES-002`: EU/EEA/Swiss citizens do not generally need a Dutch residence permit, although the IND identifies a specific prior-residency situation in which registration is required.
- `RES-003`: Requirements, documents, sponsor duties, fees and decision periods must come from the selected current IND route.

Primary route sources:

- `src.ind.residence-permits` — [Residence permits](https://ind.nl/en/residence-permits), IND.
- `src.ind.eu-registration` — [Registering with the IND as an EU, EEA or Swiss citizen](https://ind.nl/en/residence-permits/eu-eea-or-swiss-citizens/registering-with-the-ind-as-an-eu-eea-or-swiss-citizen), IND; page last updated 2026-06-17.

### Collecting a residence document

- `RES-004`: Collect only after the IND confirms that the document is ready, at the location named in the message, and in person.
- `RES-005`: The standard collection checklist includes a valid passport or travel document, appointment code and any existing or expired residence document. A police report is needed when the prior document was lost or stolen.

Source:

- `src.ind.collect-document` — [Appointment to collect document](https://ind.nl/en/appointment-to-collect-document), IND; page last updated 2026-06-01.

### Lost or stolen residence card

- `RES-006`: Report loss or theft to the police, obtain a certified copy and include a copy with the replacement application.
- `RES-007`: If the loss occurs abroad, report it to local police. A report outside Dutch, English, French or German needs a sworn translation. Return travel may require a visa.
- `RES-008`: After the police report, the document is invalid even if later found; it must be handed in to the IND.
- `RES-009`: If a lost or stolen regular permit has less than 3 months remaining, the IND currently allows an extension or change application instead of replacement for that period, subject to the page's conditions.
- `RES-010`: The replacement page currently states an 8-week decision period that can be extended and says a fee applies. The live fee must be checked; no amount is stored here.

Source:

- `src.ind.lost-stolen-card` — [Residence permit lost or stolen](https://ind.nl/en/replace-extend-renew-and-change/residence-permit-lost-or-stolen), IND; page last updated 2026-06-12.

Publication blocker: this guide must remain a route selector until each intended permit route has its own sourced, reviewed instructions. Lost/stolen, damaged, expiring and changed-personal-details cases cannot be merged.

## 5. Taxes and allowances

Target guide: `guide.taxes-and-allowances`

### Income tax

- `TAX-001`: Someone invited to file must file. A person without an invitation may still have to file or may file to request a refund.
- `TAX-002`: The route differs for full-year non-residents and people who immigrated or emigrated during the tax year.
- `TAX-003`: The current Tax Administration page provides online, app and paper routes, with entrepreneurs generally filing online and stated exceptions for entrepreneurs living abroad.
- `TAX-004`: Tax partners use separate DigiD credentials. Filing for someone else uses an official authorisation.

Primary sources:

- `src.gov.tax-return` — [Tax return](https://www.government.nl/themes/taxes-benefits-and-allowances/income-tax/filing-a-tax-return), Government of the Netherlands.
- `src.taxadmin.filing-methods` — [Aangifte inkomstenbelasting doen: online, met de app of op papier](https://www.belastingdienst.nl/wps/wcm/connect/nl/belastingaangifte/content/hoe-aangifte-inkomstenbelasting-doen), Belastingdienst. This operational page is in Dutch and currently covers the 2025 return filed in 2026.

### Allowances

- `TAX-005`: A resident with health insurance, rented housing or children may qualify for a contribution, but eligibility is allowance-specific and never automatic.
- `TAX-006`: Applications can be made through Mijn toeslagen with DigiD; Dienst Toeslagen also offers telephone and assisted help.
- `TAX-007`: Payments are monthly advances followed by a final annual calculation. Relevant changes must be reported; excess payments may need repayment.
- `TAX-008`: The current Dutch page says relevant changes must be reported in Mijn toeslagen within 4 weeks. A move already reported to the municipality need not be reported again to Dienst Toeslagen.
- `TAX-009`: Thresholds, amounts, asset limits, deadlines and cross-border outcomes are tax-year- and person-specific and must not be treated as evergreen figures.

Primary sources:

- `src.toeslagen.how-benefits-work` — [How do benefits work?](https://www.belastingdienst.nl/wps/wcm/connect/bldcontenten/belastingdienst/individuals/benefits/how_do_benefits_work/), Dienst Toeslagen.
- `src.toeslagen.report-changes` — [Wijzigingen doorgeven voor uw toeslag](https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/toeslagen/wijzigingen_doorgeven/), Dienst Toeslagen.

Publication blocker: tax-year-specific amounts and conditions have not been modelled, and no tax reviewer is assigned. The guide may explain navigation and official handoffs, but must not calculate eligibility.

## 6. Moving to another municipality

Target guide: `guide.moving-to-another-municipality`

### National baseline

- `MOVE-001`: Report the move to the municipality of the new address from 4 weeks before until 5 days after moving.
- `MOVE-002`: A late report can make the report date the official moving date. A municipality may fine late reporting up to EUR 325 under the current source.
- `MOVE-003`: The baseline evidence is valid identification and proof of occupancy; the receiving municipality specifies its exact form and upload route.
- `MOVE-004`: The new municipality updates the BRP and the prior municipality deregisters the resident.
- `MOVE-005`: Wmo and social-assistance services may not transfer automatically; ask the new municipality about continued eligibility and applications.
- `MOVE-006`: For a residence-permit holder who reports on time, the municipality forwards the address to the IND. If the municipal report is late, the person must also notify the IND.

Primary sources:

- `src.gov.change-address` — [How do I inform the municipality of a change of address?](https://www.government.nl/faq/how-do-i-inform-the-municipality-of-a-change-of-address), Government of the Netherlands.
- `src.gov.foreign-national-move` — [As a foreign national, do I need to inform the Immigration and Naturalisation Service (IND) if I move?](https://www.government.nl/faq/as-a-foreign-national-do-i-need-to-inform-the-immigration-and-naturalisation-service-ind-if-i-move), Government of the Netherlands.

### Amsterdam execution

- `MOVE-007`: Amsterdam lists online, City Office and post routes with local occupancy evidence and currently states processing within 3 weeks after the move date.
- `MOVE-008`: A person moving from Amsterdam to another municipality reports to the new municipality.

Municipal source:

- `src.amsterdam.change-address` — [Reporting a change of address](https://www.amsterdam.nl/en/civil-affairs/reporting-change-address/), City of Amsterdam.

Publication blocker: only Amsterdam's municipal variant is researched. The generic guide must link to the user's receiving municipality instead of displaying Amsterdam steps as national steps.

## 7. Starting a business

Target guide: `guide.starting-a-business`

- `BUS-001`: The official start-up plan is a general guideline; immigration status, sector, location, staff, products and starting situation can add requirements.
- `BUS-002`: KVK currently uses three core registration criteria: independent products or services, income from them, and regular supply beyond family and friends. Borderline cases require KVK assessment.
- `BUS-003`: The founder chooses a legal structure because it affects liability, tax and registration. Legal entities such as a BV or NV use a civil-law notary. `zzp` and `freelancer` are ways of working, not legal structures.
- `BUS-004`: A founder from outside the EU/EEA/Switzerland may need an appropriate residence permit and must use the relevant IND route.
- `BUS-005`: The ordinary Dutch route requires a BSN and a Dutch business address. The official page identifies extra address evidence for an RNI-registered non-resident.
- `BUS-006`: The ordinary self-registration route includes the KVK form, an appointment, identity verification and the evidence listed in the appointment confirmation.
- `BUS-007`: KVK currently says to register 1 week before or after activities begin. Details can be checked up to 3 months before the start date.
- `BUS-008`: KVK passes ordinary registration details to Belastingdienst, but KVK and Belastingdienst use different entrepreneur criteria. Tax status is decided separately.
- `BUS-009`: The one-time registration fee is EUR 85.15 for 2026. It changes annually; extracts and notarial costs are separate.
- `BUS-010`: The founder must separately check permits, professional requirements and location rules for the actual activity.
- `BUS-011`: Business Register information is public. A founder using a home address should check current address-shielding rules.

Primary sources:

- `src.businessgov.start-plan` — [Step-by-step plan: How to start a business in the Netherlands](https://business.gov.nl/starting-your-business/preparations/step-by-step-plan-how-to-start-a-business-in-the-netherlands/), Business.gov.nl; checked 2025-12-19.
- `src.businessgov.register-kvk` — [Register your Dutch business with KVK](https://business.gov.nl/starting-your-business/registering-your-business/registration-at-the-netherlands-chamber-of-commerce-kvk/), Business.gov.nl.
- `src.kvk.entrepreneur-criteria` — [Do you need to register your business with KVK?](https://www.kvk.nl/en/starting/do-you-need-to-register-your-business-with-kvk/), KVK; edited 2026-07-15.
- `src.kvk.registration-fee-2026` — [Registration fee](https://www.kvk.nl/en/registration/registration-fee/), KVK; edited 2026-01-01.
- Residence-status routing also relies on `src.ind.residence-permits`.

Publication blocker: the final guide needs branches for residence status, legal structure, location and regulated activity. The 2026 fee expires as an evergreen fact at the end of the year.

## Source-to-fact integrity

The JSON contains a bidirectional mapping:

- every `fact` has one or more `source_ids`;
- every `source` lists its `supports_fact_ids`;
- every topic dossier lists the exact facts intended for its guide.

Before editorial use, validate that every referenced ID exists in both directions and that all sources still return an official page. Any missing, redirected-to-unrelated or materially changed source must block publication until the fact is re-researched.

## Next editorial steps

1. Assign named human reviewers for civil registration, immigration, tax/allowances and business registration.
2. Convert factual statements into short factual blocks while preserving their source IDs.
3. Draft national decision trees first, then attach municipality-specific modules.
4. Reopen sources with short `reverify_by` dates immediately before review.
5. Keep all guides in `draft` or `review` until the reviewer, verification date and source-per-step validation are complete.

