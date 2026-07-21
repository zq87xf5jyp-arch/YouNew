import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const siteRoot = new URL("../", import.meta.url);
const canonicalRuntime = JSON.parse(await readFile(new URL("../../YouNew/Resources/Data/younew-runtime-data.json", siteRoot), "utf8"));
const { projectPublishedPracticalGuide } = await import(new URL("../scripts/practical-guide.mjs", import.meta.url).href);
const { buildPublicDataset } = await import(new URL("../scripts/generate-public-content.mjs", import.meta.url).href);

function fixture(overrides: Record<string, unknown> = {}) {
  const id = "government_service.first-registration-in-amsterdam";
  const source = {
    id: "source.fixture",
    title: "Test-only official source",
    publisher: "YouNew QA fixture",
    url: "https://example.com/official-fixture",
    isOfficial: true,
    checkedAt: "2026-07-18",
    status: "verified_opened"
  };
  return {
    schemaVersion: 2,
    id,
    slug: "first-registration-in-amsterdam",
    locale: "en",
    title: "First registration in Amsterdam",
    shortSummary: { id: "summary", text: "Test-only sourced summary.", sourceIDs: [source.id] },
    audienceProfiles: ["expat"],
    whoThisIsFor: { id: "audience", text: "Test-only audience explanation.", sourceIDs: [source.id] },
    whenYouNeedIt: { id: "when", text: "Test-only applicability explanation.", sourceIDs: [source.id] },
    applicability: { cityIDs: [], provinceIDs: [] },
    jurisdiction: { level: "national", countryCode: "NL", municipalityDependent: false, note: null, sourceIDs: [source.id] },
    prerequisites: [{ id: "prereq.one", text: "Test-only prerequisite.", sourceIDs: [source.id] }],
    requiredDocuments: [{ id: "document.one", text: "Test-only required document.", sourceIDs: [source.id] }],
    estimatedTime: { state: "known", value: "Test-only value", note: "Test-only timing note.", sourceIDs: [source.id] },
    estimatedCost: { state: "known", value: "10", note: "Test-only cost note.", currency: "EUR", sourceIDs: [source.id] },
    numberedSteps: [{ id: "step.one", position: 1, title: "Test step", body: "This is test-only procedural content.", sourceIDs: [source.id], municipalityDependent: false }],
    warnings: [{ id: "warning.one", text: "Test-only warning.", sourceIDs: [source.id] }],
    commonMistakes: [{ id: "mistake.one", text: "Test-only common mistake.", sourceIDs: [source.id] }],
    tips: [{ id: "tip.one", text: "Use the official test fixture.", sourceIDs: [source.id] }],
    checklist: [{ id: "check.one", text: "Complete the test-only step.", sourceIDs: [source.id] }],
    faqs: [
      { id: "faq.one", question: "What is this fixture?", answer: "It is a test-only guide fixture.", sourceIDs: [source.id] },
      { id: "faq.two", question: "Is this user-visible?", answer: "No, it exists only inside automated tests.", sourceIDs: [source.id] },
      { id: "faq.three", question: "Does it use a source?", answer: "Yes, every answer cites the fixture source.", sourceIDs: [source.id] }
    ],
    emergencyInformation: [{ id: "emergency.one", text: "Test-only emergency context.", sourceIDs: [source.id] }],
    sections: [{ id: "section.one", title: "Test context", body: "This is test-only contextual information.", sourceIDs: [source.id] }],
    officialSources: [source],
    contactOptions: [{ id: "contact.one", kind: "url", label: "Test contact", value: "https://example.com/contact", sourceIDs: [source.id] }],
    relatedGuideIDs: ["housing.renting-a-home-in-amsterdam"],
    nextActions: [{ id: "next.one", text: "Test-only next action.", sourceIDs: [source.id] }],
    verifiedAt: "2026-07-18",
    updatedAt: "2026-07-18",
    reviewer: { id: "reviewer.qa-fixture-human", name: "QA Fixture Human", role: "Test editor", reviewerType: "human_editor", reviewedAt: "2026-07-18" },
    readingTimeMinutes: 4,
    difficulty: "basic",
    confidenceLevel: "high",
    tags: ["quality assurance", "test fixture"],
    publicationGate: {
      status: "passed",
      checkedAt: "2026-07-18",
      checks: { schema: true, factual_sources: true, links: true, language: true, media: true, duplicate_content: true, accessibility: true },
      notes: "Test-only gate evidence.",
      evidenceIDs: ["evidence.qa-fixture"]
    },
    disclaimer: "Test-only disclaimer, never user-visible.",
    status: "published",
    seo: {
      title: "First registration fixture",
      description: "Test-only metadata used to verify fail-closed practical guide projection.",
      canonicalPath: "/guides/first-registration-in-amsterdam"
    },
    synonyms: ["fixture synonym"],
    commonQuestions: ["Does the projection pass QA?"],
    ...overrides
  };
}

function parentContext(overrides: Record<string, unknown> = {}) {
  return {
    id: fixture().id,
    title: "First registration in Amsterdam",
    route: "/guides/first-registration-in-amsterdam",
    language: "en",
    mediaAssets: [{
      id: "media.fixture",
      verified: true,
      alt: "Test-only accessible fixture image",
      publicAssetPath: "/images/og-younew.jpg",
      assetURL: "https://example.com/fixture.jpg",
      sourcePageURL: "https://example.com/fixture-source",
      licenseURL: "https://example.com/fixture-license"
    }],
    ...overrides
  };
}

function parentWithAuthoredMedia<T extends { images: Array<Record<string, unknown>> }>(entity: T) {
  return {
    ...entity,
    attributes: { ...(entity as { attributes?: Record<string, unknown> }).attributes, publicWebCategory: "healthcare" },
    images: entity.images.map((image) => ({ ...image, alt: "Amsterdam municipal registration building", publicAssetPath: "/images/og-younew.jpg" }))
  };
}

type RuntimeEntityFixture = { id: string; images: Array<Record<string, unknown>>; [key: string]: unknown };

test("a complete published practical guide projects to the typed public model", () => {
  const projected = projectPublishedPracticalGuide(fixture(), parentContext());
  assert.equal(projected.contentDepth, undefined);
  assert.equal(projected.numberedSteps.length, 1);
  assert.deepEqual(projected.numberedSteps[0].sourceIds, ["source.fixture"]);
  assert.equal(projected.officialSources[0].isOfficial, true);
  assert.equal(projected.estimatedCost.currency, "EUR");
  assert.deepEqual(projected.publicationGate.evidenceIds, ["evidence.qa-fixture"]);
});

test("draft, qa, review and archived payloads remain private extensions of a brief record", () => {
  for (const status of ["draft", "qa", "review", "archived"]) {
    assert.equal(projectPublishedPracticalGuide(fixture({ status }), { id: fixture().id }), null);
  }
});

test("published practical guides fail closed on missing trust and structure fields", () => {
  const cases: Array<[string, () => Record<string, unknown>, RegExp]> = [
    ["official source", () => fixture({ officialSources: [] }), /officialSources/],
    ["officiality", () => { const value = fixture(); value.officialSources[0].isOfficial = false; return value; }, /official and verified_opened/],
    ["verified date", () => fixture({ verifiedAt: "2026-02-30" }), /ISO date/],
    ["steps", () => fixture({ numberedSteps: [] }), /between 1 and 25 steps/],
    ["source reference", () => { const value = fixture(); value.numberedSteps[0].sourceIDs = ["source.missing"]; return value; }, /unknown source/],
    ["sourced document", () => fixture({ requiredDocuments: [{ id: "document.one", text: "Passport", sourceIDs: [] }] }), /at least 1 item/],
    ["contiguous positions", () => { const value = fixture(); value.numberedSteps[0].position = 2; return value; }, /contiguous/],
    ["municipal applicability", () => fixture({ jurisdiction: { level: "municipal", countryCode: "NL", municipalityDependent: true, note: "Varies locally.", sourceIDs: ["source.fixture"] } }), /applicable city ID/],
    ["human reviewer", () => fixture({ reviewer: { id: "reviewer.bot", name: "Bot", role: "Generator", reviewerType: "automated", reviewedAt: "2026-07-18" } }), /human reviewer/],
    ["publication gate", () => fixture({ publicationGate: { ...fixture().publicationGate, status: "failed" } }), /must equal passed/],
    ["gate notes", () => fixture({ publicationGate: { ...fixture().publicationGate, notes: "" } }), /notes/],
    ["gate evidence", () => fixture({ publicationGate: { ...fixture().publicationGate, evidenceIDs: [] } }), /at least 1/],
    ["FAQ depth", () => fixture({ faqs: fixture().faqs.slice(0, 2) }), /between 3 and 20 items/],
    ["emergency context", () => fixture({ emergencyInformation: [] }), /between 1 and 10 items/],
    ["unrouted locale", () => fixture({ locale: "nl" }), /page language/],
    ["parent title mismatch", () => fixture({ title: "Different title" }), /parent entity title/],
    ["invalid contact kind", () => fixture({ contactOptions: [{ ...fixture().contactOptions[0], kind: "chatbot" }] }), /unsupported kind/]
  ];
  for (const [label, make, expected] of cases) {
    assert.throws(() => projectPublishedPracticalGuide(make(), parentContext()), expected, label);
  }
  assert.throws(() => projectPublishedPracticalGuide(fixture(), parentContext({ mediaAssets: [{ id: "media.fixture", verified: true, alt: "" }] })), /alt is missing/);
  assert.throws(() => projectPublishedPracticalGuide(fixture(), parentContext({ mediaAssets: [{ ...parentContext().mediaAssets[0], publicAssetPath: "https://example.com/fixture.jpg" }] })), /safe local image path/);
});

test("legacy guide records remain summary-depth and malformed published payloads stop generation", () => {
  const baseline = buildPublicDataset(canonicalRuntime);
  assert.equal(baseline.content.guides.length, 15);
  assert.ok(baseline.content.guides.every((guide: { contentDepth: string; practicalGuide: unknown }) => guide.contentDepth === "summary" && guide.practicalGuide === null));

  const parent = canonicalRuntime.entities.find((entity: { id: string }) => entity.id === fixture().id);
  const withDraft = buildPublicDataset({
    ...canonicalRuntime,
    entities: canonicalRuntime.entities.map((entity: { id: string }) => entity.id === parent.id ? { ...entity, practicalGuide: fixture({ status: "draft" }) } : entity)
  }, { verifyChecksum: false });
  const publicParent = withDraft.content.guides.find((guide: { id: string }) => guide.id === parent.id);
  assert.equal(publicParent.contentDepth, "summary");
  assert.equal(publicParent.practicalGuide, null);
  assert.doesNotMatch(JSON.stringify(withDraft.search), /Test-only sourced summary/);

  assert.throws(() => buildPublicDataset({
    ...canonicalRuntime,
    entities: canonicalRuntime.entities.map((entity: RuntimeEntityFixture) => entity.id === parent.id ? parentWithAuthoredMedia({ ...entity, practicalGuide: fixture({ numberedSteps: [] }) }) : entity)
  }, { verifyChecksum: false }), /numberedSteps/);
});

test("a valid published payload enriches guide rendering and search without changing its stable route", () => {
  const parentId = fixture().id;
  const output = buildPublicDataset({
    ...canonicalRuntime,
    entities: canonicalRuntime.entities.map((entity: RuntimeEntityFixture) => entity.id === parentId ? parentWithAuthoredMedia({ ...entity, practicalGuide: fixture() }) : entity)
  }, { verifyChecksum: false });
  const guide = output.content.guides.find((item: { id: string }) => item.id === parentId);
  const document = output.search.documents.find((item: { id: string }) => item.id === parentId);
  assert.equal(guide.route, "/guides/first-registration-in-amsterdam");
  assert.equal(guide.contentDepth, "practical");
  assert.deepEqual(guide.categorySlugs, ["healthcare"]);
  assert.equal(guide.practicalGuide.numberedSteps.length, 1);
  assert.deepEqual(document.audienceProfiles, ["expat"]);
  assert.match(document.numberedSteps.join(" "), /test step/i);
  assert.match(document.commonQuestions.join(" "), /projection pass/i);
  assert.match(document.faqAnswers.join(" "), /test-only guide fixture/i);
  assert.match(document.checklist.join(" "), /complete the test-only step/i);
});

test("a full guide requires an explicit canonical web category instead of the legacy Housing fallback", () => {
  const parentId = fixture().id;
  assert.throws(() => buildPublicDataset({
    ...canonicalRuntime,
    entities: canonicalRuntime.entities.map((entity: RuntimeEntityFixture) => entity.id === parentId ? {
      ...entity,
      images: entity.images.map((image) => ({ ...image, alt: "Test-only image", publicAssetPath: "/images/og-younew.jpg" })),
      practicalGuide: fixture()
    } : entity)
  }, { verifyChecksum: false }), /publicWebCategory/);
});
