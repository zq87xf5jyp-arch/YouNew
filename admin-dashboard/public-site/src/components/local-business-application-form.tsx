"use client";

import Link from "next/link";
import { useEffect, useRef, useState, type FormEvent } from "react";
import {
  createApiPartnerApplicationRepository,
  mailtoPartnerApplicationRepository,
  requiresKvkNumber,
  validateBusinessApplication
} from "@/lib/business/application";
import siteConfig from "@/config/site-config.json";
import type {
  BusinessApplicationInput,
  BusinessApplicationResult,
  BusinessApplicationValidation,
  BusinessUserProfileId,
  OrganizationType
} from "@/lib/business/types";
import { track } from "@/lib/analytics/client";

const organizationOptions: ReadonlyArray<{ value: OrganizationType; label: string }> = [
  { value: "commercial-business", label: "Commercial business" },
  { value: "sole-trader", label: "Sole trader" },
  { value: "non-profit", label: "Non-profit" },
  { value: "public-organization", label: "Public organization" },
  { value: "education", label: "Education provider" },
  { value: "healthcare", label: "Healthcare provider" },
  { value: "other", label: "Other" }
];

const audienceOptions: ReadonlyArray<{ value: BusinessUserProfileId; label: string }> = [
  { value: "tourist", label: "Tourists" },
  { value: "student", label: "Students" },
  { value: "expat", label: "Expats" },
  { value: "worker", label: "Workers" },
  { value: "resident", label: "New residents" },
  { value: "refugee", label: "Refugees" }
];

type ErrorMap = BusinessApplicationValidation["errors"];

function valueOf(formData: FormData, name: string): string {
  const value = formData.get(name);
  return typeof value === "string" ? value : "";
}

function valuesOf<T extends string>(formData: FormData, name: string): T[] {
  return formData.getAll(name).filter((value): value is string => typeof value === "string") as T[];
}

function listingGoal(value: string) {
  if (value === "add") return "Request to add a new business profile.";
  if (value === "claim") return "Request to claim an existing business profile.";
  return "";
}

function applicationFrom(formData: FormData): BusinessApplicationInput {
  const currentUrl = new URL(window.location.href);
  return {
    companyName: valueOf(formData, "companyName"),
    contactPerson: valueOf(formData, "contactPerson"),
    contactRole: valueOf(formData, "contactRole"),
    offerInterest: "founding_partner_page",
    email: valueOf(formData, "email"),
    phone: valueOf(formData, "phone"),
    website: valueOf(formData, "website"),
    inquiryType: "partnership",
    organizationType: valueOf(formData, "organizationType") as BusinessApplicationInput["organizationType"],
    kvkNumber: valueOf(formData, "kvkNumber"),
    city: valueOf(formData, "city"),
    province: valueOf(formData, "province"),
    targetAudience: valuesOf<BusinessUserProfileId>(formData, "targetAudience"),
    requestedPlacements: ["verified-organization-profile"],
    campaignGoal: listingGoal(valueOf(formData, "listingAction")),
    budgetRange: "request-discussion",
    campaignStart: "",
    campaignEnd: "",
    description: valueOf(formData, "description"),
    consentToPrivacy: formData.get("consentToPrivacy") === "yes",
    confirmAccuracy: formData.get("confirmAccuracy") === "yes",
    websiteConfirmation: valueOf(formData, "websiteConfirmation"),
    sourcePage: "/for-business/local/apply/",
    utmSource: currentUrl.searchParams.get("utm_source")?.slice(0, 120) ?? "",
    utmMedium: currentUrl.searchParams.get("utm_medium")?.slice(0, 120) ?? "",
    utmCampaign: currentUrl.searchParams.get("utm_campaign")?.slice(0, 160) ?? "",
    utmContent: currentUrl.searchParams.get("utm_content")?.slice(0, 160) ?? "",
    utmTerm: currentUrl.searchParams.get("utm_term")?.slice(0, 160) ?? ""
  };
}

function FieldError({ errors, name }: { errors: ErrorMap; name: keyof BusinessApplicationInput }) {
  const message = errors[name];
  if (!message) return null;
  const localMessage = name === "campaignGoal" ? "Choose whether you want to add or claim a business profile." : message;
  return <p className="form-field-error" id={`local-${name}-error`}>{localMessage}</p>;
}

export function LocalBusinessApplicationForm({
  municipalities,
  provinces
}: {
  municipalities: readonly string[];
  provinces: readonly string[];
}) {
  const [interactive, setInteractive] = useState(false);
  const [organizationType, setOrganizationType] = useState<BusinessApplicationInput["organizationType"]>("");
  const [errors, setErrors] = useState<ErrorMap>({});
  const [result, setResult] = useState<BusinessApplicationResult | null>(null);
  const [submissionError, setSubmissionError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const leadStarted = useRef(false);
  const kvkRequired = requiresKvkNumber(organizationType);
  const repository = createApiPartnerApplicationRepository(siteConfig.businessInquiry.endpoint);

  useEffect(() => setInteractive(true), []);

  const handleInput = (event: FormEvent<HTMLFormElement>) => {
    if (result) setResult(null);
    if (submissionError) setSubmissionError("");
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
    setResult(null);
    setSubmissionError("");
    const application = applicationFrom(new FormData(event.currentTarget));
    const validation = validateBusinessApplication(application);
    setErrors(validation.errors);

    if (!validation.valid) {
      requestAnimationFrame(() => document.getElementById("local-business-form-errors")?.focus());
      return;
    }

    setSubmitting(true);
    try {
      const submission = await repository.submit(application);
      setResult(submission);
      track({ name: "lead_submit" });
    } catch (error) {
      setSubmissionError(error instanceof Error
        ? error.message
        : "The request was not saved. Your entries are still available; please retry.");
      const handoff = await mailtoPartnerApplicationRepository.submit(application);
      setResult(handoff);
      track({ name: "business_mailto_prepared", organizationType: application.organizationType });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <>
      <noscript>
        <div className="form-delivery-notice">
          <strong>JavaScript is required to submit this request securely.</strong>
          <p>No details have been sent. Email support@younew.nl directly instead.</p>
        </div>
      </noscript>
      <form className="business-application-form" action="/for-business/local/apply/" method="post" onSubmit={handleSubmit} onInput={handleInput} noValidate inert={interactive ? undefined : true}>
        {Object.keys(errors).length ? (
          <div className="form-error-summary" id="local-business-form-errors" role="alert" tabIndex={-1}>
            <h2>Review the highlighted fields</h2>
            <p>The request cannot be submitted until the required details are complete.</p>
            {errors.form ? <p>{errors.form}</p> : null}
          </div>
        ) : null}

        <fieldset className="form-section form-choice-group" aria-describedby={errors.campaignGoal ? "local-campaignGoal-error" : undefined}>
          <legend>What do you want to do?</legend>
          <div className="form-checkbox-grid local-business-action-grid">
            <label><input type="radio" name="listingAction" value="add" required /> Add a new business profile</label>
            <label><input type="radio" name="listingAction" value="claim" required /> Claim an existing YouNew profile</label>
          </div>
          <FieldError errors={errors} name="campaignGoal" />
        </fieldset>

        <fieldset className="form-section">
          <legend>Organization and contact</legend>
          <div className="form-grid">
            <div className="form-field">
              <label htmlFor="local-companyName">Company or organization name</label>
              <input id="local-companyName" name="companyName" maxLength={120} autoComplete="organization" aria-describedby={errors.companyName ? "local-companyName-error" : undefined} aria-invalid={Boolean(errors.companyName)} required />
              <FieldError errors={errors} name="companyName" />
            </div>
            <div className="form-field">
              <label htmlFor="local-organizationType">Organization type</label>
              <select id="local-organizationType" name="organizationType" value={organizationType} onChange={(event) => setOrganizationType(event.target.value as BusinessApplicationInput["organizationType"])} aria-describedby={errors.organizationType ? "local-organizationType-error" : undefined} aria-invalid={Boolean(errors.organizationType)} required>
                <option value="">Select a type</option>
                {organizationOptions.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}
              </select>
              <FieldError errors={errors} name="organizationType" />
            </div>
            <div className="form-field">
              <label htmlFor="local-contactPerson">Authorized contact</label>
              <input id="local-contactPerson" name="contactPerson" maxLength={120} autoComplete="name" aria-describedby={errors.contactPerson ? "local-contactPerson-error" : undefined} aria-invalid={Boolean(errors.contactPerson)} required />
              <FieldError errors={errors} name="contactPerson" />
            </div>
            <div className="form-field">
              <label htmlFor="local-contactRole">Role <span>(optional)</span></label>
              <input id="local-contactRole" name="contactRole" maxLength={120} autoComplete="organization-title" aria-describedby={errors.contactRole ? "local-contactRole-error" : undefined} aria-invalid={Boolean(errors.contactRole)} />
              <FieldError errors={errors} name="contactRole" />
            </div>
            <div className="form-field">
              <label htmlFor="local-email">Business email</label>
              <input id="local-email" name="email" type="email" maxLength={254} autoComplete="email" aria-describedby={errors.email ? "local-email-error" : undefined} aria-invalid={Boolean(errors.email)} required />
              <FieldError errors={errors} name="email" />
            </div>
            <div className="form-field">
              <label htmlFor="local-phone">Phone <span>(optional)</span></label>
              <input id="local-phone" name="phone" type="tel" maxLength={40} autoComplete="tel" aria-describedby={errors.phone ? "local-phone-error" : undefined} aria-invalid={Boolean(errors.phone)} />
              <FieldError errors={errors} name="phone" />
            </div>
            <div className="form-field">
              <label htmlFor="local-website">Official website</label>
              <input id="local-website" name="website" type="url" maxLength={300} inputMode="url" placeholder="https://example.nl" autoComplete="url" aria-describedby={errors.website ? "local-website-error" : undefined} aria-invalid={Boolean(errors.website)} required />
              <FieldError errors={errors} name="website" />
            </div>
            <div className="form-field">
              <label htmlFor="local-kvkNumber">KvK number {kvkRequired ? <span>(required)</span> : <span>(optional)</span>}</label>
              <input id="local-kvkNumber" name="kvkNumber" inputMode="numeric" maxLength={8} autoComplete="off" aria-describedby={`local-kvk-help${errors.kvkNumber ? " local-kvkNumber-error" : ""}`} aria-invalid={Boolean(errors.kvkNumber)} required={kvkRequired} />
              <p className="form-field-help" id="local-kvk-help">Required for commercial businesses and sole traders. Use 8 digits.</p>
              <FieldError errors={errors} name="kvkNumber" />
            </div>
          </div>
        </fieldset>

        <fieldset className="form-section">
          <legend>Location and audience</legend>
          <div className="form-grid">
            <div className="form-field">
              <label htmlFor="local-city">Primary municipality or city</label>
              <input id="local-city" name="city" list="local-municipality-options" maxLength={100} autoComplete="address-level2" aria-describedby={errors.city ? "local-city-error" : undefined} aria-invalid={Boolean(errors.city)} required />
              <datalist id="local-municipality-options">{municipalities.map((municipality) => <option value={municipality} key={municipality} />)}</datalist>
              <FieldError errors={errors} name="city" />
            </div>
            <div className="form-field">
              <label htmlFor="local-province">Province</label>
              <select id="local-province" name="province" autoComplete="address-level1" aria-describedby={errors.province ? "local-province-error" : undefined} aria-invalid={Boolean(errors.province)} required>
                <option value="">Select a province</option>
                {provinces.map((province) => <option value={province} key={province}>{province}</option>)}
              </select>
              <FieldError errors={errors} name="province" />
            </div>
          </div>
          <fieldset className="form-choice-group" aria-describedby={errors.targetAudience ? "local-targetAudience-error" : undefined}>
            <legend>Who do you mainly help?</legend>
            <div className="form-checkbox-grid">
              {audienceOptions.map((option) => <label key={option.value}><input type="checkbox" name="targetAudience" value={option.value} /> {option.label}</label>)}
            </div>
            <FieldError errors={errors} name="targetAudience" />
          </fieldset>
        </fieldset>

        <fieldset className="form-section">
          <legend>Profile context</legend>
          <div className="form-field">
            <label htmlFor="local-description">What should we verify?</label>
            <textarea id="local-description" name="description" rows={6} maxLength={600} placeholder="Describe the services, location and public facts that should appear. For a claim, include the current YouNew page URL. Do not include sensitive personal information." aria-describedby={`local-description-help${errors.description ? " local-description-error" : ""}`} aria-invalid={Boolean(errors.description)} required />
            <p className="form-field-help" id="local-description-help">30–600 characters. YouNew checks identity, public claims and source links before publication.</p>
            <FieldError errors={errors} name="description" />
          </div>
        </fieldset>

        <div className="form-honeypot" aria-hidden="true" hidden>
          <label htmlFor="local-websiteConfirmation">Leave this field empty</label>
          <input id="local-websiteConfirmation" name="websiteConfirmation" tabIndex={-1} autoComplete="off" />
        </div>

        <fieldset className="form-section form-confirmations">
          <legend>Confirmations</legend>
          <label><input type="checkbox" name="consentToPrivacy" value="yes" aria-describedby={errors.consentToPrivacy ? "local-consentToPrivacy-error" : undefined} /> I consent to the processing described in the <Link href="/privacy/">Privacy Policy</Link> so YouNew can review and respond to this request.</label>
          <FieldError errors={errors} name="consentToPrivacy" />
          <label><input type="checkbox" name="confirmAccuracy" value="yes" aria-describedby={errors.confirmAccuracy ? "local-confirmAccuracy-error" : undefined} /> I confirm that the information is accurate and that I am authorized to represent this organization.</label>
          <FieldError errors={errors} name="confirmAccuracy" />
        </fieldset>

        <div className="form-delivery-notice">
          <strong>Review first, no automatic publication</strong>
          <p>Submitting creates a review request only. It does not publish a profile, verify ownership, start a paid plan or create a contract.</p>
        </div>

        <button className="button button-primary" type="submit" disabled={!interactive || submitting}>{submitting ? "Saving request…" : "Submit profile request"}</button>

        {submissionError ? (
          <section className="form-error-summary" role="alert">
            <h2>The request was not saved</h2>
            <p>{submissionError}</p>
            {result?.kind === "user-email-handoff" ? <><p>You may retry or review an email draft. Opening the draft does not send it.</p><a className="button button-outline" href={result.href}>Review email draft</a></> : null}
          </section>
        ) : null}

        {result?.kind === "server-submission" ? (
          <section className="form-prepared-state" aria-live="polite" aria-labelledby="local-request-saved">
            <h2 id="local-request-saved">Profile request saved</h2>
            <p>Your confirmation ID is <strong>{result.confirmationId}</strong>. Keep it if you contact support.</p>
            <p>YouNew will review the organization and public claims. Submission does not guarantee publication or ownership confirmation.</p>
          </section>
        ) : null}
      </form>
    </>
  );
}
