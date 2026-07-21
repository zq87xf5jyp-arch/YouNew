import assert from "node:assert/strict";
import test from "node:test";

import { guideChecklistCompletion, sanitizeGuideChecklistState, sanitizeUserPathProfile, userPathProfiles } from "../src/lib/storage/local-content.ts";

test("guide checklist state accepts only stable IDs and booleans", () => {
  const state = sanitizeGuideChecklistState({
    "guide.valid": { "check.one": true, "check.two": false, bad: "yes" },
    "Unsafe guide": { "check.one": true },
    "guide.array": []
  });
  assert.deepEqual(state, { "guide.valid": { "check.one": true, "check.two": false } });
});

test("guide checklist completion is deterministic and ignores unrelated state", () => {
  const state = sanitizeGuideChecklistState({
    "guide.valid": { "check.one": true, "check.two": false, "check.unrelated": true }
  });
  assert.deepEqual(guideChecklistCompletion(state, "guide.valid", ["check.one", "check.two"]), { completed: 1, total: 2 });
  assert.deepEqual(guideChecklistCompletion(state, "guide.missing", ["check.one"]), { completed: 0, total: 1 });
});

test("all six user paths are accepted while unknown stored profiles fail closed", () => {
  assert.deepEqual(userPathProfiles, ["tourist", "student", "expat", "refugee", "worker", "resident"]);
  for (const profile of userPathProfiles) assert.equal(sanitizeUserPathProfile(profile), profile);
  assert.equal(sanitizeUserPathProfile("administrator"), null);
  assert.equal(sanitizeUserPathProfile({ profile: "worker" }), null);
});
