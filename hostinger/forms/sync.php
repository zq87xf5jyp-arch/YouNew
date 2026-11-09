<?php
declare(strict_types=1);
// CLI only: never create a public read endpoint or include secrets in the browser.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/service.php';
try {
    $configPath = __DIR__ . '/sync-config.php';
    if (!is_file($configPath) || is_link($configPath) || (fileperms($configPath) & 0077)) throw new RuntimeException('Private config required');
    $config = require $configPath;
    $url = rtrim((string) ($config['url'] ?? ''), '/');
    $parts = parse_url($url);
    $local = getenv('YOUNEW_LOCAL_REHEARSAL') === 'true' && in_array($url, ['http://api-gw:8000','http://127.0.0.1:54331'], true);
    if (!$parts || isset($parts['user']) || isset($parts['pass']) || (!$local && ($parts['scheme'] ?? '') !== 'https') || empty($parts['host']) || isset($parts['query']) || isset($parts['fragment'])) throw new RuntimeException('Invalid destination');
    $key = (string) ($config['serviceKey'] ?? '');
    if (strlen($key) < 40 || str_contains($key, "\n") || str_contains($key, "\r")) throw new RuntimeException('Missing credential');
    $documentRoot = (string) ($config['documentRoot'] ?? '');
    if (!is_dir($documentRoot)) throw new RuntimeException('Document root required');
    umask(0077);
    $lockPath = __DIR__ . '/sync.lock';
    if (is_link($lockPath)) throw new RuntimeException('Invalid lock');
    $lock = fopen($lockPath, 'c');
    if (!$lock) throw new RuntimeException('Lock unavailable');
    if (!flock($lock, LOCK_EX | LOCK_NB)) {
        echo json_encode(['attempted'=>0,'delivered'=>0,'failed'=>0,'skipped'=>'worker_running']) . "\n";
        exit(0);
    }
    $store = new \YouNewForms\Store(dirname(__DIR__) . '/forms-data', $documentRoot);
    $pending = $store->pendingDeliveries();
    $delivered = 0; $failed = 0;
    foreach ($pending as $row) {
        $ch = curl_init($url . '/rest/v1/rpc/ingest_hostinger_form');
        curl_setopt_array($ch, [CURLOPT_POST=>true,CURLOPT_RETURNTRANSFER=>true,CURLOPT_CONNECTTIMEOUT=>5,CURLOPT_TIMEOUT=>20,CURLOPT_FOLLOWLOCATION=>false,
            CURLOPT_HTTPHEADER=>['Content-Type: application/json','apikey: '.$key,'Authorization: Bearer '.$key],
            CURLOPT_POSTFIELDS=>json_encode(['p_receipt'=>$row['id'],'p_kind'=>$row['kind'],'p_payload'=>$row['payload'],'p_created_at'=>$row['created_at'],'p_consent_version'=>$row['consent_version']], JSON_THROW_ON_ERROR)]);
        $body = curl_exec($ch); $status = curl_getinfo($ch, CURLINFO_RESPONSE_CODE); curl_close($ch);
        $result = is_string($body) ? json_decode($body, true) : null;
        if ($status !== 200 || !is_array($result) || count($result) !== 1 || ($result[0]['receipt'] ?? '') !== $row['id'] || !is_string($result[0]['remote_id'] ?? null)) { $failed++; continue; }
        $store->acknowledgeDelivery($row['id'], $result[0]['remote_id']); $delivered++;
    }
    // Operational counts only: no personal data, URLs or response bodies in logs.
    echo json_encode(['attempted'=>count($pending),'delivered'=>$delivered,'failed'=>$failed], JSON_THROW_ON_ERROR) . "\n";
    exit($failed ? 1 : 0);
} catch (Throwable $e) { fwrite(STDERR, "Form delivery unavailable; queue retained.\n"); exit(1); }
