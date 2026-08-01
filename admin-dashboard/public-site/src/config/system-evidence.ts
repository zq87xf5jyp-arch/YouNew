export const systemEvidence = {
  asOf: "2026-08-01",
  posture: "Working ecosystem · controlled release candidate",
  metrics: {
    staticRoutes: 582,
    indexableUrls: 572,
    publishedRecords: 183,
    passingWebAdminAiTests: 129,
    freshnessPercent: 97.8
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
