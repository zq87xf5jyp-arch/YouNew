import assert from "node:assert/strict";
import test from "node:test";
import {
  buildPlannerActions,
  type PlannerGuideRoute,
  type PlannerMunicipality
} from "../src/lib/planner/definitions.ts";

const amsterdam: PlannerMunicipality = {
  slug: "amsterdam",
  name: "Amsterdam",
  officialWebsite: "https://www.amsterdam.nl/en/"
};

const rotterdam: PlannerMunicipality = {
  slug: "rotterdam",
  name: "Rotterdam",
  officialWebsite: "https://www.rotterdam.nl/en"
};

const national: PlannerMunicipality = {
  slug: "national",
  name: "National guidance",
  officialWebsite: "https://www.government.nl/"
};

const guides: readonly PlannerGuideRoute[] = [
  {
    id: "government_service.first-registration-in-amsterdam",
    route: "/guides/first-registration-in-amsterdam",
    title: "First registration in Amsterdam",
    contentDepth: "summary"
  },
  {
    id: "housing.renting-a-home-in-amsterdam",
    route: "/guides/renting-home-amsterdam",
    title: "Renting home Amsterdam",
    contentDepth: "summary"
  },
  {
    id: "national.documents",
    route: "/essentials/documents-registration-and-digid/",
    title: "BSN, registration, DigiD and residence documents",
    contentDepth: "practical"
  },
  {
    id: "national.healthcare",
    route: "/essentials/healthcare-doctor-and-insurance/",
    title: "Healthcare, huisarts and health insurance",
    contentDepth: "practical"
  },
  {
    id: "national.work",
    route: "/essentials/work-and-employment/",
    title: "Work and employment in the Netherlands",
    contentDepth: "practical"
  },
  {
    id: "national.taxes",
    route: "/essentials/taxes-and-income-tax-return/",
    title: "Taxes and income tax returns",
    contentDepth: "practical"
  },
  {
    id: "national.utilities-moving",
    route: "/essentials/utilities-and-moving-home/",
    title: "Utilities and moving home",
    contentDepth: "practical"
  },
  {
    id: "national.consumer-rights",
    route: "/essentials/consumer-rights-scams-and-complaints/",
    title: "Consumer rights, scams and complaints",
    contentDepth: "practical"
  },
  {
    id: "national.mental-health",
    route: "/essentials/mental-health-and-crisis-support/",
    title: "Mental health and crisis support",
    contentDepth: "practical"
  },
  {
    id: "national.pregnancy",
    route: "/essentials/pregnancy-midwife-and-maternity-care/",
    title: "Pregnancy, midwife and maternity care",
    contentDepth: "practical"
  },
  {
    id: "national.business-zzp",
    route: "/essentials/starting-a-business-and-zzp/",
    title: "Starting a business and working as a ZZP'er",
    contentDepth: "practical"
  }
];

test("planner keeps a national guide visible and adds municipality context", () => {
  const amsterdamActions = buildPlannerActions({
    profile: "new-resident",
    municipality: amsterdam,
    goalIds: ["registration"],
    guides
  });
  assert.equal(amsterdamActions[0]?.href, "/essentials/documents-registration-and-digid/");
  assert.equal(amsterdamActions[0]?.status, "Practical guide");
  assert.equal(amsterdamActions[1]?.href, "/municipalities/amsterdam/");

  const rotterdamActions = buildPlannerActions({
    profile: "new-resident",
    municipality: rotterdam,
    goalIds: ["registration"],
    guides
  });
  assert.equal(rotterdamActions[0]?.href, "/essentials/documents-registration-and-digid/");
  assert.match(rotterdamActions[0]?.description ?? "", /Rotterdam/);
  assert.equal(rotterdamActions[1]?.href, "/municipalities/rotterdam/");
});

test("planner routes published national topics to practical guides", () => {
  const actions = buildPlannerActions({
    profile: "student",
    municipality: rotterdam,
    goalIds: ["health-insurance", "work", "taxes-benefits"],
    guides
  });
  assert.deepEqual(actions.map((action) => action.status), [
    "Practical guide",
    "Practical guide",
    "Practical guide"
  ]);
  assert.ok(actions.every((action) => !action.external));
  assert.ok(actions.every((action) => action.href.startsWith("/essentials/")));
});

test("planner exposes new household, rights, wellbeing, family and business routes", () => {
  const actions = buildPlannerActions({
    profile: "resident",
    municipality: rotterdam,
    goalIds: ["utilities-moving", "consumer-legal", "health-wellbeing", "pregnancy-family", "business"],
    guides
  });
  assert.deepEqual(actions.map((action) => action.href), [
    "/essentials/utilities-and-moving-home/",
    "/essentials/consumer-rights-scams-and-complaints/",
    "/essentials/mental-health-and-crisis-support/",
    "/essentials/pregnancy-midwife-and-maternity-care/",
    "/essentials/starting-a-business-and-zzp/"
  ]);
  assert.ok(actions.every((action) => action.status === "Practical guide"));
});

test("planner keeps emergency guidance inside the dedicated YouNew route", () => {
  const actions = buildPlannerActions({
    profile: "tourist",
    municipality: amsterdam,
    goalIds: ["urgent-help"],
    guides
  });
  assert.deepEqual(actions, [{
    id: "urgent-help-internal",
    title: "Open emergency help",
    description: "Use the dedicated safety page for immediate and non-immediate help routes.",
    status: "Published YouNew route",
    href: "/emergency/",
    external: false
  }]);
});

test("national routes never invent a municipality page", () => {
  const actions = buildPlannerActions({
    profile: "prefer-not-to-say",
    municipality: national,
    goalIds: ["registration"],
    guides
  });
  assert.equal(actions.some((action) => action.href.includes("/municipalities/national")), false);
  assert.equal(actions[0]?.href, "/essentials/documents-registration-and-digid/");
  assert.equal(actions[0]?.status, "Practical guide");
});
