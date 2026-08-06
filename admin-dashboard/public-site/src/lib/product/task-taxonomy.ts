export type TaskIconName =
  | "home"
  | "work"
  | "healthcare"
  | "documents"
  | "study"
  | "daily-life"
  | "emergency"
  | "lgbtiq"
  | "pets"
  | "family";

export type ProductValue = "answer" | "checklist" | "decision" | "official-source" | "saved-item";

export interface TaskClarification {
  readonly id: string;
  readonly label: string;
  readonly description: string;
  readonly href: string;
  readonly result: string;
}

export interface YouNewTask {
  readonly id: string;
  readonly label: string;
  readonly example: string;
  readonly description: string;
  readonly icon: TaskIconName;
  readonly outcome: string;
  readonly value: readonly ProductValue[];
  readonly urgent?: boolean;
  readonly clarifications: readonly TaskClarification[];
}

export const youNewTasks = [
  {
    id: "housing",
    label: "Housing",
    example: "Rent a home",
    description: "Renting, tenant rights and moving into a home.",
    icon: "home",
    outcome: "A safe next step for finding, renting or leaving a home.",
    value: ["decision", "checklist", "official-source"],
    clarifications: [
      { id: "rent", label: "I need to rent a home", description: "Start with the national renting route and common checks.", href: "/essentials/housing-and-renting/", result: "Renting checklist and responsible sources" },
      { id: "move", label: "I am moving home", description: "Arrange energy, water, internet, waste and address changes.", href: "/essentials/utilities-and-moving-home/", result: "Moving-home checklist" },
      { id: "problem", label: "I have a housing or contract problem", description: "Use consumer, complaint and legal-help routes without treating YouNew as legal advice.", href: "/essentials/consumer-rights-scams-and-complaints/", result: "Complaint and escalation options" }
    ]
  },
  {
    id: "work",
    label: "Work",
    example: "Find a job",
    description: "Employment, contracts, taxes and self-employment.",
    icon: "work",
    outcome: "The right employment route and the authority responsible for it.",
    value: ["answer", "decision", "official-source"],
    clarifications: [
      { id: "job", label: "I am looking for work", description: "Understand the national employment route and basic checks.", href: "/essentials/work-and-employment/", result: "Employment route and next actions" },
      { id: "tax", label: "I need to understand income tax", description: "Start with tax-return responsibilities and official tax information.", href: "/essentials/taxes-and-income-tax-return/", result: "Tax checklist and Belastingdienst source" },
      { id: "zzp", label: "I want to start as a ZZP’er", description: "Prepare the KVK, residence and tax questions before registering.", href: "/essentials/starting-a-business-and-zzp/", result: "ZZP preparation route" }
    ]
  },
  {
    id: "healthcare",
    label: "Healthcare",
    example: "Find a GP",
    description: "Huisarts, insurance, medicines and specialist routes.",
    icon: "healthcare",
    outcome: "A safe healthcare route with escalation boundaries and official sources.",
    value: ["answer", "checklist", "official-source"],
    clarifications: [
      { id: "gp", label: "I need a huisarts (GP)", description: "See how primary care and registration normally work.", href: "/essentials/healthcare-doctor-and-insurance/", result: "GP and insurance route" },
      { id: "mental-health", label: "I need mental-health support", description: "Choose the non-urgent or crisis route; emergencies remain separate.", href: "/essentials/mental-health-and-crisis-support/", result: "Mental-health support route" },
      { id: "dentist", label: "I need a dentist", description: "Understand dental registration, coverage and urgent dental care.", href: "/essentials/dentist-and-dental-care/", result: "Dental-care checklist" },
      { id: "medicines", label: "I need medicines or a pharmacy", description: "Check prescriptions, pharmacies and safe medicine information.", href: "/essentials/medicines-prescriptions-and-pharmacies/", result: "Medicine and pharmacy route" },
      { id: "pregnancy", label: "I need pregnancy or maternity care", description: "Start with the midwife, screening and maternity-care route.", href: "/essentials/pregnancy-midwife-and-maternity-care/", result: "Pregnancy-care checklist" }
    ]
  },
  {
    id: "documents",
    label: "Documents",
    example: "Get a BSN",
    description: "Registration, DigiD, residence and identity documents.",
    icon: "documents",
    outcome: "A document checklist and the correct official authority.",
    value: ["checklist", "official-source"],
    clarifications: [
      { id: "bsn", label: "I need a BSN or municipal registration", description: "Start with registration, BSN and DigiD basics.", href: "/essentials/documents-registration-and-digid/", result: "Registration and DigiD checklist" },
      { id: "residence", label: "I need a visa or residence permit", description: "Identify the national immigration route and responsible IND source.", href: "/essentials/immigration-visas-and-residence-permits/", result: "Immigration route and IND source" },
      { id: "benefits", label: "I need benefits or allowances", description: "Review the national allowance route and exact eligibility source.", href: "/essentials/benefits-and-allowances/", result: "Allowance checklist and official source" }
    ]
  },
  {
    id: "study",
    label: "Study",
    example: "Find a course",
    description: "Schools, higher education, Dutch and civic integration.",
    icon: "study",
    outcome: "A study or school route with the responsible education source.",
    value: ["decision", "checklist", "official-source"],
    clarifications: [
      { id: "education", label: "I want to study or learn Dutch", description: "Start with education, diploma and Dutch-language routes.", href: "/essentials/education-and-learning-dutch/", result: "Education and language-learning route" },
      { id: "school", label: "I need school or childcare for my child", description: "Understand childcare, school and family basics.", href: "/essentials/family-childcare-and-school/", result: "School and childcare checklist" },
      { id: "residence", label: "I need a study residence route", description: "Check immigration conditions with the responsible national authority.", href: "/essentials/immigration-visas-and-residence-permits/", result: "Residence route and IND source" }
    ]
  },
  {
    id: "daily-life",
    label: "Daily life",
    example: "Open a bank account",
    description: "Banking, transport, phone, utilities and everyday rules.",
    icon: "daily-life",
    outcome: "A practical checklist for one everyday need.",
    value: ["answer", "checklist", "official-source"],
    clarifications: [
      { id: "bank", label: "I need a bank account", description: "Understand common account and payment requirements.", href: "/essentials/bank-account-and-payments/", result: "Banking checklist" },
      { id: "transport", label: "I need public transport or cycling help", description: "Use the national transport and safe-travel route.", href: "/essentials/public-transport-and-cycling/", result: "Transport route and official sources" },
      { id: "phone", label: "I need a SIM card or internet", description: "Compare the practical requirements before choosing a contract.", href: "/essentials/sim-phone-and-internet/", result: "Phone and internet checklist" },
      { id: "utilities", label: "I need utilities or waste information", description: "Arrange energy, water, internet and local waste services.", href: "/essentials/utilities-and-moving-home/", result: "Utilities checklist" },
      { id: "fine", label: "I received a fine or need to check a rule", description: "Find the responsible rule, deadline and official route.", href: "/essentials/rules-and-fines/", result: "Rules and fines route" }
    ]
  },
  {
    id: "emergency",
    label: "Emergency",
    example: "Get urgent help",
    description: "Immediate help and clear urgent versus non-urgent boundaries.",
    icon: "emergency",
    outcome: "The correct urgent action without delay.",
    value: ["answer", "official-source"],
    urgent: true,
    clarifications: [
      { id: "urgent", label: "I need urgent help now", description: "Open the emergency page immediately.", href: "/emergency/", result: "Urgent action and official numbers" }
    ]
  },
  {
    id: "lgbtiq",
    label: "LGBTIQ+",
    example: "Find support",
    description: "Support, safety and discrimination reporting routes.",
    icon: "lgbtiq",
    outcome: "A verified support or reporting route.",
    value: ["answer", "official-source"],
    clarifications: [
      { id: "support", label: "I need LGBTIQ+ support", description: "Start with national support and safety routes.", href: "/essentials/lgbtiq-support-and-discrimination-help/", result: "Support and official contact route" },
      { id: "discrimination", label: "I want to report discrimination", description: "See responsible reporting and support options.", href: "/essentials/lgbtiq-support-and-discrimination-help/", result: "Reporting and support options" }
    ]
  },
  {
    id: "pets",
    label: "Pets",
    example: "Register a pet",
    description: "Dogs, cats, vets, registration and local rules.",
    icon: "pets",
    outcome: "A pet-care and registration checklist with local-rule boundaries.",
    value: ["checklist", "official-source"],
    clarifications: [
      { id: "pet", label: "I am bringing or keeping a pet", description: "Review national pet, dog and cat basics.", href: "/essentials/pets-dogs-and-cats/", result: "Pet checklist and responsible sources" },
      { id: "local-rule", label: "I need a local pet rule", description: "Start nationally, then verify the exact rule with your municipality.", href: "/essentials/pets-dogs-and-cats/", result: "National route plus local verification boundary" }
    ]
  },
  {
    id: "family",
    label: "Family",
    example: "Find childcare",
    description: "Children, childcare, school, pregnancy and allowances.",
    icon: "family",
    outcome: "A family checklist and the correct responsible service.",
    value: ["checklist", "decision", "official-source"],
    clarifications: [
      { id: "childcare", label: "I need childcare or school", description: "Start with childcare, school and family basics.", href: "/essentials/family-childcare-and-school/", result: "Childcare and school checklist" },
      { id: "pregnancy", label: "I need pregnancy or maternity care", description: "Use the midwife, screening and maternity-care route.", href: "/essentials/pregnancy-midwife-and-maternity-care/", result: "Pregnancy-care checklist" },
      { id: "benefits", label: "I need family benefits or allowances", description: "Review the national allowance route and exact eligibility source.", href: "/essentials/benefits-and-allowances/", result: "Benefits checklist and official source" }
    ]
  }
] as const satisfies readonly YouNewTask[];

export type YouNewTaskId = (typeof youNewTasks)[number]["id"];

export function getYouNewTask(id: string): YouNewTask | undefined {
  return youNewTasks.find((task) => task.id === id);
}

export function taskHref(task: YouNewTask): string {
  return task.urgent ? "/emergency/" : `/tasks/${task.id}/`;
}
