"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createMapPoint, updateMapPoint } from "@/app/(admin)/map/actions";
import { mapPointStatuses, mapPointTypes, mapPointUuid, type MapPointRow, type MapPointStatus, type MapPointType, type MapPointApiMode } from "@/lib/map-points";
import { Button } from "@/components/ui/button";

const inputClass = "w-full rounded-md border border-border bg-background px-3 py-2 text-sm";
const blank = { title: "", type: "custom" as MapPointType, latitude: "", longitude: "", city: "", province: "", description: "", source_url: "", icon: "", color: "", status: "draft" as MapPointStatus };
type Fields = typeof blank;
function fromRow(row: MapPointRow): Fields { return { title: row.title, type: row.type, latitude: row.latitude.toFixed(6), longitude: row.longitude.toFixed(6), city: row.city ?? "", province: row.province ?? "", description: row.description ?? "", source_url: row.source_url ?? "", icon: row.icon ?? "", color: row.color ?? "", status: row.status }; }
function publicationImpact(mode: MapPointApiMode) {
  return mode === "database"
    ? "Статус «Опубликовано» делает запись доступной через существующий публичный API Admin после обновления кэша. Сайт и приложение этой формой автоматически не обновляются."
    : "Это отдельная запись базы Admin. Канонический публичный map API использует упакованный набор ниже; эта форма не изменяет его, сайт или приложение автоматически.";
}
function FieldsEditor({ value, change, canPublish, disabled, readOnly = false, create = false }: { value: Fields; change: (next: Fields) => void; canPublish: boolean; disabled: boolean; readOnly?: boolean; create?: boolean }) {
  function field(key: keyof Fields, next: string) { change({ ...value, [key]: next }); }
  return <fieldset disabled={disabled} className="grid gap-3 md:grid-cols-2">
    <label>Название<input readOnly={readOnly} className={inputClass} name="title" required maxLength={160} value={value.title} onChange={e => field("title", e.target.value)} /></label>
    <label>Тип<select disabled={readOnly} className={inputClass} name="type" value={value.type} onChange={e => field("type", e.target.value)}>{Object.entries(mapPointTypes).map(([key, label]) => <option key={key} value={key}>{label}</option>)}</select></label>
    <label>Широта<input readOnly={readOnly} className={inputClass} name="latitude" required inputMode="decimal" maxLength={12} placeholder="52.367600" value={value.latitude} onChange={e => field("latitude", e.target.value)} /></label>
    <label>Долгота<input readOnly={readOnly} className={inputClass} name="longitude" required inputMode="decimal" maxLength={12} placeholder="4.904100" value={value.longitude} onChange={e => field("longitude", e.target.value)} /></label>
    <p className="text-xs text-muted-foreground md:col-span-2">Широта −90…90, долгота −180…180; десятичная точка и до 6 знаков после неё. Совпадающие координаты разрешены.</p>
    <label>Город<input readOnly={readOnly} className={inputClass} name="city" maxLength={160} value={value.city} onChange={e => field("city", e.target.value)} /></label>
    <label>Провинция<input readOnly={readOnly} className={inputClass} name="province" maxLength={160} value={value.province} onChange={e => field("province", e.target.value)} /></label>
    <label className="md:col-span-2">Описание<textarea readOnly={readOnly} className={inputClass} name="description" maxLength={4000} value={value.description} onChange={e => field("description", e.target.value)} /></label>
    <label className="md:col-span-2">Ссылка на источник<input readOnly={readOnly} className={inputClass} name="source_url" type="url" maxLength={2000} placeholder="https://example.com/" value={value.source_url} onChange={e => field("source_url", e.target.value)} /></label>
    <label>Код иконки<input readOnly={readOnly} className={inputClass} name="icon" maxLength={64} placeholder="MapPin" value={value.icon} onChange={e => field("icon", e.target.value)} /></label>
    <label>Цвет (HEX)<input readOnly={readOnly} className={inputClass} name="color" maxLength={7} placeholder="#38bdf8" value={value.color} onChange={e => field("color", e.target.value)} /></label>
    {create ? <input type="hidden" name="status" value="draft" /> : <label>Статус<select disabled={readOnly} className={inputClass} name="status" value={value.status} onChange={e => field("status", e.target.value)}>{Object.entries(mapPointStatuses).filter(([key]) => canPublish || key !== "published" || key === value.status).map(([key, label]) => <option key={key} value={key}>{label}</option>)}</select></label>}
  </fieldset>;
}

function MapPointEditor({ initial, canPublish, apiMode, available }: { initial: MapPointRow; canPublish: boolean; apiMode: MapPointApiMode; available: boolean }) {
  const router = useRouter();
  const [row, setRow] = useState(initial), [fields, setFields] = useState(() => fromRow(initial)), [busy, setBusy] = useState(false), [notice, setNotice] = useState<{ ok: boolean; text: string } | null>(null);
  const lastIncomingVersion = useRef(initial.updated_at);
  const [incoming, setIncoming] = useState<MapPointRow | null>(null);
  useEffect(() => {
    if (initial.updated_at !== lastIncomingVersion.current) {
      lastIncomingVersion.current = initial.updated_at;
      setIncoming(initial.updated_at === row.updated_at ? null : initial);
    }
  }, [initial, row.updated_at]);
  const publicEffect = row.status === "published" || fields.status === "published";
  const publicationLocked = !canPublish && (row.status === "published" || initial.status === "published");
  async function submit(form: FormData) {
    if (busy || !available || publicationLocked || incoming !== null) return;
    setBusy(true); setNotice(null);
    try {
      const result = await updateMapPoint(form);
      if (result.ok) { setRow(result.row); setFields(fromRow(result.row)); setIncoming(current => current?.updated_at === result.row.updated_at ? null : current); setNotice({ ok: true, text: "Сохранение подтверждено источником." }); }
      else setNotice({ ok: false, text: result.message });
    } catch { setNotice({ ok: false, text: "Результат неизвестен. Скопируйте черновик и перечитайте список перед повтором." }); }
    finally { setBusy(false); }
  }
  return <form action={submit} className="rounded-lg border border-border p-4 space-y-3">
    <h3 className="break-words font-semibold">{row.title}</h3>
    <p className="break-all text-xs text-muted-foreground">ID {row.id} · версия {row.updated_at}</p>
    <input type="hidden" name="id" value={row.id} /><input type="hidden" name="updated_at" value={row.updated_at} />
    <FieldsEditor value={fields} change={v => { setFields(v); setNotice(null); }} canPublish={canPublish} disabled={busy} readOnly={publicationLocked || !available} />
    {publicationLocked ? <p role="note" className="text-sm">В источнике опубликованная точка. Изменять её может только Owner/Admin. Ваш черновик сохранён в полях и доступен для копирования.</p> : null}
    {publicEffect ? <p className="text-sm" role="note">{publicationImpact(apiMode)} Опубликованные поля доступны публично: не добавляйте приватные заметки.</p> : null}
    {incoming ? <div className="space-y-2 text-sm"><p role="alert">В перечитанном списке другая версия записи ({incoming.updated_at}). Ваш черновик и его исходная версия сохранены. Скопируйте нужные изменения перед загрузкой версии из списка.</p><Button type="button" variant="outline" disabled={busy || !available} onClick={() => { if (!available) return; setRow(incoming); setFields(fromRow(incoming)); setIncoming(null); setNotice(null); }}>Загрузить версию из списка (заменить черновик)</Button></div> : null}
    <div className="flex flex-wrap gap-2"><Button type="submit" disabled={busy || !available || incoming !== null || publicationLocked}>{busy ? "Сохранение…" : publicEffect ? "Сохранить опубликованную точку" : "Сохранить точку"}</Button><Button type="button" variant="outline" disabled={busy} onClick={() => router.refresh()}>Перечитать список</Button></div>
    {notice && available ? <p role={notice.ok ? "status" : "alert"}>{notice.text}</p> : null}
  </form>;
}

export function MapPointManager({ rows, available, canEdit, canPublish, userId, apiMode }: { rows: MapPointRow[]; available: boolean; canEdit: boolean; canPublish: boolean; userId: string; apiMode: MapPointApiMode }) {
  const router = useRouter();
  const [id, setId] = useState(""), [fields, setFields] = useState(blank), [busy, setBusy] = useState(false), [notice, setNotice] = useState<{ ok: boolean; text: string } | null>(null), [localRows, setLocalRows] = useState(rows), [hasRead, setHasRead] = useState(available);
  const storageKey = `younew-map-point-draft-v1:${userId}`;
  useEffect(() => { if (available) { setLocalRows(rows); setHasRead(true); } }, [rows, available]);
  useEffect(() => { if (!canEdit) return; let next = ""; try { next = localStorage.getItem(storageKey) ?? ""; } catch {} if (!mapPointUuid.test(next)) next = crypto.randomUUID(); setId(next); try { localStorage.setItem(storageKey, next); } catch {} }, [storageKey, canEdit]);
  function changeId(value: string) { setId(value); setNotice(null); if (mapPointUuid.test(value)) { try { localStorage.setItem(storageKey, value); } catch {} } }
  async function submit(form: FormData) {
    if (busy || !available) return;
    setBusy(true); setNotice(null);
    try {
      const result = await createMapPoint(form);
      if (result.ok) {
        setLocalRows(current => [result.row, ...current.filter(row => row.id !== result.row.id)]);
        setFields(blank); changeId(crypto.randomUUID());
        setNotice({ ok: true, text: result.replayed ? "Подтверждён ранее сохранённый черновик; дубликат не создан." : "Черновик сохранён и прочитан из источника." });
      } else setNotice({ ok: false, text: result.message });
    } catch { setNotice({ ok: false, text: "Результат неизвестен. Сохраните ID и повторите запрос с теми же данными." }); }
    finally { setBusy(false); }
  }
  return <div className="space-y-6">
    <section className="rounded-lg border border-border p-4">
      {available ? <p className="text-sm text-muted-foreground">Прочитано записей: {localRows.length} (серверная выборка до 100). {publicationImpact(apiMode)}</p> : <><h2>Точки карты недоступны</h2><p role="status">Количество и статусы неизвестны. Создание и сохранение отключены до успешного чтения источника.</p>{hasRead ? <p className="text-sm">Ниже оставлены последние прочитанные записи и ваши черновики для копирования; это не текущие данные источника.</p> : null}<Button type="button" variant="outline" onClick={() => router.refresh()}>Повторить чтение</Button></>}
    </section>
    {canEdit && (available || hasRead) ? <form action={submit} className="rounded-lg border border-border p-4 space-y-3">
      <h2 className="font-semibold">Новая точка — черновик</h2>
      <label className="block">ID повторной попытки<input className={inputClass} name="id" required value={id} onChange={e => changeId(e.target.value)} readOnly={busy || !available} /></label>
      <p className="text-xs text-muted-foreground">При неопределённом результате сохраните этот ID и исходные поля. Повтор с тем же ID не создаёт новую запись. После перезагрузки текст полей нужно восстановить вручную.</p>
      <FieldsEditor value={fields} change={v => { setFields(v); setNotice(null); }} canPublish={false} disabled={busy} readOnly={!available} create />
      <Button type="submit" disabled={busy || !available || !mapPointUuid.test(id)}>{busy ? "Сохранение…" : "Создать черновик"}</Button>
      {notice && available ? <p role={notice.ok ? "status" : "alert"}>{notice.text}</p> : null}
    </form> : !canEdit ? <p>Режим просмотра. Изменять точки могут Owner/Admin/Editor; опубликованные — Owner/Admin.</p> : null}
    <div className="space-y-6">
    {available && localRows.length === 0 ? <p>Источник прочитан: точек в выборке нет.</p> : null}
    {localRows.map(row => canEdit ? <MapPointEditor key={row.id} initial={row} canPublish={canPublish} apiMode={apiMode} available={available} /> : <article key={row.id} className="rounded-lg border border-border p-4"><h3 className="break-words font-semibold">{row.title}</h3><p>{mapPointTypes[row.type]} · {mapPointStatuses[row.status]} · {row.latitude}, {row.longitude}</p><p>{row.city} {row.province}</p><p>{row.description}</p><p className="break-all text-sm">{row.source_url}</p><p className="text-xs text-muted-foreground">Иконка {row.icon ?? "—"} · цвет {row.color ?? "—"} · версия {row.updated_at}</p>{canEdit && row.status === "published" ? <p>Изменения опубликованной точки доступны Owner/Admin.</p> : null}</article>)}
    </div>
  </div>;
}
