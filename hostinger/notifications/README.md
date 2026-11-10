# Hostinger service notifications

Private CLI worker for `support@younew.nl`. It sends counts of new delivered
BUSINESS inquiries and health state changes, with links to Admin. It never reads
inquiry payloads, sends to submitters, or uses an external paid service.

Copy the worker and a mode-0600 config outside public_html. Set the state directory
to mode 0700. `php worker.php config.json init` records existing receipts as a
baseline, so historical inquiries are not mailed. `probe` queues one idempotent
installation check. A scheduler invokes `run` every five minutes. Only the private
notification SQLite database changes; the production form queue is read-only.

One digest per invocation, at least 60 seconds between attempts, at most 24 attempts
per rolling day. A rejected mail submission backs off up to four attempts. A crash
during submission becomes `uncertain`, requiring operator inspection before any
manual retry. A true PHP mail result means accepted by the local mailer, not proof
of mailbox delivery. Verify the installation probe in the destination mailbox.

Hostinger's published built-in sending limit is 10/minute and 100/day, shared with
other scripts. These worker limits leave headroom but cannot reserve shared quota.
Source: https://www.hostinger.com/support/6976044-parameters-and-limits-of-hosting-plans-in-hostinger/

Health is read from the existing private monitor; stale output after 25 minutes
also raises an alert. Complete Hostinger/server failure prevents this same-host
worker from sending. It is not independent external outage monitoring. SMS has no
confirmed included transport and remains disabled. No email auto-renewal changes.

Rollback: create `PAUSED` in the private state directory and disable only this
worker's cron entry. Keep its SQLite ledger for deduplication and recovery; never
reset it or reinitialize against the production queue. Existing BUSINESS delivery,
analytics and health jobs are independent.

Run `python3 test-worker.py` for isolated SQLite/PHP integration checks. The test
uses capture/reject transports only and never sends real mail.
