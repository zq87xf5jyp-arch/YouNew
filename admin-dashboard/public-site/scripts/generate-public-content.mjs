import { createHash } from "node:crypto";
import { readFile, mkdir, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { projectPublishedPracticalGuide } from "./practical-guide.mjs";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const publicSiteRoot = resolve(scriptDirectory, "..");

export const paths = Object.freeze({
  source: resolve(publicSiteRoot, "../../YouNew/Resources/Data/younew-runtime-data.json"),
  geography: resolve(publicSiteRoot, "src/generated/netherlands-geography.json"),
  nationalGuides: resolve(publicSiteRoot, "src/content/national-guides.json"),
  taxonomy: resolve(publicSiteRoot, "src/data/life-domain-taxonomy.json"),
  content: resolve(publicSiteRoot, "src/generated/public-content.json"),
  search: resolve(publicSiteRoot, "public/data/search-index.json"),
  provenance: resolve(publicSiteRoot, "public/data/content-provenance.json")
});

const geography = JSON.parse(await readFile(paths.geography, "utf8"));
const nationalGuideDataset = JSON.parse(await readFile(paths.nationalGuides, "utf8"));
const lifeDomains = JSON.parse(await readFile(paths.taxonomy, "utf8"));
const lifeDomainBySlug = new Map(lifeDomains.map((domain) => [domain.slug, domain]));

if (nationalGuideDataset?.schemaVersion !== 1 || !Array.isArray(nationalGuideDataset.guides) || nationalGuideDataset.guides.length === 0) {
  throw new Error("The national guide dataset is missing or invalid.");
}
for (const guide of nationalGuideDataset.guides) {
  if (!guide?.id || !guide?.slug || !guide?.title || guide.scope !== "national" || guide.nationalFallback !== true) {
    throw new Error(`Invalid national guide metadata: ${String(guide?.id ?? "unknown")}.`);
  }
  if (!Array.isArray(guide.officialSources) || guide.officialSources.length === 0 || guide.officialSources.some((source) => !source?.url?.startsWith("https://") || !source?.checkedAt)) {
    throw new Error(`National guide ${guide.id} must have checked HTTPS official sources.`);
  }
}
if (!Array.isArray(lifeDomains) || lifeDomains.length === 0 || lifeDomains.some((domain) => !domain?.slug || !domain?.title || !Array.isArray(domain?.officialSources))) {
  throw new Error("The life-domain taxonomy is missing or invalid.");
}

const provinceNames = Object.freeze({
  "drenthe": "Drenthe",
  "flevoland": "Flevoland",
  "fryslan": "Fryslân",
  "gelderland": "Gelderland",
  "groningen": "Groningen",
  "limburg": "Limburg",
  "noord-brabant": "Noord-Brabant",
  "noord-holland": "Noord-Holland",
  "overijssel": "Overijssel",
  "utrecht": "Utrecht",
  "zeeland": "Zeeland",
  "zuid-holland": "Zuid-Holland"
});

const legacyBroadCategoryDefinitions = Object.freeze({
  government: {
    title: "Government",
    summary: "Municipal services and official administrative information."
  },
  housing: {
    title: "Housing",
    summary: "Published housing resources and tenant information."
  },
  healthcare: {
    title: "Healthcare",
    summary: "Healthcare organizations and public-health services."
  },
  transport: {
    title: "Transport",
    summary: "Stations and other published transport resources."
  },
  education: {
    title: "Education",
    summary: "Universities and other published education organizations."
  },
  work: {
    title: "Work",
    summary: "Source-backed guidance about working and employment in the Netherlands."
  },
  integration: {
    title: "Integration",
    summary: "Published integration guidance and official routes for new residents."
  },
  emergency: {
    title: "Emergency",
    summary: "Urgent-help information kept separate from commercial placements."
  },
  finance: {
    title: "Money & finance",
    summary: "Practical information about banking, taxes and allowances."
  },
  business: {
    title: "Starting a business",
    summary: "Official routes for setting up and running a business in the Netherlands."
  },
  "local-services": {
    title: "Local services",
    summary: "Local companies whose source information has been checked by YouNew."
  },
  "food-drink": {
    title: "Food & drink",
    summary: "Published restaurants and cafes."
  },
  culture: {
    title: "Culture & events",
    summary: "Museums and published cultural events."
  },
  outdoors: {
    title: "Parks & outdoors",
    summary: "Published parks and outdoor places."
  },
  "things-to-do": {
    title: "Places to visit",
    summary: "Published attractions, districts and useful public places."
  }
});

const broadCategoryDefinitions = Object.freeze({
  ...legacyBroadCategoryDefinitions,
  ...Object.fromEntries(lifeDomains.map((domain) => [domain.slug, { title: domain.title, summary: domain.summary }]))
});

const entityTypeByKind = Object.freeze({
  city: "city",
  knowledgeTopic: "guide",
  governmentService: "guide",
  healthcare: "organization",
  university: "organization",
  localPartner: "organization",
  cafe: "place",
  event: "place",
  museum: "place",
  park: "place",
  place: "place",
  restaurant: "place",
  transport: "place"
});

const categoryByKind = Object.freeze({
  city: "things-to-do",
  governmentService: "government",
  knowledgeTopic: "housing",
  healthcare: "healthcare",
  transport: "transport",
  university: "education",
  localPartner: "local-services",
  cafe: "food-drink",
  restaurant: "food-drink",
  event: "culture",
  museum: "culture",
  park: "outdoors",
  place: "things-to-do"
});
const practicalGuideCategories = new Set(["government", "housing", "healthcare", "transport", "education", "work", "integration", "emergency", "finance", "business"]);

const routePrefixByType = Object.freeze({
  city: "/cities",
  guide: "/guides",
  organization: "/organizations",
  place: "/places"
});

function canonicalMunicipalityId(value) {
  if (!value) return null;
  if (value === "den-haag" || value === "the-hague") return "s-gravenhage";
  if (value === "den-bosch") return "s-hertogenbosch";
  return value;
}

// Backward-compatible search vocabulary for the brief canonical records that
// pre-date `practical_guide`. This adds discoverability, not procedural facts;
// full guide vocabulary comes from the governed practical-guide payload.
const legacySearchMetadataById = Object.freeze({
  "government_service.first-registration-in-amsterdam": {
    synonyms: ["register gemeente", "municipality registration", "BSN registration", "burgerservicenummer registration"],
    terminology: ["gemeente", "BRP", "basisregistratie personen", "BSN", "burgerservicenummer"],
    commonQuestions: ["How do I get a BSN?", "How do I register with a gemeente?"],
    officialOrganizationNames: ["City of Amsterdam", "Gemeente Amsterdam"]
  },
  "housing.woon": {
    synonyms: ["landlord does not repair", "housing defects", "tenant support", "rental problem"],
    terminology: ["landlord", "repair", "tenant", "huurders", "gebreken"],
    commonQuestions: ["What can I do if my landlord does not repair a defect?"],
    officialOrganizationNames: ["!WOON"]
  },
  "housing.renting-a-home-in-amsterdam": {
    synonyms: ["rent a home", "find rental housing", "huurwoning"],
    terminology: ["renting", "rental", "huurwoning", "tenancy"],
    commonQuestions: ["Where can I read the official Amsterdam renting guidance?"],
    officialOrganizationNames: ["City of Amsterdam", "Gemeente Amsterdam"]
  },
  "government_service.moving-within-amsterdam": {
    synonyms: ["change address gemeente", "report a move", "moving municipality"],
    terminology: ["address change", "verhuizing", "gemeente"],
    commonQuestions: ["How do I report a move in Amsterdam?"],
    officialOrganizationNames: ["City of Amsterdam", "Gemeente Amsterdam"]
  }
});

const categorySearchMetadata = Object.freeze({
  government: {
    synonyms: ["gemeente services", "municipality services"],
    terminology: ["gemeente", "municipality", "civil affairs"]
  },
  housing: {
    synonyms: ["student housing", "rental housing", "landlord repair"],
    terminology: ["housing", "rent", "huurwoning", "tenant"]
  },
  healthcare: {
    synonyms: ["find healthcare", "healthcare organizations"],
    terminology: ["healthcare", "zorg", "medical services", "public health"]
  },
  transport: {
    synonyms: ["public transport", "travel by train", "OV card"],
    terminology: ["OV", "OV-chipkaart", "openbaar vervoer"]
  },
  education: {
    synonyms: ["study in the Netherlands", "Dutch university"],
    terminology: ["student", "studying", "onderwijs"]
  }
});

const searchableUtilityPages = Object.freeze([
  {
    id: "page.emergency",
    type: "page",
    sourceKind: "utilityPage",
    slug: "emergency",
    route: "/emergency",
    title: "Emergency numbers and urgent help",
    summary: "Open YouNew's emergency page for urgent Dutch contact routes and source links.",
    keywords: ["emergency", "urgent help", "112", "noodgeval"],
    synonyms: ["emergency", "urgent help", "police ambulance fire"],
    terminology: ["112", "noodgeval"],
    commonQuestions: ["What number do I call in an emergency?"],
    categories: ["healthcare", "government"]
  },
  {
    id: "page.journeys",
    type: "page",
    sourceKind: "utilityPage",
    slug: "journeys",
    route: "/journeys",
    title: "Practical journeys",
    summary: "Follow released source-backed guide paths and keep progress locally in this browser.",
    keywords: ["journey", "checklist", "new in the Netherlands", "student", "housing"],
    synonyms: ["getting started path", "newcomer checklist"],
    terminology: ["journey", "reading progress"],
    commonQuestions: ["Where should I start in the Netherlands?"],
    categories: ["government", "housing"]
  },
  {
    id: "page.map",
    type: "page",
    sourceKind: "utilityPage",
    slug: "map",
    route: "/map",
    title: "Published coverage map",
    summary: "Browse released YouNew cities, places and organizations by coordinate and accessible list.",
    keywords: ["map", "cities", "places", "organizations", "Netherlands"],
    synonyms: ["YouNew map", "nearby published places"],
    terminology: ["coverage map"],
    commonQuestions: ["What YouNew content is shown on the map?"],
    categories: ["things-to-do", "local-services"]
  }
]);

function cleanText(value, maximumLength = 2_000) {
  if (typeof value !== "string") return "";

  return value
    .normalize("NFC")
    .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, maximumLength);
}

export function publicWebSummary(summary) {
  return cleanText(summary)
    .replace(/\s*This governed entry stores a verified city location and direct web route without copying mutable prices, ratings, reviews or opening hours\.\s*$/, "")
    .replace("The cited source specifically covers ", "The source covers ")
    .trim();
}

function cleanIdentifier(value) {
  return cleanText(value, 160).replace(/[^a-zA-Z0-9._-]/g, "");
}

function cleanDate(value) {
  const candidate = cleanText(value, 40);
  if (!candidate || Number.isNaN(Date.parse(candidate))) return null;
  return candidate;
}

function cleanURL(value) {
  const candidate = cleanText(value, 2_048);
  if (!candidate) return null;

  try {
    const url = new URL(candidate);
    if (!new Set(["http:", "https:"]).has(url.protocol)) return null;
    if (url.username || url.password) return null;

    url.hash = "";
    for (const parameter of [...url.searchParams.keys()]) {
      if (/^(utm_|fbclid$|gclid$)/i.test(parameter)) url.searchParams.delete(parameter);
    }
    return url.toString();
  } catch {
    return null;
  }
}

const governanceEnums = Object.freeze({
  publicationStatus: new Set(["draft", "qa", "published", "archived"]),
  verificationStatus: new Set(["unverified", "verified", "review_due_soon", "overdue", "source_unavailable", "disputed", "archived"]),
  reviewState: new Set(["needs_review", "assigned", "in_review", "approved", "monitoring", "expired", "closed"]),
  criticality: new Set(["standard", "critical"]),
  contentOrigin: new Set(["imported", "manually_created", "municipality_release", "government_publication", "ai_generated_draft", "migrated"]),
  confidenceLevel: new Set(["low", "medium", "high"]),
  jurisdictionLevel: new Set(["national", "provincial", "municipal", "mixed"])
});

function nullableText(value, maximumLength = 500) {
  const cleaned = cleanText(value, maximumLength);
  return cleaned || null;
}

function utcDate(value, field, nullable = true) {
  if (value == null && nullable) return null;
  const cleaned = cleanDate(value);
  if (!cleaned) throw new Error(`Governance ${field} must be an ISO 8601 instant.`);
  if (!/(?:Z|\+00:00)$/i.test(cleaned)) throw new Error(`Governance ${field} must be UTC.`);
  const parsed = new Date(cleaned);
  return parsed.toISOString();
}

function requireEnum(value, values, field) {
  if (!values.has(value)) throw new Error(`Governance ${field} is invalid.`);
  return value;
}

function requireInteger(value, field, minimum, maximum = Number.MAX_SAFE_INTEGER) {
  if (!Number.isInteger(value) || value < minimum || value > maximum) {
    throw new Error(`Governance ${field} must be an integer in ${minimum}...${maximum}.`);
  }
  return value;
}

function sanitizeGovernanceEnvelope(raw, entityID) {
  if (raw == null) return null;
  if (typeof raw !== "object" || Array.isArray(raw)) throw new Error(`Governance envelope for ${entityID} must be an object.`);
  const id = cleanIdentifier(raw.id);
  if (id !== entityID) throw new Error(`Governance envelope ID ${id || "<missing>"} does not match ${entityID}.`);
  const publicationStatus = requireEnum(raw.publicationStatus, governanceEnums.publicationStatus, "publicationStatus");
  const verificationStatus = requireEnum(raw.verificationStatus, governanceEnums.verificationStatus, "verificationStatus");
  const contentOrigin = requireEnum(raw.contentOrigin, governanceEnums.contentOrigin, "contentOrigin");
  if (["ai_generated_draft", "migrated"].includes(contentOrigin) && publicationStatus !== "draft") {
    throw new Error(`Governance origin ${contentOrigin} cannot enter the public projection.`);
  }
  const jurisdiction = raw.jurisdiction;
  if (!jurisdiction || typeof jurisdiction !== "object" || jurisdiction.countryCode !== "NL") {
    throw new Error(`Governance jurisdiction for ${entityID} is invalid.`);
  }
  const sourceURL = raw.officialSourceURL == null ? null : cleanURL(raw.officialSourceURL);
  if (sourceURL && !sourceURL.startsWith("https://")) throw new Error(`Governance officialSourceURL for ${entityID} must use HTTPS.`);
  const breakdown = raw.confidenceBreakdown;
  if (!breakdown || typeof breakdown !== "object") throw new Error(`Governance confidenceBreakdown for ${entityID} is missing.`);
  const officialSource = requireInteger(breakdown.officialSource, "confidenceBreakdown.officialSource", 0, 40);
  const humanReviewer = requireInteger(breakdown.humanReviewer, "confidenceBreakdown.humanReviewer", 0, 20);
  const independentReview = requireInteger(breakdown.independentReview, "confidenceBreakdown.independentReview", 0, 15);
  const freshness = requireInteger(breakdown.freshness, "confidenceBreakdown.freshness", 0, 10);
  const jurisdictionApplicability = requireInteger(breakdown.jurisdictionApplicability, "confidenceBreakdown.jurisdictionApplicability", 0, 15);
  if (![0, 40].includes(officialSource) || ![0, 20].includes(humanReviewer) || ![0, 15].includes(independentReview) || ![0, 10].includes(freshness) || ![0, 15].includes(jurisdictionApplicability)) {
    throw new Error(`Governance confidenceBreakdown for ${entityID} does not match formula v1.`);
  }
  const confidenceScore = requireInteger(raw.confidenceScore, "confidenceScore", 0, 100);
  if (confidenceScore !== officialSource + humanReviewer + independentReview + freshness + jurisdictionApplicability) {
    throw new Error(`Governance confidenceScore for ${entityID} is not reproducible.`);
  }
  const digest = nullableText(raw.originArtifactDigest, 80);
  if (digest && !/^sha256:[a-f0-9]{64}$/.test(digest)) throw new Error(`Governance originArtifactDigest for ${entityID} is invalid.`);

  return {
    id,
    title: cleanText(raw.title, 240),
    contentType: cleanIdentifier(raw.contentType),
    jurisdiction: {
      countryCode: "NL",
      level: requireEnum(jurisdiction.level, governanceEnums.jurisdictionLevel, "jurisdiction.level"),
      municipalityDependent: jurisdiction.municipalityDependent === true,
      applicabilityVerified: jurisdiction.applicabilityVerified === true,
      provinceCode: nullableText(jurisdiction.provinceCode, 20),
      provinceName: nullableText(jurisdiction.provinceName, 120),
      municipalityCode: nullableText(jurisdiction.municipalityCode, 20),
      municipalityName: nullableText(jurisdiction.municipalityName, 120)
    },
    officialSourceURL: sourceURL,
    sourceTitle: nullableText(raw.sourceTitle, 240),
    sourcePublisher: nullableText(raw.sourcePublisher, 160),
    lastVerifiedAt: utcDate(raw.lastVerifiedAt, "lastVerifiedAt"),
    nextReviewAt: utcDate(raw.nextReviewAt, "nextReviewAt"),
    reviewIntervalDays: raw.reviewIntervalDays == null ? null : requireInteger(raw.reviewIntervalDays, "reviewIntervalDays", 1, 730),
    contentOwner: nullableText(raw.contentOwner, 160),
    reviewedBy: nullableText(raw.reviewedBy, 160),
    verificationStatus,
    confidenceLevel: requireEnum(raw.confidenceLevel, governanceEnums.confidenceLevel, "confidenceLevel"),
    validityStart: utcDate(raw.validityStart, "validityStart"),
    validityEnd: utcDate(raw.validityEnd, "validityEnd"),
    changeNotes: nullableText(raw.changeNotes, 2_000),
    version: requireInteger(raw.version, "version", 1),
    updatedAt: utcDate(raw.updatedAt, "updatedAt", false),
    publicationStatus,
    reviewState: requireEnum(raw.reviewState, governanceEnums.reviewState, "reviewState"),
    criticality: requireEnum(raw.criticality, governanceEnums.criticality, "criticality"),
    contentOrigin,
    originReference: nullableText(raw.originReference, 2_048),
    originCapturedAt: utcDate(raw.originCapturedAt, "originCapturedAt"),
    originArtifactDigest: digest,
    confidenceScore,
    confidenceScoreVersion: requireInteger(raw.confidenceScoreVersion, "confidenceScoreVersion", 1),
    confidenceBreakdown: { officialSource, humanReviewer, independentReview, freshness, jurisdictionApplicability }
  };
}

function cleanPublicAssetPath(value) {
  const candidate = cleanText(value, 240);
  if (!/^\/images\/[A-Za-z0-9](?:[A-Za-z0-9._/-]*[A-Za-z0-9])?\.(?:avif|gif|jpe?g|png|svg|webp)$/i.test(candidate)) return null;
  if (candidate.includes("//") || candidate.includes("/../")) return null;
  return candidate;
}

function hash(value, length = 8) {
  return createHash("sha256").update(value).digest("hex").slice(0, length);
}

function canonicalRuntimeJSON(value) {
  const sorted = (item) => {
    if (Array.isArray(item)) return item.map(sorted);
    if (item && typeof item === "object") {
      return Object.fromEntries(Object.keys(item).sort().map((key) => [key, sorted(item[key])]));
    }
    return item;
  };
  return `${JSON.stringify(sorted(value), null, 2)}\n`;
}

export function assertCanonicalRuntimeChecksum(runtime) {
  const expected = cleanText(runtime?.outputChecksum, 160);
  if (!/^[a-f0-9]{64}$/.test(expected)) throw new Error("Canonical runtime outputChecksum is missing or invalid.");
  const unsigned = { ...runtime };
  delete unsigned.outputChecksum;
  const actual = createHash("sha256").update(canonicalRuntimeJSON(unsigned)).digest("hex");
  if (actual !== expected) throw new Error("Canonical runtime outputChecksum does not match the checked-in payload.");
}

export function slugify(value) {
  return cleanText(value, 180)
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/&/g, " and ")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 96)
    .replace(/-+$/g, "");
}

export function assignStableSlugs(records, baseForRecord = (record) => record.title) {
  const grouped = new Map();

  for (const record of records) {
    const fallback = `item-${hash(String(record.id))}`;
    const base = slugify(baseForRecord(record)) || fallback;
    const group = grouped.get(base) ?? [];
    group.push(record);
    grouped.set(base, group);
  }

  const result = new Map();
  for (const [base, group] of grouped) {
    const ordered = [...group].sort((left, right) => String(left.id).localeCompare(String(right.id)));
    if (ordered.length === 1) {
      result.set(ordered[0].id, base);
      continue;
    }

    for (const record of ordered) result.set(record.id, `${base}-${hash(String(record.id))}`);
  }

  return result;
}

function entityTypeFor(kind) {
  return entityTypeByKind[kind] ?? null;
}

function categoryFor(entity) {
  const kind = typeof entity === "string" ? entity : entity?.kind;
  const fallback = categoryByKind[kind] ?? null;
  if (typeof entity !== "object" || entity == null) return fallback;
  const explicit = cleanIdentifier(entity.attributes?.publicWebCategory);
  if (entity.practicalGuide?.status === "published") {
    if (!practicalGuideCategories.has(explicit)) throw new Error(`Published practical guide ${entity.id ?? "<missing id>"} requires a supported canonical publicWebCategory.`);
    return explicit;
  }
  return practicalGuideCategories.has(explicit) ? explicit : fallback;
}

function titleFromSlug(value) {
  const key = slugify(value);
  if (provinceNames[key]) return provinceNames[key];
  return key
    .split("-")
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function sanitizeImage(image, entityTitle) {
  if (!image || image.verified !== true) return null;
  const url = cleanPublicAssetPath(image.publicAssetPath) ?? cleanURL(image.assetURL);
  if (!url) return null;

  const role = new Set(["hero", "thumbnail", "gallery", "map_preview"]).has(image.role)
    ? image.role
    : "gallery";
  return {
    id: cleanIdentifier(image.id) || `media.${hash(url, 12)}`,
    role,
    url,
    alt: cleanText(image.alt, 300) || `${entityTitle} — ${role.replace("_", " ")}`,
    attribution: cleanText(image.attribution, 500),
    license: cleanText(image.license, 80),
    licenseUrl: cleanURL(image.licenseURL),
    sourcePageUrl: cleanURL(image.sourcePageURL),
    retrievedAt: cleanDate(image.retrievedAt)
  };
}

function isPublishableEntity(entity, publishedReleaseIds) {
  return Boolean(
    entity &&
      entityTypeFor(entity.kind) &&
      categoryFor(entity) &&
      publishedReleaseIds.has(entity.attributes?.dataProjectRelease) &&
      entity.publicationStatus === "published" &&
      entity.attributes?.lifecycleStatus === "published" &&
      entity.verificationStatus === "verified" &&
      entity.attributes?.verificationStatus === "verified" &&
      entity.source?.status === "verified_opened"
  );
}

function sanitizeEntity(entity, slug) {
  const id = cleanIdentifier(entity.id);
  const sourceKind = cleanIdentifier(entity.kind);
  const type = entityTypeFor(sourceKind);
  const title = cleanText(entity.title, 180);
  const summary = cleanText(entity.summary, 800);
  const narrowCategory = slugify(entity.category);
  const broadCategorySlug = categoryFor(entity);
  const cityId = slugify(entity.cityId);
  const provinceId = slugify(entity.provinceId);
  const isLocalPartner = sourceKind === "localPartner";
  const sourceUrl = cleanURL(entity.source?.url);
  const verifiedAt = cleanDate(entity.source?.checkedAt) ?? cleanDate(entity.lastChecked);

  if (!id || !sourceKind || !type || !broadCategorySlug || !title || !summary || !sourceUrl || !verifiedAt) {
    throw new Error(`Published entity ${entity.id ?? "<missing id>"} is missing a required public field.`);
  }

  const images = Array.isArray(entity.images)
    ? entity.images.map((image) => sanitizeImage(image, title)).filter(Boolean)
    : [];
  const keywords = Array.isArray(entity.keywords)
    ? [...new Set(entity.keywords.map((keyword) => cleanText(keyword, 120)).filter(Boolean))].slice(0, 32)
    : [];

  const latitude = Number(entity.coordinate?.latitude);
  const longitude = Number(entity.coordinate?.longitude);
  const coordinate =
    Number.isFinite(latitude) &&
    latitude >= -90 &&
    latitude <= 90 &&
    Number.isFinite(longitude) &&
    longitude >= -180 &&
    longitude <= 180
      ? { latitude, longitude }
      : null;

  const route = `${routePrefixByType[type]}/${slug}`;
  if (entity.practicalGuide != null && type !== "guide") {
    throw new Error(`Published non-guide entity ${entity.id} contains a practicalGuide payload.`);
  }
  const practicalGuide = projectPublishedPracticalGuide(entity.practicalGuide, {
    id,
    title,
    route,
    language: "en",
    mediaAssets: entity.images
  });
  const source = {
    title: cleanText(entity.source?.title, 240),
    publisher: cleanText(entity.source?.publisher, 160),
    url: sourceUrl,
    checkedAt: verifiedAt,
    publisherOfficial: !isLocalPartner && entity.source?.isOfficial === true
  };

  return {
    id,
    slug,
    type,
    sourceKind,
    route,
    language: "en",
    status: "published",
    title,
    summary,
    contentDepth: practicalGuide ? "practical" : "summary",
    practicalGuide,
    cityId: cityId || null,
    provinceId: provinceId || null,
    categorySlugs: [broadCategorySlug],
    narrowCategory: narrowCategory || null,
    keywords,
    coordinate,
    images,
    source,
    trust: {
      sourceChecked: true,
      officialSource: !isLocalPartner && entity.source?.isOfficial === true
    },
    governance: sanitizeGovernanceEnvelope(entity.governance, id),
    verifiedAt,
    updatedAt: cleanDate(entity.lastChecked) ?? verifiedAt,
    releaseId: cleanIdentifier(entity.attributes?.dataProjectRelease),
    relatedEntityIds: Array.isArray(entity.relatedEntityIDs)
      ? [...new Set(entity.relatedEntityIDs.map(cleanIdentifier).filter(Boolean))].slice(0, 32)
      : [],
    seo: {
      title: `${title} | YouNew`,
      description: summary.slice(0, 160),
      canonicalPath: route
    }
  };
}

function buildCategories(entities) {
  const buckets = new Map();
  for (const entity of entities) {
    for (const slug of entity.categorySlugs) {
      const existing = buckets.get(slug) ?? [];
      existing.push(entity);
      buckets.set(slug, existing);
    }
  }

  for (const domain of lifeDomains) {
    if (!buckets.has(domain.slug)) buckets.set(domain.slug, []);
  }

  return [...buckets.entries()]
    .map(([slug, records]) => {
      const definition = broadCategoryDefinitions[slug] ?? {
        title: titleFromSlug(slug),
        summary: `Published ${titleFromSlug(slug).toLowerCase()} information.`
      };
      return {
        id: `category.${slug}`,
        slug,
        route: `/categories/${slug}`,
        title: definition.title,
        summary: definition.summary,
        status: "published",
        language: "en",
        entityCount: records.length,
        entityIds: records.map((record) => record.id).sort(),
        entityTypes: [...new Set(records.map((record) => record.type))].sort()
      };
    })
    .sort((left, right) => left.title.localeCompare(right.title));
}

function buildProvinces(entities) {
  const buckets = new Map();
  for (const entity of entities) {
    if (!entity.provinceId) continue;
    const existing = buckets.get(entity.provinceId) ?? [];
    existing.push(entity);
    buckets.set(entity.provinceId, existing);
  }

  return [...buckets.entries()]
    .map(([slug, records]) => ({
      id: `province.${slug}`,
      slug,
      route: `/provinces/${slug}`,
      title: titleFromSlug(slug),
      summary: `Published YouNew information for ${titleFromSlug(slug)}.`,
      status: "published",
      language: "en",
      entityCount: records.length,
      entityIds: records.map((record) => record.id).sort(),
      cityIds: [...new Set(records.map((record) => record.cityId).filter(Boolean))].sort(),
      categorySlugs: [...new Set(records.flatMap((record) => record.categorySlugs))].sort()
    }))
    .sort((left, right) => left.title.localeCompare(right.title));
}

export function buildSearchIndex(entities, categories, citiesById, provincesById, generatedAt, datasetFingerprint) {
  const entityDocuments = entities.map((entity) => {
    const practical = entity.practicalGuide ?? null;
    const legacy = legacySearchMetadataById[entity.id] ?? {};
    const officialOrganizationNames = [
      entity.source.publisher,
      ...(practical?.officialSources?.map((source) => source.publisher) ?? []),
      ...(legacy.officialOrganizationNames ?? [])
    ];
    return {
      id: entity.id,
      type: entity.type,
      sourceKind: entity.sourceKind,
      slug: entity.slug,
      route: entity.route,
      title: entity.title,
      summary: publicWebSummary(entity.summary),
      contentDepth: entity.contentDepth,
      keywords: entity.keywords,
      city: entity.cityId ? citiesById.get(entity.cityId)?.title ?? titleFromSlug(entity.cityId) : null,
      cityId: entity.cityId,
      province: entity.provinceId ? provincesById.get(entity.provinceId)?.title ?? titleFromSlug(entity.provinceId) : null,
      provinceId: entity.provinceId,
      municipalityId: canonicalMunicipalityId(entity.cityId),
      locationScope: entity.cityId ? (entity.type === "organization" ? "organization" : "city") : entity.provinceId ? "province" : "national",
      country: "NL",
      categories: entity.categorySlugs,
      intents: entity.categorySlugs,
      languages: ["en"],
      nationalFallback: !entity.cityId && !entity.provinceId,
      qualityScore: entity.contentDepth === "practical" ? 94 : 70,
      verifiedAt: entity.verifiedAt,
      officialSourceUrls: [...new Set([entity.source.url, ...(practical?.officialSources?.map((source) => source.url) ?? [])].filter(Boolean))],
      relatedOrganizationIds: entity.relatedEntityIds.filter((id) => id.startsWith("organization.")),
      narrowCategory: entity.narrowCategory,
      organization: entity.type === "organization" ? entity.title : entity.source.publisher,
      audienceProfiles: practical?.audienceProfiles ?? [],
      numberedSteps: practical?.numberedSteps?.flatMap((step) => [step.title, step.body]) ?? [],
      requiredDocuments: practical?.requiredDocuments?.map((item) => item.text) ?? [],
      checklist: practical?.checklist?.map((item) => item.text) ?? [],
      tips: practical?.tips?.map((item) => item.text) ?? [],
      faqAnswers: practical?.faqs?.map((item) => `${item.question} ${item.answer}`) ?? [],
      whenYouNeedIt: practical?.whenYouNeedIt?.text ? [practical.whenYouNeedIt.text] : [],
      tags: practical?.tags ?? [],
      synonyms: [...new Set([...(practical?.synonyms ?? []), ...(legacy.synonyms ?? [])])],
      officialOrganizationNames: [...new Set(officialOrganizationNames.filter(Boolean))],
      terminology: [...new Set(legacy.terminology ?? [])],
      commonQuestions: [...new Set([...(practical?.commonQuestions ?? []), ...(legacy.commonQuestions ?? [])])]
    };
  });

  const nationalGuideDocuments = nationalGuideDataset.guides.map((guide) => ({
    id: guide.id,
    type: "guide",
    sourceKind: "nationalResourceGuide",
    slug: guide.slug,
    route: `/essentials/${guide.slug}`,
    title: guide.title,
    summary: guide.summary,
    contentDepth: "practical",
    keywords: [...guide.keywords, ...guide.subcategories],
    city: null,
    cityId: null,
    province: null,
    provinceId: null,
    municipalityId: null,
    locationScope: "national",
    country: "NL",
    categories: [guide.category],
    intents: guide.intents,
    languages: guide.languages,
    nationalFallback: true,
    qualityScore: guide.qualityScore,
    verifiedAt: nationalGuideDataset.verifiedAt,
    officialSourceUrls: guide.officialSources.map((source) => source.url),
    relatedOrganizationIds: [],
    narrowCategory: guide.subcategories[0] ?? guide.category,
    organization: guide.officialSources.map((source) => source.publisher).join(", "),
    audienceProfiles: guide.applicableProfiles,
    numberedSteps: guide.sections.steps,
    requiredDocuments: guide.sections.documents,
    checklist: guide.sections.steps,
    tips: [guide.sections.localDifferences],
    faqAnswers: [guide.sections.cost, guide.sections.timing, ...guide.sections.problems],
    whenYouNeedIt: [guide.sections.who],
    tags: [...guide.subcategories, ...guide.relatedTopics],
    synonyms: Object.values(guide.synonyms).flat(),
    officialOrganizationNames: guide.officialSources.map((source) => source.publisher),
    terminology: guide.subcategories,
    commonQuestions: []
  }));

  const categoryDocuments = categories.map((category) => {
    const metadata = categorySearchMetadata[category.slug] ?? {};
    const domain = lifeDomainBySlug.get(category.slug);
    const domainAliases = domain ? Object.values(domain.aliases).flat() : [];
    const domainIntentTerms = domain?.intents.flatMap((intent) => intent.terms) ?? [];
    return {
      id: category.id,
      type: "category",
      sourceKind: "contentCategory",
      slug: category.slug,
      route: category.route,
      title: category.title,
      summary: category.summary,
      keywords: [category.title, category.slug, ...domainIntentTerms],
      city: null,
      cityId: null,
      province: null,
      provinceId: null,
      municipalityId: null,
      locationScope: "national",
      country: "NL",
      categories: [category.slug],
      intents: [...new Set([category.slug, ...(domain?.intents.map((intent) => intent.id) ?? [])])],
      languages: domain ? Object.keys(domain.aliases) : ["en"],
      nationalFallback: true,
      qualityScore: domain ? 95 : 62,
      verifiedAt: generatedAt,
      officialSourceUrls: domain?.officialSources.map((source) => source.url) ?? [],
      relatedOrganizationIds: [],
      narrowCategory: category.slug,
      organization: null,
      audienceProfiles: domain?.profiles ?? [],
      numberedSteps: domain?.startHere ?? [],
      requiredDocuments: [],
      checklist: [],
      tips: [],
      faqAnswers: [],
      whenYouNeedIt: [],
      tags: [],
      synonyms: [...new Set([...(metadata.synonyms ?? []), ...domainAliases, ...domainIntentTerms])],
      officialOrganizationNames: domain?.officialSources.map((source) => source.name) ?? [],
      terminology: metadata.terminology ?? [],
      commonQuestions: []
    };
  });

  const utilityDocuments = searchableUtilityPages.map((page) => ({
    ...page,
    city: null,
    cityId: null,
    province: null,
    provinceId: null,
    municipalityId: null,
    locationScope: page.id === "page.emergency" ? "emergency" : "national",
    country: "NL",
    intents: page.id === "page.emergency" ? [...new Set([...page.categories, "emergency"])] : page.categories,
    languages: ["en"],
    nationalFallback: true,
    qualityScore: 82,
    verifiedAt: generatedAt,
    officialSourceUrls: [],
    relatedOrganizationIds: [],
    narrowCategory: null,
    organization: null,
    audienceProfiles: [],
    numberedSteps: [],
    requiredDocuments: [],
    checklist: [],
    tips: [],
    faqAnswers: [],
    whenYouNeedIt: [],
    tags: [],
    officialOrganizationNames: []
  }));

  const municipalityDocuments = geography.municipalities.map((municipality) => ({
    id: `municipality.${municipality.code.toLocaleLowerCase("en")}`,
    type: "municipality",
    sourceKind: "officialMunicipalityDirectory",
    slug: municipality.slug,
    route: `/municipalities/${municipality.slug}`,
    title: municipality.name,
    summary: `Official 2026 municipality entry in ${municipality.provinceName}, containing ${municipality.settlements.length} BAG settlement${municipality.settlements.length === 1 ? "" : "s"}.`,
    keywords: [municipality.code, municipality.administrativeSeat ?? "", ...municipality.settlements.map((settlement) => settlement.name)].filter(Boolean),
    city: municipality.name,
    cityId: municipality.slug,
    province: municipality.provinceName,
    provinceId: municipality.provinceSlug,
    municipalityId: canonicalMunicipalityId(municipality.slug),
    locationScope: "municipality",
    country: "NL",
    categories: [],
    intents: ["government", "municipal-services"],
    languages: ["en"],
    nationalFallback: false,
    qualityScore: municipality.officialWebsite ? 76 : 62,
    verifiedAt: municipality.sourceCheckedAt,
    officialSourceUrls: [municipality.officialWebsite].filter(Boolean),
    relatedOrganizationIds: [],
    narrowCategory: null,
    organization: `Municipality of ${municipality.name}`,
    audienceProfiles: [],
    numberedSteps: [],
    requiredDocuments: [],
    checklist: [],
    tips: [],
    faqAnswers: [],
    whenYouNeedIt: [],
    tags: ["municipality", "gemeente", "local government"],
    synonyms: [`Gemeente ${municipality.name}`, municipality.administrativeSeat ?? ""].filter(Boolean),
    officialOrganizationNames: [`Municipality of ${municipality.name}`],
    terminology: ["municipality", "gemeente", "BAG woonplaats"],
    commonQuestions: [`Which municipality contains ${municipality.name}?`]
  }));

  const provinceDocuments = geography.provinces.map((province) => ({
    id: `province.${province.code.toLocaleLowerCase("en")}`,
    type: "province",
    sourceKind: "officialProvinceDirectory",
    slug: province.slug,
    route: province.route,
    title: province.name,
    summary: `Official province directory with ${province.municipalityCount} municipalities and ${province.settlementCount} BAG settlements.`,
    keywords: [
      province.code,
      ...geography.municipalities
        .filter((municipality) => municipality.provinceCode === province.code)
        .map((municipality) => municipality.name)
    ],
    city: null,
    cityId: null,
    province: province.name,
    provinceId: province.slug,
    municipalityId: null,
    locationScope: "province",
    country: "NL",
    categories: [],
    intents: ["government"],
    languages: ["en"],
    nationalFallback: false,
    qualityScore: province.officialWebsite ? 76 : 62,
    verifiedAt: province.sourceCheckedAt,
    officialSourceUrls: [province.officialWebsite].filter(Boolean),
    relatedOrganizationIds: [],
    narrowCategory: null,
    organization: `Province of ${province.name}`,
    audienceProfiles: [],
    numberedSteps: [],
    requiredDocuments: [],
    checklist: [],
    tips: [],
    faqAnswers: [],
    whenYouNeedIt: [],
    tags: ["province", "provincie", "regional government"],
    synonyms: [`Provincie ${province.name}`],
    officialOrganizationNames: [`Province of ${province.name}`],
    terminology: ["province", "provincie", "municipality"],
    commonQuestions: []
  }));

  return {
    schemaVersion: 3,
    generatedAt,
    datasetFingerprint,
    locale: "en",
    geographyEffectiveDate: geography.effectiveDate,
    documents: [...entityDocuments, ...nationalGuideDocuments, ...categoryDocuments, ...provinceDocuments, ...municipalityDocuments, ...utilityDocuments]
  };
}

export function buildPublicDataset(runtime, { verifyChecksum = true } = {}) {
  if (!runtime || runtime.mode !== "production") {
    throw new Error("Public content generation requires a canonical dataset with mode=production.");
  }
  if (runtime.schemaVersion !== 1) {
    throw new Error(`Unsupported canonical schemaVersion: ${String(runtime.schemaVersion)}.`);
  }
  if (verifyChecksum) assertCanonicalRuntimeChecksum(runtime);

  const releases = Array.isArray(runtime.releases) ? runtime.releases : [];
  const publishedReleases = releases.filter((release) => release?.status === "published");
  const publishedReleaseIds = new Set(publishedReleases.map((release) => release.id));
  if (publishedReleaseIds.size === 0) throw new Error("No published canonical releases are available.");

  const sourceEntities = Array.isArray(runtime.entities) ? runtime.entities : [];
  const accepted = sourceEntities.filter((entity) => isPublishableEntity(entity, publishedReleaseIds));

  const rawByType = new Map();
  for (const entity of accepted) {
    const type = entityTypeFor(entity.kind);
    const records = rawByType.get(type) ?? [];
    records.push(entity);
    rawByType.set(type, records);
  }

  const slugById = new Map();
  for (const records of rawByType.values()) {
    const assigned = assignStableSlugs(records, (record) => {
      const identifierSlug = String(record.id ?? "").split(".").slice(1).join("-");
      return identifierSlug || record.title;
    });
    for (const [id, slug] of assigned) slugById.set(id, slug);
  }

  const entities = accepted
    .map((entity) => sanitizeEntity(entity, slugById.get(entity.id)))
    .sort((left, right) => left.title.localeCompare(right.title) || left.id.localeCompare(right.id));
  const guideIds = new Set(entities.filter((entity) => entity.type === "guide").map((entity) => entity.id));
  for (const entity of entities) {
    if (!entity.practicalGuide) continue;
    const unresolved = entity.practicalGuide.relatedGuideIds.filter((id) => !guideIds.has(id));
    if (unresolved.length > 0) {
      throw new Error(`Published practical guide ${entity.id} references unpublished related guides: ${unresolved.join(", ")}`);
    }
  }
  const cities = entities.filter((entity) => entity.type === "city");
  const guides = entities.filter((entity) => entity.type === "guide");
  const organizations = entities.filter((entity) => entity.type === "organization");
  const places = entities.filter((entity) => entity.type === "place");
  const categories = buildCategories(entities.filter((entity) => entity.type !== "city"));
  const provinces = buildProvinces(entities);
  const citiesById = new Map(cities.map((city) => [city.cityId, city]));
  const provincesById = new Map(provinces.map((province) => [province.slug, province]));

  const generatedAt = cleanDate(runtime.generatedAt);
  if (!generatedAt) throw new Error("Canonical dataset generatedAt is invalid.");

  const content = {
    schemaVersion: 1,
    generatedAt,
    datasetFingerprint: cleanText(runtime.datasetFingerprint, 160),
    language: "en",
    fallbackLanguage: "en",
    publishedReleaseIds: [...publishedReleaseIds].sort(),
    stats: {
      entities: entities.length,
      cities: cities.length,
      guides: guides.length,
      practicalGuides: guides.filter((guide) => guide.contentDepth === "practical").length,
      summaryGuides: guides.filter((guide) => guide.contentDepth === "summary").length,
      organizations: organizations.length,
      places: places.length,
      categories: categories.length,
      provinces: provinces.length
    },
    entities,
    cities,
    guides,
    organizations,
    places,
    categories,
    provinces
  };
  const search = buildSearchIndex(
    entities,
    categories,
    citiesById,
    provincesById,
    generatedAt,
    content.datasetFingerprint
  );
  const provenance = {
    schemaVersion: 1,
    generatedAt,
    generatorVersion: 1,
    source: "../../YouNew/Resources/Data/younew-runtime-data.json",
    sourceMode: runtime.mode,
    sourceSchemaVersion: runtime.schemaVersion,
    datasetFingerprint: content.datasetFingerprint,
    sourceOutputChecksum: cleanText(runtime.outputChecksum, 160),
    acceptedReleaseIds: content.publishedReleaseIds,
    publicationRules: {
      datasetMode: "production",
      entityKinds: Object.keys(entityTypeByKind).sort(),
      releaseStatus: "published",
      recordLifecycleStatus: "published",
      recordVerificationStatus: "verified",
      sourceStatus: "verified_opened"
    },
    counts: {
      sourceRecords: sourceEntities.length,
      acceptedRecords: entities.length,
      excludedRecords: sourceEntities.length - entities.length
    }
  };

  return { content, search, provenance };
}

async function writeJSON(filePath, value) {
  await mkdir(dirname(filePath), { recursive: true });
  await writeFile(filePath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

export async function generatePublicContent(sourcePath = paths.source) {
  const runtime = JSON.parse(await readFile(sourcePath, "utf8"));
  const outputs = buildPublicDataset(runtime);
  await Promise.all([
    writeJSON(paths.content, outputs.content),
    writeJSON(paths.search, outputs.search),
    writeJSON(paths.provenance, outputs.provenance)
  ]);
  return outputs;
}

const invokedPath = process.argv[1] ? pathToFileURL(resolve(process.argv[1])).href : null;
if (invokedPath === import.meta.url) {
  const { content, provenance } = await generatePublicContent();
  process.stdout.write(
    `Generated ${content.stats.entities} public records from ${provenance.acceptedReleaseIds.join(", ")}.\n`
  );
}
