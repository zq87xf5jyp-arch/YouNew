import {cp,mkdir,rm} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {readPlaceReview,reviewPath} from './place-review.mjs';
const root=fileURLToPath(new URL('../../../',import.meta.url));
const target=fileURLToPath(new URL('../public/images/place-review',import.meta.url));
if(process.env.YOUNEW_PLACE_REVIEW) {
  if(process.env.YOUNEW_PRIVATE_REVIEW_BUILD!=='1')throw Error('private review build required');
  const batch=process.env.YOUNEW_PLACE_REVIEW;
  const {manifest}=await readPlaceReview(root,batch);
  await rm(target,{recursive:true,force:true});
  if(Object.keys(manifest.media).length){await mkdir(target,{recursive:true});await cp(`${root}/${reviewPath(batch)}/media`,target,{recursive:true});}
} else await rm(target,{recursive:true,force:true}); // Only this generated, reserved review directory.
