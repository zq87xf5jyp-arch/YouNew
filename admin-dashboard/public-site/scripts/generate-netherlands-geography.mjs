import { mkdir, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const outputPath = resolve(projectRoot, "src/generated/netherlands-geography.json");
const pdokBase = "https://api.pdok.nl/kadaster/brk-bestuurlijke-gebieden/ogc/v1";
const municipalityCsvUrl = "https://organisaties.overheid.nl/export/Gemeenten.csv";
const provinceCsvUrl = "https://organisaties.overheid.nl/export/Provincies.csv";
const settlementsUrl = "https://opendata.cbs.nl/ODataApi/OData/86312NED/TypedDataSet?$top=3000";
const settlementNamesUrl = "https://opendata.cbs.nl/ODataApi/OData/86312NED/Woonplaatsen?$top=3000";

function slugify(value) {
  return String(value ?? "")
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLocaleLowerCase("en")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

async function fetchText(url) {
  const response = await fetch(url, {
    headers: {
      Accept: "text/csv, application/json;q=0.9, */*;q=0.5",
      "User-Agent": "YouNew geography generator/1.0 (support@younew.nl)"
    }
  });
  if (!response.ok) throw new Error(`Unable to fetch ${url}: ${response.status}`);
  return response.text();
}

async function fetchJson(url) {
  return JSON.parse(await fetchText(url));
}

function parseDelimited(input, delimiter = ";") {
  const rows = [];
  let row = [];
  let field = "";
  let quoted = false;

  for (let index = 0; index < input.length; index += 1) {
    const character = input[index];
    if (quoted) {
      if (character === "\"" && input[index + 1] === "\"") {
        field += "\"";
        index += 1;
      } else if (character === "\"") {
        quoted = false;
      } else {
        field += character;
      }
      continue;
    }
    if (character === "\"") {
      quoted = true;
    } else if (character === delimiter) {
      row.push(field);
      field = "";
    } else if (character === "\n") {
      row.push(field.replace(/\r$/, ""));
      rows.push(row);
      row = [];
      field = "";
    } else {
      field += character;
    }
  }
  if (field || row.length) {
    row.push(field.replace(/\r$/, ""));
    rows.push(row);
  }
  const [headers = [], ...records] = rows;
  return records
    .filter((record) => record.some((value) => value.trim()))
    .map((record) => Object.fromEntries(headers.map((header, index) => [header, record[index] ?? ""])));
}

function firstUrl(value) {
  return String(value ?? "").match(/https?:\/\/[^,;\s]+/i)?.[0] ?? null;
}

function firstContactValue(value) {
  const contact = String(value ?? "").split(/[;,]/, 1)[0]?.trim() ?? "";
  return contact || null;
}

function addressCoordinate(value) {
  const latitude = Number(String(value ?? "").match(/centroideLatitude:\s*([0-9.]+)/i)?.[1]);
  const longitude = Number(String(value ?? "").match(/centroideLongitude:\s*([0-9.]+)/i)?.[1]);
  return Number.isFinite(latitude) && Number.isFinite(longitude) ? { latitude, longitude } : null;
}

function addressLocality(value) {
  return String(value ?? "").match(/woonplaats:\s*([^,;]+)/i)?.[1]?.trim() ?? null;
}

function polygonCoordinate(feature) {
  const coordinates = feature?.geometry?.coordinates ?? [];
  const points = [];
  const visit = (value) => {
    if (Array.isArray(value) && value.length >= 2 && value.every((part) => typeof part === "number")) {
      points.push(value);
      return;
    }
    if (Array.isArray(value)) value.forEach(visit);
  };
  visit(coordinates);
  if (!points.length) return null;
  const longitude = points.reduce((sum, point) => sum + point[0], 0) / points.length;
  const latitude = points.reduce((sum, point) => sum + point[1], 0) / points.length;
  return { latitude, longitude };
}

function codeDigits(value) {
  return String(value ?? "").trim().match(/(\d{4})$/)?.[1] ?? null;
}

function provinceCode(value) {
  const digits = String(value ?? "").trim().match(/(\d{2})$/)?.[1];
  return digits ? `PV${digits}` : null;
}

function isoDate(value) {
  const match = String(value ?? "").match(/^(\d{2})-(\d{2})-(\d{4})$/);
  return match ? `${match[3]}-${match[2]}-${match[1]}` : null;
}

function wholeNumber(value) {
  const normalized = String(value ?? "").replace(/[.\s]/g, "").replace(",", ".");
  const number = Number(normalized);
  return Number.isFinite(number) ? Math.round(number) : null;
}

const [
  municipalityCollection,
  provinceCollection,
  municipalityCsv,
  provinceCsv,
  settlementDataset,
  settlementNames
] = await Promise.all([
  fetchJson(`${pdokBase}/collections/gemeentegebied/items?f=json&limit=1000`),
  fetchJson(`${pdokBase}/collections/provinciegebied/items?f=json&limit=20`),
  fetchText(municipalityCsvUrl),
  fetchText(provinceCsvUrl),
  fetchJson(settlementsUrl),
  fetchJson(settlementNamesUrl)
]);

const municipalityContacts = parseDelimited(municipalityCsv)
  .filter((record) => record.Type === "Gemeente")
  .map((record) => [codeDigits(record.Organisatiecode || record["TOOi URI"]), record])
  .filter(([code]) => code)
  .reduce((map, [code, record]) => map.set(code, record), new Map());

const provinceContacts = parseDelimited(provinceCsv)
  .filter((record) => record.Type === "Provincie")
  .reduce((map, record) => map.set(slugify(record["Officiële naam"].replace(/^Provincie\s+/i, "")), record), new Map());

const settlementNameByCode = new Map(
  (settlementNames.value ?? []).map((record) => [String(record.Key ?? "").trim(), String(record.Title ?? "").trim()])
);

const settlementsByMunicipality = new Map();
for (const record of settlementDataset.value ?? []) {
  const municipalityCode = codeDigits(record.Code_3);
  const code = String(record.Woonplaatsen ?? record.Woonplaatscode_1 ?? "").trim();
  const name = settlementNameByCode.get(code) ?? "";
  if (!municipalityCode || !name || !code) continue;
  const existing = settlementsByMunicipality.get(municipalityCode) ?? [];
  existing.push({ code, name });
  settlementsByMunicipality.set(municipalityCode, existing);
}

const municipalityFeatures = municipalityCollection.features ?? [];
const municipalities = municipalityFeatures.map((feature) => {
  const properties = feature.properties ?? {};
  const code = codeDigits(properties.code ?? properties.identificatie);
  if (!code) throw new Error(`Municipality without a supported code: ${JSON.stringify(properties)}`);
  const contact = municipalityContacts.get(code);
  if (!contact) throw new Error(`ROO contact record missing for municipality GM${code} ${properties.naam}`);
  const provinceName = String(properties.ligt_in_provincie_naam ?? "").trim();
  const province = provinceCode(properties.ligt_in_provincie_code);
  if (!provinceName || !province) throw new Error(`Province relationship missing for municipality GM${code}`);
  const settlements = [...(settlementsByMunicipality.get(code) ?? [])]
    .sort((left, right) => left.name.localeCompare(right.name, "nl"));
  const contactAddress = contact["Adressen (type, toelichting, straat, huisnummer, toevoeging, postbus, postcode, plaats, regio, provincieAfkorting, land, centroideLatitude, centroideLongitude, centroideRdx, centroideRdy)"];
  return {
    code: `GM${code}`,
    slug: slugify(properties.naam),
    name: String(properties.naam).trim(),
    provinceCode: province,
    provinceSlug: slugify(provinceName),
    provinceName,
    coordinate: addressCoordinate(contactAddress) ?? polygonCoordinate(feature),
    administrativeSeat: addressLocality(contactAddress),
    officialWebsite: firstUrl(contact["Internetpagina's"]) ?? firstUrl(contact["Link naar uitgebreidere organisatiebeschrijving"]),
    appointmentUrl: firstUrl(contact["Online afspraak url"]),
    phone: firstContactValue(contact["Telefoonnummers "]),
    email: firstContactValue(contact["E-mail adressen"]),
    population: wholeNumber(contact["Aantal inwoners"]),
    settlements,
    sourceCheckedAt: isoDate(contact["Datum ter verificatie"]) ?? isoDate(contact["Laatste mutatie"])
  };
}).sort((left, right) => left.name.localeCompare(right.name, "nl"));

const municipalitySlugs = new Set(municipalities.map((municipality) => municipality.slug));
if (municipalitySlugs.size !== municipalities.length) throw new Error("Municipality slugs are not unique.");

const provinces = (provinceCollection.features ?? []).map((feature) => {
  const properties = feature.properties ?? {};
  const name = String(properties.naam ?? "").trim();
  const slug = slugify(name);
  const code = provinceCode(properties.code ?? properties.identificatie);
  if (!name || !code) throw new Error(`Province without a supported identity: ${JSON.stringify(properties)}`);
  const contact = provinceContacts.get(slug);
  if (!contact) throw new Error(`ROO contact record missing for province ${name}`);
  const provinceMunicipalities = municipalities.filter((municipality) => municipality.provinceCode === code);
  return {
    code,
    slug,
    name,
    route: `/provinces/${slug}`,
    coordinate: polygonCoordinate(feature),
    officialWebsite: firstUrl(contact["Internetpagina's"]),
    phone: firstContactValue(contact["Telefoonnummers "]),
    email: firstContactValue(contact["E-mail adressen"]),
    administrativeSeat: addressLocality(contact["Adressen (type, toelichting, straat, huisnummer, toevoeging, postbus, postcode, plaats, regio, provincieAfkorting, land, centroideLatitude, centroideLongitude, centroideRdx, centroideRdy)"]),
    municipalityCodes: provinceMunicipalities.map((municipality) => municipality.code),
    municipalityCount: provinceMunicipalities.length,
    settlementCount: provinceMunicipalities.reduce((sum, municipality) => sum + municipality.settlements.length, 0),
    sourceCheckedAt: isoDate(contact["Datum ter verificatie"]) ?? isoDate(contact["Laatste mutatie"])
  };
}).sort((left, right) => left.name.localeCompare(right.name, "nl"));

const generatedAt = new Date().toISOString();
const geography = {
  schemaVersion: 1,
  effectiveDate: "2026-01-01",
  generatedAt,
  country: "Netherlands",
  language: "en",
  sources: [
    {
      id: "cbs-municipalities-2026",
      title: "Municipal division on 1 January 2026",
      publisher: "Statistics Netherlands (CBS)",
      url: "https://www.cbs.nl/nl-nl/onze-diensten/methoden/classificaties/overig/gemeentelijke-indelingen-per-jaar/indeling-per-jaar/gemeentelijke-indeling-op-1-januari-2026",
      checkedAt: generatedAt.slice(0, 10)
    },
    {
      id: "cbs-settlements-2026",
      title: "Settlements in the Netherlands 2026",
      publisher: "Statistics Netherlands (CBS)",
      url: "https://www.cbs.nl/nl-nl/cijfers/detail/86312NED",
      checkedAt: generatedAt.slice(0, 10)
    },
    {
      id: "pdok-boundaries-2026",
      title: "Bestuurlijke Gebieden",
      publisher: "Kadaster / PDOK",
      url: "https://www.pdok.nl/introductie/-/article/bestuurlijke-gebieden",
      checkedAt: generatedAt.slice(0, 10),
      license: "CC BY 4.0"
    },
    {
      id: "roo-government-organizations",
      title: "Register of Government Organisations",
      publisher: "KOOP / Ministry of the Interior and Kingdom Relations",
      url: "https://organisaties.overheid.nl/",
      checkedAt: generatedAt.slice(0, 10)
    }
  ],
  stats: {
    provinces: provinces.length,
    municipalities: municipalities.length,
    settlements: municipalities.reduce((sum, municipality) => sum + municipality.settlements.length, 0)
  },
  provinces,
  municipalities
};

if (geography.stats.provinces !== 12) throw new Error(`Expected 12 provinces, received ${geography.stats.provinces}.`);
if (geography.stats.municipalities !== 342) throw new Error(`Expected 342 municipalities, received ${geography.stats.municipalities}.`);
if (geography.stats.settlements !== 2502) throw new Error(`Expected 2502 settlements, received ${geography.stats.settlements}.`);

await mkdir(dirname(outputPath), { recursive: true });
await writeFile(outputPath, `${JSON.stringify(geography, null, 2)}\n`, "utf8");
console.log(`Generated ${geography.stats.provinces} provinces, ${geography.stats.municipalities} municipalities and ${geography.stats.settlements} settlements.`);
