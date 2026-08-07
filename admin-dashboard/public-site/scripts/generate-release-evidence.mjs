import { createHash } from "node:crypto";
import { readFile, writeFile } from "node:fs/promises";

const root = new URL("../", import.meta.url);

async function readJson(path) {
  return JSON.parse(await readFile(new URL(path, root), "utf8"));
}

function latestDate(values) {
  return values
    .filter((value) => /^\d{4}-\d{2}-\d{2}$/.test(value ?? ""))
    .sort()
    .at(-1);
}

const [publicContent, nationalGuidePack, geography, searchIndexBytes, searchQa, baseStatus] = await Promise.all([
  readJson("src/generated/public-content.json"),
  readJson("src/content/national-guides.json"),
  readJson("src/generated/netherlands-geography.json"),
  readFile(new URL("public/data/search-index.json", root)),
  readJson("../../docs/reports/SEARCH_QA_MATRIX.json"),
  readJson("src/config/status.json")
]);

const searchIndexSha256 = createHash("sha256").update(searchIndexBytes).digest("hex");
if (searchQa.status !== "PASS" || searchQa.evidence?.searchIndexSha256 !== searchIndexSha256 || searchQa.totals?.failed !== 0) {
  throw new Error("Release evidence cannot be generated from a stale or failing search QA artifact.");
}

const localRecords = publicContent.stats?.entities ?? publicContent.entities?.length ?? 0;
const nationalGuides = nationalGuidePack.guides?.length ?? 0;
const municipalityRoutes = geography.stats?.municipalities ?? geography.municipalities?.length ?? 0;
const publishedRecords = localRecords + nationalGuides;
const asOf = latestDate([
  nationalGuidePack.verifiedAt,
  ...publicContent.entities.map((entity) => entity.updatedAt),
  ...publicContent.entities.flatMap((entity) => entity.sources?.map((source) => source.checkedAt) ?? [])
]);

if (!asOf || localRecords < 1 || nationalGuides < 1 || municipalityRoutes < 1 || searchQa.totals.passed < 1) {
  throw new Error("Release evidence is missing required governed metrics.");
}

const releaseEvidence = {
  schemaVersion: 1,
  asOf,
  metrics: {
    publishedRecords,
    localRecords,
    nationalGuides,
    municipalityRoutes,
    searchQualityChecks: searchQa.totals.passed
  },
  searchQuality: {
    status: searchQa.status,
    searchIndexSha256,
    failedChecks: searchQa.totals.failed
  },
  releaseGates: {
    liveMonitoring: false,
    authenticatedAdminE2E: false,
    backupRestore: false
  }
};

const statusSnapshot = {
  ...baseStatus,
  checkedAt: asOf,
  website: {
    ...baseStatus.website,
    summary: `The production website is available. The released search index passed ${searchQa.totals.passed.toLocaleString("en-US")} governed quality checks, including national fallbacks for all ${municipalityRoutes} municipalities.`
  },
  content: {
    ...baseStatus.content,
    asOf,
    summary: `The governed public catalogue contains ${localRecords} published local records and ${nationalGuides} national practical guides (${publishedRecords} published records across these collections). Counts are generated from the released content artifacts.`
  },
  limitations: [
    ...baseStatus.limitations.filter((item) => !/static snapshot|live uptime monitoring/i.test(item)),
    "This page is a generated release snapshot and does not provide live uptime monitoring.",
    "Authenticated Admin E2E and backup-and-restore remain release gates; this snapshot does not claim they are closed."
  ]
};

await Promise.all([
  writeFile(new URL("src/generated/release-evidence.json", root), `${JSON.stringify(releaseEvidence, null, 2)}\n`),
  writeFile(new URL("src/generated/status.json", root), `${JSON.stringify(statusSnapshot, null, 2)}\n`)
]);

console.log(
  `Release evidence generated: ${publishedRecords} records, ${nationalGuides} national guides, ${municipalityRoutes} municipalities, ${searchQa.totals.passed} search checks.`
);
