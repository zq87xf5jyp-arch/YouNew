export const mapPointStatuses = {
  draft: "Черновик", research: "Исследование", review: "На проверке", qa: "QA",
  published: "Опубликовано", needs_review: "Требует проверки", archived: "Архив"
} as const;
export const mapPointTypes = {
  city: "Город", municipality: "Муниципалитет", hospital: "Больница", transport: "Транспорт",
  government: "Государство", education: "Образование", custom: "Другое"
} as const;
export type MapPointStatus = keyof typeof mapPointStatuses;
export type MapPointType = keyof typeof mapPointTypes;
export type MapPointRow = {
  id: string; title: string; type: MapPointType; latitude: number; longitude: number;
  city: string | null; province: string | null; description: string | null; source_url: string | null;
  status: MapPointStatus; icon: string | null; color: string | null; created_at: string; updated_at: string;
};
export type MapPointFields = Omit<MapPointRow, "id" | "created_at" | "updated_at">;
export type MapPointResult = { ok: true; row: MapPointRow; replayed?: boolean } | { ok: false; message: string };
export type MapPointApiMode = "database" | "packaged";
export const mapPointColumns = "id,title,type,latitude,longitude,city,province,description,source_url,status,icon,color,created_at,updated_at";
export const mapPointUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
export function validMapPointDate(value: unknown): value is string {
  return typeof value === "string" && value.length <= 64 && /^\d{4}-\d{2}-\d{2}T/.test(value) && Number.isFinite(Date.parse(value));
}
function coordinate(value: FormDataEntryValue | null, limit: number): number | null {
  if (typeof value !== "string" || !/^-?(?:0|[1-9]\d{0,2})(?:\.\d{1,6})?$/.test(value.trim())) return null;
  const number = Number(value);
  return Number.isFinite(number) && Math.abs(number) <= limit ? number : null;
}
export function mapPointFields(form: FormData): MapPointFields | null {
  const title = form.get("title"), type = form.get("type"), status = form.get("status");
  const latitude = coordinate(form.get("latitude"), 90), longitude = coordinate(form.get("longitude"), 180);
  const city = form.get("city"), province = form.get("province"), description = form.get("description"), source = form.get("source_url"), icon = form.get("icon"), color = form.get("color");
  if (typeof title !== "string" || !title.trim() || title.trim().length > 160 || typeof type !== "string" || !Object.hasOwn(mapPointTypes, type) || typeof status !== "string" || !Object.hasOwn(mapPointStatuses, status) || latitude === null || longitude === null || typeof city !== "string" || city.length > 160 || typeof province !== "string" || province.length > 160 || typeof description !== "string" || description.length > 4000 || typeof source !== "string" || source.length > 2000 || typeof icon !== "string" || (icon.trim() && !/^[A-Za-z][A-Za-z0-9_-]{0,63}$/.test(icon.trim())) || typeof color !== "string" || (color.trim() && !/^#[0-9a-f]{6}$/i.test(color.trim()))) return null;
  if (source.trim()) {
    try { const url = new URL(source.trim()); if (!["https:", "http:"].includes(url.protocol) || url.username || url.password || /[\x00-\x20\x7f]/.test(source.trim())) return null; }
    catch { return null; }
  }
  return { title: title.trim(), type: type as MapPointType, latitude, longitude,
    city: city.trim() || null, province: province.trim() || null, description: description.trim() || null,
    source_url: source.trim() || null, status: status as MapPointStatus, icon: icon.trim() || null, color: color.trim() || null };
}
export function validMapPointRow(value: unknown): value is MapPointRow {
  if (!value || typeof value !== "object") return false;
  const row = value as MapPointRow;
  return typeof row.id === "string" && mapPointUuid.test(row.id) && typeof row.title === "string" && typeof row.type === "string" && Object.hasOwn(mapPointTypes, row.type) && typeof row.status === "string" && Object.hasOwn(mapPointStatuses, row.status)
    && typeof row.latitude === "number" && Number.isFinite(row.latitude) && Math.abs(row.latitude) <= 90
    && typeof row.longitude === "number" && Number.isFinite(row.longitude) && Math.abs(row.longitude) <= 180
    && [row.city, row.province, row.description, row.source_url, row.icon, row.color].every(v => v === null || typeof v === "string")
    && validMapPointDate(row.created_at) && validMapPointDate(row.updated_at);
}
export function mapPointFieldsMatch(row: MapPointRow, fields: MapPointFields) {
  return (Object.keys(fields) as Array<keyof MapPointFields>).every(key => row[key] === fields[key]);
}
