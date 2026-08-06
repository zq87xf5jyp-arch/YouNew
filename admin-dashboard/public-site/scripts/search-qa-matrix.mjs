import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { normalizeSearchText, rankSearchDocuments } from "../src/lib/search/rank.ts";
import { resolveSearchLocation } from "../src/lib/search/geography.ts";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const indexPath = join(root, "public/data/search-index.json");
const geographyPath = join(root, "src/generated/netherlands-geography.json");
const guidesPath = join(root, "src/content/national-guides.json");
const reportDirectory = join(root, "../../docs/reports");
const reportJsonPath = join(reportDirectory, "SEARCH_QA_MATRIX.json");
const reportMarkdownPath = join(reportDirectory, "SEARCH_QA_MATRIX.md");

const indexBytes = await readFile(indexPath);
const index = JSON.parse(indexBytes);
const geography = JSON.parse(await readFile(geographyPath, "utf8"));
const nationalGuides = JSON.parse(await readFile(guidesPath, "utf8"));

assert.equal(index.schemaVersion, 3, "search QA requires search index schema v3");
assert.equal(geography.provinces.length, 12, "the official geography must contain 12 provinces");
assert.equal(geography.municipalities.length, 342, "the official 2026 geography must contain 342 municipalities");

const groups = [
  { id: "housing", expected: "national.housing", representative: "rent", queries: ["rent", "housing", "apartment", "room", "huur", "woning", "аренда", "квартира"] },
  { id: "work", expected: "national.work", representative: "work", queries: ["work", "job", "vacancy", "work contract", "salary", "werk", "baan", "работа", "вакансия"] },
  { id: "healthcare", expected: "national.healthcare", representative: "huisarts", queries: ["doctor", "huisarts", "hospital", "dentist", "pharmacy", "zorgverzekering", "врач", "аптека"] },
  { id: "documents", expected: "national.documents", representative: "BSN", queries: ["BSN", "DigiD", "registration", "residence permit", "inschrijving", "регистрация", "ВНЖ"] },
  { id: "education", expected: "national.education", representative: "Dutch course", queries: ["Dutch course", "language school", "university", "MBO", "study", "taalschool", "школа", "курсы"] },
  { id: "telecom", expected: "national.telecom", representative: "SIM card", queries: ["SIM", "prepaid", "eSIM", "phone contract", "internet", "simkaart", "сим-карта"] },
  { id: "rules-fines", expected: "national.rules-fines", representative: "parking fine", queries: ["parking fine", "traffic rules", "bicycle rules", "waste fine", "parkeerboete", "fietsregels", "штраф за парковку"] },
  { id: "lgbtiq-support", expected: "national.lgbtiq-support", representative: "LGBTQ support", queries: ["LGBTQ support", "queer support", "trans support", "LHBTI hulp", "discriminatie melden", "ЛГБТ поддержка", "гомофобия"] }
];
const profiles = ["tourist", "student", "expat", "refugee", "worker", "resident"];
const failures = [];
let checks = 0;

function evaluate({ dimension, context, query, expected, options = {}, requireFirst = false }) {
  checks += 1;
  const results = rankSearchDocuments(index.documents, query, { ...options, limit: 8 });
  const topIds = results.map(({ document }) => document.id);
  const passed = results.length > 0 && (requireFirst ? topIds[0] === expected : topIds.includes(expected));
  if (!passed) failures.push({ dimension, context, query, expected, topIds });
  return { query, expected, topIds, passed };
}

const baseline = groups.flatMap((group) => group.queries.map((query) => evaluate({
  dimension: "baseline-query",
  context: group.id,
  query,
  expected: group.expected
})));

const provinces = geography.provinces.map((province) => {
  const rows = groups.map((group) => evaluate({
    dimension: "province",
    context: province.slug,
    query: group.representative,
    expected: group.expected,
    options: { filters: { provinceId: province.slug } }
  }));
  return { id: province.slug, name: province.name, checks: rows.length, passed: rows.every((row) => row.passed) };
});

const municipalities = geography.municipalities.map((municipality) => {
  const rows = groups.map((group) => evaluate({
    dimension: "municipality",
    context: municipality.slug,
    query: group.representative,
    expected: group.expected,
    options: { filters: { cityId: municipality.slug } }
  }));
  return {
    id: municipality.slug,
    name: municipality.name,
    province: municipality.provinceSlug,
    checks: rows.length,
    passed: rows.every((row) => row.passed)
  };
});

const profileRows = profiles.map((profile) => {
  const rows = groups.map((group) => evaluate({
    dimension: "profile",
    context: profile,
    query: group.representative,
    expected: group.expected,
    options: { preferredProfile: profile }
  }));
  return { profile, checks: rows.length, passed: rows.every((row) => row.passed) };
});

const combinedScenarios = [
  ["Rent + Den Haag + Worker", "rent", "s-gravenhage", "worker", "national.housing"],
  ["housing rent + Den Haag + Worker", "housing rent", "s-gravenhage", "worker", "national.housing"],
  ["work + Leiden", "work", "leiden", "worker", "national.work"],
  ["huisarts + Rotterdam", "huisarts", "rotterdam", "resident", "national.healthcare"],
  ["Dutch school + Groningen", "Dutch school", "groningen", "student", "national.education"],
  ["BSN + Eindhoven", "BSN", "eindhoven", "expat", "national.documents"],
  ["SIM card + Maastricht", "SIM card", "maastricht", "tourist", "national.telecom"],
  ["parking fine + Utrecht", "parking fine", "utrecht", "resident", "national.rules-fines"],
  ["LGBTQ support + Groningen", "LGBTQ support", "groningen", "student", "national.lgbtiq-support"]
].map(([label, query, cityId, preferredProfile, expected]) => evaluate({
  dimension: "city-profile",
  context: label,
  query,
  expected,
  requireFirst: true,
  options: { filters: { cityId }, preferredProfile }
}));

const aliases = [
  "Den Haag rent", "The Hague rent", "’s-Gravenhage rent", "s Gravenhage rent", "s-Gravenhage rent", "DenHaag rent"
].map((query) => {
  const location = resolveSearchLocation(index.documents, normalizeSearchText(query), normalizeSearchText);
  const result = evaluate({ dimension: "city-alias", context: "s-gravenhage", query, expected: "national.housing", requireFirst: true });
  const canonical = location?.canonicalId ?? null;
  const passed = result.passed && canonical === "s-gravenhage";
  if (!passed && result.passed) failures.push({ dimension: "city-alias", context: "s-gravenhage", query, expected: "canonical s-gravenhage", topIds: [String(canonical)] });
  return { query, canonical, topIds: result.topIds, passed };
});

const typoRows = [
  ["houisng", "national.housing"],
  ["vacncy", "national.work"],
  ["huisart", "national.healthcare"],
  ["registraton", "national.documents"],
  ["taalschol", "national.education"],
  ["simkart", "national.telecom"],
  ["parkeerboet", "national.rules-fines"],
  ["LGBT suport", "national.lgbtiq-support"]
].map(([query, expected]) => evaluate({ dimension: "typo", context: query, query, expected }));

const guideSourceChecks = nationalGuides.guides.flatMap((guide) => guide.officialSources.map((source) => ({
  guide: guide.id,
  url: source.url,
  checkedAt: source.checkedAt,
  valid: source.url.startsWith("https://") && /^\d{4}-\d{2}-\d{2}$/.test(source.checkedAt)
})));
for (const source of guideSourceChecks) {
  checks += 1;
  if (!source.valid) failures.push({ dimension: "official-source", context: source.guide, query: source.url, expected: "HTTPS and ISO checkedAt", topIds: [] });
}

const report = {
  schemaVersion: 1,
  generatedAt: new Date().toISOString(),
  status: failures.length === 0 ? "PASS" : "FAIL",
  evidence: {
    searchIndexSha256: createHash("sha256").update(indexBytes).digest("hex"),
    searchIndexSchemaVersion: index.schemaVersion,
    searchDocumentCount: index.documents.length,
    nationalGuideCount: nationalGuides.guides.length,
    provinceCount: geography.provinces.length,
    municipalityCount: geography.municipalities.length,
    profileCount: profiles.length
  },
  totals: { checks, passed: checks - failures.length, failed: failures.length },
  dimensions: {
    baseline,
    provinces,
    municipalities,
    profiles: profileRows,
    combinedScenarios,
    aliases,
    typoRows,
    officialSourceMetadata: guideSourceChecks
  },
  failures
};

await mkdir(reportDirectory, { recursive: true });
await writeFile(reportJsonPath, `${JSON.stringify(report, null, 2)}\n`);
const markdown = `# YouNew search QA matrix\n\n` +
  `Generated: ${report.generatedAt}\n\n` +
  `Status: **${report.status}**\n\n` +
  `- Checks: ${report.totals.checks}\n` +
  `- Passed: ${report.totals.passed}\n` +
  `- Failed: ${report.totals.failed}\n` +
  `- Search documents: ${report.evidence.searchDocumentCount}\n` +
  `- Provinces: ${report.evidence.provinceCount}/12\n` +
  `- Municipalities: ${report.evidence.municipalityCount}/342\n` +
  `- Profiles: ${report.evidence.profileCount}\n\n` +
  `## Required production scenarios\n\n` +
  `| Scenario | Result | First result |\n|---|---:|---|\n` +
  combinedScenarios.map((row, index) => `| ${["Rent + Den Haag + Worker", "housing rent + Den Haag + Worker", "work + Leiden", "huisarts + Rotterdam", "Dutch school + Groningen", "BSN + Eindhoven", "SIM card + Maastricht", "parking fine + Utrecht", "LGBTQ support + Groningen"][index]} | ${row.passed ? "PASS" : "FAIL"} | ${row.topIds[0] ?? "none"} |`).join("\n") +
  `\n\n## Failure evidence\n\n${failures.length ? failures.map((failure) => `- ${failure.dimension} / ${failure.context} / ${failure.query}: expected ${failure.expected}; got ${failure.topIds.join(", ") || "zero"}`).join("\n") : "No failures."}\n`;
await writeFile(reportMarkdownPath, markdown);

console.log(`Search QA ${report.status}: ${checks - failures.length}/${checks} checks, ${geography.provinces.length} provinces, ${geography.municipalities.length} municipalities.`);
if (failures.length > 0) process.exitCode = 1;
