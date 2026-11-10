import {notFound} from 'next/navigation';
import {PageShell} from '@/components/page-shell';
import {EditorialDetail} from '@/components/editorial-detail';
import {editorialMetadata} from '@/lib/content/editorial-metadata';
import {getPublicContent,getContentEntity} from '@/lib/content';
export const dynamicParams=false;
export function generateStaticParams(){return getPublicContent().guides.filter(e=>e.editorial).map(e=>({slug:e.slug}));}
export async function generateMetadata({params}:{params:Promise<{slug:string}>}){const e=getContentEntity('guide',(await params).slug);return e?.editorial?editorialMetadata(e,'nl'):{};}
export default async function Page({params}:{params:Promise<{slug:string}>}){const e=getContentEntity('guide',(await params).slug);if(!e?.editorial)notFound();return <PageShell locale="nl"><EditorialDetail entity={e} locale="nl"/></PageShell>;}
