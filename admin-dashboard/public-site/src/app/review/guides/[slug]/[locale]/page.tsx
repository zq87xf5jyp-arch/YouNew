import Link from 'next/link';
import {notFound} from 'next/navigation';
import type {Metadata} from 'next';
import {guideReview as review} from '@/lib/content/guide-review';
import {PageShell} from '@/components/page-shell';
import {PracticalGuideArticle} from '@/components/practical-guide-article';
import type {PracticalGuideDraft} from '@/lib/content/types';
export const dynamicParams=false;
export const metadata:Metadata={title:'Private editorial review',robots:{index:false,follow:false},alternates:{canonical:null,languages:{}},openGraph:{url:undefined}};
export function generateStaticParams(){return review.guides.length ? review.guides.map(x=>({slug:x.guide.slug,locale:x.guide.locale})) : [{slug:'__empty__',locale:'en'}];}
export default async function Page({params}:{params:Promise<{slug:string;locale:string}>}){
 const {slug,locale}=await params;
 const entry=review.guides.find(x=>x.guide.slug===slug&&x.guide.locale===locale);
 if(!review.enabled||!entry||(locale!=='en'&&locale!=='nl'))notFound();
 const guide=entry.guide as PracticalGuideDraft;
 const order=review.guides.filter(x=>x.guide.locale===locale);
 const index=order.findIndex(x=>x.guide.slug===slug);
 const nav=(offset:number)=>order[index+offset]?{title:order[index+offset].guide.title,href:`/review/guides/${order[index+offset].guide.slug}/${locale}/`}:undefined;
 return <PageShell locale={locale}><p className="section-shell"><Link href="/review/guides/">Editorial review index</Link></p><PracticalGuideArticle guide={guide} alternate={{title:locale==='nl'?'Read in English':'Lees in het Nederlands',href:`/review/guides/${slug}/${locale==='nl'?'en':'nl'}/`}} before={nav(-1)} next={nav(1)} media={{url:`/images/guide-workflow-${locale}.svg`,alt:locale==='nl'?'Controleer de bron, volg de stappen, controleer het resultaat.':'Check the source, follow the steps, check the result.',attribution:'Original YouNew diagram · editorial rights review pending'}}/><aside className="section-shell"><h2>Release blockers</h2><ul>{entry.blockers.map(b=><li key={b}>{b}</li>)}</ul><p>Batch SHA-256: {review.digest}</p></aside></PageShell>;
}
