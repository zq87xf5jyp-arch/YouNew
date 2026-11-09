import 'server-only';
import {redirect} from 'next/navigation';
import {signedIn,Denied} from './r4/security';
import {canEditContent} from './authorization';
export {roleLabels,rolePermissions,canAccessPath,canEditContent} from './authorization';
export type {AdminRole} from './authorization';
export function isLocalDemoAdminEnabled(){return false;}
export async function requireAdmin(){try{return await signedIn();}catch(e){if(e instanceof Denied)redirect('/login?error=not-approved');throw e;}}
export async function requireContentEditor(){const a=await requireAdmin();if(!canEditContent(a.role))throw new Denied(403,'forbidden');return a;}
