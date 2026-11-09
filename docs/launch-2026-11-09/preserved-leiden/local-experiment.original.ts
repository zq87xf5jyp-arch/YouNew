// Explicit opt-in QA only, in memory. Never sends requests, cookies or identifiers.
const names = new Set(['search','card_open','official_source_click','directions_open','lead_start','lead_submit']);
type BoundedEvent = {name:string;resultCount?:number;zeroResult?:boolean};
declare global { interface Window { __YOUNEW_LOCAL_EVENTS__?: {name:string;resultCount?:number;environment:'test';language:'en'|'nl'}[]; } }
export function localEvent(event:BoundedEvent,language:'en'|'nl') {
 if(!names.has(event.name))return [];
 const row={name:event.name,environment:'test' as const,language};
 if(event.name!=='search')return [row];
 const resultCount=Number.isFinite(event.resultCount)?Math.max(0,Math.min(100000,Math.trunc(event.resultCount!))):0;
 return [{...row,resultCount},...(resultCount===0?[{...row,name:'search_zero',resultCount}]:[])];
}
export function captureLocalEvent(event:BoundedEvent) {
 if(typeof window==='undefined'||!['127.0.0.1','localhost'].includes(window.location.hostname))return;
 try {if(sessionStorage.getItem('younew.local-event-check')!=='enabled')return;} catch {return;}
 const rows=localEvent(event,location.pathname.startsWith('/nl/')?'nl':'en');
 window.__YOUNEW_LOCAL_EVENTS__=[...(window.__YOUNEW_LOCAL_EVENTS__??[]),...rows].slice(-300);
}
