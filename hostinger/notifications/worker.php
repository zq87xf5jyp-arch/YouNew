<?php
/** Private CLI-only notifications. Reads receipt IDs, never inquiry payloads. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
umask(0077);

function statement(SQLite3 $db, string $sql, array $params = []): SQLite3Result {
    $q = $db->prepare($sql);
    foreach ($params as $key => $value) $q->bindValue($key, $value, is_int($value) ? SQLITE3_INTEGER : SQLITE3_TEXT);
    return $q->execute();
}
function privateFile(string $path): void {
    if (!is_file($path) || is_link($path) || (fileperms($path) & 0077)) throw new RuntimeException('private_file_required');
}
function enqueue(SQLite3 $db, string $key, string $kind, string $detail): void {
    statement($db, 'INSERT OR IGNORE INTO events(id,kind,detail,created_at) VALUES(:id,:kind,:detail,:at)', [':id'=>$key, ':kind'=>$kind, ':detail'=>$detail, ':at'=>time()]);
}
try {
    $configPath = $argv[1] ?? ''; privateFile($configPath);
    $c = json_decode(file_get_contents($configPath), true, 32, JSON_THROW_ON_ERROR);
    $mode = $argv[2] ?? 'run';
    if (!in_array($mode, ['init','run','probe'], true)) throw new RuntimeException('invalid_mode');
    $transport = $c['transport'] ?? '';
    if (!in_array($transport, ['mail','capture','reject'], true)) throw new RuntimeException('invalid_transport');
    if ($transport !== 'mail' && ($c['environment'] ?? '') !== 'qa') throw new RuntimeException('qa_transport_only');
    // Deliberately not a general relay. No submitter address can become a recipient.
    if (($c['recipient'] ?? '') !== 'support@younew.nl' || ($c['sender'] ?? '') !== 'support@younew.nl') throw new RuntimeException('mailbox_not_allowed');
    $state = $c['stateDirectory'] ?? '';
    if (!str_contains($state, '/younew-private/') || is_link($state)) throw new RuntimeException('private_directory_required');
    if (!is_dir($state) && !mkdir($state, 0700, true)) throw new RuntimeException('state_unavailable');
    if (fileperms($state) & 0077) throw new RuntimeException('private_directory_permissions');
    if (is_file($state.'/PAUSED')) { echo "{\"status\":\"paused\"}\n"; exit; }
    $lockPath = $state.'/worker.lock';
    if (is_link($lockPath)) throw new RuntimeException('invalid_lock');
    $lock = fopen($lockPath, 'c');
    if (!flock($lock, LOCK_EX|LOCK_NB)) { echo "{\"status\":\"already_running\"}\n"; exit; }
    $dbPath = $state.'/notifications.sqlite';
    if (is_link($dbPath)) throw new RuntimeException('invalid_database');
    $db = new SQLite3($dbPath); $db->enableExceptions(true); $db->busyTimeout(5000);
    $db->exec("CREATE TABLE IF NOT EXISTS meta(key TEXT PRIMARY KEY,value TEXT NOT NULL);
      CREATE TABLE IF NOT EXISTS events(id TEXT PRIMARY KEY,kind TEXT NOT NULL,detail TEXT NOT NULL,created_at INTEGER NOT NULL,state TEXT NOT NULL DEFAULT 'pending',attempts INTEGER NOT NULL DEFAULT 0,next_at INTEGER NOT NULL DEFAULT 0,batch_id TEXT);
      CREATE TABLE IF NOT EXISTS batches(id TEXT PRIMARY KEY,created_at INTEGER NOT NULL,state TEXT NOT NULL,accepted_at INTEGER);");
    $initialized = $db->querySingle("SELECT value FROM meta WHERE key='initialized'");
    if (!$initialized && $mode !== 'init') throw new RuntimeException('initialize_before_sending');
    if ($initialized && $mode === 'init') { echo "{\"status\":\"already_initialized\"}\n"; exit; }
    $source = new SQLite3($c['queue'], SQLITE3_OPEN_READONLY); $source->enableExceptions(true); $source->busyTimeout(5000);
    $receipts = $source->query("SELECT d.submission_id FROM delivery_receipts d JOIN submissions s ON s.id=d.submission_id WHERE s.kind='business'");
    $db->exec('BEGIN IMMEDIATE');
    while ($r = $receipts->fetchArray(SQLITE3_ASSOC)) {
        enqueue($db, 'business:'.$r['submission_id'], 'business', '');
    }
    $healthState = 'DEGRADED'; $failed = ['health_monitor'];
    try {
        $h = json_decode(file_get_contents($c['health']), true, 32, JSON_THROW_ON_ERROR);
        $at = strtotime($h['at'] ?? '');
        if ($at === false || time()-$at > 1500 || $at > time()+60) throw new RuntimeException('stale_health');
        $failed = [];
        foreach ($h['checks'] as $check) if (($check['pass'] ?? false) !== true) {
            $name = $check['name'] ?? '';
            if (!preg_match('/^[a-z_]{1,40}$/D', $name)) throw new RuntimeException('invalid_check');
            $failed[] = $name;
        }
        $healthState = $h['status'] === 'OK' && !$failed ? 'OK' : 'DEGRADED';
    } catch (Throwable $ignored) { $healthState = 'DEGRADED'; $failed = ['health_monitor']; }
    sort($failed); $signature = $healthState.':'.implode(',', $failed);
    $prior = $db->querySingle("SELECT value FROM meta WHERE key='health'");
    if ($initialized && $signature !== $prior) enqueue($db, 'health:'.bin2hex(random_bytes(16)), 'health', $signature);
    statement($db, "INSERT INTO meta(key,value) VALUES('health',:v) ON CONFLICT(key) DO UPDATE SET value=excluded.value", [':v'=>$signature]);
    if (!$initialized) {
        $db->exec("UPDATE events SET state='baseline'; INSERT INTO meta(key,value) VALUES('initialized',datetime('now'))");
        if ($healthState !== 'OK') enqueue($db, 'health:initial', 'health', $signature);
    }
    // Interrupted sendmail calls are ambiguous. Do not blindly send them again.
    $db->exec("UPDATE events SET state='uncertain' WHERE state='sending'; UPDATE batches SET state='uncertain' WHERE state='sending'");
    if ($mode === 'probe') enqueue($db, 'probe:installation-v1', 'probe', 'Installation verification');
    $db->exec('COMMIT');
    if ($mode === 'init' || $mode === 'probe') { echo json_encode(['status'=>$mode==='init'?'initialized':'probe_queued'])."\n"; exit; }
    $used = statement($db, 'SELECT COUNT(*) AS n FROM batches WHERE created_at>:since', [':since'=>time()-86400])->fetchArray(SQLITE3_ASSOC)['n'];
    // At most 24 attempts/rolling day, one message per scheduler invocation.
    if ($used >= 24) { echo "{\"status\":\"daily_limit\"}\n"; exit; }
    $last = (int)$db->querySingle('SELECT MAX(created_at) FROM batches');
    if ($last > time()-60) { echo "{\"status\":\"rate_limited\"}\n"; exit; }
    $q = statement($db, "SELECT * FROM events WHERE state='pending' AND next_at<=:now ORDER BY created_at,id LIMIT 100", [':now'=>time()]);
    $events = []; while ($e = $q->fetchArray(SQLITE3_ASSOC)) $events[] = $e;
    if (!$events) { echo "{\"status\":\"idle\"}\n"; exit; }
    $business = count(array_filter($events, fn($e)=>$e['kind']==='business'));
    $health = array_values(array_filter($events, fn($e)=>$e['kind']==='health'));
    $probe = count(array_filter($events, fn($e)=>$e['kind']==='probe'));
    $subject = '[YouNew] '.($probe?'Notification delivery verification':($health?'Service status update':$business.' new business inquiries'));
    $body = "YouNew service notification\n\n";
    if ($probe) $body .= "This verifies notification delivery on Hostinger. No customer inquiry was created.\n\n";
    if ($business) $body .= $business." new business inquiries are available in Admin.\nhttps://admin.younew.nl/business-inquiries\n\n";
    foreach ($health as $e) $body .= 'Service status: '.$e['detail']."\n";
    $body .= "\nOpen Admin: https://admin.younew.nl/\nNo customer names, contacts or inquiry text are included.\n";
    $batch = bin2hex(random_bytes(16));
    $db->exec('BEGIN IMMEDIATE');
    statement($db, "INSERT INTO batches(id,created_at,state) VALUES(:id,:at,'sending')", [':id'=>$batch, ':at'=>time()]);
    foreach ($events as $e) statement($db, "UPDATE events SET state='sending',attempts=attempts+1,batch_id=:batch WHERE id=:id", [':batch'=>$batch,':id'=>$e['id']]);
    $db->exec('COMMIT');
    if ($transport === 'capture') {
        $ok = file_put_contents($state.'/capture.jsonl', json_encode(['subject'=>$subject,'body'=>$body])."\n", FILE_APPEND|LOCK_EX) !== false;
    } elseif ($transport === 'reject') $ok = false;
    else $ok = mail($c['recipient'], $subject, $body, ['From'=>'YouNew <support@younew.nl>','Content-Type'=>'text/plain; charset=UTF-8','Auto-Submitted'=>'auto-generated','Message-ID'=>'<younew-'.$batch.'@younew.nl>']);
    $db->exec('BEGIN IMMEDIATE');
    statement($db, 'UPDATE batches SET state=:state,accepted_at=:at WHERE id=:id', [':state'=>$ok?'accepted':'rejected', ':at'=>$ok?time():0, ':id'=>$batch]);
    foreach ($events as $e) {
        $attempts=(int)$e['attempts']+1;
        statement($db, 'UPDATE events SET state=:state,next_at=:next WHERE id=:id', [':state'=>$ok?'accepted':($attempts>=4?'failed':'pending'), ':next'=>time()+min(3600,300*(2**($attempts-1))), ':id'=>$e['id']]);
    }
    $db->exec('COMMIT');
    echo json_encode(['status'=>$ok?'accepted_by_local_mailer':'retry_or_failed','events'=>count($events),'businessCount'=>$business,'healthCount'=>count($health),'probeCount'=>$probe,'at'=>gmdate('c')])."\n";
    exit($ok?0:1);
} catch (Throwable $e) {
    // Do not emit connection paths, mail config or user data in error output.
    fwrite(STDERR, json_encode(['status'=>'notification_worker_error','at'=>gmdate('c')])."\n"); exit(1);
}
