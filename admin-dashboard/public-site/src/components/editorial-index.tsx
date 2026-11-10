import Link from 'next/link';
import {PageShell} from './page-shell';
import {EntityCard} from './entity-card';
import {NlEntityCard} from './nl-entity-card';
import {getPublicContent} from '@/lib/content';
import '@/styles/editorial.css';
export function EditorialIndex({locale='en'}:{locale?:'en'|'nl'}){
  const nl=locale==='nl';const records=getPublicContent().entities.filter(e=>e.editorial);
  const sections=nl?{LIVE:'Praktisch leven in Leiden',EXPLORE:'Plekken in Leiden en andere steden',COLLECTIONS:'Selecties voor Leiden',BUSINESS:'Voor bedrijven'}:{LIVE:'Practical life in Leiden',EXPLORE:'Places in Leiden and other cities',COLLECTIONS:'Leiden collections',BUSINESS:'For businesses'};
  return <PageShell locale={locale}><div className="section-shell editorial-index"><h1>{nl?'Leiden ontdekken':'Discover Leiden'}</h1><p>{nl?'Praktische gidsen, plekken en selecties met bronnen. Bekijk de vermelde stad bij iedere locatie.':'Practical guides, places and collections with sources. Check the listed city for each place.'}</p><Link href={nl?'/leiden/':'/nl/leiden/'}>{nl?'Read in English':'Lees in het Nederlands'}</Link><nav className="topic-links" aria-label={nl?'Onderwerpen':'Topics'}>{Object.entries(sections).map(([key,title])=><a key={key} href={`#${key.toLowerCase()}`}>{title}</a>)}</nav>{Object.entries(sections).map(([section,title])=><section id={section.toLowerCase()} key={section}><h2>{title}</h2><div className="entity-grid">{records.filter(e=>e.editorial?.section===section).map(e=>nl?<NlEntityCard key={e.id} entity={e}/>:<EntityCard key={e.id} entity={e}/>)}</div></section>)}</div></PageShell>;
}
