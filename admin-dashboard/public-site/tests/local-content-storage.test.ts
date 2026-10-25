import assert from "node:assert/strict";
import test from "node:test";

import {
  localContentRepository,
  removeLegacySearchHistory,
  sanitizePlannerState,
  sanitizeRecentContentItems,
  sanitizeRecentSearches,
  sanitizeSavedContentItems
} from "../src/lib/storage/local-content.ts";

const validSaved = {
  id: "guide.valid",
  route: "/guides/valid/",
  title: "A valid guide",
  kind: "Guide",
  savedAt: "2026-07-21T12:00:00.000Z"
};

test("saved and recent content fail closed for malformed or unsafe records", () => {
  assert.deepEqual(sanitizeSavedContentItems({ 0: validSaved }), []);
  assert.deepEqual(sanitizeSavedContentItems([
    validSaved,
    { ...validSaved },
    { ...validSaved, id: "guide.external", route: "https://example.com" },
    { ...validSaved, id: "guide.protocol", route: "//example.com" },
    { ...validSaved, id: "guide.missing-date", savedAt: "not-a-date" },
    { ...validSaved, id: "guide.rollover-date", savedAt: "2026-02-30" },
    { ...validSaved, id: "guide.non-iso-date", savedAt: "1" },
    null
  ]), [validSaved]);

  const validRecent = { ...validSaved, id: "place.valid", viewedAt: validSaved.savedAt };
  Reflect.deleteProperty(validRecent, "savedAt");
  assert.deepEqual(sanitizeRecentContentItems([validRecent, { ...validRecent, title: "" }]), [validRecent]);
});

test("recent searches are normalized, deduplicated and bounded", () => {
  const result = sanitizeRecentSearches(["  DigiD  ", "DigiD", "x", 12, ...Array.from({ length: 12 }, (_, index) => `query ${index}`)]);
  assert.deepEqual(result, ["DigiD", "query 0", "query 1", "query 2", "query 3", "query 4", "query 5", "query 6"]);
});

test("planner routes accept only known, bounded and deduplicated choices", () => {
  const valid = {
    profile: "new-resident",
    municipalitySlug: "den-haag",
    goalIds: ["registration", "housing"]
  };
  assert.deepEqual(sanitizePlannerState(valid), valid);
  assert.equal(sanitizePlannerState({ ...valid, profile: "admin" }), null);
  assert.equal(sanitizePlannerState({ ...valid, municipalitySlug: "https://example.com" }), null);
  assert.equal(sanitizePlannerState({ ...valid, goalIds: [] }), null);
  assert.equal(sanitizePlannerState({ ...valid, goalIds: ["registration", "registration"] }), null);
  assert.equal(sanitizePlannerState({ ...valid, goalIds: ["registration", "housing", "work", "transport"] }), null);
});

class MemoryStorage implements Storage {
  private readonly values = new Map<string, string>();
  get length() { return this.values.size; }
  clear() { this.values.clear(); }
  getItem(key: string) { return this.values.get(key) ?? null; }
  key(index: number) { return [...this.values.keys()][index] ?? null; }
  removeItem(key: string) { this.values.delete(key); }
  setItem(key: string, value: string) { this.values.set(key, value); }
}

function withStorage(storage: Storage, check: () => void) {
  const previousWindow = Object.getOwnPropertyDescriptor(globalThis, "window");
  Object.defineProperty(globalThis, "window", {
    configurable: true,
    value: { localStorage: storage, dispatchEvent: () => true } as unknown as Window & typeof globalThis
  });
  try { check(); }
  finally {
    if (previousWindow) Object.defineProperty(globalThis, "window", previousWindow);
    else Reflect.deleteProperty(globalThis, "window");
  }
}

test("legacy-query migration removes exactly two keys and preserves user content byte-for-byte", () => {
  const storage = new MemoryStorage();
  const privateQuery = "person@example.invalid BSN 123456782";
  const preserved = Object.values(localContentRepository.keys).filter(key => key !== localContentRepository.keys.searches && key !== localContentRepository.keys.rememberSearches);
  for (const key of preserved) storage.setItem(key, `untouched:${key}`);
  storage.setItem("unrelated.preference", "untouched");
  storage.setItem(localContentRepository.keys.searches, JSON.stringify({ version: 1, value: [privateQuery] }));
  storage.setItem(localContentRepository.keys.rememberSearches, JSON.stringify({ version: 1, value: true }));
  withStorage(storage, () => {
    assert.equal(removeLegacySearchHistory(), true);
    assert.equal(removeLegacySearchHistory(), true);
    assert.equal(storage.getItem(localContentRepository.keys.searches), null);
    assert.equal(storage.getItem(localContentRepository.keys.rememberSearches), null);
    for (const key of preserved) assert.equal(storage.getItem(key), `untouched:${key}`);
    assert.equal(storage.getItem("unrelated.preference"), "untouched");
    assert.equal(localContentRepository.searchHistoryEnabled(), false);
    assert.deepEqual(localContentRepository.recentSearches(), []);
  });
});

test("opt-in recent searches and one-time navigation handoff never persist or enter exports", () => {
  const storage = new MemoryStorage();
  const query = "private housing question person@example.invalid BSN 123456782";
  withStorage(storage, () => {
    localContentRepository.rememberSearch(query);
    assert.deepEqual(localContentRepository.recentSearches(), []);
    localContentRepository.setSearchHistoryEnabled(true);
    localContentRepository.rememberSearch(query);
    assert.deepEqual(localContentRepository.recentSearches(), [query]);
    assert.deepEqual(localContentRepository.snapshot().recentSearches, []);
    assert.equal(JSON.stringify(localContentRepository.snapshot()).includes(query), false);
    localContentRepository.handoffSearch(query);
    assert.equal(localContentRepository.takeSearchHandoff(), query);
    assert.equal(localContentRepository.takeSearchHandoff(), null);
    assert.equal(storage.length, 0);
    localContentRepository.setSearchHistoryEnabled(false);
    assert.deepEqual(localContentRepository.recentSearches(), []);
  });
  // A replacement document/window has no memory, even with the same storage.
  withStorage(storage, () => {
    assert.equal(localContentRepository.searchHistoryEnabled(), false);
    assert.deepEqual(localContentRepository.recentSearches(), []);
    assert.equal(localContentRepository.takeSearchHandoff(), null);
  });
});

test("blocked legacy cleanup is reported without reviving or persisting raw queries", () => {
  const storage = new MemoryStorage();
  storage.setItem(localContentRepository.keys.searches, JSON.stringify({ version: 1, value: ["person@example.invalid"] }));
  storage.removeItem = () => { throw new Error("blocked"); };
  storage.setItem = () => { throw new Error("unexpected write"); };
  withStorage(storage, () => {
    assert.equal(removeLegacySearchHistory(), false);
    assert.deepEqual(localContentRepository.recentSearches(), []);
    localContentRepository.setSearchHistoryEnabled(true);
    localContentRepository.rememberSearch("new private query");
    assert.deepEqual(localContentRepository.recentSearches(), ["new private query"]);
    assert.deepEqual(localContentRepository.snapshot().recentSearches, []);
  });
});

test("clear all also clears only the current document's transient searches and handoff", () => {
  withStorage(new MemoryStorage(), () => {
    localContentRepository.setSearchHistoryEnabled(true);
    localContentRepository.rememberSearch("private query");
    localContentRepository.handoffSearch("pending query");
    localContentRepository.clearAll();
    assert.equal(localContentRepository.searchHistoryEnabled(), false);
    assert.deepEqual(localContentRepository.recentSearches(), []);
    assert.equal(localContentRepository.takeSearchHandoff(), null);
  });
});

test("repository access never exposes malformed local storage payloads to UI consumers", () => {
  const storage = new MemoryStorage();
  storage.setItem(localContentRepository.keys.saved, JSON.stringify({ version: 1, value: { broken: true } }));
  storage.setItem(localContentRepository.keys.recent, JSON.stringify({ version: 1, value: [null, { route: "javascript:alert(1)" }] }));
  storage.setItem(localContentRepository.keys.searches, JSON.stringify({ version: 1, value: "DigiD" }));
  storage.setItem(localContentRepository.keys.rememberSearches, JSON.stringify({ version: 1, value: "true" }));

  const previousWindow = Object.getOwnPropertyDescriptor(globalThis, "window");
  Object.defineProperty(globalThis, "window", {
    configurable: true,
    value: { localStorage: storage, dispatchEvent: () => true } as unknown as Window & typeof globalThis
  });

  try {
    assert.deepEqual(localContentRepository.saved(), []);
    assert.equal(localContentRepository.isSaved("guide.valid"), false);
    assert.deepEqual(localContentRepository.recent(), []);
    assert.equal(localContentRepository.searchHistoryEnabled(), false);
    assert.deepEqual(localContentRepository.recentSearches(), []);
  } finally {
    if (previousWindow) Object.defineProperty(globalThis, "window", previousWindow);
    else Reflect.deleteProperty(globalThis, "window");
  }
});

test("clear saved removes only saved shortcuts", () => {
  const storage = new MemoryStorage();
  const previousWindow = Object.getOwnPropertyDescriptor(globalThis, "window");
  Object.defineProperty(globalThis, "window", {
    configurable: true,
    value: { localStorage: storage, dispatchEvent: () => true } as unknown as Window & typeof globalThis
  });

  try {
    localContentRepository.toggleSaved({ id: validSaved.id, route: validSaved.route, title: validSaved.title, kind: validSaved.kind });
    localContentRepository.setProfile("student");
    assert.equal(localContentRepository.saved().length, 1);
    assert.equal(localContentRepository.clearSaved(), true);
    assert.deepEqual(localContentRepository.saved(), []);
    assert.equal(localContentRepository.profile(), "student");
  } finally {
    if (previousWindow) Object.defineProperty(globalThis, "window", previousWindow);
    else Reflect.deleteProperty(globalThis, "window");
  }
});

test("a saved profile can be explicitly cleared when search returns to all content", () => {
  const storage = new MemoryStorage();
  const previousWindow = Object.getOwnPropertyDescriptor(globalThis, "window");
  Object.defineProperty(globalThis, "window", {
    configurable: true,
    value: { localStorage: storage, dispatchEvent: () => true } as unknown as Window & typeof globalThis
  });

  try {
    localContentRepository.setProfile("expat");
    assert.equal(localContentRepository.profile(), "expat");
    localContentRepository.clearProfile();
    assert.equal(localContentRepository.profile(), null);
  } finally {
    if (previousWindow) Object.defineProperty(globalThis, "window", previousWindow);
    else Reflect.deleteProperty(globalThis, "window");
  }
});

test("planner state migrates from v18, exports safely and is removed by clear all", () => {
  const storage = new MemoryStorage();
  const previousWindow = Object.getOwnPropertyDescriptor(globalThis, "window");
  Object.defineProperty(globalThis, "window", {
    configurable: true,
    value: {
      localStorage: storage,
      dispatchEvent: () => true
    } as unknown as Window & typeof globalThis
  });

  try {
    const legacyRoute = {
      profile: "student",
      municipalitySlug: "utrecht",
      goalIds: ["registration", "housing"]
    };
    storage.setItem(localContentRepository.keys.plannerRoute, JSON.stringify(legacyRoute));
    assert.deepEqual(localContentRepository.plannerRoute(), legacyRoute);

    assert.equal(localContentRepository.setPlannerRoute({
      profile: "worker",
      municipalitySlug: "rotterdam",
      goalIds: ["work", "taxes-benefits"]
    }), true);
    assert.deepEqual(localContentRepository.snapshot().plannerRoute, {
      profile: "worker",
      municipalitySlug: "rotterdam",
      goalIds: ["work", "taxes-benefits"]
    });

    localContentRepository.clearAll();
    assert.equal(localContentRepository.plannerRoute(), null);
    assert.equal(storage.length, 0);
  } finally {
    if (previousWindow) Object.defineProperty(globalThis, "window", previousWindow);
    else Reflect.deleteProperty(globalThis, "window");
  }
});
