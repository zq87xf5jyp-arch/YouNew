"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createBug, updateBug } from "@/app/(admin)/bugs/actions";
import { bugPlatforms, bugPriorities, bugSeverities, bugStatuses, bugTextLimits, bugUuid, sameBugVersion, type BugFields, type BugRow } from "@/lib/bugs";
import { Button } from "@/components/ui/button";

const inputClass = "min-w-0 w-full rounded-md border border-border bg-background px-3 py-2 text-sm";
const blank = { title: "", description: "", severity: "low", priority: "low", status: "open", platform: "Admin", app_screen: "", steps_to_reproduce: "", expected_result: "", actual_result: "" } satisfies BugFields;
type Fields = { [K in keyof BugFields]: NonNullable<BugFields[K]> };
function fromRow(row: BugRow): Fields { return { title: row.title, description: row.description ?? "", severity: row.severity, priority: row.priority, status: row.status, platform: row.platform, app_screen: row.app_screen ?? "", steps_to_reproduce: row.steps_to_reproduce ?? "", expected_result: row.expected_result ?? "", actual_result: row.actual_result ?? "" }; }
const textLabels = { description: "Описание", steps_to_reproduce: "Шаги воспроизведения", expected_result: "Ожидаемый результат", actual_result: "Фактический результат" } as const;
function FieldsEditor({ value, change, disabled, readOnly = false, create = false }: { value: Fields; change: (next: Fields) => void; disabled: boolean; readOnly?: boolean; create?: boolean }) {
  function field(key: keyof Fields, next: string) { change({ ...value, [key]: next }); }
  return <fieldset disabled={disabled} className="min-w-0 grid gap-3 md:grid-cols-2">
    <label className="min-w-0">Название<input readOnly={readOnly} className={inputClass} name="title" required maxLength={bugTextLimits.title} value={value.title} onChange={e => field("title", e.target.value)} /></label>
    <label className="min-w-0">Экран приложения<input readOnly={readOnly} className={inputClass} name="app_screen" maxLength={bugTextLimits.app_screen} value={value.app_screen} onChange={e => field("app_screen", e.target.value)} /></label>
    <label className="min-w-0">Серьёзность<select disabled={readOnly} className={inputClass} name="severity" value={value.severity} onChange={e => field("severity", e.target.value)}>{Object.entries(bugSeverities).map(([key, label]) => <option key={key} value={key}>{label}</option>)}</select></label>
    <label className="min-w-0">Приоритет<select disabled={readOnly} className={inputClass} name="priority" value={value.priority} onChange={e => field("priority", e.target.value)}>{Object.entries(bugPriorities).map(([key, label]) => <option key={key} value={key}>{label}</option>)}</select></label>
    <label className="min-w-0">Платформа<select disabled={readOnly} className={inputClass} name="platform" value={value.platform} onChange={e => field("platform", e.target.value)}>{bugPlatforms.map(key => <option key={key} value={key}>{key}</option>)}</select></label>
    {create ? <input type="hidden" name="status" value="open" /> : <label className="min-w-0">Статус<select disabled={readOnly} className={inputClass} name="status" value={value.status} onChange={e => field("status", e.target.value)}>{Object.entries(bugStatuses).map(([key, label]) => <option key={key} value={key}>{label}</option>)}</select></label>}
    {Object.entries(textLabels).map(([key, label]) => <label key={key} className="min-w-0 md:col-span-2">{label}<textarea readOnly={readOnly} className={inputClass} name={key} maxLength={bugTextLimits[key as keyof typeof textLabels]} rows={3} value={value[key as keyof typeof textLabels]} onChange={e => field(key as keyof Fields, e.target.value)} /></label>)}
  </fieldset>;
}

function BugEditor({ initial, available }: { initial: BugRow; available: boolean }) {
  const router = useRouter();
  const [row, setRow] = useState(initial), [fields, setFields] = useState(() => fromRow(initial)), [busy, setBusy] = useState(false), [notice, setNotice] = useState<{ ok: boolean; text: string } | null>(null);
  const lastIncomingVersion = useRef(initial.updated_at);
  const [incoming, setIncoming] = useState<BugRow | null>(null);
  useEffect(() => {
    if (!sameBugVersion(initial.updated_at, lastIncomingVersion.current)) {
      lastIncomingVersion.current = initial.updated_at;
      setIncoming(sameBugVersion(initial.updated_at, row.updated_at) ? null : initial);
    }
  }, [initial, row.updated_at]);
  async function submit(form: FormData) {
    if (busy || !available || incoming !== null) return;
    setBusy(true); setNotice(null);
    try {
      const result = await updateBug(form);
      if (result.ok) { setRow(result.row); setFields(fromRow(result.row)); setIncoming(current => current && sameBugVersion(current.updated_at, result.row.updated_at) ? null : current); setNotice({ ok: true, text: "Сохранение подтверждено источником. Статус — ручная отметка оператора." }); }
      else setNotice({ ok: false, text: result.message });
    } catch { setNotice({ ok: false, text: "Результат неизвестен. Скопируйте черновик и перечитайте список перед повтором." }); }
    finally { setBusy(false); }
  }
  return <form action={submit} className="min-w-0 rounded-lg border border-border p-4 space-y-3 [overflow-wrap:anywhere]">
    <h3 className="min-w-0 break-words font-semibold">{row.title}</h3>
    <p className="break-all text-xs text-muted-foreground">ID {row.id} · версия {row.updated_at}</p>
    <input type="hidden" name="id" value={row.id} /><input type="hidden" name="updated_at" value={row.updated_at} />
    <FieldsEditor value={fields} change={v => { setFields(v); setNotice(null); }} disabled={busy} readOnly={!available} />
    <p className="break-all text-xs text-muted-foreground">Создана {row.created_at} · автор {row.created_by ?? "не указан"} · назначена {row.assigned_to ?? "не назначена"} · связанный скриншот {row.linked_screenshot_id ?? "не указан"}. Связи и автор сохраняются; эта форма их не меняет.</p>
    {incoming ? <div className="space-y-2 text-sm"><p role="alert">В перечитанном списке другая версия записи ({incoming.updated_at}). Ваш черновик и исходная версия сохранены. Скопируйте нужные изменения перед загрузкой версии из списка.</p><Button type="button" variant="outline" className="h-auto max-w-full whitespace-normal" disabled={busy || !available} onClick={() => { if (!available) return; setRow(incoming); setFields(fromRow(incoming)); setIncoming(null); setNotice(null); }}>Загрузить версию из списка (заменить черновик)</Button></div> : null}
    <div className="flex flex-wrap gap-2"><Button type="submit" disabled={busy || !available || incoming !== null}>{busy ? "Сохранение…" : "Сохранить ошибку"}</Button><Button type="button" variant="outline" disabled={busy} onClick={() => router.refresh()}>Перечитать список</Button></div>
    {notice && available ? <p role={notice.ok ? "status" : "alert"}>{notice.text}</p> : null}
  </form>;
}

export function BugManager({ rows, available, userId }: { rows: BugRow[]; available: boolean; userId: string }) {
  const router = useRouter();
  const [id, setId] = useState(""), [fields, setFields] = useState<Fields>(blank), [busy, setBusy] = useState(false), [notice, setNotice] = useState<{ ok: boolean; text: string } | null>(null), [localRows, setLocalRows] = useState(rows), [hasRead, setHasRead] = useState(available);
  const storageKey = `younew-bug-draft-v1:${userId}`;
  useEffect(() => { if (available) { setLocalRows(rows); setHasRead(true); } }, [rows, available]);
  useEffect(() => { let next = ""; try { next = localStorage.getItem(storageKey) ?? ""; } catch {} if (!bugUuid.test(next)) next = crypto.randomUUID(); setId(next); try { localStorage.setItem(storageKey, next); } catch {} }, [storageKey]);
  function changeId(value: string) { setId(value); setNotice(null); if (bugUuid.test(value)) { try { localStorage.setItem(storageKey, value); } catch {} } }
  async function submit(form: FormData) {
    if (busy || !available) return;
    setBusy(true); setNotice(null);
    try {
      const result = await createBug(form);
      if (result.ok) {
        setLocalRows(current => [result.row, ...current.filter(row => row.id !== result.row.id)]);
        setFields(blank); changeId(crypto.randomUUID());
        setNotice({ ok: true, text: result.replayed ? "Подтверждена ранее сохранённая ошибка; дубликат не создан." : "Ошибка создана со статусом «Открыта» и прочитана из источника." });
      } else setNotice({ ok: false, text: result.message });
    } catch { setNotice({ ok: false, text: "Результат неизвестен. Сохраните ID и повторите запрос с теми же данными." }); }
    finally { setBusy(false); }
  }
  return <div className="min-w-0 space-y-6 [overflow-wrap:anywhere]">
    <section className="rounded-lg border border-border p-4">
      {available ? <p className="text-sm text-muted-foreground">Прочитано записей: {localRows.length} (серверная выборка до 100). Это очередь ошибок Admin; отсутствие записей не подтверждает отсутствие ошибок продукта.</p> : <><h2>Источник ошибок недоступен</h2><p role="status">Количество и статусы неизвестны. Создание и сохранение отключены до успешного чтения источника.</p>{hasRead ? <p className="text-sm">Ниже оставлены последние прочитанные записи и ваши черновики для копирования; это не текущие данные источника.</p> : null}<Button type="button" variant="outline" onClick={() => router.refresh()}>Повторить чтение</Button></>}
      <p className="mt-2 text-sm">«Исправлена», «Проверена» и «Закрыта» — ручные отметки оператора. Сохранение не запускает автоматическое исправление, тестирование или проверку релиза. Не добавляйте пароли, токены и лишние персональные данные.</p>
    </section>
    {available || hasRead ? <form action={submit} className="min-w-0 rounded-lg border border-border p-4 space-y-3">
      <h2 className="font-semibold">Новая ошибка — открыта</h2>
      <label className="block min-w-0">ID повторной попытки<input className={inputClass} name="id" required value={id} onChange={e => changeId(e.target.value)} readOnly={busy || !available} /></label>
      <p className="text-xs text-muted-foreground">При неопределённом результате сохраните ID и исходные поля. Повтор с тем же ID проверяет ранее созданную запись. После полной перезагрузки страницы текст полей нужно восстановить вручную.</p>
      <FieldsEditor value={fields} change={v => { setFields(v); setNotice(null); }} disabled={busy} readOnly={!available} create />
      <Button type="submit" disabled={busy || !available || !bugUuid.test(id)}>{busy ? "Создание…" : "Создать ошибку"}</Button>
      {notice && available ? <p role={notice.ok ? "status" : "alert"}>{notice.text}</p> : null}
    </form> : null}
    <div className="min-w-0 space-y-6">
      {available && localRows.length === 0 ? <p>Источник прочитан: ошибок в выборке нет.</p> : null}
      {localRows.map(row => <BugEditor key={row.id} initial={row} available={available} />)}
    </div>
    <section aria-label="Статусы очереди">
      <h2 className="mb-3 font-semibold">Канбан по статусам</h2>
      <p className="mb-3 text-sm text-muted-foreground">Карточки и счётчики относятся только к последней прочитанной выборке, а не ко всем ошибкам продукта.</p>
      <div className="grid min-w-0 gap-3 sm:grid-cols-2 lg:grid-cols-5">{Object.entries(bugStatuses).map(([key, label]) => <section key={key} aria-label={`Статус: ${label}`} className="min-w-0 rounded-lg border border-border p-3">
        <div className="mb-3 flex items-center justify-between gap-2"><h3 className="font-semibold">{label}</h3><p>{available ? localRows.filter(row => row.status === key).length : "—"}</p></div>
        <div className="flex min-w-0 flex-col gap-2">{available ? localRows.filter(row => row.status === key).map(row => <article key={row.id} className="min-w-0 rounded-md border border-border bg-card p-3 text-sm [overflow-wrap:anywhere]"><p className="break-words font-medium">{row.title}</p><p className="mt-1 break-words text-xs text-muted-foreground">{row.platform} · {row.app_screen ?? "Экран не указан"}</p></article>) : <p className="text-xs text-muted-foreground">Карточки не показаны: источник недоступен; количество неизвестно.</p>}</div>
      </section>)}</div>
    </section>
  </div>;
}
