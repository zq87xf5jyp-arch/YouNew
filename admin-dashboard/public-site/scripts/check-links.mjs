import assert from "node:assert/strict";
import { access, readdir, readFile } from "node:fs/promises";
import { extname, join, relative, resolve } from "node:path";

const root = resolve(process.env.YOUNEW_STATIC_ROOT ?? new URL("../out/", import.meta.url).pathname);
const rootPrefix = `${root}/`;
const canonicalOrigin = "https://younew.nl";

async function files(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  return (await Promise.all(entries.map((entry) => entry.isDirectory() ? files(join(directory, entry.name)) : [join(directory, entry.name)]))).flat();
}

const allFiles = await files(root);
const htmlFiles = allFiles.filter((file) => extname(file) === ".html");
const htmlCache = new Map();
const broken = new Set();
let checked = 0;

async function existingTarget(pathname) {
  const clean = decodeURIComponent(pathname).replace(/\?.*$/, "").replace(/^\//, "");
  const candidates = clean === "" ? ["index.html"] : extname(clean) ? [clean] : [clean, join(clean, "index.html"), `${clean}.html`];
  for (const candidate of candidates) {
    try {
      const absolute = resolve(root, candidate);
      if (absolute !== root && !absolute.startsWith(rootPrefix)) return null;
      await access(absolute);
      return absolute;
    } catch { /* continue */ }
  }
  return null;
}

async function htmlAtPath(pathname) {
  const target = await existingTarget(pathname);
  if (!target || extname(target) !== ".html") return null;
  if (!htmlCache.has(target)) htmlCache.set(target, await readFile(target, "utf8"));
  return { target, html: htmlCache.get(target) };
}

function fragmentExists(html, fragment) {
  const decoded = decodeURIComponent(fragment);
  const escaped = decoded.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return new RegExp(`(?:id|name)=(?:"|')${escaped}(?:"|')`).test(html);
}

function normalizeInternalReference(reference) {
  const value = reference.trim();
  if (!value || value.startsWith("//")) return null;
  if (value.startsWith("/")) return value;
  try {
    const url = new URL(value);
    if (url.origin === canonicalOrigin) return `${url.pathname}${url.search}${url.hash}`;
  } catch { /* non-URL and external references are outside this static-package check */ }
  return null;
}

function attributeValue(tag, name) {
  const match = tag.match(new RegExp(`\\b${name}\\s*=\\s*(?:"([^"]*)"|'([^']*)')`, "i"));
  return match?.[1] ?? match?.[2] ?? null;
}

function renderedAssetMetadataReferences(html) {
  const references = [];
  for (const match of html.matchAll(/<meta\b[^>]*>/gi)) {
    const tag = match[0];
    const key = (attributeValue(tag, "property") ?? attributeValue(tag, "name") ?? "").toLowerCase();
    if (!["og:image", "og:image:url", "twitter:image", "twitter:image:src"].includes(key)) continue;
    const content = attributeValue(tag, "content");
    if (content) references.push(content);
  }
  return references;
}

async function checkInternalReference(sourceFile, reference) {
  const internalReference = normalizeInternalReference(reference);
  if (!internalReference || internalReference.startsWith("/_next/image")) return;
  const [pathname, fragment] = internalReference.split("#");
  checked += 1;
  const target = await existingTarget(pathname);
  if (!target) {
    broken.add(`${relative(root, sourceFile)}: ${internalReference} (missing target)`);
    return;
  }
  if (fragment) {
    const targetHtml = await htmlAtPath(pathname);
    if (!targetHtml || !fragmentExists(targetHtml.html, fragment)) broken.add(`${relative(root, sourceFile)}: ${internalReference} (missing fragment)`);
  }
}

for (const file of htmlFiles) {
  const html = await readFile(file, "utf8");
  htmlCache.set(file, html);
  assert.doesNotMatch(html, /(?:href|src)=(?:"|')\s*(?:#|)(?:"|')/, `Empty link in ${file}`);
  const references = [...html.matchAll(/(?:href|src|poster)=(?:"|')([^"']+)(?:"|')/g)].map((match) => match[1].replaceAll("&amp;", "&"));
  const srcsetReferences = [...html.matchAll(/srcset=(?:"|')([^"']+)(?:"|')/g)]
    .flatMap((match) => match[1].split(",").map((candidate) => candidate.trim().split(/\s+/)[0]));
  const metadataReferences = renderedAssetMetadataReferences(html);
  for (const reference of [...references, ...srcsetReferences, ...metadataReferences]) await checkInternalReference(file, reference);
}

for (const file of allFiles.filter((candidate) => extname(candidate) === ".css")) {
  const css = await readFile(file, "utf8");
  for (const match of css.matchAll(/url\((?:"|')?([^"')]+)(?:"|')?\)/g)) await checkInternalReference(file, match[1]);
}

const manifestPath = join(root, "manifest.webmanifest");
const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
for (const icon of manifest.icons ?? []) await checkInternalReference(manifestPath, icon.src);
for (const shortcut of manifest.shortcuts ?? []) await checkInternalReference(manifestPath, shortcut.url);

const serviceWorkerPath = join(root, "sw.js");
const serviceWorker = await readFile(serviceWorkerPath, "utf8");
const shellMatch = serviceWorker.match(/const SHELL_URLS = \[([^\]]+)\]/);
assert.ok(shellMatch, "Service-worker shell URL list is missing");
const offlineMatch = serviceWorker.match(/const OFFLINE_URL = "([^"]+)"/);
assert.ok(offlineMatch, "Service-worker offline URL is missing");
for (const match of shellMatch[1].matchAll(/"([^"]+)"|OFFLINE_URL/g)) {
  await checkInternalReference(serviceWorkerPath, match[1] ?? offlineMatch[1]);
}

assert.equal(broken.size, 0, `Broken internal references:\n${[...broken].join("\n")}`);
console.log(`Broken-link and asset check passed: ${checked} internal references, fragments, manifest/SW paths and CSS assets across ${htmlFiles.length} HTML files.`);
