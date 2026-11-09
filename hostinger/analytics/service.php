<?php
declare(strict_types=1);
namespace YouNewAnalytics;

const CONSENT_VERSION = '2026-10-26-hostinger';
// One-day margin keeps routine scheduled cleanup within the public 90-day upper bound.
const RETENTION_SECONDS = 89 * 86400;
const ORIGINS = ['https://younew.nl', 'https://www.younew.nl'];
const PROPERTY_KEYS = [
    'page_view'=>[], 'profile_selected'=>[], 'lead_start'=>[], 'lead_submit'=>[], 'pilot_request'=>[], 'analytics_consent_granted'=>[],
    'search'=>['normalized_query_safe','intent_ids','filter_type','filter_city','filter_province','filter_category','filter_profile','result_count','has_results','zero_result','fallback_tier'],
    'search_result_opened'=>['content_id','position','normalized_query_safe'],
    'explicit_city_detected'=>['city','intent_id'], 'city_filter_applied'=>['city','source'], 'city_filter_corrected'=>['city','source'],
    'local_result_available'=>['city','intent_id'], 'national_fallback_shown'=>['city','intent_id'], 'wrong_geo_result_reported'=>['city','intent_id'],
    'action_panel_cta_clicked'=>['content_id','city'], 'time_to_first_action'=>['city','intent_id','duration_ms'],
    'official_source_click'=>['content_id'], 'partner_click'=>['content_id'], 'item_saved'=>['content_id'],
    'app_cta_click'=>['location'], 'business_mailto_prepared'=>['organization_type'],
];

final class RequestError extends \RuntimeException {
    public function __construct(public int $status, string $message) { parent::__construct($message); }
}
function invalid(): never { throw new RequestError(400, 'invalid_event_batch'); }
function section(string $screen): string {
    $parts = explode('/', trim(explode('?', explode('#', $screen)[0])[0], '/'));
    $nl = ($parts[0] ?? '') === 'nl';
    $first = $parts[$nl ? 1 : 0] ?? '';
    $allowed = ['search','zoeken','for-business','voor-bedrijven','partners','business','support','privacy','terms','app','start','saved','my-younew','guides','essentials','journeys','cities','city-guides','municipalities','gemeenten','provinces','provincies','places','plekken','organizations','organisaties','categories','categorieen','map','discover','arrival-planner','emergency','status','updates','offline','acquisition'];
    if ($first === '') return $nl ? '/nl/' : '/';
    return in_array($first, $allowed, true) ? ($nl ? '/nl/' : '/') . $first . '/' : '/other/';
}

/** Never persist free text, query phrases, form data, raw UUIDs, IPs, or user-agent headers. */
function normalize(mixed $input): array {
    if (!$input instanceof \stdClass || array_keys((array)$input) !== ['events'] || !is_array($input->events) || !array_is_list($input->events) || count($input->events) < 1 || count($input->events) > 20) invalid();
    $result = [];
    $keys = ['client_event_id','app_instance_id','session_id','event_name','screen','platform','app_version','language','properties','occurred_at','consent_version','schema_version','environment'];
    foreach ($input->events as $event) {
        if (!$event instanceof \stdClass || count((array)$event) !== count($keys) || array_diff(array_keys((array)$event), $keys)) invalid();
        foreach (['client_event_id','app_instance_id','session_id'] as $key) if (!is_string($event->$key) || !preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/Di', $event->$key)) invalid();
        if (!is_string($event->event_name) || !array_key_exists($event->event_name, PROPERTY_KEYS) || $event->platform !== 'Web' || $event->schema_version !== 1 || $event->consent_version !== CONSENT_VERSION || $event->environment !== 'production') invalid();
        if (!is_string($event->screen) || strlen($event->screen) > 160 || !str_starts_with($event->screen, '/') || str_starts_with($event->screen, '//')) invalid();
        if (!is_string($event->language) || !preg_match('/^[a-z]{2}(?:-[a-zA-Z]{2,8})?$/D', $event->language)) invalid();
        if (!is_string($event->app_version) || !preg_match('/^[a-zA-Z0-9._-]{1,80}$/D', $event->app_version)) invalid();
        if (!is_string($event->occurred_at) || !preg_match('/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z$/D', $event->occurred_at) || strtotime($event->occurred_at) === false) invalid();
        if (!$event->properties instanceof \stdClass) invalid();
        $properties = (array)$event->properties;
        if (array_diff(array_keys($properties), PROPERTY_KEYS[$event->event_name])) invalid();
        foreach ($properties as $value) if (!(is_bool($value) || is_int($value) || (is_string($value) && strlen($value) <= 640))) invalid();
        $count = null; $zero = null; $tier = null; $duration = null;
        if ($event->event_name === 'search') {
            $count = $properties['result_count'] ?? null; $zero = $properties['zero_result'] ?? null; $tier = $properties['fallback_tier'] ?? null;
            if (!is_int($count) || $count < 0 || $count > 100000 || !is_bool($zero) || $zero !== ($count === 0) || ($properties['has_results'] ?? null) !== !$zero || !in_array($tier, ['exact','national','broadened'], true)) invalid();
        }
        if ($event->event_name === 'time_to_first_action') {
            $duration = $properties['duration_ms'] ?? null;
            if (!is_int($duration) || $duration < 0 || $duration > 3600000) invalid();
        }
        $result[] = ['event_id'=>strtolower($event->client_event_id), 'session_id'=>strtolower($event->session_id), 'event'=>$event->event_name,
            'section'=>section($event->screen), 'language'=>in_array($event->language,['en','nl'],true) ? $event->language : 'other',
            'result_count'=>$count, 'zero_result'=>$zero === null ? null : (int)$zero, 'fallback_tier'=>$tier, 'duration_ms'=>$duration];
    }
    return $result;
}

final class Store {
    private \SQLite3 $db;
    private string $salt;
    public function __construct(private string $directory, string $publicRoot) {
        umask(0077);
        if (!is_dir($directory) && !mkdir($directory,0700,true) && !is_dir($directory)) throw new \RuntimeException('Storage unavailable');
        $real = realpath($directory); $public = realpath($publicRoot);
        if ($real === false || $public === false || $real === $public || str_starts_with($real,$public.DIRECTORY_SEPARATOR) || is_link($directory)) throw new \RuntimeException('Private storage required');
        if (!chmod($directory,0700) || is_link($directory.'/analytics.sqlite')) throw new \RuntimeException('Private storage required');
        $this->db = new \SQLite3($directory.'/analytics.sqlite'); $this->db->enableExceptions(true); $this->db->busyTimeout(5000);
        $this->db->exec('PRAGMA journal_mode=DELETE; PRAGMA synchronous=FULL; PRAGMA trusted_schema=OFF; PRAGMA secure_delete=ON;');
        if (!chmod($directory.'/analytics.sqlite',0600)) throw new \RuntimeException('Private permissions required');
        $this->db->exec('CREATE TABLE IF NOT EXISTS settings(name TEXT PRIMARY KEY,value TEXT NOT NULL);
            CREATE TABLE IF NOT EXISTS events(event_hash TEXT PRIMARY KEY,session_hash TEXT NOT NULL,received_at INTEGER NOT NULL,day TEXT NOT NULL,event TEXT NOT NULL,section TEXT NOT NULL,language TEXT NOT NULL,result_count INTEGER,zero_result INTEGER,fallback_tier TEXT,duration_ms INTEGER);
            CREATE INDEX IF NOT EXISTS event_retention ON events(received_at);
            CREATE INDEX IF NOT EXISTS event_day ON events(day,event);
            CREATE TABLE IF NOT EXISTS rate_windows(bucket TEXT PRIMARY KEY,total INTEGER NOT NULL,expires INTEGER NOT NULL);');
        $this->execute("INSERT OR IGNORE INTO settings(name,value) VALUES('salt',:value)",[':value'=>bin2hex(random_bytes(32))]);
        $this->salt = (string)$this->db->querySingle("SELECT value FROM settings WHERE name='salt'");
    }
    private function execute(string $sql,array $values=[]): \SQLite3Result {
        $s=$this->db->prepare($sql);
        foreach($values as $key=>$value) $s->bindValue($key,$value,$value === null ? SQLITE3_NULL : (is_int($value) ? SQLITE3_INTEGER : SQLITE3_TEXT));
        return $s->execute();
    }
    private function limit(string $identity,int $amount,int $maximum,int $now): void {
        $window=intdiv($now,60)*60; $bucket=hash_hmac('sha256',$identity.':'.$window,$this->salt);
        $row=$this->execute('SELECT total FROM rate_windows WHERE bucket=:bucket',[':bucket'=>$bucket])->fetchArray(SQLITE3_ASSOC);
        if (($row['total'] ?? 0)+$amount>$maximum) throw new RequestError(429,'rate_limited');
        $this->execute('INSERT INTO rate_windows(bucket,total,expires) VALUES(:bucket,:amount,:expires) ON CONFLICT(bucket) DO UPDATE SET total=total+:amount',[':bucket'=>$bucket,':amount'=>$amount,':expires'=>$window+60]);
    }
    private function expire(int $now): void {
        $this->execute('DELETE FROM events WHERE received_at<=:cutoff',[':cutoff'=>$now-RETENTION_SECONDS]);
        $this->execute('DELETE FROM rate_windows WHERE expires<=:now',[':now'=>$now]);
    }
    public function ingest(array $events,string $network,?int $now=null): int {
        $now ??= time(); $day=gmdate('Y-m-d',$now); $accepted=0;
        $this->db->exec('BEGIN IMMEDIATE');
        try {
            $this->expire($now); $this->limit('network:'.$network,1,300,$now);
            $total=(int)$this->db->querySingle('SELECT COUNT(*) FROM events');
            foreach($events as $event) {
                $hash=hash_hmac('sha256','event:'.$event['event_id'],$this->salt);
                if ($this->execute('SELECT 1 FROM events WHERE event_hash=:hash',[':hash'=>$hash])->fetchArray()) continue;
                if ($total+$accepted>=300000) throw new RequestError(503,'capacity_reached');
                $session=hash_hmac('sha256','session:'.$day.':'.$event['session_id'],$this->salt);
                $this->limit('session:'.$session,1,120,$now);
                $this->execute('INSERT INTO events VALUES(:hash,:session,:time,:day,:event,:section,:language,:count,:zero,:tier,:duration)',[
                    ':hash'=>$hash,':session'=>$session,':time'=>$now,':day'=>$day,':event'=>$event['event'],':section'=>$event['section'],':language'=>$event['language'],
                    ':count'=>$event['result_count'],':zero'=>$event['zero_result'],':tier'=>$event['fallback_tier'],':duration'=>$event['duration_ms']]);
                $accepted++;
            }
            $this->db->exec('COMMIT');
        } catch(\Throwable $e) { $this->db->exec('ROLLBACK'); throw $e; }
        $this->export($now,false);
        return $accepted;
    }
    private function rows(string $sql): array {
        $result=$this->db->query($sql);$rows=[];while($row=$result->fetchArray(SQLITE3_ASSOC))$rows[]=$row;return $rows;
    }
    public function maintain(?int $now=null): array {
        $now ??= time(); $this->db->exec('BEGIN IMMEDIATE');
        try { $this->expire($now); $this->execute("INSERT INTO settings(name,value) VALUES('last_maintenance',:value) ON CONFLICT(name) DO UPDATE SET value=:value",[':value'=>gmdate('c',$now)]); $this->db->exec('COMMIT'); }
        catch(\Throwable $e) { $this->db->exec('ROLLBACK');throw $e; }
        $snapshot=$this->directory.'/analytics.snapshot.sqlite';
        return $this->export($now,!is_file($snapshot) || $now-filemtime($snapshot)>=86400);
    }
    private function export(int $now,bool $snapshot): array {
        $lock=fopen($this->directory.'/report.lock','c');if(!$lock || !flock($lock,LOCK_EX))throw new \RuntimeException('Report unavailable');
        $temp=null;
        try {
            $this->db->exec('BEGIN');
            try {
                $report=['generatedAt'=>gmdate('c',$now),'retentionDays'=>90,'source'=>'Hostinger PHP/SQLite — consented website events only',
                    'lastMaintenance'=>$this->db->querySingle("SELECT value FROM settings WHERE name='last_maintenance'"),
                    'totalEvents'=>(int)$this->db->querySingle('SELECT COUNT(*) FROM events'),
                    'daily'=>$this->rows('SELECT day,COUNT(*) AS events,COUNT(DISTINCT session_hash) AS browser_tab_sessions,SUM(event=\'page_view\') AS page_views FROM events GROUP BY day ORDER BY day DESC'),
                    'events'=>$this->rows('SELECT event,COUNT(*) AS total FROM events GROUP BY event ORDER BY total DESC'),
                    'pages'=>$this->rows("SELECT section,language,COUNT(*) AS page_views FROM events WHERE event='page_view' GROUP BY section,language ORDER BY page_views DESC"),
                    'search'=>$this->rows("SELECT fallback_tier,COUNT(*) AS searches,SUM(zero_result) AS zero_results,ROUND(AVG(result_count),2) AS average_results FROM events WHERE event='search' GROUP BY fallback_tier"),
                    'firstAction'=>$this->rows("SELECT COUNT(*) AS samples,ROUND(AVG(duration_ms)) AS average_ms FROM events WHERE event='time_to_first_action'"),
                    'notes'=>['Sessions are browser-tab counts per UTC day, not unique people.','Counts depend on visitor consent and can include bots or synthetic QA.','No search phrases, profile filters, form contents, raw IPs or raw session IDs are stored.','Historical Supabase events are not imported.']];
                $this->db->exec('COMMIT');
            } catch(\Throwable $e) { $this->db->exec('ROLLBACK');throw $e; }
            $body=json_encode($report,JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR);
            $temp=$this->directory.'/report-'.bin2hex(random_bytes(8)).'.tmp';
            if(file_put_contents($temp,$body,LOCK_EX)!==strlen($body)||!chmod($temp,0600)||!rename($temp,$this->directory.'/report.json'))throw new \RuntimeException('Report unavailable');
            $temp=null;
            if($snapshot) {
                $temp=$this->directory.'/snapshot-'.bin2hex(random_bytes(8)).'.tmp';$copy=new \SQLite3($temp);$copy->enableExceptions(true);
                if(!$this->db->backup($copy))throw new \RuntimeException('Snapshot unavailable');$copy->close();
                if(!chmod($temp,0600)||!rename($temp,$this->directory.'/analytics.snapshot.sqlite'))throw new \RuntimeException('Snapshot unavailable');$temp=null;
            }
            return $report;
        } finally { if($temp&&is_file($temp))unlink($temp);flock($lock,LOCK_UN);fclose($lock); }
    }
}

function handle(string $body,array $server,string $storage,string $publicRoot): array {
    $headers=['Content-Type'=>'application/json; charset=utf-8','Cache-Control'=>'no-store, max-age=0','X-Content-Type-Options'=>'nosniff','X-Robots-Tag'=>'noindex, nofollow','Vary'=>'Origin'];
    try {
        $origin=$server['HTTP_ORIGIN']??'';if(!in_array($origin,ORIGINS,true))throw new RequestError(403,'origin_not_allowed');
        $headers+=['Access-Control-Allow-Origin'=>$origin,'Access-Control-Allow-Methods'=>'POST, OPTIONS','Access-Control-Allow-Headers'=>'content-type'];
        if(($server['REQUEST_METHOD']??'')==='OPTIONS')return [204,$headers,null];
        if(($server['REQUEST_METHOD']??'')!=='POST')throw new RequestError(405,'method_not_allowed');
        if(!preg_match('/^application\/json(?:\s*;|$)/i',$server['CONTENT_TYPE']??''))throw new RequestError(415,'json_required');
        if(strlen($body)>65536||(int)($server['CONTENT_LENGTH']??0)>65536)throw new RequestError(413,'payload_too_large');
        try{$input=json_decode($body,false,20,JSON_THROW_ON_ERROR);}catch(\JsonException){invalid();}
        $events=normalize($input);$network=$server['REMOTE_ADDR']??'';
        if(!filter_var($network,FILTER_VALIDATE_IP))throw new RequestError(503,'service_unavailable');
        $store=new Store($storage,$publicRoot);$accepted=$store->ingest($events,$network);
        return [202,$headers,['accepted'=>$accepted,'stored'=>true]];
    }catch(RequestError $e){if($e->status===429)$headers['Retry-After']='60';if($e->status===405)$headers['Allow']='POST, OPTIONS';return[$e->status,$headers,['accepted'=>0,'stored'=>false,'error'=>$e->getMessage()]];}
    catch(\Throwable){error_log('YouNew analytics temporarily unavailable');return[503,$headers,['accepted'=>0,'stored'=>false,'error'=>'service_unavailable']];}
}
function run(string $storage): never {
    ini_set('display_errors','0');$body=file_get_contents('php://input',false,null,0,65537);
    [$status,$headers,$result]=handle($body===false?'':$body,$_SERVER,$storage,(string)($_SERVER['DOCUMENT_ROOT']??''));
    http_response_code($status);foreach($headers as $key=>$value)header($key.': '.$value);
    if($result!==null)echo json_encode($result,JSON_THROW_ON_ERROR);exit;
}
