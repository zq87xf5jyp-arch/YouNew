import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import { runInNewContext } from "node:vm";

const source = await readFile(new URL("../public/sw.js", import.meta.url), "utf8");
const version = source.match(/const CACHE_VERSION = "([^"]+)"/)?.[1];
const origin = "https://younew.test";
const privateQuery = "test.person@example.invalid BSN 000000000";

function worker() {
  const listeners = new Map<string, (event: unknown) => void>();
  const stores = new Map<string, Map<string, Response>>();
  const fetched: string[] = [];
  const key = (input: string | Request) => typeof input === "string" ? new URL(input, origin).href : input.url;
  const cache = (name: string) => {
    let data = stores.get(name);
    if (!data) { data = new Map(); stores.set(name, data); }
    return {
      put: async (input: string | Request, value: Response) => { data.set(key(input), value); },
      match: async (input: string | Request) => data.get(key(input)),
      keys: async () => [...data.keys()].map((url) => new Request(url)),
      delete: async (input: string | Request) => data.delete(key(input)),
      add: async (input: string | Request) => { data.set(key(input), new Response("shell")); }
    };
  };
  let offline = false;
  runInNewContext(source, {
    URL, Response,
    self: { location: { origin }, addEventListener: (name: string, fn: (event: unknown) => void) => listeners.set(name, fn), clients: { claim: async () => {} }, skipWaiting: async () => {} },
    caches: {
      open: async (name: string) => cache(name),
      keys: async () => [...stores.keys()],
      delete: async (name: string) => stores.delete(name),
      match: async (input: string | Request) => { for (const data of stores.values()) if (data.has(key(input))) return data.get(key(input)); }
    },
    fetch: async (request: Request) => { fetched.push(request.url); if (offline) throw new Error("offline"); return new Response("guide"); }
  });
  return {
    stores, fetched, cache,
    offline: () => { offline = true; },
    activate: async () => { let completion: Promise<void> | undefined; listeners.get("activate")?.({ waitUntil: (value: Promise<void>) => { completion = value; } }); await completion; },
    request: async (path: string, mode = "navigate", destination = "") => {
      let response: Promise<Response> | undefined;
      listeners.get("fetch")?.({ request: { method: "GET", url: new URL(path, origin).href, mode, destination }, respondWith: (value: Promise<Response>) => { response = value; } });
      return response;
    }
  };
}

test("guide cache omits private q on write and offline read while network and other parameters stay intact", async () => {
  const sw = worker();
  const path = `/guides/woon/?q=${encodeURIComponent(privateQuery)}&view=summary`;
  assert.equal(await (await sw.request(path))?.text(), "guide");
  assert.equal(sw.fetched[0], `${origin}${path}`);
  assert.deepEqual([...sw.stores.get(`${version}-guides`)!.keys()], [`${origin}/guides/woon/?view=summary`]);
  sw.offline();
  assert.equal(await (await sw.request(`/guides/woon/?q=another-private-query&view=summary`))?.text(), "guide");
});

test("activate deletes only q-bearing same-origin keys in current owned caches plus already-obsolete owned caches", async () => {
  const sw = worker();
  for (const name of [`${version}-shell`, `${version}-guides`, `${version}-assets`, "another-app-cache"]) {
    const cache = sw.cache(name);
    await cache.put(`${origin}/guides/woon/?q=${encodeURIComponent(privateQuery)}`, new Response("legacy"));
    await cache.put(`${origin}/guides/woon/?view=summary`, new Response("keep"));
    await cache.put("https://other.test/guide?q=public", new Response("external"));
  }
  await sw.cache("younew-web-obsolete-guides").put(`${origin}/guides/old/`, new Response("old"));
  await sw.activate();
  assert.equal(sw.stores.has("younew-web-obsolete-guides"), false);
  for (const name of [`${version}-shell`, `${version}-guides`, `${version}-assets`]) {
    assert.deepEqual([...sw.stores.get(name)!.keys()], [`${origin}/guides/woon/?view=summary`, "https://other.test/guide?q=public"]);
  }
  assert.equal(sw.stores.get("another-app-cache")!.size, 3);
});

test("search, map and directory navigations do not enter caches; static asset key semantics stay intact", async () => {
  const sw = worker();
  for (const route of ["search", "map", "municipalities"]) await sw.request(`/${route}/?q=${encodeURIComponent(privateQuery)}`);
  assert.equal(sw.stores.size, 0);
  await sw.request("/_next/static/chunks/page.js?v=build", "cors", "script");
  assert.deepEqual([...sw.stores.get(`${version}-assets`)!.keys()], [`${origin}/_next/static/chunks/page.js?v=build`]);
});
