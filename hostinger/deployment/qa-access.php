<?php
declare(strict_types=1);

function younewQaBasicMatches(?string $header, array $credentials): bool
{
    if (!is_string($header) || strlen($header) > 512 || !str_starts_with($header, 'Basic ')) return false;
    $decoded = base64_decode(substr($header, 6), true);
    if ($decoded === false || !str_contains($decoded, ':')) return false;
    [$user, $password] = explode(':', $decoded, 2);
    $expectedUser = $credentials['user'] ?? null;
    $expectedPassword = $credentials['password'] ?? null;
    return is_string($expectedUser) && is_string($expectedPassword) && strlen($expectedPassword) >= 64
        && hash_equals($expectedUser, $user)
        && hash_equals(hash('sha256', $expectedPassword), hash('sha256', $password));
}

function younewRequireQaAccess(string $credentialFile): void
{
    header('Cache-Control: no-store, max-age=0');
    header('X-Robots-Tag: noindex, nofollow, noarchive');
    header('X-Content-Type-Options: nosniff');
    if (($_SERVER['HTTP_HOST'] ?? '') !== 'qa-catalog.younew.nl') {
        http_response_code(403); exit;
    }
    // The file endpoint independently verifies its HMAC, timestamp and nonce.
    if (parse_url($_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH) === '/private-files.php') return;
    try {
        if (is_link($credentialFile) || !is_file($credentialFile) || (fileperms($credentialFile) & 0077)) throw new RuntimeException();
        $credentials = json_decode(file_get_contents($credentialFile), true, 4, JSON_THROW_ON_ERROR);
        if (!is_array($credentials)) throw new RuntimeException();
    } catch (Throwable $error) {
        http_response_code(503); echo 'QA access configuration unavailable.'; exit;
    }
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? null;
    if ($header === null && isset($_SERVER['PHP_AUTH_USER'], $_SERVER['PHP_AUTH_PW'])) {
        $header = 'Basic ' . base64_encode($_SERVER['PHP_AUTH_USER'] . ':' . $_SERVER['PHP_AUTH_PW']);
    }
    if (!younewQaBasicMatches($header, $credentials)) {
        header('WWW-Authenticate: Basic realm="YouNew isolated acceptance", charset="UTF-8"');
        http_response_code(401); echo 'QA authentication required.'; exit;
    }
}
