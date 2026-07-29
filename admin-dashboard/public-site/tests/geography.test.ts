import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const geography = JSON.parse(
  await readFile(new URL("../src/generated/netherlands-geography.json", import.meta.url), "utf8")
) as {
  schemaVersion: number;
  effectiveDate: string;
  stats: { provinces: number; municipalities: number; settlements: number };
  sources: Array<{ url: string; checkedAt: string }>;
  provinces: Array<{ code: string; slug: string; municipalityCodes: string[]; municipalityCount: number; settlementCount: number }>;
  municipalities: Array<{
    code: string;
    slug: string;
    provinceCode: string;
    officialWebsite: string | null;
    coordinate: { latitude: number; longitude: number } | null;
    settlements: Array<{ code: string; name: string }>;
  }>;
};

test("official 2026 geography contains all provinces, municipalities and BAG settlements", () => {
  assert.equal(geography.schemaVersion, 1);
  assert.equal(geography.effectiveDate, "2026-01-01");
  assert.deepEqual(geography.stats, { provinces: 12, municipalities: 342, settlements: 2502 });
  assert.equal(geography.provinces.length, geography.stats.provinces);
  assert.equal(geography.municipalities.length, geography.stats.municipalities);
  assert.equal(
    geography.municipalities.reduce((sum, municipality) => sum + municipality.settlements.length, 0),
    geography.stats.settlements
  );
});

test("municipality routes, identities and province relationships are deterministic", () => {
  assert.equal(new Set(geography.municipalities.map((municipality) => municipality.code)).size, 342);
  assert.equal(new Set(geography.municipalities.map((municipality) => municipality.slug)).size, 342);
  const provinceCodes = new Set(geography.provinces.map((province) => province.code));
  assert.ok(geography.municipalities.every((municipality) => provinceCodes.has(municipality.provinceCode)));
  assert.ok(geography.municipalities.every((municipality) => municipality.officialWebsite?.startsWith("http")));
  assert.ok(geography.municipalities.every((municipality) =>
    municipality.coordinate
    && Number.isFinite(municipality.coordinate.latitude)
    && Number.isFinite(municipality.coordinate.longitude)
  ));
});

test("province counts reconcile with municipality and settlement records", () => {
  const municipalitiesByCode = new Map(geography.municipalities.map((municipality) => [municipality.code, municipality]));
  for (const province of geography.provinces) {
    assert.equal(province.municipalityCodes.length, province.municipalityCount);
    assert.equal(
      province.municipalityCodes.reduce((sum, code) => sum + (municipalitiesByCode.get(code)?.settlements.length ?? 0), 0),
      province.settlementCount
    );
  }
  assert.ok(geography.sources.every((source) => source.url.startsWith("https://") && /^\d{4}-\d{2}-\d{2}$/.test(source.checkedAt)));
});
