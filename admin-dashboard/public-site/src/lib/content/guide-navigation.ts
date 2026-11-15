import {getPublicContent} from '@/lib/content';
const order=['leiden-student-housing','leiden-bsn','leiden-digid','leiden-student-health-insurance','leiden-gp','leiden-registration'];
export function guideNavigation(slug:string,locale:'en'|'nl') {
 const index=order.indexOf(slug);
 const published=getPublicContent().guides;
 const lookup=(slugs:string[])=>{
  for(const candidate of slugs){
   const entity=published.find(e=>e.slug===candidate);
   if(entity && (locale==='en'||entity.editorial||entity.practicalGuideLocales?.nl))return {title:entity.practicalGuideLocales?.[locale]?.title ?? entity.editorial?.locales[locale].title ?? entity.title,href:locale==='en'?`${entity.route}/`:`/nl/gidsen/${entity.slug}/`};
  }
  return undefined;
 };
 return index<0?{}:{before:lookup(order.slice(0,index).reverse()),next:lookup(order.slice(index+1))};
}
