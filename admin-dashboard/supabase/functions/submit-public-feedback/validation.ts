const feedbackTypes = new Set([
  "incorrect-information",
  "product-problem",
  "accessibility",
  "privacy",
  "suggestion",
  "other",
]);
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

type UnknownRecord = Record<string, unknown>;

export type PublicFeedbackValidation = {
  valid: boolean;
  fields: string[];
};

function isObject(value: unknown): value is UnknownRecord {
  return Boolean(value) && typeof value === "object" && !Array.isArray(value);
}

function text(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

export function validatePublicFeedbackPayload(
  value: unknown,
): PublicFeedbackValidation {
  if (!isObject(value)) return { valid: false, fields: ["form"] };
  const fields: string[] = [];
  const email = text(value.email);
  const message = text(value.message);
  const pageReference = text(value.pageReference);

  if (text(value.websiteConfirmation)) fields.push("form");
  if (email && (!emailPattern.test(email) || email.length > 254)) {
    fields.push("email");
  }
  if (!feedbackTypes.has(text(value.feedbackType))) fields.push("feedbackType");
  if (message.length < 20 || message.length > 2000) fields.push("message");
  if (!pageReference.startsWith("/") || pageReference.length > 300) {
    fields.push("pageReference");
  }
  if (value.consentToPrivacy !== true) fields.push("consentToPrivacy");

  return { valid: fields.length === 0, fields };
}
