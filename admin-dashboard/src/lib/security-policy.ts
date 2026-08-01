const commonContentSecurityPolicyDirectives = [
  "default-src 'self'",
  "base-uri 'self'",
  "form-action 'self'",
  "object-src 'none'",
  "script-src 'self' 'unsafe-inline'",
  "style-src 'self' 'unsafe-inline'",
  "img-src 'self' data: blob: https://*.supabase.co",
  "font-src 'self' data:",
  "connect-src 'self' https://*.supabase.co wss://*.supabase.co",
  "worker-src 'self' blob:",
  "manifest-src 'self'",
  "upgrade-insecure-requests"
] as const;

export const ADMIN_CONTENT_SECURITY_POLICY = [
  ...commonContentSecurityPolicyDirectives,
  "frame-ancestors 'none'"
].join("; ");

// Hostinger's managed CDN currently replaces the upstream CSP header with only
// `upgrade-insecure-requests`. Keep an HTML fallback for directives supported
// by CSP meta tags; X-Frame-Options and the upstream header still deny framing.
export const ADMIN_META_CONTENT_SECURITY_POLICY = commonContentSecurityPolicyDirectives.join("; ");
