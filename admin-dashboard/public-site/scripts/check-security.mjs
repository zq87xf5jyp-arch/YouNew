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
const allowedExternalImageOrigins = new Set([
  "https://commons.wikimedia.org",
  "https://live.staticflickr.com"
]);

function assertSafeImageUrl(value, file) {
  if (!/^(?:https?:)?\/\//i.test(value)) return;
  const parsed = new URL(value, "https://younew.nl");
  assert.equal(parsed.protocol, "https:", `Non-HTTPS image ${value} in ${file}`);
  assert.ok(
    allowedExternalImageOrigins.has(parsed.origin),
    `External image origin ${parsed.origin} in ${file} is not in the production CSP allowlist`
  );
}

for (const file of await files(root)) {
  if (!textExtensions.has(extname(file)) && !file.endsWith(".htaccess")) continue;
  const content = await readFile(file, "utf8");
  for (const pattern of secretPatterns) assert.doesNotMatch(content, pattern, `Potential secret or demo identity in ${file}`);
  if (extname(file) === ".html") {
    for (const match of content.matchAll(/<img\b[^>]*\bsrc=["']([^"']+)["']/gi)) {
      assertSafeImageUrl(match[1], file);
    }
    for (const match of content.matchAll(/<img\b[^>]*\bsrcset=["']([^"']+)["']/gi)) {
      for (const candidate of match[1].split(",")) {
        const value = candidate.trim().split(/\s+/, 1)[0];
        if (value) assertSafeImageUrl(value, file);
      }
    }
  }
}

const headers = await readFile(join(root, ".htaccess"), "utf8");
for (const required of ["Content-Security-Policy", "X-Content-Type-Options", "Referrer-Policy", "X-Frame-Options", "Permissions-Policy", "ErrorDocument 404"]) assert.match(headers, new RegExp(required));
const csp = headers.match(/Content-Security-Policy "([^"]+)"/)?.[1] ?? "";
for (const origin of allowedExternalImageOrigins) assert.match(csp, new RegExp(origin.replaceAll(".", "\\.")));
console.log("Security package check passed: no known secret patterns, remote images match the HTTPS CSP allowlist, and required Hostinger headers are present.");
