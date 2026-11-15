import {cp,mkdir,rm} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {readPlaceReview,reviewPath,placeReviewBatches} from './place-review.mjs';
const root=fileURLToPath(new URL('../../../',import.meta.url));
const publicRoot=fileURLToPath(new URL('../public',import.meta.url));
const reviewTarget=`${publicRoot}/images/place-review`;
const selected=process.env.YOUNEW_PLACE_REVIEW;
if(selected) {
  reviewPath(selected);
  if(process.env.YOUNEW_PRIVATE_REVIEW_BUILD!=='1')throw Error('private review build required');
}
// Only registered generated directories are removed; retain published batch
// assets when another batch is being privately reviewed.
await rm(reviewTarget,{recursive:true,force:true});
for(const batch of placeReviewBatches) {
  const {reviewer}=await readPlaceReview(root,batch);
  const publishedTarget=`${publicRoot}/images/places/${batch}`;
  await rm(publishedTarget,{recursive:true,force:true});
  const target=batch===selected?reviewTarget:reviewer?publishedTarget:null;
  if(target) {await mkdir(target,{recursive:true});await cp(`${root}/${reviewPath(batch)}/media`,target,{recursive:true});}
}
