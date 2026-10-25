"use client";

import { useEffect, useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import { readContentSync, requestContentSync } from "@/app/(admin)/sync/actions";
import { canStartNextSync, formatSyncTime, parseStoredSyncId, syncStorageKey, type SyncResult } from "@/lib/sync-workflow";

export function SyncRequestPanel({ userId, disabled = false }: { userId: string; disabled?: boolean }) {
  const [id, setId] = useState<string | null>(null), [result, setResult] = useState<SyncResult | null>(null);
  const [ready, setReady] = useState(false), [pending, setPending] = useState(false), [storageError, setStorageError] = useState(false);
  const activeId = useRef<string | null>(null), busy = useRef(false), requestGeneration = useRef(0);
  const key = syncStorageKey(userId);
  useEffect(() => {
    let cancelled = false;
    const generation = ++requestGeneration.current;
    setReady(false); setResult(null); setId(null); activeId.current = null;
    try {
      const stored = localStorage.getItem(key), saved = parseStoredSyncId(stored);
      if (stored !== null && !saved) throw new Error("stored_id_invalid");
      setStorageError(false); setReady(true); activeId.current = saved; setId(saved);
      if (saved) { const form = new FormData(); form.set("request_id", saved); void readContentSync(form).then((value) => { if (!cancelled && requestGeneration.current === generation && activeId.current === saved) setResult(value); }).catch(() => { if (!cancelled && requestGeneration.current === generation) setResult({ state: "unknown", message: "Ответ недоступен. ID сохранён; проверьте этот же запрос." }); }); }
    } catch { setStorageError(true); }
    return () => { cancelled = true; };
  }, [key]);
  async function run(mode: "read" | "resume" | "new") {
    if (disabled || busy.current || !ready) return;
    const savedReceipt = result?.state === "confirmed" ? result.receipt : null;
    if (mode === "new" && activeId.current && !canStartNextSync(savedReceipt)) return;
    busy.current = true; setPending(true);
    const generation = ++requestGeneration.current;
    try {
      let selected = activeId.current;
      if (mode === "new") {
        selected = crypto.randomUUID();
        const value = JSON.stringify({ version: 1, id: selected });
        // Persist before any request; failed storage means no mutation is sent.
        try { localStorage.setItem(key, value); if (localStorage.getItem(key) !== value) throw new Error("storage_readback_failed"); }
        catch { setStorageError(true); setReady(false); return; }
        activeId.current = selected; setId(selected); setResult(null);
      }
      if (!selected) return;
      const form = new FormData(); form.set("request_id", selected);
      const response = mode === "read" ? await readContentSync(form) : await requestContentSync(form);
      if (requestGeneration.current === generation && activeId.current === selected) setResult(response);
    } catch { if (requestGeneration.current === generation) setResult({ state: "unknown", message: "Ответ недоступен. ID сохранён; проверьте или продолжите этот же запрос." }); }
    finally { busy.current = false; setPending(false); }
  }
  const row = result?.state === "confirmed" ? result.receipt : null;
  return <div className="space-y-3 rounded-md border border-border p-4">
    <p className="font-medium text-foreground">Подготовка кандидата — ручной запуск</p>
    <p>Команда сохраняет артефакт и результат подготовки. Она не активирует сайт или iOS, не меняет даты проверки источников и не запускает расписание.</p>
    {id && <p className="break-all text-xs">ID запроса: <code>{id}</code></p>}
    {storageError && <p role="alert">Не удалось сохранить или восстановить ID в браузере. Новый запрос не отправлен; существующий ID не сбрасывается автоматически.</p>}
    <div className="flex flex-wrap gap-2">
      {!id ? <Button disabled={disabled || !ready || pending} onClick={() => void run("new")}>Подготовить candidate-артефакт</Button> : <>
        <Button variant="secondary" disabled={disabled || !ready || pending} onClick={() => void run("read")}>Проверить этот запрос</Button>
        <Button disabled={disabled || !ready || pending || (row !== null && (row.status === "succeeded" || row.status === "cancelled" || (row.status === "failed" && !row.retryable)))} onClick={() => void run("resume")}>Продолжить с тем же ID</Button>
        <Button variant="outline" disabled={disabled || !ready || pending || !canStartNextSync(row)} onClick={() => void run("new")}>Новый отдельный запрос</Button>
      </>}
    </div>
    {disabled ? <p role="status" className="text-xs">Подготовка отключена: административные источники не прочитаны.</p> : null}
    <p className="text-xs">Повтор использует тот же ID. После неизвестного ответа или перезагрузки сначала прочитайте его состояние. В браузере хранится только непрозрачный ID, отдельно для вашего аккаунта.</p>
    <div aria-live="polite">{pending ? <p>Проверяем запрос… Закрытие страницы не отменяет уже принятую задачу.</p> : result && <p>{result.message}</p>}</div>
    {row && <dl className="grid gap-2 text-xs sm:grid-cols-2">
      <div><dt>Сохранённый статус</dt><dd>{row.status}{row.status === "running" ? " — проверьте срок аренды; это не сигнал работающего процесса" : ""}</dd></div>
      <div><dt>Попыток этого исполнителя</dt><dd>{row.attemptCount ?? "неизвестно (историческая задача)"}</dd></div>
      <div><dt>Последняя попытка · Amsterdam</dt><dd>{formatSyncTime(row.attemptAt)}</dd></div>
      <div><dt>Сохранённое завершение · Amsterdam</dt><dd>{formatSyncTime(row.completedAt)}</dd></div>
      <div><dt>Аренда до · Amsterdam</dt><dd>{formatSyncTime(row.leaseExpiresAt)}</dd></div>
      <div><dt>Повтор доступен с · Amsterdam</dt><dd>{formatSyncTime(row.nextRetryAt)}</dd></div>
      {row.status === "succeeded" && <><div><dt>Записей в подготовленном артефакте</dt><dd>{row.recordCount}</dd></div><div><dt>Fingerprint</dt><dd className="break-all font-mono">{row.fingerprint}</dd></div></>}
      {row.errorCode && <div><dt>Сохранённая причина</dt><dd>{row.errorCode}</dd></div>}
    </dl>}
    <p className="text-xs">Исполнитель делает не более трёх попыток. После прерывания запроса восстановление запускается кнопкой с тем же ID, когда истечёт аренда. Постоянный фоновый исполнитель не подтверждён.</p>
  </div>;
}
