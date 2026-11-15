import {cp,mkdir,rm} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {readPlaceReview,placeReviewPath,placeReviewBatch,placePublishedMediaPath} from './place-review.mjs';
const root=fileURLToPath(new URL('../../../',import.meta.url));
const publicRoot=fileURLToPath(new URL('../public',import.meta.url));
const reviewTarget=`${publicRoot}/images/place-review`;
const publishedTarget=`${publicRoot}${placePublishedMediaPath}`;
const {reviewer}=await readPlaceReview(root);
// These two reserved directories contain only generated copies of this batch.
await rm(reviewTarget,{recursive:true,force:true});
await rm(publishedTarget,{recursive:true,force:true});
let target=null;
if(process.env.YOUNEW_PLACE_REVIEW) {
  if(process.env.YOUNEW_PLACE_REVIEW!==placeReviewBatch||process.env.YOUNEW_PRIVATE_REVIEW_BUILD!=='1')throw Error('private review build required');
  target=reviewTarget;
} else if(reviewer) target=publishedTarget;
if(target) {await mkdir(target,{recursive:true});await cp(`${root}/${placeReviewPath}/media`,target,{recursive:true});}
