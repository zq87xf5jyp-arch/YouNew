import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

type Coverage = {
  weightedCoverage: number | null;
  taskCount: number;
  sourceArtifact: string;
  tasks: Array<{ id: string; weight: number; coveragePercent: number | null; missing: string[] }>;
};

const [coverage, page, generator] = await Promise.all([
  readFile(new URL("../src/generated/task-coverage.json", import.meta.url), "utf8").then((value) => JSON.parse(value) as Coverage),
  readFile(new URL("../src/app/(admin)/coverage/page.tsx", import.meta.url), "utf8"),
  readFile(new URL("../scripts/generate-task-coverage.mjs", import.meta.url), "utf8")
]);

test("task coverage uses the ten approved tasks and a complete weight denominator", () => {
  assert.equal(coverage.taskCount, 10);
  assert.equal(coverage.tasks.length, 10);
  assert.equal(new Set(coverage.tasks.map((task) => task.id)).size, 10);
  assert.equal(coverage.tasks.reduce((total, task) => total + task.weight, 0), 100);
  assert.ok(coverage.weightedCoverage !== null && coverage.weightedCoverage >= 0 && coverage.weightedCoverage <= 100);
});

test("coverage generator derives evidence from published sources instead of concept numbers", () => {
  assert.match(coverage.sourceArtifact, /national-guides\.json/);
  assert.match(generator, /evaluateGuide/);
  assert.match(generator, /evaluateEmergency/);
  assert.match(generator, /qualityScore/);
  const emergency = coverage.tasks.find((task) => task.id === "emergency");
  assert.ok(emergency);
  assert.ok((emergency.coveragePercent ?? 100) < 100);
  assert.deepEqual(emergency.missing.sort(), ["Checked date", "Requirements or documents"].sort());
});

test("Coverage Dashboard labels unknown live metrics instead of inventing zeros", () => {
  assert.match(page, /Not established/);
  assert.match(page, /feedbackResult\.source === "supabase"/);
  assert.match(page, /Municipality-topic coverage/);
  assert.match(page, /Target hypothesis, not a measured product claim/);
  assert.doesNotMatch(page, /city heatmap.*\d+%/i);
});
