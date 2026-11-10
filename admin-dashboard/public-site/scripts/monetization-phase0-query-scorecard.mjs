import { readFile } from "node:fs/promises";

import { rankSearchDocuments } from "../src/lib/search/rank.ts";

const searchIndex = JSON.parse(await readFile(new URL("../public/data/search-index.json", import.meta.url), "utf8"));

const cases = [
  ["BSN", "national.documents"],
  ["DigiD", "national.documents"],
  ["gemeente registration", "national.documents"],
  ["huisarts", "national.healthcare"],
  ["health insurance", "national.healthcare"],
  ["rental contract", "national.housing"],
  ["landlord problem", "national.housing"],
  ["work without Dutch", "national.work"],
  ["taxes", "national.finance"],
  ["toeslagen", "national.finance"],
  ["debt help", "national.finance"],
  ["bank account", "national.finance"],
  ["SIM card", "national.telecom"],
  ["home internet", "national.telecom"],
  ["OV-chipkaart", "national.transport"],
  ["diploma recognition", "national.education"],
  ["Dutch language course", "national.education"],
  ["residence permit", "national.documents"],
  ["Dutch citizenship", "national.documents"],
  ["register a pet", "national.pets"],
  ["veterinarian", "national.pets"],
  ["fines", "national.rules-fines"],
  ["emergency", "page.emergency"],
  ["childcare", "national.family"],
  ["pregnancy midwife", "national.healthcare"],
  ["mental health", "national.healthcare"],
  ["register with gemeente in Leiden", "national.documents"],
  ["find a huisarts in Leiden", "national.healthcare"],
  ["rental contract in Leiden", "national.housing"],
  ["work without Dutch in Leiden", "national.work"],
  ["debt help in Leiden", "national.finance"],
  ["emergency help in Leiden", "page.emergency"],
  ["register with gemeente in Rotterdam", "national.documents"],
  ["find a huisarts in Rotterdam", "national.healthcare"],
  ["rental contract in Rotterdam", "national.housing"],
  ["work without Dutch in Rotterdam", "national.work"],
  ["debt help in Rotterdam", "national.finance"],
  ["emergency help in Rotterdam", "page.emergency"],
  ["register with gemeente in Utrecht", "national.documents"],
  ["find a huisarts in Utrecht", "national.healthcare"],
  ["rental contract in Utrecht", "national.housing"],
  ["work without Dutch in Utrecht", "national.work"],
  ["debt help in Utrecht", "national.finance"],
  ["emergency help in Utrecht", "page.emergency"],
  ["register with gemeente in Eindhoven", "national.documents"],
  ["find a huisarts in Eindhoven", "national.healthcare"],
  ["rental contract in Eindhoven", "national.housing"],
  ["work without Dutch in Eindhoven", "national.work"],
  ["debt help in Eindhoven", "national.finance"],
  ["emergency help in Eindhoven", "page.emergency"]
];

const rows = cases.map(([query, requiredDestination], index) => {
  const results = rankSearchDocuments(searchIndex.documents, query, { limit: 5 });
  const destinationRank = results.findIndex(({ document }) => document.id === requiredDestination);
  const top = results[0]?.document;
  return {
    id: index + 1,
    query,
    requiredDestination,
    actionable: destinationRank >= 0,
    destinationRank: destinationRank >= 0 ? destinationRank + 1 : null,
    resultCount: results.length,
    topId: top?.id ?? null,
    topTitle: top?.title ?? null,
    topRoute: top?.route ?? null
  };
});

const actionable = rows.filter((row) => row.actionable).length;
const zeroResults = rows.filter((row) => row.resultCount === 0).length;
const report = {
  schemaVersion: 1,
  searchIndexSchemaVersion: searchIndex.schemaVersion,
  searchDocumentCount: searchIndex.documents.length,
  totals: {
    queries: rows.length,
    actionable,
    actionablePercent: Number(((actionable / rows.length) * 100).toFixed(1)),
    zeroResults
  },
  rows
};

if (rows.length !== 50) throw new Error(`Expected 50 mandatory queries, received ${rows.length}.`);
console.log(JSON.stringify(report, null, 2));
