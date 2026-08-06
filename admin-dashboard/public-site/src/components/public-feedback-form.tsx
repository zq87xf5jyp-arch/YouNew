"use client";

import { useEffect, useId, useMemo, useState, type FormEvent } from "react";
import siteConfig from "@/config/site-config.json";
import {
  createPublicFeedbackRepository,
  publicFeedbackTypes,
  validatePublicFeedback,
  type PublicFeedbackErrors,
  type PublicFeedbackInput,
  type PublicFeedbackType
} from "@/lib/feedback/submission";

const feedbackTypeLabels: Record<(typeof publicFeedbackTypes)[number], string> = {
  "incorrect-information": "Incorrect or outdated information",
  "product-problem": "Website or app problem",
  accessibility: "Accessibility problem",
  privacy: "Privacy question",
  suggestion: "Suggestion",
  other: "Other"
};

function safePageReference(value: string | null, fallback: string) {
  return value?.startsWith("/") && value.length <= 300 ? value : fallback;
}

export function PublicFeedbackForm({
  defaultPageReference,
  initialFeedbackType,
  compact = false
}: {
  defaultPageReference?: string;
  initialFeedbackType?: PublicFeedbackType;
  compact?: boolean;
} = {}) {
  const id = useId();
  const typeId = `${id}-type`;
  const emailId = `${id}-email`;
  const messageId = `${id}-message`;
  const websiteConfirmationId = `${id}-website-confirmation`;
  const repository = useMemo(
    () => createPublicFeedbackRepository(siteConfig.publicFeedback.endpoint),
    []
  );
  const [feedbackType, setFeedbackType] = useState(initialFeedbackType ?? "");
  const [pageReference, setPageReference] = useState(defaultPageReference ?? "/support/");
  const [errors, setErrors] = useState<PublicFeedbackErrors>({});
  const [deliveryError, setDeliveryError] = useState("");
  const [confirmationId, setConfirmationId] = useState("");
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!initialFeedbackType) {
      const params = new URLSearchParams(window.location.search);
      const requestedType = params.get("type");
      if (publicFeedbackTypes.includes(requestedType as (typeof publicFeedbackTypes)[number])) {
        setFeedbackType(requestedType ?? "");
      }
    }
    if (defaultPageReference) {
      setPageReference(safePageReference(defaultPageReference, window.location.pathname));
    } else {
      const params = new URLSearchParams(window.location.search);
      setPageReference(safePageReference(params.get("page"), window.location.pathname));
    }
  }, [defaultPageReference, initialFeedbackType]);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    const input: PublicFeedbackInput = {
      email: String(data.get("email") ?? ""),
      feedbackType,
      message: String(data.get("message") ?? ""),
      pageReference,
      consentToPrivacy: data.get("consentToPrivacy") === "on",
      websiteConfirmation: String(data.get("websiteConfirmation") ?? "")
    };
    const validationErrors = validatePublicFeedback(input);
    setErrors(validationErrors);
    setDeliveryError("");
    if (Object.keys(validationErrors).length > 0) return;

    setSubmitting(true);
    const result = await repository.submit(input);
    setSubmitting(false);
    if (!result.submitted) {
      setDeliveryError(result.error);
      return;
    }
    setConfirmationId(result.receipt.confirmationId);
  }

  if (confirmationId) {
    return (
      <section className="form-prepared-state" role="status" aria-live="polite">
        <h2>Feedback saved</h2>
        <p>Your confirmation ID is <strong>{confirmationId}</strong>.</p>
        <p>Keep this ID if you need to contact support about the submission.</p>
      </section>
    );
  }

  return (
    <form className={`business-application-form support-feedback-form${compact ? " is-compact" : ""}`} onSubmit={submit} noValidate>
      <div className="form-delivery-notice">
        <strong>Secure feedback form</strong>
        <p>The form saves your report before showing a confirmation ID. Do not include BSN numbers, passwords, identity documents, medical files or financial records.</p>
      </div>
      {deliveryError ? (
        <div className="form-error-summary" role="alert">
          <h2>Feedback was not saved</h2>
          <p>{deliveryError}</p>
          <p>If the problem continues, email <a href="mailto:support@younew.nl">support@younew.nl</a>.</p>
        </div>
      ) : null}
      {errors.form ? <p className="form-field-error" role="alert">{errors.form}</p> : null}
      <fieldset className="form-section" disabled={submitting}>
        <legend>Send feedback</legend>
        <div className="form-grid">
          <div className="form-field">
            <label htmlFor={typeId}>Type</label>
            <select id={typeId} name="feedbackType" value={feedbackType} onChange={(event) => setFeedbackType(event.target.value)} aria-invalid={Boolean(errors.feedbackType)} required>
              <option value="">Choose a type</option>
              {publicFeedbackTypes.map((type) => <option value={type} key={type}>{feedbackTypeLabels[type]}</option>)}
            </select>
            {errors.feedbackType ? <p className="form-field-error">{errors.feedbackType}</p> : null}
          </div>
          <div className="form-field">
            <label htmlFor={emailId}>Email <span>(optional)</span></label>
            <input id={emailId} name="email" type="email" maxLength={254} autoComplete="email" aria-invalid={Boolean(errors.email)} />
            {errors.email ? <p className="form-field-error">{errors.email}</p> : null}
          </div>
        </div>
        <div className="form-field">
          <label htmlFor={messageId}>What should we review?</label>
          <textarea id={messageId} name="message" rows={compact ? 5 : 7} minLength={20} maxLength={2000} aria-invalid={Boolean(errors.message)} required />
          <p className="form-field-help">20–2,000 characters. Referenced page: <code>{pageReference}</code></p>
          {errors.message ? <p className="form-field-error">{errors.message}</p> : null}
        </div>
        <div className="form-field visually-hidden" aria-hidden="true">
          <label htmlFor={websiteConfirmationId}>Leave this field empty</label>
          <input id={websiteConfirmationId} name="websiteConfirmation" tabIndex={-1} autoComplete="off" />
        </div>
        <div className="form-confirmations">
          <label>
            <input name="consentToPrivacy" type="checkbox" />
            <span>I agree that YouNew may process this feedback according to the <a href="/privacy/">privacy notice</a>.</span>
          </label>
          {errors.consentToPrivacy ? <p className="form-field-error">{errors.consentToPrivacy}</p> : null}
        </div>
      </fieldset>
      <button className="button button-primary" type="submit" disabled={submitting}>
        {submitting ? "Saving…" : "Send feedback"}
      </button>
    </form>
  );
}
