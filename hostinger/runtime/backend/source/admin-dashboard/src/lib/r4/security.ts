import 'server-only';
import {cookies,headers} from 'next/headers';
import {createHash,randomBytes,scrypt as rawScrypt,timingSafeEqual} from 'node:crypto';
import {db,rows,transaction,type Conn} from './db';
import type {AdminRole} from '../authorization';
export class Denied extends Error {constructor(public status:number,public code:string){super(code);}}
export const hash=(s:string|Buffer)=>createHash('sha256').update(s).digest('hex');
let activeHashes=0;
export const COOKIE='younew_hostprep_session';
export function origin(){const s=process.env.R4_ORIGIN;if(!s) throw new Error('Origin required');const u=new URL(s);if(u.origin!==s || (u.protocol!=='https:' && !(process.env.R4_LOCAL==='true' && s==='http://127.0.0.1:4404'))) throw new Error('Invalid origin');return s;}
export async function mutationGuard(){const h=await headers();if(h.get('origin')!==origin() || h.get('host')!==new URL(origin()).host)throw new Denied(403,'origin_denied');}
export type Actor={id:string;workspace_id:string;email:string;full_name:string;role:AdminRole};
export async function actor(c?:Pick<Conn,'execute'>,lock=false):Promise<Actor>{
 const token=(await cookies()).get(COOKIE)?.value;
 if(!token || !/^[a-f0-9]{64}$/.test(token))throw new Denied(401,'authentication_required');
 const [p]=await rows(c??db(),`SELECT p.id,p.workspace_id,p.email,p.full_name,p.role,p.is_approved,p.is_blocked FROM sessions s JOIN profiles p ON p.id=s.profile_id WHERE s.token_hash=? AND s.revoked_at IS NULL AND s.expires_at>UTC_TIMESTAMP(3)${lock?' FOR UPDATE':''}`,[hash(token)]);
 if(!p)throw new Denied(401,'authentication_required');
 if(!p.is_approved || p.is_blocked)throw new Denied(403,'account_denied');
 return {id:p.id,workspace_id:p.workspace_id,email:p.email,full_name:p.full_name,role:p.role};
}
const policies:Record<string,readonly string[]>={ 'catalog.read':['owner','admin','editor','qa','viewer'],'catalog.write':['owner','admin','editor'],'catalog.approve':['owner','admin'], 'crm.read':['owner','admin'],'crm.write':['owner','admin'],'files.read':['owner','admin'],'files.write':['owner','admin'],'audit.read':['owner','admin'],'dashboard.read':['owner','admin','editor','qa','viewer']};
export function permit(a:Actor,capability:string){if(!policies[capability]?.includes(a.role))throw new Denied(403,'forbidden');}
export async function authorize(cap:string,c?:Pick<Conn,'execute'>,lock=false){const a=await actor(c,lock);permit(a,cap);return a;}
export async function signedIn(){return actor();}
export async function login(email:unknown,password:unknown){
 await mutationGuard();
 if(typeof email!=='string'||typeof password!=='string'||email.length>254||password.length>256)throw new Denied(401,'invalid_credentials');
 const normalized=email.trim().toLowerCase(), window=Math.floor(Date.now()/900000);
 await transaction(async c=>{for(const identity of ['account:'+normalized,'global']){const key=hash(identity+':'+window);await c.execute('INSERT INTO auth_attempts(bucket,total,expires_at) VALUES(?,1,DATE_ADD(UTC_TIMESTAMP(3),INTERVAL 15 MINUTE)) ON DUPLICATE KEY UPDATE total=total+1',[key]);const [r]=await rows(c,'SELECT total FROM auth_attempts WHERE bucket=?',[key]);if(r.total>(identity==='global'?1000:10))throw new Denied(429,'rate_limited');}});
 const [p]=await rows(db(),'SELECT id,password_hash,is_approved,is_blocked FROM profiles WHERE email=?',[normalized]);
 const stored=p?.password_hash ?? process.env.R4_DUMMY_PASSWORD_HASH;
 if(!stored)throw new Error('Dummy hash required');
 const [version,salt,digest]=stored.split('$');
 if(version!=='scrypt32768' || !/^[a-f0-9]{128}$/.test(digest??''))throw new Error('Invalid credential record');
 if(activeHashes>=2)throw new Denied(429,'rate_limited');activeHashes++;
 let actual:Buffer;try{actual=await new Promise<Buffer>((resolve,reject)=>rawScrypt(password,salt,64,{N:32768,r:8,p:1,maxmem:64*1024*1024},(e,v)=>e?reject(e):resolve(v)));}finally{activeHashes--;}
 if(!p || !timingSafeEqual(Buffer.from(digest,'hex'),actual))throw new Denied(401,'invalid_credentials');
 if(!p.is_approved||p.is_blocked)throw new Denied(403,'account_denied');
 const token=randomBytes(32).toString('hex');
 await transaction(async c=>{const [current]=await rows(c,'SELECT is_approved,is_blocked,password_hash FROM profiles WHERE id=? FOR UPDATE',[p.id]);if(!current?.is_approved||current.is_blocked||current.password_hash!==stored)throw new Denied(403,'account_denied');await c.execute('INSERT INTO sessions(token_hash,profile_id,expires_at) VALUES(?,?,DATE_ADD(UTC_TIMESTAMP(3),INTERVAL 8 HOUR))',[hash(token),p.id]);});
 (await cookies()).set(COOKIE,token,{httpOnly:true,secure:new URL(origin()).protocol==='https:',sameSite:'strict',path:'/',maxAge:8*3600});
 return {ok:true};
}
export async function logout(){await mutationGuard();const token=(await cookies()).get(COOKIE)?.value;if(token)await db().execute('UPDATE sessions SET revoked_at=UTC_TIMESTAMP(3) WHERE token_hash=?',[hash(token)]);(await cookies()).delete(COOKIE);}
export function safeError(e:unknown){if(e instanceof Denied)return {status:e.status,body:{error:e.code}};return {status:503,body:{error:'service_unavailable'}};}
