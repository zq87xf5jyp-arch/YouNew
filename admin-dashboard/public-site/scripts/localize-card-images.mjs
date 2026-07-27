import { createHash } from "node:crypto";
import { mkdir, mkdtemp, readFile, rename, rm, writeFile } from "node:fs/promises";
import { basename, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "sharp";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const siteRoot = resolve(scriptDirectory, "..");
const imagesRoot = resolve(siteRoot, "public/images");
const finalImagesDirectory = resolve(imagesRoot, "entities");
const manifestPath = resolve(siteRoot, "public/data/card-image-manifest.json");
const nextManifestPath = resolve(siteRoot, "public/data/card-image-manifest.next.json");
const contentPath = resolve(siteRoot, "src/generated/public-content.json");

const supportedSource = /\.(?:avif|gif|jpe?g|png|webp)(?:[?#]|$)/i;
const rolePriority = Object.freeze({ thumbnail: 0, hero: 1, gallery: 2, map_preview: 3 });
const concurrency = 4;
const maximumDownloadBytes = 40 * 1024 * 1024;
const hostQueues = new Map();
const lastRequestAt = new Map();

function validateManagedPath(candidate, expectedSuffix) {
  if (!candidate.startsWith(siteRoot) || !candidate.endsWith(expectedSuffix)) {
    throw new Error(`Refusing to manage an unexpected path: ${candidate}`);
  }
}

function preferredAsset(entity) {
  return [...entity.images]
    .filter((asset) => supportedSource.test(asset.url))
    .sort((left, right) => rolePriority[left.role] - rolePriority[right.role])[0] ?? null;
}

function outputFilename(entity) {
  const filename = `${entity.type}-${entity.slug}.webp`;
  if (!/^[a-z0-9][a-z0-9-]*\.webp$/.test(filename)) {
    throw new Error(`Unsafe card image filename for ${entity.id}: ${filename}`);
  }
  return filename;
}

function resizedWikimediaUrl(sourceUrl) {
  const url = new URL(sourceUrl);
  if (url.hostname !== "upload.wikimedia.org" || url.pathname.includes("/thumb/")) return sourceUrl;

  const filename = basename(url.pathname);
  url.pathname = `${url.pathname.replace("/commons/", "/commons/thumb/")}/1280px-${filename}`;
  return url.toString();
}

async function withHostRateLimit(url, operation) {
  const hostname = new URL(url).hostname;
  const previous = hostQueues.get(hostname) ?? Promise.resolve();
  let release;
  const current = new Promise((resolveQueue) => {
    release = resolveQueue;
  });
  hostQueues.set(hostname, previous.catch(() => undefined).then(() => current));

  await previous.catch(() => undefined);
  try {
    const minimumInterval = hostname === "upload.wikimedia.org" ? 1_300 : 150;
    const waitMilliseconds = Math.max(0, (lastRequestAt.get(hostname) ?? 0) + minimumInterval - Date.now());
    if (waitMilliseconds > 0) {
      await new Promise((resolveDelay) => setTimeout(resolveDelay, waitMilliseconds));
    }
    lastRequestAt.set(hostname, Date.now());
    return await operation();
  } finally {
    release();
  }
}

async function download(url) {
  return withHostRateLimit(url, async () => {
    const response = await fetch(url, {
      headers: {
        Accept: "image/avif,image/webp,image/png,image/jpeg,image/*;q=0.8",
        "User-Agent": "YouNew card media localizer/1.0 (+https://younew.nl)"
      },
      redirect: "follow",
      signal: AbortSignal.timeout(30_000)
    });

    if (!response.ok) throw new Error(`${response.status} ${response.statusText}`);

    const declaredLength = Number(response.headers.get("content-length") ?? 0);
    if (declaredLength > maximumDownloadBytes) {
      throw new Error(`declared file size ${declaredLength} exceeds ${maximumDownloadBytes}`);
    }

    const bytes = Buffer.from(await response.arrayBuffer());
    if (bytes.length === 0 || bytes.length > maximumDownloadBytes) {
      throw new Error(`downloaded file size ${bytes.length} is invalid`);
    }
    return bytes;
  });
}

async function downloadWithFallback(sourceUrl) {
  const optimizedUrl = resizedWikimediaUrl(sourceUrl);
  const candidates = optimizedUrl === sourceUrl ? [sourceUrl] : [optimizedUrl, sourceUrl];
  let lastError;

  for (const candidate of candidates) {
    for (let attempt = 1; attempt <= 2; attempt += 1) {
      try {
        return { bytes: await download(candidate), downloadedFrom: candidate };
      } catch (error) {
        lastError = error;
        if (attempt < 2) await new Promise((resolveDelay) => setTimeout(resolveDelay, 5_000 * attempt));
      }
    }
  }

  throw lastError;
}

async function localizeEntity(entity, temporaryDirectory) {
  const asset = preferredAsset(entity);
  if (!asset) throw new Error(`No supported raster image for ${entity.id}`);

  const { bytes, downloadedFrom } = await downloadWithFallback(asset.url);
  const image = await sharp(bytes, { limitInputPixels: 100_000_000 })
    .rotate()
    .resize({
      width: 960,
      height: 600,
      fit: "cover",
      position: "attention",
      withoutEnlargement: false
    })
    .webp({ quality: 78, effort: 4, smartSubsample: true })
    .toBuffer();

  const filename = outputFilename(entity);
  await writeFile(resolve(temporaryDirectory, filename), image);

  return {
    entityId: entity.id,
    entityType: entity.type,
    route: entity.route,
    localPath: `/images/entities/${filename}`,
    sourceUrl: asset.url,
    downloadedFrom,
    sourcePageUrl: asset.sourcePageUrl,
    alt: asset.alt,
    attribution: asset.attribution,
    license: asset.license,
    licenseUrl: asset.licenseUrl,
    retrievedAt: asset.retrievedAt,
    bytes: image.length,
    sha256: createHash("sha256").update(image).digest("hex")
  };
}

async function mapWithConcurrency(items, limit, operation) {
  const results = new Array(items.length);
  let nextIndex = 0;
  let completed = 0;

  async function worker() {
    while (nextIndex < items.length) {
      const index = nextIndex;
      nextIndex += 1;
      results[index] = await operation(items[index], index);
      completed += 1;
      if (completed % 10 === 0 || completed === items.length) {
        process.stdout.write(`Localized ${completed}/${items.length} card images\n`);
      }
    }
  }

  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, () => worker()));
  return results;
}

async function main() {
  validateManagedPath(finalImagesDirectory, "/public/images/entities");
  validateManagedPath(manifestPath, "/public/data/card-image-manifest.json");
  validateManagedPath(nextManifestPath, "/public/data/card-image-manifest.next.json");

  const content = JSON.parse(await readFile(contentPath, "utf8"));
  if (!Array.isArray(content.entities) || content.entities.length === 0) {
    throw new Error("The public content dataset contains no entities");
  }

  const filenames = content.entities.map(outputFilename);
  const assets = content.entities.map(preferredAsset);
  if (new Set(filenames).size !== filenames.length) throw new Error("Card image filenames are not unique");
  if (assets.some((asset) => asset === null)) throw new Error("At least one entity has no supported card image");
  if (new Set(assets.map((asset) => asset.url)).size !== assets.length) {
    throw new Error("Card image source URLs are not unique");
  }

  await mkdir(imagesRoot, { recursive: true });
  const temporaryDirectory = await mkdtemp(resolve(imagesRoot, ".entities-"));

  try {
    const entries = await mapWithConcurrency(
      content.entities,
      concurrency,
      (entity) => localizeEntity(entity, temporaryDirectory)
    );
    const manifest = {
      schemaVersion: 1,
      generatedAt: new Date().toISOString(),
      datasetFingerprint: content.datasetFingerprint,
      imageWidth: 960,
      imageHeight: 600,
      imageFormat: "webp",
      entries: entries.sort((left, right) => left.entityId.localeCompare(right.entityId))
    };

    await writeFile(nextManifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
    await rm(finalImagesDirectory, { recursive: true, force: true });
    await rename(temporaryDirectory, finalImagesDirectory);
    await rm(manifestPath, { force: true });
    await rename(nextManifestPath, manifestPath);
  } catch (error) {
    await rm(temporaryDirectory, { recursive: true, force: true });
    await rm(nextManifestPath, { force: true });
    throw error;
  }
}

await main();
