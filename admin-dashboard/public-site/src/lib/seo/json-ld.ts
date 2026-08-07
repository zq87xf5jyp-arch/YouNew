/** Serialize structured data without allowing imported text to terminate its script element. */
export function serializeJsonLd(value: unknown): string {
  return JSON.stringify(value)
    // Hostinger's temporary-domain preview rewrites the literal production
    // hostname in HTML responses. Escaping the dot keeps the JSON-LD value
    // identical after JSON parsing while protecting React Flight text-row
    // byte lengths from that response-time rewrite.
    .replaceAll("younew.nl", "younew\\u002enl")
    .replace(/&/g, "\\u0026")
    .replace(/</g, "\\u003c")
    .replace(/>/g, "\\u003e")
    .replace(/\u2028/g, "\\u2028")
    .replace(/\u2029/g, "\\u2029");
}
