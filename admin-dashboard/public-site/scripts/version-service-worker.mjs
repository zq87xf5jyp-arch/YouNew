import { createHash } from "node:crypto";
import { readdir, readFile, writeFile } from "node:fs/promises";
import { join, relative } from "node:path";

const siteRoot = new URL("../", import.meta.url).pathname;
const serviceWorkerPath = join(siteRoot, "public/sw.js");

async function files(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  return (await Promise.all(entries.map((entry) => entry.isDirectory() ? files(join(directory, entry.name)) : [join(directory, entry.name)]))).flat();
}

const serviceWorker = await readFile(serviceWorkerPath, "utf8");
const normalized = serviceWorker.replace(
  /^const CACHE_VERSION = "[^"]+";/,
  'const CACHE_VERSION = "__BUILD_VERSION__";'
);
if (!normalized.includes("__BUILD_VERSION__")) throw new Error("Service-worker cache version marker is missing.");

const fingerprintFiles = [
  ...(await files(join(siteRoot, "src"))),
  ...(await files(join(siteRoot, "public"))).filter((path) => path !== serviceWorkerPath),
  ...(await files(join(siteRoot, "scripts"))),
  ...["package.json", "pnpm-lock.yaml", "next.config.ts", "tsconfig.json"].map((path) => join(siteRoot, path))
].sort();
const digest = createHash("sha256").update(normalized);
for (const path of fingerprintFiles) {
  digest.update(relative(siteRoot, path));
  digest.update(await readFile(path));
}
const version = digest.digest("hex").slice(0, 12);
await writeFile(serviceWorkerPath, normalized.replace("__BUILD_VERSION__", `younew-web-${version}`), "utf8");
process.stdout.write(`Versioned service-worker caches with ${version} from ${fingerprintFiles.length} authored files.\n`);
