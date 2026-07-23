import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { spawn } from "node:child_process";
import { once } from "node:events";
import { readdir, readFile } from "node:fs/promises";
import { extname, join, relative } from "node:path";

const siteRoot = new URL("../", import.meta.url).pathname;
const outRoot = join(siteRoot, "out");
const mirrorRoot = join(siteRoot, "dist/client");
const canonicalOrigin = "https://younew.nl";

async function files(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  return (await Promise.all(entries.map((entry) => entry.isDirectory() ? files(join(directory, entry.name)) : [join(directory, entry.name)]))).flat();
}

function routeForHtml(path) {
  const rel = relative(outRoot, path).replaceAll("\\", "/");
  if (rel === "index.html") return "/";
  if (rel === "404.html") return null;
  if (rel.endsWith("/index.html")) return `/${rel.slice(0, -"index.html".length)}`;
  if (rel.endsWith(".html")) return `/${rel.slice(0, -".html".length)}/`;
  return null;
}

function sha256(value) {
  return createHash("sha256").update(value).digest("hex");
}

async function treeFingerprint(root) {
  const result = new Map();
  for (const path of (await files(root)).sort()) result.set(relative(root, path).replaceAll("\\", "/"), sha256(await readFile(path)));
  return result;
}

const outFiles = await files(outRoot);
const htmlFiles = outFiles.filter((path) => extname(path) === ".html");
const sitemap = await readFile(join(outRoot, "sitemap.xml"), "utf8");
const sitemapUrls = [...sitemap.matchAll(/<loc>([^<]+)<\/loc>/g)].map((match) => match[1].replaceAll("&amp;", "&"));
assert.equal(new Set(sitemapUrls).size, sitemapUrls.length, "Sitemap contains duplicate URLs");

const indexableRoutes = new Set();
for (const path of htmlFiles) {
  const route = routeForHtml(path);
  if (!route) continue;
  const html = await readFile(path, "utf8");
  const noIndex = /<meta[^>]+name="robots"[^>]+content="[^"]*noindex/i.test(html);
  const canonicals = [...html.matchAll(/<link[^>]+rel="canonical"[^>]+href="([^"]+)"/g)].map((match) => match[1]);
  if (noIndex) continue;
  assert.equal(canonicals.length, 1, `${route} must have exactly one canonical`);
  const expected = route === "/" ? `${canonicalOrigin}/` : `${canonicalOrigin}${route}`;
  assert.equal(canonicals[0], expected, `${route} has an unexpected canonical`);
  assert.match(canonicals[0], /^https:\/\/younew\.nl\/(?:.*\/)?$/, `${route} canonical must use the production origin and trailing slash`);
  indexableRoutes.add(expected);
}
assert.deepEqual(new Set(sitemapUrls), indexableRoutes, `Sitemap/HTML route mismatch (sitemap ${sitemapUrls.length}, indexable HTML ${indexableRoutes.size})`);

const robots = await readFile(join(outRoot, "robots.txt"), "utf8");
assert.match(robots, /Sitemap: https:\/\/younew\.nl\/sitemap\.xml/);
for (const route of ["/admin/", "/business/dashboard/", "/_next/data/"]) assert.match(robots, new RegExp(`Disallow: ${route.replaceAll("/", "\\/")}`));
for (const route of ["/saved/", "/search/", "/offline/"]) assert.doesNotMatch(robots, new RegExp(`Disallow: ${route.replaceAll("/", "\\/")}`), `${route} must remain crawlable so its page-level noindex can be read`);

const manifest = JSON.parse(await readFile(join(outRoot, "manifest.webmanifest"), "utf8"));
assert.equal(manifest.display, "standalone");
assert.equal(manifest.scope, "/");
assert.equal(manifest.start_url, "/");
assert.ok(Array.isArray(manifest.icons) && manifest.icons.length >= 2);
for (const icon of manifest.icons) {
  const data = await readFile(join(outRoot, icon.src.replace(/^\//, "")));
  assert.equal(data.subarray(1, 4).toString(), "PNG", `${icon.src} is not PNG`);
  const dimensions = `${data.readUInt32BE(16)}x${data.readUInt32BE(20)}`;
  assert.equal(dimensions, icon.sizes, `${icon.src} dimensions do not match manifest`);
}
for (const shortcut of manifest.shortcuts ?? []) {
  const route = shortcut.url.replace(/^\//, "");
  await readFile(join(outRoot, route, "index.html"));
}

const serviceWorker = await readFile(join(outRoot, "sw.js"), "utf8");
assert.match(serviceWorker, /^const CACHE_VERSION = "younew-web-[a-f0-9]{12}";/);
assert.doesNotMatch(serviceWorker, /__BUILD_VERSION__|Promise\.allSettled/);
for (const marker of ["/offline/", "/guides/", "/journeys/", "/static-shell.js", "/_next/static/css/", "isEmergencyRequest", "isMutableConfiguration", "url.origin !== self.location.origin"]) assert.match(serviceWorker, new RegExp(marker.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));

const headers = await readFile(join(outRoot, ".htaccess"), "utf8");
assert.match(headers, /ErrorDocument 404 \/404\.html/);
assert.match(headers, /AddType application\/manifest\+json \.webmanifest/);
assert.match(headers, /FilesMatch "\^\(sw\\\.js\|static-shell\\\.js\|manifest\\\.webmanifest/);
const csp = headers.match(/Content-Security-Policy "([^"]+)"/)?.[1];
assert.ok(csp, "CSP is missing");
for (const directive of ["default-src 'self'", "base-uri 'self'", "form-action 'self' mailto:", "frame-ancestors 'none'", "object-src 'none'", "img-src 'self' data: https://commons.wikimedia.org https://live.staticflickr.com", "script-src 'self'", "connect-src 'self'"]) assert.match(csp, new RegExp(directive.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));

const authoredExtensions = new Set([".html", ".json", ".xml", ".css", ".txt", ".webmanifest", ".htaccess"]);
const localUrlPattern = /(?:https?:\/\/(?:localhost|127(?:\.\d{1,3}){3}|\[::1\])(?::\d+)?|file:\/{2,}|\/Users\/[A-Za-z0-9._-]+\/|\/home\/[A-Za-z0-9._-]+\/|[A-Za-z]:\\Users\\)/i;
const secretPatterns = [
  /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/,
  /\b(?:OPENAI_API_KEY|SUPABASE_SERVICE_ROLE_KEY)\s*[:=]/,
  /\bsk-[A-Za-z0-9_-]{20,}\b/
];
for (const path of outFiles) {
  const rel = relative(outRoot, path).replaceAll("\\", "/");
  const authoredJavaScript = rel === "sw.js" || rel === "static-shell.js";
  if (!authoredExtensions.has(extname(path)) && !path.endsWith(".htaccess") && !authoredJavaScript) continue;
  const value = await readFile(path, "utf8");
  assert.doesNotMatch(value, localUrlPattern, `Local-only URL/path leaked into ${rel}`);
  for (const pattern of secretPatterns) assert.doesNotMatch(value, pattern, `Potential secret leaked into ${rel}`);
}

const publicContent = JSON.parse(await readFile(join(siteRoot, "src/generated/public-content.json"), "utf8"));
assert.ok(publicContent.entities.every((entity) => entity.status === "published"));
assert.equal(publicContent.stats.practicalGuides + publicContent.stats.summaryGuides, publicContent.stats.guides);
assert.ok(publicContent.entities.every((entity) => entity.practicalGuide == null || entity.practicalGuide.status === "published"));
const searchIndex = JSON.parse(await readFile(join(outRoot, "data/search-index.json"), "utf8"));
assert.ok(searchIndex.documents.every((document) => !/\b(?:draft|archived)\b/i.test(document.id)));
assert.doesNotMatch(sitemap, /\b(?:draft|preview|archived)\b/i);

const outFingerprint = await treeFingerprint(outRoot);
const mirrorFingerprint = await treeFingerprint(mirrorRoot);
assert.deepEqual(mirrorFingerprint, outFingerprint, "out/ and dist/client/ are not byte-identical");

const previewPort = 43000 + (process.pid % 1000);
const preview = spawn(process.execPath, ["scripts/preview.mjs"], {
  cwd: siteRoot,
  env: { ...process.env, PORT: String(previewPort), HOST: "127.0.0.1" },
  stdio: ["ignore", "pipe", "pipe"]
});
let previewError = "";
preview.stderr.on("data", (chunk) => { previewError += chunk.toString(); });
try {
  let ready = false;
  for (let attempt = 0; attempt < 60; attempt += 1) {
    try {
      const response = await fetch(`http://127.0.0.1:${previewPort}/`);
      if (response.ok) { ready = true; break; }
    } catch { /* retry */ }
    await new Promise((resolve) => setTimeout(resolve, 50));
  }
  assert.ok(ready, `Preview did not start: ${previewError}`);
  const missing = await fetch(`http://127.0.0.1:${previewPort}/predeploy-definitely-missing/`);
  assert.equal(missing.status, 404);
  assert.match(await missing.text(), /That page isn’t here/);
} finally {
  preview.kill("SIGTERM");
  await Promise.race([once(preview, "exit"), new Promise((resolve) => setTimeout(resolve, 1500))]);
}

console.log(`Pre-deploy package check passed: ${indexableRoutes.size} sitemap routes, ${htmlFiles.length} HTML files, exact out/dist mirror, real HTTP 404, no drafts/local paths/secrets.`);
