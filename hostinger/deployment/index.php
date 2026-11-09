<?php
// PHP runs as the hosting account and can read the private 0600 credential file.
require '/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1/deployment/qa-access.php';
younewRequireQaAccess('/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1/qa-http.private.json');
putenv('YOUNEW_PUBLICATION_ROOT=/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1/publication');
require '/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1/kit/tools/integration-router.php';
