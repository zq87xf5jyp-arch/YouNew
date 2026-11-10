<?php
declare(strict_types=1);
ini_set('display_errors', '0');
$private = dirname(__DIR__, 2) . '/younew-private';
require $private . '/forms-v1/service.php';
\YouNewForms\run('feedback', $private . '/forms-data');
