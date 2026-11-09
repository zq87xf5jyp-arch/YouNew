<?php
declare(strict_types=1);
// CLI only. Configure this private path in Hostinger Cron Jobs; never expose a web maintenance endpoint.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__.'/service.php';
$private=dirname(__DIR__);
$store=new \YouNewAnalytics\Store($private.'/analytics-data',dirname($private).'/public_html');
$report=$store->maintain();
echo json_encode(['ok'=>true,'generatedAt'=>$report['generatedAt'],'totalEvents'=>$report['totalEvents']],JSON_THROW_ON_ERROR),"\n";
