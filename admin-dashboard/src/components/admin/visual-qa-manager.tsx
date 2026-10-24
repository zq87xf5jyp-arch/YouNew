"use client";

import { useEffect, useRef, useState, useTransition, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { createScreenshotReview, saveScreenshotReview } from "@/app/(admin)/visual-qa/actions";
import { isReviewId, visualStatuses, visualStatusLabels, type ScreenshotView } from "@/lib/visual-qa";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

const selectStyle = "h-10 rounded-md border border-input bg-background px-3 text-sm";

function ReviewRow({ initial }: { initial: ScreenshotView }) {
  const [row, setRow] = useState(initial);
  const [notes, setNotes] = useState(initial.notes ?? "");
  const [status, setStatus] = useState(initial.visual_status);
  const [notice, setNotice] = useState<{ ok: boolean; message: string } | null>(null);
  const [previewFailed, setPreviewFailed] = useState(false);
  const [pending, start] = useTransition();
  useEffect(() => {
    setRow(current => ({ ...current, previewUrl: initial.previewUrl }));
    setPreviewFailed(false);
  }, [initial.previewUrl]);
  function save(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); const form = new FormData(event.currentTarget); setNotice(null);
    start(async () => { try {
      const result = await saveScreenshotReview(form);
      setNotice({ ok: result.ok, message: result.message });
      if (result.ok) setRow({ ...result.row, previewUrl: row.previewUrl });
    } catch { setNotice({ ok: false, message: "Сохранение неизвестно. Черновик остаётся в форме; перечитайте каталог перед повтором." }); } });
  }
  return <Card><CardHeader><CardTitle>{row.screen_type}</CardTitle><CardDescription>{row.platform} · {row.device} · Сохранено: {visualStatusLabels[row.visual_status]} · {row.updated_at}</CardDescription></CardHeader>
    <CardContent className="grid gap-3">
      {row.previewUrl && !previewFailed ? <>
        {/* Short-lived private URL; never written to the database or browser storage. */}
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={row.previewUrl} alt={`Скриншот экрана ${row.screen_type}`} className="max-h-96 max-w-full rounded border object-contain" referrerPolicy="no-referrer" onError={() => setPreviewFailed(true)} />
      </> : <p>Приватный просмотр недоступен или истёк. Обновите каталог; отсутствие изображения не означает успешную проверку.</p>}
      <form onSubmit={save} className="grid gap-3">
        <input type="hidden" name="id" value={row.id} /><input type="hidden" name="updated_at" value={row.updated_at} />
        <Label htmlFor={`visual-status-${row.id}`}>Результат ручной проверки</Label>
        <select className={selectStyle} id={`visual-status-${row.id}`} name="visual_status" value={status} disabled={pending} onChange={event => { setStatus(event.target.value as typeof status); setNotice(null); }}>{visualStatuses.map(value => <option key={value} value={value}>{visualStatusLabels[value]}</option>)}</select>
        <Label htmlFor={`visual-notes-${row.id}`}>Заметки и основание результата</Label>
        <Textarea id={`visual-notes-${row.id}`} name="notes" maxLength={4000} value={notes} disabled={pending} onChange={event => { setNotes(event.target.value); setNotice(null); }} />
        <Button type="submit" disabled={pending}>{pending ? "Сохранение…" : "Сохранить ручную проверку"}</Button>
      </form>
      {notice ? <p role={notice.ok ? "status" : "alert"}>{notice.message}</p> : null}
    </CardContent></Card>;
}

export function VisualQAManager({ rows, available, requestId, draftKey }: { rows: ScreenshotView[]; available: boolean; requestId: string; draftKey: string }) {
  const router = useRouter(); const formRef = useRef<HTMLFormElement>(null);
  const [id, setId] = useState(requestId);
  const [draftReady, setDraftReady] = useState(false);
  const [persistentDraft, setPersistentDraft] = useState(true);
  const [notice, setNotice] = useState<{ ok: boolean; message: string } | null>(null);
  const [pending, start] = useTransition();
  useEffect(() => {
    try { const saved = localStorage.getItem(draftKey); if (isReviewId(saved)) setId(saved); }
    catch { setPersistentDraft(false); }
    setDraftReady(true);
  }, [draftKey]);
  useEffect(() => {
    if (!draftReady) return;
    try { localStorage.setItem(draftKey, id); } catch { setPersistentDraft(false); }
  }, [draftKey, draftReady, id]);
  function create(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); const form = new FormData(event.currentTarget); setNotice(null);
    start(async () => { try {
      const result = await createScreenshotReview(form); setNotice({ ok: result.ok, message: result.message });
      if (result.ok) { formRef.current?.reset(); setId(crypto.randomUUID()); router.refresh(); }
    } catch { setNotice({ ok: false, message: "Результат неизвестен. Не меняйте файл и идентификатор при повторе; сначала проверьте каталог." }); } });
  }
  return <section className="grid gap-5" aria-label="Ручная проверка скриншотов">
    <div><Button variant="outline" disabled={pending} onClick={() => start(() => router.refresh())}>Обновить каталог и приватный просмотр</Button></div>
    {!available ? <p role="alert">Каталог недоступен: количество и результаты проверок неизвестны. Загрузка и сохранение отключены.</p> : <>
      <Card><CardHeader><CardTitle>Загрузить скриншот и создать проверку</CardTitle><CardDescription>PNG/JPEG до 512 КБ, до 8192 пикселей по стороне и 32 Мп. Новая запись всегда требует ручной проверки. Не загружайте пароли и персональные данные.</CardDescription></CardHeader>
        <CardContent><form ref={formRef} onSubmit={create} className="grid gap-3" onChange={() => setNotice(null)}>
          <Label htmlFor="visual-request-id">Идентификатор для восстановления после сбоя</Label><Input id="visual-request-id" name="id" value={id} disabled={pending || !draftReady} maxLength={36} onChange={event => setId(event.target.value)} required />
          <p className="text-xs text-muted-foreground">При повторе сохраните этот идентификатор и выберите тот же файл. После перезагрузки поля и файл нужно заполнить снова. Локально сохраняется только идентификатор, отдельно для вашего аккаунта.</p>
          {!persistentDraft ? <p role="alert">Локальное сохранение идентификатора недоступно. Скопируйте его перед отправкой для восстановления после перезагрузки.</p> : null}
          <Label htmlFor="visual-file">Скриншот PNG/JPEG</Label><Input id="visual-file" name="file" type="file" accept="image/png,image/jpeg" required disabled={pending} />
          <Label htmlFor="visual-screen">Экран</Label><Input id="visual-screen" name="screen_type" maxLength={120} required disabled={pending} />
          <Label htmlFor="visual-platform">Платформа</Label><select id="visual-platform" name="platform" className={selectStyle} defaultValue="Web" disabled={pending}>{["iOS", "Android", "Web"].map(value => <option key={value}>{value}</option>)}</select>
          <Label htmlFor="visual-device">Устройство</Label><select id="visual-device" name="device" className={selectStyle} defaultValue="Desktop" disabled={pending}>{["iPhone", "Android", "Tablet", "Desktop"].map(value => <option key={value}>{value}</option>)}</select>
          <Label htmlFor="visual-notes">Заметки</Label><Textarea id="visual-notes" name="notes" maxLength={4000} disabled={pending} />
          <Button type="submit" disabled={pending || !draftReady}>{pending ? "Загрузка и сохранение…" : "Загрузить и создать проверку"}</Button>
        </form>{notice ? <p className="mt-3" role={notice.ok ? "status" : "alert"}>{notice.message}</p> : null}</CardContent>
      </Card>
      <p className="text-sm text-muted-foreground">Показано {rows.length} последних записей, максимум 20. Приватные ссылки действуют 60 секунд. Это ручная проверка, не автоматический visual diff, CI или AI-анализ.</p>
      {rows.length ? rows.map(row => <ReviewRow key={`${row.id}:${row.updated_at}`} initial={row} />) : <p>Запрос выполнен: сохранённых проверок нет.</p>}
    </>}
  </section>;
}
