"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createCity, updateCity } from "@/app/(admin)/cities/actions";
import { cityProvinces, cityStatuses, cityUuid, type CityRow, type CityStatus } from "@/lib/cities";
import { Button } from "@/components/ui/button";

const inputClass = "w-full rounded-md border border-border bg-background px-3 py-2 text-sm";
const blank = { name: "", province: "", description: "", lat: "", lng: "", municipality_link: "", transport_notes: "", status: "draft" as CityStatus };
type Fields = typeof blank;
function fromRow(row: CityRow): Fields { return { name: row.name, province: row.province, description: row.description ?? "", lat: row.lat === null ? "" : String(row.lat), lng: row.lng === null ? "" : String(row.lng), municipality_link: row.municipality_link ?? "", transport_notes: row.transport_notes ?? "", status: row.status }; }
function FieldsEditor({ value, change, canPublish, disabled, readOnly = false, create = false }: { value: Fields; change: (next: Fields) => void; canPublish: boolean; disabled: boolean; readOnly?: boolean; create?: boolean }) {
  function field(key: keyof Fields, next: string) { change({ ...value, [key]: next }); }
  return <fieldset disabled={disabled} className="grid gap-3 md:grid-cols-2">
    <label>Название города<input className={inputClass} name="name" required maxLength={160} readOnly={readOnly} value={value.name} onChange={e => field("name", e.target.value)} /></label>
    <label>Провинция<select className={inputClass} name="province" required disabled={readOnly} value={value.province} onChange={e => field("province", e.target.value)}><option value="">Выберите провинцию</option>{cityProvinces.map(province => <option key={province}>{province}</option>)}</select></label>
    <label className="md:col-span-2">Описание<textarea className={inputClass} name="description" maxLength={5000} readOnly={readOnly} value={value.description} onChange={e => field("description", e.target.value)} /></label>
    <label>Широта<input className={inputClass} name="lat" type="number" step="0.000001" min={-90} max={90} readOnly={readOnly} value={value.lat} onChange={e => field("lat", e.target.value)} /></label>
    <label>Долгота<input className={inputClass} name="lng" type="number" step="0.000001" min={-180} max={180} readOnly={readOnly} value={value.lng} onChange={e => field("lng", e.target.value)} /></label>
    <p className="text-xs text-muted-foreground md:col-span-2">Координаты вводятся парой, до 6 знаков после точки. Оставьте оба поля пустыми, если положение неизвестно.</p>
    <label className="md:col-span-2">Ссылка муниципалитета<input className={inputClass} name="municipality_link" type="url" maxLength={2048} readOnly={readOnly} placeholder="https://gemeente.leiden.nl/" value={value.municipality_link} onChange={e => field("municipality_link", e.target.value)} /></label>
    <label className="md:col-span-2">Транспортные заметки<textarea className={inputClass} name="transport_notes" maxLength={3000} readOnly={readOnly} value={value.transport_notes} onChange={e => field("transport_notes", e.target.value)} /></label>
    {create ? <input type="hidden" name="status" value="draft" /> : <label>Статус<select className={inputClass} name="status" disabled={readOnly} value={value.status} onChange={e => field("status", e.target.value)}>{Object.entries(cityStatuses).filter(([key]) => canPublish || key !== "published" || key === value.status).map(([key, label]) => <option key={key} value={key}>{label}</option>)}</select></label>}
  </fieldset>;
}
function CityEditor({ initial, canPublish, sourceAvailable }: { initial: CityRow; canPublish: boolean; sourceAvailable: boolean }) {
  const router = useRouter();
  const [row, setRow] = useState(initial), [fields, setFields] = useState(() => fromRow(initial)), [busy, setBusy] = useState(false), [notice, setNotice] = useState<{ ok: boolean; text: string } | null>(null);
  const retiredVersions = useRef(new Set<string>());
  const dirty = JSON.stringify(fields) !== JSON.stringify(fromRow(row));
  const incomingChanged = initial.updated_at !== row.updated_at && !retiredVersions.current.has(initial.updated_at);
  const publicationLocked = !canPublish && (initial.status === "published" || row.status === "published");
  const writesLocked = publicationLocked || !sourceAvailable;
  const publicEffect = initial.status === "published" || row.status === "published" || fields.status === "published";
  useEffect(() => {
    if (!sourceAvailable || !incomingChanged || dirty || busy) return;
    retiredVersions.current.add(row.updated_at);
    setRow(initial); setFields(fromRow(initial)); setNotice(null);
  }, [initial, incomingChanged, dirty, busy, row.updated_at, sourceAvailable]);
  async function submit(form: FormData) {
    if (writesLocked || incomingChanged) return;
    if (busy) return; setBusy(true); setNotice(null);
    try { const result = await updateCity(form); if (result.ok) { retiredVersions.current.add(row.updated_at); retiredVersions.current.add(initial.updated_at); setRow(result.row); setFields(fromRow(result.row)); setNotice({ ok: true, text: "Сохранение подтверждено источником." }); } else setNotice({ ok: false, text: result.message }); }
    catch { setNotice({ ok: false, text: "Результат неизвестен. Скопируйте черновик и перечитайте список перед повтором." }); }
    finally { setBusy(false); }
  }
  return <form action={submit} className="rounded-lg border border-border p-4 space-y-3">
    <h3 className="break-words font-semibold">{row.name}</h3><p className="break-all text-sm text-muted-foreground">Слаг: {row.slug} · версия {row.updated_at}</p>
    <input type="hidden" name="id" value={row.id} /><input type="hidden" name="updated_at" value={row.updated_at} />
    <FieldsEditor value={fields} change={v => { setFields(v); setNotice(null); }} canPublish={canPublish} disabled={busy} readOnly={writesLocked} />
    {incomingChanged ? <div role="alert"><p>В источнике появилась новая версия. Ваш черновик сохранён в форме; скопируйте нужный текст перед заменой.</p><Button type="button" variant="outline" disabled={busy || !sourceAvailable} onClick={() => { retiredVersions.current.add(row.updated_at); setRow(initial); setFields(fromRow(initial)); setNotice(null); }}>Заменить черновик данными источника</Button></div> : null}
    {publicationLocked ? <p role="note">Город опубликован. Сохранение доступно Owner/Admin; ваш текст остаётся доступным для копирования.</p> : null}
    <p className="text-xs text-muted-foreground">Слаг, обложка, экстренные контакты и дополнительные ссылки не изменяются этой формой.</p>
    {publicEffect ? <p className="text-sm" role="note">Изменения опубликованного города станут доступны через публичный API после обновления кэша. Страницы сайта и приложение требуют отдельного выпуска.</p> : null}
    <div className="flex flex-wrap gap-2"><Button type="submit" disabled={busy || writesLocked || incomingChanged}>{busy ? "Сохранение…" : publicEffect ? "Сохранить публичный город" : "Сохранить город"}</Button><Button type="button" variant="outline" disabled={busy} onClick={() => router.refresh()}>Перечитать список</Button></div>
    {notice ? <p role={notice.ok ? "status" : "alert"}>{notice.text}</p> : null}
  </form>;
}
export function CityManager({ rows, available, canEdit, canPublish, userId }: { rows: CityRow[]; available: boolean; canEdit: boolean; canPublish: boolean; userId: string }) {
  const router = useRouter(), createForm = useRef<HTMLFormElement>(null);
  const [id, setId] = useState(""), [slug, setSlug] = useState(""), [fields, setFields] = useState(blank), [busy, setBusy] = useState(false), [notice, setNotice] = useState<{ ok: boolean; text: string } | null>(null), [localRows, setLocalRows] = useState(available ? rows : []), [hasLoaded, setHasLoaded] = useState(available);
  const storageKey = `younew-city-draft-v1:${userId}`;
  useEffect(() => { if (available) { setLocalRows(rows); setHasLoaded(true); } }, [rows, available]);
  useEffect(() => { if (!canEdit) return; let next = ""; try { next = localStorage.getItem(storageKey) ?? ""; } catch {} if (!cityUuid.test(next)) next = crypto.randomUUID(); setId(next); try { localStorage.setItem(storageKey, next); } catch {} }, [storageKey, canEdit]);
  function changeId(value: string) { setId(value); setNotice(null); if (cityUuid.test(value)) { try { localStorage.setItem(storageKey, value); } catch {} } }
  async function submit(form: FormData) {
    if (!available) return;
    if (busy) return; setBusy(true); setNotice(null);
    try { const result = await createCity(form); if (result.ok) { setLocalRows(current => [result.row, ...current.filter(row => row.id !== result.row.id)]); setFields(blank); setSlug(""); createForm.current?.reset(); changeId(crypto.randomUUID()); setNotice({ ok: true, text: result.replayed ? "Подтверждён ранее сохранённый черновик; дубликат не создан." : "Черновик сохранён и прочитан из источника." }); } else setNotice({ ok: false, text: result.message }); }
    catch { setNotice({ ok: false, text: "Результат неизвестен. Сохраните ID и повторите запрос с теми же данными." }); }
    finally { setBusy(false); }
  }
  return <div className="space-y-6">
    {!available ? <section className="rounded-lg border border-border p-4"><h2>Города недоступны</h2><p role="status">Количество и статусы неизвестны. Создание и сохранение отключены до успешного чтения источника.</p>{hasLoaded ? <p>Ниже — последнее успешное чтение и ваши черновики. Текст доступен для копирования; актуальность данных не подтверждена.</p> : null}<Button type="button" variant="outline" onClick={() => router.refresh()}>Повторить чтение</Button></section> : <p className="text-sm text-muted-foreground">Прочитано городов: {localRows.length} (выборка до 100). Публичный API отдаёт только опубликованные записи. Сохранение здесь не обновляет страницы сайта и приложение автоматически.</p>}
    {canEdit && hasLoaded ? <form ref={createForm} action={submit} className="rounded-lg border border-border p-4 space-y-3">
      <h2 className="font-semibold">Новый город — черновик</h2>
      <label className="block">ID повторной попытки<input className={inputClass} name="id" required value={id} onChange={e => changeId(e.target.value)} readOnly={busy || !available} /></label>
      <p className="text-xs text-muted-foreground">При неизвестном результате сохраните ID и исходные поля. Повтор с тем же ID не создаёт новую запись. После перезагрузки текст полей нужно восстановить вручную.</p>
      <label className="block">Слаг<input className={inputClass} name="slug" required maxLength={80} pattern="[a-z0-9]+(-[a-z0-9]+)*" placeholder="new-city" readOnly={busy || !available} value={slug} onChange={e => { setSlug(e.target.value); setNotice(null); }} /></label>
      <FieldsEditor value={fields} change={v => { setFields(v); setNotice(null); }} canPublish={false} disabled={busy} readOnly={!available} create />
      <Button type="submit" disabled={busy || !available || !cityUuid.test(id)}>{busy ? "Сохранение…" : "Создать черновик города"}</Button>
      {notice ? <p role={notice.ok ? "status" : "alert"}>{notice.text}</p> : null}
    </form> : !canEdit ? <p>Режим просмотра. Города редактируют Owner/Admin/Editor; опубликованные — Owner/Admin.</p> : null}
    {available && localRows.length === 0 ? <p>Источник прочитан: городов в выборке нет.</p> : localRows.map(row => canEdit ? <CityEditor key={row.id} initial={row} canPublish={canPublish} sourceAvailable={available} /> : <article key={row.id} className="rounded-lg border border-border p-4"><h3 className="break-words font-semibold">{row.name}</h3><p className="break-all">{row.slug} · {row.province} · {cityStatuses[row.status]}</p><p>{row.description}</p><p>Координаты: {row.lat ?? "неизвестно"}, {row.lng ?? "неизвестно"}</p><p className="break-all">{row.municipality_link}</p><p>{row.transport_notes}</p><p className="text-sm text-muted-foreground">Версия {row.updated_at}</p></article>)}
  </div>;
}
