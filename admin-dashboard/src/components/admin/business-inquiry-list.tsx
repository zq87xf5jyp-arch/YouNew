"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { Download, Search } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";

export type BusinessInquiryListRow = {
  id: string;
  confirmation_code: string;
  company: string;
  contact_name: string;
  work_email: string;
  inquiry_type: string;
  status: "new" | "contacted" | "qualified" | "closed" | "rejected" | "spam";
  source_page: string;
  created_at: string;
};

const statusLabels: Record<BusinessInquiryListRow["status"], string> = {
  new: "новая",
  contacted: "связались",
  qualified: "подтверждена",
  closed: "закрыта",
  rejected: "отклонена",
  spam: "спам"
};

export function BusinessInquiryList({
  rows,
  available
}: {
  rows: BusinessInquiryListRow[];
  available: boolean;
}) {
  const [query, setQuery] = useState("");
  const [status, setStatus] = useState("");
  const filtered = useMemo(() => {
    const normalized = query.trim().toLocaleLowerCase("ru");
    return rows.filter((row) => {
      const statusMatches = !status || row.status === status;
      const queryMatches = !normalized || [
        row.confirmation_code,
        row.company,
        row.contact_name,
        row.work_email,
        row.inquiry_type
      ].join(" ").toLocaleLowerCase("ru").includes(normalized);
      return statusMatches && queryMatches;
    });
  }, [query, rows, status]);

  return (
    <Card>
      <CardHeader>
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <CardTitle>Входящие бизнес-заявки</CardTitle>
            <CardDescription>
              {available
                ? `${rows.length} заявок · показано ${filtered.length}`
                : "Таблица business_inquiries пока недоступна в подключённом Supabase."}
            </CardDescription>
          </div>
          {available ? (
            <Button asChild variant="outline" size="sm">
              <Link href="/business-inquiries/export"><Download className="size-4" />Экспорт без сообщения и внутренних заметок</Link>
            </Button>
          ) : null}
        </div>
        <div className="grid gap-3 pt-3 md:grid-cols-[1fr_220px]">
          <div className="relative">
            <Search className="absolute left-3 top-3 size-4 text-muted-foreground" />
            <Input className="pl-9" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="ID, компания, контакт или email" />
          </div>
          <label className="sr-only" htmlFor="business-inquiry-status">Статус заявки</label>
          <select id="business-inquiry-status" className="h-10 rounded-md border border-input bg-secondary/50 px-3 text-sm" value={status} onChange={(event) => setStatus(event.target.value)}>
            <option value="">Все статусы</option>
            {Object.entries(statusLabels).map(([value, label]) => <option value={value} key={value}>{label}</option>)}
          </select>
        </div>
      </CardHeader>
      <CardContent>
        <div className="overflow-x-auto">
          <table className="younew-table">
            <thead><tr><th>ID</th><th>Компания</th><th>Тип</th><th>Статус</th><th>Создано</th><th /></tr></thead>
            <tbody>
              {filtered.map((row) => (
                <tr key={row.id}>
                  <td className="font-mono text-xs">{row.confirmation_code}</td>
                  <td><p className="font-medium">{row.company}</p><p className="text-xs text-muted-foreground">{row.contact_name} · {row.work_email}</p></td>
                  <td>{row.inquiry_type}</td>
                  <td><Badge variant={row.status === "new" ? "warning" : row.status === "qualified" ? "success" : "secondary"}>{statusLabels[row.status]}</Badge></td>
                  <td>{new Intl.DateTimeFormat("nl-NL", { dateStyle: "medium", timeStyle: "short" }).format(new Date(row.created_at))}</td>
                  <td><Link className="text-cyan-200 underline-offset-4 hover:underline" href={`/business-inquiries/${row.id}`}>Открыть</Link></td>
                </tr>
              ))}
              {filtered.length === 0 ? <tr><td colSpan={6} className="py-10 text-center text-muted-foreground">Подтверждённых заявок по выбранным фильтрам нет.</td></tr> : null}
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  );
}
