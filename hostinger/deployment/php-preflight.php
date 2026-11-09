<?php
// Read-only runtime probe; prints no environment values, paths with credentials or DB details.
if(PHP_SAPI!=='cli') {http_response_code(404);exit;}
$checks=['php83'=>PHP_VERSION_ID>=80300&&PHP_VERSION_ID<80400,'sqlite'=>extension_loaded('sqlite3'),'pdo_sqlite'=>extension_loaded('pdo_sqlite'),'curl'=>extension_loaded('curl'),'json'=>extension_loaded('json'),'openssl'=>extension_loaded('openssl'),'flock'=>function_exists('flock'),'hash_hmac'=>function_exists('hash_hmac')];
echo json_encode(['at'=>gmdate('c'),'php'=>PHP_VERSION,'sapi'=>PHP_SAPI,'checks'=>$checks,'status'=>in_array(false,$checks,true)?'FAIL':'PASS'])."\n";
exit(in_array(false,$checks,true)?1:0);
