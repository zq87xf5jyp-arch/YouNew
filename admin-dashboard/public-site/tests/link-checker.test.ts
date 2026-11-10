import assert from "node:assert/strict";
import { mkdtemp, mkdir, writeFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { spawnSync } from "node:child_process";
import test from "node:test";

test("static link audit resolves directory indexes and still rejects missing fragments", async () => {
  const fixture = await mkdtemp(join(tmpdir(), "younew-links-test-"));
  try {
    await mkdir(join(fixture,"nl"));
    await writeFile(join(fixture,"index.html"),'<a href="/nl/#cities">Cities</a>');
    await writeFile(join(fixture,"nl/index.html"),'<h2 id="cities">Steden</h2>');
    await writeFile(join(fixture,"manifest.webmanifest"),'{}');
    await writeFile(join(fixture,"sw.js"),'const OFFLINE_URL = "/"; const SHELL_URLS = ["/", OFFLINE_URL];');
    const run = () => spawnSync(process.execPath,[new URL("../scripts/check-links.mjs",import.meta.url).pathname],{env:{...process.env,YOUNEW_STATIC_ROOT:fixture},encoding:"utf8"});
    const valid = run();
    assert.equal(valid.status,0,valid.stderr);
    await writeFile(join(fixture,"nl/index.html"),'<h2 id="elsewhere">Steden</h2>');
    const invalid = run();
    assert.notEqual(invalid.status,0);
    assert.match(invalid.stderr,/missing fragment/);
  } finally {
    await rm(fixture,{recursive:true,force:true});
  }
});
