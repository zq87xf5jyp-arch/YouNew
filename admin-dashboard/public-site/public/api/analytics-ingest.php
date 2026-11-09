<?php
declare(strict_types=1);
ini_set('display_errors', '0');
$private = dirname(__DIR__, 2) . '/younew-private';
require $private . '/analytics-v1/service.php';
\YouNewAnalytics\run($private . '/analytics-data');
