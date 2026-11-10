import releaseTruthJSON from "@/generated/release-truth.json";
import type { EvidenceMetric, EvidenceState, ReleaseTruthSnapshot } from "./types";

function isEvidenceState(value: unknown): value is EvidenceState {
  return ["measured", "provisional", "not_applicable", "unknown", "unavailable", "stale"].includes(String(value));
}

function assertReleaseTruth(value: unknown): asserts value is ReleaseTruthSnapshot {
  if (!value || typeof value !== "object") throw new Error("Release truth must be an object.");
  const snapshot = value as Partial<ReleaseTruthSnapshot>;
  if (snapshot.schemaVersion !== 2) throw new Error("Unsupported release-truth schema.");
  if (!snapshot.snapshotID || !/^[a-z0-9.-]+$/.test(snapshot.snapshotID)) throw new Error("Invalid release-truth snapshot ID.");
  if (!snapshot.snapshotDigest || !/^[a-f0-9]{64}$/.test(snapshot.snapshotDigest)) throw new Error("Invalid release-truth digest.");
  if (!snapshot.candidateCommit || !/^[a-f0-9]{40}$/.test(snapshot.candidateCommit)) throw new Error("Invalid release-truth candidate commit.");
  if (!snapshot.sourceTreeState || !["clean", "dirty"].includes(snapshot.sourceTreeState)) throw new Error("Invalid source-tree state.");
  if (!["GO", "PARTIAL", "NO_GO"].includes(String(snapshot.technicalVerdict))) throw new Error("Invalid technical verdict.");
  for (const source of snapshot.sources ?? []) {
    if (!isEvidenceState(source.state)) throw new Error(`Invalid evidence state for ${source.id}.`);
  }
  for (const [id, metric] of Object.entries(snapshot.metrics ?? {})) {
    if (!isEvidenceState(metric.state)) throw new Error(`Invalid metric state for ${id}.`);
    if (metric.kind === "ratio" && metric.state === "measured" && (!metric.denominator || metric.denominator <= 0)) {
      throw new Error(`Measured ratio ${id} requires a positive denominator.`);
    }
    if (metric.state !== "measured" && metric.value !== null) {
      throw new Error(`Non-measured metric ${id} must not expose a current value.`);
    }
  }
  if (snapshot.technicalVerdict === "GO" && Object.values(snapshot.gates ?? {}).some((gate) => !["pass", "not_applicable"].includes(gate.result))) {
    throw new Error("GO cannot contain failed or blocked gates.");
  }
}

assertReleaseTruth(releaseTruthJSON);

export const releaseTruth: ReleaseTruthSnapshot = releaseTruthJSON;

export function displayMetric(metric: EvidenceMetric): string {
  if (metric.state === "not_applicable") return "N/A";
  if (metric.state !== "measured") return "—";
  if (metric.unit === "percent") return `${metric.value}%`;
  return String(metric.value);
}

export function evidenceStateLabel(state: EvidenceState): string {
  return {
    measured: "измерено",
    provisional: "предварительно",
    not_applicable: "N/A",
    unknown: "неизвестно",
    unavailable: "недоступно",
    stale: "устарело"
  }[state];
}
