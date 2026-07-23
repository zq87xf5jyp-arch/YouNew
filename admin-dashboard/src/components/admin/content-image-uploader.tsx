"use client";

import { useRef, useState } from "react";
import { ImagePlus, LoaderCircle, Star, Trash2, UploadCloud } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { CONTENT_IMAGE_LIMIT, type ManagedContentImage } from "@/lib/content-images";
import { removeContentImage, uploadContentImages } from "@/lib/supabase/content-image-storage";

type ContentImageUploaderProps = {
  images: ManagedContentImage[];
  folder: string;
  enabled: boolean;
  onChange: (images: ManagedContentImage[]) => void;
  onNotice: (message: string) => void;
};

function formatBytes(bytes: number) {
  if (bytes < 1024 * 1024) return `${Math.max(1, Math.round(bytes / 1024))} КБ`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} МБ`;
}

export function ContentImageUploader({ images, folder, enabled, onChange, onNotice }: ContentImageUploaderProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [busy, setBusy] = useState(false);
  const [dragging, setDragging] = useState(false);

  async function addFiles(fileList: FileList | null) {
    const files = fileList ? Array.from(fileList) : [];
    if (files.length === 0) return;
    if (!enabled) {
      onNotice("Подключите Supabase: локальное хранение изображений отключено.");
      return;
    }

    setBusy(true);
    try {
      const uploaded = await uploadContentImages(files, folder, images.length);
      onChange([...images, ...uploaded]);
      onNotice(`Загружено в Supabase Storage: ${uploaded.length}. URL созданы автоматически.`);
    } catch (error) {
      onNotice(error instanceof Error ? error.message : "Не удалось загрузить изображения.");
    } finally {
      setBusy(false);
      if (inputRef.current) inputRef.current.value = "";
    }
  }

  async function removeImage(image: ManagedContentImage) {
    if (!window.confirm(`Удалить изображение «${image.alt || "без подписи"}» из Supabase Storage?`)) return;
    setBusy(true);
    try {
      await removeContentImage(image.path);
      const remaining = images.filter((candidate) => candidate.id !== image.id);
      if (image.role === "cover" && remaining[0]) remaining[0] = { ...remaining[0], role: "cover" };
      onChange(remaining);
      onNotice("Изображение удалено из Supabase Storage.");
    } catch (error) {
      onNotice(error instanceof Error ? error.message : "Не удалось удалить изображение.");
    } finally {
      setBusy(false);
    }
  }

  function setCover(id: string) {
    onChange(images.map((image) => ({ ...image, role: image.id === id ? "cover" : "gallery" })));
    onNotice("Обложка выбрана. Сохраните материал, чтобы применить изменение.");
  }

  function updateAlt(id: string, alt: string) {
    onChange(images.map((image) => image.id === id ? { ...image, alt } : image));
  }

  return (
    <section className="grid gap-3 lg:col-span-2" aria-labelledby="content-images-title">
      <div>
        <Label id="content-images-title">Изображения</Label>
        <p className="mt-1 text-xs leading-5 text-muted-foreground">
          Только Supabase Storage. JPG, PNG или WebP до 8 МБ; автоматически WebP, максимум 1920×1280. До {CONTENT_IMAGE_LIMIT} файлов.
        </p>
      </div>

      <input
        ref={inputRef}
        className="sr-only"
        type="file"
        accept="image/jpeg,image/png,image/webp"
        multiple
        disabled={!enabled || busy || images.length >= CONTENT_IMAGE_LIMIT}
        onChange={(event) => void addFiles(event.target.files)}
      />
      <button
        type="button"
        className={`flex min-h-32 flex-col items-center justify-center gap-2 rounded-lg border border-dashed px-5 py-6 text-center transition ${dragging ? "border-cyan-300 bg-cyan-400/10" : "border-border bg-muted/20"} ${!enabled ? "cursor-not-allowed opacity-60" : "hover:border-cyan-400/60 hover:bg-cyan-400/5"}`}
        disabled={!enabled || busy || images.length >= CONTENT_IMAGE_LIMIT}
        onClick={() => inputRef.current?.click()}
        onDragEnter={(event) => { event.preventDefault(); setDragging(true); }}
        onDragOver={(event) => event.preventDefault()}
        onDragLeave={() => setDragging(false)}
        onDrop={(event) => { event.preventDefault(); setDragging(false); void addFiles(event.dataTransfer.files); }}
      >
        {busy ? <LoaderCircle className="size-7 animate-spin text-cyan-300" /> : images.length > 0 ? <ImagePlus className="size-7 text-cyan-300" /> : <UploadCloud className="size-7 text-cyan-300" />}
        <span className="text-sm font-semibold">{busy ? "Оптимизация и загрузка…" : enabled ? "Перетащите изображения или выберите файлы" : "Загрузка доступна после подключения Supabase"}</span>
        <span className="text-xs text-muted-foreground">{images.length} из {CONTENT_IMAGE_LIMIT} · файлы не сохраняются на сервере сайта</span>
      </button>

      {images.length > 0 ? (
        <div className="grid gap-3 sm:grid-cols-2">
          {images.map((image) => (
            <article className="overflow-hidden rounded-lg border bg-muted/20" key={image.id}>
              {/* Public Supabase URL is intentionally used instead of a local asset. */}
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img className="aspect-[16/10] w-full object-cover" src={image.thumbnailUrl || image.url} alt={image.alt} loading="lazy" decoding="async" />
              <div className="grid gap-3 p-3">
                <div className="flex items-center justify-between gap-3 text-xs text-muted-foreground">
                  <span>{image.width}×{image.height} · {formatBytes(image.bytes)}</span>
                  <span className={image.role === "cover" ? "font-semibold text-orange-300" : ""}>{image.role === "cover" ? "Обложка" : "Галерея"}</span>
                </div>
                <div className="grid gap-1.5">
                  <Label htmlFor={`image-alt-${image.id}`}>Описание для доступности</Label>
                  <Input id={`image-alt-${image.id}`} value={image.alt} onChange={(event) => updateAlt(image.id, event.target.value)} placeholder="Что изображено на фото" />
                </div>
                <div className="flex flex-wrap gap-2">
                  {image.role !== "cover" ? <Button type="button" size="sm" variant="outline" disabled={busy} onClick={() => setCover(image.id)}><Star className="size-4" /> Сделать обложкой</Button> : null}
                  <Button type="button" size="sm" variant="ghost" disabled={busy} onClick={() => void removeImage(image)}><Trash2 className="size-4" /> Удалить</Button>
                </div>
              </div>
            </article>
          ))}
        </div>
      ) : null}
    </section>
  );
}
