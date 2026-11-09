// Explicit allowlist: do not expose arbitrary internal attributes.
function text(value, limit) {
  return typeof value === "string" && !/[\u0000-\u001f\u007f]/.test(value) && value.trim().length <= limit ? value.trim() : "";
}
function https(value) {
  const raw = text(value, 2048);
  try {
    const url = new URL(raw);
    return url.protocol === "https:" && !url.username && !url.password ? url.href : "";
  } catch { return ""; }
}
function date(value) {
  if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value)) return "";
  const parsed = new Date(value);
  return Number.isFinite(parsed.getTime()) && parsed.toISOString().slice(0, 10) === value && value <= new Date().toISOString().slice(0, 10) ? value : "";
}
export function projectPlaceDetails(entity) {
  const a = entity?.attributes ?? {};
  function field(key, validate) {
    const value = validate(a[key]);
    const sourceUrl = https(a[`${key}_source_url`]);
    const checkedAt = date(a[`${key}_checked_at`]);
    return value && sourceUrl && checkedAt ? { value, sourceUrl, checkedAt } : null;
  }
  const address = field("address", v => text(v, 300));
  const website = field("website", https);
  const email = field("contact_email", v => {
    const s = text(v, 254);
    return /^[A-Za-z0-9.!#$&'*+/=^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$/.test(s) ? s : "";
  });
  const phone = field("contact_phone", v => {
    const s = text(v, 60); const digits = s.replace(/\D/g, "");
    return /^\+?[0-9 ()\-.]+$/.test(s) && digits.length >= 7 && digits.length <= 15 ? s : "";
  });
  if (!address && !website && !email && !phone) return null;
  return { address, website, email, phone,
    addressNote: address ? text(a.address_note, 600) || null : null,
    contactNote: email || phone ? text(a.contact_note, 600) || null : null };
}
