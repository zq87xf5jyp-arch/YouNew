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
 * Journeys only reference records already present in the published canonical
 * artifact. Missing national topics are not substituted with draft content.
 */
export const practicalJourneys = [
  {
    id: "new-in-the-netherlands",
    title: "New in the Netherlands",
    audience: "New residents",
    description: "A local reading path for first registration, housing and municipal basics.",
    guideIds: [
      "government_service.first-registration-in-amsterdam",
      "housing.renting-a-home-in-amsterdam",
      "government_service.municipal-taxes-amsterdam",
      "government_service.moving-within-amsterdam"
    ],
    coverageNote: "The currently released steps are Amsterdam-specific. National BSN and DigiD guides remain in editorial review."
  },
  {
    id: "international-student",
    title: "International student",
    audience: "Students",
    description: "Published housing starting points relevant to students looking in Amsterdam.",
    guideIds: [
      "housing.renting-a-home-in-amsterdam",
      "housing.affordable-housing-amsterdam",
      "housing.woningnet-stadsregio-amsterdam",
      "housing.woon"
    ],
    coverageNote: "Study enrolment and student-housing procedures are not yet released as practical guides."
  },
  {
    id: "starting-work",
    title: "Starting work",
    audience: "Workers and expats",
    description: "A planned path for contracts, taxes, banking and employee essentials.",
    guideIds: [],
    coverageNote: "No governed work guide is in the production release yet, so YouNew does not show an unverified sequence."
  },
  {
    id: "looking-for-housing",
    title: "Looking for housing",
    audience: "Renters",
    description: "Published Amsterdam housing resources in a suggested reading order.",
    guideIds: [
      "housing.renting-a-home-in-amsterdam",
      "housing.affordable-housing-amsterdam",
      "housing.housing-permit-amsterdam",
      "housing.woningnet-stadsregio-amsterdam",
      "housing.woon"
    ],
    coverageNote: "These are verified source cards, not a national rental procedure. Requirements can differ by municipality."
  },
  {
    id: "healthcare-setup",
    title: "Healthcare setup",
    audience: "New residents",
    description: "A planned path for a huisarts, insurance and urgent-care access.",
    guideIds: [],
    coverageNote: "Healthcare organizations are published, but no complete healthcare procedure has passed the guide release gate."
  },
  {
    id: "refugee-essentials",
    title: "Refugee essentials",
    audience: "Refugees and support networks",
    description: "Currently released municipal registration and housing source cards.",
    guideIds: [
      "government_service.first-registration-in-amsterdam",
      "housing.renting-a-home-in-amsterdam",
      "housing.woon"
    ],
    coverageNote: "This limited Amsterdam path is not asylum or legal advice. National refugee procedures remain under specialist review."
  },
  {
    id: "tourist-essentials",
    title: "Tourist essentials",
    audience: "Tourists",
    description: "A planned path for transport, local orientation and urgent help.",
    guideIds: [],
    coverageNote: "Use Cities, Map and Emergency today; a governed ordered guide sequence has not been released."
  },
  {
    id: "starting-a-business",
    title: "Starting a business",
    audience: "Entrepreneurs",
    description: "A planned path for registration, tax and local business setup.",
    guideIds: [],
    coverageNote: "The business-registration practical guide is a draft until its composed instructions receive editorial approval."
  }
] as const satisfies readonly PracticalJourneyDefinition[];

const stepsByJourney: ReadonlyMap<string, ReadonlySet<string>> = new Map(
  practicalJourneys.map((journey) => [journey.id, new Set<string>(journey.guideIds)])
);

export function isKnownJourneyStep(journeyId: string, guideId: string): boolean {
  return stepsByJourney.get(journeyId)?.has(guideId) ?? false;
}
