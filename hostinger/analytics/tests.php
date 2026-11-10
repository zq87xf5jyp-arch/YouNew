<?php
declare(strict_types=1);
require __DIR__.'/service.php';
$tests=[];
function verify(string $name,bool $value):void {global $tests;if(!$value)throw new RuntimeException('FAIL: '.$name);$tests[]=$name;}
function uuid():string {$h=bin2hex(random_bytes(16));return substr($h,0,8).'-'.substr($h,8,4).'-4'.substr($h,13,3).'-8'.substr($h,17,3).'-'.substr($h,20,12);}
function fixture(string $name='page_view',array $properties=[]):array {return ['client_event_id'=>uuid(),'app_instance_id'=>uuid(),'session_id'=>uuid(),'event_name'=>$name,'screen'=>'/guides/example/?email=private@example.invalid','platform'=>'Web','app_version'=>'web-test','language'=>'en','properties'=>(object)$properties,'occurred_at'=>gmdate('Y-m-d\TH:i:s\Z'),'consent_version'=>\YouNewAnalytics\CONSENT_VERSION,'schema_version'=>1,'environment'=>'production'];}
$root=sys_get_temp_dir().'/yn-analytics-'.bin2hex(random_bytes(6));$public=$root.'/public_html';$directory=$root.'/private';mkdir($public,0700,true);
$server=['HTTP_ORIGIN'=>'https://younew.nl','REQUEST_METHOD'=>'POST','CONTENT_TYPE'=>'application/json','REMOTE_ADDR'=>'192.0.2.11'];
function request(mixed $payload,array $overrides=[],?string $body=null):array {global $server,$directory,$public;return \YouNewAnalytics\handle($body??json_encode($payload,JSON_THROW_ON_ERROR),array_replace($server,$overrides),$directory,$public);}
$event=fixture();$payload=['events'=>[$event]];
verify('foreign origin rejected',request($payload,['HTTP_ORIGIN'=>'https://evil.invalid'])[0]===403);
verify('missing origin rejected',request($payload,['HTTP_ORIGIN'=>''])[0]===403);
verify('no public reporting API',request($payload,['REQUEST_METHOD'=>'GET'])[0]===405);
verify('no DELETE method',request($payload,['REQUEST_METHOD'=>'DELETE'])[0]===405);
verify('preflight does not create data',request($payload,['REQUEST_METHOD'=>'OPTIONS'])[0]===204&&!is_dir($directory));
verify('JSON required',request($payload,['CONTENT_TYPE'=>'text/plain'])[0]===415);
verify('declared body cap',request($payload,['CONTENT_LENGTH'=>'65537'])[0]===413);
verify('actual body cap',request(null,[],str_repeat('x',65537))[0]===413);
verify('invalid JSON',request(null,[],'{')[0]===400);
verify('empty batch',request(['events'=>[]])[0]===400);
verify('batch cap',request(['events'=>array_fill(0,21,$event)])[0]===400);
verify('root unknown field',request($payload+['email'=>'private@example.invalid'])[0]===400);
foreach(['client_event_id'=>'invalid','session_id'=>'invalid','app_instance_id'=>'invalid','event_name'=>'unknown','platform'=>'iOS','schema_version'=>'1','consent_version'=>'2026-07-28','environment'=>'staging','screen'=>'https://evil.invalid','language'=>'en<script>','app_version'=>'bad<script>','occurred_at'=>'invalid','properties'=>['email'=>'private@example.invalid']] as $key=>$value){
 verify('invalid '.$key,request(['events'=>[array_replace($event,[$key=>$value])]])[0]===400);
}
verify('unknown envelope field',request(['events'=>[$event+['email'=>'private@example.invalid']]])[0]===400);
verify('invalid request stores nothing',!is_dir($directory));
[$status,$headers,$result]=request($payload);verify('accepted only after storing',$status===202&&$result===['accepted'=>1,'stored'=>true]);
verify('no caching',$headers['Cache-Control']==='no-store, max-age=0');verify('duplicate idempotent',request($payload)[2]['accepted']===0);
$db=new SQLite3($directory.'/analytics.sqlite');verify('one row after duplicate',$db->querySingle('SELECT COUNT(*) FROM events')===1);
verify('only section retained',$db->querySingle('SELECT section FROM events')==='/guides/');
$dump=json_encode($db->querySingle('SELECT * FROM events',true));verify('raw IDs not retained',!str_contains($dump,$event['session_id'])&&!str_contains($dump,$event['client_event_id']));
verify('no raw IP, query or email',!str_contains($dump,'192.0.2.11')&&!str_contains($dump,'private')&&!str_contains($dump,'example.invalid'));
verify('private database permissions',(fileperms($directory.'/analytics.sqlite')&0777)===0600);verify('private folder permissions',(fileperms($directory)&0777)===0700);
$search=fixture('search',['normalized_query_safe'=>'private@example.invalid','intent_ids'=>'sensitive query','filter_profile'=>'private profile','result_count'=>0,'zero_result'=>true,'has_results'=>false,'fallback_tier'=>'national']);
verify('bounded search stats accepted',request(['events'=>[$search]])[0]===202);
verify('raw search phrase is absent from database',!str_contains(file_get_contents($directory.'/analytics.sqlite'),'private@example.invalid'));
verify('search zero count persisted',$db->querySingle("SELECT zero_result FROM events WHERE event='search'")===1);
$badSearch=$search;$badSearch['properties']=(object)['result_count'=>4,'zero_result'=>true,'has_results'=>false,'fallback_tier'=>'national'];
verify('contradictory search results rejected',request(['events'=>[$badSearch]])[0]===400);
$badSearch['properties']=(object)['result_count'=>0,'zero_result'=>true,'has_results'=>false,'fallback_tier'=>'private-free-text'];verify('unknown tier rejected',request(['events'=>[$badSearch]])[0]===400);
verify('invalid event makes whole batch atomic',request(['events'=>[fixture(),array_replace(fixture(),['event_name'=>'bad'])]])[0]===400&&$db->querySingle('SELECT COUNT(*) FROM events')===2);
$geo=fixture('time_to_first_action',['city'=>'privatecity','intent_id'=>'privatetopic','duration_ms'=>2000]);verify('bounded timing accepted',request(['events'=>[$geo]])[0]===202);
$report=json_decode(file_get_contents($directory.'/report.json'),true);verify('report exact count',$report['totalEvents']===3);verify('report search stats',$report['search'][0]['zero_results']===1);
verify('report contains no raw identifiers',!str_contains(json_encode($report),$event['session_id']));
$store=new \YouNewAnalytics\Store($directory,$public);$store->maintain();verify('consistent snapshot generated',is_file($directory.'/analytics.snapshot.sqlite'));
$copy=$root.'/restored.sqlite';copy($directory.'/analytics.snapshot.sqlite',$copy);$restored=new SQLite3($copy);verify('snapshot restores integrity',$restored->querySingle('PRAGMA integrity_check')==='ok');verify('snapshot restores events',$restored->querySingle('SELECT COUNT(*) FROM events')===3);$restored->close();
$now=1800000000;$rate=new \YouNewAnalytics\Store($root.'/rate',$public);$session=uuid();
for($batch=0;$batch<6;$batch++){$events=[];for($i=0;$i<20;$i++)$events[]=array_replace(fixture(),['session_id'=>$session]);$normal=\YouNewAnalytics\normalize(json_decode(json_encode(['events'=>$events])));verify('session batch '.$batch,$rate->ingest($normal,'192.0.2.20',$now)===20);}
$limited=false;try{$rate->ingest(\YouNewAnalytics\normalize(json_decode(json_encode(['events'=>[array_replace(fixture(),['session_id'=>$session])]]))),'192.0.2.20',$now);}catch(\YouNewAnalytics\RequestError $e){$limited=$e->status===429;}verify('session rate limit',$limited);
$rateReport=$rate->maintain($now+\YouNewAnalytics\RETENTION_SECONDS+1);verify('scheduled cleanup removes expired rows',$rateReport['totalEvents']===0);
$rateDb=new SQLite3($root.'/rate/analytics.sqlite');verify('expired rate fingerprints removed',$rateDb->querySingle('SELECT COUNT(*) FROM rate_windows')===0);$rateDb->close();
verify('unknown paths are bucketed',\YouNewAnalytics\section('/private-person@example.invalid')==='/other/');verify('NL sections retained',\YouNewAnalytics\section('/nl/voor-bedrijven/aanmelden/')==='/nl/voor-bedrijven/');
$refused=false;try{new \YouNewAnalytics\Store($public.'/unsafe',$public);}catch(RuntimeException){$refused=true;}verify('public storage rejected',$refused);
$db->close();unset($store,$rate);
$remove=static function(string $path)use(&$remove):void{foreach(scandir($path)as$n){if($n==='.'||$n==='..')continue;$f=$path.'/'.$n;if(is_dir($f)&&!is_link($f))$remove($f);else unlink($f);}rmdir($path);};$remove($root);
echo json_encode(['passed'=>count($tests),'tests'=>$tests],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),"\n";
