<?php
// A dedicated isolated origin. Public docroot contains no build, database or secret.
$path = rawurldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? '/');
if (str_contains($path, '..') || str_contains($path, '\\') || str_contains($path, "\0")) { http_response_code(404); exit; }
$routes = ['/submit-business-inquiry.php'=>'submit-business-inquiry.php','/api/submit-business-inquiry.php'=>'api/submit-business-inquiry.php','/private-files.php'=>'private-files.php'];
if (isset($routes[$path])) { require dirname(__DIR__).'/backend/php/public/'.$routes[$path]; exit; }
if (!in_array($_SERVER['REQUEST_METHOD'], ['GET','HEAD'], true)) { http_response_code(405); exit; }
$store = getenv('YOUNEW_PUBLICATION_ROOT') ?: dirname(__DIR__).'/publication';
$pointer = @json_decode(file_get_contents($store.'/current.json'), true);
if (!$pointer || !preg_match('/^hp-[a-zA-Z0-9-]+$/D', $pointer['releaseId'] ?? '')) { http_response_code(503); header('Cache-Control: no-store'); echo 'No validated catalog release is active.'; exit; }
$base = realpath($store.'/releases/'.$pointer['releaseId'].'/out');
$file = $base.$path;
if (is_dir($file)) $file .= '/index.html';
$file = realpath($file);
$types=['html'=>'text/html; charset=utf-8','json'=>'application/json; charset=utf-8','xml'=>'application/xml','js'=>'text/javascript; charset=utf-8','css'=>'text/css; charset=utf-8','svg'=>'image/svg+xml','png'=>'image/png','jpg'=>'image/jpeg','jpeg'=>'image/jpeg','webp'=>'image/webp','avif'=>'image/avif','ico'=>'image/x-icon','woff'=>'font/woff','woff2'=>'font/woff2','txt'=>'text/plain; charset=utf-8','webmanifest'=>'application/manifest+json','mp4'=>'video/mp4','pdf'=>'application/pdf'];
$association=$path==='/.well-known/apple-app-site-association';
$ext=$association?'json':($file?pathinfo($file,PATHINFO_EXTENSION):'');
header('Cache-Control: no-store, max-age=0');header('X-Content-Type-Options: nosniff');
if (!$file || !$base || !str_starts_with($file,$base.'/') || !is_file($file) || !isset($types[$ext]) || (preg_match('#/\.[^/]*#',$path)&&!$association)) {http_response_code(404);exit;}
header('Content-Type: '.$types[$ext]);header('X-YouNew-Release: '.$pointer['releaseId']);
$size=filesize($file);$start=0;$end=$size-1;header('Accept-Ranges: bytes');
if (isset($_SERVER['HTTP_RANGE'])) {
 if (!preg_match('/^bytes=(\d*)-(\d*)$/D',$_SERVER['HTTP_RANGE'],$m) || ($m[1]==='' && $m[2]==='')) {http_response_code(416);header('Content-Range: bytes */'.$size);exit;}
 if ($m[1]==='') {$start=max(0,$size-(int)$m[2]);} else {$start=(int)$m[1];if($m[2]!=='')$end=min($end,(int)$m[2]);}
 if($start>$end || $start>=$size){http_response_code(416);header('Content-Range: bytes */'.$size);exit;}
 http_response_code(206);header("Content-Range: bytes $start-$end/$size");
}
header('Content-Length: '.($end-$start+1));
if ($_SERVER['REQUEST_METHOD']!=='HEAD') { $stream=fopen($file,'rb');fseek($stream,$start);$left=$end-$start+1;while($left>0&&!feof($stream)){ $chunk=fread($stream,min(65536,$left));if($chunk===false||$chunk==='')break;echo $chunk;$left-=strlen($chunk);}fclose($stream);}
