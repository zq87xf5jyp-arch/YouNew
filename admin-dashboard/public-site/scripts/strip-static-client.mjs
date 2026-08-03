import { createHash } from "node:crypto";
import { readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

const outputRoot = new URL("../out/", import.meta.url).pathname;
const file = join(outputRoot, "index.html");
const html = await readFile(file, "utf8");
const staticShell = await readFile(join(outputRoot, "static-shell.js"));
const themeInit = await readFile(join(outputRoot, "theme-init.js"), "utf8");
const staticShellVersion = createHash("sha256").update(staticShell).digest("hex").slice(0, 12);
const staticShellPath = `/static-shell.${staticShellVersion}.js`;
await writeFile(join(outputRoot, staticShellPath.slice(1)), staticShell);
const staticHtml = html
  .replace(/<script(?![^>]*type="application\/ld\+json")[^>]*>[\s\S]*?<\/script>/g, "")
  .replace(/<link(?=[^>]*rel="preload")(?=[^>]*as="script")[^>]*>/g, "")
  .replace("</head>", `<script>${themeInit}</script></head>`)
  .replace("</body>", `<script src="${staticShellPath}" defer></script></body>`);

await writeFile(file, staticHtml);
console.log(`Replaced unnecessary homepage hydration with progressive enhancement ${staticShellPath}.`);
