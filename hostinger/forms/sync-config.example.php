<?php
// PRIVATE example. Copy to sync-config.php outside public_html, chmod 0600.
// Generate a new key for the new backend; never copy a managed-project secret.
return [
    'url' => 'https://backend.example.invalid',
    'serviceKey' => 'REPLACE_PRIVATELY_WITH_NEW_BACKEND_SERVICE_ROLE_KEY',
    'documentRoot' => '/REPLACE_WITH_YOUR_SITE/public_html',
];
