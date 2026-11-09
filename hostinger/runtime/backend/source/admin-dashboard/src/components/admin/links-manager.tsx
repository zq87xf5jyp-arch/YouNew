"use client";

import { useState, useTransition, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { verifyOfficialLink } from "@/app/(admin)/links/actions";
import { officialLinkCheckLabel, type OfficialLinkRow } from "@/lib/official-link-workflow";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

function LinkCheckRow({ initial, writable }: { initial: OfficialLinkRow; writable: boolean }) {
  const [row, setRow] = useState(initial);
  const [notice, setNotice] = useState<{ ok: boolean; message: string } | null>(null);
  const [pending, startTransition] = useTransition();
  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    setNotice(null);
    startTransition(async () => {
      try {
        const result = await verifyOfficialLink(form);
        if (!result.ok) { setNotice({ ok: false, message: result.message }); return; }
        setRow(result.row);
        setNotice({ ok: true, message: `${officialLinkCheckLabel(result.check)} Результат сохранён. Время: ${result.check.checkedAt}.` });
      } catch {
        setNotice({ ok: false, message: "Результат сохранения неизвестен. Обновите список перед повтором." });
      }
    });
  }
  return <Card>
    <CardHeader><CardTitle>{row.title}</CardTitle><CardDescription>Сохранённый статус: {row.status}. Дата последней попытки (UTC): {row.last_checked_date ?? "не указана"}.</CardDescription></CardHeader>
    <CardContent className="grid gap-3">
      <p className="break-all text-sm">{row.url}</p>
      <p className="text-sm text-muted-foreground">HTTP-доступность относится только к этому URL и времени наблюдения. Она не подтверждает содержание, актуальность рекомендаций или весь реестр.</p>
      {row.notes ? <details className="text-sm"><summary>Заметки и сохранённые наблюдения</summary><pre className="whitespace-pre-wrap break-words font-sans">{row.notes}</pre></details> : null}
      {writable ? <form onSubmit={submit}>
        <input type="hidden" name="id" value={row.id} /><input type="hidden" name="url" value={row.url} /><input type="hidden" name="updated_at" value={row.updated_at} />
        <Button disabled={pending} type="submit">{pending ? "Проверка и сохранение…" : "Проверить URL и сохранить результат"}</Button>
      </form> : <p className="text-sm text-muted-foreground">Запуск проверки доступен владельцу и администратору.</p>}
      {notice ? <p role={notice.ok ? "status" : "alert"} className="text-sm">{notice.message}</p> : null}
    </CardContent>
  </Card>;
}

export function LinksManager({ rows, available, writable }: { rows: OfficialLinkRow[]; available: boolean; writable: boolean }) {
  const router = useRouter();
  const [refreshing, startRefresh] = useTransition();
  return <section className="grid gap-4" aria-label="Проверка официальных ссылок">
    <div><Button variant="outline" disabled={refreshing} onClick={() => startRefresh(() => router.refresh())}>{refreshing ? "Обновление…" : "Обновить каталог"}</Button></div>
    {!available ? <p role="alert">Каталог недоступен. Количество и состояние ссылок неизвестны; проверка не запущена.</p>
      : rows.length === 0 ? <p>Запрос выполнен: доступных ссылок в каталоге нет.</p>
        : <><p className="text-sm text-muted-foreground">Показано {rows.length} записей, максимум 100. Каждая проверка запускается отдельно.</p>{rows.map((row) => <LinkCheckRow key={`${row.id}:${row.updated_at}`} initial={row} writable={writable} />)}</>}
  </section>;
}
