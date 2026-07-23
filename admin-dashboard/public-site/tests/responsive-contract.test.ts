import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const css = await readFile(new URL("../src/app/globals.css", import.meta.url), "utf8");

test("mobile navigation remains reachable in short viewports", () => {
  assert.match(css, /\.site-header \{[^}]*z-index:120;/);
  assert.match(css, /\.mobile-menu nav \{[^}]*max-height:calc\(100dvh - 82px - env\(safe-area-inset-bottom\)\);[^}]*overflow-y:auto;[^}]*overscroll-behavior:contain;/);
});

test("narrow layouts reflow without a forced 320px body and retain readable metric labels", () => {
  assert.doesNotMatch(css, /body \{[^}]*min-width:320px;/);
  assert.match(css, /@media \(max-width:430px\) \{[\s\S]*?\.hero-proof dd \{ font-size:11px; \}/);
  assert.match(css, /@media \(max-width:760px\) \{[\s\S]*?\.header-cta \{ display:none; \}/);
  assert.match(css, /@media \(max-width:760px\) \{[\s\S]*?\.hero-section::before \{ display:none; \}/, "mobile hero decoration must not create layout shift");
});
