import Link from 'next/link';
import {getPublicContent} from '@/lib/content';
import {EntityCard} from './entity-card';
import {NlEntityCard} from './nl-entity-card';

// Collections are emitted by the same approved editorial release as their places.
export function EditorialCollections({locale='en',memberId}:{locale?:'en'|'nl';memberId?:string}) {
  const data=getPublicContent(),nl=locale==='nl';
  const collections=(data.editorialCollections??[]).filter(c=>!memberId||c.entityIds.includes(memberId));
  if(!collections.length)return null;
  return <section className="section-shell editorial-collections" id="visit-selections">
    <h2 className="text-2xl font-semibold mt-8 mb-4">{nl?'Thematische selecties':'Themed selections'}</h2>
    {collections.map(c=>{
      const places=c.entityIds.map(id=>data.entities.find(e=>e.id===id)).filter(e=>!!e);
      const sources=[...new Map(c.sources.map(s=>[`${s.url}:${s.checkedAt}`,s])).values()];
      return <section className="mb-10" id={`collection-${c.key}`} key={c.key}>
        <h3 className="text-xl font-semibold mt-6 mb-3">{c.title[locale]}</h3><p className="mb-4 max-w-prose">{c.description[locale]}</p>
        {memberId?<ul className="editorial-related">{places.map(e=><li key={e.id}><Link href={nl?`/nl/plaatsen/${e.slug}/`:e.route}>{e.editorial?.locales[locale].title??e.title}</Link></li>)}</ul>:<div className="entity-grid">{places.map(e=>nl?<NlEntityCard key={e.id} entity={e}/>:<EntityCard key={e.id} entity={e}/>)}</div>}
        <details><summary>{nl?'Bronnen en controledatums':'Sources and check dates'}</summary><ul>{sources.map(s=><li key={`${s.url}:${s.checkedAt}`}><a href={s.url} target="_blank" rel="noreferrer">{s.publisher}</a> · <time dateTime={s.checkedAt}>{s.checkedAt}</time></li>)}</ul></details>
        <p>{nl?'Redactionele selectie van YouNew; geen gezamenlijk arrangement of aanbeveling namens de locaties.':'An editorial selection by YouNew; not a joint package or an endorsement by the venues.'}</p>
      </section>;
    })}
  </section>;
}
