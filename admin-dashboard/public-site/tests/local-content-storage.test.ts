import assert from "node:assert/strict";
import test from "node:test";

import {
  localContentRepository,
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

class MemoryStorage implements Storage {
  private readonly values = new Map<string, string>();
  get length() { return this.values.size; }
  clear() { this.values.clear(); }
  getItem(key: string) { return this.values.get(key) ?? null; }
  key(index: number) { return [...this.values.keys()][index] ?? null; }
  removeItem(key: string) { this.values.delete(key); }
  setItem(key: string, value: string) { this.values.set(key, value); }
}

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
