"use client";

import { createSupabaseBrowserClient } from "@/lib/supabase/client";
import {
  CONTENT_IMAGE_LIMIT,
  CONTENT_IMAGE_MAX_BYTES,
  CONTENT_IMAGE_MAX_HEIGHT,
  CONTENT_IMAGE_MAX_WIDTH,
  CONTENT_IMAGE_QUALITY,
  CONTENT_IMAGES_BUCKET,
  type ManagedContentImage
} from "@/lib/content-images";

const supportedTypes = new Set(["image/jpeg", "image/png", "image/webp"]);

type OptimizedImage = {
  blob: Blob;
  width: number;
  height: number;
};

function safeFileStem(value: string) {
  const stem = value.replace(/\.[^.]+$/, "").normalize("NFKD").replace(/[^a-zA-Z0-9-]+/g, "-").replace(/^-+|-+$/g, "").toLowerCase();
  return stem.slice(0, 64) || "image";
}

function safeFolder(value: string) {
  return value.replace(/[^a-zA-Z0-9_-]+/g, "-").replace(/^-+|-+$/g, "").slice(0, 80) || "new-material";
}

function canvasToBlob(canvas: HTMLCanvasElement) {
  return new Promise<Blob>((resolve, reject) => {
    canvas.toBlob((blob) => {
      if (blob) resolve(blob);
      else reject(new Error("Не удалось оптимизировать изображение."));
    }, "image/webp", CONTENT_IMAGE_QUALITY);
  });
}

async function optimizeImage(file: File): Promise<OptimizedImage> {
  if (!supportedTypes.has(file.type)) {
    throw new Error("Поддерживаются JPG, PNG и WebP.");
  }
  if (file.size > CONTENT_IMAGE_MAX_BYTES) {
    throw new Error("Файл больше 8 МБ. Выберите изображение меньшего размера.");
  }

  const bitmap = await createImageBitmap(file, { imageOrientation: "from-image" });
  try {
    const scale = Math.min(1, CONTENT_IMAGE_MAX_WIDTH / bitmap.width, CONTENT_IMAGE_MAX_HEIGHT / bitmap.height);
    const width = Math.max(1, Math.round(bitmap.width * scale));
    const height = Math.max(1, Math.round(bitmap.height * scale));
    const canvas = document.createElement("canvas");
    canvas.width = width;
    canvas.height = height;
    const context = canvas.getContext("2d");
    if (!context) throw new Error("Браузер не поддерживает оптимизацию изображений.");
    context.drawImage(bitmap, 0, 0, width, height);
    return { blob: await canvasToBlob(canvas), width, height };
  } finally {
    bitmap.close();
  }
}

export async function uploadContentImages(files: File[], folder: string, existingCount: number) {
  if (existingCount + files.length > CONTENT_IMAGE_LIMIT) {
    throw new Error(`Можно добавить не более ${CONTENT_IMAGE_LIMIT} изображений к одному материалу.`);
  }

  const supabase = createSupabaseBrowserClient();
  const bucket = supabase.storage.from(CONTENT_IMAGES_BUCKET);
  const results: ManagedContentImage[] = [];

  try {
    for (const file of files) {
      const optimized = await optimizeImage(file);
      const id = crypto.randomUUID();
      const path = `articles/${safeFolder(folder)}/${Date.now()}-${id}-${safeFileStem(file.name)}.webp`;
      const { error } = await bucket.upload(path, optimized.blob, {
        cacheControl: "31536000",
        contentType: "image/webp",
        upsert: false
      });
      if (error) throw new Error(`Не удалось загрузить ${file.name}: ${error.message}`);

      const url = bucket.getPublicUrl(path, { transform: { width: CONTENT_IMAGE_MAX_WIDTH, resize: "contain", quality: 82 } }).data.publicUrl;
      const thumbnailUrl = bucket.getPublicUrl(path, { transform: { width: 640, height: 420, resize: "contain", quality: 82 } }).data.publicUrl;
      results.push({
        id,
        path,
        url,
        thumbnailUrl,
        alt: safeFileStem(file.name).replaceAll("-", " "),
        role: existingCount + results.length === 0 ? "cover" : "gallery",
        width: optimized.width,
        height: optimized.height,
        bytes: optimized.blob.size,
        mimeType: "image/webp"
      });
    }
  } catch (error) {
    if (results.length > 0) await bucket.remove(results.map((image) => image.path));
    throw error;
  }

  return results;
}

export async function removeContentImage(path: string) {
  const supabase = createSupabaseBrowserClient();
  const { error } = await supabase.storage.from(CONTENT_IMAGES_BUCKET).remove([path]);
  if (error) throw new Error(`Не удалось удалить изображение: ${error.message}`);
}
