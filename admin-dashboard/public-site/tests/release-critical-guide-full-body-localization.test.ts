import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import test from "node:test";

const guideBundleURL = new URL(
  "../../../DataProject/staging/release-critical-practical-guides-v2.json",
  import.meta.url
);
const searchSurfaceBundleURL = new URL(
  "../../../DataProject/staging/release-critical-practical-guides-v2-localization.json",
  import.meta.url
);
const fullBodyBundleURL = new URL(
  "../../../DataProject/staging/release-critical-practical-guides-v2-full-body-localization.json",
  import.meta.url
);

type Locale = "nl" | "ru";

type TextItem = { id: string; text: string };
type TitledItem = { id: string; title: string; body: string };
type FAQ = { id: string; question: string; answer: string };
type Contact = { id: string; kind: string; label: string; value: string };

type PracticalGuide = {
  id: string;
  who_this_is_for: { text: string };
  when_you_need_it: { text: string };
  jurisdiction: { note: string };
  prerequisites: TextItem[];
  required_documents: TextItem[];
  estimated_time: { value: string | null; note: string };
  estimated_cost: { value: string | null; note: string };
  numbered_steps: TitledItem[];
  warnings: TextItem[];
  common_mistakes: TextItem[];
  tips: TextItem[];
  checklist: TextItem[];
  faqs: FAQ[];
  emergency_information: TextItem[];
  sections: TitledItem[];
  contact_options: Contact[];
  next_actions: TextItem[];
  disclaimer: string;
  seo: { title: string; description: string };
};

type FullBodyEntry = {
  source_guide_id: string;
  source_locale: "en";
  locale: Locale;
  search_surface_ref: string;
  translation_status: "machine_assisted_full_body_draft";
  publication_authorized: boolean;
  reviewer: unknown;
  verified_at: unknown;
  fields: Record<string, string>;
};

type FullBodyBundle = {
  schema_version: number;
  source_bundle: string;
  source_bundle_sha256: string;
  search_surface_bundle: string;
  search_surface_bundle_sha256: string;
  status: string;
  publication_authorized: boolean;
  completion_summary: {
    expected_guide_locale_pairs: number;
    full_body_draft_pairs: number;
    remaining_pairs: number;
  };
  required_publication_gaps: string[];
  entries: FullBodyEntry[];
};

const guideSource = await readFile(guideBundleURL);
const searchSurfaceSource = await readFile(searchSurfaceBundleURL);
const guideBundle = JSON.parse(guideSource.toString("utf8")) as {
  guides: Array<{ practical_guide: PracticalGuide }>;
};
const searchSurfaceBundle = JSON.parse(searchSurfaceSource.toString("utf8")) as {
  entries: Array<{ source_guide_id: string; locale: Locale }>;
};
const fullBodyBundle = JSON.parse(await readFile(fullBodyBundleURL, "utf8")) as FullBodyBundle;

function sourceNarrativeFields(guide: PracticalGuide): Map<string, string> {
  const fields = new Map<string, string>([
    ["who_this_is_for.text", guide.who_this_is_for.text],
    ["when_you_need_it.text", guide.when_you_need_it.text],
    ["jurisdiction.note", guide.jurisdiction.note],
    ["estimated_time.note", guide.estimated_time.note],
    ["estimated_cost.note", guide.estimated_cost.note],
    ["disclaimer", guide.disclaimer],
    ["seo.title", guide.seo.title],
    ["seo.description", guide.seo.description]
  ]);
  if (guide.estimated_cost.value !== null) {
    fields.set("estimated_cost.value", guide.estimated_cost.value);
  }
  if (guide.estimated_time.value !== null) {
    fields.set("estimated_time.value", guide.estimated_time.value);
  }

  const addTextItems = (group: string, items: TextItem[]) => {
    for (const item of items) fields.set(`${group}.${item.id}.text`, item.text);
  };
  const addTitledItems = (group: string, items: TitledItem[]) => {
    for (const item of items) {
      fields.set(`${group}.${item.id}.title`, item.title);
      fields.set(`${group}.${item.id}.body`, item.body);
    }
  };

  addTextItems("prerequisites", guide.prerequisites);
  addTextItems("required_documents", guide.required_documents);
  addTitledItems("numbered_steps", guide.numbered_steps);
  addTextItems("warnings", guide.warnings);
  addTextItems("common_mistakes", guide.common_mistakes);
  addTextItems("tips", guide.tips);
  addTextItems("checklist", guide.checklist);
  for (const faq of guide.faqs) {
    fields.set(`faqs.${faq.id}.question`, faq.question);
    fields.set(`faqs.${faq.id}.answer`, faq.answer);
  }
  addTextItems("emergency_information", guide.emergency_information);
  addTitledItems("sections", guide.sections);
  for (const contact of guide.contact_options) {
    if (contact.kind !== "url") {
      fields.set(`contact_options.${contact.id}.label`, contact.label);
    }
    if (/\p{L}/u.test(contact.value) && !/^https?:/u.test(contact.value)) {
      fields.set(`contact_options.${contact.id}.value`, contact.value);
    }
  }
  addTextItems("next_actions", guide.next_actions);

  return fields;
}

test("full-body localization is pinned to both exact source bundles", () => {
  assert.equal(
    fullBodyBundle.source_bundle_sha256,
    createHash("sha256").update(guideSource).digest("hex")
  );
  assert.equal(
    fullBodyBundle.search_surface_bundle_sha256,
    createHash("sha256").update(searchSurfaceSource).digest("hex")
  );
  assert.equal(fullBodyBundle.source_bundle, "DataProject/staging/release-critical-practical-guides-v2.json");
  assert.equal(
    fullBodyBundle.search_surface_bundle,
    "DataProject/staging/release-critical-practical-guides-v2-localization.json"
  );
});

test("completed guide pairs have complete Dutch and Russian narrative overlays", () => {
  assert.equal(fullBodyBundle.schema_version, 1);
  assert.equal(fullBodyBundle.status, "machine_assisted_full_body_draft");
  assert.equal(fullBodyBundle.publication_authorized, false);
  assert.deepEqual(fullBodyBundle.completion_summary, {
    expected_guide_locale_pairs: 16,
    full_body_draft_pairs: 16,
    remaining_pairs: 0
  });
  assert.deepEqual(
    fullBodyBundle.entries.map((entry) => `${entry.source_guide_id}:${entry.locale}`),
    [
      "guide.getting-a-bsn:nl",
      "guide.getting-a-bsn:ru",
      "guide.finding-a-huisarts:nl",
      "guide.finding-a-huisarts:ru",
      "guide.renting-a-home:nl",
      "guide.renting-a-home:ru",
      "guide.finding-work:nl",
      "guide.finding-work:ru",
      "guide.understanding-an-employment-contract:nl",
      "guide.understanding-an-employment-contract:ru",
      "guide.registering-a-child-at-school:nl",
      "guide.registering-a-child-at-school:ru",
      "guide.choosing-a-sim-card:nl",
      "guide.choosing-a-sim-card:ru",
      "guide.handling-a-parking-fine:nl",
      "guide.handling-a-parking-fine:ru"
    ]
  );

  for (const entry of fullBodyBundle.entries) {
    const context = `${entry.source_guide_id}:${entry.locale}`;
    const guide = guideBundle.guides.find(
      ({ practical_guide }) => practical_guide.id === entry.source_guide_id
    )?.practical_guide;
    assert.ok(guide, `${context} references an unknown guide`);
    const sourceFields = sourceNarrativeFields(guide);
    const expectedFieldCounts: Record<string, number> = {
      "guide.getting-a-bsn": 47,
      "guide.finding-a-huisarts": 48,
      "guide.renting-a-home": 53,
      "guide.finding-work": 45,
      "guide.understanding-an-employment-contract": 47,
      "guide.registering-a-child-at-school": 54,
      "guide.choosing-a-sim-card": 51,
      "guide.handling-a-parking-fine": 53
    };
    const expectedFieldCount = expectedFieldCounts[entry.source_guide_id];
    assert.ok(expectedFieldCount, `${entry.source_guide_id} has no field-count contract`);
    assert.equal(sourceFields.size, expectedFieldCount, `${entry.source_guide_id} source contract changed`);
    assert.equal(entry.source_locale, "en");
    assert.equal(entry.search_surface_ref, context);
    assert.ok(
      searchSurfaceBundle.entries.some(
        (surface) => `${surface.source_guide_id}:${surface.locale}` === entry.search_surface_ref
      ),
      `${context} must resolve to a search-surface draft`
    );
    assert.equal(entry.translation_status, "machine_assisted_full_body_draft");
    assert.equal(entry.publication_authorized, false);
    assert.equal(entry.reviewer, null);
    assert.equal(entry.verified_at, null);
    assert.deepEqual(Object.keys(entry.fields).sort(), [...sourceFields.keys()].sort(), `${context} coverage`);

    for (const [path, sourceText] of sourceFields) {
      const translated = entry.fields[path];
      assert.ok(translated.length >= 5, `${context}:${path} must not be empty`);
      assert.notEqual(translated, sourceText, `${context}:${path} must be localized`);
      if (entry.locale === "ru") {
        assert.match(translated, /\p{Script=Cyrillic}/u, `${context}:${path} must contain Cyrillic`);
      }
    }
  }
});

test("machine-assisted full-body drafts preserve all publication gates", () => {
  assert.deepEqual(fullBodyBundle.required_publication_gaps, [
    "independent_language_review",
    "source_to_translation_review",
    "editorial_and_domain_review",
    "media_and_accessibility_review"
  ]);
  const serialized = JSON.stringify(fullBodyBundle);
  assert.doesNotMatch(serialized, /human_verified|publication_ready|"publication_authorized":true/i);
  assert.doesNotMatch(serialized, /"reviewer":"|"verified_at":"/i);
});
