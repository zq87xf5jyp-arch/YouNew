export const systemEvidence = {
  asOf: "2026-08-06",
  posture: "Production available · release candidate locally verified",
  metrics: {
    staticRoutes: 626,
    indexableUrls: 616,
    publishedRecords: 204,
    passingWebAdminAiTests: 148,
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
