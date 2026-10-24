import { createSupabaseServerClient } from "../supabase/server.ts";
import { assembleOperationalTruth, unavailableOperationalTruth } from "./operational-classification.ts";
import type {
  GovernanceRisk,
  GovernanceSummary,
  OperationalTruth,
  ReviewTask
} from "./types.ts";

export async function loadOperationalTruth(offset = 0, pageSize = 50): Promise<OperationalTruth> {
  const observedAt = new Date().toISOString();
  const supabase = await createSupabaseServerClient();
  if (!supabase) {
    return unavailableOperationalTruth(observedAt);
  }

  const [summaryResult, queueResult, slaBreachResult, riskResult] = await Promise.all([
    supabase.from("content_governance_health_summary").select("*").maybeSingle(),
    supabase
      .from("admin_review_queue")
      .select("id,governance_state_id,owner_id,reason,severity,severity_rank,state,sla_due_at,resolved_at,created_at,updated_at", { count: "exact" })
      .order("severity_rank", { ascending: true })
      .order("sla_due_at", { ascending: true })
      .order("id", { ascending: true })
      .range(offset, offset + pageSize - 1),
    supabase
      .from("admin_review_queue")
      .select("id", { count: "exact", head: true })
      .lt("sla_due_at", observedAt),
    supabase.from("content_governance_top_risks").select("*").order("risk_priority", { ascending: true }).limit(25)
  ]);

  return assembleOperationalTruth(
    { data: summaryResult.data as GovernanceSummary | null, error: summaryResult.error },
    { data: (queueResult.data ?? []) as ReviewTask[], error: queueResult.error, count: queueResult.count },
    { data: (riskResult.data ?? []) as GovernanceRisk[], error: riskResult.error },
    { data: null, error: slaBreachResult.error, count: slaBreachResult.count },
    observedAt,
    offset
  );
}
