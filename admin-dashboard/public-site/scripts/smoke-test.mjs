import assert from "node:assert/strict";
import { access, readFile } from "node:fs/promises";
import { join } from "node:path";

const root = new URL("../out/", import.meta.url).pathname;
const requiredFiles = [
  "index.html", "discover/index.html", "search/index.html", "guides/index.html", "guides/woon/index.html",
  "journeys/index.html", "map/index.html",
  "categories/index.html", "categories/housing/index.html", "cities/index.html", "cities/amsterdam/index.html",
  "provinces/noord-holland/index.html", "places/index.html", "organizations/index.html", "emergency/index.html",
  "saved/index.html", "status/index.html", "offline/index.html", "app/index.html", "business/index.html",
  "business/apply/index.html", "business/media-kit/index.html", "privacy/index.html", "terms/index.html", "support/index.html", "robots.txt",
  "sitemap.xml", "manifest.webmanifest", "sw.js", ".htaccess", "404.html", "data/search-index.json",
  "data/content-provenance.json", "data/status.json", "data/site-config.json", "images/app-home-nl.webp",
  "images/app-map-en.webp", "images/app-map-nl.webp", "images/og-younew.jpg",
  "icons/apple-touch-icon.png", "icons/icon-192.png", "icons/icon-512.png",
  "static-shell.js"
];
for (const file of requiredFiles) await access(join(root, file));

const home = await readFile(join(root, "index.html"), "utf8");
assert.match(home, /Your next step in the Netherlands/);
assert.match(home, /Use YouNew on the web/);
assert.match(home, /support@younew\.nl/);
assert.match(home, /rel="canonical" href="https:\/\/younew\.nl\/"/);
assert.match(home, /application\/ld\+json/);
for (const path of ["/discover/", "/search/", "/privacy/", "/terms/", "/support/"]) assert.match(home, new RegExp(`href="${path}"`));
assert.doesNotMatch(home, /href=(?:"|')#(?:"|')/);
assert.doesNotMatch(home, /apps\.apple\.com|testflight\.apple\.com/);
assert.doesNotMatch(home, /<script[^>]+src="\/_next\/static\/chunks\//, "Static homepage should not hydrate the full Next runtime");
assert.match(home, /<script src="\/static-shell\.js" defer><\/script>/);

const search = await readFile(join(root, "search/index.html"), "utf8");
assert.match(search, /Search published YouNew content/);
assert.match(search, /name="robots" content="noindex, follow"/);
assert.match(search, /<script[^>]+src="\/_next\/static\/chunks\//, "Interactive routes must retain client JavaScript");

const guide = await readFile(join(root, "guides/woon/index.html"), "utf8");
for (const text of ["!WOON", "Last verified", "Open source", "Report outdated information", "What to do next", "Source-backed summary", "Print guide", "Step-by-step guide not yet released"]) assert.match(guide, new RegExp(text));
assert.match(guide, /data-guide-depth="summary"/);

const journeys = await readFile(join(root, "journeys/index.html"), "utf8");
for (const text of ["New in the Netherlands", "International student", "Starting work", "Looking for housing", "Healthcare setup", "Refugee essentials", "Tourist essentials", "Starting a business", "stays only in this browser"]) assert.match(journeys, new RegExp(text, "i"));
assert.doesNotMatch(journeys, /sync(?:ed|ing)? successfully/i);

const map = await readFile(join(root, "map/index.html"), "utf8");
for (const text of ["Published YouNew coverage", "Released content list", "no location permission", "primary accessible fallback"]) assert.match(map, new RegExp(text, "i"));
assert.doesNotMatch(map, /navigator\.geolocation|tile\.openstreetmap|mapbox/i);

const businessApply = await readFile(join(root, "business/apply/index.html"), "utf8");
for (const field of ["companyName", "contactPerson", "organizationType", "kvkNumber", "targetAudience", "requestedPlacements", "consentToPrivacy", "confirmAccuracy", "websiteConfirmation"]) assert.match(businessApply, new RegExp(`name="${field}"`));
assert.match(businessApply, /nothing is submitted automatically/i);

const mediaKit = await readFile(join(root, "business/media-kit/index.html"), "utf8");
for (const text of ["Request a quote", "DEMO PARTNER CARD", "DEMO REPORT", "ILLUSTRATIVE DATA", "Editorial independence", "Reasons YouNew may refuse or stop a placement"]) assert.match(mediaKit, new RegExp(text, "i"));

const status = await readFile(join(root, "status/index.html"), "utf8");
assert.match(status, /Static status snapshot/);
assert.match(status, /does not (?:use|provide) live (?:uptime )?monitoring/i);

const notFound = await readFile(join(root, "404.html"), "utf8");
assert.match(notFound, /That page isn’t here/);

const searchIndex = JSON.parse(await readFile(join(root, "data/search-index.json"), "utf8"));
assert.equal(searchIndex.schemaVersion, 2);
const provenance = JSON.parse(await readFile(join(root, "data/content-provenance.json"), "utf8"));
assert.equal(provenance.counts.acceptedRecords, 188);
assert.ok(searchIndex.documents.length > provenance.counts.acceptedRecords, "Search should include derived category and useful-page destinations");
assert.ok(searchIndex.documents.every((document) => !/\b(?:draft|archived)\b/i.test(document.id)));

const manifest = JSON.parse(await readFile(join(root, "manifest.webmanifest"), "utf8"));
assert.equal(manifest.display, "standalone");
assert.deepEqual(manifest.icons.map((icon) => icon.sizes), ["192x192", "512x512"]);

const serviceWorker = await readFile(join(root, "sw.js"), "utf8");
assert.match(serviceWorker, /isEmergencyRequest/);
assert.match(serviceWorker, /isMutableConfiguration/);
assert.match(serviceWorker, /\/static-shell\.js/);
assert.match(serviceWorker, /\/_next\/static\/css\//, "The install cache must include the generated stylesheet for a styled first offline launch");

const sitemap = await readFile(join(root, "sitemap.xml"), "utf8");
for (const path of ["https://younew.nl", "/discover", "/guides/woon", "/journeys", "/map", "/cities/amsterdam", "/categories/housing", "/business/apply", "/business/media-kit", "/privacy", "/terms", "/support"]) assert.match(sitemap, new RegExp(path));
const sitemapCount = (sitemap.match(/<url>/g) ?? []).length;
assert.equal(new Set([...sitemap.matchAll(/<loc>([^<]+)<\/loc>/g)].map((match) => match[1])).size, sitemapCount, "Sitemap URLs must be unique");

console.log(`Smoke tests passed: ${sitemapCount} indexable URLs, functional guides/journeys/map/search/business, PWA, metadata, legal pages and 404.`);
