import assert from "node:assert/strict";
import test from "node:test";
import { businessLanguageHref } from "../src/lib/i18n/routes.ts";

test("business language links preserve only recognized profile intent", () => {
  assert.equal(businessLanguageHref("/for-business/local/apply/", "/nl/voor-bedrijven/aanmelden/", "claim"), "/for-business/local/apply/?action=claim");
  assert.equal(businessLanguageHref("/nl/voor-bedrijven/aanmelden/", "/for-business/local/apply/", "add"), "/nl/voor-bedrijven/aanmelden/?action=add");
  for (const value of [null, "claim&email=private@example.invalid", "https://example.invalid", "unknown"]) {
    assert.equal(businessLanguageHref("/nl/voor-bedrijven/aanmelden/", "/for-business/local/apply/", value), "/nl/voor-bedrijven/aanmelden/");
  }
  assert.equal(businessLanguageHref("/nl/zoeken/", "/search/", "claim"), "/nl/zoeken/");
});
