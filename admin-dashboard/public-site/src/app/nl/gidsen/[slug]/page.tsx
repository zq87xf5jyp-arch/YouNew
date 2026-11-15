import {guideNavigation} from "@/lib/content/guide-navigation";
import {PracticalGuideArticle} from '@/components/practical-guide-article';
import {notFound} from 'next/navigation';
import {PageShell} from '@/components/page-shell';
import {EditorialDetail} from '@/components/editorial-detail';
import {editorialMetadata} from '@/lib/content/editorial-metadata';
import {getPublicContent,getContentEntity} from '@/lib/content';
export const dynamicParams=false;
export function generateStaticParams(){return getPublicContent().guides.filter(e=>e.editorial || e.practicalGuideLocales?.nl).map(e=>({slug:e.slug}));}
export async function generateMetadata({params}:{params:Promise<{slug:string}>}){const e=getContentEntity('guide',(await params).slug);return e && (e.editorial || e.practicalGuideLocales?.nl)?editorialMetadata(e,'nl'):{};}
export default async function Page({params}:{params:Promise<{slug:string}>}){const e=getContentEntity('guide',(await params).slug);if(!e || (!e.editorial && !e.practicalGuideLocales?.nl))notFound();return <PageShell locale="nl">{e.practicalGuideLocales?.nl ? <PracticalGuideArticle {...guideNavigation(e.slug,"nl")} guide={e.practicalGuideLocales.nl} media={e.images[0]} alternate={{title:"Read in English",href:`${e.route}/`}}/> : <EditorialDetail entity={e} locale="nl"/>}</PageShell>;}
