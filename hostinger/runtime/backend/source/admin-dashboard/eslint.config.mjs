import { createRequire } from "node:module";
import { dirname } from "node:path";
import { fileURLToPath } from "node:url";

const baseDirectory = dirname(fileURLToPath(import.meta.url));
const requireFromEslint = createRequire(createRequire(import.meta.url).resolve("eslint/package.json"));
const { FlatCompat } = requireFromEslint("@eslint/eslintrc");
const compat = new FlatCompat({ baseDirectory });

export default [
  ...compat.extends("next/core-web-vitals", "next/typescript"),
  { ignores: [".next/**", "public-site/**", "next-env.d.ts"] }
];
