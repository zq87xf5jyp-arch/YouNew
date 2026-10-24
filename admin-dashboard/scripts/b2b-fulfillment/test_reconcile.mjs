import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import Stripe from 'stripe';
import { API_VERSION, createTestProvider, verifyTestPayment, prepareVerified } from './reconcile.mjs';

const now = new Date('2026-09-19T12:00:00Z');
const order = JSON.parse(readFileSync(new URL('./fixtures/sandbox-order.json', import.meta.url), 'utf8'));
const binding = {schema_version:1,order_id:order.id,account_id:'acct_fixture',session_id:'cs_test_fixture',
  payment_intent_id:'pi_fixture',product_id:'prod_fixture'};
function fixture() {
  const state = {
    account: {id:'acct_fixture'},
    session: {id:'cs_test_fixture',object:'checkout.session',livemode:false,mode:'payment',subscription:null,
      status:'complete',payment_status:'paid',payment_intent:'pi_fixture',amount_total:150000,currency:'eur',
      line_items:{has_more:false,data:[{quantity:1,amount_total:150000,
        price:{livemode:false,type:'one_time',product:'prod_fixture'}}]}},
    payment: {id:'pi_fixture',object:'payment_intent',livemode:false,status:'succeeded',amount:150000,
      amount_received:150000,currency:'eur',latest_charge:{id:'ch_fixture',object:'charge',livemode:false,
        payment_intent:'pi_fixture',status:'succeeded',paid:true,captured:true,amount:150000,currency:'eur',
        disputed:false,refunded:false,amount_refunded:0}},
    refunds: {object:'list',has_more:false,data:[]}, calls:[]
  };
  const get = key => async (...args) => {state.calls.push([key,args]);return structuredClone(state[key]);};
  return {state, provider:{accounts:{retrieve:get('account')},checkout:{sessions:{retrieve:get('session')}},
    paymentIntents:{retrieve:get('payment')},refunds:{list:get('refunds')}}};
}

test('rejects live, missing and malformed credentials before SDK creation', () => {
  for(const key of [undefined,'','sk_live_fixture','rk_live_fixture','sk_test_a\nsecret'])
    assert.throws(()=>createTestProvider(key),/test_key_required/);
  assert.ok(createTestProvider('rk_test_fixture'));
});

test('current provider state produces only sandbox evidence through bounded read methods',async()=>{
  const {state,provider}=fixture();
  const result=await verifyTestPayment(provider,binding,order,now);
  assert.equal(result.method,'stripe_test_api_readback'); assert.equal(result.mode,'sandbox');
  assert.equal(result.id,'pi_fixture'); assert.equal(result.checked_at,'2026-09-19T12:00:00Z');
  assert.deepEqual(state.calls.map(c=>c[0]),['account','session','payment','refunds']);
  assert.equal(state.calls[3][1][0].limit,100);
});

const cases=[
  ['wrong account',s=>s.account.id='acct_other',/account_mismatch/],
  ['live session',s=>s.session.livemode=true,/unsupported_session/],
  ['subscription',s=>s.session.mode='subscription',/unsupported_session/],
  ['unpaid delayed payment',s=>s.session.payment_status='unpaid',/session_not_paid/],
  ['expired checkout',s=>s.session.status='expired',/session_not_paid/],
  ['wrong payment',s=>s.session.payment_intent='pi_other',/session_binding_mismatch/],
  ['wrong total',s=>s.session.amount_total=1,/session_binding_mismatch/],
  ['wrong product',s=>s.session.line_items.data[0].price.product='prod_other',/product_or_amount_mismatch/],
  ['truncated items',s=>s.session.line_items.has_more=true,/incomplete_line_items/],
  ['uncaptured charge',s=>s.payment.latest_charge.captured=false,/charge_not_confirmed/],
  ['partial refund',s=>s.payment.latest_charge.amount_refunded=1,/refund_or_dispute/],
  ['full refund',s=>{s.payment.latest_charge.refunded=true;s.payment.latest_charge.amount_refunded=150000;},/refund_or_dispute/],
  ['dispute',s=>s.payment.latest_charge.disputed=true,/refund_or_dispute/],
  ['pending refund',s=>s.refunds.data.push({id:'re_fixture',status:'pending'}),/refund_history_requires_review/],
  ['failed refund',s=>s.refunds.data.push({id:'re_fixture',status:'failed'}),/refund_history_requires_review/],
  ['truncated refunds',s=>s.refunds.has_more=true,/incomplete_refunds/]
];
for(const [name,change,error] of cases)test(`blocks ${name}`,async()=>{
  const {state,provider}=fixture();change(state);
  await assert.rejects(verifyTestPayment(provider,binding,order,now),error);
});

test('provider outage does not return stale successful evidence',async()=>{
  const {provider}=fixture();provider.paymentIntents.retrieve=async()=>{throw new Error('offline');};
  await assert.rejects(verifyTestPayment(provider,binding,order,now),/offline/);
});

test('pinned Stripe SDK executes retrieval-only requests using an in-memory HTTP transport',async()=>{
  const {state}=fixture(); const calls=[];
  const fetcher=async(url,init)=>{
    const target=new URL(url);calls.push({path:target.pathname,query:target.search,method:init.method});
    assert.equal(target.hostname,'api.stripe.com');assert.equal(init.method,'GET');
    const key={ '/v1/account':'account','/v1/checkout/sessions/cs_test_fixture':'session',
      '/v1/payment_intents/pi_fixture':'payment','/v1/refunds':'refunds' }[target.pathname];
    assert.ok(key,'unexpected API endpoint');
    return new Response(JSON.stringify(state[key]),{status:200,headers:{'content-type':'application/json'}});
  };
  const sdk=new Stripe('rk_test_fixture',{apiVersion:API_VERSION,maxNetworkRetries:0,
    httpClient:Stripe.createFetchHttpClient(fetcher)});
  const result=await verifyTestPayment(sdk,binding,order,now);
  assert.equal(result.id,'pi_fixture');assert.equal(calls.length,4);
  assert.match(calls[1].query,/line_items/);assert.match(calls[2].query,/latest_charge/);
  assert.match(calls[3].query,/payment_intent=pi_fixture/);
});

test('current payment → actual Python preparation → fresh retry → refund denial preserves files',async()=>{
  const root=mkdtempSync(join(tmpdir(),'younew-b2b-test-'));
  try{
    const {state,provider}=fixture();
    const payment=await verifyTestPayment(provider,binding,order,now);
    const first=prepareVerified(order,payment,root,now);assert.equal(first.status,'prepared_not_sent');
    const original=readFileSync(join(first.directory,'PREPARATION.json'),'utf8');
    const later=new Date(now.getTime()+86_400_000);
    const refreshed=await verifyTestPayment(provider,binding,order,later);
    assert.equal(prepareVerified(order,refreshed,root,later).status,'already_prepared');
    assert.equal(readFileSync(join(first.directory,'PREPARATION.json'),'utf8'),original);
    const ledger=JSON.parse(readFileSync(join(first.directory,'ledger-entry.json'),'utf8'));
    assert.equal(ledger.live_received_minor,0);assert.equal(ledger.mrr_minor,0);
    assert.equal(ledger.fees_minor,null);assert.equal(ledger.delivery_status,'prepared_not_sent');
    assert.equal(ledger.provider_verified_by_cli,false);
    state.payment.latest_charge.refunded=true;state.payment.latest_charge.amount_refunded=150000;
    await assert.rejects(verifyTestPayment(provider,binding,order,later),/refund_or_dispute/);
    assert.equal(readFileSync(join(first.directory,'PREPARATION.json'),'utf8'),original);
  }finally{rmSync(root,{recursive:true,force:true});}
});
