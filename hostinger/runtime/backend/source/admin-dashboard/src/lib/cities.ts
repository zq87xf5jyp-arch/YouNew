export const cityStatuses = { draft: "Черновик", research: "Исследование", review: "На проверке", qa: "QA", published: "Опубликовано", needs_review: "Требует проверки", archived: "Архив" } as const;
export const cityProvinces = ["Drenthe", "Flevoland", "Friesland", "Gelderland", "Groningen", "Limburg", "Noord-Brabant", "Noord-Holland", "Overijssel", "Utrecht", "Zeeland", "Zuid-Holland"] as const;
export type CityStatus = keyof typeof cityStatuses;
export type CityRow = { id: string; name: string; slug: string; province: string; description: string | null; lat: number | null; lng: number | null; municipality_link: string | null; transport_notes: string | null; emergency_contacts: unknown; useful_official_links: unknown; cover_image_path: string | null; status: CityStatus; created_at: string; updated_at: string; published_at: string | null };
export type CityFields = Pick<CityRow, "name" | "province" | "description" | "lat" | "lng" | "municipality_link" | "transport_notes" | "status">;
export type CityResult = { ok: true; row: CityRow; replayed?: boolean } | { ok: false; message: string };
export const cityColumns = "id,name,slug,province,description,lat,lng,municipality_link,transport_notes,emergency_contacts,useful_official_links,cover_image_path,status,created_at,updated_at,published_at";
export const cityUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
export const cityDate = (v: unknown): v is string => typeof v === "string" && v.length <= 64 && /^\d{4}-\d{2}-\d{2}T/.test(v) && Number.isFinite(Date.parse(v));
export function cityFields(form: FormData): CityFields | null {
  const values: Record<string, string> = {};
  for (const key of ["name", "province", "description", "lat", "lng", "municipality_link", "transport_notes", "status"]) { const value = form.get(key); if (typeof value !== "string") return null; values[key] = value.trim(); }
  const v = values;
  if (!v.name || v.name.length > 160 || !cityProvinces.includes(v.province as typeof cityProvinces[number]) || v.description.length > 5000 || v.transport_notes.length > 3000 || !Object.hasOwn(cityStatuses, v.status)) return null;
  if (Boolean(v.lat) !== Boolean(v.lng)) return null;
  const lat = v.lat ? Number(v.lat) : null, lng = v.lng ? Number(v.lng) : null;
  if ((v.lat && !/^-?\d{1,2}(?:\.\d{1,6})?$/.test(v.lat)) || (v.lng && !/^-?\d{1,3}(?:\.\d{1,6})?$/.test(v.lng)) || (lat !== null && (!Number.isFinite(lat) || Math.abs(lat) > 90)) || (lng !== null && (!Number.isFinite(lng) || Math.abs(lng) > 180))) return null;
  if (v.municipality_link) { try { const url = new URL(v.municipality_link); if (v.municipality_link.length > 2048 || url.protocol !== "https:" || url.username || url.password || !url.hostname.includes(".") || /(^localhost$|\.local$|\.localhost$)/i.test(url.hostname) || /^[\d.:\[\]]+$/.test(url.hostname)) return null; } catch { return null; } }
  return { name: v.name, province: v.province, description: v.description || null, lat, lng, municipality_link: v.municipality_link || null, transport_notes: v.transport_notes || null, status: v.status as CityStatus };
}
export function validCityRow(value: unknown): value is CityRow {
  if (!value || typeof value !== "object") return false;
  const row = value as CityRow;
  return typeof row.id === "string" && cityUuid.test(row.id) && typeof row.name === "string" && typeof row.slug === "string" && typeof row.province === "string" && Object.hasOwn(cityStatuses, row.status) && [row.description, row.municipality_link, row.transport_notes, row.cover_image_path].every(v => v === null || typeof v === "string") && [row.lat, row.lng].every(v => v === null || (typeof v === "number" && Number.isFinite(v))) && row.emergency_contacts !== undefined && row.useful_official_links !== undefined && cityDate(row.created_at) && cityDate(row.updated_at) && (row.published_at === null || cityDate(row.published_at));
}
export const cityFieldsMatch = (row: CityRow, fields: CityFields) => (Object.keys(fields) as Array<keyof CityFields>).every(key => row[key] === fields[key]);
