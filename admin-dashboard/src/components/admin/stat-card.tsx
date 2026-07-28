import type { LucideIcon } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

export function StatCard({
  label,
  value,
  note,
  icon: Icon,
  tone = "info"
}: {
  label: string;
  value: string | number;
  note: string;
  icon: LucideIcon;
  tone?: "info" | "warning" | "success" | "destructive";
}) {
  return (
    <Card>
      <CardHeader className="flex-row items-center justify-between gap-4 pb-3">
        <CardTitle className="text-sm text-muted-foreground">{label}</CardTitle>
        <Badge variant={tone}>
          <Icon className="size-3" />
        </Badge>
      </CardHeader>
      <CardContent>
        <p className="text-3xl font-bold">{value}</p>
        <p className="mt-1 text-xs text-muted-foreground">{note}</p>
      </CardContent>
    </Card>
  );
}
