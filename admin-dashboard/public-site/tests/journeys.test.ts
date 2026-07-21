import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import { isKnownJourneyStep, practicalJourneys } from "../src/lib/journeys/definitions.ts";
import { journeyCompletion, localContentRepository, sanitizeJourneyProgress, withoutJourneyProgress } from "../src/lib/storage/local-content.ts";

const content = JSON.parse(await readFile(new URL("../src/generated/public-content.json", import.meta.url), "utf8"));
const publishedGuideIds = new Set(content.guides.map((guide: { id: string }) => guide.id));

test("the eight requested journeys have stable unique IDs and never reference an unpublished guide", () => {
  assert.equal(practicalJourneys.length, 8);
  assert.equal(new Set(practicalJourneys.map((journey) => journey.id)).size, 8);
  for (const journey of practicalJourneys) {
    assert.equal(new Set(journey.guideIds).size, journey.guideIds.length);
    assert.ok(journey.guideIds.every((id) => publishedGuideIds.has(id)), journey.id);
  }
});

test("journey progress accepts only known steps and supported states", () => {
  const first = practicalJourneys.find((journey) => journey.guideIds.length > 0);
  assert.ok(first);
  const guideId = first.guideIds[0];
  assert.ok(guideId);
  assert.equal(isKnownJourneyStep(first.id, guideId), true);
  assert.equal(isKnownJourneyStep(first.id, "guide.draft"), false);

  assert.deepEqual(sanitizeJourneyProgress({
    [first.id]: { [guideId]: "completed", "guide.draft": "completed" },
    unknown: { [guideId]: "in-progress" },
    malformed: "completed"
  }), { [first.id]: { [guideId]: "completed" } });
});

test("journey completion is deterministic and isolated by journey", () => {
  const available = practicalJourneys.filter((journey) => journey.guideIds.length > 0);
  const first = available[0];
  const second = available[1];
  assert.ok(first);
  assert.ok(second);
  const firstGuide = first.guideIds[0];
  const firstSecondGuide = first.guideIds[1];
  const secondGuide = second.guideIds[0];
  assert.ok(firstGuide);
  assert.ok(firstSecondGuide);
  assert.ok(secondGuide);
  const states = sanitizeJourneyProgress({
    [first.id]: { [firstGuide]: "completed", [firstSecondGuide]: "in-progress" },
    [second.id]: { [secondGuide]: "completed" }
  });
  assert.deepEqual(journeyCompletion(states, first.id, first.guideIds), { completed: 1, total: first.guideIds.length });
  assert.deepEqual(journeyCompletion(states, second.id, second.guideIds), { completed: 1, total: second.guideIds.length });
});

test("resetting one journey leaves progress for every other journey intact", () => {
  const available = practicalJourneys.filter((journey) => journey.guideIds.length > 0);
  const first = available[0];
  const second = available[1];
  assert.ok(first);
  assert.ok(second);
  const firstGuide = first.guideIds[0];
  const secondGuide = second.guideIds[0];
  assert.ok(firstGuide);
  assert.ok(secondGuide);
  const states = sanitizeJourneyProgress({
    [first.id]: { [firstGuide]: "completed" },
    [second.id]: { [secondGuide]: "in-progress" }
  });

  const reset = withoutJourneyProgress(states, first.id);
  assert.equal(reset[first.id], undefined);
  assert.deepEqual(reset[second.id], { [secondGuide]: "in-progress" });
  assert.deepEqual(states[first.id], { [firstGuide]: "completed" }, "the input state must not be mutated");
});

class MemoryStorage implements Storage {
  private readonly values = new Map<string, string>();
  failWrites = false;

  get length() { return this.values.size; }
  clear() { this.values.clear(); }
  getItem(key: string) { return this.values.get(key) ?? null; }
  key(index: number) { return [...this.values.keys()][index] ?? null; }
  removeItem(key: string) { this.values.delete(key); }
  setItem(key: string, value: string) {
    if (this.failWrites) throw new DOMException("Storage unavailable", "QuotaExceededError");
    this.values.set(key, value);
  }
}

test("journey reset is atomic, verified and fails closed when browser storage rejects the write", () => {
  const available = practicalJourneys.filter((journey) => journey.guideIds.length > 0);
  const first = available[0];
  const second = available[1];
  assert.ok(first);
  assert.ok(second);
  const firstGuide = first.guideIds[0];
  const secondGuide = second.guideIds[0];
  assert.ok(firstGuide);
  assert.ok(secondGuide);
  const initial = {
    [first.id]: { [firstGuide]: "completed" },
    [second.id]: { [secondGuide]: "in-progress" }
  };
  const storage = new MemoryStorage();
  storage.setItem(localContentRepository.keys.journeys, JSON.stringify({ version: 1, value: initial }));
  const previousWindow = Object.getOwnPropertyDescriptor(globalThis, "window");
  Object.defineProperty(globalThis, "window", {
    configurable: true,
    value: { localStorage: storage, dispatchEvent: () => true } as unknown as Window & typeof globalThis
  });

  try {
    assert.equal(localContentRepository.resetJourney(first.id, first.guideIds), true);
    assert.equal(localContentRepository.journeyProgress()[first.id], undefined);
    assert.deepEqual(localContentRepository.journeyProgress()[second.id], { [secondGuide]: "in-progress" });

    storage.setItem(localContentRepository.keys.journeys, JSON.stringify({ version: 1, value: initial }));
    storage.failWrites = true;
    assert.equal(localContentRepository.resetJourney(first.id, first.guideIds), false);
    assert.deepEqual(localContentRepository.journeyProgress()[first.id], { [firstGuide]: "completed" });
    assert.equal(localContentRepository.resetJourney("unknown", first.guideIds), false);
    assert.equal(localContentRepository.resetJourney(first.id, []), false);
  } finally {
    if (previousWindow) Object.defineProperty(globalThis, "window", previousWindow);
    else Reflect.deleteProperty(globalThis, "window");
  }
});

test("journey page is explicit about local-only state and absent synchronization", async () => {
  const source = await readFile(new URL("../src/components/journey-explorer.tsx", import.meta.url), "utf8");
  assert.match(source, /stays only in this browser/i);
  assert.match(source, /not an official task status, account record or iOS sync/i);
  assert.match(source, /Reset journey progress/i);
  assert.match(source, /reset to not started in this browser/i);
  assert.doesNotMatch(source, /sync(?:ed|ing)? successfully/i);
});
