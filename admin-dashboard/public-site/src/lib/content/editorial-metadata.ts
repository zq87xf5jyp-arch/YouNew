import type {Metadata} from 'next';
import type {ContentEntity} from './types';
export function editorialMetadata(entity:ContentEntity,locale:'en'|'nl'='en'):Metadata {
  const full=entity.practicalGuideLocales?.[locale];
  const copy=full ? {title:full.seo.title,summary:full.seo.description} : entity.editorial!.locales[locale];
  const en=`https://younew.nl${entity.route}/`;
  const nl=`https://younew.nl/nl/${entity.type==='place'?'plaatsen':'gidsen'}/${entity.slug}/`;
  return {title:{absolute:`${copy.title} | YouNew`},description:copy.summary.slice(0,160),alternates:{canonical:locale==='en'?en:nl,languages:{en,nl,'x-default':en}},openGraph:{title:copy.title,description:copy.summary.slice(0,160),url:locale==='en'?en:nl,locale:locale==='en'?'en_US':'nl_NL',type:'article'}};
}
