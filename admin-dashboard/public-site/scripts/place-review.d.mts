import type {EditorialRelease} from './editorial-release.mjs';
export interface PlaceRevision {
  id:string; entity_type:string; category:string; city_id:string; province_id:string;
  lifecycle_status:string; verification_status:string; attributes:Record<string,string>;
  images:Array<{verified:boolean;license_url:string}>;
}
export interface PlaceManifest {
  ids:string[]; baseFiles:Record<string,{file:string;sha256:string}>;
  media:Record<string,{bytes:number;width:number;sha256:string}>;
}
export const placeReviewBatch:string;
export const placeReviewPath:string;
export const placeReviewBatches:string[];
export function reviewPath(batch?:string):string;
export function readPlaceReview(root:string,batchId?:string):Promise<{manifest:PlaceManifest;records:PlaceRevision[]}>;
export function validatePlaceRecords(records:PlaceRevision[],ids:string[],bases:Map<string,PlaceRevision>,allowIncomplete?:boolean):void;
export function applyPlaceReview(release:EditorialRelease,root:string,env?:Record<string,string|undefined>):Promise<EditorialRelease>;
