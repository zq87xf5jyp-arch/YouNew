create policy "deny all direct business inquiry rate-limit access"
on private.business_inquiry_rate_limits
for all
to public
using (false)
with check (false);