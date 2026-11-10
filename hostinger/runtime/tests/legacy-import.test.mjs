import test from 'node:test';
import assert from 'node:assert/strict';
import {array,timestamp,plan,SOURCE_SHA,sha} from '../../deployment/import-legacy.mjs';

test('PostgreSQL array parser retains quoted commas, null and escapes',()=>{
 assert.deepEqual(array('{"one,two",NULL,"NULL","a\\\\b",plain}'),['one,two',null,'NULL','a\\b','plain']);
 assert.deepEqual(array('{}'),[]);assert.throws(()=>array('{"unterminated}'));
 assert.throws(()=>array('{{nested}}'));
});
test('legacy timestamps preserve microseconds and reject non-UTC input',()=>{
 assert.equal(timestamp('2026-07-01 12:00:00.123456+00'),'2026-07-01 12:00:00.123456');
 assert.equal(timestamp('2026-07-01 12:00:00+00:00'),'2026-07-01 12:00:00');
 assert.throws(()=>timestamp('2026-07-01 12:00:00+02'));
});
const table=(name,columns,rows)=>({name,columns,rows,copyBase64:'',copySha256:sha('')});
test('source, incomplete mapping and MFA cannot silently create credentials',()=>{
 assert.throws(()=>plan({schemaVersion:1,sourceSha256:'different',tables:[]}));
 const bundle={schemaVersion:1,sourceSha256:SOURCE_SHA,tables:[table('auth.mfa_factors',[],[[]])]};
 assert.throws(()=>plan(bundle),/MFA/);
 bundle.tables=[table('auth.mfa_factors',[],[]),table('auth.webauthn_credentials',[],[]),table('auth.users',['id'],[['x']]),table('public.profiles',[],[])];
 assert.throws(()=>plan(bundle),/mapping/);
});
