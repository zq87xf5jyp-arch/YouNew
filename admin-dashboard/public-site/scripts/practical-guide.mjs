const statuses = new Set(["draft", "qa", "review", "published", "archived"]);
const audiences = new Set(["tourist", "student", "expat", "refugee", "worker", "resident"]);
const jurisdictionLevels = new Set(["national", "provincial", "municipal", "mixed"]);
const locales = new Set(["en", "nl", "ru", "uk", "pl"]);
const difficulties = new Set(["basic", "intermediate", "advanced"]);
const estimateStates = new Set(["unknown", "not_applicable", "varies", "known"]);
const contactKinds = new Set(["phone", "email", "url", "in_person", "other"]);
const dateOnly = /^\d{4}-\d{2}-\d{2}$/;
const slugPattern = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const publicAssetPattern = /^\/images\/[A-Za-z0-9](?:[A-Za-z0-9._/-]*[A-Za-z0-9])?\.(?:avif|gif|jpe?g|png|svg|webp)$/i;
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const phonePattern = /^\+?[0-9][0-9 .()/-]{4,30}$/;

function failure(context, message) {
  throw new Error(`Published practical guide ${context}: ${message}`);
}

function text(value, label, context, minimum = 1, maximum = 5_000) {
  if (typeof value !== "string") failure(context, `${label} is missing`);
  const result = value.normalize("NFC").replace(/[\u0000-\u001F\u007F\u200B-\u200F\u202A-\u202E\u2060-\u206F\uFEFF]/g, "").trim();
  if (result.length < minimum) failure(context, `${label} is missing`);
  if (result.length > maximum) failure(context, `${label} exceeds ${maximum} characters`);
  return result;
}

function stringArray(value, label, context, { minimum = 0, maximum = 40, itemMaximum = 240, allowed } = {}) {
  if (!Array.isArray(value) || value.length < minimum) failure(context, `${label} must contain at least ${minimum} item(s)`);
  if (value.length > maximum) failure(context, `${label} must contain at most ${maximum} item(s)`);
  const result = value.map((item, index) => text(item, `${label}[${index}]`, context, 1, itemMaximum));
  if (new Set(result).size !== result.length) failure(context, `${label} contains duplicate values`);
  if (allowed && result.some((item) => !allowed.has(item))) failure(context, `${label} contains an unsupported value`);
  return result;
}

function isoDate(value, label, context) {
  const result = text(value, label, context);
  const parsed = new Date(`${result}T00:00:00Z`);
  if (!dateOnly.test(result) || Number.isNaN(parsed.valueOf()) || parsed.toISOString().slice(0, 10) !== result) failure(context, `${label} must be an ISO date`);
  return result;
}

function sourcedText(value, label, context, sourceIds) {
  if (!value || typeof value !== "object" || Array.isArray(value)) failure(context, `${label} must be an object`);
  const id = text(value.id, `${label}.id`, context, 1, 160);
  const sourceReferences = stringArray(value.sourceIDs, `${label}.sourceIDs`, context, { minimum: 1, maximum: 12, itemMaximum: 160 });
  for (const sourceId of sourceReferences) if (!sourceIds.has(sourceId)) failure(context, `${label} references unknown source ${sourceId}`);
  return { id, text: text(value.text, `${label}.text`, context, 2, 2_000), sourceIds: sourceReferences };
}

function sourcedTextArray(value, label, context, sourceIds, { minimum = 0, maximum = 20 } = {}) {
  if (!Array.isArray(value)) failure(context, `${label} must be an array`);
  if (value.length < minimum || value.length > maximum) failure(context, `${label} must contain between ${minimum} and ${maximum} items`);
  const result = value.map((item, index) => sourcedText(item, `${label}[${index}]`, context, sourceIds));
  if (new Set(result.map((item) => item.id)).size !== result.length) failure(context, `${label} contains duplicate IDs`);
  return result;
}

function faqArray(value, label, context, sourceIds) {
  if (!Array.isArray(value) || value.length < 3 || value.length > 20) failure(context, `${label} must contain between 3 and 20 items`);
  const result = value.map((item, index) => {
    const itemLabel = `${label}[${index}]`;
    if (!item || typeof item !== "object" || Array.isArray(item)) failure(context, `${itemLabel} must be an object`);
    const sourceReferences = stringArray(item.sourceIDs, `${itemLabel}.sourceIDs`, context, { minimum: 1, maximum: 12, itemMaximum: 160 });
    for (const sourceId of sourceReferences) if (!sourceIds.has(sourceId)) failure(context, `${itemLabel} references unknown source ${sourceId}`);
    return {
      id: text(item.id, `${itemLabel}.id`, context, 1, 160),
      question: text(item.question, `${itemLabel}.question`, context, 4, 240),
      answer: text(item.answer, `${itemLabel}.answer`, context, 10, 3_000),
      sourceIds: sourceReferences
    };
  });
  if (new Set(result.map((item) => item.id)).size !== result.length) failure(context, `${label} contains duplicate IDs`);
  return result;
}

function publicationGate(value, context) {
  if (!value || typeof value !== "object" || Array.isArray(value)) failure(context, "publicationGate is missing");
  if (value.status !== "passed") failure(context, "publicationGate.status must equal passed");
  const checks = value.checks;
  if (!checks || typeof checks !== "object" || Array.isArray(checks)) failure(context, "publicationGate.checks is missing");
  const required = ["schema", "factual_sources", "links", "language", "media", "duplicate_content", "accessibility"];
  if (Object.keys(checks).sort().join("|") !== [...required].sort().join("|")) failure(context, "publicationGate.checks has an unexpected shape");
  if (required.some((key) => checks[key] !== true)) failure(context, "publicationGate requires every check to pass");
  const evidenceIds = stringArray(value.evidenceIDs, "publicationGate.evidenceIDs", context, { minimum: 1, maximum: 20, itemMaximum: 160 });
  return {
    status: "passed",
    checkedAt: isoDate(value.checkedAt, "publicationGate.checkedAt", context),
    checks: Object.fromEntries(required.map((key) => [key, true])),
    notes: text(value.notes, "publicationGate.notes", context, 10, 2_000),
    evidenceIds
  };
}

function estimate(value, label, context, sourceIds, isCost = false) {
  if (!value || typeof value !== "object" || Array.isArray(value)) failure(context, `${label} must be an object`);
  const sourceReferences = stringArray(value.sourceIDs, `${label}.sourceIDs`, context, { minimum: 1, maximum: 12, itemMaximum: 160 });
  for (const sourceId of sourceReferences) if (!sourceIds.has(sourceId)) failure(context, `${label} references unknown source ${sourceId}`);
  const state = text(value.state, `${label}.state`, context, 1, 32);
  if (!estimateStates.has(state)) failure(context, `${label}.state is unsupported`);
  if (state === "known" && (typeof value.value !== "string" || !value.value.trim())) failure(context, `${label}.value is required for a known estimate`);
  if (state !== "known" && value.value != null) failure(context, `${label}.value must be null unless the estimate is known`);
  const note = text(value.note, `${label}.note`, context, 2, 1_000);
  const currency = typeof value.currency === "string" && value.currency.trim() ? text(value.currency, `${label}.currency`, context, 3, 3) : null;
  if (isCost && state === "known" && !/^[A-Z]{3}$/.test(currency ?? "")) failure(context, `${label}.currency is required for a known cost`);
  if (isCost && state !== "known" && currency !== null) failure(context, `${label}.currency must be null unless cost is known`);
  const result = {
    state,
    value: state === "known" ? text(value.value, `${label}.value`, context, 1, 240) : state === "not_applicable" ? "Not applicable" : state === "varies" ? "Varies" : "Not published",
    note,
    sourceIds: sourceReferences
  };
  if (isCost && currency) result.currency = currency;
  return result;
}

function officialSources(value, context) {
  if (!Array.isArray(value) || value.length === 0 || value.length > 20) failure(context, "officialSources must contain between 1 and 20 sources");
  const result = value.map((source, index) => {
    const label = `officialSources[${index}]`;
    if (!source || typeof source !== "object" || Array.isArray(source)) failure(context, `${label} must be an object`);
    if (source.isOfficial !== true || source.status !== "verified_opened") failure(context, `${label} must be official and verified_opened`);
    const urlValue = text(source.url, `${label}.url`, context, 1, 2_048);
    let url;
    try { url = new URL(urlValue); } catch { failure(context, `${label}.url is invalid`); }
    if (url.protocol !== "https:" || url.username || url.password) failure(context, `${label}.url must be a safe HTTPS URL`);
    return {
      id: text(source.id, `${label}.id`, context, 1, 160),
      title: text(source.title, `${label}.title`, context, 2, 300),
      publisher: text(source.publisher, `${label}.publisher`, context, 2, 160),
      url: url.toString(),
      isOfficial: true,
      checkedAt: isoDate(source.checkedAt, `${label}.checkedAt`, context),
      status: "verified_opened"
    };
  });
  if (new Set(result.map((source) => source.id)).size !== result.length) failure(context, "officialSources contains duplicate IDs");
  return result;
}

function steps(value, context, sourceIds) {
  if (!Array.isArray(value) || value.length === 0 || value.length > 25) failure(context, "numberedSteps must contain between 1 and 25 steps");
  const result = value.map((step, index) => {
    const label = `numberedSteps[${index}]`;
    if (!step || typeof step !== "object" || Array.isArray(step)) failure(context, `${label} must be an object`);
    const sourceReferences = stringArray(step.sourceIDs, `${label}.sourceIDs`, context, { minimum: 1, maximum: 12, itemMaximum: 160 });
    for (const sourceId of sourceReferences) if (!sourceIds.has(sourceId)) failure(context, `${label} references unknown source ${sourceId}`);
    if (!Number.isInteger(step.position) || step.position < 1) failure(context, `${label}.position must be a positive integer`);
    if (typeof step.municipalityDependent !== "boolean") failure(context, `${label}.municipalityDependent must be boolean`);
    return {
      id: text(step.id, `${label}.id`, context, 1, 160),
      position: step.position,
      title: text(step.title, `${label}.title`, context, 2, 120),
      body: text(step.body, `${label}.body`, context, 10, 4_000),
      sourceIds: sourceReferences,
      municipalityDependent: step.municipalityDependent
    };
  });
  if (new Set(result.map((step) => step.id)).size !== result.length) failure(context, "numberedSteps contains duplicate IDs");
  const positions = result.map((step) => step.position).sort((left, right) => left - right);
  if (positions.some((position, index) => position !== index + 1)) failure(context, "numberedSteps positions must be contiguous from 1");
  return result.sort((left, right) => left.position - right.position);
}

/**
 * Validate and project the optional canonical runtime practicalGuide payload.
 * Draft/review/archived payloads deliberately return null: the parent remains a
 * backward-compatible brief record and no draft text reaches public output.
 */
export function projectPublishedPracticalGuide(raw, parent = {}) {
  if (raw == null) return null;
  const context = typeof parent.id === "string" ? parent.id : "<unknown>";
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) failure(context, "payload must be an object");
  if (!statuses.has(raw.status)) failure(context, "status is unsupported");
  if (raw.status !== "published") return null;

  if (raw.schemaVersion !== 2) failure(context, "schemaVersion must equal 2");
  const id = text(raw.id, "id", context);
  if (parent.id && id !== parent.id) failure(context, "id must match the parent entity ID");
  const slug = text(raw.slug, "slug", context, 1, 120);
  if (!slugPattern.test(slug)) failure(context, "slug has an invalid format");
  const locale = text(raw.locale, "locale", context);
  if (!locales.has(locale)) failure(context, "locale is unsupported");
  if (parent.language && locale !== parent.language) failure(context, "locale must match the generated page language");
  if (parent.title && text(raw.title, "title", context, 2, 120) !== parent.title) failure(context, "title must match the parent entity title");
  if (!Array.isArray(parent.mediaAssets) || parent.mediaAssets.length === 0) failure(context, "at least one verified media asset is required");
  for (const [index, media] of parent.mediaAssets.entries()) {
    if (media?.verified !== true || text(media?.alt, `mediaAssets[${index}].alt`, context, 2, 300).length < 2) failure(context, `mediaAssets[${index}] must be verified and have authored alt text`);
    const publicAssetPath = text(media?.publicAssetPath, `mediaAssets[${index}].publicAssetPath`, context, 1, 240);
    if (!publicAssetPattern.test(publicAssetPath) || publicAssetPath.includes("//") || publicAssetPath.includes("/../")) failure(context, `mediaAssets[${index}].publicAssetPath must be a safe local image path`);
    for (const key of ["assetURL", "sourcePageURL", "licenseURL"]) {
      let mediaUrl;
      try { mediaUrl = new URL(text(media?.[key], `mediaAssets[${index}].${key}`, context, 1, 2_048)); } catch { failure(context, `mediaAssets[${index}].${key} is invalid`); }
      if (mediaUrl.protocol !== "https:" || mediaUrl.username || mediaUrl.password) failure(context, `mediaAssets[${index}].${key} must use safe HTTPS`);
    }
  }

  const sources = officialSources(raw.officialSources, context);
  const sourceIds = new Set(sources.map((source) => source.id));
  const audienceProfiles = stringArray(raw.audienceProfiles, "audienceProfiles", context, { minimum: 1, maximum: 6, allowed: audiences });
  const cityIds = stringArray(raw.applicability?.cityIDs, "applicability.cityIDs", context, { maximum: 40, itemMaximum: 160 });
  const provinceIds = stringArray(raw.applicability?.provinceIDs, "applicability.provinceIDs", context, { maximum: 12, itemMaximum: 160 });
  const jurisdiction = raw.jurisdiction;
  if (!jurisdiction || typeof jurisdiction !== "object" || Array.isArray(jurisdiction)) failure(context, "jurisdiction must be an object");
  const jurisdictionLevel = text(jurisdiction.level, "jurisdiction.level", context);
  if (!jurisdictionLevels.has(jurisdictionLevel)) failure(context, "jurisdiction.level is unsupported");
  if (jurisdiction.countryCode !== "NL") failure(context, "jurisdiction.countryCode must equal NL");
  if (typeof jurisdiction.municipalityDependent !== "boolean") failure(context, "jurisdiction.municipalityDependent must be boolean");
  const jurisdictionSourceIds = stringArray(jurisdiction.sourceIDs, "jurisdiction.sourceIDs", context, { minimum: 1, maximum: 12, itemMaximum: 160 });
  for (const sourceId of jurisdictionSourceIds) if (!sourceIds.has(sourceId)) failure(context, `jurisdiction references unknown source ${sourceId}`);

  const numberedSteps = steps(raw.numberedSteps, context, sourceIds);
  const municipalSteps = numberedSteps.some((step) => step.municipalityDependent);
  if ((jurisdictionLevel === "municipal" || jurisdiction.municipalityDependent || municipalSteps) && cityIds.length === 0) {
    failure(context, "municipality-dependent guidance requires at least one applicable city ID");
  }
  if (jurisdictionLevel === "provincial" && provinceIds.length === 0) failure(context, "provincial guidance requires at least one applicable province ID");
  if (jurisdictionLevel === "mixed" && cityIds.length === 0 && provinceIds.length === 0) failure(context, "mixed guidance requires city or province applicability");
  if (jurisdictionLevel === "national" && (jurisdiction.municipalityDependent || municipalSteps)) failure(context, "national guidance cannot contain municipality-dependent instructions");

  if (!raw.reviewer || typeof raw.reviewer !== "object") failure(context, "reviewer is missing");
  const reviewerId = text(raw.reviewer.id, "reviewer.id", context, 1, 160);
  const reviewerType = text(raw.reviewer.reviewerType, "reviewer.reviewerType", context, 1, 64);
  if (!new Set(["human_editor", "subject_matter_expert", "official_owner"]).has(reviewerType)) failure(context, "reviewer.reviewerType must identify a human reviewer");
  const reviewedAt = isoDate(raw.reviewer.reviewedAt, "reviewer.reviewedAt", context);
  const gate = publicationGate(raw.publicationGate, context);
  const readingTimeMinutes = raw.readingTimeMinutes;
  if (!Number.isInteger(readingTimeMinutes) || readingTimeMinutes < 1 || readingTimeMinutes > 120) failure(context, "readingTimeMinutes must be between 1 and 120");
  const difficulty = text(raw.difficulty, "difficulty", context);
  if (!difficulties.has(difficulty)) failure(context, "difficulty is unsupported");
  if (raw.confidenceLevel !== "high") failure(context, "confidenceLevel must equal high");
  if (!raw.seo || typeof raw.seo !== "object") failure(context, "seo is missing");
  const canonicalPath = text(raw.seo.canonicalPath, "seo.canonicalPath", context, 1, 180);
  if (!canonicalPath.startsWith("/guides/")) failure(context, "seo.canonicalPath must be a guide route");
  if (parent.route && canonicalPath !== parent.route) failure(context, "seo.canonicalPath must match the generated route");

  const contacts = Array.isArray(raw.contactOptions) ? raw.contactOptions.map((contact, index) => {
    const label = `contactOptions[${index}]`;
    const references = stringArray(contact?.sourceIDs, `${label}.sourceIDs`, context, { minimum: 1, maximum: 12, itemMaximum: 160 });
    for (const sourceId of references) if (!sourceIds.has(sourceId)) failure(context, `${label} references unknown source ${sourceId}`);
    return {
      id: text(contact?.id, `${label}.id`, context, 1, 160),
      kind: text(contact?.kind, `${label}.kind`, context, 1, 32),
      label: text(contact?.label, `${label}.label`, context, 2, 160),
      value: text(contact?.value, `${label}.value`, context, 2, 500),
      sourceIds: references
    };
  }) : failure(context, "contactOptions must be an array");
  if (contacts.length < 1 || contacts.length > 20) failure(context, "contactOptions must contain between 1 and 20 items");
  if (contacts.some((contact) => !contactKinds.has(contact.kind))) failure(context, "contactOptions contains an unsupported kind");
  for (const contact of contacts.filter((item) => item.kind === "url")) {
    let contactUrl;
    try { contactUrl = new URL(contact.value); } catch { failure(context, `contactOptions ${contact.id} URL is invalid`); }
    if (contactUrl.protocol !== "https:" || contactUrl.username || contactUrl.password) failure(context, `contactOptions ${contact.id} must use safe HTTPS`);
  }
  for (const contact of contacts.filter((item) => item.kind === "email")) {
    if (contact.value.length > 254 || !emailPattern.test(contact.value)) failure(context, `contactOptions ${contact.id} email is invalid`);
  }
  for (const contact of contacts.filter((item) => item.kind === "phone")) {
    if (!phonePattern.test(contact.value) || [...contact.value].filter((character) => /\d/.test(character)).length < 6) failure(context, `contactOptions ${contact.id} phone is invalid`);
  }
  if (new Set(contacts.map((contact) => contact.id)).size !== contacts.length) failure(context, "contactOptions contains duplicate IDs");

  if (!Array.isArray(raw.sections) || raw.sections.length < 1 || raw.sections.length > 20) failure(context, "sections must contain between 1 and 20 items");
  const projectedSections = raw.sections.map((section, index) => {
    const label = `sections[${index}]`;
    const references = stringArray(section?.sourceIDs, `${label}.sourceIDs`, context, { minimum: 1, maximum: 12, itemMaximum: 160 });
    for (const sourceId of references) if (!sourceIds.has(sourceId)) failure(context, `${label} references unknown source ${sourceId}`);
    return { id: text(section?.id, `${label}.id`, context, 1, 160), title: text(section?.title, `${label}.title`, context, 2, 120), body: text(section?.body, `${label}.body`, context, 10, 5_000), sourceIds: references };
  });
  if (new Set(projectedSections.map((section) => section.id)).size !== projectedSections.length) failure(context, "sections contains duplicate IDs");

  const verifiedAt = isoDate(raw.verifiedAt, "verifiedAt", context);
  const updatedAt = isoDate(raw.updatedAt, "updatedAt", context);
  const today = new Date().toISOString().slice(0, 10);
  if (verifiedAt > today || updatedAt > today || reviewedAt > today || gate.checkedAt > today) failure(context, "review and verification dates cannot be in the future");
  if (sources.some((source) => source.checkedAt < updatedAt || source.checkedAt > verifiedAt)) failure(context, "official source dates must fall between update and verification");
  if (!(updatedAt <= reviewedAt && reviewedAt <= verifiedAt)) failure(context, "reviewer date must fall between update and verification");
  if (!(updatedAt <= gate.checkedAt && gate.checkedAt <= verifiedAt)) failure(context, "publication gate date must fall between update and verification");

  return {
    schemaVersion: 2,
    id,
    slug,
    locale,
    title: text(raw.title, "title", context, 2, 120),
    shortSummary: sourcedText(raw.shortSummary, "shortSummary", context, sourceIds),
    audienceProfiles,
    whoThisIsFor: sourcedText(raw.whoThisIsFor, "whoThisIsFor", context, sourceIds),
    whenYouNeedIt: sourcedText(raw.whenYouNeedIt, "whenYouNeedIt", context, sourceIds),
    applicability: { cityIds, provinceIds },
    jurisdiction: {
      level: jurisdictionLevel,
      countryCode: "NL",
      municipalityDependent: jurisdiction.municipalityDependent,
      note: typeof jurisdiction.note === "string" && jurisdiction.note.trim() ? text(jurisdiction.note, "jurisdiction.note", context) : "",
      sourceIds: jurisdictionSourceIds
    },
    prerequisites: sourcedTextArray(raw.prerequisites, "prerequisites", context, sourceIds, { minimum: 1, maximum: 20 }),
    requiredDocuments: sourcedTextArray(raw.requiredDocuments, "requiredDocuments", context, sourceIds, { minimum: 1, maximum: 20 }),
    estimatedTime: estimate(raw.estimatedTime, "estimatedTime", context, sourceIds),
    estimatedCost: estimate(raw.estimatedCost, "estimatedCost", context, sourceIds, true),
    numberedSteps,
    warnings: sourcedTextArray(raw.warnings, "warnings", context, sourceIds, { minimum: 1, maximum: 15 }),
    commonMistakes: sourcedTextArray(raw.commonMistakes, "commonMistakes", context, sourceIds, { minimum: 1, maximum: 15 }),
    tips: sourcedTextArray(raw.tips, "tips", context, sourceIds, { minimum: 1, maximum: 20 }),
    checklist: sourcedTextArray(raw.checklist, "checklist", context, sourceIds, { minimum: 1, maximum: 30 }),
    faqs: faqArray(raw.faqs, "faqs", context, sourceIds),
    emergencyInformation: sourcedTextArray(raw.emergencyInformation, "emergencyInformation", context, sourceIds, { minimum: 1, maximum: 10 }),
    sections: projectedSections,
    officialSources: sources,
    contactOptions: contacts,
    relatedGuideIds: (() => {
      const ids = stringArray(raw.relatedGuideIDs, "relatedGuideIDs", context, { minimum: 1, maximum: 20, itemMaximum: 160 });
      if (ids.includes(id)) failure(context, "relatedGuideIDs cannot contain the guide itself");
      return ids;
    })(),
    nextActions: sourcedTextArray(raw.nextActions, "nextActions", context, sourceIds, { minimum: 1, maximum: 20 }),
    verifiedAt,
    updatedAt,
    reviewer: {
      id: reviewerId,
      name: text(raw.reviewer.name, "reviewer.name", context, 2, 120),
      role: text(raw.reviewer.role, "reviewer.role", context, 2, 160),
      reviewerType,
      reviewedAt
    },
    readingTimeMinutes,
    difficulty,
    confidenceLevel: "high",
    tags: stringArray(raw.tags, "tags", context, { minimum: 2, maximum: 20, itemMaximum: 60 }),
    publicationGate: gate,
    disclaimer: text(raw.disclaimer, "disclaimer", context, 10, 2_000),
    status: "published",
    seo: {
      title: (() => {
        const seoTitle = text(raw.seo.title, "seo.title", context, 10, 70);
        if (seoTitle.toLocaleLowerCase("en").endsWith("| younew")) failure(context, "seo.title must be unbranded because the layout adds YouNew");
        return seoTitle;
      })(),
      description: text(raw.seo.description, "seo.description", context, 40, 180),
      canonicalPath
    },
    synonyms: stringArray(raw.synonyms, "synonyms", context, { minimum: 1, maximum: 40, itemMaximum: 120 }),
    commonQuestions: stringArray(raw.commonQuestions, "commonQuestions", context, { minimum: 1, maximum: 40, itemMaximum: 240 })
  };
}
