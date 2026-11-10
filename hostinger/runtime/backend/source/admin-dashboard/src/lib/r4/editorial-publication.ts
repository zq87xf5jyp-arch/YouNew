import {createHash} from 'node:crypto';
import approval from '../../generated/editorial-approval.json' with {type:'json'};

function canonical(value:unknown):string {
 if(Array.isArray(value))return '['+value.map(canonical).join(',')+']';
 if(value&&typeof value==='object')return '{'+Object.entries(value).sort(([a],[b])=>a<b?-1:a>b?1:0).map(([k,v])=>JSON.stringify(k)+':'+canonical(v)).join(',')+'}';
 return JSON.stringify(value);
}
// A receipt is installed only after the same public payload passes production checks.
// Approval alone, or an edited private catalogue, must never report publication.
export function editorialPublished(data:{entities:unknown[];publication?:unknown}):boolean {
 if(data.publication===undefined)return false;
 const p=data.publication as Record<string,unknown>;
 if(!p||p.status!=='active'||p.releaseId!==approval.releaseId||p.batchSha256!==approval.batchSha256||p.documentsSha256!==approval.documentsSha256||!/^([a-f0-9]{40})$/.test(String(p.sourceCommit))||!/^([a-f0-9]{64})$/.test(String(p.publicProvenanceSha256))||typeof p.activatedAt!=='string'||!Number.isFinite(Date.parse(p.activatedAt))||Date.parse(p.activatedAt)>Date.now())throw new Error('Invalid editorial publication receipt');
 if(data.entities.length!==approval.count||createHash('sha256').update(canonical(data.entities)).digest('hex')!==approval.documentsSha256)throw new Error('Editorial source differs from approved publication');
 return true;
}
