import { readFile, readdir, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const nlRoot = fileURLToPath(new URL("../out/nl/", import.meta.url));

async function htmlFiles(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  return (await Promise.all(entries.map((entry) => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? htmlFiles(path) : path.endsWith(".html") ? [path] : [];
  }))).flat();
}

const files = await htmlFiles(nlRoot);
for (const file of files) {
  const source = await readFile(file, "utf8");
  const localized = source.replace(/<html lang="en"/i, '<html lang="nl"');
  if (localized === source) throw new Error(`Expected English document language in ${file}`);
  await writeFile(file, localized);
}
console.log(`Set lang=nl on ${files.length} Dutch HTML documents.`);
