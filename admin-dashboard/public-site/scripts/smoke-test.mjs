import assert from "node:assert/strict";
import { access, readFile } from "node:fs/promises";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../out/", import.meta.url));
const requiredFiles = [
  "index.html", "start/index.html", "my-younew/index.html", "discover/index.html", "search/index.html", "guides/index.html", "guides/driving-licence-amsterdam/index.html",
  "journeys/index.html", "map/index.html",
  "categories/index.html", "categories/housing/index.html", "cities/index.html", "cities/amsterdam/index.html",
  "nl/index.html", "nl/categorieen/index.html", "nl/categorieen/healthcare/index.html", "nl/zoeken/index.html",
  "nl/organisaties/index.html", "nl/voor-bedrijven/index.html",
  "nl/voor-bedrijven/lokaal/index.html", "nl/voor-bedrijven/aanmelden/index.html",
  "nl/stadsgidsen/amsterdam/index.html", "nl/stadsgidsen/rotterdam/index.html",
  "nl/stadsgidsen/den-haag/index.html", "nl/stadsgidsen/utrecht/index.html", "nl/stadsgidsen/eindhoven/index.html",
  "municipalities/index.html", "municipalities/amsterdam/index.html",
  "provinces/noord-holland/index.html", "places/index.html", "organizations/index.html", "emergency/index.html",
  "saved/index.html", "status/index.html", "offline/index.html", "app/index.html", "business/index.html",
  "for-business/index.html", "for-business/local/index.html", "for-business/local/apply/index.html", "for-business/pilot/index.html", "for-business/demo-report/index.html", "partners/index.html", "partners/apply/index.html", "partners/apply/success/index.html", "privacy/index.html", "terms/index.html", "support/index.html", "robots.txt",
  "sitemap.xml", "manifest.webmanifest", "sw.js", ".htaccess", "404.html", "data/search-index.json",
  "acquisition/index.html", "acquisition/YouNew_Acquisition_Demo_2026-08-28.mp4", "acquisition/YouNew_Acquisition_Brief_2026-08-28.pdf",
  ".well-known/apple-app-site-association",
  "data/content-provenance.json", "data/status.json", "data/site-config.json", "images/app-home-nl.webp", "images/app-amsterdam-evening-background.webp",
  "images/app-map-en.webp", "images/app-map-nl.webp", "images/og-younew.jpg",
  "icons/apple-touch-icon.png", "icons/brand-64.png", "icons/icon-192.png", "icons/icon-512.png",
  "theme-init.js", "static-shell.js"
];
for (const file of requiredFiles) await access(join(root, file));

const home = await readFile(join(root, "index.html"), "utf8");
assert.match(home, /Your guide to life in the Netherlands/);
assert.match(home, /What do you need in the Netherlands\?/);
assert.match(home, /data-private-search-form="true"/);
assert.doesNotMatch(home.match(/<input[^>]+id="home-search"[^>]*>/)?.[0] ?? "", /name=/);
assert.match(home, /Find my next step/);
for (const title of [
  "Find housing",
  "Find work",
  "Healthcare",
  "Documents",
  "Study",
  "Daily life",
  "Emergency",
  "LGBTQ+",
  "Pets",
  "Families"
]) assert.match(home, new RegExp(title));
for (const section of ["Life in the Netherlands", "Popular tasks", "Cities", "Useful services", "Trusted resources", "Why YouNew", "Published content snapshot"]) {
  assert.match(home, new RegExp(section));
}
assert.match(home, /No live public campaigns/);
assert.match(home, /never shown in emergency guidance/);
assert.match(home, /never replace responsible official sources/);
assert.match(home, /never change organic search ranking/);
assert.match(home, /support@younew\.nl/);
assert.match(home, /rel="canonical" href="https:\/\/younew\.nl\/"/);
assert.match(home, /application\/ld\+json/);
for (const path of ["/start/", "/search/", "/privacy/", "/terms/", "/support/"]) assert.match(home, new RegExp(`href="${path}"`));
assert.doesNotMatch(home, /href=(?:"|')#(?:"|')/);
assert.match(home, /href="\/app\/"/);
assert.match(home, /iOS app/);
assert.match(home, /<script[^>]+src="\/_next\/static\/chunks\//, "Private homepage handoff requires the Next client runtime");
assert.match(home, /theme-init\.js/, "Retain the layout's beforeInteractive theme bootstrap");
assert.doesNotMatch(home, /<script[^>]+src="\/static-shell/, "Do not load a second enhancement runtime beside React");
assert.match(home, /<noscript>Open the search page with this button, then enable JavaScript to search privately/);

const search = await readFile(join(root, "search/index.html"), "utf8");
assert.match(search, /Search YouNew and Dutch municipalities/);
assert.match(search, /name="robots" content="noindex, follow"/);
assert.match(search, /<script[^>]+src="\/_next\/static\/chunks\//, "Interactive routes must retain client JavaScript");

const nlHome = await readFile(join(root, "nl/index.html"), "utf8");
assert.match(nlHome, /<html lang="nl"/);
assert.match(nlHome, /Praktische informatie\. Zichtbare bronnen\. Een duidelijke volgende stap\./);
assert.match(nlHome, /hrefLang="en" href="https:\/\/younew\.nl\/"/);
assert.match(nlHome, /hrefLang="nl" href="https:\/\/younew\.nl\/nl\/"/);
assert.match(nlHome, /rel="canonical" href="https:\/\/younew\.nl\/nl\/"/);
assert.match(nlHome, /Basile Morin/);

const nlSearch = await readFile(join(root, "nl/zoeken/index.html"), "utf8");
assert.match(nlSearch, /Zoek op onderwerp, organisatie of plaats/);
assert.match(nlSearch, /<script[^>]+src="\/_next\/static\/chunks\//, "De Nederlandse zoekpagina moet interactief blijven");

const nlBusinessApply = await readFile(join(root, "nl/voor-bedrijven/aanmelden/index.html"), "utf8");
assert.match(nlBusinessApply, /name="websiteConfirmation"/);
assert.match(nlBusinessApply, /name="consentToPrivacy"/);
assert.match(nlBusinessApply, /name="confirmAccuracy"/);
assert.match(nlBusinessApply, /name="robots" content="noindex, follow"/);

const nlCityGuide = await readFile(join(root, "nl/stadsgidsen/amsterdam/index.html"), "utf8");
for (const text of ["Je eerste stappen in Amsterdam", "Open de officiële bron", "Bron gecontroleerd", "2026-10-23"]) assert.match(nlCityGuide, new RegExp(text));

const start = await readFile(join(root, "start/index.html"), "utf8");
for (const text of ["Find your next step in the Netherlands", "What do you need help with", "Next: your situation", "Complete the three steps", "No account, email or precise location"]) {
  assert.match(start, new RegExp(text, "i"));
}
assert.match(start, /<script[^>]+src="\/_next\/static\/chunks\//, "The route planner must retain client JavaScript");

const myYouNew = await readFile(join(root, "my-younew/index.html"), "utf8");
for (const text of ["Continue where you left off", "Loading local YouNew progress"]) {
  assert.match(myYouNew, new RegExp(text, "i"));
}
assert.match(myYouNew, /name="robots" content="noindex, follow"/);
assert.match(myYouNew, /<script[^>]+src="\/_next\/static\/chunks\//, "My YouNew must retain client JavaScript");

const guide = await readFile(join(root, "guides/driving-licence-amsterdam/index.html"), "utf8");
for (const text of ["Driving licence in Amsterdam", "Source checked", "Open official source", "Report outdated information", "next steps"]) assert.match(guide, new RegExp(text, "i"));
assert.match(guide, /data-guide-depth="useful-summary"/);

const journeys = await readFile(join(root, "journeys/index.html"), "utf8");
for (const text of ["New in the Netherlands", "International student", "Starting work", "Looking for housing", "Healthcare setup", "Refugee essentials", "Tourist essentials", "Starting a business", "stays only in this browser"]) assert.match(journeys, new RegExp(text, "i"));
assert.doesNotMatch(journeys, /sync(?:ed|ing)? successfully/i);

const map = await readFile(join(root, "map/index.html"), "utf8");
for (const text of ["Netherlands directory and YouNew coverage", "Directory and published content list", "no location permission", "primary accessible fallback"]) assert.match(map, new RegExp(text, "i"));
assert.doesNotMatch(map, /navigator\.geolocation|tile\.openstreetmap|mapbox/i);
assert.doesNotMatch(map, /\\?"image\\?":null/, "Map payload must omit absent optional image URLs");

const businessApply = await readFile(join(root, "business/apply/index.html"), "utf8");
for (const field of ["companyName", "contactPerson", "inquiryType", "organizationType", "kvkNumber", "targetAudience", "requestedPlacements", "consentToPrivacy", "confirmAccuracy", "websiteConfirmation"]) assert.match(businessApply, new RegExp(`name="${field}"`));
assert.match(businessApply, /saved only after server validation succeeds/i);
assert.match(businessApply, /confirmation ID appears after the database record is created/i);
assert.doesNotMatch(businessApply, /Email handoff only|does not upload or submit this form to a server/i);
assert.doesNotMatch(businessApply, /no secure upload or form backend|nothing is submitted automatically/i);

const business = await readFile(join(root, "business/index.html"), "utf8");
for (const text of [
  "Knowledge trust stays independent",
  "municipalities in the directory",
  "defined placement surfaces",
  "live public campaigns",
  "not visitors, reach, impressions or guaranteed inventory",
  "Paid placement never changes organic ranking"
]) {
  assert.match(business, new RegExp(text, "i"));
}
assert.match(business, /Technical release status:\s*(?:<!-- -->)?PARTIAL/i);

const mediaKit = await readFile(join(root, "business/media-kit/index.html"), "utf8");
for (const text of ["Request a quote", "DEMO PARTNER CARD", "DEMO REPORT", "ILLUSTRATIVE DATA", "Editorial independence", "Reasons YouNew may refuse or stop a placement"]) assert.match(mediaKit, new RegExp(text, "i"));

const businessWorkspace = await readFile(join(root, "business/workspace/index.html"), "utf8");
for (const text of ["Build your business presence with YouNew", "Local workspace preview", "0 live", "Sponsored preview", "Illustrative preview only", "Continue to secure inquiry", "Leads require a secure verified account", "Knowledge trust stays independent"]) assert.match(businessWorkspace, new RegExp(text, "i"));
assert.match(businessWorkspace, /Technical release status:\s*(?:<!-- -->)?PARTIAL/i);
assert.match(businessWorkspace, /name="robots" content="noindex, follow"/);
assert.match(businessWorkspace, /<script[^>]+src="\/_next\/static\/chunks\//, "The business workspace must retain client JavaScript");
assert.doesNotMatch(businessWorkspace, /guaranteed (?:reach|results|returns)|live public campaign/i);

const advertise = await readFile(join(root, "business/advertise/index.html"), "utf8");
for (const text of ["Where advertising can appear", "defined placement surfaces", "0", "live public campaigns", "Reserved", "Advertising is excluded from"]) assert.match(advertise, new RegExp(text, "i"));

const status = await readFile(join(root, "status/index.html"), "utf8");
assert.match(status, /Static status snapshot/);
assert.match(status, /does not (?:use|provide) live (?:uptime )?monitoring/i);
assert.match(status, /Business and feedback forms/);
assert.match(status, /Knowledge trust stays independent/i);
assert.match(status, /Technical release status:\s*(?:<!-- -->)?PARTIAL/i);

const support = await readFile(join(root, "support/index.html"), "utf8");
for (const field of ["feedbackType", "email", "message", "consentToPrivacy", "websiteConfirmation"]) {
  assert.match(support, new RegExp(`name="${field}"`));
}
assert.match(support, /confirmation ID/i);

const notFound = await readFile(join(root, "404.html"), "utf8");
assert.match(notFound, /That page isn’t here/);
assert.doesNotMatch(notFound, /rel="canonical"/, "The 404 page must not canonicalize missing URLs to the homepage");
assert.doesNotMatch(notFound, /property="og:url"/, "The 404 page must not advertise the homepage as its social URL");
assert.match(notFound, /property="og:title" content="Page not found \| YouNew"/);
assert.match(notFound, /name="twitter:card" content="summary"/);

const searchIndex = JSON.parse(await readFile(join(root, "data/search-index.json"), "utf8"));
assert.equal(searchIndex.schemaVersion, 3);
assert.ok(searchIndex.documents.some((document) => document.sourceKind === "nationalResourceGuide" && document.locationScope === "national" && document.nationalFallback === true));
const provenance = JSON.parse(await readFile(join(root, "data/content-provenance.json"), "utf8"));
const governedContent = JSON.parse(
  await readFile(new URL("../src/generated/public-content.json", import.meta.url), "utf8"),
);
const freshnessExclusions = JSON.parse(
  await readFile(new URL("../src/generated/public-freshness-exclusions.json", import.meta.url), "utf8"),
);
assert.equal(
  provenance.counts.sourceRecords,
  provenance.counts.acceptedRecords + provenance.counts.freshnessExcludedRecords,
  "Every governed source record must be either accepted or explicitly excluded by the freshness gate",
);
assert.equal(
  provenance.counts.freshnessExcludedRecords,
  freshnessExclusions.count,
  "Published provenance must use the complete fail-closed exclusion registry",
);
assert.equal(
  provenance.counts.acceptedRecords,
  governedContent.stats.entities,
  "Published provenance and the filtered public runtime must contain the same number of accepted records",
);
const publicIds = new Set(governedContent.entities.map((entity) => entity.id));
assert.ok(freshnessExclusions.records.every((record) => !publicIds.has(record.id)), "Freshness-excluded records must not appear in public content");
assert.ok(searchIndex.documents.length > provenance.counts.acceptedRecords, "Search should include derived category and useful-page destinations");
assert.ok(searchIndex.documents.every((document) => !/\b(?:draft|archived)\b/i.test(document.id)));

const manifest = JSON.parse(await readFile(join(root, "manifest.webmanifest"), "utf8"));
assert.equal(manifest.display, "standalone");
assert.deepEqual(manifest.icons.map((icon) => icon.sizes), ["192x192", "512x512"]);

const association = JSON.parse(await readFile(join(root, ".well-known/apple-app-site-association"), "utf8"));
assert.deepEqual(association.applinks.details[0].appIDs, ["9CXDJ2YMUZ.nl.younew.app"]);
assert.ok(association.applinks.details[0].components.some((component) => component["/"] === "/guides/*"));

const serviceWorker = await readFile(join(root, "sw.js"), "utf8");
assert.match(serviceWorker, /isEmergencyRequest/);
assert.match(serviceWorker, /isMutableConfiguration/);
assert.match(serviceWorker, /\.then\(\(\) => self\.skipWaiting\(\)\)/, "A new service worker must activate without waiting for every stale tab to close");
assert.match(serviceWorker, /fetch\(request, \{ cache: "no-store" \}\)/, "Navigations must bypass stale browser HTTP cache entries");
assert.match(serviceWorker, /\/static-shell\.[a-f0-9]{12}\.js/);
assert.match(serviceWorker, /\/theme-init\.js/);
assert.match(serviceWorker, /\/_next\/static\/css\//, "The install cache must include the generated stylesheet for a styled first offline launch");

const hostingerRules = await readFile(join(root, ".htaccess"), "utf8");
assert.match(hostingerRules, /FilesMatch "\\\.\(\?:html\|txt\)\$"[\s\S]*?Cache-Control "public, max-age=0, must-revalidate"/, "Hostinger must permit CDN storage while forcing exported HTML revalidation");
assert.match(hostingerRules, /AddType application\/manifest\+json \.webmanifest/, "Hostinger must serve the web manifest with its correct MIME type");
assert.match(hostingerRules, /ForceType application\/manifest\+json/, "Hostinger must override a generic MIME mapping for the web manifest");
assert.match(hostingerRules, /Files "apple-app-site-association"[\s\S]*ForceType application\/json/, "Hostinger must serve Apple's association file as JSON");
assert.match(hostingerRules, /FilesMatch "\^\(sw\\\.js\|theme-init\\\.js\|static-shell\\\.js\|manifest\\\.webmanifest/, "The unversioned homepage runtime must not remain stale between releases");
assert.match(hostingerRules, /Strict-Transport-Security "max-age=31536000"/, "HTTPS responses must advertise HSTS");

const sitemap = await readFile(join(root, "sitemap.xml"), "utf8");
for (const path of ["https://younew.nl", "/start", "/discover", "/guides/driving-licence-amsterdam", "/journeys", "/map", "/categories/housing", "/for-business", "/for-business/pilot", "/for-business/demo-report", "/partners", "/partners/apply", "/privacy", "/terms", "/support"]) assert.match(sitemap, new RegExp(path));
for (const path of ["/cities/amsterdam", "/cities/den-haag", "/cities/eindhoven", "/cities/rotterdam", "/cities/utrecht", "/places/begijnhof-amsterdam"]) {
  assert.doesNotMatch(sitemap, new RegExp(path), `${path} is a legacy noindex route and must stay out of the sitemap`);
}
const legacyAmsterdam = await readFile(join(root, "cities/amsterdam/index.html"), "utf8");
assert.match(legacyAmsterdam, /name="robots" content="noindex, follow"/, "Legacy routes remain reachable but must fail closed for indexing");
const sitemapCount = (sitemap.match(/<url>/g) ?? []).length;
assert.equal(new Set([...sitemap.matchAll(/<loc>([^<]+)<\/loc>/g)].map((match) => match[1])).size, sitemapCount, "Sitemap URLs must be unique");

console.log(`Smoke tests passed: ${sitemapCount} indexable URLs, functional planner/My YouNew/guides/journeys/map/search/business, PWA, metadata, legal pages and 404.`);
