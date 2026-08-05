import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const packageURL = new URL("../../../DataProject/staging/release-critical-practical-guides-v2.json", import.meta.url);

type OfficialSource = {
  id: string;
  is_official: boolean;
  status: string;
  checked_at: string;
  url: string;
};

type DraftGuide = Record<string, unknown> & {
  schema_version: number;
  id: string;
  title: string;
  status: string;
  reviewer: unknown;
  verified_at: unknown;
  publication_gate: unknown;
  confidence_level: unknown;
  short_summary: unknown;
  who_this_is_for: unknown;
  when_you_need_it: unknown;
  official_sources: OfficialSource[];
  numbered_steps: Array<{ position: number; source_ids: string[] }>;
  faqs: unknown[];
  sections: unknown[];
  contact_options: unknown[];
  related_guide_ids: string[];
  estimated_time: { note: unknown };
  estimated_cost: { note: unknown };
  seo: unknown;
  synonyms: string[];
  common_questions: string[];
};

type ReviewBundle = {
  schema_version: number;
  status: string;
  publication_authorized: boolean;
  guides: Array<{ publication_gaps: unknown; practical_guide: DraftGuide }>;
};

const bundle = JSON.parse(await readFile(packageURL, "utf8")) as ReviewBundle;
const guides = bundle.guides.map((entry) => entry.practical_guide);

const expectedGuideIDs = [
  "guide.getting-a-bsn",
  "guide.finding-a-huisarts",
  "guide.renting-a-home",
  "guide.finding-work",
  "guide.understanding-an-employment-contract",
  "guide.registering-a-child-at-school",
  "guide.choosing-a-sim-card",
  "guide.handling-a-parking-fine"
];

const sourcedArrayFields = [
  "prerequisites",
  "required_documents",
  "warnings",
  "common_mistakes",
  "tips",
  "checklist",
  "emergency_information",
  "next_actions"
];

const officialHosts = new Set([
  "www.government.nl",
  "www.netherlandsworldwide.nl",
  "www.thuisarts.nl",
  "www.nza.nl",
  "www.zorginstituutnederland.nl",
  "www.huurcommissie.nl",
  "www.rijksoverheid.nl",
  "www.uwv.nl",
  "workinnl.nl",
  "consument.acm.nl",
  "loket.digitaal.utrecht.nl",
  "bghu.nl",
  "www.cjib.nl"
]);

function assertSourced(value: unknown, sourceIDs: Set<string>, context: string) {
  assert.ok(value && typeof value === "object" && !Array.isArray(value), `${context} must be an object`);
  const block = value as { id?: unknown; text?: unknown; source_ids?: unknown };
  assert.equal(typeof block.id, "string", `${context}.id`);
  assert.ok(typeof block.text === "string" && block.text.trim().length >= 2, `${context}.text`);
  assert.ok(Array.isArray(block.source_ids) && block.source_ids.length > 0, `${context}.source_ids`);
  for (const sourceID of block.source_ids as string[]) {
    assert.ok(sourceIDs.has(sourceID), `${context} references unknown source ${sourceID}`);
  }
}

function allSourceReferences(guide: Record<string, unknown>) {
  const references: string[] = [];
  const visit = (value: unknown, key = "") => {
    if (key === "source_ids" && Array.isArray(value)) references.push(...value as string[]);
    if (Array.isArray(value)) value.forEach((item) => visit(item));
    else if (value && typeof value === "object") Object.entries(value).forEach(([childKey, child]) => visit(child, childKey));
  };
  visit(guide);
  return references;
}

test("critical guide review bundle is private, explicit and contains the eight intended drafts", () => {
  assert.equal(bundle.schema_version, 2);
  assert.equal(bundle.status, "editorial_draft");
  assert.equal(bundle.publication_authorized, false);
  assert.deepEqual(guides.map((guide: { id: string }) => guide.id), expectedGuideIDs);
  assert.equal(new Set(expectedGuideIDs).size, expectedGuideIDs.length);
});

test("every draft answers all twelve practical-content areas without bypassing governance", () => {
  for (const [index, entry] of bundle.guides.entries()) {
    const guide = entry.practical_guide;
    const context = guide.id ?? `guide[${index}]`;
    assert.equal(guide.schema_version, 2, `${context} schema`);
    assert.equal(guide.status, "draft", `${context} status`);
    assert.equal(guide.reviewer, null, `${context} reviewer must remain human-unassigned`);
    assert.equal(guide.verified_at, null, `${context} must not claim human verification`);
    assert.equal(guide.publication_gate, null, `${context} must not claim a passed publication gate`);
    assert.equal(guide.confidence_level, "medium", `${context} must not claim publishable high confidence`);
    assert.ok(Array.isArray(entry.publication_gaps) && entry.publication_gaps.length >= 3, `${context} publication gaps`);

    const sourceIDs = new Set<string>(guide.official_sources.map((source: { id: string }) => source.id));
    assertSourced(guide.short_summary, sourceIDs, `${context}.short_summary`);
    assertSourced(guide.who_this_is_for, sourceIDs, `${context}.who_this_is_for`);
    assertSourced(guide.when_you_need_it, sourceIDs, `${context}.when_you_need_it`);

    for (const field of sourcedArrayFields) {
      assert.ok(Array.isArray(guide[field]) && guide[field].length > 0, `${context}.${field}`);
      guide[field].forEach((block: unknown, blockIndex: number) => assertSourced(block, sourceIDs, `${context}.${field}[${blockIndex}]`));
    }

    assert.ok(guide.numbered_steps.length >= 5, `${context} needs an actionable sequence`);
    guide.numbered_steps.forEach((step: { position: number; source_ids: string[] }, stepIndex: number) => {
      assert.equal(step.position, stepIndex + 1, `${context} step positions must be contiguous`);
      assert.ok(step.source_ids.length > 0, `${context} step source mapping`);
    });
    assert.ok(guide.faqs.length >= 3, `${context} needs at least three FAQs`);
    assert.ok(guide.sections.length >= 2, `${context} needs local/problem/related context`);
    assert.ok(guide.contact_options.length > 0, `${context} needs an official handoff`);
    assert.ok(guide.related_guide_ids.length > 0, `${context} needs related topics`);
    assert.ok(guide.estimated_time.note, `${context} timing explanation`);
    assert.ok(guide.estimated_cost.note, `${context} cost explanation`);
    assert.ok(guide.seo && guide.synonyms.length > 0 && guide.common_questions.length > 0, `${context} search metadata`);

    const unresolved = allSourceReferences(guide).filter((sourceID) => !sourceIDs.has(sourceID));
    assert.deepEqual(unresolved, [], `${context} has unresolved per-fact source references`);
  }
});

test("draft sources are primary official URLs and disclose access restrictions", () => {
  for (const guide of guides) {
    for (const source of guide.official_sources) {
      assert.equal(source.is_official, true, `${guide.id}:${source.id} must be official`);
      assert.ok(["verified_opened", "access_restricted"].includes(source.status), `${guide.id}:${source.id} status`);
      assert.ok(/^2026-\d{2}-\d{2}$/.test(source.checked_at), `${guide.id}:${source.id} checked_at`);
      assert.ok(officialHosts.has(new URL(source.url).host), `${guide.id}:${source.id} uses unexpected host`);
    }
  }
});

test("the exact release-critical journeys are represented in the editorial bundle", () => {
  const corpus = new Map<string, string>(guides.map((guide) => [
    guide.id,
    [guide.title, ...guide.synonyms, ...guide.common_questions].join(" ").toLocaleLowerCase("en")
  ] as [string, string]));
  const expectations = [
    ["guide.renting-a-home", ["rent", "housing", "den haag", "worker"]],
    ["guide.finding-work", ["work", "leiden"]],
    ["guide.finding-a-huisarts", ["huisarts", "rotterdam"]],
    ["guide.registering-a-child-at-school", ["dutch school", "groningen"]],
    ["guide.getting-a-bsn", ["bsn", "eindhoven"]],
    ["guide.choosing-a-sim-card", ["sim card", "maastricht"]],
    ["guide.handling-a-parking-fine", ["parking fine", "utrecht"]]
  ] as const;
  for (const [guideID, terms] of expectations) {
    const text = corpus.get(guideID);
    assert.ok(text, `${guideID} is missing`);
    for (const term of terms) assert.match(text!, new RegExp(term, "i"), `${guideID} must represent ${term}`);
  }
});

test("review bundle contains no placeholder or fake approval markers", () => {
  const serialized = JSON.stringify(bundle);
  assert.doesNotMatch(serialized, /lorem ipsum|todo|tbd|placeholder reviewer/i);
  assert.doesNotMatch(serialized, /"status":"published"|"status":"passed"/);
});
