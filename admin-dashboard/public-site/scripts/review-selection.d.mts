import type {PlaceRevision} from './place-review.mjs';
export function verifyReviewSelection(root:string,selectionPath:string,expectedSha256:string):Promise<{sourceCommit:string;files:Record<string,{sha256:string;bytes:number}>;batches:Array<{batchId:string;ids:string[];records:number;blocksEnNl:number;photos:number}>;amsterdamPlacement:Record<string,string>}>;
export function composeTextAndPhotoReview<T extends PlaceRevision>(base:T,text:T,photo:T):T;
