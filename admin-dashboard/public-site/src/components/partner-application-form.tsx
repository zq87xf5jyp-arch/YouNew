"use client";

import Link from "next/link";
import { useEffect, useState, type FormEvent } from "react";
import {
  mailtoPartnerApplicationRepository,
  requiresKvkNumber,
  validateBusinessApplication
} from "@/lib/business/application";
import { advertisingFormatCatalog } from "@/lib/business/catalog";
import type {
  BusinessApplicationInput,
  BusinessApplicationValidation,
  BusinessUserProfileId,
  OrganizationType,
  PreparedBusinessApplication,
  RequestedPlacementId
} from "@/lib/business/types";

const organizationOptions: Array<{ value: OrganizationType; label: string }> = [
  { value: "commercial-business", label: "Commercial business" },
  { value: "sole-trader", label: "Sole trader" },
  { value: "advertising-agency", label: "Advertising agency" },
  { value: "non-profit", label: "Non-profit" },
  { value: "public-organization", label: "Public organization" },
  { value: "education", label: "Education provider" },
  { value: "healthcare", label: "Healthcare provider" },
  { value: "other", label: "Other" }
];

const profileOptions: Array<{ value: BusinessUserProfileId; label: string }> = [
  { value: "tourist", label: "Tourists" },
  { value: "student", label: "Students" },
  { value: "expat", label: "Expats" },
  { value: "refugee", label: "Refugees" },
  { value: "worker", label: "Workers" },
  { value: "resident", label: "Residents" }
];

const provinces = [
  "Drenthe",
  "Flevoland",
  "Friesland",
  "Gelderland",
  "Groningen",
  "Limburg",
  "North Brabant",
  "North Holland",
  "Overijssel",
  "South Holland",
  "Utrecht",
  "Zeeland"
];

type ErrorMap = BusinessApplicationValidation["errors"];

function valuesOf<T extends string>(formData: FormData, name: string): T[] {
  return formData.getAll(name).filter((value): value is string => typeof value === "string") as T[];
}

function valueOf(formData: FormData, name: string): string {
  const value = formData.get(name);
  return typeof value === "string" ? value : "";
}

function applicationFrom(formData: FormData): BusinessApplicationInput {
  return {
    companyName: valueOf(formData, "companyName"),
    contactPerson: valueOf(formData, "contactPerson"),
    email: valueOf(formData, "email"),
    phone: valueOf(formData, "phone"),
    website: valueOf(formData, "website"),
    organizationType: valueOf(formData, "organizationType") as BusinessApplicationInput["organizationType"],
    kvkNumber: valueOf(formData, "kvkNumber"),
    city: valueOf(formData, "city"),
    province: valueOf(formData, "province"),
    targetAudience: valuesOf<BusinessUserProfileId>(formData, "targetAudience"),
    requestedPlacements: valuesOf<RequestedPlacementId>(formData, "requestedPlacements"),
    campaignGoal: valueOf(formData, "campaignGoal"),
    budgetRange: valueOf(formData, "budgetRange") as BusinessApplicationInput["budgetRange"],
    campaignStart: valueOf(formData, "campaignStart"),
    campaignEnd: valueOf(formData, "campaignEnd"),
    description: valueOf(formData, "description"),
    consentToPrivacy: formData.get("consentToPrivacy") === "yes",
    confirmAccuracy: formData.get("confirmAccuracy") === "yes",
    websiteConfirmation: valueOf(formData, "websiteConfirmation")
  };
}

function FieldError({ errors, name }: { errors: ErrorMap; name: keyof BusinessApplicationInput }) {
  const message = errors[name];
  return message ? <p className="form-field-error" id={`${name}-error`}>{message}</p> : null;
}

export function PartnerApplicationForm() {
  const [interactive, setInteractive] = useState(false);
  const [organizationType, setOrganizationType] = useState<BusinessApplicationInput["organizationType"]>("");
  const [errors, setErrors] = useState<ErrorMap>({});
  const [prepared, setPrepared] = useState<PreparedBusinessApplication | null>(null);
  const kvkRequired = requiresKvkNumber(organizationType);

  useEffect(() => setInteractive(true), []);

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setPrepared(null);
    const application = applicationFrom(new FormData(event.currentTarget));
    const validation = validateBusinessApplication(application);
    setErrors(validation.errors);

    if (!validation.valid) {
      requestAnimationFrame(() => document.getElementById("business-form-errors")?.focus());
      return;
    }

    const handoff = await mailtoPartnerApplicationRepository.submit(application);
    setPrepared(handoff);
  };

  return (
    <>
      <noscript>
        <div className="form-delivery-notice">
          <strong>JavaScript is required to prepare the email safely.</strong>
          <p>The form below is disabled and no details have been sent. Email support@younew.nl directly instead.</p>
        </div>
      </noscript>
      <form className="business-application-form" action="/business/apply/" method="post" onSubmit={handleSubmit} onInput={() => { if (prepared) setPrepared(null); if (Object.keys(errors).length) setErrors({}); }} noValidate inert={interactive ? undefined : true}>
      {Object.keys(errors).length ? (
        <div className="form-error-summary" id="business-form-errors" role="alert" tabIndex={-1}>
          <h2>Review the highlighted fields</h2>
          <p>The inquiry cannot be prepared until the required details are complete.</p>
          {errors.form ? <p>{errors.form}</p> : null}
        </div>
      ) : null}

      <fieldset className="form-section">
        <legend>Organization and contact</legend>
        <div className="form-grid">
          <div className="form-field">
            <label htmlFor="companyName">Company or organization name</label>
            <input id="companyName" name="companyName" maxLength={120} autoComplete="organization" aria-describedby={errors.companyName ? "companyName-error" : undefined} aria-invalid={Boolean(errors.companyName)} required />
            <FieldError errors={errors} name="companyName" />
          </div>
          <div className="form-field">
            <label htmlFor="contactPerson">Contact person</label>
            <input id="contactPerson" name="contactPerson" maxLength={120} autoComplete="name" aria-describedby={errors.contactPerson ? "contactPerson-error" : undefined} aria-invalid={Boolean(errors.contactPerson)} required />
            <FieldError errors={errors} name="contactPerson" />
          </div>
          <div className="form-field">
            <label htmlFor="email">Email</label>
            <input id="email" name="email" type="email" maxLength={254} autoComplete="email" aria-describedby={errors.email ? "email-error" : undefined} aria-invalid={Boolean(errors.email)} required />
            <FieldError errors={errors} name="email" />
          </div>
          <div className="form-field">
            <label htmlFor="phone">Phone <span>(optional)</span></label>
            <input id="phone" name="phone" type="tel" maxLength={40} autoComplete="tel" aria-describedby={errors.phone ? "phone-error" : undefined} aria-invalid={Boolean(errors.phone)} />
            <FieldError errors={errors} name="phone" />
          </div>
          <div className="form-field">
            <label htmlFor="website">Website</label>
            <input id="website" name="website" type="url" maxLength={300} inputMode="url" placeholder="https://example.nl" autoComplete="url" aria-describedby={errors.website ? "website-error" : undefined} aria-invalid={Boolean(errors.website)} required />
            <FieldError errors={errors} name="website" />
          </div>
          <div className="form-field">
            <label htmlFor="organizationType">Organization type</label>
            <select
              id="organizationType"
              name="organizationType"
              value={organizationType}
              onChange={(event) => setOrganizationType(event.target.value as BusinessApplicationInput["organizationType"])}
              aria-describedby={errors.organizationType ? "organizationType-error" : undefined}
              aria-invalid={Boolean(errors.organizationType)}
              required
            >
              <option value="">Select a type</option>
              {organizationOptions.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}
            </select>
            <FieldError errors={errors} name="organizationType" />
          </div>
          <div className="form-field">
            <label htmlFor="kvkNumber">KvK number {kvkRequired ? <span>(required)</span> : <span>(optional)</span>}</label>
            <input id="kvkNumber" name="kvkNumber" inputMode="numeric" autoComplete="off" aria-describedby={`kvk-help${errors.kvkNumber ? " kvkNumber-error" : ""}`} aria-invalid={Boolean(errors.kvkNumber)} required={kvkRequired} />
            <p className="form-field-help" id="kvk-help">Required for commercial businesses, sole traders and advertising agencies. Use 8 digits.</p>
            <FieldError errors={errors} name="kvkNumber" />
          </div>
        </div>
      </fieldset>

      <fieldset className="form-section">
        <legend>Location and audience</legend>
        <div className="form-grid">
          <div className="form-field">
            <label htmlFor="city">Primary city</label>
            <input id="city" name="city" maxLength={100} autoComplete="address-level2" aria-describedby={errors.city ? "city-error" : undefined} aria-invalid={Boolean(errors.city)} required />
            <FieldError errors={errors} name="city" />
          </div>
          <div className="form-field">
            <label htmlFor="province">Province</label>
            <select id="province" name="province" autoComplete="address-level1" aria-describedby={errors.province ? "province-error" : undefined} aria-invalid={Boolean(errors.province)} required>
              <option value="">Select a province</option>
              {provinces.map((province) => <option value={province} key={province}>{province}</option>)}
            </select>
            <FieldError errors={errors} name="province" />
          </div>
        </div>
        <fieldset className="form-choice-group" aria-describedby={errors.targetAudience ? "targetAudience-error" : undefined}>
          <legend>Target audience</legend>
          <div className="form-checkbox-grid">
            {profileOptions.map((option) => (
              <label key={option.value}><input type="checkbox" name="targetAudience" value={option.value} /> {option.label}</label>
            ))}
          </div>
          <FieldError errors={errors} name="targetAudience" />
        </fieldset>
      </fieldset>

      <fieldset className="form-section">
        <legend>Placement request</legend>
        <fieldset className="form-choice-group" aria-describedby={errors.requestedPlacements ? "requestedPlacements-error" : undefined}>
          <legend>Requested placement</legend>
          <div className="form-checkbox-grid">
            {advertisingFormatCatalog.map((option) => (
              <label key={option.id}><input type="checkbox" name="requestedPlacements" value={option.id} /> {option.title}</label>
            ))}
          </div>
          <FieldError errors={errors} name="requestedPlacements" />
        </fieldset>
        <div className="form-field">
          <label htmlFor="campaignGoal">Campaign goal</label>
          <textarea id="campaignGoal" name="campaignGoal" rows={3} maxLength={240} aria-describedby={errors.campaignGoal ? "campaignGoal-error" : undefined} aria-invalid={Boolean(errors.campaignGoal)} required />
          <FieldError errors={errors} name="campaignGoal" />
        </div>
        <div className="form-grid">
          <div className="form-field">
            <label htmlFor="budgetRange">Budget range</label>
            <select id="budgetRange" name="budgetRange" aria-describedby={errors.budgetRange ? "budgetRange-error" : undefined} aria-invalid={Boolean(errors.budgetRange)} required>
              <option value="">Select a range</option>
              <option value="under-1000">Under €1,000</option>
              <option value="1000-3000">€1,000–€3,000</option>
              <option value="3000-10000">€3,000–€10,000</option>
              <option value="over-10000">Over €10,000</option>
              <option value="request-discussion">Prefer to discuss</option>
            </select>
            <FieldError errors={errors} name="budgetRange" />
          </div>
          <div className="form-field form-date-range">
            <span className="form-label">Campaign dates <span>(optional)</span></span>
            <div>
              <label htmlFor="campaignStart">Start</label>
              <input id="campaignStart" name="campaignStart" type="date" />
              <label htmlFor="campaignEnd">End</label>
              <input id="campaignEnd" name="campaignEnd" type="date" aria-describedby={errors.campaignEnd ? "campaignEnd-error" : undefined} aria-invalid={Boolean(errors.campaignEnd)} />
            </div>
            <FieldError errors={errors} name="campaignEnd" />
          </div>
        </div>
        <div className="form-field">
          <label htmlFor="description">Description</label>
          <textarea id="description" name="description" rows={7} maxLength={600} placeholder="Tell us about the organization, intended audience and proposed placement." aria-describedby={`description-help${errors.description ? " description-error" : ""}`} aria-invalid={Boolean(errors.description)} required />
          <p className="form-field-help" id="description-help">30–600 characters. The shorter limit keeps the email handoff compatible with common mail clients. Do not include sensitive personal information.</p>
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
          <input type="checkbox" name="consentToPrivacy" value="yes" aria-describedby={errors.consentToPrivacy ? "consentToPrivacy-error" : undefined} />
          I consent to the processing described in the <Link href="/privacy">Privacy Policy</Link> for the purpose of responding to this inquiry.
        </label>
        <FieldError errors={errors} name="consentToPrivacy" />
        <label>
          <input type="checkbox" name="confirmAccuracy" value="yes" aria-describedby={errors.confirmAccuracy ? "confirmAccuracy-error" : undefined} />
          I confirm that the information provided is accurate and that I am authorized to make this inquiry.
        </label>
        <FieldError errors={errors} name="confirmAccuracy" />
      </fieldset>

      <div className="form-delivery-notice">
        <strong>Email handoff only</strong>
        <p>This website does not upload or submit this form to a server. After validation, it prepares an email draft for support@younew.nl. You decide whether to send it in your email application.</p>
      </div>

      <button className="button button-primary" type="submit" disabled={!interactive}>Review and prepare email</button>

      {prepared ? (
        <section className="form-prepared-state" aria-live="polite" aria-labelledby="prepared-heading">
          <h2 id="prepared-heading">{prepared.notice}</h2>
          <p>Your information has only been used to prepare a local email draft. Open the draft, review it, and send it from your email application if you wish to continue.</p>
          <a className="button button-outline" href={prepared.href}>Open prefilled email draft</a>
          <p>If the link does not work, email <a href={`mailto:${prepared.recipient}`}>{prepared.recipient}</a> directly.</p>
        </section>
      ) : null}
      </form>
    </>
  );
}
