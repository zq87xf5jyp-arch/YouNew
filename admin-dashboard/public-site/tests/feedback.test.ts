import assert from "node:assert/strict";
import test from "node:test";

import {
  createPublicFeedbackRepository,
  validatePublicFeedback,
  type PublicFeedbackInput
} from "../src/lib/feedback/submission.ts";

const validFeedback: PublicFeedbackInput = {
  email: "reader@example.nl",
  feedbackType: "incorrect-information",
  message: "The municipality page now lists a different official procedure.",
  pageReference: "/guides/example/",
  consentToPrivacy: true,
  websiteConfirmation: ""
};

test("public feedback validates the controlled submission contract", () => {
  assert.deepEqual(validatePublicFeedback(validFeedback), {});
  assert.deepEqual(
    validatePublicFeedback({
      ...validFeedback,
      feedbackType: "invented",
      pageReference: "https://malicious.example",
      consentToPrivacy: false,
      websiteConfirmation: "bot"
    }),
    {
      form: "The submission could not be accepted.",
      feedbackType: "Choose a feedback type.",
      pageReference: "The referenced page is invalid.",
      consentToPrivacy: "Confirm the privacy notice before submitting."
    }
  );
});

test("public feedback reports success only for a valid stored receipt", async (context) => {
  context.mock.method(globalThis, "fetch", async (input: RequestInfo | URL, init?: RequestInit) => {
    assert.equal(input, "/api/submit-public-feedback.php");
    assert.equal(init?.mode, "same-origin");
    assert.equal(init?.credentials, "omit");
    assert.equal(init?.redirect, "error");
    return new Response(JSON.stringify({
    confirmationId: "YNF-A1B2C3D4E5F6",
    createdAt: "2026-07-28T10:00:00.000Z"
  }), {
    status: 201,
    headers: { "Content-Type": "application/json" }
    });
  });
  const repository = createPublicFeedbackRepository(
    "/api/submit-public-feedback.php"
  );
  assert.deepEqual(await repository.submit(validFeedback), {
    submitted: true,
    receipt: {
      confirmationId: "YNF-A1B2C3D4E5F6",
      createdAt: "2026-07-28T10:00:00.000Z"
    }
  });
});

test("feedback refuses external endpoints and invalid receipt dates", async (context) => {
  for (const endpoint of ["//evil.example/api/submit-public-feedback.php", "https://younew.nl.evil.example/api/submit-public-feedback.php", "/api/submit-public-feedback.php?x=1"]) {
    assert.throws(() => createPublicFeedbackRepository(endpoint), /configuration is invalid/);
  }
  context.mock.method(globalThis, "fetch", async () => new Response(JSON.stringify({confirmationId:"YNF-A1B2C3D4E5F6",createdAt:"invalid"}),{status:201}));
  assert.equal((await createPublicFeedbackRepository("/api/submit-public-feedback.php").submit(validFeedback)).submitted,false);
});

test("public feedback keeps an honest error when confirmation is unavailable", async (context) => {
  context.mock.method(globalThis, "fetch", async () => new Response("{}", {
    status: 503,
    headers: { "Content-Type": "application/json" }
  }));
  const repository = createPublicFeedbackRepository(
    "/api/submit-public-feedback.php"
  );
  assert.equal((await repository.submit(validFeedback)).submitted, false);
});
