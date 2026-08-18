"use client";

import Link from "next/link";
import { useEffect, useRef, useState, type FormEvent } from "react";
import {
  createApiPartnerApplicationRepository,
  mailtoPartnerApplicationRepository,
  requiresKvkNumber,
  validateBusinessApplication
} from "@/lib/business/application";
import type {
  BusinessApplicationInput,
  BusinessApplicationValidation,
  OrganizationType
} from "@/lib/business/types";
import { track } from "@/lib/analytics/client";
import siteConfig from "@/config/site-config.json";

const organizationOptions: Array<{ value: OrganizationType; label: string }> = [
  { value: "commercial-business", label: "Dutch employer" },
  { value: "advertising-agency", label: "Relocation or global-mobility company" },
  { value: "sole-trader", label: "Independent provider" },
  { value: "non-profit", label: "Non-profit" },
  { value: "public-organization", label: "Public organization" },
  { value: "education", label: "Education provider" },
  { value: "healthcare", label: "Healthcare provider" },
  { value: "other", label: "Other" }
];

type ErrorMap = BusinessApplicationValidation["errors"];

function valueOf(formData: FormData, name: string): string {
  const value = formData.get(name);
  return typeof value === "string" ? value : "";
}

function pilotApplicationFrom(formData: FormData): BusinessApplicationInput {
  const currentUrl = new URL(window.location.href);
  return {
    companyName: valueOf(formData, "companyName"),
    contactPerson: valueOf(formData, "contactPerson"),
    contactRole: valueOf(formData, "contactRole"),
    offerInterest: "onboarding_pilot",
    email: valueOf(formData, "email"),
    phone: valueOf(formData, "phone"),
    website: valueOf(formData, "website"),
    inquiryType: "partnership",
    organizationType: valueOf(formData, "organizationType") as BusinessApplicationInput["organizationType"],
    kvkNumber: valueOf(formData, "kvkNumber"),
    city: valueOf(formData, "city"),
    province: valueOf(formData, "province"),
    targetAudience: ["worker", "expat"],
    requestedPlacements: ["content-partnership"],
    campaignGoal: valueOf(formData, "campaignGoal"),
    budgetRange: "1000-3000",
    campaignStart: "",
    campaignEnd: "",
    description: valueOf(formData, "description"),
    consentToPrivacy: formData.get("consentToPrivacy") === "yes",
    confirmAccuracy: formData.get("confirmAccuracy") === "yes",
    websiteConfirmation: valueOf(formData, "websiteConfirmation"),
    sourcePage: currentUrl.pathname,
    utmSource: currentUrl.searchParams.get("utm_source")?.slice(0, 120) ?? "",
    utmMedium: currentUrl.searchParams.get("utm_medium")?.slice(0, 120) ?? "",
    utmCampaign: currentUrl.searchParams.get("utm_campaign")?.slice(0, 160) ?? "",
    utmContent: currentUrl.searchParams.get("utm_content")?.slice(0, 160) ?? "",
    utmTerm: currentUrl.searchParams.get("utm_term")?.slice(0, 160) ?? ""
  };
}

function FieldError({ errors, name }: { errors: ErrorMap; name: keyof BusinessApplicationInput }) {
  const message = errors[name];
  return message ? <p className="form-field-error" id={`pilot-${name}-error`}>{message}</p> : null;
}

export function PilotRequestForm({
  municipalities,
  provinces
}: {
  municipalities: readonly string[];
  provinces: readonly string[];
}) {
  const [interactive, setInteractive] = useState(false);
  const [organizationType, setOrganizationType] = useState<BusinessApplicationInput["organizationType"]>("");
  const [errors, setErrors] = useState<ErrorMap>({});
  const [submissionError, setSubmissionError] = useState(false);
  const [emailDraft, setEmailDraft] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const leadStarted = useRef(false);
  const kvkRequired = requiresKvkNumber(organizationType);
  const repository = createApiPartnerApplicationRepository(siteConfig.businessInquiry.endpoint);

  useEffect(() => setInteractive(true), []);

  const handleInput = (event: FormEvent<HTMLFormElement>) => {
    if (submissionError) setSubmissionError(false);
    if (emailDraft) setEmailDraft("");
    if (Object.keys(errors).length) setErrors({});

    const target = event.target;
    if (target instanceof HTMLInputElement && target.name === "websiteConfirmation") return;
    const meaningful = target instanceof HTMLInputElement
      ? ((target.type === "checkbox" || target.type === "radio") ? target.checked : target.value.trim().length > 0)
      : target instanceof HTMLSelectElement || target instanceof HTMLTextAreaElement
        ? target.value.trim().length > 0
        : false;
    if (meaningful && !leadStarted.current) {
      leadStarted.current = true;
      track({ name: "lead_start" });
    }
  };

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setSubmissionError(false);
    setEmailDraft("");
    const application = pilotApplicationFrom(new FormData(event.currentTarget));
    const validation = validateBusinessApplication(application);
    setErrors(validation.errors);
    if (!validation.valid) {
      requestAnimationFrame(() => document.getElementById("pilot-form-errors")?.focus());
      return;
    }

    setSubmitting(true);
    try {
      const submission = await repository.submit(application);
      if (submission.kind !== "server-submission") throw new Error("A stored receipt was not returned.");
      sessionStorage.setItem("younew-pilot-receipt", JSON.stringify({
        confirmationId: submission.confirmationId,
        createdAt: submission.createdAt
      }));
      track({ name: "lead_submit" });
      track({ name: "pilot_request" });
      window.location.assign("/partners/apply/success/");
    } catch {
      setSubmissionError(true);
      try {
        const handoff = await mailtoPartnerApplicationRepository.submit(application);
        setEmailDraft(handoff.kind === "user-email-handoff" ? handoff.href : "");
        track({ name: "business_mailto_prepared", organizationType: application.organizationType });
      } catch {
        setEmailDraft("");
      }
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <>
      <noscript>
        <div className="form-delivery-notice">
          <strong>JavaScript is required to submit this request securely.</strong>
          <p>No details have been sent. Email support@younew.nl if you want to contact YouNew directly.</p>
        </div>
      </noscript>
      <form className="business-application-form pilot-request-form" action="/partners/apply/" method="post" onSubmit={handleSubmit} onInput={handleInput} noValidate inert={interactive ? undefined : true}>
        {Object.keys(errors).length ? (
          <div className="form-error-summary" id="pilot-form-errors" role="alert" tabIndex={-1}>
            <h2>Check the highlighted fields.</h2>
            <p>Complete the required details before sending the pilot request.</p>
            {errors.form ? <p>{errors.form}</p> : null}
          </div>
        ) : null}

        <fieldset className="form-section">
          <legend>Your team</legend>
          <div className="form-grid">
            <div className="form-field">
              <label htmlFor="companyName">Company or organization</label>
              <input id="companyName" name="companyName" maxLength={120} autoComplete="organization" aria-describedby={errors.companyName ? "pilot-companyName-error" : undefined} aria-invalid={Boolean(errors.companyName)} required />
              <FieldError errors={errors} name="companyName" />
            </div>
            <div className="form-field">
              <label htmlFor="organizationType">Organization type</label>
              <select id="organizationType" name="organizationType" value={organizationType} onChange={(event) => setOrganizationType(event.target.value as BusinessApplicationInput["organizationType"])} aria-describedby={errors.organizationType ? "pilot-organizationType-error" : undefined} aria-invalid={Boolean(errors.organizationType)} required>
                <option value="">Select a type</option>
                {organizationOptions.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}
              </select>
              <FieldError errors={errors} name="organizationType" />
            </div>
            <div className="form-field">
              <label htmlFor="contactPerson">Contact person</label>
              <input id="contactPerson" name="contactPerson" maxLength={120} autoComplete="name" aria-describedby={errors.contactPerson ? "pilot-contactPerson-error" : undefined} aria-invalid={Boolean(errors.contactPerson)} required />
              <FieldError errors={errors} name="contactPerson" />
            </div>
            <div className="form-field">
              <label htmlFor="contactRole">Role</label>
              <input id="contactRole" name="contactRole" maxLength={120} autoComplete="organization-title" placeholder="Global Mobility Lead" aria-describedby={errors.contactRole ? "pilot-contactRole-error" : undefined} aria-invalid={Boolean(errors.contactRole)} required />
              <FieldError errors={errors} name="contactRole" />
            </div>
            <div className="form-field">
              <label htmlFor="email">Work email</label>
              <input id="email" name="email" type="email" maxLength={254} autoComplete="email" aria-describedby={errors.email ? "pilot-email-error" : undefined} aria-invalid={Boolean(errors.email)} required />
              <FieldError errors={errors} name="email" />
            </div>
            <div className="form-field">
              <label htmlFor="phone">Phone <span>(optional)</span></label>
              <input id="phone" name="phone" type="tel" maxLength={40} autoComplete="tel" aria-describedby={errors.phone ? "pilot-phone-error" : undefined} aria-invalid={Boolean(errors.phone)} />
              <FieldError errors={errors} name="phone" />
            </div>
            <div className="form-field">
              <label htmlFor="website">Organization website</label>
              <input id="website" name="website" type="url" maxLength={300} inputMode="url" placeholder="https://example.nl" autoComplete="url" aria-describedby={errors.website ? "pilot-website-error" : undefined} aria-invalid={Boolean(errors.website)} required />
              <FieldError errors={errors} name="website" />
            </div>
            <div className="form-field">
              <label htmlFor="kvkNumber">KvK number {kvkRequired ? <span>(required)</span> : <span>(optional)</span>}</label>
              <input id="kvkNumber" name="kvkNumber" inputMode="numeric" maxLength={8} autoComplete="off" aria-describedby={errors.kvkNumber ? "pilot-kvkNumber-error" : undefined} aria-invalid={Boolean(errors.kvkNumber)} required={kvkRequired} />
              <FieldError errors={errors} name="kvkNumber" />
            </div>
          </div>
        </fieldset>

        <fieldset className="form-section">
          <legend>Pilot scope</legend>
          <div className="form-grid">
            <div className="form-field">
              <label htmlFor="city">Selected Dutch city or region</label>
              <input id="city" name="city" list="pilot-municipality-options" maxLength={100} autoComplete="address-level2" aria-describedby={errors.city ? "pilot-city-error" : undefined} aria-invalid={Boolean(errors.city)} required />
              <datalist id="pilot-municipality-options">{municipalities.map((municipality) => <option value={municipality} key={municipality} />)}</datalist>
              <FieldError errors={errors} name="city" />
            </div>
            <div className="form-field">
              <label htmlFor="province">Province</label>
              <select id="province" name="province" autoComplete="address-level1" aria-describedby={errors.province ? "pilot-province-error" : undefined} aria-invalid={Boolean(errors.province)} required>
                <option value="">Select a province</option>
                {provinces.map((province) => <option value={province} key={province}>{province}</option>)}
              </select>
              <FieldError errors={errors} name="province" />
            </div>
          </div>
          <div className="form-field">
            <label htmlFor="campaignGoal">What should the pilot help your team improve?</label>
            <textarea id="campaignGoal" name="campaignGoal" rows={3} maxLength={240} placeholder="For example: reduce repeated onboarding questions after an employee arrives." aria-describedby={errors.campaignGoal ? "pilot-campaignGoal-error" : undefined} aria-invalid={Boolean(errors.campaignGoal)} required />
            <FieldError errors={errors} name="campaignGoal" />
          </div>
          <div className="form-field">
            <label htmlFor="description">What do international employees ask today?</label>
            <textarea id="description" name="description" rows={6} maxLength={600} placeholder="Share the recurring questions, current onboarding approach and preferred region. Do not include employee personal data." aria-describedby={`pilot-description-help${errors.description ? " pilot-description-error" : ""}`} aria-invalid={Boolean(errors.description)} required />
            <p className="form-field-help" id="pilot-description-help">30–600 characters. Do not include employee names, health information or other sensitive personal data.</p>
            <FieldError errors={errors} name="description" />
          </div>
        </fieldset>

        <div className="form-honeypot" aria-hidden="true" hidden>
          <label htmlFor="websiteConfirmation">Leave this field empty</label>
          <input id="websiteConfirmation" name="websiteConfirmation" tabIndex={-1} autoComplete="off" />
        </div>

        <fieldset className="form-section form-confirmations">
          <legend>Confirmations</legend>
          <label>
            <input type="checkbox" name="consentToPrivacy" value="yes" aria-describedby={errors.consentToPrivacy ? "pilot-consentToPrivacy-error" : undefined} />
            I consent to the processing described in the <Link href="/privacy">Privacy Policy</Link> so YouNew can review and reply to this request.
          </label>
          <FieldError errors={errors} name="consentToPrivacy" />
          <label>
            <input type="checkbox" name="confirmAccuracy" value="yes" aria-describedby={errors.confirmAccuracy ? "pilot-confirmAccuracy-error" : undefined} />
            I confirm that the information is accurate and that I am authorized to submit this request.
          </label>
          <FieldError errors={errors} name="confirmAccuracy" />
        </fieldset>

        <div className="form-delivery-notice">
          <strong>What happens next</strong>
          <p>YouNew reviews fit and prepares a scoped proposal. The form does not create a contract, invoice or payment. Consent-based usage analytics are used only within the approved pilot scope, and no employee personal data is requested here.</p>
        </div>
        <button className="button button-primary" type="submit" disabled={!interactive || submitting}>{submitting ? "Sending request…" : "Send pilot request"}</button>

        {submissionError ? (
          <section className="form-error-summary pilot-submit-error" role="alert" aria-labelledby="pilot-submit-error-heading">
            <h2 id="pilot-submit-error-heading">We couldn’t send your request.</h2>
            <p>Your request was not completed. Please check the fields and try again.</p>
            {emailDraft ? <a className="button button-outline" href={emailDraft}>Review an email draft</a> : null}
          </section>
        ) : null}
      </form>
    </>
  );
}
