import {EditorialIndex} from '@/components/editorial-index';
import {metadataForPage} from '@/lib/seo/metadata';
export const metadata=metadataForPage('Leiden ontdekken','Praktische gidsen, plekken en selecties met bronnen.','/nl/leiden',{locale:'nl'});
export default function Page(){return <EditorialIndex locale="nl"/>;}
