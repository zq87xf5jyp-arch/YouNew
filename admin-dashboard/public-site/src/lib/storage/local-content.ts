export type SavedContentItem = {
  id: string;
  route: string;
  title: string;
  kind: string;
  savedAt: string;
};

export type RecentContentItem = Omit<SavedContentItem, "savedAt"> & {
  viewedAt: string;
};

export type UserPathProfile = "tourist" | "student" | "expat" | "refugee" | "worker" | "resident";
export const userPathProfiles = ["tourist", "student", "expat", "refugee", "worker", "resident"] as const satisfies readonly UserPathProfile[];
import { isKnownJourneyStep, journeyStepStates, type JourneyStepState } from "../journeys/definitions.ts";

export type JourneyProgressState = Record<string, Record<string, JourneyStepState>>;
export type GuideChecklistState = Record<string, Record<string, boolean>>;

type StoredValue<T> = {
  version: 1;
  value: T;
};

const keys = {
  saved: "younew.web.saved.v1",
  recent: "younew.web.recent.v1",
  searches: "younew.web.searches.v1",
  rememberSearches: "younew.web.remember-searches.v1",
  profile: "younew.web.profile.v1",
  journeys: "younew.web.journeys.v1",
  guideChecklists: "younew.web.guide-checklists.v1"
} as const;

const localIdentifier = /^[a-z0-9]+(?:[._:-][a-z0-9]+)*$/;
const reservedIdentifiers = new Set(["constructor", "prototype", "__proto__"]);

function isSafeLocalIdentifier(value: unknown): value is string {
  return typeof value === "string" && localIdentifier.test(value) && !reservedIdentifiers.has(value);
}

function isSafeInternalRoute(value: unknown): value is string {
  return typeof value === "string" && value.startsWith("/") && !value.startsWith("//") && !value.includes("\\");
}

function isUsefulText(value: unknown, maximumLength: number): value is string {
  return typeof value === "string" && value.trim().length > 0 && value.length <= maximumLength;
}

function isIsoDate(value: unknown): value is string {
  if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/.test(value)) return false;
  const parsed = new Date(value);
  return !Number.isNaN(parsed.getTime()) && parsed.toISOString() === value;
}

function sanitizeContentItems<T extends SavedContentItem | RecentContentItem>(
  value: unknown,
  dateKey: "savedAt" | "viewedAt",
  limit: number
): T[] {
  if (!Array.isArray(value)) return [];
  const seen = new Set<string>();
  const result: T[] = [];
  for (const rawItem of value) {
    if (!rawItem || typeof rawItem !== "object" || Array.isArray(rawItem)) continue;
    const item = rawItem as Record<string, unknown>;
    if (
      !isSafeLocalIdentifier(item.id) || seen.has(item.id) ||
      !isSafeInternalRoute(item.route) ||
      !isUsefulText(item.title, 240) ||
      !isUsefulText(item.kind, 80) ||
      !isIsoDate(item[dateKey])
    ) continue;
    seen.add(item.id);
    result.push(item as T);
    if (result.length === limit) break;
  }
  return result;
}

export function sanitizeSavedContentItems(value: unknown): SavedContentItem[] {
  return sanitizeContentItems<SavedContentItem>(value, "savedAt", 250);
}

export function sanitizeRecentContentItems(value: unknown): RecentContentItem[] {
  return sanitizeContentItems<RecentContentItem>(value, "viewedAt", 12);
}

export function sanitizeRecentSearches(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  const result: string[] = [];
  for (const item of value) {
    if (typeof item !== "string") continue;
    const normalized = item.trim();
    if (normalized.length < 2 || normalized.length > 120 || result.includes(normalized)) continue;
    result.push(normalized);
    if (result.length === 8) break;
  }
  return result;
}

export function sanitizeGuideChecklistState(value: unknown): GuideChecklistState {
  if (!value || typeof value !== "object" || Array.isArray(value)) return {};
  const result: GuideChecklistState = {};
  for (const [guideId, rawItems] of Object.entries(value)) {
    if (!isSafeLocalIdentifier(guideId) || !rawItems || typeof rawItems !== "object" || Array.isArray(rawItems)) continue;
    for (const [itemId, completed] of Object.entries(rawItems)) {
      if (!isSafeLocalIdentifier(itemId) || typeof completed !== "boolean") continue;
      (result[guideId] ??= {})[itemId] = completed;
    }
  }
  return result;
}

export function sanitizeUserPathProfile(value: unknown): UserPathProfile | null {
  return typeof value === "string" && userPathProfiles.includes(value as UserPathProfile) ? value as UserPathProfile : null;
}

export function guideChecklistCompletion(states: GuideChecklistState, guideId: string, itemIds: readonly string[]) {
  const completed = itemIds.filter((itemId) => states[guideId]?.[itemId] === true).length;
  return { completed, total: itemIds.length };
}

export function sanitizeJourneyProgress(value: unknown): JourneyProgressState {
  if (!value || typeof value !== "object" || Array.isArray(value)) return {};
  const result: JourneyProgressState = {};
  for (const [journeyId, rawSteps] of Object.entries(value)) {
    if (!rawSteps || typeof rawSteps !== "object" || Array.isArray(rawSteps)) continue;
    for (const [guideId, state] of Object.entries(rawSteps)) {
      if (!isKnownJourneyStep(journeyId, guideId) || !journeyStepStates.includes(state as JourneyStepState)) continue;
      (result[journeyId] ??= {})[guideId] = state as JourneyStepState;
    }
  }
  return result;
}

export function journeyCompletion(states: JourneyProgressState, journeyId: string, guideIds: readonly string[]) {
  const completed = guideIds.filter((guideId) => states[journeyId]?.[guideId] === "completed").length;
  return { completed, total: guideIds.length };
}

export function withoutJourneyProgress(states: JourneyProgressState, journeyId: string): JourneyProgressState {
  const next = { ...states };
  delete next[journeyId];
  return next;
}

function read<T>(key: string, fallback: T): T {
  if (typeof window === "undefined") return fallback;
  try {
    const raw = window.localStorage.getItem(key);
    if (!raw) return fallback;
    const parsed = JSON.parse(raw) as StoredValue<T>;
    return parsed.version === 1 ? parsed.value : fallback;
  } catch {
    return fallback;
  }
}

function notify(key: string) {
  window.dispatchEvent(new CustomEvent("younew:storage", { detail: { key } }));
}

function write<T>(key: string, value: T): boolean {
  if (typeof window === "undefined") return false;
  try {
    const serialized = JSON.stringify({ version: 1, value } satisfies StoredValue<T>);
    window.localStorage.setItem(key, serialized);
    if (window.localStorage.getItem(key) !== serialized) return false;
    notify(key);
    return true;
  } catch {
    return false;
  }
}

function remove(key: string): boolean {
  if (typeof window === "undefined") return false;
  try {
    window.localStorage.removeItem(key);
    notify(key);
    return true;
  } catch {
    return false;
  }
}

export const localContentRepository = {
  saved(): SavedContentItem[] {
    return sanitizeSavedContentItems(read<unknown>(keys.saved, []));
  },
  isSaved(id: string): boolean {
    return this.saved().some((item) => item.id === id);
  },
  toggleSaved(item: Omit<SavedContentItem, "savedAt">): boolean {
    const current = this.saved();
    const exists = current.some((saved) => saved.id === item.id);
    const next = exists
      ? current.filter((saved) => saved.id !== item.id)
      : [{ ...item, savedAt: new Date().toISOString() }, ...current].slice(0, 250);
    return write(keys.saved, next) ? !exists : exists;
  },
  recent(): RecentContentItem[] {
    return sanitizeRecentContentItems(read<unknown>(keys.recent, []));
  },
  rememberViewed(item: Omit<RecentContentItem, "viewedAt">) {
    const next = [
      { ...item, viewedAt: new Date().toISOString() },
      ...this.recent().filter((recent) => recent.id !== item.id)
    ].slice(0, 12);
    write(keys.recent, next);
  },
  recentSearches(): string[] {
    if (!this.searchHistoryEnabled()) return [];
    return sanitizeRecentSearches(read<unknown>(keys.searches, []));
  },
  searchHistoryEnabled(): boolean {
    return read<unknown>(keys.rememberSearches, false) === true;
  },
  setSearchHistoryEnabled(enabled: boolean) {
    write(keys.rememberSearches, enabled);
    if (!enabled) remove(keys.searches);
  },
  rememberSearch(query: string) {
    if (!this.searchHistoryEnabled()) return;
    const normalized = query.trim();
    if (normalized.length < 2) return;
    write(keys.searches, [normalized, ...this.recentSearches().filter((item) => item !== normalized)].slice(0, 8));
  },
  profile(): UserPathProfile | null {
    return sanitizeUserPathProfile(read<unknown>(keys.profile, null));
  },
  setProfile(profile: UserPathProfile) {
    write(keys.profile, profile);
  },
  journeyProgress(): JourneyProgressState {
    return sanitizeJourneyProgress(read<unknown>(keys.journeys, {}));
  },
  journeyStepState(journeyId: string, guideId: string): JourneyStepState {
    if (!isKnownJourneyStep(journeyId, guideId)) return "not-started";
    return this.journeyProgress()[journeyId]?.[guideId] ?? "not-started";
  },
  setJourneyStepState(journeyId: string, guideId: string, state: JourneyStepState): boolean {
    if (!isKnownJourneyStep(journeyId, guideId) || !journeyStepStates.includes(state)) return false;
    const current = this.journeyProgress();
    const next = { ...current, [journeyId]: { ...(current[journeyId] ?? {}), [guideId]: state } };
    return write(keys.journeys, next);
  },
  resetJourney(journeyId: string, guideIds: readonly string[]): boolean {
    if (guideIds.length === 0 || guideIds.some((guideId) => !isKnownJourneyStep(journeyId, guideId))) return false;
    return write(keys.journeys, withoutJourneyProgress(this.journeyProgress(), journeyId));
  },
  guideChecklistState(): GuideChecklistState {
    return sanitizeGuideChecklistState(read<unknown>(keys.guideChecklists, {}));
  },
  setGuideChecklistItem(guideId: string, itemId: string, completed: boolean): boolean {
    if (!isSafeLocalIdentifier(guideId) || !isSafeLocalIdentifier(itemId)) return false;
    const current = this.guideChecklistState();
    const next = { ...current, [guideId]: { ...(current[guideId] ?? {}), [itemId]: completed } };
    return write(keys.guideChecklists, next);
  },
  clearRecentSearches() {
    remove(keys.searches);
  },
  clearAll() {
    for (const key of Object.values(keys)) remove(key);
  },
  keys
};
