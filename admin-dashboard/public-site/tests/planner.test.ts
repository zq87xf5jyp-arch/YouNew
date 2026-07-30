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
  }
];

test("planner uses a published local guide only where it applies", () => {
  const amsterdamActions = buildPlannerActions({
    profile: "new-resident",
    municipality: amsterdam,
    goalIds: ["registration"],
    guides
  });
  assert.equal(amsterdamActions[0]?.href, "/guides/first-registration-in-amsterdam");
  assert.equal(amsterdamActions[0]?.status, "Published summary");
  assert.equal(amsterdamActions[1]?.href, "/municipalities/amsterdam/");

  const rotterdamActions = buildPlannerActions({
    profile: "new-resident",
    municipality: rotterdam,
    goalIds: ["registration"],
    guides
  });
  assert.match(rotterdamActions[0]?.href ?? "", /^\/search\/\?/);
  assert.equal(rotterdamActions[0]?.href.includes("city=rotterdam"), true);
  assert.equal(rotterdamActions[1]?.href, "/municipalities/rotterdam/");
});

test("planner routes unreleased national topics to responsible sources", () => {
  const actions = buildPlannerActions({
    profile: "student",
    municipality: rotterdam,
    goalIds: ["health-insurance", "work", "taxes-benefits"],
    guides
  });
  assert.deepEqual(actions.map((action) => action.status), [
    "Official source",
    "Official source",
    "Official source"
  ]);
  assert.ok(actions.every((action) => action.external));
  assert.ok(actions.every((action) => action.href.startsWith("https://")));
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
