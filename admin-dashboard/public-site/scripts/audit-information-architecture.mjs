import { readFile, readdir } from "node:fs/promises";
import { join, relative, sep } from "node:path";

const outputRoot = new URL("../out/", import.meta.url).pathname;

async function walk(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  return (await Promise.all(entries.map((entry) => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? walk(path) : [path];
  }))).flat();
}

function routeForFile(file) {
  const path = relative(outputRoot, file).split(sep).join("/");
  if (path === "index.html") return "/";
  if (path.endsWith("/index.html")) return `/${path.replace(/index\.html$/, "")}`;
  return `/${path}`;
}

function internalRoute(href, sourceRoute, routes) {
  try {
    const url = new URL(href, `https://younew.nl${sourceRoute}`);
    if (url.origin !== "https://younew.nl") return null;
    if (routes.has(url.pathname)) return url.pathname;
    const withSlash = url.pathname.endsWith("/") ? url.pathname : `${url.pathname}/`;
    return routes.has(withSlash) ? withSlash : null;
  } catch {
    return null;
  }
}

function anchorHrefs(source) {
  return [...source.matchAll(/<a\b[^>]*\bhref=(["'])(.*?)\1/gi)].map((match) => match[2]);
}

function readableText(source) {
  return source
    .replace(/<script\b[\s\S]*?<\/script>/gi, " ")
    .replace(/<style\b[\s\S]*?<\/style>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/&[a-z0-9#]+;/gi, " ")
    .replace(/\s+/g, " ")
    .trim();
}

const htmlFiles = (await walk(outputRoot)).filter((file) => file.endsWith(".html"));
const routeEntries = htmlFiles.map((file) => [routeForFile(file), file]);
const routes = new Set(routeEntries.map(([route]) => route));
const incoming = new Map([...routes].map((route) => [route, new Set()]));
const canonicalOwners = new Map();
const titleOwners = new Map();
const lowChoicePages = [];
const lowTextPages = [];

for (const [sourceRoute, file] of routeEntries) {
  const html = await readFile(file, "utf8");
  const main = html.match(/<main\b[^>]*>([\s\S]*?)<\/main>/i)?.[1] ?? "";
  const outgoing = new Set();

  for (const href of anchorHrefs(html)) {
    const target = internalRoute(href, sourceRoute, routes);
    if (!target || target === sourceRoute) continue;
    incoming.get(target)?.add(sourceRoute);
  }

  for (const href of anchorHrefs(main)) {
    const target = internalRoute(href, sourceRoute, routes);
    if (target && target !== sourceRoute) outgoing.add(target);
  }

  if (main && outgoing.size <= 1) lowChoicePages.push({ route: sourceRoute, outgoing: [...outgoing] });
  if (main && readableText(main).length < 120) lowTextPages.push({ route: sourceRoute, textLength: readableText(main).length });

  const canonical = html.match(/<link\b[^>]*\brel=["']canonical["'][^>]*\bhref=["']([^"']+)/i)?.[1]
    ?? html.match(/<link\b[^>]*\bhref=["']([^"']+)["'][^>]*\brel=["']canonical["']/i)?.[1];
  if (canonical) canonicalOwners.set(canonical, [...(canonicalOwners.get(canonical) ?? []), sourceRoute]);

  const title = html.match(/<title>(.*?)<\/title>/i)?.[1]?.trim();
  if (title) titleOwners.set(title, [...(titleOwners.get(title) ?? []), sourceRoute]);
}

const ignoredRoutes = new Set(["/404/", "/404.html", "/offline/"]);
const orphanRoutes = [...incoming]
  .filter(([route, sources]) => route !== "/" && !ignoredRoutes.has(route) && sources.size === 0)
  .map(([route]) => route)
  .sort();
const duplicateCanonicals = [...canonicalOwners]
  .filter(([, owners]) => owners.length > 1)
  .map(([canonical, owners]) => ({ canonical, owners }));
const duplicateTitles = [...titleOwners]
  .filter(([, owners]) => owners.length > 1)
  .map(([title, owners]) => ({ title, owners }));

console.log(JSON.stringify({
  generatedAt: new Date().toISOString(),
  htmlFiles: htmlFiles.length,
  routes: routes.size,
  orphanRoutes,
  duplicateCanonicals,
  duplicateTitles,
  pagesWithAtMostOneInternalMainLink: lowChoicePages,
  pagesWithLessThan120MainTextCharacters: lowTextPages
}, null, 2));
