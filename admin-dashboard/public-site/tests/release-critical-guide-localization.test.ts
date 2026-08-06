import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import test from "node:test";

const guideBundleURL = new URL(
  "../../../DataProject/staging/release-critical-practical-guides-v2.json",
  import.meta.url
);
const localizationBundleURL = new URL(
  "../../../DataProject/staging/release-critical-practical-guides-v2-localization.json",
  import.meta.url
);

type Locale = "nl" | "ru";

type LocalizationEntry = {
  source_guide_id: string;
  source_locale: "en";
  locale: Locale;
  translation_status: "search_surface_draft";
  publication_authorized: boolean;
  reviewer: unknown;
  verified_at: unknown;
  title: string;
  short_summary: string;
  synonyms: string[];
  common_questions: string[];
  terminology: Array<{ source: string; target: string; note: string }>;
};

type LocalizationBundle = {
  schema_version: number;
  collection_id: string;
  source_bundle: string;
  source_bundle_sha256: string;
  status: string;
  publication_authorized: boolean;
  locales: Locale[];
  required_publication_gaps: string[];
  entries: LocalizationEntry[];
};

type GuideBundle = {
  guides: Array<{ practical_guide: { id: string; title: string; short_summary: { text: string } } }>;
};

const guideSource = await readFile(guideBundleURL);
const guideBundle = JSON.parse(guideSource.toString("utf8")) as GuideBundle;
const localizationBundle = JSON.parse(await readFile(localizationBundleURL, "utf8")) as LocalizationBundle;

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

const requiredPublicationGaps = [
  "full_body_translation",
  "independent_language_review",
  "source_to_translation_review",
  "media_and_accessibility_review"
];

const journeyTerms = new Map<string, Record<Locale, string[]>>([
  ["guide.getting-a-bsn", { nl: ["bsn", "eindhoven", "brp", "rni"], ru: ["bsn", "эйндховен", "brp", "rni"] }],
  ["guide.finding-a-huisarts", { nl: ["huisarts", "rotterdam"], ru: ["huisarts", "роттердам"] }],
  ["guide.renting-a-home", { nl: ["huren", "den haag", "werknemer"], ru: ["аренд", "гааг", "работник"] }],
  ["guide.finding-work", { nl: ["werk", "leiden"], ru: ["работ", "лейден"] }],
  ["guide.understanding-an-employment-contract", { nl: ["arbeidscontract", "cao"], ru: ["трудов", "cao"] }],
  ["guide.registering-a-child-at-school", { nl: ["school", "groningen"], ru: ["школ", "гронинген"] }],
  ["guide.choosing-a-sim-card", { nl: ["simkaart", "maastricht"], ru: ["sim-карт", "маастрихт"] }],
  ["guide.handling-a-parking-fine", { nl: ["parkeerboete", "utrecht"], ru: ["штраф", "утрехт"] }]
]);

test("localization package is pinned to the exact English source bundle", () => {
  const actualDigest = createHash("sha256").update(guideSource).digest("hex");
  assert.equal(localizationBundle.source_bundle_sha256, actualDigest);
  assert.equal(
    localizationBundle.source_bundle,
    "DataProject/staging/release-critical-practical-guides-v2.json"
  );
});

test("all eight release-critical guides have one Dutch and one Russian search-surface draft", () => {
  assert.equal(localizationBundle.schema_version, 1);
  assert.equal(localizationBundle.status, "localization_brief");
  assert.equal(localizationBundle.publication_authorized, false);
  assert.deepEqual(localizationBundle.locales, ["nl", "ru"]);
  assert.deepEqual(localizationBundle.required_publication_gaps, requiredPublicationGaps);

  const actualPairs = localizationBundle.entries.map((entry) => `${entry.source_guide_id}:${entry.locale}`);
  const expectedPairs = expectedGuideIDs.flatMap((guideID) => [
    `${guideID}:nl`,
    `${guideID}:ru`
  ]);

  assert.equal(localizationBundle.entries.length, 16);
  assert.equal(new Set(actualPairs).size, actualPairs.length, "localization pairs must be unique");
  assert.deepEqual(actualPairs, expectedPairs);
});

test("localization drafts expose useful search language without claiming full translation or review", () => {
  const EnglishByID = new Map(
    guideBundle.guides.map(({ practical_guide }) => [practical_guide.id, practical_guide])
  );

  for (const entry of localizationBundle.entries) {
    const context = `${entry.source_guide_id}:${entry.locale}`;
    const EnglishGuide = EnglishByID.get(entry.source_guide_id);
    assert.ok(EnglishGuide, `${context} references an unknown guide`);
    assert.equal(entry.source_locale, "en", `${context} source locale`);
    assert.equal(entry.translation_status, "search_surface_draft", `${context} status`);
    assert.equal(entry.publication_authorized, false, `${context} publication authorization`);
    assert.equal(entry.reviewer, null, `${context} must remain human-unassigned`);
    assert.equal(entry.verified_at, null, `${context} must not claim human verification`);
    assert.ok(entry.title.length >= 8, `${context} title`);
    assert.ok(entry.short_summary.length >= 120, `${context} summary`);
    assert.notEqual(entry.title, EnglishGuide.title, `${context} title must be localized`);
    assert.notEqual(entry.short_summary, EnglishGuide.short_summary.text, `${context} summary must be localized`);
    assert.ok(entry.synonyms.length >= 8, `${context} synonyms`);
    assert.ok(entry.common_questions.length >= 3, `${context} common questions`);
    assert.ok(entry.terminology.length >= 3, `${context} terminology controls`);
    entry.terminology.forEach((term, index) => {
      assert.ok(term.source && term.target && term.note, `${context}.terminology[${index}]`);
    });
    if (entry.locale === "ru") {
      assert.match(
        `${entry.title} ${entry.short_summary} ${entry.common_questions.join(" ")}`,
        /\p{Script=Cyrillic}/u,
        `${context} must contain Cyrillic user-facing copy`
      );
    }
  }
});

test("localized search surfaces represent every exact release-critical city journey", () => {
  for (const entry of localizationBundle.entries) {
    const expectedTerms = journeyTerms.get(entry.source_guide_id)?.[entry.locale];
    assert.ok(expectedTerms, `${entry.source_guide_id}:${entry.locale} has no journey contract`);
    const corpus = [entry.title, entry.short_summary, ...entry.synonyms, ...entry.common_questions]
      .join(" ")
      .toLocaleLowerCase(entry.locale);

    for (const term of expectedTerms) {
      assert.ok(corpus.includes(term), `${entry.source_guide_id}:${entry.locale} must represent ${term}`);
    }
  }
});

test("localization package contains no fake completion markers", () => {
  const serialized = JSON.stringify(localizationBundle);
  assert.doesNotMatch(serialized, /full_translation|human_verified|publication_ready/i);
  assert.doesNotMatch(serialized, /"publication_authorized":true|"translation_status":"complete"/);
});
