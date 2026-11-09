<?php
declare(strict_types=1);

namespace YouNewForms;

const CONSENT_VERSION = '2026-10-26-hostinger';
const ORIGINS = ['https://younew.nl', 'https://www.younew.nl'];

final class RequestError extends \RuntimeException
{
    public function __construct(public int $status, public array $response)
    {
        parent::__construct((string) ($response['error'] ?? 'request_failed'));
    }
}

function invalid(array $fields): never
{
    throw new RequestError(400, ['error' => 'validation_failed', 'fields' => array_values(array_unique($fields))]);
}

/** Keep only explicitly supported fields; never persist the raw request or headers. */
function normalize(string $kind, mixed $input): array
{
    if (!is_object($input) || !($input instanceof \stdClass)) invalid(['form']);
    $values = (array) $input;
    $errors = [];
    $text = static function (string $name, int $min, int $max) use ($values, &$errors): string {
        $value = $values[$name] ?? '';
        if (!is_string($value)) { $errors[] = $name; return ''; }
        $value = trim($value);
        $length = preg_match_all('/./us', $value);
        if ($length === false || $length < $min || $length > $max || preg_match('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/u', $value)) $errors[] = $name;
        return $value;
    };
    $enum = static function (string $name, array $allowed) use ($text, &$errors): string {
        $value = $text($name, 1, 100);
        if (!in_array($value, $allowed, true)) $errors[] = $name;
        return $value;
    };
    $selection = static function (string $name, array $allowed) use ($values, &$errors): array {
        $value = $values[$name] ?? null;
        if (!is_array($value) || !array_is_list($value) || count($value) < 1 || count($value) > count($allowed)) { $errors[] = $name; return []; }
        foreach ($value as $item) if (!is_string($item) || !in_array($item, $allowed, true)) { $errors[] = $name; return []; }
        if (count(array_unique($value)) !== count($value)) $errors[] = $name;
        sort($value, SORT_STRING);
        return $value;
    };
    if ($text('websiteConfirmation', 0, 0) !== '') $errors[] = 'form';
    if (($values['consentToPrivacy'] ?? null) !== true) $errors[] = 'consentToPrivacy';
    $result = ['consentToPrivacy' => true];
    $email = strtolower($text('email', $kind === 'business' ? 3 : 0, 254));
    if ($email !== '' && !preg_match('/^[^\s@]+@[^\s@]+\.[^\s@]+$/u', $email)) $errors[] = 'email';
    $result['email'] = $email;
    if ($kind === 'feedback') {
        $result['feedbackType'] = $enum('feedbackType', ['incorrect-information', 'product-problem', 'accessibility', 'privacy', 'suggestion', 'other']);
        $result['message'] = $text('message', 20, 2000);
        $result['pageReference'] = $text('pageReference', 1, 300);
        if (!str_starts_with($result['pageReference'], '/') || str_starts_with($result['pageReference'], '//') || str_contains($result['pageReference'], '\\')) $errors[] = 'pageReference';
    } elseif ($kind === 'business') {
        foreach (['companyName' => [2,120], 'contactPerson' => [2,120], 'phone' => [0,40], 'website' => [1,300], 'city' => [2,100], 'province' => [2,100], 'campaignGoal' => [10,240], 'description' => [30,600]] as $key => [$min,$max]) $result[$key] = $text($key, $min, $max);
        if ($result['phone'] !== '' && strlen($result['phone']) < 6) $errors[] = 'phone';
        $url = parse_url($result['website']);
        if (!$url || !in_array(strtolower($url['scheme'] ?? ''), ['https','http'], true) || empty($url['host']) || isset($url['user']) || isset($url['pass'])) $errors[] = 'website';
        $result['inquiryType'] = $enum('inquiryType', ['advertising','partnership','media','public-interest','other']);
        $result['organizationType'] = $enum('organizationType', ['commercial-business','sole-trader','advertising-agency','non-profit','public-organization','education','healthcare','other']);
        $result['offerInterest'] = $enum('offerInterest', ['not_specified','onboarding_pilot','founding_partner_page','sponsored_practical_guide','other']);
        $result['contactRole'] = $text('contactRole', $result['offerInterest'] === 'onboarding_pilot' ? 2 : 0, 120);
        if ($result['contactRole'] !== '' && strlen($result['contactRole']) < 2) $errors[] = 'contactRole';
        $result['kvkNumber'] = $text('kvkNumber', 0, 8);
        $needsKvk = in_array($result['organizationType'], ['commercial-business','sole-trader','advertising-agency'], true);
        if (($needsKvk || $result['kvkNumber'] !== '') && !preg_match('/^[0-9]{8}$/D', $result['kvkNumber'])) $errors[] = 'kvkNumber';
        $result['targetAudience'] = $selection('targetAudience', ['tourist','student','expat','refugee','worker','resident']);
        $result['requestedPlacements'] = $selection('requestedPlacements', ['featured-local-partner','sponsored-listing','sponsored-city-placement','sponsored-category-placement','featured-offer','verified-organization-profile','local-deal','campaign-banner','content-partnership','referral-affiliate']);
        $result['budgetRange'] = $enum('budgetRange', ['under-1000','1000-3000','3000-10000','over-10000','request-discussion']);
        foreach (['campaignStart','campaignEnd'] as $key) {
            $result[$key] = $text($key, 0, 10);
            if ($result[$key] !== '') {
                $date = \DateTimeImmutable::createFromFormat('!Y-m-d', $result[$key]);
                if (!$date || $date->format('Y-m-d') !== $result[$key]) $errors[] = $key;
            }
        }
        if (($result['campaignStart'] === '') !== ($result['campaignEnd'] === '') || $result['campaignEnd'] < $result['campaignStart']) $errors[] = 'campaignEnd';
        if (($values['confirmAccuracy'] ?? null) !== true) $errors[] = 'confirmAccuracy';
        $result['confirmAccuracy'] = true;
        $result['sourcePage'] = $enum('sourcePage', ['/business/apply/','/partners/apply/','/for-business/local/apply/','/nl/voor-bedrijven/aanmelden/']);
        foreach (['utmSource','utmMedium','utmCampaign','utmContent','utmTerm'] as $key) $result[$key] = $text($key, 0, in_array($key, ['utmSource','utmMedium'], true) ? 120 : 160);
    } else {
        throw new \LogicException('Unsupported form');
    }
    foreach (array_keys($values) as $key) if ($key !== 'websiteConfirmation' && !array_key_exists($key, $result)) $errors[] = 'form';
    if ($errors) invalid($errors);
    ksort($result);
    return $result;
}

final class Store
{
    private \SQLite3 $db;
    private string $salt;

    public function __construct(private string $directory, string $documentRoot)
    {
        umask(0077);
        if (!is_dir($directory) && !mkdir($directory, 0700, true) && !is_dir($directory)) throw new \RuntimeException('Storage unavailable');
        $real = realpath($directory);
        $public = realpath($documentRoot);
        if ($real === false || $public === false || $real === $public || str_starts_with($real, $public . DIRECTORY_SEPARATOR) || is_link($directory)) throw new \RuntimeException('Private storage required');
        if (!chmod($directory, 0700)) throw new \RuntimeException('Private permissions required');
        $path = $directory . '/submissions.sqlite';
        if (is_link($path)) throw new \RuntimeException('Invalid storage');
        $this->db = new \SQLite3($path, SQLITE3_OPEN_READWRITE | SQLITE3_OPEN_CREATE);
        $this->db->enableExceptions(true);
        $this->db->busyTimeout(5000);
        $this->db->exec('PRAGMA journal_mode=DELETE; PRAGMA synchronous=FULL; PRAGMA trusted_schema=OFF;');
        if (!chmod($path, 0600)) throw new \RuntimeException('Private permissions required');
        $this->db->exec('CREATE TABLE IF NOT EXISTS settings (name TEXT PRIMARY KEY, value TEXT NOT NULL);
            CREATE TABLE IF NOT EXISTS submissions (id TEXT PRIMARY KEY, kind TEXT NOT NULL, payload TEXT NOT NULL, dedupe TEXT NOT NULL UNIQUE, created_at TEXT NOT NULL, consent_version TEXT NOT NULL, status TEXT NOT NULL DEFAULT \'new\');
            CREATE TABLE IF NOT EXISTS rate_windows (bucket TEXT PRIMARY KEY, total INTEGER NOT NULL, expires INTEGER NOT NULL);');
        $this->db->exec('CREATE TABLE IF NOT EXISTS delivery_receipts (submission_id TEXT PRIMARY KEY REFERENCES submissions(id), remote_id TEXT NOT NULL, delivered_at TEXT NOT NULL);');
        $this->execute('INSERT OR IGNORE INTO settings(name,value) VALUES (\'salt\', :value)', [':value' => bin2hex(random_bytes(32))]);
        $this->salt = (string) $this->db->querySingle("SELECT value FROM settings WHERE name='salt'");
    }

    private function execute(string $sql, array $values = []): \SQLite3Result
    {
        $statement = $this->db->prepare($sql);
        foreach ($values as $name => $value) $statement->bindValue($name, $value, is_int($value) ? SQLITE3_INTEGER : SQLITE3_TEXT);
        return $statement->execute();
    }

    private function limit(string $identity, int $seconds, int $maximum, int $now): void
    {
        $window = intdiv($now, $seconds) * $seconds;
        $key = hash_hmac('sha256', $identity . ':' . $window, $this->salt);
        $row = $this->execute('SELECT total FROM rate_windows WHERE bucket=:bucket', [':bucket'=>$key])->fetchArray(SQLITE3_ASSOC);
        if ($row && $row['total'] >= $maximum) throw new RequestError(429, ['error'=>'rate_limited']);
        $this->execute('INSERT INTO rate_windows(bucket,total,expires) VALUES(:bucket,1,:expires) ON CONFLICT(bucket) DO UPDATE SET total=total+1', [':bucket'=>$key, ':expires'=>$window+$seconds]);
    }

    public function submit(string $kind, array $payload, string $networkAddress, ?int $now = null): array
    {
        $now ??= time();
        $encoded = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
        $dedupe = hash_hmac('sha256', $kind . ':' . $encoded, $this->salt);
        $this->db->exec('BEGIN IMMEDIATE');
        try {
            $this->execute('DELETE FROM rate_windows WHERE expires<:now', [':now'=>$now]);
            $this->limit('attempt:' . $networkAddress, 900, 40, $now);
            $row = $this->execute('SELECT id,created_at FROM submissions WHERE dedupe=:dedupe', [':dedupe'=>$dedupe])->fetchArray(SQLITE3_ASSOC);
            if (!$row) {
                $this->limit('network:' . $networkAddress, 900, 8, $now);
                if ($payload['email'] !== '') $this->limit('email:' . $payload['email'], 3600, 4, $now);
                $row = ['id'=>($kind === 'business' ? 'YNI-' : 'YNF-') . strtoupper(bin2hex(random_bytes(6))), 'created_at'=>gmdate('Y-m-d\TH:i:s\Z', $now)];
                $this->execute('INSERT INTO submissions(id,kind,payload,dedupe,created_at,consent_version) VALUES(:id,:kind,:payload,:dedupe,:created,:consent)', [':id'=>$row['id'], ':kind'=>$kind, ':payload'=>$encoded, ':dedupe'=>$dedupe, ':created'=>$row['created_at'], ':consent'=>CONSENT_VERSION]);
            }
            $this->db->exec('COMMIT');
        } catch (\Throwable $error) {
            $this->db->exec('ROLLBACK');
            throw $error;
        }
        // A retry repairs an interrupted export and returns the original receipt.
        $this->refreshReviewFiles();
        return ['confirmationId'=>$row['id'], 'createdAt'=>$row['created_at']];
    }

    private function refreshReviewFiles(): void
    {
        $lock = fopen($this->directory . '/review.lock', 'c');
        if (!$lock || !flock($lock, LOCK_EX)) throw new \RuntimeException('Review export unavailable');
        $temporary = null;
        try {
            $rows = $this->db->query('SELECT id,kind,payload,created_at,consent_version,status FROM submissions ORDER BY rowid DESC LIMIT 200');
            $items = [];
            while ($row = $rows->fetchArray(SQLITE3_ASSOC)) {
                $row['payload'] = json_decode($row['payload'], true, 32, JSON_THROW_ON_ERROR);
                $items[] = $row;
            }
            $body = json_encode(['generatedAt'=>gmdate('c'), 'total'=>$this->db->querySingle('SELECT COUNT(*) FROM submissions'), 'latest'=>$items], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
            $temporary = $this->directory . '/review-' . bin2hex(random_bytes(8)) . '.tmp';
            if (file_put_contents($temporary, $body, LOCK_EX) !== strlen($body) || !chmod($temporary, 0600) || !rename($temporary, $this->directory . '/inbox-latest.json')) throw new \RuntimeException('Review export unavailable');
            $temporary = $this->directory . '/snapshot-' . bin2hex(random_bytes(8)) . '.tmp';
            $snapshot = new \SQLite3($temporary);
            $snapshot->enableExceptions(true);
            if (!$this->db->backup($snapshot)) throw new \RuntimeException('Snapshot unavailable');
            $snapshot->close();
            if (!chmod($temporary, 0600) || !rename($temporary, $this->directory . '/submissions.snapshot.sqlite')) throw new \RuntimeException('Snapshot unavailable');
            $temporary = null;
        } finally {
            if ($temporary && is_file($temporary)) unlink($temporary);
            flock($lock, LOCK_UN);
            fclose($lock);
        }
    }

    /** Durable outbox: acknowledgement is written only after remote commit. */
    public function pendingDeliveries(int $limit = 100): array
    {
        if ($limit < 1 || $limit > 100) throw new \InvalidArgumentException('Invalid batch size');
        $result = $this->execute('SELECT s.id,s.kind,s.payload,s.created_at,s.consent_version FROM submissions s LEFT JOIN delivery_receipts d ON d.submission_id=s.id WHERE d.submission_id IS NULL ORDER BY s.rowid LIMIT :limit', [':limit'=>$limit]);
        $rows = [];
        while ($row = $result->fetchArray(SQLITE3_ASSOC)) { $row['payload'] = json_decode($row['payload'], true, 32, JSON_THROW_ON_ERROR); $rows[] = $row; }
        return $rows;
    }

    public function acknowledgeDelivery(string $id, string $remoteId): void
    {
        if (!preg_match('/^YN[IF]-[A-F0-9]{12}$/D', $id) || !preg_match('/^[a-f0-9-]{36}$/D', $remoteId)) throw new \InvalidArgumentException('Invalid acknowledgement');
        $this->execute('INSERT INTO delivery_receipts(submission_id,remote_id,delivered_at) VALUES(:id,:remote,:now) ON CONFLICT(submission_id) DO NOTHING', [':id'=>$id, ':remote'=>$remoteId, ':now'=>gmdate('c')]);
    }
}

/** No read/list endpoint exists. Only a validated submission can return its own receipt. */
function handle(string $kind, string $body, array $server, string $storage, string $documentRoot, array $allowedOrigins = ORIGINS): array
{
    $origin = $server['HTTP_ORIGIN'] ?? '';
    $headers = ['Content-Type'=>'application/json; charset=utf-8', 'Cache-Control'=>'no-store, max-age=0', 'X-Content-Type-Options'=>'nosniff', 'X-Robots-Tag'=>'noindex, nofollow', 'Vary'=>'Origin'];
    try {
        if (!in_array($origin, $allowedOrigins, true)) throw new RequestError(403, ['error'=>'origin_not_allowed']);
        $headers += ['Access-Control-Allow-Origin'=>$origin, 'Access-Control-Allow-Methods'=>'POST, OPTIONS', 'Access-Control-Allow-Headers'=>'content-type'];
        $method = $server['REQUEST_METHOD'] ?? '';
        if ($method === 'OPTIONS') return [204, $headers, null];
        if ($method !== 'POST') throw new RequestError(405, ['error'=>'method_not_allowed']);
        if (!preg_match('/^application\/json(?:\s*;|$)/i', $server['CONTENT_TYPE'] ?? '')) throw new RequestError(415, ['error'=>'json_required']);
        $maximum = $kind === 'feedback' ? 16384 : 32768;
        if (strlen($body) > $maximum || (int) ($server['CONTENT_LENGTH'] ?? 0) > $maximum) throw new RequestError(413, ['error'=>'payload_too_large']);
        try { $input = json_decode($body, false, 32, JSON_THROW_ON_ERROR); }
        catch (\JsonException) { throw new RequestError(400, ['error'=>'invalid_json']); }
        $payload = normalize($kind, $input);
        // REMOTE_ADDR is set by the web server; never trust client-supplied forwarding headers.
        $address = $server['REMOTE_ADDR'] ?? '';
        if (filter_var($address, FILTER_VALIDATE_IP) === false) throw new RequestError(503, ['error'=>'service_unavailable']);
        $store = new Store($storage, $documentRoot);
        return [201, $headers, $store->submit($kind, $payload, $address)];
    } catch (RequestError $error) {
        if ($error->status === 429) $headers['Retry-After'] = '900';
        if ($error->status === 405) $headers['Allow'] = 'POST, OPTIONS';
        return [$error->status, $headers, $error->response];
    } catch (\Throwable $error) {
        error_log('YouNew form storage temporarily unavailable');
        return [503, $headers, ['error'=>'service_unavailable']];
    }
}

function run(string $kind, string $storage): never
{
    ini_set('display_errors', '0');
    $maximum = $kind === 'feedback' ? 16384 : 32768;
    $body = file_get_contents('php://input', false, null, 0, $maximum + 1);
    $origins = ORIGINS;
    // An explicit isolated rehearsal may accept only this exact loopback origin.
    // Never accept arbitrary origins from request headers or forwarded headers.
    if (getenv('YOUNEW_LOCAL_REHEARSAL') === 'true') $origins[] = 'http://127.0.0.1:4198';
    [$status, $headers, $result] = handle($kind, $body === false ? '' : $body, $_SERVER, $storage, (string) ($_SERVER['DOCUMENT_ROOT'] ?? ''), $origins);
    http_response_code($status);
    foreach ($headers as $name=>$value) header($name . ': ' . $value);
    if ($result !== null) echo json_encode($result, JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
    exit;
}
