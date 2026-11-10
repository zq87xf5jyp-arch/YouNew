import {catalogList} from '@/lib/r4/catalog';
import {signedIn} from '@/lib/r4/security';
import {CatalogEditor} from '@/components/admin/catalog-editor';
import {productionMode} from '@/lib/r4/runtime-mode';
export const dynamic='force-dynamic';
export default async function Page(){const actor=await signedIn();return <CatalogEditor initial={await catalogList()} role={actor.role} readOnly={productionMode()}/>;}
