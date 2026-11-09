<?php
require dirname(__DIR__) . '/qa-access.php';
$credentials = ['user'=>'qa', 'password'=>str_repeat('a', 64)];
$cases = [
    [null, false], ['Basic !!!', false], ['Bearer anything', false],
    ['Basic ' . base64_encode('qa:' . str_repeat('a', 64)), true],
    ['Basic ' . base64_encode('qa:' . str_repeat('a', 63)), false],
    ['Basic ' . base64_encode('other:' . str_repeat('a', 64)), false],
    ['Basic ' . base64_encode('qa:' . str_repeat('a', 64) . ':suffix'), false],
    [str_repeat('a', 513), false],
];
foreach ($cases as [$header, $expected]) {
    if (younewQaBasicMatches($header, $credentials) !== $expected) throw new RuntimeException('Authentication boundary failed');
}
if (younewQaBasicMatches('Basic ' . base64_encode('qa:short'), ['user'=>'qa', 'password'=>'short'])) throw new RuntimeException('Weak config accepted');
echo "QA Basic credential boundary: 9 checks PASS\n";
