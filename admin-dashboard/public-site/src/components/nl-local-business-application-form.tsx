"use client";

import Link from "next/link";
import { FormEvent, useRef, useState } from "react";
import siteConfig from "@/config/site-config.json";
import { track } from "@/lib/analytics/client";
import { createApiPartnerApplicationRepository, mailtoPartnerApplicationRepository, requiresKvkNumber, validateBusinessApplication } from "@/lib/business/application";
import type { BusinessApplicationInput, BusinessApplicationResult, BusinessUserProfileId, OrganizationType } from "@/lib/business/types";

const organizationOptions: ReadonlyArray<{ value: OrganizationType; label: string }> = [
  { value: "commercial-business", label: "Bedrijf" }, { value: "sole-trader", label: "Eenmanszaak / zzp" },
  { value: "non-profit", label: "Stichting of vereniging" }, { value: "public-organization", label: "Publieke organisatie" },
  { value: "education", label: "Onderwijs" }, { value: "healthcare", label: "Zorg" }, { value: "other", label: "Anders" }
];
const audiences: ReadonlyArray<{ value: BusinessUserProfileId; label: string }> = [
  { value: "resident", label: "Nieuwe inwoners" }, { value: "expat", label: "Internationals" }, { value: "student", label: "Studenten" },
  { value: "worker", label: "Werknemers" }, { value: "tourist", label: "Bezoekers" }, { value: "refugee", label: "Vluchtelingen" }
];
const futureInterestOptions = [
  { value: "profile-insights", label: "Inzicht in profielweergaven en doorverwijzingen" },
  { value: "richer-profile", label: "Meer gecontroleerde profielinformatie en media" },
  { value: "sponsored-placement", label: "Een duidelijk gemarkeerde gesponsorde positie" }
] as const;

function text(data: FormData, key: string) { const value = data.get(key); return typeof value === "string" ? value : ""; }
function list<T extends string>(data: FormData, key: string) { return data.getAll(key).filter((value): value is string => typeof value === "string") as T[]; }

export function NlLocalBusinessApplicationForm({ municipalities, provinces }: { municipalities: readonly string[]; provinces: readonly string[] }) {
  const [organizationType, setOrganizationType] = useState<BusinessApplicationInput["organizationType"]>("");
  const [errors, setErrors] = useState<Partial<Record<keyof BusinessApplicationInput | "form", string>>>({});
  const [result, setResult] = useState<BusinessApplicationResult | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [submissionError, setSubmissionError] = useState("");
  const started = useRef(false);
  const repository = createApiPartnerApplicationRepository(siteConfig.businessInquiry.endpoint);

  function application(data: FormData): BusinessApplicationInput {
    const action = text(data, "listingAction");
    const businessInterest = data.get("businessPremiumInterest") === "yes";
    const interestFeatures = list<string>(data, "futureInterestFeature")
      .filter((value) => futureInterestOptions.some((option) => option.value === value));
    const actionGoal = action === "claim" ? "Request to claim an existing business profile." : action === "add" ? "Request to add a new business profile." : "";
    const interestGoal = businessInterest
      ? ` Non-binding future Business/Premium interest: ${interestFeatures.length ? interestFeatures.join(", ") : "general research"}.`
      : "";
    const current = new URL(window.location.href);
    return {
      companyName: text(data, "companyName"), contactPerson: text(data, "contactPerson"), contactRole: text(data, "contactRole"),
      offerInterest: businessInterest ? "other" : "founding_partner_page", email: text(data, "email"), phone: text(data, "phone"), website: text(data, "website"),
      inquiryType: "partnership", organizationType: text(data, "organizationType") as BusinessApplicationInput["organizationType"], kvkNumber: text(data, "kvkNumber"),
      city: text(data, "city"), province: text(data, "province"), targetAudience: list<BusinessUserProfileId>(data, "targetAudience"),
      requestedPlacements: ["verified-organization-profile"], campaignGoal: `${actionGoal}${interestGoal}`,
      budgetRange: "request-discussion", campaignStart: "", campaignEnd: "", description: text(data, "description"),
      consentToPrivacy: data.get("consentToPrivacy") === "yes", confirmAccuracy: data.get("confirmAccuracy") === "yes", websiteConfirmation: text(data, "websiteConfirmation"),
      sourcePage: "/nl/voor-bedrijven/aanmelden/", utmSource: current.searchParams.get("utm_source")?.slice(0, 120) ?? "", utmMedium: current.searchParams.get("utm_medium")?.slice(0, 120) ?? "", utmCampaign: current.searchParams.get("utm_campaign")?.slice(0, 160) ?? "", utmContent: current.searchParams.get("utm_content")?.slice(0, 160) ?? "", utmTerm: current.searchParams.get("utm_term")?.slice(0, 160) ?? ""
    };
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); setResult(null); setSubmissionError("");
    const input = application(new FormData(event.currentTarget));
    const validation = validateBusinessApplication(input); setErrors(validation.errors);
    if (!validation.valid) { requestAnimationFrame(() => document.getElementById("nl-business-errors")?.focus()); return; }
    setSubmitting(true);
    try { const receipt = await repository.submit(input); setResult(receipt); track({ name: "lead_submit" }); }
    catch (error) { setSubmissionError(error instanceof Error ? error.message : "De aanvraag kon niet worden opgeslagen."); const handoff = await mailtoPartnerApplicationRepository.submit(input); setResult(handoff); track({ name: "business_mailto_prepared", organizationType: input.organizationType }); }
    finally { setSubmitting(false); }
  }

  const errorFor = (key: keyof BusinessApplicationInput | "form") => errors[key] ? <p className="form-field-error">Controleer dit veld.</p> : null;
  return <form className="business-application-form" action="/nl/voor-bedrijven/aanmelden/" method="post" onSubmit={submit} onInput={(event) => { const target = event.target as HTMLInputElement; if (target.name !== "websiteConfirmation" && !started.current) { started.current = true; track({ name: "lead_start" }); } }} noValidate>
    {Object.keys(errors).length ? <div className="form-error-summary" id="nl-business-errors" role="alert" tabIndex={-1}><h2>Controleer de gemarkeerde velden</h2><p>De aanvraag wordt pas verstuurd als de verplichte gegevens compleet zijn.</p></div> : null}
    <fieldset className="form-section form-choice-group"><legend>Wat wil je doen?</legend><div className="form-checkbox-grid local-business-action-grid"><label><input type="radio" name="listingAction" value="add" required /> Een nieuw bedrijfsprofiel toevoegen</label><label><input type="radio" name="listingAction" value="claim" required /> Een bestaand profiel claimen</label></div>{errorFor("campaignGoal")}</fieldset>
    <fieldset className="form-section"><legend>Organisatie en contact</legend><div className="form-grid">
      <div className="form-field"><label htmlFor="nl-company">Naam organisatie</label><input id="nl-company" name="companyName" maxLength={120} autoComplete="organization" required />{errorFor("companyName")}</div>
      <div className="form-field"><label htmlFor="nl-type">Type organisatie</label><select id="nl-type" name="organizationType" value={organizationType} onChange={(event) => setOrganizationType(event.target.value as BusinessApplicationInput["organizationType"])} required><option value="">Kies een type</option>{organizationOptions.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}</select>{errorFor("organizationType")}</div>
      <div className="form-field"><label htmlFor="nl-contact">Bevoegde contactpersoon</label><input id="nl-contact" name="contactPerson" maxLength={120} autoComplete="name" required />{errorFor("contactPerson")}</div>
      <div className="form-field"><label htmlFor="nl-role">Functie <span>(optioneel)</span></label><input id="nl-role" name="contactRole" maxLength={120} autoComplete="organization-title" /></div>
      <div className="form-field"><label htmlFor="nl-email">Zakelijk e-mailadres</label><input id="nl-email" name="email" type="email" maxLength={254} autoComplete="email" required />{errorFor("email")}</div>
      <div className="form-field"><label htmlFor="nl-phone">Telefoon <span>(optioneel)</span></label><input id="nl-phone" name="phone" type="tel" maxLength={40} autoComplete="tel" />{errorFor("phone")}</div>
      <div className="form-field"><label htmlFor="nl-website">Officiële website</label><input id="nl-website" name="website" type="url" maxLength={300} placeholder="https://voorbeeld.nl" autoComplete="url" required />{errorFor("website")}</div>
      <div className="form-field"><label htmlFor="nl-kvk">KvK-nummer {requiresKvkNumber(organizationType) ? "(verplicht)" : "(optioneel)"}</label><input id="nl-kvk" name="kvkNumber" inputMode="numeric" maxLength={8} required={requiresKvkNumber(organizationType)} /><p className="form-field-help">Acht cijfers voor bedrijven en eenmanszaken.</p>{errorFor("kvkNumber")}</div>
    </div></fieldset>
    <fieldset className="form-section"><legend>Locatie en doelgroep</legend><div className="form-grid"><div className="form-field"><label htmlFor="nl-city">Gemeente of stad</label><input id="nl-city" name="city" list="nl-municipalities" maxLength={100} autoComplete="address-level2" required /><datalist id="nl-municipalities">{municipalities.map((name) => <option value={name} key={name} />)}</datalist>{errorFor("city")}</div><div className="form-field"><label htmlFor="nl-province">Provincie</label><select id="nl-province" name="province" required><option value="">Kies een provincie</option>{provinces.map((name) => <option value={name} key={name}>{name}</option>)}</select>{errorFor("province")}</div></div><fieldset className="form-choice-group"><legend>Wie help je vooral?</legend><div className="form-checkbox-grid">{audiences.map((item) => <label key={item.value}><input type="checkbox" name="targetAudience" value={item.value} /> {item.label}</label>)}</div>{errorFor("targetAudience")}</fieldset></fieldset>
    <fieldset className="form-section"><legend>Profielinformatie</legend><div className="form-field"><label htmlFor="nl-description">Wat moet YouNew controleren?</label><textarea id="nl-description" name="description" rows={5} maxLength={600} placeholder="Beschrijf diensten, locatie en openbare feiten. Voeg bij een claim de huidige YouNew-link toe. Deel geen gevoelige persoonsgegevens." required /><p className="form-field-help">30–600 tekens.</p>{errorFor("description")}</div></fieldset>
    <fieldset className="form-section form-choice-group"><legend>Vrijblijvende Business/Premium-interesse <span>(optioneel)</span></legend><p className="form-field-help">Deze functies zijn nog niet beschikbaar. Je keuze is alleen marktonderzoek: geen bestelling, prijsafspraak of toezegging.</p><label><input type="checkbox" name="businessPremiumInterest" value="yes" /> Ik wil vrijblijvend benaderd kunnen worden voor onderzoek naar een toekomstig zakelijk pakket.</label><div className="form-checkbox-grid">{futureInterestOptions.map((option) => <label key={option.value}><input type="checkbox" name="futureInterestFeature" value={option.value} /> {option.label}</label>)}</div></fieldset>
    <div className="form-honeypot" aria-hidden="true" hidden><label htmlFor="nl-confirmation">Laat dit veld leeg</label><input id="nl-confirmation" name="websiteConfirmation" tabIndex={-1} autoComplete="off" /></div>
    <fieldset className="form-section form-confirmations"><legend>Bevestigingen</legend><label><input type="checkbox" name="consentToPrivacy" value="yes" /> Ik ga akkoord met de verwerking volgens het <Link href="/privacy/">privacybeleid</Link>, zodat YouNew deze aanvraag kan beoordelen en beantwoorden.</label>{errorFor("consentToPrivacy")}<label><input type="checkbox" name="confirmAccuracy" value="yes" /> Ik bevestig dat de informatie klopt en dat ik de organisatie mag vertegenwoordigen.</label>{errorFor("confirmAccuracy")}</fieldset>
    <div className="form-delivery-notice"><strong>Eerst beoordelen, niet automatisch publiceren</strong><p>Deze aanvraag publiceert niets, bevestigt geen eigendom en start geen betaald abonnement.</p></div>
    <button className="button button-primary" type="submit" disabled={submitting}>{submitting ? "Aanvraag opslaan…" : "Gratis profielcontrole aanvragen"}</button>
    {submissionError ? <section className="form-error-summary" role="alert"><h2>De aanvraag is niet opgeslagen</h2><p>{submissionError}</p>{result?.kind === "user-email-handoff" ? <a className="button button-outline" href={result.href}>Bekijk e-mailconcept</a> : null}</section> : null}
    {result?.kind === "server-submission" ? <section className="form-prepared-state" aria-live="polite"><h2>Aanvraag opgeslagen</h2><p>Je bevestigingsnummer is <strong>{result.confirmationId}</strong>.</p><p>YouNew controleert de organisatie en openbare claims vóór publicatie.</p></section> : null}
  </form>;
}
