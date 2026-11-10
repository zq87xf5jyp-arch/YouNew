<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
require __DIR__.'/service.php';
umask(0077);
$started=gmdate('c');
try {
 $path=__DIR__.'/sync-config.php';if(!is_file($path)||is_link($path)||(fileperms($path)&0077))throw new RuntimeException();
 $c=require $path;$url=$c['url']??'';$key=$c['ingestKey']??'';
 $u=parse_url($url);$local=($c['local']??false)===true&&$url==='http://127.0.0.1:4404';
 if(!$u||(!$local&&($u['scheme']??'')!=='https')||isset($u['user'])||isset($u['pass'])||isset($u['query'])||isset($u['fragment'])||isset($u['path'])||strlen($key)<64)throw new RuntimeException();
 $root=$c['documentRoot']??'';if(!is_dir($root))throw new RuntimeException();
 $lockPath=__DIR__.'/sync.lock';if(is_link($lockPath))throw new RuntimeException();$lock=fopen($lockPath,'c');
 if(!$lock)throw new RuntimeException();if(!flock($lock,LOCK_EX|LOCK_NB)){echo json_encode(['at'=>$started,'skipped'=>'worker_running'])."\n";exit(0);}
 $dir=dirname(__DIR__).'/forms-data';$store=new \YouNewForms\Store($dir,$root);
 $retry=new SQLite3($dir.'/retry.sqlite');$retry->enableExceptions(true);$retry->busyTimeout(5000);$retry->exec('CREATE TABLE IF NOT EXISTS retries(id TEXT PRIMARY KEY,attempts INTEGER NOT NULL,next_at INTEGER NOT NULL,last_code INTEGER NOT NULL)');
 $count=['at'=>$started,'attempted'=>0,'delivered'=>0,'failed'=>0,'deferred'=>0];$deadline=microtime(true)+50;
 foreach($store->pendingDeliveries(20,'business') as $row){if(microtime(true)>$deadline)break;
  $q=$retry->prepare('SELECT attempts,next_at FROM retries WHERE id=:id');$q->bindValue(':id',$row['id']);$prior=$q->execute()->fetchArray(SQLITE3_ASSOC);
  if($prior&&$prior['next_at']>time()){$count['deferred']++;continue;}
  $count['attempted']++;$body=json_encode(['p_receipt'=>$row['id'],'p_kind'=>$row['kind'],'p_payload'=>$row['payload'],'p_created_at'=>$row['created_at'],'p_consent_version'=>$row['consent_version']],JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR);
  $ts=(string)time();$nonce=bin2hex(random_bytes(32));$sig=hash_hmac('sha256',"POST\n/api/r4/ingest/business\n$ts\n$nonce\n".hash('sha256',$body),$key);
  $ch=curl_init($url.'/api/r4/ingest/business');curl_setopt_array($ch,[CURLOPT_POST=>true,CURLOPT_RETURNTRANSFER=>true,CURLOPT_CONNECTTIMEOUT=>3,CURLOPT_TIMEOUT=>8,CURLOPT_FOLLOWLOCATION=>false,CURLOPT_PROTOCOLS=>CURLPROTO_HTTP|CURLPROTO_HTTPS,CURLOPT_HTTPHEADER=>['Content-Type: application/json','X-R4-Time: '.$ts,'X-R4-Nonce: '.$nonce,'X-R4-Signature: '.$sig],CURLOPT_POSTFIELDS=>$body]);
  $raw=curl_exec($ch);$status=curl_getinfo($ch,CURLINFO_RESPONSE_CODE);curl_close($ch);$r=is_string($raw)?json_decode($raw,true):null;
  $success=$status===200&&is_array($r)&&count($r)===1&&($r[0]['receipt']??'')===$row['id']&&is_string($r[0]['remote_id']??null);
  if($success){$store->acknowledgeDelivery($row['id'],$r[0]['remote_id']);$q=$retry->prepare('DELETE FROM retries WHERE id=:id');$q->bindValue(':id',$row['id']);$q->execute();$count['delivered']++;}
  else{$attempts=($prior['attempts']??0)+1;$wait=min(3600,30*(2**min($attempts-1,7)));$q=$retry->prepare('INSERT INTO retries(id,attempts,next_at,last_code) VALUES(:id,:attempts,:next,:code) ON CONFLICT(id) DO UPDATE SET attempts=excluded.attempts,next_at=excluded.next_at,last_code=excluded.last_code');foreach([':id'=>$row['id'],':attempts'=>$attempts,':next'=>time()+$wait,':code'=>$status] as $k=>$v)$q->bindValue($k,$v,is_int($v)?SQLITE3_INTEGER:SQLITE3_TEXT);$q->execute();$count['failed']++;}
  // Receipt is a synthetic/opaque reference; do not log payload, contact, URL, key or response.
  echo json_encode(['at'=>gmdate('c'),'receipt'=>$row['id'],'result'=>$success?'delivered':'retry_scheduled','http'=>$status,'attempt'=>($prior['attempts']??0)+1])."\n";
 }
 echo json_encode($count)."\n";flock($lock,LOCK_UN);fclose($lock);exit($count['failed']?1:0);
}catch(Throwable $e){fwrite(STDERR,json_encode(['at'=>gmdate('c'),'error'=>'delivery_unavailable','queue_retained'=>true])."\n");exit(1);}
