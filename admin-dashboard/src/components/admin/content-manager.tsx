"use client";

import { useEffect, useMemo, useState } from "react";
import { Download, Edit, Plus, RotateCcw, Save, Search, Trash2, X } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ContentImageUploader } from "@/components/admin/content-image-uploader";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectGroup, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { slugify } from "@/lib/utils";
import type { ManagedContentImage } from "@/lib/content-images";
import { createArticle, deleteArticle as deleteRemoteArticle, updateArticle } from "@/app/(admin)/content/actions";

type ArticleStatus = "draft" | "review" | "published" | "archived";

export type ManagedArticle = {
  id: string;
  title: string;
  slug: string;
  category: string;
  language: string;
  status: ArticleStatus;
  priority: number;
  description?: string;
  content?: string;
  source?: string;
  tags?: string;
  images: ManagedContentImage[];
  updatedAt?: string;
};

type ArticleDraft = Omit<ManagedArticle, "id" | "updatedAt">;

const storageKey = "younew-admin-articles-v1";

const emptyDraft: ArticleDraft = {
  title: "",
  slug: "",
  category: "documents-services",
  language: "ru",
  status: "draft",
  priority: 1,
  description: "",
  content: "",
  source: "",
  tags: "",
  images: []
};

const categoryLabels: Record<string, string> = {
  "documents-services": "Документы и сервисы",
  transport: "Транспорт",
  housing: "Жильё",
  healthcare: "Здравоохранение",
  education: "Образование",
  government: "Государственные сервисы"
};

const statusLabels: Record<ArticleStatus, string> = {
  draft: "черновик",
  review: "на проверке",
  published: "опубликовано",
  archived: "архив"
};

export function ContentManager({ initialRows, supabaseEnabled, canEdit }: { initialRows: ManagedArticle[]; supabaseEnabled: boolean; canEdit: boolean }) {
  const [rows, setRows] = useState(initialRows);
  const [draft, setDraft] = useState<ArticleDraft>(emptyDraft);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [query, setQuery] = useState("");
  const [notice, setNotice] = useState("");
  const [ready, setReady] = useState(false);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (supabaseEnabled) {
      setReady(true);
      return;
    }
    const saved = window.localStorage.getItem(storageKey);
    if (saved) {
      try {
        const parsed = JSON.parse(saved) as ManagedArticle[];
        if (Array.isArray(parsed)) setRows(parsed.map((row) => ({ ...row, images: Array.isArray(row.images) ? row.images : [] })));
      } catch {
        window.localStorage.removeItem(storageKey);
      }
    }
    setReady(true);
  }, [supabaseEnabled]);

  useEffect(() => {
    if (ready && !supabaseEnabled) window.localStorage.setItem(storageKey, JSON.stringify(rows));
  }, [ready, rows, supabaseEnabled]);

  const filteredRows = useMemo(() => {
    const normalized = query.trim().toLocaleLowerCase("ru");
    if (!normalized) return rows;
    return rows.filter((row) =>
      [row.title, row.slug, categoryLabels[row.category] ?? row.category, row.language, statusLabels[row.status]]
        .join(" ")
        .toLocaleLowerCase("ru")
        .includes(normalized)
    );
  }, [query, rows]);

  function updateDraft<K extends keyof ArticleDraft>(key: K, value: ArticleDraft[K]) {
    setDraft((current) => ({ ...current, [key]: value }));
  }

  function resetForm() {
    setDraft(emptyDraft);
    setEditingId(null);
  }

  async function submitArticle(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!draft.title.trim() || !draft.slug.trim()) {
      setNotice("Заполните название и слаг.");
      return;
    }

    setSaving(true);
    try {
      const updatedAt = new Date().toISOString();
      if (editingId) {
        const article = supabaseEnabled
          ? await updateArticle(editingId, draft)
          : { ...draft, id: editingId, updatedAt };
        setRows((current) => current.map((row) => row.id === editingId ? article : row));
        setNotice(supabaseEnabled ? "Материал обновлён в Supabase." : "Материал обновлён и сохранён локально.");
      } else {
        const article = supabaseEnabled
          ? await createArticle(draft)
          : { ...draft, id: crypto.randomUUID(), updatedAt };
        setRows((current) => [article, ...current]);
        setNotice(supabaseEnabled ? "Материал создан в Supabase." : "Материал создан и сохранён локально.");
      }
      resetForm();
    } catch (error) {
      setNotice(error instanceof Error ? error.message : "Не удалось сохранить материал.");
    } finally {
      setSaving(false);
    }
  }

  function editArticle(article: ManagedArticle) {
    setDraft({
      title: article.title,
      slug: article.slug,
      category: article.category,
      language: article.language,
      status: article.status,
      priority: article.priority,
      description: article.description ?? "",
      content: article.content ?? "",
      source: article.source ?? "",
      tags: article.tags ?? "",
      images: article.images ?? []
    });
    setEditingId(article.id);
    setNotice("");
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  async function deleteArticle(article: ManagedArticle) {
    if (!window.confirm(`Удалить «${article.title}»?`)) return;
    setSaving(true);
    try {
      const result = supabaseEnabled ? await deleteRemoteArticle(article.id) : null;
      setRows((current) => current.filter((row) => row.id !== article.id));
      if (editingId === article.id) resetForm();
      setNotice(result?.cleanupWarning ?? (supabaseEnabled ? "Материал и его изображения удалены из Supabase." : "Материал удалён."));
    } catch (error) {
      setNotice(error instanceof Error ? error.message : "Не удалось удалить материал.");
    } finally {
      setSaving(false);
    }
  }

  function restoreInitialRows() {
    if (!window.confirm("Восстановить исходные демонстрационные материалы?")) return;
    setRows(initialRows);
    resetForm();
    setNotice("Исходные материалы восстановлены.");
  }

  function exportJson() {
    const blob = new Blob([JSON.stringify(rows, null, 2)], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement("a");
    anchor.href = url;
    anchor.download = `younew-content-${new Date().toISOString().slice(0, 10)}.json`;
    anchor.click();
    URL.revokeObjectURL(url);
    setNotice("JSON подготовлен для скачивания.");
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-cyan-400/20 bg-cyan-400/10 px-4 py-3">
        <div>
          <p className="text-sm font-semibold text-cyan-100">{supabaseEnabled ? "Supabase подключён" : "Рабочий локальный режим"}</p>
          <p className="text-xs text-muted-foreground">{supabaseEnabled ? "Материалы централизованно сохраняются в защищённой базе данных." : "Добавьте параметры Supabase — до этого изменения сохраняются только в этом браузере."}</p>
        </div>
        <div className="flex flex-wrap gap-2">
          {!supabaseEnabled && <Button type="button" variant="outline" size="sm" onClick={restoreInitialRows}>
            <RotateCcw className="size-4" /> Восстановить
          </Button>}
          <Button type="button" size="sm" onClick={exportJson}>
            <Download className="size-4" /> Экспорт JSON
          </Button>
        </div>
      </div>

      <div className="grid gap-6 xl:grid-cols-[1fr_0.9fr]">
        <Card>
          <CardHeader>
            <div className="flex flex-wrap items-start justify-between gap-4">
              <div>
                <CardTitle>Статьи и гайды</CardTitle>
                <CardDescription>{rows.length} материалов · показано {filteredRows.length}</CardDescription>
              </div>
              {canEdit && <Button type="button" size="sm" onClick={resetForm}>
                <Plus className="size-4" /> Новый материал
              </Button>}
            </div>
            <div className="relative pt-2">
              <Search className="absolute left-3 top-5 size-4 text-muted-foreground" />
              <Input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Поиск по названию, категории или статусу" className="pl-9" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="younew-table">
                <thead><tr><th>Название</th><th>Категория</th><th>Язык</th><th>Статус</th><th>Действия</th></tr></thead>
                <tbody>
                  {filteredRows.map((row) => (
                    <tr key={row.id}>
                      <td><p className="font-medium">{row.title}</p><p className="text-xs text-muted-foreground">{row.slug}</p></td>
                      <td>{categoryLabels[row.category] ?? row.category}</td>
                      <td>{row.language}</td>
                      <td><Badge variant={row.status === "published" ? "success" : "warning"}>{statusLabels[row.status]}</Badge></td>
                      <td>{canEdit ? <div className="flex gap-2">
                        <Button type="button" variant="outline" size="icon" aria-label={`Редактировать ${row.title}`} onClick={() => editArticle(row)}><Edit className="size-4" /></Button>
                        <Button type="button" variant="ghost" size="icon" aria-label={`Удалить ${row.title}`} onClick={() => deleteArticle(row)}><Trash2 className="size-4" /></Button>
                      </div> : <span className="text-xs text-muted-foreground">Только просмотр</span>}</td>
                    </tr>
                  ))}
                  {filteredRows.length === 0 && <tr><td colSpan={5} className="py-10 text-center text-muted-foreground">Материалы не найдены.</td></tr>}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>

        {canEdit && <Card>
          <CardHeader>
            <div className="flex items-start justify-between gap-3">
              <div><CardTitle>{editingId ? "Редактировать материал" : "Создать материал"}</CardTitle><CardDescription>Поля публикации для сайта и мобильного приложения.</CardDescription></div>
              {editingId && <Button type="button" variant="ghost" size="icon" aria-label="Отменить редактирование" onClick={resetForm}><X className="size-4" /></Button>}
            </div>
          </CardHeader>
          <CardContent>
            <form className="grid gap-4 lg:grid-cols-2" onSubmit={submitArticle}>
              <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-title">Название</Label><Input id="managed-title" value={draft.title} onChange={(event) => { updateDraft("title", event.target.value); if (!editingId) updateDraft("slug", slugify(event.target.value)); }} placeholder="Регистрация в муниципалитете" /></div>
              <div className="flex flex-col gap-2"><Label htmlFor="managed-slug">Слаг</Label><Input id="managed-slug" value={draft.slug} onChange={(event) => updateDraft("slug", event.target.value)} /></div>
              <div className="flex flex-col gap-2"><Label htmlFor="managed-language">Язык</Label><Input id="managed-language" value={draft.language} onChange={(event) => updateDraft("language", event.target.value)} /></div>
              <div className="flex flex-col gap-2"><Label>Категория</Label><Select value={draft.category} onValueChange={(value) => updateDraft("category", value)}><SelectTrigger><SelectValue /></SelectTrigger><SelectContent><SelectGroup>{Object.entries(categoryLabels).map(([value, label]) => <SelectItem value={value} key={value}>{label}</SelectItem>)}</SelectGroup></SelectContent></Select></div>
              <div className="flex flex-col gap-2"><Label>Статус</Label><Select value={draft.status} onValueChange={(value) => updateDraft("status", value as ArticleStatus)}><SelectTrigger><SelectValue /></SelectTrigger><SelectContent><SelectGroup>{Object.entries(statusLabels).map(([value, label]) => <SelectItem value={value} key={value}>{label}</SelectItem>)}</SelectGroup></SelectContent></Select></div>
              <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-description">Короткое описание</Label><Input id="managed-description" value={draft.description} onChange={(event) => updateDraft("description", event.target.value)} /></div>
              <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-content">Полный текст</Label><Textarea id="managed-content" value={draft.content} onChange={(event) => updateDraft("content", event.target.value)} placeholder="Напишите текст материала…" /></div>
              <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-source">Официальный источник</Label><Input id="managed-source" type="url" value={draft.source} onChange={(event) => updateDraft("source", event.target.value)} placeholder="https://www.government.nl/..." /></div>
              <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-tags">Теги</Label><Input id="managed-tags" value={draft.tags} onChange={(event) => updateDraft("tags", event.target.value)} placeholder="bsn, municipality, registration" /></div>
              <ContentImageUploader
                images={draft.images}
                folder={editingId ?? (draft.slug || "new-material")}
                enabled={supabaseEnabled}
                onChange={(images) => updateDraft("images", images)}
                onNotice={setNotice}
              />
              {notice && <p role="status" className="text-sm text-cyan-100 lg:col-span-2">{notice}</p>}
              <div className="lg:col-span-2"><Button type="submit" disabled={saving}><Save className="size-4" />{saving ? "Сохранение…" : editingId ? "Сохранить изменения" : "Создать материал"}</Button></div>
            </form>
          </CardContent>
        </Card>}
      </div>
    </div>
  );
}
