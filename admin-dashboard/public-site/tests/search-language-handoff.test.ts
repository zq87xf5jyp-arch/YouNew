import test from "node:test";
import assert from "node:assert/strict";
import { publishSearchTask, stageSearchLanguageHandoff, takeSearchLanguageHandoff, type SearchTask } from "../src/lib/search/language-handoff.ts";

test("language changes retain the task once, only inside the same tab", () => {
  const previous = Object.getOwnPropertyDescriptor(globalThis, "window");
  const task: SearchTask = { query: "I need a doctor in Amsterdam", type: "guide", city: "amsterdam", category: "healthcare", province: "noord-holland", profile: "resident", sort: "reviewed" };
  try {
    Object.defineProperty(globalThis, "window", { configurable: true, value: {} });
    publishSearchTask(task);
    assert.equal(takeSearchLanguageHandoff(), null, "ordinary navigation must not transfer a query");
    stageSearchLanguageHandoff();
    publishSearchTask(null);
    assert.deepEqual(takeSearchLanguageHandoff(), task, "unmount must not discard the explicit handoff");
    assert.equal(takeSearchLanguageHandoff(), null, "consume only once");
    publishSearchTask(task); stageSearchLanguageHandoff();
    Object.defineProperty(globalThis, "window", { configurable: true, value: {} });
    assert.equal(takeSearchLanguageHandoff(), null, "reload/new tab clears the query");
  } finally { if (previous) Object.defineProperty(globalThis, "window", previous); else Reflect.deleteProperty(globalThis, "window"); }
});
