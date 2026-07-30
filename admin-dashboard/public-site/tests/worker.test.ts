import assert from "node:assert/strict";
import test from "node:test";

import worker from "../worker/index.js";

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

test("Sites worker preserves the public well-known association file", async () => {
  const pathname = "/.well-known/apple-app-site-association";
  const mock = createAssets({
    [pathname]: new Response("{}", {
      status: 200,
      headers: { "content-type": "application/json" }
    })
  });
  const response = await worker.fetch(
    new Request(`https://younew.nl${pathname}`),
    { ASSETS: mock.assets }
  );

  assert.equal(response.status, 200);
  assert.deepEqual(mock.calls, [pathname]);
  assert.equal(response.headers.get("content-security-policy")?.includes("default-src 'self'"), true);
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
  assert.equal(response.headers.get("x-frame-options"), "DENY");
});

test("Sites worker keeps a real missing route at 404", async () => {
  const mock = createAssets({});
  const response = await worker.fetch(
    new Request("https://younew.nl/missing-release-check-404"),
    { ASSETS: mock.assets }
  );

  assert.equal(response.status, 404);
  assert.deepEqual(mock.calls, [
    "/missing-release-check-404",
    "/__site_payloads/missing-release-check-404/index.html.payload"
  ]);
});
