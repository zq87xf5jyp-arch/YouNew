<?php
declare(strict_types=1);
ini_set('display_errors','0');header('Cache-Control: no-store');header('Content-Type: application/json');header('X-Content-Type-Options: nosniff');umask(0077);
try {
 if(($_SERVER['REQUEST_METHOD']??'')!=='POST'){http_response_code(404);exit;}
 $config=dirname(__DIR__).'/private/files/config.php';if(!is_file($config)||is_link($config)||(fileperms($config)&0077))throw new RuntimeException();$key=(require $config)['key']??'';if(strlen($key)<64)throw new RuntimeException();
 $body=file_get_contents('php://input',false,null,0,1400300);if($body===false||strlen($body)>1400200){http_response_code(413);exit;}
 $ts=$_SERVER['HTTP_X_R4_TIME']??'';$nonce=$_SERVER['HTTP_X_R4_NONCE']??'';$sig=$_SERVER['HTTP_X_R4_SIGNATURE']??'';
 if(!preg_match('/^[0-9]{10}$/D',$ts)||abs(time()-(int)$ts)>120||!preg_match('/^[a-f0-9]{64}$/D',$nonce)||!hash_equals(hash_hmac('sha256',"$ts\n$nonce\n".hash('sha256',$body),$key),$sig)){http_response_code(401);echo '{"error":"unauthorized"}';exit;}
 $dir=dirname(__DIR__).'/private/files-data';if(is_link($dir))throw new RuntimeException();if(!is_dir($dir))mkdir($dir,0700,true);if(is_link($dir.'/nonces.sqlite'))throw new RuntimeException();$db=new SQLite3($dir.'/nonces.sqlite');$db->enableExceptions(true);$db->busyTimeout(5000);$db->exec('CREATE TABLE IF NOT EXISTS nonces(nonce TEXT PRIMARY KEY,expires INTEGER NOT NULL)');
 $q=$db->prepare('INSERT OR IGNORE INTO nonces(nonce,expires) VALUES(:nonce,:expires)');$q->bindValue(':nonce',$nonce);$q->bindValue(':expires',time()+300,SQLITE3_INTEGER);$q->execute();if($db->changes()!==1){http_response_code(409);exit;}
 $q=$db->prepare('DELETE FROM nonces WHERE expires<:now');$q->bindValue(':now',time(),SQLITE3_INTEGER);$q->execute();
 $input=json_decode($body,true,16,JSON_THROW_ON_ERROR);if(!is_array($input)||array_diff(array_keys($input),['operation','key','data'])||!preg_match('/^[a-f0-9-]{36}$/D',$input['key']??'')||!in_array($input['operation']??'',['read','write'],true)){http_response_code(400);exit;}
 $path=$dir.'/'.$input['key'].'.blob';if(is_link($path))throw new RuntimeException();
 if($input['operation']==='write'){$data=base64_decode($input['data']??'',true);if($data===false||strlen($data)<1||strlen($data)>1048576){http_response_code(400);exit;}$f=fopen($path,'xb');if(!$f){http_response_code(409);exit;}$ok=fwrite($f,$data)===strlen($data)&&fflush($f);if(function_exists('fsync'))$ok=$ok&&fsync($f);fclose($f);if(!$ok)throw new RuntimeException();echo '{"ok":true}';}
 else {if(!is_file($path)){http_response_code(404);exit;}$f=fopen($path,'rb');if(!$f)throw new RuntimeException();$data=stream_get_contents($f,1048577);fclose($f);if($data===false||strlen($data)>1048576)throw new RuntimeException();echo json_encode(['data'=>base64_encode($data)],JSON_THROW_ON_ERROR);}
}catch(Throwable $e){http_response_code(503);echo '{"error":"unavailable"}';}
