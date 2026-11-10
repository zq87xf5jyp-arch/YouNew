import assert from "node:assert/strict";
import test from "node:test";
import { createComponentHarness, findElement, handler } from "./component-harness.ts";
import { requiresKvkNumber, validateBusinessApplication } from "../src/lib/business/application.ts";

const variants = [
  { locale: "en", file: "local-business-application-form.tsx", component: "LocalBusinessApplicationForm", summaryId: "local-business-form-errors" },
  { locale: "nl", file: "nl-local-business-application-form.tsx", component: "NlLocalBusinessApplicationForm", summaryId: "nl-business-errors" }
] as const;

function formData(overrides: Record<string, string>) {
  const data = new FormData();
  for (const [name, value] of Object.entries({
    listingAction: "add",
    companyName: "Synthetic Example",
    contactPerson: "Test Contact",
    contactRole: "",
    email: "qa@example.invalid",
    phone: "",
    website: "https://example.invalid",
    organizationType: "non-profit",
    city: "Leiden",
    province: "Zuid-Holland",
    targetAudience: "expat",
    description: "Synthetic profile request for a local validation test only.",
    consentToPrivacy: "yes",
    confirmAccuracy: "yes",
    ...overrides
  })) data.set(name, value);
  return data;
}

function setup(variant: (typeof variants)[number]) {
  let submissions = 0;
  const focused: string[] = [];
  const details = { open: false };
  const harness = createComponentHarness(new URL(`../src/components/${variant.file}`, import.meta.url), {
    "next/link": "a",
    "@/config/site-config.json": { businessInquiry: { endpoint: "/api/submit-business-inquiry.php" } },
    "@/lib/analytics/client": { track() {} },
    "@/lib/business/application": {
      requiresKvkNumber,
      validateBusinessApplication,
      createApiPartnerApplicationRepository: () => ({ submit() { submissions += 1; throw new Error("No network submission is permitted in validation tests."); } }),
      mailtoPartnerApplicationRepository: { submit() { throw new Error("No email fallback is expected for invalid input."); } }
    }
  }, {
    window: { location: { href: "https://younew.nl/for-business/local/apply/", search: "" } },
    FormData: class {
      data: FormData;
      constructor(data: FormData) { this.data = data; }
      get(name: string) { return this.data.get(name); }
      getAll(name: string) { return this.data.getAll(name); }
    },
    requestAnimationFrame(callback: () => void) { callback(); },
    document: { getElementById(id: string) { return { focus() { focused.push(id); } }; } }
  });
  const render = () => harness.render(variant.component, { municipalities: ["Leiden"], provinces: ["Zuid-Holland"] });
  let tree = render();
  harness.flushEffects();
  tree = render();
  const ref = findElement(tree, (element) => element.type === "details").props.ref;
  assert.ok(ref && typeof ref === "object" && "current" in ref);
  ref.current = details;
  return {
    details,
    focused,
    submissions: () => submissions,
    async submit(data: FormData) {
      const form = findElement(render(), (element) => element.type === "form");
      await handler(form, "onSubmit")({ preventDefault() {}, currentTarget: data });
      return render();
    }
  };
}

for (const variant of variants) {
  for (const field of ["contactRole", "phone"] as const) {
    test(`${variant.locale} local form reveals a collapsed optional ${field} error and connects it to the input`, async () => {
      const harness = setup(variant);
      const tree = await harness.submit(formData({ [field]: "x" }));
      assert.equal(harness.details.open, true);
      assert.equal(harness.submissions(), 0);
      assert.deepEqual(harness.focused, [variant.summaryId]);

      const details = findElement(tree, (element) => element.type === "details");
      const input = findElement(details, (element) => element.type === "input" && element.props.name === field);
      assert.equal(input.props["aria-invalid"], true);
      const errorId = input.props["aria-describedby"];
      assert.equal(typeof errorId, "string");
      const error = findElement(details, (element) => element.props.id === errorId);
      assert.equal(error.type, "p");
      assert.equal(typeof error.props.children, "string");
      assert.match(error.props.children as string, variant.locale === "nl" ? /Vul .* of laat dit veld leeg\./ : /or leave it blank\./);

      // Closing the native disclosure must not hide the same error on a later attempt.
      harness.details.open = false;
      await harness.submit(formData({ [field]: "x" }));
      assert.equal(harness.details.open, true);
      assert.equal(harness.submissions(), 0);
    });
  }

  test(`${variant.locale} unrelated validation leaves blank optional contact fields collapsed`, async () => {
    const harness = setup(variant);
    const tree = await harness.submit(formData({ companyName: "" }));
    assert.equal(harness.details.open, false);
    assert.equal(harness.submissions(), 0);
    for (const field of ["contactRole", "phone"]) {
      const input = findElement(tree, (element) => element.type === "input" && element.props.name === field);
      assert.ok(!input.props["aria-invalid"]);
      assert.equal(input.props["aria-describedby"], undefined);
    }
  });
}
