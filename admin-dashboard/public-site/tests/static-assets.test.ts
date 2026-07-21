import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtemp, mkdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";

const checkScript = new URL("../scripts/check-links.mjs", import.meta.url).pathname;

function runAssetCheck(root: string) {
  return spawnSync(process.execPath, [checkScript], {
    encoding: "utf8",
    env: { ...process.env, YOUNEW_STATIC_ROOT: root }
  });
}

test("static reference QA fails closed for missing rendered and social image assets", async () => {
  const root = await mkdtemp(join(tmpdir(), "younew-static-assets-"));
  try {
    await writeFile(join(root, "index.html"), `<!doctype html>
      <html><head>
        <meta property="og:image" content="https://younew.nl/images/og-younew.jpg">
      </head><body>
        <img src="/images/app-home-en.webp" alt="YouNew app home">
      </body></html>`);
    await writeFile(join(root, "manifest.webmanifest"), JSON.stringify({ icons: [], shortcuts: [] }));
    await writeFile(join(root, "sw.js"), `const OFFLINE_URL = "/";\nconst SHELL_URLS = [OFFLINE_URL];\n`);

    const missing = runAssetCheck(root);
    const missingOutput = `${missing.stdout}\n${missing.stderr}`;
    assert.notEqual(missing.status, 0);
    assert.match(missingOutput, /\/images\/app-home-en\.webp \(missing target\)/);
    assert.match(missingOutput, /\/images\/og-younew\.jpg \(missing target\)/);

    await mkdir(join(root, "images"));
    await writeFile(join(root, "images/app-home-en.webp"), "fixture");
    await writeFile(join(root, "images/og-younew.jpg"), "fixture");

    const complete = runAssetCheck(root);
    assert.equal(complete.status, 0, `${complete.stdout}\n${complete.stderr}`);
    assert.match(complete.stdout, /Broken-link and asset check passed/);
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});
