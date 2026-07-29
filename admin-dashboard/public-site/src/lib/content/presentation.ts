import type { ContentEntity, ContentEntityType } from "./types";

const INTERNAL_GOVERNANCE_SUFFIX = /\s*This governed entry stores a verified city location and direct web route without copying mutable prices, ratings, reviews or opening hours\.\s*$/;

export function publicWebSummary(summary: string): string {
  return summary
    .replace(INTERNAL_GOVERNANCE_SUFFIX, "")
    .replace("The cited source specifically covers ", "The source covers ")
    .trim();
}

export function contentKindLabel(
  type: ContentEntityType | "category" | "page",
  contentDepth?: ContentEntity["contentDepth"]
): string {
  if (type === "guide") return contentDepth === "practical" ? "Step-by-step guide" : "Verified summary";
  if (type === "category") return "Category";
  if (type === "page") return "Useful page";
  return `${type[0].toUpperCase()}${type.slice(1)}`;
}
