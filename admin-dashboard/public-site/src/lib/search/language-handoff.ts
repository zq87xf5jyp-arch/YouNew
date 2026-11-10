import type { SearchSort } from "./sort.ts";

export type SearchTask = { query: string; type: string; city: string; category: string; province: string; profile: string; sort: SearchSort };
// Only an explicit language switch transfers state. Nothing is written to URLs,
// storage, analytics, or the network; reloading creates a new Window and clears it.
const tasks = new WeakMap<object, { active: SearchTask | null; pending: SearchTask | null }>();
function memory() {
  if (typeof window === "undefined") return null;
  let entry = tasks.get(window);
  if (!entry) { entry = { active: null, pending: null }; tasks.set(window, entry); }
  return entry;
}
export function publishSearchTask(task: SearchTask | null) { const entry = memory(); if (entry) entry.active = task ? { ...task } : null; }
export function stageSearchLanguageHandoff() { const entry = memory(); if (entry) entry.pending = entry.active ? { ...entry.active } : null; }
export function takeSearchLanguageHandoff(): SearchTask | null { const entry = memory(); if (!entry) return null; const task = entry.pending; entry.pending = null; return task; }
