import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import worker from "../worker/index.js";

const siteRoot = new URL("../", import.meta.url);
const publicContent = JSON.parse(await readFile(new URL("src/generated/public-content.json", siteRoot), "utf8"));
const sitesBuildScript = await readFile(new URL("scripts/build-sites.sh", siteRoot), "utf8");

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

test("Sites worker serves the legacy favicon path from the canonical PNG asset", async () => {
  const favicon = new Uint8Array([137, 80, 78, 71]);
  const mock = createAssets({
    "/icons/favicon.png": new Response(favicon, {
      status: 200,
      headers: { "content-type": "image/png" }
    })
  });
  const response = await worker.fetch(
    new Request("https://younew.nl/favicon.ico"),
    { ASSETS: mock.assets }
  );

  assert.equal(response.status, 200);
  assert.equal(response.headers.get("content-type"), "image/png");
  assert.equal(response.headers.get("x-content-type-options"), "nosniff");
  assert.deepEqual(mock.calls, ["/icons/favicon.png"]);
  assert.deepEqual(new Uint8Array(await response.arrayBuffer()), favicon);
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

test("Sites package routes the association file through a worker-first payload", () => {
  assert.match(sitesBuildScript, /association_source=.*\.well-known\/apple-app-site-association/);
  assert.match(sitesBuildScript, /association_payload="\$payload_root\/\.well-known\/apple-app-site-association\.payload"/);
  assert.match(sitesBuildScript, /mv "\$association_source" "\$association_payload"/);
});

test("Sites package routes the service worker through a worker-first payload", () => {
  assert.match(sitesBuildScript, /service_worker_source="\$project_root\/dist\/client\/sw\.js"/);
  assert.match(sitesBuildScript, /service_worker_payload="\$payload_root\/sw\.js\.payload"/);
  assert.match(sitesBuildScript, /mv "\$service_worker_source" "\$service_worker_payload"/);
});

test("Sites worker serves the service worker with security and no-cache headers", async () => {
  const payloadPathname = "/__site_payloads/sw.js.payload";
  const mock = createAssets({
    [payloadPathname]: new Response("self.addEventListener('fetch', () => {});", {
      status: 200,
      headers: { "content-type": "application/octet-stream" }
    })
  });
  const response = await worker.fetch(
    new Request("https://younew.nl/sw.js"),
    { ASSETS: mock.assets }
  );

  assert.equal(response.status, 200);
  assert.deepEqual(mock.calls, [payloadPathname]);
  assert.equal(response.headers.get("content-type"), "text/javascript; charset=utf-8");
  assert.equal(response.headers.get("cache-control"), "no-cache, no-store, must-revalidate");
  assert.equal(response.headers.get("x-content-type-options"), "nosniff");
  assert.match(response.headers.get("content-security-policy") ?? "", /default-src 'self'/);
});

test("Sites worker recovers crawler-only null image requests without changing real 404 semantics", async () => {
  const mock = createAssets({});
  const crawlerResponse = await worker.fetch(
    new Request("https://younew.nl/places/example/null", {
      headers: { Accept: "image/avif,image/webp,image/*,*/*;q=0.8" }
    }),
    { ASSETS: mock.assets }
  );
  const navigationResponse = await worker.fetch(
    new Request("https://younew.nl/places/example/null", {
      headers: { Accept: "text/html" }
    }),
    { ASSETS: mock.assets }
  );

  assert.equal(crawlerResponse.status, 302);
  assert.equal(crawlerResponse.headers.get("location"), "https://younew.nl/images/og-younew.jpg");
  assert.equal(crawlerResponse.headers.get("x-robots-tag"), "noindex, nofollow, noarchive");
  assert.equal(navigationResponse.status, 404);
  assert.deepEqual(mock.calls, [
    "/places/example/null",
    "/__site_payloads/places/example/null/index.html.payload",
    "/__site_payloads/404.html.payload"
  ]);
});

test("Sites worker serves the worker-first association payload as JSON", async () => {
  const pathname = "/.well-known/apple-app-site-association";
  const payloadPathname = "/__site_payloads/.well-known/apple-app-site-association.payload";
  const mock = createAssets({
    [payloadPathname]: new Response("{}", {
      status: 200,
      headers: { "content-type": "application/octet-stream" }
    })
  });
  const response = await worker.fetch(
    new Request(`https://younew.nl${pathname}`),
    { ASSETS: mock.assets }
  );

  assert.equal(response.status, 200);
  assert.deepEqual(mock.calls, [pathname, payloadPathname]);
  assert.equal(response.headers.get("content-type"), "application/json");
  assert.equal(response.headers.get("x-content-type-options"), "nosniff");
  assert.equal(response.headers.get("content-security-policy")?.includes("default-src 'self'"), true);
  assert.equal(await response.text(), "{}");
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
