export interface NetherlandsSettlement {
  readonly code: string;
  readonly name: string;
}

export interface NetherlandsMunicipality {
  readonly code: string;
  readonly slug: string;
  readonly name: string;
  readonly provinceCode: string;
  readonly provinceSlug: string;
  readonly provinceName: string;
  readonly coordinate: Readonly<{ latitude: number; longitude: number }> | null;
  readonly administrativeSeat: string | null;
  readonly officialWebsite: string | null;
  readonly appointmentUrl: string | null;
  readonly phone: string | null;
  readonly email: string | null;
  readonly population: number | null;
  readonly settlements: readonly NetherlandsSettlement[];
  readonly sourceCheckedAt: string | null;
}

export interface NetherlandsProvince {
  readonly code: string;
  readonly slug: string;
  readonly name: string;
  readonly route: string;
  readonly coordinate: Readonly<{ latitude: number; longitude: number }> | null;
  readonly officialWebsite: string | null;
  readonly phone: string | null;
  readonly email: string | null;
  readonly administrativeSeat: string | null;
  readonly municipalityCodes: readonly string[];
  readonly municipalityCount: number;
  readonly settlementCount: number;
  readonly sourceCheckedAt: string | null;
}

export interface GeographySource {
  readonly id: string;
  readonly title: string;
  readonly publisher: string;
  readonly url: string;
  readonly checkedAt: string;
  readonly license?: string;
}

export interface NetherlandsGeographyDataset {
  readonly schemaVersion: 1;
  readonly effectiveDate: string;
  readonly generatedAt: string;
  readonly country: "Netherlands";
  readonly language: "en";
  readonly sources: readonly GeographySource[];
  readonly stats: Readonly<{
    provinces: 12;
    municipalities: 342;
    settlements: 2502;
  }>;
  readonly provinces: readonly NetherlandsProvince[];
  readonly municipalities: readonly NetherlandsMunicipality[];
}
