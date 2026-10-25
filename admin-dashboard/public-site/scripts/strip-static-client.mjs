import { createHash } from "node:crypto";
import { readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const outputRoot = fileURLToPath(new URL("../out/", import.meta.url));
const file = join(outputRoot, "index.html");
const html = await readFile(file, "utf8");
// The private search handoff lives only in the current document's memory.
// Removing hydration would force a native navigation and lose that query.
// Keep this build step as a guard rather than silently restoring a raw GET.
if (!html.includes('data-private-search-form="true"') || !html.includes("/_next/static/")) {
  throw new Error("Homepage private search requires its form and client runtime.");
}
console.log("Retained homepage hydration for the private in-memory search handoff.");
// Preserve the existing offline manifest contract without loading a second runtime.
const staticShell = await readFile(join(outputRoot, "static-shell.js"), "utf8");
const staticShellName = `static-shell.${createHash("sha256").update(staticShell).digest("hex").slice(0, 12)}.js`;
await writeFile(join(outputRoot, staticShellName), staticShell, "utf8");
