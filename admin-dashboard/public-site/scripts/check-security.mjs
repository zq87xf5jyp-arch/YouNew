import assert from "node:assert/strict";
import { readdir, readFile } from "node:fs/promises";
import { extname, join } from "node:path";

const root = new URL("../out/", import.meta.url).pathname;
async function files(directory) { const entries = await readdir(directory, { withFileTypes: true }); return (await Promise.all(entries.map((entry) => entry.isDirectory() ? files(join(directory, entry.name)) : [join(directory, entry.name)]))).flat(); }

const textExtensions = new Set([".html", ".js", ".json", ".txt", ".xml", ".css", ".webmanifest", ".htaccess"]);
const secretPatterns = [
  /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/,
  /\bOPENAI_API_KEY\b/,
  /\bSUPABASE_SERVICE_ROLE_KEY\b/,
  /\bsk-[A-Za-z0-9_-]{20,}\b/,
  /demo@younew\.nl/
];

for (const file of await files(root)) {
  if (!textExtensions.has(extname(file)) && !file.endsWith(".htaccess")) continue;
  const content = await readFile(file, "utf8");
  for (const pattern of secretPatterns) assert.doesNotMatch(content, pattern, `Potential secret or demo identity in ${file}`);
  if (extname(file) === ".html") {
    for (const match of content.matchAll(/<img\b[^>]*\bsrc=["']([^"']+)["']/gi)) {
      assert.doesNotMatch(match[1], /^(?:https?:)?\/\//i, `External image ${match[1]} in ${file} is incompatible with the self-only image CSP`);
    }
  }
}

const headers = await readFile(join(root, ".htaccess"), "utf8");
for (const required of ["Content-Security-Policy", "X-Content-Type-Options", "Referrer-Policy", "X-Frame-Options", "Permissions-Policy", "ErrorDocument 404"]) assert.match(headers, new RegExp(required));
console.log("Security package check passed: no known secret patterns and required Hostinger headers are present.");
