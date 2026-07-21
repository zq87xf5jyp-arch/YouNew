import { readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

const outputRoot = new URL("../out/", import.meta.url).pathname;
const file = join(outputRoot, "index.html");
const html = await readFile(file, "utf8");
const staticHtml = html
  .replace(/<script(?![^>]*type="application\/ld\+json")[^>]*>[\s\S]*?<\/script>/g, "")
  .replace(/<link(?=[^>]*rel="preload")(?=[^>]*as="script")[^>]*>/g, "")
  .replace("</body>", '<script src="/static-shell.js" defer></script></body>');

await writeFile(file, staticHtml);
console.log("Replaced unnecessary homepage hydration with progressive enhancement.");
