import assert from "node:assert/strict";
import test from "node:test";
import { createComponentHarness, findElement } from "./component-harness.ts";

const components = new URL("../src/components/", import.meta.url);

test("feedback cannot expose named fields through a native GET before hydration", () => {
  const harness = createComponentHarness(new URL("public-feedback-form.tsx", components), {
    "@/config/site-config.json": { publicFeedback: { endpoint: "/api/submit-public-feedback.php" } },
    "@/lib/feedback/submission": {
      createPublicFeedbackRepository: () => ({ submit: () => { throw new Error("No submission expected"); } }),
      publicFeedbackTypes: ["suggestion"],
      validatePublicFeedback: () => ({})
    }
  }, { window: { location: { search: "", pathname: "/support/" } } });
  const beforeHydration = harness.render("PublicFeedbackForm");
  const form = findElement(beforeHydration, (element) => element.type === "form");
  assert.equal(form.props.method, "post", "native fallback must never put report fields in a URL");
  assert.equal(form.props.action, "/support/");
  assert.equal(form.props.inert, true);
  assert.equal(findElement(beforeHydration, (element) => element.type === "fieldset").props.disabled, true);
  assert.equal(findElement(beforeHydration, (element) => element.props.type === "submit").props.disabled, true);
  findElement(beforeHydration, (element) => element.type === "noscript");

  harness.flushEffects();
  const hydrated = harness.render("PublicFeedbackForm");
  assert.equal(findElement(hydrated, (element) => element.type === "form").props.inert, undefined);
  assert.equal(findElement(hydrated, (element) => element.type === "fieldset").props.disabled, false);
  assert.equal(findElement(hydrated, (element) => element.props.type === "submit").props.disabled, false);
});

function pilotHarness(serverResult: unknown) {
  const navigations: string[] = [];
  const tracked: string[] = [];
  let submitted = 0;
  let fallback = 0;
  let storageAttempts = 0;
  const harness = createComponentHarness(new URL("pilot-request-form.tsx", components), {
    "next/link": () => null,
    "@/config/site-config.json": { businessInquiry: { endpoint: "/api/submit-business-inquiry.php" } },
    "@/lib/business/application": {
      requiresKvkNumber: () => false,
      validateBusinessApplication: () => ({ valid: true, errors: {} }),
      createApiPartnerApplicationRepository: () => ({ submit: async () => { submitted++; return serverResult; } }),
      mailtoPartnerApplicationRepository: { submit: async () => { fallback++; return { kind: "user-email-handoff", href: "mailto:test@example.invalid" }; } }
    },
    "@/lib/analytics/client": { track: (event: { name: string }) => tracked.push(event.name) }
  }, {
    window: { location: { href: "https://example.invalid/partners/apply/", assign: (url: string) => navigations.push(url) } },
    sessionStorage: { setItem() { storageAttempts++; throw new Error("QuotaExceededError"); } },
    FormData: class { get() { return ""; } }
  });
  return { harness, navigations, tracked, counts: () => ({ submitted, fallback, storageAttempts }) };
}

test("a stored pilot receipt remains successful when Safari storage is unavailable", async () => {
  const scenario = pilotHarness({ kind: "server-submission", confirmationId: "YNB-TEST", createdAt: "2026-10-26T12:00:00Z" });
  const tree = scenario.harness.render("PilotRequestForm", { municipalities: [], provinces: [] });
  let prevented = false;
  await findElement(tree, (element) => element.type === "form").props.onSubmit({
    preventDefault() { prevented = true; }, currentTarget: {}
  });
  assert.equal(prevented, true);
  assert.deepEqual(scenario.counts(), { submitted: 1, fallback: 0, storageAttempts: 1 });
  assert.deepEqual(scenario.navigations, ["/partners/apply/success/"]);
  assert.deepEqual(scenario.tracked, ["lead_submit", "pilot_request"]);
});

test("an unconfirmed pilot submission still cannot reach the success page", async () => {
  const scenario = pilotHarness({ kind: "user-email-handoff", href: "mailto:test@example.invalid" });
  const tree = scenario.harness.render("PilotRequestForm", { municipalities: [], provinces: [] });
  await findElement(tree, (element) => element.type === "form").props.onSubmit({ preventDefault() {}, currentTarget: {} });
  assert.deepEqual(scenario.counts(), { submitted: 1, fallback: 1, storageAttempts: 0 });
  assert.deepEqual(scenario.navigations, []);
  assert.equal(scenario.tracked.includes("lead_submit"), false);
});
