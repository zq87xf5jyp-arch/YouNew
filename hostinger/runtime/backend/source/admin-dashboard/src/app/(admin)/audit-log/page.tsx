import {notFound} from 'next/navigation';
import {requireAdmin} from '@/lib/auth';
import {audit} from '@/lib/r4/repository';
export const dynamic='force-dynamic';
export default async function Page(){
 if(!['owner','admin'].includes((await requireAdmin()).role))notFound();
 const events=await audit();
 return <section className="space-y-4"><h1 className="text-2xl font-semibold">Журнал действий</h1><p>Последние 100 изменений в текущем рабочем пространстве. История до переноса сохранена в отдельном разделе.</p>
 {!events.length&&<p>Изменений пока нет.</p>}
 <div className="space-y-3">{events.map((e,index)=><article className="border rounded p-3 break-words" key={index}><p>{String(e.event)}</p><p className="text-sm text-muted-foreground">{String(e.created_at)} UTC · {String(e.object_id)}</p></article>)}</div></section>;
}
