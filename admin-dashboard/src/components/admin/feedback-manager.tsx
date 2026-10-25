"use client";

import { useState, useTransition, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { updateFeedback } from "@/app/(admin)/feedback/actions";
import { feedbackStatuses, type FeedbackRow, type FeedbackStatus } from "@/lib/feedback";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

function FeedbackEditor({ initial }: { initial: FeedbackRow }) {
  const [saved, setSaved] = useState(initial);
  const [status, setStatus] = useState<FeedbackStatus>(initial.status);
  const [note, setNote] = useState(initial.resolution_note ?? "");
  const [notice, setNotice] = useState<{ ok: boolean; text: string } | null>(null);
  const [pending, startTransition] = useTransition();
  const label = initial.confirmation_code || initial.id;

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    setNotice(null);
    startTransition(async () => {
      try {
        const result = await updateFeedback(data);
        if (!result.ok) { setNotice({ ok: false, text: result.message }); return; }
        setSaved({ ...saved, ...result.row });
        setStatus(result.row.status);
        setNote(result.row.resolution_note ?? "");
        setNotice({ ok: true, text: "Изменения подтверждены источником." });
      } catch {
        setNotice({ ok: false, text: "Сохранение не подтверждено. Черновик оставлен в форме; проверьте вход и обновите список перед повторной попыткой." });
      }
    });
  }

  return <Card>
    <CardHeader>
      <CardTitle>{label}</CardTitle>
      <CardDescription>Создано: {initial.created_at}. Сохранённый статус: {feedbackStatuses[saved.status] ?? saved.status}. Последнее изменение: {saved.updated_at}.</CardDescription>
    </CardHeader>
    <CardContent>
      <dl className="mb-4 grid gap-2 text-sm">
        <div><dt className="text-muted-foreground">Происхождение записи</dt><dd>{initial.record_origin ?? "Не классифицировано — не считать подтверждением реального пользователя"}</dd></div>
        <div><dt className="text-muted-foreground">Тип и страница</dt><dd>{initial.feedback_type ?? "Не указан"} · {initial.page_reference ?? "Не указана"}</dd></div>
        <div><dt className="text-muted-foreground">Email для связи</dt><dd>{initial.user_email || "Не указан"}</dd></div>
        <div><dt className="text-muted-foreground">Сообщение</dt><dd className="whitespace-pre-wrap break-words">{initial.message}</dd></div>
      </dl>
      <form onSubmit={submit} className="grid gap-3" aria-label={`Обработка ${label}`}>
        <input type="hidden" name="id" value={initial.id} />
        <input type="hidden" name="updated_at" value={saved.updated_at} />
        <Label htmlFor={`status-${initial.id}`}>Статус обращения</Label>
        <select id={`status-${initial.id}`} name="status" value={status} disabled={pending} onChange={(event) => { setStatus(event.target.value as FeedbackStatus); setNotice(null); }} className="h-10 rounded-md border border-input bg-background px-3 text-sm">
          {Object.entries(feedbackStatuses).map(([value, title]) => <option key={value} value={value}>{title}</option>)}
        </select>
        <Label htmlFor={`note-${initial.id}`}>Внутренний комментарий / результат проверки</Label>
        <Textarea id={`note-${initial.id}`} name="resolution_note" value={note} maxLength={4000} disabled={pending} onChange={(event) => { setNote(event.target.value); setNotice(null); }} />
        <p className="text-sm text-muted-foreground">Комментарий остаётся в Admin. Смена статуса не отправляет письмо и не исправляет материал автоматически.</p>
        {notice ? <p role={notice.ok ? "status" : "alert"} className={notice.ok ? "text-sm text-emerald-400" : "text-sm text-red-400"}>{notice.text}</p> : null}
        <div><Button type="submit" disabled={pending}>{pending ? "Сохранение…" : "Сохранить обработку"}</Button></div>
      </form>
    </CardContent>
  </Card>;
}

export function FeedbackManager({ rows, available }: { rows: FeedbackRow[]; available: boolean }) {
  const router = useRouter();
  const [refreshing, startRefresh] = useTransition();
  return <div className="grid gap-4">
    <div><Button variant="outline" disabled={refreshing} onClick={() => startRefresh(() => router.refresh())}>{refreshing ? "Обновление…" : "Обновить список"}</Button></div>
    <p className="text-sm text-muted-foreground">Перед обновлением скопируйте несохранённый комментарий. {available ? `Показаны последние ${rows.length} доступных записей, максимум100; это не число реальных пользователей.` : "Количество обращений неизвестно, пока источник недоступен."}</p>
    {!available ? <p role="alert">Источник обращений недоступен. Отсутствие данных не означает пустую очередь.</p> : rows.length === 0 ? <p>Запрос выполнен успешно: доступных обращений нет.</p> : rows.map((row) => <FeedbackEditor key={`${row.id}:${row.updated_at}`} initial={row} />)}
  </div>;
}
