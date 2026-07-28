-- Public buckets serve object URLs without a storage.objects SELECT policy.
-- Keep object listing available only to approved editorial roles.

drop policy if exists "public reads content images" on storage.objects;
drop policy if exists "approved editors list content images" on storage.objects;
create policy "approved editors list content images"
on storage.objects for select
to authenticated
using (
  bucket_id = 'content-images'
  and (select private.current_admin_role()) in ('owner', 'admin', 'editor')
);

-- Cover production foreign keys used by Admin and operational workflows.

create index if not exists articles_reviewer_id_idx
  on public.articles (reviewer_id);

create index if not exists business_inquiries_handled_by_idx
  on public.business_inquiries (handled_by);

create index if not exists deployment_status_created_by_idx
  on public.deployment_status (created_by);

create index if not exists deployment_status_service_id_idx
  on public.deployment_status (service_id);

create index if not exists feedback_resolved_by_idx
  on public.feedback (resolved_by);

create index if not exists published_content_artifacts_created_by_idx
  on public.published_content_artifacts (created_by);

create index if not exists sync_jobs_initiator_idx
  on public.sync_jobs (initiator);
