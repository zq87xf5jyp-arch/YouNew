import { Badge } from "@/components/ui/badge";

export type ReadOnlySourceState =
  | "data"
  | "empty"
  | "forbidden"
  | "unavailable"
  | "stale"
  | "demo"
  | "unknown";

export function ReadOnlySource({ state, label, detail }: { state: ReadOnlySourceState; label: string; detail: string }) {
  const variant = state === "data" || state === "empty"
    ? "success"
    : state === "forbidden" || state === "unavailable"
      ? "destructive"
      : "warning";
  const stateLabel = {
    data: "data",
    empty: "empty (measured)",
    forbidden: "forbidden",
    unavailable: "unavailable",
    stale: "stale",
    demo: "demo",
    unknown: "unknown"
  }[state];
  return (
    <div className="mb-6 flex flex-wrap items-start justify-between gap-3 rounded-lg border border-border bg-secondary/25 p-4">
      <div>
        <p className="text-sm font-semibold">Источник: {label}</p>
        <p className="mt-1 text-xs text-muted-foreground">{detail}</p>
      </div>
      <Badge variant={variant}>{stateLabel}</Badge>
    </div>
  );
}
