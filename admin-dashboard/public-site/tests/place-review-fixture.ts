import {mkdtemp,mkdir,symlink,readFile,readdir,writeFile,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {placeReviewBatches,reviewPath} from '../scripts/place-review.mjs';
import {approvalPath} from '../scripts/editorial-release.mjs';
export async function pendingReviewRoot(root:string,batches:string[]) {
 const temp=await mkdtemp(join(tmpdir(),'younew-review-gate-'));
 await mkdir(`${temp}/DataProject/editorial`,{recursive:true});
 for(const path of ['DataProject/staging','DataProject/batches','DataProject/operations',approvalPath,'DataProject/editorial/expansion-prepublication-20261115.json','DataProject/editorial/selections','DataProject/editorial/hospitality-release-review-20261116'])await symlink(`${root}/${path}`,`${temp}/${path}`);
 for(const batch of placeReviewBatches){
  const path=reviewPath(batch);if(!batches.includes(batch)){await symlink(`${root}/${path}`,`${temp}/${path}`);continue;}
  await mkdir(`${temp}/${path}`);
  for(const file of await readdir(`${root}/${path}`))if(file!=='manifest.json')await symlink(`${root}/${path}/${file}`,`${temp}/${path}/${file}`);
  const m=JSON.parse(await readFile(`${root}/${path}/manifest.json`,'utf8'));
  await writeFile(`${temp}/${path}/manifest.json`,JSON.stringify({...m,status:'needs_review',publicationAuthorized:false,approvedAt:null,reviewerId:null,...(m.privateOnly!==undefined?{privateOnly:true}:{})}));
 }
 return {root:temp,cleanup:()=>rm(temp,{recursive:true,force:true})};
}
