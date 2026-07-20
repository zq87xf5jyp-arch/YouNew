import type { MetadataRoute } from "next";

export const dynamic = "force-static";

export default function sitemap(): MetadataRoute.Sitemap {
  const updated = new Date("2026-07-14T00:00:00Z");
  return ["", "/privacy", "/terms", "/support"].map((path) => ({
    url: `https://younew.nl${path}`,
    lastModified: updated,
    changeFrequency: path === "" ? "weekly" : "monthly",
    priority: path === "" ? 1 : 0.7
  }));
}
