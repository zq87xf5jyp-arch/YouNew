import { createHash } from "node:crypto";
import { readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const adminRoot = resolve(scriptDirectory, "..");
const repositoryRoot = resolve(adminRoot, "..");

const paths = {
  content: resolve(repositoryRoot, "admin-dashboard/public-site/src/generated/public-content.json"),
  geography: resolve(repositoryRoot, "admin-dashboard/public-site/src/generated/netherlands-geography.json"),
  sourceRegistry: resolve(repositoryRoot, "source_registry.json"),
  mapOutput: resolve(adminRoot, "src/generated/canonical-map-points.json"),
  linksOutput: resolve(adminRoot, "src/generated/canonical-official-links.json")
};

const sha256 = (value) => createHash("sha256").update(value).digest("hex");
const stableJSONString = (value) => `${JSON.stringify(value, null, 2)}\n`;

function deterministicUUID(key) {
  const bytes = Buffer.from(sha256(key).slice(0, 32), "hex");
  bytes[6] = (bytes[6] & 0x0f) | 0x50;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  const hex = bytes.toString("hex");
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`;
}

function latestTimestamp(values) {
  const timestamps = values
    .filter((value) => typeof value === "string" && !Number.isNaN(Date.parse(value)))
    .map((value) => new Date(value).toISOString())
    .sort();
  return timestamps.at(-1) ?? null;
}

function textValue(value) {
  if (typeof value === "string") return value;
  if (!value || typeof value !== "object" || Array.isArray(value)) return "";
  for (const key of ["en", "nl", "ru"]) {
    if (typeof value[key] === "string") return value[key];
  }
  return Object.values(value).find((item) => typeof item === "string") ?? "";
}

function canonicalURL(value) {
  if (typeof value !== "string" || value.trim() === "") return null;
  const raw = value.trim();
  if (/[^\x21-\x7e]/u.test(raw)) return null;
  const rawPath = raw.replace(/^[a-z][a-z0-9+.-]*:\/\/[^/?#]+/iu, "").split(/[?#]/u, 1)[0];
  if (/(?:^|\/)(?:\.|%2e|\.%2e|%2e\.|%2e%2e)(?:\/|$)/iu.test(rawPath)) return null;
  let parsed;
  try {
    parsed = new URL(raw);
  } catch {
    return null;
  }
  if (!new Set(["http:", "https:"]).has(parsed.protocol)) return null;
  if (parsed.username || parsed.password) return null;
  parsed.protocol = parsed.protocol.toLowerCase();
  parsed.hostname = parsed.hostname.toLowerCase();
  parsed.hash = "";
  if ((parsed.protocol === "https:" && parsed.port === "443") || (parsed.protocol === "http:" && parsed.port === "80")) {
    parsed.port = "";
  }
  if (parsed.pathname === "/") parsed.pathname = "";
  return parsed.toString();
}

function sourceTypeForEntity(entity) {
  const prefix = String(entity.id ?? "").split(".")[0];
  if (prefix === "healthcare") return "healthcare";
  if (prefix === "education") return "education";
  if (prefix === "transport") return "transport";
  if (prefix === "government") return "government";
  if (entity.type === "city") return "municipality";
  return "other";
}

function mapTypeForEntity(entity) {
  if (entity.type === "city") return "city";
  const sourceType = sourceTypeForEntity(entity);
  if (sourceType === "healthcare") return "hospital";
  if (["education", "transport", "government"].includes(sourceType)) return sourceType;
  return "custom";
}

function mapColor(type) {
  return {
    city: "#38bdf8",
    municipality: "#22c55e",
    hospital: "#ef4444",
    transport: "#14b8a6",
    government: "#8b5cf6",
    education: "#eab308",
    custom: "#f97316"
  }[type] ?? "#f97316";
}

function buildMapArtifact(content, geography, inputHashes) {
  const publishedEntities = content.entities
    .filter((entity) => entity.status === "published" && ["city", "organization", "place"].includes(entity.type) && entity.coordinate)
    .map((entity) => {
      const type = mapTypeForEntity(entity);
      return {
        id: deterministicUUID(`content_entity:${entity.id}`),
        title: entity.title,
        type,
        latitude: entity.coordinate.latitude,
        longitude: entity.coordinate.longitude,
        city: entity.cityId ?? null,
        province: entity.provinceId ?? null,
        description: textValue(entity.summary) || null,
        source_url: entity.source?.url ?? null,
        status: "published",
        icon: "MapPin",
        color: mapColor(type),
        created_at: null,
        updated_at: entity.source?.checkedAt ? `${entity.source.checkedAt}T00:00:00Z` : null,
        source_kind: "content_entity",
        source_id: entity.id,
        route: entity.route
      };
    });

  const municipalities = geography.municipalities
    .filter((municipality) => municipality.coordinate)
    .map((municipality) => ({
      id: deterministicUUID(`municipality:${municipality.code}`),
      title: municipality.name,
      type: "municipality",
      latitude: municipality.coordinate.latitude,
      longitude: municipality.coordinate.longitude,
      city: municipality.slug,
      province: municipality.provinceSlug,
      description: `Official municipality registry entry in ${municipality.provinceName}.`,
      source_url: municipality.officialWebsite ?? null,
      status: "published",
      icon: "MapPin",
      color: mapColor("municipality"),
      created_at: null,
      updated_at: municipality.sourceCheckedAt ? `${municipality.sourceCheckedAt}T00:00:00Z` : null,
      source_kind: "municipality",
      source_id: municipality.code,
      route: `/municipalities/${municipality.slug}`
    }));

  const points = [...publishedEntities, ...municipalities]
    .sort((left, right) => left.title.localeCompare(right.title) || left.source_id.localeCompare(right.source_id));
  const identities = new Set(points.map((point) => `${point.source_kind}:${point.source_id}`));
  if (identities.size !== points.length) throw new Error("Canonical map source identities are not unique.");

  const datasetFingerprint = sha256([
    content.datasetFingerprint,
    geography.effectiveDate,
    inputHashes.content,
    inputHashes.geography
  ].join("\n"));

  const categories = content.categories
    .filter((category) => category.status === "published")
    .map((category, index) => ({
      priority: index + 1,
      title: category.title,
      slug: category.slug,
      status: category.status,
      entity_count: category.entityCount,
      source_id: category.id
    }))
    .sort((left, right) => left.title.localeCompare(right.title));
  const cities = content.cities
    .filter((city) => city.status === "published" && city.coordinate)
    .map((city) => ({
      name: city.title,
      slug: city.slug,
      province: city.provinceId,
      lat: city.coordinate.latitude,
      lng: city.coordinate.longitude,
      status: city.status,
      source_id: city.id
    }))
    .sort((left, right) => left.name.localeCompare(right.name));

  return {
    schemaVersion: 1,
    generatedAt: latestTimestamp([content.generatedAt, geography.generatedAt]),
    datasetFingerprint,
    source: {
      contentDatasetFingerprint: content.datasetFingerprint,
      geographyEffectiveDate: geography.effectiveDate,
      contentSha256: inputHashes.content,
      geographySha256: inputHashes.geography
    },
    counts: {
      contentEntities: publishedEntities.length,
      municipalities: municipalities.length,
      total: points.length,
      categories: categories.length,
      cities: cities.length
    },
    categories,
    cities,
    points
  };
}

function addSourceReference(references, candidate) {
  const normalized = canonicalURL(candidate.url);
  if (!normalized) return;
  references.push({
    normalized,
    title: candidate.title,
    publisher: candidate.publisher,
    url: candidate.url,
    sourceType: candidate.sourceType,
    checkedAt: candidate.checkedAt ?? null,
    referenceKind: candidate.referenceKind,
    referenceID: candidate.referenceID
  });
}

function buildLinksArtifact(content, geography, sourceRegistry, inputHashes) {
  const references = [];
  for (const entity of content.entities.filter((item) => item.status === "published")) {
    addSourceReference(references, {
      title: entity.source?.title ?? entity.title,
      publisher: entity.source?.publisher ?? entity.title,
      url: entity.source?.url,
      sourceType: sourceTypeForEntity(entity),
      checkedAt: entity.source?.checkedAt,
      referenceKind: "content_entity",
      referenceID: entity.id
    });
  }
  for (const municipality of geography.municipalities) {
    addSourceReference(references, {
      title: `${municipality.name} official website`,
      publisher: municipality.name,
      url: municipality.officialWebsite,
      sourceType: "municipality",
      checkedAt: municipality.sourceCheckedAt,
      referenceKind: "municipality",
      referenceID: municipality.code
    });
    addSourceReference(references, {
      title: `${municipality.name} appointment page`,
      publisher: municipality.name,
      url: municipality.appointmentUrl,
      sourceType: "municipality",
      checkedAt: municipality.sourceCheckedAt,
      referenceKind: "municipality_appointment",
      referenceID: municipality.code
    });
  }
  for (const province of geography.provinces) {
    addSourceReference(references, {
      title: `${province.name} official website`,
      publisher: province.name,
      url: province.officialWebsite,
      sourceType: "government",
      checkedAt: province.sourceCheckedAt,
      referenceKind: "province",
      referenceID: province.code
    });
  }
  for (const source of sourceRegistry.sources ?? []) {
    addSourceReference(references, {
      title: source.authority,
      publisher: source.authority,
      url: source.url,
      sourceType: "government",
      checkedAt: source.last_verified_at,
      referenceKind: "tracked_registry",
      referenceID: source.id
    });
  }

  const grouped = new Map();
  for (const reference of references) {
    const group = grouped.get(reference.normalized) ?? [];
    group.push(reference);
    grouped.set(reference.normalized, group);
  }
  const links = [...grouped.entries()].map(([normalized, group]) => {
    group.sort((left, right) => String(right.checkedAt ?? "").localeCompare(String(left.checkedAt ?? "")));
    const representative = group[0];
    const checkedAt = group.map((item) => item.checkedAt).filter(Boolean).sort().at(-1) ?? null;
    return {
      source_key: `source.${sha256(normalized).slice(0, 24)}`,
      title: representative.title,
      publisher: representative.publisher,
      url: representative.url,
      canonical_url: normalized,
      source_type: representative.sourceType,
      evidence_state: normalized.startsWith("https://") && checkedAt ? "measured" : "provisional",
      link_health_state: "unknown",
      last_checked_date: checkedAt,
      reference_count: group.length,
      reference_kinds: [...new Set(group.map((item) => item.referenceKind))].sort(),
      reference_ids: [...new Set(group.map((item) => item.referenceID))].sort()
    };
  }).sort((left, right) => left.publisher.localeCompare(right.publisher) || left.canonical_url.localeCompare(right.canonical_url));

  return {
    schemaVersion: 1,
    generatedAt: latestTimestamp([content.generatedAt, geography.generatedAt, sourceRegistry.generated_at]),
    registryFingerprint: sha256(links.map((link) => `${link.source_key}\0${link.canonical_url}`).join("\n")),
    source: {
      contentSha256: inputHashes.content,
      geographySha256: inputHashes.geography,
      trackedRegistrySha256: inputHashes.sourceRegistry
    },
    linkHealth: {
      state: "unknown",
      reasonCode: "network_check_not_part_of_deterministic_build",
      observedAt: null,
      validThrough: null,
      total: null,
      reachable: null,
      confirmedBroken: null
    },
    counts: {
      references: references.length,
      canonicalLinks: links.length,
      duplicatesCollapsed: references.length - links.length
    },
    links
  };
}

async function readJSON(path) {
  const bytes = await readFile(path);
  return { bytes, value: JSON.parse(bytes.toString("utf8")) };
}

async function main() {
  const checkOnly = process.argv.includes("--check");
  const [contentInput, geographyInput, sourceRegistryInput] = await Promise.all([
    readJSON(paths.content),
    readJSON(paths.geography),
    readJSON(paths.sourceRegistry)
  ]);
  const inputHashes = {
    content: sha256(contentInput.bytes),
    geography: sha256(geographyInput.bytes),
    sourceRegistry: sha256(sourceRegistryInput.bytes)
  };
  const outputs = new Map([
    [paths.mapOutput, stableJSONString(buildMapArtifact(contentInput.value, geographyInput.value, inputHashes))],
    [paths.linksOutput, stableJSONString(buildLinksArtifact(contentInput.value, geographyInput.value, sourceRegistryInput.value, inputHashes))]
  ]);

  for (const [path, expected] of outputs) {
    if (checkOnly) {
      const actual = await readFile(path, "utf8");
      if (actual !== expected) throw new Error(`${path} is stale; run generate-canonical-admin-data.mjs.`);
    } else {
      await writeFile(path, expected, "utf8");
    }
  }
  process.stdout.write(`${checkOnly ? "Verified" : "Generated"} ${outputs.size} canonical admin artifacts.\n`);
}

main().catch((error) => {
  process.stderr.write(`${error.stack ?? error.message}\n`);
  process.exitCode = 1;
});
