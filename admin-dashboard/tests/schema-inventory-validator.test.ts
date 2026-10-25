import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtemp, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

const validator = path.resolve("scripts/validate-admin-schema-inventory.py");
const md5 = (character: string) => character.repeat(32);

async function runValidation(options: {
  before: string;
  after: string;
  reviewed: Record<string, unknown>;
}) {
  const directory = await mkdtemp(path.join(tmpdir(), "younew-schema-review-"));
  const beforePath = path.join(directory, "before.txt");
  const afterPath = path.join(directory, "after.txt");
  const reviewedPath = path.join(directory, "reviewed.json");
  const candidatePath = path.join(directory, "candidate.json");
  const reportPath = path.join(directory, "report.txt");
  await Promise.all([
    writeFile(beforePath, options.before),
    writeFile(afterPath, options.after),
    writeFile(reviewedPath, `${JSON.stringify(options.reviewed)}\n`)
  ]);
  const result = spawnSync("python3", [
    validator,
    beforePath,
    afterPath,
    "--reviewed",
    reviewedPath,
    "--candidate",
    candidatePath,
    "--report",
    reportPath
  ], { encoding: "utf8" });
  return {
    ...result,
    candidate: JSON.parse(await readFile(candidatePath, "utf8")),
    report: await readFile(reportPath, "utf8")
  };
}

test("schema inventory gate accepts only an exact reviewed fingerprint delta", async () => {
  const result = await runValidation({
    before: `policy|public.articles.editor update|${md5("a")}\n`,
    after: `policy|public.articles.editor update|${md5("b")}\nrelation|public.safe_view:v|${md5("c")}\n`,
    reviewed: {
      schemaVersion: 1,
      status: "reviewed",
      removed: {},
      changed: {
        "policy|public.articles.editor update": { before: md5("a"), after: md5("b") }
      },
      added: { "relation|public.safe_view:v": md5("c") }
    }
  });
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.report, /exact_reviewed_delta_match=yes/);
  assert.match(result.report, /verdict=PASS/);
});

test("schema inventory gate rejects a weaker same-name definition and writes the candidate", async () => {
  const result = await runValidation({
    before: `policy|public.articles.editor update|${md5("a")}\n`,
    after: `policy|public.articles.editor update|${md5("d")}\n`,
    reviewed: {
      schemaVersion: 1,
      status: "reviewed",
      removed: {},
      changed: {
        "policy|public.articles.editor update": { before: md5("a"), after: md5("b") }
      },
      added: {}
    }
  });
  assert.equal(result.status, 1);
  assert.equal(result.candidate.changed["policy|public.articles.editor update"].after, md5("d"));
  assert.match(result.report, /exact_reviewed_delta_match=no/);
  assert.match(result.report, /verdict=FAIL/);
});

test("schema inventory gate rejects additions and PUBLIC grants even when named like approved objects", async () => {
  const publicGrant = "table_grant|public.official_link_check_results:PUBLIC:DELETE";
  const result = await runValidation({
    before: "",
    after: `${publicGrant}|${md5("e")}\n`,
    reviewed: {
      schemaVersion: 1,
      status: "reviewed",
      removed: {},
      changed: {},
      added: { [publicGrant]: md5("e") }
    }
  });
  assert.equal(result.status, 1);
  assert.match(result.report, /unexpected_public_grant_additions=/);
  assert.match(result.report, /verdict=FAIL/);
});

test("unreviewed placeholder can never approve a disposable schema", async () => {
  const result = await runValidation({
    before: "",
    after: "",
    reviewed: {
      schemaVersion: 1,
      status: "awaiting_disposable_review",
      removed: {},
      changed: {},
      added: {}
    }
  });
  assert.equal(result.status, 1);
  assert.match(result.report, /reviewed_status=awaiting_disposable_review/);
  assert.match(result.report, /verdict=FAIL/);
});
