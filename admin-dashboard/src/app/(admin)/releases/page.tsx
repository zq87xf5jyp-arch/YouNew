import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { ReleaseReadinessOverview } from "@/components/admin/release-readiness-overview";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import dataProject from "@/generated/data-project-dashboard.json";

export default function ReleasesPage() {
  const nextDataRelease = dataProject.next_release;

  return (
    <>
      <PageHeader
        title="Release Control"
        description="Product Release и независимые Data Releases: только подтверждённый evidence, открытые gates и воспроизводимый статус."
      />
      <div className="mb-8">
        <ReleaseReadinessOverview />
      </div>
      <h2 className="mb-4 text-lg font-semibold">DATA PROJECT Releases</h2>
      <div className="grid gap-6 xl:grid-cols-[0.8fr_1.2fr]">
        <Card>
          <CardHeader>
            <CardTitle>Текущий Data Release</CardTitle>
            <CardDescription>Версия данных, находящаяся у пользователей.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex items-center justify-between gap-3">
              <span className="text-sm text-muted-foreground">Release</span>
              <Badge variant="warning">{dataProject.runtime_release.version}</Badge>
            </div>
            <p className="text-sm">{dataProject.runtime_release.note}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Следующий Data Release</CardTitle>
            <CardDescription>{nextDataRelease ? `${nextDataRelease.dataset} · v${nextDataRelease.version}` : "Не запланирован"}</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {nextDataRelease ? (
              <>
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <p className="text-sm font-semibold">{nextDataRelease.id}</p>
                    <p className="text-xs text-muted-foreground">{nextDataRelease.milestone} · {nextDataRelease.published_records} / {nextDataRelease.target_records} records</p>
                  </div>
                  <Badge>{nextDataRelease.status}</Badge>
                </div>
                <div className="grid gap-2 sm:grid-cols-2 lg:grid-cols-4">
                  {Object.entries(nextDataRelease.qa).map(([gate, status]) => (
                    <div key={gate} className="rounded-md border border-border bg-secondary/25 p-2 text-xs">
                      <span className="font-medium uppercase">{gate}</span>
                      <span className="ml-2 text-muted-foreground">{status}</span>
                    </div>
                  ))}
                </div>
              </>
            ) : null}
          </CardContent>
        </Card>
      </div>
    </>
  );
}
