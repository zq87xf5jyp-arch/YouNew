// Offline derivative generation from explicitly supplied, licensed source files.
// No downloads, credentials, external image service or publication.
import fs from 'node:fs/promises';
import path from 'node:path';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const sharp = require(require.resolve('sharp', { paths: [require.resolve('next')] }));
const manifestPath = process.argv[2];
if (!manifestPath) throw new Error('Pass the licensed photo-source manifest path.');
const photos = JSON.parse(await fs.readFile(manifestPath, 'utf8'));
const target = path.resolve('public/images/cities');
await fs.mkdir(target, { recursive: true });
const index = {};
for (const photo of photos) {
  const files = [];
  for (const width of [480, 800, 1200, 1920]) {
    const output = path.join(target, `${photo.slug}-${width}.webp`);
    await sharp(photo.localSource).rotate().resize({ width, withoutEnlargement:true }).webp({ quality:78 }).toFile(output);
    files.push({ width, url: `/images/cities/${photo.slug}-${width}.webp`, bytes:(await fs.stat(output)).size });
  }
  index[photo.slug] = { ...photo.original, url:files.at(-1).url, variants:files };
  console.log(photo.slug, files.map(f=>`${f.width}:${f.bytes}`).join(' '));
}
await fs.writeFile('src/content/discovery-media.json', JSON.stringify(index,null,2)+'\n');
