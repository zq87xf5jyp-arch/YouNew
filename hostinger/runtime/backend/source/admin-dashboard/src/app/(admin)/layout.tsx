import {AdminShell} from '@/components/admin/admin-shell';
import {requireAdmin} from '@/lib/auth';
import {notifications} from '@/lib/r4/repository';
export const dynamic='force-dynamic';
export default async function Layout({children}:{children:React.ReactNode}){const a=await requireAdmin();let n=null;if(['owner','admin'].includes(a.role))n=(await notifications()).filter(x=>x.status==='unread').length;return <AdminShell role={a.role} name={a.full_name} unreadNotifications={n}>{children}</AdminShell>;}
