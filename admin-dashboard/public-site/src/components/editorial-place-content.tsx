import {ContentMedia,preferredMedia} from '@/components/content-media';
import type {ContentEntity} from '@/lib/content/types';
export function EditorialPlaceContent({entity,locale}:{entity:ContentEntity;locale:'en'|'nl'}) {
  const place=entity.editorial?.place;if(!place)return null;
  const nl=locale==='nl';const copy=place.locales[locale];const media=preferredMedia(entity.images,['hero']);
  const sources=entity.editorial!.sources;
  return <section className="editorial-place" aria-label={nl?'Over deze plek':'About this place'}>
    {media?<ContentMedia asset={{...media,alt:copy.alt}} variant="hero" eager/>:null}
    <div className="editorial-actions">
      {entity.coordinate?<a className="button button-secondary" href={`https://www.google.com/maps/dir/?api=1&destination=${entity.coordinate.latitude},${entity.coordinate.longitude}`} target="_blank" rel="noreferrer">{nl?'Route':'Directions'}</a>:null}
      {entity.placeDetails?.website?<a className="button button-secondary" href={entity.placeDetails.website.value} target="_blank" rel="noreferrer">Website</a>:null}
      {place.tickets?<a className="button button-primary" href={place.tickets.url} target="_blank" rel="noreferrer">Tickets</a>:null}
    </div>
    {copy.blocks.map(block=><section key={block.id} className={block.id==='warning'?'safety-note':undefined}>
      {block.title?<h2>{block.title}</h2>:null}<p>{block.text}</p>
      <span className="editorial-source-links">{block.sourceIds.map(id=>sources.find(s=>s.id===id)).filter(s=>!!s).map(s=><a href={s.url} target="_blank" rel="noreferrer" key={s.id}>{s.title} · <time dateTime={s.checkedAt}>{s.checkedAt}</time></a>)}</span>
    </section>)}
    {entity.images.some(image=>image.placement==='archive_gallery_only')?<section className="editorial-archive-gallery"><h2>{nl?'Archieffoto’s':'Archive photographs'}</h2><p>{nl?'Deze beelden tonen de vermelde opnamedatum, niet noodzakelijk de huidige situatie.':'These images show their stated capture dates, not necessarily the current situation.'}</p>{entity.images.filter(image=>image.placement==='archive_gallery_only').map(image=><div key={image.id}><p>{image.captions?.[locale]??image.alt}</p><ContentMedia asset={{...image,alt:image.captions?.[locale]??image.alt}} variant="gallery"/></div>)}</section>:null}
    <p className="editorial-disclaimer">{nl?'Bij elk onderdeel staat de controledatum van de bijbehorende bron.':'Source check dates are shown beside each fact.'} {nl?'Controleer de officiële pagina voor vertrek; foto’s tonen de vermelde opnamedatum.':'Recheck the official page before travel; photographs show their stated capture dates.'}</p>
  </section>;
}
