export const SCREENSHOT_MAX_BYTES = 512 * 1024;
export const SCREENSHOT_PREVIEW_SECONDS = 60;
export const visualStatuses = ["good", "needs review", "broken", "fixed"] as const;
export const visualStatusLabels = { good: "Проверено вручную: хорошо", "needs review": "Нужна ручная проверка", broken: "Проблема интерфейса", fixed: "Исправление проверено вручную" };
export type VisualStatus = typeof visualStatuses[number];
export type ScreenshotRow = { id: string; file_path: string; expected_file_path: string | null; screen_type: string; platform: string; device: string; notes: string | null; visual_status: VisualStatus; markers: unknown; created_by: string | null; created_at: string; updated_at: string };
export type ScreenshotView = ScreenshotRow & { previewUrl: string | null };
export type VisualQAResult = { ok: true; row: ScreenshotRow; message: string } | { ok: false; message: string };
export const screenshotColumns = "id,file_path,expected_file_path,screen_type,platform,device,notes,visual_status,markers,created_by,created_at,updated_at";
export const isReviewId = (value: unknown): value is string => typeof value === "string" && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test(value);
export const canReviewScreenshots = (role: string) => ["owner", "admin", "qa"].includes(role);
export const isReviewVersion = (value: unknown): value is string => typeof value === "string" && value.length <= 64 && /T.*(?:Z|[+-]\d{2}:\d{2})$/.test(value) && Number.isFinite(Date.parse(value));
export function validScreenshotPath(row: Pick<ScreenshotRow, "id" | "created_by" | "file_path">) {
  return isReviewId(row.id) && isReviewId(row.created_by) && ["png", "jpg"].some(ext => row.file_path === `reviews/${row.created_by}/${row.id}.${ext}`);
}
export function screenshotKind(bytes: Uint8Array, mime: string): "png" | "jpg" | null {
  if (bytes.length > SCREENSHOT_MAX_BYTES || bytes.length < 12) return null;
  const boundedDimensions = (width: number, height: number) => width > 0 && height > 0 && width <= 8192 && height <= 8192 && width * height <= 32000000;
  if (mime === "image/png" && bytes.length >= 45 && [137,80,78,71,13,10,26,10].every((byte,index) => bytes[index] === byte)
    && String.fromCharCode(...bytes.slice(12,16)) === "IHDR" && String.fromCharCode(...bytes.slice(-8,-4)) === "IEND") {
    const data = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    return data.getUint32(8) === 13 && boundedDimensions(data.getUint32(16), data.getUint32(20)) ? "png" : null;
  }
  if (mime === "image/jpeg" && bytes[0] === 255 && bytes[1] === 216 && bytes[2] === 255 && bytes.at(-2) === 255 && bytes.at(-1) === 217) {
    let offset = 2;
    while (offset + 4 < bytes.length) {
      if (bytes[offset++] !== 255) return null;
      while (bytes[offset] === 255) offset++;
      const marker = bytes[offset++];
      if (marker === 218 || marker === 217) return null;
      const length = bytes[offset] * 256 + bytes[offset + 1];
      if (length < 2 || offset + length > bytes.length) return null;
      if ([192,193,194].includes(marker)) return length >= 8 && boundedDimensions(bytes[offset + 5] * 256 + bytes[offset + 6], bytes[offset + 3] * 256 + bytes[offset + 4]) ? "jpg" : null;
      offset += length;
    }
  }
  return null;
}
