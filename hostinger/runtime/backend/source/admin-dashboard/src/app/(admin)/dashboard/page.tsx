import Link from 'next/link';
import {authorize} from '@/lib/r4/security';
export default async function Page(){const a=await authorize('dashboard.read');return <><h1 className="text-2xl">YouNew Admin</h1><p>Заявки, редакторские черновики и журнал обработки.</p><p><Link href="/content">Каталог: редакторские черновики</Link></p>{['owner','admin'].includes(a.role)&&<p><Link href="/business-inquiries">Открыть бизнес-заявки</Link></p>}{a.role==='owner'&&<p><Link href="/history">Сохранённая история</Link></p>}</>;}
