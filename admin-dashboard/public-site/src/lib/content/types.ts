export type ContentEntityType = "city" | "guide" | "organization" | "place";

export type PublishedStatus = "published";

export interface PublicMediaAsset {
  readonly id: string;
  readonly role: "hero" | "thumbnail" | "gallery" | "map_preview";
  readonly url: string;
  readonly alt: string;
  readonly attribution: string;
  readonly license: string;
  readonly licenseUrl: string | null;
  readonly sourcePageUrl: string | null;
  readonly retrievedAt: string | null;
}

export interface PublicSource {
  readonly title: string;
  readonly publisher: string;
  readonly url: string;
  readonly checkedAt: string;
  readonly publisherOfficial: boolean;
}

export interface ContentTrust {
  readonly sourceChecked: true;
  readonly officialSource: boolean;
}

export interface ContentSeo {
  readonly title: string;
  readonly description: string;
  readonly canonicalPath: string;
}

export type GuidePublicationStatus = "published";
export type GuideAudienceProfile = "tourist" | "student" | "expat" | "refugee" | "worker" | "resident";

export interface GuideSourcedText {
  readonly id: string;
  readonly text: string;
  readonly sourceIds: readonly string[];
}

export interface GuideOfficialSource {
  readonly id: string;
  readonly title: string;
  readonly publisher: string;
  readonly url: string;
  readonly isOfficial: true;
  readonly checkedAt: string;
  readonly status: "verified_opened";
}

export interface GuideStep {
  readonly id: string;
  readonly position: number;
  readonly title: string;
  readonly body: string;
  readonly sourceIds: readonly string[];
  readonly municipalityDependent: boolean;
}

export interface GuideSection {
  readonly id: string;
  readonly title: string;
  readonly body: string;
  readonly sourceIds: readonly string[];
}

export interface GuideFAQ {
  readonly id: string;
  readonly question: string;
  readonly answer: string;
  readonly sourceIds: readonly string[];
}

export interface GuideEstimate {
  readonly state: string;
  readonly value: string;
  readonly note: string;
  readonly currency?: string;
  readonly sourceIds: readonly string[];
}

export interface GuideContactOption {
  readonly id: string;
  readonly kind: "phone" | "email" | "url" | "in_person" | "other";
  readonly label: string;
  readonly value: string;
  readonly sourceIds: readonly string[];
}

export interface PracticalGuide {
  readonly schemaVersion: 2;
  readonly id: string;
  readonly slug: string;
  readonly locale: "en" | "nl" | "ru" | "uk" | "pl";
  readonly title: string;
  readonly shortSummary: GuideSourcedText;
  readonly audienceProfiles: readonly GuideAudienceProfile[];
  readonly whoThisIsFor: GuideSourcedText;
  readonly whenYouNeedIt: GuideSourcedText;
  readonly applicability: Readonly<{ cityIds: readonly string[]; provinceIds: readonly string[] }>;
  readonly jurisdiction: Readonly<{
    level: "national" | "provincial" | "municipal" | "mixed";
    countryCode: "NL";
    municipalityDependent: boolean;
    note: string;
    sourceIds: readonly string[];
  }>;
  readonly prerequisites: readonly GuideSourcedText[];
  readonly requiredDocuments: readonly GuideSourcedText[];
  readonly estimatedTime: GuideEstimate;
  readonly estimatedCost: GuideEstimate;
  readonly numberedSteps: readonly GuideStep[];
  readonly warnings: readonly GuideSourcedText[];
  readonly commonMistakes: readonly GuideSourcedText[];
  readonly tips: readonly GuideSourcedText[];
  readonly checklist: readonly GuideSourcedText[];
  readonly faqs: readonly GuideFAQ[];
  readonly emergencyInformation: readonly GuideSourcedText[];
  readonly sections: readonly GuideSection[];
  readonly officialSources: readonly GuideOfficialSource[];
  readonly contactOptions: readonly GuideContactOption[];
  readonly relatedGuideIds: readonly string[];
  readonly nextActions: readonly GuideSourcedText[];
  readonly verifiedAt: string;
  readonly updatedAt: string;
  readonly reviewer: Readonly<{
    id: string;
    name: string;
    role: string;
    reviewerType: "human_editor" | "subject_matter_expert" | "official_owner";
    reviewedAt: string;
  }>;
  readonly readingTimeMinutes: number;
  readonly difficulty: "basic" | "intermediate" | "advanced";
  readonly confidenceLevel: "high";
  readonly tags: readonly string[];
  readonly publicationGate: Readonly<{
    status: "passed";
    checkedAt: string;
    checks: Readonly<Record<"schema" | "factual_sources" | "links" | "language" | "media" | "duplicate_content" | "accessibility", true>>;
    notes: string;
    evidenceIds: readonly string[];
  }>;
  readonly disclaimer: string;
  readonly status: GuidePublicationStatus;
  readonly seo: ContentSeo;
  readonly synonyms: readonly string[];
  readonly commonQuestions: readonly string[];
}

export interface ContentEntity {
  readonly id: string;
  readonly slug: string;
  readonly type: ContentEntityType;
  readonly sourceKind: string;
  readonly route: string;
  readonly language: "en";
  readonly status: PublishedStatus;
  readonly title: string;
  readonly summary: string;
  readonly contentDepth: "summary" | "practical";
  readonly practicalGuide: PracticalGuide | null;
  readonly cityId: string | null;
  readonly provinceId: string | null;
  readonly categorySlugs: readonly string[];
  readonly narrowCategory: string | null;
  readonly keywords: readonly string[];
  readonly coordinate: Readonly<{ latitude: number; longitude: number }> | null;
  readonly images: readonly PublicMediaAsset[];
  readonly source: PublicSource;
  readonly trust: ContentTrust;
  readonly verifiedAt: string;
  readonly updatedAt: string;
  readonly releaseId: string;
  readonly relatedEntityIds: readonly string[];
  readonly seo: ContentSeo;
}

export interface ContentCategory {
  readonly id: string;
  readonly slug: string;
  readonly route: string;
  readonly title: string;
  readonly summary: string;
  readonly status: PublishedStatus;
  readonly language: "en";
  readonly entityCount: number;
  readonly entityIds: readonly string[];
  readonly entityTypes: readonly ContentEntityType[];
}

export interface ContentProvince {
  readonly id: string;
  readonly slug: string;
  readonly route: string;
  readonly title: string;
  readonly summary: string;
  readonly status: PublishedStatus;
  readonly language: "en";
  readonly entityCount: number;
  readonly entityIds: readonly string[];
  readonly cityIds: readonly string[];
  readonly categorySlugs: readonly string[];
}

export interface PublicContentDataset {
  readonly schemaVersion: 1;
  readonly generatedAt: string;
  readonly datasetFingerprint: string;
  readonly language: "en";
  readonly fallbackLanguage: "en";
  readonly publishedReleaseIds: readonly string[];
  readonly stats: Readonly<{
    entities: number;
    cities: number;
    guides: number;
    practicalGuides: number;
    summaryGuides: number;
    organizations: number;
    places: number;
    categories: number;
    provinces: number;
  }>;
  readonly entities: readonly ContentEntity[];
  readonly cities: readonly ContentEntity[];
  readonly guides: readonly ContentEntity[];
  readonly organizations: readonly ContentEntity[];
  readonly places: readonly ContentEntity[];
  readonly categories: readonly ContentCategory[];
  readonly provinces: readonly ContentProvince[];
}
