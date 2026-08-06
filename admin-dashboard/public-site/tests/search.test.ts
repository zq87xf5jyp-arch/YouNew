import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import test from "node:test";

import type { SearchDocument } from "../src/lib/search/rank";

const rankModule = (await import(new URL("../src/lib/search/rank.ts", import.meta.url).href)) as {
  boundedEditDistance: (left: string, right: string, maximum: number) => number;
  filterSearchDocumentsByProfile: (
    documents: readonly SearchDocument[],
    profile: unknown
  ) => SearchDocument[];
  searchDocumentMatchesProfile: (document: SearchDocument, profile: unknown) => boolean;
  normalizeSearchText: (value: string) => string;
  rankSearchDocuments: (
    documents: readonly SearchDocument[],
    query: string,
    options?: {
      filters?: { type?: SearchDocument["type"]; cityId?: string; provinceId?: string; category?: string };
      limit?: number;
      preferredProfile?: import("../src/lib/content/types").GuideAudienceProfile | null;
    }
  ) => Array<{ document: SearchDocument; score: number; matchedTerms: readonly string[] }>;
};

const index = JSON.parse(
  await readFile(new URL("../public/data/search-index.json", import.meta.url), "utf8")
) as { schemaVersion: number; documents: SearchDocument[] };
const content = JSON.parse(
  await readFile(new URL("../src/generated/public-content.json", import.meta.url), "utf8")
) as { entities: Array<{ id: string; status: string }>; categories: Array<{ id: string }> };
const geography = JSON.parse(
  await readFile(new URL("../src/generated/netherlands-geography.json", import.meta.url), "utf8")
) as { municipalities: Array<{ code: string }>; provinces: Array<{ code: string }> };

test("search index v3 contains only published entities, national guides and derived public routes", () => {
  assert.equal(index.schemaVersion, 3);
  assert.ok(index.documents.length > 0);
  assert.ok(content.entities.every((entity) => entity.status === "published"));
  const entityTypes = new Set(["city", "guide", "organization", "place"]);
  const indexedEntityIds = index.documents.filter((document) => entityTypes.has(document.type) && document.sourceKind !== "nationalResourceGuide").map((document) => document.id).sort();
  assert.deepEqual(indexedEntityIds, content.entities.map((entity) => entity.id).sort());
  assert.deepEqual(index.documents.filter((document) => document.type === "category").map((document) => document.id).sort(), content.categories.map((category) => category.id).sort());
  assert.equal(index.documents.filter((document) => document.type === "municipality").length, geography.municipalities.length);
  assert.equal(index.documents.filter((document) => document.type === "province").length, geography.provinces.length);
});

test("official settlement names resolve to their municipality page", () => {
  const results = rankModule.rankSearchDocuments(index.documents, "Giethoorn");
  assert.ok(results.length > 0);
  assert.equal(results[0].document.type, "municipality");
  assert.equal(results[0].document.route, "/municipalities/steenwijkerland");
});

test("search normalizes accents and ranks exact titles first", () => {
  assert.equal(rankModule.normalizeSearchText("  Fryslân & Café  "), "fryslan cafe");
  assert.equal(rankModule.normalizeSearchText("  ’s-Gravenhage — ЖИЛЬЁ  "), "s gravenhage жилье");
  const results = rankModule.rankSearchDocuments(index.documents, "Amsterdam");
  assert.ok(results.length > 0);
  assert.equal(results[0].document.title, "Amsterdam");
});

test("search tolerates a useful typo without returning the whole index", () => {
  const results = rankModule.rankSearchDocuments(index.documents, "Rijksmusem");
  assert.ok(results.length > 0);
  assert.match(results[0].document.title, /Rijksmuseum/i);
  assert.ok(results.length < index.documents.length);
});

test("search filters are applied before ranking", () => {
  const results = rankModule.rankSearchDocuments(index.documents, "Amsterdam", {
    filters: { type: "guide", category: "government" }
  });
  assert.ok(results.length > 0);
  assert.ok(results.every(({ document }) => document.type === "guide" && document.categories.includes("government")));
});

test("search is deterministic and bounded", () => {
  const first = rankModule.rankSearchDocuments(index.documents, "housing Amsterdam", { limit: 3 });
  const second = rankModule.rankSearchDocuments([...index.documents].reverse(), "housing Amsterdam", { limit: 3 });
  assert.deepEqual(
    first.map(({ document }) => document.id),
    second.map(({ document }) => document.id)
  );
  assert.ok(first.length <= 3);
  assert.equal(rankModule.rankSearchDocuments(index.documents, "   ").length, 40);
  assert.equal(rankModule.boundedEditDistance("museum", "musem", 1), 1);
});

test("location filters boost applicable content while type and category stay hard filters", () => {
  const results = rankModule.rankSearchDocuments(index.documents, "", {
    filters: { type: "place", provinceId: "noord-holland" },
    limit: 80
  });
  assert.ok(results.length > 0);
  assert.ok(results.every(({ document }) => document.type === "place" && document.provinceId === "noord-holland"));
});

test("practical-guide search fields participate in ranking", () => {
  const fixture: SearchDocument = {
    id: "guide.search-field-fixture",
    type: "guide",
    sourceKind: "knowledgeTopic",
    slug: "search-field-fixture",
    route: "/guides/search-field-fixture",
    title: "Verified procedural fixture",
    summary: "A test-only document for exercising the pure ranking function.",
    keywords: [],
    city: null,
    cityId: null,
    province: null,
    provinceId: null,
    categories: ["government"],
    narrowCategory: "government",
    organization: null,
    audienceProfiles: ["expat"],
    numberedSteps: ["Activate the account with the official letter"],
    requiredDocuments: ["Valid passport"],
    checklist: ["Bring your identity document to the appointment"],
    tips: ["Keep the confirmation letter"],
    faqAnswers: ["Can I reschedule? Use the official appointment portal."],
    whenYouNeedIt: ["Use this process after moving to the Netherlands"],
    tags: ["registration workflow"],
    synonyms: ["digital identity"],
    officialOrganizationNames: ["Official test institution"],
    terminology: ["voorbeeldterm"],
    commonQuestions: ["Where is my activation letter?"]
  };

  for (const query of ["activation letter", "valid passport", "identity document appointment", "confirmation letter", "reschedule appointment", "after moving", "registration workflow", "digital identity", "test institution", "voorbeeldterm"]) {
    assert.equal(rankModule.rankSearchDocuments([fixture], query)[0]?.document.id, fixture.id, query);
  }
});

test("profile matching can personalize ranking without becoming a hard filter", () => {
  const base: SearchDocument = {
    id: "guide.profile-fixture",
    type: "guide",
    sourceKind: "knowledgeTopic",
    slug: "profile-fixture",
    route: "/guides/profile-fixture",
    title: "Profile fixture",
    summary: "Test-only profile filtering fixture.",
    keywords: [],
    city: null,
    cityId: null,
    province: null,
    provinceId: null,
    categories: ["government"],
    narrowCategory: "government",
    organization: null,
    audienceProfiles: ["student"]
  };
  const authored = { ...base, id: "guide.authored-student" };
  const legacy = { ...base, id: "guide.legacy-summary", audienceProfiles: [] };

  assert.deepEqual(
    rankModule.filterSearchDocumentsByProfile([authored, legacy], "expat").map((document) => document.id),
    [authored.id, legacy.id],
    "an authored audience mismatch must not hide otherwise published content"
  );
  assert.deepEqual(
    rankModule.filterSearchDocumentsByProfile([authored, legacy], "student").map((document) => document.id),
    [authored.id, legacy.id],
    "a matching profile may boost order but must not remove general content"
  );
  assert.equal(rankModule.searchDocumentMatchesProfile(legacy, "not-a-profile"), false);
  assert.deepEqual(rankModule.filterSearchDocumentsByProfile([authored, legacy], "not-a-profile"), [authored, legacy]);
});

test("a preferred profile personalizes ranking without hiding exact published answers", () => {
  const results = rankModule.rankSearchDocuments(index.documents, "BSN", {
    preferredProfile: "tourist",
    limit: 5
  });

  assert.equal(results[0]?.document.id, "national.documents");
  assert.ok(
    results.every(({ matchedTerms }) => matchedTerms.includes("bsn")),
    "profile preference must not introduce unrelated results"
  );
});

test("requested quality queries find a source-backed released destination", () => {
  const expected = new Map<string, string>([
    ["How do I get a BSN?", "national.documents"],
    ["Register gemeente", "national.documents"],
    ["Landlord does not repair", "housing.woon"],
    ["Student housing", "national.housing"],
    ["Emergency", "page.emergency"],
    ["Lost residence card", "national.documents"],
    ["DigiD", "national.documents"],
    ["Work contract", "national.work"],
    ["Need a doctor", "national.healthcare"],
    ["Health insurance", "national.healthcare"],
    ["Open a bank account", "national.banking"],
    ["Families childcare", "national.family-childcare"],
    ["Pets registration", "national.pets"],
    ["Tax Belastingdienst", "national.taxes"],
    ["Benefits allowances", "national.benefits"],
    ["Buy a bicycle", "national.transport"],
    ["Immigration residence permit", "national.immigration"],
    ["Arrange utilities when moving", "national.utilities-moving"],
    ["Consumer rights complaint", "national.consumer-rights"],
    ["Debt help legal advice", "national.debt-legal-help"],
    ["Mental health support", "national.mental-health"],
    ["Find a dentist", "national.dental-care"],
    ["Prescription medicines pharmacy", "national.medicines"],
    ["Pregnancy midwife", "national.pregnancy"],
    ["Start a business ZZP KVK", "national.business-zzp"]
  ]);
  for (const [query, expectedId] of expected) {
    const results = rankModule.rankSearchDocuments(index.documents, query, { limit: 5 });
    assert.equal(results[0]?.document.id, expectedId, `${query}: ${results.map(({ document }) => document.id).join(", ")}`);
  }

});

test("every homepage and search-suggestion query opens a useful published destination", () => {
  const expected = new Map<string, string>([
    ["I need housing in Leiden", "national.housing"],
    ["I need work", "national.work"],
    ["I need a GP", "national.healthcare"],
    ["I need BSN", "national.documents"],
    ["housing", "national.housing"],
    ["work", "national.work"],
    ["healthcare GP", "national.healthcare"],
    ["BSN documents", "national.documents"],
    ["study education", "national.education"],
    ["daily life bank account", "national.banking"],
    ["LGBTQ support", "national.lgbtiq-support"],
    ["pets registration", "national.pets"],
    ["families childcare", "national.family-childcare"],
    ["education study", "national.education"],
    ["moving registration", "national.documents"],
    ["open a bank account", "national.banking"],
    ["find work", "national.work"],
    ["register with a huisarts GP", "national.healthcare"],
    ["DigiD", "national.documents"],
    ["health insurance", "national.healthcare"],
    ["Dutch lessons", "national.education"],
    ["buy a bicycle", "national.transport"],
    ["tax Belastingdienst", "national.taxes"],
    ["benefits allowances", "national.benefits"],
    ["immigration residence permit", "national.immigration"],
    ["utilities moving home", "national.utilities-moving"],
    ["consumer rights complaint", "national.consumer-rights"],
    ["debt legal help", "national.debt-legal-help"],
    ["mental health support", "national.mental-health"],
    ["dentist dental care", "national.dental-care"],
    ["medicines prescription pharmacy", "national.medicines"],
    ["pregnancy midwife maternity care", "national.pregnancy"],
    ["start a business ZZP KVK", "national.business-zzp"],
    ["Register gemeente", "national.documents"],
    ["Housing defects", "national.housing"],
    ["Student housing", "national.housing"],
    ["Emergency", "page.emergency"],
    ["Amsterdam", "city.amsterdam"],
    ["train station", "national.transport"]
  ]);
  for (const [query, expectedId] of expected) {
    const results = rankModule.rankSearchDocuments(index.documents, query, { limit: 5 });
    assert.equal(results[0]?.document.id, expectedId, `${query}: ${results.map(({ document }) => document.id).join(", ")}`);
    assert.ok(results[0]?.document.route, `${query} must resolve to a published route`);
  }
});

test("critical EN, NL and RU intents do not return a useless zero", () => {
  const queries = new Map<string, readonly string[]>([
    ["national.housing", ["rent", "housing rent", "huur", "woning", "аренда", "квартира"]],
    ["national.work", ["work", "find work", "baan", "vacature", "работа", "вакансия"]],
    ["national.documents", ["BSN", "DigiD", "residence permit", "inschrijving", "регистрация", "ВНЖ"]],
    ["national.healthcare", ["doctor", "huisarts", "health insurance", "zorgverzekering", "врач", "медицинская страховка"]],
    ["national.education", ["Dutch school", "language course", "taalschool", "opleiding", "школа", "курсы"]],
    ["national.telecom", ["SIM card", "eSIM", "simkaart", "telefoonabonnement", "сим-карта", "интернет"]],
    ["national.rules-fines", ["parking fine", "traffic rules", "parkeerboete", "fietsregels", "штраф за парковку", "правила движения"]],
    ["national.lgbtiq-support", ["LGBTQ support", "queer support", "trans support", "LHBTI hulp", "discriminatie melden", "ЛГБТ поддержка", "гомофобия"]],
    ["national.banking", ["open a bank account", "payment account", "bankrekening openen", "betaalrekening", "открыть банковский счёт", "банковский счет"]],
    ["national.family-childcare", ["families childcare", "find childcare", "kinderopvang", "buitenschoolse opvang", "детский сад", "уход за детьми"]],
    ["national.pets", ["pets registration", "register a dog", "hond registreren", "dierenpaspoort", "регистрация питомца", "зарегистрировать собаку"]],
    ["national.taxes", ["tax Belastingdienst", "tax return", "belastingaangifte", "inkomstenbelasting", "налоговая декларация", "налоги в Нидерландах"]],
    ["national.benefits", ["benefits allowances", "healthcare benefit", "toeslagen", "huurtoeslag", "пособия", "пособие на аренду"]],
    ["national.transport", ["buy a bicycle", "public transport", "fiets kopen", "openbaar vervoer", "купить велосипед", "общественный транспорт"]],
    ["national.immigration", ["immigration residence permit", "visa Netherlands", "immigratie", "verblijfsvergunning verlengen", "иммиграция", "виза в Нидерланды"]],
    ["national.utilities-moving", ["utilities moving home", "electricity contract", "energiecontract", "meterstanden", "коммунальные услуги", "переезд"]],
    ["national.consumer-rights", ["consumer rights complaint", "online purchase problem", "consumentenrecht", "misleidende verkoop", "права потребителя", "жалоба на покупку"]],
    ["national.debt-legal-help", ["debt legal help", "money problems", "schuldhulpverlening", "juridische hulp", "помощь с долгами", "юридическая помощь"]],
    ["national.mental-health", ["mental health support", "psychologist", "mentale gezondheid", "psycholoog", "психолог", "психическое здоровье"]],
    ["national.dental-care", ["find a dentist", "emergency dentist", "tandarts", "spoedtandarts", "стоматолог", "зубная боль"]],
    ["national.medicines", ["medicine", "patient leaflet", "recept", "apotheek", "лекарство", "инструкция к лекарству"]],
    ["national.pregnancy", ["pregnancy", "maternity care", "verloskundige", "kraamzorg", "беременность", "родовспоможение"]],
    ["national.business-zzp", ["start a business ZZP KVK", "open a company", "bedrijf starten zzp", "inschrijven KVK", "открыть бизнес ZZP", "регистрация KVK"]]
  ]);

  for (const [expectedId, aliases] of queries) {
    for (const query of aliases) {
      const results = rankModule.rankSearchDocuments(index.documents, query, { limit: 8 });
      assert.ok(results.length > 0, `${query} returned zero`);
      assert.equal(results[0]?.document.id, expectedId, `${query}: ${results.map(({ document }) => document.id).join(", ")}`);
    }
  }
});

test("city and profile keep national guidance while excluding unrelated local results", () => {
  const scenarios = [
    ["housing rent", "s-gravenhage", "worker", "national.housing"],
    ["work", "leiden", "worker", "national.work"],
    ["huisarts", "rotterdam", "resident", "national.healthcare"],
    ["Dutch school", "groningen", "student", "national.education"],
    ["BSN", "eindhoven", "expat", "national.documents"],
    ["SIM card", "maastricht", "tourist", "national.telecom"],
    ["parking fine", "utrecht", "resident", "national.rules-fines"],
    ["LGBTQ support", "groningen", "student", "national.lgbtiq-support"],
    ["open a bank account", "utrecht", "resident", "national.banking"],
    ["families childcare", "rotterdam", "worker", "national.family-childcare"],
    ["pets registration", "groningen", "expat", "national.pets"],
    ["tax Belastingdienst", "eindhoven", "worker", "national.taxes"],
    ["benefits allowances", "maastricht", "refugee", "national.benefits"],
    ["buy a bicycle", "leiden", "student", "national.transport"],
    ["immigration residence permit", "s-gravenhage", "expat", "national.immigration"],
    ["utilities moving home", "leiden", "resident", "national.utilities-moving"],
    ["consumer rights complaint", "utrecht", "tourist", "national.consumer-rights"],
    ["debt legal help", "rotterdam", "refugee", "national.debt-legal-help"],
    ["mental health support", "groningen", "student", "national.mental-health"],
    ["find a dentist", "eindhoven", "worker", "national.dental-care"],
    ["prescription medicines pharmacy", "maastricht", "resident", "national.medicines"],
    ["pregnancy midwife", "leiden", "resident", "national.pregnancy"],
    ["start a business ZZP KVK", "s-gravenhage", "worker", "national.business-zzp"]
  ] as const;
  for (const [query, cityId, profile, expectedId] of scenarios) {
    const results = rankModule.rankSearchDocuments(index.documents, query, {
      filters: { cityId }, preferredProfile: profile, limit: 8
    });
    assert.ok(results.length > 0, `${query} + ${cityId} + ${profile}`);
    assert.equal(results[0]?.document.id, expectedId, `${query} + ${cityId} + ${profile}`);
    assert.ok(results.some(({ document }) => document.locationScope === "national"), `${query} must retain national guidance`);
    assert.ok(results.every(({ document }) => {
      const localCity = document.municipalityId ?? document.cityId;
      return !localCity || document.nationalFallback || rankModule.normalizeSearchText(localCity) === rankModule.normalizeSearchText(cityId);
    }), `${query} + ${cityId} must not include another city's local result`);
  }
});

test("Groningen city filter keeps national education and removes Amsterdam schools", () => {
  const results = rankModule.rankSearchDocuments(index.documents, "Dutch school", {
    filters: { cityId: "groningen" },
    limit: 40
  });

  assert.equal(results[0]?.document.id, "national.education");
  assert.ok(results.some(({ document }) => document.locationScope === "national"));
  assert.ok(results.every(({ document }) => document.cityId !== "amsterdam"));
  assert.ok(results.every(({ document }) => !document.cityId || document.cityId === "groningen"));
});

test("rent no longer matches Drenthe as an infix and national guidance ranks first", () => {
  const results = rankModule.rankSearchDocuments(index.documents, "rent", { limit: 12 });
  assert.equal(results[0]?.document.id, "national.housing");
  assert.ok(results.every(({ document }) => !/drenthe/i.test(`${document.id} ${document.title}`)));
});

test("Dutch city aliases produce one canonical location and the same top result", async () => {
  const geographyModule = await import(new URL("../src/lib/search/geography.ts", import.meta.url).href) as {
    canonicalCityId: typeof import("../src/lib/search/geography").canonicalCityId;
    resolveSearchLocation: typeof import("../src/lib/search/geography").resolveSearchLocation;
  };
  const aliases = ["Den Haag rent", "The Hague rent", "’s-Gravenhage rent", "s Gravenhage rent", "s-Gravenhage rent", "DenHaag rent"];
  for (const query of aliases) {
    const context = geographyModule.resolveSearchLocation(index.documents, rankModule.normalizeSearchText(query), rankModule.normalizeSearchText);
    assert.equal(context?.canonicalId, "s-gravenhage", query);
    assert.equal(rankModule.rankSearchDocuments(index.documents, query, { limit: 1 })[0]?.document.id, "national.housing", query);
  }
  for (const value of ["Den Haag", "The Hague", "’s-Gravenhage", "s Gravenhage", "s-Gravenhage", "DenHaag", "sGravenhage"]) {
    assert.equal(geographyModule.canonicalCityId(value), "s-gravenhage", `URL city filter: ${value}`);
  }
});

test("search UI suggests only queries with a released destination", async () => {
  const source = await readFile(new URL("../src/components/search-experience.tsx", import.meta.url), "utf8");
  assert.match(source, /placeholder="[^"]*Register gemeente[^"]*Housing defects[^"]*"/);
  assert.doesNotMatch(source, /placeholder="[^"]*Need a doctor[^"]*"/);
  assert.match(source, /submittedQuery \|\| hasActiveFilters \|\| showAllResults/);
  assert.match(source, /setShowAllResults\(!submittedQuery && !Object\.values\(next\)\.some\(Boolean\)\)/);
  assert.match(source, /profileParameter === null \? ""/, "a saved Discover profile must not change search unless the URL explicitly requests it");
  assert.match(source, /preferredProfile:/, "an explicitly selected profile may be passed as a secondary ranking signal");
  assert.doesNotMatch(source, /filterSearchDocumentsByProfile\(documents/, "profile must not pre-filter the published index");
  assert.match(source, /search-filter-toggle/);
  assert.match(source, /search-active-chips/);
  assert.match(source, /Search all Netherlands/);
  assert.match(source, /No published local match for \{activeLocationLabel\} — showing national guidance\./);
  assert.match(source, /if \(key === "city" && value\) next\.province = ""/);
  assert.match(source, /if \(key === "province" && value\) next\.city = ""/);
  assert.match(source, /Opening share…/, "native sharing must expose progress while the system sheet is open");
  assert.match(source, /Unable to share/, "sharing failures must remain visible instead of being swallowed");
  assert.match(source, /showing useful broader results/);
});

test("saved exhaustive QA evidence matches the current search index", async () => {
  const report = JSON.parse(await readFile(new URL("../../../docs/reports/SEARCH_QA_MATRIX.json", import.meta.url), "utf8")) as {
    status: string;
    evidence: { searchIndexSha256: string; provinceCount: number; municipalityCount: number };
    totals: { checks: number; passed: number; failed: number };
    dimensions: { municipalities: Array<{ passed: boolean }>; provinces: Array<{ passed: boolean }> };
  };
  const indexBytes = await readFile(new URL("../public/data/search-index.json", import.meta.url));
  assert.equal(report.status, "PASS");
  assert.equal(report.totals.failed, 0);
  assert.equal(report.totals.passed, report.totals.checks);
  assert.ok(report.totals.checks >= 2_600);
  assert.equal(report.evidence.provinceCount, 12);
  assert.equal(report.evidence.municipalityCount, 342);
  assert.ok(report.dimensions.provinces.every((entry) => entry.passed));
  assert.ok(report.dimensions.municipalities.every((entry) => entry.passed));
  assert.equal(report.evidence.searchIndexSha256, createHash("sha256").update(indexBytes).digest("hex"));
});
