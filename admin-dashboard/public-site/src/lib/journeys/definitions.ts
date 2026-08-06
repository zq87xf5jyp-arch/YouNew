export const journeyStepStates = ["not-started", "in-progress", "completed"] as const;
export type JourneyStepState = (typeof journeyStepStates)[number];

export interface PracticalJourneyDefinition {
  readonly id: string;
  readonly title: string;
  readonly audience: string;
  readonly description: string;
  readonly guideIds: readonly string[];
  readonly coverageNote: string;
}

/**
 * Journeys reference only source-checked national guides in the published web
 * dataset. A journey is a suggested reading order, not an eligibility decision
 * or proof that an administrative process is complete.
 */
export const practicalJourneys = [
  {
    id: "new-in-the-netherlands",
    title: "New in the Netherlands",
    audience: "New residents",
    description: "Start with residence status and registration, then arrange the essentials for everyday life.",
    guideIds: [
      "national.immigration",
      "national.documents",
      "national.housing",
      "national.utilities-moving",
      "national.healthcare",
      "national.banking",
      "national.transport"
    ],
    coverageNote: "National starting point. Your municipality, residence status and personal circumstances can change the exact order and documents."
  },
  {
    id: "international-student",
    title: "International student",
    audience: "Students",
    description: "A national route through study, registration, housing, healthcare and daily payments.",
    guideIds: [
      "national.education",
      "national.immigration",
      "national.documents",
      "national.housing",
      "national.utilities-moving",
      "national.healthcare",
      "national.mental-health",
      "national.banking",
      "national.transport"
    ],
    coverageNote: "Admission, visa and housing rules depend on the institution, nationality and length of stay. Confirm them with the responsible organisation."
  },
  {
    id: "starting-work",
    title: "Starting work",
    audience: "Workers and expats",
    description: "Review work rights, registration, pay, tax, insurance and benefits in a practical order.",
    guideIds: [
      "national.immigration",
      "national.work",
      "national.documents",
      "national.banking",
      "national.taxes",
      "national.healthcare",
      "national.benefits"
    ],
    coverageNote: "This is general employee guidance. Contract type, residence status and cross-border work can require a different route."
  },
  {
    id: "looking-for-housing",
    title: "Looking for housing",
    audience: "Renters",
    description: "Prepare for a rental search, documents, costs, allowances and problems with a landlord.",
    guideIds: [
      "national.housing",
      "national.documents",
      "national.banking",
      "national.benefits",
      "national.utilities-moving",
      "national.consumer-rights",
      "national.debt-legal-help",
      "national.rules-fines"
    ],
    coverageNote: "Permits, social-housing access and local registration vary by municipality. Never transfer money before checking the home, contract and counterparty."
  },
  {
    id: "healthcare-setup",
    title: "Healthcare setup",
    audience: "New residents",
    description: "Set up registration and insurance, then learn how routine and urgent care are organised.",
    guideIds: [
      "national.documents",
      "national.healthcare",
      "national.mental-health",
      "national.dental-care",
      "national.medicines",
      "national.pregnancy",
      "national.benefits"
    ],
    coverageNote: "This route is not medical advice. For urgent danger use the Emergency page; insurance duties and access can differ by situation."
  },
  {
    id: "refugee-essentials",
    title: "Refugee essentials",
    audience: "Refugees and support networks",
    description: "Find national starting points for status, registration, housing, healthcare, work and support.",
    guideIds: [
      "national.immigration",
      "national.documents",
      "national.healthcare",
      "national.mental-health",
      "national.housing",
      "national.debt-legal-help",
      "national.work",
      "national.benefits",
      "national.lgbtiq-support"
    ],
    coverageNote: "This is not an asylum procedure or legal advice. Follow COA, IND, VluchtelingenWerk and municipal instructions for the specific case."
  },
  {
    id: "tourist-essentials",
    title: "Tourist essentials",
    audience: "Tourists",
    description: "Prepare transport, connectivity and key Dutch rules before and during a short visit.",
    guideIds: [
      "national.transport",
      "national.telecom",
      "national.consumer-rights",
      "national.rules-fines"
    ],
    coverageNote: "These guides are national orientation, not travel insurance or visa advice. Use the Emergency page for urgent help."
  },
  {
    id: "starting-a-business",
    title: "Starting a business",
    audience: "Entrepreneurs",
    description: "Check whether you may work, prepare the legal structure and KVK route, then arrange banking, tax and client basics.",
    guideIds: [
      "national.immigration",
      "national.documents",
      "national.business-zzp",
      "national.banking",
      "national.taxes",
      "national.work",
      "national.consumer-rights"
    ],
    coverageNote: "National preparation route. Residence status, legal structure, sector rules and municipality permits can change the exact procedure."
  }
] as const satisfies readonly PracticalJourneyDefinition[];

const stepsByJourney: ReadonlyMap<string, ReadonlySet<string>> = new Map(
  practicalJourneys.map((journey) => [journey.id, new Set<string>(journey.guideIds)])
);

export function isKnownJourneyStep(journeyId: string, guideId: string): boolean {
  return stepsByJourney.get(journeyId)?.has(guideId) ?? false;
}
