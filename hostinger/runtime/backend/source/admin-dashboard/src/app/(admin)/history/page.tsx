import Link from 'next/link';
import {notFound} from 'next/navigation';
import {requireAdmin} from '@/lib/auth';
import {historyTables,historyRows,historyAssets} from '@/lib/r4/history';
export const dynamic='force-dynamic';
export default async function Page({searchParams}:{searchParams:Promise<{table?:string;page?:string}>}){
 if((await requireAdmin()).role!=='owner')notFound();
 const query=await searchParams,[tables,assets]=await Promise.all([historyTables(),historyAssets()]);
 const table=tables.find(t=>t.table_name===query.table),page=Number(query.page??0);
 if(!Number.isInteger(page)||page<0||page>1000||(query.table&&!table))notFound();
 const records=table?await historyRows(String(table.table_name),page):[];
 return <section className="space-y-5"><h1 className="text-2xl font-semibold">Сохранённая история</h1>
 <p>Исходные записи до переноса. Доступны только владельцу и не изменяются. Текущая обработка заявок находится в разделе «Бизнес-заявки».</p>
 <div className="flex flex-wrap gap-3">{tables.map(t=><Link className="underline break-all" key={String(t.table_name)} href={'/history?table='+encodeURIComponent(String(t.table_name))}>{String(t.table_name).replace('public.','')} ({Number(t.row_count)})</Link>)}</div>
 {table&&<><h2 className="text-lg font-semibold">{String(table.table_name)} · {Number(table.row_count)} записей</h2>
 {records.map(r=><details className="border rounded p-3" key={r.index}><summary>Запись {r.index+1}</summary><pre className="mt-3 whitespace-pre-wrap break-words text-xs">{JSON.stringify(r.values,null,2)}</pre></details>)}
 <div className="flex gap-4">{page>0&&<Link className="underline" href={'/history?table='+encodeURIComponent(String(table.table_name))+'&page='+(page-1)}>Назад</Link>}{(page+1)*25<Number(table.row_count)&&<Link className="underline" href={'/history?table='+encodeURIComponent(String(table.table_name))+'&page='+(page+1)}>Далее</Link>}</div></>}
 {assets.length>0&&<div className="space-y-2"><h2 className="text-lg font-semibold">Сохранённые файлы</h2>{assets.map(f=><p className="break-all" key={String(f.id)}><a className="underline" href={'/api/r4/history-files/'+String(f.id)}>Скачать файл {String(f.id)}</a> · {Number(f.bytes)} байт</p>)}</div>}
 {!tables.length&&<p>История ещё не импортирована в эту среду.</p>}</section>;
}
