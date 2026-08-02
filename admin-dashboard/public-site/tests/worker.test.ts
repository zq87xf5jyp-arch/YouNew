import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import worker from "../worker/index.js";

const siteRoot = new URL("../", import.meta.url);
const publicContent = JSON.parse(await readFile(new URL("src/generated/public-content.json", siteRoot), "utf8"));

function createAssets(responses: Record<string, Response>) {
  const calls: string[] = [];
  return {
    calls,
    assets: {
      async fetch(request: Request) {
        const pathname = new URL(request.url).pathname;
        calls.push(pathname);
        return responses[pathname] ?? new Response(null, { status: 404 });
      }
    }
  };
}

test("Sites worker blocks deployment-only files without touching asset storage", async () => {
  for (const pathname of ["/.htaccess", "/_headers", "/nested/.private"]) {
    const mock = createAssets({});
    const response = await worker.fetch(
      new Request(`https://younew.nl${pathname}`),
      { ASSETS: mock.assets }
    );

    assert.equal(response.status, 404);
    assert.deepEqual(mock.calls, []);
    assert.equal(response.headers.get("x-content-type-options"), "nosniff");
  }
});

test("Sites worker permanently redirects www to the canonical origin", async () => {
  const mock = createAssets({});
  const response = await worker.fetch(
    new Request("https://www.younew.nl/guides/?topic=brp"),
    { ASSETS: mock.assets }
  );

  assert.equal(response.status, 301);
  assert.equal(response.headers.get("location"), "https://younew.nl/guides/?topic=brp");
  assert.equal(response.headers.get("x-frame-options"), "DENY");
  assert.deepEqual(mock.calls, []);
});

test("Sites worker exposes only the MTA-STS policy on its dedicated hostname", async () => {
  const policyPath = "/.well-known/mta-sts.txt";
  const mock = createAssets({
    [policyPath]: new Response("version: STSv1\nmode: testing\n", {
      status: 200,
      headers: { "content-type": "text/plain" }
    })
  });

  const policy = await worker.fetch(
    new Request(`https://mta-sts.younew.nl${policyPath}`),
    { ASSETS: mock.assets }
  );
  const homepage = await worker.fetch(
    new Request("https://mta-sts.younew.nl/"),
    { ASSETS: mock.assets }
  );

  assert.equal(policy.status, 200);
  assert.deepEqual(mock.calls, [policyPath]);
  assert.equal(homepage.status, 404);
});

test("Sites worker serves the public well-known association file as JSON", async () => {
  const pathname = "/.well-known/apple-app-site-association";
  const mock = createAssets({
    [pathname]: new Response("{}", {
      status: 200,
      headers: { "content-type": "application/octet-stream" }
    })
  });
  const response = await worker.fetch(
    new Request(`https://younew.nl${pathname}`),
    { ASSETS: mock.assets }
  );

  assert.equal(response.status, 200);
  assert.deepEqual(mock.calls, [pathname]);
  assert.equal(response.headers.get("content-type"), "application/json");
  assert.equal(response.headers.get("x-content-type-options"), "nosniff");
  assert.equal(response.headers.get("content-security-policy")?.includes("default-src 'self'"), true);
});

test("Sites worker permits every governed public image host and Wikimedia redirects", async () => {
  const mock = createAssets({
    "/": new Response("<!doctype html>", { status: 200, headers: { "content-type": "text/html" } })
  });
  const response = await worker.fetch(new Request("https://younew.nl/"), { ASSETS: mock.assets });
  const policy = response.headers.get("content-security-policy") ?? "";
  const mediaHosts = new Set<string>(
    publicContent.entities.flatMap((entity: { images?: Array<{ url: string }> }) =>
      (entity.images ?? []).map((image) => new URL(image.url).origin)
    )
  );

  for (const origin of mediaHosts) {
    const escapedOrigin = origin.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    assert.match(policy, new RegExp(escapedOrigin));
  }
  assert.match(policy, /https:\/\/commons\.wikimedia\.org/);
  assert.match(policy, /https:\/\/upload\.wikimedia\.org/);
});

test("Sites worker resolves an exported directory through its index asset", async () => {
  const pathname = "/business/workspace/";
  const indexPathname = "/__site_payloads/business/workspace/index.html.payload";
  const mock = createAssets({
    [indexPathname]: new Response("<!doctype html><title>Workspace</title>", {
      status: 200,
      headers: { "content-type": "application/octet-stream" }
    })
  });
  const response = await worker.fetch(
    new Request(`https://younew.nl${pathname}`),
    { ASSETS: mock.assets }
  );

  assert.equal(response.status, 200);
  assert.deepEqual(mock.calls, [pathname, indexPathname]);
  assert.equal(await response.text(), "<!doctype html><title>Workspace</title>");
  assert.equal(response.headers.get("content-type"), "text/html; charset=utf-8");
  assert.match(response.headers.get("cache-control") ?? "", /(?:^|,\s*)no-transform(?:,|$)/);
  assert.equal(response.headers.get("x-frame-options"), "DENY");
});

test("Sites worker keeps a real missing route at 404", async () => {
  const mock = createAssets({
    "/__site_payloads/404.html.payload": new Response(
      "<!doctype html><title>Page not found</title>",
      { status: 200, headers: { "content-type": "application/octet-stream" } }
    )
  });
  const response = await worker.fetch(
    new Request("https://younew.nl/missing-release-check-404"),
    { ASSETS: mock.assets }
  );

  assert.equal(response.status, 404);
  assert.deepEqual(mock.calls, [
    "/missing-release-check-404",
    "/__site_payloads/missing-release-check-404/index.html.payload",
    "/__site_payloads/404.html.payload"
  ]);
  assert.equal(response.headers.get("content-type"), "text/html; charset=utf-8");
  assert.match(response.headers.get("cache-control") ?? "", /(?:^|,\s*)no-transform(?:,|$)/);
  assert.equal(await response.text(), "<!doctype html><title>Page not found</title>");
});
