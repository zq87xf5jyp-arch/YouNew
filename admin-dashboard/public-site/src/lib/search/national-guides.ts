import data from "@/content/national-guides.json";
import type { GuideAudienceProfile } from "@/lib/content/types";

export interface NationalGuideSource {
  readonly title: string;
  readonly publisher: string;
  readonly url: string;
  readonly checkedAt: string;
}

export interface NationalGuide {
  readonly id: string;
  readonly slug: string;
  readonly title: string;
  readonly summary: string;
  readonly category: string;
  readonly subcategories: readonly string[];
  readonly intents: readonly string[];
  readonly synonyms: Readonly<Record<"en" | "nl" | "ru", readonly string[]>>;
  readonly keywords: readonly string[];
  readonly languages: readonly ("en" | "nl" | "ru")[];
  readonly applicableProfiles: readonly GuideAudienceProfile[];
  readonly scope: "national";
  readonly nationalFallback: true;
  readonly qualityScore: number;
  readonly sections: Readonly<{
    what: string;
    who: string;
    steps: readonly string[];
    documents: readonly string[];
    cost: string;
    timing: string;
    problems: readonly string[];
    mistakes: readonly string[];
    localDifferences: string;
  }>;
  readonly relatedTopics: readonly string[];
  readonly officialSources: readonly NationalGuideSource[];
}

const dataset = data as unknown as {
  readonly schemaVersion: 1;
  readonly verifiedAt: string;
  readonly guides: readonly NationalGuide[];
};

export function getNationalGuides(): readonly NationalGuide[] {
  return dataset.guides;
}

export function getNationalGuide(slug: string): NationalGuide | undefined {
  return dataset.guides.find((guide) => guide.slug === slug);
}

export function nationalGuidesVerifiedAt(): string {
  return dataset.verifiedAt;
}
