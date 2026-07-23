import { createHash } from "node:crypto";
import { readFile, mkdir, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { projectPublishedPracticalGuide } from "./practical-guide.mjs";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const publicSiteRoot = resolve(scriptDirectory, "..");

export const paths = Object.freeze({
  source: resolve(publicSiteRoot, "../../YouNew/Resources/Data/younew-runtime-data.json"),
  content: resolve(publicSiteRoot, "src/generated/public-content.json"),
  search: resolve(publicSiteRoot, "public/data/search-index.json"),
  provenance: resolve(publicSiteRoot, "public/data/content-provenance.json")
});

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

const broadCategoryDefinitions = Object.freeze({
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

  return [...buckets.entries()]
    .filter(([, records]) => records.length > 0)
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
      summary: entity.summary,
      keywords: entity.keywords,
      city: entity.cityId ? citiesById.get(entity.cityId)?.title ?? titleFromSlug(entity.cityId) : null,
      cityId: entity.cityId,
      province: entity.provinceId ? provincesById.get(entity.provinceId)?.title ?? titleFromSlug(entity.provinceId) : null,
      provinceId: entity.provinceId,
      categories: entity.categorySlugs,
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

  const categoryDocuments = categories.map((category) => {
    const metadata = categorySearchMetadata[category.slug] ?? {};
    return {
      id: category.id,
      type: "category",
      sourceKind: "contentCategory",
      slug: category.slug,
      route: category.route,
      title: category.title,
      summary: category.summary,
      keywords: [category.title, category.slug],
      city: null,
      cityId: null,
      province: null,
      provinceId: null,
      categories: [category.slug],
      narrowCategory: category.slug,
      organization: null,
      audienceProfiles: [],
      numberedSteps: [],
      requiredDocuments: [],
      checklist: [],
      tips: [],
      faqAnswers: [],
      whenYouNeedIt: [],
      tags: [],
      synonyms: metadata.synonyms ?? [],
      officialOrganizationNames: [],
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

  return {
    schemaVersion: 2,
    generatedAt,
    datasetFingerprint,
    locale: "en",
    documents: [...entityDocuments, ...categoryDocuments, ...utilityDocuments]
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
