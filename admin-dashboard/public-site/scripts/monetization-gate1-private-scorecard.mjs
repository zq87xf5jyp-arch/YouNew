import { readFile } from "node:fs/promises";

import { rankSearchDocuments } from "../src/lib/search/rank.ts";

const publicIndex = JSON.parse(
  await readFile(new URL("../public/data/search-index.json", import.meta.url), "utf8")
);
const qaCollection = JSON.parse(
  await readFile(
    new URL("../../../DataProject/staging/practical-guides-wave-1.json", import.meta.url),
    "utf8"
  )
);

const classification = {
  "guide.getting-a-bsn": ["documents", "government", "integration"],
  "guide.applying-for-digid": ["documents", "government"],
  "guide.residence-permits": ["documents", "government", "immigration"],
  "guide.dutch-health-insurance": ["healthcare", "insurance"],
  "guide.finding-a-huisarts": ["healthcare"],
  "guide.emergency-numbers-and-urgent-help": ["emergency", "healthcare", "safety"],
  "guide.renting-a-home": ["housing"],
  "guide.temporary-housing": ["housing"],
  "guide.reporting-housing-defects": ["housing", "legal-help"],
  "guide.finding-work": ["work"],
  "guide.understanding-an-employment-contract": ["work", "legal-help"],
  "guide.taxes-and-allowances": ["finance", "taxes", "benefits"],
  "guide.debt-help": ["finance", "debt-help", "legal-help"],
  "guide.opening-a-dutch-bank-account": ["finance", "banking"],
  "guide.sim-card-and-home-internet": ["telecom", "internet", "daily-life"],
  "guide.using-public-transport": ["transport", "daily-life"],
  "guide.diploma-recognition": ["education", "work"],
  "guide.dutch-integration-exams": ["education", "language-learning", "integration"],
  "guide.family-children-and-school-registration": ["family", "children", "education"],
  "guide.pets-and-veterinary-care": ["pets", "daily-life"]
};

const cases = [
  ["BSN", "national.documents", "guide.getting-a-bsn"],
  ["DigiD", "national.documents", "guide.applying-for-digid"],
  ["gemeente registration", "national.documents", "guide.getting-a-bsn"],
  ["huisarts", "national.healthcare", "guide.finding-a-huisarts"],
  ["health insurance", "national.healthcare", "guide.dutch-health-insurance"],
  ["rental contract", "national.housing", "guide.renting-a-home"],
  ["landlord problem", "national.housing", "guide.reporting-housing-defects"],
  ["work without Dutch", "national.work", "guide.finding-work"],
  ["taxes", "national.finance", "guide.taxes-and-allowances"],
  ["toeslagen", "national.finance", "guide.taxes-and-allowances"],
  ["debt help", "national.finance", "guide.debt-help"],
  ["bank account", "national.finance", "guide.opening-a-dutch-bank-account"],
  ["SIM card", "national.telecom", "guide.sim-card-and-home-internet"],
  ["home internet", "national.telecom", "guide.sim-card-and-home-internet"],
  ["OV-chipkaart", "national.transport", "guide.using-public-transport"],
  ["diploma recognition", "national.education", "guide.diploma-recognition"],
  ["Dutch language course", "national.education", "guide.dutch-integration-exams"],
  ["residence permit", "national.documents", "guide.residence-permits"],
  ["Dutch citizenship", "national.documents", null],
  ["register a pet", "national.pets", "guide.pets-and-veterinary-care"],
  ["veterinarian", "national.pets", "guide.pets-and-veterinary-care"],
  ["fines", "national.rules-fines", null],
  ["emergency", "page.emergency", "guide.emergency-numbers-and-urgent-help"],
  ["childcare", "national.family", "guide.family-children-and-school-registration"],
  ["pregnancy midwife", "national.healthcare", null],
  ["mental health", "national.healthcare", null],
  ["register with gemeente in Leiden", "national.documents", "guide.getting-a-bsn", "leiden"],
  ["find a huisarts in Leiden", "national.healthcare", "guide.finding-a-huisarts", "leiden"],
  ["rental contract in Leiden", "national.housing", "guide.renting-a-home", "leiden"],
  ["work without Dutch in Leiden", "national.work", "guide.finding-work", "leiden"],
  ["debt help in Leiden", "national.finance", "guide.debt-help", "leiden"],
  ["emergency help in Leiden", "page.emergency", "guide.emergency-numbers-and-urgent-help", "leiden"],
  ["register with gemeente in Rotterdam", "national.documents", "guide.getting-a-bsn", "rotterdam"],
  ["find a huisarts in Rotterdam", "national.healthcare", "guide.finding-a-huisarts", "rotterdam"],
  ["rental contract in Rotterdam", "national.housing", "guide.renting-a-home", "rotterdam"],
  ["work without Dutch in Rotterdam", "national.work", "guide.finding-work", "rotterdam"],
  ["debt help in Rotterdam", "national.finance", "guide.debt-help", "rotterdam"],
  ["emergency help in Rotterdam", "page.emergency", "guide.emergency-numbers-and-urgent-help", "rotterdam"],
  ["register with gemeente in Utrecht", "national.documents", "guide.getting-a-bsn", "utrecht"],
  ["find a huisarts in Utrecht", "national.healthcare", "guide.finding-a-huisarts", "utrecht"],
  ["rental contract in Utrecht", "national.housing", "guide.renting-a-home", "utrecht"],
  ["work without Dutch in Utrecht", "national.work", "guide.finding-work", "utrecht"],
  ["debt help in Utrecht", "national.finance", "guide.debt-help", "utrecht"],
  ["emergency help in Utrecht", "page.emergency", "guide.emergency-numbers-and-urgent-help", "utrecht"],
  ["register with gemeente in Eindhoven", "national.documents", "guide.getting-a-bsn", "eindhoven"],
  ["find a huisarts in Eindhoven", "national.healthcare", "guide.finding-a-huisarts", "eindhoven"],
  ["rental contract in Eindhoven", "national.housing", "guide.renting-a-home", "eindhoven"],
  ["work without Dutch in Eindhoven", "national.work", "guide.finding-work", "eindhoven"],
  ["debt help in Eindhoven", "national.finance", "guide.debt-help", "eindhoven"],
  ["emergency help in Eindhoven", "page.emergency", "guide.emergency-numbers-and-urgent-help", "eindhoven"]
];

function text(block) {
  return typeof block?.text === "string" ? block.text : "";
}

function qaSearchDocument(item) {
  const guide = item.practical_guide;
  const categories = classification[guide.id];
  if (!categories) throw new Error(`Private search classification missing for ${guide.id}.`);
  if (guide.status !== "qa" || guide.reviewer !== null) {
    throw new Error(`Private search projection requires an unreviewed QA packet: ${guide.id}.`);
  }
  if (guide.publication_gate?.status !== "pending") {
    throw new Error(`Private search projection refuses a non-pending publication gate: ${guide.id}.`);
  }
  return {
    id: guide.id,
    type: "guide",
    sourceKind: "privateQaPracticalGuide",
    slug: guide.slug,
    route: `/__private-search-eval__/${guide.slug}`,
    title: guide.title,
    summary: text(guide.short_summary),
    contentDepth: "practical",
    keywords: [...guide.tags, ...guide.synonyms],
    city: null,
    cityId: null,
    province: null,
    provinceId: null,
    municipalityId: null,
    locationScope: "national",
    country: "NL",
    categories,
    intents: categories,
    languages: [guide.locale],
    nationalFallback: true,
    scope: "national",
    officialSourceURLs: guide.official_sources.map((source) => source.url),
    officialSourceUrls: guide.official_sources.map((source) => source.url),
    qualityScore: 80,
    verifiedAt: guide.verified_at,
    narrowCategory: categories[0],
    organization: null,
    audienceProfiles: guide.audience_profiles,
    numberedSteps: guide.numbered_steps.flatMap((step) => [step.title, step.body]),
    requiredDocuments: guide.required_documents.map(text),
    checklist: guide.checklist.map(text),
    tips: guide.tips.map(text),
    faqAnswers: guide.faqs.flatMap((faq) => [faq.question, faq.answer]),
    whenYouNeedIt: [text(guide.when_you_need_it)],
    tags: guide.tags,
    synonyms: guide.synonyms,
    officialOrganizationNames: guide.official_sources.map((source) => source.publisher),
    terminology: guide.synonyms,
    commonQuestions: guide.common_questions
  };
}

function localIdentity(document) {
  return String(
    document?.municipalityId ??
      document?.cityId ??
      (document?.type === "municipality" ? document.slug : "")
  ).replace(/^municipality\./, "").toLocaleLowerCase("en");
}

function invisibleSubstitution(top, expectedLocation) {
  const localId = localIdentity(top);
  if (!localId) return false;
  if (!expectedLocation) return true;
  return localId !== expectedLocation;
}

function evaluate(documents) {
  const rows = cases.map(([query, publicDestination, qaDestination, expectedLocation], index) => {
    const expectedIds = [publicDestination, qaDestination].filter(Boolean);
    const results = rankSearchDocuments(documents, query, { limit: 5 });
    const destinationRank = results.findIndex(({ document }) => expectedIds.includes(document.id));
    const top = results[0]?.document;
    return {
      id: index + 1,
      query,
      publicDestination,
      qaDestination,
      expectedLocation: expectedLocation ?? null,
      actionable: destinationRank >= 0,
      destinationRank: destinationRank >= 0 ? destinationRank + 1 : null,
      resultCount: results.length,
      topId: top?.id ?? null,
      topTitle: top?.title ?? null,
      topSourceKind: top?.sourceKind ?? null,
      invisibleLocationSubstitution: invisibleSubstitution(top, expectedLocation ?? null)
    };
  });
  const actionable = rows.filter((row) => row.actionable).length;
  return {
    totals: {
      queries: rows.length,
      actionable,
      actionablePercent: Number(((actionable / rows.length) * 100).toFixed(1)),
      zeroResults: rows.filter((row) => row.resultCount === 0).length,
      invisibleLocationSubstitutions: rows.filter((row) => row.invisibleLocationSubstitution).length
    },
    rows
  };
}

function gaps(evaluation) {
  return evaluation.rows
    .filter((row) => !row.actionable || row.invisibleLocationSubstitution)
    .map((row) => ({
      id: row.id,
      query: row.query,
      actionable: row.actionable,
      invisibleLocationSubstitution: row.invisibleLocationSubstitution,
      topId: row.topId,
      topTitle: row.topTitle
    }));
}

if (cases.length !== 50) throw new Error(`Expected 50 mandatory queries, received ${cases.length}.`);
if (qaCollection.status !== "qa" || qaCollection.guides.length !== 20) {
  throw new Error("Private Gate 1 scorecard requires the exact 20-guide QA collection.");
}
if (publicIndex.documents.some((document) => document.sourceKind === "privateQaPracticalGuide")) {
  throw new Error("Private QA guide content leaked into the public search index.");
}

const qaDocuments = qaCollection.guides.map(qaSearchDocument);
const baseline = evaluate(publicIndex.documents);
const projected = evaluate([...publicIndex.documents, ...qaDocuments]);
const report = {
  schemaVersion: 1,
  mode: "private_non_publishing_projection",
  searchIndexSchemaVersion: publicIndex.schemaVersion,
  publicSearchDocumentCount: publicIndex.documents.length,
  privateQaDocumentCount: qaDocuments.length,
  publicationAuthorized: false,
  baseline: baseline.totals,
  projected: projected.totals,
  baselineGaps: gaps(baseline),
  remainingGaps: gaps(projected),
  rows: projected.rows
};

console.log(JSON.stringify(report, null, 2));

if (baseline.totals.actionable !== 32) {
  throw new Error(`Public baseline drifted: expected 32 actionable, received ${baseline.totals.actionable}.`);
}
if (baseline.totals.invisibleLocationSubstitutions !== 0) {
  throw new Error(
    `Public baseline has ${baseline.totals.invisibleLocationSubstitutions} invisible location substitutions.`
  );
}
if (projected.totals.actionable < 45) {
  throw new Error(`Private Gate 1 projection is below 90%: ${projected.totals.actionable}/50.`);
}
if (projected.totals.invisibleLocationSubstitutions !== 0) {
  const substitutions = report.remainingGaps
    .filter((row) => row.invisibleLocationSubstitution)
    .map((row) => row.query)
    .join(", ");
  throw new Error(
    `Private Gate 1 projection has ${projected.totals.invisibleLocationSubstitutions} invisible location substitutions: ${substitutions}.`
  );
}
