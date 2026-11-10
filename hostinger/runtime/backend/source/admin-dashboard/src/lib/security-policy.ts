export function adminScriptSourceDirective(environment=process.env.NODE_ENV){return environment==='development'?"script-src 'self' 'unsafe-inline' 'unsafe-eval'":"script-src 'self' 'unsafe-inline'";}
const base=["default-src 'self'","base-uri 'self'","form-action 'self'","object-src 'none'",adminScriptSourceDirective(),"style-src 'self' 'unsafe-inline'","img-src 'self' data: blob:","font-src 'self' data:","connect-src 'self'","worker-src 'self' blob:",...(process.env.R4_LOCAL==='true'?[]:["upgrade-insecure-requests"])];
export const ADMIN_META_CONTENT_SECURITY_POLICY=base.join('; ');
export const ADMIN_CONTENT_SECURITY_POLICY=[...base,"frame-ancestors 'none'"].join('; ');
