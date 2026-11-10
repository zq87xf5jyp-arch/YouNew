import Link from "next/link";
import {MapPin, ExternalLink} from "lucide-react";
import {PlaceContactDetails} from "@/components/place-contact-details";
import {SaveButton} from "@/components/save-button";
import {ShareButton} from "@/components/share-button";
import {getPublicContent} from "@/lib/content";
import type {ContentEntity, EditorialBlock, EditorialSource} from "@/lib/content/types";
import {serializeJsonLd} from "@/lib/seo/json-ld";
import "@/styles/editorial.css";

export function editorialRoute(entity: ContentEntity, locale: "en"|"nl") {
  return locale==='en' ? entity.route : `/nl/${entity.type==='place'?'plaatsen':'gidsen'}/${entity.slug}`;
}
export function EditorialDetail({entity,locale='en'}:{entity:ContentEntity;locale?:'en'|'nl'}) {
  const content=entity.editorial!; const nl=locale==='nl'; const copy=content.locales[locale]; const guide=copy.guide;
  const sources=guide?.sources ?? content.sources;
  const route=editorialRoute(entity,locale);
  const related=getPublicContent().entities.filter(e=>entity.relatedEntityIds.includes(e.id));
  const labels=nl?{EXPLORE:'Plekken',LIVE:'Praktische gids',COLLECTIONS:'Selectie',BUSINESS:'Voor bedrijven'}:{EXPLORE:'Places',LIVE:'Practical guide',COLLECTIONS:'Collection',BUSINESS:'For businesses'};
  const sourceLinks=(item:EditorialBlock)=> <span className="editorial-source-links">{item.sourceIds.map(id=>sources.find(s=>s.id===id)).filter((s):s is EditorialSource=>!!s).map(s=><a href={s.url} key={s.id} rel="noreferrer" target="_blank">{s.publisher}<ExternalLink aria-hidden /></a>)}</span>;
  const list=(items:readonly EditorialBlock[])=> <ul>{items.map(item=><li key={item.id}><p>{item.text}</p>{sourceLinks(item)}</li>)}</ul>;
  const report=`mailto:support@younew.nl?subject=${encodeURIComponent(`${nl?'Correctie':'Correction'}: ${copy.title} (${entity.id})`)}`;
  return <article className="section-shell editorial-detail" lang={locale}>
    <nav className="editorial-breadcrumb" aria-label={nl?'Navigatie':'Navigation'}><Link href={nl?'/nl/leiden/':'/leiden/'}>Leiden</Link><span aria-hidden> / </span><span>{labels[content.section]}</span></nav>
    <header><span className="entity-kind">{labels[content.section]}</span><h1>{copy.title}</h1><p className="editorial-summary">{copy.summary}</p>
      <div className="editorial-actions"><SaveButton item={{id:entity.id,route,title:copy.title,kind:entity.type}}/><ShareButton title={copy.title}/><Link href={editorialRoute(entity,nl?'en':'nl')} hrefLang={nl?'en':'nl'}>{nl?'Read in English':'Lees in het Nederlands'}</Link></div>
      {entity.cityId?<p><MapPin aria-hidden className="editorial-inline-icon"/> {entity.cityId.replaceAll('-',' ')}</p>:null}
    </header>
    <div className="editorial-columns"><div>
      {entity.type==='place'?<PlaceContactDetails details={entity.placeDetails} locale={locale}/>:null}
      {entity.coordinate?<p><Link href={`/map/?city=${entity.cityId}`}>{nl?'Bekijk op de kaart':'View on the map'}</Link></p>:null}
      {guide?<>
        {guide.audience?<section><h2>{nl?'Voor wie':'Who this is for'}</h2><p>{guide.audience.text}</p>{sourceLinks(guide.audience)}</section>:null}
        {guide.situation && guide.situation.text!==guide.audience?.text?<section><h2>{nl?'Wanneer je dit nodig hebt':'When you need this'}</h2><p>{guide.situation.text}</p>{sourceLinks(guide.situation)}</section>:null}
        <section><h2>{nl?'Stappen':'Steps'}</h2><ol className="editorial-steps">{guide.steps.map(s=><li key={s.id}><p>{s.text}</p>{sourceLinks(s)}</li>)}</ol></section>
        {guide.documents.length?<section><h2>{nl?'Benodigde documenten':'Required documents'}</h2>{list(guide.documents)}</section>:null}
        {guide.sections.map(s=><section key={s.id}><h2>{s.title}</h2><p>{s.text}</p>{sourceLinks(s)}</section>)}
        {guide.warnings.length?<section className="safety-note"><h2>{nl?'Let op':'Important'}</h2>{list(guide.warnings)}</section>:null}
        <p className="editorial-disclaimer">{guide.disclaimer}</p>
      </>:null}
      {content.section==='BUSINESS'?<p><Link className="button button-primary" href={`${nl?'/nl/voor-bedrijven/aanmelden/':'/for-business/local/apply/'}?action=${entity.id.endsWith('-add')?'add':'claim'}`}>{nl?'Aanvraag indienen':'Submit a request'}</Link></p>:null}
      {related.length?<section><h2>{content.section==='COLLECTIONS'?(nl?'Plekken in deze selectie':'Places in this collection'):(nl?'Gerelateerde informatie':'Related information')}</h2><ul className="editorial-related">{related.map(e=><li key={e.id}><Link href={e.editorial?editorialRoute(e,locale):e.route}>{e.editorial?.locales[locale].title ?? e.title}</Link><p>{e.editorial?.locales[locale].summary ?? e.summary}</p></li>)}</ul></section>:null}
    </div><aside className="editorial-sources"><h2>{nl?'Bronnen':'Sources'}</h2><ul>{sources.map((s,i)=><li key={`${s.id}-${i}`}><a href={s.url} target="_blank" rel="noreferrer">{s.publisher}<ExternalLink aria-hidden /></a><small>{nl?'Gecontroleerd':'Checked'} <time dateTime={s.checkedAt}>{s.checkedAt}</time></small></li>)}</ul>
      <p>{nl?'Redactioneel beoordeeld':'Editorially reviewed'} <time dateTime={content.reviewedAt}>{content.reviewedAt}</time></p>
      {content.section==='COLLECTIONS'?<p>{nl?'Een redactionele selectie van YouNew; geen aanbeveling namens de genoemde locaties.':'A YouNew editorial selection; not an endorsement by the listed places.'}</p>:null}
      <a href={report}>{nl?'Meld een correctie':'Report a correction'}</a>
    </aside></div>
    <script type="application/ld+json" dangerouslySetInnerHTML={{__html:serializeJsonLd({'@context':'https://schema.org','@type':entity.type==='place'?'Place':'Article',name:copy.title,headline:copy.title,description:copy.summary,url:`https://younew.nl${route}/`,inLanguage:locale,dateModified:content.reviewedAt,citation:sources.map(s=>s.url),...(entity.coordinate?{geo:{'@type':'GeoCoordinates',latitude:entity.coordinate.latitude,longitude:entity.coordinate.longitude}}:{})})}}/>
  </article>;
}
