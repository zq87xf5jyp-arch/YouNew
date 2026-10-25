import { Link2, Network } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { LinksManager } from "@/components/admin/links-manager";
import { requireAdmin } from "@/lib/auth";
import { canCheckOfficialLink, canReadOfficialLinks, type OfficialLinkRow } from "@/lib/official-link-workflow";
import { CrudTable } from "@/components/admin/crud-table";
import { ReadOnlySource } from "@/components/admin/read-only-source";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { canonicalOfficialLinks } from "@/lib/canonical-admin-data";
import { fetchRowsResult } from "@/lib/data";
import {
  classifyOfficialLinkObservation,
  OFFICIAL_LINK_HEALTH_FRESHNESS_WINDOW_HOURS
} from "@/lib/official-link-health";

type OperationalLinkRow = {
  source_key: string;
  link_health_state: "reachable" | "redirected" | "broken" | "unknown" | null;
  http_status: number | null;
  checked_at: string | null;
  alias_urls: string[] | null;
  admin_notes: string | null;
  check_notes: string | null;
  updated_at: string;
};

export default async function LinksPage() {
  const admin = await requireAdmin();
  if (!canReadOfficialLinks(admin.role)) return <PageHeader title="Официальные ссылки" description="Недостаточно прав для просмотра каталога." />;
  const legacy = await fetchRowsResult<OfficialLinkRow>("official_links", [], 100);
  const operational = await fetchRowsResult<OperationalLinkRow>(
    "official_link_operational_latest",
    [],
    1000,
    "updated_at"
  );
  const operationsBySource = new Map(operational.rows.map((row) => [row.source_key, row]));
  const classifiedRows = canonicalOfficialLinks.links.map((link) => {
    const operation = operationsBySource.get(link.source_key);
    const lastObservedHealth = operation?.link_health_state ?? "unknown";
    const observation = classifyOfficialLinkObservation(operation, operational.observedAt);
    return {
      row: {
        ...link,
        link_health_state: observation.countsTowardCoverage ? lastObservedHealth : "unknown",
        last_observed_health: observation.observedHealth,
        health_freshness: observation.freshness === "unmeasured" ? "Не измерено" : observation.freshness,
        http_status: operation?.http_status ?? null,
        checked_at: observation.checkedAt,
        valid_through: observation.validThrough,
        alias_count: operation?.alias_urls?.length ?? 0,
        admin_notes: operation?.admin_notes ?? null,
        check_notes: operation?.check_notes ?? null
      },
      observation
    };
  });
  const visibleRows = classifiedRows.slice(0, 100).map((entry) => entry.row);
  const freshRows = classifiedRows.filter((row) => row.observation.countsTowardCoverage);
  const staleRows = classifiedRows.filter((row) => row.observation.freshness === "stale");
  const unmeasuredRows = classifiedRows.filter((row) => row.observation.freshness === "unmeasured");
  const brokenRows = freshRows.filter((row) => row.observation.observedHealth === "broken");
  const completeFreshCoverage = canonicalOfficialLinks.counts.canonicalLinks > 0
    && freshRows.length === canonicalOfficialLinks.counts.canonicalLinks;
  const operationalSourceState = operational.state === "data"
    ? freshRows.length > 0
      ? "data"
      : staleRows.length > 0
        ? "stale"
        : "unknown"
    : operational.state === "empty"
      ? "unknown"
      : operational.state;
  const operationalDetail = operational.state === "data"
    ? freshRows.length > 0
      ? `${freshRows.length} fresh canonical checks; ${staleRows.length} stale; ${unmeasuredRows.length} не измерено. Freshness window: ${OFFICIAL_LINK_HEALTH_FRESHNESS_WINDOW_HOURS} hours.`
      : staleRows.length > 0
        ? `No fresh canonical checks. ${staleRows.length} retained observations are stale; ${unmeasuredRows.length} не измерено.`
        : "Не измерено: imported rows have no valid timestamp paired with a measured health result."
    : operational.state === "empty"
      ? "Не измерено: the operational registry query returned no rows."
      : operational.state === "forbidden"
        ? "The authenticated identity is not permitted to read operational link evidence."
        : operational.state === "demo"
          ? "No production check result is inferred from local demo mode."
          : "Operational link checks are unavailable; packaged source evidence remains visible separately.";
  return (
    <>
      <PageHeader
        title="Канонический реестр официальных ссылок"
        description="Канонический реестр — только просмотр. URL собраны из packaged content, муниципалитетов, провинций и tracked registry; варианты нормализованы без объединения по одному названию."
      />
      <ReadOnlySource
        state={canonicalOfficialLinks.links.length ? "data" : "empty"}
        label="deterministic canonical official-link registry"
        detail={`${canonicalOfficialLinks.counts.canonicalLinks} canonical URLs · registry ${canonicalOfficialLinks.registryFingerprint}`}
      />
      <ReadOnlySource
        state={operationalSourceState}
        label="Supabase official_link_operational_latest"
        detail={operationalDetail}
      />
      <div className="mb-6 grid gap-4 md:grid-cols-3">
        <Card><CardHeader className="pb-2"><CardTitle className="flex items-center gap-2 text-base"><Link2 className="size-4" />References</CardTitle></CardHeader><CardContent><p className="text-3xl font-bold">{canonicalOfficialLinks.counts.references}</p></CardContent></Card>
        <Card><CardHeader className="pb-2"><CardTitle className="text-base">Canonical URLs</CardTitle></CardHeader><CardContent><p className="text-3xl font-bold">{canonicalOfficialLinks.counts.canonicalLinks}</p><p className="text-xs text-muted-foreground">{canonicalOfficialLinks.counts.duplicatesCollapsed} exact normalized duplicates collapsed.</p></CardContent></Card>
        <Card><CardHeader className="pb-2"><CardTitle className="flex items-center gap-2 text-base"><Network className="size-4" />Link health</CardTitle></CardHeader><CardContent><p className="text-2xl font-bold">{freshRows.length ? `${freshRows.length} fresh` : "Не измерено"}</p><Badge variant={brokenRows.length ? "destructive" : completeFreshCoverage ? "success" : "warning"}>{brokenRows.length ? `${brokenRows.length} fresh broken` : completeFreshCoverage ? "complete fresh coverage" : staleRows.length ? `${staleRows.length} stale` : "fresh coverage incomplete"}</Badge><p className="mt-2 text-xs text-muted-foreground">Only measured canonical observations from the last {OFFICIAL_LINK_HEALTH_FRESHNESS_WINDOW_HOURS} hours count. Invalid, epoch, future and stale timestamps never contribute to coverage.</p></CardContent></Card>
      </div>
      <PageHeader title="Проверка ссылок текущего каталога" description="Проверка одного сохранённого URL фиксирует HTTP-ответ и время. Она не подтверждает содержание и не обновляет автоматически покрытие всего реестра." />
      <LinksManager rows={legacy.rows} available={legacy.source === "supabase"} writable={canCheckOfficialLink(admin.role)} />
      <CrudTable
        title="Первые 100 canonical sources"
        description={`Показано ${visibleRows.length} из ${canonicalOfficialLinks.counts.canonicalLinks}. link_health_state показывает только fresh результат; stale и «Не измерено» не засчитываются в coverage.`}
        rows={visibleRows}
        columns={["publisher", "canonical_url", "source_type", "evidence_state", "link_health_state", "last_observed_health", "health_freshness", "http_status", "checked_at", "valid_through", "alias_count", "admin_notes", "check_notes", "reference_count"]}
      />
    </>
  );
}
