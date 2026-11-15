import type {EditorialRelease} from './editorial-release.mjs';
export interface PlaceRevision {
  id:string; entity_type:string; category:string; city_id:string; province_id:string;
  lifecycle_status:string; verification_status:string; attributes:Record<string,string>;
  images:Array<{verified:boolean;license_url:string}>;
}
export interface PlaceManifest {
  status:string; publicationAuthorized:boolean; approvedAt:string|null; reviewerId:string|null;
  approvalSha256:string; recordsSha256:string; preparedAt:string; batchId:string;
  ids:string[]; baseFiles:Record<string,{file:string;sha256:string}>;
  media:Record<string,{bytes:number;width:number;sha256:string}>;
}
export const placeReviewBatch:string;
export const placeReviewBatches:string[];
export const expansionReviews:Record<string,{count:number;city?:string;bounds?:number[];cities?:Record<string,number[]>;allowPrivateAdditions?:boolean}>;
export function selectedPlaceReviews(env?:Record<string,string|undefined>):string[];
export function reviewPath(batch?:string):string;
export const placePublishedMediaPath:string;
export function placeApprovalDigest(manifest:unknown):string;
export function validatePlaceApproval(manifest:unknown,records:PlaceRevision[],registry:unknown,options?:{today:string}):{name:string}|null;
export const placeReviewPath:string;
export function readPlaceReview(root:string,batchId?:string):Promise<{manifest:PlaceManifest;records:PlaceRevision[];reviewer:{name:string}|null}>;
export function validatePlaceRecords(records:PlaceRevision[],ids:string[],bases:Map<string,PlaceRevision>,optionalTickets?:boolean,expansion?:{count:number;city?:string;bounds?:number[];cities?:Record<string,number[]>;allowPrivateAdditions?:boolean}|null):void;
export function applyPlaceReview(release:EditorialRelease,root:string,env?:Record<string,string|undefined>):Promise<EditorialRelease>;
