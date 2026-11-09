# Hostinger forms

The public site submits business inquiries and feedback to its own PHP endpoints. PHP 8.3 with the built-in SQLite3 extension is sufficient; no paid service, Supabase connection, email delivery or scheduled process is required.

## Layout

Keep these directories beside each other in the domain's Hostinger File Manager:

```
public_html/api/submit-business-inquiry.php
public_html/api/submit-public-feedback.php
younew-private/forms-v1/service.php
younew-private/forms-data/              # created by PHP, never inside public_html
```

The private directory also has a deny-all `.htaccess`. The application rejects a storage path inside the document root. Never upload a database, inbox export, backup, or authentication material to `public_html`.

## Review received requests

Use the existing authenticated Hostinger File Manager. Open `younew-private/forms-data/inbox-latest.json` to review the newest 200 requests, including their receipt IDs, consent version, UTC creation time, and original language/source page. `total` is the number of all retained requests. The full authoritative store is `submissions.sqlite`; `submissions.snapshot.sqlite` is a consistent copy refreshed after each accepted submission. Download private files only to a trusted location. No public list or admin endpoint exists.

New requests are marked `new`. No email is sent and no business is automatically published. A saved request still needs the owner's review and follow-up. Entries containing `YN-QA` or `YouNew Synthetic QA` and `example.invalid` addresses are synthetic verification records; never contact or publish them. Existing Supabase records have not been moved or deleted. The existing admin dashboard continues to read its original source; new Hostinger requests are reviewed in File Manager.

## Validation and retention

The server accepts only JSON from the exact YouNew origins, validates the allowed fields and explicit consents, rejects the honeypot, limits body size, and deduplicates normalized submissions. Limits are 8 new submissions per 15-minute network window and 4 per hourly email window; identical retries return their original receipt. There is also a limit of 40 validated attempts per 15-minute network window. Counters use keyed hashes; raw client IP addresses are not stored in the request database. Expired counters are removed on the next transaction. Hosting access logs are managed separately by Hostinger.

The website privacy policy applies to retained requests. Retention and erasure are a manual operational responsibility; there is no scheduled deletion. Remove records only after confirming the affected request, and regenerate the private inbox/snapshot rather than leaving stale copies. Backups may retain older records until they expire.

## Backups and rollback

Hostinger daily backups are enabled. Verify that a selected backup contains `younew-private` before relying on it for forms recovery; do not assume a backup created before installation includes new submissions. A snapshot is on the same server and is not a substitute for a separately recoverable hosting backup.

For a frontend rollback, rename the current `public_html` aside and restore the previous saved public directory. Leave `younew-private/forms-data` untouched so requests survive. The pre-migration frontend uses Supabase endpoints; rolling back to it will restore that dependency. A backend rollback must keep the existing data directory and compatible schema. Never replace the production database with the synthetic QA database.

Tests in `tests.php` create only isolated synthetic temporary storage, verify validation, limits, duplicate receipts, exports, and snapshot restore, then clean that temporary storage. Run them with PHP 8.3 CLI. The temporary web QA entry is not part of the release and must be absent from the final public directory.
