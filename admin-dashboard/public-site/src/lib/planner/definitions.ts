export const plannerProfileIds = [
  "new-resident",
  "student",
  "expat",
  "worker",
  "refugee",
  "tourist",
  "resident",
  "prefer-not-to-say"
] as const;

export type PlannerProfileId = (typeof plannerProfileIds)[number];

export const plannerGoalIds = [
  "registration",
  "health-insurance",
  "housing",
  "study",
  "work",
  "taxes-benefits",
  "transport",
  "urgent-help",
  "other"
] as const;

export type PlannerGoalId = (typeof plannerGoalIds)[number];

export interface PlannerMunicipality {
  readonly slug: string;
  readonly name: string;
  readonly officialWebsite: string | null;
}

export interface PlannerGuideRoute {
  readonly id: string;
  readonly route: string;
  readonly title: string;
  readonly contentDepth: "summary" | "practical";
}

export interface PlannerAction {
  readonly id: string;
  readonly title: string;
  readonly description: string;
  readonly status: string;
  readonly href: string;
  readonly external: boolean;
}

export const plannerGoals = [
  {
    id: "registration",
    title: "BSN & registration",
    searchQuery: "registration BSN",
    preferredGuideId: "national.documents"
  },
  {
    id: "health-insurance",
    title: "Health insurance",
    searchQuery: "health insurance",
    preferredGuideId: "national.healthcare",
    officialHref: "https://www.government.nl/topics/health-insurance",
    officialTitle: "Check Dutch health insurance rules"
  },
  {
    id: "housing",
    title: "Housing",
    searchQuery: "housing rent",
    preferredGuideId: "national.housing"
  },
  {
    id: "study",
    title: "Study",
    searchQuery: "study education",
    preferredGuideId: "national.education",
    internalHref: "/categories/education/",
    internalTitle: "Browse published education guidance"
  },
  {
    id: "work",
    title: "Work",
    searchQuery: "work employment",
    preferredGuideId: "national.work",
    officialHref: "https://www.workinnl.nl/en/",
    officialTitle: "Open official Work in NL information"
  },
  {
    id: "taxes-benefits",
    title: "Taxes & benefits",
    searchQuery: "taxes benefits",
    preferredGuideId: "national.taxes",
    officialHref: "https://www.belastingdienst.nl/wps/wcm/connect/en/individuals/individuals",
    officialTitle: "Open the Dutch Tax Administration"
  },
  {
    id: "transport",
    title: "Transport",
    searchQuery: "transport",
    preferredGuideId: "national.transport",
    internalHref: "/map/?category=transport",
    internalTitle: "Explore published transport coverage"
  },
  {
    id: "urgent-help",
    title: "Urgent help",
    searchQuery: "urgent help",
    internalHref: "/emergency/",
    internalTitle: "Open emergency help"
  },
  {
    id: "other",
    title: "Something else",
    searchQuery: "Netherlands guidance",
    internalHref: "/search/",
    internalTitle: "Search all published guidance"
  }
] as const satisfies readonly Readonly<{
  id: PlannerGoalId;
  title: string;
  searchQuery: string;
  preferredGuideId?: string;
  officialHref?: string;
  officialTitle?: string;
  internalHref?: string;
  internalTitle?: string;
}>[];

const goalsById = new Map<PlannerGoalId, (typeof plannerGoals)[number]>(
  plannerGoals.map((goal) => [goal.id, goal])
);

function searchHref(query: string, municipality: PlannerMunicipality, profile: PlannerProfileId) {
  const params = new URLSearchParams({ q: query });
  if (municipality.slug !== "national") params.set("city", municipality.slug);
  if (profile !== "prefer-not-to-say") params.set("profile", profile === "new-resident" ? "resident" : profile);
  return `/search/?${params.toString()}`;
}

export function buildPlannerActions(input: Readonly<{
  profile: PlannerProfileId;
  municipality: PlannerMunicipality;
  goalIds: readonly PlannerGoalId[];
  guides: readonly PlannerGuideRoute[];
}>): readonly PlannerAction[] {
  const guideById = new Map(input.guides.map((guide) => [guide.id, guide]));
  const actions: PlannerAction[] = [];

  input.goalIds.forEach((goalId) => {
    const goal = goalsById.get(goalId);
    if (!goal) return;
    const preferredGuide = "preferredGuideId" in goal
      ? guideById.get(goal.preferredGuideId)
      : undefined;
    const guideApplies = preferredGuide && (
      preferredGuide.id.startsWith("national.") || input.municipality.slug === "amsterdam"
    );

    if (guideApplies) {
      actions.push({
        id: `${goalId}-guide`,
        title: preferredGuide.title,
        description: preferredGuide.contentDepth === "practical"
          ? input.municipality.slug === "national"
            ? "Follow the published national guide and verify the current requirements with its responsible sources."
            : `Start with the published national guide, then check the local details for ${input.municipality.name}.`
          : "Start with the published YouNew summary, then verify the current procedure with the responsible source.",
        status: preferredGuide.contentDepth === "practical" ? "Practical guide" : "Published summary",
        href: preferredGuide.route,
        external: false
      });
      return;
    }

    if ("internalHref" in goal) {
      actions.push({
        id: `${goalId}-internal`,
        title: goal.internalTitle,
        description: goalId === "urgent-help"
          ? "Use the dedicated safety page for immediate and non-immediate help routes."
          : "Review the locations and source-backed records currently published by YouNew.",
        status: "Published YouNew route",
        href: goal.internalHref,
        external: false
      });
      return;
    }

    if ("officialHref" in goal) {
      actions.push({
        id: `${goalId}-official`,
        title: goal.officialTitle,
        description: "YouNew does not yet publish a complete practical guide for this topic. Continue with the responsible national source.",
        status: "Official source",
        href: goal.officialHref,
        external: true
      });
      return;
    }

    actions.push({
      id: `${goalId}-search`,
      title: `Search YouNew for ${goal.title.toLowerCase()}`,
      description: `Review the guidance currently published for ${input.municipality.name}. If nothing relevant is available, continue to the responsible source.`,
      status: "Search current coverage",
      href: searchHref(goal.searchQuery, input.municipality, input.profile),
      external: false
    });
  });

  if (input.municipality.slug !== "national" && input.goalIds.some((goalId) => goalId === "registration" || goalId === "housing")) {
    actions.push({
      id: "municipality",
      title: `Check ${input.municipality.name} municipality`,
      description: "Confirm appointments, local documents and municipal variations before acting.",
      status: "Official local context",
      href: `/municipalities/${input.municipality.slug}/`,
      external: false
    });
  }

  return actions;
}
