#!/usr/bin/env node
import { execFileSync } from "node:child_process";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const outputIndex = process.argv.indexOf("--output-dir");
const outputDir = resolve(outputIndex >= 0 ? process.argv[outputIndex + 1] : "release-artifacts/sbom");
const pnpm = process.env.PNPM_BIN || "pnpm";
const generatedAt = new Date().toISOString();

function purl(name, version) {
  const encodedName = name.startsWith("@") ? name.replace("/", "%2F") : name;
  return `pkg:npm/${encodedName}@${version}`;
}

function collectNpmDependencies(node, map) {
  for (const [name, dependency] of Object.entries(node?.dependencies || {})) {
    const version = dependency.version || "unknown";
    const key = `${name}@${version}`;
    if (!map.has(key)) {
      map.set(key, { type: "library", name, version, purl: purl(name, version) });
      collectNpmDependencies(dependency, map);
    }
  }
}

function npmBom(relativePath, applicationName) {
  const cwd = resolve(repositoryRoot, relativePath);
  const raw = execFileSync(pnpm, ["list", "--prod", "--json", "--depth", "Infinity"], {
    cwd,
    encoding: "utf8"
  });
  const tree = JSON.parse(raw)[0];
  const components = new Map();
  collectNpmDependencies(tree, components);
  return {
    bomFormat: "CycloneDX",
    specVersion: "1.5",
    version: 1,
    metadata: {
      timestamp: generatedAt,
      component: { type: "application", name: applicationName, version: tree.version || "0.0.0" },
      tools: [{ vendor: "YouNew", name: "scripts/generate-sbom.mjs", version: "1.0" }]
    },
    components: [...components.values()].sort((a, b) => a.name.localeCompare(b.name) || a.version.localeCompare(b.version))
  };
}

function iosMarketingVersion() {
  const projectPath = resolve(repositoryRoot, "YouNew.xcodeproj/project.pbxproj");
  const project = readFileSync(projectPath, "utf8");
  const appBuildSettings = [...project.matchAll(/buildSettings\s*=\s*\{([\s\S]*?)\n\s*\};/g)]
    .map((match) => match[1])
    .filter((settings) => /\bPRODUCT_BUNDLE_IDENTIFIER\s*=\s*nl\.younew\.app\s*;/.test(settings));
  const versions = new Set(appBuildSettings.flatMap((settings) =>
    [...settings.matchAll(/\bMARKETING_VERSION\s*=\s*([^;\s]+)\s*;/g)].map((match) => match[1])
  ));
  if (versions.size !== 1) {
    throw new Error(`Expected one iOS MARKETING_VERSION, found: ${[...versions].join(", ") || "none"}`);
  }
  return [...versions][0];
}

function swiftBom() {
  const resolvedPath = resolve(repositoryRoot, "YouNew.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved");
  const resolved = JSON.parse(readFileSync(resolvedPath, "utf8"));
  const pins = resolved.pins || resolved.object?.pins || [];
  const components = pins.map((pin) => {
    const version = pin.state?.version || pin.state?.revision || "unknown";
    const name = pin.identity || pin.package || pin.location?.split("/").pop()?.replace(/\.git$/, "") || "unknown";
    return {
      type: "library",
      name,
      version,
      purl: `pkg:swift/${name}@${version}`,
      externalReferences: pin.location ? [{ type: "vcs", url: pin.location }] : []
    };
  });
  return {
    bomFormat: "CycloneDX",
    specVersion: "1.5",
    version: 1,
    metadata: {
      timestamp: generatedAt,
      component: { type: "application", name: "YouNew iOS", version: iosMarketingVersion() },
      tools: [{ vendor: "YouNew", name: "scripts/generate-sbom.mjs", version: "1.0" }]
    },
    components
  };
}

mkdirSync(outputDir, { recursive: true });
const outputs = [
  ["admin-dashboard.cdx.json", npmBom("admin-dashboard", "YouNew Admin")],
  ["public-site.cdx.json", npmBom("admin-dashboard/public-site", "YouNew Public Site")],
  ["ios-spm.cdx.json", swiftBom()]
];
for (const [name, bom] of outputs) {
  writeFileSync(resolve(outputDir, name), `${JSON.stringify(bom, null, 2)}\n`, { mode: 0o600 });
}
console.log(outputs.map(([name]) => resolve(outputDir, name)).join("\n"));
