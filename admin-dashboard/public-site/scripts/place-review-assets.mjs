import {cp,mkdir,rm} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {readPlaceReview,reviewPath,placeReviewBatches,selectedPlaceReviews} from './place-review.mjs';
const root=fileURLToPath(new URL('../../../',import.meta.url));
const publicRoot=fileURLToPath(new URL('../public',import.meta.url));
const reviewTarget=`${publicRoot}/images/place-review`;
const selected=selectedPlaceReviews();
// Only registered generated directories are removed; retain published batch
// assets when another batch is being privately reviewed.
await rm(reviewTarget,{recursive:true,force:true});
for(const batch of placeReviewBatches) {
  const {reviewer,manifest}=await readPlaceReview(root,batch);
  const publishedTarget=`${publicRoot}/images/places/${batch}`;
  await rm(publishedTarget,{recursive:true,force:true});
  const target=selected.includes(batch)?reviewTarget:reviewer?publishedTarget:null;
  if(target) {
    await mkdir(target,{recursive:true});
    // Copy only active, hash-validated derivatives. Retained evidence is not served.
    for(const file of Object.keys(manifest.media))await cp(`${root}/${reviewPath(batch)}/media/${file}`,`${target}/${file}`);
  }
}
