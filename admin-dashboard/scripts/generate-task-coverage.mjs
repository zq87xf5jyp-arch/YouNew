import { readFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";

const guidesPath = fileURLToPath(new URL("../public-site/src/content/national-guides.json", import.meta.url));
const emergencyPath = fileURLToPath(new URL("../public-site/src/app/emergency/page.tsx", import.meta.url));
const outputPath = fileURLToPath(new URL("../src/generated/task-coverage.json", import.meta.url));

const taskDefinitions = [
  { id: "housing", label: "Housing", weight: 14, guideIds: ["national.housing", "national.utilities-moving", "national.consumer-rights"] },
  { id: "work", label: "Work", weight: 13, guideIds: ["national.work", "national.taxes", "national.business-zzp"] },
  { id: "healthcare", label: "Healthcare", weight: 14, guideIds: ["national.healthcare", "national.mental-health", "national.dental-care", "national.medicines", "national.pregnancy"] },
  { id: "documents", label: "Documents", weight: 13, guideIds: ["national.documents", "national.immigration", "national.benefits"] },
  { id: "study", label: "Study", weight: 9, guideIds: ["national.education", "national.family-childcare", "national.immigration"] },
  { id: "daily-life", label: "Daily life", weight: 12, guideIds: ["national.banking", "national.transport", "national.telecom", "national.utilities-moving", "national.rules-fines"] },
  { id: "emergency", label: "Emergency", weight: 10, guideIds: [], special: "emergency-page" },
  { id: "lgbtiq", label: "LGBTIQ+", weight: 5, guideIds: ["national.lgbtiq-support"] },
  { id: "pets", label: "Pets", weight: 4, guideIds: ["national.pets"] },
  { id: "family", label: "Family", weight: 6, guideIds: ["national.family-childcare", "national.pregnancy", "national.benefits"] }
];

const criteria = [
  ["answer", "Verified answer"],
  ["officialSource", "Official source"],
  ["nextAction", "Useful next action"],
  ["requirements", "Requirements or documents"],
  ["checkedDate", "Checked date"],
  ["localDisclosure", "Local-difference disclosure"],
  ["qa", "QA evidence"]
];

function evaluateGuide(guide, datasetVerifiedAt) {
  return {
    answer: Boolean(guide?.summary?.trim() && guide?.sections?.what?.trim()),
    officialSource: Boolean(guide?.officialSources?.length),
    nextAction: Boolean(guide?.sections?.steps?.length),
    requirements: Boolean(guide?.sections?.documents?.length),
    checkedDate: Boolean(datasetVerifiedAt && guide?.officialSources?.every((source) => source.checkedAt)),
    localDisclosure: Boolean(guide?.sections?.localDifferences?.trim()),
    qa: Number(guide?.qualityScore ?? 0) >= 80
  };
}

function evaluateEmergency(source) {
  return {
    answer: source.includes("Emergency help") && source.includes("Use 112 only"),
    officialSource: source.includes("government.nl/topics/emergency-number-112") && source.includes("politie.nl/en/contact"),
    nextAction: source.includes('href="tel:112"'),
    requirements: false,
    checkedDate: false,
    localDisclosure: source.includes("Phone numbers differ by region"),
    qa: true
  };
}

function score(checks) {
  const values = Object.values(checks);
  return Math.round((values.filter(Boolean).length / values.length) * 100);
}

const dataset = JSON.parse(await readFile(guidesPath, "utf8"));
const emergencySource = await readFile(emergencyPath, "utf8");
const guidesById = new Map(dataset.guides.map((guide) => [guide.id, guide]));

const tasks = taskDefinitions.map((task) => {
  const records = task.special === "emergency-page"
    ? [{ id: "page.emergency", title: "Emergency help", checks: evaluateEmergency(emergencySource) }]
    : task.guideIds.map((id) => {
        const guide = guidesById.get(id);
        return { id, title: guide?.title ?? id, checks: guide ? evaluateGuide(guide, dataset.verifiedAt) : Object.fromEntries(criteria.map(([key]) => [key, false])) };
      });
  const available = records.filter((record) => record.checks.answer).length;
  const taskScore = records.length ? Math.round(records.reduce((total, record) => total + score(record.checks), 0) / records.length) : null;
  const missing = criteria.flatMap(([key, label]) => records.some((record) => !record.checks[key]) ? [label] : []);
  return {
    id: task.id,
    label: task.label,
    weight: task.weight,
    requiredSolutions: records.length,
    availableSolutions: available,
    coveragePercent: taskScore,
    evidenceState: taskScore === null ? "not_established" : taskScore === 100 ? "established" : "partial",
    missing,
    records
  };
});

const establishedTasks = tasks.filter((task) => task.coveragePercent !== null);
const totalWeight = establishedTasks.reduce((total, task) => total + task.weight, 0);
const weightedCoverage = totalWeight
  ? Math.round(establishedTasks.reduce((total, task) => total + task.coveragePercent * task.weight, 0) / totalWeight)
  : null;

const result = {
  schemaVersion: 1,
  generatedAt: new Date().toISOString(),
  sourceArtifact: "public-site/src/content/national-guides.json + public-site/src/app/emergency/page.tsx",
  datasetVerifiedAt: dataset.verifiedAt,
  formula: "Weighted mean of seven binary useful-solution criteria across the required published solutions for each top-level task.",
  formulaVersion: 1,
  criteria: criteria.map(([key, label]) => ({ key, label })),
  weightedCoverage,
  establishedTaskCount: establishedTasks.length,
  taskCount: tasks.length,
  tasks
};

await writeFile(outputPath, `${JSON.stringify(result, null, 2)}\n`, "utf8");
console.log(`Generated ${outputPath}`);
