"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import type { AdminRole } from "@/lib/authorization";
import { approveContentPublicationAction, transitionReviewTaskAction, verifyContentNowAction } from "@/app/(admin)/trust/actions";
import { canTrustAction, nextTrustTransition, safeOfficialUrl, sameTrustTime, sourcePrerequisite, trustUuid, trustRequest, trustRequestForm, restoredTrustIntent, restoredTrustDraft, type TrustRequest, type ReviewTask, type TrustAction, type TrustResult, type TrustState } from "@/lib/trust-workflow";
import { Button } from "@/components/ui/button";

const inputClass = "w-full min-w-0 rounded-md border border-border bg-background px-3 py-2 text-sm";
type Observation = { state: TrustState; task: ReviewTask | null };
function sameObservation(a: Observation, b: Observation) { return a.state.version === b.state.version && (a.task === null ? b.task === null : b.task !== null && a.task.state === b.task.state && sameTrustTime(a.task.updated_at, b.task.updated_at)); }
function TrustEditor({ initial, task: initialTask, available, role, userId, observedAt }: { initial: TrustState; task: ReviewTask | null; available: boolean; role: AdminRole; userId: string; observedAt: string }) {
  const router = useRouter();
  const [baseline, setBaseline] = useState<Observation>({ state: initial, task: initialTask });
  const [incoming, setIncoming] = useState<Observation | null>(null), [reason, setReason] = useState(""), [requestId, setRequestId] = useState(""), [busy, setBusy] = useState(false), [result, setResult] = useState<TrustResult | null>(null);
  const [recordAction, setRecordAction] = useState<TrustAction>("verify");
  const [pending, setPending] = useState<TrustRequest | null>(null);
  const lastIncoming = useRef<Observation>({ state: initial, task: initialTask });
  const initialRecordKey = initial.record_key;
  const initialTaskId = initialTask?.id ?? null;
  const storageKey = `younew-trust-request-v1:${userId}:${initialTaskId ?? initial.id}`;
  useEffect(() => {
    let key = ""; try { key = sessionStorage.getItem(storageKey) ?? ""; } catch {}
    let confirmed = false; try { confirmed = sessionStorage.getItem(storageKey + ":confirmed") === key; } catch {}
    if (!trustUuid.test(key) || confirmed) key = crypto.randomUUID();
    setRequestId(key); try { sessionStorage.setItem(storageKey,key); } catch {}
    let saved: TrustRequest | null = null; try { saved = restoredTrustIntent(sessionStorage.getItem(storageKey + ":pending"),userId,initialRecordKey,initialTaskId); } catch {}
    if (saved) { setPending(saved); setRequestId(saved.requestId); setReason(saved.reason); if (saved.action !== "transition") setRecordAction(saved.action); }
  }, [storageKey, userId, initialRecordKey, initialTaskId]);
  useEffect(() => {
    const next = { state: initial, task: initialTask };
    if (!sameObservation(lastIncoming.current, next)) { lastIncoming.current = next; setIncoming(sameObservation(baseline,next) ? null : next); }
  }, [initial, initialTask, baseline]);
  const row = baseline.state, task = baseline.task;
  const transition = task ? nextTrustTransition(task.state) : null;
  const action: TrustAction = task ? "transition" : recordAction;
  const allowed = canTrustAction(role,action,transition?.state ?? null);
  const hasSource = sourcePrerequisite(row,Date.parse(observedAt));
  const eligible = task ? transition !== null && task.resolved_at === null : action === "verify" ? hasSource : row.review_state === "approved" && ["verified","review_due_soon"].includes(row.effective_verification_status ?? row.verification_status);
  const source = safeOfficialUrl(row.official_source_url);
  function updateId(value: string) { setRequestId(value); setResult(null); if (trustUuid.test(value)) { try { sessionStorage.setItem(storageKey,value); } catch {} } }
  function loadIncoming() {
    if (!available || busy || !incoming || pending !== null) return;
    setBaseline(incoming); setIncoming(null); setReason(""); setResult(null); updateId(crypto.randomUUID());
  }
  async function executeIntent(intent: TrustRequest) {
    if (busy || !canTrustAction(role,intent.action,intent.toState)) return;
    setBusy(true); setResult(null);
    try {
      const response = await (intent.action === "transition" ? transitionReviewTaskAction : intent.action === "publish" ? approveContentPublicationAction : verifyContentNowAction)(trustRequestForm(intent));
      setResult(response);
      if (response.ok) { setPending(null); try { sessionStorage.setItem(storageKey + ":confirmed",response.receipt.requestId); sessionStorage.removeItem(storageKey + ":pending"); } catch {} }
      if (response.ok && response.readbackAvailable && response.current) {
        const next = { state: response.current, task: response.task };
        setIncoming(current => current && current.state.version > next.state.version ? current : next);
      }
    } catch { setResult({ ok: false, kind: "unknown", message: "Результат неизвестен. ID и черновик оставлены. Повторите тот же запрос; не считайте отсутствие ответа отказом записи." }); }
    finally { setBusy(false); }
  }
  async function submit(form: FormData) {
    if (busy || !available || incoming !== null || pending !== null || !allowed || !eligible || !trustUuid.test(requestId)) return;
    const intent = trustRequest(form,action,userId);
    if (!intent) { setResult({ ok: false, kind: "invalid", message: "Проверьте исходные поля запроса и заметку." }); return; }
    setPending(intent); try { const saved = JSON.stringify({ actor: userId, request: intent, observation: baseline }); if (saved.length <= 6000) sessionStorage.setItem(storageKey + ":pending",saved); } catch {}
    await executeIntent(intent);
  }
  return <article className="min-w-0 space-y-3 rounded-lg border border-border p-4 [overflow-wrap:anywhere]">
    <h3 className="break-words font-semibold">{row.title}</h3>
    <p className="break-all text-xs text-muted-foreground">{row.record_key} · исходная версия {row.version} · обновлена {row.updated_at}</p>
    {task ? <><p>Причина: {task.reason}</p><p>Severity: {task.severity} · состояние {task.state} · SLA {task.sla_due_at}</p><p className="text-xs break-all">Задача {task.id} · версия {task.updated_at} · владелец {task.owner_id ?? "не назначен"}</p></> : <>
      <p>Verification: {row.effective_verification_status ?? row.verification_status} · Review: {row.review_state} · Publication: {row.publication_status} · Confidence: {row.effective_confidence_score ?? "—"} / 100</p>
      <p>Последняя ручная проверка: {row.last_verified_at ?? "не подтверждена"}. Следующая проверка: {row.next_review_at ?? "не установлена"}. Интервал: {row.review_interval_days} дней.</p>
      <p className="text-sm">Источник: {source ? <a href={source} target="_blank" rel="noopener noreferrer" className="underline break-all">{source}</a> : "без безопасной ссылки"}; официальность в данных: {row.source_is_official ? "да" : "не подтверждена"}; последнее открытие в источнике: {row.source_opened_at ?? "не подтверждено"}.</p>
      <p className="text-xs text-muted-foreground">Открытие ссылки здесь не записывает проверку. HTTP-доступность не подтверждает содержание. «Verified now» означает выполненную вами содержательную проверку; не используйте её только для тестирования интерфейса.</p>
    </>}
    {incoming ? <div className="space-y-2"><p role="alert">Прочитана версия {incoming.state.version} / задача {incoming.task?.state ?? "—"}. Исходная версия и заметка сохранены. Загрузите текущие данные явно, чтобы продолжить.</p><Button type="button" variant="outline" className="h-auto max-w-full whitespace-normal" disabled={busy || !available || pending !== null} onClick={loadIncoming}>Загрузить текущую версию (заменить черновик)</Button></div> : null}
    {pending ? <div className="space-y-2 rounded-md border border-amber-400/40 p-3"><p role="alert">Сохранён исходный запрос {pending.requestId} ({pending.action}, версия {pending.expectedVersion}). Локальная копия не доказывает выполнение. Повтор ниже отправляет ровно исходные поля независимо от более новой прочитанной версии.</p><Button type="button" variant="outline" className="h-auto max-w-full whitespace-normal" disabled={busy || !canTrustAction(role,pending.action,pending.toState)} onClick={() => executeIntent(pending)}>Повторить исходный запрос</Button><Button type="button" variant="outline" className="h-auto max-w-full whitespace-normal" disabled={busy} onClick={() => { if (busy) return; setPending(null); try { sessionStorage.removeItem(storageKey + ":pending"); } catch {} updateId(crypto.randomUUID()); setResult({ ok: false, kind: "unknown", message: "Локальный повтор отменён. Это не отменяет возможную запись в БД. Перечитайте текущую версию перед следующим действием; заметка оставлена для копирования." }); }}>Отменить локальный повтор (не запись в БД)</Button></div> : null}
    {canTrustAction(role,"transition") ? <form action={submit} className="min-w-0 space-y-3">
      <input type="hidden" name="recordKey" value={row.record_key} /><input type="hidden" name="expectedVersion" value={row.version} />
      {task ? <><input type="hidden" name="taskID" value={task.id} /><input type="hidden" name="expectedState" value={task.state} /><input type="hidden" name="expectedUpdatedAt" value={task.updated_at} /><input type="hidden" name="toState" value={transition?.state ?? ""} /><input type="hidden" name="ownerID" value={transition?.state === "assigned" ? userId : ""} /></> : <label className="block">Действие<select name="action" className={inputClass} disabled={busy || !available || pending !== null} value={recordAction} onChange={e => { setRecordAction(e.target.value as TrustAction); setResult(null); }}><option value="verify">Verified now — ручная проверка</option>{canTrustAction(role,"publish") ? <option value="publish">Явное одобрение operational publication</option> : null}</select></label>}
      <label className="block">ID запроса<input name="idempotencyKey" className={inputClass} value={requestId} readOnly={busy || !available || pending !== null} onChange={e => updateId(e.target.value)} required /></label>
      <label className="block">Заметка и основания действия<textarea name="reason" className={inputClass} rows={3} required minLength={2} maxLength={1000} readOnly={busy || !available || pending !== null} value={reason} onChange={e => { setReason(e.target.value); setResult(null); }} /></label>
      <p className="text-xs text-muted-foreground">Не добавляйте секреты или лишние персональные данные. Исходный отправленный запрос сохраняется в sessionStorage этой вкладки до подтверждения или явного отказа от повтора. Это не серверная квитанция; при недоступном хранилище сохраните ID и поля самостоятельно.</p>
      {!allowed ? <p>Это действие недоступно текущей роли.</p> : !eligible ? <p>{task?.state === "approved" ? "Задача закрывается только при явном одобрении публикации соответствующей записи." : "Условия действия не подтверждены: требуется допустимый переход либо свежий официальный источник и ручное одобрение."}</p> : null}
      <Button type="submit" disabled={busy || !available || incoming !== null || pending !== null || !allowed || !eligible || !trustUuid.test(requestId)}>{busy ? "Ожидание подтверждения…" : task ? transition?.label ?? "Нет перехода" : action === "verify" ? "Verified now" : "Одобрить operational publication"}</Button>
    </form> : <p>Только чтение для этой роли.</p>}
    {result ? result.ok ? <div role="status"><p>Операция подтверждена: версия {result.receipt.resultVersion}, {result.receipt.confirmedAt}{result.replayed ? "; повтор без новой операции" : ""}. Это подтверждение операции в указанное время.</p><p>{result.readbackAvailable && available ? `Отдельное текущее чтение: версия ${result.current?.version}, review ${result.current?.review_state}.` : "Текущее состояние недоступно или вне текущей выборки; оно неизвестно. Квитанция операции от этого не меняется."}</p></div> : <p role="alert">{result.message}</p> : null}
    <Button type="button" variant="outline" disabled={busy} onClick={() => router.refresh()}>Перечитать список</Button>
  </article>;
}

export function TrustWorkflow({ states, tasks, taskStates, statesAvailable, tasksAvailable, role, userId, observedAt, stateTotal, taskTotal }: { states: TrustState[]; tasks: ReviewTask[]; taskStates: TrustState[]; statesAvailable: boolean; tasksAvailable: boolean; role: AdminRole; userId: string; observedAt: string; stateTotal: number | null; taskTotal: number | null }) {
  const [localStates,setLocalStates] = useState(states), [localTasks,setLocalTasks] = useState(tasks), [localTaskStates,setLocalTaskStates] = useState(taskStates);
  useEffect(() => {
    // Only this approved user's bounded pending drafts, never credentials or a
    // server permission/receipt. Off-page copies stay read-only except exact retry.
    try {
      const recovered: Observation[] = [];
      for (let index=0; index < Math.min(sessionStorage.length,200) && recovered.length < 50; index++) {
        const key = sessionStorage.key(index);
        if (!key?.startsWith(`younew-trust-request-v1:${userId}:`) || !key.endsWith(":pending")) continue;
        const value = restoredTrustDraft(sessionStorage.getItem(key),userId); if (value) recovered.push(value);
      }
      setLocalStates(prior => [...prior,...recovered.filter(v => v.task === null && !prior.some(row => row.id === v.state.id)).map(v => v.state)]);
      setLocalTasks(prior => [...prior,...recovered.filter(v => v.task !== null && !prior.some(row => row.id === v.task?.id)).map(v => v.task!)]);
      setLocalTaskStates(prior => [...prior,...recovered.filter(v => v.task !== null && !prior.some(row => row.id === v.state.id)).map(v => v.state)]);
    } catch { /* Storage is optional; no source or zero-count claims follow. */ }
  }, [userId]);
  useEffect(() => { if (statesAvailable) setLocalStates(prior => [...states,...prior.filter(row => !states.some(next => next.id === row.id))]); }, [states,statesAvailable]);
  useEffect(() => { if (tasksAvailable) { setLocalTasks(prior => [...tasks,...prior.filter(row => !tasks.some(next => next.id === row.id))]); setLocalTaskStates(prior => [...taskStates,...prior.filter(row => !taskStates.some(next => next.id === row.id))]); } }, [tasks,taskStates,tasksAvailable]);
  return <div className="mt-8 min-w-0 space-y-8 [overflow-wrap:anywhere]">
    <section aria-labelledby="review-queue-title" className="min-w-0 space-y-4">
      <h2 id="review-queue-title" className="text-lg font-semibold">Human Review Queue</h2>
      <p>Needs review → Assigned → In review → Approved → explicit publication → закрытая задача; запись переходит в Monitoring. Это operational status, не публикация сайта или приложения.</p>
      <p className="text-xs">Чтение: {observedAt}. {tasksAvailable ? `Открытых задач: ${taskTotal ?? "неизвестно"}; в текущей выборке ${tasks.length}.` : "Очередь недоступна: количество и текущие статусы неизвестны. Последние записи и черновики оставлены только для копирования; запись отключена."}</p>
      {tasksAvailable && taskTotal === 0 ? <p>Источник прочитан: открытых задач нет. Это не подтверждает работу scheduled aging: задачи создаются отдельным процессом.</p> : null}
      <p className="text-xs">Задача, исчезнувшая из текущей открытой выборки, остаётся ниже как последняя известная копия с отключённой записью. Это может означать закрытие или другую страницу; не считается отказом операции.</p>
      <div className="min-w-0 space-y-4">{localTasks.map(task => { const state = localTaskStates.find(s => s.id === task.governance_state_id); return state ? <TrustEditor key={task.id} initial={state} task={task} available={tasksAvailable && tasks.some(next => next.id === task.id)} role={role} userId={userId} observedAt={observedAt} /> : <article key={task.id}><p>{task.reason} · {task.state} · SLA {task.sla_due_at}</p><p>Связанная запись недоступна; действие отключено.</p></article>; })}</div>
    </section>
    <section aria-labelledby="content-health-title" className="min-w-0 space-y-4">
      <h2 id="content-health-title" className="text-lg font-semibold">Governed records</h2>
      <p>{statesAvailable ? `Записей: ${stateTotal ?? "неизвестно"}; в текущей выборке ${states.length}. Остальные сохранённые формы — последние известные копии, запись из них отключена.` : "Записи недоступны: количество и актуальность неизвестны. Последние данные и черновики оставлены для копирования; действия отключены."}</p>
      <p className="text-xs">Срок следующей проверки — поле источника. overdue/review_due_soon вычисляются по срокам; это не доказательство запущенного executor и не автоматическая проверка содержания.</p>
      {statesAvailable && stateTotal === 0 ? <p>Источник прочитан: governed records отсутствуют.</p> : null}
      <div className="min-w-0 space-y-4">{localStates.map(state => <TrustEditor key={state.id} initial={state} task={null} available={statesAvailable && states.some(next => next.id === state.id)} role={role} userId={userId} observedAt={observedAt} />)}</div>
    </section>
  </div>;
}
