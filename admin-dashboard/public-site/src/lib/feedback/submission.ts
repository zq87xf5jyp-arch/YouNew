export const publicFeedbackTypes = [
  "incorrect-information",
  "product-problem",
  "accessibility",
  "privacy",
  "suggestion",
  "other"
] as const;

export type PublicFeedbackType = (typeof publicFeedbackTypes)[number];

export type PublicFeedbackInput = {
  email: string;
  feedbackType: string;
  message: string;
  pageReference: string;
  consentToPrivacy: boolean;
  websiteConfirmation: string;
};

export type PublicFeedbackErrors = Partial<Record<keyof PublicFeedbackInput | "form", string>>;

export type PublicFeedbackReceipt = {
  confirmationId: string;
  createdAt: string;
};

export type PublicFeedbackResult =
  | { submitted: true; receipt: PublicFeedbackReceipt }
  | { submitted: false; error: string };

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function validatePublicFeedback(input: PublicFeedbackInput): PublicFeedbackErrors {
  const errors: PublicFeedbackErrors = {};
  const email = input.email.trim();
  const message = input.message.trim();

  if (input.websiteConfirmation.trim()) errors.form = "The submission could not be accepted.";
  if (email && (!emailPattern.test(email) || email.length > 254)) errors.email = "Enter a valid email address or leave it empty.";
  if (!publicFeedbackTypes.includes(input.feedbackType as PublicFeedbackType)) errors.feedbackType = "Choose a feedback type.";
  if (message.length < 20 || message.length > 2000) errors.message = "Use 20–2,000 characters.";
  if (!input.pageReference.startsWith("/") || input.pageReference.length > 300) errors.pageReference = "The referenced page is invalid.";
  if (!input.consentToPrivacy) errors.consentToPrivacy = "Confirm the privacy notice before submitting.";
  return errors;
}

function validatedEndpoint(value: string) {
  const endpoint = new URL(value);
  if (
    endpoint.protocol !== "https:" ||
    !endpoint.hostname.endsWith(".supabase.co") ||
    endpoint.pathname !== "/functions/v1/submit-public-feedback"
  ) {
    throw new Error("Feedback endpoint configuration is invalid.");
  }
  return endpoint.toString();
}

export function createPublicFeedbackRepository(endpointValue: string) {
  const endpoint = validatedEndpoint(endpointValue);
  return {
    async submit(input: PublicFeedbackInput): Promise<PublicFeedbackResult> {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), 15_000);
      try {
        const response = await fetch(endpoint, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(input),
          signal: controller.signal
        });
        const payload = await response.json().catch(() => null) as Partial<PublicFeedbackReceipt> | null;
        if (
          !response.ok ||
          !payload ||
          typeof payload.confirmationId !== "string" ||
          !/^YNF-[A-F0-9]{12}$/.test(payload.confirmationId) ||
          typeof payload.createdAt !== "string"
        ) {
          return {
            submitted: false,
            error: response.status === 429
              ? "Too many recent attempts. Wait 15 minutes and try again."
              : "Feedback could not be saved. Your text is still here; please try again."
          };
        }
        return {
          submitted: true,
          receipt: {
            confirmationId: payload.confirmationId,
            createdAt: payload.createdAt
          }
        };
      } catch {
        return {
          submitted: false,
          error: "Feedback could not be saved. Your text is still here; please try again."
        };
      } finally {
        clearTimeout(timeout);
      }
    }
  };
}
