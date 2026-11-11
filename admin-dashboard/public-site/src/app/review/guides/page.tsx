import type {Metadata} from 'next';
import {notFound} from 'next/navigation';
import {guideReview as review} from '@/lib/content/guide-review';
import {PageShell} from '@/components/page-shell';
import '@/styles/editorial.css';
export const metadata:Metadata={title:'Leiden student guide review',robots:{index:false,follow:false},alternates:{canonical:null,languages:{}}};
export default function Page(){
 if(!review.enabled)notFound();
 return <PageShell><article className="section-shell editorial-detail"><h1>First steps in Leiden / Eerste stappen in Leiden</h1><p>Editorial draft · Sources checked 11 November 2026 · Owner EN/NL approval pending</p><p>Start with housing before travelling. When you arrive, arrange registration; then DigiD. Check insurance for your own study/work situation and find a GP. Report another move through the address-change route.</p><p>Begin vóór vertrek met huisvesting. Regel bij aankomst inschrijving en daarna DigiD. Controleer je verzekering voor je studie- of werksituatie en zoek een huisarts. Gebruik bij een volgende verhuizing de adreswijzigingsroute.</p><p>This is a proposed entry page; all instructions below are private drafts. Use the linked official sources before acting.</p><ol>{review.guides.filter(x=>x.guide.locale==='en').map(x=><li key={x.code}><h2>{x.code} · {x.guide.title}</h2><a href={`/review/guides/${x.guide.slug}/en/`}>English</a> · <a href={`/review/guides/${x.guide.slug}/nl/`}>Nederlands</a></li>)}</ol><p><a href="/arrival-planner/">Existing arrival planner</a></p><p>Review facts, language, application branches, dates, media rights, and each listed release blocker. Approval must refer to the exact digest below.</p><code style={{overflowWrap:'anywhere'}}>{review.digest}</code></article></PageShell>;
}
