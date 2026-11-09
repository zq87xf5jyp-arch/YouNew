<?php
declare(strict_types=1);
require __DIR__ . '/service.php';

$business = [
    'companyName'=>'YouNew Synthetic QA', 'contactPerson'=>'Synthetic Reviewer', 'contactRole'=>'Owner',
    'offerInterest'=>'not_specified', 'email'=>'yn-qa@example.invalid', 'phone'=>'', 'website'=>'https://example.invalid',
    'inquiryType'=>'partnership', 'organizationType'=>'non-profit', 'kvkNumber'=>'', 'city'=>'Amsterdam', 'province'=>'North Holland',
    'targetAudience'=>['resident'], 'requestedPlacements'=>['verified-organization-profile'],
    'campaignGoal'=>'YN-QA synthetic website verification', 'budgetRange'=>'request-discussion', 'campaignStart'=>'', 'campaignEnd'=>'',
    'description'=>'YN-QA synthetic submission. No real person or business. Do not contact or publish.',
    'consentToPrivacy'=>true, 'confirmAccuracy'=>true, 'websiteConfirmation'=>'', 'sourcePage'=>'/for-business/local/apply/',
    'utmSource'=>'', 'utmMedium'=>'', 'utmCampaign'=>'', 'utmContent'=>'', 'utmTerm'=>''
];
$feedback = ['email'=>'yn-feedback@example.invalid', 'feedbackType'=>'product-problem', 'message'=>'YN-QA synthetic feedback for verifying private storage. No reply needed.', 'pageReference'=>'/support/', 'consentToPrivacy'=>true, 'websiteConfirmation'=>''];
if (($argv[1] ?? '') === '--fixtures') { echo json_encode(compact('business','feedback'), JSON_PRETTY_PRINT); exit; }

$root = sys_get_temp_dir() . '/yn-forms-' . bin2hex(random_bytes(6));
$public = $root . '/public_html';
mkdir($public, 0700, true);
$directory = $root . '/private';
$server = ['HTTP_ORIGIN'=>'https://younew.nl', 'REQUEST_METHOD'=>'POST', 'CONTENT_TYPE'=>'application/json', 'REMOTE_ADDR'=>'192.0.2.10'];
$tests = [];
function verify(string $name, bool $condition): void { global $tests; if (!$condition) throw new RuntimeException('FAIL: ' . $name); $tests[] = $name; }
function callForm(string $kind, mixed $data, array $overrides = [], ?string $raw = null, ?string $store = null): array {
    global $server, $directory, $public;
    return \YouNewForms\handle($kind, $raw ?? json_encode($data, JSON_THROW_ON_ERROR), array_replace($server, $overrides), $store ?? $directory, $public);
}

verify('untrusted origin', callForm('business',$business,['HTTP_ORIGIN'=>'https://evil.example'])[0] === 403);
verify('missing origin', callForm('business',$business,['HTTP_ORIGIN'=>''])[0] === 403);
verify('no public GET inbox', callForm('business',$business,['REQUEST_METHOD'=>'GET'])[0] === 405);
verify('no PUT or DELETE', callForm('business',$business,['REQUEST_METHOD'=>'DELETE'])[0] === 405);
verify('preflight has no database side effects', callForm('business',$business,['REQUEST_METHOD'=>'OPTIONS'])[0] === 204 && !is_dir($directory));
verify('JSON media type required', callForm('business',$business,['CONTENT_TYPE'=>'text/plain'])[0] === 415);
verify('malformed JSON', callForm('business',null,[], '{bad')[0] === 400);
verify('actual body cap', callForm('business',null,[],str_repeat('x',32769))[0] === 413);
verify('declared body cap', callForm('business',$business,['CONTENT_LENGTH'=>'999999'])[0] === 413);
verify('feedback actual body cap', callForm('feedback',null,[],str_repeat('x',16385))[0] === 413);
foreach ([['consentToPrivacy',false],['consentToPrivacy','true'],['confirmAccuracy',false],['companyName',[]],['contactPerson',''],['websiteConfirmation','spam'],['organizationType','invented'],['targetAudience',['resident','resident']],['requestedPlacements',['invented']],['campaignStart','2026-02-30'],['sourcePage','/untrusted/'],['description',str_repeat('x',601)],['website','javascript:alert(1)'],['website','https://username:password@example.invalid'],['email',"person@example.invalid\nBcc: x@x.invalid"],['utmTerm',str_repeat('x',161)]] as [$key,$value]) {
    verify('reject invalid '.$key.' '.count($tests), callForm('business',array_replace($business,[$key=>$value]))[0] === 400);
}
verify('unknown fields are not retained', callForm('business',$business+['admin'=>true])[0] === 400);
verify('object required', callForm('business',[])[0] === 400);
verify('no public storage after invalid requests', !is_dir($directory));
verify('Kvk required for commercial companies', callForm('business',array_replace($business,['organizationType'=>'commercial-business']))[0] === 400);

[$status,$headers,$receipt] = callForm('business',$business);
verify('valid inquiry stored', $status === 201 && preg_match('/^YNI-[A-F0-9]{12}$/D',$receipt['confirmationId']) === 1);
verify('cache disabled', $headers['Cache-Control'] === 'no-store, max-age=0');
verify('no body or contact details in receipt', array_keys($receipt) === ['confirmationId','createdAt']);
$duplicate = callForm('business',$business);
verify('retry returns same stored receipt', $duplicate[0] === 201 && $duplicate[2] === $receipt);
$db = new SQLite3($directory.'/submissions.sqlite');
verify('one row after retry', $db->querySingle('SELECT COUNT(*) FROM submissions') === 1);
verify('storage file private', (fileperms($directory.'/submissions.sqlite') & 0777) === 0600);
verify('storage directory private', (fileperms($directory) & 0777) === 0700);
$stored = $db->querySingle('SELECT payload FROM submissions');
verify('network address not stored with inquiry', !str_contains($stored,'192.0.2.10'));
verify('honeypot not stored', !str_contains($stored,'websiteConfirmation'));
verify('consent version recorded', $db->querySingle('SELECT consent_version FROM submissions') === \YouNewForms\CONSENT_VERSION);
$inbox = json_decode(file_get_contents($directory.'/inbox-latest.json'), true);
verify('private review export matches receipt', $inbox['total'] === 1 && $inbox['latest'][0]['id'] === $receipt['confirmationId']);
unlink($directory.'/inbox-latest.json');
verify('retry repairs review export', callForm('business',$business)[0] === 201 && is_file($directory.'/inbox-latest.json'));

$nl = array_replace($business,['sourcePage'=>'/nl/voor-bedrijven/aanmelden/','description'=>'YN-QA synthetische aanvraag voor de Nederlandse route. Niet publiceren of beantwoorden.']);
verify('NL source accepted', callForm('business',$nl)[0] === 201);
[$feedbackStatus,,$feedbackReceipt] = callForm('feedback',$feedback);
verify('feedback persisted', $feedbackStatus === 201 && str_starts_with($feedbackReceipt['confirmationId'],'YNF-'));
verify('feedback retries are idempotent', callForm('feedback',$feedback)[2] === $feedbackReceipt);
verify('feedback invalid privacy consent', callForm('feedback',array_replace($feedback,['consentToPrivacy'=>false]))[0] === 400);
verify('feedback rejects external reference', callForm('feedback',array_replace($feedback,['pageReference'=>'//evil.example/']))[0] === 400);

// A separate feedback backlog must never starve the BUSINESS worker.
$queue = new \YouNewForms\Store($directory, $public);
verify('mixed outbox is retained', count($queue->pendingDeliveries()) === 3);
verify('business outbox excludes feedback', count($queue->pendingDeliveries(100, 'business')) === 2);
verify('feedback remains available separately', count($queue->pendingDeliveries(100, 'feedback')) === 1);
$rejectedKind = false;
try { $queue->pendingDeliveries(20, 'unknown'); } catch (InvalidArgumentException) { $rejectedKind = true; }
verify('invalid outbox type refused', $rejectedKind);
$backlog = new \YouNewForms\Store($root.'/mixed-backlog', $public);
for ($i=0;$i<21;$i++) $backlog->submit('feedback', array_replace($feedback, ['email'=>'backlog-'.$i.'@example.invalid']), '192.0.2.'.($i+100));
$businessAfterFeedback = $backlog->submit('business', $business, '192.0.2.200');
verify('generic first batch contains only older feedback', count(array_filter($backlog->pendingDeliveries(20), static fn($r)=>$r['kind']==='business')) === 0);
$businessBatch = $backlog->pendingDeliveries(20, 'business');
verify('business behind feedback backlog is delivered in first business batch', count($businessBatch) === 1 && $businessBatch[0]['id'] === $businessAfterFeedback['confirmationId']);
verify('all feedback remains retained', count($backlog->pendingDeliveries(100, 'feedback')) === 21);

// Dedicated data directories exercise rate limits without altering other tests.
for ($i=0;$i<8;$i++) verify('network allows bounded new request '.$i, callForm('business',array_replace($business,['email'=>'net-'.$i.'@example.invalid']),[],null,$root.'/network')[0] === 201);
verify('network new-request limit', callForm('business',array_replace($business,['email'=>'net-over@example.invalid']),[],null,$root.'/network')[0] === 429);
for ($i=0;$i<4;$i++) verify('email bounded request '.$i, callForm('business',array_replace($business,['companyName'=>'YN-QA '.$i]),['REMOTE_ADDR'=>'192.0.2.'.($i+20)],null,$root.'/email')[0] === 201);
verify('email limit across network addresses', callForm('business',array_replace($business,['companyName'=>'YN-QA over']),['REMOTE_ADDR'=>'192.0.2.99'],null,$root.'/email')[0] === 429);
for ($i=0;$i<40;$i++) verify('bounded retry '.$i, callForm('feedback',$feedback,[],null,$root.'/attempts')[0] === 201);
verify('repeated attempts eventually limited', callForm('feedback',$feedback,[],null,$root.'/attempts')[0] === 429);

$refusedPublicStorage = false;
try { new \YouNewForms\Store($public.'/unsafe', $public); }
catch (RuntimeException) { $refusedPublicStorage = true; }
verify('private path enforcement', $refusedPublicStorage);
copy($directory.'/submissions.snapshot.sqlite',$root.'/restored.sqlite');
$restored = new SQLite3($root.'/restored.sqlite');
verify('isolated snapshot restore integrity', $restored->querySingle('PRAGMA integrity_check') === 'ok');
verify('isolated snapshot restore retains all receipts', $restored->querySingle('SELECT COUNT(*) FROM submissions') === 3);
verify('restored receipt found', $restored->querySingle("SELECT COUNT(*) FROM submissions WHERE id='".$receipt['confirmationId']."'") === 1);
$db->close();
$restored->close();
// Only this invocation's randomly named synthetic-test directory is removed.
$removeTestTree = static function (string $path) use (&$removeTestTree): void {
    foreach (scandir($path) as $name) {
        if ($name === '.' || $name === '..') continue;
        $file = $path . '/' . $name;
        if (is_dir($file) && !is_link($file)) $removeTestTree($file); else unlink($file);
    }
    rmdir($path);
};
$removeTestTree($root);
echo json_encode(['passed'=>count($tests),'tests'=>$tests],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),"\n";
