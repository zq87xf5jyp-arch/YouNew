"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createCategory, updateCategory } from "@/app/(admin)/categories/actions";
import { categoryStatuses, categoryUuid, type CategoryRow, type CategoryStatus } from "@/lib/categories";
import { Button } from "@/components/ui/button";

const inputClass = "w-full rounded-md border border-border bg-background px-3 py-2 text-sm";
const blank = { title: "", short_description: "", icon: "", color: "", priority: "0", status: "draft" as CategoryStatus };
type Fields = typeof blank;
function fromRow(row: CategoryRow): Fields { return { title: row.title, short_description: row.short_description ?? "", icon: row.icon ?? "", color: row.color ?? "", priority: String(row.priority), status: row.status }; }
function FieldsEditor({ value, change, canPublish, disabled, readOnly = false, create = false }: { value: Fields; change: (next: Fields) => void; canPublish: boolean; disabled: boolean; readOnly?: boolean; create?: boolean }) {
  function field(key: keyof Fields, next: string) { change({ ...value, [key]: next }); }
  return <fieldset disabled={disabled} className="grid gap-3 md:grid-cols-2">
    <label>Название<input readOnly={readOnly} className={inputClass} name="title" required maxLength={160} value={value.title} onChange={e => field("title", e.target.value)} /></label>
    <label>Порядок<input readOnly={readOnly} className={inputClass} name="priority" type="number" min={0} max={10000} required value={value.priority} onChange={e => field("priority", e.target.value)} /></label>
    <label className="md:col-span-2">Краткое описание<textarea readOnly={readOnly} className={inputClass} name="short_description" maxLength={1000} value={value.short_description} onChange={e => field("short_description", e.target.value)} /></label>
    <label>Код иконки<input readOnly={readOnly} className={inputClass} name="icon" maxLength={64} pattern={"[A-Za-z][A-Za-z0-9_\\-]*"} placeholder="House" value={value.icon} onChange={e => field("icon", e.target.value)} /></label>
    <label>Цвет (HEX)<input readOnly={readOnly} className={inputClass} name="color" maxLength={7} pattern="#[0-9a-fA-F]{6}" placeholder="#3b82f6" value={value.color} onChange={e => field("color", e.target.value)} /></label>
    {create ? <input type="hidden" name="status" value="draft" /> : <label>Статус<select disabled={readOnly} className={inputClass} name="status" value={value.status} onChange={e => field("status", e.target.value)}>{Object.entries(categoryStatuses).filter(([key]) => canPublish || key !== "published" || key === value.status).map(([key, label]) => <option key={key} value={key}>{label}</option>)}</select></label>}
  </fieldset>;
}

function CategoryEditor({ initial, canPublish, available }: { initial: CategoryRow; canPublish: boolean; available: boolean }) {
  const router = useRouter();
  const [row, setRow] = useState(initial), [fields, setFields] = useState(() => fromRow(initial)), [busy, setBusy] = useState(false), [notice, setNotice] = useState<{ ok: boolean; text: string } | null>(null);
  const lastIncomingVersion = useRef(initial.updated_at);
  const [incoming, setIncoming] = useState<CategoryRow | null>(null);
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
      const result = await updateCategory(form);
      if (result.ok) { setRow(result.row); setFields(fromRow(result.row)); setIncoming(current => current?.updated_at === result.row.updated_at ? null : current); setNotice({ ok: true, text: "Сохранение подтверждено источником." }); }
      else setNotice({ ok: false, text: result.message });
    } catch { setNotice({ ok: false, text: "Результат неизвестен. Скопируйте черновик и перечитайте список перед повтором." }); }
    finally { setBusy(false); }
  }
  return <form action={submit} className="rounded-lg border border-border p-4 space-y-3">
    <h3 className="break-words font-semibold">{row.title}</h3>
    <p className="break-all text-sm text-muted-foreground">Слаг: {row.slug} · версия {row.updated_at}{row.canonical_category_id ? " · каноническая связь сохранена" : ""}</p>
    <input type="hidden" name="id" value={row.id} /><input type="hidden" name="updated_at" value={row.updated_at} />
    <FieldsEditor value={fields} change={v => { setFields(v); setNotice(null); }} canPublish={canPublish && row.canonical_category_id === null} disabled={busy} readOnly={publicationLocked || !available} />
    {publicationLocked ? <p role="note" className="text-sm">В источнике опубликованная категория. Изменять её может только Owner/Admin. Ваш черновик сохранён в полях и доступен для копирования.</p> : null}
    {row.canonical_category_id ? <p className="text-sm">Исторический псевдоним: публикация запрещена, каноническая связь сохраняется.</p> : null}
    {publicEffect ? <p className="text-sm" role="note">Изменение опубликованной категории влияет на публичный API после обновления кэша. Статус «Опубликовано» не подтверждает синхронизацию приложения или сайта.</p> : null}
    {incoming ? <div className="space-y-2 text-sm"><p role="alert">В перечитанном списке другая версия записи ({incoming.updated_at}). Ваш черновик и его исходная версия сохранены. Скопируйте нужные изменения перед загрузкой версии из списка.</p><Button type="button" variant="outline" disabled={busy || !available} onClick={() => { if (!available) return; setRow(incoming); setFields(fromRow(incoming)); setIncoming(null); setNotice(null); }}>Загрузить версию из списка (заменить черновик)</Button></div> : null}
    <div className="flex flex-wrap gap-2"><Button type="submit" disabled={busy || !available || incoming !== null || publicationLocked}>{busy ? "Сохранение…" : publicEffect ? "Сохранить публичную категорию" : "Сохранить категорию"}</Button><Button type="button" variant="outline" disabled={busy} onClick={() => router.refresh()}>Перечитать список</Button></div>
    {notice && available ? <p role={notice.ok ? "status" : "alert"}>{notice.text}</p> : null}
  </form>;
}

export function CategoryManager({ rows, available, canEdit, canPublish, userId }: { rows: CategoryRow[]; available: boolean; canEdit: boolean; canPublish: boolean; userId: string }) {
  const router = useRouter(), createForm = useRef<HTMLFormElement>(null);
  const [id, setId] = useState(""), [slug, setSlug] = useState(""), [fields, setFields] = useState(blank), [busy, setBusy] = useState(false), [notice, setNotice] = useState<{ ok: boolean; text: string } | null>(null), [localRows, setLocalRows] = useState(rows), [hasRead, setHasRead] = useState(available);
  const storageKey = `younew-category-draft-v1:${userId}`;
  useEffect(() => { if (available) { setLocalRows(rows); setHasRead(true); } }, [rows, available]);
  useEffect(() => { if (!canEdit) return; let next = ""; try { next = localStorage.getItem(storageKey) ?? ""; } catch {} if (!categoryUuid.test(next)) next = crypto.randomUUID(); setId(next); try { localStorage.setItem(storageKey, next); } catch {} }, [storageKey, canEdit]);
  function changeId(value: string) { setId(value); setNotice(null); if (categoryUuid.test(value)) { try { localStorage.setItem(storageKey, value); } catch {} } }
  async function submit(form: FormData) {
    if (busy || !available) return;
    setBusy(true); setNotice(null);
    try {
      const result = await createCategory(form);
      if (result.ok) {
        setLocalRows(current => [result.row, ...current.filter(row => row.id !== result.row.id)]);
        setFields(blank); setSlug(""); createForm.current?.reset(); changeId(crypto.randomUUID());
        setNotice({ ok: true, text: result.replayed ? "Подтверждён ранее сохранённый черновик; дубликат не создан." : "Черновик сохранён и прочитан из источника." });
      } else setNotice({ ok: false, text: result.message });
    } catch { setNotice({ ok: false, text: "Результат неизвестен. Сохраните ID и повторите запрос с теми же данными." }); }
    finally { setBusy(false); }
  }
  return <div className="space-y-6">
    <section className="rounded-lg border border-border p-4">
      {available ? <p className="text-sm text-muted-foreground">Прочитано записей: {localRows.length} (серверная выборка до 100). Это категории базы Admin. Публичный API отдаёт только published; packaged dataset приложения и сайта не обновляется этой формой автоматически.</p> : <><h2>Категории недоступны</h2><p role="status">Количество и статусы неизвестны. Создание и сохранение отключены до успешного чтения источника.</p>{hasRead ? <p className="text-sm">Ниже оставлены последние прочитанные записи и ваши черновики для копирования; это не текущие данные источника.</p> : null}<Button type="button" variant="outline" onClick={() => router.refresh()}>Повторить чтение</Button></>}
    </section>
    {canEdit && (available || hasRead) ? <form ref={createForm} action={submit} className="rounded-lg border border-border p-4 space-y-3">
      <h2 className="font-semibold">Новая категория — черновик</h2>
      <label className="block">ID повторной попытки<input className={inputClass} name="id" required value={id} onChange={e => changeId(e.target.value)} readOnly={busy || !available} /></label>
      <p className="text-xs text-muted-foreground">При неопределённом результате сохраните этот ID и исходные поля. Повтор с тем же ID не создаёт новую запись. После перезагрузки текст полей нужно восстановить вручную.</p>
      <label className="block">Слаг<input className={inputClass} name="slug" required maxLength={80} pattern="[a-z0-9]+(-[a-z0-9]+)*" placeholder="new-category" readOnly={busy || !available} value={slug} onChange={e => { setSlug(e.target.value); setNotice(null); }} /></label>
      <FieldsEditor value={fields} change={v => { setFields(v); setNotice(null); }} canPublish={false} disabled={busy} readOnly={!available} create />
      <Button type="submit" disabled={busy || !available || !categoryUuid.test(id)}>{busy ? "Сохранение…" : "Создать черновик"}</Button>
      {notice && available ? <p role={notice.ok ? "status" : "alert"}>{notice.text}</p> : null}
    </form> : !canEdit ? <p>Режим просмотра. Изменять категории могут Owner/Admin/Editor; опубликованные — Owner/Admin.</p> : null}
    <div className="space-y-6">
    {available && localRows.length === 0 ? <p>Источник прочитан: категорий в выборке нет.</p> : null}
    {localRows.map(row => canEdit ? <CategoryEditor key={row.id} initial={row} canPublish={canPublish} available={available} /> : <article key={row.id} className="break-words rounded-lg border border-border p-4"><h3 className="break-words font-semibold">{row.title}</h3><p className="break-all">{row.slug} · {categoryStatuses[row.status]} · порядок {row.priority}</p><p>{row.short_description}</p><p className="text-sm text-muted-foreground">Иконка {row.icon ?? "—"} · цвет {row.color ?? "—"} · версия {row.updated_at}</p></article>)}
    </div>
  </div>;
}
