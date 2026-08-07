import releaseEvidence from "@/generated/release-evidence.json";

export const systemEvidence = {
  asOf: releaseEvidence.asOf,
  posture: "Production available · release candidate locally verified",
  metrics: {
    publishedRecords: releaseEvidence.metrics.publishedRecords,
    nationalGuides: releaseEvidence.metrics.nationalGuides,
    municipalityRoutes: releaseEvidence.metrics.municipalityRoutes,
    searchQualityChecks: releaseEvidence.metrics.searchQualityChecks,
    freshnessPercent: 98
  },
  surfaces: [
    {
      id: "workspace",
      title: "Workspace + CI",
      description: "Health, builds and release evidence"
    },
    {
      id: "admin",
      title: "Admin",
      description: "Content, quality and release control"
    },
    {
      id: "supabase",
      title: "Supabase",
      description: "Governed data, Edge Functions and AI context"
    },
    {
      id: "product",
      title: "Public Web + iOS",
      description: "Guides, search, maps and source verification"
    }
  ]
} as const;
