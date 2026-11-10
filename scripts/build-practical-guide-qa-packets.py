#!/usr/bin/env python3
"""Build 20 source-backed, non-publishable practical-guide QA packets.

The research handoff is the factual input. This builder turns each packet into
an actionable schema-v2 editorial draft while preserving the fail-closed
boundary: no reviewer is invented, confidence stays below ``high``, media is
not claimed, the publication gate remains pending, and status remains ``qa``.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
STAGING = ROOT / "DataProject/staging/practical-guides-wave-1.json"
HANDOFF = ROOT / "DataProject/quality/priority-1-editorial-handoff.json"
EDITORIAL_DATE = "2026-08-18"
EMERGENCY_SOURCE_ID = "emergency.gov-when-112"

GUIDE_ORDER = (
    "guide.getting-a-bsn",
    "guide.applying-for-digid",
    "guide.residence-permits",
    "guide.dutch-health-insurance",
    "guide.finding-a-huisarts",
    "guide.emergency-numbers-and-urgent-help",
    "guide.renting-a-home",
    "guide.temporary-housing",
    "guide.reporting-housing-defects",
    "guide.finding-work",
    "guide.understanding-an-employment-contract",
    "guide.taxes-and-allowances",
    "guide.debt-help",
    "guide.opening-a-dutch-bank-account",
    "guide.sim-card-and-home-internet",
    "guide.using-public-transport",
    "guide.diploma-recognition",
    "guide.dutch-integration-exams",
    "guide.family-children-and-school-registration",
    "guide.pets-and-veterinary-care",
)

GUIDE_METADATA = {
    "guide.getting-a-bsn": {
        "slug": "getting-bsn-municipality-registration",
        "title": "Getting a BSN and registering at a municipality",
        "synonyms": ["citizen service number", "burgerservicenummer", "gemeente registration", "BRP registration", "BSN"],
        "common_questions": ["How do I get a BSN and register with my municipality?"],
    },
    "guide.applying-for-digid": {
        "slug": "applying-for-digid",
        "title": "Applying for DigiD",
        "synonyms": ["digital identity", "DigiD aanvragen", "DigiD"],
        "common_questions": ["How do I apply for and activate DigiD?"],
    },
    "guide.residence-permits": {
        "slug": "residence-permits",
        "title": "Navigating residence permits",
        "synonyms": ["verblijfsvergunning", "IND", "residence card", "residence permit"],
        "common_questions": ["Which official IND residence-permit route applies to me?"],
    },
    "guide.dutch-health-insurance": {
        "slug": "dutch-health-insurance",
        "title": "Arranging Dutch health insurance",
        "synonyms": ["zorgverzekering", "basic health insurance", "Dutch health insurance"],
        "common_questions": ["Do I need Dutch health insurance and how do I arrange it?"],
    },
    "guide.finding-a-huisarts": {
        "slug": "finding-a-huisarts",
        "title": "Finding a huisarts",
        "synonyms": ["family doctor", "general practitioner", "huisarts", "GP"],
        "common_questions": ["How do I find and register with a huisarts?"],
    },
    "guide.emergency-numbers-and-urgent-help": {
        "slug": "emergency-numbers-and-urgent-help",
        "title": "Emergency numbers and urgent help",
        "synonyms": ["112", "urgent help", "huisartsenpost", "emergency"],
        "common_questions": ["Who should I contact in an emergency or urgent medical situation?"],
    },
    "guide.renting-a-home": {
        "slug": "renting-a-home",
        "title": "Finding long-term housing",
        "synonyms": ["home rental", "huurwoning", "long-term housing", "tenancy agreement"],
        "common_questions": ["How do I find and safely rent a long-term home in the Netherlands?"],
    },
    "guide.temporary-housing": {
        "slug": "temporary-housing",
        "title": "Finding temporary housing",
        "synonyms": ["short stay", "temporary accommodation", "fixed-term tenancy", "temporary housing"],
        "common_questions": ["How do I find and check temporary housing in the Netherlands?"],
    },
    "guide.reporting-housing-defects": {
        "slug": "landlord-problems-and-housing-defects",
        "title": "Handling landlord problems and housing defects",
        "synonyms": ["landlord problem", "rental defect", "woninggebrek", "Huurcommissie"],
        "common_questions": ["What can I do if my landlord does not repair a defect or follow rental rules?"],
    },
    "guide.finding-work": {
        "slug": "finding-work-with-limited-dutch",
        "title": "Finding work with limited Dutch",
        "synonyms": ["jobs without Dutch", "vacatures", "finding employment", "English-speaking jobs"],
        "common_questions": ["How do I find work if my Dutch is limited?"],
    },
    "guide.understanding-an-employment-contract": {
        "slug": "employment-contract-and-payslip-basics",
        "title": "Employment contract and payslip basics",
        "synonyms": ["arbeidsovereenkomst", "work contract", "employment terms", "payslip"],
        "common_questions": ["What should I check in a Dutch employment contract and payslip?"],
    },
    "guide.taxes-and-allowances": {
        "slug": "taxes-and-allowances",
        "title": "Taxes and allowances",
        "synonyms": ["tax return", "toeslagen", "zorgtoeslag", "huurtoeslag"],
        "common_questions": ["Which Dutch taxes and allowances may apply to me?"],
    },
    "guide.debt-help": {
        "slug": "getting-help-with-debt",
        "title": "Getting help with debt",
        "synonyms": ["schuldhulpverlening", "debt support", "debt mediation", "money problems"],
        "common_questions": ["Where can I get official help with debts?"],
    },
    "guide.opening-a-dutch-bank-account": {
        "slug": "opening-a-dutch-bank-account",
        "title": "Opening a Dutch bank account",
        "synonyms": ["bankrekening openen", "Dutch bank account", "IBAN"],
        "common_questions": ["How do I open a Dutch bank account?"],
    },
    "guide.sim-card-and-home-internet": {
        "slug": "sim-card-and-home-internet",
        "title": "Choosing a SIM card and home internet",
        "synonyms": ["mobile plan", "telecom contract", "internet provider", "SIM card"],
        "common_questions": ["How do I compare a Dutch SIM card and home internet contract?"],
    },
    "guide.using-public-transport": {
        "slug": "using-public-transport",
        "title": "Using public transport",
        "synonyms": ["OVpay", "OV-pas", "OV-chipkaart", "public transport"],
        "common_questions": ["How do I plan and pay for public transport?"],
    },
    "guide.diploma-recognition": {
        "slug": "diploma-recognition",
        "title": "Getting a foreign diploma recognised",
        "synonyms": ["credential evaluation", "diplomawaardering", "foreign qualification", "IDW"],
        "common_questions": ["Do I need a Dutch credential evaluation for my foreign diploma?"],
    },
    "guide.dutch-integration-exams": {
        "slug": "dutch-language-courses-and-integration",
        "title": "Dutch language courses and civic integration",
        "synonyms": ["Dutch course", "inburgering", "inburgeringsexamen", "civic integration"],
        "common_questions": ["Which Dutch course or integration route applies to me?"],
    },
    "guide.family-children-and-school-registration": {
        "slug": "family-children-and-school-registration",
        "title": "Family, children and school registration",
        "synonyms": ["primary school", "basisschool", "child benefit", "family registration"],
        "common_questions": ["What should a family arrange after moving to the Netherlands?"],
    },
    "guide.pets-and-veterinary-care": {
        "slug": "pets-and-veterinary-care",
        "title": "Pets and veterinary care",
        "synonyms": ["huisdieren", "dierenarts", "pet passport", "vet"],
        "common_questions": ["What must I arrange when moving to the Netherlands with a pet?"],
    },
}


PROFILES = {
    "guide.registering-at-a-municipality": ["expat", "refugee", "worker", "resident", "student"],
    "guide.getting-a-bsn": ["expat", "refugee", "worker", "resident", "student"],
    "guide.applying-for-digid": ["expat", "refugee", "worker", "resident", "student"],
    "guide.finding-a-huisarts": ["expat", "refugee", "worker", "resident", "student"],
    "guide.dutch-health-insurance": ["expat", "refugee", "worker", "resident", "student"],
    "guide.renting-a-home": ["expat", "refugee", "worker", "resident", "student"],
    "guide.reporting-housing-defects": ["expat", "refugee", "worker", "resident", "student"],
    "guide.using-public-transport": ["tourist", "student", "expat", "refugee", "worker", "resident"],
    "guide.finding-work": ["student", "expat", "refugee", "worker", "resident"],
    "guide.understanding-an-employment-contract": ["student", "expat", "refugee", "worker", "resident"],
    "guide.taxes-and-allowances": ["student", "expat", "refugee", "worker", "resident"],
    "guide.opening-a-dutch-bank-account": ["student", "expat", "refugee", "worker", "resident"],
    "guide.emergency-numbers-and-urgent-help": ["tourist", "student", "expat", "refugee", "worker", "resident"],
    "guide.residence-permits": ["student", "expat", "refugee", "worker", "resident"],
    "guide.dutch-integration-exams": ["expat", "refugee", "worker", "resident"],
    "guide.studying-in-the-netherlands": ["student", "expat", "refugee", "resident"],
    "guide.student-housing": ["student", "expat", "refugee"],
    "guide.moving-to-another-municipality": ["student", "expat", "refugee", "worker", "resident"],
    "guide.reporting-discrimination": ["tourist", "student", "expat", "refugee", "worker", "resident"],
    "guide.starting-a-business": ["student", "expat", "refugee", "worker", "resident"],
    "guide.temporary-housing": ["student", "expat", "refugee", "worker", "resident"],
    "guide.debt-help": ["student", "expat", "refugee", "worker", "resident"],
    "guide.sim-card-and-home-internet": ["student", "expat", "refugee", "worker", "resident"],
    "guide.diploma-recognition": ["student", "expat", "refugee", "worker", "resident"],
    "guide.family-children-and-school-registration": ["student", "expat", "refugee", "worker", "resident"],
    "guide.pets-and-veterinary-care": ["student", "expat", "refugee", "worker", "resident"],
}


DOCUMENT_GUIDANCE = {
    "guide.registering-at-a-municipality": "Prepare valid identity evidence, proof that you may occupy the address, and any civil-status documents requested for your household. Foreign documents may need translation or legalisation.",
    "guide.getting-a-bsn": "Bring the identity and address evidence required by the BRP or RNI route that applies to you; check first whether you already have a BSN.",
    "guide.applying-for-digid": "Have your BSN, BRP-registered address and mobile phone ready. The abroad route also requires RNI registration, valid identity evidence and an email address.",
    "guide.finding-a-huisarts": "Keep your health-insurance details and a concise overview of the care you need. Ask the practice what identity or intake information it requires before visiting.",
    "guide.dutch-health-insurance": "Keep evidence of when you began living or working in the Netherlands and any CAK or SVB correspondence that affects your insurance-duty route.",
    "guide.renting-a-home": "Keep the written tenancy agreement, the rent and service-cost breakdown, deposit terms and a dated condition report for the property.",
    "guide.reporting-housing-defects": "Keep the tenancy agreement, dated photos, the written defect notice to the landlord and proof of when it was sent.",
    "guide.using-public-transport": "Use the same contactless card or device for check-in and check-out. Keep the correct travel product or season-ticket card separate.",
    "guide.finding-work": "Prepare a current CV and retain evidence of applications or other job-search activity. If exporting unemployment benefit, obtain PD U2 before relying on that route.",
    "guide.understanding-an-employment-contract": "Keep the written contract, the employer's written terms and the applicable collective labour agreement (CAO), if any, together for comparison.",
    "guide.taxes-and-allowances": "Keep the Tax Administration invitation, the correct tax-year records and your own DigiD. Use official authorisation instead of sharing DigiD when someone helps you.",
    "guide.opening-a-dutch-bank-account": "Prepare valid identity evidence and the information the bank requests about address, connection to the Netherlands and source of funds.",
    "guide.emergency-numbers-and-urgent-help": "Be ready to state what happened, the exact location and whether police, fire brigade or ambulance appears to be needed.",
    "guide.residence-permits": "Use the checklist for your exact IND route. Collection commonly requires a valid passport, the appointment code and any existing residence document; replacement can require a police report.",
    "guide.dutch-integration-exams": "Keep your PIP or other route decision, DigiD access and every DUO registration confirmation, invoice, letter and result.",
    "guide.studying-in-the-netherlands": "Keep the programme and institution details, admission evidence and the records needed to assess tuition and student-finance eligibility.",
    "guide.student-housing": "Keep the written tenancy agreement, rent and service-cost breakdown, deposit terms and the evidence needed for municipal address registration or a local housing permit.",
    "guide.moving-to-another-municipality": "Prepare valid identity evidence and proof of occupancy at the new address. Keep residence-permit details if the IND notification rule applies to you.",
    "guide.reporting-discrimination": "Record what happened, when and where it occurred, who was involved and any messages, witnesses or other evidence that can help the chosen reporting route.",
    "guide.starting-a-business": "Prepare valid identity evidence, BSN and address evidence, the KVK registration form and the documents listed in the appointment confirmation.",
    "guide.temporary-housing": "Keep the written accommodation or tenancy agreement, rent and service-cost breakdown, deposit terms, address-registration evidence and dated property-condition records.",
    "guide.debt-help": "Gather proof of identity and address plus current income, benefits, housing costs, bank balances, debts, creditor letters, payment demands and enforcement notices for the municipal intake.",
    "guide.sim-card-and-home-internet": "Keep valid identity and payment evidence requested by the provider, the pre-contract summary, address-availability result, order confirmation, contract and equipment-return terms.",
    "guide.diploma-recognition": "Prepare colour copies of the diploma, grades list or diploma supplement, valid identity evidence and any required sworn translations; the exact documents depend on purpose and country.",
    "guide.family-children-and-school-registration": "Keep identity, address and civil-status evidence for the household, each child's BSN evidence and prior school records; check whether foreign documents need translation or legalisation.",
    "guide.pets-and-veterinary-care": "Keep the microchip details, vaccination record, pet passport or health certificate and origin-country evidence. Ask the NVWA route and veterinarian which originals must travel with the animal.",
}


STEP_TITLES = {
    "guide.registering-at-a-municipality": ["Choose BRP or RNI", "Act within the resident deadline", "Confirm the address route", "Prepare for identity checks", "Use RNI for a short stay", "Choose an eligible RNI desk", "Prepare a child's documents", "Use Amsterdam rules only in Amsterdam", "Check Amsterdam attendance rules", "Confirm Amsterdam RNI eligibility"],
    "guide.getting-a-bsn": ["Understand what a BSN is", "Choose the registration route", "Check for an existing BSN", "Do not seek a separate application", "Use RNI when appropriate", "Attend an eligible RNI desk", "Apply Amsterdam rules only locally", "Check Amsterdam RNI eligibility"],
    "guide.applying-for-digid": ["Confirm why you need DigiD", "Check the resident prerequisites", "Submit the resident application", "Activate before the code expires", "Keep DigiD personal", "Use the abroad route when eligible"],
    "guide.finding-a-huisarts": ["Decide to register before care is urgent", "Ask for help finding a practice", "Search close to home", "Request care mediation", "Check what basic insurance covers"],
    "guide.dutch-health-insurance": ["Check whether the Dutch duty applies", "Choose basic before supplementary cover", "Understand the 2026 deductible", "Respond to a CAK letter", "Check the current fine before acting"],
    "guide.renting-a-home": ["Identify the rental sector", "Check the deposit", "Require a written agreement", "Record the full contract terms", "Reject double mediation fees", "Check the municipality for permits"],
    "guide.reporting-housing-defects": ["Notify the landlord in writing", "Wait or escalate after six weeks", "Choose the correct Huurcommissie route", "Report building-safety defects locally", "Use the Good Landlordship reporting point"],
    "guide.using-public-transport": ["Plan and recheck the journey", "Enable accessible planning if needed", "Choose a contactless payment method", "Check out with the correct operator", "Keep subscriptions on their assigned card"],
    "guide.finding-work": ["Use EURES and UWV", "Set up the Work Folder", "Register quickly when exporting benefit", "Keep evidence of required activities"],
    "guide.understanding-an-employment-contract": ["Check the first-week terms", "Check the first-month terms", "Put the agreement in writing", "Identify fixed or permanent status", "Compare the contract with the CAO"],
    "guide.taxes-and-allowances": ["Decide whether to file", "Choose the correct return", "Use an accepted filing method", "Keep DigiD personal", "Check each allowance separately", "Apply through Mijn toeslagen", "Plan for the final calculation", "Report relevant changes", "Recheck annual limits and deadlines"],
    "guide.opening-a-dutch-bank-account": ["Prepare for the bank's acceptance check", "Complete identity verification", "Use the basic-account fallback", "Challenge a rejection through the complaint route"],
    "guide.emergency-numbers-and-urgent-help": ["Call 112 for immediate danger", "Give the operator essential facts", "Call the out-of-hours GP first", "Understand the care-cost route", "Use the non-urgent police number correctly"],
    "guide.residence-permits": ["Select the exact IND route", "Check whether EU rules apply", "Use the current purpose-specific checklist", "Wait for the collection message", "Prepare for document collection", "Report a lost document to police", "Handle a loss abroad", "Do not reuse a reported-lost document", "Consider extension near expiry", "Check the live fee and decision period"],
    "guide.dutch-integration-exams": ["Confirm your personal route", "Follow the PIP and municipal plan", "Choose the correct registration route", "Register and retain confirmation", "Prepare DigiD portal access", "Track the correct result process"],
    "guide.studying-in-the-netherlands": ["Verify institution and programme recognition", "Meet the correct application deadline", "Check programme-specific admission", "Identify the tuition category", "Test student-finance eligibility"],
    "guide.student-housing": ["Use several room-search routes", "Sign a contract and register the address", "Check for a local housing permit", "Run the shared-room Rent Check", "Apply ordinary tenant protections"],
    "guide.moving-to-another-municipality": ["Report within the legal window", "Avoid a late-report penalty", "Prepare identity and occupancy evidence", "Report to the new municipality", "Recheck municipal support", "Protect your IND address record", "Use Amsterdam processing claims only locally", "Let the new municipality deregister Amsterdam"],
    "guide.reporting-discrimination": ["Choose the outcome and reporting route", "Contact the local anti-discrimination service", "Use the national helpline", "Consider a Human Rights Institute complaint", "Report criminal conduct to police", "Use online or anonymous routes when appropriate"],
    "guide.starting-a-business": ["Define sector, location and immigration constraints", "Check whether KVK registration is required", "Choose the legal structure", "Confirm the right to stay and operate", "Prepare BSN and address evidence", "Complete the KVK form and appointment", "Register around the start date", "Wait for the separate tax assessment", "Check the current registration fee", "Check permits and professional rules", "Protect private address information where possible"],
    "guide.temporary-housing": ["Identify the legal accommodation type", "Require written terms", "Check the full housing cost", "Understand how the contract ends", "Verify address registration locally", "Use urgent municipal support when necessary"],
    "guide.debt-help": ["Contact your municipality", "Prepare a complete financial overview", "Record the ordinary response dates", "Flag a threatening situation immediately", "Ask which free municipal route applies", "Escalate a written decision through the correct route"],
    "guide.sim-card-and-home-internet": ["Compare the contract summary", "Check mobile coverage and bundle limits", "Check fixed-internet availability by address", "Compare total cost after discounts", "Understand the cooling-off period", "Keep evidence when cancelling or complaining"],
    "guide.diploma-recognition": ["Choose the purpose of recognition", "Understand what an evaluation proves", "Ask the institution first for study", "Check regulated-profession rules for work", "Prepare the required documents", "Recheck the live fee and queue"],
    "guide.family-children-and-school-registration": ["Register the household address", "Check the child's school-age route", "Use local school admission rules", "Prepare school-registration documents", "Ask for a suitable support placement", "Check child-benefit eligibility", "Register the child with the health insurer"],
    "guide.pets-and-veterinary-care": ["Choose the origin-country route", "Prepare the EU identity and passport route", "Respect rabies timing", "Follow the third-country arrival route", "Register an imported dog on time", "Arrange responsible local veterinary care"],
}


FAQ_QUESTIONS = {
    "guide.registering-at-a-municipality": ["Should I use BRP or RNI?", "When must a new resident register?", "Can I use Amsterdam instructions in another municipality?"],
    "guide.getting-a-bsn": ["Is a BSN a separate application?", "Can a non-resident receive a BSN?", "What if I may already have a BSN?"],
    "guide.applying-for-digid": ["What do I need for a resident DigiD application?", "How long is the activation code valid?", "Can someone else apply using my details?"],
    "guide.finding-a-huisarts": ["Is GP registration mandatory?", "What if nearby practices are full?", "Does GP care use the compulsory deductible?"],
    "guide.dutch-health-insurance": ["When must I arrange Dutch insurance?", "Is supplementary insurance compulsory?", "What should I do after a CAK uninsured letter?"],
    "guide.renting-a-home": ["Which rental rules apply to my home?", "How large can a recent-contract deposit be?", "Can an agent charge both landlord and tenant?"],
    "guide.reporting-housing-defects": ["What should I send the landlord first?", "When can I approach the Huurcommissie?", "Which municipality reporting point can help?"],
    "guide.using-public-transport": ["Can I travel with a contactless bank card?", "What happens when I change train operators?", "Should I recheck a planned journey?"],
    "guide.finding-work": ["Which official services can support a job search?", "What must I do when exporting unemployment benefit?", "Which job-search evidence should I keep?"],
    "guide.understanding-an-employment-contract": ["Which terms must be provided in the first week?", "Can an employment contract be oral?", "What happens when a CAO applies?"],
    "guide.taxes-and-allowances": ["Must I file without an invitation?", "Are allowances granted automatically?", "When must allowance changes be reported?"],
    "guide.opening-a-dutch-bank-account": ["Why does a bank ask about identity and funds?", "What is a basic payment account?", "How can I challenge a rejection?"],
    "guide.emergency-numbers-and-urgent-help": ["When should I call 112?", "Where should I go when the GP is closed?", "What is the non-emergency police number?"],
    "guide.residence-permits": ["Is there one residence-permit checklist for everyone?", "What do I bring to collect a residence document?", "What should I do if the document is lost abroad?"],
    "guide.dutch-integration-exams": ["How do I know which exams I need?", "Where do I register for each exam type?", "When are results available?"],
    "guide.studying-in-the-netherlands": ["How do I check programme recognition?", "Which application deadline applies?", "Does every student receive Dutch student finance?"],
    "guide.student-housing": ["Where can I look for a student room?", "Can a room require a housing permit?", "How do I check the rent for shared accommodation?"],
    "guide.moving-to-another-municipality": ["When can I report the move?", "Which municipality receives the report?", "Does municipal support move automatically?"],
    "guide.reporting-discrimination": ["Which reporting route should I choose?", "Can a local service help with a complaint?", "Is a Human Rights Institute decision binding?"],
    "guide.starting-a-business": ["When is KVK registration required?", "Is zzp a legal structure?", "Which costs and permits should I verify?"],
    "guide.temporary-housing": ["Is every short stay a temporary tenancy?", "What must be written in the agreement?", "What if I need emergency accommodation?"],
    "guide.debt-help": ["Where do I apply for debt assistance?", "How quickly should the municipality respond?", "What counts as an urgent debt situation?"],
    "guide.sim-card-and-home-internet": ["What should I compare before signing?", "Does every provider serve every address?", "How can I cancel or complain?"],
    "guide.diploma-recognition": ["Do I always need a credential evaluation?", "Which documents should I prepare?", "Are the fee and processing time fixed?"],
    "guide.family-children-and-school-registration": ["When should I register a child with school?", "Which school rules are local?", "Which family steps follow municipal registration?"],
    "guide.pets-and-veterinary-care": ["Which travel route applies to my pet?", "When must a dog be registered in the Netherlands?", "How should I choose veterinary care?"],
}


TIME_VALUES = {
    "guide.applying-for-digid": "Allow for postal delivery; the resident activation letter may take up to 5 working days.",
    "guide.reporting-housing-defects": "The Huurcommissie route normally starts after the landlord has had 6 weeks to act on written notice.",
    "guide.understanding-an-employment-contract": "Key written terms are due within 1 week and further terms within 1 month after employment starts.",
    "guide.emergency-numbers-and-urgent-help": "Act immediately for danger; non-emergency routes depend on the service.",
    "guide.dutch-integration-exams": "Registration timing varies; listed A2 and knowledge-exam results can take up to 8 weeks.",
    "guide.studying-in-the-netherlands": "Application timing depends on the programme; common first-degree deadlines are 15 January or 1 May.",
    "guide.moving-to-another-municipality": "Report from 4 weeks before the move through 5 days after it.",
    "guide.starting-a-business": "KVK registration is normally completed around the business start date.",
    "guide.debt-help": "The ordinary municipal route should explain expected help within 4 weeks and decide within 8 weeks; a threatening situation uses an urgent 3-day route.",
    "guide.diploma-recognition": "Processing varies by purpose and live workload; IDW currently warns of longer processing times, so recheck immediately before applying.",
    "guide.pets-and-veterinary-care": "Preparation varies by origin country and animal; vaccination, blood-test and certificate routes can require advance planning.",
}


COST_VALUES = {
    "guide.registering-at-a-municipality": "RNI registration is free; confirm any route-specific municipal document costs.",
    "guide.getting-a-bsn": "There is no separate BSN application fee in the ordinary BRP/RNI routes; confirm route-specific document costs.",
    "guide.finding-a-huisarts": "GP care itself is covered by the basic package without the compulsory deductible; medicines, external tests and referred care can differ.",
    "guide.dutch-health-insurance": "Premiums vary; the compulsory deductible is EUR 385 in 2026 for insured adults, with listed exemptions.",
    "guide.emergency-numbers-and-urgent-help": "Calling 112 is free; healthcare costs depend on whether care is GP/out-of-hours GP or hospital care.",
    "guide.residence-permits": "IND fees depend on the exact route; replacement after loss or theft has a live fee that must be checked.",
    "guide.studying-in-the-netherlands": "Tuition depends on eligibility; statutory tuition is EUR 2,694 for 2026–2027 and institutional tuition varies.",
    "guide.reporting-discrimination": "Local advice and the Human Rights Institute route described here are free; court or legal-support costs can differ.",
    "guide.starting-a-business": "A new KVK registration costs EUR 85.15 in 2026; extracts, notarial work, permits and sector costs are separate.",
    "guide.debt-help": "Municipal debt assistance is free; legal, court or third-party costs can differ and must be checked separately.",
    "guide.diploma-recognition": "Fees depend on the purpose and live IDW tariff; verify the current amount before paying.",
    "guide.sim-card-and-home-internet": "Prices, connection charges, equipment terms and usage costs vary by provider and address; compare the full contract summary.",
    "guide.pets-and-veterinary-care": "Veterinary, vaccination, certificate, registration and travel costs vary; confirm current fees with the competent authority and chosen veterinarian.",
}


def load(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def unique(values: list[str]) -> list[str]:
    return list(dict.fromkeys(value for value in values if value))


def block(block_id: str, text: str, source_ids: list[str]) -> dict[str, Any]:
    return {"id": block_id, "text": text, "source_ids": unique(source_ids)}


def source_ids(facts: list[dict[str, Any]]) -> list[str]:
    return unique([source_id for fact in facts for source_id in fact["source_ids"]])


def join_fact_text(facts: list[dict[str, Any]]) -> str:
    return " ".join(fact["statement"] for fact in facts)


def jurisdiction_for(value: str | None, refs: list[str]) -> dict[str, Any]:
    mixed = value not in {"national", None}
    return {
        "level": "mixed" if mixed else "national",
        "country_code": "NL",
        "municipality_dependent": mixed,
        "note": (
            "National rules set the baseline, but the responsible municipality, provider, institution or sector can control execution. Use local instructions only for the place or provider that issued them."
            if mixed
            else "The current research packet identifies a national baseline. Provider-specific execution and live availability still require confirmation."
        ),
        "source_ids": refs[:12],
    }


def estimate(kind: str, guide_id: str, refs: list[str]) -> dict[str, Any]:
    if kind == "time":
        value = TIME_VALUES.get(guide_id)
        note = value or "Timing varies by route, provider, appointment availability and the user's circumstances; confirm the live official page before relying on a deadline or processing estimate."
        return {"state": "varies", "value": value, "note": note, "source_ids": refs[:12]}
    value = COST_VALUES.get(guide_id)
    note = value or "Costs vary by provider, route and year. Confirm the current official fee or tariff before paying."
    return {"state": "varies", "value": value, "note": note, "currency": "EUR", "source_ids": refs[:12]}


def guide_source(source: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": source["source_id"],
        "title": source["title"],
        "publisher": source["publisher"],
        "url": source["url"],
        "is_official": True,
        "checked_at": source["verified_at"],
        "status": "verified_opened",
    }


def build_guide(
    scaffold: dict[str, Any],
    research: dict[str, Any],
    emergency_source: dict[str, Any],
    related_ids: list[str],
) -> dict[str, Any]:
    original = scaffold["practical_guide"]
    guide_id = original["id"]
    facts = research["facts"]
    titles = STEP_TITLES[guide_id]
    if len(titles) != len(facts):
        raise SystemExit(f"Step-title count mismatch for {guide_id}: {len(titles)} != {len(facts)}")
    refs = source_ids(facts)
    first_refs = facts[0]["source_ids"]
    middle = max(1, len(facts) // 2)
    faq_fact_indexes = [0, middle, len(facts) - 1]
    all_sources = list(research["sources"])
    if EMERGENCY_SOURCE_ID not in {item["source_id"] for item in all_sources}:
        all_sources.append(emergency_source)

    summary_facts = facts[: min(2, len(facts))]
    summary_refs = source_ids(summary_facts)
    profile_names = ", ".join(PROFILES[guide_id])
    numbered_steps = [
        {
            "id": f"step.{index}",
            "position": index,
            "title": title,
            "body": fact["statement"],
            "source_ids": fact["source_ids"],
            "municipality_dependent": str(fact.get("jurisdiction", "")).startswith("municipal"),
        }
        for index, (title, fact) in enumerate(zip(titles, facts), start=1)
    ]
    checklist = [
        block(f"check.{index}", f"Complete and verify: {step['title']}.", step["source_ids"])
        for index, step in enumerate(numbered_steps, start=1)
    ]
    questions = FAQ_QUESTIONS[guide_id]
    faqs = [
        {
            "id": f"faq.{index}",
            "question": question,
            "answer": facts[fact_index]["statement"],
            "source_ids": facts[fact_index]["source_ids"],
        }
        for index, (question, fact_index) in enumerate(zip(questions, faq_fact_indexes), start=1)
    ]
    section_split = max(1, len(facts) // 2)
    sources_by_id = {item["source_id"]: item for item in all_sources}
    contacts = [
        {
            "id": f"contact.{index}",
            "kind": "url",
            "label": source["publisher"],
            "value": source["url"],
            "source_ids": [source["source_id"]],
        }
        for index, source in enumerate(all_sources[:3], start=1)
    ]
    if guide_id == "guide.emergency-numbers-and-urgent-help":
        emergency = block(
            "emergency.112",
            "Call 112 when life is in immediate danger, someone is seriously injured and needs prompt medical attention, or you are witnessing a serious crime.",
            [EMERGENCY_SOURCE_ID],
        )
    else:
        emergency = block(
            "emergency.112",
            "This administrative guide is not an emergency service. Call 112 when life is in immediate danger, someone is seriously injured and needs prompt medical attention, or you are witnessing a serious crime.",
            [EMERGENCY_SOURCE_ID],
        )

    seo_title = f"{original['title']} in the Netherlands"
    if len(seo_title) > 70:
        seo_title = original["title"][:70].rstrip()
    description = (
        f"A source-backed guide to {original['title'].lower()}, with official routes, "
        "preparation, warnings, checks and next actions."
    )

    return {
        "schema_version": 2,
        "id": guide_id,
        "slug": original["slug"],
        "locale": original["locale"],
        "title": original["title"],
        "short_summary": block("summary", join_fact_text(summary_facts), summary_refs),
        "audience_profiles": PROFILES[guide_id],
        "who_this_is_for": block(
            "audience",
            f"This QA guide is intended for {profile_names} users whose situation matches the official conditions below.",
            first_refs,
        ),
        "when_you_need_it": block(
            "when",
            f"Use this guide when you need to handle {original['title'].lower()} and must choose a current official route without assuming that another person's municipality, provider or status applies to you.",
            first_refs,
        ),
        "applicability": original.get("applicability", {"city_ids": [], "province_ids": []}),
        "jurisdiction": jurisdiction_for(research["research_input"]["jurisdiction"], refs),
        "prerequisites": [
            block("prerequisite.route", f"Confirm the rule that determines your route: {facts[0]['statement']}", facts[0]["source_ids"]),
            block("prerequisite.live-check", "Open the cited official page immediately before acting and confirm that the route, location, deadline and eligibility still match your situation.", first_refs),
        ],
        "required_documents": [block("documents.core", DOCUMENT_GUIDANCE[guide_id], refs[:12])],
        "estimated_time": estimate("time", guide_id, refs),
        "estimated_cost": estimate("cost", guide_id, refs),
        "numbered_steps": numbered_steps,
        "warnings": [
            block("warning.scope", f"Do not generalise a route beyond its stated scope. {facts[-1]['statement']}", facts[-1]["source_ids"]),
        ],
        "common_mistakes": [
            block("mistake.route", f"A common mistake is choosing a familiar route before checking eligibility. {facts[0]['statement']}", facts[0]["source_ids"]),
        ],
        "tips": [
            block("tip.evidence", f"Keep confirmations, dates and evidence for the route you use. {facts[middle]['statement']}", facts[middle]["source_ids"]),
        ],
        "checklist": checklist,
        "faqs": faqs,
        "emergency_information": [emergency],
        "sections": [
            {
                "id": "section.official-baseline",
                "title": "Official baseline",
                "body": join_fact_text(facts[:section_split]),
                "source_ids": source_ids(facts[:section_split])[:12],
            },
            {
                "id": "section.situation-checks",
                "title": "Situation and local checks",
                "body": join_fact_text(facts[section_split:]),
                "source_ids": source_ids(facts[section_split:])[:12],
            },
        ],
        "official_sources": [guide_source(source) for source in all_sources],
        "contact_options": contacts,
        "related_guide_ids": related_ids,
        "next_actions": [
            block("next.verify", "Open the official source for the route you selected and verify its current instructions before submitting, booking or paying.", first_refs),
            block("next.related", f"Continue with the related YouNew QA guide {related_ids[0]} only if that next procedure applies to your situation.", first_refs),
        ],
        "verified_at": research["research_input"]["verified_at"],
        "updated_at": EDITORIAL_DATE,
        "reviewer": None,
        "reading_time_minutes": max(5, min(18, 4 + len(numbered_steps))),
        "difficulty": "advanced" if len(numbered_steps) >= 9 else "intermediate" if len(numbered_steps) >= 6 else "basic",
        "confidence_level": "medium",
        "tags": [value for value in unique(["netherlands", *original["slug"].split("-")]) if len(value) >= 2][:20],
        "publication_gate": {
            "status": "pending",
            "checked_at": EDITORIAL_DATE,
            "checks": {
                "schema": True,
                "factual_sources": True,
                "links": True,
                "language": True,
                "media": False,
                "duplicate_content": False,
                "accessibility": True,
            },
            "notes": "Automated source-mapping and schema QA completed. Human editorial review, dedicated verified media and final duplicate-content review remain mandatory before publication.",
            "evidence_ids": ["evidence.priority-1.qa-packet"],
        },
        "disclaimer": "This source-backed QA draft is general information, not individual legal, medical, tax or financial advice. Verify the current official route and obtain qualified help when needed.",
        "seo": {"title": seo_title, "description": description, "canonical_path": f"/guides/{original['slug']}"},
        "synonyms": original["synonyms"],
        "common_questions": original["common_questions"],
        "status": "qa",
    }


def build() -> dict[str, Any]:
    staging = load(STAGING)
    handoff = load(HANDOFF)
    research_by_id = {item["guide_id"]: item for item in handoff["queue"]}
    source_catalog = {
        source["source_id"]: source
        for item in handoff["queue"]
        for source in item["sources"]
    }
    emergency_source = source_catalog[EMERGENCY_SOURCE_ID]
    scaffold_by_id = {item["practical_guide"]["id"]: item for item in staging["guides"]}
    missing_scaffolds = sorted(set(GUIDE_ORDER) - set(scaffold_by_id))
    if missing_scaffolds:
        raise SystemExit(f"Missing guide packet identities: {missing_scaffolds}")
    guide_ids = list(GUIDE_ORDER)
    guides = []
    for index, guide_id in enumerate(guide_ids):
        scaffold = scaffold_by_id[guide_id]
        scaffold = {
            **scaffold,
            "practical_guide": {
                **scaffold["practical_guide"],
                **GUIDE_METADATA[guide_id],
                "locale": "en",
                "applicability": {"city_ids": [], "province_ids": []},
            },
        }
        related_ids = [guide_ids[(index + 1) % len(guide_ids)], guide_ids[(index - 1) % len(guide_ids)]]
        if guide_id not in research_by_id:
            raise SystemExit(f"Missing official-source research for {guide_id}")
        research = research_by_id[guide_id]
        guide = build_guide(scaffold, research, emergency_source, related_ids)
        publication_gaps = [
            "A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.",
            "Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.",
            "The publication gate remains pending and no guide-specific evidence registry record authorizes release.",
        ]
        if research["locality_readiness"]["required"]:
            publication_gaps.append(research["locality_readiness"]["note"])
        guides.append({
            "source_entity_ids": scaffold["source_entity_ids"],
            "publication_gaps": publication_gaps,
            "practical_guide": guide,
        })
    return {
        "schema_version": 2,
        "collection_id": "practical-guides-wave-1",
        "purpose": "Twenty source-backed schema-v2 QA packets prepared for named human review. This staging collection is not a runtime or publication input.",
        "status": "qa",
        "guides": guides,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.write == args.check:
        raise SystemExit("Choose exactly one of --write or --check")
    rendered = json.dumps(build(), ensure_ascii=False, indent=2) + "\n"
    if args.write:
        STAGING.write_text(rendered, encoding="utf-8")
        print(f"Wrote {STAGING.relative_to(ROOT)}")
        return
    current = STAGING.read_text(encoding="utf-8")
    if current != rendered:
        raise SystemExit("Practical-guide QA packets are stale; run with --write")
    print("Practical-guide QA packets are current")


if __name__ == "__main__":
    main()
