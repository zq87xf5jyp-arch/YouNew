# YouNew content readiness matrix

Evidence date: **2026-10-24**. This is a read-only local audit; no live URL check was performed.

## Outcome

**NOT PRODUCTION READY for the attached 100%-content brief.** The repository has substantial governed summary inventory, but no practical guide passes the fail-closed production contract.

- Governed records: **454**; effectively published: **177**.
- Guide-capable material records: **281**; effectively published material records: **15**.
- Material lifecycle states: **{"published": 15, "qa": 266}**.
- Public guides: **1 summary / 0 full**.
- Source-backed guide QA packets: **20**; production-ready guides: **0**.
- Published FAQ: **0/300**; staged draft FAQ: **60**; staged search questions (not FAQ): **20**.
- Governed topic families with zero inventory records: **0**.
- Governed topic families with zero effective published records: **36/36**.
- Repository content-target coverage: **266/3000 (8.9%)**; production-ready: **0/3000 (0.0%)**.
- Stale governed records: **410**; stale guide-capable records: **272**.
- Audit integrity/reconciliation: **PASSED**.

## Denominators and interpretation

Coverage is not an invented score. Target-level coverage uses `DataProject/coverage-targets.json`; topic-family coverage uses the minimum-per-family values in `DataProject/coverage-dimensions.json`. Percentages are capped at 100%, so surplus in one family cannot hide an empty family. Production readiness uses the stricter brief contract listed in the JSON `definitions.production_ready` field.

## Repository target coverage

| Target | Materials | Target denominator | Coverage | Published | Ready full guides | Production ready |
| --- | --- | --- | --- | --- | --- | --- |
| government | 105 | 1000 | 10.5% | 0 | 0 | 0.0% |
| housing | 41 | 500 | 8.2% | 0 | 0 | 0.0% |
| healthcare | 40 | 500 | 8.0% | 0 | 0 | 0.0% |
| transport | 40 | 500 | 8.0% | 0 | 0 | 0.0% |
| education | 40 | 500 | 8.0% | 0 | 0 | 0.0% |

## Proposed priority coverage

P1/P2/P3 is a report-only editorial proposal over existing topic-family keys. The brief supplies examples but no canonical priority field, so this audit does not write the classification into content.

| Priority | Covered families | Family coverage | Covered slots | Slot coverage | Ready slots | Production ready |
| --- | --- | --- | --- | --- | --- | --- |
| P1 | 22/22 | 100.0% | 160/160 | 100.0% | 0/160 | 0.0% |
| P2 | 10/10 | 100.0% | 70/70 | 100.0% | 0/70 | 0.0% |
| P3 | 4/4 | 100.0% | 30/30 | 100.0% | 0/30 | 0.0% |

## Governed topic-family matrix

| P | Target | Family | Materials | Minimum | Coverage | Published | Full | Ready | Ready % | Draft associations |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2 | education | schools | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | education | higher-education | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | education | duo | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | education | civic-integration | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | transport | rail-travel | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | transport | public-transport-payment | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 2 | transport | cycling | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 3 | transport | parking | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | healthcare | primary-care | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | healthcare | health-insurance | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 2 | healthcare | hospitals-specialists | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | healthcare | emergency-care | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | housing | renting | 11 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 2 |
| 3 | housing | home-buying | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | housing | tenant-rights | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 3 |
| 2 | housing | utilities | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | government | identity-registration | 6 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | digital-government | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | immigration-residency | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | citizenship-integration | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | taxes | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | benefits-allowances | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 2 |
| 1 | government | employment-unemployment | 6 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 2 |
| 2 | government | business-entrepreneurship | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | government | health-insurance | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 2 |
| 2 | government | family-parenthood | 6 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | government | education-finance | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 2 | government | driving-transport | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 2 | government | documents-certificates | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 2 | government | pensions-social-security | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | government | housing-local-services | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | justice-legal-aid | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | safety-emergencies | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 3 | government | voting-democracy | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 2 | government | consumer-privacy | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 3 | government | death-inheritance | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |

## Observed canonical material categories

This table uses the observed category count as the denominator for summary-field completeness; it does not claim that the observed count is the desired topic coverage target.

| WP | Category | Denominator | Base complete | Completeness | Published | Ready | No image | No steps | No FAQ |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| WP-01 | banking | 2 | 2/2 | 100.0% | 0 | 0 | 2 | 2 | 2 |
| WP-01 | benefits | 5 | 0/5 | 0.0% | 0 | 0 | 5 | 5 | 5 |
| WP-01 | business | 5 | 0/5 | 0.0% | 0 | 0 | 5 | 5 | 5 |
| WP-01 | certificates | 3 | 0/3 | 0.0% | 0 | 0 | 3 | 3 | 3 |
| WP-01 | citizenship | 3 | 0/3 | 0.0% | 0 | 0 | 3 | 3 | 3 |
| WP-01 | civil_status | 4 | 0/4 | 0.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | consumer_rights | 4 | 0/4 | 0.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | death | 2 | 0/2 | 0.0% | 0 | 0 | 2 | 2 | 2 |
| WP-01 | democracy | 1 | 0/1 | 0.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | digital_government | 4 | 0/4 | 0.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | digital_identity | 1 | 1/1 | 100.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | document_legalisation | 2 | 0/2 | 0.0% | 0 | 0 | 2 | 2 | 2 |
| WP-01 | driving_documents | 4 | 0/4 | 0.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | driving_licence | 1 | 0/1 | 0.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | education_finance | 5 | 0/5 | 0.0% | 0 | 0 | 5 | 5 | 5 |
| WP-01 | elections | 4 | 0/4 | 0.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | emergencies | 1 | 0/1 | 0.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | employment | 6 | 1/6 | 16.7% | 0 | 0 | 6 | 6 | 6 |
| WP-01 | family_leave | 2 | 0/2 | 0.0% | 0 | 0 | 2 | 2 | 2 |
| WP-01 | healthcare | 4 | 1/4 | 25.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | healthcare_registration | 1 | 0/1 | 0.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | housing | 3 | 0/3 | 0.0% | 0 | 0 | 3 | 3 | 3 |
| WP-01 | identification_documents | 1 | 0/1 | 0.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | identity | 1 | 1/1 | 100.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | immigration | 5 | 1/5 | 20.0% | 0 | 0 | 5 | 5 | 5 |
| WP-01 | inheritance | 3 | 0/3 | 0.0% | 0 | 0 | 3 | 3 | 3 |
| WP-01 | integration | 2 | 0/2 | 0.0% | 0 | 0 | 2 | 2 | 2 |
| WP-01 | justice | 4 | 0/4 | 0.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | legal_aid | 1 | 0/1 | 0.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | local_services | 2 | 0/2 | 0.0% | 0 | 0 | 2 | 2 | 2 |
| WP-01 | municipal_registration | 4 | 1/4 | 25.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | privacy_data | 1 | 0/1 | 0.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | safety | 4 | 0/4 | 0.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | social_security | 5 | 0/5 | 0.0% | 0 | 0 | 5 | 5 | 5 |
| WP-01 | taxes | 5 | 0/5 | 0.0% | 0 | 0 | 5 | 5 | 5 |
| WP-02 | home_buying | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-02 | renting | 11 | 1/11 | 9.1% | 0 | 0 | 11 | 11 | 11 |
| WP-02 | tenant_rights | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-02 | utilities | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-03 | emergency_care | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-03 | health_insurance | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-03 | hospitals_specialists | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-03 | primary_care | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-04 | cycling | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-04 | parking | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-04 | public_transport_payment | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-04 | rail_travel | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-05 | civic_integration | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-05 | duo | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-05 | higher_education | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-05 | schools | 10 | 0/10 | 0.0% | 0 | 0 | 10 | 10 | 10 |
| WP-06 | civil-affairs | 2 | 0/2 | 0.0% | 2 | 0 | 0 | 2 | 2 |
| WP-06 | civil-status | 2 | 0/2 | 0.0% | 2 | 0 | 0 | 2 | 2 |
| WP-06 | driving-documents | 1 | 0/1 | 0.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | identity-documents | 1 | 0/1 | 0.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | municipal-housing-information | 2 | 0/2 | 0.0% | 2 | 0 | 0 | 2 | 2 |
| WP-06 | municipal-housing-service | 1 | 0/1 | 0.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | municipal-taxes | 1 | 0/1 | 0.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | parking | 1 | 0/1 | 0.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | public-space | 1 | 0/1 | 0.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | social-housing-platform | 1 | 0/1 | 0.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | tenant-support | 1 | 0/1 | 0.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | waste-recycling | 1 | 0/1 | 0.0% | 1 | 0 | 0 | 1 | 1 |

## Quality gaps

- Material records without an official parent source: **0/281**.
- Material records without a verified image: **266/281**.
- Material records without published steps: **281/281**.
- Material records without published FAQ: **281/281**.
- Staged guides without reviewer, verified date, official guide sources, steps and FAQ: **20/20**, **0/20**, **0/20**, **0/20**, **0/20**.
- Staged guides with no canonical source entity IDs: **1** (guide.pets-and-veterinary-care).
- Conservative placeholder hits: canonical **0**, staged guides **0**.
- Missing canonical source IDs referenced by scaffolds: **0** (none).
- Stale governed records under `freshness-policy.json`: **410** (government.mijnoverheid, government.passport-id-card, government.healthcare-benefit, government.housing-benefit, government.childcare-benefit, government.income-tax-return, government.naturalisation, government.foreign-driving-licence-exchange, government.rni-registration, government.change-address, government.vog, government.driving-licence-application, government.child-benefit, government.unemployment-benefit, government.aow-pension, government.student-finance, government.birth-registration, government.marriage-registered-partnership, government.donor-register, government.child-budget, government.civic-integration, government.permanent-residence, government.partner-residence-permit, government.work-permit, government.business-registration, government.parental-leave, government.maternity-pay, government.acknowledge-child, government.deregister-moving-abroad, government.foreign-document-legalisation, government.civil-status-extract, government.housing-permit, government.municipal-taxes, government.report-crime, government.subsidised-legal-aid, government.emergency-number-112, government.nl-alert, government.municipal-election-voting, government.parliamentary-democracy, government.consumer-complaint, government.privacy-rights, government.after-death-checklist, government.inheritance-choice, government.vat-numbers, government.tax-disagreement, government.minimum-wage, government.employment-contract, government.business-legal-structure, government.ubo-register, government.tuition-fees, government.credential-evaluation, government.lost-driving-licence, government.eherkenning, government.uninsured-health-insurance, government.option-procedure, government.legalise-dutch-document, government.anw-survivor-benefit, government.rent-tribunal, government.going-to-court, government.emergency-kit, government.voting-abroad, government.legal-product-guarantee, government.inheritance-tax-return, government.expat-scheme-30-percent, government.provisional-tax-assessment, government.holiday-hours, government.sickness-benefit, government.business-records-retention, government.deregister-business, government.student-travel-product, government.higher-education-enrolment, government.renew-driving-licence-online, government.drive-with-foreign-licence, government.digid-authorisation, government.european-login, government.highly-skilled-migrant, government.student-residence-permit, government.renounce-nationality, government.integration-exam-registration, government.register-family-doctor, government.change-health-insurance, government.rent-increase-rules, government.woz-objection, government.public-authority-complaint, government.report-discrimination, government.consular-certificate, government.certificate-of-life, government.claim-aow-pension, government.orphan-benefit, government.warning-siren, government.crisis-information, government.proxy-vote, government.replacement-voting-pass, government.cooling-off-period, government.cancel-subscription, government.report-death-abroad, government.european-certificate-succession, housing.home-buying-checklist, housing.maximum-mortgage, housing.mortgage-application, housing.purchase-cooling-off, housing.home-buying-costs, housing.transfer-tax, housing.property-research, housing.energy-label-home, housing.notarial-transfer, housing.home-tax-deductions, housing.renting-step-by-step, housing.tenancy-agreement, housing.temporary-rental-contract, housing.rent-price-check, housing.housing-association, housing.service-cost-basics, housing.tenant-protection, housing.tenant-duties, housing.mediation-fees, housing.all-in-rent, housing.rental-deposit, housing.repair-responsibility, housing.defects-rent-reduction, housing.rent-increase-objection, housing.landlord-ending-tenancy, housing.ending-tenancy, housing.service-cost-statement, housing.rent-reduction-points, housing.huurcommissie-procedure, housing.landlord-reporting-point, housing.energy-supplier-choice, housing.energy-contract-moving, housing.energy-contract-ending, housing.licensed-energy-suppliers, housing.grid-costs, housing.utility-emergency, housing.power-outage-compensation, housing.district-heating-rights, housing.drinking-water-tax, housing.sewer-water-charges, healthcare.emergency-112, healthcare.112nl-app, healthcare.emergency-accessibility, healthcare.out-of-hours-gp, healthcare.acute-care-network, healthcare.urgent-gp-system, healthcare.suicide-crisis-help, healthcare.mental-health-crisis, healthcare.aed-use, healthcare.emergency-dental-care, healthcare.hospital-specialist-care, healthcare.specialist-referral, healthcare.hospital-stay, healthcare.patient-rights, healthcare.medical-records, healthcare.hospital-waiting-list, healthcare.hospital-billing, healthcare.healthcare-provider-complaint, healthcare.igj-care-report, healthcare.treatment-representation, healthcare.basic-package, healthcare.mandatory-insurance, healthcare.mandatory-deductible, healthcare.insurer-acceptance-duty, healthcare.noncontracted-care, healthcare.waiting-time-mediation, healthcare.cross-border-insurance, healthcare.long-term-care, healthcare.insurer-complaint, healthcare.insurance-children, healthcare.choose-gp, healthcare.contact-gp-practice, healthcare.gp-practice-team, healthcare.gp-basic-package, healthcare.gp-mental-health, healthcare.midwifery-care, healthcare.medicines-pharmacy, healthcare.dental-care, healthcare.physiotherapy, healthcare.district-nursing, transport.cycling-rules, transport.bicycle-lights, transport.ebike-rules, transport.speed-pedelec-helmet, transport.child-on-bike, transport.cycling-alcohol, transport.bike-theft, transport.ov-fiets, transport.bike-on-train, transport.bike-storage, transport.parking-signs, transport.paid-parking, transport.park-and-ride, transport.resident-parking-permit, transport.visitor-parking, transport.disabled-parking, transport.parking-fines, transport.municipal-parking-rules, transport.airport-parking, transport.station-parking, transport.payment-card, transport.ov-pas, transport.personal-ov-chipkaart, transport.automatic-reload, transport.travel-history, transport.missed-checkout, transport.card-expiry, transport.lost-card, transport.balance-refund, transport.ov-privacy, transport.journey-planning, transport.disruptions, transport.check-in-out, transport.e-tickets, transport.season-tickets, transport.delay-refund, transport.travel-assistance, transport.station-information, transport.app-notifications, transport.lost-property, education.duo-account, education.student-finance-overview, education.supplementary-grant, education.tuition-and-fees, education.student-loan, education.student-travel-product, education.finance-amounts, education.repay-student-debt, education.graduation-changes, education.diploma-register, education.higher-education-system, education.hbo-wo-choice, education.programme-recognition, education.degree-levels, education.foreign-diploma-admission, education.credential-evaluation, education.studielink-enrolment, education.application-process, education.accreditation-check, education.international-student-code, education.integration-obligation, education.integration-pip-routes, education.integration-school, education.integration-exams, education.integration-register-exam, education.integration-knowledge, education.integration-costs, education.integration-results, education.integration-diploma, education.integration-deadline, education.school-system, education.secondary-pathways, education.compulsory-education, education.school-absence, education.school-support, education.school-costs-primary, education.school-costs-secondary, education.school-holidays, education.school-complaints, education.school-inspection, place.amsterdam-centrum, place.amsterdam-noord, place.amsterdam-west, place.amsterdam-nieuw-west, place.amsterdam-zuid, place.amsterdam-oost, place.amsterdam-zuidoost, place.amsterdam-westpoort, place.royal-palace-amsterdam, place.artis, place.hortus-botanicus-amsterdam, place.oude-kerk, place.de-nieuwe-kerk-amsterdam, place.westerkerk, place.adam-lookout, place.heineken-experience, place.johan-cruijff-arena, place.seventeenth-century-canal-ring-of-amsterdam, place.dam-square, place.begijnhof-amsterdam, place.de-hallen-amsterdam, place.albert-cuyp-market, place.waterlooplein-market, place.bloemenmarkt, place.ndsm, place.oba-oosterdok, place.this-is-holland, place.wondr-experience, restaurant.restaurant-de-kas, restaurant.rijks, restaurant.ciel-bleu, restaurant.restaurant-212, restaurant.kaagman-and-kortekaas, restaurant.breda, restaurant.choux, restaurant.daalder, restaurant.flore, restaurant.the-white-room, restaurant.vinkeles, restaurant.restaurant-vermeer, restaurant.bougainville, restaurant.mos-amsterdam, restaurant.restaurant-moon, restaurant.jansz, restaurant.ron-gastrobar, restaurant.cannibale-royale, restaurant.moeders, restaurant.bak, restaurant.entrepot, restaurant.scheepskameel, restaurant.wils, restaurant.coulisse, restaurant.gitane, restaurant.caf-caron, restaurant.toscanini, restaurant.domenica, restaurant.yamazato, restaurant.sazanka, restaurant.visaandeschelde, restaurant.pesca, restaurant.restaurant-de-juwelier, restaurant.wilde-zwijnen, restaurant.gebr-hartering, restaurant.de-belhamel, restaurant.restaurant-europa, restaurant.restaurant-as, restaurant.de-plantage, restaurant.caf-restaurant-amsterdam, cafe.bocca-coffee, cafe.lot-sixty-one-coffee-roasters, cafe.white-label-coffee, cafe.back-to-black, cafe.scandinavian-embassy, cafe.screaming-beans, cafe.monks-coffee-roasters, cafe.rum-baba, cafe.fuku-friedhats, cafe.toki, cafe.coffee-and-coconuts, cafe.de-koffiesalon, cafe.bakers-and-roasters, cafe.koffie-academie, cafe.coffee-bru, cafe.uncommon-amsterdam, cafe.saint-jean, cafe.dignita-hoftuin, cafe.pluk-amsterdam, cafe.caf-de-jaren, transport.amsterdam-centraal-station, transport.amsterdam-zuid-station, transport.amsterdam-sloterdijk-station, transport.amsterdam-amstel-station, transport.amsterdam-muiderpoort-station, transport.amsterdam-rai-station, transport.amsterdam-bijlmer-arena-station, transport.amsterdam-holendrecht-station, transport.amsterdam-lelylaan-station, transport.amsterdam-science-park-station, government_service.first-registration-in-amsterdam, government_service.moving-within-amsterdam, government_service.passport-and-id-card-amsterdam, government_service.driving-licence-amsterdam, government_service.parking-permit-amsterdam, government_service.waste-and-recycling-amsterdam, government_service.municipal-taxes-amsterdam, government_service.report-a-problem-in-public-space-amsterdam, government_service.marriage-and-registered-partnership-amsterdam, government_service.registering-a-birth-in-amsterdam, education.university-of-amsterdam, education.vrije-universiteit-amsterdam, education.amsterdam-university-of-applied-sciences, education.inholland-amsterdam, education.gerrit-rietveld-academie, education.conservatorium-van-amsterdam, education.amsterdam-university-college, education.roc-van-amsterdam, education.hotelschool-the-hague-amsterdam, education.tio-business-school-amsterdam, healthcare.amsterdam-umc-location-amc, healthcare.amsterdam-umc-location-vumc, healthcare.olvg-east, healthcare.olvg-west, healthcare.bovenij-hospital, healthcare.reade-overtoom, healthcare.ggd-amsterdam, healthcare.acta, healthcare.antoni-van-leeuwenhoek, healthcare.arkin, event.worldpride-amsterdam-2026-pride-walk, event.worldpride-amsterdam-2026-pride-park, event.worldpride-amsterdam-2026-open-air-film-festival, event.worldpride-amsterdam-2026-senior-pride-concert, event.worldpride-amsterdam-2026-canal-parade, event.worldpride-amsterdam-2026-unity-concert, event.worldpride-amsterdam-2026-human-rights-conference, event.worldpride-amsterdam-2026-worldpride-village, event.worldpride-amsterdam-2026-worldpride-march, event.worldpride-amsterdam-2026-closing-concert, local_partner.van-der-valk-hotel-amsterdam-amstel, local_partner.citizenm-amsterdam-south, local_partner.ikea-amsterdam, local_partner.everaert-advocaten, local_partner.ing-group, local_partner.macbike-amsterdam, local_partner.tca-taxi-amsterdam, local_partner.funda, local_partner.uva-talen, local_partner.rob-peetoom-amsterdam, housing.woningnet-stadsregio-amsterdam, housing.woon, housing.housing-permit-amsterdam, housing.affordable-housing-amsterdam, housing.renting-a-home-in-amsterdam).
- Scenario interpretation: The canonical guide schema has no separate scenario field. numbered_steps is used as the auditable procedural/scenario proxy; no published material has numbered steps.

## Duplicates

- Canonical ID exact groups / near pairs: **0 / 0**.
- Canonical title exact groups / near pairs: **0 / 0**.
- Staged guide ID exact groups / near pairs: **0 / 0**.
- Staged guide title exact groups / near pairs: **0 / 0**.
- Staged guide slug exact groups / near pairs: **0 / 0**.

Candidate pairs are evidence for editorial review, not automatic deletion. Full pair details are in the JSON output.

## Runtime reconciliation

- Effective published → runtime: **0 missing / 0 unexpected**.
- Runtime → public web: **0 unexplained missing / 0 unexpected**.
- Fail-closed freshness exclusions: **170**; public records that violate the exclusion: **0**.
- Practical guides in runtime/public: **0 / 0**.

## Existing link-health evidence

The repository's existing link report checked **2920** URLs at **2026-10-23T12:54:18.221248+00:00**: **0 confirmed broken**, **792 access-restricted**, and **97 transient failures**. This audit imported those counts but did not perform a new network check.

## Audience-path gap

Production-ready explicit audience coverage is **0/6 (0.0%)**. All six brief paths are supported by the current audience_profiles enum, but no published practical guide carries audience metadata.

## Smallest useful remediation

1. Keep the 20 scaffolds in draft; assign canonical source entities to every scaffold before factual writing.
2. Complete and review one P1 guide end-to-end, including official source IDs for every fact, reviewer, verification date, verified media, steps and FAQ; publish only through the existing release pipeline.
3. Repeat P1 family by family. Do not interpret the 100% minimum-family summary inventory as 100% public or production readiness.
4. Assign and review explicit audience profiles before claiming full user-path coverage.
5. Run the existing live link/data-health check alongside this audit before any release; this script intentionally performs no network mutations or requests.

## Reproduction

```bash
python3 scripts/content-readiness-audit.py --as-of 2026-10-24 --check
```
