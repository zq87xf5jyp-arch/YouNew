import 'server-only';
import mysql, {type RowDataPacket, type PoolConnection} from 'mysql2/promise';
import type {ExecuteValues} from 'mysql2';
let pool: ReturnType<typeof mysql.createPool> | undefined;
export function db() {
  if (!pool) {
    const {R4_DB_USER:user,R4_DB_PASSWORD:password,R4_DB_NAME:database,R4_DB_SOCKET:socketPath} = process.env;
    if (!user || !password || !database || !/^[a-zA-Z0-9_]{1,64}$/.test(database) || (process.env.R4_LOCAL==='true' && !database.startsWith('r4_'))) throw new Error('R4 DB configuration required');
    pool = mysql.createPool({user,password,database,...(socketPath ? {socketPath} : {host:process.env.R4_DB_HOST ?? '127.0.0.1',port:3306}),connectionLimit:5,charset:'utf8mb4_unicode_ci',timezone:'Z',dateStrings:true,multipleStatements:false,connectTimeout:5000,enableKeepAlive:true});
  }
  return access;
}
// Hostinger's server default is non-strict. Configure every checked-out
// connection, await success, and fail closed. No global privileges are needed.
async function connection():Promise<PoolConnection> {
 db(); const c=await pool!.getConnection();
 try {
  await c.query("SET SESSION sql_mode='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION', time_zone='+00:00'");
  return c;
 } catch(e) {c.destroy();throw e;}
}
const access = {
 getConnection:connection,
 execute:(async (sql:string,params?:ExecuteValues)=>{const c=await connection();try{return await c.execute(sql,params);}finally{c.release();}}) as ReturnType<typeof mysql.createPool>['execute']
};
export type Conn = PoolConnection;
export async function rows(c: Pick<PoolConnection,'execute'>, sql:string, params:ExecuteValues=[]):Promise<RowDataPacket[]> { const [r]=await c.execute(sql,params); return r as RowDataPacket[]; }
export async function transaction<T>(run:(c:Conn)=>Promise<T>):Promise<T> {
 const c=await db().getConnection();
 try {await c.query('SET TRANSACTION ISOLATION LEVEL READ COMMITTED'); await c.beginTransaction(); const value=await run(c); await c.commit(); return value;}
 catch(e){await c.rollback(); throw e;} finally{c.release();}
}
