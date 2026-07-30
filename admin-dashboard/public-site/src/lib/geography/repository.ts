import generatedGeography from "@/generated/netherlands-geography.json";
import type {
  NetherlandsGeographyDataset,
  NetherlandsMunicipality,
  NetherlandsProvince
} from "./types";

const geography = generatedGeography as unknown as NetherlandsGeographyDataset;
const municipalitiesByCode = new Map(geography.municipalities.map((municipality) => [municipality.code, municipality]));

export function getNetherlandsGeography(): NetherlandsGeographyDataset {
  return geography;
}

export function getMunicipalities(): readonly NetherlandsMunicipality[] {
  return geography.municipalities;
}

export function getMunicipality(slug: string): NetherlandsMunicipality | undefined {
  return geography.municipalities.find((municipality) => municipality.slug === slug);
}

export function getGeographyProvinces(): readonly NetherlandsProvince[] {
  return geography.provinces;
}

export function getGeographyProvince(slug: string): NetherlandsProvince | undefined {
  return geography.provinces.find((province) => province.slug === slug);
}

export function getMunicipalitiesForProvince(slug: string): readonly NetherlandsMunicipality[] {
  const province = getGeographyProvince(slug);
  if (!province) return [];
  return province.municipalityCodes
    .map((code) => municipalitiesByCode.get(code))
    .filter((municipality): municipality is NetherlandsMunicipality => Boolean(municipality));
}
