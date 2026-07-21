import { access, readdir, readFile, writeFile } from "node:fs/promises";
import { join, relative } from "node:path";

const outRoot = new URL("../out/", import.meta.url).pathname;
const serviceWorkerPath = join(outRoot, "sw.js");
const staticRoot = join(outRoot, "_next/static");

async function files(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  return (await Promise.all(entries.map((entry) => entry.isDirectory() ? files(join(directory, entry.name)) : [join(directory, entry.name)]))).flat();
}

async function existingPublicUrl(path) {
  try {
    await access(join(outRoot, path.replace(/^\//, "")));
    return path;
  } catch {
    return null;
  }
}

const authoredShell = [
  "/",
  "/offline/",
  "/guides/",
  "/journeys/",
  "/manifest.webmanifest",
  "/static-shell.js",
  "/icons/apple-touch-icon.png",
  "/icons/icon-192.png",
  "/icons/icon-512.png"
];
const generatedStyles = (await files(staticRoot))
  .filter((path) => path.endsWith(".css"))
  .map((path) => `/${relative(outRoot, path).replaceAll("\\", "/")}`)
  .sort();
const shellUrls = (await Promise.all(authoredShell.map(existingPublicUrl))).filter(Boolean).concat(generatedStyles);

const serviceWorker = await readFile(serviceWorkerPath, "utf8");
const marker = /const SHELL_URLS = \[[^\n]+\];/;
if (!marker.test(serviceWorker)) throw new Error("Service-worker shell URL marker is missing.");
await writeFile(serviceWorkerPath, serviceWorker.replace(marker, `const SHELL_URLS = ${JSON.stringify(shellUrls)};`), "utf8");
process.stdout.write(`Finalized service-worker install cache with ${shellUrls.length} shell resources.\n`);
