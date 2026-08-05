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
import lifeDomainTaxonomy from "../../../public-site/src/data/life-domain-taxonomy.json";

type ArticleStatus = "draft" | "research" | "review" | "qa" | "published" | "needs_review" | "archived";
type SearchScopeLevel = "national" | "province" | "municipality" | "city" | "neighbourhood" | "organization" | "emergency" | "online_service";

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
  canonicalTitle: string;
  subcategory: string;
  intents: string;
  synonyms: string;
  keywords: string;
  supportedLanguages: string;
  countryScope: "NL";
  scopeLevel: SearchScopeLevel;
  province: string;
  municipality: string;
  city: string;
  nationalFallback: boolean;
  applicableProfiles: string;
  sourceUrls: string;
  contentQualityScore: number;
  searchIndexed: boolean;
  images: ManagedContentImage[];
  verifiedDate?: string;
  reviewConfirmed: boolean;
  requiresMedia: boolean;
  updatedAt?: string;
};

type ArticleDraft = Omit<ManagedArticle, "id" | "updatedAt">;

const storageKey = "younew-admin-articles-v1";

const emptyDraft: ArticleDraft = {
  title: "",
  slug: "",
  category: "documents",
  language: "ru",
  status: "draft",
  priority: 1,
  description: "",
  content: "",
  source: "",
  tags: "",
  canonicalTitle: "",
  subcategory: "",
  intents: "",
  synonyms: "",
  keywords: "",
  supportedLanguages: "en, nl, ru",
  countryScope: "NL",
  scopeLevel: "national",
  province: "",
  municipality: "",
  city: "",
  nationalFallback: true,
  applicableProfiles: "student, expat, refugee, worker, resident",
  sourceUrls: "",
  contentQualityScore: 0,
  searchIndexed: false,
  images: [],
  verifiedDate: "",
  reviewConfirmed: false,
  requiresMedia: false
};

const categoryLabels: Record<string, string> = Object.fromEntries(
  lifeDomainTaxonomy.map((domain) => [domain.slug, domain.title])
);

const warningLabels: Record<string, string> = {
  no_synonyms: "нет синонимов",
  no_official_source: "нет официального источника",
  no_national_fallback: "нет national fallback",
  no_city_mapping: "нет city mapping",
  no_category: "нет категории",
  duplicate_intent: "дублирующий intent",
  conflicting_aliases: "конфликт aliases",
  content_not_indexed: "не в индексе",
  stale_content: "устаревшая проверка",
  empty_result_risk: "риск нулевой выдачи"
};

function normalizedList(value: string): string[] {
  return [...new Set(value.split(/[\n,]/u).map((item) => item.trim().toLocaleLowerCase("und")).filter(Boolean))];
}

function articleWarnings(article: ManagedArticle, articles: readonly ManagedArticle[]): string[] {
  const warnings: string[] = [];
  const intents = normalizedList(article.intents);
  const synonyms = normalizedList(article.synonyms);
  const keywords = normalizedList(article.keywords);
  const sources = normalizedList(`${article.source}\n${article.sourceUrls}`);
  if (synonyms.length === 0) warnings.push("no_synonyms");
  if (!sources.some((source) => source.startsWith("https://"))) warnings.push("no_official_source");
  if (!article.nationalFallback) warnings.push("no_national_fallback");
  if (["municipality", "city", "neighbourhood"].includes(article.scopeLevel) && !article.municipality.trim() && !article.city.trim()) warnings.push("no_city_mapping");
  if (!article.category) warnings.push("no_category");
  if (articles.some((candidate) => candidate.id !== article.id && normalizedList(candidate.intents).some((intent) => intents.includes(intent)))) warnings.push("duplicate_intent");
  if (articles.some((candidate) => candidate.id !== article.id && candidate.category !== article.category && normalizedList(candidate.synonyms).some((alias) => synonyms.includes(alias)))) warnings.push("conflicting_aliases");
  if (article.status === "published" && !article.searchIndexed) warnings.push("content_not_indexed");
  const verifiedAt = article.verifiedDate ? Date.parse(article.verifiedDate) : Number.NaN;
  if (article.status === "published" && (!Number.isFinite(verifiedAt) || verifiedAt < Date.now() - 90 * 86_400_000)) warnings.push("stale_content");
  if (intents.length === 0 || synonyms.length === 0 || keywords.length === 0) warnings.push("empty_result_risk");
  return warnings;
}

const statusLabels: Record<ArticleStatus, string> = {
  draft: "черновик",
  research: "исследование",
  review: "на проверке",
  qa: "QA",
  published: "опубликовано",
  needs_review: "требует перепроверки",
  archived: "архив"
};

export function ContentManager({
  initialRows,
  supabaseEnabled,
  canEdit
}: {
  initialRows: ManagedArticle[];
  supabaseEnabled: boolean;
  canEdit: boolean;
}) {
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
        if (Array.isArray(parsed)) setRows(parsed.map((row) => ({
          ...emptyDraft,
          ...row,
          id: row.id,
          canonicalTitle: row.canonicalTitle || row.title,
          keywords: row.keywords || row.tags || "",
          supportedLanguages: row.supportedLanguages || row.language || "en",
          images: Array.isArray(row.images) ? row.images : [],
          reviewConfirmed: Boolean(row.reviewConfirmed),
          requiresMedia: Boolean(row.requiresMedia),
          nationalFallback: row.nationalFallback !== false,
          searchIndexed: Boolean(row.searchIndexed)
        })));
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
  const warningsById = useMemo(
    () => new Map(rows.map((row) => [row.id, articleWarnings(row, rows)])),
    [rows]
  );

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
    if (draft.status === "published") {
      setNotice("Прямая публикация заблокирована. Переведите материал в QA и завершите Human Review Queue.");
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
      canonicalTitle: article.canonicalTitle,
      subcategory: article.subcategory,
      intents: article.intents,
      synonyms: article.synonyms,
      keywords: article.keywords,
      supportedLanguages: article.supportedLanguages,
      countryScope: article.countryScope,
      scopeLevel: article.scopeLevel,
      province: article.province,
      municipality: article.municipality,
      city: article.city,
      nationalFallback: article.nationalFallback,
      applicableProfiles: article.applicableProfiles,
      sourceUrls: article.sourceUrls,
      contentQualityScore: article.contentQualityScore,
      searchIndexed: article.searchIndexed,
      images: article.images ?? [],
      verifiedDate: article.verifiedDate ?? "",
      reviewConfirmed: article.reviewConfirmed,
      requiresMedia: article.requiresMedia
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
                <thead><tr><th>Название</th><th>Категория</th><th>Язык</th><th>Статус</th><th>Search QA</th><th>Действия</th></tr></thead>
                <tbody>
                  {filteredRows.map((row) => (
                    <tr key={row.id}>
                      <td><p className="font-medium">{row.title}</p><p className="text-xs text-muted-foreground">{row.slug}</p></td>
                      <td>{categoryLabels[row.category] ?? row.category}</td>
                      <td>{row.language}</td>
                      <td><Badge variant={row.status === "published" ? "success" : "warning"}>{statusLabels[row.status]}</Badge></td>
                      <td>
                        <div className="flex max-w-72 flex-wrap gap-1">
                          {(warningsById.get(row.id) ?? []).length === 0
                            ? <Badge variant="success">готово</Badge>
                            : (warningsById.get(row.id) ?? []).map((warning) => <Badge variant="warning" key={warning}>{warningLabels[warning] ?? warning}</Badge>)}
                        </div>
                      </td>
                      <td>{canEdit ? <div className="flex gap-2">
                        <Button type="button" variant="outline" size="icon" aria-label={`Редактировать ${row.title}`} onClick={() => editArticle(row)}><Edit className="size-4" /></Button>
                        <Button type="button" variant="ghost" size="icon" aria-label={`Удалить ${row.title}`} onClick={() => deleteArticle(row)}><Trash2 className="size-4" /></Button>
                      </div> : <span className="text-xs text-muted-foreground">Только просмотр</span>}</td>
                    </tr>
                  ))}
                  {filteredRows.length === 0 && <tr><td colSpan={6} className="py-10 text-center text-muted-foreground">Материалы не найдены.</td></tr>}
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
              <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-title">Название</Label><Input id="managed-title" value={draft.title} onChange={(event) => { updateDraft("title", event.target.value); if (!editingId) { updateDraft("slug", slugify(event.target.value)); updateDraft("canonicalTitle", event.target.value); } }} placeholder="Регистрация в муниципалитете" /></div>
              <div className="flex flex-col gap-2"><Label htmlFor="managed-slug">Слаг</Label><Input id="managed-slug" value={draft.slug} onChange={(event) => updateDraft("slug", event.target.value)} /></div>
              <div className="flex flex-col gap-2"><Label htmlFor="managed-language">Язык</Label><Input id="managed-language" value={draft.language} onChange={(event) => updateDraft("language", event.target.value)} /></div>
              <div className="flex flex-col gap-2"><Label>Категория</Label><Select value={draft.category} onValueChange={(value) => updateDraft("category", value)}><SelectTrigger><SelectValue /></SelectTrigger><SelectContent><SelectGroup>{Object.entries(categoryLabels).map(([value, label]) => <SelectItem value={value} key={value}>{label}</SelectItem>)}</SelectGroup></SelectContent></Select></div>
              <div className="flex flex-col gap-2"><Label>Статус</Label><Select value={draft.status} onValueChange={(value) => updateDraft("status", value as ArticleStatus)}><SelectTrigger><SelectValue /></SelectTrigger><SelectContent><SelectGroup>{Object.entries(statusLabels).map(([value, label]) => <SelectItem value={value} key={value} disabled={value === "published"}>{label}</SelectItem>)}</SelectGroup></SelectContent></Select></div>
              <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-description">Короткое описание</Label><Input id="managed-description" value={draft.description} onChange={(event) => updateDraft("description", event.target.value)} /></div>
              <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-content">Полный текст</Label><Textarea id="managed-content" value={draft.content} onChange={(event) => updateDraft("content", event.target.value)} placeholder="Напишите текст материала…" /></div>
              <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-source">Официальный источник</Label><Input id="managed-source" type="url" value={draft.source} onChange={(event) => updateDraft("source", event.target.value)} placeholder="https://www.government.nl/..." /></div>
              <fieldset className="grid gap-4 rounded-md border border-border bg-secondary/20 p-4 lg:col-span-2 lg:grid-cols-2">
                <legend className="px-1 text-sm font-medium">Search applicability — обязательные поля</legend>
                <p className="text-xs text-muted-foreground lg:col-span-2">Фильтры усиливают ранжирование, но не скрывают national guidance. Database publication gate блокирует неполную search metadata.</p>
                <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-canonical-title">Canonical title</Label><Input id="managed-canonical-title" value={draft.canonicalTitle} onChange={(event) => updateDraft("canonicalTitle", event.target.value)} placeholder={draft.title || "Canonical search title"} /></div>
                <div className="flex flex-col gap-2"><Label htmlFor="managed-subcategory">Подкатегория</Label><Input id="managed-subcategory" value={draft.subcategory} onChange={(event) => updateDraft("subcategory", event.target.value)} placeholder="rental-rights" /></div>
                <div className="flex flex-col gap-2"><Label htmlFor="managed-quality">Content quality score, 0–100</Label><Input id="managed-quality" type="number" min={0} max={100} value={draft.contentQualityScore} onChange={(event) => updateDraft("contentQualityScore", Number(event.target.value))} /></div>
                <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-intents">Intents</Label><Textarea id="managed-intents" value={draft.intents} onChange={(event) => updateDraft("intents", event.target.value)} placeholder="documents.bsn, documents.registration" /></div>
                <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-synonyms">Synonyms / aliases (EN, NL, RU)</Label><Textarea id="managed-synonyms" value={draft.synonyms} onChange={(event) => updateDraft("synonyms", event.target.value)} placeholder="BSN, registration, inschrijving, регистрация" /></div>
                <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-keywords">Search keywords</Label><Input id="managed-keywords" value={draft.keywords} onChange={(event) => updateDraft("keywords", event.target.value)} /></div>
                <div className="flex flex-col gap-2"><Label htmlFor="managed-languages">Supported languages</Label><Input id="managed-languages" value={draft.supportedLanguages} onChange={(event) => updateDraft("supportedLanguages", event.target.value)} placeholder="en, nl, ru" /></div>
                <div className="flex flex-col gap-2"><Label htmlFor="managed-profiles">Applicable profiles</Label><Input id="managed-profiles" value={draft.applicableProfiles} onChange={(event) => updateDraft("applicableProfiles", event.target.value)} placeholder="student, expat, worker" /></div>
                <div className="flex flex-col gap-2"><Label>Scope level</Label><Select value={draft.scopeLevel} onValueChange={(value) => updateDraft("scopeLevel", value as SearchScopeLevel)}><SelectTrigger><SelectValue /></SelectTrigger><SelectContent><SelectGroup>{["national", "province", "municipality", "city", "neighbourhood", "organization", "emergency", "online_service"].map((value) => <SelectItem value={value} key={value}>{value}</SelectItem>)}</SelectGroup></SelectContent></Select></div>
                <div className="flex flex-col gap-2"><Label htmlFor="managed-country">Country scope</Label><Input id="managed-country" value={draft.countryScope} readOnly /></div>
                <div className="flex flex-col gap-2"><Label htmlFor="managed-province">Province</Label><Input id="managed-province" value={draft.province} onChange={(event) => updateDraft("province", event.target.value)} /></div>
                <div className="flex flex-col gap-2"><Label htmlFor="managed-municipality">Municipality</Label><Input id="managed-municipality" value={draft.municipality} onChange={(event) => updateDraft("municipality", event.target.value)} /></div>
                <div className="flex flex-col gap-2"><Label htmlFor="managed-city">City</Label><Input id="managed-city" value={draft.city} onChange={(event) => updateDraft("city", event.target.value)} /></div>
                <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-source-urls">Source URLs</Label><Textarea id="managed-source-urls" value={draft.sourceUrls} onChange={(event) => updateDraft("sourceUrls", event.target.value)} placeholder="Один HTTPS URL на строку" /></div>
                <label className="flex items-start gap-2 text-sm"><input type="checkbox" className="mt-1" checked={draft.nationalFallback} onChange={(event) => updateDraft("nationalFallback", event.target.checked)} />National fallback разрешён.</label>
                <label className="flex items-start gap-2 text-sm"><input type="checkbox" className="mt-1" checked={draft.searchIndexed} onChange={(event) => updateDraft("searchIndexed", event.target.checked)} />Материал подтверждён в production search index.</label>
              </fieldset>
              <div className="rounded-md border border-cyan-400/20 bg-cyan-400/10 p-3 text-sm lg:col-span-2">
                <p className="font-medium text-cyan-100">Verification evidence отделено от редактирования</p>
                <p className="mt-1 text-xs text-muted-foreground">Изменение текста не обновляет reviewer, дату проверки или confidence. Используйте Trust & Review → Verified now после отдельной проверки источника.</p>
                {draft.verifiedDate ? <p className="mt-2 text-xs">Последняя историческая дата: {draft.verifiedDate}. Это значение здесь только для чтения.</p> : null}
              </div>
              <fieldset className="flex flex-col gap-3 rounded-md border border-border bg-secondary/20 p-3 lg:col-span-2">
                <legend className="px-1 text-sm font-medium">Content requirements</legend>
                <label className="flex items-start gap-2 text-sm"><input type="checkbox" className="mt-1" checked={draft.requiresMedia} onChange={(event) => updateDraft("requiresMedia", event.target.checked)} />Для публикации этого материала обязательно изображение.</label>
              </fieldset>
              <div className="flex flex-col gap-2 lg:col-span-2"><Label htmlFor="managed-tags">Теги</Label><Input id="managed-tags" value={draft.tags} onChange={(event) => updateDraft("tags", event.target.value)} placeholder="bsn, municipality, registration" /></div>
              <ContentImageUploader
                images={draft.images}
                folder={editingId ?? (draft.slug || "new-material")}
                enabled={supabaseEnabled}
                onChange={(images) => updateDraft("images", images)}
                onNotice={setNotice}
              />
              {notice && <p role="status" className="text-sm text-cyan-100 lg:col-span-2">{notice}</p>}
              {draft.status === "published" ? <p className="rounded-md border border-amber-400/30 bg-amber-400/10 p-3 text-xs text-amber-100 lg:col-span-2">Прямая публикация запрещена. Human verification и server-side approval выполняются отдельными идемпотентными действиями; DataProject publication и deployment остаются отдельными подтверждаемыми операциями.</p> : null}
              <div className="lg:col-span-2"><Button type="submit" disabled={saving}><Save className="size-4" />{saving ? "Сохранение…" : editingId ? "Сохранить изменения" : "Создать материал"}</Button></div>
            </form>
          </CardContent>
        </Card>}
      </div>
    </div>
  );
}
